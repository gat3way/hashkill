/*
 * ocl_androidfde.c
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
static struct android_hdr 
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

static unsigned char mkey[32];
static unsigned char msalt[16];
static unsigned char blockbuf[512*3];



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
    OAES_SET_ENCRYPT_KEY(essivhash, 256, &aeskey);
    OAES_CBC_ENCRYPT(sectorbuf, essiv, 16, &aeskey, zeroiv, AES_ENCRYPT);
    OAES_SET_DECRYPT_KEY(key, myphdr.keysize*8, &aeskey);
    OAES_CBC_ENCRYPT(src, dst, size, &aeskey, essiv, AES_DECRYPT);
}


static hash_stat check_androidfde(char *keycandidate)
{
    unsigned char keycandidate2[255];
    unsigned char decrypted1[512]; // FAT
    unsigned char decrypted2[512]; // ext3/4
    AES_KEY aeskey;
    uint16_t v2,v3,v4;
    uint32_t v1,v5;

    // Get pbkdf2 of the password to obtain decryption key
    OAES_SET_DECRYPT_KEY((unsigned char*)keycandidate, myphdr.keysize*8, &aeskey);
    OAES_CBC_ENCRYPT(mkey, keycandidate2, 16, &aeskey, (unsigned char*)(keycandidate+16), AES_DECRYPT);
    decrypt_aes_cbc_essiv(blockbuf, decrypted1, keycandidate2,0,32);
    decrypt_aes_cbc_essiv(blockbuf+1024, decrypted2, keycandidate2,2,128);

    // Check for FAT
    if ((memcmp(decrypted1+3,"MSDOS5.0",8)==0))
    {
        return hash_ok;
    }
    // Check for extfs
    memcpy(&v1,decrypted2+72,4);
    memcpy(&v2,decrypted2+0x3a,2);
    memcpy(&v3,decrypted2+0x3c,2);
    memcpy(&v4,decrypted2+0x4c,2);
    memcpy(&v5,decrypted2+0x48,4);

    if ((v1<5)&&(v2<4)&&(v3<5)&&(v4<2)&&(v5<5))
    {
        return hash_ok;
    }
    return hash_err;
}






hash_stat load_androidfde(char *filename)
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

    return hash_ok;
}



static cl_uint16 ocl_get_salt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    memcpy((char *)salt2,msalt,16);
    len=16;
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
    memcpy((char *)salt2,msalt,16);
    len=16;
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




/* Crack callback */
static void ocl_androidfde_crack_callback(char *line, int self)
{
    int a,b,c,e;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 salt2;
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

    b=(2*2000)/1000;
    for (a=0;a<2000;a+=1000)
    {
	if (attack_over!=0) pthread_exit(NULL);
	addline.sA=a;
	addline.sB=a+1000;
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

    for (a=0;a<2000;a+=1000)
    {
	if (attack_over!=0) pthread_exit(NULL);
	addline.sA=a;
	addline.sB=a+1000;
	if (addline.sB>2000) addline.sB=2000;
	if (a==0) addline.sA=1;
	_clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(nws1)/b;
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);

    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*nws, rule_ptr[self], 0, NULL, NULL);
    for (a=0;a<nws;a++)
    for (c=0;c<wthreads[self].vectorsize;c++)
    {
        e=(a)*wthreads[self].vectorsize+c;
        if (check_androidfde(rule_ptr[self]+e*32)==hash_ok)
        {
    	    strcpy(plain,&rule_images[self][0]+(e*MAX));
    	    strcat(plain,line);
    	    add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
	}
    }
}



static void ocl_androidfde_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strncpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line,MAX);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_androidfde_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_androidfde_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
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


    singlehash.x=0;singlehash.y=0;singlehash.z=0;singlehash.w=0;
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelend2[self], 5, sizeof(cl_uint4), (void*) &singlehash);

    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_androidfde_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_androidfde(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_androidfde(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_androidfde(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    load_androidfde(hashlist_file);
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
    	    sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_androidfde__%s.bin",pbuf);

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
    	    sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_androidfde__%s.ptx",pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_androidfde_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_androidfde_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

