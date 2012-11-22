/* wpa.c
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
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


typedef struct
{
    char          essid[36];
    unsigned char mac1[6];
    unsigned char mac2[6];
    unsigned char nonce1[32];
    unsigned char nonce2[32];
    unsigned char eapol[256];
    int           eapol_size;
    int           keyver;
    unsigned char keymic[16];
} hccap_t;


char myfilename[255];
int vectorsize;
int erev=0;
hccap_t hccap;
unsigned char ptkbuf[128];


char * hash_plugin_summary(void)
{
    return("wpa \t\tWPA-PSK plugin");
}


char * hash_plugin_detailed(void)
{
    return("wpa - WPA-PSK plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack WPA-PSK keys\n"
	    "Input should be a pcap dump file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Various 802.11 implementations.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd,err;
    struct stat f_stat;

    err = stat(filename,&f_stat);
    if (err<0)
    {
	if (!hashline) elog("Cannot stat file: %s\n",filename);
	return hash_err;
    }
    if (f_stat.st_size!=392)
    {
	if (!hashline) elog("Not a HCCAP file: %s\n",filename);
	return hash_err;
    }

    fd = open(filename,O_RDONLY);
    if (fd<0)
    {
	if (!hashline) elog("Cannot open pcap file: %s\n",filename);
	return hash_err;
    }
    read(fd,&hccap,sizeof(hccap_t));
    if (hccap.eapol_size>256)
    {
	if (!hashline) elog("Cannot open pcap file: %s\n",filename);
	return hash_err;
    }

    /* Fix for hashcat format */
    if (memcmp(hccap.mac1,hccap.mac2,6)>0)
    {
        memcpy(&ptkbuf[0],hccap.mac2,6);
	memcpy(&ptkbuf[6],hccap.mac1,6);
    }
    else
    {
	memcpy(&ptkbuf[0],hccap.mac1,6);
	memcpy(&ptkbuf[6],hccap.mac2,6);
    }
    if (memcmp(hccap.nonce1,hccap.nonce2,32)>0)
    {
	memcpy(&ptkbuf[12],hccap.nonce2,32);
	memcpy(&ptkbuf[44],hccap.nonce1,32);
    }
    else
    {
	memcpy(&ptkbuf[12],hccap.nonce1,32);
	memcpy(&ptkbuf[44],hccap.nonce2,32);
    }


    close(fd);
    strcpy(myfilename, filename);
    (void)hash_add_username(hccap.essid);
    if (hccap.keyver!=2) (void)hash_add_hash("        WPA-PSK",0);
    else (void)hash_add_hash("       WPA2-PSK",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("         ");

    return hash_ok;
}






hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int v;
    unsigned char pmk[64];
    unsigned char ptk[32];
    unsigned char block[128];
    char out[32];
    
    memcpy(block,"Pairwise key expansion",22);
    block[22]=0;
    memcpy(&block[23],ptkbuf,76);
    block[99]=0;
    
    if (hccap.keyver!=2)
    {
	for (v=0;v<vectorsize;v++)
	{
	    hash_pbkdf2((char *)password[v], (unsigned char *)hccap.essid, strlen(hccap.essid),4096, 32, pmk);
	    hash_hmac_sha1(pmk,32,(unsigned char *)block,100,(unsigned char *)ptk,16);
	    //int a;for (a=0;a<16;a++) printf("%02x ",ptk[a]);printf("\n");
	    hash_hmac_md5(ptk,16,hccap.eapol,hccap.eapol_size,(unsigned char*)out,16);
	    if (memcmp((const char *)out,hccap.keymic,16)==0) {*num=v;return hash_ok;}
	    salt2[v][0]=0;
	}
    }
    else
    {
	for (v=0;v<vectorsize;v++)
	{
	    hash_pbkdf2((char *)password[v], (unsigned char *)hccap.essid, strlen(hccap.essid),4096, 32, pmk);
	    hash_hmac_sha1(pmk,32,(unsigned char *)block,100,(unsigned char *)ptk,16);
	    hash_hmac_sha1(ptk,16,hccap.eapol,hccap.eapol_size,(unsigned char*)salt2[v],16);
	    if (memcmp((const char *)salt2[v],hccap.keymic,16)==0) {*num=v;return hash_ok;}
	    salt2[v][0]=0;
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
