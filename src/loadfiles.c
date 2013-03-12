/*
 * loadfiles.c
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

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "loadfiles.h"
#include "plugins.h"
#include "hashinterface.h"
#include "err.h"


/* Temp. globals */
extern char temp_username[HASHFILE_MAX_PLAIN_LENGTH];
extern char temp_salt[256];
extern char temp_salt2[HASHFILE_MAX_PLAIN_LENGTH];
extern char temp_hash[HASHFILE_MAX_PLAIN_LENGTH];


/* Function prototypes */
hash_stat load_hashes_file(const char *filename);
hash_stat load_single_hash(char *hash);




/* Load hashlist file */
hash_stat load_hashes_file(const char *filename)
{
    FILE *hashfile;
    char buf[HASHFILE_MAX_LINE_LENGTH*3];
    hash_stat temp_stat;
    char filename_copy[512]; 
    unsigned int lines[2];
    unsigned int successful_lines[2];
    
    lines[1]=0;
    successful_lines[1]=0;
    strcpy(filename_copy, filename);
    temp_username[0]=0;
    temp_hash[0]=0;
    temp_salt[0]=0;
    temp_salt2[0]=0;

    if (!hash_plugin_parse_hash)
    {
	elog("%s failed: please call load_plugin() first!\n","load_hashes_file");
	return hash_err;
    }
    
    if (hash_plugin_is_special())
    {
	temp_stat = hash_plugin_parse_hash(additional_options,(char *)filename);
	if (add_hash_list(temp_username, temp_hash, temp_salt, temp_salt2) == hash_err)
	{
	    elog("Not enough memory to insert new hash_list entry! %s\n","");
	    return hash_err;
	}
	if (temp_stat == hash_ok) 
	{
	    hlog("File %s loaded successfully\n",filename);
	    return temp_stat;
	}
	else
	{
	    elog("Cannot load file: %s, exiting!\n", filename);
	    exit(EXIT_FAILURE);
	}
    }


    hashfile = fopen(filename, "r");
    if (hashfile == NULL)
    {
	elog("Cannot open hashlist file: %s\n", filename);
	return hash_err;
    }
    else
    {
	while (!feof(hashfile))
	{
	    if (fgets((char *)&buf, HASHFILE_MAX_LINE_LENGTH, hashfile) != NULL)
	    {
		if ((strlen(buf) > 0) && (buf[strlen(buf)-1] == '\n')) buf[strlen(buf)-1] = 0;
		if (buf[strlen(buf)-1] == '\r') buf[strlen(buf)-1] = 0;
		lines[1]++;
		if (hash_plugin_parse_hash(buf, NULL) == hash_ok)
		{
		    if (add_hash_list(temp_username, temp_hash, temp_salt, temp_salt2) == hash_err)
		    {
			elog("Not enough memory to insert new hash_list entry! %s\n","");
			return hash_err;
		    }
		    else successful_lines[1]++;
		}
	    }
	}
    }
    
    fclose(hashfile);
    hlog("(%s): %d hashes loaded successfully, %d errors\n",filename_copy, successful_lines[1], lines[1]-successful_lines[1]);
    return hash_ok;
}


/* Load single hash (from command-line) */
hash_stat load_single_hash(char *hash)
{

    if (hash_plugin_is_special())
    {
	return hash_err;
    }

    if (!hash) return hash_err;
    
    if (hash_plugin_parse_hash(hash, NULL) == hash_ok)
    {
	if (add_hash_list(temp_username, temp_hash, temp_salt, temp_salt2) == hash_err)
	{
	    elog("Not enough memory to insert new hash_list entry! %s\n","");
	    return hash_err;
	}
    }
    else return hash_err;

    return hash_ok;
}

