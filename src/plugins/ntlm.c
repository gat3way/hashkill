/* ntlm.c
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
    return("ntlm \t\tNTLM plugin");
}


char * hash_plugin_detailed(void)
{
    return("ntlm - NTLM plugin\n"
	    "------------------------\n"
	    "Use this module to crack simple NTLM hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "PWDUMP hash format is also supported\n"
	    "Known software that uses this password hashing method:\n"
	    "Recent Microsoft Windows versions\n"
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
    
    /* Special case: that is a pwdump hash format */
    if (strstr(hashline,":::"))
    {
        snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
        strcpy(username, strtok(line, ":"));
	/* skip uid */
        temp_str=strtok(NULL,":");
        /* skip first hash */
        temp_str=strtok(NULL,":");
        if (strlen(temp_str)!=32) return hash_err;
        /* get LM hash */
        temp_str=strtok(NULL,":");
	if (!temp_str) return hash_err;
        strcpy(hash, temp_str);
        /* Hash is not 32 characters long => not a md4 hash */
        if (strlen(hash)!=32)
        {
            return hash_err;
        }
        (void)hash_add_username(username);
        strlow(hash);
        hex2str(line, hash, 32);
        (void)hash_add_hash(line,16);
	(void)hash_add_salt("");
	(void)hash_add_salt2("");
	return hash_ok;
    }
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);
	/* Hash is not 32 characters long => not a md4 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}

	/* Could be a salt anyway, let's check */
	int flag=0;
	int a;
	for (a=0;a<strlen(hash);a++) if ( ((hash[a]<'0')||(hash[a]>'9'))&&((hash[a]<'a')||(hash[a]>'f'))) flag=1;
	if (flag==1) return hash_err;

	(void)hash_add_username(username);
	strlow(hash);
	hex2str(line, hash, 32);
	(void)hash_add_hash(line,16);
    }
    else
    {
	strcpy(hash, username);
	/* Hash is not 32 characters long => not a md4 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}
	(void)hash_add_username("N/A");
	strlow(hash);
	hex2str(line, hash, 32);
	(void)hash_add_hash(line,16);
    }
    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *newuser[VECTORSIZE];
    int lens[VECTORSIZE];
    int a,b,sz;
    
    for (b=0;b<vectorsize;b++)
    {
	newuser[b] = alloca(64);
	bzero(newuser[b],64);
	sz = strlen(password[b]);
	for (a=0;a<sz;a++)
	{
	    newuser[b][a<<1] = password[b][a];
	}
	lens[b] = sz<<1;
    }
    (void)hash_md4_slow((const char **)newuser, salt2, lens,0);
    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *newuser[VECTORSIZE];
    int a,b,sz;
    int wb;
    
    sz = strlen(password[0])<<1;
    //if (sz==0) return hash_err;
    
    for (b=0;b<vectorsize;b++)
    {
	newuser[b] = alloca(64);
	for (a=0;a<16;a+=2)
	{
	    wb=0;
	    wb=(password[b][a])|((password[b][a+1])<<16);
	    //memcpy((&newuser[b][a<<1]),&wb,4);
	    *(unsigned int *)(&newuser[b][a<<1])=wb;
	}
    }

    return hash_md4_unicode((const char **)newuser, salt2, sz,THREAD_LENPROVIDED);
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
