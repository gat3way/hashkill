/* cpu-serpent.h
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


#ifndef SERPENT_H
#define SERPENT_H

#include <inttypes.h>

typedef uint8_t  serpent_byte;          /* Exactly 1 byte  */
typedef uint16_t serpent_word16;        /* Exactly 2 bytes */
typedef uint32_t serpent_word32;        /* Exactly 4 bytes */
typedef uint64_t serpent_word64;        /* Exactly 8 bytes */
typedef serpent_word32 u32;
typedef serpent_word32 serpent_subkey[4];
typedef struct _Serpent_CTX { serpent_subkey subkey[33]; } serpent_ctx;



#define SERPENT_KEY serpent_ctx
void SERPENT_set_key(unsigned char *key, int keysize, SERPENT_KEY *serpent_key);
void SERPENT_encrypt(SERPENT_KEY *serpent_key,char *input, char *output);
void SERPENT_decrypt(SERPENT_KEY *serpent_key,char *input, char *output);

#endif
