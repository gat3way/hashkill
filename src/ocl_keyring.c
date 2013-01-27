/*
 * ocl_keyring.c
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
#include <ctype.h>
#include <string.h>
#include <pthread.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"

#define KEYRING_FILE_HEADER "GnomeKeyring\n\r\0\n"
#define KEYRING_FILE_HEADER_LEN 16
#define SALTLEN 8
#define LINE_BUFFER_SIZE 81920


typedef unsigned char guchar;
typedef unsigned int guint;
typedef int gint;

struct custom_salt {
        unsigned int iterations;
	unsigned char salt[SALTLEN];
        unsigned int crypto_size;
        unsigned int inlined;
        unsigned char ct[LINE_BUFFER_SIZE];
        unsigned char hash[16];
    } cs;

static int hash_ret_len1=16;

static uint32_t fget32_(FILE * fp)
{
        uint32_t v = fgetc(fp) << 24;
        v |= fgetc(fp) << 16;
        v |= fgetc(fp) << 8;
        v |= fgetc(fp);
        return v;
}

static void get_uint32(FILE * fp, int *next_offset, uint32_t * val)
{
        *val = fget32_(fp);
        *next_offset = *next_offset + 4;
}

static int get_utf8_string(FILE * fp, int *next_offset)
{
        uint32_t len;
        unsigned char buf[1024];
        get_uint32(fp, next_offset, &len);

        if (len == 0xffffffff) {
                return 1;
        } else if (len >= 0x7fffffff) {
                // bad
                return 0;
        }
        /* read len bytes */
        fread(buf, len, 1, fp);
        *next_offset = *next_offset + len;
        return 1;
}

static void buffer_get_attributes(FILE * fp, int *next_offset)
{
        guint list_size;
        guint type;
        guint val;
        int i;
        get_uint32(fp, next_offset, &list_size);
        for (i = 0; i < list_size; i++) {
                get_utf8_string(fp, next_offset);
                get_uint32(fp, next_offset, &type);
                switch (type) {
                case 0: /* A string */
                        get_utf8_string(fp, next_offset);
                        break;
                case 1: /* A uint32 */
                        get_uint32(fp, next_offset, &val);
                        break;
                }
        }
}

static int read_hashed_item_info(FILE * fp, int *next_offset, uint32_t n_items)
{

        int i;
        uint32_t id;
        uint32_t type;

        for (i = 0; i < n_items; i++) {
                get_uint32(fp, next_offset, &id);
                get_uint32(fp, next_offset, &type);
                buffer_get_attributes(fp, next_offset);
        }
        return 1;
}

hash_stat load_keyring(char *filename)
{
        FILE *fp;
        unsigned char buf[1024];
        int i, offset;
        uint32_t flags;
        uint32_t lock_timeout;
        unsigned char major, minor, crypto, hash;
        uint32_t tmp;
        uint32_t num_items;
        unsigned char salt[8];
        unsigned char *to_decrypt;
        int count;

        if (!(fp = fopen(filename, "rb"))) {
                return hash_err;
        }
        count = fread(buf, KEYRING_FILE_HEADER_LEN, 1, fp);
        if (count!=1) return hash_err;
        if (memcmp(buf, KEYRING_FILE_HEADER, KEYRING_FILE_HEADER_LEN) != 0) {
                return hash_err;
        }
        offset = KEYRING_FILE_HEADER_LEN;
        major = fgetc(fp);
        minor = fgetc(fp);
        crypto = fgetc(fp);
        hash = fgetc(fp);
        offset += 4;

        if (major != 0 || minor != 0 || crypto != 0 || hash != 0) {
                fclose(fp);
                return hash_err;
        }
        // Keyring name
        if (!get_utf8_string(fp, &offset))
                goto bail;
        // ctime
        count = fread(buf, 8, 1, fp);
        if (count!=1)
        {
            fclose(fp);
            return hash_err;
        }
        offset += 8;
        // mtime
        count = fread(buf, 8, 1, fp);
        offset += 8;
        // flags
        get_uint32(fp, &offset, &flags);
        // lock timeout
        get_uint32(fp, &offset, &lock_timeout);
        // iterations
        get_uint32(fp, &offset, &cs.iterations);
        // salt
        count = fread(salt, 8, 1, fp);
        offset += 8;
        // reserved
        for (i = 0; i < 4; i++) {
                get_uint32(fp, &offset, &tmp);
        }
        // num_items
        get_uint32(fp, &offset, &num_items);
        if (!read_hashed_item_info(fp, &offset, num_items))
                goto bail;

        // crypto_size
        get_uint32(fp, &offset, &cs.crypto_size);

        /* Make the crypted part is the right size */
        if (cs.crypto_size % 16 != 0)
                goto bail;

        to_decrypt = (unsigned char *) malloc(cs.crypto_size);
        count = fread(to_decrypt, cs.crypto_size, 1, fp);
        memcpy(cs.salt, salt, SALTLEN);
        memcpy(cs.ct, to_decrypt, cs.crypto_size);
        if(to_decrypt)
                free(to_decrypt);

	memcpy(cs.hash,"\xd4\x1d\x8c\xd9\x8f\x00\xb2\x04\xe9\x80\x09\x98\xec\xf8\x42\x7e",16);
        return hash_ok;

bail:
        fclose(fp);
        return hash_err;
}



/* Crack callback */
static void ocl_keyring_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    char plain[MAX];
    char hex1[16];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 singlehash;
    char mhash[32];
    size_t gws,gws1;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt.s0=(cs.salt[0])|(cs.salt[1]<<8)|(cs.salt[2]<<16)|(cs.salt[3]<<24);
    salt.s1=(cs.salt[4])|(cs.salt[5]<<8)|(cs.salt[6]<<16)|(cs.salt[7]<<24);
    salt.s4=(cs.ct[0])|(cs.ct[1]<<8)|(cs.ct[2]<<16)|(cs.ct[3]<<24);
    salt.s5=(cs.ct[4])|(cs.ct[5]<<8)|(cs.ct[6]<<16)|(cs.ct[7]<<24);
    salt.s6=(cs.ct[8])|(cs.ct[9]<<8)|(cs.ct[10]<<16)|(cs.ct[11]<<24);
    salt.s7=(cs.ct[12])|(cs.ct[13]<<8)|(cs.ct[14]<<16)|(cs.ct[15]<<24);
    

    memcpy(mhash,cs.hash,16);
    unsigned int A,B,C,D;
    memcpy(hex1,mhash,4);
    memcpy(&A, hex1, 4);
    memcpy(hex1,mhash+4,4);
    memcpy(&B, hex1, 4);
    memcpy(hex1,mhash+8,4);
    memcpy(&C, hex1, 4);
    memcpy(hex1,mhash+12,4);
    memcpy(&D, hex1, 4);
    singlehash.s0=A;
    singlehash.s1=B;
    singlehash.s2=C;
    singlehash.s3=D;

    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernellast[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernellast[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);


    if (rule_counts[self][0]==-1) return;
    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    for (a=0;a<((cs.iterations-1)/200);a++)
    {
    	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	wthreads[self].tries+=(gws1)/(cs.iterations/200);
    }
    salt.sA=((cs.iterations-1)%200);
    _clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
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
                memcpy(mhash,cs.hash,hash_ret_len1);
    		if (memcmp(mhash, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1) == 0)
    		{
            	    strcpy(plain,&rule_images[self][0]+(e*MAX));
            	    strcat(plain,line);
            	    pthread_mutex_lock(&crackedmutex);
            	    if (!cracked_list)
            	    {
                	pthread_mutex_unlock(&crackedmutex);
                	add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
        	    }
        	    else pthread_mutex_unlock(&crackedmutex);
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



static void ocl_keyring_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_keyring_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_keyring_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=256*128;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "block", &err );
    rule_kernellast[self] = _clCreateKernel(program[self], "final", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_keyring_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_keyring(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_keyring(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_keyring(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (hash_err==load_keyring(hashlist_file)) return hash_err;

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_keyring__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_keyring__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_keyring_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_keyring_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

