/* smf.c
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
    return("smf \t\tSMF plugin");
}


char * hash_plugin_detailed(void)
{
    return("smf - SMF password hashes plugin\n"
	    "-------------------------------\n"
	    "Use this module to crack SMF hashes\n"
	    "Input should be in form: \'user:hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Simple Machines Forum (SMF) \n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    char line2[HASHFILE_MAX_LINE_LENGTH];
    
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);
    }

    /* Hash is not 40 characters long => not a smf hash */
    if (strlen(hash)!=40)
    {
	return hash_err;
    }
    
    /* No hash provided at all */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    
    hex2str(line2, hash, 40);
    strlow(username);
    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 20);
    (void)hash_add_salt("   ");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash1[VECTORSIZE];
    char *hash2[VECTORSIZE];
    int a;
    int usernamelen,passlen;

    usernamelen = strlen(username);
    passlen = strlen(password[0]);
    for (a=0;a<vectorsize;a++)
    {
	hash1[a]=alloca(64);
	hash2[a]=alloca(64);
	hash1[a][0] = 0;
	bzero(hash2[a], 64);
	strcpy(hash2[a], username);
	//strlow(hash2[a]);
	memcpy(hash1[a], hash2[a],usernamelen);
	memcpy(hash1[a]+usernamelen, password[a], strlen(password[a]));
    }
    (void)hash_sha1((const char **)hash1, salt2, usernamelen+passlen, THREAD_LENPROVIDED);

    for (a=0;a<vectorsize;a++) if (fastcompare(salt2[a], hash,20)==0) {*num=a;return hash_ok;}
    return hash_err;
}

hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash1[VECTORSIZE];
    int lens[VECTORSIZE];
    char *hash2[VECTORSIZE];
    int a;
    int usernamelen;

    usernamelen = strlen(username);
    for (a=0;a<vectorsize;a++)
    {
	hash1[a]=alloca(64);
	hash2[a]=alloca(64);
	hash1[a][0] = 0;
	bzero(hash2[a], 64);
	bzero(hash1[a], 64);
	strcpy(hash2[a], username);
	//strlow(hash2[a]);
	memcpy(hash1[a], hash2[a],usernamelen);
	memcpy(hash1[a]+usernamelen, password[a], strlen(password[a]));
	lens[a]=strlen(password[a])+usernamelen;
    }
    (void)hash_sha1_unicode((const char **)hash1, salt2, lens);

    for (a=0;a<vectorsize;a++) if (fastcompare(salt2[a], hash,20)==0) {*num=a;return hash_ok;}
    return hash_err;
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
