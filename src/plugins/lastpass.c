/* lastpass.c
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


char * hash_plugin_summary(void)
{
    return("lastpass \tLastPass keychain plugin");
}


char * hash_plugin_detailed(void)
{
    return("lastpass - LastPass keychain plugin\n"
	    "------------------------\n"
	    "Use this module to crack LastPass master passwords\n"
	    "Input should be in form: \'lastpass:email:1|loginhash\' \n"
	    "You can use the lastpass2hashkill tool to scan for keychains \n"
	    "Known software that uses this password hashing method:\n"
	    "LastPass Password Manager\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char line[1024];
    char myhash[32];
    char myhash2[16];
    char mysalt[512];
    char myuser[512];
    int a;

    bzero(mysalt,512);
    
    if (!hashline) return hash_err;
    if (!strstr(hashline,"lastpass")) return hash_err;
    if (!strstr(hashline,"|")) return hash_err;
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, 511, "%s", hashline);
    line[511]=0;

    strncpy(mysalt,strtok(line,"|"),511);
    strncpy(myhash,strtok(NULL,"|"),32);

    memset(myuser,0,512);
    a=9;
    while ((mysalt[a]!=':')&&(a<512))
    {
	myuser[a-9]=mysalt[a];
	a++;
    }

    myuser[31]=0;
    hex2str(myhash2, myhash, 32);

    (void)hash_add_username(myuser);
    (void)hash_add_hash(myhash2, 16);
    (void)hash_add_salt(mysalt);
    (void)hash_add_salt2("");
    return hash_ok;
}



hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char dest[32];
    int a;
    char mysalt[512];
    char myuser[512];
    char *tok;
    char *save;
    char *verifier="lastpass rocks\x02\x02";
    int iterations;
    int len;
    AES_KEY key;
    unsigned char result[16];
    unsigned char iv[16];

    strcpy(mysalt,salt);
    tok = strtok_r(mysalt,":",&save);
    tok = strtok_r(NULL,":",&save);
    if (!tok) return hash_err;
    strcpy(myuser,tok);
    tok = strtok_r(NULL,":",&save);
    if (!tok) return hash_err;
    tok = strtok_r(NULL,":",&save);
    if (!tok) return hash_err;
    iterations = atoi(tok);
    len = strlen(myuser);

    for (a=0;a<vectorsize;a++) 
    {
	hash_pbkdf2_256_len(password[a], strlen(password[a]), (unsigned char *)myuser, len, iterations, 32, (unsigned char *)dest);
	memset(iv,0,16);
	hash_aes_set_encrypt_key((unsigned char *)dest, 256, &key);
	hash_aes_cbc_encrypt((unsigned char *)verifier, (unsigned char *)result, 16, &key, iv, AES_ENCRYPT);
	if (fastcompare((const char *)result,(const char *)hash,16)==0) 
	{
	    *num=a;
	    return hash_ok;
	}
    }
    return hash_err;
}



int hash_plugin_hash_length(void)
{
    return 16;
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
    return 512;
}

