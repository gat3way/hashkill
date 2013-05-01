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
static unsigned int fcrc;



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
    comprsize=ucomprsize=0;
    fileoffset=0;
    memset(zipbuf,0,1024*16);
    memset(verifiers,0,5);
    memset(zip_crc32,0,4);
    memset(zip_tim,0,2);

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
        if (cur==0) memcpy(&fcrc,zip_crc32,4);
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


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char key[68];
    unsigned char check[2];
    unsigned long key0=0,key1=0,key2=0;
    unsigned long k0=0,k1=0,k2=0;
    unsigned char norm_zip_local[12];
    int fd;
    int ret, bsize, rsize, usize,a,b=0;
    unsigned char in[1024*16+100];
    unsigned char out[1024*16*10+100];
    unsigned char authcode[16];
    unsigned char authresult[16];
    int iter=0;
    unsigned int mcrc=0xffffffff;

    for (a=0;a<vectorsize;a++)
    {
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
    	unsigned char temp1;
    	unsigned char c;
    	unsigned  long temp;
	for (b=0;b<cur;b++)
	{
	    key0 = 305419896L;
	    key1 = 591751049L;
	    key2 = 878082192L;
	    int i;
	    for (i=0;i<strlen(password[a]);i++)
	    {
		key0=CRC_UPDATE_BYTE(key0, (char)*(password[a]+i));
		key1 += key0 & 0xff;
		key1 = key1 * 134775813L + 1;
		key2 = CRC_UPDATE_BYTE(key2,(char)(key1>>24));
	    }
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
	    else goto next;
	    if (b==0)
	    {
		k0=key0;k1=key1;k2=key2;
	    }
	}
	if (passes<(cur)) goto next;
	mcrc=0xffffffff;
        {
            key0=k0;key1=k1;key2=k2;
            if (precheck_zip(key0,key1,key2)==hash_err) goto next;
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
            iter=0;
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
                        key0 = CRC_UPDATE_BYTE(key0, c);
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
                    int d;
                    for (d=0;d<(bsize*10 - strm.avail_out);d++)
                    {
                	mcrc = CRC_UPDATE_BYTE(mcrc, out[d]);
                    }
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
                        key0 = CRC_UPDATE_BYTE(key0, c);
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
                    int d;
                    for (d=0;d<(bsize*10 - strm.avail_out);d++)
                    {
                	mcrc = CRC_UPDATE_BYTE(mcrc, out[d]);
                    }
                }
                iter++;

                if (ret == Z_DATA_ERROR) 
                {
                    close(fd);
                    inflateEnd(&strm);
                    goto next;
                }
                if (ret == Z_NEED_DICT) 
                {

                    close(fd);
                    inflateEnd(&strm);
                    goto next;
                }
                if (ret == Z_STREAM_ERROR) 
                {
                    close(fd);
                    inflateEnd(&strm);
                    goto next;
                }

                if  ((ret == Z_MEM_ERROR))
                {
                    close(fd);
                    inflateEnd(&strm);
                    goto next;
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
                if (~mcrc!=fcrc) goto next;
                close(fd);
                *num=a;
                memcpy(salt2[a],"ZIP file        \0\0",17);
                return hash_ok;
            }

            else
            {
                inflateEnd(&strm);
                close(fd);
                goto next;
            }
    	    close(fd);
        }
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
