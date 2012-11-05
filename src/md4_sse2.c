/*
 * md4_sse2.c
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

#include <emmintrin.h>
#include <stdio.h>
#include <string.h>
#include "err.h"
#include "hashinterface.h"
#include "md4_sse2.h"

static __m128i AR;

#define ROTATE_RIGHT(x, n) (((x) >> (n)) | ((x) << (32-(n))))
#define Ca 0x67452301
#define Cb 0xefcdab89
#define Cc 0x98badcfe
#define Cd 0x10325476
#define H(x, y, z)   ((x) ^ (y) ^ (z))
#define S31 3
#define S32 9
#define S33 11
#define S34 15
#define REVERSE_MD4STEP_ROUND3(a, b, c, d, x, s) a= ROTATE_RIGHT(a, s) - 0x6ed9eba1 - x - H(b, c, d);

void MD4_PREPARE_OPT(void)
{
    unsigned char hex1[16];
    memcpy(hex1,hash_list->hash,4);
    unsigned int A,B,C,D;
    memcpy(&A, hex1, 4);
    memcpy(hex1,hash_list->hash+4,4);
    memcpy(&B, hex1, 4);
    memcpy(hex1,hash_list->hash+8,4);
    memcpy(&C, hex1, 4);
    memcpy(hex1,hash_list->hash+12,4);
    memcpy(&D, hex1, 4);
    A=(A-Ca);
    B=(B-Cb);
    C=(C-Cc);
    D=(D-Cd);
    REVERSE_MD4STEP_ROUND3 (B, C, D, A, 0,      S34);
    int ARAW=B;
    //memcpy(&ARAW,hash_list->hash,4);
    //ARAW = ARAW-0x67452301;
    AR = _mm_set_epi32(ARAW, ARAW, ARAW, ARAW);
}


hash_stat MD4_SSE(char *plains[16], char *hash[16], int lens[16])
{

    __m128i w0, w1, w2, w3, w4, w5, w6, w7, w14;
    __m128i w01, w11, w21, w31, w41, w51, w61, w71, w141;
    __m128i w02, w12, w22, w32, w42, w52, w62, w72, w142;


    __m128i a, b, c, d, AC, AD;
    __m128i a2, b2, c2, d2, tmp1, tmp1_2, tmp1_3;
    __m128i a3, b3, c3, d3 ;

    __m128i A,B,C,D;
    int i;

#define udata1 ((UINT4 *)plains[0])
#define udata2 ((UINT4 *)plains[1])
#define udata3 ((UINT4 *)plains[2])
#define udata4 ((UINT4 *)plains[3])
#define udata5 ((UINT4 *)plains[4])
#define udata6 ((UINT4 *)plains[5])
#define udata7 ((UINT4 *)plains[6])
#define udata8 ((UINT4 *)plains[7])
#define udata9 ((UINT4 *)plains[8])
#define udata10 ((UINT4 *)plains[9])
#define udata11 ((UINT4 *)plains[10])
#define udata12 ((UINT4 *)plains[11])



#define _mm_extract_epi32(x, imm) \
        _mm_cvtsi128_si32(_mm_srli_si128((x), (imm)<<2))


    AC = _mm_set1_epi32(0x5a827999);
    AD = _mm_set1_epi32(0x6ed9eba1);

    for (i = 0; i < 12; i++) plains[i][lens[i]]=0x80;

    w0 = _mm_set_epi32(udata1[0],udata2[0],udata3[0],udata4[0]);
    w01 = _mm_set_epi32(udata5[0],udata6[0],udata7[0],udata8[0]);
    w02 = _mm_set_epi32(udata9[0],udata10[0],udata11[0],udata12[0]);
    w1 = _mm_set_epi32(udata1[1],udata2[1],udata3[1],udata4[1]);
    w11 = _mm_set_epi32(udata5[1],udata6[1],udata7[1],udata8[1]);
    w12 = _mm_set_epi32(udata9[1],udata10[1],udata11[1],udata12[1]);
    w2 = _mm_set_epi32(udata1[2],udata2[2],udata3[2],udata7[2]);
    w21 = _mm_set_epi32(udata5[2],udata6[2],udata7[2],udata8[2]);
    w22 = _mm_set_epi32(udata9[2],udata10[2],udata11[2],udata12[2]);
    w3 = _mm_set_epi32(udata1[3],udata2[3],udata3[3],udata7[3]);
    w31 = _mm_set_epi32(udata5[3],udata6[3],udata7[3],udata8[3]);
    w32 = _mm_set_epi32(udata9[3],udata10[3],udata11[3],udata12[3]);
    w4 = _mm_set_epi32(udata1[4],udata2[4],udata3[4],udata7[4]);
    w41 = _mm_set_epi32(udata5[4],udata6[4],udata7[4],udata8[4]);
    w42 = _mm_set_epi32(udata9[4],udata10[4],udata11[4],udata12[4]);


    w5 = _mm_set_epi32(udata1[5],udata2[5],udata3[5],udata7[5]);
    w51 = _mm_set_epi32(udata5[5],udata6[5],udata7[5],udata8[5]);
    w52 = _mm_set_epi32(udata9[5],udata10[5],udata11[5],udata12[5]);
    w6 = _mm_set_epi32(udata1[6],udata2[6],udata3[6],udata7[6]);
    w61 = _mm_set_epi32(udata5[6],udata6[6],udata7[6],udata8[6]);
    w62 = _mm_set_epi32(udata9[6],udata10[6],udata11[6],udata12[6]);
    w7 = _mm_set_epi32(udata1[7],udata2[7],udata3[7],udata7[7]);
    w71 = _mm_set_epi32(udata5[7],udata6[7],udata7[7],udata8[7]);
    w72 = _mm_set_epi32(udata9[7],udata10[7],udata11[7],udata12[7]);




    w14 = _mm_set_epi32(lens[0]<<3,lens[1]<<3,lens[2]<<3,lens[3]<<3);
    w141 = _mm_set_epi32(lens[4]<<3,lens[5]<<3,lens[6]<<3,lens[7]<<3);
    w142 = _mm_set_epi32(lens[8]<<3,lens[9]<<3,lens[10]<<3,lens[11]<<3);

    a = _mm_set1_epi32(Ca);
    a2 = _mm_set1_epi32(Ca);
    a3 = _mm_set1_epi32(Ca);
    b = _mm_set1_epi32(Cb); 
    b2 = _mm_set1_epi32(Cb);
    b3 = _mm_set1_epi32(Cb);
    c = _mm_set1_epi32(Cc); 
    c2 = _mm_set1_epi32(Cc);
    c3 = _mm_set1_epi32(Cc);
    d = _mm_set1_epi32(Cd); 
    d2 = _mm_set1_epi32(Cd);
    d3 = _mm_set1_epi32(Cd);
    A = _mm_set1_epi32(Ca);
    B = _mm_set1_epi32(Cb); 
    C = _mm_set1_epi32(Cc); 
    D = _mm_set1_epi32(Cd); 

    MD4_STEPS();
    if ((cpu_optimize_single==1)&&(!hash_list->next))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }
    MD4_STEPS_LAST();

    a = _mm_add_epi32(a,A);
    b = _mm_add_epi32(b,B);
    c = _mm_add_epi32(c,C);
    d = _mm_add_epi32(d,D);
    a2 = _mm_add_epi32(a2,A);
    b2 = _mm_add_epi32(b2,B);
    c2 = _mm_add_epi32(c2,C);
    d2 = _mm_add_epi32(d2,D);
    a3 = _mm_add_epi32(a3,A);
    b3 = _mm_add_epi32(b3,B);
    c3 = _mm_add_epi32(c3,C);
    d3 = _mm_add_epi32(d3,D);


#define udigest1 ((UINT4 *)hash[0])
#define udigest2 ((UINT4 *)hash[1])
#define udigest3 ((UINT4 *)hash[2])
#define udigest4 ((UINT4 *)hash[3])
#define udigest5 ((UINT4 *)hash[4])
#define udigest6 ((UINT4 *)hash[5])
#define udigest7 ((UINT4 *)hash[6])
#define udigest8 ((UINT4 *)hash[7])
#define udigest9 ((UINT4 *)hash[8])
#define udigest10 ((UINT4 *)hash[9])
#define udigest11 ((UINT4 *)hash[10])
#define udigest12 ((UINT4 *)hash[11])

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 3),_mm_extract_epi32(c, 3),_mm_extract_epi32(b, 3),_mm_extract_epi32(a, 3));
    _mm_store_si128((__m128i *)udigest1,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 3),_mm_extract_epi32(c2, 3),_mm_extract_epi32(b2, 3),_mm_extract_epi32(a2, 3));
    _mm_store_si128((__m128i *)udigest5,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 3),_mm_extract_epi32(c3, 3),_mm_extract_epi32(b3, 3),_mm_extract_epi32(a3, 3));
    _mm_store_si128((__m128i *)udigest9,tmp1);


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 2),_mm_extract_epi32(c, 2),_mm_extract_epi32(b, 2),_mm_extract_epi32(a, 2));
    _mm_store_si128((__m128i *)udigest2,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 2),_mm_extract_epi32(c2, 2),_mm_extract_epi32(b2, 2),_mm_extract_epi32(a2, 2));
    _mm_store_si128((__m128i *)udigest6,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 2),_mm_extract_epi32(c3, 2),_mm_extract_epi32(b3, 2),_mm_extract_epi32(a3, 2));
    _mm_store_si128((__m128i *)udigest10,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 1),_mm_extract_epi32(c, 1),_mm_extract_epi32(b, 1),_mm_extract_epi32(a, 1));
    _mm_store_si128((__m128i *)udigest3,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 1),_mm_extract_epi32(c2, 1),_mm_extract_epi32(b2, 1),_mm_extract_epi32(a2, 1));
    _mm_store_si128((__m128i *)udigest7,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 1),_mm_extract_epi32(c3, 1),_mm_extract_epi32(b3, 1),_mm_extract_epi32(a3, 1));
    _mm_store_si128((__m128i *)udigest11,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 0),_mm_extract_epi32(c, 0),_mm_extract_epi32(b, 0),_mm_extract_epi32(a, 0));
    _mm_store_si128((__m128i *)udigest4,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 0),_mm_extract_epi32(c2, 0),_mm_extract_epi32(b2, 0),_mm_extract_epi32(a2, 0));
    _mm_store_si128((__m128i *)udigest8,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 0),_mm_extract_epi32(c3, 0),_mm_extract_epi32(b3, 0),_mm_extract_epi32(a3, 0));
    _mm_store_si128((__m128i *)udigest12,tmp1);


    for (i = 0; i < 12; i+=4)
    {
	*(plains[i]+lens[i])=0x0;
	*(plains[i+1]+lens[i+1])=0x0;
	*(plains[i+2]+lens[i+2])=0x0;
	*(plains[i+3]+lens[i+3])=0x0;
    }
    return hash_ok;
}


hash_stat MD4_SSE_SHORT(char *plains[16], char *hash[16], int lens[16])
{

    __m128i w0, w1, w2, w3, w14;
    __m128i w01, w11, w21, w31, w141;
    __m128i w02, w12, w22, w32, w142;


    __m128i a, b, c, d, AC, AD;
    __m128i a2, b2, c2, d2, tmp1, tmp1_2, tmp1_3;
    __m128i a3, b3, c3, d3 ;

    __m128i A,B,C,D;
    int i;


#define udata1 ((UINT4 *)plains[0])
#define udata2 ((UINT4 *)plains[1])
#define udata3 ((UINT4 *)plains[2])
#define udata4 ((UINT4 *)plains[3])
#define udata5 ((UINT4 *)plains[4])
#define udata6 ((UINT4 *)plains[5])
#define udata7 ((UINT4 *)plains[6])
#define udata8 ((UINT4 *)plains[7])
#define udata9 ((UINT4 *)plains[8])
#define udata10 ((UINT4 *)plains[9])
#define udata11 ((UINT4 *)plains[10])
#define udata12 ((UINT4 *)plains[11])
#define udata13 ((UINT4 *)plains[12])
#define udata14 ((UINT4 *)plains[13])
#define udata15 ((UINT4 *)plains[14])
#define udata16 ((UINT4 *)plains[15])



#define _mm_extract_epi32(x, imm) \
        _mm_cvtsi128_si32(_mm_srli_si128((x), (imm)<<2))


    AC = _mm_set1_epi32(0x5a827999);
    AD = _mm_set1_epi32(0x6ed9eba1);

    for (i = 0; i < 12; i++)
    {
	plains[i][lens[i]]=0x80;
    }

    w0 = _mm_set_epi32(udata1[0],udata2[0],udata3[0],udata4[0]);
    w01 = _mm_set_epi32(udata5[0],udata6[0],udata7[0],udata8[0]);
    w02 = _mm_set_epi32(udata9[0],udata10[0],udata11[0],udata12[0]);
    w1 = _mm_set_epi32(udata1[1],udata2[1],udata3[1],udata4[1]);
    w11 = _mm_set_epi32(udata5[1],udata6[1],udata7[1],udata8[1]);
    w12 = _mm_set_epi32(udata9[1],udata10[1],udata11[1],udata12[1]);
    w2 = _mm_set_epi32(udata1[2],udata2[2],udata3[2],udata7[2]);
    w21 = _mm_set_epi32(udata5[2],udata6[2],udata7[2],udata8[2]);
    w22 = _mm_set_epi32(udata9[2],udata10[2],udata11[2],udata12[2]);
    w3 = _mm_set_epi32(udata1[3],udata2[3],udata3[3],udata7[3]);
    w31 = _mm_set_epi32(udata5[3],udata6[3],udata7[3],udata8[3]);
    w32 = _mm_set_epi32(udata9[3],udata10[3],udata11[3],udata12[3]);


    w14 = _mm_set_epi32(lens[0]<<3,lens[1]<<3,lens[2]<<3,lens[3]<<3);
    w141 = _mm_set_epi32(lens[4]<<3,lens[5]<<3,lens[6]<<3,lens[7]<<3);
    w142 = _mm_set_epi32(lens[8]<<3,lens[9]<<3,lens[10]<<3,lens[11]<<3);


    A = _mm_set1_epi32(Ca);
    B = _mm_set1_epi32(Cb); 
    C = _mm_set1_epi32(Cc); 
    D = _mm_set1_epi32(Cd); 

    a = A;
    a2 = A;
    a3 = A;
    b = B; 
    b2 = B;
    b3 = B;
    c = C; 
    c2 = C;
    c3 = C;
    d = D; 
    d2 = D;
    d3 = D;

    MD4_STEPS_SHORT();
    if ((cpu_optimize_single==1)&&(!hash_list->next))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }
    MD4_STEPS_SHORT_LAST();
    
    a = _mm_add_epi32(a,A);
    b = _mm_add_epi32(b,B);
    c = _mm_add_epi32(c,C);
    d = _mm_add_epi32(d,D);
    a2 = _mm_add_epi32(a2,A);
    b2 = _mm_add_epi32(b2,B);
    c2 = _mm_add_epi32(c2,C);
    d2 = _mm_add_epi32(d2,D);
    a3 = _mm_add_epi32(a3,A);
    b3 = _mm_add_epi32(b3,B);
    c3 = _mm_add_epi32(c3,C);
    d3 = _mm_add_epi32(d3,D);


#define udigest1 ((UINT4 *)hash[0])
#define udigest2 ((UINT4 *)hash[1])
#define udigest3 ((UINT4 *)hash[2])
#define udigest4 ((UINT4 *)hash[3])
#define udigest5 ((UINT4 *)hash[4])
#define udigest6 ((UINT4 *)hash[5])
#define udigest7 ((UINT4 *)hash[6])
#define udigest8 ((UINT4 *)hash[7])
#define udigest9 ((UINT4 *)hash[8])
#define udigest10 ((UINT4 *)hash[9])
#define udigest11 ((UINT4 *)hash[10])
#define udigest12 ((UINT4 *)hash[11])
#define udigest13 ((UINT4 *)hash[12])
#define udigest14 ((UINT4 *)hash[13])
#define udigest15 ((UINT4 *)hash[14])
#define udigest16 ((UINT4 *)hash[15])


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 3),_mm_extract_epi32(c, 3),_mm_extract_epi32(b, 3),_mm_extract_epi32(a, 3));
    _mm_store_si128((__m128i *)udigest1,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 3),_mm_extract_epi32(c2, 3),_mm_extract_epi32(b2, 3),_mm_extract_epi32(a2, 3));
    _mm_store_si128((__m128i *)udigest5,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 3),_mm_extract_epi32(c3, 3),_mm_extract_epi32(b3, 3),_mm_extract_epi32(a3, 3));
    _mm_store_si128((__m128i *)udigest9,tmp1);


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 2),_mm_extract_epi32(c, 2),_mm_extract_epi32(b, 2),_mm_extract_epi32(a, 2));
    _mm_store_si128((__m128i *)udigest2,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 2),_mm_extract_epi32(c2, 2),_mm_extract_epi32(b2, 2),_mm_extract_epi32(a2, 2));
    _mm_store_si128((__m128i *)udigest6,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 2),_mm_extract_epi32(c3, 2),_mm_extract_epi32(b3, 2),_mm_extract_epi32(a3, 2));
    _mm_store_si128((__m128i *)udigest10,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 1),_mm_extract_epi32(c, 1),_mm_extract_epi32(b, 1),_mm_extract_epi32(a, 1));
    _mm_store_si128((__m128i *)udigest3,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 1),_mm_extract_epi32(c2, 1),_mm_extract_epi32(b2, 1),_mm_extract_epi32(a2, 1));
    _mm_store_si128((__m128i *)udigest7,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 1),_mm_extract_epi32(c3, 1),_mm_extract_epi32(b3, 1),_mm_extract_epi32(a3, 1));
    _mm_store_si128((__m128i *)udigest11,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 0),_mm_extract_epi32(c, 0),_mm_extract_epi32(b, 0),_mm_extract_epi32(a, 0));
    _mm_store_si128((__m128i *)udigest4,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 0),_mm_extract_epi32(c2, 0),_mm_extract_epi32(b2, 0),_mm_extract_epi32(a2, 0));
    _mm_store_si128((__m128i *)udigest8,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 0),_mm_extract_epi32(c3, 0),_mm_extract_epi32(b3, 0),_mm_extract_epi32(a3, 0));
    _mm_store_si128((__m128i *)udigest12,tmp1);


    for (i = 0; i < 12; i++)
    {
	*(plains[i]+lens[i])=0x0;
    }
    return hash_ok;
}


hash_stat MD4_SSE_FIXED(char *plains[16], char *hash[16], int lens)
{

    __m128i w0, w1, w2, w3, w4, w5, w6, w7, w14;
    __m128i w01, w11, w21, w31, w41, w51, w61, w71, w141;
    __m128i w02, w12, w22, w32, w42, w52, w62, w72, w142;


    __m128i a, b, c, d, AC, AD;
    __m128i a2, b2, c2, d2, tmp1, tmp1_2, tmp1_3;
    __m128i a3, b3, c3, d3 ;

    __m128i A,B,C,D;
    int i;


#define udata1 ((UINT4 *)plains[0])
#define udata2 ((UINT4 *)plains[1])
#define udata3 ((UINT4 *)plains[2])
#define udata4 ((UINT4 *)plains[3])
#define udata5 ((UINT4 *)plains[4])
#define udata6 ((UINT4 *)plains[5])
#define udata7 ((UINT4 *)plains[6])
#define udata8 ((UINT4 *)plains[7])
#define udata9 ((UINT4 *)plains[8])
#define udata10 ((UINT4 *)plains[9])
#define udata11 ((UINT4 *)plains[10])
#define udata12 ((UINT4 *)plains[11])
#define udata13 ((UINT4 *)plains[12])
#define udata14 ((UINT4 *)plains[13])
#define udata15 ((UINT4 *)plains[14])
#define udata16 ((UINT4 *)plains[15])



#define _mm_extract_epi32(x, imm) \
        _mm_cvtsi128_si32(_mm_srli_si128((x), (imm)<<2))


    AC = _mm_set1_epi32(0x5a827999);
    AD = _mm_set1_epi32(0x6ed9eba1);

    for (i = 0; i < 12; i+=4)
    {
	plains[i][lens]=0x80;
	plains[i+1][lens]=0x80;
	plains[i+2][lens]=0x80;
	plains[i+3][lens]=0x80;

    }

    w0 = _mm_set_epi32(udata1[0],udata2[0],udata3[0],udata4[0]);
    w01 = _mm_set_epi32(udata5[0],udata6[0],udata7[0],udata8[0]);
    w02 = _mm_set_epi32(udata9[0],udata10[0],udata11[0],udata12[0]);
    w1 = _mm_set_epi32(udata1[1],udata2[1],udata3[1],udata4[1]);
    w11 = _mm_set_epi32(udata5[1],udata6[1],udata7[1],udata8[1]);
    w12 = _mm_set_epi32(udata9[1],udata10[1],udata11[1],udata12[1]);
    w2 = _mm_set_epi32(udata1[2],udata2[2],udata3[2],udata7[2]);
    w21 = _mm_set_epi32(udata5[2],udata6[2],udata7[2],udata8[2]);
    w22 = _mm_set_epi32(udata9[2],udata10[2],udata11[2],udata12[2]);
    w3 = _mm_set_epi32(udata1[3],udata2[3],udata3[3],udata7[3]);
    w31 = _mm_set_epi32(udata5[3],udata6[3],udata7[3],udata8[3]);
    w32 = _mm_set_epi32(udata9[3],udata10[3],udata11[3],udata12[3]);
    if (lens<15)
    {
	w4=w41=w42=w5=w51=w52=w6=w61=w62=w7=w71=w72=_mm_set_epi32(0,0,0,0);
    }
    else
    {
	w4 = _mm_set_epi32(udata1[4],udata2[4],udata3[4],udata7[4]);
	w41 = _mm_set_epi32(udata5[4],udata6[4],udata7[4],udata8[4]);
	w42 = _mm_set_epi32(udata9[4],udata10[4],udata11[4],udata12[4]);
	w5 = _mm_set_epi32(udata1[5],udata2[5],udata3[5],udata7[5]);
	w51 = _mm_set_epi32(udata5[5],udata6[5],udata7[5],udata8[5]);
	w52 = _mm_set_epi32(udata9[5],udata10[5],udata11[5],udata12[5]);
	w6 = _mm_set_epi32(udata1[6],udata2[6],udata3[6],udata7[6]);
	w61 = _mm_set_epi32(udata5[6],udata6[6],udata7[6],udata8[6]);
	w62 = _mm_set_epi32(udata9[6],udata10[6],udata11[6],udata12[6]);
	w7 = _mm_set_epi32(udata1[7],udata2[7],udata3[7],udata7[7]);
	w71 = _mm_set_epi32(udata5[7],udata6[7],udata7[7],udata8[7]);
	w72 = _mm_set_epi32(udata9[7],udata10[7],udata11[7],udata12[7]);
    }


    int nl=lens<<3;
    w14 = _mm_set_epi32(nl,nl,nl,nl);
    w141 = _mm_set_epi32(nl,nl,nl,nl);
    w142 = _mm_set_epi32(nl,nl,nl,nl);

    a = _mm_set1_epi32(Ca);
    a2 = _mm_set1_epi32(Ca);
    a3 = _mm_set1_epi32(Ca);
    b = _mm_set1_epi32(Cb); 
    b2 = _mm_set1_epi32(Cb);
    b3 = _mm_set1_epi32(Cb);
    c = _mm_set1_epi32(Cc); 
    c2 = _mm_set1_epi32(Cc);
    c3 = _mm_set1_epi32(Cc);
    d = _mm_set1_epi32(Cd); 
    d2 = _mm_set1_epi32(Cd);
    d3 = _mm_set1_epi32(Cd);
    A = _mm_set1_epi32(Ca);
    B = _mm_set1_epi32(Cb); 
    C = _mm_set1_epi32(Cc); 
    D = _mm_set1_epi32(Cd); 

    MD4_STEPS();
    if ((cpu_optimize_single==1)&&(!hash_list->next))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }
    MD4_STEPS_LAST();

    a = _mm_add_epi32(a,A);
    b = _mm_add_epi32(b,B);
    c = _mm_add_epi32(c,C);
    d = _mm_add_epi32(d,D);
    a2 = _mm_add_epi32(a2,A);
    b2 = _mm_add_epi32(b2,B);
    c2 = _mm_add_epi32(c2,C);
    d2 = _mm_add_epi32(d2,D);
    a3 = _mm_add_epi32(a3,A);
    b3 = _mm_add_epi32(b3,B);
    c3 = _mm_add_epi32(c3,C);
    d3 = _mm_add_epi32(d3,D);


#define udigest1 ((UINT4 *)hash[0])
#define udigest2 ((UINT4 *)hash[1])
#define udigest3 ((UINT4 *)hash[2])
#define udigest4 ((UINT4 *)hash[3])
#define udigest5 ((UINT4 *)hash[4])
#define udigest6 ((UINT4 *)hash[5])
#define udigest7 ((UINT4 *)hash[6])
#define udigest8 ((UINT4 *)hash[7])
#define udigest9 ((UINT4 *)hash[8])
#define udigest10 ((UINT4 *)hash[9])
#define udigest11 ((UINT4 *)hash[10])
#define udigest12 ((UINT4 *)hash[11])
#define udigest13 ((UINT4 *)hash[12])
#define udigest14 ((UINT4 *)hash[13])
#define udigest15 ((UINT4 *)hash[14])
#define udigest16 ((UINT4 *)hash[15])


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 3),_mm_extract_epi32(c, 3),_mm_extract_epi32(b, 3),_mm_extract_epi32(a, 3));
    _mm_store_si128((__m128i *)udigest1,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 3),_mm_extract_epi32(c2, 3),_mm_extract_epi32(b2, 3),_mm_extract_epi32(a2, 3));
    _mm_store_si128((__m128i *)udigest5,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 3),_mm_extract_epi32(c3, 3),_mm_extract_epi32(b3, 3),_mm_extract_epi32(a3, 3));
    _mm_store_si128((__m128i *)udigest9,tmp1);


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 2),_mm_extract_epi32(c, 2),_mm_extract_epi32(b, 2),_mm_extract_epi32(a, 2));
    _mm_store_si128((__m128i *)udigest2,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 2),_mm_extract_epi32(c2, 2),_mm_extract_epi32(b2, 2),_mm_extract_epi32(a2, 2));
    _mm_store_si128((__m128i *)udigest6,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 2),_mm_extract_epi32(c3, 2),_mm_extract_epi32(b3, 2),_mm_extract_epi32(a3, 2));
    _mm_store_si128((__m128i *)udigest10,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 1),_mm_extract_epi32(c, 1),_mm_extract_epi32(b, 1),_mm_extract_epi32(a, 1));
    _mm_store_si128((__m128i *)udigest3,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 1),_mm_extract_epi32(c2, 1),_mm_extract_epi32(b2, 1),_mm_extract_epi32(a2, 1));
    _mm_store_si128((__m128i *)udigest7,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 1),_mm_extract_epi32(c3, 1),_mm_extract_epi32(b3, 1),_mm_extract_epi32(a3, 1));
    _mm_store_si128((__m128i *)udigest11,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 0),_mm_extract_epi32(c, 0),_mm_extract_epi32(b, 0),_mm_extract_epi32(a, 0));
    _mm_store_si128((__m128i *)udigest4,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 0),_mm_extract_epi32(c2, 0),_mm_extract_epi32(b2, 0),_mm_extract_epi32(a2, 0));
    _mm_store_si128((__m128i *)udigest8,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 0),_mm_extract_epi32(c3, 0),_mm_extract_epi32(b3, 0),_mm_extract_epi32(a3, 0));
    _mm_store_si128((__m128i *)udigest12,tmp1);


    for (i = 0; i < 12; i+=4)
    {
	*(plains[i]+lens)=0x0;
	*(plains[i+1]+lens)=0x0;
	*(plains[i+2]+lens)=0x0;
	*(plains[i+3]+lens)=0x0;
    }
    return hash_ok;
}


hash_stat MD4_SSE_SHORT_FIXED(char *plains[16], char *hash[16], int lens)
{

    __m128i w0, w1, w2, w3, w14;
    __m128i w01, w11, w21, w31, w141;
    __m128i w02, w12, w22, w32, w142;


    __m128i a, b, c, d, AC, AD;
    __m128i a2, b2, c2, d2, tmp1, tmp1_2, tmp1_3;
    __m128i a3, b3, c3, d3 ;

    __m128i A,B,C,D;
    int i;


#define udata1 ((UINT4 *)plains[0])
#define udata2 ((UINT4 *)plains[1])
#define udata3 ((UINT4 *)plains[2])
#define udata4 ((UINT4 *)plains[3])
#define udata5 ((UINT4 *)plains[4])
#define udata6 ((UINT4 *)plains[5])
#define udata7 ((UINT4 *)plains[6])
#define udata8 ((UINT4 *)plains[7])
#define udata9 ((UINT4 *)plains[8])
#define udata10 ((UINT4 *)plains[9])
#define udata11 ((UINT4 *)plains[10])
#define udata12 ((UINT4 *)plains[11])
#define udata13 ((UINT4 *)plains[12])
#define udata14 ((UINT4 *)plains[13])
#define udata15 ((UINT4 *)plains[14])
#define udata16 ((UINT4 *)plains[15])



#define _mm_extract_epi32(x, imm) \
        _mm_cvtsi128_si32(_mm_srli_si128((x), (imm)<<2))


    AC = _mm_set1_epi32(0x5a827999);
    AD = _mm_set1_epi32(0x6ed9eba1);

    for (i = 0; i < 12; i+=4)
    {
	plains[i][lens]=0x80;
	plains[i+1][lens]=0x80;
	plains[i+2][lens]=0x80;
	plains[i+3][lens]=0x80;
    }


    w0 = _mm_set_epi32(udata1[0],udata2[0],udata3[0],udata4[0]);
    w01 = _mm_set_epi32(udata5[0],udata6[0],udata7[0],udata8[0]);
    w02 = _mm_set_epi32(udata9[0],udata10[0],udata11[0],udata12[0]);
    w1 = _mm_set_epi32(udata1[1],udata2[1],udata3[1],udata4[1]);
    w11 = _mm_set_epi32(udata5[1],udata6[1],udata7[1],udata8[1]);
    w12 = _mm_set_epi32(udata9[1],udata10[1],udata11[1],udata12[1]);
    w2 = _mm_set_epi32(udata1[2],udata2[2],udata3[2],udata7[2]);
    w21 = _mm_set_epi32(udata5[2],udata6[2],udata7[2],udata8[2]);
    w22 = _mm_set_epi32(udata9[2],udata10[2],udata11[2],udata12[2]);
    w3 = _mm_set_epi32(udata1[3],udata2[3],udata3[3],udata7[3]);
    w31 = _mm_set_epi32(udata5[3],udata6[3],udata7[3],udata8[3]);
    w32 = _mm_set_epi32(udata9[3],udata10[3],udata11[3],udata12[3]);


    int nlens=lens<<3;
    w14 = _mm_set_epi32(nlens,nlens,nlens,nlens);
    w141 = _mm_set_epi32(nlens,nlens,nlens,nlens);
    w142 = _mm_set_epi32(nlens,nlens,nlens,nlens);


    A = _mm_set1_epi32(Ca);
    B = _mm_set1_epi32(Cb); 
    C = _mm_set1_epi32(Cc); 
    D = _mm_set1_epi32(Cd); 

    a = A;
    a2 = A;
    a3 = A;
    b = B; 
    b2 = B;
    b3 = B;
    c = C; 
    c2 = C;
    c3 = C;
    d = D; 
    d2 = D;
    d3 = D;

    MD4_STEPS_SHORT();
    if ((cpu_optimize_single==1)&&(!hash_list->next))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(AR, b3));
	if ((r1|r2|r3)==0) return hash_err;
    }
    MD4_STEPS_SHORT_LAST();

    a = _mm_add_epi32(a,A);
    b = _mm_add_epi32(b,B);
    c = _mm_add_epi32(c,C);
    d = _mm_add_epi32(d,D);
    a2 = _mm_add_epi32(a2,A);
    b2 = _mm_add_epi32(b2,B);
    c2 = _mm_add_epi32(c2,C);
    d2 = _mm_add_epi32(d2,D);
    a3 = _mm_add_epi32(a3,A);
    b3 = _mm_add_epi32(b3,B);
    c3 = _mm_add_epi32(c3,C);
    d3 = _mm_add_epi32(d3,D);

#define udigest1 ((UINT4 *)hash[0])
#define udigest2 ((UINT4 *)hash[1])
#define udigest3 ((UINT4 *)hash[2])
#define udigest4 ((UINT4 *)hash[3])
#define udigest5 ((UINT4 *)hash[4])
#define udigest6 ((UINT4 *)hash[5])
#define udigest7 ((UINT4 *)hash[6])
#define udigest8 ((UINT4 *)hash[7])
#define udigest9 ((UINT4 *)hash[8])
#define udigest10 ((UINT4 *)hash[9])
#define udigest11 ((UINT4 *)hash[10])
#define udigest12 ((UINT4 *)hash[11])
#define udigest13 ((UINT4 *)hash[12])
#define udigest14 ((UINT4 *)hash[13])
#define udigest15 ((UINT4 *)hash[14])
#define udigest16 ((UINT4 *)hash[15])


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 3),_mm_extract_epi32(c, 3),_mm_extract_epi32(b, 3),_mm_extract_epi32(a, 3));
    _mm_store_si128((__m128i *)udigest1,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 3),_mm_extract_epi32(c2, 3),_mm_extract_epi32(b2, 3),_mm_extract_epi32(a2, 3));
    _mm_store_si128((__m128i *)udigest5,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 3),_mm_extract_epi32(c3, 3),_mm_extract_epi32(b3, 3),_mm_extract_epi32(a3, 3));
    _mm_store_si128((__m128i *)udigest9,tmp1);


    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 2),_mm_extract_epi32(c, 2),_mm_extract_epi32(b, 2),_mm_extract_epi32(a, 2));
    _mm_store_si128((__m128i *)udigest2,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 2),_mm_extract_epi32(c2, 2),_mm_extract_epi32(b2, 2),_mm_extract_epi32(a2, 2));
    _mm_store_si128((__m128i *)udigest6,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 2),_mm_extract_epi32(c3, 2),_mm_extract_epi32(b3, 2),_mm_extract_epi32(a3, 2));
    _mm_store_si128((__m128i *)udigest10,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 1),_mm_extract_epi32(c, 1),_mm_extract_epi32(b, 1),_mm_extract_epi32(a, 1));
    _mm_store_si128((__m128i *)udigest3,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 1),_mm_extract_epi32(c2, 1),_mm_extract_epi32(b2, 1),_mm_extract_epi32(a2, 1));
    _mm_store_si128((__m128i *)udigest7,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 1),_mm_extract_epi32(c3, 1),_mm_extract_epi32(b3, 1),_mm_extract_epi32(a3, 1));
    _mm_store_si128((__m128i *)udigest11,tmp1);

    tmp1 = _mm_set_epi32(_mm_extract_epi32(d, 0),_mm_extract_epi32(c, 0),_mm_extract_epi32(b, 0),_mm_extract_epi32(a, 0));
    _mm_store_si128((__m128i *)udigest4,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d2, 0),_mm_extract_epi32(c2, 0),_mm_extract_epi32(b2, 0),_mm_extract_epi32(a2, 0));
    _mm_store_si128((__m128i *)udigest8,tmp1);
    tmp1 = _mm_set_epi32(_mm_extract_epi32(d3, 0),_mm_extract_epi32(c3, 0),_mm_extract_epi32(b3, 0),_mm_extract_epi32(a3, 0));
    _mm_store_si128((__m128i *)udigest12,tmp1);

    for (i = 0; i < 12; i+=4)
    {
	*(plains[i]+lens)=0x0;
	*(plains[i+1]+lens)=0x0;
	*(plains[i+2]+lens)=0x0;
	*(plains[i+3]+lens)=0x0;
    }
    return hash_ok;
}


#endif
