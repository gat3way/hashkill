/*
 * ocl_mscash2.c
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
#include <ctype.h>
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

static cl_uint16 ocl_get_salt(char *salt)
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    bzero(salt2,32);
    strcpy((char *)salt2,salt);
    for (len=0;len<strlen(salt);len++) 
    {
        salt2[len*2]=tolower(salt[len]);
        salt2[len*2+1]=0;
    }
    salt2[len*2]=0x80;
    t.s0=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s1=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.s2=salt2[8]|(salt2[9]<<8)|(salt2[10]<<16)|(salt2[11]<<24);
    t.s3=salt2[12]|(salt2[13]<<8)|(salt2[14]<<16)|(salt2[15]<<24);
    t.s4=salt2[16]|(salt2[17]<<8)|(salt2[18]<<16)|(salt2[19]<<24);
    t.s5=0;
    t.s6=0;
    t.s7=((strlen(salt)*2)+16)<<3;


    bzero(salt2,32);
    strcpy((char *)salt2,salt);
    for (len=0;len<strlen(salt);len++) 
    {
        salt2[len*2]=tolower(salt[len]);
        salt2[len*2+1]=0;
    }
    salt2[len*2]=0;
    salt2[len*2+1]=0;
    salt2[len*2+2]=0;
    salt2[len*2+3]=1;
    salt2[len*2+4]=0x80;

    t.s8=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s9=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.sA=salt2[8]|(salt2[9]<<8)|(salt2[10]<<16)|(salt2[11]<<24);
    t.sB=salt2[12]|(salt2[13]<<8)|(salt2[14]<<16)|(salt2[15]<<24);
    t.sC=salt2[16]|(salt2[17]<<8)|(salt2[18]<<16)|(salt2[19]<<24);
    t.sD=salt2[20]|(salt2[21]<<8)|(salt2[22]<<16)|(salt2[23]<<24);
    t.sE=0;
    t.sF=((strlen(salt)*2)+64+4)<<3;

    return t;
}






/* Crack callback */
static void ocl_mscash2_crack_callback(char *line, int self)
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
    char mhash[20];

    mylist = hash_list;
    while (mylist)
    {
        if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
	/* setup addline */
	addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
	addline.sF=strlen(line);
	addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
	addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
	addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
	addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

	/* setup salt */
	salt=ocl_get_salt(mylist->username);
	salt.sE=addline.sF;

        memcpy(mhash,mylist->hash,hash_ret_len1);
        unsigned int A,B,C,D;
        memcpy(hex1,mhash,4);
        memcpy(&A, hex1, 4);
        memcpy(hex1,mhash+4,4);
        memcpy(&B, hex1, 4);
        memcpy(hex1,mhash+8,4);
        memcpy(&C, hex1, 4);
        memcpy(hex1,mhash+12,4);
        memcpy(&D, hex1, 4);
	singlehash.x=A;
	singlehash.y=B;
	singlehash.z=C;
	singlehash.w=D;

        if (attack_over!=0) pthread_exit(NULL);
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);

        _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
        _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
        _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
        _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
	_clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &addline);
	_clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint16), (void*) &salt);

        _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
	_clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
	_clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt);

        _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
	_clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt);

        _clSetKernelArg(rule_kernellast[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
        _clSetKernelArg(rule_kernellast[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
        _clSetKernelArg(rule_kernellast[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
        _clSetKernelArg(rule_kernellast[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
        _clSetKernelArg(rule_kernellast[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
	_clSetKernelArg(rule_kernellast[self], 5, sizeof(cl_uint4), (void*) &singlehash);
	_clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);

        size_t nws=ocl_rule_workset[self]*wthreads[self].vectorsize;
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	for (a=0;a<10;a++)
	{
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
    	    wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/(get_hashes_num()*10);
	}
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);

        found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
        if (err!=CL_SUCCESS) continue;
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
    		    if (memcmp(mylist->hash, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1-1) == 0)
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



static void ocl_mscash2_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strncpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line,MAX);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_mscash2_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_mscash2_thread(void *arg)
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
    ocl_rule_workset[self]=64*128;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "pbkdf", &err );
    rule_kernellast[self] = _clCreateKernel(program[self], "final", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*76);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*76, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX*2);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*76);
    bzero(rule_sizes[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    bzero(rule_sizes2[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_mscash2_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_mscash2(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_mscash2(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_mscash2(void)
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_mscash2__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_mscash2__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_mscash2_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_mscash2_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

