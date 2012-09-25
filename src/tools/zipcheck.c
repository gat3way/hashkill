/* zipcheck.c
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
static numfiles=0;



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



int check_zip(char *hashline, char *filename)
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
        //printf("Cannot open file %s\n", filename);
        return 0;
    }
    read(fd, &u321, 4);
    fileoffset+=4;
    if (u321 != 0x04034b50)
    {
        //printf("Not a ZIP file: %s!\n", filename);
        return 0;
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
        ////printf("File: %s verneeded=%d haswe=%d compmethod=%d eflen=%d\n",buf,verneeded,has_winzip_encryption,compmethod,extrafieldlen);

        /* extra field should be taken care if winzip encryption is used */
        read(fd, buf, extrafieldlen);
        fileoffset+=extrafieldlen;

        if (CHECK_BIT(genpurpose, 3) == 1) has_ext_flag = 1;
        else has_ext_flag=0;
        ////printf("has extra flag=%d\n",has_ext_flag);
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
                    default: return 0;//printf("Unknown AES encryption key length (0x%02x) quitting...\n",buf[8]&255);return 0;
                }
                //printf("Encrypted using strong AES%d encryption\n",winzip_key_size);
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

    //printf("Found >= %d password-protected files in archive!\n",cur);
    numfiles=cur;

    if ((cur==0)&&(has_winzip_encryption==0))
    {
            //printf("File %s is not a password-protected ZIP archive\n", filename);
            return 2;
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

    return 1;
}




void main(int argc, char *argv[])
{
    int status;
    
    if (argc<2) {printf("Please provide a ZIP file\n");exit(1);}
    status=check_zip("",argv[1]);
    if (status==0)
    {
	printf("0\nNot a ZIP archive or file corrupted\n\n\n");
	exit(1);
    }
    if (status==2)
    {
	printf("0\nZIP archive is not password protected\n\n\n");
	exit(1);
    }
    if (has_winzip_encryption==1)
    {
	printf("1\nZIP archive with strong encryption\n%d\n\n",numfiles);
	exit(1);
    }
    if ((has_winzip_encryption==0)&&(numfiles>2))
    {
	printf("1\nZIP archive with old (2.x) encryption and >=%d files in archive\n%d\n\n",numfiles,numfiles);
	exit(1);
    }
    if ((has_winzip_encryption==0)&&(numfiles<3))
    {
	printf("1\nZIP archive with old (2.x) encryption and %d files in archive\n%d\n\n",numfiles,numfiles);
	exit(1);
    }


}