/* odf.c
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
#include <fcntl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <openssl/sha.h>
#include <openssl/blowfish.h>
#include "zlib.h"
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;
char myfilename[255];

static int filenamelen;
static int comprsize, ucomprsize;
static unsigned char content[1024];
static unsigned char *manifest = NULL;
static unsigned char *manifest_u = NULL;
static unsigned char s_checksum[64];
static unsigned char s_checksum_type[64];
static unsigned char s_iv[64];
static unsigned char s_salt[64];
static unsigned char s_algo_name[64];
static unsigned char s_iterations[64];
static unsigned char s_key_size[64];
static unsigned char iv[64];
static unsigned char bsalt[64];
static unsigned char checksum[64];
static int iterations;
static int keysize;
static int cs_size;
static int algorithm;
static int csalgorithm;
static int contentsize;

extern int b64_pton(char const *src, unsigned char *target, size_t targsize);


char * hash_plugin_summary(void)
{
    return("odf \t\tOpenOffice passwords plugin");
}


char * hash_plugin_detailed(void)
{
    return("odf - OpenOffice passwords plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack odf archives passwords\n"
	    "Input should be a passworded odf file specified with -f\n"
	    "Supports the old encryption method as well as AES encryption (Winodf)\n"
	    "Known software that uses this password hashing method:\n"
	    "OpenOffice, LibreOffice, etc\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    char buf[4096];
    unsigned int u321;
    unsigned short u161, genpurpose, extrafieldlen;
    //int compmethod=0;
    unsigned char *tok,*tok1,*tok2;
    int a;
    int parsed=0;
    int parsedc=0;
    size_t apos,epos,cpos,rpos;

    strcpy(myfilename, filename);

    fd = open(filename, O_RDONLY);
    if (fd<1)
    {
        if (!hashline) elog("Cannot open file %s\n", filename);
        return hash_err;
    }
    read(fd, &u321, 4);

    if (u321 != 0x04034b50)
    {
        if (!hashline) elog("Not a odf file: %s!\n", filename);
        return hash_err;
    }
    close(fd);

    fd = open(filename, O_RDONLY);

    //compmethod=0;

    while ((parsed==0)||(parsedc==0))
    {
	read(fd, &u321, 4);
	if (u321 != 0x04034b50)
	{
	    if ((parsed==0)||(parsedc==0)) goto out;
	}

	/* version needed to extract */
	read(fd, &u161, 2);

	/* general purpose bit flag */
	read(fd, &genpurpose, 2);

	/* compression method, last mod file time, last mod file date */
	read(fd, &u161, 2);
	//compmethod=u161;
	read(fd, &u161, 2);
	read(fd, &u161, 2);

	/* crc32 */
	read(fd, &u321, 4);

	/* compressed size */
        read(fd, &comprsize, 4);

	/* uncompressed size */
	read(fd, &ucomprsize, 4);

        /* file name length */
	read(fd, &filenamelen, 2);

        /* extra field length */
	read(fd, &extrafieldlen, 2);

	/* file name */
	bzero(buf,4096);
	read(fd, buf, filenamelen);

	apos = lseek(fd,0,SEEK_CUR);
	if ((comprsize==0)&&(((genpurpose>>3)&1)))
	{
	    int flag=0;
	    while (flag==0)
	    {
		cpos = lseek(fd,0,SEEK_CUR);
		if (read(fd,&u321,4)!=4) goto out;
		if (u321 == 0x08074b50) flag = 1;
		else lseek(fd,cpos+1,SEEK_SET);
	    }
	    read(fd,&u321,4);
	    read(fd,&comprsize,4);
	    read(fd,&ucomprsize,4);
	    cpos = lseek(fd,0,SEEK_CUR);
	    epos = cpos-16;
	}
	else
	{
	    lseek(fd,extrafieldlen,SEEK_CUR);
	    epos = lseek(fd,0,SEEK_CUR);
	    lseek(fd,comprsize,SEEK_CUR);
	    if ((genpurpose>>3)&1) lseek(fd,12,SEEK_CUR);
	    cpos = lseek(fd,0,SEEK_CUR);
	}

	// content.xml? Read 1024 bytes or less
	if (strcmp(buf,"content.xml")==0)
	{
	    memset(content,0,1024);
	    rpos=(epos-apos);
	    lseek(fd,apos,SEEK_SET);
	    read(fd,content,(rpos>1024) ? 1024: rpos);
	    contentsize = rpos;
	    if (contentsize>1024) contentsize=1024;
	    lseek(fd,cpos,SEEK_SET);
	    parsedc=1;
	}

	// META-INF/manifest.xml? 
	if (strcmp(buf,"META-INF/manifest.xml")==0)
	{
	    parsed=1;
	    rpos=(epos-apos);
	    lseek(fd,apos,SEEK_SET);
	    manifest = malloc(rpos+1);
	    read(fd,manifest,rpos);
	    lseek(fd,cpos,SEEK_SET);
	    manifest_u = malloc(ucomprsize+1);
	    z_stream strm;
	    int ret=0;
	    strm.zalloc = Z_NULL;
    	    strm.zfree = Z_NULL;
    	    strm.opaque = Z_NULL;
            strm.avail_in = comprsize;
            strm.avail_out = ucomprsize;

            strm.next_in = manifest;
            strm.next_out = manifest_u;

            ret = inflateInit2(&strm,-15);
            if (ret != Z_OK)
            {
        	goto out;
            }
    	    ret = inflate(&strm, Z_SYNC_FLUSH);
    	    if (ret == Z_DATA_ERROR) 
    	    {
    	        inflateEnd(&strm);
    	        //return hash_err;
    	        goto out;
    	    }
            if (ret == Z_NEED_DICT) 
	    {
        	inflateEnd(&strm);
        	//return hash_err;
        	goto out;
    	    }
    	    if (ret == Z_STREAM_ERROR) 
    	    {
        	inflateEnd(&strm);
        	goto out;
    	    }

    	    if  ((ret == Z_MEM_ERROR))
	    {
		inflateEnd(&strm);
        	//return hash_err;
        	goto out;
    	    }
    	    
	    tok1 = memmem(manifest_u,ucomprsize,"manifest:full-path=\"content.xml\"",strlen("manifest:full-path=\"content.xml\""));
	    if (!tok1) goto out;
	    tok2 = memmem(tok1,ucomprsize-(tok1-manifest_u),"</manifest:file-entry>",strlen("</manifest:file-entry>"));
	    if ((!tok1)||(!tok2)) goto out;
	    // Get checksum
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"checksum=\"",strlen("checksum=\""))==0)
		{
		    memset(s_checksum,0,64);
		    tok+=strlen("checksum=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_checksum[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    // Get checksum-type
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"checksum-type=\"",strlen("checksum-type=\""))==0)
		{
		    memset(s_checksum_type,0,64);
		    tok+=strlen("checksum-type=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_checksum_type[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    // Get iv
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"initialisation-vector=\"",strlen("initialisation-vector=\""))==0)
		{
		    memset(s_iv,0,64);
		    tok+=strlen("initialisation-vector=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_iv[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }
	    // Get salt
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"salt=\"",strlen("salt=\""))==0)
		{
		    memset(s_salt,0,64);
		    tok+=strlen("salt=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_salt[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    // Get algorithm-name
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"algorithm-name=\"",strlen("algorithm-name=\""))==0)
		{
		    memset(s_algo_name,0,64);
		    tok+=strlen("algorithm-name=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_algo_name[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    // Get iteration-count
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"iteration-count=\"",strlen("iteration-count=\""))==0)
		{
		    memset(s_iterations,0,64);
		    tok+=strlen("iteration-count=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_iterations[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    // Get key-size
	    tok = tok1;
	    while (tok<tok2)
	    {
		if (memcmp(tok,"key-size=\"",strlen("key-size=\""))==0)
		{
		    memset(s_key_size,0,64);
		    tok+=strlen("key-size=\"");
		    a=0;
		    while (tok[a]!='"')
		    {
			s_key_size[a]=tok[a];
			a++;
		    }
		    tok+=(a+1);
		}
		tok++;
	    }

	    if (strstr((char*)s_algo_name,"Blowfish CFB")) algorithm=0;
	    else if (strstr((char*)s_algo_name,"aes256-cbc")) algorithm=1;
	    else goto out;

	    if (!strstr((char*)s_checksum_type,"SHA1")==0) csalgorithm=0;
	    else if (!strstr((char*)s_checksum_type,"sha256")==0) csalgorithm=1;
	    else goto out;

	    keysize = atoi((const char *)s_key_size);
	    if (keysize==0)
	    {
		if (algorithm==0) keysize=128;
		else keysize=256;
	    }
	    if (keysize==20) keysize=128;
	    if (keysize==32) keysize=256;
	    iterations = atoi((const char *)s_iterations);
	    if (iterations==0) goto out;
	    b64_pton((const char*)s_salt,bsalt,16+4);
	    cs_size = (csalgorithm==0) ? 20 : 32;
	    b64_pton((const char*)s_checksum,checksum,cs_size+4);
	    b64_pton((const char*)s_iv,iv,(algorithm==0) ? 8+4 : 16+4);
	}
    }


    free(manifest);
    free(manifest_u);
    (void)hash_add_username(filename);
    (void)hash_add_hash("ODF file        ",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");
    return hash_ok;

    out:
    close(fd);
    if (manifest) free(manifest);
    if (manifest_u) free(manifest_u);
    return hash_err;
}




hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;
    char *buf[VECTORSIZE];
    char *buf2[VECTORSIZE];
    int lens[VECTORSIZE];
    unsigned char dec[1024];

    if ((algorithm==0)&&(csalgorithm==0))
    {
	BF_KEY bf_key;
	SHA_CTX ctx;
	unsigned char localiv[8];
	int pos;

	for (a=0;a<vectorsize;a++)
	{
	    buf[a]=alloca(64);
	    buf2[a]=alloca(64);
	    lens[a]=strlen(password[a]);
	}
	hash_sha1_slow(password,buf,lens);
	for (a=0;a<vectorsize;a++)
	{
	    hash_pbkdf2((char *)buf[a], (unsigned char *)bsalt, 16,iterations, keysize/8, (unsigned char*)buf2[a]);
	    pos=0;
	    memcpy(localiv,iv,8);
	    BF_set_key(&bf_key, keysize/8, (const unsigned char*)buf2[a]);
	    BF_cfb64_encrypt(content, dec, 1024, &bf_key, localiv, &pos, 0);
	    SHA1_Init(&ctx);
	    SHA1_Update(&ctx, dec, contentsize);
	    SHA1_Final((unsigned char*)buf[a], &ctx);
	}
	for (a=0;a<vectorsize;a++)
	{
	    if (memcmp(checksum,buf[a],cs_size)==0)
	    {
		*num=a;
		memcpy(salt2[a],"ODF file        \0\0",17);
		return hash_ok;
	    }
	}
    }
    else
    {
	SHA256_CTX ctx;
	AES_KEY akey;
	unsigned char localiv[16];

	for (a=0;a<vectorsize;a++)
	{
	    buf[a]=alloca(64);
	    buf2[a]=alloca(64);
	    lens[a]=strlen(password[a]);
	}
	hash_sha256_unicode(password,buf,lens);
	for (a=0;a<vectorsize;a++)
	{
	    hash_pbkdf2((char *)buf[a], (unsigned char *)bsalt, 16,iterations, keysize/8, (unsigned char*)buf2[a]);
	    memcpy(localiv,iv,16);
	    hash_aes_set_decrypt_key((const unsigned char*)buf2[a],keysize,&akey);
	    hash_aes_cbc_encrypt(content,dec,1024,&akey,localiv,AES_DECRYPT);
	    SHA256_Init(&ctx);
	    SHA256_Update(&ctx, dec, contentsize);
	    SHA256_Final((unsigned char*)buf[a], &ctx);
	}
	for (a=0;a<vectorsize;a++)
	{
	    if (memcmp(checksum,buf[a],cs_size)==0)
	    {
		*num=a;
		memcpy(salt2[a],"ODF file        \0\0",17);
		return hash_ok;
	    }
	}
    }



    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 32;
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
   return 5;
}
