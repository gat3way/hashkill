/* md5.c
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
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char * hash_plugin_summary(void)
{
    return("a51 \t\tA5/1 (GSM encryption) plugin");
}


char * hash_plugin_detailed(void)
{
    return("a51 - A5/1 (GSM encryption) plugin\n"
	    "------------------------\n"
	    "Use this module to crack GSM Kc keys\n"
	    "Input should be in form: \'frame_number:keystream\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Most of the world :)\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str = NULL;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(salt, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);

	/* Hash is not 16 characters long => not a a51 ks */
	if (strlen(hash)!=16)
	{
	    return hash_err;
	}


	/* No hash provided at all */
	if (strcmp(salt,hashline)==0)
	{
	    return hash_err;
	}
	
	(void)hash_add_username("A5/1 Kc");
	strlow(hash);
	hex2str(line, hash, 16);
	(void)hash_add_hash(line,8);
    }
    else return hash_err;

    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int len = strlen(password[0]);
    wlog("A5/1 Cracking is available on GPUs only!%s\n","");
    exit(1);
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    wlog("A5/1 Cracking is available on GPUs only!%s\n","");
    exit(1);
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
    return 10;
}