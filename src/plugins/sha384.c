/* sha384.c
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


int vectorsize;

char * hash_plugin_summary(void)
{
    return("sha384 \t\tSHA-384 plugin");
}


char * hash_plugin_detailed(void)
{
    return("sha384 - A simple sha384 plugin\n"
	    "------------------------\n"
	    "Use this module to crack simple sha384 hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "None.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[255];
    char hash[255];
    char line[255];
    char line2[255];
    char *temp_str=NULL;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    snprintf(line, 254, "%s", hashline);
    if (strstr(line,":"))
    {
	strcpy(username, strtok(line, ":"));
	temp_str=strtok(NULL,":");
    }
    if (temp_str) 
    {
	strcpy(hash, temp_str);
    }
    else
    {
	strcpy(hash,line);
	strcpy(username,"N/A");
    }

    /* Hash is not 96 characters long => not a sha384 hash*/
    if (strlen(hash)!=96)
    {
	return hash_err;
    }


    (void)hash_add_username(username);
    hex2str(line2, hash, 96);
   
    (void)hash_add_hash(line2, 48);
    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a;
    int lens[VECTORSIZE];
    
    for (a=0;a<vectorsize;a++) lens[a] = strlen(password[a]);
    (void)hash_sha384_unicode(password, salt2, lens);
    
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
