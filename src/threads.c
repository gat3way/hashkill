/* 
 * threads.c
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


//#define DEBUG

#ifdef HAVE_SSE2
#include <emmintrin.h>
#endif
#define __USE_UNIX98

#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/sysinfo.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <stdint.h>
#include <math.h>
#include <pthread.h>
#include <alloca.h>
#include <termios.h>
#include <openssl/bn.h>
#include <openssl/crypto.h>
#include "err.h"
#include "threads.h"
#include "hashinterface.h"
#include "plugins.h"
#include "sessions.h"
#include "hashgen.h"
#include "cpu-feat.h"

#define POPWAIT 1000
#define PUSHWAIT 3000

/* Global static variables */
static unsigned char bitmap[256*256*32] __read_mostly;
static unsigned char bitmap2[256*256*32] __read_mostly;
static unsigned char bitmap3[256*256*32] __read_mostly;
static __thread int cur=-1;
int charset_size;
int reduced_size;
char reduced_charset[88];
int markov2[88][88];
static pthread_t monitorinfothread;


/* OpenSSL thread-safety variables */
static pthread_mutex_t *lock_cs;			// mutexes
static long            *lock_count;			// mutex_count


/* Used to get attack timing */
static time_t time1,time2;

/* Crack routine callback */
typedef void (*finalthread_t)(int self);
finalthread_t finalthread;


/* Function prototypes */
static void * start_monitor_thread(void *arg);
static void * start_monitor_info_thread(void *arg);
static void SSL_thread_cleanup( void );
static void SSL_pthreads_locking_callback(int mode, int type, char *file, int line);
static unsigned long SSL_pthreads_thread_id(void);
static void SSL_thread_setup(void);
hash_stat spawn_threads(unsigned int num);
unsigned int hash_num_cpu(void);
void thread_attack_cleanup(void);




/* Cleanup openssl thread-safe callbacks */
static void SSL_thread_cleanup(void) 
{
    int x;
    CRYPTO_set_locking_callback(NULL);
    for( x = 0; x < CRYPTO_num_locks(); x++ ) 
    {
	pthread_mutex_destroy(&(lock_cs[x]));
    }
    OPENSSL_free(lock_cs);
    OPENSSL_free(lock_count);
}


/* The openssl crypto locking callback */
static void SSL_pthreads_locking_callback(int mode, int type, char *file, int line) 
{
    if(mode & CRYPTO_LOCK)
    {
	pthread_mutex_lock(&(lock_cs[type]));
	lock_count[type]++;
    } 
    else
    { 
	pthread_mutex_unlock(&(lock_cs[type]));
    }
}


/* The next callback needed */
static unsigned long SSL_pthreads_thread_id(void) 
{
  unsigned long ret;
  ret = (unsigned long)pthread_self();

  return(ret);
}


/* setup open crypto callbacks */
static void SSL_thread_setup(void) 
{
    int x;

#define OPENSSL_THREAD_DEFINES
#include <openssl/opensslconf.h>
#if defined(THREADS) || defined(OPENSSL_THREADS)
#else
    fprintf(stderr, "WARNING: your openssl libraries were compiled without thread support\n");
    pthread_sleep_np( 2 );
#endif
    lock_cs    = (pthread_mutex_t*)OPENSSL_malloc(CRYPTO_num_locks()*sizeof(pthread_mutex_t));
    lock_count = (long*)OPENSSL_malloc(CRYPTO_num_locks() * sizeof(long));
    for( x = 0; x < CRYPTO_num_locks(); x++ )
    {
	lock_count[x] = 0;
	pthread_mutex_init(&(lock_cs[x]), NULL);
    }
    CRYPTO_set_id_callback((unsigned long (*)())SSL_pthreads_thread_id);
    CRYPTO_set_locking_callback((void (*)())SSL_pthreads_locking_callback);
}



static void thread_attack_worker_nonlinear_rule(int self)
{
    struct  hash_list_s  *mylist;
    struct hash_list_s * addlist;
    int flag;
    int whoami=self;
    int res;
    int num;
    int lens=0;


    wthreads[self].tries+=vectorsize;
    if (attack_over==2) return;
    mylist = hash_list;
    while ((mylist)&&(attack_over!=2))
    {
        num = lens;
        res=hash_plugin_check_hash_dictionary(mylist->hash, (const char **)hash_cpu[self].plaintext,mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
        if (res==hash_ok)
        {
    	    flag = 0;
	    pthread_mutex_lock(&crackedmutex);
	    addlist = cracked_list;
	    while (addlist)
	    {
	        if ( (strcmp(addlist->username, mylist->username) == 0) && (strcmp(addlist->hash, mylist->hash) == 0)
		&& (memcmp(addlist->salt, mylist->salt,salt_size) == 0))
	        flag = 1;
	        addlist = addlist->next;
	    }
	    pthread_mutex_unlock(&crackedmutex);
	    if (flag == 0) add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[num]);
	}
	if (mylist) mylist = mylist->next;
    }
}

static void thread_attack_worker_linear_rule(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num;
    int flag = 0;
    int d;
    int lens=0;

    wthreads[self].tries+=vectorsize;
    if (attack_over==2) return;
    mylist = hash_list;
    if (mylist)
    {
        num = lens;
        hash_plugin_check_hash_dictionary(mylist->hash, (const char **)hash_cpu[self].plaintext,
        mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
    }

    int present = 0;
    for (d=0;d<vectorsize;d++) 
    if (
        ((bitmap[((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255))) >> 3)] >> ((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255)))&7)&1) == 1) &&
	((bitmap2[((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255))) >> 3)] >> ((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255)))&7)&1) == 1) &&
        ((bitmap3[((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255))) >> 3)] >> ((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255)))&7)&1)==1) ) 
	present = 1;
    if (present == 1)
    {
	for (d=0;d<vectorsize;d++) 
	if (hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes)
	{
	    mylist = hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes;
	    while (mylist)
	    {
	        if (memcmp(hash_cpu[self].result[d],mylist->hash,hash_ret_len)==0)
	        {
		    flag = 0;
		    pthread_mutex_lock(&crackedmutex);
		    addlist = cracked_list;
		    while (addlist)
		    {
		        if ((strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0)) flag = 1;
		        addlist = addlist->next;
		    }
		    pthread_mutex_unlock(&crackedmutex);
		    if (flag == 0) 
		    {
		        add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[d]);
		    }
		}
		mylist=mylist->indexnext;
	    }
	}
    }
}


static void thread_attack_worker_linear_rule_single(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num,a;
    int flag = 0;
    int lens=0;

    if (attack_over==2) return;
    mylist = hash_list;
    num = lens;
    hash_plugin_check_hash_dictionary(mylist->hash, (const char **)hash_cpu[self].plaintext,
    	mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
    for (a=0;a<vectorsize;a++) 
    {
	if (unlikely(mylist->hash[0] == hash_cpu[self].result[a][0]))
    	if (unlikely(mylist->hash[1] == hash_cpu[self].result[a][1]))
    	if (memcmp(mylist->hash, hash_cpu[self].result[a], hash_ret_len) == 0)
    	{
	    flag = 0;
	    pthread_mutex_lock(&crackedmutex);
	    addlist = cracked_list;
	    while (addlist)
	    {
		if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
	    	flag = 1;
	    	addlist = addlist->next;
	    }
	    pthread_mutex_unlock(&crackedmutex);
	    if (flag == 0) 
	    {
		add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[a]);
	    }
	}
    }
    wthreads[self].tries+=vectorsize;
}



static void thread_attack_worker_nonlinear_bruteforce(int self)
{
    struct  hash_list_s  *mylist;
    struct hash_list_s * addlist;
    int flag;
    int whoami=self;
    int res;
    int num;
    int a,b,lens=0;


    wthreads[self].tries+=vectorsize*charset_size;
    for (b=0;b<charset_size;b++)
    {
	if (attack_over==2) return;
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=bruteforce_charset[b];
	}
	mylist = hash_list;
	while ((mylist)&&(attack_over!=2))
	{
	    num = lens;
	    res=hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
	    if (res==hash_ok)
	    {
		flag = 0;
		pthread_mutex_lock(&crackedmutex);
		addlist = cracked_list;
		while (addlist)
		{
	    	    if ( (strcmp(addlist->username, mylist->username) == 0) && (strcmp(addlist->hash, mylist->hash) == 0)
			&& (memcmp(addlist->salt, mylist->salt,salt_size) == 0))
		    flag = 1;
		    addlist = addlist->next;
		}
		pthread_mutex_unlock(&crackedmutex);
		if (flag == 0) add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[num]);
	    }
	    if (mylist) mylist = mylist->next;
	}
    }
}

static void thread_attack_worker_linear_bruteforce(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num,a,b;
    int flag = 0;
    int d;
    int lens=0;

    wthreads[self].tries+=vectorsize*charset_size;
    for (b=0;b<charset_size;b++)
    {
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=bruteforce_charset[b];
	}

	if (attack_over==2) return;

        mylist = hash_list;
        if (mylist)
        {
    	    num = lens;
	    hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,
	    mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
	}

        int present = 0;
	for (d=0;d<vectorsize;d++) 
	if (
        ((bitmap[((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255))) >> 3)] >> ((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255)))&7)&1) == 1) &&
	((bitmap2[((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255))) >> 3)] >> ((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255)))&7)&1) == 1) &&
        ((bitmap3[((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255))) >> 3)] >> ((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255)))&7)&1)==1) ) present = 1;
        if (present == 1)
        {
	    for (d=0;d<vectorsize;d++) 
	    if (hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes)
	    {
		mylist = hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes;
		while (mylist)
		{
		    if (memcmp(hash_cpu[self].result[d],mylist->hash,hash_ret_len)==0)
		    {
			flag = 0;
			pthread_mutex_lock(&crackedmutex);
			addlist = cracked_list;
			while (addlist)
			{
			    if ((strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0)) flag = 1;
			    addlist = addlist->next;
			}
			if (flag == 0) 
			{
			    pthread_mutex_unlock(&crackedmutex);
			    add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[d]);
			}
			else pthread_mutex_unlock(&crackedmutex);
		    }
		    mylist=mylist->indexnext;
		}
	    }
	}
    }
}


static void thread_attack_worker_linear_bruteforce_single(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num,a,b;
    int flag = 0;
    int lens=0;


    for (b=0;b<charset_size;b++)
    {
	if (attack_over==2) return;
	mylist = hash_list;
	num = lens;
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=bruteforce_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=bruteforce_charset[b];
	}

	if (hash_ok==hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,
		mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami))
	for (a=0;a<vectorsize;a++) 
	{
    	    if (unlikely(mylist->hash[0] == hash_cpu[self].result[a][0]))
    	    if (unlikely(mylist->hash[1] == hash_cpu[self].result[a][1]))
    	    if (memcmp(mylist->hash, hash_cpu[self].result[a], hash_ret_len) == 0)
    	    {
		flag = 0;
		pthread_mutex_lock(&crackedmutex);
		addlist = cracked_list;
		while (addlist)
		{
	    	    if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
	    	    flag = 1;
	    	    addlist = addlist->next;
		}
		pthread_mutex_unlock(&crackedmutex);
		if (flag == 0) 
		{
	    	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[a]);
		}
	    }
	}
    }
    wthreads[self].tries+=vectorsize*charset_size;
}




static void thread_attack_worker_nonlinear_markov(int self)
{
    struct  hash_list_s  *mylist;
    struct hash_list_s * addlist;
    int flag;
    int whoami=self;
    int res;
    int num;
    int a,b,lens=0;


    wthreads[self].tries+=vectorsize*charset_size;
    for (b=0;b<charset_size;b++)
    {
	if (attack_over==2) return;
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=markov_charset[b];
	}
	mylist = hash_list;
	while ((mylist)&&(attack_over!=2))
	{
	    num = lens;
	    res=hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
	    if (res==hash_ok)
	    {
		flag = 0;
		pthread_mutex_lock(&crackedmutex);
		addlist = cracked_list;
		while (addlist)
		{
	    	    if ( (strcmp(addlist->username, mylist->username) == 0) && (strcmp(addlist->hash, mylist->hash) == 0)
			&& (memcmp(addlist->salt, mylist->salt,salt_size) == 0))
		    flag = 1;
		    addlist = addlist->next;
		}
		pthread_mutex_unlock(&crackedmutex);
		if (flag == 0) add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[num]);
	    }
	    if (mylist) mylist = mylist->next;
	}
    }
}

static void thread_attack_worker_linear_markov(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num,a,b;
    int flag = 0;
    int d;
    int lens=0;

    wthreads[self].tries+=vectorsize*charset_size;
    for (b=0;b<charset_size;b++)
    {
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=markov_charset[b];
	}

	if (attack_over==2) return;

        mylist = hash_list;
        if (mylist)
        {
    	    num = lens;
	    hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,
	    mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami);
	}

        int present = 0;
	for (d=0;d<vectorsize;d++) 
	if (
        ((bitmap[((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255))) >> 3)] >> ((((hash_cpu[self].result[d][0]&255)<<16)|((hash_cpu[self].result[d][1]&255)<<8)|((hash_cpu[self].result[d][2]&255)))&7)&1) == 1) &&
	((bitmap2[((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255))) >> 3)] >> ((((hash_cpu[self].result[d][3]&255)<<16)|((hash_cpu[self].result[d][4]&255)<<8)|((hash_cpu[self].result[d][5]&255)))&7)&1) == 1) &&
        ((bitmap3[((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255))) >> 3)] >> ((((hash_cpu[self].result[d][6]&255)<<16)|((hash_cpu[self].result[d][7]&255)<<8)|((hash_cpu[self].result[d][8]&255)))&7)&1)==1) ) present = 1;
        if (present == 1)
        {
	    for (d=0;d<vectorsize;d++) 
	    if (hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes)
	    {
		mylist = hash_index[hash_cpu[self].result[d][0]&255][hash_cpu[self].result[d][1]&255].nodes;
		while (mylist)
		{
		    if (memcmp(hash_cpu[self].result[d],mylist->hash,hash_ret_len)==0)
		    {
			flag = 0;
			pthread_mutex_lock(&crackedmutex);
			addlist = cracked_list;
			while (addlist)
			{
			    if ((strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0)) flag = 1;
			    addlist = addlist->next;
			}
			pthread_mutex_unlock(&crackedmutex);
			if (flag == 0) 
			{
			    add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[d]);
			}
		    }
		    mylist=mylist->indexnext;
		}
	    }
	}
    }
}


static void thread_attack_worker_linear_markov_single(int self)
{
    struct  hash_list_s  *mylist, *addlist;
    int whoami=self;
    int num,a,b;
    int flag = 0;
    int lens=0;

    mylist = hash_list;
    for (b=0;b<charset_size;b++)
    {
	if (attack_over==2) return;
	num = lens;
	for (a=0;a<vectorsize;a+=4) 
	{
	    *(int *)&hash_cpu[self].plaintext[a][hash_cpu[self].len[a]]=0;
	    hash_cpu[self].plaintext[a][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+1][hash_cpu[self].len[a+1]]=0;
	    hash_cpu[self].plaintext[a+1][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+2][hash_cpu[self].len[a+2]]=0;
	    hash_cpu[self].plaintext[a+2][0]=markov_charset[b];
	    *(int *)&hash_cpu[self].plaintext[a+3][hash_cpu[self].len[a+3]]=0;
	    hash_cpu[self].plaintext[a+3][0]=markov_charset[b];
	}
	if (hash_ok==hash_plugin_check_hash(mylist->hash, (const char **)hash_cpu[self].plaintext,
		mylist->salt, hash_cpu[self].result, mylist->username, &num, whoami))
	for (a=0;a<vectorsize;a++)
	{
    	    if (unlikely(mylist->hash[0] == hash_cpu[self].result[a][0]))
    	    if (unlikely(mylist->hash[1] == hash_cpu[self].result[a][1]))
    	    if (memcmp(mylist->hash, hash_cpu[self].result[a], hash_ret_len) == 0)
    	    {
		flag = 0;
		pthread_mutex_lock(&crackedmutex);
		addlist = cracked_list;
		while (addlist)
		{
	    	    if ( (strcmp(addlist->username, mylist->username) == 0) && (memcmp(addlist->hash, mylist->hash, hash_ret_len) == 0))
	    	    flag = 1;
	    	    addlist = addlist->next;
		}
		pthread_mutex_unlock(&crackedmutex);
		if (flag == 0) 
		{
	    	    add_cracked_list(mylist->username, mylist->hash, mylist->salt, hash_cpu[self].plaintext[a]);
		}
	    }
	}
    }
    wthreads[self].tries+=(vectorsize*charset_size);
}




/* Init hash bitmaps */
static void init_bitmaps()
{
    int a;
    struct hash_list_s *mylist;
    char hex1[24];
    
    for (a=0;a<256*256*32;a++) 
    {
	    bitmap[a]=0;
	    bitmap2[a]=0;
	    bitmap3[a]=0;
    }

    mylist = hash_list;
    while (mylist) 
    {
	memcpy(hex1,mylist->hash,16);
	bitmap[(((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))>>3] |= (1 << ((((hex1[0]&255)<<16)|((hex1[1]&255)<<8)|((hex1[2]&255)))&7) );
	bitmap2[(((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))>>3] |= (1 << ((((hex1[3]&255)<<16)|((hex1[4]&255)<<8)|((hex1[5]&255)))&7) );
	bitmap3[(((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))>>3] |= (1 << ((((hex1[6]&255)<<16)|((hex1[7]&255)<<8)|((hex1[8]&255)))&7) );

	mylist = mylist->next;
    }
    hlog("Initialized hash bitmaps\n%s","");
}



/* Spawn worker threads, monitor thread */
hash_stat spawn_threads(unsigned int num)
{
    unsigned int cnt, cnt1;
    pthread_t monitorthread;
    pthread_attr_t thread_attr;
    struct sched_param thread_param;

    SSL_thread_setup();

    nwthreads=0;
    for (cnt=0; cnt<num; cnt++)
    {
	for (cnt1=0; cnt1 < vectorsize; cnt1++)
	{
	    if (
		(posix_memalign((void **)&hash_cpu[cnt].plaintext[cnt1],16, 64)!=0)||
		(posix_memalign((void **)&hash_cpu[cnt].result[cnt1],16, 128)!=0)
	    )
	    {
		elog("Cannot allocate aligned memory for thread queues!%s\n","");
		break;
	    }
	    bzero(hash_cpu[cnt].plaintext[cnt1],64);
	    bzero(hash_cpu[cnt].result[cnt1],128);
	}
	wthreads[cnt].type = cpu_thread;
	wthreads[cnt].vectorsize = vectorsize;
	nwthreads++;
    }

    pthread_attr_init(&thread_attr);
    pthread_attr_setschedpolicy(&thread_attr, SCHED_RR);
    thread_param.sched_priority = 50;
    pthread_attr_setschedparam(&thread_attr, &thread_param);
    pthread_attr_setinheritsched(&thread_attr,PTHREAD_EXPLICIT_SCHED); 
    if (pthread_create(&monitorthread, &thread_attr, start_monitor_thread, &cnt)!=0)
    {
	pthread_create(&monitorthread, NULL, start_monitor_thread, &cnt);
    }
    if (hashgen_stdout_mode==0) pthread_create(&monitorinfothread, NULL, start_monitor_info_thread, &cnt);
    hlog("Spawned %d threads.\n",num);
    return hash_ok;
}



/* Get number of CPUs, read from /proc/cpuinfo */
unsigned int hash_num_cpu(void)
{
    FILE *fcpu;
    unsigned int proc = 0;
    char buf[128];
    char *status;

    bzero(buf,128); // Make valgrind happy
    fcpu=fopen("/proc/cpuinfo","r");
    if (!fcpu)
    {
        elog("Cannot open /proc/cpuinfo! errno=%d", errno);
        return 0;
    }
    else
    {
        do
        {
            status = fgets(buf, 128, fcpu);
            if ((status) && (strstr(buf, "processor"))) proc++;
        } while (status);

        fclose(fcpu);
    }
    hlog("Detected %d CPUs.\n", proc);
    return proc;
}




/* Start monitor thread */ 
static void * start_monitor_thread(void *arg)
{
    uint64_t sum;
    int cracked;
    FILE *sessionfile;
    char *attack_current_str = "abcdeffsd";
    int a;

    while ((wthreads[0].tries==0)&&(attack_over==0)) usleep(10000);
    printf("\n");

    if ((strcmp(get_current_plugin(),"sl3")==0)) 
    {
        strcpy(bruteforce_charset,"0123456789");
        attack_method=attack_method_simple_bruteforce;
    }
    attack_checkpoints=0;

    while ((attack_over == 0)&&(hashgen_stdout_mode==0))
    {
        sleep(3);
        attack_checkpoints++;
        sum = 0;
        if (attack_over != 2)
        {
            cracked = get_cracked_num();
            if ((attack_method == attack_method_simple_bruteforce))
            {
                for (a=0;a<nwthreads;a++) 
                {
                    sum+=wthreads[a].tries;
                    wthreads[a].oldtries = wthreads[a].tries;
                    wthreads[a].tries=0;
                }
                if (attack_checkpoints==1) attack_avgspeed = sum;
                else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
                attack_current_count+=sum;
            }
            if (attack_method==attack_method_markov)
            { 
                for (a=0;a<nwthreads;a++) 
                {
                    sum+=wthreads[a].tries;
                    wthreads[a].oldtries = wthreads[a].tries;
                    wthreads[a].tries=0;
                }
                if (attack_checkpoints==1) attack_avgspeed = sum;
                else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
                attack_current_count+=sum;
            }
            if (attack_method==attack_method_rule)
            {
                for (a=0;a<nwthreads;a++) 
                {
                    sum+=wthreads[a].tries;
                    wthreads[a].oldtries = wthreads[a].tries;
                    wthreads[a].tries=0;
                }
                if (attack_checkpoints==1) attack_avgspeed = sum;
                else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
                if (attack_overall_count <= 1)
                {
                    if ((sum / 30000000) > 20) printf("\rSpeed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
                    else if ((sum / 3000) > 20) printf("\rSpeed: %lldK c/s (avg: %lldK c/s)   Cracked: %d passwords   ", (sum / 3000),(attack_avgspeed/3000) ,cracked);
                    else printf("\rSpeed: %lld c/s (avg: %lld c/s)  Cracked: %d passwords   ", (sum / 3),(attack_avgspeed/3), cracked);
                }

                else
                {
                    if ( ((attack_current_count*100) / attack_overall_count) > 100)
                    {
                        if (sum>30000000) printf("\rProgress: 100%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000000),(attack_avgspeed/3000000) ,cracked);
                        else printf("\rProgress: 100%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000),(attack_avgspeed/3000) ,cracked);
                    }
                    else  
                    {
                        if (sum>30000000) printf("\rProgress: %lld%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", ((attack_current_count*100)/attack_overall_count) ,(sum / 3000000),(attack_avgspeed/3000000) ,cracked);
                        else if ((sum / 3000) > 20) printf("\rProgress: %lld%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ", (uint64_t)((attack_current_count*100)/attack_overall_count) ,(sum / 3000),(attack_avgspeed/3000) ,cracked);
                        else printf("\rProgress: %lld%%   Speed: %lld c/s (avg: %lld c/s)  Cracked: %d passwords   ",(uint64_t)((attack_current_count*100)/attack_overall_count), (sum / 3),(attack_avgspeed/3), cracked);
                    }
                }
                if (cracked >= hashes_count) attack_over = 2;
                fflush(stdout);
            }
            else
            {
                if (attack_overall_count == 1)
                {
                    if ((sum / 30000000) > 20)  printf("\rSpeed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
                    else if ((sum / 3000) > 20) printf("\rSpeed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ", (sum / 3000),(attack_avgspeed/3000), cracked);
                    else printf("\rSpeed: %lld c/s (avg: %lld c/s)   Cracked: %d passwords    ", (sum / 3),(attack_avgspeed/3), cracked);
                }
                else
                {
                    if ( ((attack_current_count*100) / attack_overall_count) > 100)
                    {
                        if (sum>30000000) printf("\rProgress: 100%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
                        else printf("\rProgress: 100%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000),(attack_avgspeed/3000), cracked);
                    }
                    else  
                    {
                        if (sum>30000000)       printf("\rProgress: %lld%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ",((attack_current_count*100)/attack_overall_count) ,(sum / 3000000),(attack_avgspeed/3000000), cracked);
                        else if ((sum / 3000) > 20) printf("\rProgress: %lld%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ",((attack_current_count*100)/attack_overall_count) , (sum / 3000),(attack_avgspeed/3000), cracked);
                        else printf("\rProgress: %lld%%   Speed: %lld c/s (avg: %lld c/s)  Cracked: %d passwords   ",(uint64_t)((attack_current_count*100)/attack_overall_count), (sum / 3),(attack_avgspeed/3), cracked);
                    }
                }
            }
            printf("                        ");
            fflush(stdout);
            printf("\r\e[?25l");
            fflush(stdout);

            if (session_init_file(&sessionfile) == hash_ok)
            {
                if (attack_overall_count<2) session_write_parameters(get_current_plugin(), attack_method, 0 , sessionfile);
                else session_write_parameters(get_current_plugin(), attack_method, ((attack_current_count*100)/(attack_overall_count+1)), sessionfile);
                if (attack_method == attack_method_simple_bruteforce)
                {
                    // FIXME: add real start and curstr
                    session_write_bruteforce_parm(bruteforce_start, bruteforce_end, "", "", bruteforce_charset, 0, "", attack_current_count, sessionfile);
                }
                else if (attack_method == attack_method_markov)
                {
                    session_write_markov_parm(markov_statfile, markov_threshold, markov_max_len, attack_overall_count, attack_current_count, attack_current_str,  sessionfile);
                }
                else if (attack_method == attack_method_rule)
                {
                    session_write_rule_parm(rule_file, attack_current_count, attack_overall_count, sessionfile);
                }
                if (attack_over==0)
                {
                    session_write_hashlist(sessionfile);
                    session_write_crackedlist(sessionfile);
                }
                session_close_file(sessionfile);
            }
            if ((cracked >= hashes_count)&&(hashgen_stdout_mode==0)) attack_over = 2;
        }
    }
    printf("\n");
    pthread_cancel(monitorinfothread);
    pthread_exit(NULL);
    return 0;
}



/* Start monitor info thread (this actually just waits for keyboard input and prints out stats*/ 
static void * start_monitor_info_thread(void *arg)
{
    int key;
    uint64_t timeest;
    char *stringest = alloca(200);
    char *stringest1 = alloca(100);
    
    while (1)
    {
	key = getchar();
	printf("\n");
	if (key=='\n')
	{
	    print_cracked_list();
	    hlog(" -= End list =-%s\n","");
	}
	time2 = time(NULL);
	bzero(stringest,200);
	timeest = (((attack_overall_count-attack_current_count)*(time2-time1))/(attack_current_count+1));
	if (attack_overall_count == 1)
	{
	    strcpy(stringest, "Time remaining: UNKNOWN");
	}
	else
	{
	    strcpy(stringest, "Time remaining: ");
	    if ((timeest / (60*60*24*30*12))>1)
	    {
		sprintf(stringest1,"%llu years ",(timeest / (60*60*24*30*12)));
		strcat(stringest, stringest1);
	    }
	    if ((timeest / (60*60*24*30))>1)
	    {
		sprintf(stringest1,"%llu months ",(timeest / (60*60*24*30))%(12));
		strcat(stringest, stringest1);
	    }
	    if ((timeest / (60*60*24))>1)
	    {
		sprintf(stringest1,"%llu days ",(timeest / (60*60*24))%(30));
		strcat(stringest, stringest1);
	    }
	    if ((timeest / (60*60))>1)
	    {
		sprintf(stringest1,"%llu hours ",(timeest / (60*60))%(24));
		strcat(stringest, stringest1);
	    }
	    if ((timeest / (60))>1)
	    {
		sprintf(stringest1,"%llu minutes ",(timeest / (60))%60);
		strcat(stringest, stringest1);
	    }
	    else 
	    {
		sprintf(stringest1,"%llu sec ",(timeest));
		strcat(stringest, stringest1);
	    }
	}
	hlog("%s\n\n", stringest);
    }
    return NULL;
}

static uint64_t markov_calculate_overall(int n)
{
    int a,b,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    uint64_t overall = 0;
    int reduced_size;
    int markov2[88][88];
    int markov_csize;

    /* wait until the threads started cracking */
    while (wthreads[0].tries==0) usleep(1000);
    reduced_size=0;
    markov_csize = strlen(markov_charset);
    if ((fast_markov==1)) markov_csize-=23;

    for (a=0;a<markov_csize;a++) if (markov0[a]>markov_threshold)
    {
        // Create markov2 table
        for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
        reduced_size++;
    }

    switch (n)
    {

        case 1:
            for (a1=0;a1<reduced_size;a1++)
            {overall++; }
        break;

        case 2:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            {overall++; }
        break;

        case 3:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            {overall++; }
	break;
        case 4:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            {overall++;} 
        break;

        case 5:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            {overall++; }
        break;

        case 6:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            {overall++; }
        break;

        case 7:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            {overall++; }
        break;
        case 8:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            {overall++; }
        break;

        case 9:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            {overall++; }
        break;

        case 10:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            for (a10=0;a10<markov_csize;a10++) if (markov1[a9][a10]>markov_threshold)
            {overall++; }
        break;
        case 11:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            for (a10=0;a10<markov_csize;a10++) if (markov1[a9][a10]>markov_threshold)
            for (a11=0;a11<markov_csize;a11++) if (markov1[a10][a11]>markov_threshold)
            {overall++; }
        break;

    }
    return overall;
}


static void *calculate_markov_thread(void *arg)
{
    int cnt;
    uint64_t overall=0;

    for (cnt=2;cnt<=markov_max_len;cnt++) 
    {
        overall += markov_calculate_overall(cnt-1);
    }
    attack_overall_count = overall*strlen(markov_charset);
    pthread_exit(NULL);
}





void* cpu_bruteforce_thread(void *arg)
{
    int self;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    char *buf;

    memcpy(&self,arg,sizeof(int));
    charset_size = strlen(bruteforce_charset);

    if (scheduler.len<2) scheduler.len=2;
    sched_wait(2);
    if (sched_len()==2)
    while ((sched_len()==2)&&((a1=sched_s1())<sched_e1()))
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=bruteforce_charset[a1];
	hash_cpu[self].len[cur]=2;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(3);
    if (sched_len()==3)
    for (a1=0;a1<charset_size;a1++)
    while ((sched_len()==3)&&((a2=sched_s2(a1))<sched_e2(a1)))
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=bruteforce_charset[a1];
	buf[2]=bruteforce_charset[a2];
	hash_cpu[self].len[cur]=3;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(4);
    if (sched_len()==4)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==4)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=bruteforce_charset[a1];
	buf[2]=bruteforce_charset[a2];
	buf[3]=bruteforce_charset[a3];
	hash_cpu[self].len[cur]=4;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(5);
    if (sched_len()==5)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==5)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[4]=bruteforce_charset[a1];
	buf[2]=bruteforce_charset[a2];
	buf[3]=bruteforce_charset[a3];
	buf[1]=bruteforce_charset[a4];
	hash_cpu[self].len[cur]=5;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;


    sched_wait(6);
    if (sched_len()==6)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==6)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[5]=bruteforce_charset[a1];
	buf[4]=bruteforce_charset[a2];
	buf[3]=bruteforce_charset[a3];
	buf[1]=bruteforce_charset[a4];
	buf[2]=bruteforce_charset[a5];
	hash_cpu[self].len[cur]=6;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(7);
    if (sched_len()==7)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[6]=bruteforce_charset[a1];
	buf[5]=bruteforce_charset[a2];
	buf[4]=bruteforce_charset[a3];
	buf[3]=bruteforce_charset[a4];
	buf[2]=bruteforce_charset[a5];
	buf[1]=bruteforce_charset[a6];
	hash_cpu[self].len[cur]=7;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(8);
    if (sched_len()==8)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[7]=bruteforce_charset[a1];
	buf[6]=bruteforce_charset[a2];
	buf[5]=bruteforce_charset[a3];
	buf[4]=bruteforce_charset[a4];
	buf[3]=bruteforce_charset[a5];
	buf[2]=bruteforce_charset[a6];
	buf[1]=bruteforce_charset[a7];
	hash_cpu[self].len[cur]=8;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(9);
    if (sched_len()==9)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[8]=bruteforce_charset[a1];
	buf[7]=bruteforce_charset[a2];
	buf[6]=bruteforce_charset[a3];
	buf[5]=bruteforce_charset[a4];
	buf[4]=bruteforce_charset[a5];
	buf[3]=bruteforce_charset[a6];
	buf[2]=bruteforce_charset[a7];
	buf[1]=bruteforce_charset[a8];
	hash_cpu[self].len[cur]=9;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(10);
    if (sched_len()==10)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[9]=bruteforce_charset[a1];
	buf[8]=bruteforce_charset[a2];
	buf[7]=bruteforce_charset[a3];
	buf[6]=bruteforce_charset[a4];
	buf[5]=bruteforce_charset[a5];
	buf[4]=bruteforce_charset[a6];
	buf[3]=bruteforce_charset[a7];
	buf[2]=bruteforce_charset[a8];
	buf[1]=bruteforce_charset[a9];
	hash_cpu[self].len[cur]=10;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(11);
    if (sched_len()==11)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    for (a10=0;a10<charset_size;a10++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[10]=bruteforce_charset[a1];
	buf[9]=bruteforce_charset[a2];
	buf[8]=bruteforce_charset[a3];
	buf[7]=bruteforce_charset[a4];
	buf[6]=bruteforce_charset[a5];
	buf[5]=bruteforce_charset[a6];
	buf[4]=bruteforce_charset[a7];
	buf[3]=bruteforce_charset[a8];
	buf[2]=bruteforce_charset[a9];
	buf[1]=bruteforce_charset[a10];
	hash_cpu[self].len[cur]=11;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(12);
    if (sched_len()==12)
    for (a1=0;a1<charset_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    for (a4=0;a4<charset_size;a4++)
    for (a5=0;a5<charset_size;a5++)
    for (a6=0;a6<charset_size;a6++)
    for (a7=0;a7<charset_size;a7++)
    for (a8=0;a8<charset_size;a8++)
    for (a9=0;a9<charset_size;a9++)
    for (a10=0;a10<charset_size;a10++)
    for (a11=0;a11<charset_size;a11++)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[11]=bruteforce_charset[a1];
	buf[10]=bruteforce_charset[a2];
	buf[9]=bruteforce_charset[a3];
	buf[8]=bruteforce_charset[a4];
	buf[7]=bruteforce_charset[a5];
	buf[6]=bruteforce_charset[a6];
	buf[5]=bruteforce_charset[a7];
	buf[4]=bruteforce_charset[a8];
	buf[3]=bruteforce_charset[a9];
	buf[2]=bruteforce_charset[a10];
	buf[1]=bruteforce_charset[a11];
	hash_cpu[self].len[cur]=12;
	if (cur==vectorsize-1)
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    return NULL;
}



void* cpu_markov_thread(void *arg)
{
    int self;
    int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    char *buf;

    memcpy(&self,arg,sizeof(int));
    if (scheduler.len<2) scheduler.len=2;

    sched_wait(2);
    if (sched_len()==2)
    while ((sched_len()==2)&&((a1=sched_s1())<sched_e1()))
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	hash_cpu[self].len[cur]=2;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(3);
    if (sched_len()==3)
    for (a1=0;a1<reduced_size;a1++)
    while ((sched_len()==3)&&((a2=sched_s2(a1))<sched_e2(a1)))
    if (markov2[a1][a2]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	hash_cpu[self].len[cur]=3;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(4);
    if (sched_len()==4)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==4)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	hash_cpu[self].len[cur]=4;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(5);
    if (sched_len()==5)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==5)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	hash_cpu[self].len[cur]=5;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(6);
    if (sched_len()==6)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==6)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	hash_cpu[self].len[cur]=6;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;


    sched_wait(7);
    if (sched_len()==7)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==7)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	hash_cpu[self].len[cur]=7;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(8);
    if (sched_len()==8)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==8)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++) 
    if (markov1[a6][a7]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	buf[7]=markov_charset[a7];
	hash_cpu[self].len[cur]=8;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(9);
    if (sched_len()==9)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==9)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++) 
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	buf[7]=markov_charset[a7];
	buf[8]=markov_charset[a8];
	hash_cpu[self].len[cur]=9;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(10);
    if (sched_len()==10)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==10)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++) 
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    for (a9=0;a9<charset_size;a9++) 
    if (markov1[a8][a9]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	buf[7]=markov_charset[a7];
	buf[8]=markov_charset[a8];
	buf[9]=markov_charset[a9];
	hash_cpu[self].len[cur]=10;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(11);
    if (sched_len()==11)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==11)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++) 
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    for (a9=0;a9<charset_size;a9++) 
    if (markov1[a8][a9]>markov_threshold)
    for (a10=0;a10<charset_size;a10++) 
    if (markov1[a9][a10]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	buf[7]=markov_charset[a7];
	buf[8]=markov_charset[a8];
	buf[9]=markov_charset[a9];
	buf[10]=markov_charset[a10];
	hash_cpu[self].len[cur]=11;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    finalthread(self);
    cur=-1;

    sched_wait(12);
    if (sched_len()==12)
    for (a1=0;a1<reduced_size;a1++)
    for (a2=0;a2<charset_size;a2++)
    while ((sched_len()==12)&&((a3=sched_s3(a1,a2))<sched_e3(a1,a2)))
    if (markov2[a1][a2]>markov_threshold)
    if (markov1[a2][a3]>markov_threshold)
    for (a4=0;a4<charset_size;a4++) 
    if (markov1[a3][a4]>markov_threshold)
    for (a5=0;a5<charset_size;a5++) 
    if (markov1[a4][a5]>markov_threshold)
    for (a6=0;a6<charset_size;a6++) 
    if (markov1[a5][a6]>markov_threshold)
    for (a7=0;a7<charset_size;a7++) 
    if (markov1[a6][a7]>markov_threshold)
    for (a8=0;a8<charset_size;a8++) 
    if (markov1[a7][a8]>markov_threshold)
    for (a9=0;a9<charset_size;a9++) 
    if (markov1[a8][a9]>markov_threshold)
    for (a10=0;a10<charset_size;a10++) 
    if (markov1[a9][a10]>markov_threshold)
    for (a11=0;a11<charset_size;a11++) 
    if (markov1[a10][a11]>markov_threshold)
    {
	cur++;
	buf = hash_cpu[self].plaintext[cur];
	buf[1]=reduced_charset[a1];
	buf[2]=markov_charset[a2];
	buf[3]=markov_charset[a3];
	buf[4]=markov_charset[a4];
	buf[5]=markov_charset[a5];
	buf[6]=markov_charset[a6];
	buf[7]=markov_charset[a7];
	buf[8]=markov_charset[a8];
	buf[9]=markov_charset[a9];
	buf[10]=markov_charset[a10];
	buf[11]=markov_charset[a11];
	hash_cpu[self].len[cur]=12;
	if ((cur==vectorsize-1))
	{
	    if (attack_over!=0) return NULL;
	    finalthread(self);
	    cur=-1;
	}
    }
    return NULL;
}


/* Crack callback */
static void cpu_rule_callback(char *line, int self)
{
    if (hashgen_stdout_mode==1)
    {
	if (attack_over!=0) return;
	if (line[0]>1) printf("%s\n",line);
	return;
    }
    cur++;
    bzero(hash_cpu[self].plaintext[cur],MAX);
    strcpy(hash_cpu[self].plaintext[cur],line);
    if ((cur==(wthreads[self].vectorsize-1))||(line[0]==0x01))
    {
        if (attack_over!=0) return;
        finalthread(self);
        cur=-1;
    }
}



void* cpu_rule_thread(void *arg)
{
    int self;

    memcpy(&self,arg,sizeof(int));
    worker_gen(self,cpu_rule_callback);
    finalthread(self);
    return NULL;
}

hash_stat main_thread_markov(int threads)
{
    int flag,count,a,b,c,etemp,e1,e2,e3;
    struct  hash_list_s *mylist;
    pthread_t crack_threads[HASHKILL_MAXTHREADS];
    int worker_thread_keys[32];
    pthread_t calc_thread;

    e1=e2=e3=0;
    time1=time(NULL);
    mylist = hash_list;
    spawn_threads(threads);
    if (session_restore_flag==0) attack_overall_count=1;
    charset_size = strlen(markov_charset);
    reduced_size=0;
    for (a=0;a<charset_size;a++) if (markov0[a]>markov_threshold)
    {
        reduced_charset[reduced_size]=markov_charset[a];
        // Create markov2 table
        for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
        reduced_size++;
        reduced_charset[reduced_size]=0;
    }

    hlog("Markov max len: %d threshold:%d\n",markov_max_len, markov_threshold);
    hlog("Progress indicator will be available once Markov calculations are done...\n%s","");
    if (session_restore_flag==0) 
    {
        attack_overall_count = 1;
        pthread_create(&calc_thread, NULL, calculate_markov_thread, NULL);
    }


    if (session_restore_flag==0)
    {
        scheduler.markov_l1 = reduced_size;
        for (a=0;a<reduced_size;a++)
        {
            etemp = 0;
            for (b=0;b<strlen(markov_charset);b++)
            if (markov2[a][b]>markov_threshold) etemp++;

            if (etemp>0)
            {
                e1=a;
                e2=etemp;
            }
            scheduler.ebitmap2[a]=etemp;
        }
        scheduler.markov_l2_1 = e1;
        scheduler.markov_l2_2 = e2;

        for (a=0;a<reduced_size;a++)
        for (b=0;b<strlen(markov_charset);b++)
        if (markov2[a][b]>markov_threshold)
        {
            etemp = 0;
            for (c=0;c<strlen(markov_charset);c++)
            if (markov1[b][c]>markov_threshold) etemp++;

            if (etemp>0)
            {
                e1=a;
                e2=b;
                e3=etemp;
            }
            scheduler.ebitmap3[a][b]=etemp;
        }
        else scheduler.ebitmap3[a][b]=0;
        scheduler.markov_l3_1 = e1;
        scheduler.markov_l3_2 = e2;
        scheduler.markov_l3_3 = e3;
    }


#ifdef HAVE_SSE2
    OMD5_PREPARE_OPT();
    OSHA1_PREPARE_OPT();
    OMD4_PREPARE_OPT();
    OFCRYPT_PREPARE_OPT();
#endif

    mylist = hash_list;
    while (mylist)
    {
	if (strlen(mylist->salt) > 1) flag = 1;
	mylist = mylist->next;
	count++;
    }

    // Some plugins have non-regular 'hash' value though 
    flag=0;
    if ((strcmp(get_current_plugin(),"md5unix")==0)||(strcmp(get_current_plugin(),"apr1")==0)
    ||(strcmp(get_current_plugin(),"sha512unix")==0)||(strcmp(get_current_plugin(),"sha256unix")==0)
    ||(strcmp(get_current_plugin(),"mscash")==0)||(strcmp(get_current_plugin(),"mscash2")==0)
    ||(strcmp(get_current_plugin(),"zip")==0)||(strcmp(get_current_plugin(),"wpa")==0)
    ||(strcmp(get_current_plugin(),"dmg")==0)||(strcmp(get_current_plugin(),"bcrypt")==0)
    ||(strcmp(get_current_plugin(),"desunix")==0)||(strcmp(get_current_plugin(),"rar")==0)
    ) 
    {
	flag=1;
	count=2;
    }

    if (((flag == 0)||(count<2))&&(salt_size<2))
    {
	hlog("Attack has O(1) complexity%s\n","");
	if (single_hash == 0)
	{
	    create_hash_indexes();
	    finalthread = thread_attack_worker_linear_markov;
	    init_bitmaps();
	}
	else
	{
	    hlog("Single hash - skipping bitmap checks%s\n","");
	    finalthread = thread_attack_worker_linear_markov_single;
	}
    }
    else
    {
	hlog("Attack has O(n) complexity%s\n","");
	finalthread = thread_attack_worker_nonlinear_markov;
	init_bitmaps();
    }
    scheduler_setup(1, 2, markov_max_len, strlen(markov_charset), strlen(markov_charset));
    for (a=0;a<nwthreads;a++) if (wthreads[a].type==cpu_thread)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, cpu_markov_thread, &worker_thread_keys[a]);
    }
    for (a=0;a<nwthreads;a++) if (wthreads[a].type==cpu_thread) 
    {
        pthread_join(crack_threads[a], NULL);
    }
    SSL_thread_cleanup();
    return hash_ok;
}




hash_stat main_thread_bruteforce(int threads)
{
    int flag,count,a,cnt;
    struct  hash_list_s *mylist;
    pthread_t crack_threads[HASHKILL_MAXTHREADS];
    int worker_thread_keys[32];

    time1=time(NULL);
    mylist = hash_list;
    spawn_threads(threads);
    if (session_restore_flag==0) attack_overall_count=1;
    if (bruteforce_start==bruteforce_end) attack_overall_count = (powl(strlen(bruteforce_charset),bruteforce_end));
    else for (cnt = bruteforce_start; cnt <= bruteforce_end; cnt++)
    {
        attack_overall_count += (powl(strlen(bruteforce_charset),cnt));
    }


#ifdef HAVE_SSE2
    OMD5_PREPARE_OPT();
    OSHA1_PREPARE_OPT();
    OMD4_PREPARE_OPT();
    OFCRYPT_PREPARE_OPT();
#endif

    mylist = hash_list;
    while (mylist)
    {
	if (strlen(mylist->salt) > 1) flag = 1;
	mylist = mylist->next;
	count++;
    }

    // Some plugins have non-regular 'hash' value though 
    flag=0;
    if ((strcmp(get_current_plugin(),"md5unix")==0)||(strcmp(get_current_plugin(),"apr1")==0)
    ||(strcmp(get_current_plugin(),"sha512unix")==0)||(strcmp(get_current_plugin(),"sha256unix")==0)
    ||(strcmp(get_current_plugin(),"mscash")==0)||(strcmp(get_current_plugin(),"mscash2")==0)
    ||(strcmp(get_current_plugin(),"zip")==0)||(strcmp(get_current_plugin(),"wpa")==0)
    ||(strcmp(get_current_plugin(),"dmg")==0)||(strcmp(get_current_plugin(),"bcrypt")==0)
    ||(strcmp(get_current_plugin(),"desunix")==0)||(strcmp(get_current_plugin(),"rar")==0)
    ) 
    {
	flag=1;
	count=2;
    }

    if (((flag == 0)||(count<2))&&(salt_size<2))
    {
	hlog("Attack has O(1) complexity%s\n","");
	if (single_hash == 0)
	{
	    create_hash_indexes();
	    finalthread = thread_attack_worker_linear_bruteforce;
	    init_bitmaps();
	}
	else
	{
	    hlog("Single hash - skipping bitmap checks%s\n","");
	    finalthread = thread_attack_worker_linear_bruteforce_single;
	}
    }
    else
    {
	hlog("Attack has O(n) complexity%s\n","");
	finalthread = thread_attack_worker_nonlinear_bruteforce;
	init_bitmaps();
    }
    scheduler_setup(bruteforce_start, 2, bruteforce_end, strlen(bruteforce_charset), strlen(bruteforce_charset));
    for (a=0;a<nwthreads;a++) if (wthreads[a].type==cpu_thread)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, cpu_bruteforce_thread, &worker_thread_keys[a]);
    }
    for (a=0;a<nwthreads;a++) if (wthreads[a].type==cpu_thread) 
    {
        pthread_join(crack_threads[a], NULL);
    }
    SSL_thread_cleanup();
    return hash_ok;
}




hash_stat main_thread_rule(int threads)
{
    int flag,count,a;
    struct  hash_list_s *mylist;
    pthread_t crack_threads[HASHKILL_MAXTHREADS];
    int worker_thread_keys[32];

    time1=time(NULL);
    mylist = hash_list;
    spawn_threads(threads);
    if (session_restore_flag==0) attack_overall_count=1;

#ifdef HAVE_SSE2
    if (hashgen_stdout_mode==0)
    {
	OMD5_PREPARE_OPT();
	OSHA1_PREPARE_OPT();
	OMD4_PREPARE_OPT();
	OFCRYPT_PREPARE_OPT();
    }
#endif

    mylist = hash_list;
    while (mylist)
    {
	if (strlen(mylist->salt) > 1) flag = 1;
	mylist = mylist->next;
	count++;
    }

    // Some plugins have non-regular 'hash' value though 
    flag=0;
    if ((strcmp(get_current_plugin(),"md5unix")==0)||(strcmp(get_current_plugin(),"apr1")==0)
    ||(strcmp(get_current_plugin(),"sha512unix")==0)||(strcmp(get_current_plugin(),"sha256unix")==0)
    ||(strcmp(get_current_plugin(),"mscash")==0)||(strcmp(get_current_plugin(),"mscash2")==0)
    ||(strcmp(get_current_plugin(),"zip")==0)||(strcmp(get_current_plugin(),"wpa")==0)
    ||(strcmp(get_current_plugin(),"dmg")==0)||(strcmp(get_current_plugin(),"bcrypt")==0)
    ||(strcmp(get_current_plugin(),"desunix")==0)||(strcmp(get_current_plugin(),"rar")==0)
    ) 
    {
	flag=1;
	count=2;
    }

    if (((flag == 0)||(count<2))&&(salt_size<2))
    {
	hlog("Attack has O(1) complexity%s\n","");
	if (single_hash == 0)
	{
	    create_hash_indexes();
	    finalthread = thread_attack_worker_linear_rule;
	    init_bitmaps();
	}
	else
	{
	    hlog("Single hash - skipping bitmap checks%s\n","");
	    finalthread = thread_attack_worker_linear_rule_single;
	}
    }
    else
    {
	hlog("Attack has O(n) complexity%s\n","");
	finalthread = thread_attack_worker_nonlinear_rule;
	init_bitmaps();
    }

    if (hashgen_stdout_mode==0) rule_stats_parse();
    for (a=0;a<nwthreads;a++) if ((wthreads[a].type==cpu_thread)&&(hashgen_stdout_mode==0))
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, cpu_rule_thread, &worker_thread_keys[a]);
    }

    rule_gen_parse(rule_file,cpu_rule_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) if ((wthreads[a].type==cpu_thread)&&(hashgen_stdout_mode==0))
    {
        pthread_join(crack_threads[a], NULL);
    }
    /* This is stupid, but we need to do that to avoid a race here */
    pthread_mutex_lock(&crackedmutex);
    pthread_mutex_unlock(&crackedmutex);
    SSL_thread_cleanup();
    return hash_ok;
}




