/*
 * des_nonstd_sse2.c
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


/*
 * Generated S-box files.
 *
 * This software may be modified, redistributed, and used for any purpose,
 * so long as its origin is acknowledged.
 *
 * Produced by Matthew Kwan - March 1998
 */

#ifdef HAVE_SSE2

#define	MINUS_1 _mm_set_epi32 (-1,-1,-1,-1)
#include <emmintrin.h>


#define sse_s1(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_andnot_si128 (a5, a3); \
	x2 = _mm_xor_si128 (x1, a4); \
	x3 = _mm_andnot_si128 (a4, a3); \
	x4 = _mm_or_si128 (x3, a5); \
	x5 = _mm_and_si128 (a6, x4); \
	x6 = _mm_xor_si128 (x2, x5); \
	x7 = _mm_andnot_si128 (a5, a4); \
	x8 = _mm_xor_si128 (a3, a4); \
	x9 = _mm_andnot_si128 (x8, a6); \
	x10 = _mm_xor_si128 (x7, x9); \
	x11 = _mm_or_si128 (a2, x10); \
	x12 = _mm_xor_si128 (x6, x11); \
	x13 = _mm_xor_si128 (a5, x5); \
	x14 = _mm_and_si128 (x13, x8); \
	x15 = _mm_andnot_si128 (a4, a5); \
	x16 = _mm_xor_si128 (x3, x14); \
	x17 = _mm_or_si128 (a6, x16); \
	x18 = _mm_xor_si128 (x15, x17); \
	x19 = _mm_or_si128 (a2, x18); \
	x20 = _mm_xor_si128 (x14, x19); \
	x21 = _mm_and_si128 (a1, x20); \
	x22 = _mm_xor_si128 (x12, _mm_andnot_si128 (x21, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x22); \
	x23 = _mm_or_si128 (x1, x5); \
	x24 = _mm_xor_si128 (x23, x8); \
	x25 = _mm_andnot_si128 (x2, x18); \
	x26 = _mm_andnot_si128 (x25, a2); \
	x27 = _mm_xor_si128 (x24, x26); \
	x28 = _mm_or_si128 (x6, x7); \
	x29 = _mm_xor_si128 (x28, x25); \
	x30 = _mm_xor_si128 (x9, x24); \
	x31 = _mm_andnot_si128 (x30, x18); \
	x32 = _mm_and_si128 (a2, x31); \
	x33 = _mm_xor_si128 (x29, x32); \
	x34 = _mm_and_si128 (a1, x33); \
	x35 = _mm_xor_si128 (x27, x34); \
	out4 = _mm_xor_si128 (out4, x35); \
	x36 = _mm_and_si128 (a3, x28); \
	x37 = _mm_andnot_si128 (x36, x18); \
	x38 = _mm_or_si128 (a2, x3); \
	x39 = _mm_xor_si128 (x37, x38); \
	x40 = _mm_or_si128 (a3, x31); \
	x41 = _mm_andnot_si128 (x37, x24); \
	x42 = _mm_or_si128 (x41, x3); \
	x43 = _mm_andnot_si128 (a2, x42); \
	x44 = _mm_xor_si128 (x40, x43); \
	x45 = _mm_andnot_si128 (x44, a1); \
	x46 = _mm_xor_si128 (x39, _mm_andnot_si128 (x45, MINUS_1)); \
	out1 = _mm_xor_si128 (out1, x46); \
	x47 = _mm_andnot_si128 (x9, x33); \
	x48 = _mm_xor_si128 (x47, x39); \
	x49 = _mm_xor_si128 (x4, x36); \
	x50 = _mm_andnot_si128 (x5, x49); \
	x51 = _mm_or_si128 (x42, x18); \
	x52 = _mm_xor_si128 (x51, a5); \
	x53 = _mm_andnot_si128 (x52, a2); \
	x54 = _mm_xor_si128 (x50, x53); \
	x55 = _mm_or_si128 (a1, x54); \
	x56 = _mm_xor_si128 (x48,  _mm_andnot_si128 (x55, MINUS_1)); \
	out3 = _mm_xor_si128 (out3, x56); \
} \


#define sse_s2(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_xor_si128 (a1, a6); \
	x2 = _mm_xor_si128 (x1, a5); \
	x3 = _mm_and_si128 (a6, a5); \
	x4 = _mm_andnot_si128 (x3, a1); \
	x5 = _mm_andnot_si128 (x4, a2); \
	x6 = _mm_xor_si128 (x2, x5); \
	x7 = _mm_or_si128 (x3, x5); \
	x8 = _mm_andnot_si128 (x1, x7); \
	x9 = _mm_or_si128 (a3, x8); \
	x10 = _mm_xor_si128 (x6, x9); \
	x11 = _mm_andnot_si128 (x4, a5); \
	x12 = _mm_or_si128 (x11, a2); \
	x13 = _mm_and_si128 (a4, x12); \
	x14 = _mm_xor_si128 (x10, _mm_andnot_si128 (x13, MINUS_1)); \
	out1 = _mm_xor_si128 (out1, x14); \
	x15 = _mm_xor_si128 (x4, x14); \
	x16 = _mm_andnot_si128 (a2, x15); \
	x17 = _mm_xor_si128 (x2, x16); \
	x18 = _mm_andnot_si128 (x4, a6); \
	x19 = _mm_xor_si128 (x6, x11); \
	x20 = _mm_and_si128 (a2, x19); \
	x21 = _mm_xor_si128 (x18, x20); \
	x22 = _mm_and_si128 (a3, x21); \
	x23 = _mm_xor_si128 (x17, x22); \
	x24 = _mm_xor_si128 (a5, a2); \
	x25 = _mm_andnot_si128 (x8, x24); \
	x26 = _mm_or_si128 (x6, a1); \
	x27 = _mm_xor_si128 (x26, a2); \
	x28 = _mm_andnot_si128 (x27, a3); \
	x29 = _mm_xor_si128 (x25, x28); \
	x30 = _mm_or_si128 (a4, x29); \
	x31 = _mm_xor_si128 (x23, x30); \
	out3 = _mm_xor_si128 (out3, x31); \
	x32 = _mm_or_si128 (x18, x25); \
	x33 = _mm_xor_si128 (x32, x10); \
	x34 = _mm_or_si128 (x27, x20); \
	x35 = _mm_and_si128 (a3, x34); \
	x36 = _mm_xor_si128 (x33, x35); \
	x37 = _mm_and_si128 (x24, x34); \
	x38 = _mm_andnot_si128 (x37, x12); \
	x39 = _mm_or_si128 (a4, x38); \
	x40 = _mm_xor_si128 (x36, _mm_andnot_si128 (x39, MINUS_1)); \
	out4 = _mm_xor_si128 (out4, x40); \
	x41 = _mm_xor_si128 (a2, x2); \
	x42 = _mm_andnot_si128 (x33, x41); \
	x43 = _mm_xor_si128 (x42, x29); \
	x44 = _mm_andnot_si128 (x43, a3); \
	x45 = _mm_xor_si128 (x41, x44); \
	x46 = _mm_or_si128 (x3, x20); \
	x47 = _mm_and_si128 (a3, x3); \
	x48 = _mm_xor_si128 (x46, x47); \
	x49 = _mm_andnot_si128 (x48, a4); \
	x50 = _mm_xor_si128 (x45, _mm_andnot_si128 (x49, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x50); \
}; \


#define sse_s3(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_xor_si128 (a2, a3); \
	x2 = _mm_xor_si128 (x1, a6); \
	x3 = _mm_and_si128 (a2, x2); \
	x4 = _mm_or_si128 (a5, x3); \
	x5 = _mm_xor_si128 (x2, x4); \
	x6 = _mm_xor_si128 (a3, x3); \
	x7 = _mm_andnot_si128 (a5, x6); \
	x8 = _mm_or_si128 (a1, x7); \
	x9 = _mm_xor_si128 (x5, x8); \
	x10 = _mm_andnot_si128 (x3, a6); \
	x11 = _mm_xor_si128 (x10, a5); \
	x12 = _mm_and_si128 (a1, x11); \
	x13 = _mm_xor_si128 (a5, x12); \
	x14 = _mm_or_si128 (a4, x13); \
	x15 = _mm_xor_si128 (x9, x14); \
	out4 = _mm_xor_si128 (out4, x15); \
	x16 = _mm_and_si128 (a3, a6); \
	x17 = _mm_or_si128 (x16, x3); \
	x18 = _mm_xor_si128 (x17, a5); \
	x19 = _mm_andnot_si128 (x7, x2); \
	x20 = _mm_xor_si128 (x19, x16); \
	x21 = _mm_or_si128 (a1, x20); \
	x22 = _mm_xor_si128 (x18, x21); \
	x23 = _mm_or_si128 (a2, x7); \
	x24 = _mm_xor_si128 (x23, x4); \
	x25 = _mm_or_si128 (x11, x19); \
	x26 = _mm_xor_si128 (x25, x17); \
	x27 = _mm_or_si128 (a1, x26); \
	x28 = _mm_xor_si128 (x24, x27); \
	x29 = _mm_andnot_si128 (x28, a4); \
	x30 = _mm_xor_si128 (x22, _mm_andnot_si128 (x29, MINUS_1)); \
	out3 = _mm_xor_si128 (out3, x30); \
	x31 = _mm_and_si128 (a3, a5); \
	x32 = _mm_xor_si128 (x31, x2); \
	x33 = _mm_andnot_si128 (a3, x7); \
	x34 = _mm_or_si128 (a1, x33); \
	x35 = _mm_xor_si128 (x32, x34); \
	x36 = _mm_or_si128 (x10, x26); \
	x37 = _mm_xor_si128 (a6, x17); \
	x38 = _mm_andnot_si128 (x5, x37); \
	x39 = _mm_and_si128 (a1, x38); \
	x40 = _mm_xor_si128 (x36, x39); \
	x41 = _mm_and_si128 (a4, x40); \
	x42 = _mm_xor_si128 (x35, x41); \
	out2 = _mm_xor_si128 (out2, x42); \
	x43 = _mm_or_si128 (a2, x19); \
	x44 = _mm_xor_si128 (x43, x18); \
	x45 = _mm_and_si128 (a6, x15); \
	x46 = _mm_xor_si128 (x45, x6); \
	x47 = _mm_andnot_si128 (a1, x46); \
	x48 = _mm_xor_si128 (x44, x47); \
	x49 = _mm_andnot_si128 (x23, x42); \
	x50 = _mm_or_si128 (a1, x49); \
	x51 = _mm_xor_si128 (x47, x50); \
	x52 = _mm_and_si128 (a4, x51); \
	x53 = _mm_xor_si128 (x48, _mm_andnot_si128 (x52, MINUS_1)); \
	out1 = _mm_xor_si128 (out1, x53); \
}; \


#define sse_s4(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_or_si128 (a1, a3); \
	x2 = _mm_and_si128 (a5, x1); \
	x3 = _mm_xor_si128 (a1, x2); \
	x4 = _mm_or_si128 (a2, a3); \
	x5 = _mm_xor_si128 (x3, x4); \
	x6 = _mm_andnot_si128 (a1, a3); \
	x7 = _mm_or_si128 (x6, x3); \
	x8 = _mm_and_si128 (a2, x7); \
	x9 = _mm_xor_si128 (a5, x8); \
	x10 = _mm_and_si128 (a4, x9); \
	x11 = _mm_xor_si128 (x5, x10); \
	x12 = _mm_xor_si128 (a3, x2); \
	x13 = _mm_andnot_si128 (x12, a2); \
	x14 = _mm_xor_si128 (x7, x13); \
	x15 = _mm_or_si128 (x12, x3); \
	x16 = _mm_xor_si128 (a3, a5); \
	x17 = _mm_andnot_si128 (a2, x16); \
	x18 = _mm_xor_si128 (x15, x17); \
	x19 = _mm_or_si128 (a4, x18); \
	x20 = _mm_xor_si128 (x14, x19); \
	x21 = _mm_or_si128 (a6, x20); \
	x22 = _mm_xor_si128 (x11, x21); \
	out1 = _mm_xor_si128 (out1, x22); \
	x23 = _mm_and_si128 (a6, x20); \
	x24 = _mm_xor_si128 (x23, _mm_andnot_si128 (x11, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x24); \
	x25 = _mm_and_si128 (a2, x9); \
	x26 = _mm_xor_si128 (x25, x15); \
	x27 = _mm_xor_si128 (a3, x8); \
	x28 = _mm_xor_si128 (x27, x17); \
	x29 = _mm_andnot_si128 (x28, a4); \
	x30 = _mm_xor_si128 (x26, x29); \
	x31 = _mm_xor_si128 (x11, x30); \
	x32 = _mm_andnot_si128 (x31, a2); \
	x33 = _mm_xor_si128 (x22, x32); \
	x34 = _mm_andnot_si128 (a4, x31); \
	x35 = _mm_xor_si128 (x33, x34); \
	x36 = _mm_or_si128 (a6, x35); \
	x37 = _mm_xor_si128 (x30, _mm_andnot_si128 (x36, MINUS_1)); \
	out3 = _mm_xor_si128 (out3, x37); \
	x38 = _mm_xor_si128 (x23, x35); \
	x39 = _mm_xor_si128 (x38, x37); \
	out4 = _mm_xor_si128 (out4, x39); \
}; \


 
#define sse_s5(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_andnot_si128 (a4, a3); \
	x2 = _mm_xor_si128 (x1, a1); \
	x3 = _mm_andnot_si128 (a3, a1); \
	x4 = _mm_or_si128 (a6, x3); \
	x5 = _mm_xor_si128 (x2, x4); \
	x6 = _mm_xor_si128 (a4, a1); \
	x7 = _mm_or_si128 (x6, x1); \
	x8 = _mm_andnot_si128 (a6, x7); \
	x9 = _mm_xor_si128 (a3, x8); \
	x10 = _mm_or_si128 (a5, x9); \
	x11 = _mm_xor_si128 (x5, x10); \
	x12 = _mm_and_si128 (a3, x7); \
	x13 = _mm_xor_si128 (x12, a4); \
	x14 = _mm_andnot_si128 (x3, x13); \
	x15 = _mm_xor_si128 (a4, x3); \
	x16 = _mm_or_si128 (a6, x15); \
	x17 = _mm_xor_si128 (x14, x16); \
	x18 = _mm_or_si128 (a5, x17); \
	x19 = _mm_xor_si128 (x13, x18); \
	x20 = _mm_andnot_si128 (a2, x19); \
	x21 = _mm_xor_si128 (x11, x20); \
	out4 = _mm_xor_si128 (out4, x21); \
	x22 = _mm_and_si128 (a4, x4); \
	x23 = _mm_xor_si128 (x22, x17); \
	x24 = _mm_xor_si128 (a1, x9); \
	x25 = _mm_and_si128 (x2, x24); \
	x26 = _mm_andnot_si128 (x25, a5); \
	x27 = _mm_xor_si128 (x23, x26); \
	x28 = _mm_or_si128 (a4, x24); \
	x29 = _mm_andnot_si128 (a2, x28); \
	x30 = _mm_xor_si128 (x27, x29); \
	out2 = _mm_xor_si128 (out2, x30); \
	x31 = _mm_and_si128 (x17, x5); \
	x32 = _mm_andnot_si128 (x31, x7); \
	x33 = _mm_andnot_si128 (a4, x8); \
	x34 = _mm_xor_si128 (x33, a3); \
	x35 = _mm_and_si128 (a5, x34); \
	x36 = _mm_xor_si128 (x32, x35); \
	x37 = _mm_or_si128 (x13, x16); \
	x38 = _mm_xor_si128 (x9, x31); \
	x39 = _mm_or_si128 (a5, x38); \
	x40 = _mm_xor_si128 (x37, x39); \
	x41 = _mm_or_si128 (a2, x40); \
	x42 = _mm_xor_si128 (x36, _mm_andnot_si128 (x41, MINUS_1)); \
	out3 = _mm_xor_si128 (out3, x42); \
	x43 = _mm_andnot_si128 (x32, x19); \
	x44 = _mm_xor_si128 (x43, x24); \
	x45 = _mm_or_si128 (x27, x43); \
	x46 = _mm_xor_si128 (x45, x6); \
	x47 = _mm_andnot_si128 (x46, a5); \
	x48 = _mm_xor_si128 (x44, x47); \
	x49 = _mm_and_si128 (x6, x38); \
	x50 = _mm_xor_si128 (x49, x34); \
	x51 = _mm_xor_si128 (x21, x38); \
	x52 = _mm_andnot_si128 (x51, x28); \
	x53 = _mm_and_si128 (a5, x52); \
	x54 = _mm_xor_si128 (x50, x53); \
	x55 = _mm_or_si128 (a2, x54); \
	x56 = _mm_xor_si128 (x48, x55); \
	out1 = _mm_xor_si128 (out1, x56); \
}; \


#define sse_s6(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_xor_si128 (a5, a1); \
	x2 = _mm_xor_si128 (x1, a6); \
	x3 = _mm_and_si128 (a1, a6); \
	x4 = _mm_andnot_si128 (a5, x3); \
	x5 = _mm_andnot_si128 (x4, a4); \
	x6 = _mm_xor_si128 (x2, x5); \
	x7 = _mm_xor_si128 (a6, x3); \
	x8 = _mm_or_si128 (x4, x7); \
	x9 = _mm_andnot_si128 (a4, x8); \
	x10 = _mm_xor_si128 (x7, x9); \
	x11 = _mm_and_si128 (a2, x10); \
	x12 = _mm_xor_si128 (x6, x11); \
	x13 = _mm_or_si128 (a6, x6); \
	x14 = _mm_andnot_si128 (a5, x13); \
	x15 = _mm_or_si128 (x4, x10); \
	x16 = _mm_andnot_si128 (x15, a2); \
	x17 = _mm_xor_si128 (x14, x16); \
	x18 = _mm_andnot_si128 (a3, x17); \
	x19 = _mm_xor_si128 (x12, _mm_andnot_si128 (x18, MINUS_1)); \
	out1 = _mm_xor_si128 (out1, x19); \
	x20 = _mm_andnot_si128 (x1, x19); \
	x21 = _mm_xor_si128 (x20, x15); \
	x22 = _mm_andnot_si128 (x21, a6); \
	x23 = _mm_xor_si128 (x22, x6); \
	x24 = _mm_andnot_si128 (x23, a2); \
	x25 = _mm_xor_si128 (x21, x24); \
	x26 = _mm_or_si128 (a5, a6); \
	x27 = _mm_andnot_si128 (x1, x26); \
	x28 = _mm_andnot_si128 (x24, a2); \
	x29 = _mm_xor_si128 (x27, x28); \
	x30 = _mm_andnot_si128 (x29, a3); \
	x31 = _mm_xor_si128 (x25, _mm_andnot_si128 (x30, MINUS_1)); \
	out4 = _mm_xor_si128 (out4, x31); \
	x32 = _mm_xor_si128 (x3, x6); \
	x33 = _mm_andnot_si128 (x10, x32); \
	x34 = _mm_xor_si128 (a6, x25); \
	x35 = _mm_andnot_si128 (x34, a5); \
	x36 = _mm_andnot_si128 (x35, a2); \
	x37 = _mm_xor_si128 (x33, x36); \
	x38 = _mm_andnot_si128 (a5, x21); \
	x39 = _mm_or_si128 (a3, x38); \
	x40 = _mm_xor_si128 (x37, _mm_andnot_si128 (x39, MINUS_1)); \
	out3 = _mm_xor_si128 (out3, x40); \
	x41 = _mm_or_si128 (x35, x2); \
	x42 = _mm_and_si128 (a5, x7); \
	x43 = _mm_andnot_si128 (x42, a4); \
	x44 = _mm_or_si128 (a2, x43); \
	x45 = _mm_xor_si128 (x41, x44); \
	x46 = _mm_or_si128 (x23, x35); \
	x47 = _mm_xor_si128 (x46, x5); \
	x48 = _mm_and_si128 (x26, x33); \
	x49 = _mm_xor_si128 (x48, x2); \
	x50 = _mm_and_si128 (a2, x49); \
	x51 = _mm_xor_si128 (x47, x50); \
	x52 = _mm_andnot_si128 (x51, a3); \
	x53 = _mm_xor_si128 (x45, _mm_andnot_si128 (x52, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x53); \
}; \


#define sse_s7(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_and_si128 (a2, a4); \
	x2 = _mm_xor_si128 (x1, a5); \
	x3 = _mm_and_si128 (a4, x2); \
	x4 = _mm_xor_si128 (x3, a2); \
	x5 = _mm_andnot_si128 (x4, a3); \
	x6 = _mm_xor_si128 (x2, x5); \
	x7 = _mm_xor_si128 (a3, x5); \
	x8 = _mm_andnot_si128 (x7, a6); \
	x9 = _mm_xor_si128 (x6, x8); \
	x10 = _mm_or_si128 (a2, a4); \
	x11 = _mm_or_si128 (x10, a5); \
	x12 = _mm_andnot_si128 (a2, a5); \
	x13 = _mm_or_si128 (a3, x12); \
	x14 = _mm_xor_si128 (x11, x13); \
	x15 = _mm_xor_si128 (x3, x6); \
	x16 = _mm_or_si128 (a6, x15); \
	x17 = _mm_xor_si128 (x14, x16); \
	x18 = _mm_and_si128 (a1, x17); \
	x19 = _mm_xor_si128 (x9, x18); \
	out1 = _mm_xor_si128 (out1, x19); \
	x20 = _mm_andnot_si128 (a3, a4); \
	x21 = _mm_andnot_si128 (x20, a2); \
	x22 = _mm_and_si128 (a6, x21); \
	x23 = _mm_xor_si128 (x9, x22); \
	x24 = _mm_xor_si128 (a4, x4); \
	x25 = _mm_or_si128 (a3, x3); \
	x26 = _mm_xor_si128 (x24, x25); \
	x27 = _mm_xor_si128 (a3, x3); \
	x28 = _mm_and_si128 (x27, a2); \
	x29 = _mm_andnot_si128 (x28, a6); \
	x30 = _mm_xor_si128 (x26, x29); \
	x31 = _mm_or_si128 (a1, x30); \
	x32 = _mm_xor_si128 (x23, _mm_andnot_si128 (x31, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x32); \
	x33 = _mm_xor_si128 (x7, x30); \
	x34 = _mm_or_si128 (a2, x24); \
	x35 = _mm_xor_si128 (x34, x19); \
	x36 = _mm_andnot_si128 (a6, x35); \
	x37 = _mm_xor_si128 (x33, x36); \
	x38 = _mm_andnot_si128 (a3, x26); \
	x39 = _mm_or_si128 (x38, x30); \
	x40 = _mm_andnot_si128 (a1, x39); \
	x41 = _mm_xor_si128 (x37, x40); \
	out3 = _mm_xor_si128 (out3, x41); \
	x42 = _mm_or_si128 (a5, x20); \
	x43 = _mm_xor_si128 (x42, x33); \
	x44 = _mm_xor_si128 (a2, x15); \
	x45 = _mm_andnot_si128 (x44, x24); \
	x46 = _mm_and_si128 (a6, x45); \
	x47 = _mm_xor_si128 (x43, x46); \
	x48 = _mm_and_si128 (a3, x22); \
	x49 = _mm_xor_si128 (x48, x46); \
	x50 = _mm_or_si128 (a1, x49); \
	x51 = _mm_xor_si128 (x47, x50); \
	out4 = _mm_xor_si128 (out4, x51); \
}; \


#define sse_s8(a1_1,a1_2,a2_1,a2_2,a3_1,a3_2,a4_1,a4_2,a5_1,a5_2,a6_1,a6_2,out1,out2,out3,out4) { \
	a1=_mm_xor_si128 (a1_1, a1_2); \
	a2=_mm_xor_si128 (a2_1, a2_2); \
	a3=_mm_xor_si128 (a3_1, a3_2); \
	a4=_mm_xor_si128 (a4_1, a4_2); \
	a5=_mm_xor_si128 (a5_1, a5_2); \
	a6=_mm_xor_si128 (a6_1, a6_2); \
	x1 = _mm_xor_si128 (a3, a1); \
	x2 = _mm_andnot_si128 (a3, a1); \
	x3 = _mm_xor_si128 (x2, a4); \
	x4 = _mm_or_si128 (a5, x3); \
	x5 = _mm_xor_si128 (x1, x4); \
	x6 = _mm_andnot_si128 (a1, x5); \
	x7 = _mm_xor_si128 (x6, a3); \
	x8 = _mm_andnot_si128 (a5, x7); \
	x9 = _mm_xor_si128 (a4, x8); \
	x10 = _mm_andnot_si128 (x9, a2); \
	x11 = _mm_xor_si128 (x5, x10); \
	x12 = _mm_or_si128 (x6, a4); \
	x13 = _mm_xor_si128 (x12, x1); \
	x14 = _mm_xor_si128 (x13, a5); \
	x15 = _mm_andnot_si128 (x14, x3); \
	x16 = _mm_xor_si128 (x15, x7); \
	x17 = _mm_andnot_si128 (x16, a2); \
	x18 = _mm_xor_si128 (x14, x17); \
	x19 = _mm_or_si128 (a6, x18); \
	x20 = _mm_xor_si128 (x11, _mm_andnot_si128 (x19, MINUS_1)); \
	out1 = _mm_xor_si128 (out1, x20); \
	x21 = _mm_or_si128 (x5, a5); \
	x22 = _mm_xor_si128 (x21, x3); \
	x23 = _mm_andnot_si128 (a4, x11); \
	x24 = _mm_andnot_si128 (x23, a2); \
	x25 = _mm_xor_si128 (x22, x24); \
	x26 = _mm_and_si128 (a1, x21); \
	x27 = _mm_and_si128 (a5, x2); \
	x28 = _mm_xor_si128 (x27, x23); \
	x29 = _mm_and_si128 (a2, x28); \
	x30 = _mm_xor_si128 (x26, x29); \
	x31 = _mm_andnot_si128 (a6, x30); \
	x32 = _mm_xor_si128 (x25, x31); \
	out3 = _mm_xor_si128 (out3, x32); \
	x33 = _mm_andnot_si128 (x16, a3); \
	x34 = _mm_or_si128 (x9, x33); \
	x35 = _mm_or_si128 (a2, x6); \
	x36 = _mm_xor_si128 (x34, x35); \
	x37 = _mm_andnot_si128 (x14, x2); \
	x38 = _mm_or_si128 (x22, x32); \
	x39 = _mm_andnot_si128 (x38, a2); \
	x40 = _mm_xor_si128 (x37, x39); \
	x41 = _mm_or_si128 (a6, x40); \
	x42 = _mm_xor_si128 (x36, _mm_andnot_si128 (x41, MINUS_1)); \
	out2 = _mm_xor_si128 (out2, x42); \
	x43 = _mm_andnot_si128 (a5, x1); \
	x44 = _mm_or_si128 (x43, a4); \
	x45 = _mm_xor_si128 (a3, a5); \
	x46 = _mm_xor_si128 (x45, x37); \
	x47 = _mm_andnot_si128 (a2, x46); \
	x48 = _mm_xor_si128 (x44, x47); \
	x49 = _mm_and_si128 (a6, x48); \
	x50 = _mm_xor_si128 (x11, _mm_andnot_si128 (x49, MINUS_1)); \
	out4 = _mm_xor_si128 (out4, x50); \
}; \


#endif
