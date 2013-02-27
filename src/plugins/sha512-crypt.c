/* One way encryption based on SHA512 sum.
   Copyright (C) 2007, 2009 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Ulrich Drepper <drepper@redhat.com>, 2007.
   Optimized for speed by Milen Rangelov <gat3way@gat3way.eu>, 2010

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
#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/param.h>
#include "plugin.h"



static const char sha512_salt_prefix[] = "$6$";

static const char sha512_rounds_prefix[] = "rounds=";

/* Maximum salt string length.  */
#define SALT_LEN_MAX 16
/* Default number of rounds if not explicitly specified.  */
#define ROUNDS_DEFAULT 5000
/* Minimum number of rounds.  */
#define ROUNDS_MIN 1000
/* Maximum number of rounds.  */
#define ROUNDS_MAX 999999999

/* Table with characters for base64 transformation.  */
static const char b64t[64] =
"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";


/* Prototypes for local functions.  */
char *__sha512_crypt_r (const char *key[VECTORSIZE], const char *salt,
			       char *buffer[VECTORSIZE], int buflen[VECTORSIZE], int vectorsize);


char *
__sha512_crypt_r (key, salt, buffer, buflen, vectorsize)
     const char *key[VECTORSIZE];
     const char *salt;
     char *buffer[VECTORSIZE];
     int buflen[VECTORSIZE];
     int vectorsize;
{
  unsigned char *alt_result[VECTORSIZE];
  unsigned char *temp_result[VECTORSIZE];
  size_t salt_len;
  size_t key_len[VECTORSIZE];
  size_t cnt;
  char *cp[VECTORSIZE];
  char *copied_key = NULL;
  char *copied_salt = NULL;
  char *p_bytes[VECTORSIZE];
  char *s_bytes[VECTORSIZE];
  /* Default number of rounds.  */
  size_t rounds = ROUNDS_DEFAULT;
  bool rounds_custom = false;
  char *bigbuf[VECTORSIZE], *bigbuf2[VECTORSIZE];
  int bbl[VECTORSIZE], bbl2[VECTORSIZE];
  int i,j;
  
  
  for (i=0;i<vectorsize;i++) 
  {
    bigbuf[i]=alloca(4255);
    bigbuf2[i]=alloca(4255);
    alt_result[i]=alloca(4255);
    temp_result[i]=alloca(4255);
    buffer[i][0]=0;
    bbl[i]=0;
    bbl2[i]=0;
  }
  

  /* Find beginning of salt string.  The prefix should normally always
     be present.  Just in case it is not.  */
  if (strncmp (sha512_salt_prefix, salt, sizeof (sha512_salt_prefix) - 1) == 0)
    /* Skip salt prefix.  */
    salt += sizeof (sha512_salt_prefix) - 1;

  if (strncmp (salt, sha512_rounds_prefix, sizeof (sha512_rounds_prefix) - 1)
      == 0)
    {
      const char *num = salt + sizeof (sha512_rounds_prefix) - 1;
      char *endp;
      unsigned long int srounds = strtoul (num, &endp, 10);
      if (*endp == '$')
        {
          salt = endp + 1;
          rounds = MAX (ROUNDS_MIN, MIN (srounds, ROUNDS_MAX));
          rounds_custom = true;
        }
    }

  salt_len = MIN (strcspn (salt, "$"), SALT_LEN_MAX);
  for (i=0;i<vectorsize;i++) key_len[i] = strlen(key[i]);

  for (i=0;i<vectorsize;i++)
  if ((key[i] - (char *) 0) % __alignof__ (uint64_t) != 0)
    {
      char *tmp = (char *) alloca (key_len[i] + __alignof__ (uint64_t));
      key[i] = copied_key =
        memcpy (tmp + __alignof__ (uint64_t)
                - (tmp - (char *) 0) % __alignof__ (uint64_t),
                key[i], key_len[i]);
    }

  if ((salt - (char *) 0) % __alignof__ (uint64_t) != 0)
    {
      char *tmp = (char *) alloca (salt_len + __alignof__ (uint64_t));
      salt = copied_salt =
        memcpy (tmp + __alignof__ (uint64_t)
                - (tmp - (char *) 0) % __alignof__ (uint64_t),
                salt, salt_len);
    }


  
  for (i=0;i<vectorsize;i++)
  {
    memcpy(bigbuf[i], key[i], key_len[i]);
    bbl[i] += key_len[i];
    memcpy(bigbuf[i]+bbl[i], salt, salt_len);
    bbl[i] += salt_len;
  
    memcpy(bigbuf2[i], key[i], key_len[i]);
    bbl2[i] += key_len[i];
    memcpy(bigbuf2[i]+bbl2[i], salt, salt_len);
    bbl2[i] += salt_len;
    memcpy(bigbuf2[i]+bbl2[i], key[i], key_len[i]);
    bbl2[i] += key_len[i];
  }
  hash_sha512_unicode(bigbuf2, alt_result, bbl2);
  for (i=0;i<vectorsize;i++) bbl2[i] = 0;

  for (i=0;i<vectorsize;i++)
  {
    for (cnt = key_len[i]; cnt > 64; cnt -= 64)
    {
	memcpy(bigbuf[i]+bbl[i], alt_result[i], 64);
	bbl[i] += 64;
    }
    memcpy(bigbuf[i]+bbl[i], alt_result[i], cnt);
    bbl[i] += cnt;
  }

  for (i=0;i<vectorsize;i++)
  for (cnt = key_len[i]; cnt > 0; cnt >>= 1)
    if ((cnt & 1) != 0)
    {
      memcpy(bigbuf[i]+bbl[i], alt_result[i], 64);
      bbl[i] += 64;
    }
    else
    {
      memcpy(bigbuf[i]+bbl[i], key[i], key_len[i]);
      bbl[i] += key_len[i];
    }
  hash_sha512_unicode(bigbuf, alt_result, bbl);
  for (i=0;i<vectorsize;i++) bbl[i] = 0;

  for (i=0;i<vectorsize;i++)
  for (cnt = 0; cnt < key_len[i]; ++cnt)
  {
    memcpy(bigbuf2[i]+bbl2[i], key[i], key_len[i]);
    bbl2[i] += key_len[i];
  }
  hash_sha512_unicode(bigbuf2, temp_result, bbl2);
  for (i=0;i<vectorsize;i++) bbl2[i] = 0;



  /* Create byte sequence P.  */
  for (i=0;i<vectorsize;i++)
  {
    cp[i] = p_bytes[i] = alloca (key_len[i]);
    for (cnt = key_len[i]; cnt >= 64; cnt -= 64)
	cp[i] = memcpy (cp[i], temp_result[i], 64);
    memcpy (cp[i], temp_result[i], cnt);
  }


  for (i=0;i<vectorsize;i++) bbl2[i] = 0;
  for (i=0;i<vectorsize;i++) for (cnt = 0; cnt < (16 + (alt_result[i][0]&255)); ++cnt)
  {
    memcpy(bigbuf2[i]+bbl2[i], salt, salt_len);
    bbl2[i] += salt_len;
  }
  hash_sha512_unicode(bigbuf2, temp_result, bbl2);
  for (i=0;i<vectorsize;i++) bbl2[i]=0;



  /* Create byte sequence S.  */
  for (i=0;i<vectorsize;i++)
  {
    cp[i] = s_bytes[i] = alloca (salt_len);
    for (cnt = salt_len; cnt >= 64; cnt -= 64)
	cp[i] = memcpy (cp[i], temp_result[i], 64);
    memcpy (cp[i], temp_result[i], cnt);
  }

  for (i=0;i<vectorsize;i+=2) 
  {
    bbl[i]=0;
    bbl[i+1]=0;
    bzero(bigbuf[i],128);
    bzero(bigbuf[i+1],128);
  }
  
  for (cnt = 0; cnt < rounds; ++cnt)
  {
      if ((cnt & 1) != 0)
      {
	for (i=0;i<vectorsize;i++)
	{
	    memcpy(bigbuf[i]+bbl[i], p_bytes[i], key_len[i]);
	    bbl[i] += key_len[i];
	}
      }
      else
      {
	for (i=0;i<vectorsize;i++)
	{
	    memcpy(bigbuf[i]+bbl[i], alt_result[i], 64);
	    bbl[i] += 64;
	}
      }

      if (cnt % 3 != 0)
      {
	for (i=0;i<vectorsize;i++)
	{
	    memcpy(bigbuf[i]+bbl[i], s_bytes[i], salt_len);
	    bbl[i] += salt_len;
	}
      }

      if (cnt % 7 != 0)
      {
        for (i=0;i<vectorsize;i++)
        {
	    memcpy(bigbuf[i]+bbl[i], p_bytes[i], key_len[i]);
	    bbl[i] += key_len[i];
	}
      }
      if ((cnt & 1) != 0)
      {
	for (i=0;i<vectorsize;i++)
	{
	    memcpy(bigbuf[i]+bbl[i], alt_result[i], 64);
	    bbl[i] += 64;
	}
      }
      else
      {
	for (i=0;i<vectorsize;i++)
	{
	    memcpy(bigbuf[i]+bbl[i], p_bytes[i], key_len[i]);
	    bbl[i] += key_len[i];
	}
      }
      hash_sha512_unicode(bigbuf, alt_result, bbl);
      for (i=0;i<vectorsize;i++) bbl[i] = 0;
  }



  /* Now we can construct the result string.  It consists of three
     parts. */
  for (i=0;i<vectorsize;i++)
  {
    cp[i] = __stpncpy (buffer[i], sha512_salt_prefix, MAX (0, buflen[i]));
    buflen[i] -= sizeof (sha512_salt_prefix) - 1;

    if (rounds_custom)
    {
      int n = snprintf (cp[i], MAX (0, buflen[i]), "%s%zu$",
                        sha512_rounds_prefix, rounds);
      cp[i] += n;
      buflen[i] -= n;
    }

    cp[i] = __stpncpy (cp[i], salt, MIN ((size_t) MAX (0, buflen[i]), salt_len));
    buflen[i] -= MIN ((size_t) MAX (0, buflen[i]), salt_len);

    if (buflen[i] > 0)
    {
      *cp[i]++ = '$';
      --buflen[i];
    }

    void b64_from_24bit (unsigned int b2, unsigned int b1, unsigned int b0,
                       int n)
    {
	unsigned int w = (b2 << 16) | (b1 << 8) | b0;
	while (n-- > 0 && buflen[i] > 0)
        {
    	    *cp[i]++ = b64t[w & 0x3f];
    	    --buflen[i];
    	    w >>= 6;
        }
    }


    b64_from_24bit (alt_result[i][0], alt_result[i][21], alt_result[i][42], 4);
    b64_from_24bit (alt_result[i][22], alt_result[i][43], alt_result[i][1], 4);
    b64_from_24bit (alt_result[i][44], alt_result[i][2], alt_result[i][23], 4);
    b64_from_24bit (alt_result[i][3], alt_result[i][24], alt_result[i][45], 4);
    b64_from_24bit (alt_result[i][25], alt_result[i][46], alt_result[i][4], 4);
    b64_from_24bit (alt_result[i][47], alt_result[i][5], alt_result[i][26], 4);
    b64_from_24bit (alt_result[i][6], alt_result[i][27], alt_result[i][48], 4);
    b64_from_24bit (alt_result[i][28], alt_result[i][49], alt_result[i][7], 4);
    b64_from_24bit (alt_result[i][50], alt_result[i][8], alt_result[i][29], 4);
    b64_from_24bit (alt_result[i][9], alt_result[i][30], alt_result[i][51], 4);
    b64_from_24bit (alt_result[i][31], alt_result[i][52], alt_result[i][10], 4);
    b64_from_24bit (alt_result[i][53], alt_result[i][11], alt_result[i][32], 4);
    b64_from_24bit (alt_result[i][12], alt_result[i][33], alt_result[i][54], 4);
    b64_from_24bit (alt_result[i][34], alt_result[i][55], alt_result[i][13], 4);
    b64_from_24bit (alt_result[i][56], alt_result[i][14], alt_result[i][35], 4);
    b64_from_24bit (alt_result[i][15], alt_result[i][36], alt_result[i][57], 4);
    b64_from_24bit (alt_result[i][37], alt_result[i][58], alt_result[i][16], 4);
    b64_from_24bit (alt_result[i][59], alt_result[i][17], alt_result[i][38], 4);
    b64_from_24bit (alt_result[i][18], alt_result[i][39], alt_result[i][60], 4);
    b64_from_24bit (alt_result[i][40], alt_result[i][61], alt_result[i][19], 4);
    b64_from_24bit (alt_result[i][62], alt_result[i][20], alt_result[i][41], 4);
    b64_from_24bit (0, 0, alt_result[i][63], 2);

    if (buflen <= 0)
    {
      __set_errno (ERANGE);
      buffer[i][0] = 0;
    }
    else
    *cp[i] = '\0';         /* Terminate the string.  */
  }
  return NULL;
}



