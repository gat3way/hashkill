/* samsungpin.c
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
#include <stdint.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;

char * hash_plugin_summary(void)
{
    return("samsungpin \tSamsung Anrdoid PIN lock plugin");
}


char * hash_plugin_detailed(void)
{
    return("samsungpin - Samsung Android PIN lock plugin\n"
	    "-------------------------------\n"
	    "Use this module to crack Samsung PINs\n"
	    "Input should be in form: \'hash:salt\'\n"
	    "Known software that uses this password hashing method:\n"
	    "Android OS\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    uint64_t seed;
    char *end;


    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(hash, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(salt, temp_str);
    }

    /* Hash is not 40 characters long => not a smf hash */
    if (strlen(hash)!=40)
    {
	return hash_err;
    }
    
    /* No hash provided at all */
    if (strcmp(hash,hashline)==0)
    {
	return hash_err;
    }
    
    strlow(hash);
    hex2str(line2, hash, 40);
    (void)hash_add_username("PIN");
    (void)hash_add_hash(line2, 20);
    seed = strtoull(salt,&end,10);
#pragma GCC diagnostic ignored "-Wformat"
    sprintf(line2,"%016llx",seed);
    (void)hash_add_salt(line2);
    (void)hash_add_salt2("");

    return hash_ok;
}


int port_itoa(int val, char* buf, const unsigned int radix)
{
    char* p;
    unsigned int a;
    int len;
    char* b;
    char temp;
    unsigned int u;

    p = buf;
    if (val < 0)
    {
        *p++ = '-';
        val = 0 - val;
    }
    u = (unsigned int)val;
    b = p;
    do
    {
        a = u % radix;
        u /= radix;
        *p++ = a + '0';
    } while (u > 0);
    len = (int)(p - buf);
    *p-- = 0;
    do
    {
        temp = *p;
        *p = *b;
        *b = temp;
        --p;
        ++b;

    } while (b < p);
    return len;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *hash1[VECTORSIZE];
    char *hash2[VECTORSIZE];
    char iter[32];
    int a,b;
    int lens[VECTORSIZE];
    int passlen,saltlen,len;


    saltlen = strlen(salt);
    for (a=0;a<vectorsize;a++)
    {
	passlen = strlen(password[a]);
	hash1[a] = alloca(64);
	hash2[a] = alloca(64);
	memset(hash1[a],0,64);
	hash1[a][0]='0';
	memcpy(hash1[a]+1,password[a],passlen);
	memcpy(hash1[a]+1+passlen,salt,saltlen);
	lens[a] = 1+passlen+saltlen;
    }
    hash_sha1_slow((const char**)hash1,hash2,lens);

    for (b=1;b<1024;b++)
    {
	port_itoa(b, iter, 10);
	len = strlen(iter);
	for (a=0;a<vectorsize;a++)
	{
	    memset(hash1[a],0,64);
	    memcpy(hash1[a],hash2[a],20);
	    memcpy(hash1[a]+20,iter,len);
	    passlen = strlen(password[a]);
	    memcpy(hash1[a]+20+len,password[a],passlen);
	    memcpy(hash1[a]+20+len+passlen,salt,saltlen);
	    lens[a] = 20+len+passlen+saltlen;
	}
	(void)hash_sha1_slow((const char **)hash1, hash2, lens);
    }
    for (a=0;a<vectorsize;a++) if (fastcompare(hash2[a], hash,20)==0) {*num=a;return hash_ok;}
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
    return 20;
}
