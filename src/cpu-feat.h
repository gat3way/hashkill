/* cpu-feat.h
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

#ifndef CPU_FEAT_H
#define CPU_FEAT_H

#include "err.h"
#include "hashinterface.h"
#include <openssl/aes.h>



/* cpu functions  */
hash_stat cpu_feat_setup();
hash_stat (*OMD5)(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
hash_stat (*OMD5_SHORT)(unsigned char* pPlain[VECTORSIZE], int nPlainLen[VECTORSIZE], unsigned char* pHash[VECTORSIZE]);
hash_stat (*OMD5_FIXED)(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
hash_stat (*OMD5_SHORT_FIXED)(unsigned char* pPlain[VECTORSIZE], int nPlainLen, unsigned char* pHash[VECTORSIZE]);
hash_stat (*OSHA1)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
hash_stat (*OSHA1_SHORT)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
hash_stat (*OSHA1_FIXED)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
hash_stat (*OSHA1_SHORT_FIXED)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
hash_stat (*OMD4)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
hash_stat (*OMD4_SHORT)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen[VECTORSIZE]);
hash_stat (*OMD4_FIXED)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
hash_stat (*OMD4_SHORT_FIXED)(char* pPlain[VECTORSIZE], char* pHash[VECTORSIZE], int nPlainLen);
hash_stat (*ODES_FCRYPT)(char salt[3], char *plains[128], char *out[128]);
void (*ODES_ONEBLOCK)(char ukey[8], char *plains[128], char *out[128]);
void (*ODES_LM)(char *plains[128], char *out[128]);
void (*ODES_CBC)(char ukey[8], char *plains[128], char *out[128], char *ivs[128], int lens[128]);
void (*OMD5_PREPARE_OPT)(void);
void (*OSHA1_PREPARE_OPT)(void);
void (*OMD4_PREPARE_OPT)(void);
void (*OFCRYPT_PREPARE_OPT)(void);
void (*OAES_CBC_ENCRYPT)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper);
int (*OAES_SET_ENCRYPT_KEY)(const unsigned char *userKey,const int bits,AES_KEY *key);
int (*OAES_SET_DECRYPT_KEY)(const unsigned char *userKey, const int bits, AES_KEY *key);


#endif
