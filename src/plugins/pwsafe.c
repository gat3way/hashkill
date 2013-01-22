/* pwsafe.c
 *
 * Password Safe cracker
 * Copyright (C) 2013 Dhiru Kholia <dhiru at openwall.com>
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
#include <openssl/sha.h>
#include <fcntl.h>
#include <assert.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

int vectorsize;
static struct custom_salt {
	int version;
	unsigned int iterations;
	unsigned char salt[32];
	unsigned char hash[32];
} cs;

char *hash_plugin_summary(void)
{
	return ("pwsafe \tPassword Safe pwsafe passphrase plugin");
}

char *hash_plugin_detailed(void)
{
	return ("pwsafe - Password Safe pwsafe passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack Password Safe pwsafe files\n"
	    "Input should be a Password Safe pwsafe (specified with -f)\n"
	    "\nAuthor: Dhiru Kholia <dhiru at openwall.com>\n");
}

static char *magic = "PWS3";

/* helper functions for byte order conversions, header values are stored
 * in little-endian byte order */
static uint32_t fget32(FILE * fp)
{
	uint32_t v = fgetc(fp);
	v |= fgetc(fp) << 8;
	v |= fgetc(fp) << 16;
	v |= fgetc(fp) << 24;
	return v;
}

hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
	FILE *fp;
	int count;
	unsigned char buf[32];

	if (!(fp = fopen(filename, "rb"))) {
		fprintf(stderr, "! %s: %s\n", filename, strerror(errno));
		goto bail;
	}
	count = fread(buf, 4, 1, fp);
	assert(count == 1);
	if(memcmp(buf, magic, 4)) {
		fprintf(stderr, "%s : Couldn't find PWS3 magic string. Is this a Password Safe file?\n", filename);
		goto bail;
	}
	count = fread(buf, 32, 1, fp);
	cs.iterations = fget32(fp);

	memcpy(cs.salt, buf, 32);
	count = fread(buf, 32, 1, fp);
	assert(count == 1);
	memcpy(cs.hash, buf, 32);
	fclose(fp);

	(void) hash_add_username(filename);
	(void) hash_add_hash("Password Safe pwsafe file    \0", 0);
	(void) hash_add_salt("123");
	(void) hash_add_salt2("                              ");
	return hash_ok;

bail:
	return hash_err;
}

static void crypt_all(const char *password, unsigned char *output)
{
	SHA256_CTX ctx;
	int i;
	SHA256_Init(&ctx);
	SHA256_Update(&ctx, password, strlen(password));
	SHA256_Update(&ctx, cs.salt, 32);
	SHA256_Final(output, &ctx);
	for(i = 0; i <= cs.iterations; i++)  {
		SHA256_Init(&ctx);
		SHA256_Update(&ctx, output, 32);
		SHA256_Final(output, &ctx);
	}
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,
    char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
	unsigned char *buf[VECTORSIZE];

	int a;

	for (a = 0; a < vectorsize; a++) {
		buf[a] = alloca(32);
	}
	for (a = 0; a < vectorsize; a++) {
		crypt_all(password[a], buf[a]);
		if (!memcmp(buf[a], cs.hash, 32)) {
			*num = a;
			return hash_ok;
		}
	}

	return hash_err;
}


int hash_plugin_hash_length(void)
{
	return 16;
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
