/*
 * sha1_sse2.h
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
 * Implementation of the SHA-1 message-digest algorithm, optimized for passwords with length < 16
 * (see http://tools.ietf.org/html/rfc3174)
 *
 * Author: Dani�l Niggebrugge
 * License: Use and share as you wish at your own risk, please keep this header ;)
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, [...] etc :p
 *
 */

#ifdef HAVE_SSE2
#include <emmintrin.h>

typedef unsigned int UINT4;

#define K0 0x5A827999
#define K1 0x6ED9EBA1
#define K2 0x8F1BBCDC
#define K3 0xCA62C1D6

#define H0 0x67452301
#define H1 0xEFCDAB89
#define H2 0x98BADCFE
#define H3 0x10325476
#define H4 0xC3D2E1F0

#define	F_00_19(b,c,d)	((((c) ^ (d)) & (b)) ^ (d)) 
#define	F_20_39(b,c,d)	((b) ^ (c) ^ (d))
#define F_40_59(b,c,d)	(((b) & (c)) | (((b)|(c)) & (d))) 
#define	F_60_79(b,c,d)	F_20_39(b,c,d)

#define SSE_ROTATE(a,n) _mm_or_si128(_mm_slli_epi32(a, n), _mm_srli_epi32(a, (32-n)))

#define SSE_Endian_Reverse32(a) \
{ \
__m128i l=(a); \
(a)=((SSE_ROTATE(l,8)&m)|(SSE_ROTATE(l,24)&m2)); \
}



#define SSE_EXPAND(t) \
{ \
	sse_W[t] = SSE_ROTATE(sse_W[t-3] ^ sse_W[t-8] ^ sse_W[t-14] ^ sse_W[t-16],1); \
	sse_W1[t] = SSE_ROTATE(sse_W1[t-3] ^ sse_W1[t-8] ^ sse_W1[t-14] ^ sse_W1[t-16],1); \
	sse_W2[t] = SSE_ROTATE(sse_W2[t-3] ^ sse_W2[t-8] ^ sse_W2[t-14] ^ sse_W2[t-16],1); \
}

#define SSE_ROTATE1(a, a1, a2, a3, b, b1, b2, b3, c, c1, c2, c3, d, d1, d2, d3, e, e1, e2, e3, x, x1, x2, x3) \
	tmp1 = _mm_slli_epi32(a, 5); \
	tmp1_1 = _mm_slli_epi32(a1, 5); \
	tmp1_2 = _mm_slli_epi32(a2, 5); \
	tmp2 = _mm_srli_epi32(a, 27); \
	tmp2_1 = _mm_srli_epi32(a1, 27); \
	tmp2_2 = _mm_srli_epi32(a2, 27); \
	tmp3 = _mm_or_si128(tmp1,tmp2); \
	tmp3_1 = _mm_or_si128(tmp1_1,tmp2_1); \
	tmp3_2 = _mm_or_si128(tmp1_2,tmp2_2); \
	e = _mm_add_epi32(e,tmp3); \
	e1 = _mm_add_epi32(e1,tmp3_1); \
	e2 = _mm_add_epi32(e2,tmp3_2); \
	tmp1 = _mm_xor_si128(c,d); \
	tmp1_1 = _mm_xor_si128(c1,d1);\
	tmp1_2 = _mm_xor_si128(c2,d2); \
	tmp2 = _mm_and_si128(tmp1,b); \
	tmp2_1 = _mm_and_si128(tmp1_1,b1); \
	tmp2_2 = _mm_and_si128(tmp1_2,b2); \
	tmp3 = _mm_xor_si128(tmp2,d); \
	tmp3_1 = _mm_xor_si128(tmp2_1,d1); \
	tmp3_2 = _mm_xor_si128(tmp2_2,d2); \
	e = _mm_add_epi32(e, tmp3); \
	e1 = _mm_add_epi32(e1, tmp3_1); \
	e2 = _mm_add_epi32(e2, tmp3_2); \
	e = _mm_add_epi32(e, x); \
	e1 = _mm_add_epi32(e1, x1); \
	e2 = _mm_add_epi32(e2, x2); \
	e = _mm_add_epi32(e, sse_K); \
	e1 = _mm_add_epi32(e1, sse_K); \
	e2 = _mm_add_epi32(e2, sse_K); \
	tmp1 = _mm_slli_epi32(b, 30); \
	tmp1_1 = _mm_slli_epi32(b1, 30); \
	tmp1_2 = _mm_slli_epi32(b2, 30); \
	tmp2 = _mm_srli_epi32(b, 2); \
	tmp2_1 = _mm_srli_epi32(b1, 2); \
	tmp2_2 = _mm_srli_epi32(b2, 2); \
	b = _mm_or_si128(tmp1,tmp2); \
	b1 = _mm_or_si128(tmp1_1,tmp2_1); \
	b2 = _mm_or_si128(tmp1_2,tmp2_2); \

#define SSE_ROTATE1_NULL(a, a1, a2, a3, b, b1, b2, b3, c, c1, c2, c3, d, d1, d2, d3, e, e1, e2, e3) \
	tmp1 = _mm_slli_epi32(a, 5); \
	tmp1_1 = _mm_slli_epi32(a1, 5); \
	tmp1_2 = _mm_slli_epi32(a2, 5); \
	tmp2 = _mm_srli_epi32(a, 27); \
	tmp2_1 = _mm_srli_epi32(a1, 27); \
	tmp2_2 = _mm_srli_epi32(a2, 27); \
	tmp3 = _mm_or_si128(tmp1,tmp2); \
	tmp3_1 = _mm_or_si128(tmp1_1,tmp2_1); \
	tmp3_2 = _mm_or_si128(tmp1_2,tmp2_2); \
	e = _mm_add_epi32(e,tmp3); \
	e1 = _mm_add_epi32(e1,tmp3_1); \
	e2 = _mm_add_epi32(e2,tmp3_2); \
	tmp1 = _mm_xor_si128(c,d); \
	tmp1_1 = _mm_xor_si128(c1,d1);\
	tmp1_2 = _mm_xor_si128(c2,d2); \
	tmp2 = _mm_and_si128(tmp1,b); \
	tmp2_1 = _mm_and_si128(tmp1_1,b1); \
	tmp2_2 = _mm_and_si128(tmp1_2,b2); \
	tmp3 = _mm_xor_si128(tmp2,d); \
	tmp3_1 = _mm_xor_si128(tmp2_1,d1); \
	tmp3_2 = _mm_xor_si128(tmp2_2,d2); \
	e = _mm_add_epi32(e, tmp3); \
	e1 = _mm_add_epi32(e1, tmp3_1); \
	e2 = _mm_add_epi32(e2, tmp3_2); \
	e = _mm_add_epi32(e, sse_K); \
	e1 = _mm_add_epi32(e1, sse_K); \
	e2 = _mm_add_epi32(e2, sse_K); \
	tmp1 = _mm_slli_epi32(b, 30); \
	tmp1_1 = _mm_slli_epi32(b1, 30); \
	tmp1_2 = _mm_slli_epi32(b2, 30); \
	tmp2 = _mm_srli_epi32(b, 2); \
	tmp2_1 = _mm_srli_epi32(b1, 2); \
	tmp2_2 = _mm_srli_epi32(b2, 2); \
	b = _mm_or_si128(tmp1,tmp2); \
	b1 = _mm_or_si128(tmp1_1,tmp2_1); \
	b2 = _mm_or_si128(tmp1_2,tmp2_2); \


#define SSE_ROTATE2_F(a, a1, a2, a3, b, b1, b2, b3, c, c1, c2, c3, d, d1, d2, d3, e, e1, e2, e3, x, x1, x2, x3) \
	tmp1 = _mm_slli_epi32(a, 5); \
	tmp1_1 = _mm_slli_epi32(a1, 5); \
	tmp1_2 = _mm_slli_epi32(a2, 5); \
	tmp2 = _mm_srli_epi32(a, 27); \
	tmp2_1 = _mm_srli_epi32(a1, 27); \
	tmp2_2 = _mm_srli_epi32(a2, 27); \
	tmp3 = _mm_or_si128(tmp1,tmp2); \
	tmp3_1 = _mm_or_si128(tmp1_1,tmp2_1); \
	tmp3_2 = _mm_or_si128(tmp1_2,tmp2_2); \
	e = _mm_add_epi32(e,tmp3); \
	e1 = _mm_add_epi32(e1,tmp3_1); \
	e2 = _mm_add_epi32(e2,tmp3_2); \
	tmp1 = _mm_xor_si128(b,c); \
	tmp1_1 = _mm_xor_si128(b1,c1); \
	tmp1_2 = _mm_xor_si128(b2,c2); \
	tmp2 = _mm_xor_si128(tmp1,d); \
	tmp2_1 = _mm_xor_si128(tmp1_1,d1); \
	tmp2_2 = _mm_xor_si128(tmp1_2,d2); \
	e = _mm_add_epi32(e, tmp2); \
	e1 = _mm_add_epi32(e1, tmp2_1); \
	e2 = _mm_add_epi32(e2, tmp2_2); \
	e = _mm_add_epi32(e, x); \
	e1 = _mm_add_epi32(e1, x1); \
	e2 = _mm_add_epi32(e2, x2); \
	e = _mm_add_epi32(e,sse_K); \
	e1 = _mm_add_epi32(e1,sse_K); \
	e2 = _mm_add_epi32(e2,sse_K); \
	tmp1 = _mm_slli_epi32(b, 30); \
	tmp1_1 = _mm_slli_epi32(b1, 30); \
	tmp1_2 = _mm_slli_epi32(b2, 30); \
	tmp2 = _mm_srli_epi32(b, 2); \
	tmp2_1 = _mm_srli_epi32(b1, 2); \
	tmp2_2 = _mm_srli_epi32(b2, 2); \
	b = _mm_or_si128(tmp1,tmp2); \
	b1 = _mm_or_si128(tmp1_1,tmp2_1); \
	b2 = _mm_or_si128(tmp1_2,tmp2_2); \


#define SSE_ROTATE3_F(a, a1, a2, a3, b, b1, b2, b3, c, c1, c2, c3, d, d1, d2, d3, e, e1, e2, e3, x, x1, x2, x3) \
	tmp1 = _mm_slli_epi32(a, 5); \
	tmp1_1 = _mm_slli_epi32(a1, 5); \
	tmp1_2 = _mm_slli_epi32(a2, 5); \
	tmp2 = _mm_srli_epi32(a, 27); \
	tmp2_1 = _mm_srli_epi32(a1, 27); \
	tmp2_2 = _mm_srli_epi32(a2, 27); \
	tmp3 = _mm_or_si128(tmp1,tmp2); \
	tmp3_1 = _mm_or_si128(tmp1_1,tmp2_1); \
	tmp3_2 = _mm_or_si128(tmp1_2,tmp2_2); \
	e = _mm_add_epi32(e,tmp3); \
	e1 = _mm_add_epi32(e1,tmp3_1); \
	e2 = _mm_add_epi32(e2,tmp3_2); \
	tmp1 = _mm_and_si128(b,c); \
	tmp1_1 = _mm_and_si128(b1,c1); \
	tmp1_2 = _mm_and_si128(b2,c2); \
	tmp2 = _mm_or_si128(b,c); \
	tmp2_1 = _mm_or_si128(b1,c1); \
	tmp2_2 = _mm_or_si128(b2,c2); \
	tmp3 = _mm_and_si128(tmp2,d); \
	tmp3_1 = _mm_and_si128(tmp2_1,d1); \
	tmp3_2 = _mm_and_si128(tmp2_2,d2); \
	tmp2 = _mm_or_si128(tmp1,tmp3); \
	tmp2_1 = _mm_or_si128(tmp1_1,tmp3_1); \
	tmp2_2 = _mm_or_si128(tmp1_2,tmp3_2); \
	e = _mm_add_epi32(e, tmp2); \
	e1 = _mm_add_epi32(e1, tmp2_1); \
	e2 = _mm_add_epi32(e2, tmp2_2); \
	e = _mm_add_epi32(e, x); \
	e1 = _mm_add_epi32(e1, x1); \
	e2 = _mm_add_epi32(e2, x2); \
	e = _mm_add_epi32(e, sse_K); \
	e1 = _mm_add_epi32(e1, sse_K); \
	e2 = _mm_add_epi32(e2, sse_K); \
	tmp1 = _mm_slli_epi32(b, 30); \
	tmp1_1 = _mm_slli_epi32(b1, 30); \
	tmp1_2 = _mm_slli_epi32(b2, 30); \
	tmp2 = _mm_srli_epi32(b, 2); \
	tmp2_1 = _mm_srli_epi32(b1, 2); \
	tmp2_2 = _mm_srli_epi32(b2, 2); \
	b = _mm_or_si128(tmp1,tmp2); \
	b1 = _mm_or_si128(tmp1_1,tmp2_1); \
	b2 = _mm_or_si128(tmp1_2,tmp2_2); \


#define SSE_ROTATE4_F(a, a1, a2, a3, b, b1, b2, b3, c, c1, c2, c3, d, d1, d2, d3, e,e1, e2, e3,  x, x1, x2, x3) \
	tmp1 = _mm_slli_epi32(a, 5); \
	tmp1_1 = _mm_slli_epi32(a1, 5); \
	tmp1_2 = _mm_slli_epi32(a2, 5); \
	tmp2 = _mm_srli_epi32(a, 27); \
	tmp2_1 = _mm_srli_epi32(a1, 27); \
	tmp2_2 = _mm_srli_epi32(a2, 27); \
	tmp3 = _mm_or_si128(tmp1,tmp2); \
	tmp3_1 = _mm_or_si128(tmp1_1,tmp2_1); \
	tmp3_2 = _mm_or_si128(tmp1_2,tmp2_2); \
	e = _mm_add_epi32(e,tmp3); \
	e1 = _mm_add_epi32(e1,tmp3_1); \
	e2 = _mm_add_epi32(e2,tmp3_2); \
	tmp1 = _mm_xor_si128(b,c); \
	tmp1_1 = _mm_xor_si128(b1,c1); \
	tmp1_2 = _mm_xor_si128(b2,c2); \
	tmp2 = _mm_xor_si128(tmp1,d); \
	tmp2_1 = _mm_xor_si128(tmp1_1,d1); \
	tmp2_2 = _mm_xor_si128(tmp1_2,d2); \
	e = _mm_add_epi32(e, tmp2); \
	e1 = _mm_add_epi32(e1, tmp2_1); \
	e2 = _mm_add_epi32(e2, tmp2_2); \
	e = _mm_add_epi32(e, x); \
	e1 = _mm_add_epi32(e1, x1); \
	e2 = _mm_add_epi32(e2, x2); \
	e = _mm_add_epi32(e, sse_K); \
	e1 = _mm_add_epi32(e1, sse_K); \
	e2 = _mm_add_epi32(e2, sse_K); \
	tmp1 = _mm_slli_epi32(b, 30); \
	tmp1_1 = _mm_slli_epi32(b1, 30); \
	tmp1_2 = _mm_slli_epi32(b2, 30); \
	tmp2 = _mm_srli_epi32(b, 2); \
	tmp2_1 = _mm_srli_epi32(b1, 2); \
	tmp2_2 = _mm_srli_epi32(b2, 2); \
	b = _mm_or_si128(tmp1,tmp2); \
	b1 = _mm_or_si128(tmp1_1,tmp2_1); \
	b2 = _mm_or_si128(tmp1_2,tmp2_2); \


#define SSE_ROTATE4(t) \
	sse_temp = _mm_add_epi32(SSE_ROTATE(sse_A,5), F_60_79(sse_B,sse_C,sse_D)); \
	sse_temp = _mm_add_epi32(sse_temp, sse_E); \
	sse_temp = _mm_add_epi32(sse_temp, sse_W[t]); \
	sse_temp = _mm_add_epi32(sse_temp, sse_K); \
	sse_E = sse_D; sse_D = sse_C; \
	sse_C = SSE_ROTATE(sse_B,30); \
	sse_B = sse_A; sse_A = sse_temp;

#endif
