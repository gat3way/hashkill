/* o5logon.c
 *
 * hashkill - a hash cracking tool
 * Copyright (C) 2012 Alex Stanev <alex@stanev.org>
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
 *
 * 
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
    return("o5logon \tOracle TNS O5logon");
}


char * hash_plugin_detailed(void)
{
    return("o5logon - TNS O5logon session,salt\n"
	    "------------------------\n"
	    "Use this module to crack TNS login sessions\n"
	    "Input should be in form: \'dbuser:AUTH_SESSKEY:AUTH_VFR_DATA\'\n"
	    "JtR-compatible input format also accepted\n"
	    "Software that uses that password hashing method:\n"
	    "oracle 11g \n"
	    "\nAuthor: Alex Stanev <alex@stanev.org>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char line2[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str;
    int a;

    if (!hashline) return hash_err;
    if (strlen(hashline)<116) return hash_err;
    
    /* Handle JTR format input */
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    if (strstr(line,"$o5logon$"))
    {
	temp_str = strtok(line,"$");
	strcpy(line2,temp_str);
	temp_str = strtok(NULL,"$");
	temp_str = strtok(NULL,"$");
	strcat(line2,temp_str);
	bzero(line,HASHFILE_MAX_LINE_LENGTH-1);
	for (a=0;a<strlen(line2);a++)
	{
	    if (line2[a]=='*') line[a]=':';
	    else line[a]=line2[a];
	}
    }

    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);
    }

    /* Hash is not 96 characters long => not oracle session */
    if (strlen(hash)!=96)
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
	strcpy(salt, temp_str);
    }
    else
    {
	strcpy(salt,hash);
	strcpy(hash,username);
	strcpy(username,"N/A");
    }

    /* Salt is not 20 characters long => not oracle salt */
    if (strlen(salt)!=20)
    {
	return hash_err;
    }

    strlow(hash);
    strlow(salt);
    hex2str(line2, hash, 96);
    //hex2str(line3, salt, 20);
    (void)hash_add_username(username);
    (void)hash_add_hash(line2, 48);
    (void)hash_add_salt(salt);
    (void)hash_add_salt2("");

    return hash_ok;
}

hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *saltpass[VECTORSIZE];
    int a;
    char *key[VECTORSIZE] = {0};
    unsigned char iv[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    unsigned char plaintext[64];
    int isok = hash_err;
    char raw_salt[10];
    AES_KEY akey;
    int lens[VECTORSIZE];
    int len;

    hex2str(raw_salt, (char *)salt, 20);

    len=strlen(password[0]);
    for (a=0;a<vectorsize;a++)
    {
        saltpass[a]=alloca(32);
        key[a]=alloca(24);
        memset(key[a]+20,0,4);
        memset(saltpass[a],0,32);
        memcpy(saltpass[a], password[a],len);
        lens[a]=len;
        memcpy(saltpass[a]+lens[a], raw_salt, 10);
        lens[a]+=10;
    }

    hash_sha1_unicode((const char **)saltpass,key,lens);
    for (a=0;a<vectorsize;a++)
    {
	hash_aes_set_decrypt_key((unsigned char *)key[a], 192, &akey);
	hash_aes_cbc_encrypt((unsigned char *)hash+16, plaintext+16, 32, &akey, iv, AES_DECRYPT);
        if (memcmp(plaintext+40, "\x08\x08\x08\x08\x08\x08\x08\x08", 8) == 0) 
        {
            isok = hash_ok;
            *num = a;
            break;
        }
    }
    return isok;
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    char *saltpass[VECTORSIZE];
    int a;
    char *key[VECTORSIZE] = {0};
    unsigned char iv[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    unsigned char plaintext[64];
    int isok = hash_err;
    char raw_salt[10];
    AES_KEY akey;
    int lens[VECTORSIZE];

    hex2str(raw_salt, (char *)salt, 20);

    for (a=0;a<vectorsize;a++)
    {
        saltpass[a]=alloca(48);
        key[a]=alloca(24);
        memset(key[a]+20,0,4);
        memset(saltpass[a],0,48);
        strcpy(saltpass[a], password[a]);
        lens[a]=strlen(password[a]);
        memcpy(saltpass[a]+lens[a], raw_salt, 10);
        lens[a]+=10;
    }

    hash_sha1_slow((const char **)saltpass,key,lens);
    for (a=0;a<vectorsize;a++)
    {
	hash_aes_set_decrypt_key((unsigned char *)key[a], 192, &akey);
	hash_aes_cbc_encrypt((unsigned char *)hash+16, plaintext+16, 32, &akey, iv, AES_DECRYPT);
        if (memcmp(plaintext+40, "\x08\x08\x08\x08\x08\x08\x08\x08", 8) == 0) 
        {
            isok = hash_ok;
            *num = a;
            break;
        }
    }
    return isok;
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
