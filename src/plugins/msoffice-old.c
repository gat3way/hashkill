/* msoffice-old.c
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
#include <fcntl.h>
#include <sys/types.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <openssl/rc4.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


/* File Buffer */
static char *buf;

/* Compound file binary format ones */
static int minifatsector;
static int minisectionstart;
static int minisectionsize;
static int *difat;
static int sectorsize;

/* Encryption-specific ones */
static int fileversion = 0;
static unsigned char docsalt[32];
static unsigned char verifier[32];
static unsigned char verifierhash[32];
static unsigned char verifierhashinput[64];
static unsigned char verifierhashvalue[72];
static int verifierhashsize;
static int spincount;
static int keybits;
unsigned int saltsize;
unsigned int type=0;

/* Office 2010/2013 */
static const unsigned char encryptedVerifierHashInputBlockKey[] = { 0xfe, 0xa7, 0xd2, 0x76, 0x3b, 0x4b, 0x9e, 0x79 };
static const unsigned char encryptedVerifierHashValueBlockKey[] = { 0xd7, 0xaa, 0x0f, 0x6d, 0x30, 0x61, 0x34, 0x4e };


char myfilename[255];
int vectorsize;

char * hash_plugin_summary(void)
{
    return("msoffice-old \tMS Office XP/2003 plugin");
}


char * hash_plugin_detailed(void)
{
    return("msoffice-old - Microsoft Office XP/2003 plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack password-protected MS Office files\n"
	    "Input should be a MS Office file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Microsoft Office 2000,XP,2003.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}



/* Get buffer+offset for sector */
char* get_buf_offset(int sector)
{
    return (buf+(sector+1)*sectorsize);
}

/* Get sector offset for sector */
int get_offset(int sector)
{
    return ((sector+1)*sectorsize);
}



/* Get FAT table for a given sector */
int* get_fat(int sector)
{
    char *fat=NULL;
    int difatn=0;

    if (sector<(sectorsize/4))
    {
        fat=get_buf_offset(difat[0]);
        return (int*)fat;
    }
    while ((!fat)&&(difatn<109))
    {
        if (sector>(((difatn+2)*sectorsize)/4)) difatn++;
        else fat=get_buf_offset(difat[difatn]);
    }
    return (int*)fat;
}


/* Get mini FAT table for a given minisector */
int* get_mtab(int sector)
{
    int *fat=NULL;
    char *mtab=NULL;
    int mtabn=0;
    int nextsector;

    nextsector = minifatsector;

    while (mtabn<sector)
    {
        mtabn++;
        if (sector>((mtabn*sectorsize)/4))
        {
            /* Get fat entry for next table; */
            fat = get_fat(nextsector);
            nextsector = fat[nextsector];
            mtabn++;
        }
    }
    mtab=get_buf_offset(nextsector);
    return (int*)mtab;
}


/* Get minisection sector nr per given mini sector offset */
int get_minisection_sector(int sector)
{
    int *fat=NULL;
    int sectn=0;
    int sectb=0;
    int nextsector;


    nextsector = minisectionstart;
    fat = get_fat(nextsector);
    sectn=0;
    while (sector>sectn)
    {
        sectn++;
        sectb++;
        if (sectb>=(sectorsize/64))
        {
            sectb=0;
            /* Get fat entry for next table; */
            fat = get_fat(nextsector);
            nextsector = fat[nextsector];
        }
    }
    return nextsector;
}


/* Get minisection offset */
int get_mini_offset(int sector)
{
    return ((sector*64)%(sectorsize));
}


char* read_stream_mini(int start, int size)
{
    char *lbuf=malloc(4);
    int lsize=0;
    int *mtab=NULL;     // current minitab
    int sector;

    sector=start;
    while (lsize<size)
    {
        lbuf = realloc(lbuf,lsize+64);
        memcpy(lbuf + lsize,get_buf_offset(get_minisection_sector(sector)) + get_mini_offset(sector), 64);
        lsize += 64;
        mtab = get_mtab(sector);
        sector = mtab[sector];
    }
    return lbuf;
}

/* Read stream from table - callee needs to free memory */
char* read_stream(int start, int size)
{
    char *lbuf=malloc(4);
    int lsize=0;
    int *fat=NULL;      // current minitab
    int sector;

    sector=start;

    while ((lsize)<size)
    {
        lbuf = realloc(lbuf,lsize+sectorsize);
        memcpy(lbuf + lsize,get_buf_offset(sector), sectorsize);
        lsize += sectorsize;
        fat = get_fat(sector);
        sector = fat[sector];
    }
    return lbuf;
}


hash_stat parse_xls(char *stream, int size)
{
    int index;
    int offset=0;
    int headersize;
    char *headerutf16;
    char *header;
    int a;

    while (offset<size-4)
    {
        if (((short)*(stream+offset))!=0x2f) offset+=4;
        else 
        {
            offset+=4;
            if (memcmp(stream+offset,"\x00\x00",2)==0)
            {
                //printf("XOR encryption not supported");
                return hash_err;
            }
            else if (memcmp(stream+offset,"\x01\x00\x01\x00\x01\x00",6)==0)
            {
                //printf("RC4 encryption (40bit)\n");
                memcpy(docsalt,stream+offset+6,16);
                memcpy(verifier,stream+offset+22,16);
                memcpy(verifierhash,stream+offset+38,16);
                verifierhashsize=16;
                return hash_err;
            }
            else if ((memcmp(stream+offset,"\x01\x00\x02\x00",4)==0)||(memcmp(stream+offset,"\x01\x00\x03\x00",4)==0))
            {
                //printf("RC4 part (CryptoAPI)\n");
                offset+=10;
                memcpy(&headersize,stream+offset,4);
                //printf("headersize=%d\n",headersize);
                offset+=20;
                memcpy(&keybits,stream+offset,4);
                //printf("keybits=%d\n",keybits);
                offset+=16;
                headersize-=32;
                headerutf16=alloca(headersize);
                memcpy(headerutf16,stream+offset,headersize);
                header=alloca(headersize/2);
                for (a=0;a<headersize;a+=2) header[a/2]=headerutf16[a];
    		if (strstr(header,"trong")) type=1;
    		else type=0;
                //printf("header: %s\n",header);
                offset+=headersize;
                memcpy(&saltsize,stream+offset,4);
                offset+=4;
                //printf("saltsize=%d\n",saltsize);
                memcpy(docsalt,stream+offset,16);
                offset+=16;
                memcpy(verifier,stream+offset,16);
                offset+=16;
                memcpy(&verifierhashsize,stream+offset,4);
                offset+=4;
                //printf("verifierhashsize=%d\n",verifierhashsize);
                memcpy(verifierhash,stream+offset,20);
                return hash_ok;
            }
        }
    }
}


hash_stat parse_doc(char *stream, int size)
{
    int index;
    int offset=0;
    int headersize;
    char *headerutf16;
    char *header;
    int a;

    /* 40bit RC4 */
    if ((((short)*(stream))==1)||(((short)*(stream+2))==1))
    {
        //printf("40bit RC4\n");
        memcpy(docsalt,stream+4,16);
        memcpy(verifier,stream+20,16);
        memcpy(verifierhash,stream+36,16);
        verifierhashsize=16;
        return hash_err;
    }
    else if ((((short)*(stream))>=2)||(((short)*(stream+2))==2))
    {
        offset+=8;
        memcpy(&headersize,stream+offset,4);
        //printf("headersize=%d\n",headersize);
        offset+=20;
        memcpy(&keybits,stream+offset,4);
        //printf("keybits=%d\n",keybits);
        offset+=16;
        headersize-=32;
        headerutf16=alloca(headersize);
        memcpy(headerutf16,stream+offset,headersize);
        header=alloca(headersize/2);
        for (a=0;a<headersize;a+=2) header[a/2]=headerutf16[a];
        if (strstr(header,"trong")) type=1;
        else type=0;
        //printf("header: %s\n",header);
        offset+=headersize;
        memcpy(&saltsize,stream+offset,4);
        //printf("saltsize=%d\n",saltsize);
        offset+=4;
        memcpy(docsalt,stream+offset,16);
        offset+=16;
        memcpy(verifier,stream+offset,16);
        offset+=16;
        memcpy(&verifierhashsize,stream+offset,4);
        //printf("verifierhashsize=%d\n",saltsize);
        offset+=4;
        memcpy(verifierhash,stream+offset,20);
        return hash_ok;
    }
    else
    {
        //printf("WTF is that word document?!?\n");
        return hash_err;
    }
}






hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    int fsize;
    int index=0;
    int dirsector;
    char utf16[64];
    char orig[64];
    int datasector,datasize;
    int ministreamcutoff;
    int a;
    char *stream=NULL;
    char *token,*token1;

    fd=open(filename,O_RDONLY);
    if (!fd)
    {
	return hash_err;
    }
    fsize=lseek(fd,0,SEEK_END);
    lseek(fd,0,SEEK_SET);
    buf=malloc(fsize+1);
    read(fd,buf,fsize);
    if (memcmp(buf,"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1",8)!=0) 
    {
        //printf("No header signature found!\n");
        free(buf);
        return hash_err;
    }
    index+=24;
    if (memcmp(buf+index,"\x3e\x00",2)!=0)
    {
        //printf("Minor version wrong!\n");
        free(buf);
        return hash_err;
    }
    index+=2;
    if ((memcmp(buf+index,"\x03\x00",2)!=0)&&(memcmp(buf+index,"\x04\x00",2)!=0))
    {
        //printf("Major version wrong!\n");
        free(buf);
        return hash_err;
    }
    else
    {
        if ((short)*(buf+index)==3) sectorsize=512;
        else if ((short)*(buf+index)==4) sectorsize=4096;
        else 
        {
            //printf("Bad sector size!\n");
            free(buf);
            return hash_err;
        }
    }

    index+=22;
    memcpy(&dirsector,(int*)(buf+index),4);
    dirsector+=1;
    dirsector*=sectorsize;
    index+=8;
    memcpy(&ministreamcutoff,(int*)(buf+index),4);
    memcpy(&minifatsector,(int*)(buf+index+4),4);
    difat=(int *)(buf+index+20);


    index=dirsector;
    orig[0]='M';
    while ((orig[0]!=0)&&((strcmp(orig,"Workbook")!=0)||(strcmp(orig,"1Table")!=0)))
    {
        memcpy(utf16,buf+index,64);
        for (a=0;a<64;a+=2) orig[a/2]=utf16[a];
        memcpy(&datasector,buf+index+116,4);
        //printf("%s \n",orig);
        if (strcmp(orig,"Root Entry")==0)
        {
            minisectionstart=datasector;
            memcpy(&minisectionsize,buf+index+120,4);
        }
        if (strcmp(orig,"Workbook")==0)
        {
            memcpy(&datasize,buf+index+120,4);
            stream = read_stream(datasector,datasize);
            if (hash_err == parse_xls(stream,datasize))
            {
        	free(stream);
        	return hash_err;
    	    }
            break;
        }
        if (strcmp(orig,"1Table")==0)
        {
            memcpy(&datasize,buf+index+120,4);
            stream = read_stream(datasector,datasize);
            if (hash_err == parse_doc(stream,datasize))
            {
        	free(stream);
        	return hash_err;
    	    }
            break;
        }
        index+=128;
    }

    if (!stream)
    {
	//printf("No stream found!\n");
	return hash_err;
    }


    close(fd);
    free(stream);
    free(buf);

    (void)hash_add_username(filename);
    (void)hash_add_hash("MS Office document  \0",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2(" ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int smth,a,b;
    unsigned char *ibuf[VECTORSIZE];
    unsigned char *hbuf[VECTORSIZE];
    unsigned char *obuf[VECTORSIZE];
    unsigned int lens[VECTORSIZE];
    unsigned char *derivedkey[VECTORSIZE];
    unsigned char *decryptedverifier[VECTORSIZE];
    unsigned char *decryptedverifierhash[VECTORSIZE];
    unsigned char passutf16[64];
    char iv[16];

/*
    if ((verifierhashsize==16)&&(type==0))
    {
        RC4_KEY key;

        for (a=0;a<vectorsize;a++)
        {
            ibuf[a]=alloca(128);
            hbuf[a]=alloca(128);
            bzero(passutf16,64);
            for (b=0;b<strlen(password[a]);b++) 
            {
                passutf16[b*2]=password[a][b];
                passutf16[b*2+1]=0;
            }
            bzero(ibuf[a],128);
            memcpy(ibuf[a],passutf16,strlen(password[a])*2);
            lens[a]=strlen(password[a])*2;
        }
	hash_md5_unicode_slow(ibuf,hbuf, lens);
	for (a=0;a<vectorsize;a++)
        {
	    obuf[a]=alloca(21*16);
	    lens[a]=21*16;
	    for (b=0;b<16;b++)
	    {
		memcpy(obuf[a] + (b*21), hbuf[a], 5);
		memcpy(obuf[a] + (b*21) + 5, docsalt, 16);
	    }
	}
	hash_md5_unicode_slow(obuf,hbuf, lens);
	for (a=0;a<vectorsize;a++)
        {
	    memcpy(ibuf[a],hbuf[a],5);
	    bzero(ibuf[a]+5,11);
	    lens[a]=9;
	}
	hash_md5_unicode_slow(ibuf,hbuf,lens);
	for (a=0;a<vectorsize;a++)
        {
	    RC4_set_key(&key, 16, hbuf[a]);
	    RC4(&key, 16, verifier, obuf[a]);
	    RC4(&key, 16, verifierhash, obuf[a]+16);
	    lens[a]=16;
	}
	hash_md5_unicode_slow(obuf,hbuf,lens);

	for (a=0;a<vectorsize;a++)
	{
    	    if (memcmp(hbuf[a],obuf[a]+16,16)==0)
    	    {
		memcpy(salt2[a],"MS Office document  \0", 21);
		*num=a;
		return hash_ok;
	    }
	}
    }
    else
    */
    if ((type==1)&&(verifierhashsize==16))
    {
        RC4_KEY key;
        char *decryptedverifier[20];
        char *decryptedverifierhash[20];

        for (a=0;a<vectorsize;a++)
        {
            ibuf[a]=alloca(128);
            hbuf[a]=alloca(128);
            bzero(passutf16,64);
            for (b=0;b<strlen(password[a]);b++) 
            {
                passutf16[b*2]=password[a][b];
                passutf16[b*2+1]=0;
            }
            bzero(ibuf[a],128);
            memcpy(ibuf[a],docsalt,saltsize);
            memcpy(ibuf[a]+saltsize,passutf16,strlen(password[a])*2);
            lens[a]=saltsize+strlen(password[a])*2;
        }
	hash_md5_unicode_slow(ibuf,hbuf, lens);
        for (a=0;a<vectorsize;a++)
        {
            memset(hbuf[a]+16,0,32);
            lens[a]=20;
	}
	hash_md5_unicode(hbuf,ibuf, lens);
	for (a=0;a<vectorsize;a++)
        {
	    decryptedverifier[a]=alloca(64);
	    bzero(decryptedverifier[a],64);
	    decryptedverifierhash[a]=alloca(20);
	    hbuf[a]=alloca(20);
	    if (type==0) memset(ibuf[a]+5,0,11);
	    RC4_set_key(&key, 16, ibuf[a]);
	    RC4(&key, 16, verifier, decryptedverifier[a]);
	    RC4(&key, 20, verifierhash, decryptedverifierhash[a]);
	    lens[a]=16;
	}
	hash_md5_unicode(decryptedverifier,hbuf,lens);
	for (a=0;a<vectorsize;a++)
	{
    	    if (memcmp(hbuf[a],decryptedverifierhash[a],16)==0)
    	    {
		memcpy(salt2[a],"MS Office document  \0", 21);
		*num=a;
		return hash_ok;
	    }
	}
    }
    else if (verifierhashsize==20)
    {
        RC4_KEY key;
        char *decryptedverifier[20];
        char *decryptedverifierhash[20];

        for (a=0;a<vectorsize;a++)
        {
            ibuf[a]=alloca(128);
            hbuf[a]=alloca(128);
            bzero(passutf16,64);
            for (b=0;b<strlen(password[a]);b++) 
            {
                passutf16[b*2]=password[a][b];
                passutf16[b*2+1]=0;
            }
            bzero(ibuf[a],128);
            memcpy(ibuf[a],docsalt,saltsize);
            memcpy(ibuf[a]+saltsize,passutf16,strlen(password[a])*2);
            lens[a]=saltsize+strlen(password[a])*2;
        }
	hash_sha1_slow(ibuf,hbuf, lens);
        for (a=0;a<vectorsize;a++)
        {
            memset(hbuf[a]+20,0,32);
            lens[a]=24;
	}
	hash_sha1_unicode(hbuf,ibuf, lens);
	for (a=0;a<vectorsize;a++)
        {
	    decryptedverifier[a]=alloca(64);
	    bzero(decryptedverifier[a],64);
	    decryptedverifierhash[a]=alloca(20);
	    hbuf[a]=alloca(20);
	    if (type==0) memset(ibuf[a]+5,0,11);
	    RC4_set_key(&key, 16, ibuf[a]);
	    RC4(&key, 16, verifier, decryptedverifier[a]);
	    RC4(&key, 20, verifierhash, decryptedverifierhash[a]);
	    lens[a]=16;
	}

	//hash_sha1_slow(decryptedverifier,hbuf,lens);
	hash_sha1_unicode(decryptedverifier,hbuf,lens);
	for (a=0;a<vectorsize;a++)
	{
    	    if (memcmp(hbuf[a],decryptedverifierhash[a],16)==0)
    	    {
		memcpy(salt2[a],"MS Office document  \0", 21);
		*num=a;
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
    return 2;
}
