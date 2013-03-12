/* grub2.c
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
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;


char * hash_plugin_summary(void)
{
    return("grub2 \t\tGRUB2 plugin");
}


char * hash_plugin_detailed(void)
{
    return("grub2 - GRUB2 plugin\n"
	    "------------------------\n"
	    "Use this module to crack GRUB2 passwords\n"
	    "Input should be in form:  \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "GRUB2\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[129];
    char salt[129];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str=NULL;
    char *temp_str2=NULL;

    if (!hashline) return hash_err;
    if (!strstr(hashline,"grub.pbkdf2.sha512")) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    if (strstr(line,"."))
    {
	temp_str=strtok(line,".");
	temp_str=strtok(NULL,".");
	temp_str=strtok(NULL,".");
	temp_str=strtok(NULL,".");
    }
    strcpy(username,"GRUB2");
    
    if (temp_str)
    {
	strcpy(line2, temp_str);
	temp_str2=strtok(NULL,".");
	if (!temp_str2) return hash_err;
	strcpy(salt, temp_str2);
	strcat(salt,line2);
	temp_str2=strtok(NULL,".");
	if (!temp_str2) return hash_err;
	strcpy(line2, temp_str2);
	strlow(line2);
	hex2str(hash,line2, 128);
	(void)hash_add_username(username);
	(void)hash_add_hash(hash, 64);
	(void)hash_add_salt(salt);
    }
    else return hash_err;

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

    rounds = atoi(salt+128);
    memcpy(mysalt2,salt,128);
    strlow(mysalt2);
    hex2str((char *)mysalt,mysalt2, 128);

    for (a=0;a<vectorsize;a++) 
    {
	len = strlen(password[a]);
	dest[a] = alloca(64);
	hash_pbkdf512((char *)password[a], len, mysalt, 64, rounds, 64, dest[a]);
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
    return 160;
}

