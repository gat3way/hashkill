/*
 * ocl_apr1.c
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


static int hash_ret_len1=16;
static unsigned const char cov_2char[65]="./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";


//Pick out the 16 bytes in this order: 11 4 10 5 3 9 15 2 8 14 1 7 13 0 6 12.
static int b64_pton_crypt(unsigned char const *src, unsigned char *target)
{
    int y,j;
    unsigned char c1,c2,c3,c4;
    

    c1=c2=c3=c4=0;
    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[3]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[2]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[1]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[0]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[0]=(y>>24)&255;
    target[6]=(y>>16)&255;
    target[12]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[7]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[6]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[5]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[4]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[1]=(y>>24)&255;
    target[7]=(y>>16)&255;
    target[13]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[11]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[10]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[9]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[8]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[2]=(y>>24)&255;
    target[8]=(y>>16)&255;
    target[14]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[15]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[14]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[13]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[12]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[3]=(y>>24)&255;
    target[9]=(y>>16)&255;
    target[15]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[19]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[18]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[17]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[16]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[4]=(y>>24)&255;
    target[10]=(y>>16)&255;
    target[5]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[21]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[20]) c2=(j&255);
    y=(c1<<14)|(c2<<8)|0;//(c3<<14)|(c4<<8);
    target[11]=(y>>8)&255;
    target[16]=0;

    return 0;
}






/* Crack callback */
static void ocl_apr1_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];
    char hex1[16];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 singlehash;
    unsigned char base64[64];
    int cc,cc1;
    size_t gws,gws1;

    cc = self_kernel16[self];
    cc1 = self_kernel16[self]+strlen(line);
    if (cc1>15) cc1=15;
    mylist = hash_list;
    while (mylist)
    {
        if (attack_over!=0) pthread_exit(NULL);
        if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
	/* setup addline */
	addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
	addline.sF=strlen(line);
	addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
	addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
	addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
	addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
	_clSetKernelArg(rule_kernel162[cc][self], 4, sizeof(cl_uint16), (void*) &addline);

	/* setup salt */
	char tempsalt[16];
        bzero(tempsalt,16);
        strcpy(tempsalt,mylist->salt);
        a=strlen(tempsalt)-1;
        tempsalt[a]=0;tempsalt[a+1]=0;tempsalt[a+2]=0;tempsalt[a+3]=0;tempsalt[a+4]=0;
        tempsalt[a+5]=0;tempsalt[a+6]=0;tempsalt[a+7]=0;tempsalt[a+8]=0;
        salt.s0=salt.s4=salt.s8=salt.sB=0;
        salt.sC=strlen(tempsalt)-6;
        salt.sE=(tempsalt[6])|(tempsalt[7]<<8)|(tempsalt[8]<<16)|(tempsalt[9]<<24);
        salt.sF=(tempsalt[10])|(tempsalt[11]<<8)|(tempsalt[12]<<16)|(tempsalt[13]<<24);
        salt.sD=cc1;
        salt.sB=cc;
        salt.s9=4;
        salt.sA=('a')|('p'<<8)|('r'<<16)|('1'<<24);

	_clSetKernelArg(rule_kernel162[cc][self], 5, sizeof(cl_uint16), (void*) &salt);
	_clSetKernelArg(rule_kernel16[cc1][self], 5, sizeof(cl_uint16), (void*) &salt);
	_clSetKernelArg(rule_kernel162[cc][self], 0, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);

        unsigned char mhash[22];
        memcpy(base64,mylist->hash,22);
        b64_pton_crypt(base64,mhash);
        unsigned int A,B,C,D;
        memcpy(hex1,mhash,4);
        memcpy(&A, hex1, 4);
        memcpy(hex1,mhash+4,4);
        memcpy(&B, hex1, 4);
        memcpy(hex1,mhash+8,4);
        memcpy(&C, hex1, 4);
        memcpy(hex1,mhash+12,4);
        memcpy(&D, hex1, 4);
	singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
	_clSetKernelArg(rule_kernel16[cc1][self], 4, sizeof(cl_uint4), (void*) &singlehash);

        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);

	gws = (rule_counts[self][cc] / wthreads[self].vectorsize);
	while ((gws%64)!=0) gws++;
	gws1 = gws*wthreads[self].vectorsize;
	if (gws1==0) gws1=64;
	if (gws==0) gws=64;
        wthreads[self].tries+=(gws1)/get_hashes_num();
        _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel162[cc][self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel16[cc1][self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
        found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
        if (err!=CL_SUCCESS) continue;
        if (*found>0) 
        {
            _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<ocl_rule_workset[self];a++)
	    if (rule_found_ind[self]!=0)
	    {
		b=a*wthreads[self].vectorsize;
    		_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*hash_ret_len1, hash_ret_len1*wthreads[self].vectorsize, rule_ptr[self]+b*hash_ret_len1, 0, NULL, NULL);
		for (c=0;c<wthreads[self].vectorsize;c++)
		{
	    	    e=(a)*wthreads[self].vectorsize+c;
                    unsigned char mhash[20];
                    memcpy(base64,mylist->hash,22);
                    b64_pton_crypt(base64,mhash);
    		    if (memcmp(mhash, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1-1) == 0)
    		    {
            		int flag = 0;
                	strcpy(plain,&rule_images162[cc][self][0]+(e*16));
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



static void ocl_apr1_callback(char *line, int self)
{
    int cc;

    cc=strlen(line);
    if (cc>15) cc=15;
    rule_counts[self][cc]++;
    strncpy(&rule_images162[cc][self][0]+(rule_counts[self][cc]*16),line,15);

    if (rule_counts[self][cc]==ocl_rule_workset[self]*wthreads[self].vectorsize-1)
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes162[self], 0, NULL, NULL);
	self_kernel16[self]=cc;
	rule_offload_perform(ocl_apr1_crack_callback,self);
    	bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
	rule_counts[self][cc]=-1;
    }

    if (line[0]==0x01)
    for (cc=1;cc<16;cc++)
    {
	self_kernel16[self]=cc;
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes162[self], 0, NULL, NULL);
	rule_offload_perform(ocl_apr1_crack_callback,self);
    	bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
	rule_counts[self][cc]=-1;
    }
    if (attack_over!=0) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_apr1_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    int a;
    char kernelname[32];

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*256;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);

    for (a=0;a<16;a++)
    {
	sprintf(kernelname,"md5unix%d",a);
	rule_kernel16[a][self] = _clCreateKernel(program[self], kernelname, &err );
	rule_kernel162[a][self] = _clCreateKernel(program[self], "strmodify", &err );
    }

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    for (a=0;a<16;a++)
    {
        rule_images16_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*16, NULL, &err );
        rule_images162_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*16, NULL, &err );
        rule_sizes16_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), NULL, &err );
        rule_sizes162_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), NULL, &err );
        rule_sizes16[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
        rule_sizes162[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
        rule_images16[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        rule_images162[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        bzero(&rule_images16[a][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
	_clSetKernelArg(rule_kernel16[a][self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
	_clSetKernelArg(rule_kernel16[a][self], 1, sizeof(cl_mem), (void*) &rule_images16_buf[a][self]);
	_clSetKernelArg(rule_kernel16[a][self], 2, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
	_clSetKernelArg(rule_kernel16[a][self], 3, sizeof(cl_mem), (void*) &rule_found_buf[self]);
        _clSetKernelArg(rule_kernel162[a][self], 0, sizeof(cl_mem), (void*) &rule_images16_buf[a][self]);
        _clSetKernelArg(rule_kernel162[a][self], 1, sizeof(cl_mem), (void*) &rule_images162_buf[a][self]);
        _clSetKernelArg(rule_kernel162[a][self], 2, sizeof(cl_mem), (void*) &rule_sizes16_buf[a][self]);
        _clSetKernelArg(rule_kernel162[a][self], 3, sizeof(cl_mem), (void*) &rule_sizes162_buf[a][self]);
        rule_counts[self][a]=-1;
    }
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_apr1_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_apr1(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_apr1(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_apr1(void)
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_md5unix__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5unix__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_apr1_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_apr1_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

