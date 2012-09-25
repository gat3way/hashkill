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

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <stdint.h>
#include <sys/types.h>
#include <fcntl.h>
#include <arpa/inet.h>
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




char myfilename[255];

char * hash_plugin_summary(void)
{
    return("luks \t\t\tLUKS encrypted block device plugin");
}


char * hash_plugin_detailed(void)
{
    return("luks - LUKS encrypted block device plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack LUKS encrypted partitions\n"
	    "Input should be a LUKS device file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "cryptsetup/LUKS\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int myfile;
    myfile = open(filename, O_RDONLY);
    int cnt;
    
    if (myfile<1) 
    {
	elog("Open %s failed!\n",filename);
	return hash_err;
    }
    
    if (read(myfile,&myphdr,sizeof(struct luks_phdr))<sizeof(struct luks_phdr)) 
    {
	elog("%s: cannot read LUKS header!\n", filename);
	return hash_err;
    }
    
    if (strcmp(myphdr.magic, "LUKS\xba\xbe") !=0 )
    {
	elog("%s: bad LUKS header!\n", filename);
	return hash_err;
    }
    
    if (strcmp(myphdr.cipherName,"aes") != 0)
    {
	elog("Only AES cipher supported. Used cipher: %s\n",myphdr.cipherName);
	return hash_err;
    }
    
    hlog("Ciphername: %s\n", myphdr.cipherName);
    hlog("Ciphermode: %s\n", myphdr.cipherMode);
    hlog("Keybytes: %d\n", ntohl(myphdr.keyBytes));
    hlog("Hashspec: %s\n", myphdr.hashSpec);
    hlog("mkdigestiterations: %d\n", htonl(myphdr.mkDigestIterations));

    
    for (cnt=0;cnt<=LUKS_NUMKEYS;cnt++)
    hlog("Keyslot %d: active: %d - iteration count %d\n", cnt, ntohl(myphdr.keyblock[cnt].active), ntohl(myphdr.keyblock[cnt].passwordIterations));
    
    

    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("LUKS device",0);
    (void)hash_add_salt("");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password, const char *salt,  char * __restrict salt2, const char *username)
{
    int cnt,fd, readbytes,smth=0;
    char keycandidate[255];
    char masterkeycandidate[255];
    char masterkeycandidate2[255];

    char *splittedkey = malloc(1024*255);
    char *cipherbuf = malloc(1024*255);
    
    
    if (strlen(password)<2) return hash_err;
    /* For each active keyslot */
    for (cnt = 0;cnt <= LUKS_NUMKEYS;cnt++)
    /* Try to decrypt master key */
    if (ntohl(myphdr.keyblock[cnt].passwordIterations) > 0)
    {
	hash_pbkdf2(password, (unsigned char *)&myphdr.keyblock[cnt].passwordSalt, LUKS_SALTSIZE, ntohl(myphdr.keyblock[cnt].passwordIterations), ntohl(myphdr.keyBytes), keycandidate);
	fd = open(myfilename, O_RDONLY);
	lseek(fd, ntohl(myphdr.keyblock[cnt].keyMaterialOffset)*512, SEEK_SET);
	readbytes = read(fd, cipherbuf, ntohl(myphdr.keyBytes)*ntohl(myphdr.keyblock[cnt].stripes));
	if (readbytes<0) goto out;
	close(fd);
	//printf("readbytes=%d stripes=%d\n", readbytes,ntohl(myphdr.keyblock[cnt].stripes));
	//hash_aes_decrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode);
	/* OK - SO WE HAVE TO GENERATE THE ESSIV */
	char essiv[32];
	char hashedkey[32];
	char zeroiv[32];
	bzero(zeroiv,32);
	hash_sha256(keycandidate, hashedkey, ntohl(myphdr.keyBytes));
	int offset = ntohl(myphdr.keyblock[cnt].keyMaterialOffset);
	hash_aes_encrypt(hashedkey, ntohl(myphdr.keyBytes), &offset , 4, zeroiv, essiv, 0);
	
	hash_aes_decrypt(keycandidate, ntohl(myphdr.keyBytes), cipherbuf, readbytes, essiv, splittedkey, 1);
	AF_merge(splittedkey,masterkeycandidate, ntohl(myphdr.keyBytes), ntohl(myphdr.keyblock[cnt].stripes));
	///int AF_merge(char *src, char *dst, size_t blocksize, unsigned int blocknumbers, const char *hash)
	hash_pbkdf2(masterkeycandidate, myphdr.mkDigestSalt, LUKS_SALTSIZE, ntohl(myphdr.mkDigestIterations), ntohl(myphdr.keyBytes), masterkeycandidate2);
	if (memcmp(masterkeycandidate2, myphdr.mkDigest, LUKS_DIGESTSIZE)==0) smth = 1;
	printf("password = %s mkcand2=",password);
	for (fd=0;fd<16;fd++) printf("%02x",masterkeycandidate2[fd]&255);
	printf(" mkdigest= ");
	for (fd=0;fd<16;fd++) printf("%02x",myphdr.mkDigest[fd]&255);
	printf("\n");
    }
    out:
    free(cipherbuf);
    free(splittedkey);


    if (smth==1) {memcpy(salt2,"LUKS device\0\0", 12);return hash_ok;}
    else 
    {
	salt2[0]=password[0];
	return hash_err;
    }
}


int hash_plugin_hash_length(void)
{
    return 14;
}

int hash_plugin_is_raw(void)
{
    return 0;
}

int hash_plugin_is_special(void)
{
    return 1;
}
