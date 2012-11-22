/* lm.c
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
    return("lm \t\tLM plugin");
}


char * hash_plugin_detailed(void)
{
    return("lm - LM plugin\n"
	    "------------------------\n"
	    "Use this module to crack simple LM hashes\n"
	    "Input should be in form: \'user:hash\', \'hash\' or pwdump format\n"
	    "Known software that uses this password hashing method:\n"
	    "Older Microsoft Windows versions\n"
	    "\nAuthor: Milen Rangelov <gat3way@gat3way.eu>\n");
}


hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{

    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char line[HASHFILE_MAX_LINE_LENGTH];
    char hash2[HASHFILE_MAX_LINE_LENGTH];

    char *temp_str;
    
    if (!hashline) return hash_err;
    
    if (strlen(hashline)<2) return hash_err;
    
    /* Special case: that is a pwdump hash format */
    if (strstr(hashline,":::"))
    {
        snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
        strcpy(username, strtok(line, ":"));
        /* skip uid */
        temp_str=strtok(NULL,":");
        /* get LM hash */
        temp_str=strtok(NULL,":");
        if (!temp_str) return hash_err;
        strcpy(hash, temp_str);
        if (strlen(hash)!=32)
        {
            return hash_err;
        }
        (void)hash_add_username(username);
        strlow(hash);
        // empty LM password = this is a NTLM hash
        if (strcmp(hash,"aad3b435b51404eeaad3b435b51404ee")==0) return hash_err;
        temp_str=strtok(NULL,":");
	if (temp_str) 
	{
	    strcpy(hash2, temp_str);
	    strlow(hash2);
	    if (strcmp(hash2,"31d6cfe0d16ae931b73c59d7e0c089c0")==0) return hash_err;
	}
        
        hex2str(line, hash, 32);
        (void)hash_add_hash(line,16);
        (void)hash_add_salt("");
        (void)hash_add_salt2("");
        return hash_ok;
    }
    
    snprintf(line, HASHFILE_MAX_LINE_LENGTH-1, "%s", hashline);
    strcpy(username, strtok(line, ":"));
    temp_str=strtok(NULL,":");
    if (temp_str) 
    {
        strcpy(hash, temp_str);
        if (strlen(hash)!=32)
        {
            return hash_err;
        }
        int flag=0;
        int a;
        for (a=0;a<strlen(hash);a++) if ( ((hash[a]<'0')||(hash[a]>'9'))&&((hash[a]<'a')||(hash[a]>'f'))) flag=1;
        if (flag==1) return hash_err;
    
        (void)hash_add_username(username);
        strlow(hash);
        hex2str(line, hash, 32);
        (void)hash_add_hash(line,16);
    }
    else
    {
        strcpy(hash, username);

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


hash_stat hash_plugin_check_hash_dictionary(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char *keyl[VECTORSIZE];
    char *newp[VECTORSIZE];
    int i,j;

    for (j=0;j<vectorsize;j++)
    {
	newp[j] = alloca(32);
	bzero(newp[j],32);
	strcpy(newp[j],strupr((char *)password[j]));
	i=0;
	while ((newp[j][i]!=0)&&(i<=15)) i++;
	for (;i<15;i++) newp[j][i]=0;
	keyl[j] = alloca(32);
	bzero(keyl[j],32);
	keyl[j][0] = newp[j][0]>>1;
	keyl[j][1] = ((newp[j][0]&0x01)<<6) | (newp[j][1]>>2);
	keyl[j][2] = ((newp[j][1]&0x03)<<5) | (newp[j][2]>>3);
	keyl[j][3] = ((newp[j][2]&0x07)<<4) | (newp[j][3]>>4);
	keyl[j][4] = ((newp[j][3]&0x0F)<<3) | (newp[j][4]>>5);
        keyl[j][5] = ((newp[j][4]&0x1F)<<2) | (newp[j][5]>>6);
	keyl[j][6] = ((newp[j][5]&0x3F)<<1) | (newp[j][6]>>7);
	keyl[j][7] = newp[j][6]&0x7F;
	keyl[j][8] = newp[j][7]>>1;
	keyl[j][9] = ((newp[j][7]&0x01)<<6) | (newp[j][8]>>2);
	keyl[j][10] = ((newp[j][8]&0x03)<<5) | (newp[j][9]>>3);
	keyl[j][11] = ((newp[j][9]&0x07)<<4) | (newp[j][10]>>4);
	keyl[j][12] = ((newp[j][10]&0x0F)<<3) | (newp[j][11]>>5);
	keyl[j][13] = ((newp[j][11]&0x1F)<<2) | (newp[j][12]>>6);
	keyl[j][14] = ((newp[j][12]&0x3F)<<1) | (newp[j][13]>>7);
	keyl[j][15] = newp[j][13]&0x7F;
	for (i=0;i<16;i+=4) 
	{
    	    keyl[j][i] = (keyl[j][i]<<1);
    	    keyl[j][i+1] = (keyl[j][i+1]<<1);
    	    keyl[j][i+2] = (keyl[j][i+2]<<1);
    	    keyl[j][i+3] = (keyl[j][i+3]<<1);
	}
    }
    hash_lm_slow((const unsigned char **)keyl, (unsigned char **)salt2);
    for (i=0;i<vectorsize;i++) if (strlen(password[i])<8) memcpy(&salt2[i][8],"\xaa\xd3\xb4\x35\xb5\x14\x04\xee",8);
    return hash_ok;
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
    unsigned char *keyl[VECTORSIZE];
    char *newp[VECTORSIZE];
    int a,i,j,flag=0;
    
    for (a=0;a<vectorsize;a++) if (strlen(password[a])>7) flag=1;
    if (flag==0) for (j=0;j<vectorsize;j++)
    {
	newp[j] = alloca(32);
	bzero(newp[j],32);
	strcpy(newp[j],strupr((char *)password[j]));
	keyl[j] = alloca(32);
	keyl[j][0] = newp[j][0]>>1;
	keyl[j][1] = ((newp[j][0]&0x01)<<6) | (newp[j][1]>>2);
	keyl[j][2] = ((newp[j][1]&0x03)<<5) | (newp[j][2]>>3);
	keyl[j][3] = ((newp[j][2]&0x07)<<4) | (newp[j][3]>>4);
	keyl[j][4] = ((newp[j][3]&0x0F)<<3) | (newp[j][4]>>5);
        keyl[j][5] = ((newp[j][4]&0x1F)<<2) | (newp[j][5]>>6);
	keyl[j][6] = ((newp[j][5]&0x3F)<<1) | (newp[j][6]>>7);
	keyl[j][7] = newp[j][6]&0x7F;
	for (i=0;i<8;i+=4) 
	{
    	    keyl[j][i] = (keyl[j][i]<<1);
    	    keyl[j][i+1] = (keyl[j][i+1]<<1);
    	    keyl[j][i+2] = (keyl[j][i+2]<<1);
    	    keyl[j][i+3] = (keyl[j][i+3]<<1);
    	}
    	keyl[j][16]=1;
    }
    else for (j=0;j<vectorsize;j++)
    {
	newp[j] = alloca(32);
	bzero(newp[j],32);
	strcpy(newp[j],strupr((char *)password[j]));
	i=0;
	keyl[j] = alloca(32);
	keyl[j][0] = newp[j][0]>>1;
	keyl[j][1] = ((newp[j][0]&0x01)<<6) | (newp[j][1]>>2);
	keyl[j][2] = ((newp[j][1]&0x03)<<5) | (newp[j][2]>>3);
	keyl[j][3] = ((newp[j][2]&0x07)<<4) | (newp[j][3]>>4);
	keyl[j][4] = ((newp[j][3]&0x0F)<<3) | (newp[j][4]>>5);
        keyl[j][5] = ((newp[j][4]&0x1F)<<2) | (newp[j][5]>>6);
	keyl[j][6] = ((newp[j][5]&0x3F)<<1) | (newp[j][6]>>7);
	keyl[j][7] = newp[j][6]&0x7F;
	keyl[j][8] = newp[j][7]>>1;
	keyl[j][9] = ((newp[j][7]&0x01)<<6) | (newp[j][8]>>2);
	keyl[j][10] = ((newp[j][8]&0x03)<<5) | (newp[j][9]>>3);
	keyl[j][11] = ((newp[j][9]&0x07)<<4) | (newp[j][10]>>4);
	keyl[j][12] = ((newp[j][10]&0x0F)<<3) | (newp[j][11]>>5);
	keyl[j][13] = ((newp[j][11]&0x1F)<<2) | (newp[j][12]>>6);
	keyl[j][14] = ((newp[j][12]&0x3F)<<1) | (newp[j][13]>>7);
	keyl[j][15] = newp[j][13]&0x7F;
	for (i=0;i<16;i+=4) 
	{
    	    keyl[j][i] = (keyl[j][i]<<1);
    	    keyl[j][i+1] = (keyl[j][i+1]<<1);
    	    keyl[j][i+2] = (keyl[j][i+2]<<1);
    	    keyl[j][i+3] = (keyl[j][i+3]<<1);
	}
    }
    hash_lm_slow((const unsigned char **)keyl, (unsigned char **)salt2);
    if (flag==0)
    {
	for (i=0;i<vectorsize;i++) memcpy(&salt2[i][8],"\xaa\xd3\xb4\x35\xb5\x14\x04\xee",8);
    }

    return hash_ok;
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
    return 1;
}
