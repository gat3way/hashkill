/* joomla.c
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


char * hash_plugin_summary(void)
{
    return("joomla \t\tmd5(password,salt) plugin (joomla)");
}


char * hash_plugin_detailed(void)
{
    return("joomla - A md5(password,salt) module\n"
	    "------------------------\n"
	    "Use this module to crack md5(password,salt) hashes\n"
	    "Input should be in form: \'user:hash:salt\' or just \'hash:salt\'\n"
	    "Software that uses that password hashing method:\n"
	    "joomla > 1.0.13\n"
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
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);
    }

    /* Hash is not 32 characters long => not a md5 hash */
    if ((strlen(hash)!=32)&&(strlen(username)!=32))
    {
	return hash_err;
    }
    
    /* No hash provided at all */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }

    /* salt */
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	if (strlen(salt)>32) return hash_err;
	strcpy(salt, temp_str);
    }
    else
    {
	strcpy(salt,hash);
	strcpy(hash,username);
	strcpy(username,"N/A");
    }

    strlow(hash);
    hex2str(line2, hash, 32);
    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 16);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *saltpass[VECTORSIZE];
    int a;
    int saltlen,passlen;//,lens[VECTORSIZE];

    passlen=0;
    saltlen = strlen(salt);
    passlen = strlen(password[0]);
    for (a=0;a<vectorsize;a+=2) 
    {
	saltpass[a] = alloca(64);
	bzero(saltpass[a],64);
	memcpy(saltpass[a],(char *)password[a],passlen);
	memcpy(saltpass[a]+passlen, (char *)salt, saltlen);
	saltpass[a+1] = alloca(64);
	bzero(saltpass[a+1],64);
	passlen = strlen(password[a+1]);
	memcpy(saltpass[a+1],(char *)password[a+1],passlen);
	memcpy(saltpass[a+1]+passlen, (char *)salt, saltlen);
    }

    (void)hash_md5((const char **)saltpass, salt2, passlen+saltlen, THREAD_LENPROVIDED);

    for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,16)==0) 
    {
	*num=a;
	return hash_ok;
    }

    return hash_err;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *saltpass[VECTORSIZE];
    int lens[VECTORSIZE];
    int a;
    int saltlen,passlen;//,lens[VECTORSIZE];


    saltlen = strlen(salt);
    for (a=0;a<vectorsize;a++) 
    {
	if (password[a]==NULL) return hash_err;
	saltpass[a] = alloca(255);
	bzero(saltpass[a],128);
	lens[a]=0;
    }

    for (a=0;a<vectorsize;a++) 
    {
	passlen = strlen(password[a]);
	memcpy(saltpass[a],(char *)password[a],passlen);
	memcpy(saltpass[a]+passlen, (char *)salt, saltlen);
	lens[a] = passlen+saltlen;
    }

    (void)hash_md5_unicode((const char **)saltpass, salt2, lens);

    for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,16)==0) 
    {
	*num=a;
	return hash_ok;
    }

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
    return 34;
}
