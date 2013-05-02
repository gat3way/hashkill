/* androidfde.c
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


#define _LARGEFILE64_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <openssl/sha.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


struct android_hdr 
{
     uint32_t  magic;
     uint16_t  major_version;
     uint16_t  minor_version;
     uint32_t  ftr_size;
     uint32_t  flags;
     uint32_t  keysize;
     uint32_t  spare1;
     uint64_t  fs_size;
     uint32_t  failed_count;
     unsigned char cipherName[64];
} myphdr;

#define CRYPT_FOOTER_OFFSET 0x4000
#define ACCEPTABLE_BACKLOG 0x2000

static char myfilename[255];
static unsigned char mkey[32];
static unsigned char msalt[16];
static unsigned char blockbuf[512*3];


char * hash_plugin_summary(void)
{
    return("androidfde \tAndroid Full Disk Encryption plugin");
}


char * hash_plugin_detailed(void)
{
    return("androidfde - Android Full Disk Encryption plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack Android encrypted partitions\n"
	    "Input should be a encrypted device file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Android\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}



// Not reference implementation - this is modified for use by androidfde!
static void decrypt_aes_cbc_essiv(unsigned char *src, unsigned char *dst, unsigned char *key, int startsector,int size)
{
    AES_KEY aeskey;
    unsigned char essiv[16];
    unsigned char essivhash[32];
    SHA256_CTX ctx;
    unsigned char sectorbuf[16];
    unsigned char zeroiv[16];

    SHA256_Init(&ctx);
    SHA256_Update(&ctx, key, myphdr.keysize);
    SHA256_Final(essivhash, &ctx);
    memset(sectorbuf,0,16);
    memset(zeroiv,0,16);
    memset(essiv,0,16);
    memcpy(sectorbuf,&startsector,4);
    hash_aes_set_encrypt_key(essivhash, 256, &aeskey);
    hash_aes_cbc_encrypt(sectorbuf, essiv, 16, &aeskey, zeroiv, AES_ENCRYPT);
    hash_aes_set_decrypt_key(key, myphdr.keysize*8, &aeskey);
    hash_aes_cbc_encrypt(src, dst, size, &aeskey, essiv, AES_DECRYPT);
}



hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int myfile;
    int cnt;

    myfile = open(filename, O_RDONLY|O_LARGEFILE);
    if (myfile<1) 
    {
	return hash_err;
    }
    
    if (lseek(myfile,-(CRYPT_FOOTER_OFFSET+ACCEPTABLE_BACKLOG),SEEK_END)<0)
    {
	close(myfile);
	return hash_err;
    }
    
    int flag = 0;
    off_t pos = lseek(myfile,0,SEEK_CUR);

    for (cnt=0;cnt<ACCEPTABLE_BACKLOG;cnt++)
    {
	lseek(myfile,pos+cnt,SEEK_SET);
	if (read(myfile,&myphdr,sizeof(struct android_hdr))<sizeof(struct android_hdr)) 
	{
	    return hash_err;
	}
	if (myphdr.magic==0xD0B5B1C4) 
	{
	    flag = 1;
	    break;
	}
    }
    if (flag==0)
    {
        close(myfile);
        return hash_err;
    }

    if (strncmp((char*)myphdr.cipherName,"aes",3) != 0)
    {
	close(myfile);
	return hash_err;
    }

    if (lseek(myfile,myphdr.ftr_size-sizeof(myphdr),SEEK_CUR)<0)
    {
	close(myfile);
	return hash_err;
    }
    read(myfile,mkey,myphdr.keysize);
    if (lseek(myfile,32,SEEK_CUR)<0)
    {
	close(myfile);
	return hash_err;
    }
    read(myfile,msalt,16);
    lseek(myfile,0,SEEK_SET);
    read(myfile,blockbuf,512*3);

    close(myfile);
    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("Android FDE",0);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2(" ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char keycandidate[255];
    unsigned char keycandidate2[255];
    unsigned char decrypted1[512]; // FAT
    unsigned char decrypted2[512]; // ext3/4
    int a;
    AES_KEY aeskey;

    for (a=0;a<vectorsize;a++)
    {
	// Get pbkdf2 of the password to obtain decryption key
	hash_pbkdf2(password[a], msalt, 16, 2000, myphdr.keysize+16, keycandidate);
	hash_aes_set_decrypt_key(keycandidate, myphdr.keysize*8, &aeskey);
	hash_aes_cbc_encrypt(mkey, keycandidate2, 16, &aeskey, keycandidate+16, AES_DECRYPT);
	decrypt_aes_cbc_essiv(blockbuf, decrypted1, keycandidate2,0,32);
	decrypt_aes_cbc_essiv(blockbuf+1024, decrypted2, keycandidate2,2,128);

	// Check for FAT
	if ((memcmp(decrypted1+3,"MSDOS5.0",8)==0))
	{
	    *num=a;
	    return hash_ok;
	}
	// Check for extfs
	uint16_t v2,v3,v4;
	uint32_t v1,v5;
	memcpy(&v1,decrypted2+72,4);
	memcpy(&v2,decrypted2+0x3a,2);
	memcpy(&v3,decrypted2+0x3c,2);
	memcpy(&v4,decrypted2+0x4c,2);
	memcpy(&v5,decrypted2+0x48,4);
	
	if ((v1<5)&&(v2<4)&&(v3<5)&&(v4<2)&&(v5<5))
	{
	    *num=a;
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

