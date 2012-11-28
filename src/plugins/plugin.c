/* plugin.c
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


#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <stdio.h>
#include "plugin.h"
#include "hashinterface.h"

/* Public functions */
void register_add_username(void *(*add_username)(const char *username));
void register_add_hash(void *(*add_hash)(const char *hash, int len));
void register_add_salt(void *(*add_salt)(const char *salt));
void register_add_salt2(void *(*add_salt2)(const char *salt2));
void register_md5(hash_stat (*md5)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid));
void register_md5_unicode(void * (*md5_unicode)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]));
void register_md5_unicode_slow(void * (*md5_unicode_slow)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]));
void register_md5slow(void * (*md5_slow)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid));
void register_md4(hash_stat (*md4)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE], int threadid));
void register_md4_unicode(hash_stat (*md4)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid));
void register_md4_slow(void * (*md4_slow)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE], int threadid));
void register_md5_hex(void * (*md5_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha1(hash_stat (*sha1)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid));
void register_sha1_unicode(void * (*sha1_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha1_slow(void * (*sha1_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha1_hex(void * (*sha1_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha256_unicode(void * (*sha256_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha256_hex(void * (*sha256_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_sha512_unicode(void * (*sha512_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]));
void register_sha512_hex(void * (*sha512_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]));
void register_fcrypt(hash_stat (*hfcrypt)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]));
void register_fcrypt_slow(hash_stat (*hfcrypt_slow)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]));
void register_PEM_readfile(void * (*PEM_readfile)(const char *passphrase, int *RSAret));
void register_new_biomem(void * (*new_biomem)(FILE *filename));
void register_pbkdf2(void * (*pbkdf2)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdf2_len(void * (*pbkdf2_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_pbkdf2_256_len(void * (*pbkdf2_256_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_hmac_sha1_file(void * (*hmac_sha1_file)(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen));
void register_hmac_sha1(void * (*hmac_sha1)(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen));
void register_hmac_md5(void * (*hmac_md5)(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen));
void register_pbkdf512(void * (*pbkdf512)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out));
void register_aes_encrypt(void * (*aes_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode));
void register_aes_decrypt(void * (*aes_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode));
void register_des_ecb_encrypt(void * (*des_ecb_encrypt)(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode));
void register_des_ecb_decrypt(void * (*des_ecb_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode));
void register_des_cbc_encrypt(void * (*des_cbc_encrypt)(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *cbc[VECTORSIZE], int mode));
void register_rc4_encrypt(void * (*rc4_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out));
void register_lm(void * (*lm)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]));
void register_lm_slow(void * (*lm_slow)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]));
void register_aes_cbc_encrypt(void * (*aes_cbc_encrypt)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper));
void register_aes_set_encrypt_key(int * (*aes_set_encrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key));
void register_aes_set_decrypt_key(int * (*aes_set_decrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key));


char* strupr(char* ioString);
char* strlow(char* ioString);


void register_add_username(void *(*add_username)(const char *username))
{
    hash_add_username = add_username;
}

void register_add_hash(void *(*add_hash)(const char *hash, int len))
{
    hash_add_hash = add_hash;
}

void register_add_salt(void *(*add_salt)(const char *salt))
{
    hash_add_salt = add_salt;
}

void register_add_salt2(void *(*add_salt2)(const char *salt2))
{
    hash_add_salt2 = add_salt2;
}

void register_ripemd160(void * (*ripemd160)(const char *plaintext[VECTORSIZE], char *hashripe[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_ripemd160 = ripemd160;
}


void register_md5(hash_stat  (*md5)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid))
{
    hash_md5 = md5;
}

void register_md5_slow(void * (*md5_slow)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid))
{
    hash_md5_slow = md5_slow;
}


void register_md4(hash_stat (*md4)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE],int threadid))
{
    hash_md4 = md4;
}


void register_md4_unicode(hash_stat (*md4_unicode)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len,int threadid))
{
    hash_md4_unicode = md4_unicode;
}


void register_md4_slow(void * (*md4_slow)(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE],int threadid))
{
    hash_md4_slow = md4_slow;
}


void register_md5_hex(void * (*md5_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]))
{
    hash_md5_hex = md5_hex;
}

void register_sha1(hash_stat (*sha1)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid))
{
    hash_sha1 = sha1;
}

void register_sha1_unicode(void * (*sha1_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_sha1_unicode = sha1_unicode;
}

void register_sha1_slow(void * (*sha1_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_sha1_slow = sha1_slow;
}



void register_md5_unicode(void * (*md5_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_md5_unicode = md5_unicode;
}

void register_md5_unicode_slow(void * (*md5_unicode_slow)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_md5_unicode_slow = md5_unicode_slow;
}



void register_sha1_hex(void * (*sha1_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]))
{
    hash_sha1_hex = sha1_hex;
}

void register_sha256_unicode(void * (*sha256_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_sha256_unicode = sha256_unicode;
}

void register_sha256_hex(void * (*sha256_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]))
{
    hash_sha256_hex = sha256_hex;
}


void register_sha512_unicode(void * (*sha512_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE]))
{
    hash_sha512_unicode = sha512_unicode;
}

void register_sha512_hex(void * (*sha512_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]))
{
    hash_sha512_hex = sha512_hex;
}

void register_fcrypt(hash_stat (*hfcrypt)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]))
{
    hash_fcrypt = hfcrypt;
}

void register_fcrypt_slow(hash_stat (*hfcrypt_slow)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]))
{
    hash_fcrypt_slow = hfcrypt_slow;
}

void register_PEM_readfile(void * (*PEM_readfile)(const char *passphrase, int *RSAret))
{
    hash_PEM_readfile = PEM_readfile;
}

void register_new_biomem(void * (*new_biomem)(FILE *filename))
{
    hash_new_biomem = new_biomem;
}

void register_pbkdf2(void * (*pbkdf2)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out))
{
    hash_pbkdf2 = pbkdf2;
}

void register_pbkdf2_len(void * (*pbkdf2_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out))
{
    hash_pbkdf2_len = pbkdf2_len;
}

void register_pbkdf2_256_len(void * (*pbkdf2_256_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out))
{
    hash_pbkdf2_256_len = pbkdf2_256_len;
}

void register_hmac_sha1_file(void * (*hmac_sha1_file)(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen))
{
    hash_hmac_sha1_file = hmac_sha1_file;
}

void register_hmac_sha1(void * (*hmac_sha1)(void *key, int keylen, unsigned char *data, int datalen,  unsigned char *output, int outputlen))
{
    hash_hmac_sha1 = hmac_sha1;
}

void register_hmac_md5(void * (*hmac_md5)(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen))
{
    hash_hmac_md5 = hmac_md5;
}


void register_pbkdf512(void * (*pbkdf512)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out))
{
    hash_pbkdf512 = pbkdf512;
}


void register_aes_encrypt(void * (*aes_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode))
{
    hash_aes_encrypt = aes_encrypt;
}


void register_aes_decrypt(void * (*aes_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode))
{
    hash_aes_decrypt = aes_decrypt;
}


void register_des_ecb_encrypt(void * (*des_ecb_encrypt)(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode))
{
    hash_des_ecb_encrypt = des_ecb_encrypt;
}


void register_des_ecb_decrypt(void * (*des_ecb_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode))
{
    hash_des_ecb_decrypt = des_ecb_decrypt;
}

void register_des_cbc_encrypt(void * (*des_cbc_encrypt)(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode))
{
    hash_des_cbc_encrypt = des_cbc_encrypt;
}

void register_rc4_encrypt(void * (*rc4_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out))
{
    hash_rc4_encrypt = rc4_encrypt;
}


void register_lm(void * (*lm)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]))
{
    hash_lm = lm;
}

void register_lm_slow(void * (*lm_slow)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]))
{
    hash_lm_slow = lm_slow;
}

void register_aes_cbc_encrypt(void * (*aes_cbc_encrypt)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper))
{
    hash_aes_cbc_encrypt = aes_cbc_encrypt;
}
void register_aes_set_encrypt_key(int * (*aes_set_encrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key))
{
    hash_aes_set_encrypt_key = aes_set_encrypt_key;
}
void register_aes_set_decrypt_key(int * (*aes_set_decrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key))
{
    hash_aes_set_decrypt_key = aes_set_decrypt_key;
}




int fastcompare(const char *s1, const char *s2, int length)
{
    unsigned int i;
    
    for(i=0; i < length; i++)
    {
        if(*(s1+i) != *(s2+i)) return 1;
    }
    return 0;
}


char* strupr(char* ioString)
{
    int i;
    int theLength = (int)strlen(ioString);

    for(i=0; i<theLength; ++i) {ioString[i] = toupper(ioString[i]);}
    return ioString;
}


char* strlow(char* ioString)
{
    int i;
    int theLength = (int)strlen(ioString);

    for(i=0; i<theLength; ++i) {ioString[i] = tolower(ioString[i]);}
    return ioString;
}


void hex2str(char *str, char *hex, int len)
{
    int cnt, cnt1;
    unsigned char val=0;
    unsigned char tmp1=0,tmp2=0;
    char *charset="0123456789abcdef";
    bzero(str, (len/2));

    for (cnt=0;cnt<(len/2);cnt++)
    {
	val = 0;
	for (cnt1=0;cnt1<16;cnt1++) if (charset[cnt1] == hex[cnt*2]) tmp1 = cnt1;
	for (cnt1=0;cnt1<16;cnt1++) if (charset[cnt1] == hex[cnt*2+1]) tmp2 = cnt1;
	val |= (tmp1 << 4);
	val |= tmp2;
	
	*(str+cnt) = val & 255;
    }
}


char itoa64[] = "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
void _to64(char *s, unsigned long v, int n)
{

        while (--n >= 0) {
                *s++ = itoa64[v&0x3f];
                v >>= 6;
        }
}



