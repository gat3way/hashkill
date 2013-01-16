/* keepass.c
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
#include <stdint.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char myfilename[255];
int vectorsize;

static unsigned int version;
static unsigned int rounds;

/* v1 data */
static unsigned char finalseed[16];
static unsigned char iv[16];
static unsigned char v1hash[32];
static unsigned char transseed[32];
static unsigned char *v1data = NULL;
static unsigned char *v1dec[VECTORSIZE];
static unsigned int v1datasize;

/* v2 data */
static unsigned char v2masterseed[32];
static unsigned int v2masterseedsize;
static unsigned char v2transseed[32];
static unsigned int v2transseedsize;
static unsigned char v2iv[16];
static unsigned int v2ivsize;
static unsigned char v2streambytes[32];
static unsigned int v2streambytessize;
static unsigned char v2enc[32];


char * hash_plugin_summary(void)
{
    return("keepass \tKeePass passphrase plugin");
}


char * hash_plugin_detailed(void)
{
    return("keepass - KeePass passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack KeePass databases\n"
	    "Input should be a KeePass db file (.kdb/.kdbx) specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "KeePass2/KeePassX, etc.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    off_t size;
    unsigned int u32,u321;
    int a;


    fd = open(filename, O_RDONLY);
    if (fd < 1) return hash_err;
    size = lseek(fd,0,SEEK_END);
    if (size<125)
    {
	close(fd);
	return hash_err;
    }
    lseek(fd,0,SEEK_SET);
    read(fd,&u32,4);
    read(fd,&u321,4);

    /* Keepass 1.x format? */
    if ((u32==0x9AA2D903)&&(u321==0xB54BFB65))
    {
	unsigned int flag, fversion,groups,entries;
	off_t datasize;

	version = 1;
	read(fd,&flag,4);
	read(fd,&fversion,4);
	read(fd,finalseed,16);
	read(fd,iv,16);
	read(fd,&groups,4);
	read(fd,&entries,4);
	read(fd,v1hash,32);
	read(fd,transseed,32);
	read(fd,&rounds,4);
	if (((fversion&0xFFFFFF00)!=0x00030000)||(!(flag&2)))
	{
	    close(fd);
	    return hash_err;
	}
	datasize = size-124;
	v1data = malloc(datasize);
	for (a=0;a<vectorsize;a++) v1dec[a] = malloc(datasize);
	lseek(fd,124,SEEK_SET);
	read(fd,v1data,datasize);
	v1datasize = datasize;
    }

    /* Keepass 2.x format? */
    else if (((u32==0x9AA2D903)&&(u321==0xB54BFB67)) || ((u32==0x9AA2D903)&&(u321==0xB54BFB66)))
    {
	unsigned int flag, fversion;
	unsigned char fid;
	unsigned short fsize;
	unsigned char *data;
	uint64_t brounds;

	version = 2;
	read(fd,&fversion,4);
	if ((fversion&0xFFFF0000) > 0x00030000)
	{
	    close(fd);
	    return hash_err;
	}
	flag = 0;
	while (flag==0)
	{
	    read(fd,&fid,1);
	    read(fd,&fsize,2);
	    if ((fsize==0)||(fsize>1024*1024))
	    {
		close(fd);
		return hash_err;
	    }

	    data = malloc(fsize);
	    if (fsize > read(fd,data,fsize))
	    {
		close(fd);
		free(data);
		return hash_err;
	    }

	    switch (fid)
	    {
		case 0:
		    flag=1;
		    free(data);
		    break;
		case 4:
		    memcpy(v2masterseed,data,fsize);
		    v2masterseedsize = fsize;
		    free(data);
		    break;
		case 5:
		    memcpy(v2transseed,data,fsize);
		    v2transseedsize = fsize;
		    free(data);
		    break;
		case 6:
		    memcpy(&brounds,data,8);
		    rounds = brounds;
		    free(data);
		    break;
		case 7:
		    memcpy(v2iv,data,fsize);
		    v2ivsize = fsize;
		    free(data);
		    break;
		case 9:
		    memcpy(v2streambytes,data,fsize);
		    v2streambytessize = fsize;
		    free(data);
		    break;
		default:
		    free(data);
		    break;
	    }
	}

	if ((v2masterseedsize!=32)||(v2transseedsize!=32)||(v2ivsize!=16)||(v2streambytessize!=32)||(rounds==0))
	{
	    close(fd);
	    return hash_err;
	}
	if (32 > read(fd,v2enc,32))
	{
	    close(fd);
	    return hash_err;
	}
    }

    /* DB Error */
    else
    {
	close(fd);
	return hash_err;
    }

    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("KeePass DB    \0",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int lens[VECTORSIZE];
    char *buf[VECTORSIZE];
    char *buf2[VECTORSIZE];
    char *buf3[VECTORSIZE];
    int a,b;
    AES_KEY akey;
    unsigned char zeroiv[16];
    unsigned char myiv[16];
    unsigned char pad;
    int v1size[VECTORSIZE];

    if (version==1)
    {
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a] = strlen(password[a]);
	    buf[a] = alloca(32);
	    buf2[a] = alloca(32);
	    buf3[a] = alloca(48);
	}
	hash_sha256_unicode(password, buf, lens);
	hash_aes_set_encrypt_key(transseed, 256, &akey);

	for (a=0;a<vectorsize;a++)
	{
	    for (b=0;b<rounds;b++)
	    {
		bzero(zeroiv,16);
		hash_aes_cbc_encrypt((unsigned char*)buf[a],(unsigned char*)buf[a],16,&akey,zeroiv,AES_ENCRYPT);
		bzero(zeroiv,16);
		hash_aes_cbc_encrypt((unsigned char*)buf[a]+16,(unsigned char*)buf[a]+16,16,&akey,zeroiv,AES_ENCRYPT);
	    }
	    lens[a]=32;
	}
	hash_sha256_unicode((const char **)buf, buf2, lens);
	for (a=0;a<vectorsize;a++)
	{
	    memcpy(buf3[a],finalseed,16);
	    memcpy(buf3[a]+16,buf2[a],32);
	    lens[a]=48;
	}
	hash_sha256_unicode((const char **)buf3, buf2, lens);
	for (a=0;a<vectorsize;a++)
	{
	    hash_aes_set_decrypt_key((const unsigned char *)buf2[a], 256, &akey);
	    memcpy(myiv,iv,16);
	    hash_aes_cbc_encrypt((unsigned char*)v1data,(unsigned char*)v1dec[a],v1datasize,&akey,myiv,AES_DECRYPT);
	    pad = v1dec[a][v1datasize-1];
	    v1size[a] = v1datasize - pad;
	}
	hash_sha256_unicode((const char **)v1dec, buf2, v1size);
	for (a=0;a<vectorsize;a++)
	{
	    if (memcmp(buf2[a],v1hash,32)==0)
	    {
		*num = a;
		return hash_ok;
	    }
	}
    }
    else
    {
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a] = strlen(password[a]);
	    buf[a] = alloca(32);
	    buf2[a] = alloca(32);
	    buf3[a] = alloca(64);
	}
	hash_sha256_unicode(password, buf2, lens);
	for (a=0;a<vectorsize;a++) lens[a]=32;
	hash_sha256_unicode((const char **)buf2, buf, lens);
	hash_aes_set_encrypt_key(v2transseed, 256, &akey);
	for (a=0;a<vectorsize;a++)
	{
	    for (b=0;b<rounds;b++)
	    {
		bzero(zeroiv,16);
		hash_aes_cbc_encrypt((unsigned char*)buf[a],(unsigned char*)buf[a],16,&akey,zeroiv,AES_ENCRYPT);
		bzero(zeroiv,16);
		hash_aes_cbc_encrypt((unsigned char*)buf[a]+16,(unsigned char*)buf[a]+16,16,&akey,zeroiv,AES_ENCRYPT);
	    }
	    lens[a]=32;
	}
	hash_sha256_unicode((const char **)buf, buf2, lens);
	for (a=0;a<vectorsize;a++)
	{
	    memcpy(buf3[a],v2masterseed,32);
	    memcpy(buf3[a]+32,buf2[a],32);
	    lens[a]=64;
	}

	hash_sha256_unicode((const char **)buf3, buf2, lens);

	for (a=0;a<vectorsize;a++)
	{
	    hash_aes_set_decrypt_key((const unsigned char *)buf2[a], 256, &akey);
	    memcpy(myiv,v2iv,16);
	    hash_aes_cbc_encrypt((unsigned char*)v2enc,(unsigned char*)buf[a],32,&akey,myiv,AES_DECRYPT);
	    if (memcmp(buf[a],v2streambytes,32)==0)
	    {
		*num = a;
		return hash_ok;
	    }
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
