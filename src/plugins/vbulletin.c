/* vbulletin.c
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
    return("vbulletin \tmd5(md5(pass).salt) plugin (vBulletin)");
}


char * hash_plugin_detailed(void)
{
    return("vbulletin - A simple md5(md5(pass).salt) plugin (vBulletin)\n"
	    "------------------------\n"
	    "Use this module to crack md5(md5(pass).salt) hashes\n"
	    "Input should be in form: \'user:hash:salt\' or just \'hash:salt\'\n"
	    "Note that the dilimiter is whitespace, not ':'\n"
	    "Known software that uses this password hashing method:\n"
	    "vBulletin, IceBB, etc\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    int a;
    
    if (!hashline) return hash_err;
    if (strlen(hashline)<32) return hash_err;

    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);


    /* first check if we have username or not */
    if (line[32]==':')
    {
	memcpy(hash,line,32);
	hash[32]=0;
	strcpy(salt,&line[33]);
	strcpy(username,"N/A");
    }
    else
    {
	a=0;
	while ((a<strlen(line))&&(line[a]!=':'))
	{
	    username[a]=line[a];
	    a++;
	}
	username[a]=0;
	memcpy(hash,&line[a],32);
	hash[32]=0;
	strcpy(salt,&line[a+33]);
    }

    int flag=0;
    for (a=0;a<strlen(hash);a++) if ( ((hash[a]<'0')||(hash[a]>'9'))&&((hash[a]<'a')||(hash[a]>'f'))) flag=1;
    if (flag==1) return hash_err;

    if (strlen(hash)!=32) return hash_err;
    if (strlen(salt)>32) return hash_err;

    (void)hash_add_username(username);
    hex2str(line2, hash, 32);
    (void)hash_add_hash(line2, 16);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    int a,b;
    
    for (a=0;a<vectorsize;a+=2)
    {
	hash2[a]=alloca(64);
	hash3[a]=alloca(64);
	hash2[a][0]=0;
	hash3[a][0]=0;
	hash2[a+1]=alloca(64);
	hash3[a+1]=alloca(64);
	hash2[a+1][0]=0;
	hash3[a+1][0]=0;
    }
    a=strlen(password[0]);

    (void)hash_md5((const char **)password, hash2, a, THREAD_LENPROVIDED);
    (void)hash_md5_hex((const char **)hash2, hash3);
    b = strlen(salt);
    for (a=0;a<vectorsize;a+=2) 
    {
	strcpy(hash3[a]+32, salt);
	strcpy(hash3[a+1]+32, salt);
    }
    (void)hash_md5_slow((const char **)hash3, salt2, 32+b, THREAD_LENPROVIDED);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}
    return hash_err;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    char *hash3[VECTORSIZE];
    int a,b;
    int lens[VECTORSIZE];
    
    for (a=0;a<vectorsize;a++)
    {
	hash2[a]=alloca(64);
	hash3[a]=alloca(64);
	hash2[a][0]=0;
	hash3[a][0]=0;
	lens[a]=strlen(password[a]);
    }

    (void)hash_md5_unicode((const char **)password, hash2, lens);
    (void)hash_md5_hex((const char **)hash2, hash3);
    b = strlen(salt);
    for (a=0;a<vectorsize;a++) strcpy(hash3[a]+32, salt);
    (void)hash_md5_slow((const char **)hash3, salt2, 32+b, THREAD_LENPROVIDED);

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
    return 33;
}
