#ifndef __COMPILER_H__
#define __COMPILER_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "lzma/lzma.h"
#include "err.h"
#include "ocl-base.h"

extern int bfimagic;
extern int optdisable;
extern int big16;

void checkErr( char * func, cl_int err );
char *readProgramSrc( char * filename );
void usage( void );

#endif
