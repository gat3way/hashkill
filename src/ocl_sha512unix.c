/*
 * ocl_sha512unix.c
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

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <openssl/sha.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"

#define MIN(a,b) ((a) < (b) ? a : b)
static int hash_ret_len1=64;

static unsigned const char cov_2char[65]="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

//Pick out the 16 bytes in this order: 
// 63 62 20 41 40 61 19 18 39 60 59 17 38 37 58 16 15 36 57 56 14 35 34 55 
// 13 12 33 54 53 11 32 31 52 10 9 30 51 50 8 29 28 49 7 6 27 48 47 5 26 
// 25 46 4 3 24 45 44 2 23 22 43 1 0 21 42
static int b64_pton_crypt(unsigned char const *src, unsigned char *target)
{
    int y,j;
    unsigned char c1,c2,c3,c4;
    

    c1=c2=c3=c4=0;
    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[3]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[2]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[1]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[0]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[0]=(y>>24)&255;
    target[21]=(y>>16)&255;
    target[42]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[7]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[6]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[5]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[4]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[22]=(y>>24)&255;
    target[43]=(y>>16)&255;
    target[1]=(y>>8)&255;
    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[11]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[10]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[9]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[8]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[44]=(y>>24)&255;
    target[2]=(y>>16)&255;
    target[23]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[15]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[14]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[13]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[12]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[3]=(y>>24)&255;
    target[24]=(y>>16)&255;
    target[45]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[19]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[18]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[17]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[16]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[25]=(y>>24)&255;
    target[46]=(y>>16)&255;
    target[4]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[23]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[22]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[21]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[20]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[47]=(y>>24)&255;
    target[5]=(y>>16)&255;
    target[26]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[27]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[26]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[25]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[24]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[6]=(y>>24)&255;
    target[27]=(y>>16)&255;
    target[48]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[31]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[30]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[29]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[28]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[28]=(y>>24)&255;
    target[49]=(y>>16)&255;
    target[7]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[35]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[34]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[33]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[32]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[50]=(y>>24)&255;
    target[8]=(y>>16)&255;
    target[29]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[39]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[38]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[37]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[36]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[9]=(y>>24)&255;
    target[30]=(y>>16)&255;
    target[51]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[43]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[42]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[41]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[40]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[31]=(y>>24)&255;
    target[52]=(y>>16)&255;
    target[10]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[47]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[46]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[45]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[44]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[53]=(y>>24)&255;
    target[11]=(y>>16)&255;
    target[32]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[51]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[50]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[49]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[48]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[12]=(y>>24)&255;
    target[33]=(y>>16)&255;
    target[54]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[55]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[54]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[53]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[52]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[34]=(y>>24)&255;
    target[55]=(y>>16)&255;
    target[13]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[59]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[58]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[57]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[56]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[56]=(y>>24)&255;
    target[14]=(y>>16)&255;
    target[35]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[63]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[62]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[61]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[60]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[15]=(y>>24)&255;
    target[36]=(y>>16)&255;
    target[57]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[67]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[66]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[65]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[64]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[37]=(y>>24)&255;
    target[58]=(y>>16)&255;
    target[16]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[71]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[70]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[69]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[68]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[59]=(y>>24)&255;
    target[17]=(y>>16)&255;
    target[38]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[75]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[74]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[73]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[72]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[18]=(y>>24)&255;
    target[39]=(y>>16)&255;
    target[60]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[79]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[78]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[77]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[76]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[40]=(y>>24)&255;
    target[61]=(y>>16)&255;
    target[19]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[83]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[82]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[81]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[80]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[62]=(y>>24)&255;
    target[20]=(y>>16)&255;
    target[41]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[87]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[86]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[85]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[84]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    //target[63]=(y>>24)&255;
    //target[63]=(y>>16)&255;
    target[63]=(y>>8)&255;


    return 0;
}


static void setup_spint0(char *key, char *salt, char *result)
{
    char *p_bytes;
    char *s_bytes;
    char *cp;
    char *bigbuf, *bigbuf2;
    int bbl, bbl2;
    int cnt;
    int key_len = strlen(key);
    int salt_len = MIN (strcspn (salt, "$"), 16);
    unsigned char *alt_result;
    unsigned char *temp_result;
    SHA512_CTX ctx;

    bigbuf=alloca(4255);
    bigbuf2=alloca(4255);
    p_bytes=alloca(16);
    s_bytes=alloca(16);
    alt_result=alloca(4255);
    temp_result=alloca(4255);
    bbl=0;
    bbl2=0;
    bzero(result,96);

    memcpy(bigbuf, key, key_len);
    bbl += key_len;
    memcpy(bigbuf+bbl, salt, salt_len);
    bbl += salt_len;
    memcpy(bigbuf2, key, key_len);
    bbl2 += key_len;
    memcpy(bigbuf2+bbl2, salt, salt_len);
    bbl2 += salt_len;
    memcpy(bigbuf2+bbl2, key, key_len);
    bbl2 += key_len;


    SHA512_Init(&ctx);
    SHA512_Update(&ctx, bigbuf2, bbl2);
    SHA512_Final((unsigned char *)alt_result,&ctx);
    //hash_sha512_unicode(bigbuf2, alt_result, bbl2);

    bbl2 = 0;

    for (cnt = key_len; cnt > 64; cnt -= 64)
    {
        memcpy(bigbuf+bbl, alt_result, 64);
        bbl += 64;
    }
    memcpy(bigbuf+bbl, alt_result, cnt);
    bbl += cnt;

    for (cnt = key_len; cnt > 0; cnt >>= 1)
    if ((cnt & 1) != 0)
    {
      memcpy(bigbuf+bbl, alt_result, 64);
      bbl += 64;
    }
    else
    {
      memcpy(bigbuf+bbl, key, key_len);
      bbl += key_len;
    }
    SHA512_Init(&ctx);
    SHA512_Update(&ctx, bigbuf, bbl);
    SHA512_Final((unsigned char *)alt_result,&ctx);
    //hash_sha512_unicode(bigbuf, alt_result, bbl);

    bbl = 0;
    for (cnt = 0; cnt < key_len; ++cnt)
    {
        memcpy(bigbuf2+bbl2, key, key_len);
        bbl2 += key_len;
    }

    SHA512_Init(&ctx);
    SHA512_Update(&ctx, bigbuf2, bbl2);
    SHA512_Final((unsigned char *)temp_result,&ctx);
    //hash_sha512_unicode(bigbuf2, temp_result, bbl2);
    bbl2 = 0;


    /* Create byte sequence P.  */
    cp = p_bytes = alloca (key_len);
    bzero(p_bytes,16);
    for (cnt = key_len; cnt >= 64; cnt -= 64)
    cp = memcpy (cp, temp_result, 64);
    memcpy (cp, temp_result, cnt);

    bbl2 = 0;
    for (cnt = 0; cnt < (16 + (alt_result[0]&255)); ++cnt)
    {
        memcpy(bigbuf2+bbl2, salt, salt_len);
        bbl2 += salt_len;
    }

    SHA512_Init(&ctx);
    SHA512_Update(&ctx, bigbuf2, bbl2);
    SHA512_Final((unsigned char *)temp_result,&ctx);
    //hash_sha512_unicode(bigbuf2, temp_result, bbl2);
    bbl2=0;
    /* Create byte sequence S.  */
    cp = s_bytes = alloca (salt_len);
    bzero(s_bytes,16);
    for (cnt = salt_len; cnt >= 64; cnt -= 64)
        cp = memcpy (cp, temp_result, 64);
    memcpy (cp, temp_result, cnt);
    bbl=0;

    /* prepare end buffer: sbytes+int0+pbytes */
    memset(result,0,16);
    memcpy(result,s_bytes,strlen(salt));
    memcpy(result+16,alt_result,64);
    memcpy(result+64+16,p_bytes,key_len);
}



/* Crack callback */
static void ocl_sha512unix_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];
    char hex1[16];
    cl_uint16 salt;
    cl_ulong8 singlehash;
    unsigned char base64[89];
    int cc,cc1;
    size_t gws,gws1;

    cc = self_kernel16[self];
    cc1 = self_kernel16[self]+strlen(line);
    if (cc1>15) cc1=15;
    mylist = hash_list;
    while (mylist)
    {
        if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
	salt.sC=cc1;
	/* setup_psalt */
        unsigned char mhash[89];
        memcpy(base64,mylist->hash,88);
        b64_pton_crypt(base64,mhash);
        uint64_t A1,A2,A3,A4,A5,A6,A7,A8;
        memcpy(hex1,mhash,8);
        memcpy(&A1, hex1, 8);
        memcpy(hex1,mhash+8,8);
        memcpy(&A2, hex1, 8);
        memcpy(hex1,mhash+16,8);
        memcpy(&A3, hex1, 8);
        memcpy(hex1,mhash+24,8);
        memcpy(&A4, hex1, 8);
        memcpy(hex1,mhash+32,8);
        memcpy(&A5, hex1, 8);
        memcpy(hex1,mhash+40,8);
        memcpy(&A6, hex1, 8);
        memcpy(hex1,mhash+48,8);
        memcpy(&A7, hex1, 8);
        memcpy(hex1,mhash+56,8);
        memcpy(&A8, hex1, 8);
        singlehash.s0=A1;singlehash.s1=A2;singlehash.s2=A3;singlehash.s3=A4;
        singlehash.s4=A5;singlehash.s5=A6;singlehash.s6=A7;singlehash.s7=A8;

	if (rule_counts[self][cc]==-1) return;
        gws = (rule_counts[self][cc] / wthreads[self].vectorsize);
        while ((gws%64)!=0) gws++;
        gws1 = gws*wthreads[self].vectorsize;
        if (gws1==0) gws1=64;
        if (gws==0) gws=64;

        for (a=0;a<gws;a++)
        {
	    char candidate[32];
	    bzero(candidate,32);
	    bzero(hex1,16);
            memcpy(hex1,mylist->salt+3,strlen(mylist->salt)-4);
	    salt.sD=strlen(hex1);
            strcpy(candidate,rule_images162[cc][self]+(a*16));
            strcat(candidate,line);
            setup_spint0(candidate,hex1,&rule_images16[cc1][self][0]+(a*96));
            if (attack_over!=0) pthread_exit(NULL);
        }

	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images16_buf[cc1][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*96, rule_images16[cc1][self], 0, NULL, NULL);
        if (attack_over!=0) pthread_exit(NULL);
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);


	/* Set sha512unixm, sha512unixe then the transform kernels */
        _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);
        _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes162_buf[cc1][self]);
        _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_mem), (void*) &rule_sizes16_buf[cc1][self]);
        _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
        _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint16), (void*) &salt);
        _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes162_buf[cc1][self]);
        _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &salt);
        _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_ulong8), (void*) &singlehash);
        _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes162_buf[cc1][self]);
        _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt);
        _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_ulong8), (void*) &singlehash);
        _clSetKernelArg(rule_kernelend[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
        _clSetKernelArg(rule_kernelend[self], 1, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
        _clSetKernelArg(rule_kernelend[self], 2, sizeof(cl_mem), (void*) &rule_sizes162_buf[cc1][self]);
        _clSetKernelArg(rule_kernelend[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernelend[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
        _clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint16), (void*) &salt);
        _clSetKernelArg(rule_kernelend[self], 6, sizeof(cl_ulong8), (void*) &singlehash);


	/* Now call first transform00+4999*(transformX+sha512unixm+sha512unixe) */
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	for (a=0;a<5000;a+=200)
	{
	    if (attack_over!=0) pthread_exit(NULL);
	    salt.sA=a;
	    salt.sB=a+200;
	    if (salt.sB>5000) salt.sB=5000;
	    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
    	    wthreads[self].tries+=(wthreads[self].vectorsize*ocl_rule_workset[self])/(get_hashes_num()*25);
            if (attack_over!=0) pthread_exit(NULL);
	}
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
        if (err!=CL_SUCCESS) continue;
        if (*found>0) 
        {
            _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<gws;a++)
	    if (rule_found_ind[self]!=0)
	    {
		b=a*wthreads[self].vectorsize;
    		_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*hash_ret_len1, hash_ret_len1*wthreads[self].vectorsize, rule_ptr[self]+b*hash_ret_len1, 0, NULL, NULL);
		for (c=0;c<wthreads[self].vectorsize;c++)
		{
	    	    e=(a)*wthreads[self].vectorsize+c;
                    unsigned char mhash[89];
                    memcpy(base64,mylist->hash,88);
                    b64_pton_crypt(base64,mhash);
    		    if (memcmp(mhash, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1-2) == 0)
    		    {
            		int flag = 0;
                	strcpy(plain,&rule_images162[cc][self][0]+(e*16));
                	strcat(plain,line);
                	pthread_mutex_lock(&crackedmutex);
                	addlist = cracked_list;
                	while (addlist)
                	{
                	    if ((strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len1) == 0))
                                flag = 1;
                    	    addlist = addlist->next;
                	}
                	pthread_mutex_unlock(&crackedmutex);
                	if (flag == 0)
                	{
                	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                	    mylist->salt2[0]=1;
                	}
    		    }
		}
	    }
	    bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    *found = 0;
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
	}
	_clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
	mylist = mylist->next;
    }
}



static void ocl_sha512unix_callback(char *line, int self)
{
    int cc=0;

    if (line[0]!=0x01)
    {
	cc=strlen(line);
	if (cc>15) cc=15;
	rule_counts[self][cc]++;
	strncpy(&rule_images162[cc][self][0]+(rule_counts[self][cc]*16),line,15);
    }


    if (rule_counts[self][cc]==ocl_rule_workset[self]*wthreads[self].vectorsize-1)
    {
	//_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes162[self], 0, NULL, NULL);
	self_kernel16[self]=cc;
	rule_offload_perform(ocl_sha512unix_crack_callback,self);
    	bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
	rule_counts[self][cc]=-1;
    }

    if (line[0]==0x01)
    for (cc=1;cc<16;cc++)
    {
	self_kernel16[self]=cc;
	//_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes162[self], 0, NULL, NULL);
	rule_offload_perform(ocl_sha512unix_crack_callback,self);
    	bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
	rule_counts[self][cc]=-1;
    }
    if (attack_over!=0) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_sha512unix_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    int a;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*128*2;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    for (a=0;a<16;a++)
    {
        rule_images16_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*96, NULL, &err );
        rule_images162_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*96, NULL, &err );
        rule_images163_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*96, NULL, &err );
        rule_sizes16_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), NULL, &err );
        rule_sizes162_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), NULL, &err );
        rule_sizes16[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
        rule_sizes162[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
        rule_images16[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        rule_images162[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        rule_images163[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        bzero(&rule_images16[a][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        bzero(&rule_images162[a][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        bzero(&rule_images163[a][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*96);
        rule_counts[self][a]=-1;
    }
    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "block", &err );
    rule_kernelend[self] = _clCreateKernel(program[self], "final", &err );



    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_sha512unix_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_sha512unix(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_sha512unix(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_sha512unix(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_sha512unix__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_sha512unix__%s.ptx",DATADIR,pbuf);

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


    pthread_mutex_init(&biglock, NULL);

    for (a=0;a<nwthreads;a++)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_rule_sha512unix_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_sha512unix_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

