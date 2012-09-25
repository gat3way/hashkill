/*
 * md4_xop.h
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


#ifdef HAVE_SSE2

#include <x86intrin.h>

typedef unsigned int UINT4;

#define S11 3 
#define S12 7 
#define S13 11
#define S14 19
#define S21 3 
#define S22 5 
#define S23 9 
#define S24 13
#define S31 3 
#define S32 9 
#define S33 11
#define S34 15

#define Ca 0x67452301
#define Cb 0xefcdab89
#define Cc 0x98badcfe
#define Cd 0x10325476


#define MD4STEP_ROUND1(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, x, x2, x3, x4, s) {\
tmp1 = _mm_cmov_si128((c),(d),(b)); \
tmp1_2 = _mm_cmov_si128((c2),(d2),(b2)); \
tmp1_3 = _mm_cmov_si128((c3),(d3),(b3)); \
(a) = _mm_add_epi32((a),tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_add_epi32((a), (x)); \
(a2) = _mm_add_epi32((a2), (x2));\
(a3) = _mm_add_epi32((a3), (x3));\
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
} 

#define MD4STEP_ROUND1_NULL(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, s) { \
tmp1 = _mm_cmov_si128((c),(d),(b)); \
tmp1_2 = _mm_cmov_si128((c2),(d2),(b2)); \
tmp1_3 = _mm_cmov_si128((c3),(d3),(b3)); \
(a) = _mm_add_epi32((a), tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
}

#define MD4STEP_ROUND2(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, x, x2, x3, x4, s) {\
tmp1 = _mm_cmov_si128((b),(c),(d)^(c)); \
tmp1_2 = _mm_cmov_si128((b2),(c2),(d2)^(c2)); \
tmp1_3 = _mm_cmov_si128((b3),(c3),(d3)^(c3)); \
(a) = _mm_add_epi32((a), tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_add_epi32((a), (x)); \
(a2) = _mm_add_epi32((a2), (x2));\
(a3) = _mm_add_epi32((a3), (x3));\
(a) = _mm_add_epi32((a), (AC));\
(a2) = _mm_add_epi32((a2), (AC));\
(a3) = _mm_add_epi32((a3), (AC));\
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
}

#define MD4STEP_ROUND2_NULL(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, s) { \
tmp1 = _mm_cmov_si128((b),(c),(d)^(c)); \
tmp1_2 = _mm_cmov_si128((b2),(c2),(d2)^(c2)); \
tmp1_3 = _mm_cmov_si128((b3),(c3),(d3)^(c3)); \
(a) = _mm_add_epi32((a), tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_add_epi32((a), (AC));\
(a2) = _mm_add_epi32((a2), (AC));\
(a3) = _mm_add_epi32((a3), (AC));\
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
}


#define MD4STEP_ROUND3(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, x, x2, x3, x4, s) {\
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a), tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_add_epi32((a), (x)); \
(a2) = _mm_add_epi32((a2), (x2));\
(a3) = _mm_add_epi32((a3), (x3));\
(a) = _mm_add_epi32((a), (AD));\
(a2) = _mm_add_epi32((a2), (AD));\
(a3) = _mm_add_epi32((a3), (AD));\
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
}


#define MD4STEP_ROUND3_NULL(a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, s) { \
tmp1 = (b) ^ (c);\
tmp1_2 = (b2) ^ (c2);\
tmp1_3 = (b3) ^ (c3);\
tmp1 = tmp1 ^ (d);\
tmp1_2 = tmp1_2 ^ (d2);\
tmp1_3 = tmp1_3 ^ (d3);\
(a) = _mm_add_epi32((a), tmp1); \
(a2) = _mm_add_epi32((a2), tmp1_2); \
(a3) = _mm_add_epi32((a3), tmp1_3); \
(a) = _mm_add_epi32((a), (AD));\
(a2) = _mm_add_epi32((a2), (AD));\
(a3) = _mm_add_epi32((a3), (AD));\
(a) = _mm_roti_epi32((a),(s)); \
(a2) = _mm_roti_epi32((a2),(s)); \
(a3) = _mm_roti_epi32((a3),(s)); \
}


#define MD4_STEPS() { \
MD4STEP_ROUND1 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S11);\
MD4STEP_ROUND1 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w1, w11, w12, w13, S12);\
MD4STEP_ROUND1 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w2, w21, w22, w23, S13);\
MD4STEP_ROUND1 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w3, w31, w32, w33, S14);\
MD4STEP_ROUND1 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w4, w41, w42, w43, S11);\
MD4STEP_ROUND1 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w5, w51, w52, w53, S12);\
MD4STEP_ROUND1 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w6, w61, w62, w63, S13);\
MD4STEP_ROUND1 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w7, w71, w72, w73, S14);\
MD4STEP_ROUND1_NULL (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, S11);\
MD4STEP_ROUND1_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S12);\
MD4STEP_ROUND1_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S13);\
MD4STEP_ROUND1_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S14);\
MD4STEP_ROUND1_NULL (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, S11);\
MD4STEP_ROUND1_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S12);\
MD4STEP_ROUND1 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w14, w141, w142, w143, S13); \
MD4STEP_ROUND1_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S14); \
\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S21);\
MD4STEP_ROUND2 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w4, w41, w42, w43, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4,  S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w1, w11, w12, w13, S21);\
MD4STEP_ROUND2 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w5, w51, w52, w53, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w2, w21, w22, w23, S21);\
MD4STEP_ROUND2 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w6, w61, w62, w63, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w14, w141, w142, w143, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w3, w31, w32, w33, S21);\
MD4STEP_ROUND2 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w7, w71, w72, w73, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S31);\
MD4STEP_ROUND3_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w4, w41, w42, w43, S33);\
MD4STEP_ROUND3_NULL(b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w2, w21, w22, w23, S31);\
MD4STEP_ROUND3_NULL(d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w6, w61, w62, w63, S33);\
MD4STEP_ROUND3 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w14, w141, w142, w143, S34);\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w1, w11, w12, w13, S31);\
MD4STEP_ROUND3_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w5, w51, w52, w53, S33);\
MD4STEP_ROUND3_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
}

#define MD4_STEPS_LAST() { \
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w3, w31, w32, w33, S31);\
MD4STEP_ROUND3_NULL(d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w7, w71, w72, w73, S33);\
MD4STEP_ROUND3_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
}



#define MD4_STEPS_SHORT() { \
MD4STEP_ROUND1 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S11);\
MD4STEP_ROUND1 (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, w1, w11, w12, w13, S12);\
MD4STEP_ROUND1 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w2, w21, w22, w23, S13);\
MD4STEP_ROUND1 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w3, w31, w32, w33, S14);\
MD4STEP_ROUND1_NULL (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, S11);\
MD4STEP_ROUND1_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S12);\
MD4STEP_ROUND1_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S13);\
MD4STEP_ROUND1_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S14);\
MD4STEP_ROUND1_NULL (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, S11);\
MD4STEP_ROUND1_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S12);\
MD4STEP_ROUND1_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S13);\
MD4STEP_ROUND1_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S14);\
MD4STEP_ROUND1_NULL (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, S11);\
MD4STEP_ROUND1_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S12);\
MD4STEP_ROUND1 (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, w14, w141, w142, w143, S13); \
MD4STEP_ROUND1_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S14); \
\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S21);\
MD4STEP_ROUND2_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4,  S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w1, w11, w12, w13, S21);\
MD4STEP_ROUND2_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w2, w21, w22, w23, S21);\
MD4STEP_ROUND2_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w14, w141, w142, w143, S24);\
MD4STEP_ROUND2 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4,  w3, w31, w32, w33,S21);\
MD4STEP_ROUND2_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S22);\
MD4STEP_ROUND2_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S23);\
MD4STEP_ROUND2_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S24);\
\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w0, w01, w02, w03, S31);\
MD4STEP_ROUND3_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S33);\
MD4STEP_ROUND3_NULL(b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w2, w21, w22, w23, S31);\
MD4STEP_ROUND3_NULL(d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S33);\
MD4STEP_ROUND3 (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, w14, w141, w142, w143, S34);\
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w1, w11, w12, w13, S31);\
MD4STEP_ROUND3_NULL (d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S33);\
MD4STEP_ROUND3_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
}


#define MD4_STEPS_SHORT_LAST() { \
MD4STEP_ROUND3 (a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, w3, w31, w32, w33,S31);\
MD4STEP_ROUND3_NULL(d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, c, c2, c3, c4, S32);\
MD4STEP_ROUND3_NULL (c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, b, b2, b3, b4, S33);\
MD4STEP_ROUND3_NULL (b, b2, b3, b4, c, c2, c3, c4, d, d2, d3, d4, a, a2, a3, a4, S34);\
}




#endif
