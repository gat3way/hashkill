/* ocl-amd.h
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


#ifndef OCLADL_H
#define OCLADL_H

#include <stdint.h>
#include "err.h"

pthread_mutex_t tempmutexes[64];

int setup_adl(void); // Returns: 0 - error, 1-amd only 2-nv only 3-both
void do_adl(void);
void adl_getstats(void);

// Nvidia rwlock
pthread_rwlock_t nvtlock;

#define NVLOCK if (ocl_dev_nvidia==1) pthread_rwlock_rdlock(&nvtlock)
#define NVUNLOCK if (ocl_dev_nvidia==1) pthread_rwlock_unlock(&nvtlock)

#endif
