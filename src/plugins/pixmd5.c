/* pixmd5.c
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
    return("pixmd5 \t\tCisco PIX password hashes plugin");
}


char * hash_plugin_detailed(void)
{
    return("pixmd5 - Cisco PIX password hashes plugin\n"
	    "------------------------\n"
	    "Use this module to crack Cisco PIX passwords\n"
	    "Input should be in form: \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Cisco PIX\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *tempstr;
    char *tempstr2;

    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    if (strlen(hashline)>48) return hash_err;
    tempstr = strtok(hashline,":");
    tempstr2 = strtok(NULL,":");
    if (tempstr2)
    {
	if (strlen(tempstr2)!=16) return hash_err;
	(void)hash_add_username(tempstr);
	(void)hash_add_hash(tempstr2,0);
    }
    else
    {
	if (strlen(tempstr)!=16) return hash_err;
	(void)hash_add_username("PIX enable pwd");
	(void)hash_add_hash(tempstr,0);
    }

    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *final[VECTORSIZE];
    int cnt,len[VECTORSIZE];
    int a;
    char *salt3;
    
    for (a=0;a<vectorsize;a++) {final[a] = alloca(32);}

    for (a=0;a<vectorsize;a++)
    {
	len[a]=16;
	for (cnt=len[a];cnt<20;cnt++) password[a][cnt] = 0;
    }
    
    /* Cannot align there...going the slow way */
    hash_md5_unicode_slow(password, final, len);

    for (a=0;a<vectorsize;a++)
    {
	_to64(salt2[a], *(unsigned long *) (final[a]+0), 4);
        _to64(salt2[a]+4, *(unsigned long *) (final[a]+4), 4);
        _to64(salt2[a]+8, *(unsigned long *) (final[a]+8), 4);
        _to64(salt2[a]+12, *(unsigned long *) (final[a]+12), 4);
        salt2[a][16]=0;
    }

    return hash_ok;
}


int hash_plugin_hash_length(void)
{
    return 16;
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
