/* rarcheck.c
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






static unsigned char header[40];
static unsigned int headerenc=0;
static unsigned short flags;
static unsigned char savedbuf[128];

int parse_rar(char *hashline, char *filename)
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
	//printf("Cannot open file %s\n", filename);
	return 0;
    }
    read(fd,signature,7);
    filepos = 7;

    if ( (signature[0]!=0x52) || (signature[1]!=0x61) || (signature[2]!=0x72) || 
	 (signature[3]!=0x21) || (signature[4]!=0x1a) || (signature[5]!=0x07))
    {
	//printf("Not a RAR3 archive: %s", filename);
	return 2;
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
	////printf("htype=%02x\n",htype);
	if (htype==0x74)
	{
	    /* flags (2) */
	    read(fd,&u161,2);
	    
	    filepos+=2;
	    issalt=0;
	    islarge=0;
	    if (!(u161 & 0x4))
	    {
		//printf("RAR archive %s is not password protected!\n",filename);
		return 3;
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
	    ////printf("Found file: %s packedsize: %d headersize=%d\n",encname,packedsize,headersize);

	    if (unpackedsize<(128*1024))
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
		//printf("Encrypted header found!\n%s","");
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
	//printf("No crackable archive files found, exiting...%s\n","");
	//exit(1);
	return 3;
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
	//printf("No header encryption, speed would suffer.%s\n","");
	//printf("Best file chosen to attack: %s\n",bestfile[c].filename);
	close(ofd);
	free(filebuf);
    }
    close(fd);

    return 1;
}


void main(int argc, char *argv[])
{
    int status;
    
    if (argc<2) {printf("ERROR - please provide archive file\n");exit(1);}
    status = parse_rar("",argv[1]);
    if (status==0) 
    {
	printf("0\nCannot open archive: %s\n\n\n",argv[1]);
	exit(1);
    }
    if (status==2) 
    {
	printf("0\nNot a RAR archive \n\n\n");
	exit(1);
    }

    if (status==3) 
    {
	printf("0\nRAR archive does not contain crackable password-protected files\n\n\n");
	exit(1);
    }
    if (headerenc==1)
    {
	printf("1\nRAR archive with header encryption\n1\n\n");
	exit(1);
    }
    if ((headerenc==0)&&(unpackedsize>128*1024))
    {
	printf("0\nRAR archive with no header encryption detected, no suitable files <1MB in archive\n0\n\n");
	exit(1);
    }
    if ((headerenc==0)&&(unpackedsize<=128*1024))
    {
	printf("1\nRAR archive with no header encryption detected, suitable file found:%s\n%d\n\n",encname,packedsize);
	exit(1);
    }


}
