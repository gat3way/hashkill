#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = select(ai2>>(32-tmp1),0U,(tmp1==0));\
    }


#define SET_ABR(ai1,ai2,ii1) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2>>(tmp1)); \
    ai1[elem+1] = select(ai2<<(32-tmp1),0U,(tmp1==0));\
    }




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


#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); } 
#define F_00_19(bb,cc,dd) (bitselect((dd),(cc),(bb)))
#define F_20_39(bb,cc,dd)  ((bb) ^ (cc) ^ (dd))  
#define F_40_59(bb,cc,dd) (bitselect((cc), (bb), ((dd)^(cc))))
#define F_60_79(bb,cc,dd)  F_20_39((bb),(cc),(dd)) 
#else
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); } 
#define F_00_19(bb,cc,dd)  ((((cc) ^ (dd)) & (bb)) ^ (dd))
#define F_20_39(bb,cc,dd)  ((cc) ^ (bb) ^ (dd))  
#define F_40_59(bb,cc,dd)  (((bb) & (cc)) | (((bb)|(cc)) & (dd)))  
#define F_60_79(bb,cc,dd)  F_20_39(bb,cc,dd) 
#endif


#define K0 0x5A827999U;
#define K1 0x6ED9EBA1U;
#define K2 0x8F1BBCDCU;
#define K3 0xCA62C1D6U;
#define H0 0x67452301U;
#define H1 0xEFCDAB89U;
#define H2 0x98BADCFEU;
#define H3 0x10325476U;
#define H4 0xC3D2E1F0U;


#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)



// This prepares the initial buffer: size(4bytes)+ctr_position(4bytes)+utf16(password)+salt+zero bytes for counter
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *input1, uint16 str, uint4 salt)
{
__local uint inpc[64][14];
__local uint inpc1[64][14];
uint SIZE;
uint elem,tmp1,l,tmp2;
uint zero=0;

inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=inpc[GLI][6]=inpc[GLI][7]=(uint)0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=(uint)0;
inpc1[GLI][0]=inpc1[GLI][1]=inpc1[GLI][2]=inpc1[GLI][3]=inpc1[GLI][4]=inpc1[GLI][5]=inpc1[GLI][6]=inpc1[GLI][7]=(uint)0;
inpc1[GLI][8]=inpc1[GLI][9]=inpc1[GLI][10]=inpc1[GLI][11]=inpc1[GLI][12]=inpc1[GLI][13]=(uint)0;

inpc[GLI][0] = inp[GGI*(4)+0];
inpc[GLI][1] = inp[GGI*(4)+1];
inpc[GLI][2] = inp[GGI*(4)+2];
inpc[GLI][3] = inp[GGI*(4)+3];

SIZE=str.sD;

SET_AB(inpc[GLI],str.s0,SIZE);
SET_AB(inpc[GLI],str.s1,SIZE+4);
SET_AB(inpc[GLI],str.s2,SIZE+8);
SET_AB(inpc[GLI],str.s3,SIZE+12);


inpc1[GLI][0] = (inpc[GLI][0]&255)|(((inpc[GLI][0]>>8)&255)<<16);
inpc1[GLI][1] = (((inpc[GLI][0]>>16)&255))|(((inpc[GLI][0]>>24)&255)<<16);
inpc1[GLI][2] = (inpc[GLI][1]&255)|(((inpc[GLI][1]>>8)&255)<<16);
inpc1[GLI][3] = (((inpc[GLI][1]>>16)&255))|(((inpc[GLI][1]>>24)&255)<<16);
inpc1[GLI][4] = (inpc[GLI][2]&255)|(((inpc[GLI][2]>>8)&255)<<16);
inpc1[GLI][5] = (((inpc[GLI][2]>>16)&255))|(((inpc[GLI][2]>>24)&255)<<16);
inpc1[GLI][6] = (inpc[GLI][3]&255)|(((inpc[GLI][3]>>8)&255)<<16);
inpc1[GLI][7] = (((inpc[GLI][3]>>16)&255))|(((inpc[GLI][3]>>24)&255)<<16);
SET_AB(inpc1[GLI],salt.s0,(SIZE+str.sF)*2);
SET_AB(inpc1[GLI],salt.s1,((SIZE+str.sF)*2)+4);


Endian_Reverse32(inpc1[GLI][0]);
Endian_Reverse32(inpc1[GLI][1]);
Endian_Reverse32(inpc1[GLI][2]);
Endian_Reverse32(inpc1[GLI][3]);
Endian_Reverse32(inpc1[GLI][4]);
Endian_Reverse32(inpc1[GLI][5]);
Endian_Reverse32(inpc1[GLI][6]);
Endian_Reverse32(inpc1[GLI][7]);
Endian_Reverse32(inpc1[GLI][8]);
Endian_Reverse32(inpc1[GLI][9]);


dst[(GGI*12)]=(SIZE+str.sF)*2+8+3;
dst[(GGI*12)+1]=(SIZE+str.sF)*2+8;
dst[(GGI*12)+2]=inpc1[GLI][0];
dst[(GGI*12)+3]=inpc1[GLI][1];
dst[(GGI*12)+4]=inpc1[GLI][2];
dst[(GGI*12)+5]=inpc1[GLI][3];
dst[(GGI*12)+6]=inpc1[GLI][4];
dst[(GGI*12)+7]=inpc1[GLI][5];
dst[(GGI*12)+8]=inpc1[GLI][6];
dst[(GGI*12)+9]=inpc1[GLI][7];
dst[(GGI*12)+10]=inpc1[GLI][8];
dst[(GGI*12)+11]=inpc1[GLI][9];
input1[(GGI*5)+0]=(uint)H0;
input1[(GGI*5)+1]=(uint)H1;
input1[(GGI*5)+2]=(uint)H2;
input1[(GGI*5)+3]=(uint)H3;
input1[(GGI*5)+4]=(uint)H4;
}


#ifdef SM21

__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateiv( __global uint4 *dst,  __global uint *input,__global uint *input1,uint16 str, uint4 salt)
{
uint2 SIZE,isize;  
uint ib,ic,id,count,elem,rest,iter;
uint2 tmp1, tmp2,l,t1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint2 K;
uint2 A,B,C,D,E;
uint2 OA,OB,OC,OD,OE;
uint size;
__local uint2 w[64][16];
__local uint2 outiv[64][5];


A.s0=input1[GGI*10+0];
B.s0=input1[GGI*10+1];
C.s0=input1[GGI*10+2];
D.s0=input1[GGI*10+3];
E.s0=input1[GGI*10+4];
A.s1=input1[GGI*10+5];
B.s1=input1[GGI*10+6];
C.s1=input1[GGI*10+7];
D.s1=input1[GGI*10+8];
E.s1=input1[GGI*10+9];

w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=(uint2)0;
w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=(uint2)0;
w[GLI][14]=w[GLI][15]=(uint2)0;

size=input[(GGI*12*2)];
w[GLI][0].s0=input[(GGI*12*2)+2];
w[GLI][1].s0=input[(GGI*12*2)+3];
w[GLI][2].s0=input[(GGI*12*2)+4];
w[GLI][3].s0=input[(GGI*12*2)+5];
w[GLI][4].s0=input[(GGI*12*2)+6];
w[GLI][5].s0=input[(GGI*12*2)+7];
w[GLI][6].s0=input[(GGI*12*2)+8];
w[GLI][7].s0=input[(GGI*12*2)+9];
w[GLI][8].s0=input[(GGI*12*2)+10];
w[GLI][9].s0=input[(GGI*12*2)+11];

w[GLI][0].s1=input[(GGI*12*2)+14];
w[GLI][1].s1=input[(GGI*12*2)+15];
w[GLI][2].s1=input[(GGI*12*2)+16];
w[GLI][3].s1=input[(GGI*12*2)+17];
w[GLI][4].s1=input[(GGI*12*2)+18];
w[GLI][5].s1=input[(GGI*12*2)+19];
w[GLI][6].s1=input[(GGI*12*2)+20];
w[GLI][7].s1=input[(GGI*12*2)+21];
w[GLI][8].s1=input[(GGI*12*2)+22];
w[GLI][9].s1=input[(GGI*12*2)+23];
ic=size-3;
isize=(salt.s2)|(0x80<<24);
Endian_Reverse32(isize);
SET_ABR(w[GLI],(uint2)(isize),ic);
SIZE=(uint2)((salt.s2*size)+size)<<3;
w0=w[GLI][0]; 
w1=w[GLI][1]; 
w2=w[GLI][2]; 
w3=w[GLI][3]; 
w4=w[GLI][4]; 
w5=w[GLI][5]; 
w6=w[GLI][6]; 
w7=w[GLI][7]; 
w8=w[GLI][8]; 
w9=w[GLI][9]; 
w10=w[GLI][10]; 
w11=w[GLI][11]; 
w12=w[GLI][12]; 
w13=w[GLI][13]; 
w14=w[GLI][14]; 
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint2)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint2)K1; 
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
K = (uint2)K2; 
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
K = (uint2)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

outiv[GLI][0]=0;
outiv[GLI][1]=0;
outiv[GLI][2]=0;
outiv[GLI][3]=0;
outiv[GLI][(salt.s2/16384)>>2] |= ((E&255)<<(((salt.s2/16384)&3)*8));
if (salt.s2==0)
{
dst[(get_global_id(0)<<2)+1] = (uint4)0;
dst[(get_global_id(0)<<2)+3] = (uint4)0;
}
dst[(get_global_id(0)<<2)+1] |= (uint4) (outiv[GLI][0].s0,outiv[GLI][1].s0,outiv[GLI][2].s0,outiv[GLI][3].s0);
dst[(get_global_id(0)<<2)+3] |= (uint4) (outiv[GLI][0].s1,outiv[GLI][1].s1,outiv[GLI][2].s1,outiv[GLI][3].s1);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateblock( __global uint *dst,  __global uint *input,__global uint *input1, uint16 str, uint4 salt)
{
uint2 SIZE;
uint i,ia,ib,ic,id,count,elem;
uint2 rest,isize,iter;
uint2 tmp1, tmp2,l,t1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint2 K;
uint2 A,B,C,D,E;
uint2 OA,OB,OC,OD,OE;
__local uint2 wr[64][27];
uint2 d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11;

wr[GLI][0]=wr[GLI][1]=wr[GLI][2]=wr[GLI][3]=wr[GLI][4]=wr[GLI][5]=wr[GLI][6]=(uint)0;
wr[GLI][7]=wr[GLI][8]=wr[GLI][9]=wr[GLI][10]=wr[GLI][11]=wr[GLI][12]=wr[GLI][13]=(uint)0;
wr[GLI][14]=wr[GLI][15]=(uint)0;

d0.s0=input[(GGI*12*2)+2];
d1.s0=input[(GGI*12*2)+3];
d2.s0=input[(GGI*12*2)+4];
d3.s0=input[(GGI*12*2)+5];
d4.s0=input[(GGI*12*2)+6];
d5.s0=input[(GGI*12*2)+7];
d6.s0=input[(GGI*12*2)+8];
d7.s0=input[(GGI*12*2)+9];
d8.s0=input[(GGI*12*2)+10];
d9.s0=input[(GGI*12*2)+11];
d0.s1=input[(GGI*12*2)+14];
d1.s1=input[(GGI*12*2)+15];
d2.s1=input[(GGI*12*2)+16];
d3.s1=input[(GGI*12*2)+17];
d4.s1=input[(GGI*12*2)+18];
d5.s1=input[(GGI*12*2)+19];
d6.s1=input[(GGI*12*2)+20];
d7.s1=input[(GGI*12*2)+21];
d8.s1=input[(GGI*12*2)+22];
d9.s1=input[(GGI*12*2)+23];



A.s0=input1[GGI*10+0];
B.s0=input1[GGI*10+1];
C.s0=input1[GGI*10+2];
D.s0=input1[GGI*10+3];
E.s0=input1[GGI*10+4];
A.s1=input1[GGI*10+5];
B.s1=input1[GGI*10+6];
C.s1=input1[GGI*10+7];
D.s1=input1[GGI*10+8];
E.s1=input1[GGI*10+9];


count=0;
for (ib=salt.s2;ib<(salt.s2+16384);ib++)
{
SET_ABR(wr[GLI],d0,count);
SET_ABR(wr[GLI],d1,count+4);
SET_ABR(wr[GLI],d2,count+8);
SET_ABR(wr[GLI],d3,count+12);
SET_ABR(wr[GLI],d4,count+16);
SET_ABR(wr[GLI],d5,count+20);
SET_ABR(wr[GLI],d6,count+24);
SET_ABR(wr[GLI],d7,count+28);
SET_ABR(wr[GLI],d8,count+32);
SET_ABR(wr[GLI],d9,count+36);
iter=(uint2)(ib);
Endian_Reverse32(iter);
SET_ABR(wr[GLI],iter,count+str.sE-3);
count+=str.sE;
if (count>63)
{
w0=wr[GLI][0];
w1=wr[GLI][1];
w2=wr[GLI][2];
w3=wr[GLI][3];
w4=wr[GLI][4];
w5=wr[GLI][5];
w6=wr[GLI][6];
w7=wr[GLI][7];
w8=wr[GLI][8];
w9=wr[GLI][9];
w10=wr[GLI][10];
w11=wr[GLI][11];
w12=wr[GLI][12];
w13=wr[GLI][13];
w14=wr[GLI][14];
SIZE=wr[GLI][15];
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint2)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint2)K1; 
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
K = (uint2)K2; 
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
K = (uint2)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

wr[GLI][0]=wr[GLI][16];
wr[GLI][1]=wr[GLI][17];
wr[GLI][2]=wr[GLI][18];
wr[GLI][3]=wr[GLI][19];
wr[GLI][4]=wr[GLI][20];
wr[GLI][5]=wr[GLI][21];
wr[GLI][6]=wr[GLI][22];
wr[GLI][7]=wr[GLI][23];
wr[GLI][8]=wr[GLI][24];
wr[GLI][9]=wr[GLI][25];
wr[GLI][10]=wr[GLI][26];
//wr[GLI][16]=wr[GLI][17]=wr[GLI][18]=wr[GLI][19]=wr[GLI][20]=wr[GLI][21]=wr[GLI][22]=wr[GLI][23]=wr[GLI][24]=wr[GLI][25]=wr[GLI][26]=0;
count-=64;
}
}

dst[GGI*10+0]=A.s0;
dst[GGI*10+1]=B.s0;
dst[GGI*10+2]=C.s0;
dst[GGI*10+3]=D.s0;
dst[GGI*10+4]=E.s0;
dst[GGI*10+5]=A.s1;
dst[GGI*10+6]=B.s1;
dst[GGI*10+7]=C.s1;
dst[GGI*10+8]=D.s1;
dst[GGI*10+9]=E.s1;
}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateblocks( __global uint *dst,  __global uint *input,__global uint *input1, uint16 str, uint4 salt)
{
uint2 SIZE;
uint i,ia,ib,ic,id,count,elem;
uint2 rest,isize,iter;
uint2 tmp1, tmp2,l,t1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint2 K;
uint2 A,B,C,D,E;
uint2 OA,OB,OC,OD,OE;
__local uint2 wr[64][22];
uint2 d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11;

wr[GLI][0]=wr[GLI][1]=wr[GLI][2]=wr[GLI][3]=wr[GLI][4]=wr[GLI][5]=wr[GLI][6]=(uint)0;
wr[GLI][7]=wr[GLI][8]=wr[GLI][9]=wr[GLI][10]=wr[GLI][11]=wr[GLI][12]=wr[GLI][13]=(uint)0;
wr[GLI][14]=wr[GLI][15]=(uint)0;

d0.s0=input[(GGI*12*2)+2];
d1.s0=input[(GGI*12*2)+3];
d2.s0=input[(GGI*12*2)+4];
d3.s0=input[(GGI*12*2)+5];
d4.s0=input[(GGI*12*2)+6];
d5.s0=input[(GGI*12*2)+7];
d0.s1=input[(GGI*12*2)+14];
d1.s1=input[(GGI*12*2)+15];
d2.s1=input[(GGI*12*2)+16];
d3.s1=input[(GGI*12*2)+17];
d4.s1=input[(GGI*12*2)+18];
d5.s1=input[(GGI*12*2)+19];


A.s0=input1[GGI*10+0];
B.s0=input1[GGI*10+1];
C.s0=input1[GGI*10+2];
D.s0=input1[GGI*10+3];
E.s0=input1[GGI*10+4];
A.s1=input1[GGI*10+5];
B.s1=input1[GGI*10+6];
C.s1=input1[GGI*10+7];
D.s1=input1[GGI*10+8];
E.s1=input1[GGI*10+9];


count=0;
for (ib=salt.s2;ib<(salt.s2+16384);ib++)
{
SET_ABR(wr[GLI],d0,count);
SET_ABR(wr[GLI],d1,count+4);
SET_ABR(wr[GLI],d2,count+8);
SET_ABR(wr[GLI],d3,count+12);
SET_ABR(wr[GLI],d4,count+16);
SET_ABR(wr[GLI],d5,count+20);
iter=(uint2)(ib);
Endian_Reverse32(iter);
SET_ABR(wr[GLI],iter,count+str.sE-3);
count+=str.sE;
if (count>63)
{
w0=wr[GLI][0];
w1=wr[GLI][1];
w2=wr[GLI][2];
w3=wr[GLI][3];
w4=wr[GLI][4];
w5=wr[GLI][5];
w6=wr[GLI][6];
w7=wr[GLI][7];
w8=wr[GLI][8];
w9=wr[GLI][9];
w10=wr[GLI][10];
w11=wr[GLI][11];
w12=wr[GLI][12];
w13=wr[GLI][13];
w14=wr[GLI][14];
SIZE=wr[GLI][15];
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint2)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint2)K1; 
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
K = (uint2)K2; 
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
K = (uint2)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

wr[GLI][0]=wr[GLI][16];
wr[GLI][1]=wr[GLI][17];
wr[GLI][2]=wr[GLI][18];
wr[GLI][3]=wr[GLI][19];
wr[GLI][4]=wr[GLI][20];
wr[GLI][5]=wr[GLI][21];
//wr[GLI][16]=wr[GLI][17]=wr[GLI][18]=wr[GLI][19]=wr[GLI][20]=wr[GLI][21]=wr[GLI][22]=wr[GLI][23]=wr[GLI][24]=wr[GLI][25]=wr[GLI][26]=0;
count-=64;
}
}

dst[GGI*10+0]=A.s0;
dst[GGI*10+1]=B.s0;
dst[GGI*10+2]=C.s0;
dst[GGI*10+3]=D.s0;
dst[GGI*10+4]=E.s0;
dst[GGI*10+5]=A.s1;
dst[GGI*10+6]=B.s1;
dst[GGI*10+7]=C.s1;
dst[GGI*10+8]=D.s1;
dst[GGI*10+9]=E.s1;
}





__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculatelast( __global uint4 *dst,  __global uint *input,  __global uint *input1, uint16 str, uint4 salt)
{
uint2 OA,OB,OC,OD,OE;  
uint2 SIZE,A,B,C,D,E;  
uint ib,ic,id,count,elem,rest,isize,iter;
uint2 tmp1, tmp2,l,t1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint2 K;


A.s0=input1[GGI*10+0];
B.s0=input1[GGI*10+1];
C.s0=input1[GGI*10+2];
D.s0=input1[GGI*10+3];
E.s0=input1[GGI*10+4];
A.s1=input1[GGI*10+5];
B.s1=input1[GGI*10+6];
C.s1=input1[GGI*10+7];
D.s1=input1[GGI*10+8];
E.s1=input1[GGI*10+9];


w0=0x80000000;
w1=w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=0;
SIZE=((str.sE*16384*16)<<3);


OA=A;OB=B;OC=C;OD=D;OE=E; 
K =  (uint2)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint2)K1; 
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
K = (uint2)K2; 
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
K = (uint2)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

dst[(get_global_id(0)<<2)+0] = (uint4) (A.s0,B.s0,C.s0,D.s0);
dst[(get_global_id(0)<<2)+2] = (uint4) (A.s1,B.s1,C.s1,D.s1);

}


#else

__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateiv( __global uint4 *dst,  __global uint *input,__global uint *input1,uint16 str, uint4 salt)
{
uint SIZE,isize;  
uint ib,ic,id,count,elem,rest,iter;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint K;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;
uint size;
__local uint w[64][16];
__local uint outiv[64][5];


A=input1[GGI*5+0];
B=input1[GGI*5+1];
C=input1[GGI*5+2];
D=input1[GGI*5+3];
E=input1[GGI*5+4];

w[GLI][0]=w[GLI][1]=w[GLI][2]=w[GLI][3]=w[GLI][4]=w[GLI][5]=w[GLI][6]=(uint)0;
w[GLI][7]=w[GLI][8]=w[GLI][9]=w[GLI][10]=w[GLI][11]=w[GLI][12]=w[GLI][13]=(uint)0;
w[GLI][14]=w[GLI][15]=(uint)0;

size=input[(GGI*12)];
w[GLI][0]=input[(GGI*12)+2];
w[GLI][1]=input[(GGI*12)+3];
w[GLI][2]=input[(GGI*12)+4];
w[GLI][3]=input[(GGI*12)+5];
w[GLI][4]=input[(GGI*12)+6];
w[GLI][5]=input[(GGI*12)+7];
w[GLI][6]=input[(GGI*12)+8];
w[GLI][7]=input[(GGI*12)+9];
w[GLI][8]=input[(GGI*12)+10];
w[GLI][9]=input[(GGI*12)+11];
ic=size-3;
isize=(salt.s2)|(0x80<<24);
Endian_Reverse32(isize);
SET_ABR(w[GLI],(uint)(isize),ic);
SIZE=(uint)((salt.s2*size)+size)<<3;
w0=w[GLI][0]; 
w1=w[GLI][1]; 
w2=w[GLI][2]; 
w3=w[GLI][3]; 
w4=w[GLI][4]; 
w5=w[GLI][5]; 
w6=w[GLI][6]; 
w7=w[GLI][7]; 
w8=w[GLI][8]; 
w9=w[GLI][9]; 
w10=w[GLI][10]; 
w11=w[GLI][11]; 
w12=w[GLI][12]; 
w13=w[GLI][13]; 
w14=w[GLI][14]; 
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint)K1; 
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
K = (uint)K2; 
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
K = (uint)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

outiv[GLI][0]=0;
outiv[GLI][1]=0;
outiv[GLI][2]=0;
outiv[GLI][3]=0;
outiv[GLI][(salt.s2/16384)>>2] |= ((E&255)<<(((salt.s2/16384)&3)*8));
if (salt.s2==0)
{
dst[(get_global_id(0)<<1)+1] = (uint4)0;
}
dst[(get_global_id(0)<<1)+1] |= (uint4) (outiv[GLI][0],outiv[GLI][1],outiv[GLI][2],outiv[GLI][3]);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateblock( __global uint *dst,  __global uint *input,__global uint *input1, uint16 str, uint4 salt)
{
uint SIZE;
uint i,ia,ib,ic,id,count,elem;
uint rest,isize,iter;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint K;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;
__local uint wr[64][27];
uint d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11;

wr[GLI][0]=wr[GLI][1]=wr[GLI][2]=wr[GLI][3]=wr[GLI][4]=wr[GLI][5]=wr[GLI][6]=(uint)0;
wr[GLI][7]=wr[GLI][8]=wr[GLI][9]=wr[GLI][10]=wr[GLI][11]=wr[GLI][12]=wr[GLI][13]=(uint)0;
wr[GLI][14]=wr[GLI][15]=(uint)0;

d0=input[(GGI*12)+2];
d1=input[(GGI*12)+3];
d2=input[(GGI*12)+4];
d3=input[(GGI*12)+5];
d4=input[(GGI*12)+6];
d5=input[(GGI*12)+7];
d6=input[(GGI*12)+8];
d7=input[(GGI*12)+9];
d8=input[(GGI*12)+10];
d9=input[(GGI*12)+11];



A=input1[GGI*5+0];
B=input1[GGI*5+1];
C=input1[GGI*5+2];
D=input1[GGI*5+3];
E=input1[GGI*5+4];


count=0;
for (ib=salt.s2;ib<(salt.s2+16384);ib++)
{
SET_ABR(wr[GLI],d0,count);
SET_ABR(wr[GLI],d1,count+4);
SET_ABR(wr[GLI],d2,count+8);
SET_ABR(wr[GLI],d3,count+12);
SET_ABR(wr[GLI],d4,count+16);
SET_ABR(wr[GLI],d5,count+20);
SET_ABR(wr[GLI],d6,count+24);
SET_ABR(wr[GLI],d7,count+28);
SET_ABR(wr[GLI],d8,count+32);
SET_ABR(wr[GLI],d9,count+36);
iter=(uint)(ib);
Endian_Reverse32(iter);
SET_ABR(wr[GLI],iter,count+str.sE-3);
count+=str.sE;
if (count>63)
{
w0=wr[GLI][0];
w1=wr[GLI][1];
w2=wr[GLI][2];
w3=wr[GLI][3];
w4=wr[GLI][4];
w5=wr[GLI][5];
w6=wr[GLI][6];
w7=wr[GLI][7];
w8=wr[GLI][8];
w9=wr[GLI][9];
w10=wr[GLI][10];
w11=wr[GLI][11];
w12=wr[GLI][12];
w13=wr[GLI][13];
w14=wr[GLI][14];
SIZE=wr[GLI][15];
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint)K1; 
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
K = (uint)K2; 
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
K = (uint)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

wr[GLI][0]=wr[GLI][16];
wr[GLI][1]=wr[GLI][17];
wr[GLI][2]=wr[GLI][18];
wr[GLI][3]=wr[GLI][19];
wr[GLI][4]=wr[GLI][20];
wr[GLI][5]=wr[GLI][21];
wr[GLI][6]=wr[GLI][22];
wr[GLI][7]=wr[GLI][23];
wr[GLI][8]=wr[GLI][24];
wr[GLI][9]=wr[GLI][25];
wr[GLI][10]=wr[GLI][26];
//wr[GLI][16]=wr[GLI][17]=wr[GLI][18]=wr[GLI][19]=wr[GLI][20]=wr[GLI][21]=wr[GLI][22]=wr[GLI][23]=wr[GLI][24]=wr[GLI][25]=wr[GLI][26]=0;
count-=64;
}
}

dst[GGI*5+0]=A;
dst[GGI*5+1]=B;
dst[GGI*5+2]=C;
dst[GGI*5+3]=D;
dst[GGI*5+4]=E;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculateblocks( __global uint *dst,  __global uint *input,__global uint *input1, uint16 str, uint4 salt)
{
uint SIZE;
uint i,ia,ib,ic,id,count,elem;
uint rest,isize,iter;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint K;
uint A,B,C,D,E;
uint OA,OB,OC,OD,OE;
__local uint wr[64][22];
uint d0,d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11;

wr[GLI][0]=wr[GLI][1]=wr[GLI][2]=wr[GLI][3]=wr[GLI][4]=wr[GLI][5]=wr[GLI][6]=(uint)0;
wr[GLI][7]=wr[GLI][8]=wr[GLI][9]=wr[GLI][10]=wr[GLI][11]=wr[GLI][12]=wr[GLI][13]=(uint)0;
wr[GLI][14]=wr[GLI][15]=(uint)0;

d0=input[(GGI*12)+2];
d1=input[(GGI*12)+3];
d2=input[(GGI*12)+4];
d3=input[(GGI*12)+5];
d4=input[(GGI*12)+6];
d5=input[(GGI*12)+7];



A=input1[GGI*5+0];
B=input1[GGI*5+1];
C=input1[GGI*5+2];
D=input1[GGI*5+3];
E=input1[GGI*5+4];


count=0;
for (ib=salt.s2;ib<(salt.s2+16384);ib++)
{
SET_ABR(wr[GLI],d0,count);
SET_ABR(wr[GLI],d1,count+4);
SET_ABR(wr[GLI],d2,count+8);
SET_ABR(wr[GLI],d3,count+12);
SET_ABR(wr[GLI],d4,count+16);
SET_ABR(wr[GLI],d5,count+20);
iter=(uint)(ib);
Endian_Reverse32(iter);
SET_ABR(wr[GLI],iter,count+str.sE-3);
count+=str.sE;
if (count>63)
{
w0=wr[GLI][0];
w1=wr[GLI][1];
w2=wr[GLI][2];
w3=wr[GLI][3];
w4=wr[GLI][4];
w5=wr[GLI][5];
w6=wr[GLI][6];
w7=wr[GLI][7];
w8=wr[GLI][8];
w9=wr[GLI][9];
w10=wr[GLI][10];
w11=wr[GLI][11];
w12=wr[GLI][12];
w13=wr[GLI][13];
w14=wr[GLI][14];
SIZE=wr[GLI][15];
OA=A;OB=B;OC=C;OD=D;OE=E; 
K = (uint)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint)K1; 
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
K = (uint)K2; 
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
K = (uint)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

wr[GLI][0]=wr[GLI][16];
wr[GLI][1]=wr[GLI][17];
wr[GLI][2]=wr[GLI][18];
wr[GLI][3]=wr[GLI][19];
wr[GLI][4]=wr[GLI][20];
wr[GLI][5]=wr[GLI][21];
//wr[GLI][16]=wr[GLI][17]=wr[GLI][18]=wr[GLI][19]=wr[GLI][20]=wr[GLI][21]=wr[GLI][22]=wr[GLI][23]=wr[GLI][24]=wr[GLI][25]=wr[GLI][26]=0;
count-=64;
}
}

dst[GGI*5+0]=A;
dst[GGI*5+1]=B;
dst[GGI*5+2]=C;
dst[GGI*5+3]=D;
dst[GGI*5+4]=E;
}






__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void calculatelast( __global uint4 *dst,  __global uint *input,  __global uint *input1, uint16 str, uint4 salt)
{
uint OA,OB,OC,OD,OE;  
uint SIZE,A,B,C,D,E;  
uint ib,ic,id,count,elem,rest,isize,iter;
uint tmp1, tmp2,l,t1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint K;


A=input1[GGI*5+0];
B=input1[GGI*5+1];
C=input1[GGI*5+2];
D=input1[GGI*5+3];
E=input1[GGI*5+4];


w0=0x80000000;
w1=w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=0;
SIZE=((str.sE*16384*16)<<3);


OA=A;OB=B;OC=C;OD=D;OE=E; 
K =  (uint)K0; 
ROTATE1(A, B, C, D, E, w0); 
ROTATE1(E, A, B, C, D, w1); 
ROTATE1(D, E, A, B, C, w2); 
ROTATE1(C, D, E, A, B, w3); 
ROTATE1(B, C, D, E, A, w4); 
ROTATE1(A, B, C, D, E, w5); 
ROTATE1(E, A, B, C, D, w6); 
ROTATE1(D, E, A, B, C, w7); 
ROTATE1(C, D, E, A, B, w8); 
ROTATE1(B, C, D, E, A, w9); 
ROTATE1(A, B, C, D, E, w10); 
ROTATE1(E, A, B, C, D, w11); 
ROTATE1(D, E, A, B, C, w12); 
ROTATE1(C, D, E, A, B, w13); 
ROTATE1(B, C, D, E, A, w14); 
ROTATE1(A, B, C, D, E, SIZE); 
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16); 
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0);  
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1);  
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2);  
K = (uint)K1; 
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
K = (uint)K2; 
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
K = (uint)K3;
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
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);
A=A+OA;B=B+OB;C=C+OC;D=D+OD;E=E+OE;

dst[(get_global_id(0)<<1)+0] = (uint4) (A,B,C,D);

}

#endif