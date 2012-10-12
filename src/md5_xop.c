/*
 * md5_xop.c
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

#ifdef HAVE_SSE2

#define SSE_SIMULTANEOUS 12
#define ROTATE_RIGHT(x, n) (((x) >> (n)) | ((x) << (32-(n))))
#define ROTATE_LEFT(x, n) (((x) << (n)) | ((x) >> (32-(n))))

#define REVERSE_MD5STEP(a,b,c,d,x,s,AC) a = ROTATE_RIGHT((a - b), s) - x - (AC) - I(b, c, d);


//#include <emmintrin.h>
#include <x86intrin.h>
#include <stdio.h>
#include <string.h>
#include "err.h"
#include "hashinterface.h"
#include "md5_xop.h"



static  __m128i COMP;
void MD5_PREPARE_OPT_XOP(void)
{
    unsigned int A,B,C,D;
    unsigned char hex1[16];

    if (cpu_optimize_single==1)
    {
	memcpy(hex1,hash_list->hash,4);
	memcpy(&A, hex1, 4);
	memcpy(hex1,hash_list->hash+4,4);
	memcpy(&B, hex1, 4);
	memcpy(hex1,hash_list->hash+8,4);
	memcpy(&C, hex1, 4);
	memcpy(hex1,hash_list->hash+12,4);
	memcpy(&D, hex1, 4);
	A=(A-0x67452301);
	B=(B-0xefcdab89);
	C=(C-0x98badcfe);
	D=(D-0x10325476);
	REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
	REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC63);//x2
	REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC62);
	REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC61);
	REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC60);
	REVERSE_MD5STEP(C, D, A, B, 0,      S43, AC59);
	REVERSE_MD5STEP(D, A, B, C, 0,      S42, AC58);
	REVERSE_MD5STEP(A, B, C, D, 0,      S41, AC57);
	unsigned int ARAW;
	ARAW=A;
	COMP = _mm_set_epi32(ARAW, ARAW, ARAW, ARAW);
    }
    else if (cpu_optimize_single==2)
    {
	memcpy(hex1,hash_list->hash,4);
	memcpy(&A, hex1, 4);
	memcpy(hex1,hash_list->hash+4,4);
	memcpy(&B, hex1, 4);
	memcpy(hex1,hash_list->hash+8,4);
	memcpy(&C, hex1, 4);
	memcpy(hex1,hash_list->hash+12,4);
	memcpy(&D, hex1, 4);
	A=(A-0x67452301);
	B=(B-0xefcdab89);
	C=(C-0x98badcfe);
	D=(D-0x10325476);
	REVERSE_MD5STEP(B, C, D, A, 0,      S44, AC64);
	unsigned int ARAW=B;
        COMP = _mm_set_epi32(ARAW, ARAW, ARAW, ARAW);
    }
}


hash_stat MD5_XOP(unsigned char* pPlain[SSE_SIMULTANEOUS], int nPlainLen[SSE_SIMULTANEOUS], unsigned char* pHash[SSE_SIMULTANEOUS])
{

    __m128i mOne = _mm_set1_epi32(0xFFFFFFFF);

    __m128i mCa = _mm_set1_epi32(Ca);
    __m128i mCb = _mm_set1_epi32(Cb);
    __m128i mCc = _mm_set1_epi32(Cc);
    __m128i mCd = _mm_set1_epi32(Cd);


    __m128i w0_1, w0_2, w0_3, w1_1, w1_2, w1_3, w2_1, w2_2, w2_3, w3_1, w3_2, w3_3, w14_1, w14_2, w14_3;
    __m128i w4_1, w4_2, w4_3, w5_1, w5_2, w5_3, w6_1, w6_2, w6_3, w7_1, w7_2, w7_3;
    __m128i w8_1, w8_2, w8_3, w9_1, w9_2, w9_3, w10_1, w10_2, w10_3;
    __m128i w11_1, w11_2, w11_3,w12_1, w12_2, w12_3,w13_1, w13_2, w13_3;

     __m128i a;
     __m128i b;
     __m128i c;
     __m128i d;
    
    __m128i tmp1, tmp2;
    __m128i a2, b2, c2, d2, tmp1_2, tmp2_2;
    __m128i a3, b3, c3, d3, tmp1_3, tmp2_3;


    int i;

    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
    	*(pPlain[i]+nPlainLen[i])=0x80;
    	*(pPlain[i+1]+nPlainLen[i+1])=0x80;
    	*(pPlain[i+2]+nPlainLen[i+2])=0x80;
    	*(pPlain[i+3]+nPlainLen[i+3])=0x80;
    }

    
#define uData ((UINT4 *)pPlain)
#define udata1 ((UINT4 *)pPlain[0])
#define udata2 ((UINT4 *)pPlain[1])
#define udata3 ((UINT4 *)pPlain[2])
#define udata4 ((UINT4 *)pPlain[3])
#define udata5 ((UINT4 *)pPlain[4])
#define udata6 ((UINT4 *)pPlain[5])
#define udata7 ((UINT4 *)pPlain[6])
#define udata8 ((UINT4 *)pPlain[7])
#define udata9 ((UINT4 *)pPlain[8])
#define udata10 ((UINT4 *)pPlain[9])
#define udata11 ((UINT4 *)pPlain[10])
#define udata12 ((UINT4 *)pPlain[11])
#define udata13 ((UINT4 *)pPlain[12])
#define udata14 ((UINT4 *)pPlain[13])
#define udata15 ((UINT4 *)pPlain[14])
#define udata16 ((UINT4 *)pPlain[15])




#define NEXT_PLAIN (MAX_PLAIN_LEN/4)

    w0_1 = _mm_set_epi32(udata1[0], udata2[0], udata3[0], udata4[0]);
    w0_2 = _mm_set_epi32(udata5[0], udata6[0], udata7[0], udata8[0]);
    w0_3 = _mm_set_epi32(udata9[0], udata10[0], udata11[0], udata12[0]);

    w1_1 = _mm_set_epi32(udata1[1], udata2[1], udata3[1], udata4[1]);
    w1_2 = _mm_set_epi32(udata5[1], udata6[1], udata7[1], udata8[1]);
    w1_3 = _mm_set_epi32(udata9[1], udata10[1], udata11[1], udata12[1]);

    w2_1 = _mm_set_epi32(udata1[2], udata2[2], udata3[2], udata4[2]);
    w2_2 = _mm_set_epi32(udata5[2], udata6[2], udata7[2], udata8[2]);
    w2_3 = _mm_set_epi32(udata9[2], udata10[2], udata11[2], udata12[2]);

    w3_1 = _mm_set_epi32(udata1[3], udata2[3], udata3[3], udata4[3]);
    w3_2 = _mm_set_epi32(udata5[3], udata6[3], udata7[3], udata8[3]);
    w3_3 = _mm_set_epi32(udata9[3], udata10[3], udata11[3], udata12[3]);

    w4_1 = _mm_set_epi32(udata1[4], udata2[4], udata3[4], udata4[4]);
    w4_2 = _mm_set_epi32(udata5[4], udata6[4], udata7[4], udata8[4]);
    w4_3 = _mm_set_epi32(udata9[4], udata10[4], udata11[4], udata12[4]);

    w5_1 = _mm_set_epi32(udata1[5], udata2[5], udata3[5], udata4[5]);
    w5_2 = _mm_set_epi32(udata5[5], udata6[5], udata7[5], udata8[5]);
    w5_3 = _mm_set_epi32(udata9[5], udata10[5], udata11[5], udata12[5]);

    w6_1 = _mm_set_epi32(udata1[6], udata2[6], udata3[6], udata4[6]);
    w6_2 = _mm_set_epi32(udata5[6], udata6[6], udata7[6], udata8[6]);
    w6_3 = _mm_set_epi32(udata9[6], udata10[6], udata11[6], udata12[6]);

    w7_1 = _mm_set_epi32(udata1[7], udata2[7], udata3[7], udata4[7]);
    w7_2 = _mm_set_epi32(udata5[7], udata6[7], udata7[7], udata8[7]);
    w7_3 = _mm_set_epi32(udata9[7], udata10[7], udata11[7], udata12[7]);

    w8_1 = _mm_set_epi32(udata1[8], udata2[8], udata3[8], udata4[8]);
    w8_2 = _mm_set_epi32(udata5[8], udata6[8], udata7[8], udata8[8]);
    w8_3 = _mm_set_epi32(udata9[8], udata10[8], udata11[8], udata12[8]);

    w9_1 = _mm_set_epi32(udata1[9], udata2[9], udata3[9], udata4[9]);
    w9_2 = _mm_set_epi32(udata5[9], udata6[9], udata7[9], udata8[9]);
    w9_3 = _mm_set_epi32(udata9[9], udata10[9], udata11[9], udata12[9]);

    w10_1 = _mm_set_epi32(udata1[10], udata2[10], udata3[10], udata4[10]);
    w10_2 = _mm_set_epi32(udata5[10], udata6[10], udata7[10], udata8[10]);
    w10_3 = _mm_set_epi32(udata9[10], udata10[10], udata11[10], udata12[10]);

    w11_1 = _mm_set_epi32(udata1[11], udata2[11], udata3[11], udata4[11]);
    w11_2 = _mm_set_epi32(udata5[11], udata6[11], udata7[11], udata8[11]);
    w11_3 = _mm_set_epi32(udata9[11], udata10[11], udata11[11], udata12[11]);

    w12_1 = _mm_set_epi32(udata1[12], udata2[12], udata3[12], udata4[12]);
    w12_2 = _mm_set_epi32(udata5[12], udata6[12], udata7[12], udata8[12]);
    w12_3 = _mm_set_epi32(udata9[12], udata10[12], udata11[12], udata12[12]);

    w13_1 = _mm_set_epi32(udata1[13], udata2[13], udata3[13], udata4[13]);
    w13_2 = _mm_set_epi32(udata5[13], udata6[13], udata7[13], udata8[13]);
    w13_3 = _mm_set_epi32(udata9[13], udata10[13], udata11[13], udata12[13]);

    w14_1 = _mm_set_epi32(nPlainLen[0]<<3, nPlainLen[1]<<3, nPlainLen[2]<<3, nPlainLen[3]<<3);
    w14_2 = _mm_set_epi32(nPlainLen[4]<<3, nPlainLen[5]<<3, nPlainLen[6]<<3, nPlainLen[7]<<3);
    w14_3 = _mm_set_epi32(nPlainLen[8]<<3, nPlainLen[9]<<3, nPlainLen[10]<<3, nPlainLen[11]<<3);

    a = mCa;
    a2 = mCa;
    a3 = mCa;

    b = mCb;
    b2 = mCb;
    b3 = mCb;

    c = mCc;
    c2 = mCc;
    c3 = mCc;

    d = mCd;
    d2 = mCd;
    d3 = mCd;

    MD5_STEPS_FULL();

    a = _mm_add_epi32(a,mCa);
    a2 =  _mm_add_epi32(a2,mCa);
    a3 =  _mm_add_epi32(a3,mCa);

    b =  _mm_add_epi32(b,mCb);
    b2 = _mm_add_epi32(b2,mCb);
    b3 = _mm_add_epi32(b3,mCb);

    c =  _mm_add_epi32(c,mCc);
    c2 = _mm_add_epi32(c2,mCc);
    c3 =  _mm_add_epi32(c3,mCc);

    d =  _mm_add_epi32(d,mCd);
    d2 =  _mm_add_epi32(d2,mCd);
    d3 =  _mm_add_epi32(d3,mCd);

#define uDigest ((UINT4 *)pHash)
#define NEXT_HASH (MAX_HASH_LEN/4)
#define udigest1 ((UINT4 *)pHash[0])
#define udigest2 ((UINT4 *)pHash[1])
#define udigest3 ((UINT4 *)pHash[2])
#define udigest4 ((UINT4 *)pHash[3])
#define udigest5 ((UINT4 *)pHash[4])
#define udigest6 ((UINT4 *)pHash[5])
#define udigest7 ((UINT4 *)pHash[6])
#define udigest8 ((UINT4 *)pHash[7])
#define udigest9 ((UINT4 *)pHash[8])
#define udigest10 ((UINT4 *)pHash[9])
#define udigest11 ((UINT4 *)pHash[10])
#define udigest12 ((UINT4 *)pHash[11])
#define udigest13 ((UINT4 *)pHash[12])
#define udigest14 ((UINT4 *)pHash[13])
#define udigest15 ((UINT4 *)pHash[14])
#define udigest16 ((UINT4 *)pHash[15])




//#define _mm_extract_epi32(x, imm) \
//	_mm_cvtsi128_si32(_mm_srli_si128((x), (imm<<2)))


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


// Revert zeros
    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen[i])=0x00;
	*(pPlain[i+1]+nPlainLen[i+1])=0x00;
	*(pPlain[i+2]+nPlainLen[i+2])=0x00;
	*(pPlain[i+3]+nPlainLen[i+3])=0x00;
    }
    return hash_ok;
}


hash_stat MD5_XOP_SHORT(unsigned char* pPlain[SSE_SIMULTANEOUS], int nPlainLen[SSE_SIMULTANEOUS], unsigned char* pHash[SSE_SIMULTANEOUS])
{
    __m128i mOne = _mm_set1_epi32(0xFFFFFFFF);
    __m128i mCa = _mm_set1_epi32(Ca);
    __m128i mCb = _mm_set1_epi32(Cb);
    __m128i mCc = _mm_set1_epi32(Cc);
    __m128i mCd = _mm_set1_epi32(Cd);
    __m128i w0_1, w0_2, w0_3, w1_1, w1_2, w1_3, w2_1, w2_2, w2_3,w14_1, w14_2, w14_3;
    __m128i a;
    __m128i b;
    __m128i c;
    __m128i d;
    __m128i tmp1, tmp2;
    __m128i a2, b2, c2, d2, tmp1_2, tmp2_2;
    __m128i a3, b3, c3, d3, tmp1_3, tmp2_3;
    int i;

    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen[i])=0x80;
	*(pPlain[i+1]+nPlainLen[i+1])=0x80;
	*(pPlain[i+2]+nPlainLen[i+2])=0x80;
	*(pPlain[i+3]+nPlainLen[i+3])=0x80;
    }

    w0_1 = _mm_set_epi32(udata1[0], udata2[0], udata3[0], udata4[0]);
    w0_2 = _mm_set_epi32(udata5[0], udata6[0], udata7[0], udata8[0]);
    w0_3 = _mm_set_epi32(udata9[0], udata10[0], udata11[0], udata12[0]);

    w1_1 = _mm_set_epi32(udata1[1], udata2[1], udata3[1], udata4[1]);
    w1_2 = _mm_set_epi32(udata5[1], udata6[1], udata7[1], udata8[1]);
    w1_3 = _mm_set_epi32(udata9[1], udata10[1], udata11[1], udata12[1]);

    w2_1 = _mm_set_epi32(udata1[2], udata2[2], udata3[2], udata4[2]);
    w2_2 = _mm_set_epi32(udata5[2], udata6[2], udata7[2], udata8[2]);
    w2_3 = _mm_set_epi32(udata9[2], udata10[2], udata11[2], udata12[2]);

    w14_1 = _mm_set_epi32(nPlainLen[0]<<3, nPlainLen[1]<<3, nPlainLen[2]<<3, nPlainLen[3]<<3);
    w14_2 = _mm_set_epi32(nPlainLen[4]<<3, nPlainLen[5]<<3, nPlainLen[6]<<3, nPlainLen[7]<<3);
    w14_3 = _mm_set_epi32(nPlainLen[8]<<3, nPlainLen[9]<<3, nPlainLen[10]<<3, nPlainLen[11]<<3);


    a = mCa;
    a2 = mCa;
    a3 = mCa;

    b = mCb;
    b2 = mCb;
    b3 = mCb;

    c = mCc;
    c2 = mCc;
    c3 = mCc;

    d = mCd;
    d2 = mCd;
    d3 = mCd;

    MD5_STEPS_SHORT();
    if ((cpu_optimize_single==1))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
	MD5_STEPS_SHORT_NEXT();
    }
    else if ((cpu_optimize_single==2))
    {
	MD5_STEPS_SHORT_NEXT();
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b2));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }
    else MD5_STEPS_SHORT_NEXT();
    MD5_STEPS_SHORT_END();

    a = _mm_add_epi32(a,mCa);
    a2 =  _mm_add_epi32(a2,mCa);
    a3 =  _mm_add_epi32(a3,mCa);

    b =  _mm_add_epi32(b,mCb);
    b2 = _mm_add_epi32(b2,mCb);
    b3 = _mm_add_epi32(b3,mCb);

    c =  _mm_add_epi32(c,mCc);
    c2 = _mm_add_epi32(c2,mCc);
    c3 =  _mm_add_epi32(c3,mCc);

    d =  _mm_add_epi32(d,mCd);
    d2 =  _mm_add_epi32(d2,mCd);
    d3 =  _mm_add_epi32(d3,mCd);

#define uDigest ((UINT4 *)pHash)
#define NEXT_HASH (MAX_HASH_LEN/4)
#define udigest1 ((UINT4 *)pHash[0])
#define udigest2 ((UINT4 *)pHash[1])
#define udigest3 ((UINT4 *)pHash[2])
#define udigest4 ((UINT4 *)pHash[3])
#define udigest5 ((UINT4 *)pHash[4])
#define udigest6 ((UINT4 *)pHash[5])
#define udigest7 ((UINT4 *)pHash[6])
#define udigest8 ((UINT4 *)pHash[7])
#define udigest9 ((UINT4 *)pHash[8])
#define udigest10 ((UINT4 *)pHash[9])
#define udigest11 ((UINT4 *)pHash[10])
#define udigest12 ((UINT4 *)pHash[11])
#define udigest13 ((UINT4 *)pHash[12])
#define udigest14 ((UINT4 *)pHash[13])
#define udigest15 ((UINT4 *)pHash[14])
#define udigest16 ((UINT4 *)pHash[15])


//#define _mm_extract_epi32(x, imm) \
//	_mm_cvtsi128_si32(_mm_srli_si128((x), (imm<<2)))

    


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




// Revert zeros
    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen[i])=0x00;
	*(pPlain[i+1]+nPlainLen[i+1])=0x00;
	*(pPlain[i+2]+nPlainLen[i+2])=0x00;
	*(pPlain[i+3]+nPlainLen[i+3])=0x00;
    }
    return hash_ok;
}





hash_stat MD5_XOP_FIXED(unsigned char* pPlain[SSE_SIMULTANEOUS], int nPlainLen, unsigned char* pHash[SSE_SIMULTANEOUS])
{

    __m128i mOne = _mm_set1_epi32(0xFFFFFFFF);

    __m128i mCa = _mm_set1_epi32(Ca);
    __m128i mCb = _mm_set1_epi32(Cb);
    __m128i mCc = _mm_set1_epi32(Cc);
    __m128i mCd = _mm_set1_epi32(Cd);


    __m128i w0_1, w0_2, w0_3, w1_1, w1_2, w1_3, w2_1, w2_2, w2_3, w3_1, w3_2, w3_3, w14_1, w14_2, w14_3;
    __m128i w4_1, w4_2, w4_3, w5_1, w5_2, w5_3, w6_1, w6_2, w6_3, w7_1, w7_2, w7_3;
    __m128i w8_1, w8_2, w8_3, w9_1, w9_2, w9_3, w10_1, w10_2, w10_3;

     __m128i a;
     __m128i b;
     __m128i c;
     __m128i d;
    
    __m128i tmp1, tmp2;
    __m128i a2, b2, c2, d2, tmp1_2, tmp2_2;
    __m128i a3, b3, c3, d3, tmp1_3, tmp2_3;


    int i;

    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
    	*(pPlain[i]+nPlainLen)=0x80;
    	*(pPlain[i+1]+nPlainLen)=0x80;
    	*(pPlain[i+2]+nPlainLen)=0x80;
    	*(pPlain[i+3]+nPlainLen)=0x80;
    }

    
#define uData ((UINT4 *)pPlain)
#define udata1 ((UINT4 *)pPlain[0])
#define udata2 ((UINT4 *)pPlain[1])
#define udata3 ((UINT4 *)pPlain[2])
#define udata4 ((UINT4 *)pPlain[3])
#define udata5 ((UINT4 *)pPlain[4])
#define udata6 ((UINT4 *)pPlain[5])
#define udata7 ((UINT4 *)pPlain[6])
#define udata8 ((UINT4 *)pPlain[7])
#define udata9 ((UINT4 *)pPlain[8])
#define udata10 ((UINT4 *)pPlain[9])
#define udata11 ((UINT4 *)pPlain[10])
#define udata12 ((UINT4 *)pPlain[11])
#define udata13 ((UINT4 *)pPlain[12])
#define udata14 ((UINT4 *)pPlain[13])
#define udata15 ((UINT4 *)pPlain[14])
#define udata16 ((UINT4 *)pPlain[15])




#define NEXT_PLAIN (MAX_PLAIN_LEN/4)

    w0_1 = _mm_set_epi32(udata1[0], udata2[0], udata3[0], udata4[0]);
    w0_2 = _mm_set_epi32(udata5[0], udata6[0], udata7[0], udata8[0]);
    w0_3 = _mm_set_epi32(udata9[0], udata10[0], udata11[0], udata12[0]);

    w1_1 = _mm_set_epi32(udata1[1], udata2[1], udata3[1], udata4[1]);
    w1_2 = _mm_set_epi32(udata5[1], udata6[1], udata7[1], udata8[1]);
    w1_3 = _mm_set_epi32(udata9[1], udata10[1], udata11[1], udata12[1]);

    w2_1 = _mm_set_epi32(udata1[2], udata2[2], udata3[2], udata4[2]);
    w2_2 = _mm_set_epi32(udata5[2], udata6[2], udata7[2], udata8[2]);
    w2_3 = _mm_set_epi32(udata9[2], udata10[2], udata11[2], udata12[2]);

    w3_1 = _mm_set_epi32(udata1[3], udata2[3], udata3[3], udata4[3]);
    w3_2 = _mm_set_epi32(udata5[3], udata6[3], udata7[3], udata8[3]);
    w3_3 = _mm_set_epi32(udata9[3], udata10[3], udata11[3], udata12[3]);

    w4_1 = _mm_set_epi32(udata1[4], udata2[4], udata3[4], udata4[4]);
    w4_2 = _mm_set_epi32(udata5[4], udata6[4], udata7[4], udata8[4]);
    w4_3 = _mm_set_epi32(udata9[4], udata10[4], udata11[4], udata12[4]);

    w5_1 = _mm_set_epi32(udata1[5], udata2[5], udata3[5], udata4[5]);
    w5_2 = _mm_set_epi32(udata5[5], udata6[5], udata7[5], udata8[5]);
    w5_3 = _mm_set_epi32(udata9[5], udata10[5], udata11[5], udata12[5]);

    if (nPlainLen>15)
    {
	w6_1 = _mm_set_epi32(udata1[6], udata2[6], udata3[6], udata4[6]);
	w6_2 = _mm_set_epi32(udata5[6], udata6[6], udata7[6], udata8[6]);
	w6_3 = _mm_set_epi32(udata9[6], udata10[6], udata11[6], udata12[6]);
	w7_1 = _mm_set_epi32(udata1[7], udata2[7], udata3[7], udata4[7]);
	w7_2 = _mm_set_epi32(udata5[7], udata6[7], udata7[7], udata8[7]);
	w7_3 = _mm_set_epi32(udata9[7], udata10[7], udata11[7], udata12[7]);

	w8_1 = _mm_set_epi32(udata1[8], udata2[8], udata3[8], udata4[8]);
	w8_2 = _mm_set_epi32(udata5[8], udata6[8], udata7[8], udata8[8]);
	w8_3 = _mm_set_epi32(udata9[8], udata10[8], udata11[8], udata12[8]);

	w9_1 = _mm_set_epi32(udata1[9], udata2[9], udata3[9], udata4[9]);
	w9_2 = _mm_set_epi32(udata5[9], udata6[9], udata7[9], udata8[9]);
	w9_3 = _mm_set_epi32(udata9[9], udata10[9], udata11[9], udata12[9]);

	w10_1 = _mm_set_epi32(udata1[10], udata2[10], udata3[10], udata4[10]);
	w10_2 = _mm_set_epi32(udata5[10], udata6[10], udata7[10], udata8[10]);
	w10_3 = _mm_set_epi32(udata9[10], udata10[10], udata11[10], udata12[10]);
    }
    else
    {
	w6_1=w6_2=w6_3=w7_1=w7_2=w7_3=w8_1=w8_2=w8_3=w9_1=w9_2=w9_3=w10_1=w10_2=w10_3=_mm_setzero_si128();
    }
    w14_1 = _mm_set_epi32(nPlainLen<<3, nPlainLen<<3, nPlainLen<<3, nPlainLen<<3);
    w14_2 = _mm_set_epi32(nPlainLen<<3, nPlainLen<<3, nPlainLen<<3, nPlainLen<<3);
    w14_3 = _mm_set_epi32(nPlainLen<<3, nPlainLen<<3, nPlainLen<<3, nPlainLen<<3);

    a = mCa;
    a2 = mCa;
    a3 = mCa;

    b = mCb;
    b2 = mCb;
    b3 = mCb;

    c = mCc;
    c2 = mCc;
    c3 = mCc;

    d = mCd;
    d2 = mCd;
    d3 = mCd;

    MD5_STEPS();

    a = _mm_add_epi32(a,mCa);
    a2 =  _mm_add_epi32(a2,mCa);
    a3 =  _mm_add_epi32(a3,mCa);

    b =  _mm_add_epi32(b,mCb);
    b2 = _mm_add_epi32(b2,mCb);
    b3 = _mm_add_epi32(b3,mCb);

    c =  _mm_add_epi32(c,mCc);
    c2 = _mm_add_epi32(c2,mCc);
    c3 =  _mm_add_epi32(c3,mCc);

    d =  _mm_add_epi32(d,mCd);
    d2 =  _mm_add_epi32(d2,mCd);
    d3 =  _mm_add_epi32(d3,mCd);

#define uDigest ((UINT4 *)pHash)
#define NEXT_HASH (MAX_HASH_LEN/4)
#define udigest1 ((UINT4 *)pHash[0])
#define udigest2 ((UINT4 *)pHash[1])
#define udigest3 ((UINT4 *)pHash[2])
#define udigest4 ((UINT4 *)pHash[3])
#define udigest5 ((UINT4 *)pHash[4])
#define udigest6 ((UINT4 *)pHash[5])
#define udigest7 ((UINT4 *)pHash[6])
#define udigest8 ((UINT4 *)pHash[7])
#define udigest9 ((UINT4 *)pHash[8])
#define udigest10 ((UINT4 *)pHash[9])
#define udigest11 ((UINT4 *)pHash[10])
#define udigest12 ((UINT4 *)pHash[11])
#define udigest13 ((UINT4 *)pHash[12])
#define udigest14 ((UINT4 *)pHash[13])
#define udigest15 ((UINT4 *)pHash[14])
#define udigest16 ((UINT4 *)pHash[15])




//#define _mm_extract_epi32(x, imm) \
//	_mm_cvtsi128_si32(_mm_srli_si128((x), (imm<<2)))


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


// Revert zeros
    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen)=0x00;
	*(pPlain[i+1]+nPlainLen)=0x00;
	*(pPlain[i+2]+nPlainLen)=0x00;
	*(pPlain[i+3]+nPlainLen)=0x00;
    }
    return hash_ok;
}




hash_stat MD5_XOP_SHORT_FIXED(unsigned char * __restrict pPlain[SSE_SIMULTANEOUS], int nPlainLen, unsigned char* pHash[SSE_SIMULTANEOUS])
{
    __m128i mOne = _mm_set1_epi32(0xFFFFFFFF);
    __m128i w0_1, w0_2, w0_3, w1_1, w1_2, w1_3, w2_1, w2_2, w2_3, w3_1, w3_2, w3_3, w14_1, w14_2, w14_3;
    __m128i a;
    __m128i b;
    __m128i c;
    __m128i d;
    __m128i mCa = _mm_set1_epi32(Ca);
    __m128i mCb = _mm_set1_epi32(Cb);
    __m128i mCc = _mm_set1_epi32(Cc);
    __m128i mCd = _mm_set1_epi32(Cd);
    __m128i tmp1, tmp2, tmp3, tmp4;
    __m128i a2, b2, c2, d2, tmp1_2, tmp2_2;
    __m128i a3, b3, c3, d3, tmp1_3, tmp2_3;
    int i;

    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen)=0x80;
	*(pPlain[i+1]+nPlainLen)=0x80;
	*(pPlain[i+2]+nPlainLen)=0x80;
	*(pPlain[i+3]+nPlainLen)=0x80;
    }

    w0_1 = _mm_set_epi32(udata1[0], udata2[0], udata3[0], udata4[0]);
    w0_2 = _mm_set_epi32(udata5[0], udata6[0], udata7[0], udata8[0]);
    w0_3 = _mm_set_epi32(udata9[0], udata10[0], udata11[0], udata12[0]);
    w1_1 = _mm_set_epi32(udata1[1], udata2[1], udata3[1], udata4[1]);
    w1_2 = _mm_set_epi32(udata5[1], udata6[1], udata7[1], udata8[1]);
    w1_3 = _mm_set_epi32(udata9[1], udata10[1], udata11[1], udata12[1]);
    

    if (/*(cpu_optimize_single>0)&&*/(nPlainLen<8))
    {
	w2_1=w2_2=w2_3=w3_1=w3_2=w3_3=_mm_setzero_si128();
    }
    else
    {
	w2_1 = _mm_set_epi32(udata1[2], udata2[2], udata3[2], udata4[2]);
	w2_2 = _mm_set_epi32(udata5[2], udata6[2], udata7[2], udata8[2]);
	w2_3 = _mm_set_epi32(udata9[2], udata10[2], udata11[2], udata12[2]);
    }
    unsigned int np=nPlainLen<<3;
    
    w14_1 = w14_2 = w14_3 = _mm_set1_epi32(np);

    a = mCa;
    a2 = a3 = a;
    b = mCb;
    b2 = b3 = b;
    c = mCc;
    c2 = c3 = c;
    d = mCd;
    d2 = d3 = d;

    MD5_STEPS_SHORT();

    if ((cpu_optimize_single==1))
    {
	unsigned int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a));
	unsigned int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a2));
	unsigned int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, a3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
	MD5_STEPS_SHORT_NEXT();
    }
    else if ((cpu_optimize_single==2))
    {
	MD5_STEPS_SHORT_NEXT();
	unsigned int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b));
	unsigned int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b2));
	unsigned int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(COMP, b3));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }
    else MD5_STEPS_SHORT_NEXT()
    MD5_STEPS_SHORT_END();

    a = _mm_add_epi32(a,mCa);
    a2 =  _mm_add_epi32(a2,mCa);
    a3 =  _mm_add_epi32(a3,mCa);

    b =  _mm_add_epi32(b,mCb);
    b2 = _mm_add_epi32(b2,mCb);
    b3 = _mm_add_epi32(b3,mCb);

    c =  _mm_add_epi32(c,mCc);
    c2 = _mm_add_epi32(c2,mCc);
    c3 =  _mm_add_epi32(c3,mCc);

    d =  _mm_add_epi32(d,mCd);
    d2 =  _mm_add_epi32(d2,mCd);
    d3 =  _mm_add_epi32(d3,mCd);


#define uDigest ((UINT4 *)pHash)
#define NEXT_HASH (MAX_HASH_LEN/4)
#define udigest1 ((UINT4 *)pHash[0])
#define udigest2 ((UINT4 *)pHash[1])
#define udigest3 ((UINT4 *)pHash[2])
#define udigest4 ((UINT4 *)pHash[3])
#define udigest5 ((UINT4 *)pHash[4])
#define udigest6 ((UINT4 *)pHash[5])
#define udigest7 ((UINT4 *)pHash[6])
#define udigest8 ((UINT4 *)pHash[7])
#define udigest9 ((UINT4 *)pHash[8])
#define udigest10 ((UINT4 *)pHash[9])
#define udigest11 ((UINT4 *)pHash[10])
#define udigest12 ((UINT4 *)pHash[11])
#define udigest13 ((UINT4 *)pHash[12])
#define udigest14 ((UINT4 *)pHash[13])
#define udigest15 ((UINT4 *)pHash[14])
#define udigest16 ((UINT4 *)pHash[15])


//#define _mm_extract_epi32(x, imm) \
//	_mm_cvtsi128_si32(_mm_srli_si128((x), (imm<<2)))

    


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
    tmp2 = _mm_set_epi32(_mm_extract_epi32(d2, 0),_mm_extract_epi32(c2, 0),_mm_extract_epi32(b2, 0),_mm_extract_epi32(a2, 0));
    tmp3 = _mm_set_epi32(_mm_extract_epi32(d3, 0),_mm_extract_epi32(c3, 0),_mm_extract_epi32(b3, 0),_mm_extract_epi32(a3, 0));

    _mm_store_si128((__m128i *)udigest4,tmp1);
    _mm_store_si128((__m128i *)udigest8,tmp2);
    _mm_store_si128((__m128i *)udigest12,tmp3);


// Revert zeros
    for (i = 0; i < SSE_SIMULTANEOUS; i+=4)
    {
	*(pPlain[i]+nPlainLen)=0x00;
	*(pPlain[i+1]+nPlainLen)=0x00;
	*(pPlain[i+2]+nPlainLen)=0x00;
	*(pPlain[i+3]+nPlainLen)=0x00;
    }
    return hash_ok;
}

#endif
