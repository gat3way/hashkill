/*
 * ocl_bfunix.c
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

static int hash_ret_len1=24;


static unsigned char bf_atoi64[0x80] = {
      64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
      64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
      64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 0, 1,
      54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 64, 64, 64, 64, 64,
      64, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
      17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 64, 64, 64, 64, 64,
      64, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
      43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 64, 64, 64, 64, 64
};


/* bf_decode was taken from JtR's BF_std.c */
static void __bf_decode(unsigned int *dst, unsigned char *src, int size)
{
    unsigned char *dptr = (unsigned char *)dst;
    unsigned char *end = dptr + size;
    unsigned char *sptr = (unsigned char *)src;
    unsigned int c1, c2, c3, c4;

    do 
    {
        c1 = bf_atoi64[((unsigned int)(unsigned char)(*sptr++))];
        c2 = bf_atoi64[((unsigned int)(unsigned char)(*sptr++))];
        *dptr++ = (c1 << 2) | ((c2 & 0x30) >> 4);
        if (dptr >= end) break;

        c3 = bf_atoi64[((unsigned int)(unsigned char)(*sptr++))];
        *dptr++ = ((c2 & 0x0F) << 4) | ((c3 & 0x3C) >> 2);
        if (dptr >= end) break;

        c4 = bf_atoi64[((unsigned int)(unsigned char)(*sptr++))];
        *dptr++ = ((c3 & 0x03) << 6) | c4;
    } while (dptr < end);
}



static void __bf_swap(unsigned int *x, int count)
{
    unsigned int tmp;

    do 
    {
        tmp = (unsigned int)*x;
        tmp = (tmp << 16) | (tmp >> 16);
        *x++ = ((tmp & 0x00FF00FF) << 8) | ((tmp >> 8) & 0x00FF00FF);
    } while (--count);
}


cl_uint16 setup_salt(unsigned char *salt)
{
    cl_uint16 ret;
    unsigned int mysalt[6];
    char rounds[3];

    // set salt 
    rounds[0]=salt[0];
    rounds[1]=salt[1];
    rounds[2]=0;
    __bf_decode(mysalt, salt+2, 16);
    __bf_swap(mysalt, 4);
    mysalt[4]=(1 << atoi(rounds));
    ret.s0=mysalt[0];
    ret.s1=mysalt[1];
    ret.s2=mysalt[2];
    ret.s3=mysalt[3];
    ret.s4=mysalt[4];
    return ret;
}

cl_uint4 setup_singlehash(unsigned char *hash)
{
    cl_uint4 ret;
    unsigned int binary[8];

    // set binary 
    binary[5] = 0;
    __bf_decode(binary, hash+29, 23);
    __bf_swap(binary, 6);
    binary[5] &= ~(unsigned int)0xFF;
    ret.s0=binary[0];
    ret.s1=binary[1];
    ret.s2=binary[2];
    ret.s3=binary[3];
    return ret;
}




/* Crack callback */
static void ocl_bfunix_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint4 singlehash;
    unsigned int binary[8];
    size_t gws,gws1;



    mylist = hash_list;
    while (mylist)
    {
	// set binary 
	binary[5] = 0;
	__bf_decode(binary, (unsigned char *)mylist->hash+29, 23);
	__bf_swap(binary, 6);
	binary[5] &= ~(unsigned int)0xFF;

        if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
	/* setup addline */
	addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
	addline.sF=strlen(line);
	addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
	addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
	addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
	addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
	_clSetKernelArg(rule_kernel2[self], 4, sizeof(cl_uint16), (void*) &addline);

	/* setup salt */
	salt=setup_salt((unsigned char*)mylist->salt);
	_clSetKernelArg(rule_kernel2[self], 5, sizeof(cl_uint16), (void*) &salt);
	_clSetKernelArg(rule_kernel[self], 6, sizeof(cl_uint16), (void*) &salt);

	singlehash=setup_singlehash((unsigned char*)mylist->hash);
	_clSetKernelArg(rule_kernel[self], 5, sizeof(cl_uint4), (void*) &singlehash);

        if (attack_over!=0) pthread_exit(NULL);
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);

        wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/get_hashes_num();

	gws = (rule_counts[self][0] / wthreads[self].vectorsize);
	while ((gws%64)!=0) gws++;
	gws1 = gws*wthreads[self].vectorsize;
	if (gws1==0) gws1=64;
	if (gws==0) gws=64;

        _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel2[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
        _clFinish(rule_oclqueue[self]);
        _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
        found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
        if (err!=CL_SUCCESS) continue;
        if (*found>0) 
        {
            _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<gws;a++)
	    if (rule_found_ind[self][a]==1)
	    {
		b=a*wthreads[self].vectorsize;
    		_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*hash_ret_len1, hash_ret_len1*wthreads[self].vectorsize, rule_ptr[self]+b*hash_ret_len1, 0, NULL, NULL);
		for (c=0;c<wthreads[self].vectorsize;c++)
		{
	    	    e=(a)*wthreads[self].vectorsize+c;
    		    if (memcmp(binary, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1-1) == 0)
    		    {
            		int flag = 0;
                	strcpy(plain,&rule_images[self][0]+(e*MAX));
                	strcat(plain,line);
                	pthread_mutex_lock(&crackedmutex);
                	addlist = cracked_list;
                	while (addlist)
                	{
                	    if ((strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len1) == 0))
                                flag = 1;
                    	    addlist = addlist->next;
                	}
                	pthread_mutex_unlock(&crackedmutex);
                	if (flag == 0)
                	{
                	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                	    mylist->salt2[0]=1;
                	}
    		    }
		}
	    }
	    bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    *found = 0;
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
	}
	_clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
	mylist = mylist->next;
    }
}



static void ocl_bfunix_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_bfunix_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_bfunix_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={8,1,1};
    size_t amd_local_work_size[3]={8,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=64*rule_local_work_size[0];
    if (wthreads[self].type==nv_thread) ocl_rule_workset[self]/=2;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=-1;

    rule_kernel[self] = _clCreateKernel(program[self], "bfunix", &err );
    rule_kernel2[self] = _clCreateKernel(program[self], "strmodify", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(cl_uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    bzero(&rule_sizes2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);

    _clSetKernelArg(rule_kernel2[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_bfunix_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_bfunix(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_bfunix(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_bfunix(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_bfunix__%s.bin",DATADIR,pbuf);

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
            if ((compute_capability_major==1)&&(compute_capability_minor==0))
            {
        	elog("Bcrypt not supported on Nvidia SM_10 GPUS!\n%s","");
        	return hash_err;
            }
            if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
            if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
            if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
            if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
            if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
	    if ((compute_capability_major==3)&&(compute_capability_minor==0)) sprintf(pbuf,"sm30");
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_bfunix__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_bfunix_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_bfunix_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

