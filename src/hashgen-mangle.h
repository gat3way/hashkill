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

#ifndef HASHGEN_MANGLE_H
#define  HASHGEN_MANGLE_H


#define MAX_MMAP_INITIAL (1024*1024*256)
#define MAX_MMAP_NEXT (1024*256)



typedef void (*parsefn_t)(char *line,char *stack,int ind, int self);


char rulesetfile[255];

typedef struct ops_s
{
    parsefn_t parsefn;
    char charset[128];
    int mode;
    int push;
    int start;
    int end;
    int max;
    int numth;
    int current;
    int chainlen;
    char params[MAXCAND*2];
    finalfn_t crack_callback;
} ops_t;

ops_t ops[HASHKILL_MAXTHREADS+3][MAXRULES] __attribute__((aligned(64)));;



typedef struct rule_queue_s
{
    volatile int pushready;
    char stack[MAXCAND];
    char line[MAXCAND];
} rule_queue_t;

rule_queue_t rule_queue[HASHKILL_MAXTHREADS+3] __attribute__((aligned(64)));;






typedef struct tablechar_s
{
    char inchar;
    char outstr[MAXCAND*2];
    int active;
} tablechar_t;
tablechar_t tablechar[HASHKILL_MAXTHREADS+3][MAXRULES];


//char *currentline[MAXRULELINES];
int currentlinenum[HASHKILL_MAXTHREADS+1];


void node_final(char *line, char *stack, int ind, int self);
void node_final_push(char *line, char *stack, int ind, int self);
void node_add_cset(char *line, char *stack,int ind,int self);
void node_add_set(char *line, char *stack,int ind,int self);
void node_add_str(char *line, char *stack,int ind,int self);
void node_add_revstr(char *line, char *stack,int ind,int self);
void node_add_samestr(char *line, char *stack,int ind,int self);
void node_add_char(char *line, char *stack,int ind,int self);
void node_add_dict(char *line, char *stack,int ind,int self);
void node_add_phrases(char *line, char *stack,int ind,int self);
void node_add_binstrings(char *line, char *stack,int ind,int self);
void node_add_pipe(char *line, char *stack,int ind,int self);
void node_add_markov(char *line, char *stack,int ind,int self);
void node_add_usernames(char *line, char *stack,int ind,int self);
void node_add_passwords(char *line, char *stack,int ind,int self);
void node_add_lastchar(char *line, char *stack,int ind,int self);
void node_insertp_str(char *line, char *stack,int ind,int self);
void node_insertp_dict(char *line, char *stack,int ind,int self);
void node_insertp_numrange(char *line, char *stack,int ind,int self);
void node_insertp_usernames(char *line, char *stack,int ind,int self);
void node_deletep(char *line, char *stack,int ind,int self);
void node_leetify(char *line, char *stack,int ind,int self);
void node_upcase(char *line, char *stack,int ind,int self);
void node_togglecase(char *line, char *stack,int ind,int self);
void node_lowcase(char *line, char *stack,int ind,int self);
void node_reverse(char *line, char *stack,int ind,int self);
void node_shuffle2(char *line, char *stack,int ind,int self);
void node_rot13(char *line, char *stack,int ind,int self);
void node_pasttense(char *line, char *stack,int ind,int self);
void node_conttense(char *line, char *stack,int ind,int self);
void node_permute(char *line, char *stack,int ind,int self);
void node_truncate(char *line, char *stack,int ind,int self);
void node_delete_char(char *line, char *stack,int ind,int self);
void node_delete_match(char *line, char *stack,int ind,int self);
void node_delete_repeating(char *line, char *stack,int ind,int self);
void node_remove_match(char *line, char *stack,int ind,int self);
void node_insert_str(char *line, char *stack,int ind,int self);
void node_insert_dict(char *line, char *stack,int ind,int self);
void node_insert_usernames(char *line, char *stack,int ind,int self);
void node_insert_passwords(char *line, char *stack,int ind,int self);
void node_replace_table_char(char *line, char *stack,int ind,int self);
void node_replace_table_str(char *line, char *stack,int ind,int self);
void node_replace_str(char *line, char *stack,int ind,int self);
void node_replace_dict(char *line, char *stack,int ind,int self);
void node_pop_add(char *line, char *stack,int ind,int self);
void node_add_numrange(char *line, char *stack,int ind,int self);
void node_upcaseat(char *line, char *stack,int ind,int self);
void node_lowcaseat(char *line, char *stack,int ind,int self);
void node_genham(char *line, char *stack,int ind,int self);
void node_genlev(char *line, char *stack,int ind,int self);
void node_genlevdam(char *line, char *stack,int ind,int self);
void node_print_stdout(char *line, char *stack,int ind,int self);
void node_queue(char *line, char *stack,int ind,int self);
void node_queue_end(char *line, char *stack,int ind,int self);
void node_dequeue(char *line, char *stack,int ind,int self);
void node_count(char *line, char *stack,int ind,int self);
void node_wait_queues();


#endif
