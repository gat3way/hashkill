/* oracle11g.c
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
    return("oracle11g \tOracle 11g plugin");
}


char * hash_plugin_detailed(void)
{
    return("oracle11g - Oracle 11g plugin\n"
	    "-------------------------------\n"
	    "Use this module to crack Oracle 11g password hashes\n"
	    "Input should be in form: \'user:spare4\'\n"
	    "spare4 can be taken via a query like:\n"
	    "SELECT name,spare4 from sys.user$ WHERE name='user'\n"
	    "Known software that uses this password hashing method:\n\n"
	    "Oracle 11g \n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char *hash = alloca(HASHFILE_MAX_LINE_LENGTH);
    char *hash2 = alloca(HASHFILE_MAX_LINE_LENGTH);
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *line2 = alloca(HASHFILE_MAX_LINE_LENGTH);
    char hashedline[40];
    char saltline[21];
    char *temp_str;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(hashline, ":"));

    temp_str=strtok(NULL,":");
    

    /* Hash is not 60 characters long => not a oracle hash */
    if (!temp_str) return hash_err;
    strcpy(hash, temp_str);
    if (strlen(hash)!=60)
    {
	return hash_err;
    }
    

    hash2 = strlow(hash);
    hex2str(line2, hash2, 60);
    memcpy(hashedline,line2,20);
    //memcpy(saltline,line2+20,10);
    memcpy(saltline,hash2+40,20);
    //saltline[10] = 0;
    saltline[20] = 0;


    (void)hash_add_username(username);
    (void)hash_add_hash(hashedline, 20);
    (void)hash_add_salt(saltline);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    int lens[VECTORSIZE];
    int a;
    char saltc[10];

    hex2str(saltc, (char *)salt, 20);

    for (a=0;a<vectorsize;a++) 
    {
	hash2[a] = alloca(64);
	bzero(hash2[a],40);
	memcpy(hash2[a], password[a], strlen(password[a]));
	memcpy(hash2[a]+strlen(password[a]), saltc,10);
	lens[a] = strlen(password[a])+10;
    }
    (void)hash_sha1_unicode((const char **)hash2, salt2, lens);
    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,20)==0) {*num=a;return hash_ok;}
    return hash_err;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash2[VECTORSIZE];
    int lens[VECTORSIZE];
    int a;
    char saltc[10];

    hex2str(saltc, (char *)salt, 20);

    for (a=0;a<vectorsize;a++) 
    {
	hash2[a] = alloca(64);
	memcpy(hash2[a], password[a], strlen(password[a]));
	memcpy(hash2[a]+strlen(password[a]), saltc,10);
	lens[a] = strlen(password[a])+10;
    }
    (void)hash_sha1_slow((const char **)hash2, salt2, lens);
    for (a=0;a<vectorsize;a++) if (fastcompare((const char *)salt2[a],hash,20)==0) {*num=a;return hash_ok;}
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
    return 21;
}