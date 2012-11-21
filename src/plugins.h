/* plugins.h
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

#ifndef PLUGINS_H
#define PLUGINS_H

#include "err.h"
#include "hashinterface.h"

/* plugin functions  */
hash_stat  (*hash_plugin_parse_hash)(char *hashline, char *filename);
hash_stat (*hash_plugin_check_hash)(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid);
hash_stat (*hash_plugin_check_hash_dictionary)(const char *hash, const char *password[VECTORSIZE], const char *salt,  char *salt2[VECTORSIZE], const char *username, int *num, int threadid);
int  (*hash_plugin_hash_length)(void);
int  (*hash_plugin_is_raw)(void);
int  (*hash_plugin_is_special)(void);
void  (*get_vector_size)(int size);
int  (*get_salt_size)(void);
hash_stat detect_plugin(char *plugindir, char *file, char *hash);

/* plugin summary functions */
hash_stat print_plugins_summary(char *plugindir);
void print_plugin_detailed(char *plugin);

/* current plugin get/set/load */
char *get_current_plugin(void);
void set_current_plugin(const char *pluginname);
hash_stat load_plugin(void);


#endif
