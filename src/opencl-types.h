/* opencl-types.h
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

#ifndef HASHOPENCLTYPES_H
#define HASHOPENCLTYPES_H

#include <stdint.h>


#if (defined (_WIN32) && defined(_MSC_VER))

/* scalar types  */
typedef signed   __int8         cl_char;
typedef unsigned __int8         cl_uchar;
typedef signed   __int16        cl_short;
typedef unsigned __int16        cl_ushort;
typedef signed   __int32        cl_int;
typedef unsigned __int32        cl_uint;
typedef signed   __int64        cl_long;
typedef unsigned __int64        cl_ulong;
typedef unsigned __int16        cl_half;
#else /* !_WIN32 */
typedef int8_t    cl_char;
typedef uint8_t   cl_uchar;
typedef int16_t   cl_short;
typedef uint16_t  cl_ushort;
typedef int32_t   cl_int;
typedef uint32_t  cl_uint;
typedef int64_t   cl_long;
typedef uint64_t  cl_ulong;
typedef uint16_t  cl_half;
#endif /* !_WIN32 */
typedef float                   cl_float;
typedef double                  cl_double;

#if defined( __SSE__ )
    #if defined( __MINGW64__ )
        #include <intrin.h>
    #else
        #include <xmmintrin.h>
    #endif
    #if defined( __GNUC__ ) && !defined( __ICC )
        typedef float __cl_float4   __attribute__((vector_size(16)));
    #else
        typedef __m128 __cl_float4;
    #endif
    #define __CL_FLOAT4__   1
#endif

#if defined( __SSE2__ )
    #if defined( __MINGW64__ )
        #include <intrin.h>
    #else
        #include <emmintrin.h>
    #endif
    #if defined( __GNUC__ ) && !defined( __ICC )
        typedef cl_uchar    __cl_uchar16    __attribute__((vector_size(16)));
        typedef cl_char     __cl_char16     __attribute__((vector_size(16)));
        typedef cl_ushort   __cl_ushort8    __attribute__((vector_size(16)));
        typedef cl_short    __cl_short8     __attribute__((vector_size(16)));
        typedef cl_uint     __cl_uint4      __attribute__((vector_size(16)));
        typedef cl_int      __cl_int4       __attribute__((vector_size(16)));
        typedef cl_ulong    __cl_ulong2     __attribute__((vector_size(16)));
        typedef cl_long     __cl_long2      __attribute__((vector_size(16)));
        typedef cl_double   __cl_double2    __attribute__((vector_size(16)));
    #else
        typedef __m128i __cl_uchar16;
        typedef __m128i __cl_char16;
        typedef __m128i __cl_ushort8;
        typedef __m128i __cl_short8;
        typedef __m128i __cl_uint4;
        typedef __m128i __cl_int4;
        typedef __m128i __cl_ulong2;
        typedef __m128i __cl_long2;
        typedef __m128d __cl_double2;
    #endif
    #define __CL_UCHAR16__  1
    #define __CL_CHAR16__   1
    #define __CL_USHORT8__  1
    #define __CL_SHORT8__   1
    #define __CL_INT4__     1
    #define __CL_UINT4__    1
    #define __CL_ULONG2__   1
    #define __CL_LONG2__    1
    #define __CL_DOUBLE2__  1
#endif
#if defined( __AVX__ )
    #if defined( __MINGW64__ )
        #include <intrin.h>
    #else
        #include <immintrin.h> 
    #endif
    #if defined( __GNUC__ ) && !defined( __ICC )
        typedef cl_float    __cl_float8     __attribute__((vector_size(32)));
        typedef cl_double   __cl_double4    __attribute__((vector_size(32)));
    #else
        typedef __m256      __cl_float8;
        typedef __m256d     __cl_double4;
    #endif
    #define __CL_FLOAT8__   1
    #define __CL_DOUBLE4__  1
#endif

/* Define alignment keys */
#if (defined( __GNUC__ ) || defined( __IBMC__ ))
    #define CL_ALIGNED(_x)          __attribute__ ((aligned(_x)))
#elif defined( _WIN32) && (_MSC_VER)
    /* Alignment keys neutered on windows because MSVC can't swallow function arguments with alignment requirements     */
    /* http://msdn.microsoft.com/en-us/library/373ak2y1%28VS.71%29.aspx                                                 */
    /* #include <crtdefs.h>                                                                                             */
    /* #define CL_ALIGNED(_x)          _CRT_ALIGN(_x)                                                                   */
    #define CL_ALIGNED(_x)
#else
   #warning  Need to implement some method to align data here
   #define  CL_ALIGNED(_x)
#endif

/* Indicate whether .xyzw, .s0123 and .hi.lo are supported */
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
    /* .xyzw and .s0123...{f|F} are supported */
    #define CL_HAS_NAMED_VECTOR_FIELDS 1
    /* .hi and .lo are supported */
    #define CL_HAS_HI_LO_VECTOR_FIELDS 1
#endif
typedef union
{
    cl_char  CL_ALIGNED(2) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_char  x, y; };
   __extension__ struct{ cl_char  s0, s1; };
   __extension__ struct{ cl_char  lo, hi; };
#endif
#if defined( __CL_CHAR2__) 
    __cl_char2     v2;
#endif
}cl_char2;

typedef union
{
    cl_char  CL_ALIGNED(4) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_char  x, y, z, w; };
   __extension__ struct{ cl_char  s0, s1, s2, s3; };
   __extension__ struct{ cl_char2 lo, hi; };
#endif
#if defined( __CL_CHAR2__) 
    __cl_char2     v2[2];
#endif
#if defined( __CL_CHAR4__) 
    __cl_char4     v4;
#endif
}cl_char4;
typedef  cl_char4  cl_char3;

typedef union
{
    cl_char   CL_ALIGNED(8) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_char  x, y, z, w; };
   __extension__ struct{ cl_char  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_char4 lo, hi; };
#endif
#if defined( __CL_CHAR2__) 
    __cl_char2     v2[4];
#endif
#if defined( __CL_CHAR4__) 
    __cl_char4     v4[2];
#endif
#if defined( __CL_CHAR8__ )
    __cl_char8     v8;
#endif
}cl_char8;
typedef union
{
    cl_char  CL_ALIGNED(16) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_char  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_char  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_char8 lo, hi; };
#endif
#if defined( __CL_CHAR2__) 
    __cl_char2     v2[8];
#endif
#if defined( __CL_CHAR4__) 
    __cl_char4     v4[4];
#endif
#if defined( __CL_CHAR8__ )
    __cl_char8     v8[2];
#endif
#if defined( __CL_CHAR16__ )
    __cl_char16    v16;
#endif
}cl_char16;
typedef union
{
    cl_uchar  CL_ALIGNED(2) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uchar  x, y; };
   __extension__ struct{ cl_uchar  s0, s1; };
   __extension__ struct{ cl_uchar  lo, hi; };
#endif
#if defined( __cl_uchar2__) 
    __cl_uchar2     v2;
#endif
}cl_uchar2;

typedef union
{
    cl_uchar  CL_ALIGNED(4) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uchar  x, y, z, w; };
   __extension__ struct{ cl_uchar  s0, s1, s2, s3; };
   __extension__ struct{ cl_uchar2 lo, hi; };
#endif
#if defined( __CL_UCHAR2__) 
    __cl_uchar2     v2[2];
#endif
#if defined( __CL_UCHAR4__) 
    __cl_uchar4     v4;
#endif
}cl_uchar4;

/* cl_uchar3 is identical in size, alignment and behavior to cl_uchar4. See section 6.1.5. */
typedef  cl_uchar4  cl_uchar3;
typedef union
{
    cl_uchar   CL_ALIGNED(8) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uchar  x, y, z, w; };
   __extension__ struct{ cl_uchar  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_uchar4 lo, hi; };
#endif
#if defined( __CL_UCHAR2__) 
    __cl_uchar2     v2[4];
#endif
#if defined( __CL_UCHAR4__) 
    __cl_uchar4     v4[2];
#endif
#if defined( __CL_UCHAR8__ )
    __cl_uchar8     v8;
#endif
}cl_uchar8;
typedef union
{
    cl_uchar  CL_ALIGNED(16) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uchar  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_uchar  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_uchar8 lo, hi; };
#endif
#if defined( __CL_UCHAR2__) 
    __cl_uchar2     v2[8];
#endif
#if defined( __CL_UCHAR4__) 
    __cl_uchar4     v4[4];
#endif
#if defined( __CL_UCHAR8__ )
    __cl_uchar8     v8[2];
#endif
#if defined( __CL_UCHAR16__ )
    __cl_uchar16    v16;
#endif
}cl_uchar16;
typedef union
{
    cl_short  CL_ALIGNED(4) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_short  x, y; };
   __extension__ struct{ cl_short  s0, s1; };
   __extension__ struct{ cl_short  lo, hi; };
#endif
#if defined( __CL_SHORT2__) 
    __cl_short2     v2;
#endif
}cl_short2;

typedef union
{
    cl_short  CL_ALIGNED(8) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_short  x, y, z, w; };
   __extension__ struct{ cl_short  s0, s1, s2, s3; };
   __extension__ struct{ cl_short2 lo, hi; };
#endif
#if defined( __CL_SHORT2__) 
    __cl_short2     v2[2];
#endif
#if defined( __CL_SHORT4__) 
    __cl_short4     v4;
#endif
}cl_short4;

/* cl_short3 is identical in size, alignment and behavior to cl_short4. See section 6.1.5. */
typedef  cl_short4  cl_short3;

typedef union
{
    cl_short   CL_ALIGNED(16) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_short  x, y, z, w; };
   __extension__ struct{ cl_short  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_short4 lo, hi; };
#endif
#if defined( __CL_SHORT2__) 
    __cl_short2     v2[4];
#endif
#if defined( __CL_SHORT4__) 
    __cl_short4     v4[2];
#endif
#if defined( __CL_SHORT8__ )
    __cl_short8     v8;
#endif
}cl_short8;

typedef union
{
    cl_short  CL_ALIGNED(32) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_short  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_short  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_short8 lo, hi; };
#endif
#if defined( __CL_SHORT2__) 
    __cl_short2     v2[8];
#endif
#if defined( __CL_SHORT4__) 
    __cl_short4     v4[4];
#endif
#if defined( __CL_SHORT8__ )
    __cl_short8     v8[2];
#endif
#if defined( __CL_SHORT16__ )
    __cl_short16    v16;
#endif
}cl_short16;


/* ---- cl_ushortn ---- */
typedef union
{
    cl_ushort  CL_ALIGNED(4) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ushort  x, y; };
   __extension__ struct{ cl_ushort  s0, s1; };
   __extension__ struct{ cl_ushort  lo, hi; };
#endif
#if defined( __CL_USHORT2__) 
    __cl_ushort2     v2;
#endif
}cl_ushort2;

typedef union
{
    cl_ushort  CL_ALIGNED(8) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ushort  x, y, z, w; };
   __extension__ struct{ cl_ushort  s0, s1, s2, s3; };
   __extension__ struct{ cl_ushort2 lo, hi; };
#endif
#if defined( __CL_USHORT2__) 
    __cl_ushort2     v2[2];
#endif
#if defined( __CL_USHORT4__) 
    __cl_ushort4     v4;
#endif
}cl_ushort4;

/* cl_ushort3 is identical in size, alignment and behavior to cl_ushort4. See section 6.1.5. */
typedef  cl_ushort4  cl_ushort3;

typedef union
{
    cl_ushort   CL_ALIGNED(16) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ushort  x, y, z, w; };
   __extension__ struct{ cl_ushort  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_ushort4 lo, hi; };
#endif
#if defined( __CL_USHORT2__) 
    __cl_ushort2     v2[4];
#endif
#if defined( __CL_USHORT4__) 
    __cl_ushort4     v4[2];
#endif
#if defined( __CL_USHORT8__ )
    __cl_ushort8     v8;
#endif
}cl_ushort8;

typedef union
{
    cl_ushort  CL_ALIGNED(32) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ushort  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_ushort  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_ushort8 lo, hi; };
#endif
#if defined( __CL_USHORT2__) 
    __cl_ushort2     v2[8];
#endif
#if defined( __CL_USHORT4__) 
    __cl_ushort4     v4[4];
#endif
#if defined( __CL_USHORT8__ )
    __cl_ushort8     v8[2];
#endif
#if defined( __CL_USHORT16__ )
    __cl_ushort16    v16;
#endif
}cl_ushort16;

/* ---- cl_intn ---- */
typedef union
{
    cl_int  CL_ALIGNED(8) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_int  x, y; };
   __extension__ struct{ cl_int  s0, s1; };
   __extension__ struct{ cl_int  lo, hi; };
#endif
#if defined( __CL_INT2__) 
    __cl_int2     v2;
#endif
}cl_int2;


typedef union
{
    cl_int  CL_ALIGNED(16) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_int  x, y, z, w; };
   __extension__ struct{ cl_int  s0, s1, s2, s3; };
   __extension__ struct{ cl_int2 lo, hi; };
#endif
#if defined( __CL_INT2__) 
    __cl_int2     v2[2];
#endif
#if defined( __CL_INT4__) 
    __cl_int4     v4;
#endif
}cl_int4;

/* cl_int3 is identical in size, alignment and behavior to cl_int4. See section 6.1.5. */
typedef  cl_int4  cl_int3;

typedef union
{
    cl_int   CL_ALIGNED(32) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_int  x, y, z, w; };
   __extension__ struct{ cl_int  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_int4 lo, hi; };
#endif
#if defined( __CL_INT2__) 
    __cl_int2     v2[4];
#endif
#if defined( __CL_INT4__) 
    __cl_int4     v4[2];
#endif
#if defined( __CL_INT8__ )
    __cl_int8     v8;
#endif
}cl_int8;

typedef union
{
    cl_int  CL_ALIGNED(64) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_int  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_int  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_int8 lo, hi; };
#endif
#if defined( __CL_INT2__) 
    __cl_int2     v2[8];
#endif
#if defined( __CL_INT4__) 
    __cl_int4     v4[4];
#endif
#if defined( __CL_INT8__ )
    __cl_int8     v8[2];
#endif
#if defined( __CL_INT16__ )
    __cl_int16    v16;
#endif
}cl_int16;

typedef union
{
    cl_uint  CL_ALIGNED(8) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uint  x, y; };
   __extension__ struct{ cl_uint  s0, s1; };
   __extension__ struct{ cl_uint  lo, hi; };
#endif
#if defined( __CL_UINT2__) 
    __cl_uint2     v2;
#endif
}cl_uint2;

typedef union
{
    cl_uint  CL_ALIGNED(16) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uint  x, y, z, w; };
   __extension__ struct{ cl_uint  s0, s1, s2, s3; };
   __extension__ struct{ cl_uint2 lo, hi; };
#endif
#if defined( __CL_UINT2__) 
    __cl_uint2     v2[2];
#endif
#if defined( __CL_UINT4__) 
    __cl_uint4     v4;
#endif
}cl_uint4;

/* cl_uint3 is identical in size, alignment and behavior to cl_uint4. See section 6.1.5. */
typedef  cl_uint4  cl_uint3;

typedef union
{
    cl_uint   CL_ALIGNED(32) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uint  x, y, z, w; };
   __extension__ struct{ cl_uint  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_uint4 lo, hi; };
#endif
#if defined( __CL_UINT2__) 
    __cl_uint2     v2[4];
#endif
#if defined( __CL_UINT4__) 
    __cl_uint4     v4[2];
#endif
#if defined( __CL_UINT8__ )
    __cl_uint8     v8;
#endif
}cl_uint8;

typedef union
{
    cl_uint  CL_ALIGNED(64) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_uint  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_uint  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_uint8 lo, hi; };
#endif
#if defined( __CL_UINT2__) 
    __cl_uint2     v2[8];
#endif
#if defined( __CL_UINT4__) 
    __cl_uint4     v4[4];
#endif
#if defined( __CL_UINT8__ )
    __cl_uint8     v8[2];
#endif
#if defined( __CL_UINT16__ )
    __cl_uint16    v16;
#endif
}cl_uint16;


/* ---- cl_longn ---- */
typedef union
{
    cl_long  CL_ALIGNED(16) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_long  x, y; };
   __extension__ struct{ cl_long  s0, s1; };
   __extension__ struct{ cl_long  lo, hi; };
#endif
#if defined( __CL_LONG2__) 
    __cl_long2     v2;
#endif
}cl_long2;

typedef union
{
    cl_long  CL_ALIGNED(32) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_long  x, y, z, w; };
   __extension__ struct{ cl_long  s0, s1, s2, s3; };
   __extension__ struct{ cl_long2 lo, hi; };
#endif
#if defined( __CL_LONG2__) 
    __cl_long2     v2[2];
#endif
#if defined( __CL_LONG4__) 
    __cl_long4     v4;
#endif
}cl_long4;

/* cl_long3 is identical in size, alignment and behavior to cl_long4. See section 6.1.5. */
typedef  cl_long4  cl_long3;

typedef union
{
    cl_long   CL_ALIGNED(64) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_long  x, y, z, w; };
   __extension__ struct{ cl_long  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_long4 lo, hi; };
#endif
#if defined( __CL_LONG2__) 
    __cl_long2     v2[4];
#endif
#if defined( __CL_LONG4__) 
    __cl_long4     v4[2];
#endif
#if defined( __CL_LONG8__ )
    __cl_long8     v8;
#endif
}cl_long8;

typedef union
{
    cl_long  CL_ALIGNED(128) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_long  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_long  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_long8 lo, hi; };
#endif
#if defined( __CL_LONG2__) 
    __cl_long2     v2[8];
#endif
#if defined( __CL_LONG4__) 
    __cl_long4     v4[4];
#endif
#if defined( __CL_LONG8__ )
    __cl_long8     v8[2];
#endif
#if defined( __CL_LONG16__ )
    __cl_long16    v16;
#endif
}cl_long16;


typedef union
{
    cl_ulong  CL_ALIGNED(16) s[2];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ulong  x, y; };
   __extension__ struct{ cl_ulong  s0, s1; };
   __extension__ struct{ cl_ulong  lo, hi; };
#endif
#if defined( __CL_ULONG2__) 
    __cl_ulong2     v2;
#endif
}cl_ulong2;

typedef union
{
    cl_ulong  CL_ALIGNED(32) s[4];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ulong  x, y, z, w; };
   __extension__ struct{ cl_ulong  s0, s1, s2, s3; };
   __extension__ struct{ cl_ulong2 lo, hi; };
#endif
#if defined( __CL_ULONG2__) 
    __cl_ulong2     v2[2];
#endif
#if defined( __CL_ULONG4__) 
    __cl_ulong4     v4;
#endif
}cl_ulong4;

/* cl_ulong3 is identical in size, alignment and behavior to cl_ulong4. See section 6.1.5. */
typedef  cl_ulong4  cl_ulong3;


typedef union
{
    cl_ulong   CL_ALIGNED(64) s[8];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ulong  x, y, z, w; };
   __extension__ struct{ cl_ulong  s0, s1, s2, s3, s4, s5, s6, s7; };
   __extension__ struct{ cl_ulong4 lo, hi; };
#endif
#if defined( __CL_ULONG2__) 
    __cl_ulong2     v2[4];
#endif
#if defined( __CL_ULONG4__) 
    __cl_ulong4     v4[2];
#endif
#if defined( __CL_ULONG8__ )
    __cl_ulong8     v8;
#endif
}cl_ulong8;

typedef union
{
    cl_ulong  CL_ALIGNED(128) s[16];
#if (defined( __GNUC__) ||  defined( __IBMC__ )) && ! defined( __STRICT_ANSI__ )
   __extension__ struct{ cl_ulong  x, y, z, w, __spacer4, __spacer5, __spacer6, __spacer7, __spacer8, __spacer9, sa, sb, sc, sd, se, sf; };
   __extension__ struct{ cl_ulong  s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, sA, sB, sC, sD, sE, sF; };
   __extension__ struct{ cl_ulong8 lo, hi; };
#endif
#if defined( __CL_ULONG2__) 
    __cl_ulong2     v2[8];
#endif
#if defined( __CL_ULONG4__) 
    __cl_ulong4     v4[4];
#endif
#if defined( __CL_ULONG8__ )
    __cl_ulong8     v8[2];
#endif
#if defined( __CL_ULONG16__ )
    __cl_ulong16    v16;
#endif
}cl_ulong16;


typedef struct _cl_platform_id *    cl_platform_id;
typedef struct _cl_device_id *      cl_device_id;
typedef struct _cl_context *        cl_context;
typedef struct _cl_command_queue *  cl_command_queue;
typedef struct _cl_mem *            cl_mem;
typedef struct _cl_program *        cl_program;
typedef struct _cl_kernel *         cl_kernel;
typedef struct _cl_event *          cl_event;

typedef cl_uint             cl_bool;                     /* WARNING!  Unlike cl_ types in cl_platform.h, cl_bool is not guaranteed to be the same size as the bool in kernels. */ 
typedef cl_ulong            cl_bitfield;
typedef cl_bitfield         cl_device_type;
typedef cl_uint             cl_platform_info;
typedef cl_uint             cl_device_info;
typedef cl_bitfield         cl_device_fp_config;
typedef cl_uint             cl_device_mem_cache_type;
typedef cl_uint             cl_device_local_mem_type;
typedef cl_bitfield         cl_device_exec_capabilities;
typedef cl_bitfield         cl_command_queue_properties;
typedef intptr_t            cl_device_partition_property;
typedef cl_bitfield         cl_device_affinity_domain;
typedef intptr_t            cl_context_properties;
typedef cl_uint             cl_context_info;
typedef cl_uint             cl_command_queue_info;
typedef cl_uint             cl_channel_order;
typedef cl_uint             cl_channel_type;
typedef cl_bitfield         cl_mem_flags;
typedef cl_uint             cl_mem_object_type;
typedef cl_uint             cl_mem_info;
typedef cl_bitfield         cl_mem_migration_flags;
typedef cl_uint             cl_image_info;
typedef cl_uint             cl_buffer_create_type;
typedef cl_uint             cl_addressing_mode;
typedef cl_uint             cl_filter_mode;
typedef cl_uint             cl_sampler_info;
typedef cl_bitfield         cl_map_flags;
typedef cl_uint             cl_program_info;
typedef cl_uint             cl_program_build_info;
typedef cl_uint             cl_program_binary_type;
typedef cl_int              cl_build_status;
typedef cl_uint             cl_kernel_info;
typedef cl_uint             cl_kernel_arg_info;
typedef cl_uint             cl_kernel_arg_address_qualifier;
typedef cl_uint             cl_kernel_arg_access_qualifier;
typedef cl_bitfield         cl_kernel_arg_type_qualifier;
typedef cl_uint             cl_kernel_work_group_info;
typedef cl_uint             cl_event_info;
typedef cl_uint             cl_command_type;
typedef cl_uint             cl_profiling_info;


#define CL_SUCCESS                                  0
#define CL_DEVICE_NOT_FOUND                         -1
#define CL_DEVICE_NOT_AVAILABLE                     -2
#define CL_COMPILER_NOT_AVAILABLE                   -3
#define CL_MEM_OBJECT_ALLOCATION_FAILURE            -4
#define CL_OUT_OF_RESOURCES                         -5
#define CL_OUT_OF_HOST_MEMORY                       -6
#define CL_PROFILING_INFO_NOT_AVAILABLE             -7
#define CL_MEM_COPY_OVERLAP                         -8
#define CL_IMAGE_FORMAT_MISMATCH                    -9
#define CL_IMAGE_FORMAT_NOT_SUPPORTED               -10
#define CL_BUILD_PROGRAM_FAILURE                    -11
#define CL_MAP_FAILURE                              -12
#define CL_MISALIGNED_SUB_BUFFER_OFFSET             -13
#define CL_EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST -14
#define CL_COMPILE_PROGRAM_FAILURE                  -15
#define CL_LINKER_NOT_AVAILABLE                     -16
#define CL_LINK_PROGRAM_FAILURE                     -17
#define CL_DEVICE_PARTITION_FAILED                  -18
#define CL_KERNEL_ARG_INFO_NOT_AVAILABLE            -19

#define CL_INVALID_VALUE                            -30
#define CL_INVALID_DEVICE_TYPE                      -31
#define CL_INVALID_PLATFORM                         -32
#define CL_INVALID_DEVICE                           -33
#define CL_INVALID_CONTEXT                          -34
#define CL_INVALID_QUEUE_PROPERTIES                 -35
#define CL_INVALID_COMMAND_QUEUE                    -36
#define CL_INVALID_HOST_PTR                         -37
#define CL_INVALID_MEM_OBJECT                       -38
#define CL_INVALID_IMAGE_FORMAT_DESCRIPTOR          -39
#define CL_INVALID_IMAGE_SIZE                       -40
#define CL_INVALID_SAMPLER                          -41
#define CL_INVALID_BINARY                           -42
#define CL_INVALID_BUILD_OPTIONS                    -43
#define CL_INVALID_PROGRAM                          -44
#define CL_INVALID_PROGRAM_EXECUTABLE               -45
#define CL_INVALID_KERNEL_NAME                      -46
#define CL_INVALID_KERNEL_DEFINITION                -47
#define CL_INVALID_KERNEL                           -48
#define CL_INVALID_ARG_INDEX                        -49
#define CL_INVALID_ARG_VALUE                        -50
#define CL_INVALID_ARG_SIZE                         -51
#define CL_INVALID_KERNEL_ARGS                      -52
#define CL_INVALID_WORK_DIMENSION                   -53
#define CL_INVALID_WORK_GROUP_SIZE                  -54
#define CL_INVALID_WORK_ITEM_SIZE                   -55
#define CL_INVALID_GLOBAL_OFFSET                    -56
#define CL_INVALID_EVENT_WAIT_LIST                  -57
#define CL_INVALID_EVENT                            -58
#define CL_INVALID_OPERATION                        -59
#define CL_INVALID_GL_OBJECT                        -60
#define CL_INVALID_BUFFER_SIZE                      -61
#define CL_INVALID_MIP_LEVEL                        -62
#define CL_INVALID_GLOBAL_WORK_SIZE                 -63
#define CL_INVALID_PROPERTY                         -64
#define CL_INVALID_IMAGE_DESCRIPTOR                 -65
#define CL_INVALID_COMPILER_OPTIONS                 -66
#define CL_INVALID_LINKER_OPTIONS                   -67
#define CL_INVALID_DEVICE_PARTITION_COUNT           -68
#define CL_PLATFORM_NOT_FOUND_KHR                   -1001

/* cl_bool */
#define CL_FALSE                                    0
#define CL_TRUE                                     1
#define CL_BLOCKING                                 CL_TRUE
#define CL_NON_BLOCKING                             CL_FALSE

/* cl_platform_info */
#define CL_PLATFORM_PROFILE                         0x0900
#define CL_PLATFORM_VERSION                         0x0901
#define CL_PLATFORM_NAME                            0x0902
#define CL_PLATFORM_VENDOR                          0x0903
#define CL_PLATFORM_EXTENSIONS                      0x0904

/* cl_device_type - bitfield */
#define CL_DEVICE_TYPE_DEFAULT                      (1 << 0)
#define CL_DEVICE_TYPE_CPU                          (1 << 1)
#define CL_DEVICE_TYPE_GPU                          (1 << 2)
#define CL_DEVICE_TYPE_ACCELERATOR                  (1 << 3)
#define CL_DEVICE_TYPE_CUSTOM                       (1 << 4)
#define CL_DEVICE_TYPE_ALL                          0xFFFFFFFF


/* cl_device_info */
#define CL_DEVICE_TYPE                              0x1000
#define CL_DEVICE_VENDOR_ID                         0x1001
#define CL_DEVICE_MAX_COMPUTE_UNITS                 0x1002
#define CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS          0x1003
#define CL_DEVICE_MAX_WORK_GROUP_SIZE               0x1004
#define CL_DEVICE_MAX_WORK_ITEM_SIZES               0x1005
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       0x1006
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      0x1007
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT        0x1008
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG       0x1009
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      0x100A
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     0x100B
#define CL_DEVICE_MAX_CLOCK_FREQUENCY               0x100C
#define CL_DEVICE_ADDRESS_BITS                      0x100D
#define CL_DEVICE_MAX_READ_IMAGE_ARGS               0x100E
#define CL_DEVICE_MAX_WRITE_IMAGE_ARGS              0x100F
#define CL_DEVICE_MAX_MEM_ALLOC_SIZE                0x1010
#define CL_DEVICE_IMAGE2D_MAX_WIDTH                 0x1011
#define CL_DEVICE_IMAGE2D_MAX_HEIGHT                0x1012
#define CL_DEVICE_IMAGE3D_MAX_WIDTH                 0x1013
#define CL_DEVICE_IMAGE3D_MAX_HEIGHT                0x1014
#define CL_DEVICE_IMAGE3D_MAX_DEPTH                 0x1015
#define CL_DEVICE_IMAGE_SUPPORT                     0x1016
#define CL_DEVICE_MAX_PARAMETER_SIZE                0x1017
#define CL_DEVICE_MAX_SAMPLERS                      0x1018
#define CL_DEVICE_MEM_BASE_ADDR_ALIGN               0x1019
#define CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          0x101A
#define CL_DEVICE_SINGLE_FP_CONFIG                  0x101B
#define CL_DEVICE_GLOBAL_MEM_CACHE_TYPE             0x101C
#define CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE         0x101D
#define CL_DEVICE_GLOBAL_MEM_CACHE_SIZE             0x101E
#define CL_DEVICE_GLOBAL_MEM_SIZE                   0x101F
#define CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE          0x1020
#define CL_DEVICE_MAX_CONSTANT_ARGS                 0x1021
#define CL_DEVICE_LOCAL_MEM_TYPE                    0x1022
#define CL_DEVICE_LOCAL_MEM_SIZE                    0x1023
#define CL_DEVICE_ERROR_CORRECTION_SUPPORT          0x1024
#define CL_DEVICE_PROFILING_TIMER_RESOLUTION        0x1025
#define CL_DEVICE_ENDIAN_LITTLE                     0x1026
#define CL_DEVICE_AVAILABLE                         0x1027
#define CL_DEVICE_COMPILER_AVAILABLE                0x1028
#define CL_DEVICE_EXECUTION_CAPABILITIES            0x1029
#define CL_DEVICE_QUEUE_PROPERTIES                  0x102A
#define CL_DEVICE_NAME                              0x102B
#define CL_DEVICE_VENDOR                            0x102C
#define CL_DRIVER_VERSION                           0x102D
#define CL_DEVICE_PROFILE                           0x102E
#define CL_DEVICE_VERSION                           0x102F
#define CL_DEVICE_EXTENSIONS                        0x1030
#define CL_DEVICE_PLATFORM                          0x1031
#define CL_DEVICE_DOUBLE_FP_CONFIG                  0x1032
/* 0x1033 reserved for CL_DEVICE_HALF_FP_CONFIG */
#define CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF       0x1034
#define CL_DEVICE_HOST_UNIFIED_MEMORY               0x1035
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR          0x1036
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT         0x1037
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_INT           0x1038
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG          0x1039
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT         0x103A
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE        0x103B
#define CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF          0x103C
#define CL_DEVICE_OPENCL_C_VERSION                  0x103D
#define CL_DEVICE_LINKER_AVAILABLE                  0x103E
#define CL_DEVICE_BUILT_IN_KERNELS                  0x103F
#define CL_DEVICE_IMAGE_MAX_BUFFER_SIZE             0x1040
#define CL_DEVICE_IMAGE_MAX_ARRAY_SIZE              0x1041
#define CL_DEVICE_PARENT_DEVICE                     0x1042
#define CL_DEVICE_PARTITION_MAX_SUB_DEVICES         0x1043
#define CL_DEVICE_PARTITION_PROPERTIES              0x1044
#define CL_DEVICE_PARTITION_AFFINITY_DOMAIN         0x1045
#define CL_DEVICE_PARTITION_TYPE                    0x1046
#define CL_DEVICE_REFERENCE_COUNT                   0x1047
#define CL_DEVICE_PREFERRED_INTEROP_USER_SYNC       0x1048
#define CL_DEVICE_PRINTF_BUFFER_SIZE                0x1049

#define CL_CONTEXT_REFERENCE_COUNT                  0x1080
#define CL_CONTEXT_DEVICES                          0x1081
#define CL_CONTEXT_PROPERTIES                       0x1082
#define CL_CONTEXT_NUM_DEVICES                      0x1083

#define CL_QUEUE_CONTEXT                            0x1090
#define CL_QUEUE_DEVICE                             0x1091
#define CL_QUEUE_REFERENCE_COUNT                    0x1092
#define CL_QUEUE_PROPERTIES                         0x1093

#define CL_MEM_READ_WRITE                           (1 << 0)
#define CL_MEM_WRITE_ONLY                           (1 << 1)
#define CL_MEM_READ_ONLY                            (1 << 2)
#define CL_MEM_USE_HOST_PTR                         (1 << 3)
#define CL_MEM_ALLOC_HOST_PTR                       (1 << 4)
#define CL_MEM_COPY_HOST_PTR                        (1 << 5)
// reserved                                         (1 << 6)    
#define CL_MEM_HOST_WRITE_ONLY                      (1 << 7)
#define CL_MEM_HOST_READ_ONLY                       (1 << 8)
#define CL_MEM_HOST_NO_ACCESS                       (1 << 9)

#define CL_MAP_READ                                 (1 << 0)
#define CL_MAP_WRITE                                (1 << 1)
#define CL_MAP_WRITE_INVALIDATE_REGION              (1 << 2)

/* cl_program_info */
#define CL_PROGRAM_REFERENCE_COUNT                  0x1160
#define CL_PROGRAM_CONTEXT                          0x1161
#define CL_PROGRAM_NUM_DEVICES                      0x1162
#define CL_PROGRAM_DEVICES                          0x1163
#define CL_PROGRAM_SOURCE                           0x1164
#define CL_PROGRAM_BINARY_SIZES                     0x1165
#define CL_PROGRAM_BINARIES                         0x1166
#define CL_PROGRAM_NUM_KERNELS                      0x1167
#define CL_PROGRAM_KERNEL_NAMES                     0x1168

/* cl_program_build_info */
#define CL_PROGRAM_BUILD_STATUS                     0x1181
#define CL_PROGRAM_BUILD_OPTIONS                    0x1182
#define CL_PROGRAM_BUILD_LOG                        0x1183
#define CL_PROGRAM_BINARY_TYPE                      0x1184
    
/* cl_program_binary_type */
#define CL_PROGRAM_BINARY_TYPE_NONE                 0x0
#define CL_PROGRAM_BINARY_TYPE_COMPILED_OBJECT      0x1
#define CL_PROGRAM_BINARY_TYPE_LIBRARY              0x2
#define CL_PROGRAM_BINARY_TYPE_EXECUTABLE           0x4

/* cl_build_status */
#define CL_BUILD_SUCCESS                            0
#define CL_BUILD_NONE                               -1
#define CL_BUILD_ERROR                              -2
#define CL_BUILD_IN_PROGRESS                        -3

/* cl_kernel_info */
#define CL_KERNEL_FUNCTION_NAME                     0x1190
#define CL_KERNEL_NUM_ARGS                          0x1191
#define CL_KERNEL_REFERENCE_COUNT                   0x1192
#define CL_KERNEL_CONTEXT                           0x1193
#define CL_KERNEL_PROGRAM                           0x1194
#define CL_KERNEL_ATTRIBUTES                        0x1195

/* cl_kernel_arg_info */
#define CL_KERNEL_ARG_ADDRESS_QUALIFIER             0x1196
#define CL_KERNEL_ARG_ACCESS_QUALIFIER              0x1197
#define CL_KERNEL_ARG_TYPE_NAME                     0x1198
#define CL_KERNEL_ARG_TYPE_QUALIFIER                0x1199
#define CL_KERNEL_ARG_NAME                          0x119A

/* cl_kernel_arg_address_qualifier */
#define CL_KERNEL_ARG_ADDRESS_GLOBAL                0x119B
#define CL_KERNEL_ARG_ADDRESS_LOCAL                 0x119C
#define CL_KERNEL_ARG_ADDRESS_CONSTANT              0x119D
#define CL_KERNEL_ARG_ADDRESS_PRIVATE               0x119E

/* cl_kernel_arg_access_qualifier */
#define CL_KERNEL_ARG_ACCESS_READ_ONLY              0x11A0
#define CL_KERNEL_ARG_ACCESS_WRITE_ONLY             0x11A1
#define CL_KERNEL_ARG_ACCESS_READ_WRITE             0x11A2
#define CL_KERNEL_ARG_ACCESS_NONE                   0x11A3

/* cl_kernel_arg_type_qualifer */
#define CL_KERNEL_ARG_TYPE_NONE                     0
#define CL_KERNEL_ARG_TYPE_CONST                    (1 << 0)
#define CL_KERNEL_ARG_TYPE_RESTRICT                 (1 << 1)
#define CL_KERNEL_ARG_TYPE_VOLATILE                 (1 << 2)

/* cl_kernel_work_group_info */
#define CL_KERNEL_WORK_GROUP_SIZE                   0x11B0
#define CL_KERNEL_COMPILE_WORK_GROUP_SIZE           0x11B1
#define CL_KERNEL_LOCAL_MEM_SIZE                    0x11B2
#define CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE 0x11B3
#define CL_KERNEL_PRIVATE_MEM_SIZE                  0x11B4
#define CL_KERNEL_GLOBAL_WORK_SIZE                  0x11B5


#define CL_CONTEXT_PLATFORM                         0x1084






#endif
