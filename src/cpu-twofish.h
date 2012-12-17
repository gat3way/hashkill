/* cpu-twofish.h
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


#ifndef TWOFISH_H
#define TWOFISH_H

#define TWOFISH_KEY int

void TWOFISH_set_key(unsigned char *key, int keysize, TWOFISH_KEY *twofish_key);
void TWOFISH_encrypt(TWOFISH_KEY *key,char *input, char *output);
void TWOFISH_decrypt(TWOFISH_KEY *key,char *input, char *output);

#endif
