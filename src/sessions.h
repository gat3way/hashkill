/* sessions.h
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

#ifndef SESSIONS_H
#define SESSIONS_H

#include <stdint.h>
#include "hashinterface.h"

/* Public sessions interface */
hash_stat session_init_file(FILE **sessionfile);
void session_close_file(FILE *sessionfile);
hash_stat session_write_hashlist(FILE *sessionfile);
hash_stat session_write_crackedlist(FILE *sessionfile);
hash_stat session_write_dictionary_parm(uint64_t filepos, char *dictfile, FILE *sessionfile);
hash_stat session_write_bruteforce_parm(int start, int end, char *prefix, char *suffix, char *charset, int curlen, char *curstr, uint64_t progress, FILE *sessionfile);
hash_stat session_write_markov_parm(char *statfile, int threshold, int len, uint64_t count, uint64_t current_elem, char *current_str, FILE *sessionfile);
hash_stat session_write_rule_parm(char *rulename, uint64_t current, uint64_t overall, FILE *sessionfile);
hash_stat session_write_parameters(char *plugin, attack_method_t attacktype, uint64_t progress, FILE *sessionfile);
void session_put_commandline(char *argv[]);
hash_stat print_sessions_summary(void);
hash_stat print_session_detailed(char *sessionname);
hash_stat session_restore(char *sessionname);
void session_unlink_file();
void session_unlink_file_ocl();

#define MAXARGV 10
char *session_argv[MAXARGV];

#endif
