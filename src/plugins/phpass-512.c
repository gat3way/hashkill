/* 
   phpass-512.c 
   
   Edited by Milen Rangelov <gat3way@gat3way.eu> to optimize for hash cracking.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */




#define _GNU_SOURCE
#define _XOPEN_SOURCE 600

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <stdint.h>
#include "plugin.h"



static char *itoa64 =
	"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

static void encode64(char *dst, char *src, int count)
{
	int i, value;

	i = 0;
	do {
		value = (unsigned char)src[i++];
		*dst++ = itoa64[value & 0x3f];
		if (i < count)
			value |= (unsigned char)src[i] << 8;
		*dst++ = itoa64[(value >> 6) & 0x3f];
		if (i++ >= count)
			break;
		if (i < count)
			value |= (unsigned char)src[i] << 16;
		*dst++ = itoa64[(value >> 12) & 0x3f];
		if (i++ >= count)
			break;
		*dst++ = itoa64[(value >> 18) & 0x3f];
	} while (i < count);
}

char *pacrypt_private_dictionary(char *password[VECTORSIZE], char *setting, char *out[VECTORSIZE], int vectorsize)
{
	char *output[VECTORSIZE];
	char *hash[VECTORSIZE];
	char *p, *salt;
	int count_log2, length[VECTORSIZE], count;
	char *bigbuf[VECTORSIZE];
	int bbl[VECTORSIZE];
	int a;
	
	
	for (a=0;a<vectorsize;a++)
	{
	    output[a] = alloca(128);
	    hash[a] = alloca(64);
	    bigbuf[a] = alloca(128);
	    length[a] = strlen(password[a]);
	}

	for (a=0;a<vectorsize;a++)
	{
	    strcpy(output[a], "*0");
	    if (!strncmp(setting, output[a], 2))
		output[a][1] = '1';
	}
	
	if (strncmp(setting, "$S$", 3))
		return "";

	p = strchr(itoa64, setting[3]);
	if (!p)
		return "";
	count_log2 = p - itoa64;
	if (count_log2 < 7 || count_log2 > 30)
		return "";

	salt = setting + 4;
	if (strlen(salt) < 8)
		return "";

	for (a=0;a<vectorsize;a++)
	{
	    bbl[a] = 0;
	    memcpy(bigbuf[a], salt, 8);
	    bbl[a]+=8;
	    memcpy(bigbuf[a]+bbl[a], password[a], length[a]);
	    bbl[a]+=length[a];
	}
	hash_sha512_unicode((const char **)bigbuf, hash, bbl);
	
	
	for (a=0;a<vectorsize;a++) bbl[a] = 0;
	count = 1 << count_log2;
	do {
		for (a=0;a<vectorsize;a++)
		{
		    memcpy(bigbuf[a], hash[a], 64);
		    bbl[a]+=64;
		    memcpy(bigbuf[a]+bbl[a], password[a], length[a]);
		    bbl[a]+=length[a];
		}
		hash_sha512_unicode((const char **)bigbuf, hash, bbl);
		for (a=0;a<vectorsize;a++) bbl[a] = 0;
	} while (--count);

	for (a=0;a<vectorsize;a++) memcpy(out[a], setting, 12);
	for (a=0;a<vectorsize;a++) encode64(&out[a][12], hash[a], 64);

	return NULL;
}


char *pacrypt_private(char *password[VECTORSIZE], char *setting, char *out[VECTORSIZE], int vectorsize)
{
	char *output[VECTORSIZE];
	char *hash[VECTORSIZE];
	char *p, *salt;
	int count_log2, length[VECTORSIZE], count;
	char *bigbuf[VECTORSIZE];
	int bbl[VECTORSIZE];
	int a;
	
	
	for (a=0;a<vectorsize;a++)
	{
	    output[a] = alloca(128);
	    hash[a] = alloca(64);
	    bigbuf[a] = alloca(128);
	    length[a] = strlen(password[a]);
	}

	for (a=0;a<vectorsize;a++)
	{
	    strcpy(output[a], "*0");
	    if (!strncmp(setting, output[a], 2))
		output[a][1] = '1';
	}
	
	if (strncmp(setting, "$S$", 3))
		return "";

	p = strchr(itoa64, setting[3]);
	if (!p)
		return "";
	count_log2 = p - itoa64;
	if (count_log2 < 7 || count_log2 > 30)
		return "";

	salt = setting + 4;
	if (strlen(salt) < 8)
		return "";

	for (a=0;a<vectorsize;a++)
	{
	    bbl[a] = 0;
	    memcpy(bigbuf[a], salt, 8);
	    bbl[a]+=8;
	    memcpy(bigbuf[a]+bbl[a], password[a], length[a]);
	    bbl[a]+=length[a];
	}
	hash_sha512_unicode((const char **)bigbuf, hash, bbl);

	for (a=0;a<vectorsize;a++) bbl[a] = 0;
	count = 1 << count_log2;
	do {
		for (a=0;a<vectorsize;a++)
		{
		    memcpy(bigbuf[a], hash[a], 64);
		    bbl[a]+=64;
		    memcpy(bigbuf[a]+bbl[a], password[a], length[a]);
		    bbl[a]+=length[a];
		}
		hash_sha512_unicode((const char **)bigbuf, hash, bbl);
		
		for (a=0;a<vectorsize;a++) bbl[a] = 0;
	} while (--count);

	for (a=0;a<vectorsize;a++) memcpy(out[a], setting, 12);
	for (a=0;a<vectorsize;a++) encode64(&out[a][12], hash[a], 64);

	return NULL;
}

