/* mssql-2012.c
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
#include <alloca.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;

char * hash_plugin_summary(void)
{
    return("mssql-2012 \tMicrosoft SQL Server 2012 plugin");
}


char * hash_plugin_detailed(void)
{
    return("mssql-2012 - Microsoft SQL Server 2012 plugin\n"
	    "------------------------\n"
	    "Use this module to crack MS-SQL 2012 pwdencrypt() hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Microsoft SQL Server 2012\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[256];
    char *hash = alloca(256);
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *line2 = alloca(256);
    char *temp_str;

    if (!hashline) return hash_err;
    if (strlen(hashline)>256) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str = strtok(NULL,":");
    if (!temp_str)
    {
	temp_str = alloca(256);
	strcpy(temp_str,username);
	strcpy(username,"N/A");
    }
    

    /* Bad constant header */
    if (!strstr(temp_str,"0x0200"))
    {
	return hash_err;
    }

    /* Bad hash */
    if (strlen(temp_str)!=142)
    {
	return hash_err;
    }

    (void)hash_add_username(username);
    strcpy(line2,strlow(temp_str));

    /* Skip header, add salt, skip case-sensitive hash, get uppercase one */
    strcpy(line, line2+14);
    line[128] = 0;
    hex2str(hash, line, 128);
    (void)hash_add_hash((char *)hash, 64);

    strncpy(line, line2+6, 8);
    line[8]=0;
    (void)hash_add_salt(line);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int cnt;
    char *newpass[VECTORSIZE];
    int intsalt;
    unsigned int t;
    unsigned char x;
    int a;
    int lens[VECTORSIZE];


    for (a=0;a<vectorsize;a++)
    {
	newpass[a] = alloca(128);
	bzero(newpass[a],64);
	for (cnt=0;cnt<strlen(password[a]);cnt++)
	{
	    newpass[a][cnt*2] = password[a][cnt];
	    newpass[a][(cnt*2)+1] = 0;
	}
	cnt *= 2;

	// add salt
	intsalt = strtol(salt, NULL, 16);
	t = intsalt >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 8;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 16;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 24;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	lens[a] = cnt;
    }
    (void)hash_sha512_unicode((const char **)newpass, salt2, lens);
    
    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,64)==0) {*num=a;return hash_ok;}
    
    return hash_err;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int cnt;
    char *newpass[VECTORSIZE];
    int intsalt;
    unsigned int t;
    unsigned char x;
    int a;
    int lens[VECTORSIZE];


    for (a=0;a<vectorsize;a++) newpass[a] = alloca(128);

    for (a=0;a<vectorsize;a++)
    {
	newpass[a] = alloca(128);
	for (cnt=0;cnt<strlen(password[a]);cnt++)
	{
	    newpass[a][cnt*2] = password[a][cnt];
	    newpass[a][(cnt*2)+1] = 0;
	}
	cnt *= 2;

	// add salt
	intsalt = strtol(salt, NULL, 16);
	t = intsalt >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 8;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 16;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	t = intsalt << 24;
	t = t >> 24;
	x = (unsigned char) t;
	newpass[a][cnt]=x;
	cnt++;
	lens[a] = cnt;
    }
    (void)hash_sha512_unicode((const char **)newpass, salt2, lens);

    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,64)==0) {*num=a;return hash_ok;}

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
    return 16;
}