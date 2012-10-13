/*
 * des_sse2.c
 *
 * hashkill - a hash cracking tool
 * Copyright (C) 2010 Milen Rangelov <gat3way@gat3way.eu>
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


/*
 * Bitslice implementation of DES.
 *
 * Checks that the plaintext bits p[0] .. p[63]
 * encrypt to the ciphertext bits c[0] .. c[63]
 * given the key bits k[0] .. k[55]
 */

#ifdef HAVE_SSE2

#include <emmintrin.h>
#include <string.h>
#include <stdio.h>

#include "err.h"
#include "hashinterface.h"

#define _mm_extract_epi8(x, imm) \
((((imm) & 0x1) == 0) ? \
_mm_extract_epi16((x), (imm) >> 1) & 0xff : \
_mm_extract_epi16(_mm_srli_epi16((x), 8), (imm) >> 1))

#define _mm_extract_epi32(x, imm) \
    _mm_cvtsi128_si32(_mm_srli_si128((x), 4 * (imm)))




void inline 
deseval_SSE (
	 __m128i 	*p,
	 __m128i 	*c,
	 __m128i 	*k
 );

void inline 
deseval_SSE_salted (
	 __m128i 	*p,
	 __m128i 	*c,
	 __m128i 	*k,
	 char salt[3];
);


extern inline void 
sse_s1 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s2 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s3 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s4 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s5 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s6 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s7 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );
extern inline void 
sse_s8 (
        __m128i a1_1,
        __m128i a1_2,
        __m128i a2_1,
        __m128i a2_2,
        __m128i a3_1,
        __m128i a3_2,
        __m128i a4_1,
        __m128i a4_2,
        __m128i a5_1,
        __m128i a5_2,
        __m128i a6_1,
        __m128i a6_2,
        __m128i *out1,
        __m128i *out2,
        __m128i *out3,
        __m128i *out4
        );



void DES_ONEBLOCK_SSE(char ukey[8], char *plains[128], char *out[128])
{
    int a,b,e,f;

    __m128i pp[64];
    __m128i c[64];
    __m128i k[56];

    __m128i pvec, pvec1;
    __m128i pveca[16];



/* Setup plaintext bits */
    for (f=0;f<8;f++)
    {
	for (b=0;b<8;b++)
	{
	    e = b*16;

	    pveca[b] = _mm_set_epi8(plains[15+e][f], plains[14+e][f], plains[13+e][f], plains[12+e][f], plains[11+e][f],
	    			    plains[10+e][f], plains[9+e][f], plains[8+e][f], plains[7+e][f], plains[6+e][f],
				    plains[5+e][f], plains[4+e][f], plains[3+e][f], plains[2+e][f],
				    plains[1+e][f], plains[0+e][f]);

	}
	for (b=0;b<8;b++)
	{
    	    pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
	    for (a=7;a>=0;a--) 
	    {
		pvec1 = pveca[a];
		pveca[a] = _mm_slli_epi16(pvec1,1);
	    }
	    pp[b+f*8] = pvec;
	}
    }

/* Setup key bits - this key setup is wrong, has to be fixed! */
    
    for (a=1;a<8;a++) if ( ((ukey[7]>>a)&1) ) k[a-1] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[6]>>a)&1) ) k[6+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[5]>>a)&1) ) k[13+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[4]>>a)&1) ) k[20+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[3]>>a)&1) ) k[27+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[2]>>a)&1) ) k[34+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[1]>>a)&1) ) k[41+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=1;a<8;a++) if ( ((ukey[0]>>a)&1) ) k[48+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);

    deseval_SSE (pp, c, k);

    char cb[16];
    __m128i vec,vec1;
    short temp;


#define fetchrow(m) \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][7] = (temp&255); \
	out[7-a+(m)*8][6] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+16],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][5] = (temp&255); \
	out[7-a+(m)*8][4] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+32],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][3] = (temp&255); \
	out[7-a+(m)*8][2] = (temp >> 8); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+48],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][1] = (temp&255); \
	out[7-a+(m)*8][0] = ((temp >> 8)); \
    }

    fetchrow(0);
    fetchrow(1);
    fetchrow(2);
    fetchrow(3);
    fetchrow(4);
    fetchrow(5);
    fetchrow(6);
    fetchrow(7);
    fetchrow(8);
    fetchrow(9);
    fetchrow(10);
    fetchrow(11);
    fetchrow(12);
    fetchrow(13);
    fetchrow(14);
    fetchrow(15);

}


/* this routine supports up to 16 blocks */
void DES_CBC_SSE(char *key[128], char *plains[128], char *out[128], char *ivs[128], int lens[128])
{
    int lens1[128];
    int flags;
    int i,j,l;
    char cb[16];
    __m128i vec,vec1;
    short temp;
    int a,b,e,f,g;
    __m128i pvec, pvec1;
    __m128i pveca[16];
    __m128i pp[64];
    __m128i c[64];
    __m128i k[56];

    
    // setup padding
    for (i=0;i<128;i++)
    {
	j=strlen(plains[i]);
	if ((j<16)&&(j>8)) 
	{
	    l=16-j;
	    memset(&plains[i][j],l,l);
	}
	if (j<8) 
	{
	    l=8-j;
	    memset(&plains[i][j],l,l);
	}
    }

    // setup ivs
    for (i=0;i<128;i++) for (j=0;j<lens[i];j++) plains[i][j] = plains[i][j] ^ ivs[i][j];

    
    /* Setup plaintext bits */
    for (f=0;f<8;f++)
    {
	for (b=0;b<8;b++)
	{
	    e = b*16;

	    pveca[b] = _mm_set_epi8(plains[15+e][f], plains[14+e][f], plains[13+e][f], plains[12+e][f], plains[11+e][f],
	    			    plains[10+e][f], plains[9+e][f], plains[8+e][f], plains[7+e][f], plains[6+e][f],
				    plains[5+e][f], plains[4+e][f], plains[3+e][f], plains[2+e][f],
				    plains[1+e][f], plains[0+e][f]);

	}
	for (b=0;b<8;b++)
	{
    	    pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
	    for (a=7;a>=0;a--) 
	    {
		pvec1 = pveca[a];
		pveca[a] = _mm_slli_epi16(pvec1,1);
	    }
	    pp[b+f*8] = pvec;
	}
    }

    /* Setup the key */
    for (f=7;f>=0;f--)
    {
	for (b=0;b<8;b++)
	{
	    e = b*16;
	    pveca[b] = _mm_set_epi8(plains[15+e][f], plains[14+e][f], plains[13+e][f], plains[12+e][f], plains[11+e][f],
	    			    plains[10+e][f], plains[9+e][f], plains[8+e][f], plains[7+e][f], plains[6+e][f],
				    plains[5+e][f], plains[4+e][f], plains[3+e][f], plains[2+e][f],
				    plains[1+e][f], plains[0+e][f]);
	}



	for (b=0;b<7;b++)
	{
    	    pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
	    k[(6-b)+(7-f)*7] = pvec;

	    for (a=0;a<8;a++) 
	    {
		pvec1 = pveca[a];
		pveca[a] = _mm_slli_epi16(pvec1,1);
	    }

	}
    }

    deseval_SSE (pp, c, k);
    
    for (i=0;i<128;i++) if (lens[i]>8) flags = 1;

    fetchrow(0);
    fetchrow(1);
    fetchrow(2);
    fetchrow(3);
    fetchrow(4);
    fetchrow(5);
    fetchrow(6);
    fetchrow(7);
    fetchrow(8);
    fetchrow(9);
    fetchrow(10);
    fetchrow(11);
    fetchrow(12);
    fetchrow(13);
    fetchrow(14);
    fetchrow(15);

    if (flags == 0)
    {
        return;
    }
/* block 1 done, let's do next blocks */
    
    for (g=1;g<20;g++)
    {
	/* Setup plaintext bits */
	for (f=0;f<8;f++)
	{
	    for (b=0;b<8;b++)
	    {
		e = b*16;

		pveca[b] = _mm_set_epi8(plains[15+e][f+8*g], plains[14+e][f+8*g], plains[13+e][f+8*g], plains[12+e][f+8*g], plains[11+e][f+8*g],
	    			    plains[10+e][f+8*g], plains[9+e][f+8*g], plains[8+e][f+8*g], plains[7+e][f+8*g], plains[6+e][f+8*g],
				    plains[5+e][f+8*g], plains[4+e][f+8*g], plains[3+e][f+8*g], plains[2+e][f+8*g],
				    plains[1+e][f+8*g], plains[0+e][f+8*g]);

	    }
	    for (b=0;b<8;b++)
	    {
    		pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
		for (a=7;a>=0;a--) 
		{
    		    pvec1 = pveca[a];
		    pveca[a] = _mm_slli_epi16(pvec1,1);
		}
		pp[b+f*8] = pvec;
    	    }
        }
        for (i=0;i<128;i++) pp[i] = _mm_xor_si128(pp[i], c[i]);

        deseval_SSE (pp, c, k);

        for (i=0;i<128;i++) lens1[i] +=8;
        for (i=0;i<128;i++) if (lens1[i]<lens[i]) flags = 1;

        fetchrow(0);
        fetchrow(1);
        fetchrow(2);
        fetchrow(3);
        fetchrow(4);
        fetchrow(5);
        fetchrow(6);
        fetchrow(7);
        fetchrow(8);
        fetchrow(9);
        fetchrow(10);
        fetchrow(11);
        fetchrow(12);
        fetchrow(13);
        fetchrow(14);
        fetchrow(15);

	if (flags == 0)
	{
    	    return;
	}
    }

}


static unsigned const char cov_2char[65]={
0x2E,0x2F,0x30,0x31,0x32,0x33,0x34,0x35,
0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,
0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,
0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,
0x55,0x56,0x57,0x58,0x59,0x5A,0x61,0x62,
0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,
0x6B,0x6C,0x6D,0x6E,0x6F,0x70,0x71,0x72,
0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0
};

static unsigned char target1,target2;

void FCRYPT_PREPARE_OPT(void)
{
    int y,j;
    unsigned char c1,c2,c3,c4;

    c1=c2=c3=c4=0;
    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==hash_list->hash[2]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==hash_list->hash[3]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==hash_list->hash[4]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==hash_list->hash[5]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target1=(y>>24)&255;
    target2=(y>>16)&255;
}



hash_stat DES_FCRYPT_SSE(char salt[3], char *plains[128], char *out[128])
{
    int a,b,e,f,i;

    __m128i pp[64];
    __m128i c[64];
    __m128i k[56];
    __m128i pvec, pvec1;
    __m128i pveca[16];


/* Setup key bits */
    for (f=7;f>=0;f--)
    {
        for (b=0;b<8;b+=2)
        {
            e = b*16;

            pveca[b] = _mm_set_epi8(plains[15+e][7-f], plains[14+e][7-f], plains[13+e][7-f], plains[12+e][7-f], plains[11+e][7-f],
                                    plains[10+e][7-f], plains[9+e][7-f], plains[8+e][7-f], plains[7+e][7-f], plains[6+e][7-f],
                                    plains[5+e][7-f], plains[4+e][7-f], plains[3+e][7-f], plains[2+e][7-f],
                                    plains[1+e][7-f], plains[0+e][7-f]);
            e = (b+1)*16;

            pveca[b+1] = _mm_set_epi8(plains[15+e][7-f], plains[14+e][7-f], plains[13+e][7-f], plains[12+e][7-f], plains[11+e][7-f],
                                    plains[10+e][7-f], plains[9+e][7-f], plains[8+e][7-f], plains[7+e][7-f], plains[6+e][7-f],
                                    plains[5+e][7-f], plains[4+e][7-f], plains[3+e][7-f], plains[2+e][7-f],
                                    plains[1+e][7-f], plains[0+e][7-f]);
        }

        for (a=7;a>=0;a--)
        {
            pvec1 = pveca[a];
            pveca[a] = _mm_slli_epi16(pvec1,1);
        }
        for (b=0;b<7;b++)
        {
            pvec = _mm_set_epi16(
                                     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
                                     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
                                     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
                                     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
                                 );
            for (a=7;a>=0;a--)
            {
                pvec1 = pveca[a];
                pveca[a] = _mm_slli_epi16(pvec1,1);
            }
            k[7-b+f*7-1] = pvec;

        }
    }


/* Setup all-zero plaintext bits */
    for (a=0;a<64;a+=2) 
    {
	pp[a] = _mm_setzero_si128();
	pp[a+1] = _mm_setzero_si128();
    }

/* Perform 25 encryptions */

    deseval_SSE_salted (pp, c, k, salt);
    for (a=0;a<24;a+=4)
    {
	deseval_SSE_salted (c, pp, k, salt);
	deseval_SSE_salted (pp, c, k, salt);
	deseval_SSE_salted (c, pp, k, salt);
	deseval_SSE_salted (pp, c, k, salt);
    }


/* Get the ciphertexts */


    char cb[16];
    __m128i vec,vec1;
    short temp;
    int flag=0;
    int flag1=0;



#define fetchrowc(m)  \
    flag=0; \
    for (a=0;a<16;a++) { cb[a] = (_mm_extract_epi8(c[a+48],(m))); } \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3],cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
        vec1 = _mm_slli_epi32 (vec, a); \
        temp = _mm_movemask_epi8(vec1); \
        out[7-a+(m)*8][1] = (temp&255); \
        out[7-a+(m)*8][0] = ((temp >> 8))&255; \
        flag = (((target1&255)==(out[(7-(a))+((m)*8)][0]&255)))  ? 1 : flag; \
    } \
    flag1+=flag;

#define fetchrowc1(m) \
    { \
        for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a],(m))); \
        vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
        for (a=0;a<8;a++) \
        { \
            vec1 = _mm_slli_epi32 (vec, a); \
            temp = _mm_movemask_epi8(vec1); \
            out[7-a+(m)*8][7] = (temp&255); \
            out[7-a+(m)*8][6] = ((temp >> 8)); \
        } \
        for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+16],(m))); \
        vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
        for (a=0;a<8;a++) \
        { \
            vec1 = _mm_slli_epi32 (vec, a); \
            temp = _mm_movemask_epi8(vec1); \
            out[7-a+(m)*8][5] = (temp&255); \
            out[7-a+(m)*8][4] = ((temp >> 8)); \
        } \
        for (a=0;a<16;a+=4) \
        { \
            cb[a] = (_mm_extract_epi8(c[a+32],(m))); \
            cb[a+1] = (_mm_extract_epi8(c[a+33],(m))); \
            cb[a+2] = (_mm_extract_epi8(c[a+34],(m))); \
            cb[a+3] = (_mm_extract_epi8(c[a+35],(m))); \
        } \
        vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
        for (a=0;a<8;a++) \
        { \
            vec1 = _mm_slli_epi32 (vec, a); \
            temp = _mm_movemask_epi8(vec1); \
            out[7-a+(m)*8][3] = (temp&255); \
            out[7-a+(m)*8][2] = (temp >> 8); \
        } \
    } \
    flag1+=flag;

    fetchrowc(0);
    fetchrowc(1);
    fetchrowc(2);
    fetchrowc(3);
    fetchrowc(4);
    fetchrowc(5);
    fetchrowc(6);
    fetchrowc(7);
    fetchrowc(8);
    fetchrowc(9);
    fetchrowc(10);
    fetchrowc(11);
    fetchrowc(12);
    fetchrowc(13);
    fetchrowc(14);
    fetchrowc(15);
    if ((cpu_optimize_single==1)&&(flag1==0)) return hash_err;
    fetchrowc1(0);
    fetchrowc1(1);
    fetchrowc1(2);
    fetchrowc1(3);
    fetchrowc1(4);
    fetchrowc1(5);
    fetchrowc1(6);
    fetchrowc1(7);
    fetchrowc1(8);
    fetchrowc1(9);
    fetchrowc1(10);
    fetchrowc1(11);
    fetchrowc1(12);
    fetchrowc1(13);
    fetchrowc1(14);
    fetchrowc1(15);



/* convert each plaintext to salt+base64(block) */

    char r[12];
    char _cov_2char[66] = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    for (a=0;a<128;a++)
    {
        int *o1 = (int *)out[a];
        int *o2 = (int *)out[a]+1;
        int t1 = ((*o1 << 16) & 0xff0000) | (*o1 & 0xff00) | ((*o1 >> 16) & 0xff);
        int t2 = ((*o1 >> 8) & 0xff0000) | ((*o2 << 8) & 0xff00) | ((*o2 >> 8) & 0xff);
        int t3 = (*o2 & 0xff0000) | ((*o2 >> 16) & 0xff00);
        r[0] = t1 >> 18 & 0x3f;
        r[1] = t1 >> 12 & 0x3f;
        r[2] = t1 >> 6 & 0x3f;
        r[3] = t1 & 0x3f;
        r[4] = t2 >> 18 & 0x3f;
        r[5] = t2 >> 12 & 0x3f;
        r[6] = t2 >> 6 & 0x3f;
        r[7] = t2 & 0x3f;
        r[8] = t3 >> 18 & 0x3f;
        r[9] = t3 >> 12 & 0x3f;
        r[10] = t3 >> 6 & 0x3f;
        for (i=0;i<12;i++) r[i] = _cov_2char[(int)r[i]];
        memcpy(out[a],salt,2);
        memcpy(out[a]+2,r,11);
        out[a][13]=0;
    }
    return hash_ok;

}



void DES_LM_SSE(char *plains[128], char *out[128])
{
    int a,b,e,f;
    __m128i c[64];
    __m128i k[56];
    __m128i pveca[8];
    __m128i pvec, pvec1;
    unsigned char ukey[8]="KGS!@#$%";
    int flag=0;
    __m128i pp[64];

    _mm_prefetch(plains[30],_MM_HINT_T1);
    _mm_prefetch(plains[31],_MM_HINT_T1);
    _mm_prefetch(plains[32],_MM_HINT_T1);
    _mm_prefetch(plains[33],_MM_HINT_T1);
    _mm_prefetch(plains[34],_MM_HINT_T1);
    _mm_prefetch(plains[35],_MM_HINT_T1);
    _mm_prefetch(plains[36],_MM_HINT_T1);
    _mm_prefetch(plains[37],_MM_HINT_T1);
    _mm_prefetch(plains[38],_MM_HINT_T1);
    _mm_prefetch(plains[39],_MM_HINT_T1);
    _mm_prefetch(plains[40],_MM_HINT_T1);
    _mm_prefetch(plains[41],_MM_HINT_T1);
    _mm_prefetch(plains[42],_MM_HINT_T1);
    _mm_prefetch(plains[43],_MM_HINT_T1);
    _mm_prefetch(plains[44],_MM_HINT_T1);
    _mm_prefetch(plains[45],_MM_HINT_T1);
    _mm_prefetch(plains[46],_MM_HINT_T1);
    _mm_prefetch(plains[47],_MM_HINT_T1);
    _mm_prefetch(plains[48],_MM_HINT_T1);
    _mm_prefetch(plains[49],_MM_HINT_T1);
    _mm_prefetch(plains[50],_MM_HINT_T1);
    _mm_prefetch(plains[51],_MM_HINT_T1);
    _mm_prefetch(plains[52],_MM_HINT_T1);
    _mm_prefetch(plains[53],_MM_HINT_T1);
    _mm_prefetch(plains[54],_MM_HINT_T1);
    _mm_prefetch(plains[55],_MM_HINT_T1);
    _mm_prefetch(plains[56],_MM_HINT_T1);
    _mm_prefetch(plains[57],_MM_HINT_T1);
    _mm_prefetch(plains[58],_MM_HINT_T1);
    _mm_prefetch(plains[59],_MM_HINT_T1);
    _mm_prefetch(plains[20],_MM_HINT_T1);
    _mm_prefetch(plains[21],_MM_HINT_T1);
    _mm_prefetch(plains[22],_MM_HINT_T1);
    _mm_prefetch(plains[23],_MM_HINT_T1);
    _mm_prefetch(plains[24],_MM_HINT_T1);
    _mm_prefetch(plains[25],_MM_HINT_T1);
    _mm_prefetch(plains[26],_MM_HINT_T1);
    _mm_prefetch(plains[27],_MM_HINT_T1);
    _mm_prefetch(plains[28],_MM_HINT_T1);
    _mm_prefetch(plains[29],_MM_HINT_T1);
    _mm_prefetch(plains[60],_MM_HINT_T1);
    _mm_prefetch(plains[61],_MM_HINT_T1);
    _mm_prefetch(plains[62],_MM_HINT_T1);
    _mm_prefetch(plains[63],_MM_HINT_T1);
    _mm_prefetch(plains[64],_MM_HINT_T1);
    _mm_prefetch(plains[65],_MM_HINT_T1);
    _mm_prefetch(plains[66],_MM_HINT_T1);
    _mm_prefetch(plains[67],_MM_HINT_T1);
    _mm_prefetch(plains[68],_MM_HINT_T1);
    _mm_prefetch(plains[69],_MM_HINT_T1);
    _mm_prefetch(plains[70],_MM_HINT_T1);
    _mm_prefetch(plains[71],_MM_HINT_T1);
    _mm_prefetch(plains[72],_MM_HINT_T1);
    _mm_prefetch(plains[73],_MM_HINT_T1);
    _mm_prefetch(plains[74],_MM_HINT_T1);
    _mm_prefetch(plains[75],_MM_HINT_T1);
    _mm_prefetch(plains[76],_MM_HINT_T1);
    _mm_prefetch(plains[77],_MM_HINT_T1);
    _mm_prefetch(plains[78],_MM_HINT_T1);
    _mm_prefetch(plains[79],_MM_HINT_T1);
    _mm_prefetch(plains[80],_MM_HINT_T1);
    _mm_prefetch(plains[81],_MM_HINT_T1);
    _mm_prefetch(plains[82],_MM_HINT_T1);
    _mm_prefetch(plains[83],_MM_HINT_T1);
    _mm_prefetch(plains[84],_MM_HINT_T1);
    _mm_prefetch(plains[85],_MM_HINT_T1);
    _mm_prefetch(plains[86],_MM_HINT_T1);
    _mm_prefetch(plains[87],_MM_HINT_T1);
    _mm_prefetch(plains[88],_MM_HINT_T1);
    _mm_prefetch(plains[89],_MM_HINT_T1);
    _mm_prefetch(plains[90],_MM_HINT_T1);
    _mm_prefetch(plains[91],_MM_HINT_T1);
    _mm_prefetch(plains[92],_MM_HINT_T1);
    _mm_prefetch(plains[93],_MM_HINT_T1);
    _mm_prefetch(plains[94],_MM_HINT_T1);
    _mm_prefetch(plains[95],_MM_HINT_T1);
    _mm_prefetch(plains[96],_MM_HINT_T1);
    _mm_prefetch(plains[97],_MM_HINT_T1);
    _mm_prefetch(plains[98],_MM_HINT_T1);
    _mm_prefetch(plains[99],_MM_HINT_T1);
    _mm_prefetch(plains[100],_MM_HINT_T1);
    _mm_prefetch(plains[101],_MM_HINT_T1);
    _mm_prefetch(plains[102],_MM_HINT_T1);
    _mm_prefetch(plains[103],_MM_HINT_T1);
    _mm_prefetch(plains[104],_MM_HINT_T1);
    _mm_prefetch(plains[105],_MM_HINT_T1);
    _mm_prefetch(plains[106],_MM_HINT_T1);
    _mm_prefetch(plains[107],_MM_HINT_T1);
    _mm_prefetch(plains[108],_MM_HINT_T1);
    _mm_prefetch(plains[109],_MM_HINT_T1);
    _mm_prefetch(plains[110],_MM_HINT_T1);
    _mm_prefetch(plains[111],_MM_HINT_T1);
    _mm_prefetch(plains[112],_MM_HINT_T1);
    _mm_prefetch(plains[113],_MM_HINT_T1);
    _mm_prefetch(plains[114],_MM_HINT_T1);
    _mm_prefetch(plains[115],_MM_HINT_T1);
    _mm_prefetch(plains[116],_MM_HINT_T1);
    _mm_prefetch(plains[117],_MM_HINT_T1);
    _mm_prefetch(plains[118],_MM_HINT_T1);
    _mm_prefetch(plains[119],_MM_HINT_T1);
    _mm_prefetch(plains[120],_MM_HINT_T1);
    _mm_prefetch(plains[121],_MM_HINT_T1);
    _mm_prefetch(plains[122],_MM_HINT_T1);
    _mm_prefetch(plains[123],_MM_HINT_T1);
    _mm_prefetch(plains[124],_MM_HINT_T1);
    _mm_prefetch(plains[125],_MM_HINT_T1);
    _mm_prefetch(plains[126],_MM_HINT_T1);
    _mm_prefetch(plains[127],_MM_HINT_T1);
    _mm_prefetch(plains[128],_MM_HINT_T0);


    for (a=0;a<128;a++) if (plains[a][16]==1) flag = 1;

    for (a=0;a<8;a++) if ( ((ukey[7]>>a)&1) ) pp[a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[6]>>a)&1) ) pp[8+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[5]>>a)&1) ) pp[16+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[4]>>a)&1) ) pp[24+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[3]>>a)&1) ) pp[32+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[2]>>a)&1) ) pp[40+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[1]>>a)&1) ) pp[48+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);
    for (a=0;a<8;a++) if ( ((ukey[0]>>a)&1) ) pp[56+a] = _mm_set_epi8(0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff);


    /* Setup the key */
    for (f=7;f>=0;f--)
    {
	for (b=0;b<8;b+=2)
	{
	    e = b*16;
	    pveca[b] = _mm_set_epi8(plains[15+e][f], plains[14+e][f], plains[13+e][f], plains[12+e][f], plains[11+e][f],
	    			    plains[10+e][f], plains[9+e][f], plains[8+e][f], plains[7+e][f], plains[6+e][f],
				    plains[5+e][f], plains[4+e][f], plains[3+e][f], plains[2+e][f],
				    plains[1+e][f], plains[0+e][f]);
	    e = (b+1)*16;
	    pveca[b+1] = _mm_set_epi8(plains[15+e][f], plains[14+e][f], plains[13+e][f], plains[12+e][f], plains[11+e][f],
	    			    plains[10+e][f], plains[9+e][f], plains[8+e][f], plains[7+e][f], plains[6+e][f],
				    plains[5+e][f], plains[4+e][f], plains[3+e][f], plains[2+e][f],
				    plains[1+e][f], plains[0+e][f]);
	}



	for (b=0;b<7;b++)
	{
    	    pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
	    k[(6-b)+(7-f)*7] = pvec;

	    for (a=0;a<8;a+=2) 
	    {
		pvec1 = pveca[a];
		pveca[a] = _mm_slli_epi16(pvec1,1);
		pvec1 = pveca[a+1];
		pveca[a+1] = _mm_slli_epi16(pvec1,1);
	    }

	}
    }


    deseval_SSE(pp, c, k);


/* Get the ciphertexts */


    char cb[16];
    __m128i vec,vec1;
    short temp;


#define fetchfirstrows(m) \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+48],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a+=2) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][1] = (temp&255); \
	out[7-a+(m)*8][0] = ((temp >> 8)); \
	vec1 = _mm_slli_epi32 (vec, a+1); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-(a+1)+(m)*8][1] = (temp&255); \
	out[7-(a+1)+(m)*8][0] = ((temp >> 8)); \
    }


#define fetchrowd(m) \
    for (a=0;a<16;a+=2) {cb[a] = (_mm_extract_epi8(c[a],(m)));cb[a+1] = (_mm_extract_epi8(c[a+1],(m)));} \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a+=2) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][7] = (temp&255); \
	out[7-a+(m)*8][6] = ((temp >> 8)); \
	vec1 = _mm_slli_epi32 (vec, a+1); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-(a+1)+(m)*8][7] = (temp&255); \
	out[7-(a+1)+(m)*8][6] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a+=2) {cb[a] = (_mm_extract_epi8(c[a+16],(m)));cb[a+1] = (_mm_extract_epi8(c[a+16+1],(m)));} \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a+=2) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][5] = (temp&255); \
	out[7-a+(m)*8][4] = ((temp >> 8)); \
	vec1 = _mm_slli_epi32 (vec, a+1); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-(a+1)+(m)*8][5] = (temp&255); \
	out[7-(a+1)+(m)*8][4] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a+=2) {cb[a] = (_mm_extract_epi8(c[a+32],(m)));cb[a+1] = (_mm_extract_epi8(c[a+32+1],(m)));} \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a+=2) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][3] = (temp&255); \
	out[7-a+(m)*8][2] = (temp >> 8); \
	vec1 = _mm_slli_epi32 (vec, a+1); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-(a+1)+(m)*8][3] = (temp&255); \
	out[7-(a+1)+(m)*8][2] = (temp >> 8); \
    } \


    fetchfirstrows(0);
    fetchfirstrows(1);
    fetchfirstrows(2);
    fetchfirstrows(3);
    fetchfirstrows(4);
    fetchfirstrows(5);
    fetchfirstrows(6);
    fetchfirstrows(7);
    fetchfirstrows(8);
    fetchfirstrows(9);
    fetchfirstrows(10);
    fetchfirstrows(11);
    fetchfirstrows(12);
    fetchfirstrows(13);
    fetchfirstrows(14);
    fetchfirstrows(15);
    
    if (!hash_list->next)
    {
	b=0;
	for (a=0;a<128;a++) if ((out[a][0]==hash_list->hash[0])&&(out[a][1]==hash_list->hash[1])) b=1;
	if (b==0) return;
    }


    fetchrowd(0);
    fetchrowd(1);
    fetchrowd(2);
    fetchrowd(3);
    fetchrowd(4);
    fetchrowd(5);
    fetchrowd(6);
    fetchrowd(7);
    fetchrowd(8);
    fetchrowd(9);
    fetchrowd(10);
    fetchrowd(11);
    fetchrowd(12);
    fetchrowd(13);
    fetchrowd(14);
    fetchrowd(15);
    
    if (flag==0) return;

    for (f=7;f>=0;f--)
    {
	for (b=0;b<8;b+=2)
	{
	    e = b*16;
	    pveca[b] = _mm_set_epi8(plains[15+e][f+8], plains[14+e][f+8], plains[13+e][f+8], plains[12+e][f+8], plains[11+e][f+8],
	    			    plains[10+e][f+8], plains[9+e][f+8], plains[8+e][f+8], plains[7+e][f+8], plains[6+e][f+8],
				    plains[5+e][f+8], plains[4+e][f+8], plains[3+e][f+8], plains[2+e][f+8],
				    plains[1+e][f+8], plains[0+e][f+8]);
	    e = (b+1)*16;
	    pveca[b+1] = _mm_set_epi8(plains[15+e][f+8], plains[14+e][f+8], plains[13+e][f+8], plains[12+e][f+8], plains[11+e][f+8],
	    			    plains[10+e][f+8], plains[9+e][f+8], plains[8+e][f+8], plains[7+e][f+8], plains[6+e][f+8],
				    plains[5+e][f+8], plains[4+e][f+8], plains[3+e][f+8], plains[2+e][f+8],
				    plains[1+e][f+8], plains[0+e][f+8]);
	}



	for (b=0;b<7;b++)
	{
    	    pvec = _mm_set_epi16(
				     _mm_movemask_epi8(pveca[7]), _mm_movemask_epi8(pveca[6]),
				     _mm_movemask_epi8(pveca[5]), _mm_movemask_epi8(pveca[4]),
				     _mm_movemask_epi8(pveca[3]), _mm_movemask_epi8(pveca[2]),
				     _mm_movemask_epi8(pveca[1]), _mm_movemask_epi8(pveca[0])
				 );
	    k[(6-b)+(7-f)*7] = pvec;

	    for (a=0;a<8;a++) 
	    {
		pvec1 = pveca[a];
		pveca[a] = _mm_slli_epi16(pvec1,1);
	    }

	}
    }

    deseval_SSE(pp, c, k);



#define fetchrow2(m) \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][15] = (temp&255); \
	out[7-a+(m)*8][14] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+16],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][13] = (temp&255); \
	out[7-a+(m)*8][12] = ((temp >> 8)); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+32],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][11] = (temp&255); \
	out[7-a+(m)*8][10] = (temp >> 8); \
    } \
    for (a=0;a<16;a++) cb[a] = (_mm_extract_epi8(c[a+48],(m))); \
    vec = _mm_set_epi8(cb[15], cb[14], cb[13], cb[12], cb[11], cb[10], cb[9], cb[8], cb[7], cb[6], cb[5], cb[4], cb[3], cb[2], cb[1], cb[0]); \
    for (a=0;a<8;a++) \
    { \
	vec1 = _mm_slli_epi32 (vec, a); \
	temp = _mm_movemask_epi8(vec1); \
	out[7-a+(m)*8][9] = (temp&255); \
	out[7-a+(m)*8][8] = ((temp >> 8)); \
    }

    fetchrow2(0);
    fetchrow2(1);
    fetchrow2(2);
    fetchrow2(3);
    fetchrow2(4);
    fetchrow2(5);
    fetchrow2(6);
    fetchrow2(7);
    fetchrow2(8);
    fetchrow2(9);
    fetchrow2(10);
    fetchrow2(11);
    fetchrow2(12);
    fetchrow2(13);
    fetchrow2(14);
    fetchrow2(15);

}








void
deseval_SSE (
	 __m128i 	*p,
	 __m128i 	*c,
	 __m128i 	*k
	 ) {
  __m128i 	l0 = p[6];
  __m128i 	l1 = p[14];
  __m128i 	l2 = p[22];
  __m128i 	l3 = p[30];
  __m128i 	l4 = p[38];
  __m128i 	l5 = p[46];
  __m128i 	l6 = p[54];
  __m128i 	l7 = p[62];
  __m128i 	l8 = p[4];
  __m128i 	l9 = p[12];
  __m128i 	l10 = p[20];
  __m128i 	l11 = p[28];
  __m128i 	l12 = p[36];
  __m128i 	l13 = p[44];
  __m128i 	l14 = p[52];
  __m128i 	l15 = p[60];
  __m128i 	l16 = p[2];
  __m128i 	l17 = p[10];
  __m128i 	l18 = p[18];
  __m128i 	l19 = p[26];
  __m128i 	l20 = p[34];
  __m128i 	l21 = p[42];
  __m128i 	l22 = p[50];
  __m128i 	l23 = p[58];
  __m128i 	l24 = p[0];
  __m128i 	l25 = p[8];
  __m128i 	l26 = p[16];
  __m128i 	l27 = p[24];
  __m128i 	l28 = p[32];
  __m128i 	l29 = p[40];
  __m128i 	l30 = p[48];
  __m128i 	l31 = p[56];
  __m128i 	r0 = p[7];
  __m128i 	r1 = p[15];
  __m128i 	r2 = p[23];
  __m128i 	r3 = p[31];
  __m128i 	r4 = p[39];
  __m128i 	r5 = p[47];
  __m128i 	r6 = p[55];
  __m128i 	r7 = p[63];
  __m128i 	r8 = p[5];
  __m128i 	r9 = p[13];
  __m128i 	r10 = p[21];
  __m128i 	r11 = p[29];
  __m128i 	r12 = p[37];
  __m128i 	r13 = p[45];
  __m128i 	r14 = p[53];
  __m128i 	r15 = p[61];
  __m128i 	r16 = p[3];
  __m128i 	r17 = p[11];
  __m128i 	r18 = p[19];
  __m128i 	r19 = p[27];
  __m128i 	r20 = p[35];
  __m128i 	r21 = p[43];
  __m128i 	r22 = p[51];
  __m128i 	r23 = p[59];
  __m128i 	r24 = p[1];
  __m128i 	r25 = p[9];
  __m128i 	r26 = p[17];
  __m128i 	r27 = p[25];
  __m128i 	r28 = p[33];
  __m128i 	r29 = p[41];
  __m128i 	r30 = p[49];
  __m128i 	r31 = p[57];


  sse_s1 (r31, k[47], r0, k[11], r1, k[26], r2, k[3], r3, k[13],
	  r4, k[41], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[27], r4, k[6], r5, k[54], r6, k[48], r7, k[39],
	  r8, k[19], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[53], r8, k[25], r9, k[33], r10, k[34], r11, k[17],
	  r12, k[5], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[4], r12, k[55], r13, k[24], r14, k[32], r15, k[40],
	  r16, k[20], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[36], r16, k[31], r17, k[21], r18, k[8], r19, k[23],
	  r20, k[52], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[14], r20, k[29], r21, k[51], r22, k[9], r23, k[35],
	  r24, k[30], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[2], r24, k[37], r25, k[22], r26, k[0], r27, k[42],
	  r28, k[38], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[16], r28, k[43], r29, k[44], r30, k[1], r31, k[7],
	  r0, k[28], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[54], l0, k[18], l1, k[33], l2, k[10], l3, k[20],
	  l4, k[48], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[34], l4, k[13], l5, k[4], l6, k[55], l7, k[46],
	  l8, k[26], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[3], l8, k[32], l9, k[40], l10, k[41], l11, k[24],
	  l12, k[12], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[11], l12, k[5], l13, k[6], l14, k[39], l15, k[47],
	  l16, k[27], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[43], l16, k[38], l17, k[28], l18, k[15], l19, k[30],
	  l20, k[0], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[21], l20, k[36], l21, k[31], l22, k[16], l23, k[42],
	  l24, k[37], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[9], l24, k[44], l25, k[29], l26, k[7], l27, k[49],
	  l28, k[45], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[23], l28, k[50], l29, k[51], l30, k[8], l31, k[14],
	  l0, k[35], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[11], r0, k[32], r1, k[47], r2, k[24], r3, k[34],
	  r4, k[5], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[48], r4, k[27], r5, k[18], r6, k[12], r7, k[3],
	  r8, k[40], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[17], r8, k[46], r9, k[54], r10, k[55], r11, k[13],
	  r12, k[26], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[25], r12, k[19], r13, k[20], r14, k[53], r15, k[4],
	  r16, k[41], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[2], r16, k[52], r17, k[42], r18, k[29], r19, k[44],
	  r20, k[14], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[35], r20, k[50], r21, k[45], r22, k[30], r23, k[1],
	  r24, k[51], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[23], r24, k[31], r25, k[43], r26, k[21], r27, k[8],
	  r28, k[0], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[37], r28, k[9], r29, k[38], r30, k[22], r31, k[28],
	  r0, k[49], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[25], l0, k[46], l1, k[4], l2, k[13], l3, k[48],
	  l4, k[19], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[5], l4, k[41], l5, k[32], l6, k[26], l7, k[17],
	  l8, k[54], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[6], l8, k[3], l9, k[11], l10, k[12], l11, k[27],
	  l12, k[40], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[39], l12, k[33], l13, k[34], l14, k[10], l15, k[18],
	  l16, k[55], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[16], l16, k[7], l17, k[1], l18, k[43], l19, k[31],
	  l20, k[28], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[49], l20, k[9], l21, k[0], l22, k[44], l23, k[15],
	  l24, k[38], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[37], l24, k[45], l25, k[2], l26, k[35], l27, k[22],
	  l28, k[14], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[51], l28, k[23], l29, k[52], l30, k[36], l31, k[42],
	  l0, k[8], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[39], r0, k[3], r1, k[18], r2, k[27], r3, k[5],
	  r4, k[33], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[19], r4, k[55], r5, k[46], r6, k[40], r7, k[6],
	  r8, k[11], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[20], r8, k[17], r9, k[25], r10, k[26], r11, k[41],
	  r12, k[54], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[53], r12, k[47], r13, k[48], r14, k[24], r15, k[32],
	  r16, k[12], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[30], r16, k[21], r17, k[15], r18, k[2], r19, k[45],
	  r20, k[42], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[8], r20, k[23], r21, k[14], r22, k[31], r23, k[29],
	  r24, k[52], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[51], r24, k[0], r25, k[16], r26, k[49], r27, k[36],
	  r28, k[28], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[38], r28, k[37], r29, k[7], r30, k[50], r31, k[1],
	  r0, k[22], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[53], l0, k[17], l1, k[32], l2, k[41], l3, k[19],
	  l4, k[47], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[33], l4, k[12], l5, k[3], l6, k[54], l7, k[20],
	  l8, k[25], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[34], l8, k[6], l9, k[39], l10, k[40], l11, k[55],
	  l12, k[11], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[10], l12, k[4], l13, k[5], l14, k[13], l15, k[46],
	  l16, k[26], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[44], l16, k[35], l17, k[29], l18, k[16], l19, k[0],
	  l20, k[1], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[22], l20, k[37], l21, k[28], l22, k[45], l23, k[43],
	  l24, k[7], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[38], l24, k[14], l25, k[30], l26, k[8], l27, k[50],
	  l28, k[42], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[52], l28, k[51], l29, k[21], l30, k[9], l31, k[15],
	  l0, k[36], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[10], r0, k[6], r1, k[46], r2, k[55], r3, k[33],
	  r4, k[4], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[47], r4, k[26], r5, k[17], r6, k[11], r7, k[34],
	  r8, k[39], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[48], r8, k[20], r9, k[53], r10, k[54], r11, k[12],
	  r12, k[25], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[24], r12, k[18], r13, k[19], r14, k[27], r15, k[3],
	  r16, k[40], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[31], r16, k[49], r17, k[43], r18, k[30], r19, k[14],
	  r20, k[15], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[36], r20, k[51], r21, k[42], r22, k[0], r23, k[2],
	  r24, k[21], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[52], r24, k[28], r25, k[44], r26, k[22], r27, k[9],
	  r28, k[1], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[7], r28, k[38], r29, k[35], r30, k[23], r31, k[29],
	  r0, k[50], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[24], l0, k[20], l1, k[3], l2, k[12], l3, k[47],
	  l4, k[18], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[4], l4, k[40], l5, k[6], l6, k[25], l7, k[48],
	  l8, k[53], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[5], l8, k[34], l9, k[10], l10, k[11], l11, k[26],
	  l12, k[39], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[13], l12, k[32], l13, k[33], l14, k[41], l15, k[17],
	  l16, k[54], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[45], l16, k[8], l17, k[2], l18, k[44], l19, k[28],
	  l20, k[29], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[50], l20, k[38], l21, k[1], l22, k[14], l23, k[16],
	  l24, k[35], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[7], l24, k[42], l25, k[31], l26, k[36], l27, k[23],
	  l28, k[15], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[21], l28, k[52], l29, k[49], l30, k[37], l31, k[43],
	  l0, k[9], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[6], r0, k[27], r1, k[10], r2, k[19], r3, k[54],
	  r4, k[25], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[11], r4, k[47], r5, k[13], r6, k[32], r7, k[55],
	  r8, k[3], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[12], r8, k[41], r9, k[17], r10, k[18], r11, k[33],
	  r12, k[46], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[20], r12, k[39], r13, k[40], r14, k[48], r15, k[24],
	  r16, k[4], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[52], r16, k[15], r17, k[9], r18, k[51], r19, k[35],
	  r20, k[36], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[2], r20, k[45], r21, k[8], r22, k[21], r23, k[23],
	  r24, k[42], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[14], r24, k[49], r25, k[38], r26, k[43], r27, k[30],
	  r28, k[22], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[28], r28, k[0], r29, k[1], r30, k[44], r31, k[50],
	  r0, k[16], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[20], l0, k[41], l1, k[24], l2, k[33], l3, k[11],
	  l4, k[39], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[25], l4, k[4], l5, k[27], l6, k[46], l7, k[12],
	  l8, k[17], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[26], l8, k[55], l9, k[6], l10, k[32], l11, k[47],
	  l12, k[3], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[34], l12, k[53], l13, k[54], l14, k[5], l15, k[13],
	  l16, k[18], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[7], l16, k[29], l17, k[23], l18, k[38], l19, k[49],
	  l20, k[50], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[16], l20, k[0], l21, k[22], l22, k[35], l23, k[37],
	  l24, k[1], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[28], l24, k[8], l25, k[52], l26, k[2], l27, k[44],
	  l28, k[36], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[42], l28, k[14], l29, k[15], l30, k[31], l31, k[9],
	  l0, k[30], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[34], r0, k[55], r1, k[13], r2, k[47], r3, k[25],
	  r4, k[53], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[39], r4, k[18], r5, k[41], r6, k[3], r7, k[26],
	  r8, k[6], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[40], r8, k[12], r9, k[20], r10, k[46], r11, k[4],
	  r12, k[17], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[48], r12, k[10], r13, k[11], r14, k[19], r15, k[27],
	  r16, k[32], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[21], r16, k[43], r17, k[37], r18, k[52], r19, k[8],
	  r20, k[9], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[30], r20, k[14], r21, k[36], r22, k[49], r23, k[51],
	  r24, k[15], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[42], r24, k[22], r25, k[7], r26, k[16], r27, k[31],
	  r28, k[50], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[1], r28, k[28], r29, k[29], r30, k[45], r31, k[23],
	  r0, k[44], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[48], l0, k[12], l1, k[27], l2, k[4], l3, k[39],
	  l4, k[10], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[53], l4, k[32], l5, k[55], l6, k[17], l7, k[40],
	  l8, k[20], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[54], l8, k[26], l9, k[34], l10, k[3], l11, k[18],
	  l12, k[6], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[5], l12, k[24], l13, k[25], l14, k[33], l15, k[41],
	  l16, k[46], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[35], l16, k[2], l17, k[51], l18, k[7], l19, k[22],
	  l20, k[23], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[44], l20, k[28], l21, k[50], l22, k[8], l23, k[38],
	  l24, k[29], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[1], l24, k[36], l25, k[21], l26, k[30], l27, k[45],
	  l28, k[9], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[15], l28, k[42], l29, k[43], l30, k[0], l31, k[37],
	  l0, k[31], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[5], r0, k[26], r1, k[41], r2, k[18], r3, k[53],
	  r4, k[24], &l8, &l16, &l22, &l30);
  sse_s2 (r3, k[10], r4, k[46], r5, k[12], r6, k[6], r7, k[54],
	  r8, k[34], &l12, &l27, &l1, &l17);
  sse_s3 (r7, k[11], r8, k[40], r9, k[48], r10, k[17], r11, k[32],
	  r12, k[20], &l23, &l15, &l29, &l5);
  sse_s4 (r11, k[19], r12, k[13], r13, k[39], r14, k[47], r15, k[55],
	  r16, k[3], &l25, &l19, &l9, &l0);
  sse_s5 (r15, k[49], r16, k[16], r17, k[38], r18, k[21], r19, k[36],
	  r20, k[37], &l7, &l13, &l24, &l2);
  sse_s6 (r19, k[31], r20, k[42], r21, k[9], r22, k[22], r23, k[52],
	  r24, k[43], &l3, &l28, &l10, &l18);
  sse_s7 (r23, k[15], r24, k[50], r25, k[35], r26, k[44], r27, k[0],
	  r28, k[23], &l31, &l11, &l21, &l6);
  sse_s8 (r27, k[29], r28, k[1], r29, k[2], r30, k[14], r31, k[51],
	  r0, k[45], &l4, &l26, &l14, &l20);
  sse_s1 (l31, k[19], l0, k[40], l1, k[55], l2, k[32], l3, k[10],
	  l4, k[13], &r8, &r16, &r22, &r30);
  sse_s2 (l3, k[24], l4, k[3], l5, k[26], l6, k[20], l7, k[11],
	  l8, k[48], &r12, &r27, &r1, &r17);
  sse_s3 (l7, k[25], l8, k[54], l9, k[5], l10, k[6], l11, k[46],
	  l12, k[34], &r23, &r15, &r29, &r5);
  sse_s4 (l11, k[33], l12, k[27], l13, k[53], l14, k[4], l15, k[12],
	  l16, k[17], &r25, &r19, &r9, &r0);
  sse_s5 (l15, k[8], l16, k[30], l17, k[52], l18, k[35], l19, k[50],
	  l20, k[51], &r7, &r13, &r24, &r2);
  sse_s6 (l19, k[45], l20, k[1], l21, k[23], l22, k[36], l23, k[7],
	  l24, k[2], &r3, &r28, &r10, &r18);
  sse_s7 (l23, k[29], l24, k[9], l25, k[49], l26, k[31], l27, k[14],
	  l28, k[37], &r31, &r11, &r21, &r6);
  sse_s8 (l27, k[43], l28, k[15], l29, k[16], l30, k[28], l31, k[38],
	  l0, k[0], &r4, &r26, &r14, &r20);
  sse_s1 (r31, k[33], r0, k[54], r1, k[12], r2, k[46], r3, k[24],
	  r4, k[27], &l8, &l16, &l22, &l30);


  sse_s2 (r3, k[13], r4, k[17], r5, k[40], r6, k[34], r7, k[25],
	  r8, k[5], &l12, &l27, &l1, &l17);


  sse_s3 (r7, k[39], r8, k[11], r9, k[19], r10, k[20], r11, k[3],
	  r12, k[48], &l23, &l15, &l29, &l5);


  sse_s4 (r11, k[47], r12, k[41], r13, k[10], r14, k[18], r15, k[26],
	  r16, k[6], &l25, &l19, &l9, &l0);


  sse_s5 (r15, k[22], r16, k[44], r17, k[7], r18, k[49], r19, k[9],
	  r20, k[38], &l7, &l13, &l24, &l2);


  sse_s6 (r19, k[0], r20, k[15], r21, k[37], r22, k[50], r23, k[21],
	  r24, k[16], &l3, &l28, &l10, &l18);


  sse_s7 (r23, k[43], r24, k[23], r25, k[8], r26, k[45], r27, k[28],
	  r28, k[51], &l31, &l11, &l21, &l6);


  sse_s8 (r27, k[2], r28, k[29], r29, k[30], r30, k[42], r31, k[52],
	  r0, k[14], &l4, &l26, &l14, &l20);


  sse_s1 (l31, k[40], l0, k[4], l1, k[19], l2, k[53], l3, k[6],
	  l4, k[34], &r8, &r16, &r22, &r30);


  sse_s2 (l3, k[20], l4, k[24], l5, k[47], l6, k[41], l7, k[32],
	  l8, k[12], &r12, &r27, &r1, &r17);


  sse_s3 (l7, k[46], l8, k[18], l9, k[26], l10, k[27], l11, k[10],
	  l12, k[55], &r23, &r15, &r29, &r5);


  sse_s4 (l11, k[54], l12, k[48], l13, k[17], l14, k[25], l15, k[33],
	  l16, k[13], &r25, &r19, &r9, &r0);


  sse_s5 (l15, k[29], l16, k[51], l17, k[14], l18, k[1], l19, k[16],
	  l20, k[45], &r7, &r13, &r24, &r2);


  sse_s6 (l19, k[7], l20, k[22], l21, k[44], l22, k[2], l23, k[28],
	  l24, k[23], &r3, &r28, &r10, &r18);


  sse_s7 (l23, k[50], l24, k[30], l25, k[15], l26, k[52], l27, k[35],
	  l28, k[31], &r31, &r11, &r21, &r6);


  sse_s8 (l27, k[9], l28, k[36], l29, k[37], l30, k[49], l31, k[0],
	  l0, k[21], &r4, &r26, &r14, &r20);


  c[37]=l12;
  c[25]=l27;
  c[15]=l1;
  c[11]=l17;
  c[5]=l8;
  c[3]=l16;
  c[51]=l22;
  c[49]=l30;
  c[59]=l23;
  c[61]=l15;
  c[41]=l29;
  c[47]=l5;
  c[9]=l25;
  c[27]=l19;
  c[13]=l9;
  c[7]=l0;
  c[63]=l7;
  c[45]=l13;
  c[1]=l24;
  c[23]=l2;
  c[31]=l3;
  c[33]=l28;
  c[21]=l10;
  c[19]=l18;
  c[57]=l31;
  c[29]=l11;
  c[43]=l21;
  c[55]=l6;
  c[39]=l4;
  c[17]=l26;
  c[53]=l14;
  c[35]=l20;
  c[4]=r8;
  c[2]=r16;
  c[50]=r22;
  c[48]=r30;
  c[36]=r12;
  c[24]=r27;
  c[14]=r1;
  c[10]=r17;
  c[58]=r23;
  c[60]=r15;
  c[40]=r29;
  c[46]=r5;
  c[8]=r25;
  c[26]=r19;
  c[12]=r9;
  c[6]=r0;
  c[62]=r7;
  c[44]=r13;
  c[0]=r24;
  c[22]=r2;
  c[30]=r3;
  c[32]=r28;
  c[20]=r10;
  c[18]=r18;
  c[56]=r31;
  c[28]=r11;
  c[42]=r21;
  c[54]=r6;
  c[38]=r4;
  c[16]=r26;
  c[52]=r14;
  c[34]=r20;

}



/* deseval_SSE_salted is different than deseval_SSE. This is very much influenced
   by Solar Designer's code. I couldn't have salted the bitslice DES routine better 
   Still his has to be better as I keep two separate copies of the DES blocks in p and c */
void
deseval_SSE_salted (
	 __m128i 	*p,
	 __m128i 	*c,
	 __m128i 	*k,
	 char salt[2]
	 ) 
{

    __m128i 	e[48];
    __m128i 	temp;
    unsigned char DES_E[48] = {
    		31, 0, 1, 2, 3, 4,
                3, 4, 5, 6, 7, 8,
                7, 8, 9, 10, 11, 12,
                11, 12, 13, 14, 15, 16,
                15, 16, 17, 18, 19, 20,
                19, 20, 21, 22, 23, 24,
                23, 24, 25, 26, 27, 28,
                27, 28, 29, 30, 31, 0
    };
    int i;
    __m128i l[32];
    __m128i r[32];
    char st;

    l[0] = p[6];
    l[1] = p[14];
    l[2] = p[22];
    l[3] = p[30];
    l[4] = p[38];
    l[5] = p[46];
    l[6] = p[54];
    l[7] = p[62];
    l[8] = p[4];
    l[9] = p[12];
    l[10] = p[20];
    l[11] = p[28];
    l[12] = p[36];
    l[13] = p[44];
    l[14] = p[52];
    l[15] = p[60];
    l[16] = p[2];
    l[17] = p[10];
    l[18] = p[18];
    l[19] = p[26];
    l[20] = p[34];
    l[21] = p[42];
    l[22] = p[50];
    l[23] = p[58];
    l[24] = p[0];
    l[25] = p[8];
    l[26] = p[16];
    l[27] = p[24];
    l[28] = p[32];
    l[29] = p[40];
    l[30] = p[48];
    l[31] = p[56];
    r[0] = p[7];
    r[1] = p[15];
    r[2] = p[23];
    r[3] = p[31];
    r[4] = p[39];
    r[5] = p[47];
    r[6] = p[55];
    r[7] = p[63];
    r[8] = p[5];
    r[9] = p[13];
    r[10] = p[21];
    r[11] = p[29];
    r[12] = p[37];
    r[13] = p[45];
    r[14] = p[53];
    r[15] = p[61];
    r[16] = p[3];
    r[17] = p[11];
    r[18] = p[19];
    r[19] = p[27];
    r[20] = p[35];
    r[21] = p[43];
    r[22] = p[51];
    r[23] = p[59];
    r[24] = p[1];
    r[25] = p[9];
    r[26] = p[17];
    r[27] = p[25];
    r[28] = p[33];
    r[29] = p[41];
    r[30] = p[49];
    r[31] = p[57];
    
#define setsalt_r  \
    for (i=0;i<48;i+=2) { \
    e[i] = r[DES_E[i]]; \
    e[i+1] = r[DES_E[i+1]]; \
    } \
    st = salt[0]; \
    if(st>'Z') st -= 6; \
    if(st>'9') st -= 7; \
    st -= '.'; \
    if((st>>0) & 01) { temp = e[0];e[0]=e[24];e[24]=temp; } \
    if((st>>1) & 01) { temp = e[1];e[1]=e[25];e[25]=temp; } \
    if((st>>2) & 01) { temp = e[2];e[2]=e[26];e[26]=temp; } \
    if((st>>3) & 01) { temp = e[3];e[3]=e[27];e[27]=temp; } \
    if((st>>4) & 01) { temp = e[4];e[4]=e[28];e[28]=temp; } \
    if((st>>5) & 01) { temp = e[5];e[5]=e[29];e[29]=temp; } \
    st = salt[1]; \
    if(st>'Z') st -= 6; \
    if(st>'9') st -= 7; \
    st -= '.'; \
    if((st>>0) & 01) { temp = e[6];e[6]=e[30];e[30]=temp; } \
    if((st>>1) & 01) { temp = e[7];e[7]=e[31];e[31]=temp; } \
    if((st>>2) & 01) { temp = e[8];e[8]=e[32];e[32]=temp; } \
    if((st>>3) & 01) { temp = e[9];e[9]=e[33];e[33]=temp; } \
    if((st>>4) & 01) { temp = e[10];e[10]=e[34];e[34]=temp; } \
    if((st>>5) & 01) { temp = e[11];e[11]=e[35];e[35]=temp; } 

#define setsalt_l \
    for (i=0;i<48;i+=2) { \
    e[i] = l[DES_E[i]]; \
    e[i+1] = l[DES_E[i+1]]; \
    } \
    st = salt[0]; \
    if(st>'Z') st -= 6; \
    if(st>'9') st -= 7; \
    st -= '.'; \
    if((st>>0) & 01) { temp = e[0];e[0]=e[24];e[24]=temp; } \
    if((st>>1) & 01) { temp = e[1];e[1]=e[25];e[25]=temp; } \
    if((st>>2) & 01) { temp = e[2];e[2]=e[26];e[26]=temp; } \
    if((st>>3) & 01) { temp = e[3];e[3]=e[27];e[27]=temp; } \
    if((st>>4) & 01) { temp = e[4];e[4]=e[28];e[28]=temp; } \
    if((st>>5) & 01) { temp = e[5];e[5]=e[29];e[29]=temp; } \
    st = salt[1]; \
    if(st>'Z') st -= 6; \
    if(st>'9') st -= 7; \
    st -= '.'; \
    if((st>>0) & 01) { temp = e[6];e[6]=e[30];e[30]=temp; } \
    if((st>>1) & 01) { temp = e[7];e[7]=e[31];e[31]=temp; } \
    if((st>>2) & 01) { temp = e[8];e[8]=e[32];e[32]=temp; } \
    if((st>>3) & 01) { temp = e[9];e[9]=e[33];e[33]=temp; } \
    if((st>>4) & 01) { temp = e[10];e[10]=e[34];e[34]=temp; } \
    if((st>>5) & 01) { temp = e[11];e[11]=e[35];e[35]=temp; } 


  setsalt_r

  sse_s1 (e[0], k[47], e[1], k[11], e[2], k[26], e[3], k[3], e[4], k[13],
	  e[5], k[41], &l[8], &l[16], &l[22], &l[30]); 
  sse_s2 (e[6], k[27], e[7], k[6], e[8], k[54], e[9], k[48], e[10], k[39],
	  e[11], k[19], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[53], e[13], k[25], e[14], k[33], e[15], k[34], e[16], k[17],
	  e[17], k[5], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[4], e[19], k[55], e[20], k[24], e[21], k[32], e[22], k[40],
	  e[23], k[20], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[36], e[25], k[31], e[26], k[21], e[27], k[8], e[28], k[23],
	  e[29], k[52], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[14], e[31], k[29], e[32], k[51], e[33], k[9], e[34], k[35],
	  e[35], k[30], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[2], e[37], k[37], e[38], k[22], e[39], k[0], e[40], k[42],
	  e[41], k[38], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[16], e[43], k[43], e[44], k[44], e[45], k[1], e[46], k[7],
	  e[47], k[28], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[54], e[1], k[18], e[2], k[33], e[3], k[10], e[4], k[20],
	  e[5], k[48], &r[8], &r[16], &r[22], &r[30]); 
  sse_s2 (e[6], k[34], e[7], k[13], e[8], k[4], e[9], k[55], e[10], k[46],
	  e[11], k[26], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[3], e[13], k[32], e[14], k[40], e[15], k[41], e[16], k[24],
	  e[17], k[12], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[11], e[19], k[5], e[20], k[6], e[21], k[39], e[22], k[47],
	  e[23], k[27], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[43], e[25], k[38], e[26], k[28], e[27], k[15], e[28], k[30],
	  e[29], k[0], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[21], e[31], k[36], e[32], k[31], e[33], k[16], e[34], k[42],
	  e[35], k[37], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[9], e[37], k[44], e[38], k[29], e[39], k[7], e[40], k[49],
	  e[41], k[45], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[23], e[43], k[50], e[44], k[51], e[45], k[8], e[46], k[14],
	  e[47], k[35], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r

  sse_s1 (e[0], k[11], e[1], k[32], e[2], k[47], e[3], k[24], e[4], k[34],
	  e[5], k[5], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[48], e[7], k[27], e[8], k[18], e[9], k[12], e[10], k[3],
	  e[11], k[40], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[17], e[13], k[46], e[14], k[54], e[15], k[55], e[16], k[13],
	  e[17], k[26], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[25], e[19], k[19], e[20], k[20], e[21], k[53], e[22], k[4],
	  e[23], k[41], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[2], e[25], k[52], e[26], k[42], e[27], k[29], e[28], k[44],
	  e[29], k[14], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[35], e[31], k[50], e[32], k[45], e[33], k[30], e[34], k[1],
	  e[35], k[51], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[23], e[37], k[31], e[38], k[43], e[39], k[21], e[40], k[8],
	  e[41], k[0], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[37], e[43], k[9], e[44], k[38], e[45], k[22], e[46], k[28],
	  e[47], k[49], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l


  sse_s1 (e[0], k[25], e[1], k[46], e[2], k[4], e[3], k[13], e[4], k[48],
	  e[5], k[19], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[5], e[7], k[41], e[8], k[32], e[9], k[26], e[10], k[17],
	  e[11], k[54], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[6], e[13], k[3], e[14], k[11], e[15], k[12], e[16], k[27],
	  e[17], k[40], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[39], e[19], k[33], e[20], k[34], e[21], k[10], e[22], k[18],
	  e[23], k[55], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[16], e[25], k[7], e[26], k[1], e[27], k[43], e[28], k[31],
	  e[29], k[28], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[49], e[31], k[9], e[32], k[0], e[33], k[44], e[34], k[15],
	  e[35], k[38], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[37], e[37], k[45], e[38], k[2], e[39], k[35], e[40], k[22],
	  e[41], k[14], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[51], e[43], k[23], e[44], k[52], e[45], k[36], e[46], k[42],
	  e[47], k[8], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r


  sse_s1 (e[0], k[39], e[1], k[3], e[2], k[18], e[3], k[27], e[4], k[5],
	  e[5], k[33], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[19], e[7], k[55], e[8], k[46], e[9], k[40], e[10], k[6],
	  e[11], k[11], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[20], e[13], k[17], e[14], k[25], e[15], k[26], e[16], k[41],
	  e[17], k[54], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[53], e[19], k[47], e[20], k[48], e[21], k[24], e[22], k[32],
	  e[23], k[12], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[30], e[25], k[21], e[26], k[15], e[27], k[2], e[28], k[45],
	  e[29], k[42], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[8], e[31], k[23], e[32], k[14], e[33], k[31], e[34], k[29],
	  e[35], k[52], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[51], e[37], k[0], e[38], k[16], e[39], k[49], e[40], k[36],
	  e[41], k[28], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[38], e[43], k[37], e[44], k[7], e[45], k[50], e[46], k[1],
	  e[47], k[22], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[53], e[1], k[17], e[2], k[32], e[3], k[41], e[4], k[19],
	  e[5], k[47], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[33], e[7], k[12], e[8], k[3], e[9], k[54], e[10], k[20],
	  e[11], k[25], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[34], e[13], k[6], e[14], k[39], e[15], k[40], e[16], k[55],
	  e[17], k[11], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[10], e[19], k[4], e[20], k[5], e[21], k[13], e[22], k[46],
	  e[23], k[26], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[44], e[25], k[35], e[26], k[29], e[27], k[16], e[28], k[0],
	  e[29], k[1], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[22], e[31], k[37], e[32], k[28], e[33], k[45], e[34], k[43],
	  e[35], k[7], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[38], e[37], k[14], e[38], k[30], e[39], k[8], e[40], k[50],
	  e[41], k[42], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[52], e[43], k[51], e[44], k[21], e[45], k[9], e[46], k[15],
	  e[47], k[36], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r

  sse_s1 (e[0], k[10], e[1], k[6], e[2], k[46], e[3], k[55], e[4], k[33],
	  e[5], k[4], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[47], e[7], k[26], e[8], k[17], e[9], k[11], e[10], k[34],
	  e[11], k[39], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[48], e[13], k[20], e[14], k[53], e[15], k[54], e[16], k[12],
	  e[17], k[25], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[24], e[19], k[18], e[20], k[19], e[21], k[27], e[22], k[3],
	  e[23], k[40], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[31], e[25], k[49], e[26], k[43], e[27], k[30], e[28], k[14],
	  e[29], k[15], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[36], e[31], k[51], e[32], k[42], e[33], k[0], e[34], k[2],
	  e[35], k[21], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[52], e[37], k[28], e[38], k[44], e[39], k[22], e[40], k[9],
	  e[41], k[1], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[7], e[43], k[38], e[44], k[35], e[45], k[23], e[46], k[29],
	  e[47], k[50], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[24], e[1], k[20], e[2], k[3], e[3], k[12], e[4], k[47],
	  e[5], k[18], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[4], e[7], k[40], e[8], k[6], e[9], k[25], e[10], k[48],
	  e[11], k[53], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[5], e[13], k[34], e[14], k[10], e[15], k[11], e[16], k[26],
	  e[17], k[39], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[13], e[19], k[32], e[20], k[33], e[21], k[41], e[22], k[17],
	  e[23], k[54], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[45], e[25], k[8], e[26], k[2], e[27], k[44], e[28], k[28],
	  e[29], k[29], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[50], e[31], k[38], e[32], k[1], e[33], k[14], e[34], k[16],
	  e[35], k[35], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[7], e[37], k[42], e[38], k[31], e[39], k[36], e[40], k[23],
	  e[41], k[15], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[21], e[43], k[52], e[44], k[49], e[45], k[37], e[46], k[43],
	  e[47], k[9], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r

  sse_s1 (e[0], k[6], e[1], k[27], e[2], k[10], e[3], k[19], e[4], k[54],
	  e[5], k[25], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[11], e[7], k[47], e[8], k[13], e[9], k[32], e[10], k[55],
	  e[11], k[3], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[12], e[13], k[41], e[14], k[17], e[15], k[18], e[16], k[33],
	  e[17], k[46], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[20], e[19], k[39], e[20], k[40], e[21], k[48], e[22], k[24],
	  e[23], k[4], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[52], e[25], k[15], e[26], k[9], e[27], k[51], e[28], k[35],
	  e[29], k[36], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[2], e[31], k[45], e[32], k[8], e[33], k[21], e[34], k[23],
	  e[35], k[42], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[14], e[37], k[49], e[38], k[38], e[39], k[43], e[40], k[30],
	  e[41], k[22], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[28], e[43], k[0], e[44], k[1], e[45], k[44], e[46], k[50],
	  e[47], k[16], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[20], e[1], k[41], e[2], k[24], e[3], k[33], e[4], k[11],
	  e[5], k[39], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[25], e[7], k[4], e[8], k[27], e[9], k[46], e[10], k[12],
	  e[11], k[17], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[26], e[13], k[55], e[14], k[6], e[15], k[32], e[16], k[47],
	  e[17], k[3], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[34], e[19], k[53], e[20], k[54], e[21], k[5], e[22], k[13],
	  e[23], k[18], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[7], e[25], k[29], e[26], k[23], e[27], k[38], e[28], k[49],
	  e[29], k[50], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[16], e[31], k[0], e[32], k[22], e[33], k[35], e[34], k[37],
	  e[35], k[1], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[28], e[37], k[8], e[38], k[52], e[39], k[2], e[40], k[44],
	  e[41], k[36], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[42], e[43], k[14], e[44], k[15], e[45], k[31], e[46], k[9],
	  e[47], k[30], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r

  sse_s1 (e[0], k[34], e[1], k[55], e[2], k[13], e[3], k[47], e[4], k[25],
	  e[5], k[53], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[39], e[7], k[18], e[8], k[41], e[9], k[3], e[10], k[26],
	  e[11], k[6], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[40], e[13], k[12], e[14], k[20], e[15], k[46], e[16], k[4],
	  e[17], k[17], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[48], e[19], k[10], e[20], k[11], e[21], k[19], e[22], k[27],
	  e[23], k[32], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[21], e[25], k[43], e[26], k[37], e[27], k[52], e[28], k[8],
	  e[29], k[9], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[30], e[31], k[14], e[32], k[36], e[33], k[49], e[34], k[51],
	  e[35], k[15], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[42], e[37], k[22], e[38], k[7], e[39], k[16], e[40], k[31],
	  e[41], k[50], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[1], e[43], k[28], e[44], k[29], e[45], k[45], e[46], k[23],
	  e[47], k[44], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[48], e[1], k[12], e[2], k[27], e[3], k[4], e[4], k[39],
	  e[5], k[10], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[53], e[7], k[32], e[8], k[55], e[9], k[17], e[10], k[40],
	  e[11], k[20], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[54], e[13], k[26], e[14], k[34], e[15], k[3], e[16], k[18],
	  e[17], k[6], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[5], e[19], k[24], e[20], k[25], e[21], k[33], e[22], k[41],
	  e[23], k[46], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[35], e[25], k[2], e[26], k[51], e[27], k[7], e[28], k[22],
	  e[29], k[23], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[44], e[31], k[28], e[32], k[50], e[33], k[8], e[34], k[38],
	  e[35], k[29], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[1], e[37], k[36], e[38], k[21], e[39], k[30], e[40], k[45],
	  e[41], k[9], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[15], e[43], k[42], e[44], k[43], e[45], k[0], e[46], k[37],
	  e[47], k[31], &r[4], &r[26], &r[14], &r[20]);


  setsalt_r

  sse_s1 (e[0], k[5], e[1], k[26], e[2], k[41], e[3], k[18], e[4], k[53],
	  e[5], k[24], &l[8], &l[16], &l[22], &l[30]);
  sse_s2 (e[6], k[10], e[7], k[46], e[8], k[12], e[9], k[6], e[10], k[54],
	  e[11], k[34], &l[12], &l[27], &l[1], &l[17]);
  sse_s3 (e[12], k[11], e[13], k[40], e[14], k[48], e[15], k[17], e[16], k[32],
	  e[17], k[20], &l[23], &l[15], &l[29], &l[5]);
  sse_s4 (e[18], k[19], e[19], k[13], e[20], k[39], e[21], k[47], e[22], k[55],
	  e[23], k[3], &l[25], &l[19], &l[9], &l[0]);
  sse_s5 (e[24], k[49], e[25], k[16], e[26], k[38], e[27], k[21], e[28], k[36],
	  e[29], k[37], &l[7], &l[13], &l[24], &l[2]);
  sse_s6 (e[30], k[31], e[31], k[42], e[32], k[9], e[33], k[22], e[34], k[52],
	  e[35], k[43], &l[3], &l[28], &l[10], &l[18]);
  sse_s7 (e[36], k[15], e[37], k[50], e[38], k[35], e[39], k[44], e[40], k[0],
	  e[41], k[23], &l[31], &l[11], &l[21], &l[6]);
  sse_s8 (e[42], k[29], e[43], k[1], e[44], k[2], e[45], k[14], e[46], k[51],
	  e[47], k[45], &l[4], &l[26], &l[14], &l[20]);

  setsalt_l

  sse_s1 (e[0], k[19], e[1], k[40], e[2], k[55], e[3], k[32], e[4], k[10],
	  e[5], k[13], &r[8], &r[16], &r[22], &r[30]);
  sse_s2 (e[6], k[24], e[7], k[3], e[8], k[26], e[9], k[20], e[10], k[11],
	  e[11], k[48], &r[12], &r[27], &r[1], &r[17]);
  sse_s3 (e[12], k[25], e[13], k[54], e[14], k[5], e[15], k[6], e[16], k[46],
	  e[17], k[34], &r[23], &r[15], &r[29], &r[5]);
  sse_s4 (e[18], k[33], e[19], k[27], e[20], k[53], e[21], k[4], e[22], k[12],
	  e[23], k[17], &r[25], &r[19], &r[9], &r[0]);
  sse_s5 (e[24], k[8], e[25], k[30], e[26], k[52], e[27], k[35], e[28], k[50],
	  e[29], k[51], &r[7], &r[13], &r[24], &r[2]);
  sse_s6 (e[30], k[45], e[31], k[1], e[32], k[23], e[33], k[36], e[34], k[7],
	  e[35], k[2], &r[3], &r[28], &r[10], &r[18]);
  sse_s7 (e[36], k[29], e[37], k[9], e[38], k[49], e[39], k[31], e[40], k[14],
	  e[41], k[37], &r[31], &r[11], &r[21], &r[6]);
  sse_s8 (e[42], k[43], e[43], k[15], e[44], k[16], e[45], k[28], e[46], k[38],
	  e[47], k[0], &r[4], &r[26], &r[14], &r[20]);

  setsalt_r

  sse_s1 (e[0], k[33], e[1], k[54], e[2], k[12], e[3], k[46], e[4], k[24],
	  e[5], k[27], &l[8], &l[16], &l[22], &l[30]);

  c[5]=l[8];
  c[3]=l[16];
  c[51]=l[22];
  c[49]=l[30];

  sse_s2 (e[6], k[13], e[7], k[17], e[8], k[40], e[9], k[34], e[10], k[25],
	  e[11], k[5], &l[12], &l[27], &l[1], &l[17]);

  c[37]=l[12];
  c[25]=l[27];
  c[15]=l[1];
  c[11]=l[17];

  sse_s3 (e[12], k[39], e[13], k[11], e[14], k[19], e[15], k[20], e[16], k[3],
	  e[17], k[48], &l[23], &l[15], &l[29], &l[5]);

  c[59]=l[23];
  c[61]=l[15];
  c[41]=l[29];
  c[47]=l[5];

  sse_s4 (e[18], k[47], e[19], k[41], e[20], k[10], e[21], k[18], e[22], k[26],
	  e[23], k[6], &l[25], &l[19], &l[9], &l[0]);

  c[9]=l[25];
  c[27]=l[19];
  c[13]=l[9];
  c[7]=l[0];

  sse_s5 (e[24], k[22], e[25], k[44], e[26], k[7], e[27], k[49], e[28], k[9],
	  e[29], k[38], &l[7], &l[13], &l[24], &l[2]);

  c[63]=l[7];
  c[45]=l[13];
  c[1]=l[24];
  c[23]=l[2];

  sse_s6 (e[30], k[0], e[31], k[15], e[32], k[37], e[33], k[50], e[34], k[21],
	  e[35], k[16], &l[3], &l[28], &l[10], &l[18]);

  c[31]=l[3];
  c[33]=l[28];
  c[21]=l[10];
  c[19]=l[18];

  sse_s7 (e[36], k[43], e[37], k[23], e[38], k[8], e[39], k[45], e[40], k[28],
	  e[41], k[51], &l[31], &l[11], &l[21], &l[6]);

  c[57]=l[31];
  c[29]=l[11];
  c[43]=l[21];
  c[55]=l[6];

  sse_s8 (e[42], k[2], e[43], k[29], e[44], k[30], e[45], k[42], e[46], k[52],
	  e[47], k[14], &l[4], &l[26], &l[14], &l[20]);

  c[39]=l[4];
  c[17]=l[26];
  c[53]=l[14];
  c[35]=l[20];


  setsalt_l


  sse_s1 (e[0], k[40], e[1], k[4], e[2], k[19], e[3], k[53], e[4], k[6],
	  e[5], k[34], &r[8], &r[16], &r[22], &r[30]);

  c[4]=r[8];
  c[2]=r[16];
  c[50]=r[22];
  c[48]=r[30];

  sse_s2 (e[6], k[20], e[7], k[24], e[8], k[47], e[9], k[41], e[10], k[32],
	  e[11], k[12], &r[12], &r[27], &r[1], &r[17]);

  c[36]=r[12];
  c[24]=r[27];
  c[14]=r[1];
  c[10]=r[17];

  sse_s3 (e[12], k[46], e[13], k[18], e[14], k[26], e[15], k[27], e[16], k[10],
	  e[17], k[55], &r[23], &r[15], &r[29], &r[5]);

  c[58]=r[23];
  c[60]=r[15];
  c[40]=r[29];
  c[46]=r[5];

  sse_s4 (e[18], k[54], e[19], k[48], e[20], k[17], e[21], k[25], e[22], k[33],
	  e[23], k[13], &r[25], &r[19], &r[9], &r[0]);

  c[8]=r[25];
  c[26]=r[19];
  c[12]=r[9];
  c[6]=r[0];

  sse_s5 (e[24], k[29], e[25], k[51], e[26], k[14], e[27], k[1], e[28], k[16],
	  e[29], k[45], &r[7], &r[13], &r[24], &r[2]);

  c[62]=r[7];
  c[44]=r[13];
  c[0]=r[24];
  c[22]=r[2];

  sse_s6 (e[30], k[7], e[31], k[22], e[32], k[44], e[33], k[2], e[34], k[28],
	  e[35], k[23], &r[3], &r[28], &r[10], &r[18]);

  c[30]=r[3];
  c[32]=r[28];
  c[20]=r[10];
  c[18]=r[18];

  sse_s7 (e[36], k[50], e[37], k[30], e[38], k[15], e[39], k[52], e[40], k[35],
	  e[41], k[31], &r[31], &r[11], &r[21], &r[6]);

  c[56]=r[31];
  c[28]=r[11];
  c[42]=r[21];
  c[54]=r[6];

  sse_s8 (e[42], k[9], e[43], k[36], e[44], k[37], e[45], k[49], e[46], k[0],
	  e[47], k[21], &r[4], &r[26], &r[14], &r[20]);

  c[38]=r[4];
  c[16]=r[26];
  c[52]=r[14];
  c[34]=r[20];

}

#endif
