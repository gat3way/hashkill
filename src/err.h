/* err.h
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


#ifndef ERR_H
#define ERR_H


/* Status codes enumeration */
typedef enum hash_stat_e
{
    hash_ok = 0,
    hash_err = 1,
} hash_stat;


/* error/stdout logging macros */
#define EWHERESTR  "\033[1;31m[hashkill]\033[0m (%s:%d) "
#define EWHEREARG  __FILE__, __LINE__
#define elogerr(...)     fprintf(stderr, __VA_ARGS__)
#define elog(_fmt, ...)  elogerr(EWHERESTR _fmt, EWHEREARG, __VA_ARGS__)


#define WWHERESTR  "\033[1;33m[hashkill]\033[0m "
#define wlogwarn(...)     fprintf(stderr, __VA_ARGS__)
#define wlog(_fmt, ...)  wlogwarn(WWHERESTR _fmt, __VA_ARGS__)


#define HWHERESTR  "\033[1m[hashkill]\033[0m "
#define hlogstd(...)     fprintf(stderr, __VA_ARGS__)
#define hlog(_fmt, ...)  hlogstd(HWHERESTR _fmt,  __VA_ARGS__)



#endif
