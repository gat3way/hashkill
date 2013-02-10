/* 
 * hashgen.h
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

#ifndef HASHGEN_H
#define HASHGEN_H

#define MAXCAND 32
// Backward-compatibility
#define MAX MAXCAND 
#define MAXRULES 32
#define MAXRULELINES 64
#define RULEQUEUESIZE 256*256*8
#define SELF_THREAD (HASHKILL_MAXTHREADS)
#define RULE_MODE_STATS 1
#define RULE_MODE_PARSE 0

#include <stdint.h>

#define HG_EWHERESTR  "\033[1;31m[hashkill]\033[0m "
#define hg_elogstd(...)     fprintf(stderr, __VA_ARGS__)

#define hg_elog(_fmt, ...) { \
hlogstd(HG_EWHERESTR _fmt,  __VA_ARGS__); \
if (is_preprocess==1) exit(1); \
}


typedef enum optimize_type_e
{
    optimize_none,  		// No optimization
    optimize_add_set,		// Add set
    optimize_may_add_set,	// May add set
    optimize_add_cset,		// Add cset
    optimize_may_add_cset,	// May add cset
    optimize_add_markov,	// Add markov
    optimize_may_add_markov,	// May add markov
    optimize_add_numrange,	// Add numrange
    optimize_may_add_numrange,	// May add numrange
    optimize_add_fastdict,	// Add fastdict
    optimize_may_add_fastdict,	// May add fastdict
} optimize_type_t;

typedef struct optimize_s
{
    int type;
    char charset[128];
    char statfile[1024];
    int threshold;
    int start;
    int end;
} optimize_t;


optimize_t rule_optimize[HASHKILL_MAXTHREADS+1] __attribute__((aligned(64)));;


typedef void (*finalfn_t)(char *line, int self);

hash_stat rule_preprocess(char *rulefile);
void rule_gen_parse(char *rulefile, finalfn_t callback, int max, int self);
void rule_stats_parse(void);
void worker_gen(int self,finalfn_t callback);
int rules_num;
uint64_t rule_current_elem;
uint64_t rule_overall_elem;
int hashgen_stdout_mode;
int hashgen_current_rules[64];
int rule_stats_available;
volatile uint64_t currentqueued;
#endif
