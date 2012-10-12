/* 
   md5-crypt.c

   One way encryption based on MD5 sum.
   Compatible with the behavior of MD5 crypt introduced in FreeBSD 2.0.
   Copyright (C) 1996, 1997, 1999, 2000, 2001, 2002, 2004, 2009
   Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@cygnus.com>, 1996.

   Modified by Milen Rangelov <gat3way@gat3way.eu> to optimize for hash cracking.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

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


/* Define our magic string to mark salt for MD5 "encryption"
   replacement.  This is meant to be the same as for other MD5 based
   encryption implementations.  */
static const char md5_salt_prefix[] = "$1$";

/* Table with characters for base64 transformation.  */
static const char b64t[64] =
"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

/* ripped off md5.h */
typedef uint32_t md5_uint32;
typedef uintptr_t md5_uintptr;


/* Prototypes for local functions.  */
extern char *__md5_crypt_r (const char *key[VECTORSIZE], const char *salt,
			    char *buffer[VECTORSIZE], int buflen[VECTORSIZE], int vectorsize);


static void to64(char *s, unsigned long v, int n)
{
    static unsigned char itoa64[] =         /* 0 ... 63 => ASCII - 64 */
        "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

    while (--n >= 0) {
        *s++ = itoa64[v&0x3f];
        v >>= 6;
    }
}



/* This entry point is equivalent to the `crypt' function in Unix
   libcs.  */
char *
__md5_crypt_r (key, salt, buffer, buflen, vectorsize)
     const char *key[VECTORSIZE];
     const char *salt;
     char *buffer[VECTORSIZE];
     int buflen[VECTORSIZE];
     int vectorsize;
{
  unsigned char *alt_result[VECTORSIZE];
  size_t salt_len;
  size_t key_len[VECTORSIZE];
  size_t cnt;
  char *cp;
  char *copied_key = NULL;
  char *copied_salt = NULL;
  char *tempbuf = alloca(128);
  char *bigbuf[VECTORSIZE];
  char *bigbuf2[VECTORSIZE];
  int bbl[VECTORSIZE];
  int bbl2[VECTORSIZE];
  int i,j;

  tempbuf[0]=0;
  /* prepare the bigbuf */
  for (i=0;i<vectorsize;i++)
  {

    alt_result[i]=alloca(128);
    bigbuf[i]=alloca(128);
    bigbuf2[i]=alloca(128);
    bbl[i]=bbl2[i]=0;
    buffer[i][0] = 0;
  }



  /* Find beginning of salt string.  The prefix should normally always
     be present.  Just in case it is not.  */
  if (strncmp (md5_salt_prefix, salt, sizeof (md5_salt_prefix) - 1) == 0)
    /* Skip salt prefix.  */
    salt += sizeof (md5_salt_prefix) - 1;

  salt_len = MIN (strcspn (salt, "$"), 8);
  for (i=0;i<vectorsize;i++) key_len[i] = strlen (key[i]);


  for (i=0;i<vectorsize;i++)
  {
	memcpy(bigbuf[i], key[i], key_len[i]);
	bbl[i] += key_len[i];
	memcpy(bigbuf[i]+bbl[i], md5_salt_prefix, sizeof(md5_salt_prefix)-1 );
	bbl[i] += sizeof(md5_salt_prefix)-1;
	memcpy(bigbuf[i]+bbl[i], salt, salt_len);
	bbl[i] += salt_len;

	memcpy(bigbuf2[i], key[i], key_len[i]);
	bbl2[i] += key_len[i];
	memcpy(bigbuf2[i]+bbl2[i], salt, salt_len);
	bbl2[i] += salt_len;
	memcpy(bigbuf2[i]+bbl2[i], key[i], key_len[i]);
	bbl2[i] += key_len[i];
  }

  hash_md5_unicode(bigbuf2, alt_result, bbl2);
  for (i=0;i<vectorsize;i++) 
  {
    bbl2[i]=0;
    bzero(bigbuf2[i],64);
  }

  for (i=0;i<vectorsize;i++) 
  {
    for (cnt = key_len[i]; cnt > 16; cnt -= 16)
    {
	memcpy(bigbuf[i]+bbl[i], alt_result[i], 16);
	bbl[i] += 16;
    }
    memcpy(bigbuf[i]+bbl[i], alt_result[i], cnt);
    bbl[i] += cnt;
    *alt_result[i] = '\0';

    for (cnt = key_len[i]; cnt > 0; cnt >>= 1)
    {
      memcpy(bigbuf[i]+bbl[i], (cnt & 1) != 0 ? (const void *) alt_result[i] : (const void *) key[i], 1);
      bbl[i]++;
    }
  }
  hash_md5_unicode(bigbuf, alt_result, bbl);
  for (i=0;i<vectorsize;i++) 
  {
    bbl[i]=0;
    bzero(bigbuf[i],64);
  }

  for (cnt = 0; cnt < 1000; ++cnt)
  {
      if ((cnt & 1) != 0)
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], key[i], key_len[i]);
	    bbl[i] += key_len[i];
	    memcpy(bigbuf[i+1]+bbl[i+1], key[i+1], key_len[i+1]);
	    bbl[i+1] += key_len[i+1];
	}
      }
      else
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], alt_result[i], 16);
	    bbl[i] += 16;
	    memcpy(bigbuf[i+1]+bbl[i+1], alt_result[i+1], 16);
	    bbl[i+1] += 16;
	}
      }

      if (cnt % 3 != 0)
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], salt, salt_len);
	    bbl[i] += salt_len;
	    memcpy(bigbuf[i+1]+bbl[i+1], salt, salt_len);
	    bbl[i+1] += salt_len;
	}
      }

      if (cnt % 7 != 0)
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], key[i], key_len[i]);
	    bbl[i] += key_len[i];
	    memcpy(bigbuf[i+1]+bbl[i+1], key[i+1], key_len[i+1]);
	    bbl[i+1] += key_len[i+1];
	}
      }

      if ((cnt & 1) != 0)
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], alt_result[i], 16);
	    bbl[i] += 16;
	    memcpy(bigbuf[i+1]+bbl[i+1], alt_result[i+1], 16);
	    bbl[i+1] += 16;
	}
      }
      else
      {
	for (i=0;i<vectorsize;i+=2) 
	{
	    memcpy(bigbuf[i]+bbl[i], key[i], key_len[i]);
	    bbl[i] += key_len[i];
	    memcpy(bigbuf[i+1]+bbl[i+1], key[i+1], key_len[i+1]);
	    bbl[i+1] += key_len[i+1];
	}
      }

      hash_md5_unicode(bigbuf, alt_result, bbl);
      for (i=0;i<vectorsize;i++) {bbl[i] = 0;bzero(bigbuf[i],64);}
  }


  /* Now we can construct the result string.  It consists of three
     parts.  */
  for (i=0;i<vectorsize;i++)
  {
	cp = __stpncpy (buffer[i], md5_salt_prefix, MAX (0, buflen[i]));
	buflen[i] -= sizeof (md5_salt_prefix) - 1;

	cp = __stpncpy (cp, salt, MIN ((size_t) MAX (0, buflen), salt_len));
	buflen[i] -= MIN ((size_t) MAX (0, buflen), salt_len);

	if (buflen[i] > 0)
	{
    	    *cp++ = '$';
    	    --buflen[i];
	}

	void b64_from_24bit (unsigned int b2, unsigned int b1, unsigned int b0, int n)
	{
	    unsigned int w = (b2 << 16) | (b1 << 8) | b0;
	    while (n-- > 0 && buflen > 0)
    	    {
		*cp++ = b64t[w & 0x3f];
		--buflen[i];
		w >>= 6;
    	    }
	}

        b64_from_24bit (alt_result[i][0], alt_result[i][6], alt_result[i][12], 4);
	b64_from_24bit (alt_result[i][1], alt_result[i][7], alt_result[i][13], 4);
	b64_from_24bit (alt_result[i][2], alt_result[i][8], alt_result[i][14], 4);
	b64_from_24bit (alt_result[i][3], alt_result[i][9], alt_result[i][15], 4);
	b64_from_24bit (alt_result[i][4], alt_result[i][10], alt_result[i][5], 4);
	b64_from_24bit (0, 0, alt_result[i][11], 2);
	if (buflen <= 0)
	{
//      __set_errno (ERANGE);
    	    printf("EXHAUSTED BUFLEN!\n");
      //buffer = NULL;
	}
	else *cp = '\0';
//	return buffer;
  }

}


