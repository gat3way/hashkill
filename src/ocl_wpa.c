/*
 * ocl_wpa.c
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
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
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

typedef struct
{
    char          essid[36];
    unsigned char mac1[6];
    unsigned char mac2[6];
    unsigned char nonce1[32];
    unsigned char nonce2[32];
    unsigned char eapol[256];
    int           eapol_size;
    int           keyver;
    unsigned char keymic[16];
} hccap_t;

static hccap_t hccap;
static unsigned char ptkbuf[128];
static cl_mem block_buf[HASHKILL_MAXTHREADS];
static cl_mem eapol_buf[HASHKILL_MAXTHREADS];


static hash_stat load_hccap(char *filename)
{
    int fd,err;
    struct stat f_stat;
    
    err = stat(filename,&f_stat);
    if (err<0)
    {
        elog("Cannot stat file: %s\n",filename);
        exit(1);
    }
    if (f_stat.st_size!=392)
    {
        elog("Not a HCCAP file: %s\n",filename);
        exit(1);
    }

    fd = open(filename,O_RDONLY);
    if (fd<0)
    {
        elog("Cannot open pcap file: %s\n",filename);
        return hash_err;
    }
    read(fd,&hccap,sizeof(hccap_t));
    if (hccap.eapol_size>256)
    {
        elog("Cannot open pcap file: %s\n",filename);
        return hash_err;
    }

    /* Fix for hashcat format */
    if (memcmp(hccap.mac1,hccap.mac2,6)>0)
    {
        memcpy(&ptkbuf[0],hccap.mac2,6);
        memcpy(&ptkbuf[6],hccap.mac1,6);
    }
    else
    {
        memcpy(&ptkbuf[0],hccap.mac1,6);
        memcpy(&ptkbuf[6],hccap.mac2,6);
    }
    if (memcmp(hccap.nonce1,hccap.nonce2,32)>0)
    {
        memcpy(&ptkbuf[12],hccap.nonce2,32);
        memcpy(&ptkbuf[44],hccap.nonce1,32);
    }
    else
    {
        memcpy(&ptkbuf[12],hccap.nonce1,32);
        memcpy(&ptkbuf[44],hccap.nonce2,32);
    }

    close(fd);
    return hash_ok;
}


static cl_uint16 ocl_get_salt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    strcpy((char *)salt2,hccap.essid);
    len=strlen(hccap.essid);
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
    t.sF=((strlen(hccap.essid))+4+64)<<3;
    t.sE=(hccap.eapol_size+64)<<3;

    return t;
}

static cl_uint16 ocl_get_salt2()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[64];

    bzero(salt2,64);
    strcpy((char *)salt2,hccap.essid);
    len=strlen(hccap.essid);
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
    t.sF=((strlen(hccap.essid))+4+64)<<3;

    return t;
}



/* Crack callback */
static void ocl_wpa_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 salt2;
    size_t gws,gws1;

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
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    _clSetKernelArg(rule_kernelend[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelend[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 9, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 10, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelmod[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelmod[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 9, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre1[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl1[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre2[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre2[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl2[self], 6, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl2[self], 7, sizeof(cl_mem), (void*) &block_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 8, sizeof(cl_mem), (void*) &eapol_buf[self]);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=0;a<7;a++)
    {
	if (attack_over==1) pthread_exit(NULL);
	addline.sA=a*1170;
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/14;
    }

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre2[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=0;a<7;a++)
    {
	if (attack_over==1) pthread_exit(NULL);
	addline.sA=a*1170;
	_clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl2[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/14;
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);

    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    if (err!=CL_SUCCESS) return;
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
    	        if (memcmp(hccap.keymic, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1-1) == 0)
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



static void ocl_wpa_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strncpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line,MAX);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_wpa_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_wpa_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    unsigned char block[128];
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


    memcpy(block,"Pairwise key expansion",22);
    block[22]=0;
    memcpy(&block[23],ptkbuf,76);
    block[99]=0;


    block_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_ONLY, 100, NULL, &err );
    eapol_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_ONLY, 256, NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], block_buf[self], CL_TRUE, 0, 100, block, 0, NULL, NULL);
    hccap.eapol[hccap.eapol_size]=0x80;
    _clEnqueueWriteBuffer(rule_oclqueue[self], eapol_buf[self], CL_TRUE, 0, 256, hccap.eapol, 0, NULL, NULL);

    memcpy(hex1,hccap.keymic,4);
    unsigned int A,B,C,D;
    memcpy(&A, hex1, 4);
    memcpy(hex1,hccap.keymic+4,4);
    memcpy(&B, hex1, 4);
    memcpy(hex1,hccap.keymic+8,4);
    memcpy(&C, hex1, 4);
    memcpy(hex1,hccap.keymic+12,4);
    memcpy(&D, hex1, 4);
    singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelbl2[self], 5, sizeof(cl_uint4), (void*) &singlehash);
    _clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint4), (void*) &singlehash);

    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_wpa_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_wpa(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_wpa(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_wpa(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    load_hccap(hashlist_file);
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
    	    if (hccap.keyver==2) sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_wpa2__%s.bin",pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_wpa__%s.bin",DATADIR,pbuf);

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
    	    if (hccap.keyver==2) sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_wpa2__%s.ptx",pbuf);
            else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_wpa__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_wpa_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_wpa_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

