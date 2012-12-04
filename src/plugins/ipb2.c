/* ipb2.c
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
    return("ipb2 \t\tmd5(md5(salt).md5(pass)) plugin (IPB > 2.x)");
}


char * hash_plugin_detailed(void)
{
    return("ipb2 - A simple md5(md5(salt).md5(pass)) plugin\n"
	    "------------------------\n"
	    "Use this module to crack md5(md5(salt).md5(pass)) hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "IPB > 2.0.0, myBB > 1.2.0\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    char *s;

    if (!hashline) return hash_err;
    if (strlen(hashline)<2) return hash_err;

    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    s = strtok(line, ":");
    if (!s) return hash_err;
    strncpy(username,s ,HASHFILE_MAX_LINE_LENGTH-2);
    username[HASHFILE_MAX_LINE_LENGTH-1]=0;
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);
    }
    // Definitely not a salted hash
    else
    {
	return hash_err;
    }
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(salt, temp_str);
	if (strlen(salt)>5) return hash_err;
    }
    else
    {
    	strcpy(salt, hash);
    	if (strlen(salt)>5) return hash_err;
	strcpy(hash,username);
	strcpy(username,"N/A");
    }

    /* Hash is not 32 characters long => not a md5 hash */
    if (strlen(hash)!=32)
    {
	return hash_err;
    }

    (void)hash_add_username(username);
    hex2str(line2, hash, 32);
    (void)hash_add_hash(line2, 16);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{

    char *hash1[VECTORSIZE];
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    char *hash4[VECTORSIZE];
    char *hash5[VECTORSIZE];
    char *hash6[VECTORSIZE];
    int a,b,c;
    

    for (a=0;a<vectorsize;a++) 
    {
	hash1[a] = alloca(74);
	hash2[a] = alloca(74);
	hash3[a] = alloca(74);
	hash4[a] = alloca(74);
	hash5[a] = alloca(74);
	hash6[a] = alloca(74);
	strcpy(hash1[a],salt);
    }
    
    b = strlen(salt);
    c = strlen(password[0]);

    (void)hash_md5((const char **)hash1, hash2, b, THREAD_LENPROVIDED);
    (void)hash_md5_hex((const char **)hash2, hash3);
    (void)hash_md5((const char **)password, hash4, c, THREAD_LENPROVIDED);
    (void)hash_md5_hex((const char **)hash4, hash5);
    for (a=0;a<vectorsize;a++)
    {
	memcpy(hash6[a], hash3[a],32);
	memcpy(&hash6[a][32], hash5[a], 32);
    }
    (void)hash_md5_slow((const char **)hash6, salt2, 64, THREAD_LENPROVIDED);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}

    return hash_err;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{

    char *hash1[VECTORSIZE];
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    char *hash4[VECTORSIZE];
    char *hash5[VECTORSIZE];
    char *hash6[VECTORSIZE];
    int a,b;
    

    for (a=0;a<vectorsize;a++) 
    {
	hash1[a] = alloca(74);
	hash2[a] = alloca(74);
	hash3[a] = alloca(74);
	hash4[a] = alloca(74);
	hash5[a] = alloca(74);
	hash6[a] = alloca(74);
	strcpy(hash1[a],salt);
    }
    
    b = strlen(salt);

    (void)hash_md5((const char **)hash1, hash2, b, THREAD_LENPROVIDED);
    (void)hash_md5_hex((const char **)hash2, hash3);
    (void)hash_md5_slow((const char **)password, hash4, THREAD_SALTPROVIDED, threadid);
    (void)hash_md5_hex((const char **)hash4, hash5);
    for (a=0;a<vectorsize;a++)
    {
	memcpy(hash6[a], hash3[a],32);
	memcpy(&hash6[a][32], hash5[a], 32);
    }
    (void)hash_md5_slow((const char **)hash6, salt2, 64, THREAD_LENPROVIDED);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}

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
    return 8;
}
