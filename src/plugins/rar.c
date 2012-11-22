/*
   All copyrights to RAR are exclusively
   owned by the author - Alexander Roshal.

   This code may not be used to develop a RAR (WinRAR) compatible archiver.
*/


/* rar.c
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

/*
                    unrar Exception

In addition, as a special exception, the author gives permission to
link the code of his release of hashkill with Rarlabs' "unrar"
library (or with modified versions of it that use the same license
as the "unrar" library), and distribute the linked executables. You
must obey the GNU General Public License in all respects for all of
the code used other than "unrar". If you modify this file, you may
extend this exception to your version of the file, but you are not
obligated to do so. If you do not wish to do so, delete this
exception statement from your version.
*/



#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <fcntl.h>
#include <sys/types.h>
#include <wchar.h>
#include <stdlib.h>
#include <openssl/sha.h>
#include <openssl/aes.h>
#include <openssl/ssl.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"
#include "unrar.h"
#define BYTESWAP32(n) ( \
        (((n)&0x000000ff) << 24) | \
        (((n)&0x0000ff00) << 8 ) | \
        (((n)&0x00ff0000) >> 8 ) | \
        (((n)&0xff000000) >> 24) )




typedef struct bestfile_s
{
    unsigned int packedsize;
    unsigned int filepos;
    unsigned char filename[255];
} bestfile_t;
static bestfile_t bestfile[1024];


static char myfilename[255];
static long filepos;
static unsigned int packedsize;
static unsigned int unpackedsize;
static uint64_t packedsize64;
static uint64_t unpackedsize64;
static unsigned int filecrc;

static char salt[8];
static int issalt;
static int islarge;
static unsigned short namesize;
static char encname[256];


char * hash_plugin_summary(void)
{
    return("rar \t\tRAR3 passwords plugin");
}


char * hash_plugin_detailed(void)
{
    return("rar - RAR3 passwords plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack RAR archives passwords\n"
	    "Input should be a passworded RAR file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "WinRAR\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}




static unsigned char header[40];
static unsigned int headerenc=0;
static unsigned short flags;
static unsigned char savedbuf[128];

hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd, ret,a,b,c;
    char buf[4096];
    unsigned int u321;
    unsigned short u161;
    unsigned char u81,htype;
    char signature[7];
    char *filebuf;
    unsigned short headersize;
    int goodtogo=0,best=0;

    issalt = islarge = 0;
    strcpy(myfilename, filename);

    fd = open(filename, O_RDONLY);
    if (fd<1)
    {
	if (!hashline) elog("Cannot open file %s\n", filename);
	return hash_err;
    }
    read(fd,signature,7);
    filepos = 7;

    if ( (signature[0]!=0x52) || (signature[1]!=0x61) || (signature[2]!=0x72) || 
	 (signature[3]!=0x21) || (signature[4]!=0x1a) || (signature[5]!=0x07))
    {
	if (!hashline) elog("Not a RAR3 archive: %s", filename);
	return hash_err;
    }
    ret=0;
    while (ret>=0)
    {
	/* header CRC (2) */
	read(fd, &u161,2);
	flags=u161;
	filepos+=2;
	/* header type (1) */
	read(fd, &htype,1);
	filepos++;
	//printf("htype=%02x\n",htype);
	if (htype==0x74)
	{
	    /* flags (2) */
	    read(fd,&u161,2);
	    
	    filepos+=2;
	    issalt=0;
	    islarge=0;
	    if (!(u161 & 0x4))
	    {
		if (!hashline) elog("RAR archive %s is not password protected!\n",filename);
		//return hash_err;
	    }
	    if ((u161 & 0x400))
	    {
		issalt = 1;
	    }
	    if ((u161 & 0x100))
	    {
		islarge = 1;
	    }
	    /* header size (2) */
	    read(fd,&u161,2);
	    filepos+=u161-8;
	    headersize=u161;
	    read(fd,&packedsize,4);
	    read(fd,&unpackedsize,4);
	    read(fd,&u81,1);
	    read(fd,&filecrc,4);
	    /* read time,ver,method = 6 bytes */
	    read(fd, buf, 6);
	    /* read namesize */
	    read(fd, &namesize,2);
	    /* read attr */
	    read(fd, &u321, 4);
	    /* read 64-bit size if used */
	    if (islarge)
	    {
		read(fd,&packedsize64,8);
		read(fd,&unpackedsize64,8);
	    }
	    read(fd, encname, namesize);

	    if (issalt)
	    {
		read(fd, salt, 8);
	    }
	    //printf("Found file: %s packedsize: %d headersize=%d\n",encname,packedsize,headersize);

	    if (packedsize<(32*1024*1024))
	    {
		lseek(fd,headersize-((issalt*8)+(islarge)*16+32+namesize),SEEK_CUR);
		filepos = lseek(fd,0,SEEK_CUR);
		bestfile[best].filepos = lseek(fd,0,SEEK_CUR);
		bestfile[best].packedsize=packedsize;
		strcpy((char *)bestfile[best].filename,encname);
		best++;
		lseek(fd,packedsize,SEEK_CUR);
	    }
	    else 
	    {
		lseek(fd,headersize-((issalt*8)+(islarge)*16+32+namesize),SEEK_CUR);
		lseek(fd,packedsize,SEEK_CUR);
	    }
	    
	}
	else if (htype==0x73)
	{
	    read(fd,&u161,2);
	    filepos+=2;
	    
	    if (((u161>>7)&255)!=0)
	    {
		hlog("Encrypted header found!\n%s","");
		read(fd,&u161,2);
		read(fd,&u161,2);
		read(fd,&u321,4);
		filepos+=8;
		/* Read in the salt */
		read(fd, salt, 8);
		filepos+=8;
		read(fd, header, 32);
		/* Better idea: Marc Bevand's one :) */
		lseek(fd,-24,SEEK_END);
		read(fd,salt,8);
		read(fd,header,16);
		headerenc=1;
		goodtogo=1;
		goto out;
	    }
	    read(fd,&u161,2);
	    read(fd,&u161,2);
	    read(fd,&u321,4);
	    filepos+=8;
	}
	else 
	{
	    ret=-1;
	}
    }
    out:
    if ((goodtogo==0)&&(best<1))
    {
	hlog("No crackable archive files found, exiting...%s\n","");
	return hash_err;
    }

    if (headerenc==0)
    {
	b=0xfffffff;
	c=0;
	for (a=0;a<best;a++) if (b>bestfile[a].packedsize) {b=bestfile[a].packedsize;c=a;}
	lseek(fd,bestfile[c].filepos,SEEK_SET);
	packedsize=bestfile[c].packedsize;

	filebuf = malloc(packedsize);
	read(fd,filebuf,packedsize);
	int ofd=open("/dev/shm/outfile",O_WRONLY|O_CREAT,0644);
	write(ofd,filebuf,packedsize);
	memcpy(savedbuf,filebuf,128);
	if (!hashline) hlog("Best file chosen to attack: %s\n",bestfile[c].filename);
	close(ofd);
	free(filebuf);
    }
    close(fd);


    (void)hash_add_username(filename);
    (void)hash_add_hash("RAR file          ",0);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("                  ");

    return hash_ok;
}



hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int fd;
    unsigned char *buf;
    int a,b,sz,i,j;
    SHA_CTX ctx,newctx;
    AES_KEY key;
    unsigned char pswn[3];
    unsigned char iv[16];
    unsigned char iv1[16];
    unsigned int digest[5];
    unsigned char digest2[16];
    unsigned char plain[32];
    unpack_data_t data;

    if (headerenc==1)
    {
	for (a=0;a<vectorsize;a++)
	{
	    sz=(strlen(password[a])*2);
	    buf=alloca(sz+11);
	    for (b=0;b<strlen(password[a]);b++)
	    {
		buf[(b*2)]=password[a][b];
		buf[(b*2)+1]=0;
	    }
	    memcpy(buf+sz,salt,8);
	    SHA1_Init(&ctx);
	    for (b=0;b<0x40000;b++)
	    {
		pswn[0]=b;
		pswn[1]=b>>8;
		pswn[2]=b>>16;
		SHA1_Update(&ctx,buf,sz+8);
		SHA1_Update(&ctx,pswn,3);
		if ((b % (0x40000 / 16))==0)
		{
		    newctx=ctx;
		    SHA1_Final((unsigned char *)digest,&newctx);
		    digest[4] = BYTESWAP32(digest[4]);
		    iv[b/(0x40000 / 16)]=digest[4];
		}
	    }
	    SHA1_Final((unsigned char *)digest,&ctx);
    	    for (j = 0; j < 5; j++) digest[j] = BYTESWAP32(digest[j]);
    	    for (i = 0; i < 4; i++)
    		for (j = 0; j < 4; j++)
        	    digest2[i * 4 + j] = (unsigned char) (digest[i] >> (j * 8));
	    hash_aes_set_decrypt_key(digest2, 16*8, &key);
	    hash_aes_cbc_encrypt(header, plain, 16, &key, iv, AES_DECRYPT);
	
	    if (memcmp(plain, "\xc4\x3d\x7b\x00\x40\x07\x00", 7)==0)
	    {
		*num=a;
		return hash_ok;
	    }
	}
    }
    /* No header encryption */
    else
    {
	for (a=0;a<vectorsize;a++)
	{
	    if (strlen(password[a])<1) continue;
	    sz=(strlen(password[a])*2);
	    buf=alloca(sz+11);
	    for (b=0;b<strlen(password[a]);b++)
	    {
		buf[(b*2)]=password[a][b];
		buf[(b*2)+1]=0;
	    }

	    memcpy(buf+sz,salt,8);
	    SHA1_Init(&ctx);
	    for (b=0;b<0x40000;b++)
	    {
		pswn[0]=b;
		pswn[1]=b>>8;
		pswn[2]=b>>16;
		SHA1_Update(&ctx,buf,sz+8);
		SHA1_Update(&ctx,pswn,3);
		if ((b % (0x40000 / 16))==0)
		{
		    newctx=ctx;
		    SHA1_Final((unsigned char *)digest,&newctx);
		    digest[4] = BYTESWAP32(digest[4]);
		    iv[b/(0x40000 / 16)]=digest[4];
		}
	    }
	    SHA1_Final((unsigned char *)digest,&ctx);
    	    for (j = 0; j < 5; j++) digest[j] = BYTESWAP32(digest[j]);
    	    for (i = 0; i < 4; i++)
    		for (j = 0; j < 4; j++)
        	    digest2[i * 4 + j] = (unsigned char) (digest[i] >> (j * 8));

	    fd = open("/dev/shm/outfile",O_RDONLY);
	    memcpy(iv1,iv,16);

	    bzero(&data,sizeof(data));
	    memcpy(iv1,iv,16);

	    data.unp_crc=0xffffffff;
	    ppm_constructor(&data.ppm_data);
    	    data.old_filter_lengths = NULL;
    	    data.PrgStack.array = data.Filters.array = NULL;
    	    data.PrgStack.num_items = data.Filters.num_items = 0;
    	    data.pack_size = packedsize;
    	    //data.ofd=fd1;
	    if (rar_unpack(digest2,iv1,fd,29,1,&data)>=1) 
	    {
	        if ((data.unp_crc^0xffffffff)==filecrc)
	        {
		    close(fd);
		    *num=a;
		    return hash_ok;
		}
	    }
	    ppm_destructor(&data.ppm_data);
	    close(fd);
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
    return 1;
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
    return 8;
}

