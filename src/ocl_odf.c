/*
 * ocl_odf.c
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
#include <zlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <arpa/inet.h>
#include <openssl/sha.h>
#include <openssl/blowfish.h>
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
static int filenamelen;
static int comprsize, ucomprsize;
static unsigned char content[1024];
static unsigned char *manifest = NULL;
static unsigned char *manifest_u = NULL;
static unsigned char s_checksum[64];
static unsigned char s_checksum_type[64];
static unsigned char s_iv[64];
static unsigned char s_salt[64];
static unsigned char s_algo_name[64];
static unsigned char s_iterations[64];
static unsigned char s_key_size[64];
static unsigned char iv[64];
static unsigned char bsalt[64];
static unsigned char checksum[64];
static int iterations;
static int keysize;
static int cs_size;
static int algorithm;
static int csalgorithm;
static int contentsize;

extern int b64_pton(char const *src, unsigned char *target, size_t targsize);

hash_stat load_odf(char *filename)
{
    int fd;
    char buf[4096];
    unsigned int u321;
    unsigned short u161, genpurpose, extrafieldlen;
    //int compmethod=0;
    unsigned char *tok,*tok1,*tok2;
    int a;
    int parsed=0;
    int parsedc=0;
    size_t apos,epos,cpos,rpos;


    fd = open(filename, O_RDONLY);
    if (fd<1)
    {
        return hash_err;
    }
    read(fd, &u321, 4);

    if (u321 != 0x04034b50)
    {
        return hash_err;
    }
    close(fd);

    fd = open(filename, O_RDONLY);

    //compmethod=0;

    while ((parsed==0)||(parsedc==0))
    {
        read(fd, &u321, 4);
        if (u321 != 0x04034b50)
        {
            if ((parsed==0)||(parsedc==0)) goto out;
        }

        /* version needed to extract */
        read(fd, &u161, 2);

        /* general purpose bit flag */
        read(fd, &genpurpose, 2);

        /* compression method, last mod file time, last mod file date */
        read(fd, &u161, 2);
        //compmethod=u161;
        read(fd, &u161, 2);
        read(fd, &u161, 2);

        /* crc32 */
        read(fd, &u321, 4);

        /* compressed size */
        read(fd, &comprsize, 4);

        /* uncompressed size */
        read(fd, &ucomprsize, 4);

        /* file name length */
        read(fd, &filenamelen, 2);

        /* extra field length */
        read(fd, &extrafieldlen, 2);

        /* file name */
        bzero(buf,4096);
        read(fd, buf, filenamelen);

        apos = lseek(fd,0,SEEK_CUR);
        if ((comprsize==0)&&(((genpurpose>>3)&1)))
        {
            int flag=0;
            while (flag==0)
            {
                cpos = lseek(fd,0,SEEK_CUR);
                if (read(fd,&u321,4)!=4) goto out;
                if (u321 == 0x08074b50) flag = 1;
                else lseek(fd,cpos+1,SEEK_SET);
            }
            read(fd,&u321,4);
            read(fd,&comprsize,4);
            read(fd,&ucomprsize,4);
            cpos = lseek(fd,0,SEEK_CUR);
            epos = cpos-16;
        }
        else
        {
            lseek(fd,extrafieldlen,SEEK_CUR);
            epos = lseek(fd,0,SEEK_CUR);
            lseek(fd,comprsize,SEEK_CUR);
            if ((genpurpose>>3)&1) lseek(fd,12,SEEK_CUR);
            cpos = lseek(fd,0,SEEK_CUR);
        }

        // content.xml? Read 1024 bytes or less
        if (strcmp(buf,"content.xml")==0)
        {
            memset(content,0,1024);
            rpos=(epos-apos);
            lseek(fd,apos,SEEK_SET);
            read(fd,content,(rpos>1024) ? 1024: rpos);
            contentsize = rpos;
            if (contentsize>1024) contentsize=1024;
            lseek(fd,cpos,SEEK_SET);
            parsedc=1;
        }

        // META-INF/manifest.xml? 
        if (strcmp(buf,"META-INF/manifest.xml")==0)
        {
            parsed=1;
            rpos=(epos-apos);
            lseek(fd,apos,SEEK_SET);
            manifest = malloc(rpos+1);
            read(fd,manifest,rpos);
            lseek(fd,cpos,SEEK_SET);
            manifest_u = malloc(ucomprsize+1);
            z_stream strm;
            int ret=0;
            strm.zalloc = Z_NULL;
            strm.zfree = Z_NULL;
            strm.opaque = Z_NULL;
            strm.avail_in = comprsize;
            strm.avail_out = ucomprsize;

            strm.next_in = manifest;
            strm.next_out = manifest_u;

            ret = inflateInit2(&strm,-15);
            if (ret != Z_OK)
            {
                goto out;
            }
            ret = inflate(&strm, Z_SYNC_FLUSH);
            if (ret == Z_DATA_ERROR) 
            {
                inflateEnd(&strm);
                //return hash_err;
                goto out;
            }
            if (ret == Z_NEED_DICT) 
            {
                inflateEnd(&strm);
                //return hash_err;
                goto out;
            }
            if (ret == Z_STREAM_ERROR) 
            {
                inflateEnd(&strm);
                goto out;
            }

            if  ((ret == Z_MEM_ERROR))
            {
                inflateEnd(&strm);
                //return hash_err;
                goto out;
            }
            
            tok1 = memmem(manifest_u,ucomprsize,"manifest:full-path=\"content.xml\"",strlen("manifest:full-path=\"content.xml\""));
            if (!tok1) goto out;
            tok2 = memmem(tok1,ucomprsize-(tok1-manifest_u),"</manifest:file-entry>",strlen("</manifest:file-entry>"));
            if ((!tok1)||(!tok2)) goto out;
            // Get checksum
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"checksum=\"",strlen("checksum=\""))==0)
                {
                    memset(s_checksum,0,64);
                    tok+=strlen("checksum=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_checksum[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            // Get checksum-type
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"checksum-type=\"",strlen("checksum-type=\""))==0)
                {
                    memset(s_checksum_type,0,64);
                    tok+=strlen("checksum-type=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_checksum_type[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            // Get iv
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"initialisation-vector=\"",strlen("initialisation-vector=\""))==0)
                {
                    memset(s_iv,0,64);
                    tok+=strlen("initialisation-vector=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_iv[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }
            // Get salt
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"salt=\"",strlen("salt=\""))==0)
                {
                    memset(s_salt,0,64);
                    tok+=strlen("salt=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_salt[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            // Get algorithm-name
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"algorithm-name=\"",strlen("algorithm-name=\""))==0)
                {
                    memset(s_algo_name,0,64);
                    tok+=strlen("algorithm-name=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_algo_name[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            // Get iteration-count
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"iteration-count=\"",strlen("iteration-count=\""))==0)
                {
                    memset(s_iterations,0,64);
                    tok+=strlen("iteration-count=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_iterations[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            // Get key-size
            tok = tok1;
            while (tok<tok2)
            {
                if (memcmp(tok,"key-size=\"",strlen("key-size=\""))==0)
                {
                    memset(s_key_size,0,64);
                    tok+=strlen("key-size=\"");
                    a=0;
                    while (tok[a]!='"')
                    {
                        s_key_size[a]=tok[a];
                        a++;
                    }
                    tok+=(a+1);
                }
                tok++;
            }

            //printf("checksum=%s\n",s_checksum);
            //printf("checksum_type=%s\n",s_checksum_type);
            //printf("iv=%s\n",s_iv);
            //printf("salt=%s\n",s_salt);
            //printf("algorithm-name=%s\n",s_algo_name);
            //printf("iteration-count=%s\n",s_iterations);
            //printf("key-size=%s\n",s_key_size);
            if (strstr((char*)s_algo_name,"Blowfish CFB")) algorithm=0;
            else if (strstr((char*)s_algo_name,"aes256-cbc")) algorithm=1;
            else goto out;

            if (!strstr((char*)s_checksum_type,"SHA1")==0) csalgorithm=0;
            else if (!strstr((char*)s_checksum_type,"sha256")==0) csalgorithm=1;
            else goto out;

            keysize = atoi((const char *)s_key_size);
            if (keysize==0)
            {
                if (algorithm==0) keysize=128;
                else keysize=256;
            }
            if (keysize==20) keysize=128;
            if (keysize==32) keysize=256;
            iterations = atoi((const char *)s_iterations);
            if (iterations==0) goto out;
            b64_pton((const char*)s_salt,bsalt,16+4);
            cs_size = (csalgorithm==0) ? 20 : 32;
            b64_pton((const char*)s_checksum,checksum,cs_size+4);
            b64_pton((const char*)s_iv,iv,(algorithm==0) ? 8+4 : 16+4);
        }
    }


    free(manifest);
    free(manifest_u);
    return hash_ok;

    out:
    close(fd);
    if (manifest) free(manifest);
    if (manifest_u) free(manifest_u);
    return hash_err;
}



static hash_stat check_odf(unsigned char *derived_key)
{
    char buf[64];
    unsigned char dec[1024];

    if ((algorithm==0)&&(csalgorithm==0))
    {
        BF_KEY bf_key;
        SHA_CTX ctx;
        unsigned char localiv[8];
        int pos;

        pos=0;
        memcpy(localiv,iv,8);
        BF_set_key(&bf_key, keysize/8, (const unsigned char*)derived_key);
        BF_cfb64_encrypt(content, dec, 1024, &bf_key, localiv, &pos, 0);
        SHA1_Init(&ctx);
        SHA1_Update(&ctx, dec, contentsize);
        SHA1_Final((unsigned char*)buf, &ctx);

        if (memcmp(checksum,buf,cs_size)==0)
        {
            return hash_ok;
        }
    }
    else
    {
        SHA256_CTX ctx;
        AES_KEY akey;
        unsigned char localiv[16];

        memcpy(localiv,iv,16);
        OAES_SET_DECRYPT_KEY((const unsigned char*)derived_key,keysize,&akey);
        OAES_CBC_ENCRYPT(content,dec,1024,&akey,localiv,AES_DECRYPT);
        SHA256_Init(&ctx);
        SHA256_Update(&ctx, dec, contentsize);
        SHA256_Final((unsigned char*)buf, &ctx);

        if (memcmp(checksum,buf,cs_size)==0)
        {
            return hash_ok;
        }
    }

    return hash_err;
}



static cl_uint16 odf_getsalt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    bzero(salt2,32);
    memcpy(salt2,bsalt,16);
    len=16;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=1;

    t.s0=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s1=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s2=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.s3=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.s4=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);

    t.sF=((len)+64+4)<<3;
    t.sE=0;
    return t;
}


static cl_uint16 odf_getsalt2()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    bzero(salt2,32);
    memcpy(salt2,bsalt,16);
    len=16;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=2;

    t.s0=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s1=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s2=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.s3=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.s4=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);

    t.sF=((len)+64+4)<<3;
    t.sE=1;
    return t;
}



/* Crack callback */
static void ocl_odf_crack_callback(char *line, int self)
{
    int a,c,d,e;
    cl_uint16 addline;
    cl_uint16 salt;
    unsigned char key[48];
    char plainimg[MAXCAND+1];
    size_t gws,gws1;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &addline);

    /* setup salt */
    salt=odf_getsalt();

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend[self], 6, sizeof(cl_uint16), (void*) &salt);


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
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    for (a=1;a<iterations;a+=128)
    {
	if (attack_over!=0) pthread_exit(NULL);
	salt.sA=a;
	salt.sB=a+128;
	if (salt.sB>iterations) salt.sB=iterations;
	_clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	if (keysize==128)
	{
	    wthreads[self].tries+=(gws1)/(iterations/128);
	}
	else
	{
	    wthreads[self].tries+=(gws1)/((iterations/128)*2);
	}
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    if (keysize==256)
    {
	if (attack_over!=0) pthread_exit(NULL);
	salt=odf_getsalt2();
	_clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	for (a=1;a<iterations;a+=128)
	{
	    salt.sA=a;
	    salt.sB=a+128;
	    if (salt.sB>iterations) salt.sB=iterations;
	    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
	    wthreads[self].tries+=(gws1)/((iterations/128)*2);
	}
	_clSetKernelArg(rule_kernelend[self], 5, sizeof(cl_uint16), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
    }

    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
    for (a=0;a<gws;a++)
    {
        for (c=0;c<wthreads[self].vectorsize;c++)
        {
            e=(a)*wthreads[self].vectorsize+c;
            memcpy(key,(char *)rule_ptr[self]+(e)*hash_ret_len1,hash_ret_len1);
            for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
            if (check_odf(key)==hash_ok)
            {
                for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
                if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, (char *)plainimg);
            }
        }
    }
}



static void ocl_odf_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_odf_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_odf_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;
    int bbufsize;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (keysize==128)
    {
	hash_ret_len1=20;
	bbufsize = 80;
    }
    else
    {
	hash_ret_len1=32;
	bbufsize = 128;
    }


    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*128*2;
    if (wthreads[self].type==nv_thread) ocl_rule_workset[self]/=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "block", &err );
    rule_kernelend[self] = _clCreateKernel(program[self], "final", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );


    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*bbufsize, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*bbufsize);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(rule_sizes[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_odf_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_odf(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_odf(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_odf(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_odf(hashlist_file)) 
    {
	elog("Could not load the odf file!%s\n","");
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
    	    if (keysize==128) sprintf(kernelfile,"%s/hashkill/kernels/amd_odf__%s.bin",DATADIR,pbuf);
	    else  sprintf(kernelfile,"%s/hashkill/kernels/amd_odf2__%s.bin",DATADIR,pbuf);

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
    	    if (keysize==128) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_odf__%s.ptx",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_odf2__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_odf_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_odf_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

