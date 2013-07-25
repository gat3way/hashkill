/* truecrypt.c
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
#include <alloca.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <stdint.h>
#include <openssl/sha.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

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





static char myfilename[255];
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


char * hash_plugin_summary(void)
{
    return("truecrypt \tTrueCrypt encrypted block device plugin");
}


char * hash_plugin_detailed(void)
{
    return("truecrypt - TrueCrypt encrypted block device plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack TrueCrypt encrypted volumes\n"
	    "Input should be a TrueCrypt device file specified with -f\n"
	    "Additional options supplied using -A using the following format:\n"
	    "-A hash_algo1,hash_algo2,..:ciper1,cipher2,...:[n[,h]]:[keyfile1,keyfile2,...]\n"
	    "-A default[:keyfile,...] will use default hash/cipher, normal partition with optional keyfiles\n"
	    "-A all[:keyfile,...] will use all algos, normal+hidden partition with optional keyfiles\n"
	    "-A default,hidden[:keyfile,...] will use default hash/cipher, normal partition with optional keyfiles\n"
	    "-A all,hidden[:keyfile,...] will use all algos, normal+hidden partition with optional keyfiles\n"
	    "hash_algos are as follows:\n"
	    "r - RIPEMD-160\n"
	    "s - SHA-512\n"
	    "w - Whirlpool\n\n"
	    "Ciphers are as follows:\n"
	    "a - AES\n"
	    "t - Twofish\n"
	    "s - Serpent\n"
	    "at - AES-Twofish\n"
	    "sa - Serpent-AES\n"
	    "ts - Twofish-Serpent\n"
	    "ats - AES-Twofish-Serpent\n"
	    "sta - Serpent-Twofish-AES\n\n"
	    "Volumes are as follows:\n"
	    "n - check the volume provided with -f (default)\n"
	    "h - check the hidden volume\n\n"
	    "You can use one or more keyfiles.\n"
	    "Example:\n"
	    "-A w,s:a,t,s,at,sa:nh:keyfile - Use Whirlpool/SHA512 with AES/Serpent/Twofish/AES-Twofish/Serpent-AES, check normal and hidden volume with keyfile: keyfile\n\n"
	    "Default is -A all\n\n"
	    "Known software that uses this password hashing method:\n"
	    "TrueCrypt\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}



void init_keytab(void)
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
    hlog("Processed keyfile: %s\n",file);
    return hash_ok;
}





hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int myfile;
    char *tok,*tok1;
    char *ptr;
    char *ptr1;
    char *myline;

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

    /* We have plugin options */
    if (hashline[0]!=0)
    {
	myline = malloc(strlen(hashline)+1);
	strcpy(myline,hashline);

	tok = strtok_r(myline,":",&ptr);
	if (!tok) return hash_err;
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
    else
    {
        sha512=ripemd=whirlpool=1;
        boot=aes=twofish=serpent=1;
        aes_twofish=aes_twofish_serpent=1;
        serpent_aes=serpent_twofish_aes=1;
        twofish_serpent=xts=lrw=normal=1;
        hidden=0;
        keyfile=0;
    }

    if ((hidden==0)&&(normal==0)) normal=1;


    (void)hash_add_hash("Truecrypt volume  ",0);
    if (hidden==1)
    {
	lseek(myfile,65536,SEEK_SET);
	if (read(myfile,sector,512) < 512) 
	{
	    return hash_err;
	}
	memcpy(tc_salt,sector,64);
	(void)hash_add_hash("Truecrypt hidden  ",0);

    }
    close(myfile);

    if ((aes)||(serpent)||(twofish)) bytes=64;
    if ((aes_twofish)||(serpent_aes)) bytes=128;
    if ((aes_twofish_serpent)||(serpent_twofish_aes)) bytes=192;

    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2(" ");

/*
printf("sha512: %d\n",sha512);
printf("ripemd: %d\n",ripemd);
printf("whirlpool: %d\n",whirlpool);
printf("boot: %d\n",boot);
printf("aes: %d\n",aes);
printf("serpent: %d\n",serpent);
printf("twofish: %d\n",twofish);
printf("aes_twofish: %d\n",aes_twofish);
printf("aes_twofish_serpent: %d\n",aes_twofish_serpent);
printf("serpent_aes: %d\n",serpent_aes);
printf("serpent_twofish_aes: %d\n",serpent_twofish_aes);
printf("lrw: %d\n",lrw);
printf("xts: %d\n",xts);
printf("hidden: %d\n",hidden);
printf("normal: %d\n",normal);
*/

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char key[64*3];
    unsigned char out[16];
    unsigned char out1[16];
    unsigned char out2[16];
    int a,b,len;
    char passphrase[64];
    char mysector[16];


    memcpy(mysector,sector+64,16);
    for (a=0;a<vectorsize;a++)
    {
	bzero(passphrase,64);
	len = strlen(password[a]);
	if ((keyfile==0)&&(len==0)) continue;
	memcpy(passphrase,password[a],len);
	if (keyfile==1)
	{
	    for (b=0;b<64;b++) passphrase[b] += keytab[b];
	    len=64;
	}

	if (sha512)
	{
	    hash_pbkdf512((char *)passphrase,len, (unsigned char *)tc_salt, 64, 1000, bytes, key);
	    if (aes)
	    {
		hash_decrypt_aes_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish)
	    {
		hash_decrypt_twofish_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent)
	    {
		hash_decrypt_serpent_xts((char *)key, (char *)key+32, (char *)mysector, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish)
	    {
		hash_decrypt_aes_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish_serpent)
	    {
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish_serpent)
	    {
		hash_decrypt_aes_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_twofish_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	}
	if (ripemd)
	{
	    hash_pbkdfrmd160((char *)passphrase,len, (unsigned char *)tc_salt, 64, 2000, bytes, key);
	    if (aes)
	    {
		hash_decrypt_aes_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish)
	    {
		hash_decrypt_twofish_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent)
	    {
		hash_decrypt_serpent_xts((char *)key, (char *)key+32, (char *)mysector, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish)
	    {
		hash_decrypt_aes_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish_serpent)
	    {
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish_serpent)
	    {
		hash_decrypt_aes_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_twofish_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	}
	if (whirlpool)
	{
	    hash_pbkdfwhirlpool((char *)passphrase,len, (unsigned char *)tc_salt, 64, 1000, bytes, key);
	    if (aes)
	    {
		hash_decrypt_aes_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish)
	    {
		hash_decrypt_twofish_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent)
	    {
		hash_decrypt_serpent_xts((char *)key, (char *)key+32, (char *)mysector, (char *)out, 16, 0, 0);
		if ((memcmp(out, "TRUE", 4)==0)&&(memcmp(out+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish)
	    {
		hash_decrypt_aes_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (twofish_serpent)
	    {
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+96, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+64, (char *)out, (char *)out1, 16, 0, 0);
		if ((memcmp(out1, "TRUE", 4)==0)&&(memcmp(out1+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (aes_twofish_serpent)
	    {
		hash_decrypt_aes_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_serpent_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
		{
		    *num=a;
		    return hash_ok;
		}
	    }
	    if (serpent_twofish_aes)
	    {
		hash_decrypt_serpent_xts((char *)key+64, (char *)key+160, (char *)mysector, (char *)out, 16, 0, 0);
		hash_decrypt_twofish_xts((char *)key+32, (char *)key+128, (char *)out, (char *)out1, 16, 0, 0);
		hash_decrypt_aes_xts((char *)key, (char *)key+96, (char *)out1, (char *)out2, 16, 0, 0);
		if ((memcmp(out2, "TRUE", 4)==0)&&(memcmp(out2+12,"\x00\x00\x00\x00",4)==0))
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
    return 0;
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

