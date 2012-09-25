/* mscash.c
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
    return("mscash \t\tDomain cached credentials plugin");
}


char * hash_plugin_detailed(void)
{
    return("mscash - Domain cached credentials plugin\n"
	    "------------------------\n"
	    "Use this module to crack Domain cached credentials hashes\n"
	    "Input should be in form: \'user:hash\''\n"
	    "Known software that uses this password hashing method:\n"
	    "Microsoft Windows\n"
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
    }
    else return hash_err;
    /* Hash is not 32 characters long => not a mscash hash */
    if ((strlen(hash)!=32))
    {
        return hash_err;
    }


    strlow(hash);
    hex2str(line2, hash, 32);

    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 16);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2("");

    return hash_ok;
}




hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *newpass[VECTORSIZE];
    char newuser[VECTORSIZE];
    char *combined[VECTORSIZE];
    char *intermediate[VECTORSIZE];

    int lens[VECTORSIZE];
    int lensu;

    int a,b,sz;
    
    /* Convert password to unicode(password) */
    for (b=0;b<vectorsize;b++)
    {
	newpass[b] = alloca(128);
	combined[b] = alloca(128);
	intermediate[b] = alloca(128);
	sz = strlen(password[b]);
	for (a=0;a<sz;a++)
	{
	    newpass[b][(a*2)+1]=0;
	    newpass[b][a*2] = password[b][a];
	}
	lens[b] = sz*2;
    }

    (void)hash_md4_slow((const char **)newpass, intermediate, lens,0);

    /* Convert username to unicode(strlow(username)), copy intermediate to combined */
    lensu=strlen(username)*2;
    sz = strlen(username);
    for (a=0;a<sz;a++)
    {
        newuser[(a*2)+1]=0;
        newuser[a*2] = username[a];
    }
    for (b=0;b<vectorsize;b++)
    {
	memcpy(combined[b],intermediate[b],16);
	memcpy(combined[b]+16,newuser,lensu);
	lens[b]=16+lensu;
    }
    (void)hash_md4_slow((const char **)combined, salt2, lens,0);

    for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}

    return hash_err;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *newpass[VECTORSIZE];
    char newuser[VECTORSIZE];
    char *combined[VECTORSIZE];
    char *intermediate[VECTORSIZE];
    int lens[VECTORSIZE];
    int lensu;
    int a,b,sz;

    sz=strlen(password[0]);

    /* Convert password to unicode(password) */
    for (b=0;b<vectorsize;b++)
    {
	newpass[b] = alloca(128);
	combined[b] = alloca(128);
	intermediate[b] = alloca(128);
	for (a=0;a<sz;a++)
	{
	    newpass[b][(a*2)+1]=0;
	    newpass[b][a*2] = password[b][a];
	}
    }

    (void)hash_md4_unicode((const char **)newpass, intermediate, sz*2,0);

    /* Convert username to unicode(strlow(username)), copy intermediate to combined */
    lensu=strlen(username)*2;
    sz = strlen(username);
    for (a=0;a<sz;a++)
    {
        newuser[(a*2)+1]=0;
        newuser[a*2] = username[a];
    }
    for (b=0;b<vectorsize;b++)
    {
	memcpy(combined[b],intermediate[b],16);
	memcpy(combined[b]+16,newuser,lensu);
	lens[b]=16+lensu;
    }
    (void)hash_md4_slow((const char **)combined, salt2, lens,0);

    for (a=0;a<vectorsize;a++) if (memcmp((const char *)salt2[a],hash,16)==0) {*num=a;return hash_ok;}

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
    return 2;
}
