/* mysql5.c
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


char * hash_plugin_summary(void)
{
    return("mysql5 \t\tMySQL > 4.1 plugin");
}


char * hash_plugin_detailed(void)
{
    return("mysql5 - MySQL 4.1 and above plugin\n"
	    "------------------------\n"
	    "Use this module to crack newer mysql  password hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'.\n"
	    "Known software that uses this password hashing method:\n"
	    "MySQL > 4.1\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    
    
    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;

    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	if (temp_str[0]=='*') strcpy(hash, temp_str+1);
	else strcpy(hash, temp_str);
	strupr(hash);
    }
    else
    {
	if (username[0]=='*') strcpy(hash, username+1);
	else strcpy(hash, username);
	strcpy(username,"N/A");
	strupr(hash);
    }
    
    if (strlen(hash)!=40)
    {
	return hash_err;
    }
    
    /* No hash provided at all*/
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    
    (void)hash_add_username(username);

    strlow(hash);
    hex2str(line, hash, 40);
    (void)hash_add_hash(line, 20);
    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    int a;

    for (a=0;a<vectorsize;a++) 
    {
    	hash2[a]=alloca(64);
    }

    (void)hash_sha1(password, hash2, *num, threadid);
    (void)hash_sha1((const char **)hash2, salt2, 20, THREAD_LENPROVIDED);

    return hash_ok;
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
    return 1;
}