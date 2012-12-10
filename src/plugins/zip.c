/* zip.c
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
#include <sys/types.h>
#include "zlib.h"
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))

int vectorsize;


char myfilename[255];
FILE *myfile;
unsigned int g_CrcTable[256];



static unsigned char zip_normbuf[5][12];
static unsigned char zip_crc32[4];
static unsigned char zip_tim[2];
static long fileoffset;
static int filenamelen;
static int comprsize, ucomprsize;
static char zipbuf[1024*16];
static char verifiers[5];
static int cur=0;
static long offsets[5];
static int has_winzip_encryption, has_ext_flag, winzip_key_size, winzip_salt_size;
static unsigned char winzip_salt[16];
static unsigned char winzip_check[2];




#define kCrcPoly 0xEDB88320
#define CRC_UPDATE_BYTE(crc, b) (g_CrcTable[((crc) ^ (b)) & 0xFF] ^ ((crc) >> 8))
static void  CrcGenerateTable(void)
{
  unsigned int i;
  for (i = 0; i < 256; i++)
  {
    unsigned int r = i;
    int j;
    for (j = 0; j < 8; j++)
      r = (r >> 1) ^ (kCrcPoly & ~((r & 1) - 1));
    g_CrcTable[i] = r;
  }
}



char * hash_plugin_summary(void)
{
    return("zip \t\tZIP passwords plugin");
}


char * hash_plugin_detailed(void)
{
    return("zip - A ZIP passwords plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack ZIP archives passwords\n"
	    "Input should be a passworded ZIP file specified with -f\n"
	    "Supports the old encryption method as well as AES encryption (WinZIP)\n"
	    "Known software that uses this password hashing method:\n"
	    "WinZIP, p7zip, etc\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd,added;
    char buf[4096];
    unsigned int u321;
    unsigned short u161, genpurpose, extrafieldlen;
    int parsed=0,compmethod=0,fileissmall=0;
    int usizes[5],csizes[5];
    
    fileoffset = 0;
    CrcGenerateTable();
    strcpy(myfilename, filename);

    fd = open(filename, O_RDONLY);
    if (fd<1)
    {
        if (!hashline) elog("Cannot open file %s\n", filename);
        return hash_err;
    }
    read(fd, &u321, 4);
    fileoffset+=4;
    if (u321 != 0x04034b50)
    {
        if (!hashline) elog("Not a ZIP file: %s!\n", filename);
        return hash_err;
    }
    close(fd);
    fileoffset=0;
    fd = open(filename, O_RDONLY);

    while (!parsed)
    {
        has_winzip_encryption=0;
        has_ext_flag=0;
        compmethod=0;
        fileissmall=0;

        read(fd, &u321, 4);
        fileoffset+=4;
        if (u321 != 0x04034b50)
        {
            parsed=1;
            break;
        }

        /* version needed to extract */
        read(fd, &u161, 2);
        fileoffset+=2;
        /* general purpose bit flag */
        read(fd, &genpurpose, 2);
        fileoffset+=2;
        /* compression method, last mod file time, last mod file date */
        read(fd, &u161, 2);
        fileoffset+=2;
        compmethod=u161;
        if (u161 == 99) 
        {
            has_winzip_encryption = 1;
        }
        read(fd, &zip_tim, 2);
        read(fd, &u161, 2);
        fileoffset+=4;

        /* crc32 */
        read(fd, zip_crc32, 4);
        fileoffset+=4;

        /* compressed size */
        read(fd, &comprsize, 4);
        fileoffset+=4;

        /* uncompressed size */
        read(fd, &ucomprsize, 4);
        fileoffset+=4;
        if (ucomprsize<100) fileissmall=1;

        /* file name length */
        read(fd, &filenamelen, 2);
        fileoffset+=2;

        /* extra field length */
        read(fd, &extrafieldlen, 2);
        fileoffset+=2;

        /* file name */
        bzero(buf,4096);
        read(fd, buf, filenamelen);
        fileoffset+=filenamelen;
        //printf("File: %s verneeded=%d haswe=%d compmethod=%d eflen=%d\n",buf,verneeded,has_winzip_encryption,compmethod,extrafieldlen);

        /* extra field should be taken care if winzip encryption is used */
        read(fd, buf, extrafieldlen);
        fileoffset+=extrafieldlen;

        if (CHECK_BIT(genpurpose, 3) == 1) has_ext_flag = 1;
        else has_ext_flag=0;
        //printf("has extra flag=%d\n",has_ext_flag);
        added=0;

        /* check if bit 0 in genpurpose are set => we've got encryption */
        if (CHECK_BIT(genpurpose, 0) == 0)
        {
        }
        else 
        {
            parsed=1;
            if (has_winzip_encryption == 1) 
            {
                switch (buf[8]&255)
                {
                    case 1: winzip_key_size = 128;winzip_salt_size = 8;break;
                    case 2: winzip_key_size = 192;winzip_salt_size = 12;break;
                    case 3: winzip_key_size = 256;winzip_salt_size = 16;break;
                    default: if (!hashline) elog("Unknown AES encryption key length (0x%02x) quitting...\n",buf[8]&255);return hash_err;
                }
                if (!hashline) hlog("Encrypted using strong AES%d encryption\n",winzip_key_size);
            }
            // Parse the encryption header - the winzip way 
            if (has_winzip_encryption)
            {
                read(fd, winzip_salt, winzip_salt_size);
                read(fd, winzip_check, 2);
            }
            else if ((compmethod==8)&&(fileissmall==0))
            {
                //if (has_ext_flag==0) 
                //{
                verifiers[cur]=zip_tim[1]&255;
                //}
                //else 
                //{
                //    verifiers[cur]=(zip_crc32[3]&255);
                //}

                read(fd, (char *)zip_normbuf[cur], 12);
                fileoffset+=12;
                offsets[cur]=fileoffset;
                comprsize-=12;
                csizes[cur]=comprsize;
                usizes[cur]=ucomprsize;
                cur++;
                added=1;
            }
            else parsed=0;
        }

        if ((cur<5)&&(has_winzip_encryption==0)) parsed=0;
        if (parsed==0)
        {
            lseek(fd,comprsize,SEEK_CUR);
            fileoffset+=comprsize;
            read(fd,&u321,4);
            if (u321==0x08074b50)
            {
                fileoffset+=4;
                lseek(fd,12,SEEK_CUR);
                fileoffset+=12;
            }
            else
            {
                if (added==1) verifiers[cur-1]=(zip_crc32[3]&255);
                lseek(fd,-4,SEEK_CUR);
            }
        }
    }


    if ((parsed==0)&&(cur!=0)&&(cur<5)&&(has_winzip_encryption==0))
    {
        parsed=1;
    }

    if ((!hashline) && (has_winzip_encryption==0)) hlog("Found >= %d password-protected files in archive!\n",cur);

    if ((cur==0)&&(has_winzip_encryption==0))
    {
            if (!hashline) elog("File %s is not a password-protected ZIP archive\n", filename);
            return hash_err;
    }

    if (has_winzip_encryption==0)
    {
        lseek(fd,offsets[0],SEEK_SET);
        fileoffset=offsets[0];
        read(fd,zipbuf,1024*16);
        comprsize=csizes[0];
        ucomprsize=usizes[0];
    }

    close(fd);

    (void)hash_add_username(filename);
    (void)hash_add_hash("ZIP file        ",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}




hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char key[68];
    unsigned char check[2];
    unsigned long key0,key1,key2;
    unsigned char norm_zip_local[12];
    int fd;
    int ret, bsize, rsize, usize,a,b=0;
    unsigned char in[1024*16+100];
    unsigned char out[1024*16*10+100];
    unsigned char authcode[16];
    unsigned char authresult[16];

    for (a=0;a<vectorsize;a++)
    if (has_winzip_encryption==1) 
    {
	hash_pbkdf2(password[a], winzip_salt, winzip_salt_size, 1000, 2*(winzip_key_size/8)+2, key);
	check[0] = key[2*(winzip_key_size/8)];
	check[1] = key[2*(winzip_key_size/8)+1];
	
	/* As mentioned in WinZIP documentation, this gives out 1/65535 error probability. Calculate auth codes */
        if (memcmp(winzip_check, check, 2)==0) 
	{
	    fd = open(myfilename, O_RDONLY);
	    lseek(fd, fileoffset + comprsize - 10, SEEK_SET);
	    read(fd, authcode, 10);
	    hash_hmac_sha1_file((unsigned char *)&key[winzip_key_size/8], winzip_key_size/8, myfilename, fileoffset+winzip_salt_size+2, comprsize-12-winzip_salt_size, (unsigned char *)&authresult, 10);
	    if (memcmp((char *)&authresult[4], (char *)&authcode[4], 6)==0)
	    {
		*num=a;
		memcpy(salt2[a],"ZIP file        \0\0",17);
		return hash_ok;
	    }
	    else
	    {
		salt2[a][0]=password[a][0];
		//return hash_err;
		goto next;
	    }
	}
	else 
	{
	    salt2[a][0]=password[a][0];
	    //return hash_err;
	    goto next;
	}
    }
    else
    {
	int passes=0;
	for (b=0;b<cur;b++)
	{
	    key0 = 305419896L;
	    key1 = 591751049L;
	    key2 = 878082192L;
	    int i;
	    for (i=0; i<strlen(password[a]); i++)
	    {
		key0=CRC_UPDATE_BYTE(key0, (char)*(password[a]+i));
		key1 += key0 & 0xff;
		key1 = key1 * 134775813L + 1;
		key2 = CRC_UPDATE_BYTE(key2,(char)(key1>>24));
	    }
    	    unsigned char temp1;
    	    unsigned char c;
    	    unsigned  long temp;
	    memcpy((char *)&norm_zip_local, (char *)&zip_normbuf[b], 12);
	    for (i=0;i<12;i++)
	    {
		temp = (key2) | 2;
		temp1 = (((temp * (temp ^1)) >> 8));
		c = norm_zip_local[i] ^ temp1;
		key0 = CRC_UPDATE_BYTE(key0,c);
		key1 += key0 & 0xff;
		key1 = key1 * 134775813L + 1;
		key2 = CRC_UPDATE_BYTE(key2,(char)(key1 >> 24));
		norm_zip_local[i] = c;
	    }
	    if (verifiers[b] == norm_zip_local[11]) passes++;
	    else break;
	}
	if (passes<(cur)) goto next;

	/* all passes OK, go on */
	key0 = 305419896L;
	key1 = 591751049L;
	key2 = 878082192L;
	int i;
	for (i=0; i<strlen(password[a]); i++)
	{
	    key0=CRC_UPDATE_BYTE(key0, (char)*(password[a]+i));
	    key1 += key0 & 0xff;
	    key1 = key1 * 134775813L + 1;
	    key2 = CRC_UPDATE_BYTE(key2,(char)(key1>>24));
	}
        unsigned char temp1;
        unsigned char c;
        unsigned  long temp;
	memcpy((char *)&norm_zip_local, (char *)&zip_normbuf[0], 12);
	for (i=0;i<12;i++)
	{
	    temp = (key2) | 2;
	    temp1 = (((temp * (temp ^1)) >> 8));
	    c = norm_zip_local[i] ^ temp1;
	    key0 = CRC_UPDATE_BYTE(key0,c);
	    key1 += key0 & 0xff;
	    key1 = key1 * 134775813L + 1;
	    key2 = CRC_UPDATE_BYTE(key2,(char)(key1 >> 24));
	    norm_zip_local[i] = c;
	}

	
	if ( verifiers[0] == norm_zip_local[11])
	{
	    fd = open(myfilename,O_RDONLY);
	    lseek(fd, fileoffset, SEEK_SET);
	    z_stream strm;
	    strm.zalloc = Z_NULL;
    	    strm.zfree = Z_NULL;
    	    strm.opaque = Z_NULL;
            strm.avail_in = 1024*16;
            strm.avail_out = 1024*16*10;

            strm.next_in = in;
            strm.next_out = out;

            ret = inflateInit2(&strm,-15);
            if (ret != Z_OK) elog("inflateinit ERROR!\n%s","");
            rsize = 0;usize = 0;
            while (rsize < (comprsize-12))
            {
        	if ((comprsize-rsize)>1024*16) ret = 1024*16;
		else ret = comprsize-rsize;
        	bsize = read(fd, in,  ret);

        	for (ret = 0; ret < bsize;ret++)
        	{
        	    temp = (key2) | 2;
		    temp1 = (((temp * (temp ^1)) >> 8));
		    c = in[ret] ^ temp1;
		    key0=CRC_UPDATE_BYTE(key0, c);
		    key1 += key0 & 0xff;
		    key1 = key1 * 134775813L + 1;
		    key2 = CRC_UPDATE_BYTE(key2,(char)(key1>>24));
		    in[ret] = c;
        	}
        	strm.next_in = in;
        	strm.avail_out = bsize*10;
        	strm.avail_in = bsize;
        	strm.next_out = out;
        	usize = strm.total_in;
        	ret = inflate(&strm, Z_SYNC_FLUSH);
        	lseek(fd, fileoffset + strm.total_in,SEEK_SET);
		rsize += (strm.total_in - usize);
        	if (ret == Z_DATA_ERROR) 
        	{
        	    close(fd);
        	    inflateEnd(&strm);
        	    //return hash_err;
        	    goto next;
    		}
                if (ret == Z_NEED_DICT) 
	        {

        	    close(fd);
        	    inflateEnd(&strm);
        	    //return hash_err;
        	    goto next;
    		}
        	if (ret == Z_STREAM_ERROR) 
        	{
        	    close(fd);
        	    inflateEnd(&strm);
        	    //return hash_err;
        	    goto next;
    		}

        	if  ((ret == Z_MEM_ERROR))
		{
		    close(fd);
		    inflateEnd(&strm);
        	    //return hash_err;
        	    goto next;
    		}
    		if (ret == Z_STREAM_END) rsize = comprsize+1;
	    }
	    if (has_ext_flag == 0)
	    {
		if ((zip_tim[1] == norm_zip_local[11]) && (ucomprsize==strm.total_out))
		{
		    memcpy(salt2[a],"ZIP file        \0\0\0\0\0\0\0\0\0",20);
		    *num=a;
		    inflateEnd(&strm);
		    close(fd);
		    return hash_ok;
    		}
    	    }
    	    else if ((norm_zip_local[11] == zip_crc32[3]) && (ucomprsize==strm.total_out))
	    {
		    memcpy(salt2[a],"ZIP file        \0\0\0\0\0\0\0\0\0",20);
		    *num=a;
		    inflateEnd(&strm);
		    close(fd);
		    return hash_ok;
    	    }

	    else
	    {
		salt2[a][0]=password[a][0];
		inflateEnd(&strm);
		close(fd);
		//return hash_err;
	    }
    
	close(fd);
	}
    next:;
    }
    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 32;
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
   return 5;
}
