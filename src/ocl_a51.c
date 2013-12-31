/*
 * ocl_a51.c
 *
 * hashkill - a hash cracking tool
 * Copyright (C) 2013 Milen Rangelov <gat3way@gat3way.eu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <stdint.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"
#include "x86intrin.h"


static int MAXFOUNDLOCAL=MAXFOUND;


inline int amdpopcnt(uint64_t x) __attribute__((always_inline));

inline int amdpopcnt(uint64_t x)
{
      asm ("lzcnt %0, %0" : "=r" (x) : "0" (x));
      return (int) x;
}

#define clzll(x) __builtin_clzll((x))
//#define clzll(x) amdpopcnt((x))


/* Masks for the three shift registers */
#define R1MASK  0x07FFFF /* 19 bits, numbered 0..18 */
#define R2MASK  0x3FFFFF /* 22 bits, numbered 0..21 */
#define R3MASK  0x7FFFFF /* 23 bits, numbered 0..22 */

/* Middle bit of each of the three shift registers, for clock control */
#define R1MID   0x000100 /* bit 8 */
#define R2MID   0x000400 /* bit 10 */
#define R3MID   0x000400 /* bit 10 */

/* Feedback taps, for clocking the shift registers.
 * These correspond to the primitive polynomials
 * x^19 + x^5 + x^2 + x + 1, x^22 + x + 1,
 * and x^23 + x^15 + x^2 + x + 1. */
#define R1TAPS  0x072000 /* bits 18,17,16,13 */
#define R2TAPS  0x300000 /* bits 21,20 */
#define R3TAPS  0x700080 /* bits 22,21,20,7 */

/* Output taps, for output generation */
#define R1OUT   0x040000 /* bit 18 (the high bit) */
#define R2OUT   0x200000 /* bit 21 (the high bit) */
#define R3OUT   0x400000 /* bit 22 (the high bit) */

typedef unsigned char byte;
typedef uint64_t word;
typedef word bit;
int frameno = 0;


bit parityf(word x) {
        x ^= x>>32;
        x ^= x>>16;
        x ^= x>>8;
        x ^= x>>4;
        x ^= x>>2;
        x ^= x>>1;
        return x&1;
}

/* Calculate the parity of a 32-bit word, i.e. the sum of its bits modulo 2 */
bit parity(word x) {
	x = x&0xFFFFFFFF;
        x ^= x>>16;
        x ^= x>>8;
        x ^= x>>4;
        x ^= x>>2;
        x ^= x>>1;
        return x&1;
}

/* Clock one shift register */
word clockone(word reg, word mask, word taps) {
        word t = reg & taps;
        reg = (reg << 1) &mask;
        reg |= parity(t);
        return reg;
}//4 (bitalign)


static __thread word R1, R2, R3;
static __thread word RRR1, RRR2, RRR3;
static __thread int acl,bcl, ccl;

#define popcnt(i) (__builtin_popcountl(i))


static byte ks[128];
static __thread uint64_t mback1[250];
static __thread uint64_t mback2[250];
static __thread uint64_t mback3[250];

static uint64_t cas[64];
static uint64_t cbs[64];
static uint64_t ccs[64];
static uint64_t tas[64];
static uint64_t tbs[64];
static uint64_t tcs[64];

static uint64_t sta[19];
static uint64_t stb[22];
static uint64_t stc[23];

static __thread int64_t counter;
static __thread int __th_self=0;
static int hash_ret_len1=8;

static cl_ulong crack_vectors[HASHKILL_MAXTHREADS][16*4096+16];
static __thread int crack_counts;


static __thread cl_command_queue queue;
static __thread cl_mem hashes_buf;
static __thread cl_kernel kernel;
static __thread unsigned char *hashes;
static __thread cl_mem input_buf;
static __thread cl_mem found_buf;
size_t global_work_size[3];
size_t nvidia_local_work_size[3]={64,1,0};
size_t amd_local_work_size[3]={64,1,0};
static __thread size_t *local_work_size;


/* Look at the middle bits of R1,R2,R3, take a vote, and
 * return the majority value of those 3 bits. */
bit majority() {
        int sum;
        sum = parity(R1&R1MID) + parity(R2&R2MID) + parity(R3&R3MID);
        if (sum >= 2)
                return 1;
        else
                return 0;
}//8


bit majorityf() {
        int sum;
        sum = parity(RRR1&R1MID) + parity(RRR2&R2MID) + parity(RRR3&R3MID);
        if (sum >= 2)
                return 1;
        else
                return 0;
}//8

/* Clock two or three of R1,R2,R3, with clock control
 * according to their middle bits.
 * Specifically, we clock Ri whenever Ri's middle bit
 * agrees with the majority value of the three middle bits.*/
void _clock() {
        bit maj = majority();
        if (((R1&R1MID)!=0) == maj)
                R1 = clockone(R1, R1MASK, R1TAPS);
        if (((R2&R2MID)!=0) == maj)
                R2 = clockone(R2, R2MASK, R2TAPS);
        if (((R3&R3MID)!=0) == maj)
                R3 = clockone(R3, R3MASK, R3TAPS);
        //printf("clock,R1=%08x R2=%08x R3=%08x\n",R1,R2,R3);

}// 8+12+3=23


void _clockf() {
        bit maj = majorityf();
        if (((RRR1&R1MID)!=0) == maj)
                RRR1 = clockone(RRR1, R1MASK, R1TAPS);
        if (((RRR2&R2MID)!=0) == maj)
                RRR2 = clockone(RRR2, R2MASK, R2TAPS);
        if (((RRR3&R3MID)!=0) == maj)
                RRR3 = clockone(RRR3, R3MASK, R3TAPS);
}// 8+12+3=23


/* Clock all three of R1,R2,R3, ignoring their middle bits.
 * This is only used for key setup. */
void clockallthree() {
        R1 = clockone(R1, R1MASK, R1TAPS);
        R2 = clockone(R2, R2MASK, R2TAPS);
        R3 = clockone(R3, R3MASK, R3TAPS);
        //printf("clockallthree,R1=%08x R2=%08x R3=%08x\n",R1,R2,R3);
}

/* Generate an output bit from the current state.
 * You grab a bit from each register via the output generation taps;
 * then you XOR the resulting three bits. */
bit getbit() {
        int a= parity(R1&R1OUT)^parity(R2&R2OUT)^parity(R3&R3OUT);
        //printf("getbit=%d,R1=%08x R2=%08x R3=%08x\n",a,R1,R2,R3);
        return a;
}
// 10

bit getbitf() {
        int a= parity(RRR1&R1OUT)^parity(RRR2&R2OUT)^parity(RRR3&R3OUT);
        //printf("getbit=%d,R1=%08x R2=%08x R3=%08x\n",a,RRR1,RRR2,RRR3);
        return a;
}
// 10

uint64_t unmixkey_reverse(uint64_t r)
{
  uint64_t r1 = r;
  uint64_t r2 = 0;
  int j;
 
  for (j = 0; j < 64 ; j++ ) 
  {
    r2 = (r2<<1) | (r1 & 0x01);
    r1 = r1 >> 1;
  }
  return r2;
}


uint64_t unmixframe_reverse(uint64_t r)
{
  uint64_t r1 = r;
  uint64_t r2 = 0;
  int j;
 
  for (j = 0; j < 23 ; j++ ) 
  {
    r2 = (r2<<1) | (r1 & 0x01);
    r1 = r1 >> 1;
  }
  return r2;
}



uint64_t unmixkey(uint64_t cand)
{
    uint64_t lfsr1[19];
    uint64_t lfsr2[22];
    uint64_t lfsr3[23];
    uint64_t mMat1[64];
    uint64_t mMat2[64];
    uint64_t mMat3[64];
    uint64_t clock_in = 1;
    int i,j,k;

    for (i=0; i<19; i++) lfsr1[i]=0ULL;
    for (i=0; i<22; i++) lfsr2[i]=0ULL;
    for (i=0; i<23; i++) lfsr3[i]=0ULL;


    for (i=0; i<64; i++) 
    {

        uint64_t feedback1 = lfsr1[13]^lfsr1[16]^lfsr1[17]^lfsr1[18];
        uint64_t feedback2 = lfsr2[20]^lfsr2[21];
        uint64_t feedback3 = lfsr3[7]^lfsr3[20]^lfsr3[21]^lfsr3[22];

        for (j=18; j>0; j--) lfsr1[j]=lfsr1[j-1];
        for (j=21; j>0; j--) lfsr2[j]=lfsr2[j-1];
        for (j=22; j>0; j--) lfsr3[j]=lfsr3[j-1];

        lfsr1[0] = feedback1^clock_in;
        lfsr2[0] = feedback2^clock_in;
        lfsr3[0] = feedback3^clock_in;
        mMat1[i] = clock_in;
        clock_in = clock_in + clock_in;

    }
   for (i=0; i<19; i++) mMat2[i]    = lfsr1[i];
    for (i=0; i<22; i++) mMat2[i+19] = lfsr2[i];
    for (i=0; i<23; i++) mMat2[i+41] = lfsr3[i];
    for (i=0; i<64; i++) mMat3[i] = mMat2[i];


    /* elimination */
    uint64_t b = 1ULL;
    for (i=0; i<64; i++) 
    {
        for (j=i; j<64; j++) 
        {
            if (i==j) 
            {
                if((mMat3[j]&b)==0) 
                {
                    int found = 0;
                    for(k=j; k<64; k++) 
                    {
                        if (mMat3[k]&b) 
                        {
                            mMat3[j] = mMat3[j] ^ mMat3[k];
                            mMat1[j] = mMat1[j] ^ mMat1[k];
                            found = 1;
                            break;
                        }
                    }
                    if (!found) 
                    {
                        printf("ERROR!\n");
                        return 0;
                    }
                }
            } 
            else
            {
                if (mMat3[j]&b) 
                {
                    mMat3[j] = mMat3[j] ^ mMat3[i];
                    mMat1[j] = mMat1[j] ^ mMat1[i];
                }
            }
        }
        b = b << 1;
    }


    /* elimination */
    b = 1ULL;
    for (i=0; i<64; i++) 
    {
        for (j=(i-1); j>=0; j--) 
        {
            if (mMat3[j]&b) 
            {
                // printf("Eliminate(2) %i -> %i\n", i, j);
                mMat3[j] = mMat3[j] ^ mMat3[i];
                mMat1[j] = mMat1[j] ^ mMat1[i];
            }
        }
        b = b << 1;
    }
   //keyunmix
    uint64_t out = 0;

    b = 1;
    for (i=0; i< 64; i++) 
    {
        out = (out<<1) | parityf(cand&mMat1[i]);
    }

    return unmixkey_reverse(out);
}



uint64_t unmixframe(uint64_t cand)
{
    uint64_t out;
    int i;
    unsigned lfsr1 = cand & 0x7ffff;
    unsigned lfsr2 = (cand>>19) & 0x3fffff;
    unsigned lfsr3 = (cand>>41) & 0x7fffff;

    for (i=0; i< 22; i++) {
        unsigned int bit = frameno >> (21-i);

        /* Clock the different lfsr - backwards */
        unsigned int low = ((lfsr1 & 0x01) ^ bit)<<31;
        lfsr1 = lfsr1 >> 1;
        unsigned int val = (lfsr1&0x52000)*0x4a000;
        val ^= lfsr1<<(31-17);
        val = val & 0x80000000;
        lfsr1 = lfsr1 | ((val^low)>>(31-18));

        low = ((lfsr2 & 0x01) ^ bit)<<31;
        lfsr2 = lfsr2 >> 1;
        val = (lfsr2&0x300000)*0xc00;
        val = val & 0x80000000;
        lfsr2 = lfsr2 | ((val^low)>>(31-21));

        low = ((lfsr3 & 0x01) ^ bit)<<31;
        lfsr3 = lfsr3 >> 1;
        val = (lfsr3&0x500080)*0x1000a00;
        val ^= lfsr3<<(31-21);
        val = val & 0x80000000;
        lfsr3 = lfsr3 | ((val^low)>>(31-22));

    }

    out = (uint64_t)lfsr1 | ((uint64_t)lfsr2<<19) | ((uint64_t)lfsr3<<41);
    return out;
}



void fillback(uint64_t final)
{
    int i;
    uint64_t lfsr1 = final & 0x7ffff;
    uint64_t lfsr2 = (final>>19) & 0x3fffff;
    uint64_t lfsr3 = (final>>41) & 0x7fffff;

    /* precalculate MAX_STEPS backwards clockings of all lfsrs */
    for (i=0; i<250; i++) 
    {
        mback1[i] = lfsr1 & 0x7ffff;
        uint64_t bit = lfsr1 ^ (lfsr1>>18) ^ (lfsr1>>17) ^ (lfsr1>>14);
        lfsr1 = (lfsr1>>1) | ((bit&0x01)<<18);
    }

    for (i=0; i<250; i++) 
    {
        mback2[i] = (lfsr2 & 0x3fffff)<<19;
        uint64_t bit = lfsr2 ^ (lfsr2>>21);
        lfsr2 = (lfsr2>>1) | ((bit&0x01)<<21);
    }

    for (i=0; i<250; i++) 
    {
        mback3[i] = (lfsr3 & 0x7fffff)<<41;
        uint64_t bit = lfsr3 ^ (lfsr3>>22) ^ (lfsr3>>21) ^ (lfsr3>>8);
        lfsr3 = (lfsr3>>1) | ((bit&0x01)<<22);
    }

    unsigned int wlfsr1 = lfsr1;
    unsigned int wlfsr2 = lfsr2;
    unsigned int wlfsr3 = lfsr3;
    for (i=0; i<250; i++) 
    {
        unsigned int val = (wlfsr1&0x52000)*0x4a000;
        val ^= wlfsr1<<(31-17);
        wlfsr1 = 2*wlfsr1 | (val>>31);

        val = (wlfsr2&0x300000)*0xc00;
        wlfsr2 = 2*wlfsr2 | (val>>31);

        val = (wlfsr3&0x500080)*0x1000a00;
        val ^= wlfsr3<<(31-21);
        wlfsr3 = 2*wlfsr3 | (val>>31);
    }
    wlfsr1 = wlfsr1 & 0x7ffff;
    wlfsr2 = wlfsr2 & 0x3fffff;
    wlfsr3 = wlfsr3 & 0x7fffff;

    // do not cmp
    //uint64_t cmp = (uint64_t)wlfsr1 | ((uint64_t)wlfsr2<<19) | ((uint64_t)wlfsr3<<41);
}



uint64_t forward(uint64_t start, int steps)
{
    int i;
    unsigned int lfsr1 = start & 0x7ffff;
    unsigned int lfsr2 = (start>>19) & 0x3fffff;
    unsigned int lfsr3 = (start>>41) & 0x7fffff;

    for (i=0; i<steps; i++) 
    {
        int count = ((lfsr1>>8)&0x01);
        count += ((lfsr2>>10)&0x01);
        count += ((lfsr3>>10)&0x01);
        count = count >> 1;

        if (((lfsr1>>8)&0x01)==count) 
        {
            unsigned int val = (lfsr1&0x52000)*0x4a000;
            val ^= lfsr1<<(31-17);
            lfsr1 = 2*lfsr1 | (val>>31);
        }
        if (((lfsr2>>10)&0x01)==count) 
        {
            unsigned int val = (lfsr2&0x300000)*0xc00;
            lfsr2 = 2*lfsr2 | (val>>31);
        }
        if (((lfsr3>>10)&0x01)==count) 
        {
            unsigned int val = (lfsr3&0x500080)*0x1000a00;
            val ^= lfsr3<<(31-21);
            lfsr3 = 2*lfsr3 | (val>>31);
        }
    }
    lfsr1 = lfsr1 & 0x7ffff;
    lfsr2 = lfsr2 & 0x3fffff;
    lfsr3 = lfsr3 & 0x7fffff;
    uint64_t res = (uint64_t)lfsr1 | ((uint64_t)lfsr2<<19) | ((uint64_t)lfsr3<<41);
    return res;
}



void clockback(uint64_t final, int steps, int o1, int o2, int o3)
{
    int i,j,k;

    if (steps>248) return;
    if (steps<0) return;
    if ((o1+o2+o3)==0) fillback(final);

    int todo=(steps>20) ? 20 : steps;
    int limit = 2*todo;
    int consider=0;

    for (i=0;i<=todo;i++)
    {
        for (j=0;j<=todo;j++)
        {
            for (k=0;k<=todo;k++)
            {
                if ((i+j+k)<limit) continue;
                consider++;
                uint64_t test = mback1[o1+i] + mback2[o2+j] + mback3[o3+k];
                uint64_t res = forward(test,todo);
                if (res==final)
                {
                    int remain = steps-todo;
                    if (remain>0)
                    {
                        clockback(test,remain,o1+i,o2+j,o3+k);
                    }
                    else
                    {
			// UNCOMMENT!!!
			attack_over=1;

			//pthread_mutex_lock(&biglock);
//                    	printf("CANDIDATE CLOCKBACK: %016llx\n",test);
                    	uint64_t cand = unmixframe(test);
//                    	printf("CANDIDATE UNMIXFRAME: %016llx\n",cand);
                    	uint64_t cand1 = unmixkey(cand);
//                    	printf("CANDIDATE KEY: %016llx\n",cand1);
                    	char rawhash[18];
			char raw[8];
			memcpy(raw,&cand1,8);
			char tmp;
			tmp=raw[0];
			raw[0]=raw[7];
			raw[7]=tmp;
			tmp=raw[1];
			raw[1]=raw[6];
			raw[6]=tmp;
			tmp=raw[2];
			raw[2]=raw[5];
			raw[5]=tmp;
			tmp=raw[3];
			raw[3]=raw[4];
			raw[4]=tmp;
                    	str2hex(raw,rawhash, 8);
			struct hash_list_s *hl = cracked_list;
			int flag=0;
			while (hl)
			{
				if (memcmp(hl->salt2,rawhash,16)==0) flag=1;
				hl = hl->next;
			}
                    	if (!flag) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, rawhash);
			//pthread_mutex_unlock(&biglock);
                    }
                }
            }
        }
    }
}


int checkforwardpre(uint64_t cand)
{
    int a;
    byte st[8];

    st[0]=st[1]=st[2]=st[3]=st[4]=st[5]=st[6]=st[7]=0;
    for (a=0;a<32;a++)
    {
        _clockf();
        st[a/8] |= (getbitf()<<(7-(a&7)));
    }
    if (memcmp(ks,st,4)==0) 
    {
        printf("PRESUCCESS! cand=%016llx\n",cand);
        return 1;
    }
    return 0;
}


int checkforward(uint64_t cand)
{
    int a;
    byte st[8];

    st[0]=st[1]=st[2]=st[3]=st[4]=st[5]=st[6]=st[7]=0;
    for (a=0;a<64;a++)
    {
        _clockf();
        st[a/8] |= (getbitf()<<(7-(a&7)));
    }
    if (memcmp(ks,st,8)==0) 
    {
//        printf("FORWARD SUCCESS! cand=%016llx\n",cand);
        return 1;
    }
    return 0;
}


/*
static void brute_recursive_1 (uint64_t cand, uint64_t *vectors, int bits, int level)
{
    if (bits==level)
    {
	if (attack_over!=0) pthread_exit(NULL);
	if ((attack_over)||(cracked_list))
	{
    	    pthread_exit(NULL);
	}
	wthreads[__th_self].tries++;

        RRR1=cand&R1MASK;
        RRR2=(cand>>9)&(R2MASK);
        RRR3=(cand>>20)&(R3MASK);
        //printf("%08x/%08x %08x/%08x %08x/%08x\n",RRR1,RR1,RRR2,RR2,RRR3,RR3);

        if (checkforwardpre(cand))
        if (checkforward(cand))
        {
            clockback(cand,100,0,0,0);
        }
        return;
    }

    cand ^= vectors[level];
    brute_recursive_1(cand,vectors,bits,level+1);
    cand ^= vectors[level];
    brute_recursive_1(cand,vectors,bits,level+1);
}
*/






static void bruteforce(uint64_t *vec, uint64_t sol)
{
    uint64_t a,b,d,j,k,l;
    uint64_t vec2[64];
    // NBITS
    uint64_t free[16];
    uint64_t vfree=0ULL;
    uint64_t sol2;
    int self = __th_self;
    int base = crack_counts*16;
    cl_uint found;

    sol2=0;
    // Convert to parametric form.
    k=0;
    for (b=0;b<51;b++)
    {
        if ((vec[b]!=0))
        {
            l=(63ULL-clzll(vec[b]));
            j = (sol>>b)&1ULL;
            vec2[l]=vec[b]^(1ULL<<l);
            sol2^=(j<<l);
            k|=(1ULL<<l);
        }
    }


    // Identify free variables
    d=0;
    for (a=0;a<64;a++) if (((k>>a)&1ULL)==0ULL)
    {
        vec2[a]=(1ULL<<a);
        free[d]=a;
	vfree^=(1ULL<<a);
        d++;
    }

    //NBITS
    for (a=d;a<13;a++) free[d]=64ULL;


    // Perform elimination
    for (a=0;a<64;a++)
    {
        uint64_t p=(vec2[a]&(~vfree));
        while (p!=0ULL)
        {
            unsigned int q = (63-clzll(p));
            vec2[a]^=vec2[q];
            vec2[a]^=(1ULL<<(uint64_t)q);
            sol2 ^= (((sol2>>(uint64_t)q)&1ULL)<<a);
            p^=(1ULL<<(uint64_t)q);
        }
    }

    // Find the vectors that hold the solutions to the system
    // NBITS
    for (a=0;a<13;a++)
    {
        uint64_t p=0ULL;
        if (free[a]<64) for (b=0;b<64;b++)
            if (((vec2[b]>>(uint64_t)free[a])&1ULL))
            {
                p^=(1ULL<<b);
            }
	crack_vectors[self][base+a]=p;
    }
    crack_vectors[self][base+13] = sol2;
    crack_vectors[self][base+14] = 0;
    crack_vectors[self][base+15] = 0;
    crack_counts++;
    if (crack_counts==4096)
    {
	if ((attack_over)||(cracked_list))
	{
    	    pthread_exit(NULL);
	}
	// GPU crack
	_clEnqueueWriteBuffer(queue, input_buf, CL_FALSE, 0, 4096*16*8, &crack_vectors[self][0], 0, NULL, NULL);
	_clEnqueueNDRangeKernel(queue, kernel, 1, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	_clEnqueueReadBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	if ((found)>0) 
	{
	    if ((found)>MAXFOUND) (found)=MAXFOUND;
    	    _clEnqueueReadBuffer(queue, hashes_buf, CL_TRUE, 0, (found)*8, hashes, 0, NULL, NULL);
    	    int cnt;
    	    for (cnt=0;cnt<(found);cnt++) 
    	    {
    	        uint64_t cand;
    	        memcpy(&cand,hashes+(cnt*8),8);
    	        RRR1=(cand&R1MASK);
    		RRR2=(cand>>19ULL)&(R2MASK);
    		RRR3=(cand>>41ULL)&(R3MASK);
		if (!attack_over)
    		if (checkforward(cand))
		{
        	    clockback(cand,100,0,0,0);
		}
    	    }
    	    found = 0;
    	    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
	wthreads[__th_self].tries+=(4096*8*1024);
	attack_current_count++;
	crack_counts=0;
    }

}


void precalc()
{
    uint64_t a,b,t;

    for (a=0;a<19;a++) sta[a]=(1ULL<<a);
    for (a=0;a<22;a++) stb[a]=(1ULL<<a);
    for (a=0;a<23;a++) stc[a]=(1ULL<<a);
    
    // Do the clockings for sta
    for (a=0;a<64;a++)
    {
        cas[a]=sta[8];
	tas[a]=sta[18];
        t=sta[18]^sta[17]^sta[16]^sta[13];
        for (b=18;b>0;b--) sta[b]=sta[b-1];
        sta[0]=t;
    }

    // Do the clockings for stb
    for (a=0;a<64;a++)
    {
        cbs[a]=stb[10];
        tbs[a]=stb[21];
        t=stb[21]^stb[20];
        for (b=21;b>0;b--) stb[b]=stb[b-1];
        stb[0]=t;
    }

    // Do the clockings for stc
    for (a=0;a<64;a++)
    {
        tcs[a]=stc[22];
        ccs[a]=stc[10];
        t=stc[22]^stc[21]^stc[20]^stc[7];
        for (b=22;b>0;b--) stc[b]=stc[b-1];
        stc[0]=t;
    }

    for (a=0;a<64;a++)
    {
        cbs[a]<<=19ULL;
        tbs[a]<<=19ULL;
        ccs[a]<<=41ULL;
        tcs[a]<<=41ULL;
    }
}



static void solve_system(uint64_t *vec, uint64_t sol, unsigned int dep,uint64_t neq)
{
    int sacl,sbcl,sccl;
    uint64_t ta,tb,tc,ssol,sneq;
    uint64_t ca,cb,cc;
    uint64_t i,j,k;


    //if (neq>51ULL)
    if (neq>50ULL)
    {
	bruteforce(vec,sol);
        return;
    }

    if (dep==4ULL)
    {
	counter++;
	if ((counter%nwthreads)!=__th_self) return;
	//printf("\nThread %d taking path %lld\n",__th_self,counter);
    }


    sacl=acl;sbcl=bcl;sccl=ccl;
    ssol=sol;sneq=neq;
    ca = cas[acl];
    cb = cbs[bcl];
    cc = ccs[ccl];

    for (k=0;k<4;k++)
    {
        switch (k)
        {
            case 3:
                vec[neq]=ca^cb;
                //sol^=(0ULL<<neq);
                neq++;
                vec[neq]=ca^cc;
                //sol^=(0ULL<<neq);
                neq++;
                acl++;
                bcl++;
                ccl++;
                break;
            
            case 1:
                vec[neq]=ca^cb;
                sol^=(1ULL<<neq);
                neq++;
                vec[neq]=ca^cc;
                sol^=(1ULL<<neq);
                neq++;
                bcl++;
                ccl++;
                break;

            case 2:
                vec[neq]=ca^cb;
                sol^=(1ULL<<neq);
                neq++;
                vec[neq]=ca^cc;
                //sol^=(0ULL<<neq);
                neq++;
                acl++;
                ccl++;
                break;

            case 0:
                vec[neq]=ca^cb;
                //sol^=(0ULL<<neq);
                neq++;
                vec[neq]=ca^cc;
                sol^=(1ULL<<neq);
                neq++;
                acl++;
                bcl++;
                break;
        }

        ta = tas[acl];
        tb = tbs[bcl];
        tc = tcs[ccl];

        vec[neq]=(ta)^(tb)^(tc);
	sol^=(((uint64_t)((ks[dep/8]>>(7-(dep&7)))&1ULL))<<neq);
        neq++;

        // Partial Gauss
        uint64_t x=vec[neq-3];
        uint64_t y=vec[neq-2];
        uint64_t z=vec[neq-1];
        for (i=0;i<(neq-3);i++) 
        {
    	    if (unlikely((x>>(63-(clzll(vec[i]))))&1ULL)) {x^=vec[i];sol^=(((sol>>i)&1ULL)<<(neq-3));}
	    if (unlikely((y>>(63-(clzll(vec[i]))))&1ULL)) {y^=vec[i];sol^=(((sol>>i)&1ULL)<<(neq-2));}
	    if (unlikely((z>>(63-(clzll(vec[i]))))&1ULL)) {z^=vec[i];sol^=(((sol>>i)&1ULL)<<(neq-1));}
	}
	if (unlikely((y>>(63ULL-(clzll(x))))&1ULL)) {y^=x;sol^=(((sol>>(neq-3))&1ULL)<<(neq-2));}
	if (unlikely((z>>(63ULL-(clzll(x))))&1ULL)) {z^=x;sol^=(((sol>>(neq-3))&1ULL)<<(neq-1));}
	if (unlikely((z>>(63ULL-(clzll(y))))&1ULL)) {z^=y;sol^=(((sol>>(neq-2))&1ULL)<<(neq-1));}
	vec[neq-3]=x;
	vec[neq-2]=y;
	vec[neq-1]=z;

        i=neq-3;j=0;
        while (j<3)
        {
            if (((vec[i]==0ULL))&&(((sol>>i)&1ULL)==1ULL)) goto nextone;
            if (((vec[i]==0ULL))&&(((sol>>i)&1ULL)==0ULL)) 
            {
                if ((dep>=64)) goto nextone;
                vec[i]=vec[i+1];
                vec[i+1]=0;
		sol^=(((sol>>(i+1))&1ULL)<<(i));
                sol^=(((sol>>(i+1))&1ULL)<<(i+1));
            }
            else i++;
            j++;
        }
        neq=i;

        //if ((neq==sneq)&&(dep>=64)) goto next;
        solve_system(vec,sol,dep+1,neq);
        nextone:
        acl=sacl;bcl=sbcl;ccl=sccl;neq=sneq;sol=ssol;
    }
}


void deinit_bruteforce()
{}

void init_bruteforce_long()
{
    ks[0] = hash_list->hash[0];
    ks[1] = hash_list->hash[1];
    ks[2] = hash_list->hash[2];
    ks[3] = hash_list->hash[3];
    ks[4] = hash_list->hash[4];
    ks[5] = hash_list->hash[5];
    ks[6] = hash_list->hash[6];
    ks[7] = hash_list->hash[7];
    frameno = (atoi(hash_list->salt));
}







/* Bruteforce larger charsets */
void* ocl_bruteforce_a51_thread(void *arg)
{
    int err;
    int self;
    int found;

    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "a51", &err );
    else  kernel = _clCreateKernel(program[self], "a51", &err );

    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );


    hashes = malloc(hash_ret_len1*MAXFOUNDLOCAL); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len1*MAXFOUNDLOCAL, NULL, &err );
    bzero(hashes,hash_ret_len1*MAXFOUNDLOCAL);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len1*MAXFOUNDLOCAL, hashes, 0, NULL, NULL);


    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    input_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY, 4096*16*8, NULL , &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);


    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_mem), (void*) &input_buf);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &found_buf);
    cl_uint kks,kks1;
    kks =( ks[3]&255)|((ks[2]&255)<<8)|((ks[1]&255)<<16)|((ks[0]&255)<<24);
//    printf("kks=%08x frameno=%d\n",kks,frameno);
    _clSetKernelArg(kernel, 3, sizeof(cl_uint), (void*) &kks);
    kks1 = (ks[7]&255)|((ks[6]&255)<<8)|((ks[5]&255)<<16)|((ks[4]&255)<<24);
//    printf("kks1=%08x frameno=%d\n",kks1,frameno);
    _clSetKernelArg(kernel, 4, sizeof(cl_uint), (void*) &kks1);

    global_work_size[0] = (4096*8*1024)/32;
    global_work_size[1] = 0;
    global_work_size[2] = 0;
    pthread_mutex_unlock(&biglock); 


    uint64_t vec[128];
    uint64_t sol;
    memset(vec,0,128*8);
    sol=0ULL;acl=bcl=ccl=0;
    __th_self = self;
    crack_counts=0;
    counter=-1ULL;
    solve_system(vec,sol, 0, 0ULL);

    return hash_ok;
}








hash_stat ocl_bruteforce_a51(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    attack_overall_count = (1024*1024*4); // 16G / 8k
    attack_current_count = 0;

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

    init_bruteforce_long();
    scheduler_setup(bruteforce_start, 5, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
    for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
    {
        _clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
    	context[i] = _clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);

    	if (wthreads[i].type != nv_thread)
    	{
    	    char *binary;
    	    size_t binary_size;
    	    FILE *fp;
    	    char pbuf[100];
    	    bzero(pbuf,100);
    	    char kernelfile[255];
    	    _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_a51__%s.bin",DATADIR,pbuf);

    	    char *ofname = kernel_decompress(kernelfile);
    	    if (!ofname) return hash_err;
    	    fp=fopen(ofname,"r");
    	    if (!fp) 
    	    {
        	elog("Can't open kernel: %s\n",kernelfile);
            	exit(1);
    	    }
    	    fseek(fp, 0, SEEK_END);
    	    binary_size = ftell(fp);
    	    fseek(fp, 0, SEEK_SET);
    	    binary=malloc(binary_size);
    	    fread(binary,binary_size,1,fp);
    	    fclose(fp);
    	    unlink(ofname);
    	    free(ofname);
    	    if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
    	    program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
    	    _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
    	    free(binary);
    	}
    	else
    	{
    	    #define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
    	    #define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
    	    char *binary;
    	    size_t binary_size;
    	    FILE *fp;
    	    char pbuf[100];
    	    bzero(pbuf,100);
    	    char kernelfile[255];
    	    _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    cl_uint compute_capability_major, compute_capability_minor;
    	    _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
    	    _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
    	    if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
    	    if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
    	    if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
    	    if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
    	    if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
    	    if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
	    if ((compute_capability_major==3)&&(compute_capability_minor==0)) sprintf(pbuf,"sm30");
    	    if (hash_list->next) 
    	    {
    	        sprintf(kernelfile,"%s/hashkill/kernels/nvidia_a51_long__%s.ptx",DATADIR,pbuf);
    	    }
    	    else
    	    {
    	        sprintf(kernelfile,"%s/hashkill/kernels/nvidia_a51_long_S_%s.ptx",DATADIR,pbuf);
	    }

    	    char *ofname = kernel_decompress(kernelfile);
    	    if (!ofname) return hash_err;
    	    fp=fopen(ofname,"r");
    	    if (!fp) 
    	    {
        	elog("Can't open kernel: %s\n",kernelfile);
            	exit(1);
    	    }

    	    fseek(fp, 0, SEEK_END);
    	    binary_size = ftell(fp);
    	    fseek(fp, 0, SEEK_SET);
    	    binary=malloc(binary_size);
    	    fread(binary,binary_size,1,fp);
    	    fclose(fp);
    	    unlink(ofname);
    	    free(ofname);
    	    if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
    	    program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
    	    _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
    	    free(binary);
    	}
    }

    precalc();

    pthread_mutex_init(&biglock, NULL);
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_bruteforce_a51_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);

    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}



hash_stat ocl_markov_a51(void)
{
    return ocl_bruteforce_a51();
}



hash_stat ocl_rule_a51(void)
{
    return ocl_bruteforce_a51();
}

