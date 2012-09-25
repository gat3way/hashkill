/* desunix.c
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

#include <crypt.h>
#include <unistd.h>
#include <crypt.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

int vectorsize;


char * hash_plugin_summary(void)
{
    return("desunix \tDES(Unix) plugin (.htpasswd)");
}



char * hash_plugin_detailed(void)
{
    return("desunix - DES(Unix) plugin\n"
	    "------------------------\n"
	    "Use this module to crack old crypt() passwords\n"
	    "Input should be in form: \'user:hash\' or just hash. non-apr1 .htpasswd files are acceptable\n"
	    "Known software that uses this password hashing method:\n"
	    "Apache 1.x, Apache 2.x, old Unix boxes, WWWThreads\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}



hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str = strtok(NULL,":");
    if (temp_str) memmove(line, temp_str,strlen(temp_str)+1);
    else 
    {
	strcpy(line,username);
	strcpy(username,"N/A");
    }


    /* Bad hash */
    if (strlen(line)!=13)
    {
	return hash_err;
    }
    
    
    salt[0] = line[0];
    salt[1] = line[1];
    salt[2] = 0;

    hash[0] = line[0];
    hash[1] = line[1];
    hash[2] = line[2];
    hash[3] = line[3];
    hash[4] = line[4];
    hash[5] = line[5];
    hash[6] = line[6];
    hash[7] = line[7];
    hash[8] = line[8];
    hash[9] = line[9];
    hash[10] = line[10];
    hash[11] = line[11];
    hash[12] = line[12];
    hash[13] = 0;
    hash[14] = 0;
    hash[15] = 0;

    
    (void)hash_add_username(username);
    (void)hash_add_hash(hash, 0);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;

    if (hash_ok==hash_fcrypt(password, salt, salt2))
    {
	for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,13)==0) {*num=a;return hash_ok;}
    }
    return hash_err;
}

hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;

    if (hash_ok==hash_fcrypt(password, salt, salt2))
    {
	for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,13)==0) {*num=a;return hash_ok;}
    }
    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 0;
}

int hash_plugin_is_raw(void)
{
    return 0;
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
    return 3;
}