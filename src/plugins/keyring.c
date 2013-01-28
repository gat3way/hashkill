/* keyring.c
 *
 * Add support for cracking GNOME Keyring files
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

#define SALTLEN 8
#define LINE_BUFFER_SIZE 81920
typedef unsigned char guchar;
typedef unsigned int guint;
typedef int gint;

int vectorsize;

struct custom_salt {
        unsigned int iterations;
        unsigned char salt[SALTLEN];
        unsigned int crypto_size;
        unsigned int inlined;
        unsigned char ct[LINE_BUFFER_SIZE];
} cs;

char *hash_plugin_summary(void)
{
	return ("keyring \tGNOME Keyring passphrase plugin");
}

char *hash_plugin_detailed(void)
{
	return ("keyring - GNOME Keyring passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack GNOME Keyring files\n"
	    "Input should be a GNOME Keyring (specified with -f)\n"
	    "\nAuthor: Dhiru Kholia <dhiru at openwall.com>\n");
}

#define KEYRING_FILE_HEADER "GnomeKeyring\n\r\0\n"
#define KEYRING_FILE_HEADER_LEN 16

typedef unsigned char guchar;
typedef unsigned int guint;
typedef int gint;

/* helper functions for byte order conversions, header values are stored
 * in big-endian byte order */
static uint32_t fget32_(FILE * fp)
{
	uint32_t v = fgetc(fp) << 24;
	v |= fgetc(fp) << 16;
	v |= fgetc(fp) << 8;
	v |= fgetc(fp);
	return v;
}

static void get_uint32(FILE * fp, int *next_offset, uint32_t * val)
{
	*val = fget32_(fp);
	*next_offset = *next_offset + 4;
}

static int get_utf8_string(FILE * fp, int *next_offset)
{
	uint32_t len;
	unsigned char buf[1024];
	get_uint32(fp, next_offset, &len);

	if (len == 0xffffffff) {
		return 1;
	} else if (len >= 0x7fffffff) {
		// bad
		return 0;
	}
	/* read len bytes */
	fread(buf, len, 1, fp);
	*next_offset = *next_offset + len;
	return 1;
}

static void buffer_get_attributes(FILE * fp, int *next_offset)
{
	guint list_size;
	guint type;
	guint val;
	int i;
	get_uint32(fp, next_offset, &list_size);
	for (i = 0; i < list_size; i++) {
		get_utf8_string(fp, next_offset);
		get_uint32(fp, next_offset, &type);
		switch (type) {
		case 0:	/* A string */
			get_utf8_string(fp, next_offset);
			break;
		case 1:	/* A uint32 */
			get_uint32(fp, next_offset, &val);
			break;
		}
	}
}

static int read_hashed_item_info(FILE * fp, int *next_offset, uint32_t n_items)
{

	int i;
	uint32_t id;
	uint32_t type;

	for (i = 0; i < n_items; i++) {
		get_uint32(fp, next_offset, &id);
		get_uint32(fp, next_offset, &type);
		buffer_get_attributes(fp, next_offset);
	}
	return 1;
}

hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
	FILE *fp;
	unsigned char buf[1024];
	int i, offset;
	uint32_t flags;
	uint32_t lock_timeout;
	unsigned char major, minor, crypto, hash;
	uint32_t tmp;
	uint32_t num_items;
	unsigned char salt[8];
	unsigned char *to_decrypt;
	int count;

	if (!(fp = fopen(filename, "rb"))) {
		fprintf(stderr, "%s : %s\n", filename, strerror(errno));
		return hash_err;
	}
	count = fread(buf, KEYRING_FILE_HEADER_LEN, 1, fp);
	if (count!=1) return hash_err;
	//assert(count == 1);
	if (memcmp(buf, KEYRING_FILE_HEADER, KEYRING_FILE_HEADER_LEN) != 0) {
		//fprintf(stderr, "%s : Not a GNOME Keyring file!\n", filename);
		return hash_err;
	}
	offset = KEYRING_FILE_HEADER_LEN;
	major = fgetc(fp);
	minor = fgetc(fp);
	crypto = fgetc(fp);
	hash = fgetc(fp);
	offset += 4;

	if (major != 0 || minor != 0 || crypto != 0 || hash != 0) {
		//fprintf(stderr, "%s : Un-supported GNOME Keyring file!\n",
		//    filename);
		fclose(fp);
		return hash_err;
	}
	// Keyring name
	if (!get_utf8_string(fp, &offset))
		goto bail;
	// ctime
	count = fread(buf, 8, 1, fp);
	//assert(count == 1);
	if (count!=1)
	{
	    fclose(fp);
	    return hash_err;
	}
	offset += 8;
	// mtime
	count = fread(buf, 8, 1, fp);
	assert(count == 1);
	offset += 8;
	// flags
	get_uint32(fp, &offset, &flags);
	// lock timeout
	get_uint32(fp, &offset, &lock_timeout);
	// iterations
	get_uint32(fp, &offset, &cs.iterations);
	// salt
	count = fread(salt, 8, 1, fp);
	assert(count == 1);
	offset += 8;
	// reserved
	for (i = 0; i < 4; i++) {
		get_uint32(fp, &offset, &tmp);
	}
	// num_items
	get_uint32(fp, &offset, &num_items);
	if (!read_hashed_item_info(fp, &offset, num_items))
		goto bail;

	// crypto_size
	get_uint32(fp, &offset, &cs.crypto_size);
	//fprintf(stderr, "%s: crypto size: %u offset : %d\n", filename, crypto_size, offset);

	/* Make the crypted part is the right size */
	if (cs.crypto_size % 16 != 0)
		goto bail;

	to_decrypt = (unsigned char *) malloc(cs.crypto_size);
	count = fread(to_decrypt, cs.crypto_size, 1, fp);
	assert(count == 1);
	memcpy(cs.salt, salt, SALTLEN);
	memcpy(cs.ct, to_decrypt, cs.crypto_size);
	if(to_decrypt)
		free(to_decrypt);

	(void) hash_add_username(filename);
	(void) hash_add_hash("GNOME Keyring file    \0", 0);
	(void) hash_add_salt("123");
	(void) hash_add_salt2("                              ");
	return hash_ok;

bail:
	//fprintf(stderr, "%s: Possible bug found, please report this upstream!\n", filename);
	fclose(fp);
	return hash_err;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,
    char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
	unsigned char *buf[VECTORSIZE];
	unsigned char *buf2[VECTORSIZE];
	unsigned char *key[VECTORSIZE];
	unsigned char *iv[VECTORSIZE];
	int lens[VECTORSIZE];
	int lens2[VECTORSIZE];
	AES_KEY aeskey;
	char *fixedverifier="\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98\xec\xf8\x42\x7e";
	int a;

	for (a = 0; a < vectorsize; a++) {
		buf[a] = alloca((cs.crypto_size + 1)>64 ? (cs.crypto_size + 1) : 64);
		buf2[a] = alloca(32);
		key[a] = alloca(16);
		iv[a] = alloca(16);
		lens[a] = strlen(password[a]);
		memcpy(buf[a],password[a],lens[a]);
		memcpy(buf[a]+lens[a],cs.salt,8);
		lens[a]+=8;
		lens2[a]=32;
	}
	hash_sha256_unicode((const char **)buf,(char **)buf2,lens);
	for (a=1;a<cs.iterations;a++)
	{
	    hash_sha256_unicode((const char **)buf2,(char **)buf2,lens2);
	}

	for (a = 0; a < vectorsize; a++) 
	{
	    memcpy(key[a],buf2[a],16);
	    memcpy(iv[a],buf2[a]+16,16);
	    memcpy(buf[a], cs.ct, cs.crypto_size);
	    hash_aes_set_decrypt_key(key[a], 128, &aeskey);
	    hash_aes_cbc_encrypt(buf[a], buf[a], cs.crypto_size, &aeskey, iv[a], AES_DECRYPT);
	}
	/*
	    Milen:
	    Here comes the magic - cs.crypto_size is always 16 which means we're comparing against
	    MD5(""). We can precalculate that rather than calculating it each time.
	    This would come rather handy for the GPU code, not so useful for CPU though
	*/
	for (a = 0; a < vectorsize; a++) 
	{
	    if (memcmp(buf[a], fixedverifier, 16) == 0)
	    {
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
