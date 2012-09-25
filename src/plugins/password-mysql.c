/* password-mysql.c
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

/* 
 * MySQL PASSWORD() routines. This is here so that you can use the MySQL
 * proprietary password-hashing routine with tpop3d. The code is inserted here
 * to avoid having to do an explicit query to get the MySQL password hash.
 * Observe that this is not completely safe, since the machine on which the
 * MySQL server is running may use a different character set to this machine.
 * However, it is probably not worth worrying about this in reality.
 *
 * In fact, these functions will probably be available in libmysqlclient, but
 * that doesn't appear to be documented, so better safe than sorry.
 *
 * We make these functions available whether or not MySQL support is
 * available, since they don't depend on MySQL and it's possible that somebody
 * might want to migrate passwords from a MySQL database to some other system.
 *
 * This code is taken from the MySQL distribution. The original license for
 * the code in sql/password.c states:
 *
 * Copyright Abandoned 1996 TCX DataKonsult AB & Monty Program KB & Detron HB
 * This file is public domain and comes with NO WARRANTY of any kind
 */

/* mysql_hash_password RESULT PASSWORD
 * Basic MySQL password-hashing routine. */

#include <stdio.h>
#include <unistd.h>
#define VECTORSIZE 128

void mysql_make_scrambled_password(char *to[VECTORSIZE], const char *password[VECTORSIZE], int vectorsize);



static void mysql_hash_password(unsigned long *result, const char *password) 
{
    register unsigned long nr=1345345333L, add=7, nr2=0x12345671L;
    unsigned long tmp;

    
    for (; *password; password++) {
        if (*password == ' ' || *password == '\t')
            continue;           /* skip space in password */
        tmp  = (unsigned long) (unsigned char) *password;
        nr  ^= (((nr & 63) + add) * tmp) + (nr << 8);
        nr2 += (nr2 << 8) ^ nr;
        add += tmp;
    }
    result[0] =  nr & (((unsigned long) 1L << 31) -1L); /* Don't use sign bit (str2int) */;
    result[1] = nr2 & (((unsigned long) 1L << 31) -1L);
    return;
}

/* mysql_make_scrambled_password RESULT PASSWORD
 * MySQL function to form a password hash and turn it into a string. */
void mysql_make_scrambled_password(char *to[VECTORSIZE], const char *password[VECTORSIZE], int vectorsize) 
{
    unsigned long hash_res[VECTORSIZE][2];
    int a;
    
    for (a=0;a<vectorsize;a++)
    {
	mysql_hash_password(hash_res[a], password[a]);
	to[a][0]=(hash_res[a][0]>>24)&255;
	to[a][1]=(hash_res[a][0]>>16)&255;
	to[a][2]=(hash_res[a][0]>>8)&255;
	to[a][3]=hash_res[a][0]&255;
	to[a][4]=(hash_res[a][1]>>24)&255;
	to[a][5]=(hash_res[a][1]>>16)&255;
	to[a][6]=(hash_res[a][1]>>8)&255;
	to[a][7]=hash_res[a][1]&255;
    }
}


