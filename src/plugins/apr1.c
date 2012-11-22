/* apr1.c
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
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

extern char *__apr1_crypt_r (const char *key[VECTORSIZE], const char *salt,
                            char *buffer[VECTORSIZE], int buflen, int vectorsize);


int vectorsize;

char * hash_plugin_summary(void)
{
    return("apr1 \t\tApache apr1 plugin");
}


char * hash_plugin_detailed(void)
{
    return("apr1 - Apache apr1 plugin\n"
	    "------------------------\n"
	    "Use this module to crack Apache apr1 passwords\n"
	    "Input should be in form: \'user:hash\' or \'hash\'. htpasswd files accepted using -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Apache web server\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char line3[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str, *temp_str2 = NULL;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str = strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(line2, temp_str);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(temp_str, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	if (strcmp(temp_str,"apr1")!=0) return hash_err;
	snprintf(salt, HASHFILE_MAX_LINE_LENGTH-1, "$%s$%s$", temp_str, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	strcpy(hash, temp_str2);
    }
    else
    {
	strcpy(line2, username);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(line3, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	if (strcmp(line3,"apr1")!=0) return hash_err;
	snprintf(salt, HASHFILE_MAX_LINE_LENGTH-1, "$%s$%s$", line3, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	strcpy(hash, temp_str2);
	strcpy(username,"N/A");
    }

    /* No hash provided at all? */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    /* ensure they aren't smashing the heap?!?*/
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",username);
    line2[HASHFILE_MAX_LINE_LENGTH-2] = 0;
    (void)hash_add_username(line2);
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",hash);
    line2[HASHFILE_MAX_LINE_LENGTH-2] = 0;
    (void)hash_add_hash(line2, 0);
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",salt);
    line2[HASHFILE_MAX_LINE_LENGTH-2] = 0;
    (void)hash_add_salt(line2);

    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;

/*
    char *password1[VECTORSIZE];
    for (a=0;a<vectorsize;a++)
    {
	password1[a] = alloca(64);
	bzero(password1[a],64);
	memcpy(password1[a],password[a], strlen(password[a]));
    }
*/
    __apr1_crypt_r((const char **)password, salt, salt2, 64, vectorsize);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a]+15,hash,16)==0) 
    {
	*num=a;
	return hash_ok;
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
    return 32;
}
