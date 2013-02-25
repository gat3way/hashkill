/* plugin.h
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


#ifndef PLUGIN_H
#define PLUGIN_H

#include <stdio.h>
#include <openssl/aes.h>
#include "err.h"
#include "hashinterface.h"




void *(*hash_add_username)(const char *username);
void *(*hash_add_hash)(const char *hash, int len);
void *(*hash_add_salt)(const char *salt);
void *(*hash_add_salt2)(const char *salt2);
hash_stat (*hash_md5)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid);
void *(*hash_md5_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_md5_unicode_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_md5_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid);
hash_stat (*hash_md4)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid);
hash_stat (*hash_md4_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len,int threadid);
void *(*hash_md4_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid);
void *(*hash_md5_hex)(const char *hash[VECTORSIZE],  char *hashhex[VECTORSIZE]);
hash_stat (*hash_sha1)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid);
void *(*hash_sha1_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_sha1_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_ripemd160)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_whirlpool)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_sha1_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void *(*hash_sha256_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_sha256_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void *(*hash_sha512_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_sha384_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]);
void *(*hash_sha512_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
hash_stat (*hash_fcrypt)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]);
hash_stat (*hash_fcrypt_slow)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]);
void *(*hash_PEM_readfile)(const char *passphrase, int *RSAret);
void *(*hash_new_biomem)(FILE *filename);
void *(*hash_pbkdf2)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_pbkdf2_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_pbkdf2_256_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_hmac_sha1_file)(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen);
void *(*hash_hmac_sha1)(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen);
void *(*hash_hmac_md5)(void *key, int keylen, unsigned char *data, int datalen,  unsigned char *output, int outputlen);
void *(*hash_pbkdf512)(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_pbkdfrmd160)(const char *pass, int len,  unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_pbkdfwhirlpool)(const char *pass, int len,  unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void *(*hash_aes_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode);
void *(*hash_aes_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode);
void *(*hash_des_ecb_encrypt)(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode);
void *(*hash_des_ecb_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode);
void *(*hash_des_cbc_encrypt)(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode);
void *(*hash_rc4_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out);
void *(*hash_lm)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]);
void *(*hash_lm_slow)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]);
void *(*hash_aes_cbc_encrypt)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper);
int *(*hash_aes_set_encrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key);
int *(*hash_aes_set_decrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key);
void *(*hash_decrypt_aes_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);
void *(*hash_decrypt_twofish_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);
void *(*hash_decrypt_serpent_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);


void register_add_username(void *(*add_username)(const char *username));
void register_add_hash(void *(*add_hash)(const char *hash, int len));
void register_add_salt(void *(*add_salt)(const char *salt));
void register_add_salt2(void *(*add_salt2)(const char *salt2));
void register_ripemd160(void *(*ripemd160)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_whirlpool(void *(*whirlpool)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_md5(hash_stat (*md5)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid));
void register_md5_unicode(void *(*md5_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_md5_unicode_slow(void *(*md5_unicode_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_md5_slow(void *(*md5_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid));
void register_md4(hash_stat (*md4)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid));
void register_md4_unicode(hash_stat (*md4)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len,int threadid));
void register_md4_slow(void *(*md4_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid));
void register_md5_hex(void *(*md5_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha1(hash_stat (*sha1)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid));
void register_sha1_unicode(void *(*sha1)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha1_slow(void *(*sha1_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha1_hex(void *(*sha1_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha256_unicode(void *(*sha256_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha256_hex(void *(*sha256_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha512_unicode(void *(*sha512_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha384_unicode(void *(*sha384_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha512_hex(void *(*sha512_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_fcrypt(hash_stat (*hfcrypt)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]));
void register_fcrypt_slow(hash_stat (*hfcrypt_slow)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]));
void register_PEM_readfile(void *(*PEM_readfile)(const char *passphrase, int *RSAret));
void register_new_biomem(void *(*PEM_readfile)(FILE *filename));
void register_pbkdf2(void *(*pbkdf2)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdf2_len(void *(*pbkdf2_len)(const char *pass, int passlen,unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdf2_256_len(void *(*pbkdf2_256_len)(const char *pass, int passlen,unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_hmac_sha1_file(void *(*hmac_sha1_file)(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen));
void register_hmac_sha1(void *(*hmac_sha1)(void *key, int keylen,unsigned char *data, int datalen, unsigned char *output, int outputlen));
void register_hmac_md5(void *(*hmac_md5)(void *key, int keylen,unsigned char *data, int datalen, unsigned char *output, int outputlen));
void register_pbkdf512(void *(*pbkdf512)(const char *pass, int len,  unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdfrmd160(void *(*pbkdfrmd160)(const char *pass, int len,  unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdfwhirlpool(void *(*pbkdfwhirlpool)(const char *pass, int len,  unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_aes_encrypt(void *(*aes_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode));
void register_aes_decrypt(void *(*aes_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode));
void register_des_ecb_encrypt(void *(*des_ecb_encrypt)(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode));
void register_des_ecb_decrypt(void *(*des_ecb_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode));
void register_des_cbc_encrypt(void *(*des_cbc_encrypt)(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode));
void register_rc4_encrypt(void *(*rc4_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out));
void register_lm(void *(*lm)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]));
void register_lm_slow(void *(*lm_slow)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]));
void register_aes_cbc_encrypt(void *(*aes_cbc_encrypt)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper));
void register_aes_set_encrypt_key(int *(*aes_set_encrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key));
void register_aes_set_decrypt_key(int *(*aes_set_decrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key));
void register_decrypt_aes_xts(void *(*decrypt_aes_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block));
void register_decrypt_twofish_xts(void *(*decrypt_twofish_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block));
void register_decrypt_serpent_xts(void *(*decrypt_serpent_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block));


int fastcompare(const char *s1, const char *s2, int length);
char* strupr(char* ioString);
char* strlow(char* ioString);
void hex2str(char *str, char *hex, int len);
void _to64(char *s, unsigned long v, int n);
unsigned char* hash_memmem(unsigned char* haystack, int hlen, char* needle, int nlen);


#endif
