/* bitcoin.c
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
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char * hash_plugin_summary(void)
{
    return("bitcoin \tA Bitcoin mining plugin");
}


char * hash_plugin_detailed(void)
{
    return("bitcoin - A bitcoin miner\n"
	    "------------------------\n"
	    "Use this module to mine bitcoins :)\n"
	    "Several pools are supported.\n"
	    "Input should be in form: \'user:pass:host:port\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Bitcoin cryptocurrency system.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char pass[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str = NULL;
    
    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));

    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(pass, temp_str);
	(void)hash_add_username(username);
	(void)hash_add_hash(pass,strlen(pass));
	temp_str=strtok(NULL,":");
	(void)hash_add_salt(temp_str);
	temp_str=strtok(NULL,":");
	(void)hash_add_salt2(temp_str);
	
    }
    else
    {
	printf("Wrong input!\n");
	return hash_err;
    }

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    elog("This plugin is GPU only!\n%s","");
    exit(1);
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    elog("This plugin is GPU only!\n%s","");
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