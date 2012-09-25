#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#define getglobalid(a) (mad24(get_group_id(0), 64, get_local_id(0)))
#else
#define getglobalid(a) (get_global_id(0))
#endif

#define S1 1
#define S2 5
#define S3 30  
#define Sl 8
#define Sr 24  



void sha1_markov1( __global uint4 *dst, uint4 input, uint size,  uint4 chbase1, __global uint *found_ind, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint16 xors, uint factor, uint4 w0, uint4 A, uint4 B, uint4 C, uint4 D, uint4 E) 
{  

uint4 w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;

uint ib,ic,id;  
uint4 K,l,tmp1,tmp2,tmp3,tmp4,tmp5,temp, SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 m=0x00FF00FF;
uint4 m2=0xFF00FF00;
uint4 table1;

uint4 K0 = (uint4)0x5A827999;
uint4 K1 = (uint4)0x6ED9EBA1;
uint4 K2 = (uint4)0x8F1BBCDC;
uint4 K3 = (uint4)0xCA62C1D6;

uint4 H0 = (uint4)0x67452301;
uint4 H1 = (uint4)0xEFCDAB89;
uint4 H2 = (uint4)0x98BADCFE;
uint4 H3 = (uint4)0x10325476;
uint4 H4 = (uint4)0xC3D2E1F0;



SIZE = (uint4)(size+3)<<3;
size1=SIZE;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
//w3 = (uint4)input.w;
w3=(uint4)0;

//w0=(uint4)chbase1|(uint4)i;


w4=(uint4)0;
w5=(uint4)0;
w6=(uint4)0;
w7=(uint4)0;
w8=(uint4)0;
w9=(uint4)0;
w10=(uint4)0;  
w11=(uint4)0;  
w12=(uint4)0;  
w13=(uint4)0;  
w14=(uint4)0;  
w16=(uint4)0;  


#ifndef OLD_ATI
#define F_00_19(b,c,d) (amd_bytealign(b,c,d))
#define F_20_39(b,c,d)  ((b) ^ (c) ^ (d))  
#define F_40_59(b,c,d) (amd_bytealign((d^c), b, c))
#define F_60_79(b,c,d)  F_20_39(b,c,d) 
#else
#define F_00_19(b,c,d)  ((((c) ^ (d)) & (b)) ^ (d))
#define F_20_39(b,c,d)  ((c) ^ (b) ^ (d))  
#define F_40_59(b,c,d)  (((b) & (c)) | (((b)|(c)) & (d)))  
#define F_60_79(b,c,d)  F_20_39(b,c,d) 

#endif

m+=w4;
m2+=w4;

#ifdef OLD_ATI
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 
#else
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=amd_bytealign(m,tmp1,tmp2); } 
#endif

#define ROTATE1A(a, b, c, d, e, x) e = K + e + rotate(a,S2) + x + ((((c) ^ (d)) & (b)) ^ (d)); b = rotate(b,S3) 
#define ROTATE1(a, b, c, d, e, x) e = K + e + rotate(a,S2) + x + F_00_19(b,c,d); b = rotate(b,S3) 
#define ROTATE1_NULL(a, b, c, d, e)  e = K + e + rotate(a,S2) + F_00_19(b,c,d); b = rotate(b,S3)
#define ROTATE2_F(a, b, c, d, e, x) e = rotate(a,S2) + e + ((c) ^ (b) ^ (d)) + K + x; b = rotate(b,S3) 
#define ROTATE3_F(a, b, c, d, e, x) e += x + rotate(a,S2) + K + F_40_59(b,c,d); b = rotate(b,S3)
#define ROTATE4_F(a, b, c, d, e, x) e += ((c) ^ (b) ^ (d)) + K + x + rotate(a,S2); b = rotate(b,S3)

K = K0;

ROTATE1_NULL(C, D, E, A, B);
ROTATE1_NULL(B, C, D, E, A);
ROTATE1_NULL(A, B, C, D, E);
ROTATE1_NULL(E, A, B, C, D);
ROTATE1_NULL(D, E, A, B, C);
ROTATE1_NULL(C, D, E, A, B);
ROTATE1_NULL(B, C, D, E, A);
ROTATE1_NULL(A, B, C, D, E);
ROTATE1_NULL(E, A, B, C, D);
ROTATE1_NULL(D, E, A, B, C);
ROTATE1_NULL(C, D, E, A, B);
ROTATE1_NULL(B, C, D, E, A);
ROTATE1(A, B, C, D, E, SIZE);  
#ifndef MAX8
w16 = rotate((w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16);
#else
w16 = rotate((w0),S1);ROTATE1(E,A,B,C,D,w16);
#endif
temp = w16;
w0 = (uint4)xors.s0; ROTATE1(D,E,A,B,C,w0); 
w1 = xors.s1; ROTATE1(C,D,E,A,B,w1); 
//w2 = rotate((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 
w2 = rotate((w16),S1);  ROTATE1(B,C,D,E,A,w2); 

K = K1;

w3 = (uint4)xors.s2; ROTATE2_F(A, B, C, D, E, w3);
w4 = (uint4)xors.s3; ROTATE2_F(E, A, B, C, D, w4);
w5 = rotate((w2),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = (uint4)xors.s4;ROTATE2_F(C, D, E, A, B, w6);
w7 = rotate((w4 ^ w16),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = rotate((w5 ^ w0),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = (uint4)xors.s5; ROTATE2_F(E, A, B, C, D, w9);
w10 = rotate((w7 ^ w2),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = rotate((w8 ^ w3),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = (uint4)xors.s6; ROTATE2_F(B, C, D, E, A, w12);
w13 = rotate((w10 ^ w5 ^w16),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = rotate((w11 ^ (uint4)xors.s7),S1); ROTATE2_F(E, A, B, C, D, w14);  
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = rotate(w14 ^ (uint4)xors.s8,S1); ROTATE2_F(B, C, D, E, A, w0);  
tmp5=w0;
//w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w1 = rotate(w12 ^ w2,2); ROTATE2_F(A, B, C, D, E, w1);
tmp4 = w1;
w2 = rotate(w13 ^ w3, 2); ROTATE2_F(E, A, B, C, D, w2); 
tmp1=w2;
w3 = rotate(w0 ^ (uint4)xors.s9,S1); ROTATE2_F(D, E, A, B, C, w3);  
tmp2=w3;
w4 = rotate(SIZE ^ w5, 2);ROTATE2_F(C, D, E, A, B, w4);
tmp3=w4;
w5 = rotate(w16 ^ w6,2); ROTATE2_F(B, C, D, E, A, w5);  
l=w5;


K = K2;

w6 = rotate(w0 ^ w7, 2); ROTATE3_F(A, B, C, D, E, w6);
w7 = rotate(w1 ^ w8, 2); ROTATE3_F(E, A, B, C, D, w7);
w8 = rotate(w2 ^ w9, 2); ROTATE3_F(D, E, A, B, C, w8); 
w9 = rotate(w3 ^ w10 ^ size1, 2); ROTATE3_F(C, D, E, A, B, w9);
w10 = rotate(w4 ^ w11 ^ temp, 2); ROTATE3_F(B, C, D, E, A, w10);  
w11 = rotate(w5 ^ w12 ^ (uint4)xors.s0, 2); ROTATE3_F(A, B, C, D, E, w11);  
w12 = rotate(w6 ^ w13 ^ (uint4)xors.s1, 2); ROTATE3_F(E, A, B, C, D, w12); 
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13); 
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14); 
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE);
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16);
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0); 
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2);
w3 = rotate(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3); 
w4 = rotate(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4); 
w5 = rotate(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5); 
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6);
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7);
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8); 

K = K3;
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10);  
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);  
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12); 
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13); 
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14); 
#ifndef MAX8
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE);
#else
SIZE = rotate(w3 ^ tmp5, 4); ROTATE4_F(E, A, B, C, D, SIZE);
#endif
//w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w16 = rotate(w4 ^ tmp4, 4); ROTATE4_F(D, E, A, B, C, w16);

w0 = rotate(w5 ^ tmp1, 4); ROTATE4_F(C, D, E, A, B, w0); 
w1 = rotate(w6 ^ tmp2, 4); ROTATE4_F(B, C, D, E, A, w1);
w2 = rotate(w7 ^ tmp3,4); ROTATE4_F(A, B, C, D, E, w2); 
w3 = rotate(w8 ^ l ^ size1, 4); ROTATE4_F(E, A, B, C, D, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
#ifdef SINGLE_MODE
if (all((uint4)singlehash.y != E)) return;
id=1;
#endif
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);    //D=...., A=rot(A,30)
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);   //C=...., E=rot(E,30)
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); //B=...., D=rot(D,30)
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); //A=...., C=rot(C,30)


#ifdef SINGLE_MODE
tmp1 = (uint4)(singlehash.z)^C;
tmp2 = (uint4)(singlehash.w)^D;
if ((tmp2.w*tmp2.y*tmp2.z*tmp2.x*tmp1.w*tmp1.y*tmp1.z*tmp1.x)) return;
#endif


A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;


Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);


#ifndef SINGLE_MODE
id=0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[getglobalid(0)] = 1;
}

#ifndef DOUBLE
dst[(getglobalid(0)*5)] = (uint4)(A.s0,B.s0,C.s0,D.s0);  
dst[(getglobalid(0)*5)+1] = (uint4)(E.s0,A.s1,B.s1,C.s1);
dst[(getglobalid(0)*5)+2] = (uint4)(D.s1,E.s1,A.s2,B.s2);
dst[(getglobalid(0)*5)+3] = (uint4)(C.s2,D.s2,E.s2,A.s3);
dst[(getglobalid(0)*5)+4] = (uint4)(B.s3,C.s3,D.s3,E.s3);
#else
dst[(getglobalid(0)*10)+factor] = (uint4)(A.s0,B.s0,C.s0,D.s0);  
dst[(getglobalid(0)*10)+1+factor] = (uint4)(E.s0,A.s1,B.s1,C.s1);
dst[(getglobalid(0)*10)+2+factor] = (uint4)(D.s1,E.s1,A.s2,B.s2);
dst[(getglobalid(0)*10)+3+factor] = (uint4)(C.s2,D.s2,E.s2,A.s3);
dst[(getglobalid(0)*10)+4+factor] = (uint4)(B.s3,C.s3,D.s3,E.s3);
#endif

}


__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_markov( __global uint4 *dst, uint4 input, uint size,  uint8 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table,  uint4 singlehash, uint16 xors) 
{
uint i;
uint4 chbase1,w0,A,B,C,D,E;

i = table[getglobalid(0)];
chbase1 = (uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);
w0=(uint4)chbase1|(uint4)i;

//Step 1
E = (uint4)xors.sB + w0;
//B = rotate(B,S3); 
B=(uint4)0x7bf36ae2;
//Step 2
D = (uint4)xors.sC + rotate(E,S2);
//A = rotate(A,S3);
A=(uint4)0x59d148c0;
//Step 3
C =  (uint4)xors.sD + rotate(D,S2)+ F_00_19(E,A,B);
E = rotate(E,S3);


sha1_markov1(dst, input, size, chbase1, found_ind, bitmaps, found, i, singlehash, xors,0, w0, A,B,C,D,E);
#ifdef DOUBLE
chbase1 = (uint4)(chbase.s4,chbase.s5,chbase.s6,chbase.s7);
w0=(uint4)chbase1|(uint4)i;
//Step 1
E = (uint4)xors.sB + w0;
//B = rotate(B,S3); 
B=(uint4)0x7bf36ae2;
//Step 2
D = (uint4)xors.sC + rotate(E,S2);
//A = rotate(A,S3);
A=(uint4)0x59d148c0;
//Step 3
C =  (uint4)xors.sD + rotate(D,S2)+ F_00_19(E,A,B);
E = rotate(E,S3);

sha1_markov1(dst, input, size, chbase1, found_ind, bitmaps, found, i, singlehash, xors, 5, w0,A,B,C,D,E);
#endif
}
