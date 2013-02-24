#ifndef SM10
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
strmodify( __global uint *dst,  __global uint *inp, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][22];
uint SIZE;
uint elem,tmp1,i,j;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=0;
inpc[GLI][4]=inpc[GLI][5]=inpc[GLI][6]=inpc[GLI][7]=0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=0;
inpc[GLI][12]=inpc[GLI][13]=inpc[GLI][14]=inpc[GLI][15]=0;

inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
if (SIZE>32) SIZE=32;

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);
SIZE+=str.sF;


sizein[GGI] = (SIZE);
dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}



#define H0 0x6A09E667U
#define H1 0xBB67AE85U
#define H2 0x3C6EF372U
#define H3 0xA54FF53AU
#define H4 0x510E527FU
#define H5 0x9B05688CU
#define H6 0x1F83D9ABU
#define H7 0x5BE0CD19U

#define Sl 8U
#define Sr 24U
#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))


#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}

#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }





__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint8 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint x[12];
uint m= 0x00FF00FFU;
uint m2= 0xFF00FF00U;
uint A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,id,SIZE;
uint TA,TB,TC,TD,TE,TF,TG,TH;
uint elem,i,j,k;


a1=input[get_global_id(0)*8];
b1=input[get_global_id(0)*8+1];
c1=input[get_global_id(0)*8+2];
d1=input[get_global_id(0)*8+3];
e1=input[get_global_id(0)*8+4];
f1=input[get_global_id(0)*8+5];
g1=input[get_global_id(0)*8+6];
h1=input[get_global_id(0)*8+7];

x[8]=x[9]=x[10]=x[11]=0;
x[0]=a1;
x[1]=b1;
x[2]=c1;
x[3]=d1;
x[4]=e1;
x[5]=f1;
x[6]=g1;
x[7]=h1;
k=size[get_global_id(0)];
SET_AB(x,singlehash.s8,k,0);
SET_AB(x,singlehash.s9,k+4,0);
SET_AB(x,0x80U,k+8,0);
k+=8;

w0=x[0];
w1=x[1];
w2=x[2];
w3=x[3];
w4=x[4];
w5=x[5];
w6=x[6];
w7=x[7];
w8=x[8];
w9=x[9];
w10=x[10];
w11=w12=w13=w14=0U;
SIZE=k<<3;

Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
Endian_Reverse32(w8);
Endian_Reverse32(w9);
Endian_Reverse32(w10);

A=(uint)H0;
B=(uint)H1;
C=(uint)H2;
D=(uint)H3;
E=(uint)H4;
F=(uint)H5;
G=(uint)H6;
H=(uint)H7;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25BU);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1U);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4U);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5U);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98U);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01U);
P(G, H, A, B, C, D, E, F, w10, 0x243185BEU);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3U);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74U);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FEU);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1U);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786U);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6U);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CCU);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6FU);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AAU);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DCU);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DAU);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152U);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66DU);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8U);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7U);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3U);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147U);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351U);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967U);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85U);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138U);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFCU);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13U);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354U);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABBU);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92EU);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85U);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1U);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664BU);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70U);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3U);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819U);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624U);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585U);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070U);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116U);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08U);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774CU);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5U);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3U);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4AU);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4FU);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3U);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EEU);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636FU);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814U);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208U);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFAU);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEBU);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7U);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2U);

A=A+(uint)H0;
B=B+(uint)H1;
C=C+(uint)H2;
D=D+(uint)H3;
E=E+(uint)H4;
F=F+(uint)H5;
G=G+(uint)H6;
H=H+(uint)H7;

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);
Endian_Reverse32(F);
Endian_Reverse32(G);
Endian_Reverse32(H);


if ((A!=singlehash.s0)) return;
if ((B!=singlehash.s1)) return;
if ((C!=singlehash.s2)) return;
if ((D!=singlehash.s3)) return;
if ((E!=singlehash.s4)) return;
if ((F!=singlehash.s5)) return;
if ((G!=singlehash.s6)) return;
if ((H!=singlehash.s7)) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint8)(A,B,C,D,E,F,G,H);
}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint8 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
}


#endif