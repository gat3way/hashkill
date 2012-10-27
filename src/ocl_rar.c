/*
 * ocl_rar.c
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

/*
                    unrar Exception

In addition, as a special exception, the author gives permission to
link the code of his release of hashkill with Rarlabs' "unrar"
library (or with modified versions of it that use the same license
as the "unrar" library), and distribute the linked executables. You
must obey the GNU General Public License in all respects for all of
the code used other than "unrar". If you modify this file, you may
extend this exception to your version of the file, but you are not
obligated to do so. If you do not wish to do so, delete this
exception statement from your version.
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
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
#include "unrargpu.h"
#include "cpu-feat.h"

static int hash_ret_len1=32;

#define BYTESWAP32(n) ( \
        (((n)&0x000000ff) << 24) | \
        (((n)&0x0000ff00) << 8 ) | \
        (((n)&0x00ff0000) >> 8 ) | \
        (((n)&0xff000000) >> 24) )


typedef struct bestfile_s
{
    unsigned int packedsize;
    unsigned int filepos;
    unsigned char filename[255];
} bestfile_t;

static bestfile_t bestfile[1024];
static long filepos;
static unsigned int packedsize;
static unsigned int unpackedsize;
static uint64_t packedsize64;
static uint64_t unpackedsize64;
static unsigned int filecrc;
static char rarsalt[8];
static int issalt;
static int islarge;
static unsigned short namesize;
static char encname[256];
static unsigned char header[40];
static unsigned int headerenc=0;
static unsigned short flags;
static char *filebuffer;

static hash_stat open_rar(void)
{
    int fd, ret,a,b,c;
    char buf[4096];
    unsigned int u321;
    unsigned short u161;
    unsigned char u81,htype;
    char signature[7];
    unsigned short headersize;
    int goodtogo=0,best=0;

    issalt = islarge = 0;

    fd = open(hashlist_file, O_RDONLY);
    if (fd<1)
    {
        return hash_err;
    }
    read(fd,signature,7);
    filepos = 7;

    if ( (signature[0]!=0x52) || (signature[1]!=0x61) || (signature[2]!=0x72) || 
         (signature[3]!=0x21) || (signature[4]!=0x1a) || (signature[5]!=0x07))
    {
        return hash_err;
    }
    ret=0;
    while (ret>=0)
    {
        /* header CRC (2) */
        read(fd, &u161,2);
        flags=u161;
        filepos+=2;
        /* header type (1) */
        read(fd, &htype,1);
        filepos++;
        //printf("htype=%02x\n",htype);
        if (htype==0x74)
        {
            /* flags (2) */
            read(fd,&u161,2);
            
            filepos+=2;
            issalt=0;
            islarge=0;
            if (!(u161 & 0x4))
            {
                //return hash_err;
            }
            if ((u161 & 0x400))
            {
                issalt = 1;
            }
            if ((u161 & 0x100))
            {
                islarge = 1;
            }
            /* header size (2) */
            read(fd,&u161,2);
            filepos+=u161-8;
            headersize=u161;
            read(fd,&packedsize,4);
            read(fd,&unpackedsize,4);
            read(fd,&u81,1);
            read(fd,&filecrc,4);
            /* read time,ver,method = 6 bytes */
            read(fd, buf, 6);
            /* read namesize */
            read(fd, &namesize,2);
            /* read attr */
            read(fd, &u321, 4);
            /* read 64-bit size if used */
            if (islarge)
            {
                read(fd,&packedsize64,8);
                read(fd,&unpackedsize64,8);
            }
            read(fd, encname, namesize);

            if (issalt)
            {
                read(fd, rarsalt, 8);
            }
            //printf("Found file: %s packedsize: %d headersize=%d\n",encname,packedsize,headersize);

            if (packedsize<(128*1024*1024))
            {
                lseek(fd,headersize-((issalt*8)+(islarge)*16+32+namesize),SEEK_CUR);
                filepos = lseek(fd,0,SEEK_CUR);
                bestfile[best].filepos = lseek(fd,0,SEEK_CUR);
                bestfile[best].packedsize=packedsize;
                strcpy((char *)bestfile[best].filename,encname);
                best++;
                lseek(fd,packedsize,SEEK_CUR);
            }
            else 
            {
                lseek(fd,headersize-((issalt*8)+(islarge)*16+32+namesize),SEEK_CUR);
                lseek(fd,packedsize,SEEK_CUR);
            }
            
        }
        else if (htype==0x73)
        {
            read(fd,&u161,2);
            filepos+=2;
            
            if (((u161>>7)&255)!=0)
            {
                read(fd,&u161,2);
                read(fd,&u161,2);
                read(fd,&u321,4);
                filepos+=8;
                /* Read in the salt */
                read(fd, rarsalt, 8);
                filepos+=8;
                read(fd, header, 32);
                /* Better idea: Marc Bevand's one :) */
                lseek(fd,-24,SEEK_END);
                read(fd,rarsalt,8);
                read(fd,header,16);
                headerenc=1;
                goodtogo=1;
                goto out;
            }
            read(fd,&u161,2);
            read(fd,&u161,2);
            read(fd,&u321,4);
            filepos+=8;
        }
        else 
        {
            ret=-1;
        }
    }
    out:
    if ((goodtogo==0)&&(best<1))
    {
        exit(1);
    }


    if (headerenc==0)
    {
        b=0xfffffff;
        c=0;
        for (a=0;a<best;a++) if (b>bestfile[a].packedsize) {b=bestfile[a].packedsize;c=a;}
        lseek(fd,bestfile[c].filepos,SEEK_SET);
        packedsize=bestfile[c].packedsize;

        filebuffer = malloc(packedsize);
        read(fd,filebuffer,packedsize);
    }
    close(fd);
    return hash_ok;
}

#define ADD_BITS(n)	\
    { \
        hold <<= n; \
        bits -= n; \
        if (bits < 25) \
        { \
	    hold |= ((unsigned int)*next++ << (24 - bits)); \
	    bits += 8; \
        } \
}

/* Huffman code check as used in JtR. Used with the permission of the author */
static int check_huffman(unsigned char *next) 
{
    unsigned int bits, hold, i;
    int left;
    unsigned int ncount[5];
    unsigned char *count = (unsigned char*)ncount;
    unsigned char bit_length[20];
    unsigned char *was = next;

    hold = __builtin_bswap32(*(unsigned int*)next);
    next += 4;
    hold <<= 2;
    bits = 32 - 2;

    for (i=0 ; i < 20 ; i++) 
    {
	int length, zero_count;
	length = hold >> 28;
	ADD_BITS(4);
	if (length == 15) 
	{
	    zero_count = hold >> 28;
	    ADD_BITS(4);
	    if (zero_count == 0) 
	    {
		bit_length[i] = 15;
	    } 
	    else 
	    {
		zero_count += 2;
		while (zero_count-- > 0 && i < sizeof(bit_length) / sizeof(bit_length[0])) bit_length[i++] = 0;
		i--;
	    }
	} 
	else 
	{
	    bit_length[i] = length;
	}
    }

    /* Count the number of codes for each code length */
    memset(count, 0, 20);
    for (i = 0; i < 20; i++) 
    {
	++count[bit_length[i]];
    }

    if (next - was > 16) 
    {
	elog("BUG: check_huffman() needed %lu bytes, we only have 16\n", next - was);
    }

    count[0] = 0;
    if (!ncount[0] && !ncount[1] && !ncount[2] && !ncount[3] && !ncount[4]) return 0; /* No codes at all */
    left = 1;
    for (i = 1; i < 16; ++i) 
    {
	left <<= 1;
	left -= count[i];
	if (left < 0) 
	{
	    return 0; /* over-subscribed */
	}
    }
    if (left) 
    {
	return 0; /* incomplete set */
    }
    return 1; /* Passed this check! */
}

static hash_stat check_rar(unsigned char *ekey, unsigned char *eiv)
{
    AES_KEY key;
    unsigned char iv1[16];
    unsigned char plain[32];
    unpack_data_t data;

    if (headerenc==1)
    {
            //AES_set_decrypt_key(ekey, 16*8, &key);
            //AES_cbc_encrypt(header, plain, 16, &key, eiv, AES_DECRYPT);
            OAES_SET_DECRYPT_KEY(ekey, 16*8, &key);
            OAES_CBC_ENCRYPT(header, plain, 16, &key, eiv, 0);
            if (memcmp(plain, "\xc4\x3d\x7b\x00\x40\x07\x00", 7)==0)
            {
                return hash_ok;
            }
    }
    /* No header encryption */
    else
    {
            memcpy(iv1,eiv,16);
            unsigned char plain[128];
            unsigned char enc[128];
            memcpy(plain,filebuffer,128);
            AES_KEY keyu;
            OAES_SET_DECRYPT_KEY(ekey, 16*8, &keyu);
            OAES_CBC_ENCRYPT(plain, enc, 128, &keyu, iv1, 0);

	    if (enc[0] & 0x80) 
	    {
		if (!(enc[2] & 0x20) ||  // Reset bit must be set
	        (enc[2] & 0xc0)  ||  // MaxOrder must be < 64
	        (enc[3] & 0x80))     // MaxMB must be < 128
		return hash_err;
	    }

	    else 
	    {
		if ((enc[0] & 0x40) || (!check_huffman(enc))) return hash_err;
	    }
            memcpy(iv1,eiv,16);
            bzero(&data,sizeof(data));
            data.unp_crc=0xffffffff;
            ppm_constructor(&data.ppm_data);
            data.old_filter_lengths = NULL;
            data.PrgStack.array = data.Filters.array = NULL;
            data.PrgStack.num_items = data.Filters.num_items = 0;
            data.pack_size = packedsize;
            //data.ofd=fd1;
            if (rar_unpack(ekey,iv1,filebuffer,29,1,&data,packedsize)>=1) 
            {
                if ((data.unp_crc^0xffffffff)==filecrc)
                {
                    return hash_ok;
                }
            }
            ppm_destructor(&data.ppm_data);
    }
    return hash_err;
}


static cl_uint4 ocl_get_salt(char *salt,int length)
{
    cl_uint4 t;
    unsigned char salt2[32];

    bzero(salt2,32);
    strcpy((char *)salt2,salt);
    t.s0=salt2[0]|(salt2[1]<<8)|(salt2[2]<<16)|(salt2[3]<<24);
    t.s1=salt2[4]|(salt2[5]<<8)|(salt2[6]<<16)|(salt2[7]<<24);
    t.s2=0;
    t.s3=0;

    return t;
}




static void ocl_rar_crack_callback(char *line, int self)
{
    int a,c,d,e;
    cl_uint16 addline;
    cl_uint4 salt;
    int cc,cc1;
    size_t gws,gws1;
    unsigned char key[16],iv[16];
    unsigned char plainimg[MAX+1];

    cc = self_kernel16[self];
    cc1 = self_kernel16[self]+strlen(line);
    if (cc1>15) cc1=15;


    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (rule_counts[self][cc]==-1) return;
    gws = (rule_counts[self][cc] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;



    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.sE=(cc1*2)+11;
    addline.sD=(cc);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt=ocl_get_salt(rarsalt,cc1);
    salt.s3=(16384*16*((cc1*2)+11));

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images162_buf[cc][self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint4), (void*) &salt);
    _clSetKernelArg(rule_kerneliv[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kerneliv[self], 1, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);
    _clSetKernelArg(rule_kerneliv[self], 2, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kerneliv[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kerneliv[self], 4, sizeof(cl_uint4), (void*) &salt);
    _clSetKernelArg(rule_kernelblock[self], 0, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblock[self], 1, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblock[self], 2, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblock[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelblock[self], 4, sizeof(cl_uint4), (void*) &salt);
    _clSetKernelArg(rule_kernelblocks[self], 0, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblocks[self], 1, sizeof(cl_mem), (void*) &rule_images16_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblocks[self], 2, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernelblocks[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelblocks[self], 4, sizeof(cl_uint4), (void*) &salt);
    _clSetKernelArg(rule_kernellast[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernellast[self], 1, sizeof(cl_mem), (void*) &rule_images164_buf[cc1][self]);
    _clSetKernelArg(rule_kernellast[self], 2, sizeof(cl_mem), (void*) &rule_images163_buf[cc1][self]);
    _clSetKernelArg(rule_kernellast[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernellast[self], 4, sizeof(cl_uint4), (void*) &salt);

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=0;a<16;a++)
    {
	if (attack_over!=0) pthread_exit(NULL);
	salt.s2=(16384*a);
        _clSetKernelArg(rule_kerneliv[self], 4, sizeof(cl_uint4), (void*) &salt);
        _clSetKernelArg(rule_kernelblock[self], 4, sizeof(cl_uint4), (void*) &salt);
        _clSetKernelArg(rule_kernelblocks[self], 4, sizeof(cl_uint4), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kerneliv[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	if (cc1>6) _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelblock[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	else _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelblocks[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	wthreads[self].tries+=((rule_counts[self][cc]*wthreads[self].vectorsize)/16);
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);

    for (a=0;a<=rule_counts[self][cc];a++)
    {
        for (c=0;c<wthreads[self].vectorsize;c++)
        {
            //wthreads[self].tries++;
            if (attack_over==2) pthread_exit(NULL);
            e=(a)*wthreads[self].vectorsize+c;
            memcpy(key,(char *)rule_ptr[self]+(e)*32,16);
            memcpy(iv,(char *)rule_ptr[self]+(e)*32+16,16);
            if (check_rar(key,iv)==hash_ok)
            {
                for (d=0;d<16;d++) plainimg[d] = rule_images162[cc][self][e*16+d];
                strcat((char *)plainimg,line);
                if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, (char *)plainimg);
            }
        }
    }
}

static void ocl_rar_callback(char *line, int self)
{
    int cc=0;

    if (line[0]!=0x01)
    {
	cc=strlen(line);
	if (cc>15) cc=15;
	rule_counts[self][cc]++;
	strncpy(&rule_images162[cc][self][0]+(rule_counts[self][cc]*16),line,15);
    }

    if (rule_counts[self][cc]==ocl_rule_workset[self]*wthreads[self].vectorsize-1)
    {
        _clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
        self_kernel16[self]=cc;
        rule_offload_perform(ocl_rar_crack_callback,self);
        bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        rule_counts[self][cc]=-1;
    }

    if (line[0]==0x01)
    for (cc=1;cc<16;cc++)
    {
        self_kernel16[self]=cc;
        _clEnqueueWriteBuffer(rule_oclqueue[self], rule_images162_buf[cc][self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*16, rule_images162[cc][self], 0, NULL, NULL);
        if (rule_counts[self][cc]!=-1) rule_offload_perform(ocl_rar_crack_callback,self);
        bzero(&rule_images162[cc][self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        rule_counts[self][cc]=-1;
    }
    if (attack_over!=0) pthread_exit(NULL);
}





/* Worker thread - rule attack */
void* ocl_rule_rar_thread(void *arg)
{
    cl_int err;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    int a;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=64*64;
    if (ocl_gpu_double==1) ocl_rule_workset[self]*=16;
    if (wthreads[self].ocl_have_gcn==1) ocl_rule_workset[self]*=4;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;

    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    for (a=0;a<16;a++)
    {
        rule_images16_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*56, NULL, &err );
        rule_images162_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*16, NULL, &err );
        rule_images163_buf[a][self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*28, NULL, &err );
        rule_images16[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*48);
        rule_images162[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        rule_images163[a][self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*20);
        bzero(rule_images16[a][self],ocl_rule_workset[self]*wthreads[self].vectorsize*48);
        bzero(rule_images162[a][self],ocl_rule_workset[self]*wthreads[self].vectorsize*16);
        bzero(rule_images163[a][self],ocl_rule_workset[self]*wthreads[self].vectorsize*20);
        rule_counts[self][a]=-1;
    }
    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kerneliv[self] = _clCreateKernel(program[self], "calculateiv", &err );
    rule_kernelblock[self] = _clCreateKernel(program[self], "calculateblock", &err );
    rule_kernelblocks[self] = _clCreateKernel(program[self], "calculateblocks", &err );
    rule_kernellast[self] = _clCreateKernel(program[self], "calculatelast", &err );


    pthread_mutex_unlock(&biglock); 
    worker_gen(self,ocl_rar_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_rar(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_rar(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_rar(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    open_rar();

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_rar__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_rar__%s.ptx",DATADIR,pbuf);

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
            if (wthreads[i].first==1) hlog("Loading kernels %s (please wait)\n",kernelfile);
            program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
            free(binary);
        }
    }


    pthread_mutex_init(&biglock, NULL);

    for (a=0;a<nwthreads;a++)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_rule_rar_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_rar_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

