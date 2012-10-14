/* nsldap.c
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
    return("nsldap \t\tLDAP SHA plugin");
}


char * hash_plugin_detailed(void)
{
    return("nsldap - nsldap plugin\n"
	    "------------------------\n"
	    "Use this module to crack LDAP SHA passwords\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "OpenLDAP, various LDAP implementations\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str=NULL;
    
    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    if (strstr(line,":"))
    {
	strcpy(username, strtok(line, ":"));
	temp_str=strtok(NULL,":");
    }
    
    if (temp_str) 
    {
	if (strlen(temp_str)<20) return hash_err;
	strcpy(hash, temp_str);
	(void)hash_add_username(username);
	(void)hash_add_hash(hash, 0);
    }
    else
    {
	(void)hash_add_username("N/A");
	(void)hash_add_hash(line, 0);
	strcpy(hash, line);
    }
    
    /* not the proper hash */
    if (memcmp(hash, "{SHA}", 5)!=0) return hash_err;
    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}

extern int b64_ntop(unsigned char const *src, size_t srclength, char *target, size_t targsize);

hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *dest[VECTORSIZE];
    int a,len;
    
    for (a=0;a<vectorsize;a++) dest[a] = alloca(20);
    (void)hash_sha1(password, dest, *num, 0);
    for (a=0;a<vectorsize;a++) 
    {
	memcpy(salt2[a],"{SHA}",5);
	len = b64_ntop((const unsigned char *)dest[a], 20, salt2[a]+5, 64);
	salt2[len]=0;
    }
    return hash_ok;
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
    return 1;
}
