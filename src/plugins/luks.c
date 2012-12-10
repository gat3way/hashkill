/* luks.c
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


#define LUKS_MAGIC_L        6
#define LUKS_CIPHERNAME_L   32
#define LUKS_CIPHERMODE_L   32
#define LUKS_HASHSPEC_L     32
#define UUID_STRING_L       40
#define LUKS_DIGESTSIZE 20
#define LUKS_SALTSIZE 32
#define LUKS_NUMKEYS 8

/* Taken from LUKS on disk format specification */
struct luks_phdr {
     char      magic[LUKS_MAGIC_L];
     uint16_t  version;
     char      cipherName[LUKS_CIPHERNAME_L];
     char      cipherMode[LUKS_CIPHERMODE_L];
     char      hashSpec[LUKS_HASHSPEC_L];
     uint32_t  payloadOffset;
     uint32_t  keyBytes;
     char      mkDigest[LUKS_DIGESTSIZE];
     char      mkDigestSalt[LUKS_SALTSIZE];
     uint32_t  mkDigestIterations;
     char      uuid[UUID_STRING_L];
     struct {
           uint32_t active;
           uint32_t passwordIterations;
           char     passwordSalt[LUKS_SALTSIZE];
           uint32_t keyMaterialOffset;
           uint32_t stripes;
    } keyblock[LUKS_NUMKEYS];
} myphdr;


static char myfilename[255];
static unsigned char *cipherbuf;
static int afsize;
static unsigned int bestslot=2000;



char * hash_plugin_summary(void)
{
    return("luks \t\tLUKS encrypted block device plugin");
}


char * hash_plugin_detailed(void)
{
    return("luks - LUKS encrypted block device plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack LUKS encrypted partitions\n"
	    "Input should be a LUKS device file specified with -f\n"
	    "Warning: currently only aes256/cbc-essiv:sha256 images supported!\n"
	    "Known software that uses this password hashing method:\n"
	    "cryptsetup/LUKS\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


void XORblock(char *src1, char *src2, char *dst, int n)
{
    int j;

    for(j=0; j<n; j++)
    dst[j] = src1[j] ^ src2[j];
}



static int diffuse(unsigned char *src, unsigned char *dst, int size)
{
    uint32_t i;
    uint32_t IV;   /* host byte order independent hash IV */
    SHA_CTX ctx;
    int fullblocks = (size)/20;
    int padding = size%20;

    for (i=0; i < fullblocks; i++) 
    {
	IV = htonl(i);
	SHA1_Init(&ctx);
	SHA1_Update(&ctx,&IV,4);
	SHA1_Update(&ctx,src+20*i,20);
	SHA1_Final(dst+20*i,&ctx);
    }

    if(padding) 
    {
	IV = htonl(fullblocks);
	SHA1_Init(&ctx);
	SHA1_Update(&ctx,&IV,4);
	SHA1_Update(&ctx,src+20*fullblocks,padding);
	SHA1_Final(dst+20*fullblocks,&ctx);
    }
    return 0;
}



extern int AF_merge(unsigned char *src, unsigned char *dst, int afsize, int stripes)
{
    int i;
    char *bufblock;
    int blocksize=afsize/stripes;

    bufblock = alloca(blocksize);

    memset(bufblock,0,blocksize);
    for(i=0; i<(stripes-1); i++) 
    {
	XORblock((char*)(src+(blocksize*i)),bufblock,bufblock,blocksize);
	diffuse((unsigned char *)bufblock,(unsigned char *)bufblock,blocksize);
    }
    XORblock((char *)(src+blocksize*(stripes-1)),bufblock,(char*)dst,blocksize);
    return 0;
}




static int af_sectors(int blocksize, int blocknumbers)
{
    int af_size;

    af_size = blocksize*blocknumbers;
    af_size = (af_size+511)/512;
    af_size*=512;
    return af_size;
}


static void decrypt_aes_cbc_essiv(unsigned char *src, unsigned char *dst, unsigned char *key, int startsector,int size)
{
    AES_KEY aeskey;
    unsigned char essiv[16];
    unsigned char essivhash[32];
    int a;
    SHA256_CTX ctx;
    unsigned char sectorbuf[16];
    unsigned char zeroiv[16];

    for (a=0;a<(size/512);a++)
    {
	SHA256_Init(&ctx);
	SHA256_Update(&ctx, key, ntohl(myphdr.keyBytes));
	SHA256_Final(essivhash, &ctx);
	bzero(sectorbuf,16);
	bzero(zeroiv,16);
	bzero(essiv,16);
	memcpy(sectorbuf,&a,4);
	hash_aes_set_encrypt_key(essivhash, 256, &aeskey);
	hash_aes_cbc_encrypt(sectorbuf, essiv, 16, &aeskey, zeroiv, AES_ENCRYPT);
	hash_aes_set_decrypt_key(key, ntohl(myphdr.keyBytes)*8, &aeskey);
	hash_aes_cbc_encrypt((src+a*512), (dst+a*512), 512, &aeskey, essiv, AES_DECRYPT);
    }
}



hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int myfile;
    int cnt;
    int readbytes;
    unsigned int bestiter=0xFFFFFFFF;

    myfile = open(filename, O_RDONLY|O_LARGEFILE);
    if (myfile<1) 
    {
	return hash_err;
    }
    
    if (read(myfile,&myphdr,sizeof(struct luks_phdr))<sizeof(struct luks_phdr)) 
    {
	return hash_err;
    }
    
    if (strcmp(myphdr.magic, "LUKS\xba\xbe") !=0 )
    {
	return hash_err;
    }
    
    if (strcmp(myphdr.cipherName,"aes") != 0)
    {
	elog("Only AES cipher supported. Used cipher: %s\n",myphdr.cipherName);
	return hash_err;
    }

    for (cnt=0;cnt<LUKS_NUMKEYS;cnt++)
    {
	if ((ntohl(myphdr.keyblock[cnt].passwordIterations)<bestiter)&&(ntohl(myphdr.keyblock[cnt].passwordIterations)>1)&&(ntohl(myphdr.keyblock[cnt].active)==0x00ac71f3))
	{
	    bestslot=cnt;
	    bestiter=ntohl(myphdr.keyblock[cnt].passwordIterations);
	}
    }
    if (bestslot==2000) return hash_err;

    hlog("Best keyslot [%d]: %d keyslot iterations, %d stripes, %d mkiterations\n", bestslot, ntohl(myphdr.keyblock[bestslot].passwordIterations),ntohl(myphdr.keyblock[bestslot].stripes),ntohl(myphdr.mkDigestIterations));
    afsize = af_sectors(ntohl(myphdr.keyBytes),ntohl(myphdr.keyblock[bestslot].stripes));
    cipherbuf = malloc(afsize);
    lseek(myfile, ntohl(myphdr.keyblock[bestslot].keyMaterialOffset)*512, SEEK_SET);
    readbytes = read(myfile, cipherbuf, afsize);

    if (readbytes<0)
    {
	free(cipherbuf);
	close(myfile);
	return hash_err;
    }



    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("LUKS device  ",0);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2(" ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char keycandidate[255];
    unsigned char masterkeycandidate[255];
    unsigned char masterkeycandidate2[255];
    unsigned char *af_decrypted = alloca(afsize);
    int a;

    for (a=0;a<vectorsize;a++)
    {
	// Get pbkdf2 of the password to obtain decryption key
	hash_pbkdf2(password[a], (unsigned char *)&myphdr.keyblock[bestslot].passwordSalt, LUKS_SALTSIZE, ntohl(myphdr.keyblock[bestslot].passwordIterations), ntohl(myphdr.keyBytes), keycandidate);
	// Decrypt the blocks
	decrypt_aes_cbc_essiv(cipherbuf, af_decrypted, keycandidate, ntohl(myphdr.keyblock[bestslot].keyMaterialOffset),afsize);
	// AFMerge the blocks
	AF_merge(af_decrypted,masterkeycandidate, afsize, ntohl(myphdr.keyblock[bestslot].stripes));
	// pbkdf2 again
	hash_pbkdf2_len((char *)masterkeycandidate, ntohl(myphdr.keyBytes), (unsigned char *)myphdr.mkDigestSalt, LUKS_SALTSIZE, ntohl(myphdr.mkDigestIterations) , LUKS_DIGESTSIZE, masterkeycandidate2);
	// compare
	if (memcmp(masterkeycandidate2, myphdr.mkDigest, LUKS_DIGESTSIZE)==0) 
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

