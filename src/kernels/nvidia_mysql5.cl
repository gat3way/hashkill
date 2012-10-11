#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
size[GGI] = (SIZE+str.sF)<<3;

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}

#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))


__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mysql5( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{

uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;

uint i,ib,ic,id;  
uint A,B,C,D,E,K,l,tmp1,tmp2,temp, SIZE;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
#define m 0x00FF00FF
#define m2 0xFF00FF00

uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;

uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;

#define S1 1
#define S2 5
#define S3 30  
#define Sl 8
#define Sr 24  


id=get_global_id(0);
SIZE=size[id]; 


w0=input[id*8];
w1=input[id*8+1];
w2=input[id*8+2];
w3=input[id*8+3];
w4=input[id*8+4];
w5=input[id*8+5];
w6=input[id*8+6];
w7=input[id*8+7];
w8=w9=w10=w11=w12=w13=w14=w16=(uint)0;


A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#define F_00_19(b,c,d)  ((((c) ^ (d)) & (b)) ^ (d))
#define F_20_39(b,c,d)  ((c) ^ (b) ^ (d))  
#define F_40_59(b,c,d)  (((b) & (c)) | (((b)|(c)) & (d)))  
#define F_60_79(b,c,d)  F_20_39ODD(b,c,d) 


#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

#define ROTATE1A(a, b, c, d, e, x) e = K + e + ROTATE(a,S2) + x + ((((c) ^ (d)) & (b)) ^ (d)); b = ROTATE(b,S3) 
#define ROTATE1(a, b, c, d, e, x) e = K + e + ROTATE(a,S2) + x + F_00_19(b,c,d); b = ROTATE(b,S3) 
#define ROTATE1_NULL(a, b, c, d, e)  e = K + e + ROTATE(a,S2) + F_00_19(b,c,d); b = ROTATE(b,S3)
#define ROTATE2_F(a, b, c, d, e, x) e = ROTATE(a,S2) + e + ((c) ^ (b) ^ (d)) + K + x; b = ROTATE(b,S3) 
#define ROTATE3_F(a, b, c, d, e, x) e += x + ROTATE(a,S2) + K + F_40_59(b,c,d); b = ROTATE(b,S3)
#define ROTATE4_F(a, b, c, d, e, x) e += ((c) ^ (b) ^ (d)) + K + x + ROTATE(a,S2); b = ROTATE(b,S3)


K = K0;
Endian_Reverse32(w0);  
ROTATE1(A, B, C, D, E, w0);
Endian_Reverse32(w1);  
ROTATE1(E, A, B, C, D, w1);
Endian_Reverse32(w2);  
ROTATE1(D, E, A, B, C, w2);
Endian_Reverse32(w3);  
ROTATE1(C, D, E, A, B, w3);
Endian_Reverse32(w4);  
ROTATE1(B, C, D, E, A, w4);
Endian_Reverse32(w5);  
ROTATE1(A, B, C, D, E, w5);
Endian_Reverse32(w6);  
ROTATE1(E, A, B, C, D, w6);
Endian_Reverse32(w7);  
ROTATE1(D, E, A, B, C, w7);
ROTATE1_NULL(C, D, E, A, B);
ROTATE1_NULL(B, C, D, E, A);
ROTATE1_NULL(A, B, C, D, E);
ROTATE1_NULL(E, A, B, C, D);
ROTATE1_NULL(D, E, A, B, C);
ROTATE1_NULL(C, D, E, A, B);
ROTATE1_NULL(B, C, D, E, A);

ROTATE1(A, B, C, D, E, SIZE);  

w16 = ROTATE((w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16);
w0 = ROTATE((w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0); 
w1 = ROTATE((SIZE ^ w2),S1); ROTATE1(C,D,E,A,B,w1); 
w2 = ROTATE((w16 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 

K = K1;

w3 = ROTATE((w0),S1); ROTATE2_F(A, B, C, D, E, w3);
w4 = ROTATE((w1),S1); ROTATE2_F(E, A, B, C, D, w4);
w5 = ROTATE((w2),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = ROTATE((w3 ^ SIZE),S1);ROTATE2_F(C, D, E, A, B, w6);
w7 = ROTATE((w4 ^ w16),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = ROTATE((w5 ^ w0),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = ROTATE((w6 ^ w1),S1); ROTATE2_F(E, A, B, C, D, w9);
w10 = ROTATE((w7 ^ w2),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = ROTATE((w8 ^ w3),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = ROTATE((w9 ^ w4 ^ SIZE),S1); ROTATE2_F(B, C, D, E, A, w12);
w13 = ROTATE((w10 ^ w5 ^w16),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = ROTATE((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14);  
SIZE = ROTATE((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = ROTATE((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);  
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2); 
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);  
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4);
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);  

K = K2;

w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6);
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7);
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8); 
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9);
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);  
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);  
w12 = ROTATE(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12); 
w13 = ROTATE(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13); 
w14 = ROTATE(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14); 
SIZE = ROTATE(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE);
w16 = ROTATE(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16);
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0); 
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2);
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3); 
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4); 
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5); 
w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6);
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7);
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8); 

K = K3;
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9);
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10);  
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);  
w12 = ROTATE(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12); 
w13 = ROTATE(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13); 
w14 = ROTATE(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14); 
SIZE = ROTATE(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE);
w16 = ROTATE(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0); 
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2); 
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);  
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);  
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9); 
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;


w0=(uint)A;
w1=(uint)B;
w2=(uint)C;
w3=(uint)D;
w4=(uint)E;
w5=(uint)(0x80<<24);
w6=w7=w8=w9=w10=w11=w12=w13=w14=w16=(uint)0;
SIZE=(uint)160;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);

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

w16 = ROTATE((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16);
w0 = ROTATE((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0); 
w1 = ROTATE((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1); 
w2 = ROTATE((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 

K = K1;

w3 = ROTATE((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3);
w4 = ROTATE((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4);
w5 = ROTATE((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = ROTATE((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6);
w7 = ROTATE((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = ROTATE((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = ROTATE((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9);
w10 = ROTATE((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = ROTATE((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = ROTATE((w9 ^ w4 ^ SIZE ^w13),S1); ROTATE2_F(B, C, D, E, A, w12);
w13 = ROTATE((w10 ^ w5 ^w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = ROTATE((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14);  
SIZE = ROTATE((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = ROTATE((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);  
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2); 
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);  
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4);
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);  

K = K2;

w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6);
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7);
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8); 
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9);
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);  
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);  
w12 = ROTATE(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12); 
w13 = ROTATE(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13); 
w14 = ROTATE(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14); 
SIZE = ROTATE(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE);
w16 = ROTATE(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16);
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0); 
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2);
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3); 
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4); 
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5); 
w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6);
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7);
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8); 

K = K3;
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9);
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10);  
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);  
w12 = ROTATE(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12); 
w13 = ROTATE(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13); 
w14 = ROTATE(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14); 
SIZE = ROTATE(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE);
w16 = ROTATE(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w0 = ROTATE(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0); 
w1 = ROTATE(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1);
w2 = ROTATE(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2); 
w3 = ROTATE(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);  
w4 = ROTATE(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = ROTATE(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = ROTATE(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = ROTATE(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
w8 = ROTATE(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);  
w9 = ROTATE(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9); 
w10 = ROTATE(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = ROTATE(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);

#ifdef SINGLE_MODE
id=0;
if ((singlehash.x==A)&&(singlehash.y==B)&&(singlehash.z==C)&&(singlehash.w==D)) id = 1; 
if (id==0) return;
#endif


#ifndef SINGLE_MODE
id=0;
b1=A;b2=B;b3=C;b4=D;
b5=(singlehash.x >> (B&31))&1;
b6=(singlehash.y >> (C&31))&1;
b7=(singlehash.z >> (D&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*5)] = (uint)(A);  
dst[(get_global_id(0)*5)+1] = (uint)(B);
dst[(get_global_id(0)*5)+2] = (uint)(C);
dst[(get_global_id(0)*5)+3] = (uint)(D);
dst[(get_global_id(0)*5)+4] = (uint)(E);


}

