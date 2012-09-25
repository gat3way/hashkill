/* Copyright 2000-2005 The Apache Software Foundation or its licensors, as
 * applicable.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * The apr_md5_encode() routine uses much code obtained from the FreeBSD 3.0
 * MD5 crypt() function, which is licenced as follows:
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <phk@login.dknet.dk> wrote this file.  As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return.   Poul-Henning Kamp
 * ----------------------------------------------------------------------------
 */
/*
   apr1-crypt.c

   Based on Apache Foundation's apr_md5.c

   Edited by Milen Rangelov <gat3way@gat3way.eu> to optimize for hash cracking.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307 USA.  */


#define _GNU_SOURCE
#define _XOPEN_SOURCE 600

#include <stdio.h>
#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <sys/param.h>
#include <stdint.h>
#include "plugin.h"


static const char apr1_id[] = "$apr1$";


static void to64(char *s, unsigned long v, int n)
{
    static unsigned char itoa64[] =         /* 0 ... 63 => ASCII - 64 */
        "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    while (--n >= 0) {
        *s++ = itoa64[v&0x3f];
        v >>= 6;
    }
}



/* Prototypes for local functions.  */
extern char *__apr1_crypt_r(const char *pw[VECTORSIZE], const char *salt,
                             char *result[VECTORSIZE], int nbytes, int vectorsize)
{

    char *passwd[VECTORSIZE];
    char *p;
    const char *sp, *ep;
    unsigned char *final[VECTORSIZE];
    ssize_t sl, pl, i;
    unsigned long l;
    int a[VECTORSIZE];
    int b[VECTORSIZE];
    int c,j;
    char *bigbuf[VECTORSIZE];
    char *bigbuf2[VECTORSIZE];

    for (c=0;c<vectorsize;c++)
    {
	a[c]=0;
	b[c]=0;
	final[c] = alloca(128);
	passwd[c] = alloca(128);
	bigbuf[c] = alloca(128);
	bigbuf2[c] = alloca(128);
//	bzero(bigbuf2[c],64);
//	bzero(bigbuf[c],64);
    }

    sp = salt;
    if (!strncmp(sp, apr1_id, strlen(apr1_id))) {
        sp += strlen(apr1_id);
    }
    for (ep = sp; (*ep != '\0') && (*ep != '$') && (ep < (sp + 8)); ep++) {
        continue;
    }
    sl = ep - sp;

    for (i=0;i<vectorsize;i++)
    {
	a[i] = strlen(pw[i]);
	memcpy(bigbuf[i],pw[i],a[i]);
	memcpy(bigbuf[i]+a[i],apr1_id,strlen(apr1_id));
	a[i]+=strlen(apr1_id);
	memcpy(bigbuf[i]+a[i],sp,sl);
	a[i]+=sl;

	b[i] = strlen(pw[i]);
	memcpy(bigbuf2[i], pw[i], b[i]);
	memcpy(bigbuf2[i]+b[i],sp,sl);
	b[i]+=sl;
	memcpy(bigbuf2[i]+b[i],pw[i],strlen(pw[i]));
	b[i]+=strlen(pw[i]);
    }
    hash_md5_unicode((const char **)bigbuf2,(char **)final,b);
    for (i=0;i<vectorsize;i++) {b[i]=0;bzero(bigbuf2[i],48);}

    for (i=0;i<vectorsize;i++)
    for (pl = strlen(pw[i]); pl > 0; pl -= 16) 
    {
        c = (pl > 16) ? 16 : pl;
        memcpy(bigbuf[i]+a[i], final[i], c);
        a[i]+=c;
    }

    for (i=0;i<vectorsize;i++) memset(final[i],0,64);

    for (j=0;j<vectorsize;j++)
    for (i = strlen(pw[j]); i != 0; i >>= 1) {
        if (i & 1) {
    	    memcpy(bigbuf[j]+a[j], final[j], 1);
    	    a[j]++;
        }
        else {
    	    memcpy(bigbuf[j]+a[j], pw[j], 1);
    	    a[j]++;
        }
    }

    for (j=0;j<vectorsize;j++)
    {
	strcpy(passwd[j], apr1_id);
	strncat(passwd[j], sp, sl);
	strcat(passwd[j], "$");
    }
    
    hash_md5_unicode((const char **)bigbuf, (char **)final, a);
    for (j=0;j<vectorsize;j++) {a[j]=0;bzero(bigbuf[j],48);}

    for (i = 0; i < 1000; i++) {
        if (i & 1) {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j],pw[j],strlen(pw[j]));
    		b[j]+=strlen(pw[j]);
    	    }
        }
        else {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j], final[j], 16);
    		b[j]+=16;
    	    }
        }
        if (i % 3) {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j], sp, sl);
    		b[j]+=sl;
    	    }
        }

        if (i % 7) {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j], pw[j], strlen(pw[j]));
    		b[j]+=strlen(pw[j]);
    	    }
        }

        if (i & 1) {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j], final[j], 16);
    		b[j]+=16;
    	    }
        }
        else {
    	    for (j=0;j<vectorsize;j++)
    	    {
    		memcpy(bigbuf2[j]+b[j], pw[j], strlen(pw[j]));
    		b[j]+=strlen(pw[j]);
    	    }
        }
        hash_md5_unicode((const char **)bigbuf2, (char **)final, b);
        for (j=0;j<vectorsize;j++) {b[j]=0;bzero(bigbuf2[j],48);}
    }

    for (j=0;j<vectorsize;j++)
    {
	p = passwd[j] + strlen(passwd[j]);
        l = (final[j][ 0]<<16) | (final[j][ 6]<<8) | final[j][12]; to64(p, l, 4); p += 4;
	l = (final[j][ 1]<<16) | (final[j][ 7]<<8) | final[j][13]; to64(p, l, 4); p += 4;
	l = (final[j][ 2]<<16) | (final[j][ 8]<<8) | final[j][14]; to64(p, l, 4); p += 4;
	l = (final[j][ 3]<<16) | (final[j][ 9]<<8) | final[j][15]; to64(p, l, 4); p += 4;
	l = (final[j][ 4]<<16) | (final[j][10]<<8) | final[j][ 5]; to64(p, l, 4); p += 4;
	l = final[j][11]; to64(p, l, 2); p += 2;
	*p = '\0';
	strncpy(result[j], passwd[j], nbytes - 1);
	bzero(result[j]+nbytes,1);
    }
    return NULL;
}





