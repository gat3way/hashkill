/*
 * ocl_sl3.c
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

/* Hash reversal macros and constants */
#define H0 0x67452301
#define H1 0xEFCDAB89
#define H2 0x98BADCFE
#define H3 0x10325476
#define H4 0xC3D2E1F0
#define ROTL(p,q) ((p) << (q)) | ((p) >> (32-(q)));
#define ROTR(p,q) ((p) >> (q)) | ((p) << (32-(q)));
#define REV(p) { tmp=(p);tmp1=ROTL(tmp,8);tmp2=ROTL(tmp,24); (p)=(tmp1 & 0x00FF00FF)|(tmp2 & 0xFF00FF00); }
#define K0 0x5A827999


static char sl3bruteforce_charset[10];

static void ocl_set_params(int loopnr, cl_uint4 param1, cl_uint4 param2, cl_uint16 param3, cl_uint16 *p1, cl_uint16 *p2, cl_uint16 *p3, cl_uint16 *p4, cl_uint16 *p5, cl_uint16 *p6)
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
	    p3->s0=param3.s0;
	    p3->s1=param3.s1;
	    p3->s2=param3.s2;
	    p3->s3=param3.s3;
	    p3->s4=param3.s4;
	    p3->s5=param3.s5;
	    p3->s6=param3.s6;
	    p3->s7=param3.s7;
	    p3->s8=param3.s8;
	    p3->s9=param3.s9;
	    p3->sA=param3.sA;
	    p3->sB=param3.sB;
	    p3->sC=param3.sC;
	    p3->sD=param3.sD;
	    p3->sE=param3.sE;
	    p3->sF=param3.sF;
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
	    p4->s0=param3.s0;
	    p4->s1=param3.s1;
	    p4->s2=param3.s2;
	    p4->s3=param3.s3;
	    p4->s4=param3.s4;
	    p4->s5=param3.s5;
	    p4->s6=param3.s6;
	    p4->s7=param3.s7;
	    p4->s8=param3.s8;
	    p4->s9=param3.s9;
	    p4->sA=param3.sA;
	    p4->sB=param3.sB;
	    p4->sC=param3.sC;
	    p4->sD=param3.sD;
	    p4->sE=param3.sE;
	    p4->sF=param3.sF;
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
	    p5->s0=param3.s0;
	    p5->s1=param3.s1;
	    p5->s2=param3.s2;
	    p5->s3=param3.s3;
	    p5->s4=param3.s4;
	    p5->s5=param3.s5;
	    p5->s6=param3.s6;
	    p5->s7=param3.s7;
	    p5->s8=param3.s8;
	    p5->s9=param3.s9;
	    p5->sA=param3.sA;
	    p5->sB=param3.sB;
	    p5->sC=param3.sC;
	    p5->sD=param3.sD;
	    p5->sE=param3.sE;
	    p5->sF=param3.sF;
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
	    p6->s0=param3.s0;
	    p6->s1=param3.s1;
	    p6->s2=param3.s2;
	    p6->s3=param3.s3;
	    p6->s4=param3.s4;
	    p6->s5=param3.s5;
	    p6->s6=param3.s6;
	    p6->s7=param3.s7;
	    p6->s8=param3.s8;
	    p6->s9=param3.s9;
	    p6->sA=param3.sA;
	    p6->sB=param3.sB;
	    p6->sC=param3.sC;
	    p6->sD=param3.sD;
	    p6->sE=param3.sE;
	    p6->sF=param3.sF;
	    break;
    }
}




static void ocl_get_cracked(cl_command_queue queuein,cl_mem plains_buf, char *plains, cl_mem hashes_buf, char *hashes, int numfound, int vsize, int hashlen)
{
    int a,b,e=0;
    unsigned char plain[32];
    char finalplain[32];
    struct hash_list_s  *mylist, *addlist;
    int flag=0;

    if (numfound>MAXFOUND) 
    {
	printf("error found=%d\n",numfound);
	return;
    }

    _clEnqueueReadBuffer(queuein, plains_buf, CL_TRUE, 0, 16*numfound*vsize, plains, 0, NULL, NULL);
    _clEnqueueReadBuffer(queuein, hashes_buf, CL_TRUE, 0, hashlen*numfound*vsize, hashes, 0, NULL, NULL);


    for (a=0;a<numfound;a++)
    for (b=0;b<vsize;b++)
    if (hash_index[hashes[(a*vsize+b)*hashlen]&255][hashes[(a*vsize+b)*hashlen+1]&255].nodes)
    {
    	e=a*vsize+b;
	mylist = hash_index[hashes[e*hashlen]&255][hashes[e*hashlen+1]&255].nodes;
	while (mylist)
	{
    	    if (memcmp(mylist->hash, (char *)hashes+(e)*hashlen, hash_ret_len) == 0)
    	    {
	        memcpy(plain,plains+(e*16),16);
	        int d;
	        for (d=0;d<15;d++) sprintf(finalplain+(d*2),"%02x",plain[d]);
        	pthread_mutex_lock(&crackedmutex);
        	addlist = cracked_list;
        	while (addlist)
        	{
            	    if ( memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0)
                        flag = 1;
            	    addlist = addlist->next;
        	}
        	pthread_mutex_unlock(&crackedmutex);
        	if (flag == 0)
        	{
            	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, finalplain);
        	}
    	    }
    	    mylist = mylist->indexnext;
        }
    }
}


/* Bruteforce initializer big charsets */
static void init_bruteforce_long()
{
    int a;
    int a1,a2,a3,a4,a5,a6;

    bitmaps = malloc(256*256*32*8*4);
    table = malloc(10000*4);

    table = malloc(sizeof(uint)*10*10*10*10*10*10);
    
    for (a1=0;a1<10;a1++)
    for (a2=0;a2<10;a2++)
    for (a3=0;a3<10;a3++)
    for (a4=0;a4<10;a4++)
    for (a5=0;a5<10;a5++)
    for (a6=0;a6<10;a6++)
    {
        table[a1*100000+a2*10000+a3*1000+a4*100+a5*10+a6] = ((((a1)<<4)|(a2))<<16) | ((((a3)<<4)|(a4))<<8) | (((a5)<<4|(a6)));
    }

    for (a=0;a<256*256*8*32;a++)
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
static void ocl_execute(cl_command_queue queue, cl_kernel kernel, size_t *global_work_size, size_t *local_work_size, int charset_size, cl_mem found_buf, cl_mem hashes_buf, cl_mem plains_buf, char *plains, char * hashes,int self, cl_uint16 *p1,cl_uint16 *p2,cl_uint16 *p3,cl_uint16 *p4,cl_uint16 *p5,cl_uint16 *p6)
{
    int err;
    int *found;

    _clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) p1);
    _clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) p2);
    _clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) p3);
    _clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) p4);
    _clSetKernelArg(kernel, 10, sizeof(cl_uint16), (void*) p5);
    _clSetKernelArg(kernel, 11, sizeof(cl_uint16), (void*) p6);

    {
	_clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	found = _clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	if (*found>0) 
	{
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len);
    	    bzero(plains,16*8*MAXFOUND);
    	    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    	    // Change for other types
    	    bzero(hashes,hash_ret_len*8*MAXFOUND);
    	    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len*8*MAXFOUND, hashes, 0, NULL, NULL);
    	    *found = 0;
    	    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
	}
    	_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
    }
    wthreads[self].tries += global_work_size[0]*global_work_size[1]*wthreads[self].loops*wthreads[self].vectorsize;
    attack_current_count += wthreads[self].loops;
}




/* Bruteforce larger charsets */
void* ocl_bruteforce_sl3_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    unsigned char hex1[hash_ret_len];
    int self;
    cl_kernel kernel;
    cl_mem bitmaps_buf;
    int a;
    int a1,a2,a3,a4,a5,a6,a7,a8;
    int try=0;
    char *hashes;
    int charset_size = 10;
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    char salt[8];
    struct  hash_list_s  *mylist;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 p1;
    cl_uint16 p2;
    cl_uint16 p3;
    cl_uint16 p4;
    cl_uint16 p5;
    cl_uint16 p6;
    cl_uint16 xors;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={128,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "sl3_double", &err );
    else  kernel = _clCreateKernel(program[self], "sl3_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );

    mylist = hash_list;
    a=0;
    while (mylist)
    {
        memcpy(hex1,mylist->hash,hash_ret_len);
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
	p2.s0=p2.s4=p2.s8=p2.sC=singlehash.x;
	p2.s1=p2.s5=p2.s9=p2.sD=singlehash.y;
	p2.s2=p2.s6=p2.sA=p2.sE=singlehash.z;
	p2.s3=p2.s7=p2.sB=p2.sF=singlehash.z;
    }
    if (a==1)
    {
        unsigned int tmp,tmp1,tmp2,E;
        mylist = hash_list;
        memcpy(hex1,mylist->hash,4);
        memcpy(&singlehash.x, hex1, 4);
        REV(singlehash.x);
        singlehash.x-=H0;
        memcpy(hex1,mylist->hash+4,4);
        memcpy(&singlehash.y, hex1, 4);
        REV(singlehash.y);
        singlehash.y-=H1;
        memcpy(hex1,mylist->hash+8,4);
        memcpy(&singlehash.z, hex1, 4);
        REV(singlehash.z);
        singlehash.z-=H2;
        memcpy(hex1,mylist->hash+12,4);
        memcpy(&singlehash.w, hex1, 4);
        REV(singlehash.w);
        singlehash.w-=H3;
        memcpy(&E,mylist->hash+16,4);
        REV(E);
        E-=H4;
        singlehash.y = ROTR(E,30);
    }
    else
    {
        singlehash.w=0;
    }



    // Change for other lens
    hashes  = malloc(hash_ret_len*8*MAXFOUND); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len*8*MAXFOUND, NULL, &err );
    plains=malloc(16*8*MAXFOUND);
    bzero(plains,16*8*MAXFOUND);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,hash_ret_len*8*MAXFOUND);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len*8*MAXFOUND, hashes, 0, NULL, NULL);


    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    table_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, sizeof(uint)*10*10*10*10*10*10,table , &err );
    bitmaps_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 256*256*32*8*4, bitmaps, &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);


    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    _clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &bitmaps_buf);
    _clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &found_buf);
    _clSetKernelArg(kernel, 5, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (10*10*10*10*10*10)/wthreads[self].vectorsize;
    global_work_size[1] = (10);
    while ((global_work_size[0] % local_work_size[0])!=0) global_work_size[0]++;
    global_work_size[1] = (global_work_size[1]);
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 



    /* bruteforce, len=12 */
    scheduler.len=12;
    csize=192;
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((a3=sched_s3(a1,a2))<sched_e3(a1,a2))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

        image.x=0;
        image.y=sl3bruteforce_charset[a1]|(sl3bruteforce_charset[a2]<<8)|(sl3bruteforce_charset[a3]<<16)|(sl3bruteforce_charset[a4]<<24);
        unsigned int tmp,tmp1,tmp2;
        image.z=sl3bruteforce_charset[a5]|(sl3bruteforce_charset[a6]<<8)|(sl3bruteforce_charset[a7]<<16)|(sl3bruteforce_charset[a8]<<16);
        image.w=0;
        REV(image.y);
        REV(image.z);
        REV(image.w);
        xors.s0=xors.s1=xors.s2=xors.s3=xors.s4=xors.s5=xors.s6=xors.s7=0;
        xors.s8=xors.s9=xors.sA=xors.sB=xors.sC=xors.sD=xors.sE=xors.sF=0;
        xors.s0=ROTL(image.w^image.y,1);
        xors.s1= ROTL(((csize))^image.z,1);
        xors.s2= ROTL(xors.s0,1);
        xors.s3= ROTL(xors.s1,1);
        xors.s4= ROTL(xors.s2^((csize)),1);
        xors.s5= ROTL(xors.s1^xors.s4,1);
        xors.s6= ROTL(xors.s5^xors.s3^((csize)),1);
        xors.s7= xors.s4^xors.s0^((csize));
        xors.s8= xors.s5^xors.s2^xors.s1;
        xors.s9= xors.s6^xors.s4^xors.s3;
        unsigned int A,B,C,D,E,l,l1;
        A=H0;B=H1;C=H2;D=H3;E=H4;
        l=ROTL(A,5);
        l1 = ((((C) ^ (D)) & (B)) ^ (D));
        E = E + K0 + l + l1;
        xors.sB = E;
        B = ROTL(B,30);
        l1 =((((B) ^ (C)) & (A)) ^ (C));
        D = D + K0 + image.y + l1;
        xors.sC = D;
        A = ROTL(A,30);
        C = C + K0 + image.z;
        xors.sD = C;
        hex2str(salt,hash_list->salt,strlen(hash_list->salt));
	xors.sE=(salt[0]&255)|((salt[1]&255) << 8)|((salt[2]&255)<<16)|((salt[3]&255)<<24);
        xors.sF=(salt[4]&255)|((salt[5]&255) << 8)|((salt[6]&255)<<16);
        REV(xors.sE);
        REV(xors.sF);
	ocl_set_params(try,image,singlehash,xors,&p1,&p2,&p3,&p4,&p5,&p6);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5,&p6);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5,&p6);

    out:
    free(hashes);
    free(plains);
    return hash_ok;
}





hash_stat ocl_bruteforce_sl3(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    attack_method=attack_method_simple_bruteforce;
    strcpy(bruteforce_charset,"0123456789");

    bruteforce_start=bruteforce_end=15;
    sl3bruteforce_charset[0]=0;
    memcpy(sl3bruteforce_charset+1,"\x01\x02\x03\x04\x05\x06\x07\x08\x09",9);

    bruteforce_start=12;
    attack_overall_count = 99999999;

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

    init_bruteforce_long();
    scheduler_setup(bruteforce_start, 9, 12, 10, 10);
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_sl3__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_sl3__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_bruteforce_sl3_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);
    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}

