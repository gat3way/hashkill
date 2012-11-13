#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
sha1_saltpass( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt, uint16 str, uint16 str1) 
{

uint4 SIZE;  
uint i,ib,ic,id,ie;  
uint4 t1,t2,t3;
uint4 A,B,C,D,E,K;
uint4 tmp1, l,tmp2,chbase1; 
uint4 w0,w1,w2,w3; 
uint4 w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,temp; 
#define m 0x00FF00FF
#define m2 0xFF00FF00 
uint x0,x1,x2,x3,x4,x5,x6,x7;
__local uint inpc[64][24];
uint elem,temp1;
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


id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];

inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s0+str.sC+salt.sF)>56) {SIZE.s0=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],x0,salt.sF,0);
SET_AB(inpc[GLI],x1,salt.sF+4,0);
SET_AB(inpc[GLI],x2,salt.sF+8,0);
SET_AB(inpc[GLI],x3,salt.sF+12,0);
SET_AB(inpc[GLI],x4,salt.sF+16,0);
SET_AB(inpc[GLI],x5,salt.sF+20,0);
SET_AB(inpc[GLI],x6,salt.sF+24,0);
SET_AB(inpc[GLI],x7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s0,salt.sF+SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,salt.sF+SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,salt.sF+SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,salt.sF+SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC+salt.sF),0);
SIZE.s0 = (SIZE.s0+str.sC+salt.sF)<<3;
w0.s0=inpc[GLI][0];
w1.s0=inpc[GLI][1];
w2.s0=inpc[GLI][2];
w3.s0=inpc[GLI][3];
w4.s0=inpc[GLI][4];
w5.s0=inpc[GLI][5];
w6.s0=inpc[GLI][6];
w7.s0=inpc[GLI][7];
w8.s0=inpc[GLI][8];
w9.s0=inpc[GLI][9];
w10.s0=inpc[GLI][10];
w11.s0=inpc[GLI][11];
w12.s0=inpc[GLI][12];
w13.s0=inpc[GLI][13];



inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s1+str.sD+salt.sF)>56) {SIZE.s1=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],x0,salt.sF,0);
SET_AB(inpc[GLI],x1,salt.sF+4,0);
SET_AB(inpc[GLI],x2,salt.sF+8,0);
SET_AB(inpc[GLI],x3,salt.sF+12,0);
SET_AB(inpc[GLI],x4,salt.sF+16,0);
SET_AB(inpc[GLI],x5,salt.sF+20,0);
SET_AB(inpc[GLI],x6,salt.sF+24,0);
SET_AB(inpc[GLI],x7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s4,salt.sF+SIZE.s0,0);
SET_AB(inpc[GLI],str.s5,salt.sF+SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s6,salt.sF+SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s7,salt.sF+SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD+salt.sF),0);
w0.s1=inpc[GLI][0];
w1.s1=inpc[GLI][1];
w2.s1=inpc[GLI][2];
w3.s1=inpc[GLI][3];
w4.s1=inpc[GLI][4];
w5.s1=inpc[GLI][5];
w6.s1=inpc[GLI][6];
w7.s1=inpc[GLI][7];
w8.s1=inpc[GLI][8];
w9.s1=inpc[GLI][9];
w10.s1=inpc[GLI][10];
w11.s1=inpc[GLI][11];
w12.s1=inpc[GLI][12];
w13.s1=inpc[GLI][13];
SIZE.s1 = (SIZE.s1+str.sD+salt.sF)<<3;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s2+str.sE+salt.sF)>56) {SIZE.s2=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],x0,salt.sF,0);
SET_AB(inpc[GLI],x1,salt.sF+4,0);
SET_AB(inpc[GLI],x2,salt.sF+8,0);
SET_AB(inpc[GLI],x3,salt.sF+12,0);
SET_AB(inpc[GLI],x4,salt.sF+16,0);
SET_AB(inpc[GLI],x5,salt.sF+20,0);
SET_AB(inpc[GLI],x6,salt.sF+24,0);
SET_AB(inpc[GLI],x7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s8,salt.sF+SIZE.s0,0);
SET_AB(inpc[GLI],str.s9,salt.sF+SIZE.s0+4,0);
SET_AB(inpc[GLI],str.sA,salt.sF+SIZE.s0+8,0);
SET_AB(inpc[GLI],str.sB,salt.sF+SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE+salt.sF),0);
w0.s2=inpc[GLI][0];
w1.s2=inpc[GLI][1];
w2.s2=inpc[GLI][2];
w3.s2=inpc[GLI][3];
w4.s2=inpc[GLI][4];
w5.s2=inpc[GLI][5];
w6.s2=inpc[GLI][6];
w7.s2=inpc[GLI][7];
w8.s2=inpc[GLI][8];
w9.s2=inpc[GLI][9];
w10.s2=inpc[GLI][10];
w11.s2=inpc[GLI][11];
w12.s2=inpc[GLI][12];
w13.s2=inpc[GLI][13];
SIZE.s2 = (SIZE.s2+str.sE+salt.sF)<<3;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s3+str1.sC+salt.sF)>56) {SIZE.s3=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],x0,salt.sF,0);
SET_AB(inpc[GLI],x1,salt.sF+4,0);
SET_AB(inpc[GLI],x2,salt.sF+8,0);
SET_AB(inpc[GLI],x3,salt.sF+12,0);
SET_AB(inpc[GLI],x4,salt.sF+16,0);
SET_AB(inpc[GLI],x5,salt.sF+20,0);
SET_AB(inpc[GLI],x6,salt.sF+24,0);
SET_AB(inpc[GLI],x7,salt.sF+28,0);
SET_AB(inpc[GLI],str1.s0,salt.sF+SIZE.s0,0);
SET_AB(inpc[GLI],str1.s1,salt.sF+SIZE.s0+4,0);
SET_AB(inpc[GLI],str1.s2,salt.sF+SIZE.s0+8,0);
SET_AB(inpc[GLI],str1.s3,salt.sF+SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC+salt.sF),0);
w0.s3=inpc[GLI][0];
w1.s3=inpc[GLI][1];
w2.s3=inpc[GLI][2];
w3.s3=inpc[GLI][3];
w4.s3=inpc[GLI][4];
w5.s3=inpc[GLI][5];
w6.s3=inpc[GLI][6];
w7.s3=inpc[GLI][7];
w8.s3=inpc[GLI][8];
w9.s3=inpc[GLI][9];
w10.s3=inpc[GLI][10];
w11.s3=inpc[GLI][11];
w12.s3=inpc[GLI][12];
w13.s3=inpc[GLI][13];
SIZE.s3 = (SIZE.s3+str1.sC+salt.sF)<<3;


w14=w16=(uint4)0;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  


#ifndef OLD_ATI
#define F_00_19(b,c,d) (bitselect(d,c,b))
#define F_20_39(b,c,d)  ((b) ^ (c) ^ (d))  
#define F_40_59(b,c,d) (bitselect(c,b,(d^c)))
#define F_60_79(b,c,d)  F_20_39(b,c,d) 
#else
#define F_00_19(b,c,d)  ((((c) ^ (d)) & (b)) ^ (d))
#define F_20_39(b,c,d)  ((c) ^ (b) ^ (d))  
#define F_40_59(b,c,d)  (((b) & (c)) | (((b)|(c)) & (d)))  
#define F_60_79(b,c,d)  F_20_39(b,c,d) 
#endif


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define ROTATE1(a, b, c, d, e, x) e = e + rotate(a,S2) + F_00_19(b,c,d) + x; e = e + K; b = rotate(b,S3) 
#define ROTATE1_NULL(a, b, c, d, e)  e = e + rotate(a,S2) + F_00_19(b,c,d) + K; b = rotate(b,S3)
#define ROTATE2_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_20_39(b,c,d) + x + K; b = rotate(b,S3) 
#define ROTATE3_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_40_59(b,c,d) + x + K; b = rotate(b,S3)
#define ROTATE4_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_60_79(b,c,d) + x + K; b = rotate(b,S3)



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
Endian_Reverse32(w8);  
ROTATE1(C, D, E, A, B, w8);
Endian_Reverse32(w9);  
ROTATE1(B, C, D, E, A, w9);
Endian_Reverse32(w10);  
ROTATE1(A, B, C, D, E, w10);
Endian_Reverse32(w11);  
ROTATE1(E, A, B, C, D, w11);
Endian_Reverse32(w12);  
ROTATE1(D, E, A, B, C, w12);
Endian_Reverse32(w13);  
ROTATE1(C, D, E, A, B, w13);
ROTATE1_NULL(B, C, D, E, A);

ROTATE1(A, B, C, D, E, SIZE);  

w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16);
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0); 
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1); 
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 


K = K1;

w3 = rotate((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3);
w4 = rotate((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4);
w5 = rotate((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = rotate((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6);
w7 = rotate((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = rotate((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = rotate((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9);
w10 = rotate((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = rotate((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = rotate((w9 ^ w4 ^ SIZE ^ w13),S1); ROTATE2_F(B, C, D, E, A, w12);
w13 = rotate((w10 ^ w5 ^ w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = rotate((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14);
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = rotate(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);  
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2); 
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4);
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);  
K = K2;

w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6);
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7);
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8); 
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);  
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);  
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12); 
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
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE);
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0); 
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2); 
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
#ifdef SINGLE_MODE
//if (all((uint4)singlehash.y != E)) return;
#endif
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);  
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9); 
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);



A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;
Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);

if (all((uint4)singlehash.x!=A)) return;
if (all((uint4)singlehash.z!=C)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*5)] = (uint4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*5)+1] = (uint4)(E.s0,A.s1,B.s1,C.s1);
dst[(get_global_id(0)*5)+2] = (uint4)(D.s1,E.s1,A.s2,B.s2);
dst[(get_global_id(0)*5)+3] = (uint4)(C.s2,D.s2,E.s2,A.s3);
dst[(get_global_id(0)*5)+4] = (uint4)(B.s3,C.s3,D.s3,E.s3);


}



