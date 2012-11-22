/* md5.c
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
#include "plugin.h"
#include "err.h"
#include "hashinterface.h"


char * hash_plugin_summary(void)
{
    return("md5 \t\tMD5 plugin");
}


char * hash_plugin_detailed(void)
{
    return("md5 - A simple md5 plugin\n"
	    "------------------------\n"
	    "Use this module to crack simple md5 hashes\n"
	    "Input should be in form: \'user:hash\' or just \'hash\'\n"
	    "Known software that uses this password hashing method:\n"
	    "IPB < 2.0, MiniBB, phpBB < 3.0.0, Wordpress < 2.5, Joomla < 1.0.13,\n"
	    "AdaptCMS Lite 1.5, b2evolution, Beehive, CMS Made Simple, DanneoCMS,\n"
	    "CruxCMS, easyPortal, Flux CMS, Geek Log, Joomla < 1.0.13, Koobi CMS < 6.x\n"
	    "PHP-Fusion, PHP-Nuke, Serendipity < 1.4.1, Typo3, TangoCMS, XOOPS\n"
	    "DeluxeBB, IPB < 2.x, PhpMyForum, W-Agora, WoltLab BB1 and BB2, Drupal\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char *temp_str = NULL;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
	strcpy(hash, temp_str);

	/* Hash is not 32 characters long => not a md5 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}

	/* Salt could be 32 chars long, check if that is the case */
        int flag=0;
        int a;
        for (a=0;a<strlen(hash);a++) if ( ((hash[a]<'0')||(hash[a]>'9'))&&((hash[a]<'a')||(hash[a]>'f'))) flag=1;
        if (flag==1) return hash_err;

	/* No hash provided at all */
	if (strcmp(username,hashline)==0)
	{
	    return hash_err;
	}

	(void)hash_add_username(username);
	strlow(hash);
	hex2str(line, hash, 32);
	(void)hash_add_hash(line,16);
    }
    else
    {
	strcpy(hash, username);
	/* Hash is not 32 characters long => not a md5 hash */
	if (strlen(hash)!=32)
	{
	    return hash_err;
	}
    
    
	(void)hash_add_username("N/A");
	strlow(hash);
	hex2str(line, hash, 32);
	(void)hash_add_hash(line,16);
    }
    
    (void)hash_add_salt("");
    (void)hash_add_salt2("");

    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int len = strlen(password[0]);
    return hash_md5(password, salt2, len, THREAD_LENPROVIDED);
}


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt, char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    int lens[VECTORSIZE];
    int a;
    for (a=0;a<vectorsize;a++) lens[a]=strlen(password[a]);
    hash_md5_unicode_slow(password, salt2, lens);
    return hash_ok;
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
    return 1;
}