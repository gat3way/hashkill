/* bfunix.c
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

#include <crypt.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


int vectorsize;


extern char *__bf_crypt_r (const char *key[VECTORSIZE], unsigned int *salt,
                            char *buffer[VECTORSIZE], int buflen[VECTORSIZE], int vectorsize,unsigned int *hash);
extern void __bf_decode(unsigned int *dst,unsigned char *src, int size);
extern void __bf_swap(unsigned int *x, int count);


char * hash_plugin_summary(void)
{
    return("bfunix \t\tbcrypt (Blowfish) plugin");
}


char * hash_plugin_detailed(void)
{
    return("bfunix - bcrypt (Blowfish) plugin\n"
	    "------------------------\n"
	    "Use this module to crack shadow passwords\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'. shadow files are acceptable\n"
	    "Known software that uses this password hashing method:\n"
	    "SUSE-based distributions, some Unix-like operating systems\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH*4];
    char hash[HASHFILE_MAX_LINE_LENGTH*4];
    char salt[HASHFILE_MAX_LINE_LENGTH*4];
    char line[HASHFILE_MAX_LINE_LENGTH*4];
    char line2[HASHFILE_MAX_LINE_LENGTH*4];
    char line3[HASHFILE_MAX_LINE_LENGTH*4];
    char line4[HASHFILE_MAX_LINE_LENGTH*4];
    char *temp_str, *temp_str2 = NULL;
    int rounds,a;

    if (!hashline) return hash_err;
    if (strlen(hashline)<5) return hash_err;
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str = strtok(NULL,":");
    if (temp_str) 
    {
	if (strlen(temp_str)<2) return hash_err;
	strcpy(line2, temp_str);
	strcpy(line3, temp_str);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(temp_str, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	if (strlen(temp_str)!=2) return hash_err;
	if ((temp_str[0]!='2')) return hash_err;
	if ((temp_str2[0] < '0') || (temp_str2[0] > '9')) return hash_err;
	if ((temp_str2[1] < '0') || (temp_str2[1] > '9')) return hash_err;
	rounds = atoi(temp_str2);
	if ((rounds<4)||(rounds>31)) return hash_err;
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	strcpy(hash,line3);
	temp_str2[22]=0;
	sprintf(salt,"%02d%s",rounds,temp_str2);
	salt[31]=0;
    }
    else
    {
	strcpy(line2, username);
	strcpy(line4, username);
	temp_str2 = strtok(line2,"$");
	if (!temp_str2) return hash_err;
	strcpy(line3, temp_str2);
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	if (strlen(line3)!=2) return hash_err;
	if ((line3[0]!='2')) return hash_err;
	if ((temp_str2[0] < '0') || (temp_str2[0] > '9')) return hash_err;
	if ((temp_str2[1] < '0') || (temp_str2[1] > '9')) return hash_err;
	rounds = atoi(temp_str2);
	if ((rounds<4)||(rounds>31)) return hash_err;
	temp_str2 = strtok(NULL,"$");
	if (!temp_str2) return hash_err;
	strcpy(hash,line4);
	strcpy(username,"N/A");
	temp_str2[22]=0;
	sprintf(salt,"%02d%s",rounds,temp_str2);
	salt[31]=0;
    }

    /* No hash provided at all? */
    if (strcmp(username,hashline)==0)
    {
	return hash_err;
    }
    /* ensure they aren't smashing the heap?!?*/
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",username);
    line2[HASHFILE_MAX_LINE_LENGTH-1] = 0;
    (void)hash_add_username(line2);
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",hash);
    line2[HASHFILE_MAX_LINE_LENGTH-1] = 0;
    (void)hash_add_hash(line2, 0);
    snprintf(line2,HASHFILE_MAX_LINE_LENGTH-3,"%s",salt);
    line2[HASHFILE_MAX_LINE_LENGTH-1] = 0;
    (void)hash_add_salt(line2);
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int a,b;
    int len[VECTORSIZE];
    char *hash2, *data;
    unsigned int mysalt[6];
    char rounds[3];
    unsigned int binary[8];

    // set salt 
    rounds[0]=salt[0];
    rounds[1]=salt[1];
    rounds[2]=0;
    rounds[3]=0;
    __bf_decode(mysalt, salt+2, 16);
    __bf_swap(mysalt, 4);
    mysalt[4]=(1 << atoi(rounds));

    // set binary 
    binary[5] = 0;
    __bf_decode(binary, hash+29, 23);
    __bf_swap(binary, 6);
    binary[5] &= ~(unsigned int)0xFF;

    __bf_crypt_r(password, mysalt, salt2, len, vectorsize,binary);

    for (a=0;a<vectorsize;a++) 
    if (salt2[a][0]=='!')
    {
        *num=a;
        salt2[a][0]=0;
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
    return 64;
}
