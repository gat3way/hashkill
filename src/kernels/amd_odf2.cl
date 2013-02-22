#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
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
size[GGI] = (SIZE+str.sF);

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


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

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
#define m 0x00FF00FFU
#define m2 0xFF00FF00U

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

#define GLI get_local_id(0)


#ifndef GCN
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint2 SIZE,sz;  
uint ib,ic,id;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint2 A,B,C,D,E,F,G,H;
uint2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint2 TA,TB,TC,TD,TE;
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(uint2)0;


a.s0=input[get_global_id(0)*2*8];
b.s0=input[get_global_id(0)*2*8+1];
c.s0=input[get_global_id(0)*2*8+2];
d.s0=input[get_global_id(0)*2*8+3];
e.s0=input[get_global_id(0)*2*8+4];
f.s0=input[get_global_id(0)*2*8+5];
g.s0=input[get_global_id(0)*2*8+6];
h.s0=input[get_global_id(0)*2*8+7];

a.s1=input[get_global_id(0)*2*8+8];
b.s1=input[get_global_id(0)*2*8+9];
c.s1=input[get_global_id(0)*2*8+10];
d.s1=input[get_global_id(0)*2*8+11];
e.s1=input[get_global_id(0)*2*8+12];
f.s1=input[get_global_id(0)*2*8+13];
g.s1=input[get_global_id(0)*2*8+14];
h.s1=input[get_global_id(0)*2*8+15];

sz.s0=size[get_global_id(0)*2]<<3;
sz.s1=size[get_global_id(0)*2+1]<<3;

// Calculate sha1(ipad^key)
w0=a;
w1=b;
w2=c;
w3=d;
w4=e;
w5=f;
w6=g;
w7=h;

w8=w9=w10=w11=w12=w13=w14=0;
SIZE=sz;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P0(A, B, C, D, E, F, G, H, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

a=A+H0;b=B+H1;c=C+H2;d=D+H3;e=E+H4;f=F+H5;g=G+H6;h=H+H7;



// Calculate sha1(ipad^key)
w0=a^(uint2)0x36363636;
w1=b^(uint2)0x36363636;
w2=c^(uint2)0x36363636;
w3=d^(uint2)0x36363636;
w4=e^(uint2)0x36363636;
w5=f^(uint2)0x36363636;
w6=g^(uint2)0x36363636;
w7=h^(uint2)0x36363636;

w7=w8=w9=w10=w11=w12=w13=w14=SIZE=(uint2)0x36363636;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);


IPA=A+H0;IPB=B+H1;IPC=C+H2;IPD=D+H3;IPE=E+H4;IPF=F+H5;IPG=G+H6;IPH=H+H7;



// Calculate sha1(opad^key)
w0=a^(uint2)0x5c5c5c5c;
w1=b^(uint2)0x5c5c5c5c;
w2=c^(uint2)0x5c5c5c5c;
w3=d^(uint2)0x5c5c5c5c;
w4=e^(uint2)0x5c5c5c5c;
w5=f^(uint2)0x5c5c5c5c;
w6=g^(uint2)0x5c5c5c5c;
w7=h^(uint2)0x5c5c5c5c;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint2)0x5c5c5c5c;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

OPA=A+H0;OPB=B+H1;OPC=C+H2;OPD=D+H3;OPE=E+H4;OPF=F+H5;OPG=G+H6;OPH=H+H7;




// calculate hash sum 1
A=IPA;
B=IPB;
C=IPC;
D=IPD;
E=IPE;
F=IPF;
G=IPG;
H=IPH;

w0=(uint2)salt.s0;
w1=(uint2)salt.s1;
w2=(uint2)salt.s2;
w3=(uint2)salt.s3;
w4=(uint2)salt.s4;
w5=0x80000000;
SIZE=(uint2)salt.sF;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint2)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;F=F+IPF;G=G+IPG;H=H+IPH;





// calculate hash sum 2

w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint2)0x80000000;
A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;
SIZE=(uint2)((64+20)<<3);
w9=w10=w11=w12=w13=w14=(uint2)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+OPA;B=B+OPB;C=C+OPC;D=D+OPD;E=E+OPE;F=F+OPF;G=G+OPG;H=H+OPH;
TTA=A;TTB=B;TTC=C;TTD=D;TTE=E;TTF=F;TTG=G;TTH=H;


dst[get_global_id(0)*64+0]=IPA.s0;
dst[get_global_id(0)*64+1]=IPB.s0;
dst[get_global_id(0)*64+2]=IPC.s0;
dst[get_global_id(0)*64+3]=IPD.s0;
dst[get_global_id(0)*64+4]=IPE.s0;
dst[get_global_id(0)*64+5]=IPF.s0;
dst[get_global_id(0)*64+6]=IPG.s0;
dst[get_global_id(0)*64+7]=IPH.s0;
dst[get_global_id(0)*64+8]=OPA.s0;
dst[get_global_id(0)*64+9]=OPB.s0;
dst[get_global_id(0)*64+10]=OPC.s0;
dst[get_global_id(0)*64+11]=OPD.s0;
dst[get_global_id(0)*64+12]=OPE.s0;
dst[get_global_id(0)*64+13]=OPF.s0;
dst[get_global_id(0)*64+14]=OPG.s0;
dst[get_global_id(0)*64+15]=OPH.s0;
dst[get_global_id(0)*64+16]=TTA.s0;
dst[get_global_id(0)*64+17]=TTB.s0;
dst[get_global_id(0)*64+18]=TTC.s0;
dst[get_global_id(0)*64+19]=TTD.s0;
dst[get_global_id(0)*64+20]=TTE.s0;
dst[get_global_id(0)*64+21]=TTF.s0;
dst[get_global_id(0)*64+22]=TTG.s0;
dst[get_global_id(0)*64+23]=TTH.s0;
dst[get_global_id(0)*64+24]=TTA.s0;
dst[get_global_id(0)*64+25]=TTB.s0;
dst[get_global_id(0)*64+26]=TTC.s0;
dst[get_global_id(0)*64+27]=TTD.s0;
dst[get_global_id(0)*64+28]=TTE.s0;
dst[get_global_id(0)*64+29]=TTF.s0;
dst[get_global_id(0)*64+30]=TTG.s0;
dst[get_global_id(0)*64+31]=TTH.s0;

dst[get_global_id(0)*64+32]=IPA.s1;
dst[get_global_id(0)*64+33]=IPB.s1;
dst[get_global_id(0)*64+34]=IPC.s1;
dst[get_global_id(0)*64+35]=IPD.s1;
dst[get_global_id(0)*64+36]=IPE.s1;
dst[get_global_id(0)*64+37]=IPF.s1;
dst[get_global_id(0)*64+38]=IPG.s1;
dst[get_global_id(0)*64+39]=IPH.s1;
dst[get_global_id(0)*64+40]=OPA.s1;
dst[get_global_id(0)*64+41]=OPB.s1;
dst[get_global_id(0)*64+42]=OPC.s1;
dst[get_global_id(0)*64+43]=OPD.s1;
dst[get_global_id(0)*64+44]=OPE.s1;
dst[get_global_id(0)*64+45]=OPF.s1;
dst[get_global_id(0)*64+46]=OPG.s1;
dst[get_global_id(0)*64+47]=OPH.s1;
dst[get_global_id(0)*64+48]=TTA.s1;
dst[get_global_id(0)*64+49]=TTB.s1;
dst[get_global_id(0)*64+50]=TTC.s1;
dst[get_global_id(0)*64+51]=TTD.s1;
dst[get_global_id(0)*64+52]=TTE.s1;
dst[get_global_id(0)*64+53]=TTF.s1;
dst[get_global_id(0)*64+54]=TTG.s1;
dst[get_global_id(0)*64+55]=TTH.s1;
dst[get_global_id(0)*64+56]=TTA.s1;
dst[get_global_id(0)*64+57]=TTB.s1;
dst[get_global_id(0)*64+58]=TTC.s1;
dst[get_global_id(0)*64+59]=TTD.s1;
dst[get_global_id(0)*64+60]=TTE.s1;
dst[get_global_id(0)*64+61]=TTF.s1;
dst[get_global_id(0)*64+62]=TTG.s1;
dst[get_global_id(0)*64+63]=TTH.s1;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint2 SIZE;  
uint ib,ic,id;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint2 A,B,C,D,E,F,G,H;
uint2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


IPA.s0=input[get_global_id(0)*64+0];
IPB.s0=input[get_global_id(0)*64+1];
IPC.s0=input[get_global_id(0)*64+2];
IPD.s0=input[get_global_id(0)*64+3];
IPE.s0=input[get_global_id(0)*64+4];
IPF.s0=input[get_global_id(0)*64+5];
IPG.s0=input[get_global_id(0)*64+6];
IPH.s0=input[get_global_id(0)*64+7];
OPA.s0=input[get_global_id(0)*64+8];
OPB.s0=input[get_global_id(0)*64+9];
OPC.s0=input[get_global_id(0)*64+10];
OPD.s0=input[get_global_id(0)*64+11];
OPE.s0=input[get_global_id(0)*64+12];
OPF.s0=input[get_global_id(0)*64+13];
OPG.s0=input[get_global_id(0)*64+14];
OPH.s0=input[get_global_id(0)*64+15];
A.s0=input[get_global_id(0)*64+16];
B.s0=input[get_global_id(0)*64+17];
C.s0=input[get_global_id(0)*64+18];
D.s0=input[get_global_id(0)*64+19];
E.s0=input[get_global_id(0)*64+20];
F.s0=input[get_global_id(0)*64+21];
G.s0=input[get_global_id(0)*64+22];
H.s0=input[get_global_id(0)*64+23];
TTA.s0=input[get_global_id(0)*64+24];
TTB.s0=input[get_global_id(0)*64+25];
TTC.s0=input[get_global_id(0)*64+26];
TTD.s0=input[get_global_id(0)*64+27];
TTE.s0=input[get_global_id(0)*64+28];
TTF.s0=input[get_global_id(0)*64+29];
TTG.s0=input[get_global_id(0)*64+30];
TTH.s0=input[get_global_id(0)*64+31];
IPA.s1=input[get_global_id(0)*64+32];
IPB.s1=input[get_global_id(0)*64+33];
IPC.s1=input[get_global_id(0)*64+34];
IPD.s1=input[get_global_id(0)*64+35];
IPE.s1=input[get_global_id(0)*64+36];
IPF.s1=input[get_global_id(0)*64+37];
IPG.s1=input[get_global_id(0)*64+38];
IPH.s1=input[get_global_id(0)*64+39];
OPA.s1=input[get_global_id(0)*64+40];
OPB.s1=input[get_global_id(0)*64+41];
OPC.s1=input[get_global_id(0)*64+42];
OPD.s1=input[get_global_id(0)*64+43];
OPE.s1=input[get_global_id(0)*64+44];
OPF.s1=input[get_global_id(0)*64+45];
OPG.s1=input[get_global_id(0)*64+46];
OPH.s1=input[get_global_id(0)*64+47];
A.s1=input[get_global_id(0)*64+48];
B.s1=input[get_global_id(0)*64+49];
C.s1=input[get_global_id(0)*64+50];
D.s1=input[get_global_id(0)*64+51];
E.s1=input[get_global_id(0)*64+52];
F.s1=input[get_global_id(0)*64+53];
G.s1=input[get_global_id(0)*64+54];
H.s1=input[get_global_id(0)*64+55];
TTA.s1=input[get_global_id(0)*64+56];
TTB.s1=input[get_global_id(0)*64+57];
TTC.s1=input[get_global_id(0)*64+58];
TTD.s1=input[get_global_id(0)*64+59];
TTE.s1=input[get_global_id(0)*64+60];
TTF.s1=input[get_global_id(0)*64+61];
TTG.s1=input[get_global_id(0)*64+62];
TTH.s1=input[get_global_id(0)*64+63];


// We now have the first HMAC. Iterate to find the rest
for (ic=salt.sA;ic<salt.sB;ic++)
{
// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint2)0x80000000;
SIZE=(uint2)(64+20)<<3;
A=IPA;
B=IPB;
C=IPC;
D=IPD;
E=IPE;
F=IPF;
G=IPG;
H=IPH;

w9=w10=w11=w12=w13=w14=(uint2)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;F=F+OPF;G=G+OPG;H+OPH;

// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint2)0x80000000;
A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;

SIZE=(uint2)(64+20)<<3;
w9=w10=w11=w12=w13=w14=w16=(uint2)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+OPA;B=B+OPB;C=C+OPC;D=D+OPD;E=E+OPE;F=F+OPF;G=G+OPG;H=H+OPH;
TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF=TTF^F;TTG=TTG^G;TTH=TTH^H;
}

dst[get_global_id(0)*64+16]=A.s0;
dst[get_global_id(0)*64+17]=B.s0;
dst[get_global_id(0)*64+18]=C.s0;
dst[get_global_id(0)*64+19]=D.s0;
dst[get_global_id(0)*64+20]=E.s0;
dst[get_global_id(0)*64+21]=F.s0;
dst[get_global_id(0)*64+22]=G.s0;
dst[get_global_id(0)*64+23]=H.s0;
dst[get_global_id(0)*64+24]=TTA.s0;
dst[get_global_id(0)*64+25]=TTB.s0;
dst[get_global_id(0)*64+26]=TTC.s0;
dst[get_global_id(0)*64+27]=TTD.s0;
dst[get_global_id(0)*64+28]=TTE.s0;
dst[get_global_id(0)*64+29]=TTF.s0;
dst[get_global_id(0)*64+30]=TTG.s0;
dst[get_global_id(0)*64+31]=TTH.s0;

dst[get_global_id(0)*64+48]=A.s1;
dst[get_global_id(0)*64+49]=B.s1;
dst[get_global_id(0)*64+50]=C.s1;
dst[get_global_id(0)*64+51]=D.s1;
dst[get_global_id(0)*64+52]=E.s1;
dst[get_global_id(0)*64+53]=F.s1;
dst[get_global_id(0)*64+54]=G.s1;
dst[get_global_id(0)*64+55]=H.s1;
dst[get_global_id(0)*64+56]=TTA.s1;
dst[get_global_id(0)*64+57]=TTB.s1;
dst[get_global_id(0)*64+58]=TTC.s1;
dst[get_global_id(0)*64+59]=TTD.s1;
dst[get_global_id(0)*64+60]=TTE.s1;
dst[get_global_id(0)*64+61]=TTF.s1;
dst[get_global_id(0)*64+62]=TTG.s1;
dst[get_global_id(0)*64+63]=TTH.s1;

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH,l,tmp1,tmp2;

TTA.s0=input[get_global_id(0)*64+24];
TTB.s0=input[get_global_id(0)*64+25];
TTC.s0=input[get_global_id(0)*64+26];
TTD.s0=input[get_global_id(0)*64+27];
TTE.s0=input[get_global_id(0)*64+28];
TTF.s0=input[get_global_id(0)*64+29];
TTG.s0=input[get_global_id(0)*64+30];
TTH.s0=input[get_global_id(0)*64+31];

TTA.s1=input[get_global_id(0)*64+56];
TTB.s1=input[get_global_id(0)*64+57];
TTC.s1=input[get_global_id(0)*64+58];
TTD.s1=input[get_global_id(0)*64+59];
TTE.s1=input[get_global_id(0)*64+60];
TTF.s1=input[get_global_id(0)*64+61];
TTG.s1=input[get_global_id(0)*64+62];
TTH.s1=input[get_global_id(0)*64+63];


Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);


dst[(get_global_id(0)*4)] = (uint4)(TTA.s0,TTB.s0,TTC.s0,TTD.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(TTE.s0,TTF.s0,TTG.s0,TTH.s0);
dst[(get_global_id(0)*4)+2] = (uint4)(TTA.s1,TTB.s1,TTC.s1,TTD.s1);
dst[(get_global_id(0)*4)+3] = (uint4)(TTE.s1,TTF.s1,TTG.s1,TTH.s1);
}



#else

__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint SIZE,sz;  
uint ib,ic,id;  
uint a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint yl,yr,zl,zr,wl,wr;
uint A,B,C,D,E,F,G,H;
uint IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint TA,TB,TC,TD,TE;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(uint)0;


a=input[get_global_id(0)*8];
b=input[get_global_id(0)*8+1];
c=input[get_global_id(0)*8+2];
d=input[get_global_id(0)*8+3];
e=input[get_global_id(0)*8+4];
f=input[get_global_id(0)*8+5];
g=input[get_global_id(0)*8+6];
h=input[get_global_id(0)*8+7];


sz=size[get_global_id(0)]<<3;

// Calculate sha1(ipad^key)
w0=a;
w1=b;
w2=c;
w3=d;
w4=e;
w5=f;
w6=g;
w7=h;

w8=w9=w10=w11=w12=w13=w14=0;
SIZE=sz;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P0(A, B, C, D, E, F, G, H, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

a=A+H0;b=B+H1;c=C+H2;d=D+H3;e=E+H4;f=F+H5;g=G+H6;h=H+H7;



// Calculate sha1(ipad^key)
w0=a^(uint)0x36363636;
w1=b^(uint)0x36363636;
w2=c^(uint)0x36363636;
w3=d^(uint)0x36363636;
w4=e^(uint)0x36363636;
w5=f^(uint)0x36363636;
w6=g^(uint)0x36363636;
w7=h^(uint)0x36363636;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x36363636;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);


IPA=A+H0;IPB=B+H1;IPC=C+H2;IPD=D+H3;IPE=E+H4;IPF=F+H5;IPG=G+H6;IPH=H+H7;



// Calculate sha1(opad^key)
w0=a^(uint)0x5c5c5c5c;
w1=b^(uint)0x5c5c5c5c;
w2=c^(uint)0x5c5c5c5c;
w3=d^(uint)0x5c5c5c5c;
w4=e^(uint)0x5c5c5c5c;
w5=f^(uint)0x5c5c5c5c;
w6=g^(uint)0x5c5c5c5c;
w7=h^(uint)0x5c5c5c5c;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x5c5c5c5c;

A=H0;
B=H1;
C=H2;
D=H3;
E=H4;
F=H5;
G=H6;
H=H7;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

OPA=A+H0;OPB=B+H1;OPC=C+H2;OPD=D+H3;OPE=E+H4;OPF=F+H5;OPG=G+H6;OPH=H+H7;




// calculate hash sum 1
A=IPA;
B=IPB;
C=IPC;
D=IPD;
E=IPE;
F=IPF;
G=IPG;
H=IPH;

w0=(uint)salt.s0;
w1=(uint)salt.s1;
w2=(uint)salt.s2;
w3=(uint)salt.s3;
w4=(uint)salt.s4;
w5=0x80000000;
SIZE=(uint)salt.sF;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;F=F+IPF;G=G+IPG;H=H+IPH;





// calculate hash sum 2

w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint)0x80000000;
A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;
SIZE=(uint)((64+20)<<3);
w9=w10=w11=w12=w13=w14=(uint)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+OPA;B=B+OPB;C=C+OPC;D=D+OPD;E=E+OPE;F=F+OPF;G=G+OPG;H=H+OPH;
TTA=A;TTB=B;TTC=C;TTD=D;TTE=E;TTF=F;TTG=G;TTH=H;


dst[get_global_id(0)*32+0]=IPA;
dst[get_global_id(0)*32+1]=IPB;
dst[get_global_id(0)*32+2]=IPC;
dst[get_global_id(0)*32+3]=IPD;
dst[get_global_id(0)*32+4]=IPE;
dst[get_global_id(0)*32+5]=IPF;
dst[get_global_id(0)*32+6]=IPG;
dst[get_global_id(0)*32+7]=IPH;
dst[get_global_id(0)*32+8]=OPA;
dst[get_global_id(0)*32+9]=OPB;
dst[get_global_id(0)*32+10]=OPC;
dst[get_global_id(0)*32+11]=OPD;
dst[get_global_id(0)*32+12]=OPE;
dst[get_global_id(0)*32+13]=OPF;
dst[get_global_id(0)*32+14]=OPG;
dst[get_global_id(0)*32+15]=OPH;
dst[get_global_id(0)*32+16]=TTA;
dst[get_global_id(0)*32+17]=TTB;
dst[get_global_id(0)*32+18]=TTC;
dst[get_global_id(0)*32+19]=TTD;
dst[get_global_id(0)*32+20]=TTE;
dst[get_global_id(0)*32+21]=TTF;
dst[get_global_id(0)*32+22]=TTG;
dst[get_global_id(0)*32+23]=TTH;
dst[get_global_id(0)*32+24]=TTA;
dst[get_global_id(0)*32+25]=TTB;
dst[get_global_id(0)*32+26]=TTC;
dst[get_global_id(0)*32+27]=TTD;
dst[get_global_id(0)*32+28]=TTE;
dst[get_global_id(0)*32+29]=TTF;
dst[get_global_id(0)*32+30]=TTG;
dst[get_global_id(0)*32+31]=TTH;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint SIZE;  
uint ib,ic,id;  
uint a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint A,B,C,D,E,F,G,H;
uint IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


IPA=input[get_global_id(0)*32+0];
IPB=input[get_global_id(0)*32+1];
IPC=input[get_global_id(0)*32+2];
IPD=input[get_global_id(0)*32+3];
IPE=input[get_global_id(0)*32+4];
IPF=input[get_global_id(0)*32+5];
IPG=input[get_global_id(0)*32+6];
IPH=input[get_global_id(0)*32+7];
OPA=input[get_global_id(0)*32+8];
OPB=input[get_global_id(0)*32+9];
OPC=input[get_global_id(0)*32+10];
OPD=input[get_global_id(0)*32+11];
OPE=input[get_global_id(0)*32+12];
OPF=input[get_global_id(0)*32+13];
OPG=input[get_global_id(0)*32+14];
OPH=input[get_global_id(0)*32+15];
A=input[get_global_id(0)*32+16];
B=input[get_global_id(0)*32+17];
C=input[get_global_id(0)*32+18];
D=input[get_global_id(0)*32+19];
E=input[get_global_id(0)*32+20];
F=input[get_global_id(0)*32+21];
G=input[get_global_id(0)*32+22];
H=input[get_global_id(0)*32+23];
TTA=input[get_global_id(0)*32+24];
TTB=input[get_global_id(0)*32+25];
TTC=input[get_global_id(0)*32+26];
TTD=input[get_global_id(0)*32+27];
TTE=input[get_global_id(0)*32+28];
TTF=input[get_global_id(0)*32+29];
TTG=input[get_global_id(0)*32+30];
TTH=input[get_global_id(0)*32+31];


// We now have the first HMAC. Iterate to find the rest
for (ic=salt.sA;ic<salt.sB;ic++)
{
// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint)0x80000000;
SIZE=(uint)(64+20)<<3;
A=IPA;
B=IPB;
C=IPC;
D=IPD;
E=IPE;
F=IPF;
G=IPG;
H=IPH;

w9=w10=w11=w12=w13=w14=(uint)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;F=F+OPF;G=G+OPG;H+OPH;

// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(uint)0x80000000;
A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;

SIZE=(uint)(64+20)<<3;
w9=w10=w11=w12=w13=w14=w16=(uint)0;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+OPA;B=B+OPB;C=C+OPC;D=D+OPD;E=E+OPE;F=F+OPF;G=G+OPG;H=H+OPH;
TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF=TTF^F;TTG=TTG^G;TTH=TTH^H;
}

dst[get_global_id(0)*32+16]=A;
dst[get_global_id(0)*32+17]=B;
dst[get_global_id(0)*32+18]=C;
dst[get_global_id(0)*32+19]=D;
dst[get_global_id(0)*32+20]=E;
dst[get_global_id(0)*32+21]=F;
dst[get_global_id(0)*32+22]=G;
dst[get_global_id(0)*32+23]=H;
dst[get_global_id(0)*32+24]=TTA;
dst[get_global_id(0)*32+25]=TTB;
dst[get_global_id(0)*32+26]=TTC;
dst[get_global_id(0)*32+27]=TTD;
dst[get_global_id(0)*32+28]=TTE;
dst[get_global_id(0)*32+29]=TTF;
dst[get_global_id(0)*32+30]=TTG;
dst[get_global_id(0)*32+31]=TTH;

}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,uint16 str)
{
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH,l,tmp1,tmp2;

TTA=input[get_global_id(0)*32+24];
TTB=input[get_global_id(0)*32+25];
TTC=input[get_global_id(0)*32+26];
TTD=input[get_global_id(0)*32+27];
TTE=input[get_global_id(0)*32+28];
TTF=input[get_global_id(0)*32+29];
TTG=input[get_global_id(0)*32+30];
TTH=input[get_global_id(0)*32+31];

Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);


dst[(get_global_id(0)*2)] = (uint4)(TTA,TTB,TTC,TTD);
dst[(get_global_id(0)*2)+1] = (uint4)(TTE,TTF,TTG,TTH);
}



#endif