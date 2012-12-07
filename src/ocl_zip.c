/*
 * ocl_zip.c
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
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"


#define CHECK_BIT(var,pos) ((var) & (1<<(pos)))
#define kCrcPoly 0xEDB88320
#define CRC_UPDATE_BYTE(crc, b) (g_CrcTable[((crc) ^ (b)) & 0xFF] ^ ((crc) >> 8))

typedef struct 
{
    unsigned char op;           /* operation, extra bits, table bits */
    unsigned char bits;         /* bits in this part of the code */
    unsigned short val;         /* offset in table or code value */
} code;

static const code lenfix[512] = {
        {96,7,0},{0,8,80},{0,8,16},{20,8,115},{18,7,31},{0,8,112},{0,8,48},
        {0,9,192},{16,7,10},{0,8,96},{0,8,32},{0,9,160},{0,8,0},{0,8,128},
        {0,8,64},{0,9,224},{16,7,6},{0,8,88},{0,8,24},{0,9,144},{19,7,59},
        {0,8,120},{0,8,56},{0,9,208},{17,7,17},{0,8,104},{0,8,40},{0,9,176},
        {0,8,8},{0,8,136},{0,8,72},{0,9,240},{16,7,4},{0,8,84},{0,8,20},
        {21,8,227},{19,7,43},{0,8,116},{0,8,52},{0,9,200},{17,7,13},{0,8,100},
        {0,8,36},{0,9,168},{0,8,4},{0,8,132},{0,8,68},{0,9,232},{16,7,8},
        {0,8,92},{0,8,28},{0,9,152},{20,7,83},{0,8,124},{0,8,60},{0,9,216},
        {18,7,23},{0,8,108},{0,8,44},{0,9,184},{0,8,12},{0,8,140},{0,8,76},
        {0,9,248},{16,7,3},{0,8,82},{0,8,18},{21,8,163},{19,7,35},{0,8,114},
        {0,8,50},{0,9,196},{17,7,11},{0,8,98},{0,8,34},{0,9,164},{0,8,2},
        {0,8,130},{0,8,66},{0,9,228},{16,7,7},{0,8,90},{0,8,26},{0,9,148},
        {20,7,67},{0,8,122},{0,8,58},{0,9,212},{18,7,19},{0,8,106},{0,8,42},
        {0,9,180},{0,8,10},{0,8,138},{0,8,74},{0,9,244},{16,7,5},{0,8,86},
        {0,8,22},{64,8,0},{19,7,51},{0,8,118},{0,8,54},{0,9,204},{17,7,15},
        {0,8,102},{0,8,38},{0,9,172},{0,8,6},{0,8,134},{0,8,70},{0,9,236},
        {16,7,9},{0,8,94},{0,8,30},{0,9,156},{20,7,99},{0,8,126},{0,8,62},
        {0,9,220},{18,7,27},{0,8,110},{0,8,46},{0,9,188},{0,8,14},{0,8,142},
        {0,8,78},{0,9,252},{96,7,0},{0,8,81},{0,8,17},{21,8,131},{18,7,31},
        {0,8,113},{0,8,49},{0,9,194},{16,7,10},{0,8,97},{0,8,33},{0,9,162},
        {0,8,1},{0,8,129},{0,8,65},{0,9,226},{16,7,6},{0,8,89},{0,8,25},
        {0,9,146},{19,7,59},{0,8,121},{0,8,57},{0,9,210},{17,7,17},{0,8,105},
        {0,8,41},{0,9,178},{0,8,9},{0,8,137},{0,8,73},{0,9,242},{16,7,4},
        {0,8,85},{0,8,21},{16,8,258},{19,7,43},{0,8,117},{0,8,53},{0,9,202},
        {17,7,13},{0,8,101},{0,8,37},{0,9,170},{0,8,5},{0,8,133},{0,8,69},
        {0,9,234},{16,7,8},{0,8,93},{0,8,29},{0,9,154},{20,7,83},{0,8,125},
        {0,8,61},{0,9,218},{18,7,23},{0,8,109},{0,8,45},{0,9,186},{0,8,13},
        {0,8,141},{0,8,77},{0,9,250},{16,7,3},{0,8,83},{0,8,19},{21,8,195},
        {19,7,35},{0,8,115},{0,8,51},{0,9,198},{17,7,11},{0,8,99},{0,8,35},
        {0,9,166},{0,8,3},{0,8,131},{0,8,67},{0,9,230},{16,7,7},{0,8,91},
        {0,8,27},{0,9,150},{20,7,67},{0,8,123},{0,8,59},{0,9,214},{18,7,19},
        {0,8,107},{0,8,43},{0,9,182},{0,8,11},{0,8,139},{0,8,75},{0,9,246},
        {16,7,5},{0,8,87},{0,8,23},{64,8,0},{19,7,51},{0,8,119},{0,8,55},
        {0,9,206},{17,7,15},{0,8,103},{0,8,39},{0,9,174},{0,8,7},{0,8,135},
        {0,8,71},{0,9,238},{16,7,9},{0,8,95},{0,8,31},{0,9,158},{20,7,99},
        {0,8,127},{0,8,63},{0,9,222},{18,7,27},{0,8,111},{0,8,47},{0,9,190},
        {0,8,15},{0,8,143},{0,8,79},{0,9,254},{96,7,0},{0,8,80},{0,8,16},
        {20,8,115},{18,7,31},{0,8,112},{0,8,48},{0,9,193},{16,7,10},{0,8,96},
        {0,8,32},{0,9,161},{0,8,0},{0,8,128},{0,8,64},{0,9,225},{16,7,6},
        {0,8,88},{0,8,24},{0,9,145},{19,7,59},{0,8,120},{0,8,56},{0,9,209},
        {17,7,17},{0,8,104},{0,8,40},{0,9,177},{0,8,8},{0,8,136},{0,8,72},
        {0,9,241},{16,7,4},{0,8,84},{0,8,20},{21,8,227},{19,7,43},{0,8,116},
        {0,8,52},{0,9,201},{17,7,13},{0,8,100},{0,8,36},{0,9,169},{0,8,4},
        {0,8,132},{0,8,68},{0,9,233},{16,7,8},{0,8,92},{0,8,28},{0,9,153},
        {20,7,83},{0,8,124},{0,8,60},{0,9,217},{18,7,23},{0,8,108},{0,8,44},
        {0,9,185},{0,8,12},{0,8,140},{0,8,76},{0,9,249},{16,7,3},{0,8,82},
        {0,8,18},{21,8,163},{19,7,35},{0,8,114},{0,8,50},{0,9,197},{17,7,11},
        {0,8,98},{0,8,34},{0,9,165},{0,8,2},{0,8,130},{0,8,66},{0,9,229},
        {16,7,7},{0,8,90},{0,8,26},{0,9,149},{20,7,67},{0,8,122},{0,8,58},
        {0,9,213},{18,7,19},{0,8,106},{0,8,42},{0,9,181},{0,8,10},{0,8,138},
        {0,8,74},{0,9,245},{16,7,5},{0,8,86},{0,8,22},{64,8,0},{19,7,51},
        {0,8,118},{0,8,54},{0,9,205},{17,7,15},{0,8,102},{0,8,38},{0,9,173},
        {0,8,6},{0,8,134},{0,8,70},{0,9,237},{16,7,9},{0,8,94},{0,8,30},
        {0,9,157},{20,7,99},{0,8,126},{0,8,62},{0,9,221},{18,7,27},{0,8,110},
        {0,8,46},{0,9,189},{0,8,14},{0,8,142},{0,8,78},{0,9,253},{96,7,0},
        {0,8,81},{0,8,17},{21,8,131},{18,7,31},{0,8,113},{0,8,49},{0,9,195},
        {16,7,10},{0,8,97},{0,8,33},{0,9,163},{0,8,1},{0,8,129},{0,8,65},
        {0,9,227},{16,7,6},{0,8,89},{0,8,25},{0,9,147},{19,7,59},{0,8,121},
        {0,8,57},{0,9,211},{17,7,17},{0,8,105},{0,8,41},{0,9,179},{0,8,9},
        {0,8,137},{0,8,73},{0,9,243},{16,7,4},{0,8,85},{0,8,21},{16,8,258},
        {19,7,43},{0,8,117},{0,8,53},{0,9,203},{17,7,13},{0,8,101},{0,8,37},
        {0,9,171},{0,8,5},{0,8,133},{0,8,69},{0,9,235},{16,7,8},{0,8,93},
        {0,8,29},{0,9,155},{20,7,83},{0,8,125},{0,8,61},{0,9,219},{18,7,23},
        {0,8,109},{0,8,45},{0,9,187},{0,8,13},{0,8,141},{0,8,77},{0,9,251},
        {16,7,3},{0,8,83},{0,8,19},{21,8,195},{19,7,35},{0,8,115},{0,8,51},
        {0,9,199},{17,7,11},{0,8,99},{0,8,35},{0,9,167},{0,8,3},{0,8,131},
        {0,8,67},{0,9,231},{16,7,7},{0,8,91},{0,8,27},{0,9,151},{20,7,67},
        {0,8,123},{0,8,59},{0,9,215},{18,7,19},{0,8,107},{0,8,43},{0,9,183},
        {0,8,11},{0,8,139},{0,8,75},{0,9,247},{16,7,5},{0,8,87},{0,8,23},
        {64,8,0},{19,7,51},{0,8,119},{0,8,55},{0,9,207},{17,7,15},{0,8,103},
        {0,8,39},{0,9,175},{0,8,7},{0,8,135},{0,8,71},{0,9,239},{16,7,9},
        {0,8,95},{0,8,31},{0,9,159},{20,7,99},{0,8,127},{0,8,63},{0,9,223},
        {18,7,27},{0,8,111},{0,8,47},{0,9,191},{0,8,15},{0,8,143},{0,8,79},
        {0,9,255}
};

static const code distfix[32] = {
        {16,5,1},{23,5,257},{19,5,17},{27,5,4097},{17,5,5},{25,5,1025},
        {21,5,65},{29,5,16385},{16,5,3},{24,5,513},{20,5,33},{28,5,8193},
        {18,5,9},{26,5,2049},{22,5,129},{64,5,0},{16,5,2},{23,5,385},
        {19,5,25},{27,5,6145},{17,5,7},{25,5,1537},{21,5,97},{29,5,24577},
        {16,5,4},{24,5,769},{20,5,49},{28,5,12289},{18,5,13},{26,5,3073},
        {22,5,193},{64,5,0}
};


static char myfilename[255];
static unsigned int g_CrcTable[256];
static unsigned char winzip_salt[16];
static int has_winzip_encryption = 0;
static int has_ext_flag = 0;
static int winzip_key_size = 0;
static int winzip_salt_size;
static unsigned char winzip_check[2];
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


static hash_stat load_zip(char *filename)
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
        elog("Cannot open file %s\n", filename);
        return hash_err;
    }
    read(fd, &u321, 4);
    fileoffset+=4;
    if (u321 != 0x04034b50)
    {
        elog("Not a ZIP file: %s!\n", filename);
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
            //encrypted=0;
        }
        else 
        {
            parsed=1;
            //encrypted=1;
            if (has_winzip_encryption == 1) 
            {
                switch (buf[8]&255)
                {
                    case 1: winzip_key_size = 128;winzip_salt_size = 8;break;
                    case 2: winzip_key_size = 192;winzip_salt_size = 12;break;
                    case 3: winzip_key_size = 256;winzip_salt_size = 16;break;
                    default: elog("Unknown AES encryption key length (0x%02x) quitting...\n",buf[8]&255);return hash_err;
                }
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


    if ((cur==0)&&(has_winzip_encryption==0))
    {
            elog("File %s is not a password-protected ZIP archive\n", filename);
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
    return hash_ok;
}


static hash_stat precheck_zip(unsigned int k0,unsigned int k1,unsigned int k2)
{
    unsigned int bits,hold,thisget,have,i,ret;
    int left=0;
    unsigned int ncode,ncount[2];
    unsigned char *count;
    unsigned char *in=alloca(256);
    unsigned long temp;
    unsigned char c,temp1;
    unsigned int key0=k0,key1=k1,key2=k2;
    unsigned int whave = 0, op,len;
    code here;
    
    memcpy(in,zipbuf,255);
    for (ret = 0; ret < 255;ret++)
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

    hold = *((unsigned int *)&in[0]);
    in+=1;
    hold>>=1;

    if ((hold&3)==2) 
    {
        hold>>=2;
        in+=2;
        count = (unsigned char*)ncount;
        if (257+(hold&0x1F) > 286) return hash_err;
        hold >>= 5;
        if(1+(hold&0x1F) > 30) return hash_err;
        hold >>= 5;
        ncode = 4+(hold&0xF);
        hold >>= 4;
        hold += ((unsigned int)(*++in)) << 15;
        hold += ((unsigned int)(*++in)) << 23;
        bits = 31;
        have = 0;
        ncount[0] = ncount[1] = 0;
        for (;;) 
        {
            if (have+7>ncode) thisget = ncode-have;
            else thisget = 7;
            have += thisget;
            bits -= thisget*3;
            while (thisget--) 
            {
                ++count[hold&7];
                hold>>=3;
            }
            if (have == ncode) break;
            hold += ((unsigned int)(*++in)) << bits;
            bits += 8;
            hold += ((unsigned int)(*++in)) << bits;
            bits += 8;
        }
        count[0] = 0;
        if (!ncount[0] && !ncount[1]) return hash_err;
        left = 1;
        for (i = 1; i <= 7; ++i) 
        {
            left <<= 1;
            left -= count[i];
            if (left < 0) return hash_err;
        }
        if (left > 0) return hash_err;
    }
    else if ((hold&3)==1) 
    {
        hold>>=2;
        in+=2;
        bits = 32-3;
        for (;;) 
        {
            if (bits < 15) 
            {
                if (left < 2) return hash_ok;
                left -= 2;
                hold += (unsigned int)(*++in) << bits;
                bits += 8;
                hold += (unsigned int)(*++in) << bits;
                bits += 8;
            }
            here=lenfix[hold & 0x1FF];
            op = (unsigned)(here.bits);
            hold >>= op;
            bits -= op;
            op = (unsigned)(here.op);
            if (op == 0)
            ++whave;
            else if (op & 16) 
            {
                len = (unsigned)(here.val);
                op &= 15;
                if (op) 
                {
                    if (bits < op) 
                    {
                        if (!left) return hash_ok;
                        --left;
                        hold += (unsigned int)(*++in) << bits;
                        bits += 8;
                    }
                    len += (unsigned)hold & ((1U << op) - 1);
                    hold >>= op;
                    bits -= op;
                }
                if (bits < 15) 
                {
                    if (left < 2)
                    return hash_ok;
                    left -= 2;
                    hold += (unsigned int)(*++in) << bits;
                    bits += 8;
                    hold += (unsigned int)(*++in) << bits;
                    bits += 8;
                }
                here = distfix[hold & 0x1F];
                dodist:
                 op = (unsigned)(here.bits);
                 hold >>= op;
                 bits -= op;
                 op = (unsigned)(here.op);
                 if (op & 16) 
                 {
                    unsigned int dist = (unsigned)(here.val);
                    op &= 15;
                    if (bits < op) 
                    {
                        if (!left) return hash_ok;
                        --left;
                        hold += (unsigned int)(*++in) << bits;
                        bits += 8;
                        if (bits < op) 
                        {
                            if (!left) return hash_ok;
                            --left;
                            hold += (unsigned int)(*++in) << bits;
                            bits += 8;
                        }
                    }
                    dist += (unsigned)hold & ((1U << op) - 1);
                    if (dist > whave) return hash_err;
                    hold >>= op;
                    bits -= op;
                    whave += len;
                }
                else if ((op & 64) == 0) 
                {
                    here = distfix[here.val + (hold & ((1U << op) - 1))];
                    goto dodist;
                }
                else return hash_err;
            }
            else 
            {
                return hash_err;
            }
        }
    }
    else return hash_err;
    return hash_ok;
}


static hash_stat check_zip(const char *password,unsigned int key0,unsigned int key1,unsigned int key2,unsigned  int nzl)
{
    unsigned char key[68];
    unsigned char check[2];
    int fd;
    int ret, bsize, rsize, usize;
    unsigned char in[1024*16+100];
    unsigned char out[1024*16*10+100];
    unsigned char authcode[10];
    unsigned char authresult[10];
    int iter=0;


    if (attack_over>0) return hash_err;
    if (has_winzip_encryption==1) 
    {
        hash_proto_pbkdf2(password, winzip_salt, winzip_salt_size, 1000, 2*(winzip_key_size/8)+2, key);
        check[0] = key[2*(winzip_key_size/8)];
        check[1] = key[2*(winzip_key_size/8)+1];

        // As mentioned in WinZIP documentation, this gives out 1/65535 error probability. Calculate auth codes 
        if (memcmp(winzip_check, check, 2)!=0) return hash_err;
        //memcpy(&key[winzip_key_size/8],password,winzip_key_size/8);
        {
            fd = open(myfilename, O_RDONLY);
            lseek(fd, fileoffset + comprsize - 10, SEEK_SET);
            read(fd, authcode, 10);
            hash_proto_hmac_sha1_file((unsigned char *)&key[winzip_key_size/8], winzip_key_size/8, myfilename, fileoffset+winzip_salt_size+2, comprsize-12-winzip_salt_size, (unsigned char *)&authresult, 10);
            if (memcmp((char *)&authresult[4], (char *)&authcode[4], 6)==0)
            {
                close(fd);
                return hash_ok;
            }
            else
            {
                close(fd);
                return hash_err;
            }
        }
    }
    else
    {
        unsigned char temp1;
        unsigned char c;
        unsigned  long temp;

        {
            if (precheck_zip(key0,key1,key2)==hash_err) return hash_err;
            fd = open(myfilename,O_RDONLY);
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
                if (iter>0)
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
                }
                else
                {
                    bsize = 1024*16;
                    memcpy(in,zipbuf,1024*16);
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
                    rsize += (strm.total_in - usize);
                }
                iter++;

                if (ret == Z_DATA_ERROR) 
                {
                    close(fd);
                    inflateEnd(&strm);
                    return hash_err;
                }
                if (ret == Z_NEED_DICT) 
                {

                    close(fd);
                    inflateEnd(&strm);
                    return hash_err;
                }
                if (ret == Z_STREAM_ERROR) 
                {
                    close(fd);
                    inflateEnd(&strm);
                    return hash_err;
                }

                if  ((ret == Z_MEM_ERROR))
                {
                    close(fd);
                    inflateEnd(&strm);
                    return hash_err;
                }
                if (ret == Z_STREAM_END) rsize = comprsize+1;
                if (iter==1)
                {
                    close(fd);
                    fd = open(myfilename,O_RDONLY);
                    lseek(fd, fileoffset + strm.total_in,SEEK_SET);
                }
            }
            if (ucomprsize==strm.total_out)
            {
                inflateEnd(&strm);
                close(fd);
                return hash_ok;
            }

            else
            {
                inflateEnd(&strm);
                close(fd);
                return hash_err;
            }
        close(fd);
        }
    }
    return hash_err;
}


static cl_uint16 zip_getsalt(int len)
{
    cl_uint16 t;
    
    t.s0=(zip_normbuf[0][0])|(zip_normbuf[0][1]<<8)|(zip_normbuf[0][2]<<16)|(zip_normbuf[0][3]<<24);
    t.s1=(zip_normbuf[0][4])|(zip_normbuf[0][5]<<8)|(zip_normbuf[0][6]<<16)|(zip_normbuf[0][7]<<24);
    t.s2=(zip_normbuf[0][8])|(zip_normbuf[0][9]<<8)|(zip_normbuf[0][10]<<16)|(zip_normbuf[0][11]<<24);
    t.s3=(zip_normbuf[1][0])|(zip_normbuf[1][1]<<8)|(zip_normbuf[1][2]<<16)|(zip_normbuf[1][3]<<24);
    t.s4=(zip_normbuf[1][4])|(zip_normbuf[1][5]<<8)|(zip_normbuf[1][6]<<16)|(zip_normbuf[1][7]<<24);
    t.s5=(zip_normbuf[1][8])|(zip_normbuf[1][9]<<8)|(zip_normbuf[1][10]<<16)|(zip_normbuf[1][11]<<24);
    t.s6=(zip_normbuf[2][0])|(zip_normbuf[2][1]<<8)|(zip_normbuf[2][2]<<16)|(zip_normbuf[2][3]<<24);
    t.s7=(zip_normbuf[2][4])|(zip_normbuf[2][5]<<8)|(zip_normbuf[2][6]<<16)|(zip_normbuf[2][7]<<24);
    t.s8=(zip_normbuf[2][8])|(zip_normbuf[2][9]<<8)|(zip_normbuf[2][10]<<16)|(zip_normbuf[2][11]<<24);
    t.s9=(verifiers[0])&255;
    t.sA=(verifiers[1])&255;
    t.sB=(verifiers[2])&255;
    t.sE=cur;
    t.sF=len;

    return t;
}

static cl_uint4 zip_getsalt2(int len)
{
    cl_uint4 t;
    
    t.s0=(zip_normbuf[3][0])|(zip_normbuf[3][1]<<8)|(zip_normbuf[3][2]<<16)|(zip_normbuf[3][3]<<24);
    t.s1=(zip_normbuf[3][4])|(zip_normbuf[3][5]<<8)|(zip_normbuf[3][6]<<16)|(zip_normbuf[3][7]<<24);
    t.s2=(zip_normbuf[3][8])|(zip_normbuf[3][9]<<8)|(zip_normbuf[3][10]<<16)|(zip_normbuf[3][11]<<24);
    t.s3=(verifiers[3])&255;

    return t;
}


static cl_uint16 zip_getsalt128()
{
    cl_uint16 t;
    int len;
    unsigned char salt2[32];

    if (winzip_key_size==256)
    {
        bzero(salt2,32);
        memcpy(salt2,winzip_salt,16);
        len=16;
        salt2[len]=0;
        salt2[len+1]=0;
        salt2[len+2]=0;
        salt2[len+3]=4;
        salt2[len+4]=0x80;

        t.s0=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
        t.s1=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
        t.s2=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
        t.s3=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
        t.s4=(salt2[16]&255)|((salt2[17]&255)<<8)|((salt2[18]&255)<<16)|((salt2[19]&255)<<24);
        t.s5=(salt2[20]&255)|((salt2[21]&255)<<8)|((salt2[22]&255)<<16)|((salt2[23]&255)<<24);
        t.s6=((16)+64+4)<<3;
        t.sF=(winzip_check[0])|(winzip_check[1]<<8);
        return t;
    }

    bzero(salt2,32);
    memcpy(salt2,winzip_salt,8);
    len=8;
    salt2[len]=0;
    salt2[len+1]=0;
    salt2[len+2]=0;
    salt2[len+3]=2;
    salt2[len+4]=0x80;

    t.s5=(salt2[0]&255)|((salt2[1]&255)<<8)|((salt2[2]&255)<<16)|((salt2[3]&255)<<24);
    t.s6=(salt2[4]&255)|((salt2[5]&255)<<8)|((salt2[6]&255)<<16)|((salt2[7]&255)<<24);
    t.s7=(salt2[8]&255)|((salt2[9]&255)<<8)|((salt2[10]&255)<<16)|((salt2[11]&255)<<24);
    t.s8=(salt2[12]&255)|((salt2[13]&255)<<8)|((salt2[14]&255)<<16)|((salt2[15]&255)<<24);
    t.s9=((8)+64+4)<<3;
    t.sF=(winzip_check[0])|(winzip_check[1]<<8);

    return t;
}




static void ocl_set_params(int loopnr, cl_uint4 param1, cl_uint4 param2,cl_uint16 param3,cl_uint16 *p1, cl_uint16 *p2, cl_uint16 *p3, cl_uint16 *p4, cl_uint16 *p5)
{
    p5->s0=param3.s0;
    p5->s1=param3.s1;
    p5->s2=param3.s2;
    p5->s3=param3.s3;
    p5->s4=param3.s4;
    p5->s5=param3.s5;
    p5->s6=param3.s6;
    p5->s7=param3.s7;
    p5->s8=param3.s8;
    p5->s9=param3.s9;
    p5->sA=param3.sA;
    p5->sB=param3.sB;
    p5->sC=param3.sC;
    p5->sD=param3.sD;
    p5->sE=param3.sE;
    p5->sF=param3.sF;

    switch (loopnr)
    {
	case 0:
	    p1->s0=param1.s0;
	    p1->s1=param1.s1;
	    p1->s2=param1.s2;
	    p1->s3=param1.s3;
	    p2->s0=param2.s0;
	    p2->s1=param2.s1;
	    p2->s2=param2.s2;
	    p2->s3=param2.s3;
	    break;
	case 1:
	    p1->s4=param1.s0;
	    p1->s5=param1.s1;
	    p1->s6=param1.s2;
	    p1->s7=param1.s3;
	    p2->s4=param2.s0;
	    p2->s5=param2.s1;
	    p2->s6=param2.s2;
	    p2->s7=param2.s3;
	    break;
	case 2:
	    p1->s8=param1.s0;
	    p1->s9=param1.s1;
	    p1->sA=param1.s2;
	    p1->sB=param1.s3;
	    p2->s8=param2.s0;
	    p2->s9=param2.s1;
	    p2->sA=param2.s2;
	    p2->sB=param2.s3;
	    break;
	case 3:
	    p1->sC=param1.s0;
	    p1->sD=param1.s1;
	    p1->sE=param1.s2;
	    p1->sF=param1.s3;
	    p2->sC=param2.s0;
	    p2->sD=param2.s1;
	    p2->sE=param2.s2;
	    p2->sF=param2.s3;
	    break;
	case 4:
	    p3->s0=param1.s0;
	    p3->s1=param1.s1;
	    p3->s2=param1.s2;
	    p3->s3=param1.s3;
	    p4->s0=param2.s0;
	    p4->s1=param2.s1;
	    p4->s2=param2.s2;
	    p4->s3=param2.s3;
	    break;
	case 5:
	    p3->s4=param1.s0;
	    p3->s5=param1.s1;
	    p3->s6=param1.s2;
	    p3->s7=param1.s3;
	    p4->s4=param2.s0;
	    p4->s5=param2.s1;
	    p4->s6=param2.s2;
	    p4->s7=param2.s3;
	    break;
	case 6:
	    p3->s8=param1.s0;
	    p3->s9=param1.s1;
	    p3->sA=param1.s2;
	    p3->sB=param1.s3;
	    p4->s8=param2.s0;
	    p4->s9=param2.s1;
	    p4->sA=param2.s2;
	    p4->sB=param2.s3;
	    break;
	case 7:
	    p3->sC=param1.s0;
	    p3->sD=param1.s1;
	    p3->sE=param1.s2;
	    p3->sF=param1.s3;
	    p4->sC=param2.s0;
	    p4->sD=param2.s1;
	    p4->sE=param2.s2;
	    p4->sF=param2.s3;
	    break;

    }
}




static void ocl_get_cracked(cl_command_queue queuein,cl_mem plains_buf, char *plains, cl_mem hashes_buf, char *hashes, int numfound, int vsize, int hashlen)
{
    int a,b=0;
    char plain[16];

    if (numfound>MAXFOUND*16) 
    {
	printf("error found=%d\n",numfound);
	return;
    }

    _clEnqueueReadBuffer(queuein, plains_buf, CL_TRUE, 0, 16*numfound*vsize, plains, 0, NULL, NULL);
    _clEnqueueReadBuffer(queuein, hashes_buf, CL_TRUE, 0, hashlen*numfound*vsize, hashes, 0, NULL, NULL);

    for (a=0;a<numfound;a++)
    for (b=0;b<vsize;b++)
    if (
        ((hashes[(a*vsize+b)*hashlen+12]&255)==1)&&
        ((hashes[(a*vsize+b)*hashlen+13]&255)==0)&&
        ((hashes[(a*vsize+b)*hashlen+14]&255)==0)&&
        ((hashes[(a*vsize+b)*hashlen+15]&255)==0))
    {
        unsigned int k1,k2,k3,k4;
        char *outf;
        outf = (char *)hashes+(a*vsize+b)*hashlen;
        memcpy(&k1,outf,4);
        memcpy(&k2,outf+4,4);
        memcpy(&k3,outf+8,4);
        memcpy(&k4,outf+12,4);
        memcpy(plain,&plains[0]+(a*vsize+b)*hashlen,16);
        plain[strlen(plain)-1] = 0;
        if (strlen(plain)>0)
        if (hash_ok==check_zip("",k1,k2,k3,k4))
        {
            if (!cracked_list) add_cracked_list(myfilename, "ZIP file    " , "123", plain);
        }
    }
}



static void markov_sched_setlimits()
{
    int a,b,c;
    int e1,e2,e3,etemp,charset_size=strlen(markov_charset);\

    e1=e2=e3=0;
    if (fast_markov == 1)
    {
	charset_size = charset_size - 23;
	if (session_restore_flag==0) markov_threshold = (markov_threshold*3)/2;
    }
    reduced_size=0;
    for (a=0;a<charset_size;a++) if (markov0[a]>markov_threshold)
    {
	reduced_charset[reduced_size]=markov_charset[a];
	// Create markov2 table
	for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
	reduced_size++;
	reduced_charset[reduced_size]=0;
    }

    if (session_restore_flag==0)
    {
	scheduler.markov_l1 = reduced_size;
	for (a=0;a<reduced_size;a++)
	{
	    etemp = 0;
	    for (b=0;b<strlen(markov_charset);b++)
	    if (markov2[a][b]>markov_threshold) etemp++;

	    if (etemp>0)
	    {
		e1=a;
		e2=etemp;
	    }
	    scheduler.ebitmap2[a]=etemp;
	}
	scheduler.markov_l2_1 = e1;
	scheduler.markov_l2_2 = e2;

	for (a=0;a<reduced_size;a++)
	for (b=0;b<strlen(markov_charset);b++)
	if (markov2[a][b]>markov_threshold)
	{
	    etemp = 0;
	    for (c=0;c<strlen(markov_charset);c++)
	    if (markov1[b][c]>markov_threshold) etemp++;

	    if (etemp>0)
	    {
		e1=a;
		e2=b;
		e3=etemp;
	    }
	    scheduler.ebitmap3[a][b]=etemp;
	}
	else scheduler.ebitmap3[a][b]=0;
	scheduler.markov_l3_1 = e1;
	scheduler.markov_l3_2 = e2;
	scheduler.markov_l3_3 = e3;
    }
}



/* Markov initializer */
static void init_markov()
{
    int a,b,charset_size;

    charset_size = strlen(markov_charset);
    table = malloc(charset_size*charset_size*charset_size*4);
    if (fast_markov == 1)
    {
	charset_size = charset_size - 23;
	if (session_restore_flag==0) markov_threshold = (markov_threshold*3)/2;
    }
    reduced_size=0;
    for (a=0;a<charset_size;a++) if (markov0[a]>markov_threshold)
    {
	reduced_charset[reduced_size]=markov_charset[a];
	// Create markov2 table
	for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
	reduced_size++;
	reduced_charset[reduced_size]=0;
    }

    for (a=0;a<strlen(markov_charset);a++)
    for (b=0;b<strlen(markov_charset);b++)
    {
	table[a*strlen(markov_charset)+b] = (markov_charset[a]<<8)|(markov_charset[b]);
    }
}

/* Markov deinit */
static void deinit_markov()
{
    free(table);
}


/* Bruteforce initializer big charsets */
static void init_bruteforce_long()
{
    int a,b;

    table = malloc(128*128*4);

    for (a=0;a<strlen(bruteforce_charset);a++)
    for (b=0;b<strlen(bruteforce_charset);b++)
    {
	table[a*strlen(bruteforce_charset)+b] = (bruteforce_charset[a]<<8)|(bruteforce_charset[b]);
    }
}


/* Bruteforce deinit */
static void deinit_bruteforce()
{
    free(table);
}




/* Execute kernel, flush parameters */
static void ocl_execute(cl_command_queue queue, cl_kernel kernel, size_t *global_work_size, size_t *local_work_size, int charset_size, cl_mem found_buf, cl_mem hashes_buf, cl_mem plains_buf, char *plains, char * hashes,int self, cl_uint16 *p1,cl_uint16 *p2,cl_uint16 *p3,cl_uint16 *p4,cl_uint16 *p5)
{
    int err;
    int *found;
    int try;
    size_t lglobal_work_size[3];
    size_t offset[3];
    _clSetKernelArg(kernel, 5, sizeof(cl_uint16), (void*) p1);
    _clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) p2);
    _clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) p3);
    _clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) p4);
    _clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) p5);

    if ((interactive_mode==1)||(cur<2))
    {
	for (try=0;try<8;try++)
	{
	    lglobal_work_size[0]=global_work_size[0];
	    lglobal_work_size[1]=(global_work_size[1]+7)/8;
	    offset[1] = try*lglobal_work_size[1];
	    offset[0] = 0;

	    _clEnqueueNDRangeKernel(queue, kernel, 2, offset, lglobal_work_size, local_work_size, 0, NULL, NULL);
	    found = _clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	    if (*found>0) 
	    {
    		ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len);
    		bzero(plains,16*8*MAXFOUND*16);
    		_clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND*16, plains, 0, NULL, NULL);
    		// Change for other types
    		bzero(hashes,hash_ret_len*8*MAXFOUND*16);
    		_clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len*8*MAXFOUND*16, hashes, 0, NULL, NULL);
    		*found = 0;
    		_clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
	    }
    	    _clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
	}
    }
    else
    {
	_clEnqueueNDRangeKernel(queue, kernel, 2, NULL, global_work_size, local_work_size, 0, NULL, NULL);
	found = _clEnqueueMapBuffer(queue, found_buf, CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
	if (*found>0) 
	{
    	    ocl_get_cracked(queue,plains_buf,plains, hashes_buf,hashes, *found, wthreads[self].vectorsize, hash_ret_len);
    	    bzero(plains,16*8*MAXFOUND*16);
    	    _clEnqueueWriteBuffer(queue, plains_buf, CL_FALSE, 0, 16*8*MAXFOUND*16, plains, 0, NULL, NULL);
    	    // Change for other types
    	    bzero(hashes,hash_ret_len*8*MAXFOUND*16);
    	    _clEnqueueWriteBuffer(queue, hashes_buf, CL_FALSE, 0, hash_ret_len*8*MAXFOUND*16, hashes, 0, NULL, NULL);
    	    *found = 0;
    	    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, found, 0, NULL, NULL);
	}
    	_clEnqueueUnmapMemObject(queue,found_buf,(void *)found,0,NULL,NULL);
    }
    wthreads[self].tries += charset_size*charset_size*charset_size*charset_size*wthreads[self].loops;
    attack_current_count += wthreads[self].loops;
}






/* Bruteforce larger charsets */
void* ocl_bruteforce_zip_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    int try=0;
    char *hashes;
    int charset_size = (int)strlen(bruteforce_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 p1;
    cl_uint16 p2;
    cl_uint16 p3;
    cl_uint16 p4;
    cl_uint16 p5;
    cl_uint16 salt;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "zip_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "zip_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );


    singlehash=zip_getsalt2(4);

    // Change for other lens
    hashes  = malloc(hash_ret_len*8*MAXFOUND*16); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len*8*MAXFOUND*16, NULL, &err );
    plains=malloc(16*8*MAXFOUND*16);
    bzero(plains,16*8*MAXFOUND*16);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND*16, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND*16, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,16*8*MAXFOUND*16);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len*8*MAXFOUND*16, hashes, 0, NULL, NULL);


    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    table_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 128*128*4,table , &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);


    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    _clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &found_buf);
    _clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (charset_size*charset_size);
    global_work_size[1] = (charset_size*charset_size);
    while ((global_work_size[0] % local_work_size[0])!=0) global_work_size[0]++;
    while ((global_work_size[1] % (wthreads[self].vectorsize))!=0) global_work_size[1]++;
    global_work_size[1] = global_work_size[1]/wthreads[self].vectorsize;
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 


    /* Bruteforce, len=4 */

    csize=4<<3;
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (attack_over!=0) goto out;
    image.x=0;image.y=0x80;image.z=0;image.w=0;
    salt = zip_getsalt(4);
    singlehash=zip_getsalt2(4);
    ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

    _clSetKernelArg(kernel, 5, sizeof(cl_uint16), (void*) &p1);
    _clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p2);
    _clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p3);
    _clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p4);
    _clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p5);

    try=0;
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
    if (bruteforce_end==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* bruteforce, len=5 */

    csize=5<<3;
    sched_wait(5);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    if (bruteforce_end>=5)
    while ((sched_len()==5)&&((a1=sched_s1())<sched_e1()))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;
    	image.x=0;
        image.y=bruteforce_charset[a1]|(0x80<<8);
        image.z=0;image.w=0;
	salt = zip_getsalt(5);
	singlehash=zip_getsalt2(5);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=6 */
    csize=6<<3;
    sched_wait(6);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    if (bruteforce_end>=6)
    for (a1=0;a1<charset_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(0x80<<16);
    	image.z=0;image.w=0;
	salt = zip_getsalt(6);
	singlehash=zip_getsalt2(6);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=7 */

    csize=7<<3;
    sched_wait(7);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    if (bruteforce_end>=7)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(0x80<<24);
    	image.z=0;image.w=0;
	salt = zip_getsalt(7);
	singlehash=zip_getsalt2(7);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);



    /* bruteforce, len=8 */

    csize=8<<3;
    sched_wait(8);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    if (bruteforce_end>=8)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=0x80;
    	image.w=0;
	salt = zip_getsalt(8);
	singlehash=zip_getsalt2(8);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=9 */
    csize=9<<3;
    sched_wait(9);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    if (bruteforce_end>=9)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(0x80<<8);
    	image.w=0;
	salt = zip_getsalt(9);
	singlehash=zip_getsalt2(9);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=10 */

    csize=10<<3;
    sched_wait(10);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    if (bruteforce_end>=10)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(0x80<<16);
    	image.w=0;
	salt = zip_getsalt(10);
	singlehash=zip_getsalt2(10);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=11 */

    csize=11<<3;
    sched_wait(11);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    if (bruteforce_end>=11)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(0x80<<24);
    	image.w=0;
	salt = zip_getsalt(11);
	singlehash=zip_getsalt2(11);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=12 */

    csize=12<<3;
    sched_wait(12);
    if (sched_len()==12)
    if (bruteforce_end>=12)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
    	image.w=0x80;
	salt = zip_getsalt(12);
	singlehash=zip_getsalt2(12);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);

    /* bruteforce, len=13 */

    csize=13<<3;
    sched_wait(13);
    if (sched_len()==13)
    if (bruteforce_end>=13)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==13)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
    	image.w=(bruteforce_charset[a9])|(0x80<<8);
	salt = zip_getsalt(13);
	singlehash=zip_getsalt2(13);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=14 */

    csize=14<<3;
    sched_wait(14);
    if (sched_len()==14)
    if (bruteforce_end>=14)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==13)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    for (a10=0;a10<charset_size;a10++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
    	image.w=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(0x80<<16);
	salt = zip_getsalt(14);
	singlehash=zip_getsalt2(14);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* bruteforce, len=15 */

    csize=15<<3;
    sched_wait(15);
    if (sched_len()==15)
    if (bruteforce_end>=15)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==15)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++) 
    for (a5=0;a5<charset_size;a5++) 
    for (a6=0;a6<charset_size;a6++) 
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++) 
    for (a9=0;a9<charset_size;a9++) 
    for (a10=0;a10<charset_size;a10++) 
    for (a11=0;a11<charset_size;a11++) 
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=bruteforce_charset[a1]|(bruteforce_charset[a2]<<8)|(bruteforce_charset[a3]<<16)|(bruteforce_charset[a4]<<24);
    	image.z=(bruteforce_charset[a5])|(bruteforce_charset[a6]<<8)|(bruteforce_charset[a7]<<16)|(bruteforce_charset[a8]<<24);
    	image.w=(bruteforce_charset[a9])|(bruteforce_charset[a10]<<8)|(bruteforce_charset[a11]<<16)|(0x80<<24);
	salt = zip_getsalt(15);
	singlehash=zip_getsalt2(15);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    out:
    free(hashes);
    free(plains);
    return hash_ok;
}





void* ocl_markov_zip_thread(void *arg)
{
    int err;
    cl_command_queue queue;
    cl_mem hashes_buf;
    size_t global_work_size[3];
    cl_uint4 image;
    int self;
    cl_kernel kernel;
    int a1,a2,a3,a4,a5,a6,a7,a8;
    int try=0;
    char *hashes;
    int charset_size = (int)strlen(markov_charset);
    cl_mem plains_buf;
    char *plains;
    int found;
    cl_mem found_buf;
    cl_uint csize;
    cl_mem table_buf;
    cl_uint16 p1;
    cl_uint16 p2;
    cl_uint16 p3;
    cl_uint16 p4;
    cl_uint16 p5;
    cl_uint16 salt;
    cl_uint4 singlehash;
    size_t nvidia_local_work_size[3]={64,1,0};
    size_t amd_local_work_size[3]={64,1,0};
    size_t *local_work_size;

    /* Lock and load! */
    pthread_mutex_lock(&biglock);
    memcpy(&self,arg,sizeof(int));

    /* Setup local work size */
    if (wthreads[self].type==nv_thread) local_work_size = nvidia_local_work_size;
    else local_work_size = amd_local_work_size;

    /* Init kernels */
    if (ocl_gpu_double) kernel = _clCreateKernel(program[self], "zip_long_double", &err );
    else  kernel = _clCreateKernel(program[self], "zip_long_normal", &err );

    /* Create queue */
    queue = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );


    // Change for other lens
    hashes  = malloc(hash_ret_len*8*MAXFOUND*16); 
    hashes_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, hash_ret_len*8*MAXFOUND*16, NULL, &err );
    plains=malloc(16*8*MAXFOUND*16);
    bzero(plains,16*8*MAXFOUND*16);
    plains_buf = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 16*8*MAXFOUND*16, NULL, &err );
    _clEnqueueWriteBuffer(queue, plains_buf, CL_TRUE, 0, 16*8*MAXFOUND*16, plains, 0, NULL, NULL);
    // Change for other types
    bzero(hashes,hash_ret_len*8*MAXFOUND*16);
    _clEnqueueWriteBuffer(queue, hashes_buf, CL_TRUE, 0, hash_ret_len*8*MAXFOUND*16, hashes, 0, NULL, NULL);
    found_buf = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, 4, NULL, &err );
    table_buf = _clCreateBuffer(context[self], CL_MEM_READ_ONLY|CL_MEM_USE_HOST_PTR, 128*128*4,table , &err );
    found = 0;
    _clEnqueueWriteBuffer(queue, found_buf, CL_TRUE, 0, 4, &found, 0, NULL, NULL);

    _clSetKernelArg(kernel, 0, sizeof(cl_mem), (void*) &hashes_buf);
    _clSetKernelArg(kernel, 1, sizeof(cl_uint), (void*) &csize);
    _clSetKernelArg(kernel, 2, sizeof(cl_mem), (void*) &plains_buf);
    _clSetKernelArg(kernel, 3, sizeof(cl_mem), (void*) &found_buf);
    _clSetKernelArg(kernel, 4, sizeof(cl_mem), (void*) &table_buf);


    global_work_size[0] = (charset_size*charset_size);
    global_work_size[1] = (charset_size*charset_size);
    while ((global_work_size[0] %  local_work_size[0])!=0) global_work_size[0]++;
    while ((global_work_size[1] % (wthreads[self].vectorsize))!=0) global_work_size[1]++;
    global_work_size[1] = global_work_size[1]/wthreads[self].vectorsize;
    image.x=image.y=image.z=image.w=0;
    pthread_mutex_unlock(&biglock); 



    /* markov, len=4 */

    csize=4<<3;
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);
    if (attack_over!=0) goto out;
    image.x=0;image.y=0x80;image.z=0;image.w=0;
    salt = zip_getsalt(4);
    singlehash=zip_getsalt2(4);
    ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

    _clSetKernelArg(kernel, 5, sizeof(cl_uint16), (void*) &p1);
    _clSetKernelArg(kernel, 6, sizeof(cl_uint16), (void*) &p2);
    _clSetKernelArg(kernel, 7, sizeof(cl_uint16), (void*) &p3);
    _clSetKernelArg(kernel, 8, sizeof(cl_uint16), (void*) &p4);
    _clSetKernelArg(kernel, 9, sizeof(cl_uint16), (void*) &p5);
    try=0;
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
    if (markov_max_len==4) goto out;
    if ((session_restore_flag==0)&&(self==0)) scheduler.len=5;


    /* markov, len=5 */

    csize=5<<3;
    sched_wait(5);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==5)
    if (markov_max_len>=5)
    while ((sched_len()==5)&&((a1=sched_s1())<sched_e1()))
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
        image.y=reduced_charset[a1]|(0x80<<8);
        image.z=0;image.w=0;
	salt = zip_getsalt(5);
	singlehash=zip_getsalt2(5);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* markov, len=6 */
    csize=6<<3;
    sched_wait(6);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==6)
    if (markov_max_len>=6)
    for (a1=0;a1<reduced_size;a1++)
    while ((sched_len()==6)&&((a2=sched_s2(a1))<sched_e2(a1)))
    if (markov2[a1][a2]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(0x80<<16);
    	image.z=0;image.w=0;
	salt = zip_getsalt(6);
	singlehash=zip_getsalt2(6);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);



    /* markov, len=7 */

    csize=7<<3;
    sched_wait(7);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==7)
    if (markov_max_len>=7)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(0x80<<24);
    	image.z=0;image.w=0;
	salt = zip_getsalt(7);
	singlehash=zip_getsalt2(7);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);



    /* markov, len=8 */

    csize=8<<3;
    sched_wait(8);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==8)
    if (markov_max_len>=8)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
    	image.z=0x80;
    	image.w=0;
	salt = zip_getsalt(8);
	singlehash=zip_getsalt2(8);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* markov, len=9 */
    csize=9<<3;
    sched_wait(9);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==9)
    if (markov_max_len>=9)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
    	image.z=(markov_charset[a5])|(0x80<<8);
    	image.w=0;
	salt = zip_getsalt(9);
	singlehash=zip_getsalt2(9);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* markov, len=10 */

    csize=10<<3;
    sched_wait(10);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==10)
    if (markov_max_len>=10)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
    	image.z=(markov_charset[a5])|(markov_charset[a6]<<8)|(0x80<<16);
    	image.w=0;
	salt = zip_getsalt(10);
	singlehash=zip_getsalt2(10);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* markov, len=11 */

    csize=11<3;
    sched_wait(11);
    _clSetKernelArg(kernel, 1, sizeof(uint), (void*) &csize);
    if (sched_len()==11)
    if (markov_max_len>=11)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++)
    if (markov1[a6][a7]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
    	image.z=(markov_charset[a5])|(markov_charset[a6]<<8)|(markov_charset[a7]<<16)|(0x80<<24);
    	image.w=0;
	salt = zip_getsalt(11);
	singlehash=zip_getsalt2(11);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);


    /* markov, len=12 */

    csize=12<<3;
    sched_wait(12);
    if (sched_len()==12)
    if (markov_max_len>=12)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++)
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    {
        pthread_mutex_lock(&wthreads[self].tempmutex);
        pthread_mutex_unlock(&wthreads[self].tempmutex);
	if (attack_over!=0) goto out;

    	image.x=0;
    	image.y=reduced_charset[a1]|(markov_charset[a2]<<8)|(markov_charset[a3]<<16)|(markov_charset[a4]<<24);
    	image.z=(markov_charset[a5])|(markov_charset[a6]<<8)|(markov_charset[a7]<<16)|(markov_charset[a8]<<24);
    	image.w=0x80;
	salt = zip_getsalt(12);
	singlehash=zip_getsalt2(12);
    	ocl_set_params(try,image,singlehash,salt,&p1,&p2,&p3,&p4,&p5);

	try++;
	if (try==wthreads[self].loops)
	{
	    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);
	    try=0;
	}
    }
    ocl_execute(queue, kernel, global_work_size, local_work_size, charset_size, found_buf, hashes_buf, plains_buf, plains, hashes, self, &p1,&p2,&p3,&p4,&p5);

    out:
    free(hashes);
    free(plains);
    return hash_ok;
}





/* Crack callback */
static void ocl_zip_crack_callback(char *line, int self)
{
    int a,b,c,e;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);
    _clSetKernelArg(rule_kernel2[self], 4, sizeof(cl_uint16), (void*) &addline);

    /* setup salt */
    if (has_winzip_encryption==1) salt=zip_getsalt128();
    else salt=zip_getsalt(0);
    _clSetKernelArg(rule_kernel[self], 5, sizeof(cl_uint16), (void*) &salt);
    

    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    wthreads[self].tries+=ocl_rule_workset[self]*wthreads[self].vectorsize;
    size_t nws=ocl_rule_workset[self]*wthreads[self].vectorsize;
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel2[self], 1, NULL, &nws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernel[self], 1, NULL, &ocl_rule_workset[self], rule_local_work_size, 0, NULL, NULL);
    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    if (*found==1) 
    {
	if (has_winzip_encryption==0)
	{
    	    _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<ocl_rule_workset[self];a++)
    	    if (rule_found_ind[self][a]==1)
    	    {
        	b=a*wthreads[self].vectorsize;
        	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*16, 16*wthreads[self].vectorsize, rule_ptr[self]+b*16, 0, NULL, NULL);
        	for (c=0;c<wthreads[self].vectorsize;c++)
                if ( ((rule_ptr[self][(b+c)*16+12]&255)==1)&&
                     ((rule_ptr[self][(b+c)*16+13]&255)==0)&&
                     ((rule_ptr[self][(b+c)*16+14]&255)==0)&&
                     ((rule_ptr[self][(b+c)*16+15]&255)==0)
                )
        	{
            	    e=(a)*wthreads[self].vectorsize+c;
            	    strcpy(plain,&rule_images[self][0]+(e*32));
                    unsigned int k1,k2,k3,k4;
                    char *outf;
                    outf = (char *)rule_ptr[self]+(e)*16;
                    memcpy(&k1,outf,4);
                    memcpy(&k2,outf+4,4);
                    memcpy(&k3,outf+8,4);
                    memcpy(&k4,outf+12,4);
                    if (strlen(plain)>0)
                    if (hash_ok==check_zip("",k1,k2,k3,k4))
                    {
                	add_cracked_list(myfilename, "ZIP file    " , "123", plain);
                    }
        	}
    	    }
    	}
    	else
    	{
    	    _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	    for (a=0;a<ocl_rule_workset[self];a++)
    	    if (rule_found_ind[self][a]==1)
    	    {
        	b=a*wthreads[self].vectorsize;
        	_clEnqueueReadBuffer(rule_oclqueue[self], rule_buffer[self], CL_TRUE, b*16, 16*wthreads[self].vectorsize, rule_ptr[self]+b*16, 0, NULL, NULL);
        	for (c=0;c<wthreads[self].vectorsize;c++)
        	{
            	    e=(a)*wthreads[self].vectorsize+c;
            	    strcpy(plain,&rule_images[self][0]+(e*32));
            	    if (strlen(plain)>0)
            	    {
                	if (hash_ok==check_zip(plain,0,0,0,0))
                	{
                    	    add_cracked_list(myfilename, "ZIP file    " , "123", plain);
                	}
            	    }
        	}
    	    }

    	}
        bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
        _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    }
    _clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
}



static void ocl_zip_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);
    if ((rule_counts[self][0]>=ocl_rule_workset[self]*wthreads[self].vectorsize-1)||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_zip_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_zip_thread(void *arg)
{
    cl_int err;
    int found;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (has_winzip_encryption==1) wthreads[self].vectorsize=2;
    else wthreads[self].vectorsize=1;
    if ((wthreads[self].type==nv_thread)&&(wthreads[self].ocl_have_sm21==0)) wthreads[self].vectorsize=1;
    if ((wthreads[self].type==amd_thread)&&(wthreads[self].ocl_have_gcn==1)) wthreads[self].vectorsize=1;
    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;

    if (has_winzip_encryption==1) ocl_rule_workset[self]=256*128;
    else ocl_rule_workset[self]=1024*512;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=4;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=4;


    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernel[self] = _clCreateKernel(program[self], "zip", &err );
    rule_kernel2[self] = _clCreateKernel(program[self], "strmodify", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );

    rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
    bzero(rule_found_ind[self],sizeof(cl_uint)*ocl_rule_workset[self]);
    rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint), NULL, &err );
    _clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
    rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
    rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
    rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_sizes2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
    bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    bzero(&rule_sizes2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    _clSetKernelArg(rule_kernel[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernel[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernel[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernel[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 2, sizeof(cl_mem), (void*) &rule_sizes2_buf[self]);
    _clSetKernelArg(rule_kernel2[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    cl_uint16 none;
    none.s0=none.s1=none.s2=none.s3=none.s4=none.s5=none.s6=none.s7=none.sF=0;
    _clSetKernelArg(rule_kernel2[self], 4, sizeof(cl_uint16), (void*) &none);
    pthread_mutex_unlock(&biglock); 
    worker_gen(self,ocl_zip_callback);
    return hash_ok;
}




hash_stat ocl_bruteforce_zip(void)
{
    int a,i;
    uint64_t bcnt;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_zip(hashlist_file)) exit(1);
    if (has_winzip_encryption==1)
    {
	suggest_rule_attack();
	return hash_ok;
    }

    bcnt=1;
    bruteforce_start=4;
    for (a=bruteforce_start;a<bruteforce_end;a++) bcnt*=strlen(bruteforce_charset);
    attack_overall_count = bcnt;

    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);

    init_bruteforce_long();
    scheduler_setup(bruteforce_start, 5, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
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

	    sprintf(kernelfile,"%s/hashkill/kernels/amd_zip_long__%s.bin",DATADIR,pbuf);

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

    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_zip_long__%s.ptx",DATADIR,pbuf);
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
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_bruteforce_zip_thread, &worker_thread_keys[a]);
    }

    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) pthread_join(crack_threads[a], NULL);

    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_bruteforce;
    attack_over=2;
    return hash_ok;
}



hash_stat ocl_markov_zip(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_zip(hashlist_file)) exit(1);
    if (has_winzip_encryption==1)
    {
	suggest_rule_attack();
	return hash_ok;
    }


    if (fast_markov==1)  hlog("Fast markov attack mode enabled%s\n","");
    init_markov();
    markov_sched_setlimits();
    if (session_restore_flag==0) scheduler_setup(4, 5, markov_max_len, reduced_size, strlen(markov_charset));

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
    	    sprintf(kernelfile,"%s/hashkill/kernels/amd_zip_long__%s.bin",DATADIR,pbuf);

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
            err = _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
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

    	    sprintf(kernelfile,"%s/hashkill/kernels/nvidia_zip_long__%s.ptx",DATADIR,pbuf);

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
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread)
    {
	worker_thread_keys[a]=a;
	pthread_create(&crack_threads[a], NULL, ocl_markov_zip_thread, &worker_thread_keys[a]);
    }
    
    for (a=0;a<nwthreads;a++) if (wthreads[a].type!=cpu_thread) 
    {
	pthread_join(crack_threads[a], NULL);
    }
    printf("\n\n");
    hlog("Done!\n%s","");
    deinit_markov;
    attack_over=2;
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_zip(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];

    if (hash_err == load_zip(hashlist_file)) exit(1);

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
            if (has_winzip_encryption==1) 
            {
                if (winzip_key_size==128) sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_zips__%s.bin",pbuf);
                else sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_zipu__%s.bin",pbuf);
            }
            else
            {
                sprintf(kernelfile,DATADIR"/hashkill/kernels/amd_zip__%s.bin",pbuf);
            }

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

            if (has_winzip_encryption==0) sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_zip__%s.ptx",pbuf);
            else 
            {
                if (winzip_key_size==128) sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_zips__%s.ptx",pbuf);
                else sprintf(kernelfile,DATADIR"/hashkill/kernels/nvidia_zipu__%s.ptx",pbuf);
            }

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
        pthread_create(&crack_threads[a], NULL, ocl_rule_zip_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_zip_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

