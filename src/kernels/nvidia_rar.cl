
#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, uint16 str, uint16 salt)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = inp[GGI*(4)+0];
inpc[GLI][1] = inp[GGI*(4)+1];
inpc[GLI][2] = inp[GGI*(4)+2];
inpc[GLI][3] = inp[GGI*(4)+3];

//SIZE=sizein[GGI];
//size[GGI] = (SIZE+str.sF)<<3;
SIZE=salt.s0;

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

dst[GGI*8+0] = (inpc[GLI][0]&255)|(((inpc[GLI][0]>>8)&255)<<16);
dst[GGI*8+1] = (((inpc[GLI][0]>>16)&255))|(((inpc[GLI][0]>>24)&255)<<16);
dst[GGI*8+2] = (inpc[GLI][1]&255)|(((inpc[GLI][1]>>8)&255)<<16);
dst[GGI*8+3] = (((inpc[GLI][1]>>16)&255))|(((inpc[GLI][1]>>24)&255)<<16);
dst[GGI*8+4] = (inpc[GLI][2]&255)|(((inpc[GLI][2]>>8)&255)<<16);
dst[GGI*8+5] = (((inpc[GLI][2]>>16)&255))|(((inpc[GLI][2]>>24)&255)<<16);
dst[GGI*8+6] = (inpc[GLI][3]&255)|(((inpc[GLI][3]>>8)&255)<<16);
dst[GGI*8+7] = (((inpc[GLI][3]>>16)&255))|(((inpc[GLI][3]>>24)&255)<<16);
}



#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); } 
#define F_00_19(bb,cc,dd) (bitselect((dd),(cc),(bb)))
#define F_20_39(bb,cc,dd)  ((bb) ^ (cc) ^ (dd))  
#define F_40_59(bb,cc,dd) (bitselect((cc), (bb), ((dd)^(cc))))
#define F_60_79(bb,cc,dd)  F_20_39((bb),(cc),(dd)) 


#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)

#define GLI get_local_id(0)


#define S11 3U
#define S12 7U
#define S13 11U
#define S14 19U
#define S21 3U
#define S22 5U
#define S23 9U
#define S24 13U
#define S31 3U
#define S32 9U
#define S33 11U
#define S34 15U

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  

#define S1 1U
#define S2 5U
#define S3 30U  
#define Sl 8U
#define Sr 24U 
#define m 0x00FF00FFU
#define m2 0xFF00FF00U


#ifdef OLD_ATI
#define SET_AB(ai1,ai2,ii1,ii2) { \
	tmp1=(ii1&3)<<3; \
	elem=ii1>>2; \
        ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
        ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
        }
#else
#define SET_AB(ai1,ai2,ii1,ii2) { \
	elem=ii1>>2; \
	tmp1=(ii1&3)<<3; \
        ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
        ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
        }
#endif


#define SHA1_BLOCK() { \
w0=w[GLI][0]; \
w1=w[GLI][1]; \
w2=w[GLI][2]; \
w3=w[GLI][3]; \
w4=w[GLI][4]; \
w5=w[GLI][5]; \
w6=w[GLI][6]; \
w7=w[GLI][7]; \
w8=w[GLI][8]; \
w9=w[GLI][9]; \
w10=w[GLI][10]; \
w11=w[GLI][11]; \
w12=w[GLI][12]; \
w13=w[GLI][13]; \
w14=w[GLI][14]; \
SIZE=w[GLI][15]; \
Endian_Reverse32(w0); \
Endian_Reverse32(w1); \
Endian_Reverse32(w2); \
Endian_Reverse32(w3); \
Endian_Reverse32(w4); \
Endian_Reverse32(w5); \
Endian_Reverse32(w6); \
Endian_Reverse32(w7); \
Endian_Reverse32(w8); \
Endian_Reverse32(w9); \
Endian_Reverse32(w10); \
Endian_Reverse32(w11); \
Endian_Reverse32(w12); \
Endian_Reverse32(w13); \
Endian_Reverse32(w14); \
Endian_Reverse32(SIZE); \
OA=A;OB=B;OC=C;OD=D;OE=E; \
K = K0; \
ROTATE1(A, B, C, D, E, w0); \
ROTATE1(E, A, B, C, D, w1); \
ROTATE1(D, E, A, B, C, w2); \
ROTATE1(C, D, E, A, B, w3); \
ROTATE1(B, C, D, E, A, w4); \
ROTATE1(A, B, C, D, E, w5); \
ROTATE1(E, A, B, C, D, w6); \
ROTATE1(D, E, A, B, C, w7); \
ROTATE1(C, D, E, A, B, w8); \
ROTATE1(B, C, D, E, A, w9); \
ROTATE1(A, B, C, D, E, w10); \
ROTATE1(E, A, B, C, D, w11); \
ROTATE1(D, E, A, B, C, w12); \
ROTATE1(C, D, E, A, B, w13); \
ROTATE1(B, C, D, E, A, w14); \
ROTATE1(A, B, C, D, E, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); \
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  \
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  \
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  \
K = K1; \
w3 = rotate((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3); \
w4 = rotate((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4); \
w5 = rotate((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5); \
w6 = rotate((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6); \
w7 = rotate((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7); \
w8 = rotate((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8); \
w9 = rotate((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9); \
w10 = rotate((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10); \
w11 = rotate((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11);  \
w12 = rotate((w9 ^ w4 ^ SIZE ^ w13),S1); ROTATE2_F(B, C, D, E, A, w12); \
w13 = rotate((w10 ^ w5 ^ w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13); \
w14 = rotate((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14); \
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);   \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4); \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);   \
K = K2; \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8);  \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);   \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2); \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3);  \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4);  \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5);  \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8);  \
K = K3; \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10); \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);   \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);   \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6);  \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7);  \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);   \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);  \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); \
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE; \
}



#define SHA1_BLOCK_SIZE() { \
w0=w[GLI][0]; \
w1=w[GLI][1]; \
w2=w[GLI][2]; \
w3=w[GLI][3]; \
w4=w[GLI][4]; \
w5=w[GLI][5]; \
w6=w[GLI][6]; \
w7=w[GLI][7]; \
w8=w[GLI][8]; \
w9=w[GLI][9]; \
w10=w[GLI][10]; \
w11=w[GLI][11]; \
w12=w[GLI][12]; \
w13=w[GLI][13]; \
w14=w[GLI][14]; \
SIZE=w[GLI][15]; \
Endian_Reverse32(w0); \
Endian_Reverse32(w1); \
Endian_Reverse32(w2); \
Endian_Reverse32(w3); \
Endian_Reverse32(w4); \
Endian_Reverse32(w5); \
Endian_Reverse32(w6); \
Endian_Reverse32(w7); \
Endian_Reverse32(w8); \
Endian_Reverse32(w9); \
Endian_Reverse32(w10); \
Endian_Reverse32(w11); \
Endian_Reverse32(w12); \
Endian_Reverse32(w13); \
Endian_Reverse32(w14); \
OA=A;OB=B;OC=C;OD=D;OE=E; \
K = K0; \
ROTATE1(A, B, C, D, E, w0); \
ROTATE1(E, A, B, C, D, w1); \
ROTATE1(D, E, A, B, C, w2); \
ROTATE1(C, D, E, A, B, w3); \
ROTATE1(B, C, D, E, A, w4); \
ROTATE1(A, B, C, D, E, w5); \
ROTATE1(E, A, B, C, D, w6); \
ROTATE1(D, E, A, B, C, w7); \
ROTATE1(C, D, E, A, B, w8); \
ROTATE1(B, C, D, E, A, w9); \
ROTATE1(A, B, C, D, E, w10); \
ROTATE1(E, A, B, C, D, w11); \
ROTATE1(D, E, A, B, C, w12); \
ROTATE1(C, D, E, A, B, w13); \
ROTATE1(B, C, D, E, A, w14); \
ROTATE1(A, B, C, D, E, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); \
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  \
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  \
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  \
K = K1; \
w3 = rotate((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3); \
w4 = rotate((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4); \
w5 = rotate((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5); \
w6 = rotate((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6); \
w7 = rotate((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7); \
w8 = rotate((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8); \
w9 = rotate((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9); \
w10 = rotate((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10); \
w11 = rotate((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11);  \
w12 = rotate((w9 ^ w4 ^ SIZE ^ w13),S1); ROTATE2_F(B, C, D, E, A, w12); \
w13 = rotate((w10 ^ w5 ^ w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13); \
w14 = rotate((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14); \
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);   \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4); \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);   \
K = K2; \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8);  \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);   \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2); \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3);  \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4);  \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5);  \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8);  \
K = K3; \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10); \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);   \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);   \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6);  \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7);  \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);   \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);  \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); \
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE; \
}




#define SHA1_BLOCK_FINAL(size) { \
w0=(uint)0x80000000; \
w1=w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;\
SIZE=((size)<<3); \
OA=A;OB=B;OC=C;OD=D;OE=E; \
K = K0; \
ROTATE1(A, B, C, D, E, w0); \
ROTATE1_NULL(E, A, B, C, D); \
ROTATE1_NULL(D, E, A, B, C); \
ROTATE1_NULL(C, D, E, A, B); \
ROTATE1_NULL(B, C, D, E, A); \
ROTATE1_NULL(A, B, C, D, E); \
ROTATE1_NULL(E, A, B, C, D); \
ROTATE1_NULL(D, E, A, B, C); \
ROTATE1_NULL(C, D, E, A, B); \
ROTATE1_NULL(B, C, D, E, A); \
ROTATE1_NULL(A, B, C, D, E); \
ROTATE1_NULL(E, A, B, C, D); \
ROTATE1_NULL(D, E, A, B, C); \
ROTATE1_NULL(C, D, E, A, B); \
ROTATE1_NULL(B, C, D, E, A); \
ROTATE1(A, B, C, D, E, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); \
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  \
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  \
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  \
K = K1; \
w3 = rotate((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3); \
w4 = rotate((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4); \
w5 = rotate((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5); \
w6 = rotate((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6); \
w7 = rotate((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7); \
w8 = rotate((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8); \
w9 = rotate((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9); \
w10 = rotate((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10);  \
w11 = rotate((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11);  \
w12 = rotate((w9 ^ w4 ^ SIZE ^ w13),S1); ROTATE2_F(B, C, D, E, A, w12); \
w13 = rotate((w10 ^ w5 ^ w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13); \
w14 = rotate((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14); \
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE); \
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);   \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);   \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4); \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);   \
K = K2; \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8);  \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);   \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2); \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3);  \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4);  \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5);  \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6); \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7); \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8);  \
K = K3; \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9); \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10);   \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);   \
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12);  \
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13);  \
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14);  \
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE); \
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16); \
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0);  \
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1); \
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2);  \
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);   \
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);   \
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);   \
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6);  \
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7);  \
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);   \
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);  \
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10); \
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11); \
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE; \
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar15( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][27];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint d8;
uint d9;
uint d10;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
d5=input[get_global_id(0)*8+5];
d6=input[get_global_id(0)*8+6];
d7=input[get_global_id(0)*8+7];

d8=(uint)salt.s0;
d9=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d10 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=2; \
SET_AB(w[GLI],d8,count,0);count+=4; \
SET_AB(w[GLI],d9,count,0);count+=4; \
SET_AB(w[GLI],d10,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][8]=w[GLI][24]; \
w[GLI][9]=w[GLI][25]; \
w[GLI][10]=w[GLI][26]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][25]=w[GLI][26]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d10=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=2; \
SET_AB(w[GLI],d8,count,0);count+=4; \
SET_AB(w[GLI],d9,count,0);count+=4; \
SET_AB(w[GLI],d10,count,0);count+=3; \
count=0;\
w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][25]=w[GLI][26]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;



int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,41+16384*iter*41);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*41);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar14( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][26];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint d8;
uint d9;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
d5=input[get_global_id(0)*8+5];
d6=input[get_global_id(0)*8+6];

d7=(uint)salt.s0;
d8=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d9 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=4; \
SET_AB(w[GLI],d9,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][8]=w[GLI][24]; \
w[GLI][9]=w[GLI][25]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][25]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=d2; \
w[GLI][3]=d3; \
w[GLI][4]=d4; \
w[GLI][5]=d5; \
w[GLI][6]=d6; \
w[GLI][7]=(uint)salt.s0; \
w[GLI][8]=(uint)salt.s1; \
w[GLI][9]=(uint)(turn|(0x80<<24)); \
w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][25]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,39+16384*iter*39);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*39);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar13( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][26];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint d8;
uint d9;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
d5=input[get_global_id(0)*8+5];
d6=input[get_global_id(0)*8+6];
//d7.s0=input[get_global_id(0)*2*8+7];

d7=(uint)salt.s0;
d8=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d9 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=2; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=4; \
SET_AB(w[GLI],d9,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][8]=w[GLI][24]; \
w[GLI][9]=w[GLI][25]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][25]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d9=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=2; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=4; \
SET_AB(w[GLI],d9,count,0);count+=3; \
count=0;\
w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=w[GLI][26]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,37+16384*iter*37);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*37);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar12( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][25];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint d8;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
d5=input[get_global_id(0)*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d6=(uint)salt.s0;
d7=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d8 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][8]=w[GLI][24]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=d2; \
w[GLI][3]=d3; \
w[GLI][4]=d4; \
w[GLI][5]=d5; \
w[GLI][6]=(uint)salt.s0; \
w[GLI][7]=(uint)salt.s1; \
w[GLI][8]=(uint)(turn|(0x80<<24)); \
w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,35+16384*iter*35);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*35);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar11( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][25];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint d8;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
d5=input[get_global_id(0)*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d6=(uint)salt.s0;
d7=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d8 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=2; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][8]=w[GLI][24]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d8=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=2; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=4; \
SET_AB(w[GLI],d8,count,0);count+=3; \
count=0;\
w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=w[GLI][24]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,33+16384*iter*33);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*33);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar10( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][24];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d5=(uint)salt.s0;
d6=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d7 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=d2; \
w[GLI][3]=d3; \
w[GLI][4]=d4; \
w[GLI][5]=(uint)salt.s0; \
w[GLI][6]=(uint)salt.s1; \
w[GLI][7]=(uint)(turn|(0x80<<24)); \
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,31+16384*iter*31);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*31);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar9( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][24];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
d4=input[get_global_id(0)*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d5=(uint)salt.s0;
d6=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d7 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=2; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][7]=w[GLI][23]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d7=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=2; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=4; \
SET_AB(w[GLI],d7,count,0);count+=3; \
count=0;\
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=w[GLI][23]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,29+16384*iter*29);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*29);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar8( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][23];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint d7;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d4=(uint)salt.s0;
d5=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d6 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=d2; \
w[GLI][3]=d3; \
w[GLI][4]=(uint)salt.s0; \
w[GLI][5]=(uint)salt.s1; \
w[GLI][6]=(uint)(turn|(0x80<<24)); \
w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,27+16384*iter*27);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*27);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar7( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][23];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint d6;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
d3=input[get_global_id(0)*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d4=(uint)salt.s0;
d5=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d6 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=2; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][6]=w[GLI][22]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d6=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=2; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=4; \
SET_AB(w[GLI],d6,count,0);count+=3; \
count=0;\
w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;

int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,25+16384*iter*25);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*25);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}





__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar6( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d3=(uint)salt.s0;
d4=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d5 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=d2; \
w[GLI][3]=(uint)salt.s0; \
w[GLI][4]=(uint)salt.s1; \
w[GLI][5]=(uint)(turn|(0x80<<24)); \
w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=w[GLI][22]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,23+16384*iter*23);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*23);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar5( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
d2=input[get_global_id(0)*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5.s0=input[get_global_id(0)*2*8+5];
//d6.s0=input[get_global_id(0)*2*8+6];
//d7.s0=input[get_global_id(0)*2*8+7];

d3=(uint)salt.s0;
d4=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d5 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=2; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d5=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=2; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=4; \
SET_AB(w[GLI],d5,count,0);count+=3; \
count=0;\
w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,21+16384*iter*21);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*21);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar4( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
//d2=input[get_global_id(0)*2*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d2=(uint)salt.s0;
d3=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d4 = ib&0xFFFFFF; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=d1; \
w[GLI][2]=(uint)salt.s0; \
w[GLI][3]=(uint)salt.s1; \
w[GLI][4]=(uint)(turn|(0x80<<24)); \
w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;

int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,19+16384*iter*19);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*19);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar3( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
d1=input[get_global_id(0)*8+1];
//d2=input[get_global_id(0)*2*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d2=(uint)salt.s0;
d3=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d4 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=2; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d4=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=2; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=4; \
SET_AB(w[GLI],d4,count,0);count+=3; \
count=0;\
w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,17+16384*iter*17);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*17);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar2( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
//d1=input[get_global_id(0)*2*8+1];
//d2=input[get_global_id(0)*2*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d1=(uint)salt.s0;
d2=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d3 = ib&0xFFFFFF; \
SET_AB(w[GLI],d0,count,0);count+=4; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
w[GLI][0]=d0; \
w[GLI][1]=(uint)salt.s0; \
w[GLI][2]=(uint)salt.s1; \
w[GLI][3]=(uint)(turn|(0x80<<24)); \
w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,15+16384*iter*15);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*15);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar1( __global uint4 *dst,  __global uint *input, uint4 salt)
{

uint SIZE;  

uint ib,ic,id,count,elem,rest,isize;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;

// change to uint
uint K;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
__local uint w[64][22];
__local uint IV[64][4];

uint d0;
uint d1;
uint d2;
uint d3;
uint d4;
uint d5;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;



d0=input[get_global_id(0)*8];
//d1=input[get_global_id(0)*2*8+1];
//d2=input[get_global_id(0)*2*8+2];
//d3=input[get_global_id(0)*2*8+3];
//d4=input[get_global_id(0)*2*8+4];
//d5=input[get_global_id(0)*2*8+5];
//d6=input[get_global_id(0)*2*8+6];
//d7=input[get_global_id(0)*2*8+7];

d1=(uint)salt.s0;
d2=(uint)salt.s1;


#define LOOP_BODY(start) { \
for (ib=start;ib<(start+16384);ib++) \
{ \
d3 = ib&0xFFFFFF;; \
SET_AB(w[GLI],d0,count,0);count+=2; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=3; \
if (count>=64)  \
{  \
SHA1_BLOCK(); \
w[GLI][0]=w[GLI][16]; \
w[GLI][1]=w[GLI][17]; \
w[GLI][2]=w[GLI][18]; \
w[GLI][3]=w[GLI][19]; \
w[GLI][4]=w[GLI][20]; \
w[GLI][5]=w[GLI][21]; \
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=0; \
count-=64; \
} \
} \
}


#define SHA1_BLOCK_IV(turn,size) { \
count=0; \
d3=(uint)(turn|(0x80<<24)); \
SET_AB(w[GLI],d0,count,0);count+=2; \
SET_AB(w[GLI],d1,count,0);count+=4; \
SET_AB(w[GLI],d2,count,0);count+=4; \
SET_AB(w[GLI],d3,count,0);count+=3; \
count=0;\
w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0; \
t1=(size<<3); \
w[GLI][15]=t1; \
SHA1_BLOCK_SIZE(); \
}


A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
count=0;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=(uint)0;
w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=(uint)0;
w[GLI][16]=w[GLI][17]=w[GLI][18]=w[GLI][19]=w[GLI][20]=w[GLI][21]=(uint)0; 
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=(uint)0;


int iter;
#pragma unroll 1
for (iter=0;iter<16;iter++)
{
SHA1_BLOCK_IV(iter*16384,13+16384*iter*13);
IV[GLI][iter>>2] |= ((E&255)<<((iter&3)*8));
A=OA;B=OB;C=OC;D=OD;E=OE;
w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=w[GLI][14]=w[GLI][15]=0; 
LOOP_BODY(16384*iter);
}
SHA1_BLOCK_FINAL(16384*16*13);


dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (uint4) (IV[GLI][0],IV[GLI][1],IV[GLI][2],IV[GLI][3]);

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void rar0( __global uint4 *dst,  __global uint *input, uint4 salt)
{
uint A,B,C,D;
uint IV[64][4];

A=B=C=D=0;
IV[GLI][0]=IV[GLI][1]=IV[GLI][2]=IV[GLI][3]=0;
// A DUMMY KERNEL
}

