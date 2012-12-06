/*
 * ocl_msoffice.c
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
#include <alloca.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <openssl/sha.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"
#include "cpu-feat.h"


extern int b64_pton(char *src,unsigned char *target,size_t targsize);

static int hash_ret_len1=20;

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
static unsigned int saltsize;

/* Office 2010/2013 */
static const unsigned char hibk[] = { 0xfe, 0xa7, 0xd2, 0x76, 0x3b, 0x4b, 0x9e, 0x79 };
static const unsigned char hvbk[] = { 0xd7, 0xaa, 0x0f, 0x6d, 0x30, 0x61, 0x34, 0x4e };


/* Get buffer+offset for sector */
static char* get_buf_offset(int sector)
{
    return (buf+(sector+1)*sectorsize);
}


/* Get sector offset for sector */
/*
static int get_offset(int sector)
{
    return ((sector+1)*sectorsize);
}
*/


/* Get FAT table for a given sector */
static int* get_fat(int sector)
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
static int* get_mtab(int sector)
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
static int get_minisection_sector(int sector)
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
static int get_mini_offset(int sector)
{
    return ((sector*64)%(sectorsize));
}


/* 
   Read stream from mini table - callee needs to free memory 
   TODO: what if stream is in FAT? Until now I haven't seen a case
   like that with EncryptionStream (it's usually around 1KB, far below 4KB)
   Anyway, this should be handled properly some day.
*/
static char* read_stream_mini(int start, int size)
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


static hash_stat load_msoffice(char *filename)
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

    index = 0;
    if (!stream)
    {
	elog("No EncryptionInfo stream found!\n%s","");
	return hash_err;
    }

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
            //printf("no keyBits parameters in XML!\n");
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
    return hash_ok;
}







static hash_stat check_msoffice(unsigned char *key, char *pwd)
{
    if (fileversion==2007)
    {
	unsigned char decryptedverifier[32];
	unsigned char decryptedverifierhash[32];
	unsigned char hbuf[32];
	AES_KEY aeskey;
	unsigned char iv[16];
	int len;
	SHA_CTX ctx;

	memset(&aeskey,0,sizeof(AES_KEY));
	memset(iv,0,16);
	OAES_SET_DECRYPT_KEY(key, 128, &aeskey);
	OAES_CBC_ENCRYPT(verifier,decryptedverifier,16,&aeskey,iv,AES_DECRYPT);
	memset(&aeskey,0,sizeof(AES_KEY));
	memset(iv,0,16);
	OAES_SET_DECRYPT_KEY(key, 128, &aeskey);
	OAES_CBC_ENCRYPT(verifierhash,decryptedverifierhash,16,&aeskey,iv,AES_DECRYPT);
	memset(&aeskey,0,sizeof(AES_KEY));
	memset(iv,0,16);
	OAES_SET_DECRYPT_KEY(key, 128, &aeskey);
	OAES_CBC_ENCRYPT(verifierhash+16,decryptedverifierhash+16,16,&aeskey,iv,AES_DECRYPT);
	len=16;
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, decryptedverifier, len);
	SHA1_Final(hbuf, &ctx);
	if (memcmp(decryptedverifierhash,hbuf,16)==0)
	{
	    return hash_ok;
	}
    }
    else if (fileversion==2010)
    {
	unsigned char decryptedhashinput[32];
	unsigned char decryptedhashvalue[32];
	unsigned char hbuf[32];
	unsigned char sbuf[32];
	unsigned char tbuf[32];
	AES_KEY aeskey;
	unsigned char iv[16];
	int len;
	SHA_CTX ctx;

	memcpy(sbuf,key,32);
	memcpy(tbuf,key+32,32);
	memset(&aeskey,0,sizeof(AES_KEY));
	memcpy(iv,docsalt,16);
	if (keybits==128) OAES_SET_DECRYPT_KEY(sbuf, 128, &aeskey);
	else OAES_SET_DECRYPT_KEY(sbuf, 256, &aeskey);
	OAES_CBC_ENCRYPT(verifierhashinput,decryptedhashinput,16,&aeskey,iv,AES_DECRYPT);
	memset(&aeskey,0,sizeof(AES_KEY));
	memcpy(iv,docsalt,16);
	if (keybits==128) OAES_SET_DECRYPT_KEY(tbuf, 128, &aeskey);
	else OAES_SET_DECRYPT_KEY(tbuf, 256, &aeskey);
	OAES_CBC_ENCRYPT(verifierhashvalue,decryptedhashvalue,32,&aeskey,iv,AES_DECRYPT);
	len=16;
	SHA1_Init(&ctx);
	SHA1_Update(&ctx, decryptedhashinput, len);
	SHA1_Final(hbuf, &ctx);
	if (memcmp(decryptedhashvalue,hbuf,20)==0)
	{
	    return hash_ok;
	}
    }
    else
    {
	unsigned char decryptedhashinput[32];
	unsigned char decryptedhashvalue[32];
	unsigned char hbuf[128];
	unsigned char sbuf[128];
	unsigned char tbuf[128];
	AES_KEY aeskey;
	unsigned char iv[16];
	int len;
	SHA512_CTX ctx;

	memcpy(sbuf,key,64);
	memcpy(tbuf,key+64,64);
	memset(&aeskey,0,sizeof(AES_KEY));
	memcpy(iv,docsalt,16);
	if (keybits==128) OAES_SET_DECRYPT_KEY(sbuf, 128, &aeskey);
	else OAES_SET_DECRYPT_KEY(sbuf, 256, &aeskey);
	OAES_CBC_ENCRYPT(verifierhashinput,decryptedhashinput,16,&aeskey,iv,AES_DECRYPT);
	memset(&aeskey,0,sizeof(AES_KEY));
	memcpy(iv,docsalt,16);
	if (keybits==128) OAES_SET_DECRYPT_KEY(tbuf, 128, &aeskey);
	else OAES_SET_DECRYPT_KEY(tbuf, 256, &aeskey);
	OAES_CBC_ENCRYPT(verifierhashvalue,decryptedhashvalue,32,&aeskey,iv,AES_DECRYPT);
	len=16;
	SHA512_Init(&ctx);
	SHA512_Update(&ctx, decryptedhashinput, len);
	SHA512_Final(hbuf, &ctx);
	if (memcmp(decryptedhashvalue,hbuf,32)==0)
	{
	    return hash_ok;
	}
    }

    return hash_err;
}



static cl_uint16 msoffice_getsalt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    len=saltsize;
    bzero(salt2,32);
    memcpy(salt2,docsalt,saltsize);

    t.s0=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s1=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s2=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.s3=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.s4=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);
    t.s5=(salt2[20]&255)|((salt2[21]&255)<<8)|((salt2[22]&255)<<16)|((salt2[23]&255)<<24);
    t.s6=(salt2[24]&255)|((salt2[25]&255)<<8)|((salt2[26]&255)<<16)|((salt2[27]&255)<<24);

    t.s9=(hibk[0]&255)|((hibk[1]&255)<<8)|((hibk[2]&255)<<16)|((hibk[3]&255)<<24);
    t.sA=(hibk[4]&255)|((hibk[5]&255)<<8)|((hibk[6]&255)<<16)|((hibk[7]&255)<<24);
    t.sB=(hvbk[0]&255)|((hvbk[1]&255)<<8)|((hvbk[2]&255)<<16)|((hvbk[3]&255)<<24);
    t.sC=(hvbk[4]&255)|((hvbk[5]&255)<<8)|((hvbk[6]&255)<<16)|((hvbk[7]&255)<<24);

    t.sF=(len);
    return t;
}






/* Crack callback */
static void ocl_msoffice_crack_callback(char *line, int self)
{
    int a,c,d,e;
    cl_uint16 addline;
    cl_uint16 salt;
    unsigned char key[128];
    char plainimg[MAXCAND+1];
    size_t gws,gws1;

    if (rule_counts[self][0]==-1) return;
    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_uint16), (void*) &addline);

    /* setup salt */
    salt=msoffice_getsalt();
    salt.s8=0;
    _clSetKernelArg(rule_kernel[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend[self], 2, sizeof(cl_uint16), (void*) &salt);

    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    for (a=0;a<((spincount)/(1000));a++)
    {
	if (attack_over!=0) pthread_exit(NULL);
	salt.s8=a*1000;
	_clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_uint16), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
    	wthreads[self].tries+=(gws1)/(spincount/1000);
    }

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);

    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
/*
int i;
printf("%s - ",rule_images[self]);
for (i=0;i<64;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
for (i=64;i<128;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
printf("%s - ",rule_images[self]+32);
for (i=128;i<192;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
for (i=192;i<256;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
printf("%s - ",rule_images[self]+64);
for (i=256;i<320;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
for (i=320;i<384;i++) printf("%02x",rule_ptr[self][i]&255);
printf("\n");
*/

    for (a=0;a<ocl_rule_workset[self];a++)
    {
        for (c=0;c<wthreads[self].vectorsize;c++)
        {
            e=(a)*wthreads[self].vectorsize+c;
            memcpy(key,(char *)rule_ptr[self]+(e)*hash_ret_len1,hash_ret_len1);
            for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
            if (check_msoffice(key,plainimg)==hash_ok)
            {
                for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
                if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, (char *)plainimg);
            }
        }
    }
}



static void ocl_msoffice_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_msoffice_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_msoffice_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    int factor;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*128;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=4;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;

    if (fileversion==2007)
    {
	hash_ret_len1=20;
	spincount=50000;
	if (wthreads[self].type==nv_thread)
	{
	    if (wthreads[self].ocl_have_sm21==1) wthreads[self].vectorsize=4;
	    else wthreads[self].vectorsize=1;
	}
	else
	{
	    if (wthreads[self].ocl_have_old_ati==1)
	    {
		wlog("Warning: AMD 4xxx GPUs not supported%s\n","");
		return NULL;
	    }
	    if (wthreads[self].ocl_have_gcn!=1) wthreads[self].vectorsize=4;
	    else wthreads[self].vectorsize=1;
	}
    }
    else if (fileversion==2010)
    {
	hash_ret_len1=64;
	ocl_rule_workset[self]/=2;
	if (wthreads[self].type==nv_thread)
	{
	    if (wthreads[self].ocl_have_sm21==1) wthreads[self].vectorsize=4;
	    else wthreads[self].vectorsize=1;
	}
	else
	{
	    if (wthreads[self].ocl_have_old_ati==1)
	    {
		wlog("Warning: AMD 4xxx GPUs not supported%s\n","");
		return NULL;
	    }
	    if (wthreads[self].ocl_have_gcn!=1) wthreads[self].vectorsize=4;
	    else wthreads[self].vectorsize=1;
	}
    }
    else if (fileversion==2013)
    {
	hash_ret_len1=128;
	ocl_rule_workset[self]/=2;
	if (wthreads[self].type==nv_thread)
	{
	    wthreads[self].vectorsize=1;
	}
	else
	{
	    if (wthreads[self].ocl_have_old_ati==1)
	    {
		wlog("Warning: AMD 4xxx GPUs not supported%s\n","");
		return NULL;
	    }
	    wthreads[self].vectorsize=1;
	}
    }

    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernel[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "officeprep", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "officeiter", &err );
    rule_kernelend[self] = _clCreateKernel(program[self], "officefinal", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    if (fileversion==2007) factor=20;
    else if (fileversion==2010) factor=20;
    else factor=64;

    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*factor, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*factor);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*factor);
    bzero(rule_sizes[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    bzero(rule_sizes2[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);

    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);

    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);

    _clSetKernelArg(rule_kernelend[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);



    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_msoffice_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_msoffice(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_msoffice(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_msoffice(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_msoffice(hashlist_file))
    {
	elog("Could not load the msoffice file!\n%s","");
	return hash_err;
    }

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

    for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
    {
	_clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
        context[i] = _clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);
        if (wthreads[i].type != nv_thread)
        {
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    if (fileversion==2007)
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/amd_msoffice2007__%s.bin",DATADIR,pbuf);
    	    }
    	    else if (fileversion==2010)
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/amd_msoffice2010__%s.bin",DATADIR,pbuf);
    	    }
    	    else
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/amd_msoffice2013__%s.bin",DATADIR,pbuf);
    	    }


    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            if (!fp) 
            {
                elog("Can't open kernel: %s\n",kernelfile);
                exit(1);
            }
            
            fseek(fp, 0, SEEK_END);
            binary_size = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            binary=malloc(binary_size);
            fread(binary,binary_size,1,fp);
            fclose(fp);
            unlink(ofname);
            free(ofname);
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
            free(binary);
        }
        else
        {
            #define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
            #define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    cl_uint compute_capability_major, compute_capability_minor;
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
            if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
            if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
            if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
            if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
            if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
            if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
	    if ((compute_capability_major==3)&&(compute_capability_minor==0)) sprintf(pbuf,"sm30");
    	    if (fileversion==2007)
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/nvidia_msoffice2007__%s.ptx",DATADIR,pbuf);
	    }
	    else if (fileversion==2010)
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/nvidia_msoffice2010__%s.ptx",DATADIR,pbuf);
	    }
	    else
    	    {
    		sprintf(kernelfile,"%s/hashkill/kernels/nvidia_msoffice2013__%s.ptx",DATADIR,pbuf);
	    }
	    
    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            if (!fp) 
            {
                elog("Can't open kernel: %s\n",kernelfile);
                exit(1);
            }
            
            fseek(fp, 0, SEEK_END);
            binary_size = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            binary=malloc(binary_size);
            fread(binary,binary_size,1,fp);
            fclose(fp);
            unlink(ofname);
            free(ofname);
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
            free(binary);
        }
    }


    pthread_mutex_init(&biglock, NULL);

    for (a=0;a<nwthreads;a++)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_rule_msoffice_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_msoffice_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

