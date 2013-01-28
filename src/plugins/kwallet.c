/* kwallet.c
 *
 * Add support for cracking KDE KWallet files
 * Copyright (c) 2013, Narendra Kangralkar <narendrakangralkar at gmail.com>
 * and Dhiru Kholia <dhiru at openwall.com>
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
#include <alloca.h>
#include <sys/types.h>
#include <fcntl.h>
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#include <openssl/sha.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"
#include "bad_blowfish.c"

#define KWMAGIC 			"KWALLET\n\r\0\r\n"
#define KWMAGIC_LEN 			12

#define KWALLET_VERSION_MAJOR           0
#define KWALLET_VERSION_MINOR           0

#define KWALLET_CIPHER_BLOWFISH_CBC     0
#define KWALLET_CIPHER_3DES_CBC         1	/* unsupported */

#define KWALLET_HASH_SHA1               0
#define KWALLET_HASH_MD5                1	/* unsupported */
#define N 				128
#define MIN(x,y) ((x) < (y) ? (x) : (y))

static int count;
static long encrypted_size;

int vectorsize;

static struct custom_salt {
	unsigned char ct[0x10000];
	unsigned char ctlen;
} cs;

char *hash_plugin_summary(void)
{
	return ("kwallet \tKDE KWallet passphrase plugin");
}

char *hash_plugin_detailed(void)
{
	return ("kwallet - KDE KWallet passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack KDE KWallet files\n"
	    "Input should be a KDE KWallet (specified with -f)\n" "\nAuthor: Narendra and Dhiru\n");
}

/* helper functions for byte order conversions, header values are stored
 * in big-endian byte order
 */
static uint32_t fget32_(FILE * fp)
{
	uint32_t v = fgetc(fp) << 24;
	v |= fgetc(fp) << 16;
	v |= fgetc(fp) << 8;
	v |= fgetc(fp);
	return v;
}

hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
	FILE *fp;
	unsigned char buf[1024];
	long size, offset = 0;
	size_t i, j;
	uint32_t n;

	if (!(fp = fopen(filename, "rb"))) {
		//fprintf(stderr, "%s : %s\n", filename, strerror(errno));
		return hash_err;
	}

	fseek(fp, 0, SEEK_END);
	size = ftell(fp);
	fseek(fp, 0, SEEK_SET);

	count = fread(buf, KWMAGIC_LEN, 1, fp);
	if (memcmp(buf, KWMAGIC, KWMAGIC_LEN) != 0) {
		//fprintf(stderr, "%s : Not a KDE KWallet file!\n", filename);
		goto bail;
	}

	offset += KWMAGIC_LEN;
	count = fread(buf, 4, 1, fp);
	offset += 4;

	/* First byte is major version, second byte is minor version */
	if (buf[0] != KWALLET_VERSION_MAJOR) {
		//fprintf(stderr, "%s : Unknown version!\n", filename);
		goto bail;
	}

	if (buf[1] != KWALLET_VERSION_MINOR) {
		//fprintf(stderr, "%s : Unknown version!\n", filename);
		goto bail;
	}

	if (buf[2] != KWALLET_CIPHER_BLOWFISH_CBC) {
		//fprintf(stderr, "%s : Unsupported cipher\n", filename);
		goto bail;
	}

	if (buf[3] != KWALLET_HASH_SHA1) {
		//fprintf(stderr, "%s : Unsupported hash\n", filename);
		goto bail;
	}

	/* Read in the hashes */
	n = fget32_(fp);
	if (n > 0xffff) {
		//fprintf(stderr, "%s : sanity check failed!\n", filename);
		goto bail;
	}
	offset += 4;
	for (i = 0; i < n; ++i) {
		uint32_t fsz;

		count = fread(buf, 16, 1, fp);
		offset += 16;
		fsz = fget32_(fp);
		offset += 4;
		for (j = 0; j < fsz; ++j) {
			count = fread(buf, 16, 1, fp);
			offset += 16;

		}
	}

	/* Read in the rest of the file. */
	encrypted_size = size - offset;
	count = fread(cs.ct, encrypted_size, 1, fp);

	if ((encrypted_size % 8) != 0) {
		//fprintf(stderr, "%s : invalid file structure!\n", filename);
		return hash_err;
	}
	fclose(fp);
	cs.ctlen = encrypted_size;

	(void) hash_add_username(filename);
	(void) hash_add_hash("KDE KWallet file    \0", 0);
	(void) hash_add_salt("123");
	(void) hash_add_salt2("                              ");
	return hash_ok;

bail:
	fclose(fp);
	return hash_err;
}



hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,
    char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
	int a;
	unsigned char *buf[VECTORSIZE];
	unsigned char *buf2[VECTORSIZE];
	int lens[VECTORSIZE];
	int lens2[VECTORSIZE];
	BlowFish _bf;
	int sz;
	unsigned char buffer[0x10000];
	const char *t;
	long fsize;
        CipherBlockChain bf;

	for (a = 0; a < vectorsize; a++) 
	{
	    buf[a]=alloca(256);
	    buf2[a]=alloca(64);
	    memset(buf[a],0,256);
	    lens[a]=MIN(strlen(password[a]), 16);
	    memcpy(buf[a],password[a],lens[a]);
	    lens2[a]=20;
	}
	
	hash_sha1_slow((const char **)buf,(char **)buf,lens);
	for (a = 0; a < 1999; a++) 
	{
	    hash_sha1_unicode((const char **)buf,(char **)buf,lens2);
	}

	for (a = 0; a < vectorsize; a++) 
	{
	    CipherBlockChain_constructor(&bf, &_bf);
	    CipherBlockChain_setKey(&bf, (void *) buf[a], 20 * 8);
	    memcpy(buffer, cs.ct, cs.ctlen);
	    CipherBlockChain_decrypt(&bf, buffer, cs.ctlen);
    	    t = (char *) buffer;
	    // strip the leading data
	    t += 8; 
	    // strip the file size off
	    fsize = 0;
	    fsize |= ((long) (*t) << 24) & 0xff000000;
	    t++;
	    fsize |= ((long) (*t) << 16) & 0x00ff0000;
	    t++;
	    fsize |= ((long) (*t) << 8) & 0x0000ff00;
	    t++;
	    fsize |= (long) (*t) & 0x000000ff;
	    t++;
	    if (fsize < 0 || fsize > (long) (cs.ctlen) - 8 - 4) 
	    {
		// file structure error
		lens[a]=1;
		buf2[a][0]='_';
		continue;
	    }
	    lens[a]=fsize;
	    memcpy(buf[a],t,fsize);
	    sz = cs.ctlen;
	    memcpy(buf2[a],buffer+(sz-20),20);
	}

	hash_sha1_slow((const char **)buf,(char **)buf,lens);
	
	for (a = 0; a < vectorsize; a++) 
	{
	    sz = cs.ctlen;
	    if (memcmp(buf2[a],buf[a],20)==0)
	    {
		*num = a;
		return hash_ok;
	    }
	}
	return hash_err;
}

int hash_plugin_hash_length(void)
{
	return 20;
}

int hash_plugin_is_raw(void)
{
	return 0;
}

int hash_plugin_is_special(void)
{
	return 1;
}

void get_vector_size(int size)
{
	vectorsize = size;
}

int get_salt_size(void)
{
	return 4;
}
