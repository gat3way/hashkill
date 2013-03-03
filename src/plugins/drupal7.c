/* drupal7.c
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

//#define _XOPEN_SOURCE
#include <crypt.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"

extern char *pacrypt_private (const char *key[VECTORSIZE], const char *salt, char *out[VECTORSIZE], int num);

int vectorsize;

char * hash_plugin_summary(void)
{
    return("drupal7 \tDrupal >=7 hashes plugin");
}


char * hash_plugin_detailed(void)
{
    return("drupal7 - Drupal >=7 hashes plugin\n"
	    "------------------------\n"
	    "Use this module to crack drupal7 passwords\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'.\n"
	    "Known software that uses this password hashing method:\n"
	    "drupal >= 7\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str=NULL, *temp_str2 = NULL, *temp_str3 = NULL;
    
    if (!hashline) return hash_err;
    if (!strstr(hashline,"$S$")) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    if (strstr(line,":"))
    {
	strcpy(username, strtok(line, ":"));
	temp_str = strtok(NULL,":");
    }
    if (temp_str) 
    {
	strcpy(line2, temp_str);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(temp_str, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	temp_str3=alloca(30);
	memcpy(temp_str3, temp_str2, 9);
	snprintf(salt, HASHFILE_MAX_LINE_LENGTH-1, "$%s$%s", temp_str, temp_str3);
	if (temp_str[0]!='S') return hash_err;
    }
    else
    {
	strcpy(line2, line);
	temp_str = alloca(64);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(temp_str, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	temp_str3=alloca(30);
	memcpy(temp_str3, temp_str2, 9);
	snprintf(salt, HASHFILE_MAX_LINE_LENGTH-1, "$%s$%s", temp_str, temp_str3);
	if (temp_str[0]!='S') return hash_err;
	strcpy(username,"N/A");
    }

    /* No hash provided at all? */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    /* ensure they aren't smashing the heap?!?*/
    (void)hash_add_username(username);
    (void)hash_add_salt(salt);
    sprintf(line,"$S$%s",temp_str2);
    (void)hash_add_hash(line, 0);
    (void)hash_add_salt2("");
    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;

    pacrypt_private(password, salt, salt2, vectorsize);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,strlen(hash))==0) {*num=a;return hash_ok;}
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
    return 14;
}
