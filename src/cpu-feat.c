/* 
 * cpu-feat.c
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

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <pthread.h>
#include <openssl/aes.h>
#include "cpu-feat.h"
#include "threads.h"
#include "err.h"
#include "hashinterface.h"


#define cpuid1(func,ax,bx,cx,dx)\
    __asm__ __volatile__ ("cpuid":\
    "=a" (ax), "=b" (bx), "=c" (cx), "=d" (dx) : "a" (func));


/* Global variables */


/* Function prototypes */
hash_stat cpu_feat_setup();



extern hash_stat MD5_SSE(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_SSE_SHORT(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_SSE_FIXED(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_SSE_SHORT_FIXED(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_XOP(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_XOP_SHORT(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_XOP_FIXED(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
extern hash_stat MD5_XOP_SHORT_FIXED(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
extern hash_stat SHA1_SSE(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat SHA1_SSE_SHORT(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat SHA1_SSE_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat SHA1_SSE_SHORT_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat SHA1_XOP(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat SHA1_XOP_SHORT(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat SHA1_XOP_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat SHA1_XOP_SHORT_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat MD4_SSE(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat MD4_SSE_SHORT(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat MD4_SSE_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat MD4_SSE_SHORT_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat MD4_XOP(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat MD4_XOP_SHORT(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
extern hash_stat MD4_XOP_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat MD4_XOP_SHORT_FIXED(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
extern hash_stat DES_FCRYPT_SSE(char salt[3], char *plains[128], char *out[128]);
extern void DES_ONEBLOCK_SSE(char ukey[8], char *plains[128], char *out[128]);
extern void DES_LM_SSE(char *plains[128], char *out[128]);
extern void DES_CBC_XOP(char ukey[8], char *plains[128], char *out[128], char *ivs[128], int lens[128]);
extern hash_stat DES_FCRYPT_XOP(char salt[3], char *plains[128], char *out[128]);
extern void DES_ONEBLOCK_XOP(char ukey[8], char *plains[128], char *out[128]);
extern void DES_LM_XOP(char *plains[128], char *out[128]);
extern void DES_CBC_XOP(char ukey[8], char *plains[128], char *out[128], char *ivs[128], int lens[128]);
extern void MD5_PREPARE_OPT(void);
extern void SHA1_PREPARE_OPT(void);
extern void MD4_PREPARE_OPT(void);
extern void FCRYPT_PREPARE_OPT(void);
extern void MD5_PREPARE_OPT_XOP(void);
extern void SHA1_PREPARE_OPT_XOP(void);
extern void MD4_PREPARE_OPT_XOP(void);
extern void FCRYPT_PREPARE_OPT_XOP(void);
extern void AESNI_cbc_encrypt(const unsigned char *in, unsigned char *out,unsigned char ivec[16],unsigned long length,unsigned char *key,int number_of_rounds);
extern int AESNI_set_encrypt_key (const unsigned char *userKey,const int bits,AES_KEY *key);
extern int AESNI_set_decrypt_key (const unsigned char *userKey, const int bits, AES_KEY *key);



void cpuid(unsigned info, unsigned *eax, unsigned *ebx, unsigned *ecx, unsigned *edx)
{
  *eax = info;
  __asm volatile
    ("mov %%ebx, %%edi;" /* 32bit PIC: don't clobber ebx */
      "cpuid;"
      "mov %%ebx, %%esi;"
      "mov %%edi, %%ebx;"
      :"+a" (*eax), "=S" (*ebx), "=c" (*ecx), "=d" (*edx)
      : :"edi");
}



/* Functions */
hash_stat cpu_feat_setup()
{
#ifdef HAVE_SSE2
    unsigned int ax,bx,cx,dx;
    int sse3,sse41,sse42,avx,xop,aesni;
    char *features;
    
    sse3=sse41=sse42=avx=xop=aesni=0;
    
    cpuid(0x80000001,&ax,&bx,&cx,&dx);
    if ((cx>>11)&1) xop=1;
    if ((cx>>28)&1) avx=1;
    if ((cx>>0)&1) sse3=1;
    if ((cx>>19)&1) sse41=1;
    if ((cx>>20)&1) sse42=1;
    if ((cx>>25)&1) aesni=1;

    /* set SSE2 defaults */
    OMD5 = MD5_SSE;
    OMD5_SHORT = MD5_SSE_SHORT;
    OMD5_FIXED = MD5_SSE_FIXED;
    OMD5_SHORT_FIXED = MD5_SSE_SHORT_FIXED;
    OSHA1 = SHA1_SSE;
    OSHA1_SHORT = SHA1_SSE_SHORT;
    OSHA1_FIXED = SHA1_SSE_FIXED;
    OSHA1_SHORT_FIXED = SHA1_SSE_SHORT_FIXED;
    OMD4 = MD4_SSE;
    OMD4_SHORT = MD4_SSE_SHORT;
    OMD4_FIXED = MD4_SSE_FIXED;
    OMD4_SHORT_FIXED = MD4_SSE_SHORT_FIXED;
    ODES_FCRYPT = DES_FCRYPT_SSE;
    ODES_ONEBLOCK = DES_ONEBLOCK_SSE;
    ODES_LM = DES_LM_SSE;
    //ODES_CBC = DES_CBC_SSE;
    OMD5_PREPARE_OPT = MD5_PREPARE_OPT;
    OMD4_PREPARE_OPT = MD4_PREPARE_OPT;
    OSHA1_PREPARE_OPT = SHA1_PREPARE_OPT;
    OFCRYPT_PREPARE_OPT = FCRYPT_PREPARE_OPT;
    OAES_CBC_ENCRYPT = (void*)AES_cbc_encrypt;
    OAES_SET_ENCRYPT_KEY = AES_set_encrypt_key;
    OAES_SET_DECRYPT_KEY = AES_set_decrypt_key;

    features=malloc(128);
    sprintf(features,"SSE2");
    if (sse3) strcat(features," SSE3");
    if (sse41) strcat(features," SSE4.1");
    if (sse42) strcat(features," SSE4.2");
    if (avx) strcat(features," AVX");
    if (xop) 
    {
	OMD5 = MD5_XOP;
	OMD5_SHORT = MD5_XOP_SHORT;
	OMD5_FIXED = MD5_XOP_FIXED;
	OMD5_SHORT_FIXED = MD5_XOP_SHORT_FIXED;
	OMD5_PREPARE_OPT = MD5_PREPARE_OPT_XOP;
	OSHA1 = SHA1_XOP;
	OSHA1_SHORT = SHA1_XOP_SHORT;
	OSHA1_FIXED = SHA1_XOP_FIXED;
	OSHA1_SHORT_FIXED = SHA1_XOP_SHORT_FIXED;
	OSHA1_PREPARE_OPT = SHA1_PREPARE_OPT_XOP;
	OMD4 = MD4_XOP;
	OMD4_SHORT = MD4_XOP_SHORT;
	OMD4_FIXED = MD4_XOP_FIXED;
	OMD4_SHORT_FIXED = MD4_XOP_SHORT_FIXED;
	OMD4_PREPARE_OPT = MD4_PREPARE_OPT_XOP;
	ODES_ONEBLOCK = DES_ONEBLOCK_XOP;
	ODES_LM = DES_LM_XOP;
	ODES_FCRYPT = DES_FCRYPT_XOP;
	OFCRYPT_PREPARE_OPT = FCRYPT_PREPARE_OPT_XOP;
	strcat(features," XOP");
    }
    if (aesni) 
    {
	OAES_CBC_ENCRYPT = (void *)AESNI_cbc_encrypt;
	OAES_SET_ENCRYPT_KEY = AESNI_set_encrypt_key;
	OAES_SET_DECRYPT_KEY = AESNI_set_decrypt_key;
	strcat(features," AES-NI");
    }
    
    if (sse3) hlog("CPU features: %s\n",features);
    free(features);
    return hash_ok;
#else
    return hash_err;
#endif
}
