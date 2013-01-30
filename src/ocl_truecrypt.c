/*
 * ocl_truecrypt.c
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

#define _LARGEFILE64_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pthread.h>
#include <arpa/inet.h>
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

static int hash_ret_len1=200;

int crc_32_tab[256]=
{
        0x00000000, 0x77073096, 0xee0e612c, 0x990951ba, 0x076dc419, 0x706af48f,
        0xe963a535, 0x9e6495a3, 0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
        0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91, 0x1db71064, 0x6ab020f2,
        0xf3b97148, 0x84be41de, 0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
        0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec, 0x14015c4f, 0x63066cd9,
        0xfa0f3d63, 0x8d080df5, 0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
        0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b, 0x35b5a8fa, 0x42b2986c,
        0xdbbbc9d6, 0xacbcf940, 0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
        0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116, 0x21b4f4b5, 0x56b3c423,
        0xcfba9599, 0xb8bda50f, 0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
        0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d, 0x76dc4190, 0x01db7106,
        0x98d220bc, 0xefd5102a, 0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
        0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818, 0x7f6a0dbb, 0x086d3d2d,
        0x91646c97, 0xe6635c01, 0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
        0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457, 0x65b0d9c6, 0x12b7e950,
        0x8bbeb8ea, 0xfcb9887c, 0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
        0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2, 0x4adfa541, 0x3dd895d7,
        0xa4d1c46d, 0xd3d6f4fb, 0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
        0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9, 0x5005713c, 0x270241aa,
        0xbe0b1010, 0xc90c2086, 0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
        0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4, 0x59b33d17, 0x2eb40d81,
        0xb7bd5c3b, 0xc0ba6cad, 0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
        0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683, 0xe3630b12, 0x94643b84,
        0x0d6d6a3e, 0x7a6a5aa8, 0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
        0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe, 0xf762575d, 0x806567cb,
        0x196c3671, 0x6e6b06e7, 0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
        0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5, 0xd6d6a3e8, 0xa1d1937e,
        0x38d8c2c4, 0x4fdff252, 0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
        0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60, 0xdf60efc3, 0xa867df55,
        0x316e8eef, 0x4669be79, 0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
        0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f, 0xc5ba3bbe, 0xb2bd0b28,
        0x2bb45a92, 0x5cb36a04, 0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
        0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a, 0x9c0906a9, 0xeb0e363f,
        0x72076785, 0x05005713, 0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
        0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21, 0x86d3d2d4, 0xf1d4e242,
        0x68ddb3f8, 0x1fda836e, 0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
        0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c, 0x8f659eff, 0xf862ae69,
        0x616bffd3, 0x166ccf45, 0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
        0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db, 0xaed16a4a, 0xd9d65adc,
        0x40df0b66, 0x37d83bf0, 0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
        0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6, 0xbad03605, 0xcdd70693,
        0x54de5729, 0x23d967bf, 0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
        0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
};


static unsigned char tc_salt[64];
static unsigned char sector[512];
static int sha512=1;
static int sha1=1;
static int ripemd=1;
static int whirlpool=1;
static int boot=1;
static int aes=1;
static int twofish=1;
static int serpent=1;
static int aes_twofish=1;
static int aes_twofish_serpent=1;
static int serpent_aes=1;
static int serpent_twofish_aes=1;
static int twofish_serpent=1;
static int xts=1;
static int lrw=1;
static int hidden=0;
static int normal=0;
static int keyfile=0;
static unsigned char keytab[64];
static int bytes=0;
static int algos=0;




static void init_keytab(void)
{
    int a;

    for (a=0;a<64;a++) keytab[a]=0;
}

static hash_stat crc_file(char *file)
{
    int fd;
    uint32_t crc=~0U;
    int pos=0;
    int fpos=0;
    char *buf;
    int len;

    fd = open(file,O_RDONLY);
    if (fd<1)
    {
        elog("Cannot open key file: %s\n",file);
        return hash_err;
    }

    buf = malloc(1024*1024);
    len = read(fd,buf,1024*1024);
    for (fpos=0;fpos<len;fpos++)
    {
        crc = crc_32_tab[(crc ^ buf[fpos]) & 0xFF] ^ (crc >> 8);
        keytab[pos++] += (unsigned char)(crc>>24);
        keytab[pos++] += (unsigned char)(crc>>16);
        keytab[pos++] += (unsigned char)(crc>>8);
        keytab[pos++] += (unsigned char)(crc);
        if (pos>=64) pos=0;

    }
    close(fd);
    free(buf);
    return hash_ok;
}



hash_stat load_truecrypt(char *filename)
{
    int myfile;
    char *tok,*tok1;
    char *ptr;
    char *ptr1;
    char *myline;
    char hashline[4096];

    if (additional_options)
    {
	strncpy(hashline,additional_options,4095);
	hashline[4095]=0;
    }
    else bzero(hashline,4095);

    init_keytab();
    myfile = open(filename, O_RDONLY|O_LARGEFILE);
    if (myfile<1) 
    {
        return hash_err;
    }
    
    if (read(myfile,sector,512) < 512) 
    {
        return hash_err;
    }
    memcpy(tc_salt,sector,64);

    keyfile=0;

    if (hashline[0]==0)
    {
	sha512=ripemd=whirlpool=1;
	boot=aes=twofish=serpent=1;
	aes_twofish=aes_twofish_serpent=1;
	serpent_aes=serpent_twofish_aes=1;
	twofish_serpent=xts=lrw=normal=1;
	hidden=0;keyfile=0;
    }
    else
    {
        myline = malloc(strlen(hashline)+1);
        strcpy(myline,hashline);

        tok = strtok_r(myline,":",&ptr);
        if (strcmp(tok,"all")==0)
        {
            // TODO: hidsalt, hidsector stuff
            sha512=ripemd=whirlpool=1;
            boot=aes=twofish=serpent=1;
            aes_twofish=aes_twofish_serpent=1;
            serpent_aes=serpent_twofish_aes=1;
            twofish_serpent=xts=lrw=normal=1;
            hidden=0;
            tok=strtok_r(NULL,":",&ptr);
            if (tok)
            {
                keyfile=1;
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (crc_file(tok1) == hash_err) return hash_err;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }
        }
        else if (strcmp(tok,"all,hidden")==0)
        {
            // TODO: hidsalt, hidsector stuff
            sha512=ripemd=whirlpool=1;
            boot=aes=twofish=serpent=1;
            aes_twofish=aes_twofish_serpent=1;
            serpent_aes=serpent_twofish_aes=1;
            twofish_serpent=xts=lrw=hidden=1;
            normal=0;
            tok=strtok_r(NULL,":",&ptr);
            if (tok)
            {
                keyfile=1;
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (crc_file(tok1) == hash_err) return hash_err;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }
        }
        else if (strcmp(tok,"default")==0)
       {
            sha512=0;
            ripemd=1;
            whirlpool=0;
            boot=1;
            aes=1;
            twofish=0;
            serpent=0;
            aes_twofish=0;
            aes_twofish_serpent=0;
            serpent_aes=0;
            serpent_twofish_aes=0;
            twofish_serpent=0;
            xts=1;
            lrw=0;
            normal=1;
            hidden=0;
            tok=strtok_r(NULL,":",&ptr);
            if (tok)
            {
                keyfile=1;
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (crc_file(tok1) == hash_err) return hash_err;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }
        }
        else if (strcmp(tok,"default,hidden")==0)
        {
            sha512=0;
            ripemd=1;
            whirlpool=0;
            boot=1;
            aes=1;
            twofish=0;
            serpent=0;
            aes_twofish=0;
            aes_twofish_serpent=0;
            serpent_aes=0;
            serpent_twofish_aes=0;
            twofish_serpent=0;
            xts=1;
            lrw=0;
            normal=0;
            hidden=1;
            tok=strtok_r(NULL,":",&ptr);
            if (tok)
            {
                keyfile=1;
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (crc_file(tok1) == hash_err) return hash_err;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }
        }
        else
        {
            sha512=0;
            ripemd=0;
            whirlpool=0;
            boot=0;
            aes=0;
            twofish=0;
            serpent=0;
            aes_twofish=0;
            aes_twofish_serpent=0;
            serpent_aes=0;
            serpent_twofish_aes=0;
            twofish_serpent=0;
            lrw=0;
            xts=0;
            normal=1;
            hidden=0;

            tok1=strtok_r(tok,",",&ptr1);
            while (tok1)
            {
                if (strcmp(tok1,"s")==0) sha512 = 1;
                if (strcmp(tok1,"1")==0) sha1 = 1;
                if (strcmp(tok1,"r")==0) ripemd = 1;
                if (strcmp(tok1,"w")==0) whirlpool = 1;
                if (strcmp(tok1,"b")==0) boot = 1;
                tok1=strtok_r(NULL,",",&ptr1);
            }
            /* Go on - get ciphers*/
            free(myline);
            myline = malloc(strlen(hashline)+1);
            strcpy(myline,hashline);
            tok = strtok_r(myline,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            if (tok)
            {
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (strcmp(tok1,"s")==0) serpent = 1;
                    if (strcmp(tok1,"t")==0) twofish = 1;
                    if (strcmp(tok1,"a")==0) aes = 1;
                    if (strcmp(tok1,"at")==0) aes_twofish = 1;
                    if (strcmp(tok1,"ats")==0) aes_twofish_serpent = 1;
                    if (strcmp(tok1,"sa")==0) serpent_aes = 1;
                    if (strcmp(tok1,"ts")==0) twofish_serpent = 1;
                    if (strcmp(tok1,"sta")==0) serpent_twofish_aes = 1;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }

            /* Go on - get normal/hidden */
            free(myline);
            myline = malloc(strlen(hashline)+1);
            strcpy(myline,hashline);
            tok = strtok_r(myline,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            if (tok)
            {
                tok1=strtok_r(tok,",",&ptr1);
                normal=hidden=0;
                while (tok1)
                {
                    if (strcmp(tok1,"h")==0) {hidden = 1;normal=0;}
                    if (strcmp(tok1,"n")==0) {normal = 1;hidden=0;}
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }

            /* Go on - get keyfile*/
            free(myline);
            myline = malloc(strlen(hashline)+1);
            strcpy(myline,hashline);
            tok = strtok_r(myline,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            tok = strtok_r(NULL,":",&ptr);
            if (tok)
            {
                keyfile=1;
                tok1=strtok_r(tok,",",&ptr1);
                while (tok1)
                {
                    if (crc_file(tok1) == hash_err) return hash_err;
                    tok1=strtok_r(NULL,",",&ptr1);
                }
            }
            free (myline);
        }
    }


    if ((hidden==0)&&(normal==0)) normal=1;
    if (hidden==1)
    {
        lseek(myfile,65536,SEEK_SET);
        if (read(myfile,sector,512) < 512) 
        {
            return hash_err;
        }
        memcpy(tc_salt,sector,64);
    }
    close(myfile);

    if (sha512) algos++;
    if (ripemd) algos++;
    if (whirlpool) algos++;

    if ((aes)||(serpent)||(twofish)) bytes=64;
    if ((aes_twofish)||(serpent_aes)) bytes=128;
    if ((aes_twofish_serpent)||(serpent_twofish_aes)) bytes=192;
    return hash_ok;
}



static hash_stat check_truecrypt(char *key)
{
    unsigned char out[16];
    unsigned char out1[16];
    unsigned char out2[16];

    if (aes)
    {
	hash_proto_decrypt_aes_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
	if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (twofish)
    {
	hash_proto_decrypt_twofish_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
	if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (serpent)
    {
	hash_proto_decrypt_serpent_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
	if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (aes_twofish)
    {
	hash_proto_decrypt_aes_xts((char *)key+32, (char *)key+96, (char *)sector+64, (char *)out, 16, 0, 0);
	hash_proto_decrypt_twofish_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
	if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (serpent_aes)
    {
	hash_proto_decrypt_serpent_xts((char *)key+32, (char *)key+96, (char *)sector+64, (char *)out, 16, 0, 0);
	hash_proto_decrypt_aes_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
	if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (twofish_serpent)
    {
	hash_proto_decrypt_twofish_xts((char *)key+32, (char *)key+96, (char *)sector+64, (char *)out, 16, 0, 0);
	hash_proto_decrypt_serpent_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
	if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (aes_twofish_serpent)
    {
	hash_proto_decrypt_aes_xts((char *)key+64, (char *)key+160, (char *)sector+64, (char *)out, 16, 0, 0);
	hash_proto_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
	hash_proto_decrypt_serpent_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
	if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }
    if (serpent_twofish_aes)
    {
	hash_proto_decrypt_serpent_xts((char *)key+64, (char *)key+160, (char *)sector+64, (char *)out, 16, 0, 0);
	hash_proto_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
	hash_proto_decrypt_aes_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
	if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
	{
	    return hash_ok;
	}
    }

    return hash_err;
}




static cl_uint16 ocl_get_salt()
{
    cl_uint16 t;

    t.s0=tc_salt[0]|(tc_salt[1]<<8)|(tc_salt[2]<<16)|(tc_salt[3]<<24);
    t.s1=tc_salt[4]|(tc_salt[5]<<8)|(tc_salt[6]<<16)|(tc_salt[7]<<24);
    t.s2=tc_salt[8]|(tc_salt[9]<<8)|(tc_salt[10]<<16)|(tc_salt[11]<<24);
    t.s3=tc_salt[12]|(tc_salt[13]<<8)|(tc_salt[14]<<16)|(tc_salt[15]<<24);
    t.s4=tc_salt[16]|(tc_salt[17]<<8)|(tc_salt[18]<<16)|(tc_salt[19]<<24);
    t.s5=tc_salt[20]|(tc_salt[21]<<8)|(tc_salt[22]<<16)|(tc_salt[23]<<24);
    t.s6=tc_salt[24]|(tc_salt[25]<<8)|(tc_salt[26]<<16)|(tc_salt[27]<<24);
    t.s7=tc_salt[28]|(tc_salt[29]<<8)|(tc_salt[30]<<16)|(tc_salt[31]<<24);
    t.s8=tc_salt[32]|(tc_salt[33]<<8)|(tc_salt[34]<<16)|(tc_salt[35]<<24);
    t.s9=tc_salt[36]|(tc_salt[37]<<8)|(tc_salt[38]<<16)|(tc_salt[39]<<24);
    t.sA=tc_salt[40]|(tc_salt[41]<<8)|(tc_salt[42]<<16)|(tc_salt[43]<<24);
    t.sB=tc_salt[44]|(tc_salt[45]<<8)|(tc_salt[46]<<16)|(tc_salt[47]<<24);
    t.sC=tc_salt[48]|(tc_salt[49]<<8)|(tc_salt[50]<<16)|(tc_salt[51]<<24);
    t.sD=tc_salt[52]|(tc_salt[53]<<8)|(tc_salt[54]<<16)|(tc_salt[55]<<24);
    t.sE=tc_salt[56]|(tc_salt[57]<<8)|(tc_salt[58]<<16)|(tc_salt[59]<<24);
    t.sF=tc_salt[60]|(tc_salt[61]<<8)|(tc_salt[62]<<16)|(tc_salt[63]<<24);

    return t;
}

static cl_uint16 ocl_get_salt2()
{
    cl_uint16 t;

    t.s0=keytab[0]|(keytab[1]<<8)|(keytab[2]<<16)|(keytab[3]<<24);
    t.s1=keytab[4]|(keytab[5]<<8)|(keytab[6]<<16)|(keytab[7]<<24);
    t.s2=keytab[8]|(keytab[9]<<8)|(keytab[10]<<16)|(keytab[11]<<24);
    t.s3=keytab[12]|(keytab[13]<<8)|(keytab[14]<<16)|(keytab[15]<<24);
    t.s4=keytab[16]|(keytab[17]<<8)|(keytab[18]<<16)|(keytab[19]<<24);
    t.s5=keytab[20]|(keytab[21]<<8)|(keytab[22]<<16)|(keytab[23]<<24);
    t.s6=keytab[24]|(keytab[25]<<8)|(keytab[26]<<16)|(keytab[27]<<24);
    t.s7=keytab[28]|(keytab[29]<<8)|(keytab[30]<<16)|(keytab[31]<<24);
    t.s8=keytab[32]|(keytab[33]<<8)|(keytab[34]<<16)|(keytab[35]<<24);
    t.s9=keytab[36]|(keytab[37]<<8)|(keytab[38]<<16)|(keytab[39]<<24);
    t.sA=keytab[40]|(keytab[41]<<8)|(keytab[42]<<16)|(keytab[43]<<24);
    t.sB=keytab[44]|(keytab[45]<<8)|(keytab[46]<<16)|(keytab[47]<<24);
    t.sC=keytab[48]|(keytab[49]<<8)|(keytab[50]<<16)|(keytab[51]<<24);
    t.sD=keytab[52]|(keytab[53]<<8)|(keytab[54]<<16)|(keytab[55]<<24);
    t.sE=keytab[56]|(keytab[57]<<8)|(keytab[58]<<16)|(keytab[59]<<24);
    t.sF=keytab[60]|(keytab[61]<<8)|(keytab[62]<<16)|(keytab[63]<<24);

    return t;
}





/* Crack callback */
static void ocl_truecrypt_crack_callback(char *line, int self)
{
    int a,b;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 salt2;
    size_t nws1;
    size_t nws;
    char key[hash_ret_len1];

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    /* setup salt */
    salt=ocl_get_salt();
    salt2=ocl_get_salt2();

    if (attack_over!=0) pthread_exit(NULL);

    if (rule_counts[self][0]==-1) return;
    nws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((nws%64)!=0) nws++;
    nws1 = nws*wthreads[self].vectorsize;
    if (nws1==0) nws1=64;
    if (nws==0) nws=64;

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelmod[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelmod[self], 6, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelend1[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend1[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend1[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelend2[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend2[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre2[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl2[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl2[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl2[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelend3[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernelend3[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelend3[self], 2, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelend3[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelend3[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelend3[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelpre3[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelpre3[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre3[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre3[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelpre3[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre3[self], 5, sizeof(cl_uint16), (void*) &salt2);
    _clSetKernelArg(rule_kernelbl3[self], 0, sizeof(cl_mem), (void*) &rule_images4_buf[self]);
    _clSetKernelArg(rule_kernelbl3[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelbl3[self], 2, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelbl3[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelbl3[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelbl3[self], 5, sizeof(cl_uint16), (void*) &salt2);
    if (attack_over!=0) pthread_exit(NULL);


    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &nws1, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    if (ripemd==1)
    {
	for (b=0;b<=((bytes)/20);b++)
	{
	    addline.sC=b;
	    addline.sD=keyfile;
	    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_uint16), (void*) &addline);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
	    _clSetKernelArg(rule_kernelend1[self], 3, sizeof(cl_uint16), (void*) &addline);
	    for (a=0;a<2000;a+=1000)
	    {
		if (attack_over!=0) return;
		addline.sA=a;
		if (a==0) addline.sA=1;
		addline.sB=a+1000;
		_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_uint16), (void*) &addline);
		_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
		_clFinish(rule_oclqueue[self]);
    		wthreads[self].tries+=(nws1)/((((bytes)/20)*2)*algos);
    		pthread_mutex_lock(&wthreads[self].tempmutex);
    		pthread_mutex_unlock(&wthreads[self].tempmutex);
	    }
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend1[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	}
	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
	for (a=0;a<nws1;a++)
	{
	    if (attack_over!=0) return;
    	    b=a*hash_ret_len1;
    	    memcpy(key,rule_ptr[self]+b,hash_ret_len1);
	    if (check_truecrypt(key)==hash_ok)
	    {
		strcpy(plain,&rule_images[self][0]+(a*MAX));
		strcat(plain,line);
		add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
	    }
	}
    }

    if (sha512==1)
    {
	for (b=0;b<(bytes/64);b++)
	{
	    if (attack_over!=0) return;
	    addline.sC=b;
	    addline.sD=keyfile;
	    _clSetKernelArg(rule_kernelpre2[self], 3, sizeof(cl_uint16), (void*) &addline);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
	    _clSetKernelArg(rule_kernelend2[self], 3, sizeof(cl_uint16), (void*) &addline);
	    for (a=0;a<1000;a+=10)
	    {
		if (attack_over!=0) return;
		addline.sA=a;
		if (a==0) addline.sA=1;
		addline.sB=a+10;
		_clSetKernelArg(rule_kernelbl2[self], 3, sizeof(cl_uint16), (void*) &addline);
		_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
		_clFinish(rule_oclqueue[self]);
    		if ((a%100)==0)wthreads[self].tries+=(nws1)/(((bytes/64)*10)*algos);
    		pthread_mutex_lock(&wthreads[self].tempmutex);
    		pthread_mutex_unlock(&wthreads[self].tempmutex);
	    }
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	}
	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
	for (a=0;a<nws1;a++)
	{
	    if (attack_over!=0) return;
    	    b=a*hash_ret_len1;
    	    memcpy(key,rule_ptr[self]+b,hash_ret_len1);
	    if (check_truecrypt(key)==hash_ok)
	    {
		strcpy(plain,&rule_images[self][0]+(a*MAX));
		strcat(plain,line);
		add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
	    }
	}
    }

    if (whirlpool==1)
    {
	for (b=0;b<(bytes/64);b++)
	{
	    if (attack_over!=0) return;
	    addline.sC=b;
	    addline.sD=keyfile;
	    _clSetKernelArg(rule_kernelpre3[self], 3, sizeof(cl_uint16), (void*) &addline);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre3[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
	    _clSetKernelArg(rule_kernelend3[self], 3, sizeof(cl_uint16), (void*) &addline);
	    for (a=0;a<1000;a+=10)
	    {
		if (attack_over!=0) return;
		addline.sA=a;
		if (a==0) addline.sA=1;
		addline.sB=a+10;
		_clSetKernelArg(rule_kernelbl3[self], 3, sizeof(cl_uint16), (void*) &addline);
		_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl3[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
		_clFinish(rule_oclqueue[self]);
    		if ((a%100)==0)wthreads[self].tries+=(nws1)/(((bytes/64)*10)*algos);
    		pthread_mutex_lock(&wthreads[self].tempmutex);
    		pthread_mutex_unlock(&wthreads[self].tempmutex);
	    }
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelend3[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
	}
	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, 0, hash_ret_len1*wthreads[self].vectorsize*ocl_rule_workset[self], rule_ptr[self], 0, NULL, NULL);
	for (a=0;a<nws1;a++)
	{
	    if (attack_over!=0) return;
    	    b=a*hash_ret_len1;
    	    memcpy(key,rule_ptr[self]+b,hash_ret_len1);
	    if (check_truecrypt(key)==hash_ok)
	    {
		strcpy(plain,&rule_images[self][0]+(a*MAX));
		strcat(plain,line);
		add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
	    }
	}
    }
}



static void ocl_truecrypt_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strncpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line,MAX);

    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_truecrypt_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) return;
}




/* Worker thread - rule attack */
void* ocl_rule_truecrypt_thread(void *arg)
{
    cl_int err;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=128*128;
    if (ocl_gpu_double) ocl_rule_workset[self]*=4;
    if (interactive_mode==1) ocl_rule_workset[self]/=4;

    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare1", &err );
    rule_kernelbl1[self] = _clCreateKernel(program[self], "pbkdf1", &err );
    rule_kernelend1[self] = _clCreateKernel(program[self], "final1", &err );
    rule_kernelpre2[self] = _clCreateKernel(program[self], "prepare2", &err );
    rule_kernelbl2[self] = _clCreateKernel(program[self], "pbkdf2", &err );
    rule_kernelend2[self] = _clCreateKernel(program[self], "final2", &err );
    rule_kernelpre3[self] = _clCreateKernel(program[self], "prepare3", &err );
    rule_kernelbl3[self] = _clCreateKernel(program[self], "pbkdf3", &err );
    rule_kernelend3[self] = _clCreateKernel(program[self], "final3", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );


    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*4, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*128, NULL, &err );
    rule_images4_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*128, NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*4);
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*128);
    rule_images4[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*128);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*4);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*128);
    bzero(&rule_images4[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*128);

    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_truecrypt_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_truecrypt(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_truecrypt(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_truecrypt(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    load_truecrypt(hashlist_file);
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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_truecrypt__%s.bin",DATADIR,pbuf);

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
            sprintf(kernelfile,"%s/hashkill/kernels/nvidia_truecrypt__%s.ptx",DATADIR,pbuf);

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_truecrypt_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_truecrypt_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

