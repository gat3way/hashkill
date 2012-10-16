/* django256.c
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
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;


extern int b64_ntop(unsigned char const *src, size_t srclength, char *target, size_t targsize);
extern int b64_pton(char const *src, unsigned char *target, size_t targsize);


char * hash_plugin_summary(void)
{
    return("django256 \tDjango SHA-256 plugin");
}


char * hash_plugin_detailed(void)
{
    return("django256 - Django SHA-256 plugin\n"
	    "------------------------\n"
	    "Use this module to crack Django SHA-256 passwords\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Django\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char myhash[200];
    char mysalt[100];
    char *temp_str=NULL;
    char *temp_str2=NULL;
    int rounds;
    
    bzero(myhash,200);
    bzero(mysalt,100);
    
    if (!hashline) return hash_err;
    if (!strstr(hashline,"pbkdf2_sha256")) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    if (strstr(line,":"))
    {
	strcpy(username, strtok(line, ":"));
	temp_str=strtok(NULL,":");
    }
    else strcpy(username,"N/A");
    
    if (temp_str)
    {
	strcpy(hash, temp_str);
	strcpy(myhash,hash);
	if (memcmp(myhash, "pbkdf2_sha256", 13)!=0) return hash_err;
	(void)hash_add_username(username);
	(void)hash_add_hash(myhash, 0);
	temp_str2=strtok(myhash,"$");
	if (!temp_str2) return hash_err;
	temp_str2=strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	rounds=atoi(temp_str2);
	if (rounds==0) return hash_err;
	temp_str2=strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	sprintf(mysalt,"%08d****%s",rounds,temp_str2);
	(void)hash_add_salt(mysalt);
    }
    else
    {
	strcpy(myhash,line);
	if (memcmp(myhash, "pbkdf2_sha256", 13)!=0) return hash_err;
	(void)hash_add_username("N/A");
	(void)hash_add_hash(myhash, 0);
	temp_str2=strtok(myhash,"$");
	if (!temp_str2) return hash_err;
	temp_str2=strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	rounds=atoi(temp_str2);
	if (rounds==0) return hash_err;
	temp_str2=strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	sprintf(mysalt,"%08d****%s",rounds,temp_str2);
	(void)hash_add_salt(mysalt);
    }
    (void)hash_add_salt2("");
    return hash_ok;
}

extern int b64_ntop(unsigned char const *src, size_t srclength, char *target, size_t targsize);

hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *dest[VECTORSIZE];
    int a;
    char myhash[64];
    char mysalt[12];
    int rounds,len,len1;

    strcpy(myhash,hash+33);
    rounds=atoi(salt);
    memcpy(mysalt,salt+12,12);
    len=strlen(password[0]);
    len1=strlen(myhash)-1;

    for (a=0;a<vectorsize;a++) 
    {
	dest[a] = alloca(128);
	hash_pbkdf2_256_len(password[a], len, (unsigned char *)mysalt, 12, rounds, 32, (unsigned char *)dest[a]);
	b64_ntop((const unsigned char *)dest[a], 32, salt2[a], 128);
	if (fastcompare((const char *)salt2[a],myhash,len1)==0) {*num=a;return hash_ok;}
    }
    return hash_err;
}

hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *dest[VECTORSIZE];
    int a;
    char myhash[64];
    char mysalt[12];
    int rounds,len;

    strcpy(myhash,hash+33);
    rounds=atoi(salt);
    memcpy(mysalt,salt+12,12);
    len=strlen(myhash)-1;

    for (a=0;a<vectorsize;a++) 
    {
	dest[a] = alloca(128);
	hash_pbkdf2_256_len(password[a], strlen(password[a]), (unsigned char *)mysalt, 12, rounds, 32, (unsigned char *)dest[a]);
	b64_ntop((const unsigned char *)dest[a], 32, salt2[a], 128);
	if (fastcompare((const char *)salt2[a],myhash,len)==0) {*num=a;return hash_ok;}
    }
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
    return 25;
}

