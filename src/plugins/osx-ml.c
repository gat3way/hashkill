/* osx-ml.c
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
#include <fcntl.h>
#include <stdint.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

#define ntohll(x) (((uint64_t) ntohl((x) >> 32)) | (((uint64_t) ntohl((uint32_t) ((x) & 0xFFFFFFFF))) << 32))


int vectorsize;


char * hash_plugin_summary(void)
{
    return("osx-ml \tOSX Mountain Lion hashes plugin");
}


char * hash_plugin_detailed(void)
{
    return("osx-ml - OSX Mountain Lion plugin\n"
	    "------------------------\n"
	    "Use this module to crack OSX Mountain Lion passwords\n"
	    "Input should be a plist file\n"
	    "Known software that uses this password hashing method:\n"
	    "OSX Mountain Lion\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}




hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char hash[129];
    char salt[65+8];
    char line[1024];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str=NULL;
    char iter[8];

    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    snprintf(line, 1024, "%s", hashline);
    temp_str=strtok(line,"$");
    if (temp_str) 
    {
        if ((strlen(temp_str)!=2)&&(strcmp(temp_str,"ml")!=0))
        {
    	    return hash_err;
        }
	temp_str=strtok(NULL,"$");
	if (!temp_str) return hash_err;
	strncpy(iter,temp_str,8);
	temp_str=strtok(NULL,"$");
        if (strlen(temp_str)!=64) return hash_err;
        else
        {
            memcpy(salt,temp_str,64);
            salt[64]=0;
            temp_str=strtok(NULL,"$");
            if (!temp_str) return hash_err;
            if (strlen(temp_str)!=128) return hash_err;
            memcpy(hash,temp_str,128);
            hash[128]=0;
        }
    }
    else return hash_err;

    (void)hash_add_username("OSX-ML hash");
    strlow(hash);
    hex2str(line2,hash,128);
    (void)hash_add_hash(line2, 64);
    strcpy(salt+64,iter);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");
    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char *dest[VECTORSIZE];
    int a;
    unsigned char mysalt[64];
    char mysalt2[128];
    int rounds,len;

    rounds = atoi(salt+64);
    memset(mysalt2,0,64);
    memcpy(mysalt2,salt,64);
    strlow(mysalt2);
    hex2str((char *)mysalt,mysalt2, 64);

    for (a=0;a<vectorsize;a++) 
    {
	len = strlen(password[a]);
	dest[a] = alloca(64);
	hash_pbkdf512((char *)password[a], len, mysalt, 32, rounds, 64, dest[a]);
	if (fastcompare((const char *)dest[a], hash, 64)==0) 
	{
	    *num=a;
	    return hash_ok;
	}
    }
    return hash_err;
}




int hash_plugin_hash_length(void)
{
    return 64;
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
    return 80;
}

