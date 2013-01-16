/*
 * ocl_keepass.c
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
#include <zlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <openssl/sha.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"
#include "cpu-feat.h"


static int hash_ret_len1=32;
static unsigned int version;
static unsigned int rounds;

/* v1 data */
static unsigned char finalseed[16];
static unsigned char iv[16];
static unsigned char v1hash[32];
static unsigned char transseed[32];
static unsigned char *v1data = NULL;
static unsigned char *v1dec;
static unsigned int v1datasize;

/* v2 data */
static unsigned char v2masterseed[32];
static unsigned int v2masterseedsize;
static unsigned char v2transseed[32];
static unsigned int v2transseedsize;
static unsigned char v2iv[16];
static unsigned int v2ivsize;
static unsigned char v2streambytes[32];
static unsigned int v2streambytessize;
static unsigned char v2enc[32];



static hash_stat load_keepass(char *filename)
{
    int fd;
    off_t size;
    unsigned int u32,u321;

    fd = open(filename, O_RDONLY);
    if (fd < 1) return hash_err;
    size = lseek(fd,0,SEEK_END);
    if (size<125)
    {
        close(fd);
        return hash_err;
    }
    lseek(fd,0,SEEK_SET);
    read(fd,&u32,4);
    read(fd,&u321,4);

    /* Keepass 1.x format? */
    if ((u32==0x9AA2D903)&&(u321==0xB54BFB65))
    {
        unsigned int flag, fversion,groups,entries;
        off_t datasize;

        version = 1;
        read(fd,&flag,4);
        read(fd,&fversion,4);
        read(fd,finalseed,16);
        read(fd,iv,16);
        read(fd,&groups,4);
        read(fd,&entries,4);
        read(fd,v1hash,32);
        read(fd,transseed,32);
        read(fd,&rounds,4);
        if (((fversion&0xFFFFFF00)!=0x00030000)||(!(flag&2)))
        {
            close(fd);
            return hash_err;
        }
        datasize = size-124;
        v1data = malloc(datasize);
        v1dec = malloc(datasize);
        lseek(fd,124,SEEK_SET);
        read(fd,v1data,datasize);
        v1datasize = datasize;
    }

    /* Keepass 2.x format? */
    else if (((u32==0x9AA2D903)&&(u321==0xB54BFB67)) || ((u32==0x9AA2D903)&&(u321==0xB54BFB66)))
    {
        unsigned int flag, fversion;
        unsigned char fid;
        unsigned short fsize;
        unsigned char *data;
        uint64_t brounds;

        version = 2;
        read(fd,&fversion,4);
        if ((fversion&0xFFFF0000) > 0x00030000)
        {
            close(fd);
            return hash_err;
        }
        flag = 0;
        while (flag==0)
        {
            read(fd,&fid,1);
            read(fd,&fsize,2);
            if ((fsize==0)||(fsize>1024*1024))
            {
                close(fd);
                return hash_err;
            }

            data = malloc(fsize);
            if (fsize > read(fd,data,fsize))
            {
                close(fd);
                free(data);
                return hash_err;
            }

            switch (fid)
            {
                case 0:
                    flag=1;
                    free(data);
                    break;
                case 4:
                    memcpy(v2masterseed,data,fsize);
                    v2masterseedsize = fsize;
                    free(data);
                    break;
                case 5:
                    memcpy(v2transseed,data,fsize);
                    v2transseedsize = fsize;
                    free(data);
                    break;
                case 6:
                    memcpy(&brounds,data,8);
                    rounds = brounds;
                    free(data);
                    break;
                case 7:
                    memcpy(v2iv,data,fsize);
                    v2ivsize = fsize;
                    free(data);
                    break;
                case 9:
                    memcpy(v2streambytes,data,fsize);
                    v2streambytessize = fsize;
                    free(data);
                    break;
                default:
                    free(data);
                    break;
            }
        }

        if ((v2masterseedsize!=32)||(v2transseedsize!=32)||(v2ivsize!=16)||(v2streambytessize!=32)||(rounds==0))
        {
            close(fd);
            return hash_err;
        }
        if (32 > read(fd,v2enc,32))
        {
            close(fd);
            return hash_err;
        }
    }

    /* DB Error */
    else
    {
        close(fd);
        return hash_err;
    }

    return hash_ok;
}


static hash_stat check_keepass(unsigned char *derived_key)
{
    unsigned char myiv[16];
    AES_KEY akey;
    unsigned int pad;
    int v1size;
    unsigned char dec[32];
    SHA256_CTX ctx;

    OAES_SET_DECRYPT_KEY((const unsigned char *)derived_key, 256, &akey);
    memcpy(myiv,iv,16);
    OAES_CBC_ENCRYPT((unsigned char*)v1data,(unsigned char*)v1dec,v1datasize,&akey,myiv,AES_DECRYPT);
    pad = v1dec[v1datasize-1];
    v1size = v1datasize - pad;

    SHA256_Init(&ctx);
    SHA256_Update(&ctx, v1dec, v1size);
    SHA256_Final(dec, &ctx);
    if (memcmp(dec,v1hash,32)==0)
    {
	return hash_ok;
    }
    return hash_err;
}


static cl_uint16 keepass_getsalt()
{
    cl_uint16 t;

    if (version==1)
    {
	t.s0=(transseed[0]&255)|((transseed[1]&255)<<8)|((transseed[2]&255)<<16)|((transseed[3]&255)<<24);
	t.s1=(transseed[4]&255)|((transseed[5]&255)<<8)|((transseed[6]&255)<<16)|((transseed[7]&255)<<24);
	t.s2=(transseed[8]&255)|((transseed[9]&255)<<8)|((transseed[10]&255)<<16)|((transseed[11]&255)<<24);
	t.s3=(transseed[12]&255)|((transseed[13]&255)<<8)|((transseed[14]&255)<<16)|((transseed[15]&255)<<24);
	t.s4=(transseed[16]&255)|((transseed[17]&255)<<8)|((transseed[18]&255)<<16)|((transseed[19]&255)<<24);
	t.s5=(transseed[20]&255)|((transseed[21]&255)<<8)|((transseed[22]&255)<<16)|((transseed[23]&255)<<24);
	t.s6=(transseed[24]&255)|((transseed[25]&255)<<8)|((transseed[26]&255)<<16)|((transseed[27]&255)<<24);
	t.s7=(transseed[28]&255)|((transseed[29]&255)<<8)|((transseed[30]&255)<<16)|((transseed[31]&255)<<24);
    }
    else
    {
	t.s0=(v2transseed[0]&255)|((v2transseed[1]&255)<<8)|((v2transseed[2]&255)<<16)|((v2transseed[3]&255)<<24);
	t.s1=(v2transseed[4]&255)|((v2transseed[5]&255)<<8)|((v2transseed[6]&255)<<16)|((v2transseed[7]&255)<<24);
	t.s2=(v2transseed[8]&255)|((v2transseed[9]&255)<<8)|((v2transseed[10]&255)<<16)|((v2transseed[11]&255)<<24);
	t.s3=(v2transseed[12]&255)|((v2transseed[13]&255)<<8)|((v2transseed[14]&255)<<16)|((v2transseed[15]&255)<<24);
	t.s4=(v2transseed[16]&255)|((v2transseed[17]&255)<<8)|((v2transseed[18]&255)<<16)|((v2transseed[19]&255)<<24);
	t.s5=(v2transseed[20]&255)|((v2transseed[21]&255)<<8)|((v2transseed[22]&255)<<16)|((v2transseed[23]&255)<<24);
	t.s6=(v2transseed[24]&255)|((v2transseed[25]&255)<<8)|((v2transseed[26]&255)<<16)|((v2transseed[27]&255)<<24);
	t.s7=(v2transseed[28]&255)|((v2transseed[29]&255)<<8)|((v2transseed[30]&255)<<16)|((v2transseed[31]&255)<<24);
    }
    return t;
}


static cl_uint16 keepass_getstr()
{
    cl_uint16 t;

    if (version==1)
    {
	t.s0=(finalseed[0]&255)|((finalseed[1]&255)<<8)|((finalseed[2]&255)<<16)|((finalseed[3]&255)<<24);
	t.s1=(finalseed[4]&255)|((finalseed[5]&255)<<8)|((finalseed[6]&255)<<16)|((finalseed[7]&255)<<24);
	t.s2=(finalseed[8]&255)|((finalseed[9]&255)<<8)|((finalseed[10]&255)<<16)|((finalseed[11]&255)<<24);
	t.s3=(finalseed[12]&255)|((finalseed[13]&255)<<8)|((finalseed[14]&255)<<16)|((finalseed[15]&255)<<24);
	t.s8=(v2iv[0]&255)|((v2iv[1]&255)<<8)|((v2iv[2]&255)<<16)|((v2iv[3]&255)<<24);
	t.s9=(v2iv[4]&255)|((v2iv[5]&255)<<8)|((v2iv[6]&255)<<16)|((v2iv[7]&255)<<24);
	t.sA=(v2iv[8]&255)|((v2iv[9]&255)<<8)|((v2iv[10]&255)<<16)|((v2iv[11]&255)<<24);
	t.sB=(v2iv[12]&255)|((v2iv[13]&255)<<8)|((v2iv[14]&255)<<16)|((v2iv[15]&255)<<24);
    }
    else
    {
	t.s0=(v2masterseed[0]&255)|((v2masterseed[1]&255)<<8)|((v2masterseed[2]&255)<<16)|((v2masterseed[3]&255)<<24);
	t.s1=(v2masterseed[4]&255)|((v2masterseed[5]&255)<<8)|((v2masterseed[6]&255)<<16)|((v2masterseed[7]&255)<<24);
	t.s2=(v2masterseed[8]&255)|((v2masterseed[9]&255)<<8)|((v2masterseed[10]&255)<<16)|((v2masterseed[11]&255)<<24);
	t.s3=(v2masterseed[12]&255)|((v2masterseed[13]&255)<<8)|((v2masterseed[14]&255)<<16)|((v2masterseed[15]&255)<<24);
	t.s4=(v2masterseed[16]&255)|((v2masterseed[17]&255)<<8)|((v2masterseed[18]&255)<<16)|((v2masterseed[19]&255)<<24);
	t.s5=(v2masterseed[20]&255)|((v2masterseed[21]&255)<<8)|((v2masterseed[22]&255)<<16)|((v2masterseed[23]&255)<<24);
	t.s6=(v2masterseed[24]&255)|((v2masterseed[25]&255)<<8)|((v2masterseed[26]&255)<<16)|((v2masterseed[27]&255)<<24);
	t.s7=(v2masterseed[28]&255)|((v2masterseed[29]&255)<<8)|((v2masterseed[30]&255)<<16)|((v2masterseed[31]&255)<<24);
	t.s8=(v2iv[0]&255)|((v2iv[1]&255)<<8)|((v2iv[2]&255)<<16)|((v2iv[3]&255)<<24);
	t.s9=(v2iv[4]&255)|((v2iv[5]&255)<<8)|((v2iv[6]&255)<<16)|((v2iv[7]&255)<<24);
	t.sA=(v2iv[8]&255)|((v2iv[9]&255)<<8)|((v2iv[10]&255)<<16)|((v2iv[11]&255)<<24);
	t.sB=(v2iv[12]&255)|((v2iv[13]&255)<<8)|((v2iv[14]&255)<<16)|((v2iv[15]&255)<<24);
    }

    return t;
}


static cl_uint16 keepass_getsalt2()
{
    cl_uint16 t;

    t.s0=(v2enc[0]&255)|((v2enc[1]&255)<<8)|((v2enc[2]&255)<<16)|((v2enc[3]&255)<<24);
    t.s1=(v2enc[4]&255)|((v2enc[5]&255)<<8)|((v2enc[6]&255)<<16)|((v2enc[7]&255)<<24);
    t.s2=(v2enc[8]&255)|((v2enc[9]&255)<<8)|((v2enc[10]&255)<<16)|((v2enc[11]&255)<<24);
    t.s3=(v2enc[12]&255)|((v2enc[13]&255)<<8)|((v2enc[14]&255)<<16)|((v2enc[15]&255)<<24);
    t.s4=(v2enc[16]&255)|((v2enc[17]&255)<<8)|((v2enc[18]&255)<<16)|((v2enc[19]&255)<<24);
    t.s5=(v2enc[20]&255)|((v2enc[21]&255)<<8)|((v2enc[22]&255)<<16)|((v2enc[23]&255)<<24);
    t.s6=(v2enc[24]&255)|((v2enc[25]&255)<<8)|((v2enc[26]&255)<<16)|((v2enc[27]&255)<<24);
    t.s7=(v2enc[28]&255)|((v2enc[29]&255)<<8)|((v2enc[30]&255)<<16)|((v2enc[31]&255)<<24);

    return t;
}


static cl_uint16 keepass_getsinglehash()
{
    cl_uint16 t;

    t.s0=(v2streambytes[0]&255)|((v2streambytes[1]&255)<<8)|((v2streambytes[2]&255)<<16)|((v2streambytes[3]&255)<<24);
    t.s1=(v2streambytes[4]&255)|((v2streambytes[5]&255)<<8)|((v2streambytes[6]&255)<<16)|((v2streambytes[7]&255)<<24);
    t.s2=(v2streambytes[8]&255)|((v2streambytes[9]&255)<<8)|((v2streambytes[10]&255)<<16)|((v2streambytes[11]&255)<<24);
    t.s3=(v2streambytes[12]&255)|((v2streambytes[13]&255)<<8)|((v2streambytes[14]&255)<<16)|((v2streambytes[15]&255)<<24);
    t.s4=(v2streambytes[16]&255)|((v2streambytes[17]&255)<<8)|((v2streambytes[18]&255)<<16)|((v2streambytes[19]&255)<<24);
    t.s5=(v2streambytes[20]&255)|((v2streambytes[21]&255)<<8)|((v2streambytes[22]&255)<<16)|((v2streambytes[23]&255)<<24);
    t.s6=(v2streambytes[24]&255)|((v2streambytes[25]&255)<<8)|((v2streambytes[26]&255)<<16)|((v2streambytes[27]&255)<<24);
    t.s7=(v2streambytes[28]&255)|((v2streambytes[29]&255)<<8)|((v2streambytes[30]&255)<<16)|((v2streambytes[31]&255)<<24);

    return t;
}



/* Crack callback */
static void ocl_keepass_crack_callback(char *line, int self)
{
    int a,e;
    cl_uint16 addline;
    cl_uint16 salt;
    size_t gws,gws1;
    cl_uint16 singlehash;
    int *found;
    int err;
    char plain[MAX];

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt=keepass_getsalt();

    /* setup singlehash */
    singlehash=keepass_getsinglehash();

    /* Setup kernel parameteres */
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
    _clSetKernelArg(rule_kernelbl1[self], 7, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernellast[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernellast[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernellast[self], 7, sizeof(cl_uint16), (void*) &addline);


    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    if (rule_counts[self][0]==-1) return;
    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    salt = keepass_getsalt();
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    for (a=0;a<rounds;a+=200)
    {
	if (attack_over!=0) return;
        salt = keepass_getsalt();
        salt.sA=a;
        salt.sB=a+200;
        if (salt.sB>rounds) salt.sB=rounds;
        _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt);
        _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
        _clFinish(rule_oclqueue[self]);
        wthreads[self].tries+=(ocl_rule_workset[self]/(rounds/200));
    }
    addline = keepass_getstr();
    salt = keepass_getsalt2();
    _clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernellast[self], 7, sizeof(cl_uint16), (void*) &addline);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);

    if (version==1)
    {
    	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*gws1, rule_ptr[self], 0, NULL, NULL);
    	for (a=0;a<gws1;a++)
    	{
    	    if (attack_over!=0) return;
    	    e=a;
    	    if (check_keepass((unsigned char *)rule_ptr[self]+(e)*hash_ret_len1) == hash_ok)
    	    {
                strcpy(plain,&rule_images[self][0]+(e*MAX));
                strcat(plain,line);
                if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
                return;
    	    }
    	}
    }
    else
    {
	found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	if (*found>0) 
        {
    	    _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<ocl_rule_workset[self]*wthreads[self].vectorsize;a++)
    	    if (rule_found_ind[self][a]==1)
    	    {
        	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, a*hash_ret_len1, hash_ret_len1, rule_ptr[self]+a*hash_ret_len1, 0, NULL, NULL);
        	e=a;
        	if (memcmp(v2streambytes, (char *)rule_ptr[self]+(e)*hash_ret_len1, hash_ret_len1) == 0)
        	{
            	    strcpy(plain,&rule_images[self][0]+(e*MAX));
            	    strcat(plain,line);
            	    if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
            	    return;
        	}
    	    }
    	    bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    *found = 0;
    	    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
	}
	_clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
    }
}



static void ocl_keepass_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_keepass_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_keepass_thread(void *arg)
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
    ocl_rule_workset[self]=128*128*2;
    if (wthreads[self].type==nv_thread) ocl_rule_workset[self]/=2;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
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
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images[self][1],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(&rule_images[self][2],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
    bzero(rule_sizes[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_keepass_callback);

    return hash_ok;
}



hash_stat ocl_bruteforce_keepass(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_keepass(void)
{
    suggest_rule_attack();
    return hash_ok;
}



/* Main thread - rule */
hash_stat ocl_rule_keepass(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_keepass(hashlist_file)) 
    {
	elog("Could not load the keepass file!%s\n","");
	return hash_err;
    }

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
    	    if (version==1) sprintf(kernelfile,"%s/hashkill/kernels/amd_keepass__%s.bin",DATADIR,pbuf);
	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_keepass2__%s.bin",DATADIR,pbuf);

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
    	    if (version==1) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_keepass__%s.ptx",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_keepass2__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_keepass_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_keepass_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

