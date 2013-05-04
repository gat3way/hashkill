/* mozilla.c
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
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char myfilename[255];
int vectorsize;


static unsigned char globalsalt[20];
static unsigned char entrysalt[20];
static unsigned char verifier[16];


char * hash_plugin_summary(void)
{
    return("mozilla \tmozilla passphrase plugin");
}


char * hash_plugin_detailed(void)
{
    return("mozilla - mozilla passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack mozilla key3.db master key\n"
	    "Input should be a mozilla db file (key3.db) specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Firefox, Thunderbird, etc.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    off_t size;
    char *buf;
    char *tok;
    unsigned char pwdcheck[52];

    memset(entrysalt,0,64);
    fd = open(filename, O_RDONLY);
    if (fd < 1) return hash_err;
    size = lseek(fd,0,SEEK_END);
    lseek(fd,0,SEEK_SET);

    // key3.db size sanity check
    if (size > 1024*1024) 
    {
	close(fd);
	return hash_err;
    }
    buf = malloc(size);
    read(fd,buf,size);
    close(fd);

    tok = (char *)memmem(buf, size, "global-salt", strlen("global-salt"));
    if (!tok) 
    {
	free(buf);
	return hash_err;
    }

    tok -= 20;
    // Sanity check
    if (tok < buf)
    {
	free(buf);
	return hash_err;
    }
    memcpy(globalsalt,tok,20);
    tok = (char *)memmem(buf, size, "password-check", strlen("password-check"));
    if (!tok) 
    {
	free(buf);
	return hash_err;
    }

    tok -= 52;
    memcpy(pwdcheck,tok,52);
    memcpy(entrysalt,&pwdcheck[3],20);
    memcpy(verifier,&pwdcheck[52-16],16);

    free(buf);
    strcpy(myfilename, filename);

    (void)hash_add_username(filename);
    (void)hash_add_hash("mozilla key3.db\0",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int lens[VECTORSIZE];
    int plens[VECTORSIZE];
    char *buf[VECTORSIZE];
    char *buf2[VECTORSIZE];
    char *buf3[VECTORSIZE];
    char *buf4[VECTORSIZE];
    int a,b,c;
    char *encver="password-check\x00\x00";
    EVP_CIPHER_CTX ctx;

    for (a=0;a<vectorsize;a++)
    {
	buf[a]=alloca(64);
	buf2[a]=alloca(64);
	buf3[a]=alloca(64);
	buf4[a]=alloca(64);
	memset(buf[a],0,64);
	memcpy(buf[a],globalsalt,20);
	plens[a]=strlen(password[a]);
	memcpy(buf[a]+20,password[a],plens[a]);
	lens[a]=20+plens[a];
    }
    hash_sha1_slow((const char **)buf, buf2, lens);

    for (a=0;a<vectorsize;a++)
    {
	memset(buf[a],0,64);
	memcpy(buf[a],buf2[a],20);
	memcpy(buf[a]+20,entrysalt,20);
	lens[a]=40;
    }
    hash_sha1_slow((const char **)buf, buf2, lens);

    for (a=0;a<vectorsize;a++)
    {
        memset(buf[a],0,64);
	memcpy(buf[a],entrysalt,20);
	memcpy(buf[a]+20,entrysalt,20);
        hash_hmac_sha1(buf2[a],20,(unsigned char *)buf[a],40,(unsigned char *)buf3[a],20);
        memset(buf[a],0,40);
	memcpy(buf[a],entrysalt,20);
        hash_hmac_sha1(buf2[a],20,(unsigned char *)buf[a],20,(unsigned char *)buf4[a],20);
        memset(buf[a],0,40);
	memcpy(buf[a],buf4[a],20);
	memcpy(buf[a]+20,entrysalt,20);
        hash_hmac_sha1(buf2[a],20,(unsigned char *)buf[a],40,(unsigned char *)buf3[a]+20,20);
	EVP_CIPHER_CTX_init(&ctx);
	EVP_DecryptInit_ex(&ctx, EVP_des_ede3_cbc(), NULL, (const unsigned char *)buf3[a], (unsigned char *)buf3[a]+32);
	EVP_DecryptUpdate(&ctx, (unsigned char *)buf[a], &b, verifier, 16);
	EVP_DecryptFinal_ex(&ctx, (unsigned char *)buf[a] + b, &c);
	if (memcmp(buf[a],encver,14)==0)
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
