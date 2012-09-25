/* md5-saltpass.c
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
#include <stdlib.h>
#include <string.h>
#include <alloca.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char * hash_plugin_summary(void)
{
    return("sl3  \t\tNokia SL3 plugin");
}


char * hash_plugin_detailed(void)
{
    return("sl3 - A Nokia SL3 unlock module\n"
	    "------------------------\n"
	    "Use this module to crack Nokia SL3 hashes\n"
	    "Input should be in form: \'hash:imei\'\n"
	    "PROVIDE THE FIRST HASH ONLY!\n"
	    "Remember this is a GPL software, you can use it commercially it provided that you provide people the source\n"
	    "This is POC code written out of academic interest.\n"
	    "I don't know how the hashes are extracted from the phone.\n"
	    "Use that at your own risk!\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char line3[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(hash, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(line2, temp_str);
    }

    /* Hash is not 32 characters long => not a md5 hash */
    if ((strlen(hash)!=40))
    {
	return hash_err;
    }

    strcpy(username,"SL3 master");

/*
    for (a=0;a<14;a+=2)
    {
	memcpy(ccopy,&line2[a],2);
	ccopy[2]=0;
	line3[a/2] = ((ccopy[1]-48)&15) | (((ccopy[0]-48)&15)<<4);
    }
    line3[8]=0;
*/
    strcpy(line3,line2);

    strlow(hash);
    hex2str(line, hash, 40);

    (void)hash_add_username(username);
    (void)hash_add_hash(line, 20);
    (void)hash_add_salt(line3);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    elog("This plugin supports GPU attacks only!\n%s","");
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
    return 16;
}

