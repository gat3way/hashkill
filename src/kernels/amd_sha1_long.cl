#ifdef GCN

#define F_00_19(bb,cc,dd) (bitselect((dd),(cc),(bb)))
#define F_20_39(bb,cc,dd)  ((bb) ^ (cc) ^ (dd))  
#define F_40_59(bb,cc,dd) (bitselect((cc), (bb), ((dd)^(cc))))
#define F_60_79(bb,cc,dd)  F_20_39((bb),(cc),(dd)) 


#define MAX8
void sha1_long1( __global uint *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint16 xors) 
{  
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint x0,x1,x2,x3;
uint ib,ic,id;  
uint A,B,C,D,E,K,l,tmp1,tmp2,tmp3,tmp4,tmp5,temp, SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint m=0x00FF00FF;
uint m2=0xFF00FF00;
uint table1;

uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;

uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;

#define S1 1U
#define S2 5U
#define S3 30U
#define Sl 8U
#define Sr 24U


SIZE = (uint)(size);
size1=SIZE;

w1 = (uint)input.y;
w2 = (uint)input.z;
#ifndef MAX8
w3 = (uint)input.w;
#else
w3=(uint)0;
#endif
w0=(uint)i;
x0=w0;x1=w1;x2=w2;x3=w3;


w4=(uint)0;
w5=(uint)0;
w6=(uint)0;
w7=(uint)0;
w8=(uint)0;
w9=(uint)0;
w10=(uint)0;
w11=(uint)0;
w12=(uint)0;
w13=(uint)0;
w14=(uint)0;
w16=(uint)0;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)


K = K0;

//Step 1
E = (uint)xors.sB + w0;
//B = rotate(B,S3); 
B=(uint)0x7bf36ae2;

//Step 2
D = (uint)xors.sC + rotate(E,S2);
//A = rotate(A,S3);
A=(uint)0x59d148c0;

//Step 3
C =  (uint)xors.sD + rotate(D,S2)+ F_00_19(E,A,B);
E = rotate(E,S3);

#ifndef MAX8
ROTATE1(C, D, E, A, B, w3);
#else
ROTATE1_NULL(C, D, E, A, B);
#endif
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
w0 = (uint)xors.s0; ROTATE1(D,E,A,B,C,w0); 
w1 = xors.s1; ROTATE1(C,D,E,A,B,w1); 
#ifndef MAX8
w2 = rotate((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 
#else
w2 = rotate((w16),S1);  ROTATE1(B,C,D,E,A,w2); 
#endif

K = K1;

w3 = (uint)xors.s2; ROTATE2_F(A, B, C, D, E, w3);
w4 = (uint)xors.s3; ROTATE2_F(E, A, B, C, D, w4);
w5 = rotate((w2),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = (uint)xors.s4;ROTATE2_F(C, D, E, A, B, w6);
w7 = rotate((w4 ^ w16),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = rotate((w5 ^ w0),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = (uint)xors.s5; ROTATE2_F(E, A, B, C, D, w9);
w10 = rotate((w7 ^ w2),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = rotate((w8 ^ w3),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = (uint)xors.s6; ROTATE2_F(B, C, D, E, A, w12);
w13 = rotate((w10 ^ w5 ^w16),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = rotate((w11 ^ (uint)xors.s7),S1); ROTATE2_F(E, A, B, C, D, w14);  
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = rotate(w14 ^ (uint)xors.s8,S1); ROTATE2_F(B, C, D, E, A, w0);  
tmp5=w0;
//w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w1 = rotate(w12 ^ w2,2U); ROTATE2_F(A, B, C, D, E, w1);
tmp4 = w1;
w2 = rotate(w13 ^ w3, 2U); ROTATE2_F(E, A, B, C, D, w2); 
tmp1=w2;
w3 = rotate(w0 ^ (uint)xors.s9,S1); ROTATE2_F(D, E, A, B, C, w3);  
tmp2=w3;
w4 = rotate(SIZE ^ w5, 2U);ROTATE2_F(C, D, E, A, B, w4);
tmp3=w4;
w5 = rotate(w16 ^ w6,2U); ROTATE2_F(B, C, D, E, A, w5);  
l=w5;


K = K2;

w6 = rotate(w0 ^ w7, 2U); ROTATE3_F(A, B, C, D, E, w6);
w7 = rotate(w1 ^ w8, 2U); ROTATE3_F(E, A, B, C, D, w7);
w8 = rotate(w2 ^ w9, 2U); ROTATE3_F(D, E, A, B, C, w8); 
w9 = rotate(w3 ^ w10 ^ size1, 2U); ROTATE3_F(C, D, E, A, B, w9);
w10 = rotate(w4 ^ w11 ^ temp, 2U); ROTATE3_F(B, C, D, E, A, w10);  
w11 = rotate(w5 ^ w12 ^ (uint)xors.s0, 2U); ROTATE3_F(A, B, C, D, E, w11);  
w12 = rotate(w6 ^ w13 ^ (uint)xors.s1, 2U); ROTATE3_F(E, A, B, C, D, w12); 
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
SIZE = rotate(w3 ^ tmp5, 4U); ROTATE4_F(E, A, B, C, D, SIZE);
#endif
//w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w16 = rotate(w4 ^ tmp4, 4U); ROTATE4_F(D, E, A, B, C, w16);

w0 = rotate(w5 ^ tmp1, 4U); ROTATE4_F(C, D, E, A, B, w0); 
w1 = rotate(w6 ^ tmp2, 4U); ROTATE4_F(B, C, D, E, A, w1);
w2 = rotate(w7 ^ tmp3,4U); ROTATE4_F(A, B, C, D, E, w2); 
w3 = rotate(w8 ^ l ^ size1, 4U); ROTATE4_F(E, A, B, C, D, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
#ifdef SINGLE_MODE
if (((uint)singlehash.y != E)) return;
id=1;
#endif
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);    //D=...., A=rot(A,30)
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);   //C=...., E=rot(E,30)
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); //B=...., D=rot(D,30)
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); //A=...., C=rot(C,30)


#ifdef SINGLE_MODE
if (C!=singlehash.z) return;
if (D!=singlehash.w) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=A;b2=B;b3=C;b4=D;
b5=(singlehash.x >> (B&31))&1;
b6=(singlehash.y >> (C&31))&1;
b7=(singlehash.z >> (D&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;


Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);


uint res = atomic_inc(found);
hashes[res*5] = (uint)(A);
hashes[res*5+1] = (uint)(B);
hashes[res*5+2] = (uint)(C);
hashes[res*5+3] = (uint)(D);
hashes[res*5+4] = (uint)(E);
Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

plains[res] = (uint4)(x0,x1,x2,x3);
}


#undef MAX8

void sha1_long2( __global uint *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint16 xors) 
{  
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint x0,x1,x2,x3;
uint ib,ic,id;  
uint A,B,C,D,E,K,l,tmp1,tmp2,tmp3,tmp4,tmp5,temp, SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint m=0x00FF00FF;
uint m2=0xFF00FF00;
uint table1;

uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;

uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;

#define S1 1U
#define S2 5U
#define S3 30U
#define Sl 8U
#define Sr 24U


SIZE = (uint)(size);
size1=SIZE;

w1 = (uint)input.y;
w2 = (uint)input.z;
#ifndef MAX8
w3 = (uint)input.w;
#else
w3=(uint)0;
#endif
w0=(uint)i;
x0=w0;x1=w1;x2=w2;x3=w3;


w4=(uint)0;
w5=(uint)0;
w6=(uint)0;
w7=(uint)0;
w8=(uint)0;
w9=(uint)0;
w10=(uint)0;
w11=(uint)0;
w12=(uint)0;
w13=(uint)0;
w14=(uint)0;
w16=(uint)0;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)


K = K0;

//Step 1
E = (uint)xors.sB + w0;
//B = rotate(B,S3); 
B=(uint)0x7bf36ae2;

//Step 2
D = (uint)xors.sC + rotate(E,S2);
//A = rotate(A,S3);
A=(uint)0x59d148c0;

//Step 3
C =  (uint)xors.sD + rotate(D,S2)+ F_00_19(E,A,B);
E = rotate(E,S3);

#ifndef MAX8
ROTATE1(C, D, E, A, B, w3);
#else
ROTATE1_NULL(C, D, E, A, B);
#endif
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
w0 = (uint)xors.s0; ROTATE1(D,E,A,B,C,w0); 
w1 = xors.s1; ROTATE1(C,D,E,A,B,w1); 
#ifndef MAX8
w2 = rotate((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 
#else
w2 = rotate((w16),S1);  ROTATE1(B,C,D,E,A,w2); 
#endif

K = K1;

w3 = (uint)xors.s2; ROTATE2_F(A, B, C, D, E, w3);
w4 = (uint)xors.s3; ROTATE2_F(E, A, B, C, D, w4);
w5 = rotate((w2),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = (uint)xors.s4;ROTATE2_F(C, D, E, A, B, w6);
w7 = rotate((w4 ^ w16),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = rotate((w5 ^ w0),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = (uint)xors.s5; ROTATE2_F(E, A, B, C, D, w9);
w10 = rotate((w7 ^ w2),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = rotate((w8 ^ w3),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = (uint)xors.s6; ROTATE2_F(B, C, D, E, A, w12);
w13 = rotate((w10 ^ w5 ^w16),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = rotate((w11 ^ (uint)xors.s7),S1); ROTATE2_F(E, A, B, C, D, w14);  
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = rotate(w14 ^ (uint)xors.s8,S1); ROTATE2_F(B, C, D, E, A, w0);  
tmp5=w0;
//w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w1 = rotate(w12 ^ w2,2U); ROTATE2_F(A, B, C, D, E, w1);
tmp4 = w1;
w2 = rotate(w13 ^ w3, 2U); ROTATE2_F(E, A, B, C, D, w2); 
tmp1=w2;
w3 = rotate(w0 ^ (uint)xors.s9,S1); ROTATE2_F(D, E, A, B, C, w3);  
tmp2=w3;
w4 = rotate(SIZE ^ w5, 2U);ROTATE2_F(C, D, E, A, B, w4);
tmp3=w4;
w5 = rotate(w16 ^ w6,2U); ROTATE2_F(B, C, D, E, A, w5);  
l=w5;


K = K2;

w6 = rotate(w0 ^ w7, 2U); ROTATE3_F(A, B, C, D, E, w6);
w7 = rotate(w1 ^ w8, 2U); ROTATE3_F(E, A, B, C, D, w7);
w8 = rotate(w2 ^ w9, 2U); ROTATE3_F(D, E, A, B, C, w8); 
w9 = rotate(w3 ^ w10 ^ size1, 2U); ROTATE3_F(C, D, E, A, B, w9);
w10 = rotate(w4 ^ w11 ^ temp, 2U); ROTATE3_F(B, C, D, E, A, w10);  
w11 = rotate(w5 ^ w12 ^ (uint)xors.s0, 2U); ROTATE3_F(A, B, C, D, E, w11);  
w12 = rotate(w6 ^ w13 ^ (uint)xors.s1, 2U); ROTATE3_F(E, A, B, C, D, w12); 
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
SIZE = rotate(w3 ^ tmp5, 4U); ROTATE4_F(E, A, B, C, D, SIZE);
#endif
//w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w16 = rotate(w4 ^ tmp4, 4U); ROTATE4_F(D, E, A, B, C, w16);

w0 = rotate(w5 ^ tmp1, 4U); ROTATE4_F(C, D, E, A, B, w0); 
w1 = rotate(w6 ^ tmp2, 4U); ROTATE4_F(B, C, D, E, A, w1);
w2 = rotate(w7 ^ tmp3,4U); ROTATE4_F(A, B, C, D, E, w2); 
w3 = rotate(w8 ^ l ^ size1, 4U); ROTATE4_F(E, A, B, C, D, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
#ifdef SINGLE_MODE
if (((uint)singlehash.y != E)) return;
id=1;
#endif
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);    //D=...., A=rot(A,30)
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);   //C=...., E=rot(E,30)
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); //B=...., D=rot(D,30)
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); //A=...., C=rot(C,30)


#ifdef SINGLE_MODE
if (C!=singlehash.z) return;
if (D!=singlehash.w) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=A;b2=B;b3=C;b4=D;
b5=(singlehash.x >> (B&31))&1;
b6=(singlehash.y >> (C&31))&1;
b7=(singlehash.z >> (D&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;


Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);


uint res = atomic_inc(found);
hashes[res*5] = (uint)(A);
hashes[res*5+1] = (uint)(B);
hashes[res*5+2] = (uint)(C);
hashes[res*5+3] = (uint)(D);
hashes[res*5+4] = (uint)(E);
Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

plains[res] = (uint4)(x0,x1,x2,x3);
}





__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_double( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
//singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
xors=xors3;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
//singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
xors=xors4;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}


__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_normal( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);


}



__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_double8( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
//singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
xors=xors3;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
//singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
xors=xors4;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}


__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_normal8( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);
input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}

#endif


#if (!GCN)

#ifdef OLD_ATI
#define F_00_19(bb,cc,dd)  ((((cc) ^ (dd)) & (bb)) ^ (dd))
#define F_20_39(bb,cc,dd)  ((cc) ^ (bb) ^ (dd))  
#define F_40_59(bb,cc,dd)  (((bb) & (cc)) | (((bb)|(cc)) & (dd)))  
#define F_60_79(bb,cc,dd)  F_20_39(bb,cc,dd) 
#else
#define F_00_19(bb,cc,dd) (bitselect((dd),(cc),(bb)))
#define F_20_39(bb,cc,dd)  ((bb) ^ (cc) ^ (dd))  
#define F_40_59(bb,cc,dd) (bitselect((cc), (bb), ((dd)^(cc))))
#define F_60_79(bb,cc,dd)  F_20_39((bb),(cc),(dd)) 
#endif



#define MAX8
void sha1_long1( __global uint4 *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint4 i,  uint4 singlehash, uint16 xors) 
{  
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint4 x0,x1,x2,x3;
uint ib,ic,id;  
uint4 A,B,C,D,E,K,l,tmp1,tmp2,tmp3,tmp4,tmp5,temp, SIZE,size1;
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

#define S1 1
#define S2 5
#define S3 30  
#define Sl 8
#define Sr 24  


SIZE = (uint4)(size);
size1=SIZE;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
#ifndef MAX8
w3 = (uint4)input.w;
#else
w3=(uint4)0;
#endif
w0=(uint4)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)


K = K0;

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

#ifndef MAX8
ROTATE1(C, D, E, A, B, w3);
#else
ROTATE1_NULL(C, D, E, A, B);
#endif
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
#ifndef MAX8
w2 = rotate((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 
#else
w2 = rotate((w16),S1);  ROTATE1(B,C,D,E,A,w2); 
#endif

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
if (all(C!=(uint4)singlehash.z)) return;
if (all(D!=(uint4)singlehash.w)) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;


Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);


#ifndef OLD_ATI
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif

hashes[res*5] = (uint4)(A.s0,B.s0,C.s0,D.s0);
hashes[res*5+1] = (uint4)(E.s0,A.s1,B.s1,C.s1);
hashes[res*5+2] = (uint4)(D.s1,E.s1,A.s2,B.s2);
hashes[res*5+3] = (uint4)(C.s2,D.s2,E.s2,A.s3);
hashes[res*5+4] = (uint4)(B.s3,C.s3,D.s3,E.s3);
Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}


#undef MAX8

void sha1_long2( __global uint4 *hashes, uint4 input, uint size , __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint4 i,  uint4 singlehash, uint16 xors) 
{  
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint4 x0,x1,x2,x3;
uint ib,ic,id;  
uint4 A,B,C,D,E,K,l,tmp1,tmp2,tmp3,tmp4,tmp5,temp, SIZE,size1;
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

#define S1 1
#define S2 5
#define S3 30  
#define Sl 8
#define Sr 24  


SIZE = (uint4)(size);
size1=SIZE;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
#ifndef MAX8
w3 = (uint4)input.w;
#else
w3=(uint4)0;
#endif
w0=(uint4)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)


K = K0;

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

#ifndef MAX8
ROTATE1(C, D, E, A, B, w3);
#else
ROTATE1_NULL(C, D, E, A, B);
#endif
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
#ifndef MAX8
w2 = rotate((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 
#else
w2 = rotate((w16),S1);  ROTATE1(B,C,D,E,A,w2); 
#endif

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
if (all(C!=(uint4)singlehash.z)) return;
if (all(D!=(uint4)singlehash.w)) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);



#ifndef OLD_ATI
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res*5] = (uint4)(A.s0,B.s0,C.s0,D.s0);
hashes[res*5+1] = (uint4)(E.s0,A.s1,B.s1,C.s1);
hashes[res*5+2] = (uint4)(D.s1,E.s1,A.s2,B.s2);
hashes[res*5+3] = (uint4)(C.s2,D.s2,E.s2,A.s3);
hashes[res*5+4] = (uint4)(B.s3,C.s3,D.s3,E.s3);
Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}





__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}


__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}



__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_double8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}


__kernel 
void  __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_long_normal8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);
input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
sha1_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}

#endif