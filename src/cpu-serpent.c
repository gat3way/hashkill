/* cpu-serpent.c
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
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <inttypes.h>
#include <assert.h>
#include "cpu-serpent.h"

#define MAX_KEY_SIZE					64
#define	SERPENT_BLOCK_LENGTH				128
#define GOLDEN_RATIO					0x9e3779b9l
#define rotl32(a, n)					(((a)<<(n)) | ((a)>>(32-(n))))
#define rotr32(a, n)					(((a)>>(n)) | ((a)<<(32-(n))))
#define byte_swap_32(x) \
  (0 \
   | (((x) & 0xff000000) >> 24) | (((x) & 0x00ff0000) >>  8) \
   | (((x) & 0x0000ff00) <<  8) | (((x) & 0x000000ff) << 24))


static serpent_word32 serpent_gen_w(serpent_word32* b, serpent_byte i)
{		serpent_word32 ret;
		ret = b[0] ^ b[3] ^ b[5] ^ b[7] ^ GOLDEN_RATIO ^ ((serpent_word32)i);
		ret = rotl32(ret, 11);
		return ret;
}


/* These are the S-Boxes of Serpent.  They are copied from Serpents
   reference implementation (the optimized one, contained in
   `floppy2') and are therefore:

     Copyright (C) 1998 Ross Anderson, Eli Biham, Lars Knudsen.

  To quote the Serpent homepage
  (http://www.cl.cam.ac.uk/~rja14/serpent.html):

  "Serpent is now completely in the public domain, and we impose no
   restrictions on its use.  This was announced on the 21st August at
   the First AES Candidate Conference. The optimised implementations
   in the submission package are now under the GNU PUBLIC LICENSE
   (GPL), although some comments in the code still say otherwise. You
   are welcome to use Serpent for any application."  */

#define SBOX0(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t05, t06, t07, t08, t09; \
    u32 t11, t12, t13, t14, t15, t17, t01; \
    t01 = b   ^ c  ; \
    t02 = a   | d  ; \
    t03 = a   ^ b  ; \
    z   = t02 ^ t01; \
    t05 = c   | z  ; \
    t06 = a   ^ d  ; \
    t07 = b   | c  ; \
    t08 = d   & t05; \
    t09 = t03 & t07; \
    y   = t09 ^ t08; \
    t11 = t09 & y  ; \
    t12 = c   ^ d  ; \
    t13 = t07 ^ t11; \
    t14 = b   & t06; \
    t15 = t06 ^ t13; \
    w   =     ~ t15; \
    t17 = w   ^ t14; \
    x   = t12 ^ t17; \
  }

#define SBOX0_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t08, t09, t10; \
    u32 t12, t13, t14, t15, t17, t18, t01; \
    t01 = c   ^ d  ; \
    t02 = a   | b  ; \
    t03 = b   | c  ; \
    t04 = c   & t01; \
    t05 = t02 ^ t01; \
    t06 = a   | t04; \
    y   =     ~ t05; \
    t08 = b   ^ d  ; \
    t09 = t03 & t08; \
    t10 = d   | y  ; \
    x   = t09 ^ t06; \
    t12 = a   | t05; \
    t13 = x   ^ t12; \
    t14 = t03 ^ t10; \
    t15 = a   ^ c  ; \
    z   = t14 ^ t13; \
    t17 = t05 & t13; \
    t18 = t14 | t17; \
    w   = t15 ^ t18; \
  }

#define SBOX1(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t08; \
    u32 t10, t11, t12, t13, t16, t17, t01; \
    t01 = a   | d  ; \
    t02 = c   ^ d  ; \
    t03 =     ~ b  ; \
    t04 = a   ^ c  ; \
    t05 = a   | t03; \
    t06 = d   & t04; \
    t07 = t01 & t02; \
    t08 = b   | t06; \
    y   = t02 ^ t05; \
    t10 = t07 ^ t08; \
    t11 = t01 ^ t10; \
    t12 = y   ^ t11; \
    t13 = b   & d  ; \
    z   =     ~ t10; \
    x   = t13 ^ t12; \
    t16 = t10 | x  ; \
    t17 = t05 & t16; \
    w   = c   ^ t17; \
  }

#define SBOX1_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t08; \
    u32 t09, t10, t11, t14, t15, t17, t01; \
    t01 = a   ^ b  ; \
    t02 = b   | d  ; \
    t03 = a   & c  ; \
    t04 = c   ^ t02; \
    t05 = a   | t04; \
    t06 = t01 & t05; \
    t07 = d   | t03; \
    t08 = b   ^ t06; \
    t09 = t07 ^ t06; \
    t10 = t04 | t03; \
    t11 = d   & t08; \
    y   =     ~ t09; \
    x   = t10 ^ t11; \
    t14 = a   | y  ; \
    t15 = t06 ^ x  ; \
    z   = t01 ^ t04; \
    t17 = c   ^ t15; \
    w   = t14 ^ t17; \
  }

#define SBOX2(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t05, t06, t07, t08; \
    u32 t09, t10, t12, t13, t14, t01; \
    t01 = a   | c  ; \
    t02 = a   ^ b  ; \
    t03 = d   ^ t01; \
    w   = t02 ^ t03; \
    t05 = c   ^ w  ; \
    t06 = b   ^ t05; \
    t07 = b   | t05; \
    t08 = t01 & t06; \
    t09 = t03 ^ t07; \
    t10 = t02 | t09; \
    x   = t10 ^ t08; \
    t12 = a   | d  ; \
    t13 = t09 ^ x  ; \
    t14 = b   ^ t13; \
    z   =     ~ t09; \
    y   = t12 ^ t14; \
  }

#define SBOX2_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t06, t07, t08, t09; \
    u32 t10, t11, t12, t15, t16, t17, t01; \
    t01 = a   ^ d  ; \
    t02 = c   ^ d  ; \
    t03 = a   & c  ; \
    t04 = b   | t02; \
    w   = t01 ^ t04; \
    t06 = a   | c  ; \
    t07 = d   | w  ; \
    t08 =     ~ d  ; \
    t09 = b   & t06; \
    t10 = t08 | t03; \
    t11 = b   & t07; \
    t12 = t06 & t02; \
    z   = t09 ^ t10; \
    x   = t12 ^ t11; \
    t15 = c   & z  ; \
    t16 = w   ^ x  ; \
    t17 = t10 ^ t15; \
    y   = t16 ^ t17; \
  }

#define SBOX3(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t08; \
    u32 t09, t10, t11, t13, t14, t15, t01; \
    t01 = a   ^ c  ; \
    t02 = a   | d  ; \
    t03 = a   & d  ; \
    t04 = t01 & t02; \
    t05 = b   | t03; \
    t06 = a   & b  ; \
    t07 = d   ^ t04; \
    t08 = c   | t06; \
    t09 = b   ^ t07; \
    t10 = d   & t05; \
    t11 = t02 ^ t10; \
    z   = t08 ^ t09; \
    t13 = d   | z  ; \
    t14 = a   | t07; \
    t15 = b   & t13; \
    y   = t08 ^ t11; \
    w   = t14 ^ t15; \
    x   = t05 ^ t04; \
  }

#define SBOX3_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t09; \
    u32 t11, t12, t13, t14, t16, t01; \
    t01 = c   | d  ; \
    t02 = a   | d  ; \
    t03 = c   ^ t02; \
    t04 = b   ^ t02; \
    t05 = a   ^ d  ; \
    t06 = t04 & t03; \
    t07 = b   & t01; \
    y   = t05 ^ t06; \
    t09 = a   ^ t03; \
    w   = t07 ^ t03; \
    t11 = w   | t05; \
    t12 = t09 & t11; \
    t13 = a   & y  ; \
    t14 = t01 ^ t05; \
    x   = b   ^ t12; \
    t16 = b   | t13; \
    z   = t14 ^ t16; \
  }

#define SBOX4(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t08, t09; \
    u32 t10, t11, t12, t13, t14, t15, t16, t01; \
    t01 = a   | b  ; \
    t02 = b   | c  ; \
    t03 = a   ^ t02; \
    t04 = b   ^ d  ; \
    t05 = d   | t03; \
    t06 = d   & t01; \
    z   = t03 ^ t06; \
    t08 = z   & t04; \
    t09 = t04 & t05; \
    t10 = c   ^ t06; \
    t11 = b   & c  ; \
    t12 = t04 ^ t08; \
    t13 = t11 | t03; \
    t14 = t10 ^ t09; \
    t15 = a   & t05; \
    t16 = t11 | t12; \
    y   = t13 ^ t08; \
    x   = t15 ^ t16; \
    w   =     ~ t14; \
  }

#define SBOX4_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t09; \
    u32 t10, t11, t12, t13, t15, t01; \
    t01 = b   | d  ; \
    t02 = c   | d  ; \
    t03 = a   & t01; \
    t04 = b   ^ t02; \
    t05 = c   ^ d  ; \
    t06 =     ~ t03; \
    t07 = a   & t04; \
    x   = t05 ^ t07; \
    t09 = x   | t06; \
    t10 = a   ^ t07; \
    t11 = t01 ^ t09; \
    t12 = d   ^ t04; \
    t13 = c   | t10; \
    z   = t03 ^ t12; \
    t15 = a   ^ t04; \
    y   = t11 ^ t13; \
    w   = t15 ^ t09; \
  }

#define SBOX5(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t07, t08, t09; \
    u32 t10, t11, t12, t13, t14, t01; \
    t01 = b   ^ d  ; \
    t02 = b   | d  ; \
    t03 = a   & t01; \
    t04 = c   ^ t02; \
    t05 = t03 ^ t04; \
    w   =     ~ t05; \
    t07 = a   ^ t01; \
    t08 = d   | w  ; \
    t09 = b   | t05; \
    t10 = d   ^ t08; \
    t11 = b   | t07; \
    t12 = t03 | w  ; \
    t13 = t07 | t10; \
    t14 = t01 ^ t11; \
    y   = t09 ^ t13; \
    x   = t07 ^ t08; \
    z   = t12 ^ t14; \
  }

#define SBOX5_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t07, t08, t09; \
    u32 t10, t12, t13, t15, t16, t01; \
    t01 = a   & d  ; \
    t02 = c   ^ t01; \
    t03 = a   ^ d  ; \
    t04 = b   & t02; \
    t05 = a   & c  ; \
    w   = t03 ^ t04; \
    t07 = a   & w  ; \
    t08 = t01 ^ w  ; \
    t09 = b   | t05; \
    t10 =     ~ b  ; \
    x   = t08 ^ t09; \
    t12 = t10 | t07; \
    t13 = w   | x  ; \
    z   = t02 ^ t12; \
    t15 = t02 ^ t13; \
    t16 = b   ^ d  ; \
    y   = t16 ^ t15; \
  }

#define SBOX6(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t07, t08, t09, t10; \
    u32 t11, t12, t13, t15, t17, t18, t01; \
    t01 = a   & d  ; \
    t02 = b   ^ c  ; \
    t03 = a   ^ d  ; \
    t04 = t01 ^ t02; \
    t05 = b   | c  ; \
    x   =     ~ t04; \
    t07 = t03 & t05; \
    t08 = b   & x  ; \
    t09 = a   | c  ; \
    t10 = t07 ^ t08; \
    t11 = b   | d  ; \
    t12 = c   ^ t11; \
    t13 = t09 ^ t10; \
    y   =     ~ t13; \
    t15 = x   & t03; \
    z   = t12 ^ t07; \
    t17 = a   ^ b  ; \
    t18 = y   ^ t15; \
    w   = t17 ^ t18; \
  }

#define SBOX6_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t07, t08, t09; \
    u32 t12, t13, t14, t15, t16, t17, t01; \
    t01 = a   ^ c  ; \
    t02 =     ~ c  ; \
    t03 = b   & t01; \
    t04 = b   | t02; \
    t05 = d   | t03; \
    t06 = b   ^ d  ; \
    t07 = a   & t04; \
    t08 = a   | t02; \
    t09 = t07 ^ t05; \
    x   = t06 ^ t08; \
    w   =     ~ t09; \
    t12 = b   & w  ; \
    t13 = t01 & t05; \
    t14 = t01 ^ t12; \
    t15 = t07 ^ t13; \
    t16 = d   | t02; \
    t17 = a   ^ x  ; \
    z   = t17 ^ t15; \
    y   = t16 ^ t14; \
  }

#define SBOX7(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t05, t06, t08, t09, t10; \
    u32 t11, t13, t14, t15, t16, t17, t01; \
    t01 = a   & c  ; \
    t02 =     ~ d  ; \
    t03 = a   & t02; \
    t04 = b   | t01; \
    t05 = a   & b  ; \
    t06 = c   ^ t04; \
    z   = t03 ^ t06; \
    t08 = c   | z  ; \
    t09 = d   | t05; \
    t10 = a   ^ t08; \
    t11 = t04 & z  ; \
    x   = t09 ^ t10; \
    t13 = b   ^ x  ; \
    t14 = t01 ^ x  ; \
    t15 = c   ^ t05; \
    t16 = t11 | t13; \
    t17 = t02 | t14; \
    w   = t15 ^ t17; \
    y   = a   ^ t16; \
  }

#define SBOX7_INVERSE(a, b, c, d, w, x, y, z) \
  { \
    u32 t02, t03, t04, t06, t07, t08, t09; \
    u32 t10, t11, t13, t14, t15, t16, t01; \
    t01 = a   & b  ; \
    t02 = a   | b  ; \
    t03 = c   | t01; \
    t04 = d   & t02; \
    z   = t03 ^ t04; \
    t06 = b   ^ t04; \
    t07 = d   ^ z  ; \
    t08 =     ~ t07; \
    t09 = t06 | t08; \
    t10 = b   ^ d  ; \
    t11 = a   | d  ; \
    x   = a   ^ t09; \
    t13 = c   ^ t06; \
    t14 = c   & t11; \
    t15 = d   | x  ; \
    t16 = t01 | t10; \
    w   = t13 ^ t15; \
    y   = t14 ^ t16; \
  }

#define LINEAR_TRANSFORMATION(block)				\
  {								\
    block[0] = rotl32(block[0], 13);				\
    block[2] = rotl32(block[2], 3);				\
    block[1] = block[1] ^ block[0] ^ block[2];			\
    block[3] = block[3] ^ block[2] ^ (block[0] << 3);		\
    block[1] = rotl32(block[1], 1);				\
    block[3] = rotl32(block[3], 7);				\
    block[0] = block[0] ^ block[1] ^ block[3];			\
    block[2] = block[2] ^ block[3] ^ (block[1] << 7);		\
    block[0] = rotl32(block[0], 5);				\
    block[2] = rotl32(block[2], 22);				\
  }

/* Apply the inverse linear transformation to BLOCK.  */
#define LINEAR_TRANSFORMATION_INVERSE(block)			\
  {								\
    block[2] = rotr32(block[2], 22);				\
    block[0] = rotr32(block[0] , 5);				\
    block[2] = block[2] ^ block[3] ^ (block[1] << 7);		\
    block[0] = block[0] ^ block[1] ^ block[3];			\
    block[3] = rotr32(block[3], 7);				\
    block[1] = rotr32(block[1], 1);				\
    block[3] = block[3] ^ block[2] ^ (block[0] << 3);		\
    block[1] = block[1] ^ block[0] ^ block[2];			\
    block[2] = rotr32(block[2], 3);				\
    block[0] = rotr32(block[0], 13);				\
  }

/* XOR BLOCK1 into BLOCK0.  */
#define BLOCK_XOR(block0, block1)				\
  {								\
    block0[0] ^= block1[0];					\
    block0[1] ^= block1[1];					\
    block0[2] ^= block1[2];					\
    block0[3] ^= block1[3];					\
  }

/* Copy BLOCK_SRC to BLOCK_DST.  */
#define BLOCK_COPY(block_dst, block_src)			\
  {								\
    block_dst[0] = block_src[0];				\
    block_dst[1] = block_src[1];				\
    block_dst[2] = block_src[2];				\
    block_dst[3] = block_src[3];				\
  }


static void  SBOX(serpent_byte which, serpent_word32 array0[], serpent_word32 array1[], serpent_byte index)
{
	switch(which)
	{
		case 0: SBOX0(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 1: SBOX1(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 2: SBOX2(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 3: SBOX3(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 4: SBOX4(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 5: SBOX5(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 6: SBOX6(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 7: SBOX7(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
	}
}

static void  SBOX_INVERSE(serpent_byte which, serpent_word32 array0[], serpent_word32 array1[], serpent_byte index)
{
	switch(which)
	{
		case 0: SBOX0_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
 		case 1: SBOX1_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
 		case 2: SBOX2_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 3: SBOX3_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 4: SBOX4_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 5: SBOX5_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 6: SBOX6_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
		case 7: SBOX7_INVERSE(array0[0], array0[1], array0[2], array0[3], array1[0+index], array1[1+index], array1[2+index], array1[3+index]); break;
	}
}



/* Apply an inverse Serpent round to BLOCK, using the SBOX number
   WHICH and the subkeys contained in SUBKEYS.  Use BLOCK_TMP as
   temporary storage.  This macro increments `round'.  */
#define ROUND_INVERSE(which, subkey, block, block_tmp)		\
  {								\
    LINEAR_TRANSFORMATION_INVERSE (block);			\
    SBOX_INVERSE (which, block, block_tmp, 0);			\
    BLOCK_XOR (block_tmp, subkey[round]);			\
    BLOCK_COPY (block, block_tmp);				\
  }

/* Apply the first Serpent round to BLOCK, using the SBOX number WHICH
   and the subkeys contained in SUBKEYS.  Use BLOCK_TMP as temporary
   storage.  The result will be stored in BLOCK_TMP.  This macro
   increments `round'.  */
#define ROUND_FIRST_INVERSE(which, subkeys, block, block_tmp)	\
  {								\
    BLOCK_XOR (block, subkeys[round]);				\
    round--;							\
    SBOX_INVERSE (which, block, block_tmp, 0);			\
    BLOCK_XOR (block_tmp, subkeys[round]);			\
    round--;							\
  }

#define ROUND(which, subkeys, block, block_tmp)			\
  {								\
    BLOCK_XOR (block, subkeys[round]);				\
    SBOX(which, block, block_tmp, 0);				\
    LINEAR_TRANSFORMATION (block_tmp);				\
    BLOCK_COPY (block, block_tmp);				\
  }

#define ROUND_LAST(which, subkeys, block, block_tmp)		\
  {								\
    BLOCK_XOR (block, subkeys[round]);			\
		round++;															\
    SBOX(which, block, block_tmp, 0);				\
    BLOCK_XOR (block_tmp, subkeys[round]);			\
		round++;															\
  }


// Initial Key Padding and Setup
static void serpent_init(serpent_ctx* ctx, const void* key, size_t keysize_bytes)
{
	serpent_word32 k[132];
	serpent_word32 buffer[8];
	serpent_byte i, j;

	memset(buffer, 0, 4*8);
	memset(k, 0, 4*132);

  for (i = 0; i < keysize_bytes/4; i++)
    {
#ifdef WORDS_BIGENDIAN
      buffer[i] = byte_swap_32 (((serpent_word32 *) key)[i]);
#else
      buffer[i] = ((serpent_word32 *) key)[i];
#endif
    }

	if(keysize_bytes < 32)
		buffer[(keysize_bytes*8)/32] |= ((serpent_word32) 1)<<((keysize_bytes * 8)%32);
	
	// This Routine Generates PreKeys
	for(i = 0; i < 33; i++)
		for(j=0; j < 4; j++)
		{
			ctx->subkey[i][j] = serpent_gen_w(buffer, i*4 + j);
			memmove(buffer, &(buffer[1]), 7*4);
			//void * memmove ( void * destination, const void * source, size_t num );
			buffer[7] = ctx->subkey[i][j];
		}

	// Now we Should Check The SBOXES
	serpent_byte sbox_count = 3;
	serpent_byte round;
	for(round = 0; round < 33; round++)
	{
		SBOX(sbox_count, ctx->subkey[round], k, round*4);
		sbox_count = sbox_count ? sbox_count-1 : 7;
	}

	for(i = 0; i<33; i++)
		for(j=0; j<4; j++)
			ctx->subkey[i][j] = k[4*i+j];
}

static void serpent_encrypt(serpent_ctx* ctx, const serpent_word32* plainText, serpent_word32* cipherText)
{
	serpent_word32 storage[4], next[4];
	int round = 0;
#if BYTE_ORDER == BIG_ENDIAN
	storage[0] = byte_swap_32(plainText[0]); storage[1] = byte_swap_32(plainText[1]); storage[2] = byte_swap_32(plainText[2]); storage[3] = byte_swap_32(plainText[3]);
#else
	storage[0] = plainText[0]; storage[1] = plainText[1]; storage[2] = plainText[2]; storage[3] = plainText[3];
#endif
	
	for(round = 0; round < 31; round++)
		ROUND(round % 8, ctx->subkey, storage, next);

	//Final Round
	ROUND_LAST(7, ctx->subkey, storage, next);
#if BYTE_ORDER == BIG_ENDIAN
	cipherText[0] = byte_swap_32(next[0]); cipherText[1] = byte_swap_32(next[1]);	cipherText[2] = byte_swap_32(next[2]);	cipherText[3] = byte_swap_32(next[3]);
#else
	cipherText[0] = next[0]; cipherText[1] = next[1];	cipherText[2] = next[2];	cipherText[3] = next[3];
#endif	
}

static void serpent_decrypt(serpent_ctx* ctx, serpent_word32* plainText, const serpent_word32* cipherText)
{
	serpent_word32 storage[4], next[4];
	int round = 32;
#if BYTE_ORDER == BIG_ENDIAN
	next[0] = byte_swap_32(cipherText[0]); next[1] = byte_swap_32(cipherText[1]); next[2] = byte_swap_32(cipherText[2]); next[3] = byte_swap_32(cipherText[3]);
#else
	next[0] = cipherText[0]; next[1] = cipherText[1]; next[2] = cipherText[2]; next[3] = cipherText[3];
#endif

	ROUND_FIRST_INVERSE(7, ctx->subkey, next, storage);
	for(round = 30; round >= 0; round--)
		ROUND_INVERSE(round % 8, ctx->subkey, storage, next);

#if BYTE_ORDER == BIG_ENDIAN
plainText[0] = byte_swap_32(next[0]); plainText[1] = byte_swap_32(next[1]);	plainText[2] = byte_swap_32(next[2]); plainText[3] = byte_swap_32(next[3]);	
#else
plainText[0] = next[0]; plainText[1] = next[1];	plainText[2] = next[2]; plainText[3] = next[3];
#endif
}



void SERPENT_set_key(unsigned char *key, int keysize, SERPENT_KEY *serpent_key)
{
    serpent_init(serpent_key, key, (keysize/8));
}

void SERPENT_encrypt(SERPENT_KEY *serpent_key,char *input, char *output)
{
    serpent_encrypt(serpent_key, (const serpent_word32 *)input, (serpent_word32 *)output);
}

void SERPENT_decrypt(SERPENT_KEY *serpent_key,char *input, char *output)
{
    serpent_decrypt(serpent_key, (const serpent_word32 *)output, (serpent_word32 *)input);
}
