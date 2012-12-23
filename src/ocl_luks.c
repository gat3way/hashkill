/*
 * ocl_luks.c
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
#include <ctype.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <arpa/inet.h>
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

static int hash_ret_len1=32;


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


static unsigned char *cipherbuf;
static int afsize=0;
static unsigned int bestslot=0;



static void XORblock(char *src1, char *src2, char *dst, int n)
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



static  int AF_merge(unsigned char *src, unsigned char *dst, int afsize, int stripes)
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
	OAES_SET_ENCRYPT_KEY(essivhash, 256, &aeskey);
	OAES_CBC_ENCRYPT(sectorbuf, essiv, 16, &aeskey, zeroiv, AES_ENCRYPT);
	OAES_SET_DECRYPT_KEY(key, ntohl(myphdr.keyBytes)*8, &aeskey);
	OAES_CBC_ENCRYPT((src+a*512), (dst+a*512), 512, &aeskey, essiv, AES_DECRYPT);
    }
}



hash_stat load_luks(char *filename)
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

    //hlog("Best keyslot %d: - iteration count %d - stripes: %d \n", bestslot, ntohl(myphdr.keyblock[bestslot].passwordIterations),ntohl(myphdr.keyblock[bestslot].stripes));

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

    return hash_ok;
}








static cl_uint16 ocl_get_salt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    memcpy((char *)salt2,myphdr.keyblock[bestslot].passwordSalt,32);
    len=32;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=1;
    salt2[len+4]=0x80;

    t.s0=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s1=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.s2=salt2[8]|(salt2[9]<<8)|(salt2[10]<<16)|(salt2[11]<<24);
    t.s3=salt2[12]|(salt2[13]<<8)|(salt2[14]<<16)|(salt2[15]<<24);
    t.s4=salt2[16]|(salt2[17]<<8)|(salt2[18]<<16)|(salt2[19]<<24);
    t.s5=salt2[20]|(salt2[21]<<8)|(salt2[22]<<16)|(salt2[23]<<24);
    t.s6=salt2[24]|(salt2[25]<<8)|(salt2[26]<<16)|(salt2[27]<<24);
    t.s7=salt2[28]|(salt2[29]<<8)|(salt2[30]<<16)|(salt2[31]<<24);
    t.s8=salt2[32]|(salt2[33]<<8)|(salt2[34]<<16)|(salt2[35]<<24);
    t.s9=salt2[36]|(salt2[37]<<8)|(salt2[38]<<16)|(salt2[39]<<24);
    t.sA=salt2[40]|(salt2[41]<<8)|(salt2[42]<<16)|(salt2[43]<<24);

    return t;
}

static cl_uint16 ocl_get_salt2()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    memcpy((char *)salt2,myphdr.keyblock[bestslot].passwordSalt,32);
    len=32;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=2;
    salt2[len+4]=0x80;

    t.s0=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s1=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.s2=salt2[8]|(salt2[9]<<8)|(salt2[10]<<16)|(salt2[11]<<24);
    t.s3=salt2[12]|(salt2[13]<<8)|(salt2[14]<<16)|(salt2[15]<<24);
    t.s4=salt2[16]|(salt2[17]<<8)|(salt2[18]<<16)|(salt2[19]<<24);
    t.s5=salt2[20]|(salt2[21]<<8)|(salt2[22]<<16)|(salt2[23]<<24);
    t.s6=salt2[24]|(salt2[25]<<8)|(salt2[26]<<16)|(salt2[27]<<24);
    t.s7=salt2[28]|(salt2[29]<<8)|(salt2[30]<<16)|(salt2[31]<<24);
    t.s8=salt2[32]|(salt2[33]<<8)|(salt2[34]<<16)|(salt2[35]<<24);
    t.s9=salt2[36]|(salt2[37]<<8)|(salt2[38]<<16)|(salt2[39]<<24);
    t.sA=salt2[40]|(salt2[41]<<8)|(salt2[42]<<16)|(salt2[43]<<24);

    return t;
}


static cl_uint16 ocl_get_salt3()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    memcpy((char *)salt2,myphdr.mkDigestSalt,32);
    len=32;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=1;
    salt2[len+4]=0x80;

    t.s0=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s1=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.s2=salt2[8]|(salt2[9]<<8)|(salt2[10]<<16)|(salt2[11]<<24);
    t.s3=salt2[12]|(salt2[13]<<8)|(salt2[14]<<16)|(salt2[15]<<24);
    t.s4=salt2[16]|(salt2[17]<<8)|(salt2[18]<<16)|(salt2[19]<<24);
    t.s5=salt2[20]|(salt2[21]<<8)|(salt2[22]<<16)|(salt2[23]<<24);
    t.s6=salt2[24]|(salt2[25]<<8)|(salt2[26]<<16)|(salt2[27]<<24);
    t.s7=salt2[28]|(salt2[29]<<8)|(salt2[30]<<16)|(salt2[31]<<24);
    t.s8=salt2[32]|(salt2[33]<<8)|(salt2[34]<<16)|(salt2[35]<<24);
    t.s9=salt2[36]|(salt2[37]<<8)|(salt2[38]<<16)|(salt2[39]<<24);
    t.sA=salt2[40]|(salt2[41]<<8)|(salt2[42]<<16)|(salt2[43]<<24);

    return t;
}



/* Crack callback */
static void ocl_luks_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 salt2;
    cl_uint16 salt3;
    unsigned char *af_decrypted = alloca(afsize);
    unsigned char masterkeycandidate[32];
    size_t nws1;
    size_t nws;


    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt=ocl_get_salt();
    salt2=ocl_get_salt2();

    if (attack_over!=0) pthread_exit(NULL);

    if (rule_counts[self][0]==-1) return;
    nws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((nws%64)!=0) nws++;
    nws1 = nws*wthreads[self].vectorsize;
    if (nws1==0) nws1=64;
    if (nws==0) nws=64;


    _clSetKernelArg(rule_kernelend[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelend[self], 7, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 8, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend2[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelend2[self], 7, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 8, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelmod[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelmod[self], 7, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre2[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl2[self], 6, sizeof(cl_uint16), (void*) &salt2);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &nws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    b=(2*ntohl(myphdr.keyblock[bestslot].passwordIterations))/1000;
    for (a=0;a<(ntohl(myphdr.keyblock[bestslot].passwordIterations));a+=1000)
    {
	if (attack_over!=0) pthread_exit(NULL);
	addline.sA=a;
	addline.sB=a+1000;
	if (a>(ntohl(myphdr.keyblock[bestslot].passwordIterations)-1000)) addline.sB=a+(ntohl(myphdr.keyblock[bestslot].passwordIterations)%1000);
	if (a==0) addline.sA=1;
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(nws1)/b;
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
    }

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=0;a<(ntohl(myphdr.keyblock[bestslot].passwordIterations));a+=1000)
    {
	if (attack_over!=0) pthread_exit(NULL);
	addline.sA=a;
	addline.sB=a+1000;
	if (a==0) addline.sA=1;
	if (a>(ntohl(myphdr.keyblock[bestslot].passwordIterations)-1000)) addline.sB=a+(ntohl(myphdr.keyblock[bestslot].passwordIterations)%1000);
	_clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(nws1)/b;
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);


    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
    for (a=0;a<nws1;a++)
    {
	if (attack_over!=0) pthread_exit(NULL);
        b=a*hash_ret_len1;
        memcpy(masterkeycandidate,rule_ptr[self]+b,32);
        decrypt_aes_cbc_essiv(cipherbuf, af_decrypted, masterkeycandidate, ntohl(myphdr.keyblock[bestslot].keyMaterialOffset),afsize);
        // AFMerge the blocks
        AF_merge(af_decrypted,(unsigned char *)rule_images2[self]+b, afsize, ntohl(myphdr.keyblock[bestslot].stripes));
    }

    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_images2_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, rule_images2[self], 0, NULL, NULL);
    salt3=ocl_get_salt3();
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt3);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_uint16), (void*) &salt3);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_uint16), (void*) &salt3);


    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=0;a<(ntohl(myphdr.mkDigestIterations));a+=1000)
    {
	if (attack_over!=0) pthread_exit(NULL);
	addline.sA=a;
	addline.sB=a+1000;
	if (a==0) addline.sA=1;
	if (a>(ntohl(myphdr.mkDigestIterations)-1000)) addline.sB=a+(ntohl(myphdr.mkDigestIterations)%1000);
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);


    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    if (err!=CL_SUCCESS) return;
    if (*found>0) 
    {
        _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
        for (a=0;a<ocl_rule_workset[self];a++)
        if (rule_found_ind[self][a]==1)
	{
	    b=a*wthreads[self].vectorsize;
    	    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*hash_ret_len1, hash_ret_len1*wthreads[self].vectorsize, rule_ptr[self]+b*hash_ret_len1, 0, NULL, NULL);
	    for (c=0;c<wthreads[self].vectorsize;c++)
	    {
	        e=(a)*wthreads[self].vectorsize+c;
    	        if (memcmp(myphdr.mkDigest, (char *)rule_ptr[self]+(e)*hash_ret_len1, 16) == 0)
    	        if (!cracked_list)
    	        {
            	    strcpy(plain,&rule_images[self][0]+(e*MAX));
            	    strcat(plain,line);
            	    add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
    		}
	    }
	}
	bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	*found = 0;
    	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
    }
    _clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
}



static void ocl_luks_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strncpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line,MAX);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_luks_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_luks_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    char hex1[16];
    cl_uint4 singlehash;


    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*128;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
    if (ocl_gpu_double) ocl_rule_workset[self]*=4;
    if (interactive_mode==1) ocl_rule_workset[self]/=4;
    if (wthreads[self].type==nv_thread) ocl_rule_workset[self]/=2;

    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare1", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "pbkdf1", &err );
    rule_kernelpre2[self] = _clCreateKernel(program[self], "prepare2", &err );
    rule_kernelbl2[self] = _clCreateKernel(program[self], "pbkdf2", &err );
    rule_kernelend[self] = _clCreateKernel(program[self], "final", &err );
    rule_kernelend2[self] = _clCreateKernel(program[self], "final2", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*4, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*40, NULL, &err );
    rule_images4_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*60, NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*4);
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*40);
    rule_images4[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*60);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*4);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*40);
    bzero(&rule_images4[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*60);


    memcpy(hex1,myphdr.mkDigest,4);
    unsigned int A,B,C,D;
    memcpy(&A, hex1, 4);
    memcpy(hex1,myphdr.mkDigest+4,4);
    memcpy(&B, hex1, 4);
    memcpy(hex1,myphdr.mkDigest+8,4);
    memcpy(&C, hex1, 4);
    memcpy(hex1,myphdr.mkDigest+12,4);
    memcpy(&D, hex1, 4);
    singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelend2[self], 5, sizeof(cl_uint4), (void*) &singlehash);

    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_luks_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_luks(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_luks(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_luks(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    load_luks(hashlist_file);
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
    	    if (ntohl(myphdr.keyBytes)==32) sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_luks256__%s.bin",pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_luks128__%s.bin",DATADIR,pbuf);

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
    	    if (ntohl(myphdr.keyBytes)==32) sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_luks256__%s.ptx",pbuf);
            else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_luks128__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_luks_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_luks_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    free(cipherbuf);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

