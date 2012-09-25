/* 
 * hashinterface.c
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
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <pthread.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <dirent.h>
#include <openssl/md5.h>
#include <openssl/sha.h>
#include <openssl/des.h>
#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <openssl/rsa.h>
#include <openssl/hmac.h>
#include <openssl/ripemd.h>
#include <openssl/aes.h>
#include <openssl/md4.h>
#include <openssl/des.h>
#include "err.h"
#include "hashinterface.h"
#include "threads.h"
#include "plugins.h"
#include "cpu-feat.h"




/* Global variables */
char temp_username[HASHFILE_MAX_PLAIN_LENGTH];	// temporary username
char temp_salt[HASHFILE_MAX_PLAIN_LENGTH];	// temporary salt
char temp_salt2[HASHFILE_MAX_PLAIN_LENGTH];	// temporary salt2
char temp_hash[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash
char temp_orighash[HASHFILE_MAX_PLAIN_LENGTH*8];// temporary hash
char temp_data1[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash
char temp_data2[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash
char temp_data3[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash
char temp_data4[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash
char temp_data5[HASHFILE_MAX_PLAIN_LENGTH];	// temporary hash


/* Function prototypes */
void hash_proto_md5(char *  plaintext[VECTORSIZE], char *  hash[VECTORSIZE], int len, int threadid);
void hash_proto_md5_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_sha1(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid);
void hash_proto_sha1_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_sha256_unicode(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha256_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_sha512_unicode(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha512_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_fcrypt(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]);
void hash_proto_add_username(const char *username);
void hash_proto_add_hash(const char *hash, int len);
void hash_proto_add_salt(const char *salt);
void hash_proto_add_salt2(const char *salt2);

hash_stat add_hash_list(char *username, char *hash, char *salt, char *salt2);
hash_stat add_cracked_list(char *username, char *hash, char *salt, char *salt2);
hash_stat del_hash_list(struct hash_list_s *node);
hash_stat del_cracked_list(struct hash_list_s *node);
void print_hash_list(void);
void print_cracked_list(void);
void print_cracked_list_to_file(char *filename);
int get_cracked_num(void);
int get_hashes_num(void);
void cleanup_lists(void);
void markov_attack_init(void);
void markov_print_statfiles(void);
hash_stat markov_load_statfile(char *statname);


static char privkey[8192];



#ifdef HAVE_SSE2
/* Optimized strlen() for x86 architectures */
#define strlen my_strlen
size_t my_strlen(const char *s) {
    size_t len = 0;
    for(;;) {
        unsigned x = *(unsigned*)s;
        if((x & 0xFF) == 0) return len;
        if((x & 0xFF00) == 0) return len + 1;
        if((x & 0xFF0000) == 0) return len + 2;
        if((x & 0xFF000000) == 0) return len + 3;
        s += 4, len += 4;
    }
}
#endif




/* MD5() proto function */
void hash_proto_md5(char *  plaintext[VECTORSIZE], char *  hash[VECTORSIZE], int len, int threadid)
{
    int a;
    int lens[VECTORSIZE];
    int lensflag = 0;

#ifndef HAVE_SSE2
    MD5_CTX ctx;
    for (a=0;a<vectorsize;a++)
    {
	MD5_Init(&ctx);
	MD5_Update(&ctx, plaintext[a], strlen(plaintext[a]));
	MD5_Final((unsigned char *)hash[a],&ctx);
    }
#else
    if (threadid != THREAD_LENPROVIDED)
    {
	for (a=0;a<vectorsize;a++)
	{
	    lens[a]=strlen(plaintext[a]);
	    if (lens[a]>11) lensflag=1;
	}
	if (lensflag == 0) OMD5_SHORT((unsigned char **)plaintext, lens, (unsigned char **)hash);
	else OMD5((unsigned char **)plaintext, lens, (unsigned char **)hash);
    }
    else 
    {
	if (len<12)
	{
	    OMD5_SHORT_FIXED((unsigned char **)plaintext, len, (unsigned char **)hash);
	}
	else 
	{
	    OMD5_FIXED((unsigned char **)plaintext, len, (unsigned char **)hash);
	}
    }
#endif
}



/* MD5 proto function - unicode*/
void hash_proto_md5_unicode(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{

#ifndef HAVE_SSE2
    int a;
    MD5_CTX ctx;
    for (a=0;a<vectorsize;a++)
    {
	MD5_Init(&ctx);
	MD5_Update(&ctx, plaintext[a], len[a]);
	MD5_Final((unsigned char *)hash[a],&ctx);
    }
#else
    OMD5((unsigned char **)plaintext, len, (unsigned char **)hash);
#endif
}



/* MD5 proto function - unicode*/
void hash_proto_md5_unicode_slow(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{
    int a;
    MD5_CTX ctx;
    for (a=0;a<vectorsize;a++)
    {
	MD5_Init(&ctx);
	MD5_Update(&ctx, plaintext[a], len[a]);
	MD5_Final((unsigned char *)hash[a],&ctx);
    }
}



/* MD5() slow openssl proto function */
void hash_proto_md5_slow(char *plaintext[VECTORSIZE], char * hash[VECTORSIZE], int len, int threadid)
{
    int a,b;
    MD5_CTX ctx;
    int lens[VECTORSIZE];
    int lensflag=0;
    
    if (threadid != THREAD_LENPROVIDED) 
    {
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a]=strlen(plaintext[a]);
	    if (lens[a]>15) lensflag = 1;
	}
	if (lensflag == 0) 
	{
	    for (b=0;b<vectorsize;b++)
	    {
		MD5_Init(&ctx);
		MD5_Update(&ctx, plaintext[b], lens[b]);
		MD5_Final((unsigned char *)hash[b],&ctx);
	    }
	}
	else for (b=0;b<vectorsize;b++)
	{
	    MD5_Init(&ctx);
	    MD5_Update(&ctx, plaintext[b], lens[b]);
	    MD5_Final((unsigned char *)hash[b],&ctx);
	}
	return;
    }
    else 
    {
	if (len>15) lensflag = 1;
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a]=len;
	}
	if (lensflag == 0) 
	for (b=0;b<vectorsize;b++)
	{
	    MD5_Init(&ctx);
	    MD5_Update(&ctx, plaintext[b], lens[b]);
	    MD5_Final((unsigned char *)hash[b],&ctx);
	}
	else for (b=0;b<vectorsize;b++)
	{
	    MD5_Init(&ctx);
	    MD5_Update(&ctx, plaintext[b], lens[b]);
	    MD5_Final((unsigned char *)hash[b],&ctx);
	}
	return;
    }
}



/* MD4() proto function */
void hash_proto_md4(char *plaintext[VECTORSIZE], char * hash[VECTORSIZE], int len[VECTORSIZE],int threadid)
{

#ifndef HAVE_SSE2

    MD4_CTX ctx;
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	MD4_Init(&ctx);
	MD4_Update(&ctx, plaintext[a], len[a]);
	MD4_Final((unsigned char *)hash[a],&ctx);
    }
#else
    int a,lensflag;
    if (threadid == 0) 
    {
	for (a=0;a<vectorsize;a++) 
	{
	    if (len[a]>15) lensflag=1;
	}
	if (lensflag == 0) OMD4_SHORT(plaintext, hash,len);
	else OMD4(plaintext, hash,len);
	return;
    }
    else 
    {
	if (threadid>15) OMD4_FIXED(plaintext, hash,threadid);
	else OMD4_SHORT_FIXED(plaintext, hash,threadid);
	return;
    }

#endif
}


/* MD4() openssl proto function */
void hash_proto_md4_slow(char *plaintext[VECTORSIZE], char * hash[VECTORSIZE], int len[VECTORSIZE],int threadid)
{
    MD4_CTX ctx;
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	MD4_Init(&ctx);
	MD4_Update(&ctx, plaintext[a], len[a]);
	MD4_Final((unsigned char *)hash[a],&ctx);
    }
}



/* MD5 digest -> hex str */
void hash_proto_md5_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])
{
    unsigned char charset[17]="0123456789abcdef";
    int cnt;

    for (cnt=0;cnt<vectorsize;cnt++)
    {
        *(hashhex[cnt]+0) = charset[(unsigned char)*(hash[cnt])>>4];
        *(hashhex[cnt]+1) = charset[(unsigned char)*(hash[cnt])&15];
        *(hashhex[cnt]+2) = charset[(unsigned char)*(hash[cnt]+1)>>4];
        *(hashhex[cnt]+3) = charset[(unsigned char)*(hash[cnt]+1)&15];
        *(hashhex[cnt]+4) = charset[(unsigned char)*(hash[cnt]+2)>>4];
        *(hashhex[cnt]+5) = charset[(unsigned char)*(hash[cnt]+2)&15];
        *(hashhex[cnt]+6) = charset[(unsigned char)*(hash[cnt]+3)>>4];
        *(hashhex[cnt]+7) = charset[(unsigned char)*(hash[cnt]+3)&15];
        *(hashhex[cnt]+8) = charset[(unsigned char)*(hash[cnt]+4)>>4];
        *(hashhex[cnt]+9) = charset[(unsigned char)*(hash[cnt]+4)&15];
        *(hashhex[cnt]+10) = charset[(unsigned char)*(hash[cnt]+5)>>4];
        *(hashhex[cnt]+11) = charset[(unsigned char)*(hash[cnt]+5)&15];
        *(hashhex[cnt]+12) = charset[(unsigned char)*(hash[cnt]+6)>>4];
        *(hashhex[cnt]+13) = charset[(unsigned char)*(hash[cnt]+6)&15];
        *(hashhex[cnt]+14) = charset[(unsigned char)*(hash[cnt]+7)>>4];
        *(hashhex[cnt]+15) = charset[(unsigned char)*(hash[cnt]+7)&15];
        *(hashhex[cnt]+16) = charset[(unsigned char)*(hash[cnt]+8)>>4];
        *(hashhex[cnt]+17) = charset[(unsigned char)*(hash[cnt]+8)&15];
        *(hashhex[cnt]+18) = charset[(unsigned char)*(hash[cnt]+9)>>4];
        *(hashhex[cnt]+19) = charset[(unsigned char)*(hash[cnt]+9)&15];
        *(hashhex[cnt]+20) = charset[(unsigned char)*(hash[cnt]+10)>>4];
        *(hashhex[cnt]+21) = charset[(unsigned char)*(hash[cnt]+10)&15];
        *(hashhex[cnt]+22) = charset[(unsigned char)*(hash[cnt]+11)>>4];
        *(hashhex[cnt]+23) = charset[(unsigned char)*(hash[cnt]+11)&15];
        *(hashhex[cnt]+24) = charset[(unsigned char)*(hash[cnt]+12)>>4];
        *(hashhex[cnt]+25) = charset[(unsigned char)*(hash[cnt]+12)&15];
        *(hashhex[cnt]+26) = charset[(unsigned char)*(hash[cnt]+13)>>4];
        *(hashhex[cnt]+27) = charset[(unsigned char)*(hash[cnt]+13)&15];
        *(hashhex[cnt]+28) = charset[(unsigned char)*(hash[cnt]+14)>>4];
        *(hashhex[cnt]+29) = charset[(unsigned char)*(hash[cnt]+14)&15];
        *(hashhex[cnt]+30) = charset[(unsigned char)*(hash[cnt]+15)>>4];
        *(hashhex[cnt]+31) = charset[(unsigned char)*(hash[cnt]+15)&15];
        *(hashhex[cnt]+32) = 0;
    }
}


/* SHA1 proto function */
void hash_proto_sha1(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid)
{

#ifndef HAVE_SSE2

    SHA_CTX ctx;
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, plaintext[a], strlen(plaintext[a]));
	SHA1_Final((unsigned char *)hash[a],&ctx);
    }
#else
    int lens[VECTORSIZE];
    int a;
    int lensflag=0;

    if (threadid != THREAD_LENPROVIDED) 
    {
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a]=strlen(plaintext[a]);
	    if (lens[a]>15) lensflag = 1;
	}
	if (lensflag == 0) OSHA1_SHORT((char **)plaintext, (char **)hash, lens);
	else OSHA1((char **)plaintext, (char **)hash, lens);
	return;
    }
    else 
    {
	if (len>15) OSHA1_FIXED((char **)plaintext, (char **)hash, len);
	else OSHA1_SHORT_FIXED((char **)plaintext, (char **)hash, len);
	return;
    }
#endif
}




/* SHA1 proto function - unicode*/
void hash_proto_sha1_unicode(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{
#ifndef HAVE_SSE2

    SHA_CTX ctx;
    int a;
    for (a=0;a<vectorsize;a++)
    {
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, plaintext[a], len[a]);
	SHA1_Final((unsigned char *)hash[a],&ctx);
    }
#else
    OSHA1((char **)plaintext, (char **)hash, len);
#endif
}




/* SHA1 proto function - slow*/
void hash_proto_sha1_slow(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{
    int a;

    for (a=0;a<vectorsize;a++)
    {
	SHA_CTX ctx;
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, plaintext[a], len[a]);
	SHA1_Final((unsigned char *)hash[a],&ctx);
    }
}



/* RIPEMD160 proto function */
void hash_proto_ripemd160(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int lens[VECTORSIZE])
{
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	RIPEMD160_CTX ctx;
	RIPEMD160_Init(&ctx);
	RIPEMD160_Update(&ctx, plaintext[a], lens[a]);
	RIPEMD160_Final((unsigned char *)hash[a],&ctx);
    }
}



/* SHA1 digest -> hex str */
void hash_proto_sha1_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])
{
    unsigned char charset[17]="0123456789abcdef";
    int cnt;

    for (cnt=0;cnt<vectorsize;cnt++)
    {
        *(hashhex[cnt]+1) = charset[(unsigned char)*(hash[cnt])&15];
	*(hashhex[cnt]+0) = charset[(unsigned char)*(hash[cnt])>>4];
        *(hashhex[cnt]+3) = charset[(unsigned char)*(hash[cnt]+1)&15];
        *(hashhex[cnt]+2) = charset[(unsigned char)*(hash[cnt]+1)>>4];
        *(hashhex[cnt]+5) = charset[(unsigned char)*(hash[cnt]+2)&15];
        *(hashhex[cnt]+4) = charset[(unsigned char)*(hash[cnt]+2)>>4];
        *(hashhex[cnt]+7) = charset[(unsigned char)*(hash[cnt]+3)&15];
        *(hashhex[cnt]+6) = charset[(unsigned char)*(hash[cnt]+3)>>4];
        *(hashhex[cnt]+9) = charset[(unsigned char)*(hash[cnt]+4)&15];
        *(hashhex[cnt]+8) = charset[(unsigned char)*(hash[cnt]+4)>>4];
        *(hashhex[cnt]+11) = charset[(unsigned char)*(hash[cnt]+5)&15];
        *(hashhex[cnt]+10) = charset[(unsigned char)*(hash[cnt]+5)>>4];
        *(hashhex[cnt]+13) = charset[(unsigned char)*(hash[cnt]+6)&15];
        *(hashhex[cnt]+12) = charset[(unsigned char)*(hash[cnt]+6)>>4];
        *(hashhex[cnt]+15) = charset[(unsigned char)*(hash[cnt]+7)&15];
        *(hashhex[cnt]+14) = charset[(unsigned char)*(hash[cnt]+7)>>4];
        *(hashhex[cnt]+17) = charset[(unsigned char)*(hash[cnt]+8)&15];
        *(hashhex[cnt]+16) = charset[(unsigned char)*(hash[cnt]+8)>>4];
        *(hashhex[cnt]+19) = charset[(unsigned char)*(hash[cnt]+9)&15];
        *(hashhex[cnt]+18) = charset[(unsigned char)*(hash[cnt]+9)>>4];
        *(hashhex[cnt]+21) = charset[(unsigned char)*(hash[cnt]+10)&15];
        *(hashhex[cnt]+20) = charset[(unsigned char)*(hash[cnt]+10)>>4];
        *(hashhex[cnt]+23) = charset[(unsigned char)*(hash[cnt]+11)&15];
        *(hashhex[cnt]+22) = charset[(unsigned char)*(hash[cnt]+11)>>4];
        *(hashhex[cnt]+25) = charset[(unsigned char)*(hash[cnt]+12)&15];
        *(hashhex[cnt]+24) = charset[(unsigned char)*(hash[cnt]+12)>>4];
        *(hashhex[cnt]+27) = charset[(unsigned char)*(hash[cnt]+13)&15];
        *(hashhex[cnt]+26) = charset[(unsigned char)*(hash[cnt]+13)>>4];
        *(hashhex[cnt]+29) = charset[(unsigned char)*(hash[cnt]+14)&15];
        *(hashhex[cnt]+28) = charset[(unsigned char)*(hash[cnt]+14)>>4];
        *(hashhex[cnt]+31) = charset[(unsigned char)*(hash[cnt]+15)&15];
        *(hashhex[cnt]+30) = charset[(unsigned char)*(hash[cnt]+15)>>4];
        *(hashhex[cnt]+33) = charset[(unsigned char)*(hash[cnt]+16)&15];
        *(hashhex[cnt]+32) = charset[(unsigned char)*(hash[cnt]+16)>>4];
        *(hashhex[cnt]+35) = charset[(unsigned char)*(hash[cnt]+17)&15];
        *(hashhex[cnt]+34) = charset[(unsigned char)*(hash[cnt]+17)>>4];
        *(hashhex[cnt]+37) = charset[(unsigned char)*(hash[cnt]+18)&15];
        *(hashhex[cnt]+36) = charset[(unsigned char)*(hash[cnt]+18)>>4];
        *(hashhex[cnt]+39) = charset[(unsigned char)*(hash[cnt]+19)&15];
        *(hashhex[cnt]+38) = charset[(unsigned char)*(hash[cnt]+19)>>4];
        *(hashhex[cnt]+40) = 0;
    }
}


/* SHA256 proto function */
void hash_proto_sha256_unicode(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{
    int a;
    SHA256_CTX ctx;
    
    for (a=0;a<vectorsize;a++)
    {
	SHA256_Init(&ctx);
	SHA256_Update(&ctx, plaintext[a], len[a]);
	SHA256_Final((unsigned char *)hash[a],&ctx);
    }
}


/* SHA256 -> hexstr */
void hash_proto_sha256_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])
{
    unsigned char charset[17]="0123456789abcdef";
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
    *(hashhex[a]+1) = charset[(unsigned char)*(hash[a])&15];
    *(hashhex[a]+0) = charset[(unsigned char)*(hash[a])>>4];
    *(hashhex[a]+3) = charset[(unsigned char)*(hash[a]+1)&15];
    *(hashhex[a]+2) = charset[(unsigned char)*(hash[a]+1)>>4];
    *(hashhex[a]+5) = charset[(unsigned char)*(hash[a]+2)&15];
    *(hashhex[a]+4) = charset[(unsigned char)*(hash[a]+2)>>4];
    *(hashhex[a]+7) = charset[(unsigned char)*(hash[a]+3)&15];
    *(hashhex[a]+6) = charset[(unsigned char)*(hash[a]+3)>>4];
    *(hashhex[a]+9) = charset[(unsigned char)*(hash[a]+4)&15];
    *(hashhex[a]+8) = charset[(unsigned char)*(hash[a]+4)>>4];
    *(hashhex[a]+11) = charset[(unsigned char)*(hash[a]+5)&15];
    *(hashhex[a]+10) = charset[(unsigned char)*(hash[a]+5)>>4];
    *(hashhex[a]+13) = charset[(unsigned char)*(hash[a]+6)&15];
    *(hashhex[a]+12) = charset[(unsigned char)*(hash[a]+6)>>4];
    *(hashhex[a]+15) = charset[(unsigned char)*(hash[a]+7)&15];
    *(hashhex[a]+14) = charset[(unsigned char)*(hash[a]+7)>>4];
    *(hashhex[a]+17) = charset[(unsigned char)*(hash[a]+8)&15];
    *(hashhex[a]+16) = charset[(unsigned char)*(hash[a]+8)>>4];
    *(hashhex[a]+19) = charset[(unsigned char)*(hash[a]+9)&15];
    *(hashhex[a]+18) = charset[(unsigned char)*(hash[a]+9)>>4];
    *(hashhex[a]+21) = charset[(unsigned char)*(hash[a]+10)&15];
    *(hashhex[a]+20) = charset[(unsigned char)*(hash[a]+10)>>4];
    *(hashhex[a]+23) = charset[(unsigned char)*(hash[a]+11)&15];
    *(hashhex[a]+22) = charset[(unsigned char)*(hash[a]+11)>>4];
    *(hashhex[a]+25) = charset[(unsigned char)*(hash[a]+12)&15];
    *(hashhex[a]+24) = charset[(unsigned char)*(hash[a]+12)>>4];
    *(hashhex[a]+27) = charset[(unsigned char)*(hash[a]+13)&15];
    *(hashhex[a]+26) = charset[(unsigned char)*(hash[a]+13)>>4];
    *(hashhex[a]+29) = charset[(unsigned char)*(hash[a]+14)&15];
    *(hashhex[a]+28) = charset[(unsigned char)*(hash[a]+14)>>4];
    *(hashhex[a]+31) = charset[(unsigned char)*(hash[a]+15)&15];
    *(hashhex[a]+30) = charset[(unsigned char)*(hash[a]+15)>>4];
    *(hashhex[a]+33) = charset[(unsigned char)*(hash[a]+16)&15];
    *(hashhex[a]+32) = charset[(unsigned char)*(hash[a]+16)>>4];
    *(hashhex[a]+35) = charset[(unsigned char)*(hash[a]+17)&15];
    *(hashhex[a]+34) = charset[(unsigned char)*(hash[a]+17)>>4];
    *(hashhex[a]+37) = charset[(unsigned char)*(hash[a]+18)&15];
    *(hashhex[a]+36) = charset[(unsigned char)*(hash[a]+18)>>4];
    *(hashhex[a]+39) = charset[(unsigned char)*(hash[a]+19)&15];
    *(hashhex[a]+38) = charset[(unsigned char)*(hash[a]+19)>>4];
    *(hashhex[a]+40) = charset[(unsigned char)*(hash[a]+20)>>4];
    *(hashhex[a]+41) = charset[(unsigned char)*(hash[a]+20)&15];
    *(hashhex[a]+42) = charset[(unsigned char)*(hash[a]+21)>>4];
    *(hashhex[a]+43) = charset[(unsigned char)*(hash[a]+21)&15];
    *(hashhex[a]+44) = charset[(unsigned char)*(hash[a]+22)>>4];
    *(hashhex[a]+45) = charset[(unsigned char)*(hash[a]+22)&15];
    *(hashhex[a]+46) = charset[(unsigned char)*(hash[a]+23)>>4];
    *(hashhex[a]+47) = charset[(unsigned char)*(hash[a]+23)&15];
    *(hashhex[a]+48) = charset[(unsigned char)*(hash[a]+24)>>4];
    *(hashhex[a]+49) = charset[(unsigned char)*(hash[a]+24)&15];
    *(hashhex[a]+50) = charset[(unsigned char)*(hash[a]+25)>>4];
    *(hashhex[a]+51) = charset[(unsigned char)*(hash[a]+25)&15];
    *(hashhex[a]+52) = charset[(unsigned char)*(hash[a]+26)>>4];
    *(hashhex[a]+53) = charset[(unsigned char)*(hash[a]+26)&15];
    *(hashhex[a]+54) = charset[(unsigned char)*(hash[a]+27)>>4];
    *(hashhex[a]+55) = charset[(unsigned char)*(hash[a]+27)&15];
    *(hashhex[a]+56) = charset[(unsigned char)*(hash[a]+28)>>4];
    *(hashhex[a]+57) = charset[(unsigned char)*(hash[a]+28)&15];
    *(hashhex[a]+58) = charset[(unsigned char)*(hash[a]+29)>>4];
    *(hashhex[a]+59) = charset[(unsigned char)*(hash[a]+29)&15];
    *(hashhex[a]+60) = charset[(unsigned char)*(hash[a]+30)>>4];
    *(hashhex[a]+61) = charset[(unsigned char)*(hash[a]+30)&15];
    *(hashhex[a]+62) = charset[(unsigned char)*(hash[a]+31)>>4];
    *(hashhex[a]+63) = charset[(unsigned char)*(hash[a]+31)&15];
    *(hashhex[a]+64) = 0;
    }
}


/* proto SHA512 function */
void hash_proto_sha512_unicode(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])
{
    SHA512_CTX ctx;
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	SHA512_Init(&ctx);
	SHA512_Update(&ctx, plaintext[a], len[a]);
	SHA512_Final((unsigned char *)hash[a],&ctx);
    }
}



/* SHA512 -> hexstr */
void hash_proto_sha512_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])
{
    unsigned char charset[17]="0123456789abcdef";
    int a;

    for (a=0;a<vectorsize;a++)
    {
    *(hashhex[a]+1) = charset[(unsigned char)*(hash[a])&15];
    *(hashhex[a]+0) = charset[(unsigned char)*(hash[a])>>4];
    *(hashhex[a]+3) = charset[(unsigned char)*(hash[a]+1)&15];
    *(hashhex[a]+2) = charset[(unsigned char)*(hash[a]+1)>>4];
    *(hashhex[a]+5) = charset[(unsigned char)*(hash[a]+2)&15];
    *(hashhex[a]+4) = charset[(unsigned char)*(hash[a]+2)>>4];
    *(hashhex[a]+7) = charset[(unsigned char)*(hash[a]+3)&15];
    *(hashhex[a]+6) = charset[(unsigned char)*(hash[a]+3)>>4];
    *(hashhex[a]+9) = charset[(unsigned char)*(hash[a]+4)&15];
    *(hashhex[a]+8) = charset[(unsigned char)*(hash[a]+4)>>4];
    *(hashhex[a]+11) = charset[(unsigned char)*(hash[a]+5)&15];
    *(hashhex[a]+10) = charset[(unsigned char)*(hash[a]+5)>>4];
    *(hashhex[a]+13) = charset[(unsigned char)*(hash[a]+6)&15];
    *(hashhex[a]+12) = charset[(unsigned char)*(hash[a]+6)>>4];
    *(hashhex[a]+15) = charset[(unsigned char)*(hash[a]+7)&15];
    *(hashhex[a]+14) = charset[(unsigned char)*(hash[a]+7)>>4];
    *(hashhex[a]+17) = charset[(unsigned char)*(hash[a]+8)&15];
    *(hashhex[a]+16) = charset[(unsigned char)*(hash[a]+8)>>4];
    *(hashhex[a]+19) = charset[(unsigned char)*(hash[a]+9)&15];
    *(hashhex[a]+18) = charset[(unsigned char)*(hash[a]+9)>>4];
    *(hashhex[a]+21) = charset[(unsigned char)*(hash[a]+10)&15];
    *(hashhex[a]+20) = charset[(unsigned char)*(hash[a]+10)>>4];
    *(hashhex[a]+23) = charset[(unsigned char)*(hash[a]+11)&15];
    *(hashhex[a]+22) = charset[(unsigned char)*(hash[a]+11)>>4];
    *(hashhex[a]+25) = charset[(unsigned char)*(hash[a]+12)&15];
    *(hashhex[a]+24) = charset[(unsigned char)*(hash[a]+12)>>4];
    *(hashhex[a]+27) = charset[(unsigned char)*(hash[a]+13)&15];
    *(hashhex[a]+26) = charset[(unsigned char)*(hash[a]+13)>>4];
    *(hashhex[a]+29) = charset[(unsigned char)*(hash[a]+14)&15];
    *(hashhex[a]+28) = charset[(unsigned char)*(hash[a]+14)>>4];
    *(hashhex[a]+31) = charset[(unsigned char)*(hash[a]+15)&15];
    *(hashhex[a]+30) = charset[(unsigned char)*(hash[a]+15)>>4];
    *(hashhex[a]+33) = charset[(unsigned char)*(hash[a]+16)&15];
    *(hashhex[a]+32) = charset[(unsigned char)*(hash[a]+16)>>4];
    *(hashhex[a]+35) = charset[(unsigned char)*(hash[a]+17)&15];
    *(hashhex[a]+34) = charset[(unsigned char)*(hash[a]+17)>>4];
    *(hashhex[a]+37) = charset[(unsigned char)*(hash[a]+18)&15];
    *(hashhex[a]+36) = charset[(unsigned char)*(hash[a]+18)>>4];
    *(hashhex[a]+39) = charset[(unsigned char)*(hash[a]+19)&15];
    *(hashhex[a]+38) = charset[(unsigned char)*(hash[a]+19)>>4];
    *(hashhex[a]+40) = charset[(unsigned char)*(hash[a]+20)>>4];
    *(hashhex[a]+41) = charset[(unsigned char)*(hash[a]+20)&15];
    *(hashhex[a]+42) = charset[(unsigned char)*(hash[a]+21)>>4];
    *(hashhex[a]+43) = charset[(unsigned char)*(hash[a]+21)&15];
    *(hashhex[a]+44) = charset[(unsigned char)*(hash[a]+22)>>4];
    *(hashhex[a]+45) = charset[(unsigned char)*(hash[a]+22)&15];
    *(hashhex[a]+46) = charset[(unsigned char)*(hash[a]+23)>>4];
    *(hashhex[a]+47) = charset[(unsigned char)*(hash[a]+23)&15];
    *(hashhex[a]+48) = charset[(unsigned char)*(hash[a]+24)>>4];
    *(hashhex[a]+49) = charset[(unsigned char)*(hash[a]+24)&15];
    *(hashhex[a]+50) = charset[(unsigned char)*(hash[a]+25)>>4];
    *(hashhex[a]+51) = charset[(unsigned char)*(hash[a]+25)&15];
    *(hashhex[a]+52) = charset[(unsigned char)*(hash[a]+26)>>4];
    *(hashhex[a]+53) = charset[(unsigned char)*(hash[a]+26)&15];
    *(hashhex[a]+54) = charset[(unsigned char)*(hash[a]+27)>>4];
    *(hashhex[a]+55) = charset[(unsigned char)*(hash[a]+27)&15];
    *(hashhex[a]+56) = charset[(unsigned char)*(hash[a]+28)>>4];
    *(hashhex[a]+57) = charset[(unsigned char)*(hash[a]+28)&15];
    *(hashhex[a]+58) = charset[(unsigned char)*(hash[a]+29)>>4];
    *(hashhex[a]+59) = charset[(unsigned char)*(hash[a]+29)&15];
    *(hashhex[a]+60) = charset[(unsigned char)*(hash[a]+30)>>4];
    *(hashhex[a]+61) = charset[(unsigned char)*(hash[a]+30)&15];
    *(hashhex[a]+62) = charset[(unsigned char)*(hash[a]+31)>>4];
    *(hashhex[a]+63) = charset[(unsigned char)*(hash[a]+31)&15];
    *(hashhex[a]+64) = charset[(unsigned char)*(hash[a]+32)>>4];
    *(hashhex[a]+65) = charset[(unsigned char)*(hash[a]+32)&15];
    *(hashhex[a]+66) = charset[(unsigned char)*(hash[a]+33)>>4];
    *(hashhex[a]+67) = charset[(unsigned char)*(hash[a]+33)&15];
    *(hashhex[a]+68) = charset[(unsigned char)*(hash[a]+34)>>4];
    *(hashhex[a]+69) = charset[(unsigned char)*(hash[a]+34)&15];
    *(hashhex[a]+70) = charset[(unsigned char)*(hash[a]+35)>>4];
    *(hashhex[a]+71) = charset[(unsigned char)*(hash[a]+35)&15];
    *(hashhex[a]+72) = charset[(unsigned char)*(hash[a]+36)>>4];
    *(hashhex[a]+73) = charset[(unsigned char)*(hash[a]+36)&15];
    *(hashhex[a]+74) = charset[(unsigned char)*(hash[a]+37)>>4];
    *(hashhex[a]+75) = charset[(unsigned char)*(hash[a]+37)&15];
    *(hashhex[a]+76) = charset[(unsigned char)*(hash[a]+38)>>4];
    *(hashhex[a]+77) = charset[(unsigned char)*(hash[a]+38)&15];
    *(hashhex[a]+78) = charset[(unsigned char)*(hash[a]+39)>>4];
    *(hashhex[a]+79) = charset[(unsigned char)*(hash[a]+39)&15];
    *(hashhex[a]+80) = charset[(unsigned char)*(hash[a]+40)>>4];
    *(hashhex[a]+81) = charset[(unsigned char)*(hash[a]+40)&15];
    *(hashhex[a]+82) = charset[(unsigned char)*(hash[a]+41)>>4];
    *(hashhex[a]+83) = charset[(unsigned char)*(hash[a]+41)&15];
    *(hashhex[a]+84) = charset[(unsigned char)*(hash[a]+42)>>4];
    *(hashhex[a]+85) = charset[(unsigned char)*(hash[a]+42)&15];
    *(hashhex[a]+86) = charset[(unsigned char)*(hash[a]+43)>>4];
    *(hashhex[a]+87) = charset[(unsigned char)*(hash[a]+43)&15];
    *(hashhex[a]+88) = charset[(unsigned char)*(hash[a]+44)>>4];
    *(hashhex[a]+89) = charset[(unsigned char)*(hash[a]+44)&15];
    *(hashhex[a]+90) = charset[(unsigned char)*(hash[a]+45)>>4];
    *(hashhex[a]+91) = charset[(unsigned char)*(hash[a]+45)&15];
    *(hashhex[a]+92) = charset[(unsigned char)*(hash[a]+46)>>4];
    *(hashhex[a]+93) = charset[(unsigned char)*(hash[a]+46)&15];
    *(hashhex[a]+94) = charset[(unsigned char)*(hash[a]+47)>>4];
    *(hashhex[a]+95) = charset[(unsigned char)*(hash[a]+47)&15];
    *(hashhex[a]+96) = charset[(unsigned char)*(hash[a]+48)>>4];
    *(hashhex[a]+97) = charset[(unsigned char)*(hash[a]+48)&15];
    *(hashhex[a]+98) = charset[(unsigned char)*(hash[a]+49)>>4];
    *(hashhex[a]+99) = charset[(unsigned char)*(hash[a]+49)&15];
    *(hashhex[a]+100) = charset[(unsigned char)*(hash[a]+50)>>4];
    *(hashhex[a]+101) = charset[(unsigned char)*(hash[a]+50)&15];
    *(hashhex[a]+102) = charset[(unsigned char)*(hash[a]+51)>>4];
    *(hashhex[a]+103) = charset[(unsigned char)*(hash[a]+51)&15];
    *(hashhex[a]+104) = charset[(unsigned char)*(hash[a]+52)>>4];
    *(hashhex[a]+105) = charset[(unsigned char)*(hash[a]+52)&15];
    *(hashhex[a]+106) = charset[(unsigned char)*(hash[a]+53)>>4];
    *(hashhex[a]+107) = charset[(unsigned char)*(hash[a]+53)&15];
    *(hashhex[a]+108) = charset[(unsigned char)*(hash[a]+54)>>4];
    *(hashhex[a]+109) = charset[(unsigned char)*(hash[a]+54)&15];
    *(hashhex[a]+110) = charset[(unsigned char)*(hash[a]+55)>>4];
    *(hashhex[a]+111) = charset[(unsigned char)*(hash[a]+55)&15];
    *(hashhex[a]+112) = charset[(unsigned char)*(hash[a]+56)>>4];
    *(hashhex[a]+113) = charset[(unsigned char)*(hash[a]+56)&15];
    *(hashhex[a]+114) = charset[(unsigned char)*(hash[a]+57)>>4];
    *(hashhex[a]+115) = charset[(unsigned char)*(hash[a]+57)&15];
    *(hashhex[a]+116) = charset[(unsigned char)*(hash[a]+58)>>4];
    *(hashhex[a]+117) = charset[(unsigned char)*(hash[a]+58)&15];
    *(hashhex[a]+118) = charset[(unsigned char)*(hash[a]+59)>>4];
    *(hashhex[a]+119) = charset[(unsigned char)*(hash[a]+59)&15];
    *(hashhex[a]+120) = charset[(unsigned char)*(hash[a]+60)>>4];
    *(hashhex[a]+121) = charset[(unsigned char)*(hash[a]+60)&15];
    *(hashhex[a]+122) = charset[(unsigned char)*(hash[a]+61)>>4];
    *(hashhex[a]+123) = charset[(unsigned char)*(hash[a]+61)&15];
    *(hashhex[a]+124) = charset[(unsigned char)*(hash[a]+62)>>4];
    *(hashhex[a]+125) = charset[(unsigned char)*(hash[a]+62)&15];
    *(hashhex[a]+126) = charset[(unsigned char)*(hash[a]+63)>>4];
    *(hashhex[a]+127) = charset[(unsigned char)*(hash[a]+63)&15];
    *(hashhex[a]+128) = 0;
    }
}


/* DES_fcrypt() from openssl */
void hash_proto_fcrypt(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE])
{
#ifndef HAVE_SSE2
    int a;
    for (a=0;a<vectorsize;a++) DES_fcrypt(password[a], salt, ret[a]);
#else
    ODES_FCRYPT((char *)salt, (char **)password, ret);
#endif
} 





/* BIO_s_mem -> readonly BIO with contents taken from FILE *file */
void hash_proto_new_biomem(FILE *file)
{
    char filedata[8192];

    fread(filedata, 8192, 1, file);
    filedata[8191] = 0;
    memcpy(privkey,filedata,8192);
    
}



/* PEM_read_RSAPrivateKey from openssl */
void hash_proto_PEM_readfile(const char *passphrase, int *RSAret)
{
    EVP_PKEY *mykey;
    BIO *localbio=NULL;
    
    localbio = BIO_new_mem_buf(privkey, -1);
    mykey = PEM_read_bio_PrivateKey(localbio, NULL, 0, (void *)passphrase);
    BIO_free(localbio);
    if (mykey!=NULL) {*RSAret = 1;}

}


/* PBKDF2 from OpenSSL */
void hash_proto_pbkdf2(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)
{
    (void)PKCS5_PBKDF2_HMAC_SHA1(pass, strlen(pass), salt, saltlen, iter, keylen, out);
}


/* PBKDF2/lenprovided from OpenSSL */
void hash_proto_pbkdf2_len(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)
{
    (void)PKCS5_PBKDF2_HMAC_SHA1(pass, passlen, salt, saltlen, iter, keylen, out);
}



/* PBKDF2 with HMAC_SHA512 */
void hash_proto_pbkdf512(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)
{
    unsigned char digtmp[SHA512_DIGEST_LENGTH], *p, itmp[4];
    int cplen, j, k, tkeylen;
    unsigned long i = 1;
    HMAC_CTX hctx;
    int passlen = strlen(pass);

    HMAC_CTX_init(&hctx);
    p = out;
    tkeylen = keylen;
    if(!pass) passlen = 0;
    else if(passlen == -1) passlen = strlen(pass);
    while(tkeylen) 
    {
        if(tkeylen > SHA512_DIGEST_LENGTH) cplen = SHA512_DIGEST_LENGTH;
        else cplen = tkeylen;
        itmp[0] = (unsigned char)((i >> 24) & 0xff);
        itmp[1] = (unsigned char)((i >> 16) & 0xff);
        itmp[2] = (unsigned char)((i >> 8) & 0xff);
        itmp[3] = (unsigned char)(i & 0xff);
        HMAC_Init_ex(&hctx, pass, passlen, EVP_sha512(), NULL);
        HMAC_Update(&hctx, salt, saltlen);
        HMAC_Update(&hctx, itmp, 4);
        HMAC_Final(&hctx, digtmp, NULL);
        memcpy(p, digtmp, cplen);
        for(j = 1; j < iter; j++) 
        {
    	    HMAC(EVP_sha512(), pass, passlen, digtmp, SHA_DIGEST_LENGTH, digtmp, NULL);
    	    for(k = 0; k < cplen; k++) p[k] ^= digtmp[k];
	}
	tkeylen-= cplen;
	i++;
	p+= cplen;
    }
    HMAC_CTX_cleanup(&hctx);
}



/* HMAC_SHA1 from OpenSSL  */
void hash_proto_hmac_sha1(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen)
{
    HMAC_CTX ctx;

    HMAC_CTX_init(&ctx);
    HMAC_Init_ex(&ctx, key, keylen, EVP_sha1(),NULL);
    HMAC_Update(&ctx, data, datalen);
    HMAC_Final(&ctx, output, (unsigned int *)&outputlen);
    HMAC_CTX_cleanup(&ctx);
}


/* HMAC_MD5 from OpenSSL  */
void hash_proto_hmac_md5(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen)
{
    HMAC_CTX ctx;

    HMAC_CTX_init(&ctx);
    HMAC_Init_ex(&ctx, key, keylen, EVP_md5(),NULL);
    HMAC_Update(&ctx, data, datalen);
    HMAC_Final(&ctx, output, (unsigned int *)&outputlen);
    HMAC_CTX_cleanup(&ctx);
}




/* HMAC_SHA1 from OpenSSL on files*/
void hash_proto_hmac_sha1_file(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen)
{
    int fd;
    unsigned char buf[4096];
    long localoff;
    int bufread;
    HMAC_CTX ctx;
    
    HMAC_CTX_init(&ctx);
    HMAC_Init(&ctx, key, keylen, EVP_sha1());
    fd = open(filename, O_RDONLY);
    if (fd<1)
    {
	memcpy(output,key,outputlen);
	return;
    }
    if (lseek(fd, offset, SEEK_SET) == -1)
    {
	memcpy(output,key,outputlen);
	return;
    }
    localoff = offset;

    while (localoff < (offset+size))
    {
	if ((localoff+4096) > (offset+size)) 
	{
	    bufread = (offset+size) - localoff;
	    localoff = offset + size;
	}
	else
	{
	    bufread = 4096;
	    localoff += 4096;
	}
	read(fd, buf, bufread);
	HMAC_Update(&ctx, buf, bufread);
    }

    HMAC_Final(&ctx, output, (unsigned int *)&outputlen);
    close(fd);
    HMAC_CTX_cleanup(&ctx);
}





/* AES encrypt openssl wrapper */
/* mode: use 0 for ECB and 1 for CBC */
void hash_proto_aes_encrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode)
{
    AES_KEY akey;
    AES_set_encrypt_key(key, keysize*8, &akey);
    switch (mode)
    {
	case 0:
	    AES_ecb_encrypt(in, out, &akey, AES_ENCRYPT);
	    break;
	case 1:
	    AES_cbc_encrypt(in, out, len, &akey, vec, AES_ENCRYPT);
	    break;
	default: return;
    }
}

/* AES decrypt openssl wrapper */
/* mode: use 0 for ECB and 1 for CBC */
void hash_proto_aes_decrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode)
{
    AES_KEY akey;
    AES_set_decrypt_key(key, keysize*8, &akey);
    switch (mode)
    {
	case 0:
	    AES_ecb_encrypt(in, out, &akey, AES_DECRYPT);
	    break;
	case 1:
	    AES_cbc_encrypt(in, out, len, &akey, vec, AES_DECRYPT);
	    break;
	default: return;
    }
}


/* DES encrypt openssl wrapper */
/* mode: use 0 for no padding and 1 for padding */
void hash_proto_des_ecb_encrypt(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode)
{

#ifndef HAVE_SSE2
    int a;
    EVP_CIPHER_CTX ctx;
    int outl;
    for (a=0;a<vectorsize;a++)
    {
	EVP_CIPHER_CTX_init(&ctx); 
	EVP_EncryptInit_ex(&ctx, EVP_des_ecb(), NULL, key, NULL); 
	EVP_CIPHER_CTX_set_padding(&ctx, mode); 
	EVP_EncryptUpdate(&ctx, out[a], &outl, in[a], len);
	EVP_EncryptFinal_ex(&ctx, out[a], &outl);
	EVP_CIPHER_CTX_cleanup(&ctx); 
    }
#else
    ODES_ONEBLOCK((char *)key, (char **)in, (char **)out);
#endif
}


/* DES decrypt openssl wrapper */
/* mode: use 0 for ECB and 1 for CBC */
void hash_proto_des_ecb_decrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode)
{
    EVP_CIPHER_CTX ctx;
    int outl;

    EVP_CIPHER_CTX_init(&ctx); 
    EVP_DecryptInit_ex(&ctx, EVP_des_ecb(), NULL, key, NULL); 
    EVP_CIPHER_CTX_set_padding(&ctx, mode); 
    EVP_DecryptUpdate(&ctx, out, &outl, in, len);
    EVP_DecryptFinal_ex(&ctx, out, &outl);
    EVP_CIPHER_CTX_cleanup(&ctx); 
}


/* DES encrypt (CBC) openssl wrapper */
/* mode: use 0 for ECB and 1 for CBC */
void hash_proto_des_cbc_encrypt(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode)
{
    DES_key_schedule desschedule;
    int a;

    for (a=0;a<vectorsize;a++)
    {
	DES_set_key((unsigned char (*)[8])key[a], &desschedule);
        DES_ncbc_encrypt(in[a], out[a], len[a], &desschedule, (unsigned char (*)[8])iv[a], DES_ENCRYPT);
    }

    //DES_CBC(key,in,out,iv,len);
}

// TODO: handle openssl case
void hash_proto_lm(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE])
{
#ifndef HAVE_SSE2
    int a;
    char half1[8], half2[8];
    unsigned char secret[8]="KGS!@#$%"; 
    for (a=0;a<vectorsize;a++)
    {
	memcpy(half1,in[a],8);
	memcpy(half2,in[a]+8,8);
	hash_proto_des_ecb_encrypt(half1, 8, secret, 8, (unsigned char *)out[a], 0);
	hash_proto_des_ecb_encrypt(half2, 8, secret, 8, (unsigned char *)out[a]+8, 0); 
    }
#else
    ODES_LM((char **)in, (char **)out);
#endif
}


void hash_proto_aes_cbc_encrypt(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper)
{
    OAES_CBC_ENCRYPT(in, out, length, key, ivec, oper);
}

int hash_proto_aes_set_encrypt_key(const unsigned char *userKey,const int bits,AES_KEY *key)
{
    return OAES_SET_ENCRYPT_KEY(userKey,bits,key);
}
int hash_proto_aes_set_decrypt_key(const unsigned char *userKey, const int bits, AES_KEY *key)
{
    return OAES_SET_DECRYPT_KEY(userKey,bits,key);
}


/* Add username to list temp */
void hash_proto_add_username(const char *username)
{
    if (username) strcpy((char *)&temp_username, username);
    else temp_username[0]=0;
}


/* Add hash to list temp */
void hash_proto_add_hash(const char *hash, int len)
{
    if (hash)
    {
	if (len==0)  {memcpy((char *)&temp_hash, hash, strlen(hash));hash_is_raw = 0;}
	if (len !=0) {memcpy((char *)&temp_hash, hash, len);hash_is_raw = 1;}
	if (len!=0) hash_ret_len = len;
	else hash_ret_len = strlen(hash);
	if (strcmp(get_current_plugin(),"pixmd5")==0) hash_ret_len=16;
    }
    else temp_hash[0]=0;
}


/* Add salt to list temp */
void hash_proto_add_salt(const char *salt)
{
    bzero(temp_salt,64);
    if (salt) memcpy((char *)&temp_salt, salt, strlen(salt));
    else temp_salt[0]=0;
}


/* Add salt2 to list temp */
void hash_proto_add_salt2(const char *salt2)
{
    if (salt2) memcpy((char *)&temp_salt2, salt2, strlen(salt2));
    else temp_salt2[0]=0;
}




/* Add to hash list */
hash_stat add_hash_list(char *username, char *hash, char *salt, char *salt2)
{
    struct hash_list_s *temp_list, *temp_list1;
    
    temp_list = hash_list;
    if (temp_list) 
    {
	temp_list1 = hash_list_end;
	temp_list = malloc(sizeof(struct hash_list_s));
	temp_list->next = NULL;
	temp_list->prev = temp_list1;
	temp_list1->next =  temp_list;
	single_hash = 0;
	hash_list_end = temp_list;
    }
    /* First entry? */
    else 
    {
	temp_list = malloc(sizeof(struct hash_list_s));
	hash_list = temp_list;
	hash_list->next = NULL;
	hash_list->prev = NULL;
	single_hash = 1;
	hash_list_end = hash_list;
    }
    
    if (!temp_list)
    {
	elog("Not enough memory for new hash_list entry! %s\n","");
	return hash_err;
    }
    
    if (username)
    {
	temp_list->username = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	bzero(temp_list->username,HASHFILE_MAX_PLAIN_LENGTH*2);
	strcpy(temp_list->username, username);
	//temp_list->username = malloc(strlen(username)+1);
	//strcpy(temp_list->username, username);
    }
    if (hash)
    {
	temp_list->hash = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	memcpy(temp_list->hash, hash, hash_ret_len);
	temp_list->hash[hash_ret_len]=0;
	//temp_list->hash = malloc(hash_ret_len+1);
	//memcpy(temp_list->hash, hash, hash_ret_len);
	//temp_list->hash[hash_ret_len]=0;
    }
    if (salt)
    {
	temp_list->salt = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	//temp_list->salt = malloc(strlen(salt)+1);
	strcpy(temp_list->salt, salt);
    }
    if (salt2)
    {
	//temp_list->salt2 = malloc(HASHFILE_MAX_PLAIN_LENGTH);
	posix_memalign((void **)&temp_list->salt2,32, HASHFILE_MAX_PLAIN_LENGTH);
	//posix_memalign((void **)&temp_list->salt2,16, hash_ret_len*2);
	strcpy(temp_list->salt2, salt2);
    }




    return hash_ok;
}



/* Add to cracked list */
hash_stat add_cracked_list(char *username, char *hash, char *salt, char *salt2)
{
    struct hash_list_s *temp_list, *temp_list1;

    pthread_mutex_lock(&crackedmutex);

    temp_list = cracked_list;
    if (temp_list) 
    {
	temp_list1 = cracked_list_end;
	while (temp_list1->next) temp_list1 = temp_list1->next;
	temp_list = malloc(sizeof(struct hash_list_s));
	temp_list->next = NULL;
	temp_list->prev = temp_list1;
	temp_list1->next =  temp_list;
	cracked_list_end = temp_list;
    }
    /* First entry? */
    else 
    {
	temp_list = malloc(sizeof(struct hash_list_s));
	cracked_list = temp_list;
	cracked_list->next = NULL;
	cracked_list->prev = NULL;
	cracked_list_end = temp_list;
    }
    
    if (!temp_list)
    {
	elog("Not enough memory for new crack_list entry! %s\n","");
	pthread_mutex_unlock(&crackedmutex);
	return hash_err;
    }
    
    if (username)
    {
	temp_list->username = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	//temp_list->username = malloc(strlen(username)+1);
	strcpy(temp_list->username, username);
    }
    if (hash)
    {
	temp_list->hash = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	//temp_list->hash = malloc(hash_ret_len+1);
	memcpy(temp_list->hash, hash, hash_ret_len);
	temp_list->hash[hash_ret_len]=0;
    }
    if (salt)
    {
	temp_list->salt = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	//temp_list->salt = malloc(strlen(salt)+1);
	strcpy(temp_list->salt, salt);
    }
    if (salt2)
    {
	temp_list->salt2 = malloc(HASHFILE_MAX_PLAIN_LENGTH*2);
	//temp_list->salt2 = malloc(hash_ret_len*2);
	strcpy(temp_list->salt2, salt2);
    }
    pthread_mutex_unlock(&crackedmutex);

    return hash_ok;
}


/* Delete hash list node */
hash_stat del_hash_list(struct hash_list_s *node)
{
    struct hash_list_s *temp_list;
    int first=0;

    if (!node) return hash_err;
    pthread_mutex_lock(&listmutex);
    if ((node->prev == NULL) && (node->next == NULL)) first = 1;
    temp_list = node->next;
    if (temp_list) temp_list->prev = node->prev;
    temp_list = node->prev;
    if (temp_list) temp_list->next = node->next;
    if (node->username) free(node->username);
    if (node->hash) free(node->hash);
    if (node->salt) free(node->salt);
    if (node->salt2) free(node->salt2);
    node->username = node->hash = node-> salt = node->salt2 = NULL;
    node = NULL;
    if (first == 1) hash_list = NULL;
    pthread_mutex_unlock(&listmutex);
    return hash_ok;
}


/* Delete cracked list node */
hash_stat del_cracked_list(struct hash_list_s *node)
{
    struct hash_list_s *temp_list;

    if (!node) return hash_err;
    pthread_mutex_lock(&crackedmutex);
    temp_list = node->next;
    if (temp_list) temp_list->prev = node->prev;
    temp_list = node->prev;
    if (temp_list) temp_list->next = node->next;
    free(node->username);
    free(node->hash);
    free(node->salt);
    free(node->salt2);
    free(node);
    if (node==cracked_list) 
    {
	node = temp_list;
    }
    else node = NULL;
    pthread_mutex_unlock(&crackedmutex);
    return hash_ok;
}


static void str2hex(char *str, char *hex, int size)
{
    int cnt;
    char charset[16]="0123456789abcdef";

    for (cnt=0;cnt<size;cnt++)
    {

	*(hex+(2*cnt)+1) = charset[(unsigned char)*(str+cnt)&15];
	*(hex+(2*cnt)) = charset[(unsigned char)*(str+cnt)>>4];
    }
    *(hex+(2*size)) = 0;
    *(hex+(2*size)+1) = 0;

}


/* Print the hashes linked list */
void print_hash_list(void)
{
    struct hash_list_s *temp_list = hash_list;
    char hashhex[HASHFILE_MAX_LINE_LENGTH];
    
//    int hash_is_raw = hash_plugin_is_raw();

    printf("...Hash list...\n\n");
    if (!temp_list) printf("empty\n");
    while (temp_list) 
    {
	if (temp_list->username) printf("Username: %s ", temp_list->username);

	if (hash_is_raw==1)
	{
	    if (temp_list->hash) 
	    {
		str2hex(temp_list->hash, hashhex, hash_ret_len);
		printf(" Hash: %s ", hashhex);
	    }
	}
	else if (temp_list->hash) printf(" Hash: %s ", temp_list->hash);
	    
	if (temp_list->salt) printf(" Salt: %s ", temp_list->salt);
	if (temp_list->salt2) printf(" Salt2: %s ", temp_list->salt2);
	printf("\n");
	temp_list=temp_list->next;
    }
}



/* Print cracked hashes linked list */
void print_cracked_list(void)
{
    struct hash_list_s *temp_list;
    char outpline[HASHFILE_MAX_LINE_LENGTH];
    char hashhex[HASHFILE_MAX_LINE_LENGTH];
    int cracked = 0;

    printf("\n");
    hlog("-= Cracked list =-\n%s\n","");
    printf("Username: \t\tHash: \t\t\t\t\tPreimage:\n");
    printf("-----------------------------------------------------------------------------------\n");
    
    pthread_mutex_lock(&crackedmutex);
    temp_list = cracked_list;
    while (temp_list)
    {

	if (temp_list->salt2) temp_list->salt2[HASHFILE_MAX_PLAIN_LENGTH]=0;
	if (temp_list->salt) temp_list->salt[HASHFILE_MAX_PLAIN_LENGTH]=0;
	if (temp_list->hash) temp_list->hash[HASHFILE_MAX_PLAIN_LENGTH]=0;
	if (temp_list->username) temp_list->username[HASHFILE_MAX_PLAIN_LENGTH]=0;
	
	while (strlen(temp_list->username)<20) strcat(temp_list->username," ");
	if ((strcmp(get_current_plugin(),"md5unix")!=0)&&(strcmp(get_current_plugin(),"apr1")!=0)&&(strcmp(get_current_plugin(),"sha512unix")!=0))
	while (strlen(temp_list->salt)<20) strcat(temp_list->salt," ");
	
	if (temp_list->username) snprintf(outpline,14,"%s                 ", temp_list->username);
	printf("%s \t",outpline);
	
	if ((strcmp(get_current_plugin(),"md5unix")==0)||(strcmp(get_current_plugin(),"apr1")==0)||(strcmp(get_current_plugin(),"sha512unix")==0))
	{
		temp_list->salt[strlen(temp_list->salt)-1]=0;
		snprintf(outpline,41,"%s%s                            ", temp_list->salt,temp_list->hash);
	}

	else if (hash_is_raw == 1)
	{
	    if (temp_list->hash) 
	    {
		str2hex(temp_list->hash, (char *)&hashhex, hash_ret_len);
		snprintf(outpline, 41, "%s                        ", hashhex);
	    }
	}
	else if (temp_list->hash) snprintf(outpline,41,"%s                            ", temp_list->hash);

	printf("%s \t",outpline);
	if (temp_list->salt2) snprintf(outpline,30,"%s             ", temp_list->salt2);
	printf("%s\n",outpline);
	temp_list = temp_list->next;
	cracked++;
    }
    temp_list = NULL;
    pthread_mutex_unlock(&crackedmutex);
    printf("\n");
    hlog("Total: %d hashes cracked\n",cracked);
}


static unsigned char *bitmap;
static unsigned char *bitmap2;
static unsigned char *bitmap3;



/* Print cracked hashes linked list */
void print_cracked_list_to_file(char *filename)
{
    FILE *hashfile, *outfile;
    char buf[HASHFILE_MAX_LINE_LENGTH];
    unsigned int lines = 0;
    unsigned int successful_lines = 0;
    struct hash_list_s *temp_list, *mylist;
    char hex1[16];
    int a;
    
    bitmap=malloc(256*256*32);
    bitmap2=malloc(256*256*32);
    bitmap3=malloc(256*256*32);
    for (a=0;a<256*256*32;a++) 
    {
            bitmap[a]=0;
            bitmap2[a]=0;
            bitmap3[a]=0;
    }

    mylist = cracked_list;
    while (mylist) 
    {
        memcpy(hex1,mylist->hash,16);
        bitmap[(((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))>>3] |= (1 << ((((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))&7) );
        bitmap2[(((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))>>3] |= (1 << ((((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))&7) );
        bitmap3[(((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))>>3] |= (1 << ((((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))&7) );

        if (mylist) mylist = mylist->next;
    }


    temp_username[0]=0;
    temp_hash[0]=0;
    temp_salt[0]=0;
    temp_salt2[0]=0;

    hlog("Filtering out cracked hashes, please wait...\n%s","");
    if (!hash_plugin_parse_hash)
    {
        elog("%s failed: please call load_plugin() first!\n","load_hashes_file");
        return;
    }
    
    if (hash_plugin_is_special())
    {
	hlog("Writing cracked password to output file%s\n",filename);
	outfile = fopen(filename, "w");
	if (!outfile)
	{
	    hlog("Cannot write output hashes list file: %s\n",filename);
	    return;
	}
	if (cracked_list) fputs(cracked_list->salt2,outfile);
	free(bitmap);
	free(bitmap2);
	free(bitmap3);
	fclose(outfile);
	return;
    }

    /* This is insecure and should be fixed */
    outfile = fopen(filename, "w");
    if (!outfile)
    {
	hlog("Cannot write output hashes list file: %s\n",filename);
	return;
    }
    
    hashfile = fopen(hashlist_file, "r");

    if (hashfile == NULL)
    {
        hlog("Cannot open hashlist file: %s, not writing uncracked hashes list output file\n", filename);
        return;
    }
    else
    {
        char separator[2];
        char newline[2];
        lines=0;
        while (!feof(hashfile))
        {
            if (fgets((char *)&buf, HASHFILE_MAX_LINE_LENGTH, hashfile) != NULL)
            {
                if ((strlen(buf) > 0) && (buf[strlen(buf)-1] == '\n')) buf[strlen(buf)-1] = 0;
                if (buf[strlen(buf)-1] == '\r') buf[strlen(buf)-1] = 0;
                lines++;
                if ((lines % 5000)==0) 
                {
            	    printf(".");
            	    fflush(stdout);
            	}
                if (hash_plugin_parse_hash(buf, NULL) == hash_ok)
                {
		    temp_list = cracked_list;
		    if (((bitmap[((((temp_hash[0]&255)<<16)|((temp_hash[1]&255)<<8)|((temp_hash[2]&255))) >> 3)] >> ((((temp_hash[0]&255)<<16)|((temp_hash[1]&255)<<8)|((temp_hash[2]&255)))&7)&1)==1) &&
		        ((bitmap2[((((temp_hash[3]&255)<<16)|((temp_hash[4]&255)<<8)|((temp_hash[5]&255))) >> 3)] >> ((((temp_hash[3]&255)<<16)|((temp_hash[4]&255)<<8)|((temp_hash[5]&255)))&7)&1)==1) &&
		        ((bitmap3[((((temp_hash[6]&255)<<16)|((temp_hash[7]&255)<<8)|((temp_hash[8]&255))) >> 3)] >> ((((temp_hash[6]&255)<<16)|((temp_hash[7]&255)<<8)|((temp_hash[8]&255)))&7)&1)==1)
		    )
		    while (temp_list)
		    {
			if (memcmp(temp_hash, temp_list->hash, hash_ret_len)==0) 
			{
			    fputs(buf,outfile);
			    separator[0]=' ';
			    separator[1]=0;
			    fputs(separator,outfile);
			    fputs(temp_list->salt2,outfile);
			    newline[0]='\n';
			    newline[1]=0;
			    fputs(newline,outfile);
			    successful_lines++;
			}
			temp_list = temp_list->next;
		    }
                }
            }
        }
    }
    free(bitmap);
    free(bitmap2);
    free(bitmap3);
    printf("\n");
    hlog("(%s): %u cracked hashes out of %u hashes overall\n",filename, successful_lines, lines);
    fclose(hashfile);
    fclose(outfile);

}



/* Print uncracked hashes linked list */
void print_uncracked_list_to_file(char *filename)
{
    FILE *hashfile, *outfile;
    char buf[HASHFILE_MAX_LINE_LENGTH];
    unsigned int lines = 0;
    unsigned int successful_lines = 0;
    struct hash_list_s *temp_list,*mylist;
    int found;
    char hex1[16];
    int a;
    
    bitmap=malloc(256*256*32);
    bitmap2=malloc(256*256*32);
    bitmap3=malloc(256*256*32);
    for (a=0;a<256*256*32;a++) 
    {
            bitmap[a]=0;
            bitmap2[a]=0;
            bitmap3[a]=0;
    }

    mylist = cracked_list;
    while (mylist) 
    {
        memcpy(hex1,mylist->hash,16);
        bitmap[(((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))>>3] |= (1 << ((((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))&7) );
        bitmap2[(((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))>>3] |= (1 << ((((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))&7) );
        bitmap3[(((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))>>3] |= (1 << ((((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))&7) );

        if (mylist) mylist = mylist->next;
    }

    temp_username[0]=0;
    temp_hash[0]=0;
    temp_salt[0]=0;
    temp_salt2[0]=0;
    
    hlog("Filtering out uncracked hashes, please wait...\n%s","");

    if (!hash_plugin_parse_hash)
    {
        elog("%s failed: please call load_plugin() first!\n","load_hashes_file");
        return;
    }
    
    if (hash_plugin_is_special())
    {
	hlog("Not writing uncracked hashes output file\n%s","");
	return;
    }

    /* This is insecure and should be fixed */
    outfile = fopen(filename, "w");
    if (!outfile)
    {
	hlog("Cannot write output hashes list file: %s\n",filename);
	return;
    }
    
    hashfile = fopen(hashlist_file, "r");

    if (hashfile == NULL)
    {
        hlog("Cannot open hashlist file: %s, not writing uncracked hashes list output file\n", filename);
        return;
    }
    else
    {
        while (!feof(hashfile))
        {
            if (fgets((char *)&buf, HASHFILE_MAX_LINE_LENGTH, hashfile) != NULL)
            {
                if ((strlen(buf) > 0) && (buf[strlen(buf)-1] == '\n')) buf[strlen(buf)-1] = 0;
                if (buf[strlen(buf)-1] == '\r') buf[strlen(buf)-1] = 0;
                lines++;
                if ((lines % 5000)==0) 
                {
            	    printf(".");
            	    fflush(stdout);
            	}
                if (hash_plugin_parse_hash(buf, NULL) == hash_ok)
                {
		    temp_list = cracked_list;
		    found = 0;
		    if (((bitmap[((((temp_hash[0]&255)<<16)|((temp_hash[1]&255)<<8)|((temp_hash[2]&255))) >> 3)] >> ((((temp_hash[0]&255)<<16)|((temp_hash[1]&255)<<8)|((temp_hash[2]&255)))&7)&1)==1) &&
		        ((bitmap2[((((temp_hash[3]&255)<<16)|((temp_hash[4]&255)<<8)|((temp_hash[5]&255))) >> 3)] >> ((((temp_hash[3]&255)<<16)|((temp_hash[4]&255)<<8)|((temp_hash[5]&255)))&7)&1)==1) &&
		        ((bitmap3[((((temp_hash[6]&255)<<16)|((temp_hash[7]&255)<<8)|((temp_hash[8]&255))) >> 3)] >> ((((temp_hash[6]&255)<<16)|((temp_hash[7]&255)<<8)|((temp_hash[8]&255)))&7)&1)==1)
		    ) found=1;
		    else while (temp_list)
		    {
			if (memcmp(temp_hash, temp_list->hash, hash_ret_len)==0) 
			{
			    found=1;
			    break;
			}
			else temp_list = temp_list->next;
		    }
		    if (found==0) 
		    {
			fputs(buf,outfile);
			char newline[2]="\n";
			fputs(newline,outfile);
			successful_lines++;
		    }
                }
            }
        }
    }
    
    free(bitmap);
    free(bitmap2);
    free(bitmap3);
    printf("\n");
    fclose(hashfile);
    fclose(outfile);
    hlog("(%s): %u uncracked hashes out of %u hashes overall\n",filename, successful_lines, lines);
}





/* Get number of cracked hashes */
int get_cracked_num(void)
{
    struct hash_list_s *temp_list = cracked_list;
    int num = 0;
    
    pthread_mutex_lock(&crackedmutex);
    while (temp_list)
    {
	num++;
	temp_list = temp_list->next;
    }
    pthread_mutex_unlock(&crackedmutex);
    return num;
}


/* Get number of hashes in list */
int get_hashes_num(void)
{
    struct hash_list_s *temp_list = hash_list;
    int num = 0;
    
    while (temp_list)
    {
	num++;
	temp_list = temp_list->next;
    }
    
    return num;
}


/* Free memory used by lists */
void cleanup_lists(void)
{
    struct hash_list_s *temp_list, *temp_list1;


    temp_list = hash_list_end;
    while (temp_list)
    {
	temp_list1 = temp_list->prev;
	if (temp_list->prev) del_hash_list(temp_list->next);
	temp_list = temp_list1;
    }

    temp_list = cracked_list_end;
    while (temp_list)
    {
	temp_list1 = temp_list->prev;
	if (temp_list->prev) del_cracked_list(temp_list->next);
	temp_list = temp_list1;
    }

}


/* Initialize Markov attack data */
void markov_attack_init(void)
{
    int a,b;

    for (a=0;a<88;a++) markov0[a]=0;
    for (a=0;a<88;a++) for (b=0;b<88;b++) markov1[a][b]=0;
    markov_threshold = 0;
    markov_max_len = 10;
    bzero(markov_statfile,255);
    markov_charset = malloc(88);
    strcpy(markov_statfile,"rockyou");
    strcpy(markov_charset,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!{}@#$%^&*()-+[]|\\;':,./");
}

/* Print out Markov statfiles summary */
void markov_print_statfiles(void)
{
    DIR *dir;
    FILE *statfile;
    struct dirent *dentry;
    char statname[1024];
    char readline[256];
    char readline2[256];
    int avg;

    dir=opendir(DATADIR"/hashkill/markov");
    if (!dir)
    {
        elog("Cannot open markov stats dir: %s", DATADIR"/hashkill/markov");
        return;
    }
    hlog("Markov attack statfiles list: %s\n\n","");
    printf("Statfile: \t\tDef.threshold\tShort description:\n"
	    "--------------------------------------------------------------------------------\n");
    do
    {
        errno = 0;
        if ((dentry = readdir(dir)) != NULL)
        {
            if ((dentry->d_type == DT_REG) && (strstr(dentry->d_name, ".stat")))
            {
                snprintf(statname,1024,DATADIR"/hashkill/markov/%s", dentry->d_name);
                /* Parse the first two lines from statfile */
                statfile = fopen(statname, "r");
                if (!statfile)
                {
                    goto next;
                }
                if (!fgets(readline, 256, statfile))
                {
                    elog("Cannot read from statfile : %s\n",statname);
                    goto next;
                }
                readline[strlen(readline)-1] = 0;
                if (!fgets(readline2, 256, statfile))
                {
                    elog("Cannot read from statfile : %s\n",statname);
                    goto next;
                }
                avg = atoi(readline2);
                snprintf(readline2, 20, "%s               ", strtok(dentry->d_name,"."));
                
                printf("\033[1;33m%s\033[1;0m\t%d\t\t%s\n", readline2, avg, readline);

            next:
            if (statfile) fclose(statfile);
            }
        }
    } while (dentry != NULL);
    closedir(dir);
    printf("\n");
}

/* Load Markov statfile */
hash_stat markov_load_statfile(char *statname)
{
    FILE *fd;
    char buf[HASHFILE_MAX_LINE_LENGTH];
    int cnt1,cnt2;
    char c1,c2;
    
    strcpy(markov_statfile, statname);
    sprintf(buf,DATADIR"/hashkill/markov/%s.stat",statname);
    fd = fopen(buf,"r");
    if (!fd)
    {
	elog("Cannot open Markov statfile: %s\n",buf);
	return hash_err;
    }
    fgets(buf, HASHFILE_MAX_LINE_LENGTH, fd);
    buf[strlen(buf)-1] = 0;
    hlog("Loading markov statfile (%s)\n", statname);
    fgets(buf, HASHFILE_MAX_LINE_LENGTH, fd);
    if (markov_threshold==0) markov_threshold = atoi(buf);
    /* TODO: LOAD TABLES! */
    for (cnt1=0;cnt1<88;cnt1++) fscanf(fd, "%c %d\n", &c1, &markov0[cnt1]);
    for (cnt1=0;cnt1<88;cnt1++) 
	for (cnt2=0;cnt2<88;cnt2++) 
	{
	    fscanf(fd, "%c %c %d\n", &c1, &c2, &markov1[cnt1][cnt2]);
	}

    fclose(fd);
    return hash_ok;
}



hash_stat create_hash_indexes(void)
{
    struct hash_list_s *mylist;
    int a,b,c;
    
    for (a=0;a<256;a++)
    for (b=0;b<256;b++)
    for (c=0;c<MAXINDEX;c++)
    {
        hash_index[a][b].nodes[c] = NULL;
        hash_index[a][b].count = 0;
    }

    mylist = hash_list;
    while (mylist)
    {
        hash_index[mylist->hash[0]&255][mylist->hash[1]&255].count++;
        int num = hash_index[mylist->hash[0]&255][mylist->hash[1]&255].count-1;
        if (num<200)
        {
            hash_index[mylist->hash[0]&255][mylist->hash[1]&255].nodes[num] = mylist;
        }
        if (mylist) mylist = mylist->next;
    }

    return hash_ok;
}



/* Scheduler - reset bitmap */
static void scheduler_reset_bitmap()
{
    int a,b;

    for (a=0;a<128;a++)
    for (b=0;b<128;b++)
	scheduler.bitmap3[a][b]=0;
    for (a=0;a<128;a++)
	scheduler.bitmap2[a]=0;
    scheduler.bitmap1=0;

}



/* Scheduler - check bitmap coverage - case 1) */
static int scheduler_check2()
{
    if (scheduler.bitmap2[scheduler.charset_size-1]>=scheduler.charset_size) return 1;
    return 0;
}

/* Scheduler - check bitmap coverage - case 2) */
static int scheduler_check3()
{
    int a;

    if (attack_method==attack_method_simple_bruteforce)
    {
	if (scheduler.bitmap3[scheduler.charset_size-1][scheduler.charset_size2-1]>=scheduler.charset_size2) return 1;
    }
    else if (attack_method==attack_method_markov)
    {
	for (a=0;a<128;a++) if (scheduler.bitmap3[scheduler.charset_size-1][a] >= scheduler.charset_size2) return 1;
    }
    return 0;
}



static void *scheduler_thread_worker(void *arg)
{
    int check;

    /* Wait until scheduler state changed */
    while ((attack_over==0)&&(scheduler.len==0)) usleep(100);
    while ((attack_over==0)&&(scheduler.len<scheduler.startlen)) usleep(100);
    while ((scheduler.len<=scheduler.maxlen)&&(attack_over==0))
    {
	check=0;
	if (scheduler.len==scheduler.startlen) check = scheduler_check2();
	if (scheduler.len>scheduler.startlen) check = scheduler_check3();
	if (check==1) 
	{
	    scheduler_reset_bitmap();
	    scheduler.len+=1;
	}
	/* Sleep */
	usleep(10000);
    }
    sleep(1);
    attack_over=2;
    return NULL;
}


/* Initialize scheduler */
void scheduler_init()
{
    int a,b;
    
    /* Initialize scheduler data */
    scheduler.len=0;
    scheduler.charset_size=0;
    scheduler.startlen=0;
    scheduler.maxlen=0;
    for (a=0;a<128;a++) 
    for (b=0;b<128;b++)
    {
	scheduler.bitmap3[a][b]=0;
	scheduler.ebitmap3[a][b]=0;
    }
    for (a=0;a<128;a++) 
    {
	scheduler.bitmap2[a]=0;
	scheduler.ebitmap2[a]=0;
    }
    scheduler.bitmap1=0;
    scheduler.ebitmap1=0;

    pthread_create(&scheduler_thread, NULL, scheduler_thread_worker, NULL);
    hlog("Scheduler initialized.%s\n","");
}


/* Setup scheduler */
void scheduler_setup(int curlen, int startlen, int maxlen, int charset_size, int charset_size2)
{
    int a,b;

    for (a=0;a<=charset_size;a++)
    for (b=0;b<=charset_size;b++)
    {
	scheduler.bitmap3[a][b]=0;
	scheduler.ebitmap3[a][b]=charset_size2;
    }
    for (a=0;a<128;a++)
    {
	scheduler.bitmap2[a]=0;
	scheduler.ebitmap2[a]=charset_size;
    }
    scheduler.bitmap1=0;
    scheduler.ebitmap1=charset_size2;

    scheduler.len=curlen;
    scheduler.startlen=startlen;
    scheduler.maxlen=maxlen;
    scheduler.charset_size=charset_size;
    scheduler.charset_size2=charset_size2;
}


/* Get sched s2 */
int sched_s2(int s1)
{
    int a = scheduler.bitmap2[(s1)];

    scheduler.bitmap2[(s1)]++;
    return a;
}

/* Get sched s3 */
int sched_s3(int s1, int s2)
{
    int a = scheduler.bitmap3[(s1)][s2];

    scheduler.bitmap3[(s1)][s2]++;
    return a;
}


/* Get sched e2 */
int sched_e2(int e1)
{
    return scheduler.ebitmap2[e1];
}

/* Get sched s2 */
int sched_e3(int e1, int e2)
{
    return scheduler.ebitmap3[e1][e2];
}

/* Get sched curlen */
int sched_len()
{
    return scheduler.len;
}

/* Get sched curlen */
void sched_wait(int len)
{
    while ((attack_over==0)&&(scheduler.len<len)) usleep(10000);
}
