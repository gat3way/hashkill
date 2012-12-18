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
#include <openssl/sha.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"




static char myfilename[255];
static unsigned char tc_salt[64];
static unsigned char sector[512];



char * hash_plugin_summary(void)
{
    return("truecrypt \t\ttruecrypt encrypted block device plugin");
}


char * hash_plugin_detailed(void)
{
    return("truecrypt - truecrypt encrypted block device plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack truecrypt encrypted partitions\n"
	    "Input should be a truecrypt device file specified with -f\n"
	    "Warning: currently only aes256/cbc-essiv:sha256 images supported!\n"
	    "Known software that uses this password hashing method:\n"
	    "cryptsetup/truecrypt\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}




hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int myfile;

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

    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("truecrypt volume  ",0);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2(" ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char key[64];
    unsigned char out[128];
    int a;

    for (a=0;a<vectorsize;a++)
    {
	hash_pbkdf512((char *)password[a], (unsigned char *)tc_salt, 64, 1000, 64, key);
	bzero(out,64);
	hash_decrypt_aes_xts((char *)key, (char *)key+32, (char *)sector+64, (char *)out, 64, 0, 0);
	// compare
	if (memcmp(out, "TRUE", 4)==0) 
	{
	    *num=a;
	    return hash_ok;
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

