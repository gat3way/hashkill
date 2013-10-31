/* hashinterface.h
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


#ifndef HASHINTERFACE_H
#define HASHINTERFACE_H

#include <openssl/aes.h> // AES-KEY...
#include <pthread.h>
#include <stdint.h>
#include "err.h"


/* Do not change those unless you know what you are doing */
#define HASHKILL_VERSION PACKAGE_VERSION		// hashkill version
#define HASHKILL_MAXTHREADS (unsigned int)128		// maximum threads
#define HASHKILL_MAXQUEUESIZE 128 			// maximum queue size
#define HASHFILE_MAX_LINE_LENGTH 4096			// maximum line length
#define HASHFILE_MAX_PLAIN_LENGTH 128
#define VECTORSIZE 128
#define THREAD_LENPROVIDED 1000
#define THREAD_SALTPROVIDED 20000
#define MAX_USERNAME 64 
#define MAX_SALT     64
#define MAX_PLAIN    32


#define KERNEL_PATH "/usr/share/hashkill/kernels/"
#define MAX_SOURCE_SIZE 5000000

#define __read_mostly __attribute__((__section__(".data.read_mostly")))
#define likely(x)       __builtin_expect((x),1)
#define unlikely(x)     __builtin_expect((x),0)


/* thread queues */
typedef struct hash_cpu_node_s
{
    char *plaintext[VECTORSIZE];
    char *result[VECTORSIZE];
    int len[VECTORSIZE];
    char pad_to_avoid_false_sharing[64];
} hash_cpu_t;

hash_cpu_t hash_cpu[HASHKILL_MAXTHREADS] __attribute__((aligned(64)));


/* hashes linked lists */
struct hash_list_s
{
    char *username;
    char *hash;
    char *salt;
    char *salt2;
    struct hash_list_s *prev;
    struct hash_list_s *next;
    struct hash_list_s *indexprev;
    struct hash_list_s *indexnext;
} *hash_list  __attribute__((aligned(32))), *cracked_list __attribute__((aligned(32))), *hash_list_end, *cracked_list_end;


/* Attack method enumeration */
typedef enum attack_method_e
{
    attack_method_simple_bruteforce,
    attack_method_markov,
    attack_method_rule
} attack_method_t;


/* Hash indexes */
struct hash_index_t
{
    struct hash_list_s *nodes;
} hash_index[256][256] __attribute__((aligned(64)));


/* Thread types enum */
typedef enum thread_types_e
{
    nv_thread,		// NVidia worker
    amd_thread,		// AMD worker
    cpu_thread		// CPU worker

} thread_types_t;

/* Workthreads structure */
typedef struct workthreads_s
{
    thread_types_t type;	// See enum thread_types_e
    int vectorsize;		// Native vector width per device 
    int loops;			// Loops per device
    int platform;		// OpenCL platform 
    int deviceid;		// Device id
    void *cldeviceid;		// OpenCL's deviceid
    int first;			// First thread in threadgroup?
    pthread_t thread;		// POSIX thread
    pthread_mutex_t tempmutex;	// Used to lock the thread (ADL)
    int templocked;		// Device is locked cause of overheating
    int ocl_have_sm21;		// Device is sm_21 ?
    int ocl_have_sm10;		// Device is sm_10 ?
    int ocl_have_old_ati;	// Device is 4xxx ?
    int ocl_have_vliw4;		// Device is VLIW4 ?
    int ocl_have_gcn;		// Device is GCN?
    volatile uint64_t tries;	// c/s on that thread since last check
    int currentsalt;		// GPU only: salt# increment
    uint64_t oldtries;		// c/s on that thread before last check
    int temperature;		// Temperature
    int activity;		// Activity
    char adaptername[255];	// Adapter name
} workthreads_t;
workthreads_t wthreads[HASHKILL_MAXTHREADS] __attribute__((aligned(64)));
int nwthreads;


/* Scheduler struct */
typedef struct scheduler_s
{
    int startlen;		// Not the start length, rather the length we multiplex at
    volatile int len;		// Current length
    int maxlen;			// Maximum length
    int charset_size;		// Charset len
    int charset_size2;		// Charset len
    volatile int bitmap3[128][128]; // Scheduler bitmap3
    volatile int ebitmap3[128][128];	// Scheduler bitmap3 - limits 
    volatile int bitmap2[128];	// Scheduler bitmap2
    volatile int ebitmap2[128];	// Scheduler bitmap2 - limits 
    volatile int bitmap1;	// Scheduler bitmap1
    volatile int ebitmap1;	// Scheduler bitmap1 - limits 
    int markov_l1;		// Markov limit -1
    int markov_l2_1;		// Markov limit -2/1
    int markov_l2_2;		// Markov limit -2/2
    int markov_l3_1;		// Markov limit -3/1
    int markov_l3_2;		// Markov limit -3/2
    int markov_l3_3;		// Markov limit -3/3
    int currentrule;		// Current rule
    uint64_t currentqueued;		// Current rule - queued elem
} scheduler_t;

volatile scheduler_t scheduler;
pthread_t scheduler_thread;




attack_method_t attack_method;
int hash_ret_len;
int single_hash;
volatile uint64_t attack_overall_count;
uint64_t attack_current_count;
uint64_t attack_checkpoints;
uint64_t attack_avgspeed;;


/* Global variables needed by modules */
char hashlist_file[255];		// Hashlist file
char hash_cmdline[HASHFILE_MAX_LINE_LENGTH]; // Hash from cmdline
char bruteforce_set1[255];		// Bruteforce set1
char bruteforce_set2[255];		// Bruteforce set1
int bruteforce_start;			// Min len of bruteforce candidates
int bruteforce_end;			// Max len of bruteforce candidates
char bruteforce_charset[255];		// Bruteforce charset
int hashes_count;			// The number of hashes in the list
int session_restore_flag;		// Did we restore a session?
char markov_statfile[255];		// Markov statfile
int markov_max_len;			// Max len of markov-generated candidates
int markov_threshold;			// Markov threshold
int markov0[88];			// Markov order 0 probs
int markov1[88][88];			// Markov order 1 probs
int markov2[88][88];			// Markov order 1 probs (To use in GPU kernels)
char *markov_charset;			// Markov charset
int hash_is_raw;			// Whether we keep it in binary or ascii form
int vectorsize;				// Vector (well not quite) size on CPU
int fast_markov;			// Fast markov mode (GPU only)
int cpuonly;				// CPU-only attack
volatile int attack_over;		// Attack over yet?
int hash_crack_speed;			// Attack speed (K/s)
int cpu_optimize_single;		// Used in CPU code
int ocl_gpu_group;			// Not used anymore?
int ctrl_c_pressed;			// User pressed ctrl-c?
int ocl_gpu_double;			// GPU double mode
int ocl_gpu_platform;			// GPU double mode
int ocl_gpu_tempthreshold;		// Temperature threshold
char *rule_file;			// Rule file to process
int hash_len;				// hash length
char *out_cracked_file;			// output hashes file 
char *out_uncracked_file;		// output hashes file 
char *addopts[10];			// Additional options
hash_stat have_ocl;			// OCL attack?
int salt_size;				// salt size as returned by plugin
char *markovstat;			// Markov statfile
char *additional_options;		// -A addopts
char *padditional_options;		// -a addopts

/* List manipulation routines */
hash_stat add_hash_list(char *username, char *hash, char *salt, char *salt2);
hash_stat add_cracked_list(char *username, char *hash, char *salt, char *salt2);
hash_stat del_hash_list(struct hash_list_s *node);
hash_stat del_cracked_list(struct hash_list_s *node);


/* Some linked lists stuff */
int get_cracked_num(void);
void print_hash_list(void);
int get_hashes_num(void);
void print_cracked_list(void);
void print_cracked_list_to_file(char *filename);
void print_uncracked_list_to_file(char *filename);


/* Proto callback functions that are registered to the plugin library */
void hash_proto_add_username(const char *username);
void hash_proto_add_hash(const char *hash, int len);
void hash_proto_add_salt(const char *salt);
void hash_proto_add_salt2(const char *salt2);
hash_stat hash_proto_md5(char *  plaintext[VECTORSIZE], char *  hashmd5[VECTORSIZE], int len, int threadid);
void hash_proto_md5_unicode(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_md5_unicode_slow(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_md5_slow(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid);
hash_stat hash_proto_md4(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE],int threadid);
hash_stat hash_proto_md4_unicode(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len,int threadid);
void hash_proto_md4_slow(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE],int threadid);
void hash_proto_ripemd160(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_whirlpool(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_md5_hex(const char *hash[VECTORSIZE],  char *hashhex[VECTORSIZE]);
hash_stat hash_proto_sha1(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len, int threadid);
void hash_proto_sha1_unicode(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha1_slow(char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha1_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_sha256_unicode(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha256_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
void hash_proto_sha512_unicode(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha384_unicode(const char *plaintext[VECTORSIZE], char *hashmd5[VECTORSIZE], int len[VECTORSIZE]);
void hash_proto_sha512_hex(const char *hash[VECTORSIZE], char *hashhex[VECTORSIZE]);
hash_stat hash_proto_fcrypt(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]);
hash_stat hash_proto_fcrypt_slow(const char *password[VECTORSIZE], const char *salt, char *ret[VECTORSIZE]);
void hash_proto_new_biomem(FILE *file);
void hash_proto_PEM_readfile(const char *passphrase, int *RSAret);
void hash_proto_pbkdf2(const char *pass, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_pbkdf2_len(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_pbkdf2_256_len(const char *pass, int passlen, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_hmac_sha1_file(void *key, int keylen, char *filename, long offset, long size, unsigned char *output, int outputlen);
void hash_proto_hmac_sha1(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen);
void hash_proto_hmac_md5(void *key, int keylen, unsigned char *data, int datalen, unsigned char *output, int outputlen);
void hash_proto_pbkdf512(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_pbkdfrmd160(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_pbkdfwhirlpool(const char *pass, int len, unsigned char *salt, int saltlen, int iter, int keylen, unsigned char *out);
void hash_proto_aes_encrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode);
void hash_proto_aes_decrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *vec, unsigned char *out, int mode);
void hash_proto_des_ecb_encrypt(const unsigned char *key, int keysize, const unsigned char *in[VECTORSIZE], int len, unsigned char *out[VECTORSIZE], int mode);
void hash_proto_des_ecb_decrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out, int mode);
void hash_proto_des_cbc_encrypt(const unsigned char *key[VECTORSIZE], int keysize, const unsigned char *in[VECTORSIZE], int len[VECTORSIZE], unsigned char *out[VECTORSIZE], unsigned char *iv[VECTORSIZE], int mode);
void hash_proto_rc4_encrypt(const unsigned char *key, int keysize, const unsigned char *in, int len, unsigned char *out);
void hash_proto_lm(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]);
void hash_proto_lm_slow(const unsigned char *in[VECTORSIZE], unsigned char *out[VECTORSIZE]);
void hash_proto_aes_cbc_encrypt(const unsigned char *in,unsigned char *out,unsigned long length,AES_KEY *key,unsigned char ivec[16],int oper);
int hash_proto_aes_set_encrypt_key(const unsigned char *userKey,const int bits,AES_KEY *key);
int hash_proto_aes_set_decrypt_key(const unsigned char *userKey, const int bits, AES_KEY *key);
void hash_proto_decrypt_aes_xts(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);
void hash_proto_decrypt_twofish_xts(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);
void hash_proto_decrypt_serpent_xts(char *key1, char *key2, char *in, char *out, int len, int sector, int cur_block);

void scheduler_init();
void scheduler_setup(int curlen, int startlen, int maxlen, int charset_size, int charset_size2);
int sched_s1();
int sched_s2(int s1);
int sched_s3(int s1, int s2);
int sched_e1();
int sched_e2(int e1);
int sched_e3(int e1, int e2);
int sched_len();
void sched_wait(int len);
void hex2str(char *str, char *hex, int len);
void str2hex(char *str, char *hex, int size);
/* cleanup routines */
void cleanup_lists(void);
/* Markov attack routines */
void markov_attack_init(void);
void markov_print_statfiles(void);
hash_stat markov_load_statfile(char *statname);
/* hash indexes routines */
hash_stat create_hash_indexes(void);
/* util functions */
void disable_term_linebuffer(void);
char *str_replace(char *orig, char *rep, char *with);
void process_addopts(char *addopt_parm);
unsigned char* hash_memmem(unsigned char* haystack, int hlen, char* needle, int nlen);
#endif
