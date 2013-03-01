/* 
 * plugins.c
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

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <dlfcn.h>
#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <pthread.h>
#include "plugins.h"
#include "threads.h"
#include "err.h"
#include "hashinterface.h"
#include "ocl-threads.h"

//#include "plugins/plugin.h"


/* Global variables */
static char currentplugin[HASHFILE_MAX_LINE_LENGTH];	// current plugin in use
/* detecting is just a flag which controls whether load_plugin() reused by detect_plugin() will print out smth */
static int detecting=0;
/* dlhandle used */
static void *dlhandle;


/* Function prototypes */
hash_stat print_plugins_summary(char *plugindir);
void print_plugin_detailed(char *plugin);
char *get_current_plugin(void);
void set_current_plugin(const char *plugin);
hash_stat load_plugin(void);
hash_stat detect_plugin(char *plugindir,char *file, char *hash);



/* Print info on all available plugins */
hash_stat print_plugins_summary(char *plugindir)
{
    char * (*hash_plugin_summary)(void);
    struct dirent **dentrylist;
    char soname[1024];
    char soname1[1024];
    DIR *dir;
    int count=-1,i=0,j=0;

    dir=opendir(plugindir);
    if (!dir)
    {
	elog("Cannot open plugins dir: %s", plugindir);
	return hash_err;
    }
    closedir(dir);

    
    hlog("Plugins list: %s\n\n","");
    
    count = scandir(plugindir, &dentrylist, 0, alphasort);
    do
    {
	errno = 0;
	if (strstr(dentrylist[i]->d_name, ".so"))
	{
	    snprintf(soname,1024,"%s/%s", plugindir, dentrylist[i]->d_name);
	    dlhandle=dlopen(soname,RTLD_LAZY);
	    if (dlhandle)
	    {
	        *(void **) (&hash_plugin_summary) = dlsym(dlhandle, "hash_plugin_summary");
	        if (hash_plugin_summary != NULL) 
	        {
	    	    for (j=0;j<strlen(dentrylist[i]->d_name)-3;j++) soname1[j]=dentrylist[i]->d_name[j];
	    	    soname1[j]=0;
	    	    if (ocl_is_supported_plugin(soname1) == hash_ok) printf("\033[1m%s\033[0m\n",hash_plugin_summary());
	    	    else printf("%s\n",hash_plugin_summary());
	    	}
	        dlclose(dlhandle);
	    }
	}
	i++;
    } while (i<count);
    free(dentrylist);
    printf("\n\033[1m*\033[0m supported on GPUs\n\n");
    return hash_ok;
}


/* Print detailed info on plugin */
void print_plugin_detailed(char *plugin)
{
    char soname[1024];
    char * (*hash_plugin_detailed)(void);

    snprintf(soname,1024,"%s/hashkill/plugins/%s.so",DATADIR, plugin);
    dlhandle=dlopen(soname,RTLD_LAZY);
    if (dlhandle)
    {
        *(void **) (&hash_plugin_detailed) = dlsym(dlhandle, "hash_plugin_detailed");
        if (hash_plugin_detailed != NULL) printf("\n%s\n\n",hash_plugin_detailed());
        dlclose(dlhandle);
    }
    else 
    {
	elog("Cannot open plugin library: %s\n",soname);
    }
}



/* Get current plugin */
char *get_current_plugin(void)
{
    return (char *)&currentplugin;
}


/* Set current plugin */
void set_current_plugin(const char *plugin)
{
    strcpy(currentplugin,plugin);
}


/* Load plugin */
hash_stat load_plugin(void)
{
    char soname[1024];

    snprintf(soname,1024,"%s/hashkill/plugins/%s.so", DATADIR, get_current_plugin());
    dlhandle=dlopen(soname,RTLD_LAZY);
    if (dlhandle)
    {
        *(hash_stat **) (&hash_plugin_parse_hash) = dlsym(dlhandle, "hash_plugin_parse_hash");
        *(hash_stat **) (&hash_plugin_check_hash) = dlsym(dlhandle, "hash_plugin_check_hash");
        *(hash_stat **) (&hash_plugin_check_hash_dictionary) = dlsym(dlhandle, "hash_plugin_check_hash_dictionary");
        /* no special dictionary function? */
        if (hash_plugin_check_hash_dictionary==NULL)
        {
    	    *(hash_stat **) (&hash_plugin_check_hash_dictionary) = dlsym(dlhandle, "hash_plugin_check_hash");
        }

        *(int **) (&hash_plugin_hash_length) = dlsym(dlhandle, "hash_plugin_hash_length");
        *(int **) (&hash_plugin_is_raw) = dlsym(dlhandle, "hash_plugin_is_raw");
        *(int **) (&hash_plugin_is_special) = dlsym(dlhandle, "hash_plugin_is_special");
        *(void **) (&get_vector_size) = dlsym(dlhandle, "get_vector_size");
        *(int **) (&get_salt_size) = dlsym(dlhandle, "get_salt_size");
	
	if ( (!hash_plugin_parse_hash) || (!hash_plugin_check_hash) || (!hash_plugin_hash_length) || (!get_vector_size) || (!get_salt_size))
	{
	    if (!detecting) elog("Plugin %s does not export all the necessary functions!\n", get_current_plugin());
	    return hash_err;
	}
	salt_size = get_salt_size();

	/* import register functions */
	void(*register_add_username)(void (*add_username)(const char *username)) = dlsym(dlhandle, "register_add_username");
	void(*register_add_hash)(void (*add_hash)(const char *hash, int len)) = dlsym(dlhandle, "register_add_hash");
	void(*register_add_salt)(void (*add_salt)(const char *salt)) = dlsym(dlhandle, "register_add_salt");
	void(*register_add_salt2)(void (*add_salt2)(const char *salt2)) = dlsym(dlhandle, "register_add_salt2");
	void(*register_md5)(hash_stat  (*md5)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid)) = dlsym(dlhandle, "register_md5");
	void(*register_md5_unicode)(void (*md5_unicode)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_md5_unicode");
	void(*register_md5_unicode_slow)(void (*md5_unicode_slow)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_md5_unicode_slow");
	void(*register_md5_slow)(void (*md5_slow)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid)) = dlsym(dlhandle, "register_md5_slow");
	void(*register_md4)(hash_stat (*md4)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid)) = dlsym(dlhandle, "register_md4");
	void(*register_md4_unicode)(hash_stat (*md4)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len,int threadid)) = dlsym(dlhandle, "register_md4_unicode");
	void(*register_md4_slow)(void (*md4_slow)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE],int threadid)) = dlsym(dlhandle, "register_md4_slow");
	void(*register_md5_hex)(void (*md5_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])) = dlsym(dlhandle, "register_md5_hex");
	void(*register_sha1)(hash_stat (*md5)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len, int threadid)) = dlsym(dlhandle, "register_sha1");
	void(*register_sha1_unicode)(void (*sha1_unicode)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_sha1_unicode");
	void(*register_sha1_slow)(void (*sha1_slow)(char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_sha1_slow");
	void(*register_sha1_hex)(void (*md5_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])) = dlsym(dlhandle, "register_sha1_hex");
	void(*register_sha256_unicode)(void (*sha256_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_sha256_unicode");
	void(*register_sha256_hex)(void (*sha256_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])) = dlsym(dlhandle, "register_sha256_hex");
	void(*register_sha512_unicode)(void (*sha512_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_sha512_unicode");
	void(*register_sha384_unicode)(void (*sha384_unicode)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_sha384_unicode");
	void(*register_sha512_hex)(void (*sha512_hex)(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE])) = dlsym(dlhandle, "register_sha512_hex");
	void(*register_fcrypt)(hash_stat (*fcrypt)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE])) = dlsym(dlhandle, "register_fcrypt");
	void(*register_fcrypt_slow)(hash_stat (*fcrypt_slow)(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE])) = dlsym(dlhandle, "register_fcrypt_slow");
	void(*register_PEM_readfile)(void (*PEM_readfile)(const char *passphrase, int *RSAret)) = dlsym(dlhandle, "register_PEM_readfile");
	void(*register_new_biomem)(void (*new_biomem)(FILE *file)) = dlsym(dlhandle, "register_new_biomem");
	void(*register_pbkdf2)(void (*pbkdf2)(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdf2");
	void(*register_pbkdf2_len)(void (*pbkdf2_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdf2_len");
	void(*register_pbkdf2_256_len)(void (*pbkdf2_256_len)(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdf2_256_len");
	void(*register_hmac_sha1_file)(void (*hmac_sha1_file)(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen)) = dlsym(dlhandle, "register_hmac_sha1_file");
	void(*register_hmac_sha1)(void (*hmac_sha1)(void *key, int keylen, unsigned char *data, int datalen,unsigned char *output, int outputlen)) = dlsym(dlhandle, "register_hmac_sha1");
	void(*register_hmac_md5)(void (*hmac_md5)(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen)) = dlsym(dlhandle, "register_hmac_md5");
	void(*register_ripemd160)(void (*ripemd160)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_ripemd160");
	void(*register_whirlpool)(void (*whirlpool)(const char *plaintext[VECTORSIZE], char *hash[VECTORSIZE], int len[VECTORSIZE])) = dlsym(dlhandle, "register_whirlpool");
	void(*register_pbkdf512)(void (*pbkdf512)(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdf512");
	void(*register_pbkdfrmd160)(void (*pbkdfrmd160)(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdfrmd160");
	void(*register_pbkdfwhirlpool)(void (*pbkdfwhirlpool)(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out)) = dlsym(dlhandle, "register_pbkdfwhirlpool");
	void(*register_aes_encrypt)(void (*aes_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode)) = dlsym(dlhandle, "register_aes_encrypt");
	void(*register_aes_decrypt)(void (*aes_decrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode)) = dlsym(dlhandle, "register_aes_decrypt");
	void(*register_des_ecb_encrypt)(void (*des_ecb_encrypt)(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode)) = dlsym(dlhandle, "register_des_ecb_encrypt");
	void(*register_des_ecb_decrypt)(void (*des_ecbdecrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode)) = dlsym(dlhandle, "register_des_ecb_decrypt");
	void(*register_des_cbc_encrypt)(void (*des_ecb_encrypt)(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode)) = dlsym(dlhandle, "register_des_cbc_encrypt");
	void(*register_rc4_encrypt)(void (*des_rc4_encrypt)(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out)) = dlsym(dlhandle, "register_rc4_encrypt");
	void(*register_lm)(void (*lm)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE])) = dlsym(dlhandle, "register_lm");
	void(*register_lm_slow)(void (*lm_slow)(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE])) = dlsym(dlhandle, "register_lm_slow");
	void(*register_aes_cbc_encrypt)(void (*aes_cbc_encrypt)(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper)) = dlsym(dlhandle, "register_aes_cbc_encrypt");
	void(*register_aes_set_encrypt_key)(int (*aes_set_encrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key)) = dlsym(dlhandle, "register_aes_set_encrypt_key");
	void(*register_aes_set_decrypt_key)(int (*aes_set_decrypt_key)(const unsigned char *userKey,const int bits,AES_KEY *key)) = dlsym(dlhandle, "register_aes_set_decrypt_key");
	void(*register_decrypt_aes_xts)(void (*decrypt_aes_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block)) = dlsym(dlhandle, "register_decrypt_aes_xts");
	void(*register_decrypt_twofish_xts)(void (*decrypt_twofish_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block)) = dlsym(dlhandle, "register_decrypt_twofish_xts");
	void(*register_decrypt_serpent_xts)(void (*decrypt_serpent_xts)(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block)) = dlsym(dlhandle, "register_decrypt_serpent_xts");



        if ((hash_plugin_parse_hash != NULL) && (hash_plugin_check_hash != NULL) && (hash_plugin_is_raw != NULL) && (hash_plugin_is_special != NULL))
        {
// register our callbacks
	    register_add_username(hash_proto_add_username);
	    register_add_hash(hash_proto_add_hash);
	    register_add_salt(hash_proto_add_salt);
	    register_add_salt2(hash_proto_add_salt2);
	    register_md5(hash_proto_md5);
	    register_md5_unicode(hash_proto_md5_unicode);
	    register_md5_unicode_slow(hash_proto_md5_unicode_slow);
	    register_md5_slow(hash_proto_md5_slow);
	    register_md4(hash_proto_md4);
	    register_md4_unicode(hash_proto_md4_unicode);
	    register_md4_slow(hash_proto_md4_slow);
	    register_md5_hex(hash_proto_md5_hex);
	    register_sha1(hash_proto_sha1);
	    register_sha1_unicode(hash_proto_sha1_unicode);
	    register_sha1_slow(hash_proto_sha1_slow);
	    register_sha1_hex(hash_proto_sha1_hex);
	    register_sha256_unicode(hash_proto_sha256_unicode);
	    register_sha256_hex(hash_proto_sha256_hex);
	    register_sha512_unicode(hash_proto_sha512_unicode);
	    register_sha384_unicode(hash_proto_sha384_unicode);
	    register_sha512_hex(hash_proto_sha512_hex);
	    register_fcrypt(hash_proto_fcrypt);
	    register_fcrypt_slow(hash_proto_fcrypt_slow);
	    register_new_biomem(hash_proto_new_biomem);
	    register_PEM_readfile(hash_proto_PEM_readfile);
	    register_pbkdf2(hash_proto_pbkdf2);
	    register_pbkdf2_len(hash_proto_pbkdf2_len);
	    register_pbkdf2_256_len(hash_proto_pbkdf2_256_len);
	    register_hmac_sha1_file(hash_proto_hmac_sha1_file);
	    register_hmac_sha1(hash_proto_hmac_sha1);
	    register_hmac_md5(hash_proto_hmac_md5);
	    register_ripemd160(hash_proto_ripemd160);
	    register_whirlpool(hash_proto_whirlpool);
	    register_pbkdf512(hash_proto_pbkdf512);
	    register_pbkdfrmd160(hash_proto_pbkdfrmd160);
	    register_pbkdfwhirlpool(hash_proto_pbkdfwhirlpool);
	    register_aes_encrypt(hash_proto_aes_encrypt);
	    register_aes_decrypt(hash_proto_aes_decrypt);
	    register_des_ecb_encrypt(hash_proto_des_ecb_encrypt);
	    register_des_ecb_decrypt(hash_proto_des_ecb_decrypt);
	    register_des_cbc_encrypt(hash_proto_des_cbc_encrypt);
	    register_rc4_encrypt(hash_proto_rc4_encrypt);
	    register_lm(hash_proto_lm);
	    register_lm_slow(hash_proto_lm_slow);
	    register_aes_cbc_encrypt(hash_proto_aes_cbc_encrypt);
	    register_aes_set_encrypt_key(hash_proto_aes_set_encrypt_key);
	    register_aes_set_decrypt_key(hash_proto_aes_set_decrypt_key);
	    register_decrypt_aes_xts(hash_proto_decrypt_aes_xts);
	    register_decrypt_twofish_xts(hash_proto_decrypt_twofish_xts);
	    register_decrypt_serpent_xts(hash_proto_decrypt_serpent_xts);

	    /* set vector size hackery */
	    if ( (strcmp(get_current_plugin(),"desunix")==0) || (strcmp(get_current_plugin(),"lm")==0) || (strcmp(get_current_plugin(),"oracle-old")==0)) 
	    {
		vectorsize = 128; 
		get_vector_size(128);
	    }
	    else if ( (strcmp(get_current_plugin(),"privkey")==0) || (strcmp(get_current_plugin(),"zip")==0) || (strcmp(get_current_plugin(),"wpa")==0) || (strcmp(get_current_plugin(),"rar")==0) || (strcmp(get_current_plugin(),"dmg")==0))
	    {
		vectorsize = 8;
		get_vector_size(8);
	    }
	    else if (strcmp(get_current_plugin(),"privkey")==0)
	    {
		vectorsize = 24;
		get_vector_size(24);
	    }
	    else 
	    {
		vectorsize = 12;
		get_vector_size(12);
	    }
	    
	    /* single-hash optimization for certain plugins */
	    cpu_optimize_single=0;
	    if ((strcmp(get_current_plugin(),"md5")==0) || (strcmp(get_current_plugin(),"sha1")==0) || (strcmp(get_current_plugin(),"md4")==0) || (strcmp(get_current_plugin(),"ntlm")==0) || (strcmp(get_current_plugin(),"desunix")==0) || (strcmp(get_current_plugin(),"md4")==0)) cpu_optimize_single=1;

	    /* is raw? */
	    hash_is_raw = hash_plugin_is_raw();
	    if (!detecting) hlog("Plugin \'%s\' loaded successfully\n",get_current_plugin());
	}
	else 
	{
	    if (!detecting) elog("Plugin \'%s\' could not be loaded\n",get_current_plugin());
	    dlclose(dlhandle);
	    return hash_err;
	}
    }
    else 
    {
	if (!detecting) elog("Cannot open plugin library: %s\n",soname);
	return hash_err;
    }
    return hash_ok;
}

/* Unload plugin */
void unload_plugin()
{
    dlclose(dlhandle);
}


/* Detect plugin */
hash_stat detect_plugin(char *plugindir,char *file, char *hash)
{
    struct dirent **dentrylist;
    char soname[1024];
    DIR *dir;
    int count=-1,i=0;
    char line[1024];
    FILE *fd;
    char *preferred_plugins[] = { "ntlm","sha1","md5","lm","sha256","sha512","smf","vbulletin","ipb2",NULL };
    char *preferred_special_plugins[] = { "zip","rar","wpa","privkey",NULL };
    char *detected_plugins[128];
    int detected;
    char *detected_list;
    int detected_list_size=0;
    int j,flag;
    char lhash[HASHFILE_MAX_LINE_LENGTH]; // Local hashline copy cause some plugins play rough with strtok

    /* We are now detecting plugins, don't be verbose */
    detecting=1;

    /* Init */
    detected=-1;

    /* Is a cmdline hash? */
    i=0;
    if (hash)
    {
	dir=opendir(plugindir);
	if (!dir)
	{
	    elog("Cannot open plugins dir: %s", plugindir);
	    return hash_err;
	}
	closedir(dir);
	count = scandir(plugindir, &dentrylist, 0, alphasort);

	/* First check preferred plugins */
	while (preferred_plugins[i])
	{
	    strncpy(soname,preferred_plugins[i],1024);
	    set_current_plugin(soname);
	    if (load_plugin() == hash_ok) 
	    if (!hash_plugin_is_special())
	    {
	        strcpy(lhash,hash);
	        if (hash_plugin_parse_hash(lhash,NULL) == hash_ok)
	        {
		    detected++;
		    detected_plugins[detected]=malloc(strlen(preferred_plugins[i]+1));
		    strcpy(detected_plugins[detected],preferred_plugins[i]);
		}
		unload_plugin();
	    }
	    i++;
	}

	/* Then the next, in order */
	i=0;
	do
	{
	    if (strstr(dentrylist[i]->d_name, ".so"))
	    {
		strcpy(soname,dentrylist[i]->d_name);
		soname[strlen(soname)-3]=0;
		set_current_plugin(soname);
		if (load_plugin() == hash_ok) 
		if (!hash_plugin_is_special())
		{
		    strcpy(lhash,hash);
		    if (hash_plugin_parse_hash(lhash,NULL) == hash_ok)
		    {
			flag=0;
			for (j=0;j<=detected;j++) if (strcmp(detected_plugins[j],soname)==0) flag=1;
			if (flag==0)
			{
			    detected++;
			    detected_plugins[detected]=malloc(strlen(soname)+1);
			    strcpy(detected_plugins[detected],soname);
			}
		    }
		    unload_plugin();
		}
	    }
	    i++;
	} while (i<count);
	free(dentrylist);
    }

    /* Is a hashfile (but hashlist)? */
    i=0;
    if (file)
    {
	fd=fopen(file,"r");
	if (!fd)
	{
	    elog("Cannot open %s\n",file);
	    return hash_err;
	}
	fgets(line,1024,fd);
	line[1023]=0;
	if (strlen(line)<1) fgets(line,1024,fd);
	line[1023]=0;
	fclose(fd);
	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
	if (line[strlen(line)-1]=='\r') line[strlen(line)-1]=0;

	dir=opendir(plugindir);
	if (!dir)
	{
	    elog("Cannot open plugins dir: %s", plugindir);
	    return hash_err;
	}
	closedir(dir);
	count = scandir(plugindir, &dentrylist, 0, alphasort);

	/* First check preferred plugins */
	while (preferred_plugins[i])
	{
	    strcpy(soname,preferred_plugins[i]);
	    set_current_plugin(soname);
	    if (load_plugin() == hash_ok) 
	    if (!hash_plugin_is_special())
	    {
	        strcpy(lhash,line);
	        if (hash_plugin_parse_hash(lhash,NULL) == hash_ok)
	        {
		    detected++;
		    detected_plugins[detected]=malloc(strlen(preferred_plugins[i]));
		    strcpy(detected_plugins[detected],preferred_plugins[i]);
		}
		unload_plugin();
	    }
	    i++;
	}

	/* Then the next, in order */
	i=0;
	do
	{
	    if (strstr(dentrylist[i]->d_name, ".so"))
	    {
		strcpy(soname,dentrylist[i]->d_name);
		soname[strlen(soname)-3]=0;
		set_current_plugin(soname);
		if (load_plugin() == hash_ok) 
		if (!hash_plugin_is_special())
		{
		    strcpy(lhash,line);
		    if (hash_plugin_parse_hash(lhash,NULL) == hash_ok)
		    {
			flag=0;
			for (j=0;j<=detected;j++) if (strcmp(detected_plugins[j],soname)==0) flag=1;
			if (flag==0)
			{
			    detected++;
			    detected_plugins[detected]=malloc(strlen(soname)+1);
			    strcpy(detected_plugins[detected],soname);
			}
		    }
		    unload_plugin();
		}
	    }
	    i++;
	} while (i<count);
	free(dentrylist);
    }

    /* Is a hashfile (but not hashlist)? */
    i=0;
    if (file)
    {
	dir=opendir(plugindir);
	if (!dir)
	{
	    elog("Cannot open plugins dir: %s", plugindir);
	    return hash_err;
	}
	closedir(dir);
	count = scandir(plugindir, &dentrylist, 0, alphasort);

	/* First check preferred plugins */
	while (preferred_special_plugins[i])
	{
	    strcpy(soname,preferred_special_plugins[i]);
	    set_current_plugin(soname);
	    if (load_plugin() == hash_ok) 
	    if (hash_plugin_is_special())
	    {
	        if (hash_plugin_parse_hash("dummy",file) == hash_ok)
	        {
		    detected++;
		    detected_plugins[detected]=malloc(strlen(preferred_special_plugins[i])+1);
		    strcpy(detected_plugins[detected],preferred_special_plugins[i]);
		}
		unload_plugin();
	    }
	    i++;
	}

	/* Then the next, in order */
	i=0;
	do
	{
	    if (strstr(dentrylist[i]->d_name, ".so"))
	    {
		strcpy(soname,dentrylist[i]->d_name);
		soname[strlen(soname)-3]=0;
		set_current_plugin(soname);
		if (load_plugin() == hash_ok) 
		if (hash_plugin_is_special())
		{
		    if (hash_plugin_parse_hash("dummy",file) == hash_ok)
		    {
			flag=0;
			for (j=0;j<=detected;j++) if (strcmp(detected_plugins[j],soname)==0) flag=1;
			if (flag==0)
			{
			    detected++;
			    detected_plugins[detected] = malloc(strlen(soname)+1);
			    strcpy(detected_plugins[detected],soname);
			}
		    }
		    unload_plugin();
		}
	    }
	    i++;
	} while (i<count);
	free(dentrylist);
    }

    detected++;
    detecting=0;
    if (detected > 1)
    {
	for (i=0;i<detected;i++)
	{
	    detected_list_size += strlen(detected_plugins[i])+1;
	}
	detected_list = malloc(detected_list_size+1);
	bzero(detected_list,detected_list_size);
	for (i=0;i<detected;i++)
	{
	    sprintf(detected_list,"%s %s",detected_list,detected_plugins[i]);
	}
	wlog("Warning: multiple plugins match this input!%s\n","");
	wlog("Plugins available:%s\n",detected_list);
	wlog("Choosing %s. If that's not what you meant, use the -p <plugin> switch!\n",detected_plugins[0]);
	set_current_plugin(detected_plugins[0]);
	load_plugin();
	free(detected_list);
	for (i=0;i<detected;i++) free(detected_plugins[i]);
	return hash_ok;
    }
    if (detected == 1)
    {
    	hlog("Loading plugin %s\n",detected_plugins[0]);
    	set_current_plugin(detected_plugins[0]);
	load_plugin();
    	free(detected_plugins[0]);
    	return hash_ok;
    }
    return hash_err;
}
