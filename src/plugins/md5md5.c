/* md5md5.c
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
    return("md5md5 \t\tmd5(md5(pass)) plugin");
}


char * hash_plugin_detailed(void)
{
    return("md5md5 - A simple md5(md5(pass)) plugin\n"
	    "------------------------\n"
	    "Use this module to crack simple md5(md5(pass)) hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "e107 < 0.8, Koobi CMS > 6.0, AVE CMS, DataLife engine, Diferior, etc\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str;
    
    
    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;

    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);

        /* Hash is not 32 characters long => not a md5 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}

	(void)hash_add_username(username);
	strlow(hash);
	hex2str(line2, hash, 32);
	(void)hash_add_hash(line2,16);
    }
    else
    {
	strcpy(hash, username);

        /* Hash is not 32 characters long => not a md5 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}

	(void)hash_add_username("N/A");
	strlow(hash);
	hex2str(line2, hash, 32);
	(void)hash_add_hash(line2,16);
    }

    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    int cnt;
    
    for (cnt=0;cnt<vectorsize;cnt++) hash2[cnt] = alloca(16);
    for (cnt=0;cnt<vectorsize;cnt++) hash3[cnt] = alloca(32);
    
    (void)hash_md5(password, hash2, *num, threadid);
    (void)hash_md5_hex((const char **)hash2, hash3);
    (void)hash_md5((const char **)hash3, salt2, 32, THREAD_LENPROVIDED);
    // No need to do that - md5md5 has linear complexity
/*    for (cnt=0;cnt<VECTORSIZE;cnt++)
    {
	if (fastcompare(salt2[cnt], hash,16)==0) {*num=cnt; return hash_ok;}
    }
    return hash_err;*/
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
