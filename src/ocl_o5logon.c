/*
 * ocl_o5logon.c
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


/* Crack callback */
static void ocl_o5logon_crack_callback(char *line, int self)
{
    int a,e;
    int *found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];
    char hex1[16];
    cl_uint16 salt;
    cl_uint16 singlehash;
    unsigned char saltc[10];

    if (ocl_rule_opt_counts[self]==0)
    {
        bzero(&addline1[self],sizeof(cl_uint16));
        bzero(&addline2[self],sizeof(cl_uint16));
    }
    strcpy(addlines[self][ocl_rule_opt_counts[self]],line);
    switch (ocl_rule_opt_counts[self])
    {
        case 0:
            addline1[self].sC=strlen(line);
            addline1[self].s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
            addline1[self].s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
            addline1[self].s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
            addline1[self].s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
            break;
        case 1:
            addline1[self].sD=strlen(line);
            addline1[self].s4=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
            addline1[self].s5=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
            addline1[self].s6=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
            addline1[self].s7=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
            break;
        case 2:
            addline1[self].sE=strlen(line);
            addline1[self].s8=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
            addline1[self].s9=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
            addline1[self].sA=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
            addline1[self].sB=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
            break;
        case 3:
            addline2[self].sC=strlen(line);
            addline2[self].s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
            addline2[self].s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
            addline2[self].s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
            addline2[self].s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
            break;
    }
    ocl_rule_opt_counts[self]++;

    if ((line[0]==0)||(ocl_rule_opt_counts[self]>=wthreads[self].vectorsize))
    {
        mylist = hash_list;
        while (mylist)
        {
            if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}

            _clSetKernelArg(rule_kernel[self], 7, sizeof(cl_uint16), (void*) &addline1[self]);
            _clSetKernelArg(rule_kernel[self], 8, sizeof(cl_uint16), (void*) &addline2[self]);
            _clSetKernelArg(rule_kernel2[self], 7, sizeof(cl_uint16), (void*) &addline1[self]);
            _clSetKernelArg(rule_kernel2[self], 8, sizeof(cl_uint16), (void*) &addline2[self]);

            if (attack_over!=0) pthread_exit(NULL);
            pthread_mutex_lock(&wthreads[self].tempmutex);
            pthread_mutex_unlock(&wthreads[self].tempmutex);
            wthreads[self].tries+=ocl_rule_workset[self]*ocl_rule_opt_counts[self];

            /* setup salt */
	    hex2str((char *)saltc, (char *)mylist->salt, 20);
	    salt.s0=salt.s1=salt.s2=salt.s3=salt.s4=salt.s5=salt.s6=salt.s7=salt.sF=0;
	    salt.sD=saltc[0]|(saltc[1]<<8)|(saltc[2]<<16)|(saltc[3]<<24);
	    salt.sE=saltc[4]|(saltc[5]<<8)|(saltc[6]<<16)|(saltc[7]<<24);
	    salt.sF=saltc[8]|(saltc[9]<<8);
	    unsigned char *block = (unsigned char *)(mylist->hash+16);
	    salt.s0=(block[3])|(block[2]<<8)|(block[1]<<16)|(block[0]<<24);
	    salt.s1=(block[7])|(block[6]<<8)|(block[5]<<16)|(block[4]<<24);
	    salt.s2=(block[11])|(block[10]<<8)|(block[9]<<16)|(block[8]<<24);
	    salt.s3=(block[15])|(block[14]<<8)|(block[13]<<16)|(block[12]<<24);
	    salt.s4=(block[19])|(block[18]<<8)|(block[17]<<16)|(block[16]<<24);
	    salt.s5=(block[23])|(block[22]<<8)|(block[21]<<16)|(block[20]<<24);
	    salt.s6=(block[27])|(block[26]<<8)|(block[25]<<16)|(block[24]<<24);
	    salt.s7=(block[31])|(block[30]<<8)|(block[29]<<16)|(block[28]<<24);

	    _clSetKernelArg(rule_kernel[self], 6, sizeof(cl_uint16), (void*) &salt);
	    _clSetKernelArg(rule_kernel2[self], 6, sizeof(cl_uint16), (void*) &salt);

            memcpy(hex1,mylist->hash,4); 
            unsigned int A,B,C,D; 
            memcpy(&A, hex1, 4); 
            memcpy(hex1,mylist->hash+4,4); 
            memcpy(&B, hex1, 4); 
            memcpy(hex1,mylist->hash+8,4); 
            memcpy(&C, hex1, 4); 
            memcpy(hex1,mylist->hash+12,4); 
            memcpy(&D, hex1, 4); 
            singlehash.x=A;
            singlehash.y=B;
            singlehash.z=C;
            singlehash.w=D;
            _clSetKernelArg(rule_kernel[self], 5, sizeof(cl_uint4), (void*) &singlehash);
            _clSetKernelArg(rule_kernel2[self], 5, sizeof(cl_uint4), (void*) &singlehash);

            _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
            size_t nws = ocl_rule_workset[self]*wthreads[self].vectorsize;
            _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
            found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
            if (*found>0) 
            {
                _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize, rule_found_ind[self], 0, NULL, NULL);
                for (a=0;a<ocl_rule_workset[self]*wthreads[self].vectorsize;a++)
                if (rule_found_ind[self][a]==1)
                {
                    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, a*hash_ret_len1, hash_ret_len1, rule_ptr[self]+a*hash_ret_len1, 0, NULL, NULL);
                    e=a;
                    if (memcmp("\x08\x08\x08\x08\x08\x08\x08\x08", (char *)rule_ptr[self]+(e)*hash_ret_len1+8, 8) == 0)
                    {
                        int flag = 0;
                        strcpy(plain,&rule_images[self][0]+((a*MAX)/wthreads[self].vectorsize));
                        strcat(plain,addlines[self][a%wthreads[self].vectorsize]);
                        pthread_mutex_lock(&crackedmutex);
                        addlist = cracked_list;
                        while (addlist)
                        {
                            if ((memcmp(addlist->hash, mylist->hash, hash_ret_len1) == 0) && (strcmp(addlist->username, mylist->username) == 0))
                            flag = 1;
                            addlist = addlist->next;
                        }
                        pthread_mutex_unlock(&crackedmutex);
                        if (flag == 0)
                        {
                            mylist->salt2[0]=1;
                            add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                        }
                    }
                }
                bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
                _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
                *found = 0;
                _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
            }
            _clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
            mylist=mylist->next;
        }
        ocl_rule_opt_counts[self]=0;
    }
}



static void ocl_o5logon_callback(char *line, int self)
{
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=(ocl_rule_workset[self]-1))||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_o5logon_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_o5logon_thread(void *arg)
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
    ocl_rule_workset[self]=128*128;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;

    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=-1;
    rule_kernel[self] = _clCreateKernel(program[self], "o5logonsha", &err );
    rule_kernel2[self] = _clCreateKernel(program[self], "o5logonaes", &err );
    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );

    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize);
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]*wthreads[self].vectorsize);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize, NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*20*wthreads[self].vectorsize, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*20*wthreads[self].vectorsize);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*20*wthreads[self].vectorsize);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*sizeof(cl_uint));
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernel2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_o5logon_callback);

    return hash_ok;
}





hash_stat ocl_bruteforce_o5logon(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_o5logon(void)
{
    suggest_rule_attack();
    return hash_ok;
}



/* Main thread - rule */
hash_stat ocl_rule_o5logon(void)
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_o5logon__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_o5logon__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_o5logon_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_o5logon_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

