/*
 * ocl_desunix.c
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


#define SETUP_PARAMS() { \
        unsigned int A,B; \
        char mhash[20]; \
        char base64[64]; \
        memcpy(base64,mylist->hash,13); \
        b64_pton(base64+2,mhash); \
        memcpy(&A, mhash, 4); \
        memcpy(&B, mhash+4, 4); \
        singlehash.x=A;singlehash.y=B; \
	singlehash.z=(con_salt[(int)mylist->salt[0]&255]<<2);\
	singlehash.w=(con_salt[(int)mylist->salt[1]&255]<<6); \
    }


static unsigned const char con_salt[128]={
0xD2,0xD3,0xD4,0xD5,0xD6,0xD7,0xD8,0xD9,
0xDA,0xDB,0xDC,0xDD,0xDE,0xDF,0xE0,0xE1,
0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,
0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF1,
0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,
0xFA,0xFB,0xFC,0xFD,0xFE,0xFF,0x00,0x01,
0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,
0x0A,0x0B,0x05,0x06,0x07,0x08,0x09,0x0A,
0x0B,0x0C,0x0D,0x0E,0x0F,0x10,0x11,0x12,
0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1A,
0x1B,0x1C,0x1D,0x1E,0x1F,0x20,0x21,0x22,
0x23,0x24,0x25,0x20,0x21,0x22,0x23,0x24,
0x25,0x26,0x27,0x28,0x29,0x2A,0x2B,0x2C,
0x2D,0x2E,0x2F,0x30,0x31,0x32,0x33,0x34,
0x35,0x36,0x37,0x38,0x39,0x3A,0x3B,0x3C,
0x3D,0x3E,0x3F,0x40,0x41,0x42,0x43,0x44,
};

static unsigned const char cov_2char[65]={
0x2E,0x2F,0x30,0x31,0x32,0x33,0x34,0x35,
0x36,0x37,0x38,0x39,0x41,0x42,0x43,0x44,
0x45,0x46,0x47,0x48,0x49,0x4A,0x4B,0x4C,
0x4D,0x4E,0x4F,0x50,0x51,0x52,0x53,0x54,
0x55,0x56,0x57,0x58,0x59,0x5A,0x61,0x62,
0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6A,
0x6B,0x6C,0x6D,0x6E,0x6F,0x70,0x71,0x72,
0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0
};

static int hash_ret_len1=8;

static int b64_pton(char const *src, char *target)
{
    int y,j;
    unsigned char c1,c2,c3,c4;

    c1=c2=c3=c4=0;
    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[0]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[1]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[2]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[3]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[0]=(y>>24)&255;
    target[1]=(y>>16)&255;
    target[2]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[4]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[5]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[6]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[7]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[3]=(y>>24)&255;
    target[4]=(y>>16)&255;
    target[5]=(y>>8)&255;

    y=0;
    for (j=0; j<65; j++) if (cov_2char[j]==src[8]) c1=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[9]) c2=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[10]) c3=(j&255);
    for (j=0; j<65; j++) if (cov_2char[j]==src[11]) c4=(j&255);
    y=(c1<<26)|(c2<<20)|(c3<<14)|(c4<<8);
    target[6]=(y>>24)&255;
    target[7]=(y>>16)&255;
    target[8]=0;
    return 0;
}


static void ocl_set_params(int loopnr, cl_uint4 param1, cl_uint4 param2,struct hash_list_s *list,cl_uint16 *p1, cl_uint16 *p2,struct hash_list_s *plist[4])
{
    switch (loopnr)
    {
	case 0:
	    p1->s0=param1.s0;
	    p1->s1=param1.s1;
	    p1->s2=param1.s2;
	    p1->s3=param1.s3;
	    p2->s0=param2.s0;
	    p2->s1=param2.s1;
	    p2->s2=param2.s2;
	    p2->s3=param2.s3;
	    plist[0]=list;
	    break;
	case 1:
	    p1->s4=param1.s0;
	    p1->s5=param1.s1;
	    p1->s6=param1.s2;
	    p1->s7=param1.s3;
	    p2->s4=param2.s0;
	    p2->s5=param2.s1;
	    p2->s6=param2.s2;
	    p2->s7=param2.s3;
	    plist[1]=list;
	    break;
	case 2:
	    p1->s8=param1.s0;
	    p1->s9=param1.s1;
	    p1->sA=param1.s2;
	    p1->sB=param1.s3;
	    p2->s8=param2.s0;
	    p2->s9=param2.s1;
	    p2->sA=param2.s2;
	    p2->sB=param2.s3;
	    plist[2]=list;
	    break;
	case 3:
	    p1->sC=param1.s0;
	    p1->sD=param1.s1;
	    p1->sE=param1.s2;
	    p1->sF=param1.s3;
	    p2->sC=param2.s0;
	    p2->sD=param2.s1;
	    p2->sE=param2.s2;
	    p2->sF=param2.s3;
	    plist[3]=list;
	    break;
    }
}


static void ocl_get_cracked(cl_command_queue queuein,cl_mem plains_buf, char *plains, cl_mem hashes_buf, char *hashes, int numfound, int vsize, int hashlen, struct hash_list_s *list)
{
    int a,b;
    struct hash_list_s  *addlist;
    char plain[9];
    char mhash[20];
    char base64[20];

    if (numfound>MAXFOUND) 
    {
	printf("error found=%d\n",numfound);
	return;
    }
    if (!list) return;

    _clEnqueueReadBuffer(queuein, plains_buf, CL_TRUE, 0, 8*numfound*vsize, plains, 0, NULL, NULL);
    _clEnqueueReadBuffer(queuein, hashes_buf, CL_TRUE, 0, hashlen*numfound*vsize, hashes, 0, NULL, NULL);

    memcpy(base64,list->hash,13);
    b64_pton(base64+2,mhash);

    for (a=0;a<numfound;a++)
    for (b=0;b<vsize;b++)
    if (memcmp(mhash, (char *)hashes+(a*vsize+b)*hashlen, hash_ret_len1) == 0)
    {
    	int flag = 0;
    	bzero(plain,9);
    	memcpy(plain,&plains[0]+((a*vsize+b)*8),8);
    	pthread_mutex_lock(&crackedmutex);
    	addlist = cracked_list;
    	while (addlist)
    	{
    	    if ( (strcmp(addlist->username, list->username) == 0) && (memcmp(addlist->hash, list->hash, hash_ret_len1) == 0))
                flag = 1;
    	    addlist = addlist->next;
    	}
    	pthread_mutex_unlock(&crackedmutex);
    	if (flag == 0)
    	{
    	    add_cracked_list(list->username, list->hash, list->salt, plain);
    	    list->salt2[0]=1;
    	}
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
static void ocl_execute(cl_command_queue queue, cl_kernel kernel, size_t *global_work_size, size_t *local_work_size, int charset_size, cl_mem found_buf, cl_mem hashes_buf, cl_mem plains_buf, char *plains, char * hashes,int self, cl_uint16 *p1,cl_uint16 *p2,struct hash_list_s *list[4])
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
    		    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len1,list[a]);
    		    bzero(plains,8*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 8*8*MAXFOUND, plains, 0, NULL, NULL);
    		    // Change for other types
    		    bzero(hashes,hash_ret_len1*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);
    		    *found = 0;
    		    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
		}
    		_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
    		wthreads[self].tries += (charset_size*charset_size*charset_size*charset_size*wthreads[self].loops)/(get_hashes_num()*64);
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
    		    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len1,list[a]);
    		    bzero(plains,8*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 8*8*MAXFOUND, plains, 0, NULL, NULL);
    		    // Change for other types
    		    bzero(hashes,hash_ret_len1*8*MAXFOUND);
    		    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len1*8*MAXFOUND, hashes, 0, NULL, NULL);
    		    *found = 0;
    		    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
		}
    		_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
    		wthreads[self].tries += (charset_size*charset_size*charset_size*charset_size*wthreads[self].loops)/(get_hashes_num()*16);
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
void* ocl_bruteforce_desunix_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4;
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
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;
    struct hash_list_s *plist[4];
    char candidate[16];

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "desunix_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "desunix_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );

    // Change for other lens
    hashes  = malloc(hash_ret_len1*8*MAXFOUND); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len1*8*MAXFOUND, NULL, &err );
    plains=malloc(8*8*MAXFOUND);
    bzero(plains,8*8*MAXFOUND);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 8*8*MAXFOUND, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 8*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,8*8*MAXFOUND);
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

    csize=4<<3;
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
        bzero(candidate,8);
	SETUP_PARAMS();
	image.y=0;image.z=0;image.w=0;
	ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
	    try=0;
	}
	mylist = mylist->next;
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
    if (bruteforce_end==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* bruteforce, len=5 */

    csize=5<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=bruteforce_charset[a1];
	    SETUP_PARAMS();
	    image.y=(bruteforce_charset[a1])|(0<<8);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);


    /* bruteforce, len=6 */
    csize=6<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
	    SETUP_PARAMS();
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(0<<16);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);


    /* bruteforce, len=7 */

    csize=7<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
	    SETUP_PARAMS();
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);


    /* bruteforce, len=8 */

    csize=8<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=(bruteforce_charset[a1]);
    	    candidate[1]=(bruteforce_charset[a2]);
    	    candidate[2]=(bruteforce_charset[a3]);
    	    candidate[3]=(bruteforce_charset[a4]);
	    SETUP_PARAMS();
	    image.y=(bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);

    out:
    free(hashes);
    free(plains);
    return hash_ok;
}





void* ocl_markov_desunix_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4;
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
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;
    struct hash_list_s *plist[4];
    char candidate[16];

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "desunix_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "desunix_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );

    // Change for other lens
    hashes  = malloc(hash_ret_len1*8*MAXFOUND); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len1*8*MAXFOUND, NULL, &err );
    plains=malloc(8*8*MAXFOUND);
    bzero(plains,8*8*MAXFOUND);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 8*8*MAXFOUND, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 8*8*MAXFOUND, plains, 0, NULL, NULL);
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

    csize=4<<3;
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
        bzero(candidate,8);
	SETUP_PARAMS();
	image.y=0;image.z=0;image.w=0;
	ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
	    try=0;
	}
	mylist = mylist->next;
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
    if (markov_max_len==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* markov, len=5 */

    csize=5<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=reduced_charset[a1];
	    SETUP_PARAMS();
	    image.y=(reduced_charset[a1])|(0<<8);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);


    /* markov, len=6 */
    csize=6<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
	    SETUP_PARAMS();
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(0<<16);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);



    /* markov, len=7 */

    csize=7<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
	    SETUP_PARAMS();
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(0<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);



    /* markov, len=8 */

    csize=8<<3;
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
    	    bzero(candidate,8);
    	    candidate[0]=reduced_charset[a1];
    	    candidate[1]=reduced_charset[a2];
    	    candidate[2]=reduced_charset[a3];
    	    candidate[3]=reduced_charset[a4];
	    SETUP_PARAMS();
	    image.y=(reduced_charset[a1])|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
	    image.z=0;
	    image.w=0;
	    ocl_set_params(try,image,singlehash,mylist,&p1,&p2,plist);
	    try++;
	    if (try==wthreads[self].loops)
	    {
		ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);
		try=0;
	    }
	    mylist = mylist->next;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,plist);


    out:
    free(hashes);
    free(plains);
    return hash_ok;
}



/* Crack callback */
static void ocl_desunix_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];
    cl_uint16 salt;
    cl_uint16 singlehash;
    unsigned int A,B; 
    char mhash[20]; 
    char base64[64]; 

    if (ocl_rule_opt_counts[self]==0)
    {
        bzero(&addline1[self],sizeof(cl_uint16));
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
    }
    ocl_rule_opt_counts[self]++;

    if ((line[0]==0)||(ocl_rule_opt_counts[self]>=wthreads[self].vectorsize))
    {
        wthreads[self].tries+=ocl_rule_workset[self]*ocl_rule_opt_counts[self];
        mylist = hash_list;
        while (mylist)
        {
            if (mylist->salt2[0]==1) {mylist=mylist->next;continue;}

            _clSetKernelArg(rule_kernel[self], 7, sizeof(cl_uint16), (void*) &addline1[self]);

            if (attack_over!=0) pthread_exit(NULL);
            pthread_mutex_lock(&wthreads[self].tempmutex);
            pthread_mutex_unlock(&wthreads[self].tempmutex);

    	    memcpy(base64,mylist->hash,13); 
    	    b64_pton(base64+2,mhash); 
    	    memcpy(&A, mhash, 4); 
    	    memcpy(&B, mhash+4, 4); 
    	    singlehash.x=A;singlehash.y=B; 
	    salt.sE=(con_salt[(int)mylist->salt[0]&255]<<2);
	    salt.sF=(con_salt[(int)mylist->salt[1]&255]<<6);
	    _clSetKernelArg(rule_kernel[self], 6, sizeof(cl_uint16), (void*) &salt);
	    _clSetKernelArg(rule_kernel[self], 5, sizeof(cl_uint4), (void*) &singlehash);

            _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
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

			memcpy(base64,mylist->hash,13);
			b64_pton(base64+2,mhash);
    			if (memcmp(mhash, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1) == 0)
                        {
                            int flag = 0;
                            strcpy(plain,&rule_images[self][0]+(a*MAX));
                            strcat(plain,addlines[self][c]);
                            pthread_mutex_lock(&crackedmutex);
                            addlist = cracked_list;
                            while (addlist)
                            {
                                if ((memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0) && (strcmp(addlist->username, mylist->username) == 0))
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



static void ocl_desunix_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=(ocl_rule_workset[self]-1))||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	ocl_rule_opt_counts[self]=0;
	rule_offload_perform(ocl_desunix_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_desunix_thread(void *arg)
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
    rule_counts[self][0]=0;
    rule_kernel[self] = _clCreateKernel(program[self], "desunix", &err );
    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(cl_uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*MAX, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*MAX);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*MAX);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*sizeof(cl_uint));
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_desunix_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_desunix(void)
{
    int a,i;
    uint64_t bcnt;
    int err;
    int worker_thread_keys[32];


    bcnt=1;
    bruteforce_start=4;
    for (a=bruteforce_start;a<bruteforce_end;a++) bcnt*=strlen(bruteforce_charset);
    attack_overall_count = bcnt;

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_desunix_long__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_desunix_long__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_bruteforce_desunix_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);

    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}



hash_stat ocl_markov_desunix(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (markov_max_len>8) markov_max_len=8;
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_desunix_long__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_desunix_long__%s.ptx",DATADIR,pbuf);

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
	pthread_create(&crack_threads[a], NULL, ocl_markov_desunix_thread, &worker_thread_keys[a]);
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
hash_stat ocl_rule_desunix(void)
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_desunix__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_desunix__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_desunix_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_desunix_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

