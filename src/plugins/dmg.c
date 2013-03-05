/* dmg.c
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
#include <alloca.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <openssl/evp.h>
#include <openssl/aes.h>
#include <openssl/hmac.h>

#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;
static unsigned char chunk[4096];
static unsigned char chunk2[4096];
#define ntohll(x) (((uint64_t) ntohl((x) >> 32)) | (((uint64_t) ntohl((uint32_t) ((x) & 0xFFFFFFFF))) << 32))
static int chunk_size;
static int chunk_no;
static int chunkoffset;



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


static int headerver;
static cencrypted_v1_header header;
static cencrypted_v2_pwheader header2;

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
	/*if (header.len_wrapped_aes_key==48)*/ return(-1);
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




char * hash_plugin_summary(void)
{
    return("dmg \t\tFileVault (v1)  passwords plugin");
}


char * hash_plugin_detailed(void)
{
    return("dmg - A FileVault (v1) passwords plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack Apple DMG images passwords\n"
	    "Input should be a dmg file specified with -f\n"
	    "Supports FileVault v1 images only \n"
	    "Known software that uses this password hashing method:\n"
	    "Apple MacOSX\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    char buf8[8];
    size_t fsize;
    size_t fromsize;

    fd = open(filename, O_RDONLY);
    if (fd<0) 
    {
	if (!hashline) elog("Can't open file: %s\n", filename);
	return hash_err;
    }
    if (read(fd,buf8,8)<=0)
    {
	if (!hashline) elog("File %s is not a DMG file!\n", filename);
	return hash_err;
    }
    if (strncmp(buf8,"encrcdsa",8)==0)
    {
	//return hash_err;
	headerver=2;
    }
    else
    {
	lseek(fd,-8,SEEK_END);
	if (read(fd,buf8,8)<=0)
	{
	    if (!hashline) elog("File %s is not a DMG file!\n", filename);
	    return hash_err;
	}
	if (strncmp(buf8,"cdsaencr",8)==0)
	{
	    headerver=1;
	}
    }
    if (headerver==0)
    {
	if (!hashline) elog("File %s is not a DMG file!\n", filename);
	return hash_err;
    }
    if (!hashline) hlog("Header version %d detected\n",headerver);

    if (headerver==1)
    {
	lseek(fd,-sizeof(cencrypted_v1_header), SEEK_END);
	if (read(fd,&header, sizeof(cencrypted_v1_header)) < 1)
	{
	    if (!hashline) elog("File %s is not a DMG file!\n", filename);
	    return hash_err;
	}
	header_byteorder_fix(&header);
    }
    else
    {
	lseek(fd,0, SEEK_SET);
	if (read(fd,&header2, sizeof(cencrypted_v2_pwheader)) < 1)
	{
	    if (!hashline) elog("File %s is not a DMG file!\n", filename);
	    return hash_err;
	}
	
	header2_byteorder_fix(&header2);
	//printf("AES key len=%d\n",header2.blob_enc_key_bits);
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


    (void)hash_add_username(filename);
    (void)hash_add_hash("DMG file        ",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}




hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;
    unsigned char derived_key[24];
    unsigned char hmacsha1_key_[20];
    unsigned char aes_key_[32];

    if (headerver==1)
    {
	for (a=0;a<vectorsize;a++)
	{
	    hash_pbkdf2_len(password[a], strlen(password[a]), (unsigned char *)header.kdf_salt, 20, header.kdf_iteration_count, sizeof(derived_key), derived_key);
	    if (
	     (apple_des3_ede_unwrap_key1(header.wrapped_aes_key, header.len_wrapped_aes_key, derived_key)==0) &&
             (apple_des3_ede_unwrap_key1(header.wrapped_hmac_sha1_key, header.len_hmac_sha1_key, derived_key)==0)
            ) 
    	    {
    		memcpy(salt2[a],"DMG file        \0\0\0\0\0\0\0\0\0",20);
    		*num=a;
    		return hash_ok;
    	    }
	}
    }
    else
    {
	for (a=0;a<vectorsize;a++)
	{
	    EVP_CIPHER_CTX ctx;
	    HMAC_CTX hmacsha1_ctx;
	    unsigned char *TEMP1;
	    int outlen, tmplen;
	    AES_KEY aes_decrypt_key;
	    //unsigned char outbuf[4096];
	    unsigned char outbuf2[4096];
	    unsigned char iv[20];

	    hash_pbkdf2_len(password[a], strlen(password[a]), (unsigned char *)header2.kdf_salt, 20, header2.kdf_iteration_count, sizeof(derived_key), derived_key);

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
        	hash_aes_set_decrypt_key(aes_key_, 128, &aes_decrypt_key);
        	hash_aes_cbc_encrypt(chunk2, outbuf2, 4096, &aes_decrypt_key, iv, AES_DECRYPT);
        	// Valid koly block
        	if ((hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x04\x00\x00\x02\x00",12))||(hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x05\x00\x00\x02\x00",12)))
        	{
            	    *num=a;
            	    return hash_ok;
        	}
        	// Valid EFI header
        	if (memcmp(outbuf2+(4096-(512-chunkoffset)),"EFI PART",8)==0)
        	{
            	    *num=a;
            	    return hash_ok;
        	}
        	// Valid HFS volume header
        	if ( ((memcmp(outbuf2+(4096-(1024-chunkoffset)),"BD",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"H+",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"HX",2)==0))
            	    && ((memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x04",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x05",2)==0))
            	    && ((memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"8.10",4)==0) ||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"10.0",4)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"HFSJ",4)==0)))
        	{
            	    *num=a;
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
        	hash_aes_set_decrypt_key(aes_key_, 128, &aes_decrypt_key);
        	hash_aes_cbc_encrypt(chunk2, outbuf2, 4096, &aes_decrypt_key, iv, AES_DECRYPT);

        	// Valid koly block
        	if ((hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x04\x00\x00\x02\x00",12))||(hash_memmem(outbuf2,4096,"koly\x00\x00\x00\x05\x00\x00\x02\x00",12)))
        	{
            	    *num=a;
            	    return hash_ok;
        	}
        	// Valid EFI header
        	if (memcmp(outbuf2+(4096-(512-chunkoffset)),"EFI PART",8)==0)
        	{
            	    *num=a;
            	    return hash_ok;
        	}
        	// Valid HFS volume header
        	if ( ((memcmp(outbuf2+(4096-(1024-chunkoffset)),"BD",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"H+",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)),"HX",2)==0))
            	    && ((memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x04",2)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+2),"\x00\x05",2)==0))
            	    && ((memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"8.10",4)==0) ||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"10.0",4)==0)||(memcmp(outbuf2+(4096-(1024-chunkoffset)+8),"HFSJ",4)==0)))
        	{
            	    *num=a;
            	    return hash_ok;
        	}
    	    }
	}
    }
    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 16;
}

int hash_plugin_is_raw(void)
{
    return 1;
}

int hash_plugin_is_special(void)
{
    return 1;
}

void get_vector_size(int size)
{
   vectorsize = size;
}

int get_salt_size(void)
{
   return 4;
}
