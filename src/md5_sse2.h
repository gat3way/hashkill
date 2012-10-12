/*
 * md5_sse2.h
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


// (C) Daniel Niggebrugge
// feel free to use in other open source code, no garantuees, etc
//

#ifdef HAVE_SSE2

#include <emmintrin.h>

typedef unsigned int UINT4;

// Define constants
#define AC1 0xd76aa478
#define AC2 0xe8c7b756
#define AC3 0x242070db
#define AC4 0xc1bdceee
#define AC5 0xf57c0faf
#define AC6 0x4787c62a
#define AC7 0xa8304613
#define AC8 0xfd469501
#define AC9 0x698098d8
#define AC10 0x8b44f7af
#define AC11 0xffff5bb1
#define AC12 0x895cd7be
#define AC13 0x6b901122
#define AC14 0xfd987193
#define AC15 0xa679438e
#define AC16 0x49b40821
#define AC17 0xf61e2562
#define AC18 0xc040b340
#define AC19 0x265e5a51
#define AC20 0xe9b6c7aa
#define AC21 0xd62f105d
#define AC22 0x02441453
#define AC23 0xd8a1e681
#define AC24 0xe7d3fbc8
#define AC25 0x21e1cde6
#define AC26 0xc33707d6
#define AC27 0xf4d50d87
#define AC28 0x455a14ed
#define AC29 0xa9e3e905
#define AC30 0xfcefa3f8
#define AC31 0x676f02d9
#define AC32 0x8d2a4c8a
#define AC33 0xfffa3942
#define AC34 0x8771f681
#define AC35 0x6d9d6122
#define AC36 0xfde5380c
#define AC37 0xa4beea44
#define AC38 0x4bdecfa9
#define AC39 0xf6bb4b60
#define AC40 0xbebfbc70
#define AC41 0x289b7ec6
#define AC42 0xeaa127fa
#define AC43 0xd4ef3085
#define AC44 0x04881d05
#define AC45 0xd9d4d039
#define AC46 0xe6db99e5
#define AC47 0x1fa27cf8
#define AC48 0xc4ac5665
#define AC49 0xf4292244
#define AC50 0x432aff97
#define AC51 0xab9423a7
#define AC52 0xfc93a039
#define AC53 0x655b59c3
#define AC54 0x8f0ccc92
#define AC55 0xffeff47d
#define AC56 0x85845dd1
#define AC57 0x6fa87e4f
#define AC58 0xfe2ce6e0
#define AC59 0xa3014314
#define AC60 0x4e0811a1
#define AC61 0xf7537e82
#define AC62 0xbd3af235
#define AC63 0x2ad7d2bb
#define AC64 0xeb86d391

// Define rotations
#define S11 7
#define S12 12
#define S13 17
#define S14 22
#define S21 5
#define S22 9
#define S23 14
#define S24 20
#define S31 4
#define S32 11
#define S33 16
#define S34 23
#define S41 6
#define S42 10
#define S43 15
#define S44 21

// Define initial values
#define Ca 0x67452301
#define Cb 0xefcdab89
#define Cc 0x98badcfe
#define Cd 0x10325476

// Define functions for use in the 4 rounds of MD5
#define F(x, y, z) ((z) ^ ((x) & ((y) ^ (z))))
#define G(x, y, z) ((y) ^ ((z) & ((x) ^ (y))))
#define H(x, y, z) ((x) ^ (y) ^ (z))
#define I(x, y, z) ((y) ^ ((x) | ~(z)))


#define MD5STEP_ROUND1(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp1 = (c) ^ (d);\
tmp1_2 = (c2) ^ (d2);\
tmp1_3 = (c3) ^ (d3);\
tmp1 = tmp1 & (b);\
tmp1_2 = tmp1_2 & (b2);\
tmp1_3 = tmp1_3 & (b3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32(a,tmp1); \
(a2) = _mm_add_epi32(a2,tmp1_2); \
(a3) = _mm_add_epi32(a3,tmp1_3); \
(a) = _mm_add_epi32(a,_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_add_epi32((a),(x)); \
(a2) = _mm_add_epi32((a2),(x2)); \
(a3) = _mm_add_epi32((a3),(x3)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND1_NULL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp1 = (c) ^ (d);\
tmp1_2 = (c2) ^ (d2);\
tmp1_3 = (c3) ^ (d3);\
tmp1 = tmp1 & (b);\
tmp1_2 = tmp1_2 & (b2);\
tmp1_3 = tmp1_3 & (b3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND2(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 & (d);\
tmp1_2 = tmp1_2 & (d2);\
tmp1_3 = tmp1_3 & (d3);\
tmp1 = tmp1 ^ (c);\
tmp1_2 = tmp1_2 ^ (c2);\
tmp1_3 = tmp1_3 ^ (c3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2), _mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_add_epi32((a),(x)); \
(a2) = _mm_add_epi32((a2),(x2)); \
(a3) = _mm_add_epi32((a3),(x3)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND2_NULL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 & (d);\
tmp1_2 = tmp1_2 & (d2);\
tmp1_3 = tmp1_3 & (d3);\
tmp1 = tmp1 ^ (c);\
tmp1_2 = tmp1_2 ^ (c2);\
tmp1_3 = tmp1_3 ^ (c3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND3_EVEN_SMALL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_shufflehi_epi16((a), 0xB1); \
(a) = _mm_shufflelo_epi16((a), 0xB1); \
(a2) = _mm_shufflehi_epi16((a2), 0xB1); \
(a2) = _mm_shufflelo_epi16((a2), 0xB1); \
(a3) = _mm_shufflehi_epi16((a3), 0xB1); \
(a3) = _mm_shufflelo_epi16((a3), 0xB1); \
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND3_EVEN(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp2 = tmp1 = (b) ^ (c);\
tmp2_2 = tmp1_2 = (b2) ^ (c2);\
tmp2_3 = tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_add_epi32((a),(x)); \
(a2) = _mm_add_epi32((a2),(x2)); \
(a3) = _mm_add_epi32((a3),(x3)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND3_ODD(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp1 = (b) ^ (tmp2);\
tmp1_2 = (b2) ^ (tmp2_2);\
tmp1_3 = (b3) ^ (tmp2_3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_add_epi32((a),(x)); \
(a2) = _mm_add_epi32((a2),(x2)); \
(a3) = _mm_add_epi32((a3),(x3)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}



#define MD5STEP_ROUND3_NULL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND3_NULL_EVEN(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp2 = tmp1 = (b) ^ (c);\
tmp2_2 = tmp1_2 = (b2) ^ (c2);\
tmp2_3 = tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND3_NULL_EVEN_SMALL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp2 = tmp1 = (b) ^ (c);\
tmp2_2 = tmp1_2 = (b2) ^ (c2);\
tmp2_3 = tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_shufflehi_epi16((a), 0xB1); \
(a) = _mm_shufflelo_epi16((a), 0xB1); \
(a2) = _mm_shufflehi_epi16((a2), 0xB1); \
(a2) = _mm_shufflelo_epi16((a2), 0xB1); \
(a3) = _mm_shufflehi_epi16((a3), 0xB1); \
(a3) = _mm_shufflelo_epi16((a3), 0xB1); \
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}



#define MD5STEP_ROUND3_NULL_ODD(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp2 = tmp1 = (b) ^ (tmp2);\
tmp2_2 = tmp1_2 = (b2) ^ (tmp2_2);\
tmp2_3 = tmp1_3 = (b3) ^ (tmp2_3);\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}


#define MD5STEP_ROUND4(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, x, x2, x3, x4, s) { \
tmp1 = _mm_andnot_si128(d, mOne);\
tmp1_2 = _mm_andnot_si128(d2, mOne);\
tmp1_3 = _mm_andnot_si128(d3, mOne);\
tmp1 = b | tmp1;\
tmp1_2 = b2 | tmp1_2;\
tmp1_3 = b3 | tmp1_3;\
tmp1 = tmp1 ^ c;\
tmp1_2 = tmp1_2 ^ c2;\
tmp1_3 = tmp1_3 ^ c3;\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
(a) = _mm_add_epi32((a),(x)); \
(a2) = _mm_add_epi32((a2),(x2)); \
(a3) = _mm_add_epi32((a3),(x3)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}

#define MD5STEP_ROUND4_NULL(f, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC, s) { \
tmp1 = _mm_andnot_si128(d, mOne);\
tmp1_2 = _mm_andnot_si128(d2, mOne);\
tmp1_3 = _mm_andnot_si128(d3, mOne);\
tmp1 = b | tmp1;\
tmp1_2 = b2 | tmp1_2;\
tmp1_3 = b3 | tmp1_3;\
tmp1 = tmp1 ^ c;\
tmp1_2 = tmp1_2 ^ c2;\
tmp1_3 = tmp1_3 ^ c3;\
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2),tmp1_2); \
(a3) = _mm_add_epi32((a3),tmp1_3); \
(a) = _mm_add_epi32((a),_mm_set1_epi32(AC)); \
(a2) = _mm_add_epi32((a2),_mm_set1_epi32(AC)); \
(a3) = _mm_add_epi32((a3),_mm_set1_epi32(AC)); \
tmp1 = _mm_slli_epi32((a), (s));\
tmp1_2 = _mm_slli_epi32((a2), (s));\
tmp1_3 = _mm_slli_epi32((a3), (s));\
(a) = _mm_srli_epi32((a), (32-s));\
(a2) = _mm_srli_epi32((a2), (32-s));\
(a3) = _mm_srli_epi32((a3), (32-s));\
(a) = tmp1 | (a);\
(a2) = tmp1_2 | (a2);\
(a3) = tmp1_3 | (a3);\
(a) = _mm_add_epi32((a),(b)); \
(a2) = _mm_add_epi32((a2),(b2)); \
(a3) = _mm_add_epi32((a3),(b3)); \
}




#define MD5_STEPS_FULL() { \
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC1, w0_1, w0_2, w0_3, w0_3, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC2, w1_1, w1_2, w1_3, w1_3, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC3, w2_1, w2_2, w2_3, w2_3, S13);\
MD5STEP_ROUND1(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC4, w3_1, w3_2, w3_3, w3_3, S14);\
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC5, w4_1, w4_2, w4_3, w4_3, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC6, w5_1, w5_2, w5_3, w5_3, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC7, w6_1, w6_2, w6_3, w6_3, S13);\
MD5STEP_ROUND1(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC8, w7_1, w7_2, w7_3, w7_3, S14);\
\
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC9, w8_1, w8_2, w8_3, w8_3, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC10, w9_1, w9_2, w9_3, w9_3, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC11, w10_1, w10_2, w10_3, w10_3, S13);\
MD5STEP_ROUND1(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC12, w11_1, w11_2, w11_3, w11_3, S14);\
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC13, w12_1, w12_2, w12_3, w12_3, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC14, w13_1, w13_2, w13_3, w13_3, S12);\
MD5STEP_ROUND1 (F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC15, w14_1, w14_2, w14_3, w14_3, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC16, S14);\
\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC17, w1_1, w1_2, w1_3, w1_3, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC18, w6_1, w6_2, w6_3, w6_3, S22);\
MD5STEP_ROUND2 (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC19, w11_1, w11_2, w11_3, w10_3, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC20, w0_1, w0_2, w0_3, w0_3, S24);\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC21, w5_1, w5_2, w5_3, w5_3, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC22, w10_1, w10_2, w10_3, w10_3, S22);\
MD5STEP_ROUND2_NULL(G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC23, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC24, w4_1, w4_2, w4_3, w4_3, S24);\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC25, w9_1, w9_2, w9_3, w9_3, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC26, w14_1, w14_2, w14_3, w14_3, S22);\
MD5STEP_ROUND2 (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC27, w3_1, w3_2, w3_3, w3_3, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC28, w8_1, w8_2, w8_3, w8_3, S24);\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC29, w13_1, w13_2, w13_3, w13_3, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC30, w2_1, w2_2, w2_3, w2_3, S22);\
MD5STEP_ROUND2 (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC31, w7_1, w7_2, w7_3, w7_3, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC32, w12_1, w12_2, w12_3, w12_3 , S24);\
\
MD5STEP_ROUND3_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC33, w5_1, w5_2, w5_3, w5_3, S31);\
MD5STEP_ROUND3_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC34, w8_1, w8_2, w8_3, w8_3, S32);\
MD5STEP_ROUND3_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC35, w11_1, w11_2, w11_3, w11_3, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC36, w14_1, w14_2, w14_3, w14_3, S34);\
MD5STEP_ROUND3_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC37, w1_1, w1_2, w1_3, w1_3, S31);\
MD5STEP_ROUND3_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC38, w4_1, w4_2, w4_3, w4_3, S32);\
MD5STEP_ROUND3_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC39, w7_1, w7_2, w7_3, w7_3, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC40, w10_1, w10_2, w10_3, w10_3, S34);\
MD5STEP_ROUND3_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC41,w13_1, w13_2, w13_3, w13_3 ,S31);\
MD5STEP_ROUND3_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC42, w0_1, w0_2, w0_3, w0_3, S32);\
MD5STEP_ROUND3_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC43, w3_1, w3_2, w3_3, w3_3, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC44, w6_1, w6_2, w6_3, w6_3, S34);\
MD5STEP_ROUND3_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC45, w9_1, w9_2, w9_3, w9_3, S31);\
MD5STEP_ROUND3_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC46,w12_1, w12_2, w12_3, w12_3, S32);\
MD5STEP_ROUND3_NULL_EVEN(H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC47, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC48, w2_1, w2_2, w2_3, w2_3, S34);\
\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC49, w0_1, w0_2, w0_3, w0_3, S41);\
MD5STEP_ROUND4 (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC50, w7_1, w7_2, w7_3, w7_3, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC51, w14_1, w14_2, w14_3, w14_3, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC52, w5_1, w5_2, w5_3, w5_3, S44);\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC53, w12_1, w12_2, w12_3, w12_3, S41);\
MD5STEP_ROUND4 (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC54, w3_1, w3_2, w3_3, w3_3, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC55, w10_1, w10_2, w10_3, w10_3, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC56, w1_1, w1_2, w1_3, w1_3, S44);\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC57, w8_1, w8_2, w8_3, w8_3, S41);\
MD5STEP_ROUND4_NULL(I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC58, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC59, w6_1, w6_2, w6_3, w6_3, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC60, w13_1, w13_2, w13_3, w13_3 ,S44);\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC61, w4_1, w4_2, w4_3, w4_3, S41);\
MD5STEP_ROUND4 (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC62, w11_1, w11_2, w11_3, w11_3 ,S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4,  AC63, w2_1, w2_2, w2_3, w2_3, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC64, w9_1, w9_2, w9_3, w9_3, S44);\
}



#define MD5_STEPS() { \
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC1, w0_1, w0_2, w0_3, w0_4, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC2, w1_1, w1_2, w1_3, w1_4, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC3, w2_1, w2_2, w2_3, w2_4, S13);\
MD5STEP_ROUND1(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC4, w3_1, w3_2, w3_3, w3_4, S14);\
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC5, w4_1, w4_2, w4_3, w4_4, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC6, w5_1, w5_2, w5_3, w5_4, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC7, w6_1, w6_2, w6_3, w6_4, S13);\
MD5STEP_ROUND1(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC8, w7_1, w7_2, w7_3, w7_4, S14);\
\
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC9, w8_1, w8_2, w8_3, w8_4, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC10, w9_1, w9_2, w9_3, w9_4, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC11, w10_1, w10_2, w10_3, w10_4, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC12, S14);\
MD5STEP_ROUND1_NULL(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC13, S11);\
MD5STEP_ROUND1_NULL(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC14, S12);\
MD5STEP_ROUND1 (F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC15, w14_1, w14_2, w14_3, w14_4, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC16, S14);\
\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC17, w1_1, w1_2, w1_3, w1_4, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC18, w6_1, w6_2, w6_3, w6_4, S22);\
MD5STEP_ROUND2_NULL (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC19, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC20, w0_1, w0_2, w0_3, w0_4, S24);\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC21, w5_1, w5_2, w5_3, w5_4, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC22, w10_1, w10_2, w10_3, w10_4, S22);\
MD5STEP_ROUND2_NULL(G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC23, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC24, w4_1, w4_2, w4_3, w4_4, S24);\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC25, w9_1, w9_2, w9_3, w9_4, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC26, w14_1, w14_2, w14_3, w14_4, S22);\
MD5STEP_ROUND2 (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC27, w3_1, w3_2, w3_3, w3_4, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC28, w8_1, w8_2, w8_3, w8_4, S24);\
MD5STEP_ROUND2_NULL(G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC29, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC30, w2_1, w2_2, w2_3, w2_4, S22);\
MD5STEP_ROUND2 (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC31, w7_1, w7_2, w7_3, w7_4, S23);\
MD5STEP_ROUND2_NULL(G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC32, S24);\
\
MD5STEP_ROUND3_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC33, w5_1, w5_2, w5_3, w5_4, S31);\
MD5STEP_ROUND3_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC34, w8_1, w8_2, w8_3, w8_4, S32);\
MD5STEP_ROUND3_NULL_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC35, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC36, w14_1, w14_2, w14_3, w14_4, S34);\
MD5STEP_ROUND3_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC37, w1_1, w1_2, w1_3, w1_4, S31);\
MD5STEP_ROUND3_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC38, w4_1, w4_2, w4_3, w4_4, S32);\
MD5STEP_ROUND3_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC39, w7_1, w7_2, w7_3, w7_4, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC40, w10_1, w10_2, w10_3, w10_4, S34);\
MD5STEP_ROUND3_NULL_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC41, S31);\
MD5STEP_ROUND3_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC42, w0_1, w0_2, w0_3, w0_4, S32);\
MD5STEP_ROUND3_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC43, w3_1, w3_2, w3_3, w3_4, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC44, w6_1, w6_2, w6_3, w6_4, S34);\
MD5STEP_ROUND3_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC45, w9_1, w9_2, w9_3, w9_4, S31);\
MD5STEP_ROUND3_NULL_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC46, S32);\
MD5STEP_ROUND3_NULL_EVEN(H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC47, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC48, w2_1, w2_2, w2_3, w2_4, S34);\
\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC49, w0_1, w0_2, w0_3, w0_4, S41);\
MD5STEP_ROUND4 (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC50, w7_1, w7_2, w7_3, w7_4, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC51, w14_1, w14_2, w14_3, w14_4, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC52, w5_1, w5_2, w5_3, w5_4, S44);\
MD5STEP_ROUND4_NULL(I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC53, S41);\
MD5STEP_ROUND4 (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC54, w3_1, w3_2, w3_3, w3_4, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC55, w10_1, w10_2, w10_3, w10_4, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC56, w1_1, w1_2, w1_3, w1_4, S44);\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC57, w8_1, w8_2, w8_3, w8_4, S41);\
MD5STEP_ROUND4_NULL(I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC58, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC59, w6_1, w6_2, w6_3, w6_4, S43);\
MD5STEP_ROUND4_NULL(I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC60, S44);\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC61, w4_1, w4_2, w4_3, w4_4, S41);\
MD5STEP_ROUND4_NULL (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC62, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4,  AC63, w2_1, w2_2, w2_3, w2_4, S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC64, w9_1, w9_2, w9_3, w9_4, S44);\
}



#define MD5_STEPS_SHORT() { \
MD5STEP_ROUND1(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC1, w0_1, w0_2, w0_3, w0_4, S11);\
MD5STEP_ROUND1(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC2, w1_1, w1_2, w1_3, w1_4, S12);\
MD5STEP_ROUND1(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC3, w2_1, w2_2, w2_3, w2_4, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC4, S14);\
MD5STEP_ROUND1_NULL(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC5, S11);\
MD5STEP_ROUND1_NULL(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC6, S12);\
MD5STEP_ROUND1_NULL(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC7, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC8, S14);\
\
MD5STEP_ROUND1_NULL(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC9, S11);\
MD5STEP_ROUND1_NULL(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC10, S12);\
MD5STEP_ROUND1_NULL(F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC11, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC12, S14);\
MD5STEP_ROUND1_NULL(F, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC13, S11);\
MD5STEP_ROUND1_NULL(F, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC14, S12);\
MD5STEP_ROUND1 (F, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC15, w14_1, w14_2, w14_3, w14_4, S13);\
MD5STEP_ROUND1_NULL(F, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC16, S14);\
\
MD5STEP_ROUND2 (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC17, w1_1, w1_2, w1_3, w1_4, S21);\
MD5STEP_ROUND2_NULL (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC18, S22);\
MD5STEP_ROUND2_NULL (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC19, S23);\
MD5STEP_ROUND2 (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC20, w0_1, w0_2, w0_3, w0_4, S24);\
MD5STEP_ROUND2_NULL (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC21, S21);\
MD5STEP_ROUND2_NULL (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC22, S22);\
MD5STEP_ROUND2_NULL(G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC23, S23);\
MD5STEP_ROUND2_NULL (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC24, S24);\
MD5STEP_ROUND2_NULL (G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC25, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC26, w14_1, w14_2, w14_3, w14_4, S22);\
MD5STEP_ROUND2_NULL (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC27, S23);\
MD5STEP_ROUND2_NULL (G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC28, S24);\
MD5STEP_ROUND2_NULL(G, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC29, S21);\
MD5STEP_ROUND2 (G, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC30, w2_1, w2_2, w2_3, w2_4, S22);\
MD5STEP_ROUND2_NULL (G, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC31, S23);\
MD5STEP_ROUND2_NULL(G, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC32, S24);\
\
MD5STEP_ROUND3_NULL_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC33, S31);\
MD5STEP_ROUND3_NULL_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC34, S32);\
MD5STEP_ROUND3_NULL_EVEN_SMALL(H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC35, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC36, w14_1, w14_2, w14_3, w14_4, S34);\
MD5STEP_ROUND3_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC37, w1_1, w1_2, w1_3, w1_4, S31);\
MD5STEP_ROUND3_NULL_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC38, S32);\
MD5STEP_ROUND3_NULL_EVEN_SMALL (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC39, S33);\
MD5STEP_ROUND3_NULL_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC40, S34);\
MD5STEP_ROUND3_NULL_EVEN(H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC41, S31);\
MD5STEP_ROUND3_ODD (H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC42, w0_1, w0_2, w0_3, w0_4, S32);\
MD5STEP_ROUND3_NULL_EVEN (H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC43, S33);\
MD5STEP_ROUND3_NULL_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC44, S34);\
MD5STEP_ROUND3_NULL_EVEN (H, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC45, S31);\
MD5STEP_ROUND3_NULL_ODD(H, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC46, S32);\
MD5STEP_ROUND3_NULL_EVEN_SMALL(H, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC47, S33);\
MD5STEP_ROUND3_ODD (H, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC48, w2_1, w2_2, w2_3, w2_4, S34);\
\
MD5STEP_ROUND4 (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC49, w0_1, w0_2, w0_3, w0_4, S41);\
MD5STEP_ROUND4_NULL (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC50, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC51, w14_1, w14_2, w14_3, w14_4, S43);\
MD5STEP_ROUND4_NULL (I, b, b2, b3, b4, c, c2, c3, c4,  d, d2, d3, d4, a, a2, a3, a4, AC52, S44);\
MD5STEP_ROUND4_NULL(I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC53, S41);\
}

#define MD5_STEPS_SHORT_NEXT() { \
MD5STEP_ROUND4_NULL (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC54, S42);\
MD5STEP_ROUND4_NULL (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC55,  S43);\
MD5STEP_ROUND4 (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC56, w1_1, w1_2, w1_3, w1_4, S44);\
MD5STEP_ROUND4_NULL (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC57, S41);\
MD5STEP_ROUND4_NULL(I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC58, S42);\
MD5STEP_ROUND4_NULL (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC59, S43);\
MD5STEP_ROUND4_NULL(I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC60, S44);\
MD5STEP_ROUND4_NULL (I, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, AC61, S41);\
}

#define MD5_STEPS_SHORT_END() { \
MD5STEP_ROUND4_NULL (I, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, AC62, S42);\
MD5STEP_ROUND4 (I, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, AC63, w2_1, w2_2, w2_3, w2_4, S43);\
MD5STEP_ROUND4_NULL (I, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, AC64, S44);\
}

#endif
