/*
 * ocl_msoffice_old.c
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


static int hash_ret_len1=20;


/* File Buffer */
static char *buf;

/* Compound file binary format ones */
static int minifatsector;
static int minisectionstart;
static int minisectionsize;
static int *difat;
static int sectorsize;

/* Encryption-specific ones */
static unsigned char docsalt[32];
static unsigned char verifier[32];
static unsigned char verifierhash[32];
static int verifierhashsize;
static int keybits;
static unsigned int saltsize;
static unsigned int type=0;


/* Get buffer+offset for sector */
static char* get_buf_offset(int sector)
{
    return (buf+(sector+1)*sectorsize);
}



/* Get FAT table for a given sector */
static int* get_fat(int sector)
{
    char *fat=NULL;
    int difatn=0;

    if (sector<(sectorsize/4))
    {
        fat=get_buf_offset(difat[0]);
        return (int*)fat;
    }
    while ((!fat)&&(difatn<109))
    {
        if (sector>(((difatn+2)*sectorsize)/4)) difatn++;
        else fat=get_buf_offset(difat[difatn]);
    }
    return (int*)fat;
}


/* Get mini FAT table for a given minisector */
static int* get_mtab(int sector)
{
    int *fat=NULL;
    char *mtab=NULL;
    int mtabn=0;
    int nextsector;

    nextsector = minifatsector;

    while (mtabn<sector)
    {
        mtabn++;
        if (sector>((mtabn*sectorsize)/4))
        {
            /* Get fat entry for next table; */
            fat = get_fat(nextsector);
            nextsector = fat[nextsector];
            mtabn++;
        }
    }
    mtab=get_buf_offset(nextsector);
    return (int*)mtab;
}


/* Get minisection sector nr per given mini sector offset */
static int get_minisection_sector(int sector)
{
    int *fat=NULL;
    int sectn=0;
    int sectb=0;
    int nextsector;


    nextsector = minisectionstart;
    fat = get_fat(nextsector);
    sectn=0;
    while (sector>sectn)
    {
        sectn++;
        sectb++;
        if (sectb>=(sectorsize/64))
        {
            sectb=0;
            /* Get fat entry for next table; */
            fat = get_fat(nextsector);
            nextsector = fat[nextsector];
        }
    }
    return nextsector;
}


/* Get minisection offset */
static int get_mini_offset(int sector)
{
    return ((sector*64)%(sectorsize));
}



/* Read stream from table - callee needs to free memory */
static char* read_stream(int start, int size)
{
    char *lbuf=malloc(4);
    int lsize=0;
    int *fat=NULL;      // current minitab
    int sector;

    sector=start;

    while ((lsize)<size)
    {
        lbuf = realloc(lbuf,lsize+sectorsize);
        memcpy(lbuf + lsize,get_buf_offset(sector), sectorsize);
        lsize += sectorsize;
        fat = get_fat(sector);
        sector = fat[sector];
    }
    return lbuf;
}


static hash_stat parse_xls(char *stream, int size)
{
    int offset=0;
    int headersize;
    char *headerutf16;
    char *header;
    int a;

    while (offset<size-4)
    {
        if (((short)*(stream+offset))!=0x2f) offset+=4;
        else 
        {
            offset+=4;
            if (memcmp(stream+offset,"\x00\x00",2)==0)
            {
                //printf("XOR encryption not supported");
                return hash_err;
            }
            else if (memcmp(stream+offset,"\x01\x00\x01\x00\x01\x00",6)==0)
            {
                //printf("RC4 encryption (40bit)\n");
                memcpy(docsalt,stream+offset+6,16);
                memcpy(verifier,stream+offset+22,16);
                memcpy(verifierhash,stream+offset+38,16);
                verifierhashsize=16;
                return hash_err;
            }
            else if ((memcmp(stream+offset,"\x01\x00\x02\x00",4)==0)||(memcmp(stream+offset,"\x01\x00\x03\x00",4)==0))
            {
                //printf("RC4 part (CryptoAPI)\n");
                offset+=10;
                memcpy(&headersize,stream+offset,4);
                //printf("headersize=%d\n",headersize);
                offset+=20;
                memcpy(&keybits,stream+offset,4);
                //printf("keybits=%d\n",keybits);
                offset+=16;
                headersize-=32;
                headerutf16=alloca(headersize);
                memcpy(headerutf16,stream+offset,headersize);
                header=alloca(headersize/2);
                for (a=0;a<headersize;a+=2) header[a/2]=headerutf16[a];
                if (strstr(header,"trong")) type=1;
                else type=0;
                //printf("header: %s\n",header);
                offset+=headersize;
                memcpy(&saltsize,stream+offset,4);
                offset+=4;
                //printf("saltsize=%d\n",saltsize);
                memcpy(docsalt,stream+offset,16);
                offset+=16;
                memcpy(verifier,stream+offset,16);
                offset+=16;
                memcpy(&verifierhashsize,stream+offset,4);
                offset+=4;
                //printf("verifierhashsize=%d\n",verifierhashsize);
                memcpy(verifierhash,stream+offset,20);
                return hash_ok;
            }
        }
    }
    return hash_err;
}


static hash_stat parse_doc(char *stream, int size)
{
    int offset=0;
    int headersize;
    char *headerutf16;
    char *header;
    int a;

    /* 40bit RC4 */
    if ((((short)*(stream))==1)||(((short)*(stream+2))==1))
    {
        //printf("40bit RC4\n");
        memcpy(docsalt,stream+4,16);
        memcpy(verifier,stream+20,16);
        memcpy(verifierhash,stream+36,16);
        verifierhashsize=16;
        return hash_err;
    }
    else if ((((short)*(stream))>=2)||(((short)*(stream+2))==2))
    {
        offset+=8;
        memcpy(&headersize,stream+offset,4);
        //printf("headersize=%d\n",headersize);
        offset+=20;
        memcpy(&keybits,stream+offset,4);
        //printf("keybits=%d\n",keybits);
        offset+=16;
        headersize-=32;
        headerutf16=alloca(headersize);
        memcpy(headerutf16,stream+offset,headersize);
        header=alloca(headersize/2);
        for (a=0;a<headersize;a+=2) header[a/2]=headerutf16[a];
        if (strstr(header,"trong")) type=1;
        else type=0;
        //printf("header: %s\n",header);
        offset+=headersize;
        memcpy(&saltsize,stream+offset,4);
        //printf("saltsize=%d\n",saltsize);
        offset+=4;
        memcpy(docsalt,stream+offset,16);
        offset+=16;
        memcpy(verifier,stream+offset,16);
        offset+=16;
        memcpy(&verifierhashsize,stream+offset,4);
        //printf("verifierhashsize=%d\n",saltsize);
        offset+=4;
        memcpy(verifierhash,stream+offset,20);
        return hash_ok;
    }
    else
    {
        //printf("WTF is that word document?!?\n");
        return hash_err;
    }
}






static hash_stat load_msoffice_old(char *filename)
{
    int fd;
    int fsize;
    int index=0;
    int dirsector;
    char utf16[64];
    char orig[64];
    int datasector,datasize;
    int ministreamcutoff;
    int a;
    char *stream=NULL;

    fd=open(filename,O_RDONLY);
    if (!fd)
    {
        //printf("can't load!\n");
        return hash_err;
    }
    fsize=lseek(fd,0,SEEK_END);
    lseek(fd,0,SEEK_SET);
    buf=malloc(fsize+1);
    read(fd,buf,fsize);
    if (memcmp(buf,"\xd0\xcf\x11\xe0\xa1\xb1\x1a\xe1",8)!=0) 
    {
        //printf("No header signature found!\n");
        free(buf);
        return hash_err;
    }
    index+=24;
    if (memcmp(buf+index,"\x3e\x00",2)!=0)
    {
        //printf("Minor version wrong!\n");
        free(buf);
        return hash_err;
    }
    index+=2;
    if ((memcmp(buf+index,"\x03\x00",2)!=0)&&(memcmp(buf+index,"\x04\x00",2)!=0))
    {
        //printf("Major version wrong!\n");
        free(buf);
        return hash_err;
    }
    else
    {
        if ((short)*(buf+index)==3) sectorsize=512;
        else if ((short)*(buf+index)==4) sectorsize=4096;
        else 
        {
            //printf("Bad sector size!\n");
            free(buf);
            return hash_err;
        }
    }

    index+=22;
    memcpy(&dirsector,(int*)(buf+index),4);
    dirsector+=1;
    dirsector*=sectorsize;
    index+=8;
    memcpy(&ministreamcutoff,(int*)(buf+index),4);
    memcpy(&minifatsector,(int*)(buf+index+4),4);
    difat=(int *)(buf+index+20);


    index=dirsector;
    orig[0]='M';
    while ((orig[0]!=0)&&((strcmp(orig,"Workbook")!=0)||(strcmp(orig,"1Table")!=0)))
    {
        memcpy(utf16,buf+index,64);
        for (a=0;a<64;a+=2) orig[a/2]=utf16[a];
        memcpy(&datasector,buf+index+116,4);
        //printf("%s \n",orig);
        if (strcmp(orig,"Root Entry")==0)
        {
            minisectionstart=datasector;
            memcpy(&minisectionsize,buf+index+120,4);
        }
        if (strcmp(orig,"Workbook")==0)
        {
            memcpy(&datasize,buf+index+120,4);
            stream = read_stream(datasector,datasize);
            if (hash_err == parse_xls(stream,datasize))
            {
                free(stream);
                return hash_err;
            }
            break;
        }
        if (strcmp(orig,"1Table")==0)
        {
            memcpy(&datasize,buf+index+120,4);
            stream = read_stream(datasector,datasize);
            if (hash_err == parse_doc(stream,datasize))
            {
                free(stream);
                return hash_err;
            }
            break;
        }
        index+=128;
    }

    if (!stream)
    {
        //printf("No stream found!\n");
        return hash_err;
    }

    close(fd);
    free(stream);
    free(buf);

    return hash_ok;
}





/* Crack callback */
static void ocl_msoffice_old_crack_callback(char *line, int self)
{
    int a;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 singlehash;
    size_t gws,gws1;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt.s0=(docsalt[0])|(docsalt[1]<<8)|(docsalt[2]<<16)|(docsalt[3]<<24);
    salt.s1=(docsalt[4])|(docsalt[5]<<8)|(docsalt[6]<<16)|(docsalt[7]<<24);
    salt.s2=(docsalt[8])|(docsalt[9]<<8)|(docsalt[10]<<16)|(docsalt[11]<<24);
    salt.s3=(docsalt[12])|(docsalt[13]<<8)|(docsalt[14]<<16)|(docsalt[15]<<24);
    salt.s4=(verifier[0])|(verifier[1]<<8)|(verifier[2]<<16)|(verifier[3]<<24);
    salt.s5=(verifier[4])|(verifier[5]<<8)|(verifier[6]<<16)|(verifier[7]<<24);
    salt.s6=(verifier[8])|(verifier[9]<<8)|(verifier[10]<<16)|(verifier[11]<<24);
    salt.s7=(verifier[12])|(verifier[13]<<8)|(verifier[14]<<16)|(verifier[15]<<24);
    salt.s8=(verifierhash[0])|(verifierhash[1]<<8)|(verifierhash[2]<<16)|(verifierhash[3]<<24);
    salt.s9=(verifierhash[4])|(verifierhash[5]<<8)|(verifierhash[6]<<16)|(verifierhash[7]<<24);
    salt.sA=(verifierhash[8])|(verifierhash[9]<<8)|(verifierhash[10]<<16)|(verifierhash[11]<<24);
    salt.sB=(verifierhash[12])|(verifierhash[13]<<8)|(verifierhash[14]<<16)|(verifierhash[15]<<24);
    salt.sF=type;


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

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    wthreads[self].tries+=(gws);
    if (*found>0) 
    {
        _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	for (a=0;a<ocl_rule_workset[self]*wthreads[self].vectorsize;a++)
	if (rule_found_ind[self][a]==1)
	{
    	    {
                strcpy(plain,&rule_images[self][0]+(a*MAX));
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
	bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
        *found = 0;
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
    }
    _clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
}



static void ocl_msoffice_old_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_msoffice_old_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_msoffice_old_thread(void *arg)
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
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_msoffice_old_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_msoffice_old(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_msoffice_old(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_msoffice_old(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];



    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (hash_err==load_msoffice_old(hashlist_file)) return hash_err;

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
    	    if (verifierhashsize==20) sprintf(kernelfile,"%s/hashkill/kernels/amd_msoffice_old__%s.bin",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_msoffice_old_md5__%s.bin",DATADIR,pbuf);

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
    	    if (verifierhashsize==20) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_msoffice_old__%s.ptx",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_msoffice_old_md5__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_msoffice_old_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_msoffice_old_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

