/* privkey.c
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


char myfilename[255];
int vectorsize;

char * hash_plugin_summary(void)
{
    return("privkey \tSSH/SSL private key passphrase plugin");
}


char * hash_plugin_detailed(void)
{
    return("privkey - SSH/SSL private key passphrase plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack private key passphrases\n"
	    "Input should be a RSA/DSA private key file specified with -f\n"
	    "Known software that uses this password hashing method:\n"
	    "Apache-SSL, OpenSSH, OpenVPN, etc.\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    FILE *myfile;
    char buf[1024];

    myfile = fopen(filename, "r");
    if (!myfile) return hash_err;
    fgets(buf,1024,myfile);
    fclose(myfile);
    if (!strstr(buf,"-BEGIN"))
    {
	return hash_err;
    }
    myfile = fopen(filename, "r");
    if (!myfile) return hash_err;
    hash_new_biomem(myfile);
    fclose(myfile);
    strcpy(myfilename, filename);
    (void)hash_add_username(filename);
    (void)hash_add_hash("Private key   \0",0);
    (void)hash_add_salt("123");
    (void)hash_add_salt2("                              ");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char * salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int smth,v;
    
    // Assuming vectorsize=1 PLEASE DO NOT CHANGE!
    for (v=0;v<vectorsize;v++)
    {
	(void)hash_PEM_readfile(password[v], &smth);
	if (smth==1) 
	{
	    memcpy(salt2[v],"Private key   \0\0", 15);
	    *num=v;
	    return hash_ok;
	}
    }
    return hash_err;
}


int hash_plugin_hash_length(void)
{
    return 14;
}

int hash_plugin_is_raw(void)
{
    return 0;
}

int hash_plugin_is_special(void)
{
    return 1;
}

void get_vector_size(int size)
{
    vectorsize = size;
}

int get_salt_size(void)
{
    return 1;
}
