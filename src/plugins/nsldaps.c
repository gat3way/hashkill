/* nsldaps.c
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


extern int b64_ntop(unsigned char const *src, size_t srclength, char *target, size_t targsize);
extern int b64_pton(char const *src, unsigned char *target, size_t targsize);


char * hash_plugin_summary(void)
{
    return("nsldaps \tLDAP SSHA (salted SHA) plugin");
}


char * hash_plugin_detailed(void)
{
    return("nsldaps - nsldaps (salted SHA) plugin\n"
	    "------------------------\n"
	    "Use this module to crack LDAP SHA passwords\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "OpenLDAP, various LDAP implementations\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char myhash[200];
    char mysalt[100];
    int blen;
    char *temp_str=NULL;
    
    bzero(myhash,200);
    bzero(mysalt,100);
    
    if (!hashline) return hash_err;
    if (!strstr(hashline,"{SSHA}")) return hash_err;
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
	if (memcmp(myhash, "{SSHA}", 6)!=0) return hash_err;
	(void)hash_add_username(username);
	(void)hash_add_hash(myhash, 0);
	blen = b64_pton(hash+6, (unsigned char *)line2, HASHFILE_MAX_LINE_LENGTH);
	line2[blen]=0;
	memcpy(mysalt,line2+20,8);
	mysalt[8]=0;
	mysalt[9]=0;
	(void)hash_add_salt(mysalt);
    }
    else
    {
	strcpy(myhash,line);
	if (memcmp(myhash, "{SSHA}", 6)!=0) return hash_err;
	(void)hash_add_username("N/A");
	(void)hash_add_hash(myhash, 0);
	blen = b64_pton(myhash+6, (unsigned char *)line2, HASHFILE_MAX_LINE_LENGTH);
	line2[blen]=0;
	memcpy(mysalt,line2+20,8);
	mysalt[8]=0;
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
    char *salted[VECTORSIZE];
    int lens[VECTORSIZE];

    for (a=0;a<vectorsize;a++) 
    {
	salted[a]=alloca(128);
	bzero(salted[a],40);
	memcpy(salted[a],password[a], strlen(password[a]));
	memcpy(salted[a]+strlen(password[a]), salt,strlen(salt));
	dest[a] = alloca(128);
	lens[a]=strlen(password[a])+8;
    }
    
    //(void)hash_sha1((const char **)salted, dest, len, THREAD_LENPROVIDED);
    (void)hash_sha1_unicode((const char **)salted, dest, lens);
    for (a=0;a<vectorsize;a++) 
    {
	memcpy(dest[a]+20,salt,8);
	memcpy(salt2[a],"{SSHA}",6);
	b64_ntop((const unsigned char *)dest[a], 28, salt2[a]+6, 128);
    }
    for (a=0;a<vectorsize;a++) 
    {
	if (fastcompare((const char *)salt2[a],hash,strlen(hash)-1)==0) {*num=a;return hash_ok;}
    }
    return hash_err;
}

hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *dest[VECTORSIZE];
    int a;
    char *salted[VECTORSIZE];
    int lens[VECTORSIZE];
    
    for (a=0;a<vectorsize;a++) 
    {
	salted[a]=alloca(128);
	bzero(salted[a],40);
	memcpy(salted[a],password[a], strlen(password[a]));
	memcpy(salted[a]+strlen(password[a]), salt,strlen(salt));
	dest[a] = alloca(128);
	lens[a] = strlen(password[a])+strlen(salt);
    }
    
    (void)hash_sha1_unicode((const char **)salted, dest, lens);
    for (a=0;a<vectorsize;a++) 
    {
	memcpy(dest[a]+20,salt,8);
	memcpy(salt2[a],"{SSHA}",6);
	b64_ntop((const unsigned char *)dest[a], 28, salt2[a]+6, 128);
    }
    for (a=0;a<vectorsize;a++) 
    {
	if (fastcompare((const char *)salt2[a],hash,strlen(hash)-1)==0) {*num=a;return hash_ok;}
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
    return 9;
}

