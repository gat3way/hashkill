/*
 * ocl_mozilla.c
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
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/types.h>
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



static unsigned char globalsalt[20];
static unsigned char entrysalt[20];
static unsigned char verifier[16];
static char *encver="password-check\x00\x00";

hash_stat load_mozilla(char *filename)
{
    int fd;
    off_t size;
    char *buf;
    char *tok;
    unsigned char pwdcheck[52];

    memset(entrysalt,0,64);
    fd = open(filename, O_RDONLY);
    if (fd < 1) return hash_err;
    size = lseek(fd,0,SEEK_END);
    lseek(fd,0,SEEK_SET);
    buf = malloc(size);
    read(fd,buf,size);
    close(fd);

    tok = (char *)memmem(buf, size, "global-salt", strlen("global-salt"));
    if (!tok) 
    {
        free(buf);
        return hash_err;
    }
    tok -= 20;
    memcpy(globalsalt,tok,20);
    tok = (char *)memmem(buf, size, "password-check", strlen("password-check"));
    if (!tok) 
    {
        free(buf);
        return hash_err;
    }
    tok -= 52;
    memcpy(pwdcheck,tok,52);
    memcpy(entrysalt,&pwdcheck[3],20);
    memcpy(verifier,&pwdcheck[52-16],16);
    free(buf);
    return hash_ok;
}


static void ocl_set_params(int loopnr, cl_uint4 param1,cl_uint16 *p1, cl_uint16 *p2)
{
    switch (loopnr)
    {
	case 0:
	    p1->s0=param1.s0;
	    p1->s1=param1.s1;
	    p1->s2=param1.s2;
	    p1->s3=param1.s3;
	    p1->s4=(globalsalt[0]&255)|((globalsalt[1]&255)<<8)|((globalsalt[2]&255)<<16)|((globalsalt[3]&255)<<24);
	    p1->s5=(globalsalt[4]&255)|((globalsalt[5]&255)<<8)|((globalsalt[6]&255)<<16)|((globalsalt[7]&255)<<24);
	    p1->s6=(globalsalt[8]&255)|((globalsalt[9]&255)<<8)|((globalsalt[10]&255)<<16)|((globalsalt[11]&255)<<24);
	    p1->s7=(globalsalt[12]&255)|((globalsalt[13]&255)<<8)|((globalsalt[14]&255)<<16)|((globalsalt[15]&255)<<24);
	    p1->s8=(globalsalt[16]&255)|((globalsalt[17]&255)<<8)|((globalsalt[18]&255)<<16)|((globalsalt[19]&255)<<24);
	    p1->s9=(verifier[0]&255)|((verifier[1]&255)<<8)|((verifier[2]&255)<<16)|((verifier[3]&255)<<24);
	    p1->sA=(verifier[4]&255)|((verifier[5]&255)<<8)|((verifier[6]&255)<<16)|((verifier[7]&255)<<24);
	    p1->sB=(verifier[8]&255)|((verifier[9]&255)<<8)|((verifier[10]&255)<<16)|((verifier[11]&255)<<24);
	    p1->sC=(verifier[12]&255)|((verifier[13]&255)<<8)|((verifier[14]&255)<<16)|((verifier[15]&255)<<24);
	    p2->s4=(entrysalt[0]&255)|((entrysalt[1]&255)<<8)|((entrysalt[2]&255)<<16)|((entrysalt[3]&255)<<24);
	    p2->s5=(entrysalt[4]&255)|((entrysalt[5]&255)<<8)|((entrysalt[6]&255)<<16)|((entrysalt[7]&255)<<24);
	    p2->s6=(entrysalt[8]&255)|((entrysalt[9]&255)<<8)|((entrysalt[10]&255)<<16)|((entrysalt[11]&255)<<24);
	    p2->s7=(entrysalt[12]&255)|((entrysalt[13]&255)<<8)|((entrysalt[14]&255)<<16)|((entrysalt[15]&255)<<24);
	    p2->s8=(entrysalt[16]&255)|((entrysalt[17]&255)<<8)|((entrysalt[18]&255)<<16)|((entrysalt[19]&255)<<24);
	    p2->s9=(encver[0]&255)|((encver[1]&255)<<8)|((encver[2]&255)<<16)|((encver[3]&255)<<24);
	    p2->sA=(encver[4]&255)|((encver[5]&255)<<8)|((encver[6]&255)<<16)|((encver[7]&255)<<24);
	    p2->sB=(encver[8]&255)|((encver[9]&255)<<8)|((encver[10]&255)<<16)|((encver[11]&255)<<24);
	    p2->sC=(encver[12]&255)|((encver[13]&255)<<8)|((encver[14]&255)<<16)|((encver[15]&255)<<24);
	    break;
	case 1:
	    p2->s0=param1.s0;
	    p2->s1=param1.s1;
	    p2->s2=param1.s2;
	    p2->s3=param1.s3;
	    p1->s4=(globalsalt[0]&255)|((globalsalt[1]&255)<<8)|((globalsalt[2]&255)<<16)|((globalsalt[3]&255)<<24);
	    p1->s5=(globalsalt[4]&255)|((globalsalt[5]&255)<<8)|((globalsalt[6]&255)<<16)|((globalsalt[7]&255)<<24);
	    p1->s6=(globalsalt[8]&255)|((globalsalt[9]&255)<<8)|((globalsalt[10]&255)<<16)|((globalsalt[11]&255)<<24);
	    p1->s7=(globalsalt[12]&255)|((globalsalt[13]&255)<<8)|((globalsalt[14]&255)<<16)|((globalsalt[15]&255)<<24);
	    p1->s8=(globalsalt[16]&255)|((globalsalt[17]&255)<<8)|((globalsalt[18]&255)<<16)|((globalsalt[19]&255)<<24);
	    p1->s9=(verifier[0]&255)|((verifier[1]&255)<<8)|((verifier[2]&255)<<16)|((verifier[3]&255)<<24);
	    p1->sA=(verifier[4]&255)|((verifier[5]&255)<<8)|((verifier[6]&255)<<16)|((verifier[7]&255)<<24);
	    p1->sB=(verifier[8]&255)|((verifier[9]&255)<<8)|((verifier[10]&255)<<16)|((verifier[11]&255)<<24);
	    p1->sC=(verifier[12]&255)|((verifier[13]&255)<<8)|((verifier[14]&255)<<16)|((verifier[15]&255)<<24);
	    p2->s4=(entrysalt[0]&255)|((entrysalt[1]&255)<<8)|((entrysalt[2]&255)<<16)|((entrysalt[3]&255)<<24);
	    p2->s5=(entrysalt[4]&255)|((entrysalt[5]&255)<<8)|((entrysalt[6]&255)<<16)|((entrysalt[7]&255)<<24);
	    p2->s6=(entrysalt[8]&255)|((entrysalt[9]&255)<<8)|((entrysalt[10]&255)<<16)|((entrysalt[11]&255)<<24);
	    p2->s7=(entrysalt[12]&255)|((entrysalt[13]&255)<<8)|((entrysalt[14]&255)<<16)|((entrysalt[15]&255)<<24);
	    p2->s8=(entrysalt[16]&255)|((entrysalt[17]&255)<<8)|((entrysalt[18]&255)<<16)|((entrysalt[19]&255)<<24);
	    p2->s9=(encver[0]&255)|((encver[1]&255)<<8)|((encver[2]&255)<<16)|((encver[3]&255)<<24);
	    p2->sA=(encver[4]&255)|((encver[5]&255)<<8)|((encver[6]&255)<<16)|((encver[7]&255)<<24);
	    p2->sB=(encver[8]&255)|((encver[9]&255)<<8)|((encver[10]&255)<<16)|((encver[11]&255)<<24);
	    p2->sC=(encver[12]&255)|((encver[13]&255)<<8)|((encver[14]&255)<<16)|((encver[15]&255)<<24);
	    break;
	}
}



static void ocl_get_cracked(cl_command_queue queuein,cl_mem plains_buf, char *plains, cl_mem hashes_buf, char *hashes, int numfound, int vsize, int hashlen)
{
    int a,b;
    char plain[16];

    if (numfound>MAXFOUND) 
    {
	printf("error found=%d\n",numfound);
	return;
    }

    _clEnqueueReadBuffer(queuein, plains_buf, CL_TRUE, 0, 16*numfound*vsize, plains, 0, NULL, NULL);
    _clEnqueueReadBuffer(queuein, hashes_buf, CL_TRUE, 0, hashlen*numfound*vsize, hashes, 0, NULL, NULL);

    for (a=0;a<numfound;a++)
    for (b=0;b<vsize;b++)
    if (memcmp("password-check", (char *)hashes+(a*vsize+b)*16, 14) == 0)
    {
    	memcpy(plain,&plains[0]+((a*vsize+b)*16),16);
    	plain[strlen(plain)-1] = 0;
    	if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
    }
}




static void markov_sched_setlimits()
{
    int a,b,c;
    int e1,e2,e3,etemp,charset_size=strlen(markov_charset);\

    e1=e2=e3=0;
    if (fast_markov == 1)
    {
	charset_size = charset_size - 23;
	if (session_restore_flag==0) markov_threshold = (markov_threshold*3)/2;
    }
    reduced_size=0;
    for (a=0;a<charset_size;a++) if (markov0[a]>markov_threshold)
    {
	reduced_charset[reduced_size]=markov_charset[a];
	// Create markov2 table
	for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
	reduced_size++;
	reduced_charset[reduced_size]=0;
    }

    if (session_restore_flag==0)
    {
	scheduler.markov_l1 = reduced_size;
	for (a=0;a<reduced_size;a++)
	{
	    etemp = 0;
	    for (b=0;b<strlen(markov_charset);b++)
	    if (markov2[a][b]>markov_threshold) etemp++;

	    if (etemp>0)
	    {
		e1=a;
		e2=etemp;
	    }
	    scheduler.ebitmap2[a]=etemp;
	}
	scheduler.markov_l2_1 = e1;
	scheduler.markov_l2_2 = e2;

	for (a=0;a<reduced_size;a++)
	for (b=0;b<strlen(markov_charset);b++)
	if (markov2[a][b]>markov_threshold)
	{
	    etemp = 0;
	    for (c=0;c<strlen(markov_charset);c++)
	    if (markov1[b][c]>markov_threshold) etemp++;

	    if (etemp>0)
	    {
		e1=a;
		e2=b;
		e3=etemp;
	    }
	    scheduler.ebitmap3[a][b]=etemp;
	}
	else scheduler.ebitmap3[a][b]=0;
	scheduler.markov_l3_1 = e1;
	scheduler.markov_l3_2 = e2;
	scheduler.markov_l3_3 = e3;
    }
}



/* Markov initializer */
static void init_markov()
{
    int a,b,charset_size;

    charset_size = strlen(markov_charset);
    table = malloc(charset_size*charset_size*charset_size*4);
    if (fast_markov == 1)
    {
	charset_size = charset_size - 23;
	if (session_restore_flag==0) markov_threshold = (markov_threshold*3)/2;
    }
    reduced_size=0;
    for (a=0;a<charset_size;a++) if (markov0[a]>markov_threshold)
    {
	reduced_charset[reduced_size]=markov_charset[a];
	// Create markov2 table
	for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
	reduced_size++;
	reduced_charset[reduced_size]=0;
    }

    for (a=0;a<strlen(markov_charset);a++)
    for (b=0;b<strlen(markov_charset);b++)
    {
	table[a*strlen(markov_charset)+b] = (markov_charset[a]<<8)|(markov_charset[b]);
    }

}

/* Markov deinit */
static void deinit_markov()
{
    free(table);
}


/* Bruteforce initializer big charsets */
static void init_bruteforce_long()
{
    int a,b;

    table = malloc(128*128*4);

    for (a=0;a<strlen(bruteforce_charset);a++)
    for (b=0;b<strlen(bruteforce_charset);b++)
    {
	table[a*strlen(bruteforce_charset)+b] = (bruteforce_charset[a]<<8)|(bruteforce_charset[b]);
    }
}


/* Bruteforce deinit */
static void deinit_bruteforce()
{
    free(table);
}



/* Execute kernel, flush parameters */
static void ocl_execute(cl_command_queue queue, cl_kernel kernel, size_t *global_work_size, size_t *local_work_size, int charset_size, cl_mem found_buf, cl_mem hashes_buf, cl_mem plains_buf, char *plains, char * hashes,int self, cl_uint16 *p1,cl_uint16 *p2)
{
    int err;
    int *found;
    int try;
    int a;
    size_t lglobal_work_size[3];
    size_t offset[3];

    _clSetKernelArg(kernel, 5, sizeof(cl_uint16), (void*) p1);
    _clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) p2);

    for (a=0;a<wthreads[self].loops;a++)
    {
	if (interactive_mode==1)
	{
	    for (try=0;try<64;try++)
	    {
		lglobal_work_size[0]=global_work_size[0];
		lglobal_work_size[1]=(global_work_size[1]+63)/64;
		offset[1] = try*lglobal_work_size[1];
		offset[0] = 0;
		if (attack_over!=0) pthread_exit(NULL);
		_clEnqueueNDRangeKernel(queue, kernel, 2, offset, lglobal_work_size, local_work_size, 0, NULL, NULL);
		found = _clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
		if (*found>0) 
		{
    		    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len1);
    		    bzero(plains,16*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    		    // Change for other types
    		    bzero(hashes,hash_ret_len1*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);
    		    *found = 0;
    		    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
		}
    		_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
		wthreads[self].tries += (charset_size*charset_size*charset_size*charset_size*wthreads[self].loops)/(128);
	    }
	}
	else
	{
	    for (try=0;try<16;try++)
	    {
		lglobal_work_size[0]=global_work_size[0];
		lglobal_work_size[1]=(global_work_size[1]+15)/16;
		offset[1] = try*lglobal_work_size[1];
		offset[0] = 0;
		if (attack_over!=0) pthread_exit(NULL);
		_clEnqueueNDRangeKernel(queue, kernel, 2, offset, lglobal_work_size, local_work_size, 0, NULL, NULL);
		found = _clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
		if (*found>0) 
		{
    		    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len1);
    		    bzero(plains,16*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    		    // Change for other types
    		    bzero(hashes,hash_ret_len1*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);
    		    *found = 0;
    		    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
		}
    		_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
		wthreads[self].tries += (charset_size*charset_size*charset_size*charset_size*wthreads[self].loops)/(16);
	    }
	}
    }
    wthreads[self].currentsalt++;
    if (wthreads[self].currentsalt==get_hashes_num())
    {
        attack_current_count += wthreads[self].loops;
        wthreads[self].currentsalt=0;
    }
}




/* Bruteforce larger charsets */
void* ocl_bruteforce_mozilla_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    int try=0;
    char *hashes;
    int charset_size = (int)strlen(bruteforce_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    struct  hash_list_s  *mylist;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 p1;
    cl_uint16 p2;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;
    char candidate[16];

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "mozilla_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "mozilla_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );

    // Change for other lens
    hashes  = malloc(hash_ret_len1*8*MAXFOUND); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len1*8*MAXFOUND, NULL, &err );
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,16*8*MAXFOUND);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);


    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    table_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 128*128*4,table , &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);

    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    _clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &found_buf);
    _clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (charset_size*charset_size);
    global_work_size[1] = (charset_size*charset_size);
    while ((global_work_size[0] % local_work_size[0])!=0) global_work_size[0]++;
    while ((global_work_size[1] % (wthreads[self].vectorsize))!=0) global_work_size[1]++;
    global_work_size[1] = global_work_size[1]/wthreads[self].vectorsize;
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 


    /* Bruteforce, len=4 */

    csize=24<<3;
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (attack_over!=0) goto out;
    mylist = hash_list;
    try=0;
    while (mylist)
    {
	if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
        bzero(candidate,16);
	image.y=0x80;image.z=0;image.w=0;
	ocl_set_params(try,image,&p1,&p2);
	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
	    try=0;
	}
	mylist = mylist->next;
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
    if (bruteforce_end==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* bruteforce, len=5 */

    csize=25<<3;
    sched_wait(5);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    if (bruteforce_end>=5)
    while ((sched_len()==5)&&((a1=sched_s1())<sched_e1()))
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=bruteforce_charset[a1];
	    image.y=(bruteforce_charset[a1])|(0x80<<8);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=6 */
    csize=26<<3;
    sched_wait(6);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    if (bruteforce_end>=6)
    for (a1=0;a1<charset_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(0x80<<16);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=7 */

    csize=27<<3;
    sched_wait(7);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    if (bruteforce_end>=7)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=8 */

    csize=28<<3;
    sched_wait(8);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    if (bruteforce_end>=8)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=0x80;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=9 */
    csize=29<<3;
    sched_wait(9);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    if (bruteforce_end>=9)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(0x80<<8);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=10 */

    csize=30<<3;
    sched_wait(10);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    if (bruteforce_end>=10)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(0x80<<16);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=11 */

    csize=31<<3;
    sched_wait(11);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    if (bruteforce_end>=11)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
    	    candidate[6]=(bruteforce_charset[a7]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(0x80<<24);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=12 */

    csize=32<<3;
    sched_wait(12);
    if (sched_len()==12)
    if (bruteforce_end>=12)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
    	    candidate[6]=(bruteforce_charset[a7]);
    	    candidate[7]=(bruteforce_charset[a8]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	    image.w=0x80;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=13 */

    csize=33<<3;
    sched_wait(13);
    if (sched_len()==13)
    if (bruteforce_end>=13)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==13)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
    	    candidate[6]=(bruteforce_charset[a7]);
    	    candidate[7]=(bruteforce_charset[a8]);
    	    candidate[8]=(bruteforce_charset[a9]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	    image.w=(bruteforce_charset[a9])|(0x80<<8);
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=14 */

    csize=34<<3;
    sched_wait(14);
    if (sched_len()==14)
    if (bruteforce_end>=14)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==13)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    for (a10=0;a10<charset_size;a10++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
    	    candidate[6]=(bruteforce_charset[a7]);
    	    candidate[7]=(bruteforce_charset[a8]);
    	    candidate[8]=(bruteforce_charset[a9]);
    	    candidate[9]=(bruteforce_charset[a10]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	    image.w=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(0x80<<16);
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* bruteforce, len=15 */

    csize=35<<3;
    sched_wait(15);
    if (sched_len()==15)
    if (bruteforce_end>=15)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==15)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    for (a10=0;a10<charset_size;a10++) 
    for (a11=0;a11<charset_size;a11++) 
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
    	    candidate[4]=(bruteforce_charset[a5]);
    	    candidate[5]=(bruteforce_charset[a6]);
    	    candidate[6]=(bruteforce_charset[a7]);
    	    candidate[7]=(bruteforce_charset[a8]);
    	    candidate[8]=(bruteforce_charset[a9]);
    	    candidate[9]=(bruteforce_charset[a10]);
    	    candidate[10]=(bruteforce_charset[a11]);
	    
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	    image.w=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(bruteforce_charset[a11]<<16)|(0x80<<24);
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    out:
    free(hashes);
    free(plains);
    return hash_ok;
}





void* ocl_markov_mozilla_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4,a5,a6,a7,a8;
    int try=0;
    char *hashes;
    int charset_size = (int)strlen(markov_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    struct  hash_list_s  *mylist;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 p1;
    cl_uint16 p2;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;
    char candidate[16];

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "mozilla_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "mozilla_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );

    // Change for other lens
    hashes  = malloc(hash_ret_len1*8*MAXFOUND); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len1*8*MAXFOUND, NULL, &err );
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,hash_ret_len1*8*MAXFOUND);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);
    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    table_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 128*128*4,table , &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);

    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    _clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &found_buf);
    _clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (charset_size*charset_size);
    global_work_size[1] = (charset_size*charset_size);
    while ((global_work_size[0] %  local_work_size[0])!=0) global_work_size[0]++;
    while ((global_work_size[1] % (wthreads[self].vectorsize))!=0) global_work_size[1]++;
    global_work_size[1] = global_work_size[1]/wthreads[self].vectorsize;
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 



    /* markov, len=4 */

    csize=24<<3;
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (attack_over!=0) goto out;
    mylist = hash_list;
    try=0;
    while (mylist)
    {
	if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
        bzero(candidate,16);
	
	image.y=0x80;image.z=0;image.w=0;
	ocl_set_params(try,image,&p1,&p2);
	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
	    try=0;
	}
	mylist = mylist->next;
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
    if (markov_max_len==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* markov, len=5 */

    csize=25<<3;
    sched_wait(5);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    if (markov_max_len>=5)
    while ((sched_len()==5)&&((a1=sched_s1())<sched_e1()))
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
	    
	    image.y=(reduced_charset[a1])|(0x80<<8);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* markov, len=6 */
    csize=26<<3;
    sched_wait(6);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    if (markov_max_len>=6)
    for (a1=0;a1<reduced_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    if (markov2[a1][a2]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(0x80<<16);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);



    /* markov, len=7 */

    csize=27<<3;
    sched_wait(7);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    if (markov_max_len>=7)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(0x80<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);



    /* markov, len=8 */

    csize=28<<3;
    sched_wait(8);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    if (markov_max_len>=8)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=0x80;
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* markov, len=9 */
    csize=29<<3;
    sched_wait(9);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    if (markov_max_len>=9)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
    	    candidate[4]=reduced_charset[a5];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=(reduced_charset[a5])|(0x80<<8);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* markov, len=10 */

    csize=30<<3;
    sched_wait(10);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    if (markov_max_len>=10)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
    	    candidate[4]=reduced_charset[a5];
    	    candidate[5]=reduced_charset[a6];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=(reduced_charset[a5])|(reduced_charset[a6]<<8)|(0x80<<16);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* markov, len=11 */

    csize=31<3;
    sched_wait(11);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    if (markov_max_len>=11)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++)
    if (markov1[a6][a7]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
    	    candidate[4]=reduced_charset[a5];
    	    candidate[5]=reduced_charset[a6];
    	    candidate[6]=reduced_charset[a7];
	    
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=(reduced_charset[a5])|(reduced_charset[a6]<<8)|(reduced_charset[a7]<<16)|(0x80<<24);
	    image.w=0;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);


    /* markov, len=12 */

    csize=32<<3;
    sched_wait(12);
    if (sched_len()==12)
    if (markov_max_len>=12)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++)
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    {
	mylist = hash_list;
	while (mylist)
	{
	    if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}
    	    pthread_mutex_lock(&wthreads[self].tempmutex);
    	    pthread_mutex_unlock(&wthreads[self].tempmutex);
	    if (attack_over!=0) goto out;
    	    bzero(candidate,16);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
    	    candidate[4]=reduced_charset[a5];
    	    candidate[5]=reduced_charset[a6];
    	    candidate[6]=reduced_charset[a7];
    	    candidate[7]=reduced_charset[a8];
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=(reduced_charset[a5])|(reduced_charset[a6]<<8)|(reduced_charset[a7]<<16)|(reduced_charset[a8]<<24);
	    image.w=0x80;
	    ocl_set_params(try,image,&p1,&p2);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2);

    out:
    free(hashes);
    free(plains);
    return hash_ok;
}


/* Crack callback */
static void ocl_mozilla_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    size_t gws,gws1;

    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/get_hashes_num();
    salt.s4=(globalsalt[0]&255)|((globalsalt[1]&255)<<8)|((globalsalt[2]&255)<<16)|((globalsalt[3]&255)<<24);
    salt.s5=(globalsalt[4]&255)|((globalsalt[5]&255)<<8)|((globalsalt[6]&255)<<16)|((globalsalt[7]&255)<<24);
    salt.s6=(globalsalt[8]&255)|((globalsalt[9]&255)<<8)|((globalsalt[10]&255)<<16)|((globalsalt[11]&255)<<24);
    salt.s7=(globalsalt[12]&255)|((globalsalt[13]&255)<<8)|((globalsalt[14]&255)<<16)|((globalsalt[15]&255)<<24);
    salt.s8=(globalsalt[16]&255)|((globalsalt[17]&255)<<8)|((globalsalt[18]&255)<<16)|((globalsalt[19]&255)<<24);
    salt.s9=(verifier[0]&255)|((verifier[1]&255)<<8)|((verifier[2]&255)<<16)|((verifier[3]&255)<<24);
    salt.sA=(verifier[4]&255)|((verifier[5]&255)<<8)|((verifier[6]&255)<<16)|((verifier[7]&255)<<24);
    salt.sB=(verifier[8]&255)|((verifier[9]&255)<<8)|((verifier[10]&255)<<16)|((verifier[11]&255)<<24);
    salt.sC=(verifier[12]&255)|((verifier[13]&255)<<8)|((verifier[14]&255)<<16)|((verifier[15]&255)<<24);
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
    addline.s4=(entrysalt[0]&255)|((entrysalt[1]&255)<<8)|((entrysalt[2]&255)<<16)|((entrysalt[3]&255)<<24);
    addline.s5=(entrysalt[4]&255)|((entrysalt[5]&255)<<8)|((entrysalt[6]&255)<<16)|((entrysalt[7]&255)<<24);
    addline.s6=(entrysalt[8]&255)|((entrysalt[9]&255)<<8)|((entrysalt[10]&255)<<16)|((entrysalt[11]&255)<<24);
    addline.s7=(entrysalt[12]&255)|((entrysalt[13]&255)<<8)|((entrysalt[14]&255)<<16)|((entrysalt[15]&255)<<24);
    addline.s8=(entrysalt[16]&255)|((entrysalt[17]&255)<<8)|((entrysalt[18]&255)<<16)|((entrysalt[19]&255)<<24);
    addline.s9=(encver[0]&255)|((encver[1]&255)<<8)|((encver[2]&255)<<16)|((encver[3]&255)<<24);
    addline.sA=(encver[4]&255)|((encver[5]&255)<<8)|((encver[6]&255)<<16)|((encver[7]&255)<<24);
    addline.sB=(encver[8]&255)|((encver[9]&255)<<8)|((encver[10]&255)<<16)|((encver[11]&255)<<24);
    addline.sC=(encver[12]&255)|((encver[13]&255)<<8)|((encver[14]&255)<<16)|((encver[15]&255)<<24);
    
    _clSetKernelArg(rule_kernel2[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernel2[self], 6, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_uint16), (void*) &addline);

    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel2[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
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
                if (memcmp("password-check", (char *)rule_ptr[self]+(e)*hash_ret_len1,14) == 0)
                {
                    strncpy(plain,&rule_images[self][0]+(e*MAX),32);
                    strncat(plain,line,32);
                    if (!cracked_list)
                    {
                        //printf("vectorsize=%d plain=[%s]\n",wthreads[self].vectorsize,plain);
                        add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
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
}



static void ocl_mozilla_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=(ocl_rule_workset[self]*wthreads[self].vectorsize-1))||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*MAX*wthreads[self].vectorsize, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(int)*wthreads[self].vectorsize, rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_mozilla_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_mozilla_thread(void *arg)
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
    ocl_rule_workset[self]=256*256;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;

    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=-1;
    rule_kernel[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernel2[self] = _clCreateKernel(program[self], "prepare", &err );
    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );

    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*MAX*wthreads[self].vectorsize, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*MAX*wthreads[self].vectorsize, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize, NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize);
    rule_images[self]=malloc(ocl_rule_workset[self]*MAX*wthreads[self].vectorsize);
    rule_images2[self]=malloc(ocl_rule_workset[self]*MAX*wthreads[self].vectorsize);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX*wthreads[self].vectorsize);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*MAX*wthreads[self].vectorsize);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize);
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernel2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_mozilla_callback);

    return hash_ok;
}





hash_stat ocl_bruteforce_mozilla(void)
{
    int a,i;
    uint64_t bcnt;
    int err;
    int worker_thread_keys[32];

    bcnt=1;
    bruteforce_start=4;
    for (a=bruteforce_start;a<bruteforce_end;a++) bcnt*=strlen(bruteforce_charset);
    attack_overall_count = bcnt;
    if (hash_err == load_mozilla(hashlist_file)) return hash_err;

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

    init_bruteforce_long();
    scheduler_setup(bruteforce_start, 5, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_mozilla_long__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_mozilla_long__%s.ptx",DATADIR,pbuf);

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
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_bruteforce_mozilla_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);

    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}



hash_stat ocl_markov_mozilla(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_mozilla(hashlist_file)) return hash_err;
    if (fast_markov==1)  hlog("Fast markov attack mode enabled%s\n","");
    init_markov();
    markov_sched_setlimits();
    if (session_restore_flag==0) scheduler_setup(4, 5, markov_max_len, reduced_size, strlen(markov_charset));

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_mozilla_long__%s.bin",DATADIR,pbuf);

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
            err = _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_mozilla_long__%s.ptx",DATADIR,pbuf);

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
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
	worker_thread_keys[a]=a;
	pthread_create(&crack_threads[a], NULL, ocl_markov_mozilla_thread, &worker_thread_keys[a]);
    }
    
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) 
    {
	pthread_join(crack_threads[a], NULL);
    }
    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_markov;
    attack_over=2;
    return hash_ok;
}




/* Main thread - rule */
hash_stat ocl_rule_mozilla(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_mozilla(hashlist_file)) return hash_err;

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_mozilla__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_mozilla__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_mozilla_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_mozilla_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

