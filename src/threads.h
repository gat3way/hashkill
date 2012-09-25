/* threads.h
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


#ifndef HASHTHREADS_H
#define HASHTHREADS_H

#include <pthread.h>
#include <semaphore.h>
#include <stdint.h>
#include "hashinterface.h"
#include "err.h"


/* global variables */
int cpu_master_ready;


/* mutexes - public since list routines need them */
pthread_mutex_t listmutex;
pthread_mutex_t crackedmutex;


/* Thread functions */
unsigned int hash_num_cpu(void);
unsigned long hash_get_total_memory(void); 
hash_stat init_mutexes(void);
hash_stat main_thread_bruteforce(int threads);
hash_stat main_thread_markov(int threads);
hash_stat main_thread_rule(int threads);



/* Cleanup routine */
void thread_attack_cleanup(void);




#endif
