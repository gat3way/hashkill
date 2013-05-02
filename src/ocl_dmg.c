/*
 * ocl_dmg.c
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
#include <arpa/inet.h>
#include <openssl/evp.h>
#include <openssl/hmac.h>
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


#define ntohll(x) (((uint64_t) ntohl((x) >> 32)) | (((uint64_t) ntohl((uint32_t) ((x) & 0xFFFFFFFF))) << 32))

/* Header structs taken from vilefault project */
typedef struct {
    unsigned char  filler1[48];
    unsigned int kdf_iteration_count;
    unsigned int kdf_salt_len;
    unsigned char  kdf_salt[48];
    unsigned char  unwrap_iv[32];
    unsigned int len_wrapped_aes_key;
    unsigned char  wrapped_aes_key[296];
    unsigned int len_hmac_sha1_key;
    unsigned char  wrapped_hmac_sha1_key[300];
    unsigned int len_integrity_key;
    unsigned char  wrapped_integrity_key[48];
    unsigned char  filler6[484];
} cencrypted_v1_header;


typedef struct {
  unsigned char sig[8];
  uint32_t version;
  uint32_t enc_iv_size;
  uint32_t unk1;
  uint32_t unk2;
  uint32_t unk3;
  uint32_t unk4;
  uint32_t unk5;
  unsigned char uuid[16];
  uint32_t blocksize;
  uint64_t datasize;
  uint64_t dataoffset;
  uint8_t filler1[24];
  uint32_t kdf_algorithm;
  uint32_t kdf_prng_algorithm;
  uint32_t kdf_iteration_count;
  uint32_t kdf_salt_len; /* in bytes */
  uint8_t  kdf_salt[32];
  uint32_t blob_enc_iv_size;
  uint8_t  blob_enc_iv[32];
  uint32_t blob_enc_key_bits;
  uint32_t blob_enc_algorithm;
  uint32_t blob_enc_padding;
  uint32_t blob_enc_mode;
  uint32_t encrypted_keyblob_size;
  uint8_t  encrypted_keyblob[0x30];
} cencrypted_v2_pwheader;



static int hash_ret_len1=24;
static int headerver;
static cencrypted_v1_header header;
static cencrypted_v2_pwheader header2;
static unsigned char chunk[4096];
static unsigned char chunk2[4096];
static int chunk_size;
static int chunk_no;
static int chunkoffset;
static char myfilename[255];

static void header_byteorder_fix(cencrypted_v1_header *hdr) 
{
    hdr->kdf_iteration_count = htonl(hdr->kdf_iteration_count);
    if (hdr->kdf_iteration_count == 0 ) hdr->kdf_iteration_count = 1000;
    hdr->kdf_salt_len = htonl(hdr->kdf_salt_len);
    hdr->len_wrapped_aes_key = htonl(hdr->len_wrapped_aes_key);
    hdr->len_hmac_sha1_key = htonl(hdr->len_hmac_sha1_key);
    hdr->len_integrity_key = htonl(hdr->len_integrity_key);
}

static void header2_byteorder_fix(cencrypted_v2_pwheader *pwhdr) 
{
    pwhdr->blocksize = ntohl(pwhdr->blocksize);
    pwhdr->datasize = ntohll(pwhdr->datasize);
    pwhdr->dataoffset = ntohll(pwhdr->dataoffset);
    pwhdr->kdf_algorithm = ntohl(pwhdr->kdf_algorithm);
    pwhdr->kdf_prng_algorithm = ntohl(pwhdr->kdf_prng_algorithm);
    pwhdr->kdf_iteration_count = ntohl(pwhdr->kdf_iteration_count);
    pwhdr->kdf_salt_len = ntohl(pwhdr->kdf_salt_len);
    pwhdr->blob_enc_iv_size = ntohl(pwhdr->blob_enc_iv_size);
    pwhdr->blob_enc_key_bits = ntohl(pwhdr->blob_enc_key_bits);
    pwhdr->blob_enc_algorithm = ntohl(pwhdr->blob_enc_algorithm);
    pwhdr->blob_enc_padding = ntohl(pwhdr->blob_enc_padding);
    pwhdr->blob_enc_mode = ntohl(pwhdr->blob_enc_mode);
    pwhdr->encrypted_keyblob_size = ntohl(pwhdr->encrypted_keyblob_size);
}




static int apple_des3_ede_unwrap_key1(unsigned char *wrapped_key, int wrapped_key_len, unsigned char *decryptKey) 
{
    EVP_CIPHER_CTX ctx;
    unsigned char *TEMP1, *TEMP2, *CEKICV;
    unsigned char IV[8] = { 0x4a, 0xdd, 0xa2, 0x2c, 0x79, 0xe8, 0x21, 0x05 };
    int outlen, tmplen, i;


    TEMP1 = alloca(wrapped_key_len);
    TEMP2 = alloca(wrapped_key_len);
    CEKICV = alloca(wrapped_key_len);

    EVP_CIPHER_CTX_init(&ctx);
    EVP_DecryptInit_ex(&ctx, EVP_des_ede3_cbc(), NULL, decryptKey, IV);

    if(!EVP_DecryptUpdate(&ctx, TEMP1, &outlen, wrapped_key, wrapped_key_len)) 
    {
        return(-1);
    }
    if(!EVP_DecryptFinal_ex(&ctx, TEMP1 + outlen, &tmplen)) 
    {
        return(-1);
    }
    outlen += tmplen;
    EVP_CIPHER_CTX_cleanup(&ctx);

    for(i = 0; i < outlen; i++) 
    {
        TEMP2[i] = TEMP1[outlen - i - 1];
    }
    EVP_CIPHER_CTX_init(&ctx);
    EVP_DecryptInit_ex(&ctx, EVP_des_ede3_cbc(), NULL, decryptKey, TEMP2);
    if(!EVP_DecryptUpdate(&ctx, CEKICV, &outlen, TEMP2+8, outlen-8)) 
    {
        return(-1);
    }
    if(!EVP_DecryptFinal_ex(&ctx, CEKICV + outlen, &tmplen)) 
    {
        return(-1);
    }
    outlen += tmplen;
    EVP_CIPHER_CTX_cleanup(&ctx);
    return 0;
}






static hash_stat load_dmg(char *filename)
{
    int fd;
    char buf8[8];
    size_t fsize;
    size_t fromsize;

    strcpy(myfilename, filename);
    fd = open(filename, O_RDONLY);
    if (fd<0) 
    {
        elog("Can't open file: %s\n", filename);
        return hash_err;
    }
    if (read(fd,buf8,8)<=0)
    {
        elog("File %s is not a dmg file!\n", filename);
        return hash_err;
    }
    if (strncmp(buf8,"encrcdsa",8)==0)
    {
        //elog("File %s is not a dmg file!\n", filename);
        //return hash_err;
        headerver=2;
    }
    else
    {
        lseek(fd,-8,SEEK_END);
        if (read(fd,buf8,8)<=0)
        {
            elog("File %s is not a dmg file!\n", filename);
            return hash_err;
        }
        if (strncmp(buf8,"cdsaencr",8)==0)
        {
            headerver=1;
        }
    }
    if (headerver==0)
    {
        elog("File %s is not a dmg file!\n", filename);
        return hash_err;
    }

    if (headerver==1)
    {
        lseek(fd,-sizeof(cencrypted_v1_header), SEEK_END);
        if (read(fd,&header, sizeof(cencrypted_v1_header)) < 1)
        {
            elog("File %s is not a dmg file!\n", filename);
            return hash_err;
        }
        header_byteorder_fix(&header);
    }
    else
    {
        lseek(fd,0, SEEK_SET);
        if (read(fd,&header2, sizeof(cencrypted_v2_pwheader)) < 1)
        {
            elog("File %s is not a dmg file!\n", filename);
            return hash_err;
        }
        header2_byteorder_fix(&header2);
        chunk_size = header2.blocksize;
        lseek(fd,header2.dataoffset,SEEK_SET);
        read(fd,chunk,/*4096*/chunk_size);
        fsize = header2.dataoffset+header2.datasize;
	fromsize=fsize-header2.dataoffset;
	while ((fromsize%4096!=0)||(fromsize==fsize-header2.dataoffset)) fromsize--;
	chunk_no = ((fromsize+1) / chunk_size);
	
	chunkoffset=0;
	if ((fsize-(fromsize+header2.dataoffset))<(4095-678)) 
	{
	    chunkoffset+=(fsize-(fromsize+header2.dataoffset));
	    fromsize-=4096;
	    chunk_no--;
	}

	//printf("fsize=%ld fromsize=%ld dataoffset=%ld at=%ld chunk_no=%d\n",fsize,header2.dataoffset,fromsize,fromsize+header2.dataoffset,chunk_no);
        lseek(fd,fromsize+header2.dataoffset,SEEK_SET);
        read(fd,chunk2,/*4096*/chunk_size);

    }
    close(fd);
    return hash_ok;
}




static hash_stat check_dmg(unsigned char *derived_key, char *pwd)
{
    unsigned char hmacsha1_key_[20];
    unsigned char aes_key_[32];


    if (headerver==1)
    {
        //hash_pbkdf2_len(password[a], strlen(password[a]), (unsigned char *)header.kdf_salt, 20, 1000, sizeof(derived_key), derived_key);
        if (
         (apple_des3_ede_unwrap_key1(header.wrapped_aes_key, header.len_wrapped_aes_key, derived_key)==0) &&
         (apple_des3_ede_unwrap_key1(header.wrapped_hmac_sha1_key, header.len_hmac_sha1_key, derived_key)==0)
        ) 
        {
            return hash_ok;
        }
    }
    else
    {
        EVP_CIPHER_CTX ctx;
	HMAC_CTX hmacsha1_ctx;
        unsigned char *TEMP1;
        int outlen, tmplen;
        AES_KEY aes_decrypt_key;
        unsigned char outbuf2[4096];
        unsigned char iv[20];


        EVP_CIPHER_CTX_init(&ctx);
        TEMP1 = alloca(header2.encrypted_keyblob_size);
        EVP_DecryptInit_ex(&ctx, EVP_des_ede3_cbc(), NULL, derived_key, header2.blob_enc_iv);
        EVP_DecryptUpdate(&ctx, TEMP1, &outlen, header2.encrypted_keyblob, header2.encrypted_keyblob_size);
        EVP_DecryptFinal_ex(&ctx, TEMP1 + outlen, &tmplen);
        EVP_CIPHER_CTX_cleanup(&ctx);
        outlen += tmplen;
        memcpy(aes_key_, TEMP1, 32);
        memcpy(hmacsha1_key_, TEMP1, 20);


        int cno = chunk_no;
        int mdlen;
        if (header2.encrypted_keyblob_size==48)
        {
            cno=chunk_no;
            HMAC_CTX_init(&hmacsha1_ctx);
    	    HMAC_Init_ex(&hmacsha1_ctx, hmacsha1_key_, 20, EVP_sha1(), NULL);
    	    HMAC_Update(&hmacsha1_ctx, (void *) &cno, 4);
    	    HMAC_Final(&hmacsha1_ctx, iv, (unsigned int *)&mdlen);
    	    HMAC_CTX_cleanup(&hmacsha1_ctx);
            OAES_SET_DECRYPT_KEY(aes_key_, 128, &aes_decrypt_key);
            OAES_CBC_ENCRYPT(chunk2, outbuf2, 4096, &aes_decrypt_key, iv, AES_DECRYPT);

            // Valid koly block
            if ((hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x04\x00\x00\x02\x00",12))||(hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x05\x00\x00\x02\x00",12)))
            {
                return hash_ok;
            }
            // Valid EFI header
            if (memcmp(outbuf2+(4096-(512-chunkoffset)),"EFI PART",8)==0)
            {
                return hash_ok;
            }
            // Valid HFS volume header
            if ( ((memcmp(outbuf2+(4096-(1024-chunkoffset)),"BD",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"H+",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"HX",2)==0))
        	&& ((memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x04",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x05",2)==0))
        	&& ((memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"8.10",4)==0) ||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"10.0",4)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"HFSJ",4)==0)))
            {
                return hash_ok;
            }

        }
        else
        {
            cno=chunk_no;
            HMAC_CTX_init(&hmacsha1_ctx);
    	    HMAC_Init_ex(&hmacsha1_ctx, hmacsha1_key_, 20, EVP_sha1(), NULL);
    	    HMAC_Update(&hmacsha1_ctx, (void *) &cno, 4);
    	    HMAC_Final(&hmacsha1_ctx, iv, (unsigned int *)&mdlen);
    	    HMAC_CTX_cleanup(&hmacsha1_ctx);
            OAES_SET_DECRYPT_KEY(aes_key_, 128*2, &aes_decrypt_key);
            OAES_CBC_ENCRYPT(chunk2, outbuf2, 4096, &aes_decrypt_key, iv, AES_DECRYPT);

            // Valid koly block
            if ((hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x04\x00\x00\x02\x00",12))||(hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x05\x00\x00\x02\x00",12)))
            {
                return hash_ok;
            }
            // Valid EFI header
            if (memcmp(outbuf2+(4096-(512-chunkoffset)),"EFI PART",8)==0)
            {
                return hash_ok;
            }
            // Valid HFS volume header
            if ( ((memcmp(outbuf2+(4096-(1024-chunkoffset)),"BD",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"H+",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"HX",2)==0))
        	&& ((memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x04",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x05",2)==0))
        	&& ((memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"8.10",4)==0) ||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"10.0",4)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"HFSJ",4)==0)))
            {
                return hash_ok;
            }
        }
    }
    return hash_err;
}






static cl_uint16 dmg_getsalt()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    bzero(salt2,32);
    if (headerver==1) memcpy(salt2,header.kdf_salt,header.kdf_salt_len);
    else memcpy(salt2,header2.kdf_salt,header2.kdf_salt_len);
    len=20;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=1;
    salt2[len+4]=0x80;

    t.s0=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s1=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s2=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.s3=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.s4=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);
    t.s5=(salt2[20]&255)|((salt2[21]&255)<<8)|((salt2[22]&255)<<16)|((salt2[23]&255)<<24);
    t.s6=(salt2[24]&255)|((salt2[25]&255)<<8)|((salt2[26]&255)<<16)|((salt2[27]&255)<<24);


    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=2;
    salt2[len+4]=0x80;

    t.s7=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s8=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s9=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.sA=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.sB=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);
    t.sC=(salt2[20]&255)|((salt2[21]&255)<<8)|((salt2[22]&255)<<16)|((salt2[23]&255)<<24);
    t.sD=(salt2[24]&255)|((salt2[25]&255)<<8)|((salt2[26]&255)<<16)|((salt2[27]&255)<<24);

    t.sF=((len)+64+4)<<3;
    return t;
}



/* Crack callback */
static void ocl_dmg_crack_callback(char *line, int self)
{
    int a,c,d,e;
    cl_uint16 addline;
    cl_uint16 salt;
    unsigned char key[48];
    char plainimg[MAXCAND+1];
    size_t gws,gws1;
    int iterations;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &addline);

    /* setup salt */
    salt=dmg_getsalt();

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_uint16), (void*) &salt);
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
    iterations = (headerver==1) ? header.kdf_iteration_count : header2.kdf_iteration_count;
    for (a=1;a<iterations;a+=1000)
    {
	salt.sA=a;
	salt.sB=a+1000;
	if (salt.sB>iterations) salt.sB=iterations;
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &salt);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	wthreads[self].tries+=(ocl_rule_workset[self]*wthreads[self].vectorsize)/(iterations/1000);
    }
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    _clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
    for (a=0;a<ocl_rule_workset[self];a++)
    {
        for (c=0;c<wthreads[self].vectorsize;c++)
        {
            e=(a)*wthreads[self].vectorsize+c;
            memcpy(key,(char *)rule_ptr[self]+(e)*hash_ret_len1,hash_ret_len1);
            for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
            if (check_dmg(key,plainimg)==hash_ok)
            {
                for (d=0;d<MAX;d++) plainimg[d] = rule_images[self][e*MAX+d];
                if (!cracked_list) add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, (char *)plainimg);
            }
        }
    }
}



static void ocl_dmg_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]==ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_dmg_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_dmg_thread(void *arg)
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
    ocl_rule_workset[self]=256*128;
    if (wthreads[self].type==nv_thread) ocl_rule_workset[self]/=2;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
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
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*160, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*160);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*160);
    bzero(rule_sizes[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    bzero(rule_sizes2[self],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_dmg_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_dmg(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_dmg(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_dmg(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_dmg(hashlist_file)) 
    {
	elog("Could not load the dmg file!%s\n","");
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_dmg__%s.bin",DATADIR,pbuf);

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_dmg__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_dmg_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_dmg_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

