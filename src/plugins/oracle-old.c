/* oracle-old.c
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

unsigned char deskey[8];


int vectorsize;

char * hash_plugin_summary(void)
{
    return("oracle-old \tOracle 7 up to 10r2 plugin");
}


char * hash_plugin_detailed(void)
{
    return("oracle-old - Oracle 7 up to 10r2 plugin\n"
	    "-------------------------------\n"
	    "Use this module to crack Oracle (up to 11g) password hashes\n"
	    "Input should be in form: \'user:hash\'\n"
	    "user/hash can be retrieved via a query like:\n"
	    "SELECT name,password FROM SYS.USER$ WHERE name='...'\n"
	    "Known software that uses this password hashing method:\n\n"
	    "Oracle 7 to 10r2 \n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char *hash = alloca(HASHFILE_MAX_LINE_LENGTH);
    char *hash2 = alloca(HASHFILE_MAX_LINE_LENGTH);
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *line2 = alloca(HASHFILE_MAX_LINE_LENGTH);
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

    /* Hash is not 16 characters long => not a oracle hash */
    if (strlen(hash) != 16)
    {
	return hash_err;
    }

    hash2 = strlow(hash);
    hex2str(line2, hash2, 16);

    /* No hash provided at all */
    if (strcmp(username,"")==0)
    {
	return hash_err;
    }

    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 8);
    (void)hash_add_salt(" ");
    (void)hash_add_salt2("");

    deskey[0] = 0x01;
    deskey[1] = 0x23;
    deskey[2] = 0x45;
    deskey[3] = 0x67;
    deskey[4] = 0x89;
    deskey[5] = 0xab;
    deskey[6] = 0xcd;
    deskey[7] = 0xef;

    return hash_ok;
}



hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char *hash2[VECTORSIZE];
    unsigned char *hash3[VECTORSIZE];
    int cnt[VECTORSIZE];
    int a,b,cnt2;
    unsigned char *zerokey[VECTORSIZE];
    unsigned char *zerokey1[VECTORSIZE];
    unsigned char *initkeys[VECTORSIZE];
    
    b = strlen(username);
    for (a=0;a<vectorsize;a++)
    {
	cnt[a]=0;
	hash2[a]=alloca(64);
	hash3[a]=alloca(64);
	zerokey[a]=alloca(16);
	zerokey1[a]=alloca(16);
	initkeys[a]=alloca(16);
	bzero(zerokey[a],8);
	bzero(zerokey1[a],8);
	memcpy(initkeys[a], "\x01\x23\x45\x67\x89\xab\xcd\xef",8);
	memcpy(hash2[a], username, b);
	memcpy(hash2[a]+b, password[a], strlen(password[a]));
	cnt[a] = b+strlen(password[a]);
	hash2[a][cnt[a]] = 0;
	memcpy((char *)hash3[a],(char *)strupr((char *)hash2[a]),cnt[a]);
	bzero(hash2[a],32);
    }
    
    
    /* convert to UTF16BE */
    for (a=0;a<vectorsize;a++)
    for (cnt2=0;cnt2<cnt[a];cnt2++)
    {
        hash2[a][cnt2*2+1] =  hash3[a][cnt2];
        //hash2[a][cnt2*2] = 0;
    }
    for (a=0;a<vectorsize;a++) cnt[a] = cnt[a]<<1;
    
    hash_des_cbc_encrypt((const unsigned char **)initkeys, 8, (const unsigned char **)hash2, cnt, hash3, zerokey, 0);
    hash_des_cbc_encrypt((const unsigned char **)zerokey, 8, (const unsigned char **)hash2, cnt, hash3, zerokey1, 0);

    for (a=0;a<vectorsize;a++) if (memcmp(zerokey1[a], hash,8)==0) 
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
    return 2;
}

