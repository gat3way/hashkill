/* mediawiki.c
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
    return("mediawiki \tmd5(salt.'-'.md5(password)) plugin (Wikimedia)");
}


char * hash_plugin_detailed(void)
{
    return("mediawiki - A md5(salt.'-'.md5(password)) module\n"
	    "------------------------\n"
	    "Use this module to crack Wikimedia type A and B hashes\n"
	    "Both type A and B types of hashes are supported.\n"
	    "Input should be in Wikimedia form: A:hash (or user:A:hash) or B:salt:hash (or user:B:salt:hash) '\n"
	    "Software that uses that password hashing method:\n"
	    "MediaWiki\n"
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
    strcpy(salt,"");

    strcpy(username, strtok(line, ":"));

    /* OK, that is an username */
    if (strlen(username)>1) 
    {
	temp_str=strtok(NULL,":");
	if (temp_str) 
	{
	    /* type A */
	    if (temp_str[0]=='A')
	    {
		temp_str=strtok(NULL,":");
		if (temp_str) strcpy(hash, temp_str);
		else return hash_err;
	    }
	    else if (temp_str[0]=='B')
	    {
		temp_str=strtok(NULL,":");
		if (temp_str)
		{
		    strcpy(salt, temp_str);
		    temp_str=strtok(NULL,":");
		    if (temp_str) strcpy(hash, temp_str);
		}
	    
	    }
	}
	else return hash_err;
    }
    /* Nope, not an username */
    else
    {
        /* type A */
        if (username[0]=='A')
        {
    	    temp_str=strtok(NULL,":");
	    if (temp_str) strcpy(hash, temp_str);
	    else return hash_err;
	}
	else if (username[0]=='B')
	{
	    temp_str=strtok(NULL,":");
	    if (temp_str)
	    {
	        strcpy(salt, temp_str);
	        temp_str=strtok(NULL,":");
	        if (temp_str) strcpy(hash, temp_str);
	    }
	}
	else return hash_err;
        strcpy(username,"N/A");
    }
    
    /* Hash is not 32 characters long => not a md5 hash */
    if ((strlen(hash)!=32)&&(strlen(username)!=32))
    {
	return hash_err;
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
    char *saltpass2[VECTORSIZE];
    char *saltpass3[VECTORSIZE];

    int a;
    int saltlen,templen;
    int lens[VECTORSIZE];
    char dash='-';

    saltlen = strlen(salt);

    /* Type A hash */
    if (saltlen==0)
    {
	for (a=0;a<vectorsize;a++) 
	{
	    lens[a]=strlen(password[a]);
	    saltpass[a]=alloca(64);
	    bzero(saltpass[a],64);
	    memcpy(saltpass[a],password[a],strlen(password[a]));
	}
	(void)hash_md5_unicode((const char **)saltpass, salt2, lens);
	for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}
	return hash_err;
    }

    /* Type B hash */
    for (a=0;a<vectorsize;a++) 
    {
	saltpass[a]=alloca(64);
	saltpass2[a] = alloca(16);
	saltpass3[a] = alloca(32);
	bzero(saltpass[a],64);
	memcpy(saltpass[a],password[a],strlen(password[a]));
	lens[a]=strlen(password[a]);
    }
    (void)hash_md5_unicode((const char **)saltpass, saltpass2, lens);
    hash_md5_hex((const char **)saltpass2,  saltpass3);

    for (a=0;a<vectorsize;a++) 
    {
	templen=saltlen;
	memcpy(saltpass[a],salt,templen);
	memcpy(saltpass[a]+templen, &dash, 1);
	templen++;
	memcpy(saltpass[a]+templen, saltpass3[a], 32);
	templen+=32;
	lens[a] = templen;
    }
    (void)hash_md5_unicode((const char **)saltpass, salt2, lens);
    
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
    return 32;
}

