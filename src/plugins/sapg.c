/* sap.c
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
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;

char * hash_plugin_summary(void)
{
    return("sapg \t\tSAP CODVN G passwords plugin");
}


char * hash_plugin_detailed(void)
{
    return("sap - SAP password hashes plugin\n"
	    "-------------------------------\n"
	    "Use this module to crack SAP R/3 CODVN G hashes\n"
	    "Input should be in form: \'user:hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "SAP R/3 \n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    char line2[HASHFILE_MAX_LINE_LENGTH];
    
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    bzero(username,20);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	if (temp_str[0]=='$') strcpy(hash, temp_str+1); // Strip $
	else strcpy(hash, temp_str);
    }

    /* Hash is not 40 characters long => not a smf hash */
    if (strlen(hash)!=40)
    {
	return hash_err;
    }
    
    /* No hash provided at all */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    
    strlow(hash);
    hex2str(line2, hash, 40);
    
    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 20);
    (void)hash_add_salt("   ");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash1[VECTORSIZE];
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    char *hash4[VECTORSIZE];
    char *hash5[VECTORSIZE];
    int a,i,j;
    unsigned char sapgarray[160]=
    {0x91, 0xAC, 0x51, 0x14, 0x9F, 0x67, 0x54, 0x43, 0x24, 0xE7, 0x3B, 0xE0, 0x28, 0x74, 
    0x7B, 0xC2,  0x86, 0x33, 0x13, 0xEB, 0x5A, 0x4F, 0xCB, 0x5C, 0x08, 0x0A, 0x73, 0x37, 
    0x0E, 0x5D, 0x1C, 0x2F,  0x33, 0x8F, 0xE6, 0xE5, 0xF8, 0x9B, 0xAE, 0xDD, 0x16, 0xF2, 
    0x4B, 0x8D, 0x2C, 0xE1, 0xD4, 0xDC,  0xB0, 0xCB, 0xDF, 0x9D, 0xD4, 0x70, 0x6D, 0x17, 
    0xF9, 0x4D, 0x42, 0x3F, 0x9B, 0x1B, 0x11, 0x94,  0x9F, 0x5B, 0xC1, 0x9B, 0x06, 0x05, 
    0x9D, 0x03, 0x9D, 0x5E, 0x13, 0x8A, 0x1E, 0x9A, 0x6A, 0xE8,  0xD9, 0x7C, 0x14, 0x17, 
    0x58, 0xC7, 0x2A, 0xF6, 0xA1, 0x99, 0x63, 0x0A, 0xD7, 0xFD, 0x70, 0xC3,  0xF6, 0x5E, 
    0x74, 0x13, 0x03, 0xC9, 0x0B, 0x04, 0x26, 0x98, 0xF7, 0x26, 0x8A, 0x92, 0x93, 0x25,  
    0xB0, 0xA2, 0x0D, 0x23, 0xED, 0x63, 0x79, 0x6D, 0x13, 0x32, 0xFA, 0x3C, 0x35, 0x02, 
    0x9A, 0xA3,  0xB3, 0xDD, 0x8E, 0x0A, 0x24, 0xBF, 0x51, 0xC3, 0x7C, 0xCD, 0x55, 0x9F, 
    0x37, 0xAF, 0x94, 0x4C,  0x29, 0x08, 0x52, 0x82, 0xB2, 0x3B, 0x4E, 0x37, 0x9F, 0x17, 
    0x07, 0x91, 0x11, 0x3B, 0xFD, 0xCD };
    int lens[VECTORSIZE];


    for (a=0;a<vectorsize;a++)
    {
	hash1[a]=alloca(64);
	hash2[a]=alloca(64);
	hash3[a]=alloca(128);
	hash4[a]=alloca(64);
	hash5[a]=alloca(128);

	hash1[a][0] = 0;
	bzero(hash2[a], 64);

	// Perform translation
	j=0;
	for (i=0; i<strlen(password[a]); i++) 
	{
	    if (password[a][i] & 0x80) 
	    {
		switch ((unsigned char)password[a][i]) 
		{
		    case 0xFC:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xBC; j+=2; break;
		    case 0xF6:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xB6; j+=2; break;
		    case 0xE4:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xA4; j+=2; break;
		    case 0xDC:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x9C; j+=2; break;
		    case 0xD6:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x96; j+=2; break;
		    case 0xC4:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x84; j+=2; break;
		    case 0xDF:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x9F; j+=2; break;
		    case 0xBA:
			hash2[a][j]=0xC2; hash2[a][j+1]=0xB0; j+=2; break;
		    case 0xB4:
			hash2[a][j]=0xC2; hash2[a][j+1]=0xB4; j+=2; break;
		    case 0xE9:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xA9; j+=2; break;
		    case 0xEA:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xAA; j+=2; break;
		    case 0xE8:
			hash2[a][j]=0xC3; hash2[a][j+1]=0xA8; j+=2; break;
		    case 0xC9:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x89; j+=2; break;
		    case 0xCA:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x8A; j+=2; break;
		    case 0xC8:
			hash2[a][j]=0xC3; hash2[a][j+1]=0x88; j+=2; break;
		    case 0xA7:
			hash2[a][j]=0xC2; hash2[a][j+1]=0xA7; j+=2; break;
		    default:
			hash2[a][j]=password[a][i]; j++;
			break;
		} 
	    }
	    else hash2[a][j++]=password[a][i];
	}
	hash2[a][j]='\0';
	memcpy(hash3[a],hash2[a],j);
	memcpy(hash3[a]+j,username,strlen(username));
	lens[a] = j+strlen(username);
    }
    (void)hash_sha1_unicode((const char **)hash3, hash4, lens);
    for (a=0;a<vectorsize;a++)
    {
	unsigned int len,offset;
	len=offset=0;
	for (i=0; i<=9; i++) len+=(hash4[a][i]&255)%6;
	len+=0x20;
	for (i=19; i>=10; i--) offset+= ((hash4[a][i]&255)%8);
	memcpy(hash5[a],hash2[a],strlen(hash2[a]));
	memcpy(hash5[a]+strlen(hash2[a]), &sapgarray[offset],len); 
	memcpy(hash5[a]+strlen(hash2[a])+len, username, strlen(username));
	lens[a] = strlen(hash2[a]) + len + strlen(username);
    }
    (void)hash_sha1_slow((const char **)hash5,salt2,lens);
    for (a=0;a<vectorsize;a++) if (fastcompare(salt2[a], hash,20)==0) {*num=a;return hash_ok;}
    
    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 0;
}

int hash_plugin_is_raw(void)
{
    return 1;
}

int hash_plugin_is_special(void)
{
    return 0;
}

void get_vector_size(int size)
{
    vectorsize = size;
}

int get_salt_size(void)
{
    return 4;
}

