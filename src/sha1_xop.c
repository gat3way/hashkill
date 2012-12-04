/*
 * sha1_xop.c
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
#include <stdio.h>
#include <string.h>
#include "err.h"
#include "hashinterface.h"
#include "sha1_xop.h"


#define VSIZE 12

#define _mm_extract_epi32(x, imm) \
        _mm_cvtsi128_si32(_mm_srli_si128((x), (imm)<<2)) 


#define ROTATE(a,n) ((a << n) | (a >> (32-n)))
#define BSWAP(a) \
{ \
int l=(a); \
(a)=((ROTATE(l,8)&0x00FF00FFUL)|(ROTATE(l,24)&0xFF00FF00UL)); \
}

static __m128i A;


void SHA1_PREPARE_OPT_XOP(void)
{
    int ARAW;
    memcpy(&ARAW,&(hash_list->hash[0]),4);
    BSWAP(ARAW);
    ARAW = ARAW - 0x67452301;
    A = _mm_set_epi32(ARAW, ARAW, ARAW, ARAW);
}


hash_stat SHA1_XOP_SHORT(char *plains[VSIZE], char *hash[VSIZE], int lens[VSIZE])
{

    const __m128i m=_mm_set1_epi32(0x00FF00FFUL);
    const __m128i m2=_mm_set1_epi32(0xFF00FF00UL);
    int t;
    __m128i plain1, plain2, plain3, plain4;
    __m128i plain5, plain6, plain7, plain8;
    __m128i plain9, plain10, plain11, plain12;
    __m128i plain13, plain14, plain15, plain16;

    __m128i sse_W[17]; 
    __m128i sse_W1[17]; 
    __m128i sse_W2[17]; 
    __m128i sse_W3[17]; 
    __m128i sse_A, sse_B, sse_C, sse_D, sse_E, sse_temp;  
    __m128i sse_A1, sse_B1, sse_C1, sse_D1, sse_E1, sse_temp1;  
    __m128i sse_A2, sse_B2, sse_C2, sse_D2, sse_E2, sse_temp2;  
    __m128i sse_A3, sse_B3, sse_C3, sse_D3, sse_E3, sse_temp3;  

    __m128i sse_K, tmp1, tmp2, tmp1_1, tmp1_2, tmp2_1, tmp2_2,tmp3, tmp3_1, tmp3_2;


    plains[0][lens[0]]=0x80;
    plains[1][lens[1]]=0x80;
    plains[2][lens[2]]=0x80;
    plains[3][lens[3]]=0x80;
    plains[4][lens[4]]=0x80;
    plains[5][lens[5]]=0x80;
    plains[6][lens[6]]=0x80;
    plains[7][lens[7]]=0x80;
    plains[8][lens[8]]=0x80;
    plains[9][lens[9]]=0x80;
    plains[10][lens[10]]=0x80;
    plains[11][lens[11]]=0x80;


    
#define udata1s ((UINT4 *)plains[0])
#define udata2s ((UINT4 *)plains[1])
#define udata3s ((UINT4 *)plains[2])
#define udata4s ((UINT4 *)plains[3])
#define udata5s ((UINT4 *)plains[4])
#define udata6s ((UINT4 *)plains[5])
#define udata7s ((UINT4 *)plains[6])
#define udata8s ((UINT4 *)plains[7])
#define udata9s ((UINT4 *)plains[8])
#define udata10s ((UINT4 *)plains[9])
#define udata11s ((UINT4 *)plains[10])
#define udata12s ((UINT4 *)plains[11])
#define udata13s ((UINT4 *)plains[12])
#define udata14s ((UINT4 *)plains[13])
#define udata15s ((UINT4 *)plains[14])
#define udata16s ((UINT4 *)plains[15])




    // load input into m128i
    plain1 = _mm_load_si128 ((__m128i *)udata1s);
    plain2 = _mm_load_si128 ((__m128i *)udata2s);
    plain3 = _mm_load_si128 ((__m128i *)udata3s);
    plain4 = _mm_load_si128 ((__m128i *)udata4s);
    plain5 = _mm_load_si128 ((__m128i *)udata5s);
    plain6 = _mm_load_si128 ((__m128i *)udata6s);
    plain7 = _mm_load_si128 ((__m128i *)udata7s);
    plain8 = _mm_load_si128 ((__m128i *)udata8s);
    plain9 = _mm_load_si128 ((__m128i *)udata9s);
    plain10 = _mm_load_si128 ((__m128i *)udata10s);
    plain11 = _mm_load_si128 ((__m128i *)udata11s);
    plain12 = _mm_load_si128 ((__m128i *)udata12s);


    sse_K = _mm_set1_epi32(K0);
    
    sse_W[0] = _mm_set_epi32(_mm_extract_epi32(plain1,0), _mm_extract_epi32(plain2,0), _mm_extract_epi32(plain3,0), _mm_extract_epi32(plain4,0));
    SSE_Endian_Reverse32(sse_W[0]);
    sse_B = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W[0]);
    sse_W1[0] = _mm_set_epi32(_mm_extract_epi32(plain5,0), _mm_extract_epi32(plain6,0), _mm_extract_epi32(plain7,0), _mm_extract_epi32(plain8,0));
    SSE_Endian_Reverse32(sse_W1[0]);
    sse_B1 = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W1[0]);
    sse_W2[0] = _mm_set_epi32(_mm_extract_epi32(plain9,0), _mm_extract_epi32(plain10,0), _mm_extract_epi32(plain11,0), _mm_extract_epi32(plain12,0));
    SSE_Endian_Reverse32(sse_W2[0]);
    sse_B2 = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W2[0]);


    sse_W[1] = _mm_set_epi32(_mm_extract_epi32(plain1,1), _mm_extract_epi32(plain2,1), _mm_extract_epi32(plain3,1), _mm_extract_epi32(plain4,1));
    SSE_Endian_Reverse32(sse_W[1]);
    sse_A = _mm_add_epi32(SSE_ROTATE(sse_B,5), _mm_set1_epi32(1722862861UL));
    sse_A = _mm_add_epi32(sse_A, sse_W[1]);
    sse_W1[1] = _mm_set_epi32(_mm_extract_epi32(plain5,1), _mm_extract_epi32(plain6,1), _mm_extract_epi32(plain7,1), _mm_extract_epi32(plain8,1));
    SSE_Endian_Reverse32(sse_W1[1]);
    sse_A1 = _mm_add_epi32(SSE_ROTATE(sse_B1,5), _mm_set1_epi32(1722862861UL));
    sse_A1 = _mm_add_epi32(sse_A1, sse_W1[1]);
    sse_W2[1] = _mm_set_epi32(_mm_extract_epi32(plain9,1), _mm_extract_epi32(plain10,1), _mm_extract_epi32(plain11,1), _mm_extract_epi32(plain12,1));
    SSE_Endian_Reverse32(sse_W2[1]);
    sse_A2 = _mm_add_epi32(SSE_ROTATE(sse_B2,5), _mm_set1_epi32(1722862861UL));
    sse_A2 = _mm_add_epi32(sse_A2, sse_W2[1]);


    sse_W[2] = _mm_set_epi32(_mm_extract_epi32(plain1,2), _mm_extract_epi32(plain2,2), _mm_extract_epi32(plain3,2), _mm_extract_epi32(plain4,2));
    SSE_Endian_Reverse32(sse_W[2]);
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_A,5), ((_mm_set1_epi32(572662306UL) & sse_B) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(H2+K0));
    sse_temp = _mm_add_epi32(sse_temp,sse_W[2]);
    sse_E = SSE_ROTATE(sse_B,30);
    sse_B = sse_temp;
    sse_W1[2] = _mm_set_epi32(_mm_extract_epi32(plain5,2), _mm_extract_epi32(plain6,2), _mm_extract_epi32(plain7,2), _mm_extract_epi32(plain8,2));
    SSE_Endian_Reverse32(sse_W1[2]);
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_A1,5), ((_mm_set1_epi32(572662306UL) & sse_B1) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(H2+K0));
    sse_temp1 = _mm_add_epi32(sse_temp1,sse_W1[2]);
    sse_E1 = SSE_ROTATE(sse_B1,30);
    sse_B1 = sse_temp1;
    sse_W2[2] = _mm_set_epi32(_mm_extract_epi32(plain9,2), _mm_extract_epi32(plain10,2), _mm_extract_epi32(plain11,2), _mm_extract_epi32(plain12,2));
    SSE_Endian_Reverse32(sse_W2[2]);
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_A2,5), ((_mm_set1_epi32(572662306UL) & sse_B2) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(H2+K0));
    sse_temp2 = _mm_add_epi32(sse_temp2,sse_W2[2]);
    sse_E2 = SSE_ROTATE(sse_B2,30);
    sse_B2 = sse_temp2;


    sse_W[3] = _mm_set_epi32(_mm_extract_epi32(plain1,3), _mm_extract_epi32(plain2,3), _mm_extract_epi32(plain3,3), _mm_extract_epi32(plain4,3));
    SSE_Endian_Reverse32(sse_W[3]);
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_B,5), (((sse_E ^ _mm_set1_epi32(1506887872UL)) & sse_A) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(2079550178UL+K0));
    sse_temp = _mm_add_epi32(sse_temp, sse_W[3]);
    sse_D = SSE_ROTATE(sse_A,30);
    sse_A = sse_temp;
    sse_W1[3] = _mm_set_epi32(_mm_extract_epi32(plain1,5), _mm_extract_epi32(plain2,6), _mm_extract_epi32(plain3,7), _mm_extract_epi32(plain4,8));
    SSE_Endian_Reverse32(sse_W1[3]);
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_B1,5), (((sse_E1 ^ _mm_set1_epi32(1506887872UL)) & sse_A1) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(2079550178UL+K0));
    sse_temp1 = _mm_add_epi32(sse_temp1, sse_W1[3]);
    sse_D1 = SSE_ROTATE(sse_A1,30);
    sse_A1 = sse_temp1;
    sse_W2[3] = _mm_set_epi32(_mm_extract_epi32(plain9,5), _mm_extract_epi32(plain10,6), _mm_extract_epi32(plain11,7), _mm_extract_epi32(plain12,8));
    SSE_Endian_Reverse32(sse_W2[3]);
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_B2,5), (((sse_E2 ^ _mm_set1_epi32(1506887872UL)) & sse_A2) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(2079550178UL+K0));
    sse_temp2 = _mm_add_epi32(sse_temp2, sse_W2[3]);
    sse_D2 = SSE_ROTATE(sse_A2,30);
    sse_A2 = sse_temp2;


    sse_W[4] = _mm_setzero_si128();
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_A,5), F_00_19(sse_B,sse_D,sse_E));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(1506887872UL+K0));
    sse_C = SSE_ROTATE(sse_B,30);
    sse_B = sse_A;
    sse_A = sse_temp;
    sse_W1[4] = _mm_setzero_si128();
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_A1,5), F_00_19(sse_B1,sse_D1,sse_E1));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(1506887872UL+K0));
    sse_C1 = SSE_ROTATE(sse_B1,30);
    sse_B1 = sse_A1;
    sse_A1 = sse_temp1;
    sse_W2[4] = _mm_setzero_si128();
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_A2,5), F_00_19(sse_B2,sse_D2,sse_E2));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(1506887872UL+K0));
    sse_C2 = SSE_ROTATE(sse_B2,30);
    sse_B2 = sse_A2;
    sse_A2 = sse_temp2;


    // do next steps of round 1 where W[5]...W[14] = 0
    for (t = 5; t < 15; t+=5)
    {
	sse_W[t] = _mm_setzero_si128(); 
	sse_W1[t] = _mm_setzero_si128(); 
	sse_W2[t] = _mm_setzero_si128(); 
	SSE_ROTATE1_NULL( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3 );
        sse_W[t+1] = _mm_setzero_si128(); 
        sse_W1[t+1] = _mm_setzero_si128(); 
        sse_W2[t+1] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3 );
	sse_W[t+2] = _mm_setzero_si128(); 
	sse_W1[t+2] = _mm_setzero_si128(); 
	sse_W2[t+2] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3 );
        sse_W[t+3] = _mm_setzero_si128(); 
        sse_W1[t+3] = _mm_setzero_si128(); 
        sse_W2[t+3] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 );
        sse_W[t+4] = _mm_setzero_si128(); 
        sse_W1[t+4] = _mm_setzero_si128(); 
        sse_W2[t+4] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3 );
    }


#define SSE_EXPAND1(t1,t2,t3,t4,t5) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3] ^ sse_W[t4] ^ sse_W[t5],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3] ^ sse_W1[t4] ^ sse_W1[t5],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3] ^ sse_W2[t4] ^ sse_W2[t5],1); \
}

#define SSE_EXPAND1_3(t1,t2,t3,t4) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3] ^ sse_W[t4],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3] ^ sse_W1[t4],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3] ^ sse_W2[t4],1); \
}

#define SSE_EXPAND1_2(t1,t2,t3) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3],1); \
}

#define SSE_EXPAND1_1(t1,t2) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2],1); \
}


    // do last few steps of round 1

    sse_W[15] = _mm_set_epi32((lens[0] << 3),(lens[1] << 3),(lens[2] << 3),(lens[3] << 3));
    sse_W1[15] = _mm_set_epi32((lens[4] << 3),(lens[5] << 3),(lens[6] << 3),(lens[7] << 3));
    sse_W2[15] = _mm_set_epi32((lens[8] << 3),(lens[9] << 3),(lens[10] << 3),(lens[11] << 3));
    SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] ); // set length
    SSE_EXPAND1_2(16,2,0); 
    SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[16], sse_W1[16],sse_W2[16], sse_W3[16] );
    SSE_EXPAND1_2(0,3,1); 
    SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1_2(1,15,2); 
    SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1_2(2,16,3);
    SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );


    // round 2
    sse_K = _mm_set1_epi32(K1);

    SSE_EXPAND1_1(3,0); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1_1(4,1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1_1(5,2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1_2(6,3,15); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1_2(7,4,16); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1_2(8,5,0); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1_2(9,6,1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1_2(10,7,2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1_2(11,8,3); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1_3(12,9,4,15); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1_3(13,10,5,16); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );

    // round 3
    sse_K = _mm_set1_epi32(K2);
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1(12,9,4,15,13); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1(13,10,5,16,14); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );


    // round 4 
    sse_K = _mm_set1_epi32(K3);
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1(12,9,4,15,13); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1(13,10,5,16,14); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );


    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );




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

    if ((cpu_optimize_single==1))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A1));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A2));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }


    __m128i HH0, HH1, HH2, HH3, HH4;
    HH0 = _mm_set1_epi32(H0);
    HH1 = _mm_set1_epi32(H1);
    HH2 = _mm_set1_epi32(H2);
    HH3 = _mm_set1_epi32(H3);
    HH4 = _mm_set1_epi32(H4);

    sse_A = _mm_add_epi32(sse_A, HH0);
    sse_B = _mm_add_epi32(sse_B, HH1);
    sse_C = _mm_add_epi32(sse_C, HH2);
    sse_D = _mm_add_epi32(sse_D, HH3);
    sse_E = _mm_add_epi32(sse_E, HH4);
    sse_A1 = _mm_add_epi32(sse_A1, HH0);
    sse_B1 = _mm_add_epi32(sse_B1, HH1);
    sse_C1 = _mm_add_epi32(sse_C1, HH2);
    sse_D1 = _mm_add_epi32(sse_D1, HH3);
    sse_E1 = _mm_add_epi32(sse_E1, HH4);
    sse_A2 = _mm_add_epi32(sse_A2, HH0);
    sse_B2 = _mm_add_epi32(sse_B2, HH1);
    sse_C2 = _mm_add_epi32(sse_C2, HH2);
    sse_D2 = _mm_add_epi32(sse_D2, HH3);
    sse_E2 = _mm_add_epi32(sse_E2, HH4);

    SSE_Endian_Reverse32(sse_A);
    SSE_Endian_Reverse32(sse_B);
    SSE_Endian_Reverse32(sse_C);
    SSE_Endian_Reverse32(sse_D);
    SSE_Endian_Reverse32(sse_E);
    SSE_Endian_Reverse32(sse_A1);
    SSE_Endian_Reverse32(sse_B1);
    SSE_Endian_Reverse32(sse_C1);
    SSE_Endian_Reverse32(sse_D1);
    SSE_Endian_Reverse32(sse_E1);
    SSE_Endian_Reverse32(sse_A2);
    SSE_Endian_Reverse32(sse_B2);
    SSE_Endian_Reverse32(sse_C2);
    SSE_Endian_Reverse32(sse_D2);
    SSE_Endian_Reverse32(sse_E2);

    

    udigest4[0] = _mm_extract_epi32(sse_A, 0);
    udigest3[0] = _mm_extract_epi32(sse_A, 1);
    udigest2[0] = _mm_extract_epi32(sse_A, 2);
    udigest1[0] = _mm_extract_epi32(sse_A, 3);
    udigest4[1] = _mm_extract_epi32(sse_B, 0);
    udigest3[1] = _mm_extract_epi32(sse_B, 1);
    udigest2[1] = _mm_extract_epi32(sse_B, 2);
    udigest1[1] = _mm_extract_epi32(sse_B, 3);
    udigest4[2] = _mm_extract_epi32(sse_C, 0);
    udigest3[2] = _mm_extract_epi32(sse_C, 1);
    udigest2[2] = _mm_extract_epi32(sse_C, 2);
    udigest1[2] = _mm_extract_epi32(sse_C, 3);
    udigest4[3] = _mm_extract_epi32(sse_D, 0);
    udigest3[3] = _mm_extract_epi32(sse_D, 1);
    udigest2[3] = _mm_extract_epi32(sse_D, 2);
    udigest1[3] = _mm_extract_epi32(sse_D, 3);
    udigest4[4] = _mm_extract_epi32(sse_E, 0);
    udigest3[4] = _mm_extract_epi32(sse_E, 1);
    udigest2[4] = _mm_extract_epi32(sse_E, 2);
    udigest1[4] = _mm_extract_epi32(sse_E, 3);
    udigest8[0] = _mm_extract_epi32(sse_A1, 0);
    udigest7[0] = _mm_extract_epi32(sse_A1, 1);
    udigest6[0] = _mm_extract_epi32(sse_A1, 2);
    udigest5[0] = _mm_extract_epi32(sse_A1, 3);
    udigest8[1] = _mm_extract_epi32(sse_B1, 0);
    udigest7[1] = _mm_extract_epi32(sse_B1, 1);
    udigest6[1] = _mm_extract_epi32(sse_B1, 2);
    udigest5[1] = _mm_extract_epi32(sse_B1, 3);
    udigest8[2] = _mm_extract_epi32(sse_C1, 0);
    udigest7[2] = _mm_extract_epi32(sse_C1, 1);
    udigest6[2] = _mm_extract_epi32(sse_C1, 2);
    udigest5[2] = _mm_extract_epi32(sse_C1, 3);
    udigest8[3] = _mm_extract_epi32(sse_D1, 0);
    udigest7[3] = _mm_extract_epi32(sse_D1, 1);
    udigest6[3] = _mm_extract_epi32(sse_D1, 2);
    udigest5[3] = _mm_extract_epi32(sse_D1, 3);
    udigest8[4] = _mm_extract_epi32(sse_E1, 0);
    udigest7[4] = _mm_extract_epi32(sse_E1, 1);
    udigest6[4] = _mm_extract_epi32(sse_E1, 2);
    udigest5[4] = _mm_extract_epi32(sse_E1, 3);
    udigest12[0] = _mm_extract_epi32(sse_A2, 0);
    udigest11[0] = _mm_extract_epi32(sse_A2, 1);
    udigest10[0] = _mm_extract_epi32(sse_A2, 2);
    udigest9[0] = _mm_extract_epi32(sse_A2, 3);
    udigest12[1] = _mm_extract_epi32(sse_B2, 0);
    udigest11[1] = _mm_extract_epi32(sse_B2, 1);
    udigest10[1] = _mm_extract_epi32(sse_B2, 2);
    udigest9[1] = _mm_extract_epi32(sse_B2, 3);
    udigest12[2] = _mm_extract_epi32(sse_C2, 0);
    udigest11[2] = _mm_extract_epi32(sse_C2, 1);
    udigest10[2] = _mm_extract_epi32(sse_C2, 2);
    udigest9[2] = _mm_extract_epi32(sse_C2, 3);
    udigest12[3] = _mm_extract_epi32(sse_D2, 0);
    udigest11[3] = _mm_extract_epi32(sse_D2, 1);
    udigest10[3] = _mm_extract_epi32(sse_D2, 2);
    udigest9[3] = _mm_extract_epi32(sse_D2, 3);
    udigest12[4] = _mm_extract_epi32(sse_E2, 0);
    udigest11[4] = _mm_extract_epi32(sse_E2, 1);
    udigest10[4] = _mm_extract_epi32(sse_E2, 2);
    udigest9[4] = _mm_extract_epi32(sse_E2, 3);

    plains[0][lens[0]]=0x00;
    plains[1][lens[1]]=0x00;
    plains[2][lens[2]]=0x00;
    plains[3][lens[3]]=0x00;
    plains[4][lens[4]]=0x00;
    plains[5][lens[5]]=0x00;
    plains[6][lens[6]]=0x00;
    plains[7][lens[7]]=0x00;
    plains[8][lens[8]]=0x00;
    plains[9][lens[9]]=0x00;
    plains[10][lens[10]]=0x00;
    plains[11][lens[11]]=0x00;
    return hash_ok;
}




hash_stat SHA1_XOP(char *plains[VSIZE], char *hash[VSIZE], int lens[VSIZE])
{

    const __m128i m=_mm_set1_epi32(0x00FF00FF);
    const __m128i m2=_mm_set1_epi32(0xFF00FF00);
    int t;
    __m128i plain10, plain20, plain30, plain40;
    __m128i plain11, plain21, plain31, plain41;
    __m128i plain12, plain22, plain32, plain42;
    __m128i plain50, plain60, plain70, plain80;
    __m128i plain51, plain61, plain71, plain81;
    __m128i plain52, plain62, plain72, plain82;
    __m128i plain90, plain100, plain110, plain120;
    __m128i plain91, plain101, plain111, plain121;
    __m128i plain92, plain102, plain112, plain122;
    __m128i plain130, plain140, plain150, plain160;
    __m128i plain131, plain141, plain151, plain161;
    __m128i plain132, plain142, plain152, plain162;



    __m128i sse_W[80]; 
    __m128i sse_A, sse_B, sse_C, sse_D, sse_E;  
    __m128i sse_K, tmp1, tmp2, tmp3, tmp1_1, tmp1_2, tmp1_3, tmp2_1, tmp2_2, tmp2_3, tmp3_1, tmp3_2, tmp3_3;

    __m128i sse_W1[80]; 
    __m128i sse_A1, sse_B1, sse_C1, sse_D1, sse_E1;  
    __m128i sse_W2[80]; 
    __m128i sse_A2, sse_B2, sse_C2, sse_D2, sse_E2;  
    __m128i sse_W3[80]; 
    __m128i sse_A3, sse_B3, sse_C3, sse_D3, sse_E3;  


    plains[0][lens[0]]=0x80;
    plains[1][lens[1]]=0x80;
    plains[2][lens[2]]=0x80;
    plains[3][lens[3]]=0x80;
    plains[4][lens[4]]=0x80;
    plains[5][lens[5]]=0x80;
    plains[6][lens[6]]=0x80;
    plains[7][lens[7]]=0x80;
    plains[8][lens[8]]=0x80;
    plains[9][lens[9]]=0x80;
    plains[10][lens[10]]=0x80;
    plains[11][lens[11]]=0x80;


#define udata10 ((UINT4 *)plains[0])
#define udata20 ((UINT4 *)plains[1])
#define udata30 ((UINT4 *)plains[2])
#define udata40 ((UINT4 *)plains[3])
#define udata11 ((UINT4 *)(&plains[0][16]))
#define udata21 ((UINT4 *)(&plains[1][16]))
#define udata31 ((UINT4 *)(&plains[2][16]))
#define udata41 ((UINT4 *)(&plains[3][16]))
#define udata12 ((UINT4 *)(&plains[0][32]))
#define udata22 ((UINT4 *)(&plains[1][32]))
#define udata32 ((UINT4 *)(&plains[2][32]))
#define udata42 ((UINT4 *)(&plains[3][32]))
#define udata50 ((UINT4 *)plains[4])
#define udata60 ((UINT4 *)plains[5])
#define udata70 ((UINT4 *)plains[6])
#define udata80 ((UINT4 *)plains[7])
#define udata51 ((UINT4 *)(&plains[4][16]))
#define udata61 ((UINT4 *)(&plains[5][16]))
#define udata71 ((UINT4 *)(&plains[6][16]))
#define udata81 ((UINT4 *)(&plains[7][16]))
#define udata52 ((UINT4 *)(&plains[4][32]))
#define udata62 ((UINT4 *)(&plains[5][32]))
#define udata72 ((UINT4 *)(&plains[6][32]))
#define udata82 ((UINT4 *)(&plains[7][32]))
#define udata90 ((UINT4 *)plains[8])
#define udata100 ((UINT4 *)plains[9])
#define udata110 ((UINT4 *)plains[10])
#define udata120 ((UINT4 *)plains[11])
#define udata91 ((UINT4 *)(&plains[8][16]))
#define udata101 ((UINT4 *)(&plains[9][16]))
#define udata111 ((UINT4 *)(&plains[10][16]))
#define udata121 ((UINT4 *)(&plains[11][16]))
#define udata92 ((UINT4 *)(&plains[8][32]))
#define udata102 ((UINT4 *)(&plains[9][32]))
#define udata112 ((UINT4 *)(&plains[10][32]))
#define udata122 ((UINT4 *)(&plains[11][32]))


    // load input into m128i
    plain10 = _mm_load_si128 ((__m128i *)udata10);
    plain20 = _mm_load_si128 ((__m128i *)udata20);
    plain30 = _mm_load_si128 ((__m128i *)udata30);
    plain40 = _mm_load_si128 ((__m128i *)udata40);
    plain11 = _mm_load_si128 ((__m128i *)udata11);
    plain21 = _mm_load_si128 ((__m128i *)udata21);
    plain31 = _mm_load_si128 ((__m128i *)udata31);
    plain41 = _mm_load_si128 ((__m128i *)udata41);
    plain12 = _mm_load_si128 ((__m128i *)udata12);
    plain22 = _mm_load_si128 ((__m128i *)udata22);
    plain32 = _mm_load_si128 ((__m128i *)udata32);
    plain42 = _mm_load_si128 ((__m128i *)udata42);

    plain50 = _mm_load_si128 ((__m128i *)udata50);
    plain60 = _mm_load_si128 ((__m128i *)udata60);
    plain70 = _mm_load_si128 ((__m128i *)udata70);
    plain80 = _mm_load_si128 ((__m128i *)udata80);
    plain51 = _mm_load_si128 ((__m128i *)udata51);
    plain61 = _mm_load_si128 ((__m128i *)udata61);
    plain71 = _mm_load_si128 ((__m128i *)udata71);
    plain81 = _mm_load_si128 ((__m128i *)udata81);
    plain52 = _mm_load_si128 ((__m128i *)udata52);
    plain62 = _mm_load_si128 ((__m128i *)udata62);
    plain72 = _mm_load_si128 ((__m128i *)udata72);
    plain82 = _mm_load_si128 ((__m128i *)udata82);

    plain90 = _mm_load_si128 ((__m128i *)udata90);
    plain100 = _mm_load_si128 ((__m128i *)udata100);
    plain110 = _mm_load_si128 ((__m128i *)udata110);
    plain120 = _mm_load_si128 ((__m128i *)udata120);
    plain91 = _mm_load_si128 ((__m128i *)udata91);
    plain101 = _mm_load_si128 ((__m128i *)udata101);
    plain111 = _mm_load_si128 ((__m128i *)udata111);
    plain121 = _mm_load_si128 ((__m128i *)udata121);
    plain92 = _mm_load_si128 ((__m128i *)udata92);
    plain102 = _mm_load_si128 ((__m128i *)udata102);
    plain112 = _mm_load_si128 ((__m128i *)udata112);
    plain122 = _mm_load_si128 ((__m128i *)udata122);



    __m128i HH0, HH1, HH2, HH3, HH4;
    HH0 = _mm_set1_epi32(H0);
    HH1 = _mm_set1_epi32(H1);
    HH2 = _mm_set1_epi32(H2);
    HH3 = _mm_set1_epi32(H3);
    HH4 = _mm_set1_epi32(H4);

    sse_A = _mm_set1_epi32(H0);
    sse_B = _mm_set1_epi32(H1);
    sse_C = _mm_set1_epi32(H2);
    sse_D = _mm_set1_epi32(H3);
    sse_E = _mm_set1_epi32(H4);
    sse_A1 = _mm_set1_epi32(H0);
    sse_B1 = _mm_set1_epi32(H1);
    sse_C1 = _mm_set1_epi32(H2);
    sse_D1 = _mm_set1_epi32(H3);
    sse_E1 = _mm_set1_epi32(H4);
    sse_A2 = _mm_set1_epi32(H0);
    sse_B2 = _mm_set1_epi32(H1);
    sse_C2 = _mm_set1_epi32(H2);
    sse_D2 = _mm_set1_epi32(H3);
    sse_E2 = _mm_set1_epi32(H4);



    sse_K = _mm_set1_epi32(K0);
    sse_W[15] = _mm_set_epi32((lens[0] << 3),(lens[1] << 3),(lens[2] << 3),(lens[3] << 3));
    sse_W1[15] = _mm_set_epi32((lens[4] << 3),(lens[5] << 3),(lens[6] << 3),(lens[7] << 3));
    sse_W2[15] = _mm_set_epi32((lens[8] << 3),(lens[9] << 3),(lens[10] << 3),(lens[11] << 3));


    // do next steps of round 1 where W[5]...W[14] = 0
    for (t = 0; t < 10; t+=10)
    {
	sse_W[t] = _mm_set_epi32(_mm_extract_epi32(plain10,0), _mm_extract_epi32(plain20,0), _mm_extract_epi32(plain30,0), _mm_extract_epi32(plain40,0)); 
	sse_W1[t] = _mm_set_epi32(_mm_extract_epi32(plain50,0), _mm_extract_epi32(plain60,0), _mm_extract_epi32(plain70,0), _mm_extract_epi32(plain80,0)); 
	sse_W2[t] = _mm_set_epi32(_mm_extract_epi32(plain90,0), _mm_extract_epi32(plain100,0), _mm_extract_epi32(plain110,0), _mm_extract_epi32(plain120,0)); 
	SSE_Endian_Reverse32(sse_W[t]);
	SSE_Endian_Reverse32(sse_W1[t]);
	SSE_Endian_Reverse32(sse_W2[t]);
	SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t],sse_W1[t], sse_W2[t],sse_W3[t] );

	sse_W[t+1] = _mm_set_epi32(_mm_extract_epi32(plain10,1), _mm_extract_epi32(plain20,1), _mm_extract_epi32(plain30,1), _mm_extract_epi32(plain40,1)); 
	sse_W1[t+1] = _mm_set_epi32(_mm_extract_epi32(plain50,1), _mm_extract_epi32(plain60,1), _mm_extract_epi32(plain70,1), _mm_extract_epi32(plain80,1)); 
	sse_W2[t+1] = _mm_set_epi32(_mm_extract_epi32(plain90,1), _mm_extract_epi32(plain100,1), _mm_extract_epi32(plain110,1), _mm_extract_epi32(plain120,1)); 
	SSE_Endian_Reverse32(sse_W[t+1]);
	SSE_Endian_Reverse32(sse_W1[t+1]);
	SSE_Endian_Reverse32(sse_W2[t+1]);
        SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1],sse_W1[t+1],sse_W2[t+1],sse_W3[t+1] );

	sse_W[t+2] = _mm_set_epi32(_mm_extract_epi32(plain10,2), _mm_extract_epi32(plain20,2), _mm_extract_epi32(plain30,2), _mm_extract_epi32(plain40,2)); 
	sse_W1[t+2] = _mm_set_epi32(_mm_extract_epi32(plain50,2), _mm_extract_epi32(plain60,2), _mm_extract_epi32(plain70,2), _mm_extract_epi32(plain80,2)); 
	sse_W2[t+2] = _mm_set_epi32(_mm_extract_epi32(plain90,2), _mm_extract_epi32(plain100,2), _mm_extract_epi32(plain110,2), _mm_extract_epi32(plain120,2)); 
	SSE_Endian_Reverse32(sse_W[t+2]);
	SSE_Endian_Reverse32(sse_W1[t+2]);
	SSE_Endian_Reverse32(sse_W2[t+2]);
	SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2],sse_W1[t+2],sse_W2[t+2],sse_W3[t+2] );

	sse_W[t+3] = _mm_set_epi32(_mm_extract_epi32(plain10,3), _mm_extract_epi32(plain20,3), _mm_extract_epi32(plain30,3), _mm_extract_epi32(plain40,3)); 
	sse_W1[t+3] = _mm_set_epi32(_mm_extract_epi32(plain50,3), _mm_extract_epi32(plain60,3), _mm_extract_epi32(plain70,3), _mm_extract_epi32(plain80,3)); 
	sse_W2[t+3] = _mm_set_epi32(_mm_extract_epi32(plain90,3), _mm_extract_epi32(plain100,3), _mm_extract_epi32(plain110,3), _mm_extract_epi32(plain120,3)); 
	SSE_Endian_Reverse32(sse_W[t+3]);
	SSE_Endian_Reverse32(sse_W1[t+3]);
	SSE_Endian_Reverse32(sse_W2[t+3]);
        SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1,sse_E2,sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 ,sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );

	sse_W[t+4] = _mm_set_epi32(_mm_extract_epi32(plain11,0), _mm_extract_epi32(plain21,0), _mm_extract_epi32(plain31,0), _mm_extract_epi32(plain41,0)); 
	sse_W1[t+4] = _mm_set_epi32(_mm_extract_epi32(plain51,0), _mm_extract_epi32(plain61,0), _mm_extract_epi32(plain71,0), _mm_extract_epi32(plain81,0)); 
	sse_W2[t+4] = _mm_set_epi32(_mm_extract_epi32(plain91,0), _mm_extract_epi32(plain101,0), _mm_extract_epi32(plain111,0), _mm_extract_epi32(plain121,0)); 
	SSE_Endian_Reverse32(sse_W[t+4]);
	SSE_Endian_Reverse32(sse_W1[t+4]);
	SSE_Endian_Reverse32(sse_W2[t+4]);
        SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );

	sse_W[t+5] = _mm_set_epi32(_mm_extract_epi32(plain11,1), _mm_extract_epi32(plain21,1), _mm_extract_epi32(plain31,1), _mm_extract_epi32(plain41,1)); 
	sse_W1[t+5] = _mm_set_epi32(_mm_extract_epi32(plain51,1), _mm_extract_epi32(plain61,1), _mm_extract_epi32(plain71,1), _mm_extract_epi32(plain81,1)); 
	sse_W2[t+5] = _mm_set_epi32(_mm_extract_epi32(plain91,1), _mm_extract_epi32(plain101,1), _mm_extract_epi32(plain111,1), _mm_extract_epi32(plain121,1)); 
	SSE_Endian_Reverse32(sse_W[t+5]);
	SSE_Endian_Reverse32(sse_W1[t+5]);
	SSE_Endian_Reverse32(sse_W2[t+5]);
        SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t+5], sse_W1[t+5], sse_W2[t+5], sse_W3[t+5] );

	sse_W[t+6] = _mm_set_epi32(_mm_extract_epi32(plain11,2), _mm_extract_epi32(plain21,2), _mm_extract_epi32(plain31,2), _mm_extract_epi32(plain41,2)); 
	sse_W1[t+6] = _mm_set_epi32(_mm_extract_epi32(plain51,2), _mm_extract_epi32(plain61,2), _mm_extract_epi32(plain71,2), _mm_extract_epi32(plain81,2)); 
	sse_W2[t+6] = _mm_set_epi32(_mm_extract_epi32(plain91,2), _mm_extract_epi32(plain101,2), _mm_extract_epi32(plain111,2), _mm_extract_epi32(plain121,2)); 
	SSE_Endian_Reverse32(sse_W[t+6]);
	SSE_Endian_Reverse32(sse_W1[t+6]);
	SSE_Endian_Reverse32(sse_W2[t+6]);
        SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3,  sse_W[t+6], sse_W1[t+6], sse_W2[t+6], sse_W3[t+6] );

	sse_W[t+7] = _mm_set_epi32(_mm_extract_epi32(plain11,3), _mm_extract_epi32(plain21,3), _mm_extract_epi32(plain31,3), _mm_extract_epi32(plain41,3)); 
	sse_W1[t+7] = _mm_set_epi32(_mm_extract_epi32(plain51,3), _mm_extract_epi32(plain61,3), _mm_extract_epi32(plain71,3), _mm_extract_epi32(plain81,3)); 
	sse_W2[t+7] = _mm_set_epi32(_mm_extract_epi32(plain91,3), _mm_extract_epi32(plain101,3), _mm_extract_epi32(plain111,3), _mm_extract_epi32(plain121,3)); 
	SSE_Endian_Reverse32(sse_W[t+7]);
	SSE_Endian_Reverse32(sse_W1[t+7]);
	SSE_Endian_Reverse32(sse_W2[t+7]);
        SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+7], sse_W1[t+7], sse_W2[t+7], sse_W3[t+7] );

	sse_W[t+8] = _mm_set_epi32(_mm_extract_epi32(plain12,0), _mm_extract_epi32(plain22,0), _mm_extract_epi32(plain32,0), _mm_extract_epi32(plain42,0)); 
	sse_W1[t+8] = _mm_set_epi32(_mm_extract_epi32(plain52,0), _mm_extract_epi32(plain62,0), _mm_extract_epi32(plain72,0), _mm_extract_epi32(plain82,0)); 
	sse_W2[t+8] = _mm_set_epi32(_mm_extract_epi32(plain92,0), _mm_extract_epi32(plain102,0), _mm_extract_epi32(plain112,0), _mm_extract_epi32(plain122,0)); 
	SSE_Endian_Reverse32(sse_W[t+8]);
	SSE_Endian_Reverse32(sse_W1[t+8]);
	SSE_Endian_Reverse32(sse_W2[t+8]);
        SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );

	sse_W[t+9] = _mm_set_epi32(_mm_extract_epi32(plain12,1), _mm_extract_epi32(plain22,1), _mm_extract_epi32(plain32,1), _mm_extract_epi32(plain42,1)); 
	sse_W1[t+9] = _mm_set_epi32(_mm_extract_epi32(plain52,1), _mm_extract_epi32(plain62,1), _mm_extract_epi32(plain72,1), _mm_extract_epi32(plain82,1)); 
	sse_W2[t+9] = _mm_set_epi32(_mm_extract_epi32(plain92,1), _mm_extract_epi32(plain102,1), _mm_extract_epi32(plain112,1), _mm_extract_epi32(plain122,1)); 
	SSE_Endian_Reverse32(sse_W[t+9]);
	SSE_Endian_Reverse32(sse_W1[t+9]);
	SSE_Endian_Reverse32(sse_W2[t+9]);
        SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    }



    for (t = 10; t < 15; t+=5)
    {
	sse_W[t] = _mm_setzero_si128(); 
	sse_W1[t] = _mm_setzero_si128(); 
	sse_W2[t] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3 );
        sse_W[t+1] = _mm_setzero_si128(); 
        sse_W1[t+1] = _mm_setzero_si128(); 
        sse_W2[t+1] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3 );
	sse_W[t+2] = _mm_setzero_si128(); 
	sse_W1[t+2] = _mm_setzero_si128(); 
	sse_W2[t+2] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3 );
        sse_W[t+3] = _mm_setzero_si128(); 
        sse_W1[t+3] = _mm_setzero_si128(); 
        sse_W2[t+3] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 );
        sse_W[t+4] = _mm_setzero_si128();
        sse_W1[t+4] = _mm_setzero_si128();
        sse_W2[t+4] = _mm_setzero_si128();
        SSE_ROTATE1_NULL( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3 );
    }

    // do last few steps of round 1
    sse_W[15] = _mm_set_epi32((lens[0] << 3),(lens[1] << 3),(lens[2] << 3),(lens[3] << 3));
    sse_W1[15] = _mm_set_epi32((lens[4] << 3),(lens[5] << 3),(lens[6] << 3),(lens[7] << 3));
    sse_W2[15] = _mm_set_epi32((lens[8] << 3),(lens[9] << 3),(lens[10] << 3),(lens[11] << 3));
    SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] ); // set length
    SSE_EXPAND(16); SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[16], sse_W1[16],sse_W2[16], sse_W3[16] );
    SSE_EXPAND(17); SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[17], sse_W1[17], sse_W2[17], sse_W3[17] );
    SSE_EXPAND(18); SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[18], sse_W1[18], sse_W2[18], sse_W3[18] );
    SSE_EXPAND(19); SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[19], sse_W1[19], sse_W2[19], sse_W3[19] );



    // round 2
    sse_K = _mm_set1_epi32(K1);

    for(t = 20; t < 40; t+=5)
    {
	SSE_EXPAND(t);   SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
	SSE_EXPAND(t+1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }

    // round 3
    sse_K = _mm_set1_epi32(K2);

    for(t = 40; t < 60; t+=5)
    {
        SSE_EXPAND(t);   SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
        SSE_EXPAND(t+1); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }

    // round 4 
    sse_K = _mm_set1_epi32(K3);

    for(t = 60; t < 80; t+=5 )
    {
        SSE_EXPAND(t);   SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
        SSE_EXPAND(t+1); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }


    sse_A = _mm_add_epi32(sse_A, HH0);
    sse_B = _mm_add_epi32(sse_B, HH1);
    sse_C = _mm_add_epi32(sse_C, HH2);
    sse_D = _mm_add_epi32(sse_D, HH3);
    sse_E = _mm_add_epi32(sse_E, HH4);
    sse_A1 = _mm_add_epi32(sse_A1, HH0);
    sse_B1 = _mm_add_epi32(sse_B1, HH1);
    sse_C1 = _mm_add_epi32(sse_C1, HH2);
    sse_D1 = _mm_add_epi32(sse_D1, HH3);
    sse_E1 = _mm_add_epi32(sse_E1, HH4);
    sse_A2 = _mm_add_epi32(sse_A2, HH0);
    sse_B2 = _mm_add_epi32(sse_B2, HH1);
    sse_C2 = _mm_add_epi32(sse_C2, HH2);
    sse_D2 = _mm_add_epi32(sse_D2, HH3);
    sse_E2 = _mm_add_epi32(sse_E2, HH4);


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

    SSE_Endian_Reverse32(sse_A);
    udigest4[0] = _mm_extract_epi32(sse_A, 0);
    udigest3[0] = _mm_extract_epi32(sse_A, 1);
    udigest2[0] = _mm_extract_epi32(sse_A, 2);
    udigest1[0] = _mm_extract_epi32(sse_A, 3);
    SSE_Endian_Reverse32(sse_B);
    udigest4[1] = _mm_extract_epi32(sse_B, 0);
    udigest3[1] = _mm_extract_epi32(sse_B, 1);
    udigest2[1] = _mm_extract_epi32(sse_B, 2);
    udigest1[1] = _mm_extract_epi32(sse_B, 3);
    SSE_Endian_Reverse32(sse_C);
    udigest4[2] = _mm_extract_epi32(sse_C, 0);
    udigest3[2] = _mm_extract_epi32(sse_C, 1);
    udigest2[2] = _mm_extract_epi32(sse_C, 2);
    udigest1[2] = _mm_extract_epi32(sse_C, 3);
    SSE_Endian_Reverse32(sse_D);
    udigest4[3] = _mm_extract_epi32(sse_D, 0);
    udigest3[3] = _mm_extract_epi32(sse_D, 1);
    udigest2[3] = _mm_extract_epi32(sse_D, 2);
    udigest1[3] = _mm_extract_epi32(sse_D, 3);
    SSE_Endian_Reverse32(sse_E);
    udigest4[4] = _mm_extract_epi32(sse_E, 0);
    udigest3[4] = _mm_extract_epi32(sse_E, 1);
    udigest2[4] = _mm_extract_epi32(sse_E, 2);
    udigest1[4] = _mm_extract_epi32(sse_E, 3);
    SSE_Endian_Reverse32(sse_A1);
    udigest8[0] = _mm_extract_epi32(sse_A1, 0);
    udigest7[0] = _mm_extract_epi32(sse_A1, 1);
    udigest6[0] = _mm_extract_epi32(sse_A1, 2);
    udigest5[0] = _mm_extract_epi32(sse_A1, 3);
    SSE_Endian_Reverse32(sse_B1);
    udigest8[1] = _mm_extract_epi32(sse_B1, 0);
    udigest7[1] = _mm_extract_epi32(sse_B1, 1);
    udigest6[1] = _mm_extract_epi32(sse_B1, 2);
    udigest5[1] = _mm_extract_epi32(sse_B1, 3);
    SSE_Endian_Reverse32(sse_C1);
    udigest8[2] = _mm_extract_epi32(sse_C1, 0);
    udigest7[2] = _mm_extract_epi32(sse_C1, 1);
    udigest6[2] = _mm_extract_epi32(sse_C1, 2);
    udigest5[2] = _mm_extract_epi32(sse_C1, 3);
    SSE_Endian_Reverse32(sse_D1);
    udigest8[3] = _mm_extract_epi32(sse_D1, 0);
    udigest7[3] = _mm_extract_epi32(sse_D1, 1);
    udigest6[3] = _mm_extract_epi32(sse_D1, 2);
    udigest5[3] = _mm_extract_epi32(sse_D1, 3);
    SSE_Endian_Reverse32(sse_E1);
    udigest8[4] = _mm_extract_epi32(sse_E1, 0);
    udigest7[4] = _mm_extract_epi32(sse_E1, 1);
    udigest6[4] = _mm_extract_epi32(sse_E1, 2);
    udigest5[4] = _mm_extract_epi32(sse_E1, 3);
    SSE_Endian_Reverse32(sse_A2);
    udigest12[0] = _mm_extract_epi32(sse_A2, 0);
    udigest11[0] = _mm_extract_epi32(sse_A2, 1);
    udigest10[0] = _mm_extract_epi32(sse_A2, 2);
    udigest9[0] = _mm_extract_epi32(sse_A2, 3);
    SSE_Endian_Reverse32(sse_B2);
    udigest12[1] = _mm_extract_epi32(sse_B2, 0);
    udigest11[1] = _mm_extract_epi32(sse_B2, 1);
    udigest10[1] = _mm_extract_epi32(sse_B2, 2);
    udigest9[1] = _mm_extract_epi32(sse_B2, 3);
    SSE_Endian_Reverse32(sse_C2);
    udigest12[2] = _mm_extract_epi32(sse_C2, 0);
    udigest11[2] = _mm_extract_epi32(sse_C2, 1);
    udigest10[2] = _mm_extract_epi32(sse_C2, 2);
    udigest9[2] = _mm_extract_epi32(sse_C2, 3);
    SSE_Endian_Reverse32(sse_D2);
    udigest12[3] = _mm_extract_epi32(sse_D2, 0);
    udigest11[3] = _mm_extract_epi32(sse_D2, 1);
    udigest10[3] = _mm_extract_epi32(sse_D2, 2);
    udigest9[3] = _mm_extract_epi32(sse_D2, 3);
    SSE_Endian_Reverse32(sse_E2);
    udigest12[4] = _mm_extract_epi32(sse_E2, 0);
    udigest11[4] = _mm_extract_epi32(sse_E2, 1);
    udigest10[4] = _mm_extract_epi32(sse_E2, 2);
    udigest9[4] = _mm_extract_epi32(sse_E2, 3);

    plains[0][lens[0]]=0x00;
    plains[1][lens[1]]=0x00;
    plains[2][lens[2]]=0x00;
    plains[3][lens[3]]=0x00;
    plains[4][lens[4]]=0x00;
    plains[5][lens[5]]=0x00;
    plains[6][lens[6]]=0x00;
    plains[7][lens[7]]=0x00;
    plains[8][lens[8]]=0x00;
    plains[9][lens[9]]=0x00;
    plains[10][lens[10]]=0x00;
    plains[11][lens[11]]=0x00;
    return hash_ok;
}



hash_stat SHA1_XOP_SHORT_FIXED(char *plains[VSIZE], char *hash[VSIZE], int lens)
{
    const __m128i m=_mm_set1_epi32(0x00FF00FFUL);
    const __m128i m2=_mm_set1_epi32(0xFF00FF00UL);
    int t;
    __m128i plain1, plain2, plain3, plain4;
    __m128i plain5, plain6, plain7, plain8;
    __m128i plain9, plain10, plain11, plain12;
    __m128i plain13, plain14, plain15, plain16;

    __m128i sse_W[17]; 
    __m128i sse_W1[17]; 
    __m128i sse_W2[17]; 
    __m128i sse_W3[17]; 
    __m128i sse_A, sse_B, sse_C, sse_D, sse_E, sse_temp;  
    __m128i sse_A1, sse_B1, sse_C1, sse_D1, sse_E1, sse_temp1;  
    __m128i sse_A2, sse_B2, sse_C2, sse_D2, sse_E2, sse_temp2;  
    __m128i sse_A3, sse_B3, sse_C3, sse_D3, sse_E3, sse_temp3;  

    __m128i sse_K, tmp1, tmp2, tmp3, tmp1_1, tmp1_2, tmp1_3, tmp2_1, tmp2_2, tmp2_3, tmp3_1, tmp3_2, tmp3_3;


    plains[0][lens]=0x80;
    plains[1][lens]=0x80;
    plains[2][lens]=0x80;
    plains[3][lens]=0x80;
    plains[4][lens]=0x80;
    plains[5][lens]=0x80;
    plains[6][lens]=0x80;
    plains[7][lens]=0x80;
    plains[8][lens]=0x80;
    plains[9][lens]=0x80;
    plains[10][lens]=0x80;
    plains[11][lens]=0x80;

    
#define udata1s ((UINT4 *)plains[0])
#define udata2s ((UINT4 *)plains[1])
#define udata3s ((UINT4 *)plains[2])
#define udata4s ((UINT4 *)plains[3])
#define udata5s ((UINT4 *)plains[4])
#define udata6s ((UINT4 *)plains[5])
#define udata7s ((UINT4 *)plains[6])
#define udata8s ((UINT4 *)plains[7])
#define udata9s ((UINT4 *)plains[8])
#define udata10s ((UINT4 *)plains[9])
#define udata11s ((UINT4 *)plains[10])
#define udata12s ((UINT4 *)plains[11])
#define udata13s ((UINT4 *)plains[12])
#define udata14s ((UINT4 *)plains[13])
#define udata15s ((UINT4 *)plains[14])
#define udata16s ((UINT4 *)plains[15])




    // load input into m128i
    plain1 = _mm_load_si128 ((__m128i *)udata1s);
    plain2 = _mm_load_si128 ((__m128i *)udata2s);
    plain3 = _mm_load_si128 ((__m128i *)udata3s);
    plain4 = _mm_load_si128 ((__m128i *)udata4s);
    plain5 = _mm_load_si128 ((__m128i *)udata5s);
    plain6 = _mm_load_si128 ((__m128i *)udata6s);
    plain7 = _mm_load_si128 ((__m128i *)udata7s);
    plain8 = _mm_load_si128 ((__m128i *)udata8s);
    plain9 = _mm_load_si128 ((__m128i *)udata9s);
    plain10 = _mm_load_si128 ((__m128i *)udata10s);
    plain11 = _mm_load_si128 ((__m128i *)udata11s);
    plain12 = _mm_load_si128 ((__m128i *)udata12s);


    sse_K = _mm_set1_epi32(K0);
    
    sse_W[0] = _mm_set_epi32(_mm_extract_epi32(plain1,0), _mm_extract_epi32(plain2,0), _mm_extract_epi32(plain3,0), _mm_extract_epi32(plain4,0));
    SSE_Endian_Reverse32(sse_W[0]);
    sse_B = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W[0]);
    sse_W1[0] = _mm_set_epi32(_mm_extract_epi32(plain5,0), _mm_extract_epi32(plain6,0), _mm_extract_epi32(plain7,0), _mm_extract_epi32(plain8,0));
    SSE_Endian_Reverse32(sse_W1[0]);
    sse_B1 = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W1[0]);
    sse_W2[0] = _mm_set_epi32(_mm_extract_epi32(plain9,0), _mm_extract_epi32(plain10,0), _mm_extract_epi32(plain11,0), _mm_extract_epi32(plain12,0));
    SSE_Endian_Reverse32(sse_W2[0]);
    sse_B2 = _mm_add_epi32(_mm_set1_epi32(2679412915UL), sse_W2[0]);


    sse_W[1] = _mm_set_epi32(_mm_extract_epi32(plain1,1), _mm_extract_epi32(plain2,1), _mm_extract_epi32(plain3,1), _mm_extract_epi32(plain4,1));
    SSE_Endian_Reverse32(sse_W[1]);
    sse_A = _mm_add_epi32(SSE_ROTATE(sse_B,5), _mm_set1_epi32(1722862861UL));
    sse_A = _mm_add_epi32(sse_A, sse_W[1]);
    sse_W1[1] = _mm_set_epi32(_mm_extract_epi32(plain5,1), _mm_extract_epi32(plain6,1), _mm_extract_epi32(plain7,1), _mm_extract_epi32(plain8,1));
    SSE_Endian_Reverse32(sse_W1[1]);
    sse_A1 = _mm_add_epi32(SSE_ROTATE(sse_B1,5), _mm_set1_epi32(1722862861UL));
    sse_A1 = _mm_add_epi32(sse_A1, sse_W1[1]);
    sse_W2[1] = _mm_set_epi32(_mm_extract_epi32(plain9,1), _mm_extract_epi32(plain10,1), _mm_extract_epi32(plain11,1), _mm_extract_epi32(plain12,1));
    SSE_Endian_Reverse32(sse_W2[1]);
    sse_A2 = _mm_add_epi32(SSE_ROTATE(sse_B2,5), _mm_set1_epi32(1722862861UL));
    sse_A2 = _mm_add_epi32(sse_A2, sse_W2[1]);


    sse_W[2] = _mm_set_epi32(_mm_extract_epi32(plain1,2), _mm_extract_epi32(plain2,2), _mm_extract_epi32(plain3,2), _mm_extract_epi32(plain4,2));
    SSE_Endian_Reverse32(sse_W[2]);
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_A,5), ((_mm_set1_epi32(572662306UL) & sse_B) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(H2+K0));
    sse_temp = _mm_add_epi32(sse_temp,sse_W[2]);
    sse_E = SSE_ROTATE(sse_B,30);
    sse_B = sse_temp;
    sse_W1[2] = _mm_set_epi32(_mm_extract_epi32(plain5,2), _mm_extract_epi32(plain6,2), _mm_extract_epi32(plain7,2), _mm_extract_epi32(plain8,2));
    SSE_Endian_Reverse32(sse_W1[2]);
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_A1,5), ((_mm_set1_epi32(572662306UL) & sse_B1) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(H2+K0));
    sse_temp1 = _mm_add_epi32(sse_temp1,sse_W1[2]);
    sse_E1 = SSE_ROTATE(sse_B1,30);
    sse_B1 = sse_temp1;
    sse_W2[2] = _mm_set_epi32(_mm_extract_epi32(plain9,2), _mm_extract_epi32(plain10,2), _mm_extract_epi32(plain11,2), _mm_extract_epi32(plain12,2));
    SSE_Endian_Reverse32(sse_W2[2]);
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_A2,5), ((_mm_set1_epi32(572662306UL) & sse_B2) ^ _mm_set1_epi32(2079550178UL)));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(H2+K0));
    sse_temp2 = _mm_add_epi32(sse_temp2,sse_W2[2]);
    sse_E2 = SSE_ROTATE(sse_B2,30);
    sse_B2 = sse_temp2;


    sse_W[3] = _mm_setzero_si128();
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_B,5), (((sse_E ^ _mm_set1_epi32(1506887872UL)) & sse_A) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(2079550178UL+K0));
    sse_temp = _mm_add_epi32(sse_temp, sse_W[3]);
    sse_D = SSE_ROTATE(sse_A,30);
    sse_A = sse_temp;
    sse_W1[3] = _mm_setzero_si128();
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_B1,5), (((sse_E1 ^ _mm_set1_epi32(1506887872UL)) & sse_A1) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(2079550178UL+K0));
    sse_temp1 = _mm_add_epi32(sse_temp1, sse_W1[3]);
    sse_D1 = SSE_ROTATE(sse_A1,30);
    sse_A1 = sse_temp1;
    sse_W2[3] = _mm_setzero_si128();
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_B2,5), (((sse_E2 ^ _mm_set1_epi32(1506887872UL)) & sse_A2) ^ _mm_set1_epi32(1506887872UL)));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(2079550178UL+K0));
    sse_temp2 = _mm_add_epi32(sse_temp2, sse_W2[3]);
    sse_D2 = SSE_ROTATE(sse_A2,30);
    sse_A2 = sse_temp2;


    sse_W[4] = _mm_setzero_si128();
    sse_temp = _mm_add_epi32(SSE_ROTATE(sse_A,5), F_00_19(sse_B,sse_D,sse_E));
    sse_temp = _mm_add_epi32(sse_temp, _mm_set1_epi32(1506887872UL+K0));
    sse_C = SSE_ROTATE(sse_B,30);
    sse_B = sse_A;
    sse_A = sse_temp;
    sse_W1[4] = _mm_setzero_si128();
    sse_temp1 = _mm_add_epi32(SSE_ROTATE(sse_A1,5), F_00_19(sse_B1,sse_D1,sse_E1));
    sse_temp1 = _mm_add_epi32(sse_temp1, _mm_set1_epi32(1506887872UL+K0));
    sse_C1 = SSE_ROTATE(sse_B1,30);
    sse_B1 = sse_A1;
    sse_A1 = sse_temp1;
    sse_W2[4] = _mm_setzero_si128();
    sse_temp2 = _mm_add_epi32(SSE_ROTATE(sse_A2,5), F_00_19(sse_B2,sse_D2,sse_E2));
    sse_temp2 = _mm_add_epi32(sse_temp2, _mm_set1_epi32(1506887872UL+K0));
    sse_C2 = SSE_ROTATE(sse_B2,30);
    sse_B2 = sse_A2;
    sse_A2 = sse_temp2;


    // do next steps of round 1 where W[5]...W[14] = 0
    for (t = 5; t < 15; t+=5)
    {
	sse_W[t] = _mm_setzero_si128(); 
	sse_W1[t] = _mm_setzero_si128(); 
	sse_W2[t] = _mm_setzero_si128(); 
	SSE_ROTATE1_NULL( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3 );
        sse_W[t+1] = _mm_setzero_si128(); 
        sse_W1[t+1] = _mm_setzero_si128(); 
        sse_W2[t+1] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3 );
	sse_W[t+2] = _mm_setzero_si128(); 
	sse_W1[t+2] = _mm_setzero_si128(); 
	sse_W2[t+2] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3 );
        sse_W[t+3] = _mm_setzero_si128(); 
        sse_W1[t+3] = _mm_setzero_si128(); 
        sse_W2[t+3] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 );
        sse_W[t+4] = _mm_setzero_si128(); 
        sse_W1[t+4] = _mm_setzero_si128(); 
        sse_W2[t+4] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3 );
    }


#define SSE_EXPAND1(t1,t2,t3,t4,t5) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3] ^ sse_W[t4] ^ sse_W[t5],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3] ^ sse_W1[t4] ^ sse_W1[t5],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3] ^ sse_W2[t4] ^ sse_W2[t5],1); \
}

#define SSE_EXPAND1_3(t1,t2,t3,t4) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3] ^ sse_W[t4],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3] ^ sse_W1[t4],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3] ^ sse_W2[t4],1); \
}

#define SSE_EXPAND1_2(t1,t2,t3) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2] ^ sse_W[t3],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2] ^ sse_W1[t3],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2] ^ sse_W2[t3],1); \
}

#define SSE_EXPAND1_1(t1,t2) \
{ \
sse_W[t1] = SSE_ROTATE(sse_W[t2],1); \
sse_W1[t1] = SSE_ROTATE(sse_W1[t2],1); \
sse_W2[t1] = SSE_ROTATE(sse_W2[t2],1); \
}


    // do last few steps of round 1

    sse_W[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W1[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W2[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W3[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] ); // set length
    SSE_EXPAND1_2(16,2,0); 
    SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[16], sse_W1[16],sse_W2[16], sse_W3[16] );
    SSE_EXPAND1_2(0,3,1); 
    SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1_2(1,15,2); 
    SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1_2(2,16,3);
    SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );


    // round 2
    sse_K = _mm_set1_epi32(K1);

    SSE_EXPAND1_1(3,0); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1_1(4,1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1_1(5,2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1_2(6,3,15); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1_2(7,4,16); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1_2(8,5,0); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1_2(9,6,1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1_2(10,7,2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1_2(11,8,3); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1_3(12,9,4,15); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1_3(13,10,5,16); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );

    // round 3
    sse_K = _mm_set1_epi32(K2);
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1(12,9,4,15,13); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1(13,10,5,16,14); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );
    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );


    // round 4 
    sse_K = _mm_set1_epi32(K3);
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );
    SSE_EXPAND1(12,9,4,15,13); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[12], sse_W1[12], sse_W2[12], sse_W3[12] );
    SSE_EXPAND1(13,10,5,16,14); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[13], sse_W1[13], sse_W2[13], sse_W3[13] );
    SSE_EXPAND1(14,11,6,0,15); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[14], sse_W1[14], sse_W2[14], sse_W3[14] );
    SSE_EXPAND1(15,12,7,1,16); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] );
    SSE_EXPAND1(16,13,8,2,0); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[16], sse_W1[16], sse_W2[16], sse_W3[16] );
    SSE_EXPAND1(0,14,9,3,1); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[0], sse_W1[0], sse_W2[0], sse_W3[0] );
    SSE_EXPAND1(1,15,10,4,2); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[1], sse_W1[1], sse_W2[1], sse_W3[1] );
    SSE_EXPAND1(2,16,11,5,3); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[2], sse_W1[2], sse_W2[2], sse_W3[2] );
    SSE_EXPAND1(3,0,12,6,4); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[3], sse_W1[3], sse_W2[3], sse_W3[3] );
    SSE_EXPAND1(4,1,13,7,5); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[4], sse_W1[4], sse_W2[4], sse_W3[4] );
    SSE_EXPAND1(5,2,14,8,6); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[5], sse_W1[5], sse_W2[5], sse_W3[5] );
    SSE_EXPAND1(6,3,15,9,7); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[6], sse_W1[6], sse_W2[6], sse_W3[6] );
    SSE_EXPAND1(7,4,16,10,8); SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[7], sse_W1[7], sse_W2[7], sse_W3[7] );


    SSE_EXPAND1(8,5,0,11,9); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );
    SSE_EXPAND1(9,6,1,12,10); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    SSE_EXPAND1(10,7,2,13,11); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[10], sse_W1[10], sse_W2[10], sse_W3[10] );
    SSE_EXPAND1(11,8,3,14,12); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[11], sse_W1[11], sse_W2[11], sse_W3[11] );




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

    if ((cpu_optimize_single==1))
    {
	int r1 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A));
	int r2 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A1));
	int r3 = _mm_movemask_epi8(_mm_cmpeq_epi32(A, sse_A2));
	if ((r1==0)&&(r2==0)&&(r3==0)) return hash_err;
    }


    __m128i HH0, HH1, HH2, HH3, HH4;
    HH0 = _mm_set1_epi32(H0);
    HH1 = _mm_set1_epi32(H1);
    HH2 = _mm_set1_epi32(H2);
    HH3 = _mm_set1_epi32(H3);
    HH4 = _mm_set1_epi32(H4);

    sse_A = _mm_add_epi32(sse_A, HH0);
    sse_B = _mm_add_epi32(sse_B, HH1);
    sse_C = _mm_add_epi32(sse_C, HH2);
    sse_D = _mm_add_epi32(sse_D, HH3);
    sse_E = _mm_add_epi32(sse_E, HH4);
    sse_A1 = _mm_add_epi32(sse_A1, HH0);
    sse_B1 = _mm_add_epi32(sse_B1, HH1);
    sse_C1 = _mm_add_epi32(sse_C1, HH2);
    sse_D1 = _mm_add_epi32(sse_D1, HH3);
    sse_E1 = _mm_add_epi32(sse_E1, HH4);
    sse_A2 = _mm_add_epi32(sse_A2, HH0);
    sse_B2 = _mm_add_epi32(sse_B2, HH1);
    sse_C2 = _mm_add_epi32(sse_C2, HH2);
    sse_D2 = _mm_add_epi32(sse_D2, HH3);
    sse_E2 = _mm_add_epi32(sse_E2, HH4);

    SSE_Endian_Reverse32(sse_A);
    SSE_Endian_Reverse32(sse_B);
    SSE_Endian_Reverse32(sse_C);
    SSE_Endian_Reverse32(sse_D);
    SSE_Endian_Reverse32(sse_E);
    SSE_Endian_Reverse32(sse_A1);
    SSE_Endian_Reverse32(sse_B1);
    SSE_Endian_Reverse32(sse_C1);
    SSE_Endian_Reverse32(sse_D1);
    SSE_Endian_Reverse32(sse_E1);
    SSE_Endian_Reverse32(sse_A2);
    SSE_Endian_Reverse32(sse_B2);
    SSE_Endian_Reverse32(sse_C2);
    SSE_Endian_Reverse32(sse_D2);
    SSE_Endian_Reverse32(sse_E2);

    udigest4[0] = _mm_extract_epi32(sse_A, 0);
    udigest3[0] = _mm_extract_epi32(sse_A, 1);
    udigest2[0] = _mm_extract_epi32(sse_A, 2);
    udigest1[0] = _mm_extract_epi32(sse_A, 3);
    udigest4[1] = _mm_extract_epi32(sse_B, 0);
    udigest3[1] = _mm_extract_epi32(sse_B, 1);
    udigest2[1] = _mm_extract_epi32(sse_B, 2);
    udigest1[1] = _mm_extract_epi32(sse_B, 3);
    udigest4[2] = _mm_extract_epi32(sse_C, 0);
    udigest3[2] = _mm_extract_epi32(sse_C, 1);
    udigest2[2] = _mm_extract_epi32(sse_C, 2);
    udigest1[2] = _mm_extract_epi32(sse_C, 3);
    udigest4[3] = _mm_extract_epi32(sse_D, 0);
    udigest3[3] = _mm_extract_epi32(sse_D, 1);
    udigest2[3] = _mm_extract_epi32(sse_D, 2);
    udigest1[3] = _mm_extract_epi32(sse_D, 3);
    udigest4[4] = _mm_extract_epi32(sse_E, 0);
    udigest3[4] = _mm_extract_epi32(sse_E, 1);
    udigest2[4] = _mm_extract_epi32(sse_E, 2);
    udigest1[4] = _mm_extract_epi32(sse_E, 3);
    udigest8[0] = _mm_extract_epi32(sse_A1, 0);
    udigest7[0] = _mm_extract_epi32(sse_A1, 1);
    udigest6[0] = _mm_extract_epi32(sse_A1, 2);
    udigest5[0] = _mm_extract_epi32(sse_A1, 3);
    udigest8[1] = _mm_extract_epi32(sse_B1, 0);
    udigest7[1] = _mm_extract_epi32(sse_B1, 1);
    udigest6[1] = _mm_extract_epi32(sse_B1, 2);
    udigest5[1] = _mm_extract_epi32(sse_B1, 3);
    udigest8[2] = _mm_extract_epi32(sse_C1, 0);
    udigest7[2] = _mm_extract_epi32(sse_C1, 1);
    udigest6[2] = _mm_extract_epi32(sse_C1, 2);
    udigest5[2] = _mm_extract_epi32(sse_C1, 3);
    udigest8[3] = _mm_extract_epi32(sse_D1, 0);
    udigest7[3] = _mm_extract_epi32(sse_D1, 1);
    udigest6[3] = _mm_extract_epi32(sse_D1, 2);
    udigest5[3] = _mm_extract_epi32(sse_D1, 3);
    udigest8[4] = _mm_extract_epi32(sse_E1, 0);
    udigest7[4] = _mm_extract_epi32(sse_E1, 1);
    udigest6[4] = _mm_extract_epi32(sse_E1, 2);
    udigest5[4] = _mm_extract_epi32(sse_E1, 3);
    udigest12[0] = _mm_extract_epi32(sse_A2, 0);
    udigest11[0] = _mm_extract_epi32(sse_A2, 1);
    udigest10[0] = _mm_extract_epi32(sse_A2, 2);
    udigest9[0] = _mm_extract_epi32(sse_A2, 3);
    udigest12[1] = _mm_extract_epi32(sse_B2, 0);
    udigest11[1] = _mm_extract_epi32(sse_B2, 1);
    udigest10[1] = _mm_extract_epi32(sse_B2, 2);
    udigest9[1] = _mm_extract_epi32(sse_B2, 3);
    udigest12[2] = _mm_extract_epi32(sse_C2, 0);
    udigest11[2] = _mm_extract_epi32(sse_C2, 1);
    udigest10[2] = _mm_extract_epi32(sse_C2, 2);
    udigest9[2] = _mm_extract_epi32(sse_C2, 3);
    udigest12[3] = _mm_extract_epi32(sse_D2, 0);
    udigest11[3] = _mm_extract_epi32(sse_D2, 1);
    udigest10[3] = _mm_extract_epi32(sse_D2, 2);
    udigest9[3] = _mm_extract_epi32(sse_D2, 3);
    udigest12[4] = _mm_extract_epi32(sse_E2, 0);
    udigest11[4] = _mm_extract_epi32(sse_E2, 1);
    udigest10[4] = _mm_extract_epi32(sse_E2, 2);
    udigest9[4] = _mm_extract_epi32(sse_E2, 3);

    plains[0][lens]=0x00;
    plains[1][lens]=0x00;
    plains[2][lens]=0x00;
    plains[3][lens]=0x00;
    plains[4][lens]=0x00;
    plains[5][lens]=0x00;
    plains[6][lens]=0x00;
    plains[7][lens]=0x00;
    plains[8][lens]=0x00;
    plains[9][lens]=0x00;
    plains[10][lens]=0x00;
    plains[11][lens]=0x00;
    return hash_ok;
}




hash_stat SHA1_XOP_FIXED(char *plains[VSIZE], char *hash[VSIZE], int lens)
{

    const __m128i m=_mm_set1_epi32(0x00FF00FF);
    const __m128i m2=_mm_set1_epi32(0xFF00FF00);
    int t;
    __m128i plain10, plain20, plain30, plain40;
    __m128i plain11, plain21, plain31, plain41;
    __m128i plain12, plain22, plain32, plain42;
    __m128i plain50, plain60, plain70, plain80;
    __m128i plain51, plain61, plain71, plain81;
    __m128i plain52, plain62, plain72, plain82;
    __m128i plain90, plain100, plain110, plain120;
    __m128i plain91, plain101, plain111, plain121;
    __m128i plain92, plain102, plain112, plain122;
    __m128i plain130, plain140, plain150, plain160;
    __m128i plain131, plain141, plain151, plain161;
    __m128i plain132, plain142, plain152, plain162;



    __m128i sse_W[80]; 
    __m128i sse_A, sse_B, sse_C, sse_D, sse_E;  
    __m128i sse_K, tmp1, tmp2, tmp3, tmp1_1, tmp1_2, tmp1_3, tmp2_1, tmp2_2, tmp2_3, tmp3_1, tmp3_2, tmp3_3;

    __m128i sse_W1[80]; 
    __m128i sse_A1, sse_B1, sse_C1, sse_D1, sse_E1;  
    __m128i sse_W2[80]; 
    __m128i sse_A2, sse_B2, sse_C2, sse_D2, sse_E2;  
    __m128i sse_W3[80]; 
    __m128i sse_A3, sse_B3, sse_C3, sse_D3, sse_E3;  


    plains[0][lens]=0x80;
    plains[1][lens]=0x80;
    plains[2][lens]=0x80;
    plains[3][lens]=0x80;
    plains[4][lens]=0x80;
    plains[5][lens]=0x80;
    plains[6][lens]=0x80;
    plains[7][lens]=0x80;
    plains[8][lens]=0x80;
    plains[9][lens]=0x80;
    plains[10][lens]=0x80;
    plains[11][lens]=0x80;


#define udata10 ((UINT4 *)plains[0])
#define udata20 ((UINT4 *)plains[1])
#define udata30 ((UINT4 *)plains[2])
#define udata40 ((UINT4 *)plains[3])
#define udata11 ((UINT4 *)(&plains[0][16]))
#define udata21 ((UINT4 *)(&plains[1][16]))
#define udata31 ((UINT4 *)(&plains[2][16]))
#define udata41 ((UINT4 *)(&plains[3][16]))
#define udata12 ((UINT4 *)(&plains[0][32]))
#define udata22 ((UINT4 *)(&plains[1][32]))
#define udata32 ((UINT4 *)(&plains[2][32]))
#define udata42 ((UINT4 *)(&plains[3][32]))
#define udata50 ((UINT4 *)plains[4])
#define udata60 ((UINT4 *)plains[5])
#define udata70 ((UINT4 *)plains[6])
#define udata80 ((UINT4 *)plains[7])
#define udata51 ((UINT4 *)(&plains[4][16]))
#define udata61 ((UINT4 *)(&plains[5][16]))
#define udata71 ((UINT4 *)(&plains[6][16]))
#define udata81 ((UINT4 *)(&plains[7][16]))
#define udata52 ((UINT4 *)(&plains[4][32]))
#define udata62 ((UINT4 *)(&plains[5][32]))
#define udata72 ((UINT4 *)(&plains[6][32]))
#define udata82 ((UINT4 *)(&plains[7][32]))
#define udata90 ((UINT4 *)plains[8])
#define udata100 ((UINT4 *)plains[9])
#define udata110 ((UINT4 *)plains[10])
#define udata120 ((UINT4 *)plains[11])
#define udata91 ((UINT4 *)(&plains[8][16]))
#define udata101 ((UINT4 *)(&plains[9][16]))
#define udata111 ((UINT4 *)(&plains[10][16]))
#define udata121 ((UINT4 *)(&plains[11][16]))
#define udata92 ((UINT4 *)(&plains[8][32]))
#define udata102 ((UINT4 *)(&plains[9][32]))
#define udata112 ((UINT4 *)(&plains[10][32]))
#define udata122 ((UINT4 *)(&plains[11][32]))
#define udata130 ((UINT4 *)plains[12])
#define udata140 ((UINT4 *)plains[13])
#define udata150 ((UINT4 *)plains[14])
#define udata160 ((UINT4 *)plains[15])
#define udata131 ((UINT4 *)(&plains[12][16]))
#define udata141 ((UINT4 *)(&plains[13][16]))
#define udata151 ((UINT4 *)(&plains[14][16]))
#define udata161 ((UINT4 *)(&plains[15][16]))
#define udata132 ((UINT4 *)(&plains[12][32]))
#define udata142 ((UINT4 *)(&plains[13][32]))
#define udata152 ((UINT4 *)(&plains[14][32]))
#define udata162 ((UINT4 *)(&plains[15][32]))


    // load input into m128i
    plain10 = _mm_load_si128 ((__m128i *)udata10);
    plain20 = _mm_load_si128 ((__m128i *)udata20);
    plain30 = _mm_load_si128 ((__m128i *)udata30);
    plain40 = _mm_load_si128 ((__m128i *)udata40);
    plain11 = _mm_load_si128 ((__m128i *)udata11);
    plain21 = _mm_load_si128 ((__m128i *)udata21);
    plain31 = _mm_load_si128 ((__m128i *)udata31);
    plain41 = _mm_load_si128 ((__m128i *)udata41);
    plain12 = _mm_load_si128 ((__m128i *)udata12);
    plain22 = _mm_load_si128 ((__m128i *)udata22);
    plain32 = _mm_load_si128 ((__m128i *)udata32);
    plain42 = _mm_load_si128 ((__m128i *)udata42);

    plain50 = _mm_load_si128 ((__m128i *)udata50);
    plain60 = _mm_load_si128 ((__m128i *)udata60);
    plain70 = _mm_load_si128 ((__m128i *)udata70);
    plain80 = _mm_load_si128 ((__m128i *)udata80);
    plain51 = _mm_load_si128 ((__m128i *)udata51);
    plain61 = _mm_load_si128 ((__m128i *)udata61);
    plain71 = _mm_load_si128 ((__m128i *)udata71);
    plain81 = _mm_load_si128 ((__m128i *)udata81);
    plain52 = _mm_load_si128 ((__m128i *)udata52);
    plain62 = _mm_load_si128 ((__m128i *)udata62);
    plain72 = _mm_load_si128 ((__m128i *)udata72);
    plain82 = _mm_load_si128 ((__m128i *)udata82);

    plain90 = _mm_load_si128 ((__m128i *)udata90);
    plain100 = _mm_load_si128 ((__m128i *)udata100);
    plain110 = _mm_load_si128 ((__m128i *)udata110);
    plain120 = _mm_load_si128 ((__m128i *)udata120);
    plain91 = _mm_load_si128 ((__m128i *)udata91);
    plain101 = _mm_load_si128 ((__m128i *)udata101);
    plain111 = _mm_load_si128 ((__m128i *)udata111);
    plain121 = _mm_load_si128 ((__m128i *)udata121);
    plain92 = _mm_load_si128 ((__m128i *)udata92);
    plain102 = _mm_load_si128 ((__m128i *)udata102);
    plain112 = _mm_load_si128 ((__m128i *)udata112);
    plain122 = _mm_load_si128 ((__m128i *)udata122);



    __m128i HH0, HH1, HH2, HH3, HH4;
    HH0 = _mm_set1_epi32(H0);
    HH1 = _mm_set1_epi32(H1);
    HH2 = _mm_set1_epi32(H2);
    HH3 = _mm_set1_epi32(H3);
    HH4 = _mm_set1_epi32(H4);

    sse_A = _mm_set1_epi32(H0);
    sse_B = _mm_set1_epi32(H1);
    sse_C = _mm_set1_epi32(H2);
    sse_D = _mm_set1_epi32(H3);
    sse_E = _mm_set1_epi32(H4);
    sse_A1 = _mm_set1_epi32(H0);
    sse_B1 = _mm_set1_epi32(H1);
    sse_C1 = _mm_set1_epi32(H2);
    sse_D1 = _mm_set1_epi32(H3);
    sse_E1 = _mm_set1_epi32(H4);
    sse_A2 = _mm_set1_epi32(H0);
    sse_B2 = _mm_set1_epi32(H1);
    sse_C2 = _mm_set1_epi32(H2);
    sse_D2 = _mm_set1_epi32(H3);
    sse_E2 = _mm_set1_epi32(H4);



    sse_K = _mm_set1_epi32(K0);
    sse_W[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W1[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W2[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));


    // do next steps of round 1 where W[5]...W[14] = 0
    for (t = 0; t < 10; t+=10)
    {
	sse_W[t] = _mm_set_epi32(_mm_extract_epi32(plain10,0), _mm_extract_epi32(plain20,0), _mm_extract_epi32(plain30,0), _mm_extract_epi32(plain40,0)); 
	sse_W1[t] = _mm_set_epi32(_mm_extract_epi32(plain50,0), _mm_extract_epi32(plain60,0), _mm_extract_epi32(plain70,0), _mm_extract_epi32(plain80,0)); 
	sse_W2[t] = _mm_set_epi32(_mm_extract_epi32(plain90,0), _mm_extract_epi32(plain100,0), _mm_extract_epi32(plain110,0), _mm_extract_epi32(plain120,0)); 
	SSE_Endian_Reverse32(sse_W[t]);
	SSE_Endian_Reverse32(sse_W1[t]);
	SSE_Endian_Reverse32(sse_W2[t]);
	SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t],sse_W1[t], sse_W2[t],sse_W3[t] );

	sse_W[t+1] = _mm_set_epi32(_mm_extract_epi32(plain10,1), _mm_extract_epi32(plain20,1), _mm_extract_epi32(plain30,1), _mm_extract_epi32(plain40,1)); 
	sse_W1[t+1] = _mm_set_epi32(_mm_extract_epi32(plain50,1), _mm_extract_epi32(plain60,1), _mm_extract_epi32(plain70,1), _mm_extract_epi32(plain80,1)); 
	sse_W2[t+1] = _mm_set_epi32(_mm_extract_epi32(plain90,1), _mm_extract_epi32(plain100,1), _mm_extract_epi32(plain110,1), _mm_extract_epi32(plain120,1)); 
	SSE_Endian_Reverse32(sse_W[t+1]);
	SSE_Endian_Reverse32(sse_W1[t+1]);
	SSE_Endian_Reverse32(sse_W2[t+1]);
        SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1],sse_W1[t+1],sse_W2[t+1],sse_W3[t+1] );

	sse_W[t+2] = _mm_set_epi32(_mm_extract_epi32(plain10,2), _mm_extract_epi32(plain20,2), _mm_extract_epi32(plain30,2), _mm_extract_epi32(plain40,2)); 
	sse_W1[t+2] = _mm_set_epi32(_mm_extract_epi32(plain50,2), _mm_extract_epi32(plain60,2), _mm_extract_epi32(plain70,2), _mm_extract_epi32(plain80,2)); 
	sse_W2[t+2] = _mm_set_epi32(_mm_extract_epi32(plain90,2), _mm_extract_epi32(plain100,2), _mm_extract_epi32(plain110,2), _mm_extract_epi32(plain120,2)); 
	SSE_Endian_Reverse32(sse_W[t+2]);
	SSE_Endian_Reverse32(sse_W1[t+2]);
	SSE_Endian_Reverse32(sse_W2[t+2]);
	SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2],sse_W1[t+2],sse_W2[t+2],sse_W3[t+2] );

	sse_W[t+3] = _mm_set_epi32(_mm_extract_epi32(plain10,3), _mm_extract_epi32(plain20,3), _mm_extract_epi32(plain30,3), _mm_extract_epi32(plain40,3)); 
	sse_W1[t+3] = _mm_set_epi32(_mm_extract_epi32(plain50,3), _mm_extract_epi32(plain60,3), _mm_extract_epi32(plain70,3), _mm_extract_epi32(plain80,3)); 
	sse_W2[t+3] = _mm_set_epi32(_mm_extract_epi32(plain90,3), _mm_extract_epi32(plain100,3), _mm_extract_epi32(plain110,3), _mm_extract_epi32(plain120,3)); 
	SSE_Endian_Reverse32(sse_W[t+3]);
	SSE_Endian_Reverse32(sse_W1[t+3]);
	SSE_Endian_Reverse32(sse_W2[t+3]);
        SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1,sse_E2,sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 ,sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );

	sse_W[t+4] = _mm_set_epi32(_mm_extract_epi32(plain11,0), _mm_extract_epi32(plain21,0), _mm_extract_epi32(plain31,0), _mm_extract_epi32(plain41,0)); 
	sse_W1[t+4] = _mm_set_epi32(_mm_extract_epi32(plain51,0), _mm_extract_epi32(plain61,0), _mm_extract_epi32(plain71,0), _mm_extract_epi32(plain81,0)); 
	sse_W2[t+4] = _mm_set_epi32(_mm_extract_epi32(plain91,0), _mm_extract_epi32(plain101,0), _mm_extract_epi32(plain111,0), _mm_extract_epi32(plain121,0)); 
	SSE_Endian_Reverse32(sse_W[t+4]);
	SSE_Endian_Reverse32(sse_W1[t+4]);
	SSE_Endian_Reverse32(sse_W2[t+4]);
        SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );

	sse_W[t+5] = _mm_set_epi32(_mm_extract_epi32(plain11,1), _mm_extract_epi32(plain21,1), _mm_extract_epi32(plain31,1), _mm_extract_epi32(plain41,1)); 
	sse_W1[t+5] = _mm_set_epi32(_mm_extract_epi32(plain51,1), _mm_extract_epi32(plain61,1), _mm_extract_epi32(plain71,1), _mm_extract_epi32(plain81,1)); 
	sse_W2[t+5] = _mm_set_epi32(_mm_extract_epi32(plain91,1), _mm_extract_epi32(plain101,1), _mm_extract_epi32(plain111,1), _mm_extract_epi32(plain121,1)); 
	SSE_Endian_Reverse32(sse_W[t+5]);
	SSE_Endian_Reverse32(sse_W1[t+5]);
	SSE_Endian_Reverse32(sse_W2[t+5]);
        SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t+5], sse_W1[t+5], sse_W2[t+5], sse_W3[t+5] );

	sse_W[t+6] = _mm_set_epi32(_mm_extract_epi32(plain11,2), _mm_extract_epi32(plain21,2), _mm_extract_epi32(plain31,2), _mm_extract_epi32(plain41,2)); 
	sse_W1[t+6] = _mm_set_epi32(_mm_extract_epi32(plain51,2), _mm_extract_epi32(plain61,2), _mm_extract_epi32(plain71,2), _mm_extract_epi32(plain81,2)); 
	sse_W2[t+6] = _mm_set_epi32(_mm_extract_epi32(plain91,2), _mm_extract_epi32(plain101,2), _mm_extract_epi32(plain111,2), _mm_extract_epi32(plain121,2)); 
	SSE_Endian_Reverse32(sse_W[t+6]);
	SSE_Endian_Reverse32(sse_W1[t+6]);
	SSE_Endian_Reverse32(sse_W2[t+6]);
        SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3,  sse_W[t+6], sse_W1[t+6], sse_W2[t+6], sse_W3[t+6] );

	sse_W[t+7] = _mm_set_epi32(_mm_extract_epi32(plain11,3), _mm_extract_epi32(plain21,3), _mm_extract_epi32(plain31,3), _mm_extract_epi32(plain41,3)); 
	sse_W1[t+7] = _mm_set_epi32(_mm_extract_epi32(plain51,3), _mm_extract_epi32(plain61,3), _mm_extract_epi32(plain71,3), _mm_extract_epi32(plain81,3)); 
	sse_W2[t+7] = _mm_set_epi32(_mm_extract_epi32(plain91,3), _mm_extract_epi32(plain101,3), _mm_extract_epi32(plain111,3), _mm_extract_epi32(plain121,3)); 
	SSE_Endian_Reverse32(sse_W[t+7]);
	SSE_Endian_Reverse32(sse_W1[t+7]);
	SSE_Endian_Reverse32(sse_W2[t+7]);
        SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+7], sse_W1[t+7], sse_W2[t+7], sse_W3[t+7] );

	sse_W[t+8] = _mm_set_epi32(_mm_extract_epi32(plain12,0), _mm_extract_epi32(plain22,0), _mm_extract_epi32(plain32,0), _mm_extract_epi32(plain42,0)); 
	sse_W1[t+8] = _mm_set_epi32(_mm_extract_epi32(plain52,0), _mm_extract_epi32(plain62,0), _mm_extract_epi32(plain72,0), _mm_extract_epi32(plain82,0)); 
	sse_W2[t+8] = _mm_set_epi32(_mm_extract_epi32(plain92,0), _mm_extract_epi32(plain102,0), _mm_extract_epi32(plain112,0), _mm_extract_epi32(plain122,0)); 
	SSE_Endian_Reverse32(sse_W[t+8]);
	SSE_Endian_Reverse32(sse_W1[t+8]);
	SSE_Endian_Reverse32(sse_W2[t+8]);
        SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[8], sse_W1[8], sse_W2[8], sse_W3[8] );

	sse_W[t+9] = _mm_set_epi32(_mm_extract_epi32(plain12,1), _mm_extract_epi32(plain22,1), _mm_extract_epi32(plain32,1), _mm_extract_epi32(plain42,1)); 
	sse_W1[t+9] = _mm_set_epi32(_mm_extract_epi32(plain52,1), _mm_extract_epi32(plain62,1), _mm_extract_epi32(plain72,1), _mm_extract_epi32(plain82,1)); 
	sse_W2[t+9] = _mm_set_epi32(_mm_extract_epi32(plain92,1), _mm_extract_epi32(plain102,1), _mm_extract_epi32(plain112,1), _mm_extract_epi32(plain122,1)); 
	SSE_Endian_Reverse32(sse_W[t+9]);
	SSE_Endian_Reverse32(sse_W1[t+9]);
	SSE_Endian_Reverse32(sse_W2[t+9]);
        SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[9], sse_W1[9], sse_W2[9], sse_W3[9] );
    }



    for (t = 10; t < 15; t+=5)
    {
	sse_W[t] = _mm_setzero_si128(); 
	sse_W1[t] = _mm_setzero_si128(); 
	sse_W2[t] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3 );
        sse_W[t+1] = _mm_setzero_si128(); 
        sse_W1[t+1] = _mm_setzero_si128(); 
        sse_W2[t+1] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3 );
	sse_W[t+2] = _mm_setzero_si128(); 
	sse_W1[t+2] = _mm_setzero_si128(); 
	sse_W2[t+2] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3 );
        sse_W[t+3] = _mm_setzero_si128(); 
        sse_W1[t+3] = _mm_setzero_si128(); 
        sse_W2[t+3] = _mm_setzero_si128(); 
        SSE_ROTATE1_NULL( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3 );
        sse_W[t+4] = _mm_setzero_si128();
        sse_W1[t+4] = _mm_setzero_si128();
        sse_W2[t+4] = _mm_setzero_si128();
        SSE_ROTATE1_NULL( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3 );
    }

    // do last few steps of round 1
    sse_W[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W1[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    sse_W2[15] = _mm_set_epi32((lens << 3),(lens << 3),(lens << 3),(lens << 3));
    SSE_ROTATE1( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[15], sse_W1[15], sse_W2[15], sse_W3[15] ); // set length
    SSE_EXPAND(16); SSE_ROTATE1( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[16], sse_W1[16],sse_W2[16], sse_W3[16] );
    SSE_EXPAND(17); SSE_ROTATE1( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[17], sse_W1[17], sse_W2[17], sse_W3[17] );
    SSE_EXPAND(18); SSE_ROTATE1( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[18], sse_W1[18], sse_W2[18], sse_W3[18] );
    SSE_EXPAND(19); SSE_ROTATE1( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[19], sse_W1[19], sse_W2[19], sse_W3[19] );



    // round 2
    sse_K = _mm_set1_epi32(K1);

    for(t = 20; t < 40; t+=5)
    {
	SSE_EXPAND(t);   SSE_ROTATE2_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
	SSE_EXPAND(t+1); SSE_ROTATE2_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE2_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE2_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE2_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }

    // round 3
    sse_K = _mm_set1_epi32(K2);

    for(t = 40; t < 60; t+=5)
    {
        SSE_EXPAND(t);   SSE_ROTATE3_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
        SSE_EXPAND(t+1); SSE_ROTATE3_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE3_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE3_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE3_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }

    // round 4 
    sse_K = _mm_set1_epi32(K3);

    for(t = 60; t < 80; t+=5 )
    {
        SSE_EXPAND(t);   SSE_ROTATE4_F( sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_W[t], sse_W1[t], sse_W2[t], sse_W3[t] );
        SSE_EXPAND(t+1); SSE_ROTATE4_F( sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_W[t+1], sse_W1[t+1], sse_W2[t+1], sse_W3[t+1] );
        SSE_EXPAND(t+2); SSE_ROTATE4_F( sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_W[t+2], sse_W1[t+2], sse_W2[t+2], sse_W3[t+2] );
        SSE_EXPAND(t+3); SSE_ROTATE4_F( sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_B, sse_B1, sse_B2, sse_B3, sse_W[t+3], sse_W1[t+3], sse_W2[t+3], sse_W3[t+3] );
        SSE_EXPAND(t+4); SSE_ROTATE4_F( sse_B, sse_B1, sse_B2, sse_B3, sse_C, sse_C1, sse_C2, sse_C3, sse_D, sse_D1, sse_D2, sse_D3, sse_E, sse_E1, sse_E2, sse_E3, sse_A, sse_A1, sse_A2, sse_A3, sse_W[t+4], sse_W1[t+4], sse_W2[t+4], sse_W3[t+4] );
    }


    sse_A = _mm_add_epi32(sse_A, HH0);
    sse_B = _mm_add_epi32(sse_B, HH1);
    sse_C = _mm_add_epi32(sse_C, HH2);
    sse_D = _mm_add_epi32(sse_D, HH3);
    sse_E = _mm_add_epi32(sse_E, HH4);
    sse_A1 = _mm_add_epi32(sse_A1, HH0);
    sse_B1 = _mm_add_epi32(sse_B1, HH1);
    sse_C1 = _mm_add_epi32(sse_C1, HH2);
    sse_D1 = _mm_add_epi32(sse_D1, HH3);
    sse_E1 = _mm_add_epi32(sse_E1, HH4);
    sse_A2 = _mm_add_epi32(sse_A2, HH0);
    sse_B2 = _mm_add_epi32(sse_B2, HH1);
    sse_C2 = _mm_add_epi32(sse_C2, HH2);
    sse_D2 = _mm_add_epi32(sse_D2, HH3);
    sse_E2 = _mm_add_epi32(sse_E2, HH4);


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

    SSE_Endian_Reverse32(sse_A);
    udigest4[0] = _mm_extract_epi32(sse_A, 0);
    udigest3[0] = _mm_extract_epi32(sse_A, 1);
    udigest2[0] = _mm_extract_epi32(sse_A, 2);
    udigest1[0] = _mm_extract_epi32(sse_A, 3);
    SSE_Endian_Reverse32(sse_B);
    udigest4[1] = _mm_extract_epi32(sse_B, 0);
    udigest3[1] = _mm_extract_epi32(sse_B, 1);
    udigest2[1] = _mm_extract_epi32(sse_B, 2);
    udigest1[1] = _mm_extract_epi32(sse_B, 3);
    SSE_Endian_Reverse32(sse_C);
    udigest4[2] = _mm_extract_epi32(sse_C, 0);
    udigest3[2] = _mm_extract_epi32(sse_C, 1);
    udigest2[2] = _mm_extract_epi32(sse_C, 2);
    udigest1[2] = _mm_extract_epi32(sse_C, 3);
    SSE_Endian_Reverse32(sse_D);
    udigest4[3] = _mm_extract_epi32(sse_D, 0);
    udigest3[3] = _mm_extract_epi32(sse_D, 1);
    udigest2[3] = _mm_extract_epi32(sse_D, 2);
    udigest1[3] = _mm_extract_epi32(sse_D, 3);
    SSE_Endian_Reverse32(sse_E);
    udigest4[4] = _mm_extract_epi32(sse_E, 0);
    udigest3[4] = _mm_extract_epi32(sse_E, 1);
    udigest2[4] = _mm_extract_epi32(sse_E, 2);
    udigest1[4] = _mm_extract_epi32(sse_E, 3);
    SSE_Endian_Reverse32(sse_A1);
    udigest8[0] = _mm_extract_epi32(sse_A1, 0);
    udigest7[0] = _mm_extract_epi32(sse_A1, 1);
    udigest6[0] = _mm_extract_epi32(sse_A1, 2);
    udigest5[0] = _mm_extract_epi32(sse_A1, 3);
    SSE_Endian_Reverse32(sse_B1);
    udigest8[1] = _mm_extract_epi32(sse_B1, 0);
    udigest7[1] = _mm_extract_epi32(sse_B1, 1);
    udigest6[1] = _mm_extract_epi32(sse_B1, 2);
    udigest5[1] = _mm_extract_epi32(sse_B1, 3);
    SSE_Endian_Reverse32(sse_C1);
    udigest8[2] = _mm_extract_epi32(sse_C1, 0);
    udigest7[2] = _mm_extract_epi32(sse_C1, 1);
    udigest6[2] = _mm_extract_epi32(sse_C1, 2);
    udigest5[2] = _mm_extract_epi32(sse_C1, 3);
    SSE_Endian_Reverse32(sse_D1);
    udigest8[3] = _mm_extract_epi32(sse_D1, 0);
    udigest7[3] = _mm_extract_epi32(sse_D1, 1);
    udigest6[3] = _mm_extract_epi32(sse_D1, 2);
    udigest5[3] = _mm_extract_epi32(sse_D1, 3);
    SSE_Endian_Reverse32(sse_E1);
    udigest8[4] = _mm_extract_epi32(sse_E1, 0);
    udigest7[4] = _mm_extract_epi32(sse_E1, 1);
    udigest6[4] = _mm_extract_epi32(sse_E1, 2);
    udigest5[4] = _mm_extract_epi32(sse_E1, 3);
    SSE_Endian_Reverse32(sse_A2);
    udigest12[0] = _mm_extract_epi32(sse_A2, 0);
    udigest11[0] = _mm_extract_epi32(sse_A2, 1);
    udigest10[0] = _mm_extract_epi32(sse_A2, 2);
    udigest9[0] = _mm_extract_epi32(sse_A2, 3);
    SSE_Endian_Reverse32(sse_B2);
    udigest12[1] = _mm_extract_epi32(sse_B2, 0);
    udigest11[1] = _mm_extract_epi32(sse_B2, 1);
    udigest10[1] = _mm_extract_epi32(sse_B2, 2);
    udigest9[1] = _mm_extract_epi32(sse_B2, 3);
    SSE_Endian_Reverse32(sse_C2);
    udigest12[2] = _mm_extract_epi32(sse_C2, 0);
    udigest11[2] = _mm_extract_epi32(sse_C2, 1);
    udigest10[2] = _mm_extract_epi32(sse_C2, 2);
    udigest9[2] = _mm_extract_epi32(sse_C2, 3);
    SSE_Endian_Reverse32(sse_D2);
    udigest12[3] = _mm_extract_epi32(sse_D2, 0);
    udigest11[3] = _mm_extract_epi32(sse_D2, 1);
    udigest10[3] = _mm_extract_epi32(sse_D2, 2);
    udigest9[3] = _mm_extract_epi32(sse_D2, 3);
    SSE_Endian_Reverse32(sse_E2);
    udigest12[4] = _mm_extract_epi32(sse_E2, 0);
    udigest11[4] = _mm_extract_epi32(sse_E2, 1);
    udigest10[4] = _mm_extract_epi32(sse_E2, 2);
    udigest9[4] = _mm_extract_epi32(sse_E2, 3);

    plains[0][lens]=0x00;
    plains[1][lens]=0x00;
    plains[2][lens]=0x00;
    plains[3][lens]=0x00;
    plains[4][lens]=0x00;
    plains[5][lens]=0x00;
    plains[6][lens]=0x00;
    plains[7][lens]=0x00;
    plains[8][lens]=0x00;
    plains[9][lens]=0x00;
    plains[10][lens]=0x00;
    plains[11][lens]=0x00;
    return hash_ok;
}

#endif

