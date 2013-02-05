/* msoffice.c
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

/* Office 2010/2013 */
static const unsigned char encryptedVerifierHashInputBlockKey[] = { 0xfe, 0xa7, 0xd2, 0x76, 0x3b, 0x4b, 0x9e, 0x79 };
static const unsigned char encryptedVerifierHashValueBlockKey[] = { 0xd7, 0xaa, 0x0f, 0x6d, 0x30, 0x61, 0x34, 0x4e };


char myfilename[255];
int vectorsize;

char * hash_plugin_summary(void)
{
    return("msoffice \tMS Office 2007/2010/2013 plugin");
}


char * hash_plugin_detailed(void)
{
    return("msoffice - Microsoft Office 2007/2010/2013 plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack password-protected MSOffice files\n"
	    "Input should be a MS Office file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Microsoft Office: 2007, 2010, 2013.\n"
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



/* 
   Read stream from mini table - callee needs to free memory 
   TODO: what if stream is in FAT? Until now I haven't seen a case
   like that with EncryptionStream (it's usually around 1KB, far below 4KB)
   Anyway, this should be handled properly some day.
*/
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
    while ((orig[0]!=0)&&(strcmp(orig,"EncryptionInfo")!=0))
    {
        memcpy(utf16,buf+index,64);
        for (a=0;a<64;a+=2) orig[a/2]=utf16[a];
        memcpy(&datasector,buf+index+116,4);
        if (strcmp(orig,"Root Entry")==0)
        {
            minisectionstart=datasector;
            memcpy(&minisectionsize,buf+index+120,4);
        }
        if (strcmp(orig,"EncryptionInfo")==0)
        {
            memcpy(&datasize,buf+index+120,4);
            stream = read_stream_mini(datasector,datasize);
        }
        index+=128;
    }

    if (!stream)
    {
	//printf("No stream found!\n");
	return hash_err;
    }

    index = 0;

    /* Now parse the encryption stream */
    /* The office 2007 case */
    if ((((short)*(stream))==0x03)&&(((short)*(stream+2))==0x02))
    {
        unsigned int headerlen;
        unsigned int skipflags;
        unsigned int extrasize;
        unsigned int algid;
        unsigned int alghashid;
        unsigned int keysize;
        unsigned int providertype;

        fileversion=2007;
        //printf("MSOffice 2007 format!\n");
        index+=4;
        if (((unsigned int)(*(stream+index))) == 16)
        {
            //printf("External provider not supported!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        index+=4;
        memcpy(&headerlen,stream+index,4);
        //printf("Header length: %d\n",headerlen);
        index+=4;
        memcpy(&skipflags,stream+index,4);
        index+=4;
        memcpy(&extrasize,stream+index,4);
        index+=4;
        memcpy(&algid,stream+index,4);
        //printf("Algo ID: %08x\n",algid);
        index+=4;
        memcpy(&alghashid,stream+index,4);
        //printf("Hash algo ID: %08x\n",alghashid);
        index+=4;
        memcpy(&keysize,stream+index,4);
        //printf("Keysize: %d\n",keysize);
        keybits=keysize;
        index+=4;
        memcpy(&providertype,stream+index,4);
        //printf("Providertype: %08x\n",providertype);
        index+=8;
        headerlen-=28;
        index+=headerlen;
        memcpy(&saltsize,stream+index,4);
        //printf("Saltsize: %d\n",saltsize);
        index+=4;
        memcpy(docsalt,stream+index,saltsize);
        index+=saltsize;
        memcpy(verifier,stream+index,16);
        index+=16;
        memcpy(&verifierhashsize,stream+index,4);
        //printf("Verifier hash size: %d\n",verifierhashsize);
        index+=4;
        /* Using RC4 encryption? */
        if (providertype == 1) memcpy(verifierhash,stream+index,20);
        else memcpy(verifierhash,stream+index,32);
    }
    else if ((((short)*(stream))==0x04)&&(((short)*(stream+2))==0x04))
    {
        char *startptr;

        fileversion=2010;
        //printf("MSOffice 2010/2013 format!\n");
        index+=4;
        //printf("Provider: %d\n",((unsigned int)(*(stream+index))));
        if (((unsigned int)(*(stream+index))) == 16)
        {
            //printf("External provider not supported!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        index+=4;

        //printf("%s\n",stream+index);
        /* clumsy XML parsing, better one would use libxml2 */
        if (strncmp(stream+index,"<?xml version=\"1.0\" ",20)!=0)
        {
            //printf("Expected XML data, got garbage!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        startptr = memmem(stream,strlen(stream+8),"<p:encryptedKey",15);
        if (!startptr)
        {
            //printf("no encryptedKey parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        startptr += 15;

        /* Get spinCount */
        token = memmem(startptr,strlen(stream+8),"spinCount=\"",11);
        if (!token)
        {
            //printf("no spinCount parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 11;
        a=0;
        token1=malloc(16);
        bzero(token1,16);
        while ((token[a]!='"')&&(a<16))
        {
            token1[a]=token[a];
            a++;
        }
        spincount=atoi(token1);
        //printf("spinCount=%d\n",spincount);
        free(token1);

        /* Get keyBits */
        token = memmem(startptr,strlen(stream+8),"keyBits=\"",9);
        if (!token)
        {
            //printf("no keyBits parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 9;
        a=0;
        token1=malloc(16);
        bzero(token1,16);
        while ((token[a]!='"')&&(a<16))
        {
            token1[a]=token[a];
            a++;
        }
        keybits=atoi(token1);
        //printf("keyBits=%d\n",keybits);
        free(token1);

        /* Get saltSize */
        token = memmem(startptr,strlen(stream+8),"saltSize=\"",10);
        if (!token)
        {
            //printf("no saltSize parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 10;
        a=0;
        token1=malloc(16);
        bzero(token1,16);
        while ((token[a]!='"')&&(a<16))
        {
            token1[a]=token[a];
            a++;
        }
        saltsize=atoi(token1);
        //printf("saltsize=%d\n",saltsize);
        free(token1);

        /* Get hashAlgorithm */
        token = memmem(startptr,strlen(stream+8),"hashAlgorithm=\"",15);
        if (!token)
        {
            //printf("no hashAlgorithm parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 15;
        a=0;
        token1=malloc(16);
        bzero(token1,16);
        while ((token[a]!='"')&&(a<16))
        {
            token1[a]=token[a];
            a++;
        }
        //printf("hashAlgorithm=%s\n",token1);
        if (strcmp(token1,"SHA1") == 0) fileversion = 2010;
        else if (strcmp(token1,"SHA512") == 0) fileversion = 2013;
        else 
        {
            //printf("Unknown hash algorithm used!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        free(token1);

        /* Get saltValue */
        token = memmem(startptr,strlen(stream+8),"saltValue=\"",11);
        if (!token)
        {
            //printf("no saltValue parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 11;
        a=0;
        token1=malloc(64);
        bzero(token1,64);
        while ((token[a]!='"')&&(a<64))
        {
            token1[a]=token[a];
            a++;
        }
        b64_pton(token1,docsalt,saltsize+4);
        //printf("saltValue=");
        free(token1);

        /* Get encryptedVerifierHashInput */
        token = memmem(startptr,strlen(stream+8),"encryptedVerifierHashInput=\"",28);
        if (!token)
        {
            //printf("no encryptedVerifierHashInput parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 28;
        a=0;
        token1=malloc(64);
        bzero(token1,64);
        while ((token[a]!='"')&&(a<64))
        {
            token1[a]=token[a];
            a++;
        }
        b64_pton(token1,verifierhashinput,32+4);
        //printf("encryptedVerifierHashInput=");
        free(token1);

        /* Get encryptedVerifierHashValue */
        token = memmem(startptr,strlen(stream+8),"encryptedVerifierHashValue=\"",28);
        if (!token)
        {
            //printf("no encryptedVerifierHashValue parameters in XML!\n");
            free(buf);
            free(stream);
            return hash_err;
        }
        token += 28;
        a=0;
        token1=malloc(64);
        bzero(token1,64);
        while ((token[a]!='"')&&(a<64))
        {
            token1[a]=token[a];
            a++;
        }
        b64_pton(token1,verifierhashvalue,64+4);
        //printf("encryptedVerifierHashValue=");
        free(token1);
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

    if (fileversion == 2007)
    {
	unsigned char *ibuf[VECTORSIZE];
	unsigned char *hbuf[VECTORSIZE];
	unsigned int lens[VECTORSIZE];
	unsigned char *derivedkey[VECTORSIZE];
	unsigned char *decryptedverifier[VECTORSIZE];
	unsigned char *decryptedverifierhash[VECTORSIZE];
	unsigned char passutf16[64];
	AES_KEY aeskey;
	char iv[16];

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
	hash_sha1_slow(ibuf,hbuf,lens);

	for (a=0;a<vectorsize;a++) memcpy(ibuf[a],hbuf[a],20);

	for (b=0;b<50000;b++)
	{
	    for (a=0;a<vectorsize;a++)
	    {
		memcpy(hbuf[a],&b,4);
		memcpy(hbuf[a]+4,ibuf[a],24);
		bzero(hbuf[a]+24,32);
		lens[a]=24;
	    }
	    hash_sha1_unicode(hbuf,ibuf,lens);
	}

	for (a=0;a<vectorsize;a++)
	{
	    memset(&ibuf[a][20],0,4);
	    memcpy(hbuf[a],ibuf[a],24);
	    lens[a]=24;
	}
	hash_sha1_slow(hbuf,ibuf,lens);

	for (b=0;b<vectorsize;b++)
	{
	    derivedkey[b]=alloca(64);
	    for (a=0;a<64;a++) derivedkey[b][a] = (a < 20 ? 0x36 ^ ibuf[b][a] : 0x36);
	    lens[b]=64;
	}
	hash_sha1_slow(derivedkey,hbuf,lens);
	// hbuf now holds the key 
	for (a=0;a<vectorsize;a++)
	{
	    decryptedverifier[a]=alloca(16);
	    decryptedverifierhash[a]=alloca(32);
	    memset(&aeskey,0,sizeof(AES_KEY));
	    memset(iv,0,16);
	    hash_aes_set_decrypt_key(hbuf[a], 128, &aeskey);
	    hash_aes_cbc_encrypt(verifier,decryptedverifier[a],16,&aeskey,iv,AES_DECRYPT);
	    memset(&aeskey,0,sizeof(AES_KEY));
	    memset(iv,0,16);
	    hash_aes_set_decrypt_key(hbuf[a], 128, &aeskey);
	    hash_aes_cbc_encrypt(verifierhash,decryptedverifierhash[a],16,&aeskey,iv,AES_DECRYPT);
	    memset(&aeskey,0,sizeof(AES_KEY));
	    memset(iv,0,16);
	    hash_aes_set_decrypt_key(hbuf[a], 128, &aeskey);
	    hash_aes_cbc_encrypt(verifierhash+16,decryptedverifierhash[a]+16,16,&aeskey,iv,AES_DECRYPT);
	    lens[a]=16;
	}
	hash_sha1_slow(decryptedverifier,hbuf,lens);

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
    else if (fileversion == 2010)
    {
	unsigned char *ibuf[VECTORSIZE];
	unsigned char *hbuf[VECTORSIZE];
	unsigned char *sbuf[VECTORSIZE];
	unsigned char *tbuf[VECTORSIZE];
	unsigned int lens[VECTORSIZE];
	unsigned char passutf16[64];
	unsigned char *decryptedhashinput[VECTORSIZE];
	unsigned char *decryptedhashvalue[VECTORSIZE];
	AES_KEY aeskey;
	char iv[16];

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
	hash_sha1_slow(ibuf,hbuf,lens);
	for (a=0;a<vectorsize;a++) memcpy(ibuf[a],hbuf[a],20);

	for (b=0;b<spincount;b++)
	{
	    for (a=0;a<vectorsize;a++)
	    {
		memcpy(hbuf[a],&b,4);
		memcpy(hbuf[a]+4,ibuf[a],24);
		bzero(hbuf[a]+24,32);
		lens[a]=24;
	    }
	    hash_sha1_unicode(hbuf,ibuf,lens);
	}
	for (a=0;a<vectorsize;a++)
	{
	    sbuf[a]=alloca(64);
	    bzero(sbuf[a],64);
	    memcpy(&ibuf[a][20],encryptedVerifierHashInputBlockKey,8);
	    memcpy(hbuf[a],ibuf[a],28);
	    lens[a]=28;
	}
	hash_sha1_slow(hbuf,sbuf,lens);
	for (a=0;a<vectorsize;a++)
	{
	    tbuf[a]=alloca(64);
	    bzero(tbuf[a],64);
	    memcpy(&ibuf[a][20],encryptedVerifierHashValueBlockKey,8);
	    memcpy(hbuf[a],ibuf[a],28);
	    lens[a]=28;
	}
	hash_sha1_slow(hbuf,tbuf,lens);
	for (a=0;a<vectorsize;a++)
	for (b=20;b<32;b++)
	{
	    sbuf[a][b]=0x36;
	    tbuf[a][b]=0x36;
	}

	for (a=0;a<vectorsize;a++)
	{
	    decryptedhashinput[a]=alloca(32);
	    memcpy(iv, docsalt, 16);
	    memset(&aeskey, 0, sizeof(AES_KEY));
	    if (keybits == 128)
	    {
    		hash_aes_set_decrypt_key(sbuf[a], 128, &aeskey);
	    }
	    else
	    {
		hash_aes_set_decrypt_key(sbuf[a], 256, &aeskey);
	    }
	    hash_aes_cbc_encrypt(verifierhashinput, decryptedhashinput[a], 16, &aeskey, iv, AES_DECRYPT);
	}

	for (a=0;a<vectorsize;a++)
	{
	    decryptedhashvalue[a]=alloca(32);
	    memcpy(iv, docsalt, 16);
	    memset(&aeskey, 0, sizeof(AES_KEY));
	    if (keybits == 128)
	    {
    		hash_aes_set_decrypt_key(tbuf[a], 128, &aeskey);
	    }
	    else
	    {
		hash_aes_set_decrypt_key(tbuf[a], 256, &aeskey);
	    }
	    hash_aes_cbc_encrypt(verifierhashvalue, decryptedhashvalue[a], 32, &aeskey, iv, AES_DECRYPT);
	}

	for (a=0;a<vectorsize;a++) lens[a]=16;
	hash_sha1_slow(decryptedhashinput,hbuf,lens);
	for (a=0;a<vectorsize;a++)
	{
	    if (memcmp(hbuf[a],decryptedhashvalue[a],20)==0)
	    {
		memcpy(salt2[a],"MS Office document  \0", 21);
		*num=a;
		return hash_ok;
	    }
	}
    }
    else if (fileversion == 2013)
    {
	unsigned char *ibuf[VECTORSIZE];
	unsigned char *hbuf[VECTORSIZE];
	unsigned char *sbuf[VECTORSIZE];
	unsigned char *tbuf[VECTORSIZE];
	unsigned int lens[VECTORSIZE];
	unsigned char passutf16[64];
	unsigned char *decryptedhashinput[VECTORSIZE];
	unsigned char *decryptedhashvalue[VECTORSIZE];
	AES_KEY aeskey;
	char iv[16];

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
	hash_sha512_unicode(ibuf,hbuf,lens);

	for (a=0;a<vectorsize;a++) memcpy(ibuf[a],hbuf[a],64);

	for (b=0;b<spincount;b++)
	{
	    for (a=0;a<vectorsize;a++)
	    {
		memcpy(hbuf[a],&b,4);
		memcpy(hbuf[a]+4,ibuf[a],68);
		bzero(hbuf[a]+68,32);
		lens[a]=68;
	    }
	    hash_sha512_unicode(hbuf,ibuf,lens);
	}

	for (a=0;a<vectorsize;a++)
	{
	    sbuf[a]=alloca(128);
	    bzero(sbuf[a],64);
	    memcpy(&ibuf[a][64],encryptedVerifierHashInputBlockKey,8);
	    memcpy(hbuf[a],ibuf[a],72);
	    lens[a]=72;
	}
	hash_sha512_unicode(hbuf,sbuf,lens);

	for (a=0;a<vectorsize;a++)
	{
	    tbuf[a]=alloca(128);
	    bzero(tbuf[a],64);
	    memcpy(&ibuf[a][64],encryptedVerifierHashValueBlockKey,8);
	    memcpy(hbuf[a],ibuf[a],72);
	    lens[a]=72;
	}
	hash_sha512_unicode(hbuf,tbuf,lens);


	for (a=0;a<vectorsize;a++)
	{
	    decryptedhashinput[a]=alloca(32);
	    memcpy(iv, docsalt, 16);
	    memset(&aeskey, 0, sizeof(AES_KEY));
	    if (keybits == 128)
	    {
    		hash_aes_set_decrypt_key(sbuf[a], 128, &aeskey);
	    }
	    else
	    {
		hash_aes_set_decrypt_key(sbuf[a], 256, &aeskey);
	    }
	    hash_aes_cbc_encrypt(verifierhashinput, decryptedhashinput[a], 16, &aeskey, iv, AES_DECRYPT);
	}

	for (a=0;a<vectorsize;a++)
	{
	    decryptedhashvalue[a]=alloca(32);
	    memcpy(iv, docsalt, 16);
	    memset(&aeskey, 0, sizeof(AES_KEY));
	    if (keybits == 128)
	    {
    		hash_aes_set_decrypt_key(tbuf[a], 128, &aeskey);
	    }
	    else
	    {
		hash_aes_set_decrypt_key(tbuf[a], 256, &aeskey);
	    }
	    hash_aes_cbc_encrypt(verifierhashvalue, decryptedhashvalue[a], 32, &aeskey, iv, AES_DECRYPT);
	}

	for (a=0;a<vectorsize;a++) lens[a]=16;
	hash_sha512_unicode(decryptedhashinput,hbuf,lens);


	for (a=0;a<vectorsize;a++)
	{
	    if (memcmp(hbuf[a],decryptedhashvalue[a],32)==0)
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
