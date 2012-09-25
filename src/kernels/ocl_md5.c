/*
 * ocl_md5.c
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

#ifdef HAVE_CL_CL_H
#include <CL/cl.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include "err.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"

/* Hash reversal macros and constants */

#define F(x, y, z) (((x) & (y)) | ((~x) & (z)))
#define I(x, y, z)  ((y) ^ ((x) | ~(z)))
#define H(x, y, z)  ((y) ^ (x) ^ (z))

#define ROTATE_RIGHT(x, n) (((x) >> (n)) | ((x) << (32-(n))))
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))

#define REVERSE_MD5STEP(a,b,c,d,x,s,AC) a = ROTATE_RIGHT((a - b), s) - x - (AC) - I(b, c, d);

#define S44 21
#define S43 15
#define S42 10
#define S41 6
#define S31 4
#define S32 11
#define S33 16
#define S34 23

#define AC2 0xe8c7b756
#define AC3 0x242070db 
#define AC4 0xc1bdceee
#define AC15 0xa679438e

#define AC1 			0xd76aa478
#define AC47			0x1fa27cf8
#define AC48 			0xc4ac5665
#define AC49                    0xf4292244
#define AC50                    0x432aff97
#define AC51                    0xab9423a7
#define AC52                    0xfc93a039
#define AC53                    0x655b59c3
#define AC54                    0x8f0ccc92
#define AC55                    0xffeff47d
#define AC56                    0x85845dd1
#define AC57                    0x6fa87e4f
#define AC58                    0xfe2ce6e0
#define AC59                    0xa3014314
#define AC60                    0x4e0811a1
#define AC61                    0xf7537e82
#define AC62                    0xbd3af235
#define AC63                    0x2ad7d2bb
#define AC64                    0xeb86d391
#define mCa 0x67452301
#define mCb 0xefcdab89
#define mCc 0x98badcfe
#define mCd 0x10325476



/* Get batch of cracked */
static void ocl_get_cracked(cl_command_queue queuein,cl_mem plains_buf, char *plains, cl_mem hashes_buf, char *hashes, int numfound, int vsize, int hashlen)
{
    int a,b,e=0,err;
    char plain[16];
    struct hash_list_s  *mylist, *addlist;

    if (numfound>MAXFOUND) 
    {
	printf("error found=%d\n",numfound);
	return;
    }

    err = clEnqueueReadBuffer(queuein, plains_buf, CL_TRUE, 0, 16*numfound*vsize, plains, 0, NULL, NULL);
    if (err!=CL_SUCCESS)
    {
	elog("clEnqueueReadBuffer error:%d (vsize=%d numfound=%d)\n",err,vsize,numfound);
	exit(1);
    }
    err = clEnqueueReadBuffer(queuein, hashes_buf, CL_TRUE, 0, hashlen*numfound*vsize, hashes, 0, NULL, NULL);
    if (err!=CL_SUCCESS)
    {
	elog("clEnqueueReadBuffer error:%d\n",err);
	exit(1);
    }

    for (a=0;a<numfound;a++)
    for (b=0;b<vsize;b++)
    if ( (hash_index[hashes[(a*vsize+b)*16]&255][hashes[(a*vsize+b)*16+1]&255].count<MAXINDEX) && (hash_index[hashes[(a*vsize+b)*16]&255][hashes[(a*vsize+b)*16+1]&255].count>0))
    {
        int i;
        e=a*vsize+b;
        for (i=0;i<hash_index[hashes[e*hashlen]&255][hashes[e*hashlen+1]&255].count;i++)
        if (memcmp(hash_index[hashes[e*hashlen]&255][hashes[e*hashlen+1]&255].nodes[i]->hash, (char *)hashes+(e)*hashlen, hash_ret_len) == 0)
        {
            mylist = hash_index[hashes[e*hashlen]&255][hashes[e*hashlen+1]&255].nodes[i];
            int flag = 0;
            memcpy(plain,&plains[0]+(e*hashlen),hashlen);
            plain[strlen(plain)-1] = 0;
            pthread_mutex_lock(&crackedmutex);
            addlist = cracked_list;
            while (addlist)
            {
                if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
                        flag = 1;
                addlist = addlist->next;
            }
            pthread_mutex_unlock(&crackedmutex);
            if (flag == 0)
            {
                add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
            }
        }
    }
    else if (hash_index[hashes[(a*vsize+b)*hashlen]&255][hashes[(a*vsize+b)*hashlen+1]&255].count>=MAXINDEX)
    {
        mylist = hash_list;
        while (mylist)
        {
            if (memcmp(mylist->hash, (char *)hashes+(e)*hashlen, hash_ret_len) == 0)
            {
                int flag = 0;
                memcpy(plain,&plains[0]+(e*hashlen),hashlen);
                plain[strlen(plain)-1] = 0;
                pthread_mutex_lock(&crackedmutex);
                addlist = cracked_list;
                while (addlist)
                {
                    if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
                    flag = 1;
                    addlist = addlist->next;
                }
                pthread_mutex_unlock(&crackedmutex);
                if (flag == 0)
                {
                    add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                }
        }
        if (mylist) mylist = mylist->next;
        }
    }
}


static void ocl_set_params(int loopnr, cl_uint4 param1, cl_uint4 param2,cl_uint16 *p1, cl_uint16 *p2, cl_uint16 *p3, cl_uint16 *p4)
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
	    break;
	case 4:
	    p3->s0=param1.s0;
	    p3->s1=param1.s1;
	    p3->s2=param1.s2;
	    p3->s3=param1.s3;
	    p4->s0=param2.s0;
	    p4->s1=param2.s1;
	    p4->s2=param2.s2;
	    p4->s3=param2.s3;
	    break;
	case 5:
	    p3->s4=param1.s0;
	    p3->s5=param1.s1;
	    p3->s6=param1.s2;
	    p3->s7=param1.s3;
	    p4->s4=param2.s0;
	    p4->s5=param2.s1;
	    p4->s6=param2.s2;
	    p4->s7=param2.s3;
	    break;
	case 6:
	    p3->s8=param1.s0;
	    p3->s9=param1.s1;
	    p3->sA=param1.s2;
	    p3->sB=param1.s3;
	    p4->s8=param2.s0;
	    p4->s9=param2.s1;
	    p4->sA=param2.s2;
	    p4->sB=param2.s3;
	    break;
	case 7:
	    p3->sC=param1.s0;
	    p3->sD=param1.s1;
	    p3->sE=param1.s2;
	    p3->sF=param1.s3;
	    p4->sC=param2.s0;
	    p4->sD=param2.s1;
	    p4->sE=param2.s2;
	    p4->sF=param2.s3;
	    break;
    }
}




/* Markov initializer */
static void init_markov()
{
    int a,b,charset_size;

    charset_size = strlen(markov_charset);
    bitmaps = malloc(256*256*32*8*4);
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
    printf("reduced size=%d\n",reduced_size);
    for (a=0;a<charset_size*charset_size*charset_size;a++)
    {
	unsigned char x,y,z,t1;
	t1 = (a / (charset_size*charset_size));
	x = (markov_charset[(a / (charset_size*charset_size))]);
	y = (markov_charset[((a-t1*(charset_size*charset_size))/charset_size)]);
	z = (markov_charset[(a % charset_size)]);
	table[a] = (x<<16)|(y<<8)|(z);
    }
    for (a=0;a<256*256*32*8;a++)
    {
	    bitmaps[a]=0;
    }
}

/* Markov deinit */
static void deinit_markov()
{
    free(bitmaps);
    free(table);
}


/* Bruteforce initializer big charsets */
static void init_bruteforce_long()
{
    int a,b,charset_size;

    charset_size = strlen(bruteforce_charset);
    bitmaps = malloc(256*256*32*8*4);
    table = malloc(128*128*4);

    for (a=0;a<strlen(bruteforce_charset);a++)
    for (b=0;b<strlen(bruteforce_charset);b++)
    {
	table[a*strlen(bruteforce_charset)+b] = (bruteforce_charset[a]<<8)|(bruteforce_charset[b]);
    }

    for (a=0;a<256*256*8*32;a++)
    {
	    bitmaps[a]=0;
    }
}


/* Bruteforce initializer small charsets */
static void init_bruteforce_short()
{
    int a,charset_size;

    charset_size = strlen(bruteforce_charset);
    bitmaps = malloc(256*256*32*8*4);
    table = malloc(sizeof(uint)*charset_size*charset_size*charset_size*charset_size);
    for (a=0;a<charset_size*charset_size*charset_size*charset_size;a++)
    {
        unsigned char x,y,z,w,t1,t2;
        t1 = (a / (charset_size*charset_size*charset_size));
        x = (bruteforce_charset[t1]);
        t2 = ((a-t1*(charset_size*charset_size*charset_size))/(charset_size*charset_size));
	y = (bruteforce_charset[t2]);
        z = (bruteforce_charset[((a-t1*(charset_size*charset_size*charset_size)) - t2*charset_size*charset_size)/charset_size]);
        w = (bruteforce_charset[(a % charset_size)]);
        table[a] = (x<<24)|(y<<16)|(z<<8)|w;
    }
    for (a=0;a<256*256*32*8;a++)
    {
	    bitmaps[a]=0;
    }
}


/* Bruteforce deinit */
static void deinit_bruteforce()
{
    free(bitmaps);
    free(table);
}


/* Execute kernel, flush parameters */
static void execute(cl_queue queue, cl_kernel kernel, size_t *global_work_size, size_t *local_work_size, cl_mem found_buf, cl_mem hashes_buf, cl_mem plains_buf, int self
{
    int err;
    int found;

    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
    if (err != CL_SUCCESS)
    {
        elog("clEnqueueNDRangeKernel error (%d)\n",err);
        goto out;
    }
    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size;
    attack_current_count += wthreads[self].loops;
    int *fnd;
    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    found = *fnd;
    if (found>0) 
    {
	ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	bzero(plains,16*8*MAXFOUND);
	clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	// Change for other types
	bzero(hashes,16*8*MAXFOUND);
	clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	found = 0;
    	clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
}





/* Bruteforce larger charsets */
void* ocl_bruteforce_md5_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    unsigned char hex1[16];
    int self;
    cl_kernel kernel;
    cl_mem bitmaps_buf;
    int a;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9;
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
    cl_uint16 p3;
    cl_uint16 p4;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = NULL;

    /* Init kernels */
    if (ocl_gpu_double) kernel = clCreateKernel(program[self], "md5_long_double", &err );
    else  kernel = clCreateKernel(program[self], "md5_long_normal", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }

    /* Create queue */
    queue = clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateCommandQueue error (%d)\n",err);
	return NULL;
    }

    
    mylist = hash_list;
    a=0;
    while (mylist)
    {
        memcpy(hex1,mylist->hash,16);
	a++;
	unsigned int *b_a = (unsigned int *)hex1;
	unsigned int *b_b = (unsigned int *)&hex1[4];
	unsigned int *b_c = (unsigned int *)&hex1[8];
	unsigned int *b_d = (unsigned int *)&hex1[12];
	unsigned int bind_a = (*b_a)>>10;
	unsigned int bval_a = (1<<((*b_a)&31));
	unsigned int bind_b = (*b_b)>>10;
	unsigned int bval_b = (1<<((*b_b)&31));
	unsigned int bind_c = (*b_c)>>10;
	unsigned int bval_c = (1<<((*b_c)&31));
	unsigned int bind_d = (*b_d)>>10;
	unsigned int bval_d = (1<<((*b_d)&31));
	bitmaps[bind_a] |=bval_a;
	bitmaps[bind_b+65535*8*8] |=bval_b;
	bitmaps[bind_c+65535*16*8] |=bval_c;
	bitmaps[bind_d+65535*24*8] |=bval_d;
	singlehash.x |= (1<<((*b_b)&31));
	singlehash.y |= (1<<((*b_c)&31));
	singlehash.z |= (1<<((*b_d)&31));
        if (mylist) mylist = mylist->next;
	singlehash.w=0;
	p2.s0=p2.s4=p2.s8=p2.sC=p4.s0=p4.s4=p4.s8=p4.sC=singlehash.x;
	p2.s1=p2.s5=p2.s9=p2.sD=p4.s1=p4.s5=p4.s9=p4.sD=singlehash.y;
	p2.s2=p2.s6=p2.sA=p2.sE=p4.s2=p4.s6=p4.sA=p4.sE=singlehash.z;
	p2.s3=p2.s7=p2.sB=p2.sF=p4.s3=p4.s7=p4.sB=p4.sF=singlehash.z;
    }

    // Change for other lens
    hashes  = malloc(16*8*MAXFOUND); 
    hashes_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,16*8*MAXFOUND);
    clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);


    found_buf = clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateBuffer error (%d)\n",err);
        return NULL;
    }

    table_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 128*128*4,table , &err );
    bitmaps_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 256*256*32*8*4, bitmaps, &err );
    found = 0;
    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);


    clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel, 5, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (charset_size*charset_size);
    global_work_size[1] = (charset_size*charset_size);
    while ((global_work_size[0] %64)!=0) global_work_size[0]++;
    while ((global_work_size[1] % (wthreads[self].vectorsize))!=0) global_work_size[1]++;
    global_work_size[1] = global_work_size[1]/wthreads[self].vectorsize;
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 



    /* Bruteforce, len=4 */

    csize=32+AC15;
    clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (attack_over!=0) goto out;
    // OK, let's do some hash reversal here 
    if (!hash_list->next)
    {
        mylist = hash_list;
        memcpy(hex1,mylist->hash,4);
        unsigned int A,B,C,D;
        memcpy(&A, hex1, 4);
        memcpy(hex1,mylist->hash+4,4);
        memcpy(&B, hex1, 4);
        memcpy(hex1,mylist->hash+8,4);
        memcpy(&C, hex1, 4);
        memcpy(hex1,mylist->hash+12,4);
        memcpy(&D, hex1, 4);
        A=(A-0x67452301);
        B=(B-0xefcdab89);
        C=(C-0x98badcfe);
        D=(D-0x10325476);
        REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
        REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
        REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
        REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
        REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
        REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
        REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
        REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
        REVERSE_MD5STEP(B, C, D, A, 0x80,	S44, AC56);//x1
        REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
        REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
        REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
        REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
        REVERSE_MD5STEP(C, D, A, B, 32,	S43, AC51);
        REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
        REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
        B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
        image.x=0;image.y=0x80;image.z=0;image.w=0;
        image.y+=AC2;image.z+=AC3;
        image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
        singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
        ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
    }
    else
    {
        image.x=0;image.y=0x80;image.z=0;image.w=0;
        image.y+=AC2;image.z+=AC3;
        ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
    }

    clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p1);
    clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p2);
    clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p3);
    clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p4);
    try=0;
    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
    if (err != CL_SUCCESS)
    {
        elog("clEnqueueNDRangeKernel error (%d)\n",err);
        goto out;
    }
    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size;
    attack_current_count += wthreads[self].loops;
    int *fnd;
    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    found = *fnd;
    if (found>0) 
    {
	ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	bzero(plains,16*8*MAXFOUND);
	clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	// Change for other types
	bzero(hashes,16*8*MAXFOUND);
	clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	found = 0;
    	clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
    if (bruteforce_end==4) goto out;
    if (session_restore_flag==0) scheduler.len=5;


    /* bruteforce, len=5 */

    csize=40+AC15;
    sched_wait(5);
    clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    for (a1=0;a1<charset_size;a1++)
    //while ((sched_len()==5)&&(a2=sched_s2(a1,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e2(a1))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	// OK, let's do some hash reversal here 
	if (!hash_list->next)
	{
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a1] | (0x80<<8);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 40,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(0x80<<8);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
	}
	else
	{
    	    image.x=0;image.y=(bruteforce_charset[a1])|(0x80<<8);image.z=0;image.w=0;
    	    image.y+=AC2;image.z+=AC3;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
	}

	try++;
	if (try==wthreads[self].loops)
	{
	    clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p1);
	    clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p2);
	    clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p3);
	    clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p4);
	    try=0;
	    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	    if (err != CL_SUCCESS)
	    {
		elog("clEnqueueNDRangeKernel error (%d)\n",err);
		goto out;
	    }
	    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size*wthreads[self].loops;
	    attack_current_count += wthreads[self].loops;
	    int *fnd;
	    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    found = *fnd;
	    if (found>0) 
    	    {
    		ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
		bzero(plains,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
		// Change for other types
		bzero(hashes,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    		found = 0;
    		clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	    }
    	    clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
	}
    }
    if (session_restore_flag==0) scheduler.len=6;


    /* bruteforce, len=6 */
    csize=48+AC15;
    sched_wait(6);
    clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    for (a1=0;a1<charset_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

        if (!hash_list->next)
        {
            unsigned int A,B,C,D,tmp;
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = (bruteforce_charset[a1])|(bruteforce_charset[a2]<<8)|(0x80<<16);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 48,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(0x80<<16);
	    image.z=0;image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
        }
	else
	{
	    image.x=0;
	    image.y=((bruteforce_charset[a1]&255)|(bruteforce_charset[a2]<<8)|(0x80<<16));
	    image.z=0;image.w=0;
    	    image.y+=AC2;image.z+=AC3;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
	}
	try++;
	if (try==wthreads[self].loops)
	{
	    clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p1);
	    clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p2);
	    clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p3);
	    clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p4);
	    try=0;
	    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	    if (err != CL_SUCCESS)
	    {
		elog("clEnqueueNDRangeKernel error (%d)\n",err);
		goto out;
	    }
	    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size*wthreads[self].loops;
	    attack_current_count += wthreads[self].loops;
	    int *fnd;
	    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    found = *fnd;
	    if (found>0) 
    	    {
    		ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
		bzero(plains,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
		// Change for other types
		bzero(hashes,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    		found = 0;
    		clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	    }
    	    clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
	}
    }


    /* bruteforce, len=7 */

    csize=56+AC15;
    sched_wait(7);
    clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 56,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);
	    image.z=0;image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);
	    image.z=0;image.w=0;
    	    image.y+=AC2;image.z+=AC3;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
	}

	try++;
	if (try==wthreads[self].loops)
	{
	    clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p1);
	    clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p2);
	    clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p3);
	    clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p4);
	    try=0;
	    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	    if (err != CL_SUCCESS)
	    {
		elog("clEnqueueNDRangeKernel error (%d)\n",err);
		goto out;
	    }
	    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size*wthreads[self].loops;
	    attack_current_count += wthreads[self].loops;
	    int *fnd;
	    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    found = *fnd;
	    if (found>0) 
    	    {
    		ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
		bzero(plains,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
		// Change for other types
		bzero(hashes,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    		found = 0;
    		clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	    }
    	    clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
	}
    }



    /* bruteforce, len=8 */

    csize=64+AC15;
    sched_wait(8);
    clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0x80, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 64,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0x80 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(0x80);image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	    image.z=(0x80);image.w=0;
    	    ocl_set_params(try,image,singlehash,&p1,&p2,&p3,&p4);
	}

	try++;
	if (try==wthreads[self].loops)
	{
	    clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p1);
	    clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p2);
	    clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p3);
	    clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p4);
	    try=0;
	    err=clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	    if (err != CL_SUCCESS)
	    {
		elog("clEnqueueNDRangeKernel error (%d)\n",err);
		goto out;
	    }
	    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size*wthreads[self].loops;
	    attack_current_count += wthreads[self].loops;
	    int *fnd;
	    fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    found = *fnd;
	    if (found>0) 
    	    {
    		ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
		bzero(plains,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
		// Change for other types
		bzero(hashes,16*8*MAXFOUND);
		clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    		found = 0;
    		clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	    }
    	    clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
	}

    }

    /* bruteforce, len=9 */
/*
    csize=72+AC15;
    sched_wait(9);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	//int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (bruteforce_charset[a6]|(0x80<<8)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 72,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (bruteforce_charset[a6]|(0x80<<8)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(0x80<<8);image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(0x80<<8);image.w=0;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : global_work_size*wthreads[self].vectorsizev;
	    //attack_current_count += (i==0) ? cbase.s0 : wthreads[self].vectorsizev;
	}
	else
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    //attack_current_count += (i==0) ? cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* bruteforce, len=10 */
/*
    csize=80+AC15;
    sched_wait(10);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	//int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(0x80<<16)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 80,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(0x80<<16)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(0x80<<16);image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(0x80<<16);image.w=0;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : global_work_size*wthreads[self].vectorsizev;
	    //attack_current_count += (i==0) ? cbase.s0 : wthreads[self].vectorsizev;
	}
	else
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    //attack_current_count += (i==0) ? cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* bruteforce, len=11 */
/*
    csize=88+AC15;
    sched_wait(11);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	//int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (unsigned int)(bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(0x80<<24)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 88,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (unsigned int)(bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(0x80<<24)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(0x80<<24);image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(0x80<<24);image.w=0;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : global_work_size*wthreads[self].vectorsizev;
	    //attack_current_count += (i==0) ? cbase.s0 : wthreads[self].vectorsizev;
	}
	else
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    //attack_current_count += (i==0) ? cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* bruteforce, len=12 */
/*
    csize=96+AC15;
    sched_wait(12);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==12)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	//int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(bruteforce_charset[a9]<<24)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0x80, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 96,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(bruteforce_charset[a9]<<24)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(bruteforce_charset[a9]<<24);image.w=0x80;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=bruteforce_charset[a2]|(bruteforce_charset[a3]<<8)|(bruteforce_charset[a4]<<16)|(bruteforce_charset[a5]<<24);
	    image.z=bruteforce_charset[a6]|(bruteforce_charset[a7]<<8)|(bruteforce_charset[a8]<<16)|(bruteforce_charset[a9]<<24);image.w=0x80;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : global_work_size*wthreads[self].vectorsizev;
	    //attack_current_count += (i==0) ? cbase.s0 : wthreads[self].vectorsizev;
	}
	else
	{
	    //wthreads[self].tries+=(i==0) ? global_work_size*cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    //attack_current_count += (i==0) ? cbase.s0 : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/
    out:
    free(hashes);
    free(plains);
    return hash_ok;
}




void* ocl_bruteforce_md5_short_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size;
    cl_uint4 image;
    int self;
    cl_kernel kernel[3];
    unsigned char hex1[16];
    cl_mem bitmaps_buf;
    int a;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    char *hashes;
    int charset_size = (int)strlen(bruteforce_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    struct  hash_list_s  *mylist;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 cbase;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={128,0,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = NULL;

    /* Init kernels */
    kernel[0] = clCreateKernel(program[self], "md5_short_scalar", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }
    kernel[1] = clCreateKernel(program[self], "md5_short_normal", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }
    kernel[2] = clCreateKernel(program[self], "md5_short_double", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }

    /* Create queue */
    queue = clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateCommandQueue error (%d)\n",err);
	return NULL;
    }

    
    mylist = hash_list;
    a=0;
    while (mylist)
    {
        memcpy(hex1,mylist->hash,16);
	a++;
	unsigned int *b_a = (unsigned int *)hex1;
	unsigned int *b_b = (unsigned int *)&hex1[4];
	unsigned int *b_c = (unsigned int *)&hex1[8];
	unsigned int *b_d = (unsigned int *)&hex1[12];
	unsigned int bind_a = (*b_a)>>13;
	unsigned int bval_a = (1<<((*b_a)&31));
	unsigned int bind_b = (*b_b)>>13;
	unsigned int bval_b = (1<<((*b_b)&31));
	unsigned int bind_c = (*b_c)>>13;
	unsigned int bval_c = (1<<((*b_c)&31));
	unsigned int bind_d = (*b_d)>>13;
	unsigned int bval_d = (1<<((*b_d)&31));
	bitmaps[bind_a] |=bval_a;
	bitmaps[bind_b+65535*8] |=bval_b;
	bitmaps[bind_c+65535*16] |=bval_c;
	bitmaps[bind_d+65535*24] |=bval_d;
	singlehash.x |= (1<<((*b_b)&31));
	singlehash.y |= (1<<((*b_c)&31));
	singlehash.z |= (1<<((*b_d)&31));
        if (mylist) mylist = mylist->next;
    }

    if (a==1)
    {
	mylist = hash_list;
	memcpy(hex1,mylist->hash,4);
	memcpy(&singlehash.x, hex1, 4);
	memcpy(hex1,mylist->hash+4,4);
	memcpy(&singlehash.y, hex1, 4);
	memcpy(hex1,mylist->hash+8,4);
	memcpy(&singlehash.z, hex1, 4);
	memcpy(hex1,mylist->hash+12,4);
	memcpy(&singlehash.w, hex1, 4);
	clSetKernelArg(kernel[0], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[1], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[2], 8, sizeof(cl_uint4), (void*) &singlehash);
    }
    else 
    {
	singlehash.w=0;
	clSetKernelArg(kernel[0], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[1], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[2], 8, sizeof(cl_uint4), (void*) &singlehash);
    }

    // Change for other lens
    hashes  = malloc(16*8*MAXFOUND); 
    hashes_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,16*8*MAXFOUND);
    clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);


    found_buf = clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateBuffer error (%d)\n",err);
        return NULL;
    }

    table_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, charset_size*charset_size*charset_size*charset_size*4,table , &err );
    bitmaps_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, 256*256*32*4, bitmaps, &err );
    found = 0;
    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);

    clSetKernelArg(kernel[0], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[0], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[0], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[0], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[0], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[0], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[0], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[0], 7, sizeof(cl_mem), (void*) &table_buf);
    clSetKernelArg(kernel[1], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[1], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[1], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[1], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[1], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[1], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[1], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[1], 7, sizeof(cl_mem), (void*) &table_buf);
    clSetKernelArg(kernel[2], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[2], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[2], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[2], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[2], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[2], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[2], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[2], 7, sizeof(cl_mem), (void*) &table_buf);

    global_work_size = charset_size*charset_size*charset_size*charset_size;
    while ((global_work_size %128)!=0) global_work_size++;

    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); // right now it should be safe to release the mutex


    /* Bruteforce, len=5 */
    csize=1;
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    for (a1=0;a1<charset_size;a1++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);

	image.x=0x80<<8;image.y=0;image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*)&cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}
	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
    if (bruteforce_end==5) goto out;
    if (session_restore_flag==0) scheduler.len=6;


    /* Bruteforce, len=6 */

    csize=2;
    sched_wait(6);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    for (a1=0;a1<charset_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|0x80<<16;image.y=0;image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }



    /* Bruteforce, len=7 */

    csize=3;
    sched_wait(7);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);image.y=0;image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }



    /* Bruteforce, len=8 */
/*
    csize=4;
    sched_wait(8);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);image.y=0x80;image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/


    /* Bruteforce, len=9 */
/*
    csize=5;
    sched_wait(9);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(0x80<<8);image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/


    /* Bruteforce, len=10 */
/*
    csize=6;
    sched_wait(10);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(0x80<<16);image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/


    /* Bruteforce, len=11 */
/*
    csize=7;
    sched_wait(11);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(0x80<<24);
	image.z=0;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Bruteforce, len=12 */
/*
    csize=8;
    sched_wait(12);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==12)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	image.z=0x80;image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}
	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Bruteforce, len=13 */
/*
    csize=9;
    sched_wait(13);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==13)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==13)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	image.z=(bruteforce_charset[a9])|(0x80<<8);image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Bruteforce, len=14 */
/*
    csize=10;
    sched_wait(14);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==14)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==14)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    for (a10=0;a10<charset_size;a10++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	image.z=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(0x80<<16);image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}
	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Bruteforce, len=15 */
/*
    csize=11;
    sched_wait(15);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==15)
    for (a1=0;a1<charset_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==15)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,charset_size),a2))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    for (a10=0;a10<charset_size;a10++)
    for (a11=0;a11<charset_size;a11++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, bruteforce_charset, &cbase);
	image.x=(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
	image.y=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
	image.z=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(bruteforce_charset[a11]<<16)|(0x80<<24);image.w=0;
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);

	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/
    out:

    free(hashes);
    free(plains);
    return hash_ok;

}






void* ocl_markov_md5_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size;
    cl_uint4 image;
    int self;
    cl_kernel kernel[3];
    unsigned char hex1[16];
    cl_mem bitmaps_buf;
    int a;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9;
    char *hashes;
    int charset_size = (int)strlen(markov_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    struct  hash_list_s  *mylist;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 cbase;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={128,0,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = NULL;

    /* Init kernels */
    kernel[0] = clCreateKernel(program[self], "md5_long_scalar", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }
    kernel[1] = clCreateKernel(program[self], "md5_long_normal", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }
    kernel[2] = clCreateKernel(program[self], "md5_long_double", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }

    /* Create queue */
    queue = clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateCommandQueue error (%d)\n",err);
	return NULL;
    }

    
    mylist = hash_list;
    a=0;
    while (mylist)
    {
        memcpy(hex1,mylist->hash,16);
	a++;
	unsigned int *b_a = (unsigned int *)hex1;
	unsigned int *b_b = (unsigned int *)&hex1[4];
	unsigned int *b_c = (unsigned int *)&hex1[8];
	unsigned int *b_d = (unsigned int *)&hex1[12];
	unsigned int bind_a = (*b_a)>>13;
	unsigned int bval_a = (1<<((*b_a)&31));
	unsigned int bind_b = (*b_b)>>13;
	unsigned int bval_b = (1<<((*b_b)&31));
	unsigned int bind_c = (*b_c)>>13;
	unsigned int bval_c = (1<<((*b_c)&31));
	unsigned int bind_d = (*b_d)>>13;
	unsigned int bval_d = (1<<((*b_d)&31));
	bitmaps[bind_a] |=bval_a;
	bitmaps[bind_b+65535*8] |=bval_b;
	bitmaps[bind_c+65535*16] |=bval_c;
	bitmaps[bind_d+65535*24] |=bval_d;
	singlehash.x |= (1<<((*b_b)&31));
	singlehash.y |= (1<<((*b_c)&31));
	singlehash.z |= (1<<((*b_d)&31));
        if (mylist) mylist = mylist->next;
    }

    if (a==1)
    {
	mylist = hash_list;
	memcpy(hex1,mylist->hash,4);
	memcpy(&singlehash.x, hex1, 4);
	memcpy(hex1,mylist->hash+4,4);
	memcpy(&singlehash.y, hex1, 4);
	memcpy(hex1,mylist->hash+8,4);
	memcpy(&singlehash.z, hex1, 4);
	memcpy(hex1,mylist->hash+12,4);
	memcpy(&singlehash.w, hex1, 4);
	clSetKernelArg(kernel[0], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[1], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[2], 8, sizeof(cl_uint4), (void*) &singlehash);
    }
    else 
    {
	singlehash.w=0;
	clSetKernelArg(kernel[0], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[1], 8, sizeof(cl_uint4), (void*) &singlehash);
	clSetKernelArg(kernel[2], 8, sizeof(cl_uint4), (void*) &singlehash);
    }

    // Change for other lens
    hashes  = malloc(16*8*MAXFOUND); 
    hashes_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,16*8*MAXFOUND);
    clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);


    found_buf = clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateBuffer error (%d)\n",err);
        return NULL;
    }

    table_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, charset_size*charset_size*charset_size*4,table , &err );
    bitmaps_buf = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, 256*256*32*4, bitmaps, &err );
    found = 0;
    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);

    clSetKernelArg(kernel[0], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[0], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[0], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[0], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[0], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[0], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[0], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[0], 7, sizeof(cl_mem), (void*) &table_buf);
    clSetKernelArg(kernel[1], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[1], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[1], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[1], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[1], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[1], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[1], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[1], 7, sizeof(cl_mem), (void*) &table_buf);
    clSetKernelArg(kernel[2], 0, sizeof(cl_mem), (void*) &hashes_buf);
    clSetKernelArg(kernel[2], 1, sizeof(cl_uint4), (void*) &image);
    clSetKernelArg(kernel[2], 2, sizeof(cl_uint), (void*) &csize);
    clSetKernelArg(kernel[2], 3, sizeof(cl_uint16), (void*) &cbase);
    clSetKernelArg(kernel[2], 4, sizeof(cl_mem), (void*) &plains_buf);
    clSetKernelArg(kernel[2], 5, sizeof(cl_mem), (void*) &bitmaps_buf);
    clSetKernelArg(kernel[2], 6, sizeof(cl_mem), (void*) &found_buf);
    clSetKernelArg(kernel[2], 7, sizeof(cl_mem), (void*) &table_buf);

    global_work_size = charset_size*charset_size*charset_size;
    while ((global_work_size %128)!=0) global_work_size++;

    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); // right now it should be safe to release the mutex


    /* Markov, len=4 */
    csize=32+AC15;
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);

        // OK, let's do some hash reversal here 
        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
    	    REVERSE_MD5STEP(B, C, D, A, 0x80,	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 32,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;image.y=0x80;image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;image.y=0x80;image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}

	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*)&cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}
	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
    if (markov_max_len==4) goto out;
    if (session_restore_flag==0) scheduler.len=5;


    /* Markov, len=5 */
/*
    sched_wait(5);
    csize=40+AC15;
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    while ((sched_len()==5)&&((a2=sched_s2(a1))<sched_e2(a1)))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2] | (0x80<<8);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 40,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(0x80<<8);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(0x80<<8);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}

	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/


    /* Markov, len=6 */
/*
    sched_wait(6);
    csize=48+AC15;
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==6)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
	    unsigned int A,B,C,D,tmp;
	    mylist = hash_list;
	    memcpy(hex1,mylist->hash,4);
	    memcpy(&A, hex1, 4);
	    memcpy(hex1,mylist->hash+4,4);
	    memcpy(&B, hex1, 4);
	    memcpy(hex1,mylist->hash+8,4);
	    memcpy(&C, hex1, 4);
	    memcpy(hex1,mylist->hash+12,4);
	    memcpy(&D, hex1, 4);
	    A=(A-0x67452301);
	    B=(B-0xefcdab89);
	    C=(C-0x98badcfe);
	    D=(D-0x10325476);
	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
	    REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
	    REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
	    REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
	    REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = (markov_charset[a2])|(markov_charset[a3]<<8)|(0x80<<16);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 48,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(0x80<<16);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(0x80<<16);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}

	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Markov, len=7 */
/*
    csize=56+AC15;
    sched_wait(7);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);

	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            cl_uint A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(0x80<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 56,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(0x80<<24);
	    image.z=0;image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(0x80<<24);
	    image.z=0;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Markov, len=8 */
/*
    csize=64+AC15;
    sched_wait(8);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    for (a5=0;a5<charset_size;a5++) if (markov1[a4][a5] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, 0x80, 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 64,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - 0x80 - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=0x80;image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=0x80;image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}

	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Markov, len=9 */
/*
    csize=72+AC15;
    sched_wait(9);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    for (a5=0;a5<charset_size;a5++) if (markov1[a4][a5] > markov_threshold)
    for (a6=0;a6<charset_size;a6++) if (markov1[a5][a6] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (markov_charset[a6]|(0x80<<8)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 72,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (markov_charset[a6]|(0x80<<8)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(0x80<<8);image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(0x80<<8);image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Markov, len=10 */
/*
    csize=80+AC15;
    sched_wait(10);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    for (a5=0;a5<charset_size;a5++) if (markov1[a4][a5] > markov_threshold)
    for (a6=0;a6<charset_size;a6++) if (markov1[a5][a6] > markov_threshold)
    for (a7=0;a7<charset_size;a7++) if (markov1[a6][a7] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (markov_charset[a6]|(markov_charset[a7]<<8)|(0x80<<16)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 80,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (markov_charset[a6]|(markov_charset[a7]<<8)|(0x80<<16)) - 0xc4ac5665; //x2
    	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(0x80<<16);image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
    	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(0x80<<16);image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/


    /* Markov, len=11 */
/*
    csize=88+AC15;
    sched_wait(11);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    for (a5=0;a5<charset_size;a5++) if (markov1[a4][a5] > markov_threshold)
    for (a6=0;a6<charset_size;a6++) if (markov1[a5][a6] > markov_threshold)
    for (a7=0;a7<charset_size;a7++) if (markov1[a6][a7] > markov_threshold)
    for (a8=0;a8<charset_size;a8++) if (markov1[a7][a8] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (unsigned int)(markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(0x80<<24)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 88,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (unsigned int)(markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(0x80<<24)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(0x80<<24);image.w=0;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(0x80<<24);image.w=0;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/

    /* Markov, len=12 */
/*
    csize=96+AC15;
    sched_wait(12);
    clSetKernelArg(kernel[0], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[1], 2, sizeof(uint), (void*) &csize);
    clSetKernelArg(kernel[2], 2, sizeof(uint), (void*) &csize);
    if (sched_len()==12)
    for (a1=0;a1<reduced_size;a1+=ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size))
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&(a3=sched_s3(a1,a2,ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size)))<sched_e3(a1+ocl_get_inc(a1,wthreads[self].vectorsizev,reduced_size),a2))
    if ((markov2[a1][a2] > markov_threshold)||(markov2[a1+1][a2] > markov_threshold)
    ||(markov2[a1+2][a2] > markov_threshold)||(markov2[a1+3][a2] > markov_threshold)
    ||(markov2[a1+4][a2] > markov_threshold)||(markov2[a1+5][a2] > markov_threshold)
    ||(markov2[a1+6][a2] > markov_threshold)||(markov2[a1+7][a2] > markov_threshold)
    )
    if (markov1[a2][a3] > markov_threshold)
    for (a4=0;a4<charset_size;a4++) if (markov1[a3][a4] > markov_threshold)
    for (a5=0;a5<charset_size;a5++) if (markov1[a4][a5] > markov_threshold)
    for (a6=0;a6<charset_size;a6++) if (markov1[a5][a6] > markov_threshold)
    for (a7=0;a7<charset_size;a7++) if (markov1[a6][a7] > markov_threshold)
    for (a8=0;a8<charset_size;a8++) if (markov1[a7][a8] > markov_threshold)
    for (a9=0;a9<charset_size;a9++) if (markov1[a8][a9] > markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
	int i = ocl_get_kernel(a1, wthreads[self].vectorsizev, reduced_charset, &cbase);
	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);

        if (!hash_list->next)
        {
            mylist = hash_list;
            memcpy(hex1,mylist->hash,4);
            unsigned int A,B,C,D,tmp;
            memcpy(&A, hex1, 4);
            memcpy(hex1,mylist->hash+4,4);
            memcpy(&B, hex1, 4);
            memcpy(hex1,mylist->hash+8,4);
            memcpy(&C, hex1, 4);
            memcpy(hex1,mylist->hash+12,4);
            memcpy(&D, hex1, 4);
            A=(A-0x67452301);
            B=(B-0xefcdab89);
            C=(C-0x98badcfe);
            D=(D-0x10325476);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
            REVERSE_MD5STEP(C, D, A, B, (markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(markov_charset[a9]<<24)), 	S43, AC63);//x2
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
    	    REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
            tmp = markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
    	    REVERSE_MD5STEP(B, C, D, A, tmp, 	S44, AC56);//x1
            REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC55);
            REVERSE_MD5STEP(D, A, B, C, 0x80, 	S42, AC54);//x3
            REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC53);
            REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC52);
    	    REVERSE_MD5STEP(C, D, A, B, 96,	S43, AC51);
            REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC50);
	    REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC49);
	    B = ROTATE_RIGHT((B - C), 23) - (markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(markov_charset[a9]<<24)) - 0xc4ac5665; //x2
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(markov_charset[a9]<<24);image.w=0x80;
	    image.x = ROTATE_RIGHT((C - D), 16) - 0x1fa27cf8;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
            singlehash.x=A;singlehash.y=B;singlehash.z=C;singlehash.w=D;
            clSetKernelArg(kernel[i], 8, sizeof(cl_uint4), (void*) &singlehash);
        }
	else
	{
	    image.x=0;
	    image.y=markov_charset[a2]|(markov_charset[a3]<<8)|(markov_charset[a4]<<16)|(markov_charset[a5]<<24);
	    image.z=markov_charset[a6]|(markov_charset[a7]<<8)|(markov_charset[a8]<<16)|(markov_charset[a9]<<24);image.w=0x80;
	    image.y+=AC2;image.z+=AC3;
	    clSetKernelArg(kernel[i], 1, sizeof(cl_uint4), (void*) &image);
	}

	clSetKernelArg(kernel[i], 3, sizeof(cl_uint16), (void*) &cbase);
	err=clEnqueueNDRangeKernel(queue, kernel[i], 1, NULL, &global_work_size, local_work_size, 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    goto out;
	}
	if (!ocl_gpu_double)
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : global_work_size*wthreads[self].vectorsizev;
	    attack_current_count += (i==0) ? cbase.sF : wthreads[self].vectorsizev;
	}
	else
	{
	    wthreads[self].tries+=(i==0) ? global_work_size*cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;
	    attack_current_count += (i==0) ? cbase.sF : (i==1) ? global_work_size*wthreads[self].vectorsizev : global_work_size*wthreads[self].vectorsizev/2;;
	}

	int *fnd;
	fnd = clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	found = *fnd;

	if (found>0) 
        {
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, found, wthreads[self].vectorsize, 16);
	    bzero(plains,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
	    // Change for other types
	    bzero(hashes,16*8*MAXFOUND);
	    clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, 16*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    found = 0;
    	    clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	}
        clEnqueueUnmapMemObject(queue,found_buf,(void *)&found,0,NULL,NULL);
    }
*/
    out:
    free(hashes);
    free(plains);
    return hash_ok;
}


/* Needed objects for rule attack */
static cl_command_queue queue[64];
static size_t *local_work_size;
static cl_mem buffer[64];
static cl_kernel kernel[64];
static cl_mem bitmaps_buf[64];
static char *ptr[64];
static cl_mem found_ind_buf[64];
static cl_mem found_buf[64];
static cl_uint4 singlehash[64];
static cl_mem images_buf[64];
static cl_mem sizes_buf[64];
static char *images[64];
static int *sizes[64];
static cl_uint *found_ind[64];
static int counts[64][16];


static void ocl_md5_callback(char *line, int self)
{
    //printf("%s\n",line);
    char terminator=0x80;
    int a,b,c,e;
    int found;
    int err;
    struct  hash_list_s  *mylist, *addlist;
    char plain[MAX];

    strcpy(&images[self][0]+(counts[self][0]*MAX),line);
    sizes[self][counts[self][0]] = strlen(line)<<3;
    memcpy((&images[self][0]+(counts[self][0]*MAX)+strlen(line)),&terminator,1);
    counts[self][0]++;

    int z;
    if ((counts[self][0]==ocl_rule_workset*ocl_vector)||(line[0]==0x01))
    {
	pthread_mutex_lock(&wthreads[self].tempmutex);
	pthread_mutex_unlock(&wthreads[self].tempmutex);
	

	if (attack_over==2) pthread_exit(NULL);
	
	err=clEnqueueWriteBuffer(queue[self], images_buf[self], CL_FALSE, 0, ocl_rule_workset*ocl_vector*MAX, images[self], 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueWriteBuffer error (%d)\n",err);
	    exit(1);
	}
	
	err=clEnqueueWriteBuffer(queue[self], sizes_buf[self], CL_FALSE, 0, ocl_rule_workset*ocl_vector*sizeof(int), sizes[self], 0, NULL, NULL);
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueWriteBuffer error (%d)\n",err);
	    exit(1);
	}
	
	
	invocations++;

        if (found==1)
        {
    	    found = 0;
    	    clEnqueueWriteBuffer(queue[self], found_buf[self], CL_FALSE, 0, 4, &found, 0, NULL, NULL);
	}

        
        
        err=clEnqueueNDRangeKernel(queue[self], kernel[self], 1, NULL, &ocl_rule_workset, local_work_size, 0, NULL, NULL);
	
	if (err != CL_SUCCESS)
	{
	    elog("clEnqueueNDRangeKernel error (%d)\n",err);
	    exit(1);
	}
	//clFlush(queue[self]);
	if (ocl_dev_nvidia==1) clEnqueueReadBuffer(queue[self], found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	else 
	{
	    int *fnd;
	    fnd = clEnqueueMapBuffer(queue[self], found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    found = *fnd;
	}

	if (found==1) 
	{
	    err = clEnqueueReadBuffer(queue[self], found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset*sizeof(cl_uint), found_ind[self], 0, NULL, NULL);
	    if (err!=CL_SUCCESS) 
	    {
		elog("clEnqueueReadBuffer error (%d)\n",err);
		exit(1);
	    }
	    for (a=0;a<ocl_rule_workset;a++)
	    if (found_ind[self][a]==1)
	    {
		b=a*ocl_vector;
    		err = clEnqueueReadBuffer(queue[self], buffer[self], CL_TRUE, b*16, 16*ocl_vector, ptr[self]+b*16, 0, NULL, NULL);
		for (c=0;c<ocl_vector;c++)
		{
		    e=(a)*ocl_vector+c;

    		    if ( (hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].count<MAXINDEX) && (hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].count>0))
    		    {
    			int i;
    			for (i=0;i<hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].count;i++)
    			if (memcmp(hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].nodes[i]->hash, (char *)ptr[self]+(e)*16, hash_ret_len) == 0)
    			{
                    	    mylist = hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].nodes[i];
                    	    int flag = 0;
                    	    strcpy(plain,&images[self][0]+(e*MAX));
                    	    plain[strlen(plain)-1] = 0;
                    	    pthread_mutex_lock(&crackedmutex);
                    	    addlist = cracked_list;
                    	    while (addlist)
                    	    {
                        	if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
                                    flag = 1;
                        	addlist = addlist->next;
                    	    }
                    	    pthread_mutex_unlock(&crackedmutex);
                    	    if (flag == 0)
                    	    {
                        	add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                    	    }
    			}
    		    }
    		    else if (hash_index[ptr[self][e*16]&255][ptr[self][e*16+1]&255].count>=MAXINDEX)
    		    {
    			mylist = hash_list;
    			while (mylist)
    			{
            		    if (memcmp(mylist->hash, (char *)ptr[self]+(e)*16, hash_ret_len) == 0)
            		    {
                    		int flag = 0;
                    		strcpy(plain,&images[self][0]+(e*MAX));
                    		plain[strlen(plain)-1] = 0;
                    		pthread_mutex_lock(&crackedmutex);
                    		addlist = cracked_list;
                    		while (addlist)
                    		{
                        	    if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
                                    flag = 1;
                        	    addlist = addlist->next;
                    		}
                    		pthread_mutex_unlock(&crackedmutex);
                    		if (flag == 0)
                    		{
                        	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, plain);
                    		}
            		    }
            		    if (mylist) mylist = mylist->next;
        		}
        	    }
		}
	    }
	    bzero(found_ind[self],ocl_rule_workset*sizeof(cl_uint));
	    pthread_mutex_lock(&biglock);
    	    clEnqueueWriteBuffer(queue[self], found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset*sizeof(cl_uint), found_ind[self], 0, NULL, NULL);
	    pthread_mutex_unlock(&biglock);
    	}
    	clEnqueueUnmapMemObject(queue[self],found_buf[self],(void *)&found,0,NULL,NULL);
    	bzero(&images[self][0],ocl_rule_workset*ocl_vector*MAX);
	counts[self][0]=0;
    }
    
    if (attack_over==2) pthread_exit(NULL);
}


/* Worker thread - hybrid attack */
void* ocl_hybrid_md5_thread(void *arg)
{
    int err;
    unsigned char hex1[16];
    int a;
    int found;
    struct  hash_list_s  *mylist;
    size_t nvidia_local_work_size[3]={128,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    if (ocl_dev_nvidia) local_work_size = nvidia_local_work_size;
    else local_work_size = NULL;
    ocl_rule_workset=256*256*2;
    ptr[self] = malloc(ocl_rule_workset*16*ocl_vector);
    counts[self][0]=0;


    /* Thread initialization */

    pthread_mutex_lock(&biglock);
    kernel[self] = clCreateKernel(program[self], "md5", &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateKernel error (%d)\n",err);
	return NULL;
    }
    memcpy(&self,arg,sizeof(int));
    queue[self] = clCreateCommandQueue(context[self], device[self/ocl_threads], 0, &err );
    if (err != CL_SUCCESS)
    {
        elog("clCreateCommandQueue error (%d)\n",err);
	return NULL;
    }
    buffer[self] = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset*ocl_vector*16, NULL, &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }
    found_buf[self] = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }
    if (err != CL_SUCCESS)
    {
	elog("clCreateBuffer error (%d)\n",err);
	return NULL;
    }

    bitmaps = malloc(256*256*32*4);
    for (a=0;a<256*256*32;a++)
    {
        bitmaps[a]=0;
    }

    mylist = hash_list;
    a=0;
    while (mylist)
    {
	memcpy(hex1,mylist->hash,16);
	a++;
	unsigned int *b_a = (unsigned int *)hex1;
	unsigned int *b_b = (unsigned int *)&hex1[4];
	unsigned int *b_c = (unsigned int *)&hex1[8];
	unsigned int *b_d = (unsigned int *)&hex1[12];
	unsigned int bind_a = (*b_a)>>13;
	unsigned int bval_a = (1<<((*b_a)&31));
	unsigned int bind_b = (*b_b)>>13;
	unsigned int bval_b = (1<<((*b_b)&31));
	unsigned int bind_c = (*b_c)>>13;
	unsigned int bval_c = (1<<((*b_c)&31));
	unsigned int bind_d = (*b_d)>>13;
	unsigned int bval_d = (1<<((*b_d)&31));
	bitmaps[bind_a] |=bval_a;
	bitmaps[bind_b+65535*8] |=bval_b;
	bitmaps[bind_c+65535*16] |=bval_c;
	bitmaps[bind_d+65535*24] |=bval_d;
	singlehash[self].x |= (1<<((*b_b)&31));
	singlehash[self].y |= (1<<((*b_c)&31));
	singlehash[self].z |= (1<<((*b_d)&31));
    	if (mylist) mylist = mylist->next;
    }
    if (a==1)
    {
        mylist = hash_list;
        memcpy(hex1,mylist->hash,4);
        memcpy(&singlehash[self].x, hex1, 4);
        memcpy(hex1,mylist->hash+4,4);
        memcpy(&singlehash[self].y, hex1, 4);
        memcpy(hex1,mylist->hash+8,4);
        memcpy(&singlehash[self].z, hex1, 4);
        memcpy(hex1,mylist->hash+12,4);
        memcpy(&singlehash[self].w, hex1, 4);
        clSetKernelArg(kernel[self], 6, sizeof(cl_uint4), (void*) &singlehash[self]);
    }
    else 
    {
        singlehash[self].w=0;
        clSetKernelArg(kernel[self], 6, sizeof(cl_uint4), (void*) &singlehash[self]);
    }

    found_ind[self]=malloc(ocl_rule_workset*sizeof(cl_uint));
    bzero(found_ind[self],sizeof(uint)*ocl_rule_workset);
    found_ind_buf[self] = clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset*sizeof(cl_uint), NULL, &err );
    clEnqueueWriteBuffer(queue[self], found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    bitmaps_buf[self] = clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, 256*256*32*4, bitmaps, &err );
    
    images_buf[self] = clCreateBuffer(context[self], CL_MEM_READ_ONLY, ocl_rule_workset*ocl_vector*MAX, NULL, &err );
    sizes_buf[self] = clCreateBuffer(context[self], CL_MEM_READ_ONLY, ocl_rule_workset*ocl_vector*sizeof(int), NULL, &err );
    sizes[self]=malloc(ocl_rule_workset*ocl_vector*sizeof(int));
    images[self]=malloc(ocl_rule_workset*ocl_vector*MAX);

    bzero(&images[self][0],ocl_rule_workset*ocl_vector*MAX);

    
    clSetKernelArg(kernel[self], 0, sizeof(cl_mem), (void*) &buffer[self]);
    clSetKernelArg(kernel[self], 1, sizeof(cl_mem), (void*) &images_buf[self]);
    clSetKernelArg(kernel[self], 2, sizeof(cl_mem), (void*) &sizes_buf[self]);
    clSetKernelArg(kernel[self], 3, sizeof(cl_mem), (void*) &found_ind_buf[self]);
    clSetKernelArg(kernel[self], 4, sizeof(cl_mem), (void*) &bitmaps_buf[self]);
    clSetKernelArg(kernel[self], 5, sizeof(cl_mem), (void*) &found_buf[self]);
    
    pthread_mutex_unlock(&biglock); 
    // TODO: ocl_vector?
    // copy to double buffer so that we release CPU time for rule thread?
    // RULE_GEN_PARSE?
    rule_gen_parse(rule_file,ocl_md5_callback,ocl_threads*devicesnum,self);

    return hash_ok;
}




hash_stat ocl_bruteforce_md5(void)
{
    int a,b,i;
    uint64_t bcnt;
    int err;
    int worker_thread_keys[32];


    if (bruteforce_end<5) 
    {
	bruteforce_end = bruteforce_start=5;
	hlog("Raising bruteforce start and max len limit to %d\n",5);
    }
    bcnt=strlen(bruteforce_charset);
    for (a=5;a<=bruteforce_end;a++) bcnt*=strlen(bruteforce_charset);
    attack_overall_count = bcnt;
    if (strlen(bruteforce_charset)<=25) attack_overall_count /= strlen(bruteforce_charset);

    /* setup initial OpenCL vars */
    int numplatforms=0;
    err = clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (err != CL_SUCCESS)
    {
	elog("clGetPlatformIDs error (%d)\n",err);
	return hash_err;
    }

    if (strlen(bruteforce_charset)>25)
    {
        init_bruteforce_long();
	scheduler_setup(bruteforce_start, 6, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
	for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
	{
	    err = clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
	    if (err != CL_SUCCESS)
	    {
    		elog("clGetDeviceIDs error (%d)\n",err);
    		return hash_err;
	    }

    	    context[i] = clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);
    	    if (err != CL_SUCCESS)
    	    {
        	elog("clCreateContext error (%d)\n",err);
        	return hash_err;
    	    }

    	    if (wthreads[i].type != nv_thread)
    	    {
        	char *binary;
        	size_t binary_size;
        	FILE *fp;
        	char pbuf[100];
        	bzero(pbuf,100);
        	char kernelfile[255];
        	err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
        	if (hash_list->next) 
        	{
        	    sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long__%s.bin",DATADIR,pbuf);
    		}
    		else
    		{
        	    if (bruteforce_end<8) sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long_SM_%s.bin",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long_S_%s.bin",DATADIR,pbuf);
		}

    		char *ofname = kernel_decompress(kernelfile);
        	if (!ofname) return hash_err;
        	fp=fopen(ofname,"r");
        	free(ofname);
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
        	if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
        	program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
        	if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
        	err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
        	if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
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
        	err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    		cl_uint compute_capability_major, compute_capability_minor;
        	clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
        	clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
        	if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
        	if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
        	if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
        	if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
        	if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
        	if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
        	if (hash_list->next) 
        	{
        	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long__%s.ptx",DATADIR,pbuf);
    		}
    		else
    		{
        	    if (bruteforce_end<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long_SM_%s.ptx",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long_S_%s.ptx",DATADIR,pbuf);
		}

    		char *ofname = kernel_decompress(kernelfile);
        	if (!ofname) return hash_err;
        	fp=fopen(ofname,"r");
        	free(ofname);
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
        	if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
        	program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
        	if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
        	err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
        	if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
        	free(binary);
    	    }
	}

	pthread_mutex_init(&biglock, NULL);
	for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
	{
	    worker_thread_keys[a]=a;
	    pthread_create(&crack_threads[a], NULL, ocl_bruteforce_md5_thread, &worker_thread_keys[a]);
	}
    }
    else
    {
        init_bruteforce_short();
	scheduler_setup(bruteforce_start, 6, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
	for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
	{
	    err = clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
	    if (err != CL_SUCCESS)
	    {
    		elog("clGetDeviceIDs error (%d)\n",err);
    		return hash_err;
	    }

    	    context[i] = clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);
    	    if (err != CL_SUCCESS)
    	    {
        	elog("clCreateContext error (%d)\n",err);
        	return hash_err;
    	    }

    	    if (wthreads[i].type != nv_thread)
    	    {
        	char *binary;
        	size_t binary_size;
        	FILE *fp;
        	char pbuf[100];
        	bzero(pbuf,100);
        	char kernelfile[255];
        	err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
        	if (hash_list->next) 
        	{
        	    sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long__%s.bin",DATADIR,pbuf);
    		}
    		else
    		{
        	    if (bruteforce_end<8) sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_short_SM_%s.bin",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_short_S_%s.bin",DATADIR,pbuf);
		}

    		char *ofname = kernel_decompress(kernelfile);
        	if (!ofname) return hash_err;
        	fp=fopen(ofname,"r");
        	free(ofname);
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
        	if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
        	program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
        	if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
        	err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
        	if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
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
        	err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    		cl_uint compute_capability_major, compute_capability_minor;
        	clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
        	clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
        	if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
        	if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
        	if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
        	if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
        	if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
        	if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
        	if (hash_list->next) 
        	{
        	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_short__%s.ptx",DATADIR,pbuf);
    		}
    		else
    		{
        	    if (bruteforce_end<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_short_SM_%s.ptx",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_short_S_%s.ptx",DATADIR,pbuf);
		}

    		char *ofname = kernel_decompress(kernelfile);
        	if (!ofname) return hash_err;
        	fp=fopen(ofname,"r");
        	free(ofname);
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
        	if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
        	program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
        	if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
        	err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
        	if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
        	free(binary);
    	    }
	}

	pthread_mutex_init(&biglock, NULL);
	for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
	{
	    worker_thread_keys[a]=a;
	    pthread_create(&crack_threads[a], NULL, ocl_bruteforce_md5_short_thread, &worker_thread_keys[a]);
	}
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);

    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}



hash_stat ocl_markov_md5(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (fast_markov==1)  hlog("Fast markov attack mode enabled%s\n","");
    init_markov();
    scheduler_setup(4, 5, markov_max_len, reduced_size, strlen(markov_charset));

    /* setup initial OpenCL vars */
    int numplatforms=0;
    err = clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (err != CL_SUCCESS)
    {
	elog("clGetPlatformIDs error (%d)\n",err);
	return hash_err;
    }

    for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
    {
	err = clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
	if (err != CL_SUCCESS)
	{
    	    elog("clGetDeviceIDs error (%d)\n",err);
    	    return hash_err;
	}

        context[i] = clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);
        if (err != CL_SUCCESS)
        {
            elog("clCreateContext error (%d)\n",err);
            return hash_err;
        }
    
        if (wthreads[i].type != nv_thread)
        {
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
            if (hash_list->next) 
            {
        	sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long__%s.bin",DATADIR,pbuf);
    	    }
    	    else
    	    {
        	if (markov_max_len<8) sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long_SM_%s.bin",DATADIR,pbuf);
        	else sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_long_S_%s.bin",DATADIR,pbuf);
	    }

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            free(ofname);
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
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
            err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
            if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
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
            err = clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    cl_uint compute_capability_major, compute_capability_minor;
            clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
            clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
            if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
            if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
            if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
            if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
            if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
            if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
            
            if (hash_list->next) 
            {
        	sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long__%s.ptx",DATADIR,pbuf);
    	    }
    	    else
    	    {
        	if (markov_max_len<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long_SM_%s.ptx",DATADIR,pbuf);
        	else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_long_S_%s.ptx",DATADIR,pbuf);
	    }

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            free(ofname);
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
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
            err = clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
            if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
            free(binary);
        }
    }

    pthread_mutex_init(&biglock, NULL);
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
	worker_thread_keys[a]=a;
	pthread_create(&crack_threads[a], NULL, ocl_markov_md5_thread, &worker_thread_keys[a]);
    }
    
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);
    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_markov;
    attack_over=2;
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_hybrid_md5(void)
{
    int a;
    int err;
    int worker_thread_keys[32];

    /* setup initial OpenCL vars */
    int numplatforms=0;
    err = clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (err != CL_SUCCESS)
    {
	elog("clGetPlatformIDs error (%d)\n",err);
	return hash_err;
    }

    err = clGetDeviceIDs(platform[ocl_gpu_platform], CL_DEVICE_TYPE_GPU, 16, device, (cl_uint *)&devicesnum);
    if (err != CL_SUCCESS)
    {
        elog("clGetDeviceIDs error (%d)\n",err);
        return hash_err;
    }


    for (a=0;a<devicesnum*ocl_threads;a++)
    {
        context[a] = clCreateContext(NULL, 1, &device[a/ocl_threads], NULL, NULL, &err);
        if (err != CL_SUCCESS)
        {
            elog("clCreateContext error (%d)\n",err);
            return hash_err;
        }
    
        if (ocl_dev_nvidia==0)
        {
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            err = clGetDeviceInfo(device[a/ocl_threads], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
            if (hash_list->next) 
            {
    		 sprintf(kernelfile,"%s/hashkill/kernels/amd_md5__%s.bin",DATADIR,pbuf);
    	    }
    	    else
    	    {
        	sprintf(kernelfile,"%s/hashkill/kernels/amd_md5_S_%s.bin",DATADIR,pbuf);
	    }

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            free(ofname);
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
            if ((a%ocl_threads)==0) hlog("Loading kernel: %s\n",kernelfile);
            program[a] = clCreateProgramWithBinary(context[a], 1, &device[a/ocl_threads], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            if (err!=CL_SUCCESS) elog("Cannot compile binary! (%d)\n",err);
            err = clBuildProgram(program[a], 1, &device[a/ocl_threads], "", NULL, NULL );
            if (err!=CL_SUCCESS) elog("Cannot build binary! (%d)\n",err);
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
            err = clGetDeviceInfo(device[a/ocl_threads], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    cl_uint compute_capability_major, compute_capability_minor;
            clGetDeviceInfo(device[a/ocl_threads], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
            clGetDeviceInfo(device[a/ocl_threads], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
            if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
            if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
            if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
            if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
            if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
            if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");

            if (hash_list->next) 
            {
        	if (ocl_gpu_double==1)
        	{
        	    if (markov_max_len<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_DM_%s.ptx",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_D_%s.ptx",DATADIR,pbuf);
        	}
        	else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5__%s.ptx",DATADIR,pbuf);
    	    }
    	    else
    	    {
        	if (ocl_gpu_double==1)
        	{
        	    if (markov_max_len<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_SDM_%s.ptx",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_SD_%s.ptx",DATADIR,pbuf);
        	}
        	else 
        	{
        	    if (markov_max_len<8) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_SM_%s.ptx",DATADIR,pbuf);
        	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_md5_S_%s.ptx",DATADIR,pbuf);
        	}
	    }

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            free(ofname);
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
            if ((a%ocl_threads)==0) hlog("Loading kernel: %s\n",kernelfile);
            program[a] = clCreateProgramWithBinary(context[a], 1, &device[a/ocl_threads], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            if (err!=CL_SUCCESS) elog("Cannot compile binary!\n%s","");
            err = clBuildProgram(program[a], 1, &device[a/ocl_threads], NULL, NULL, NULL );
            if (err!=CL_SUCCESS) elog("Cannot build binary!\n%s","");
            free(binary);
        }
    }

    pthread_mutex_init(&biglock, NULL);

    for (a=0;a<devicesnum*ocl_threads;a++)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_hybrid_md5_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<devicesnum*ocl_threads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}


#endif
