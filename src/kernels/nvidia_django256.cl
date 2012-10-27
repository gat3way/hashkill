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

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

//SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}




#define H0 0x6A09E667
#define H1 0xBB67AE85
#define H2 0x3C6EF372
#define H3 0xA54FF53A
#define H4 0x510E527F
#define H5 0x9B05688C
#define H6 0x1F83D9AB
#define H7 0x5BE0CD19

#define Sl 8U
#define Sr 24U
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))


#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}



#ifdef SM21

__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint2 a1,b1,c1,d1,e1,f1,g1,h1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint2 A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint2 m = 0x00FF00FF;
uint2 m2 = 0xFF00FF00;
uint2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(uint2)0;

a1.s0=input[get_global_id(0)*2*8];
b1.s0=input[get_global_id(0)*2*8+1];
c1.s0=input[get_global_id(0)*2*8+2];
d1.s0=input[get_global_id(0)*2*8+3];
e1.s0=input[get_global_id(0)*2*8+4];
f1.s0=input[get_global_id(0)*2*8+5];
g1.s0=input[get_global_id(0)*2*8+6];
h1.s0=input[get_global_id(0)*2*8+7];

a1.s1=input[get_global_id(0)*2*8+8];
b1.s1=input[get_global_id(0)*2*8+9];
c1.s1=input[get_global_id(0)*2*8+10];
d1.s1=input[get_global_id(0)*2*8+11];
e1.s1=input[get_global_id(0)*2*8+12];
f1.s1=input[get_global_id(0)*2*8+13];
g1.s1=input[get_global_id(0)*2*8+14];
h1.s1=input[get_global_id(0)*2*8+15];



// Calculate sha1(ipad^key)
w0=a1^(uint2)0x36363636;
w1=b1^(uint2)0x36363636;
w2=c1^(uint2)0x36363636;
w3=d1^(uint2)0x36363636;
w4=e1^(uint2)0x36363636;
w5=f1^(uint2)0x36363636;
w6=g1^(uint2)0x36363636;
w7=h1^(uint2)0x36363636;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint2)0x36363636;


A=(uint2)H0;
B=(uint2)H1;
C=(uint2)H2;
D=(uint2)H3;
E=(uint2)H4;
F=(uint2)H5;
G=(uint2)H6;
H=(uint2)H7;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
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
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

IPA=A+(uint2)H0;
IPB=B+(uint2)H1;
IPC=C+(uint2)H2;
IPD=D+(uint2)H3;
IPE=E+(uint2)H4;
IPF=F+(uint2)H5;
IPG=G+(uint2)H6;
IPH=H+(uint2)H7;



// Calculate sha1(opad^key)
w0=a1^(uint2)0x5c5c5c5c;
w1=b1^(uint2)0x5c5c5c5c;
w2=c1^(uint2)0x5c5c5c5c;
w3=d1^(uint2)0x5c5c5c5c;
w4=e1^(uint2)0x5c5c5c5c;
w5=f1^(uint2)0x5c5c5c5c;
w6=g1^(uint2)0x5c5c5c5c;
w7=h1^(uint2)0x5c5c5c5c;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint2)0x5c5c5c5c;

A=(uint2)H0;
B=(uint2)H1;
C=(uint2)H2;
D=(uint2)H3;
E=(uint2)H4;
F=(uint2)H5;
G=(uint2)H6;
H=(uint2)H7;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
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
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

OPA=A+(uint2)H0;
OPB=B+(uint2)H1;
OPC=C+(uint2)H2;
OPD=D+(uint2)H3;
OPE=E+(uint2)H4;
OPF=F+(uint2)H5;
OPG=G+(uint2)H6;
OPH=H+(uint2)H7;




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
w4=(uint2)0x80000000;

SIZE=(uint2)(12+64+4)<<3;
w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint2)0;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P0(D, E, F, G, H, A, B, C, 0x59F111F1);
P0(C, D, E, F, G, H, A, B, 0x923F82A4);
P0(B, C, D, E, F, G, H, A, 0xAB1C5ED5);
P0(A, B, C, D, E, F, G, H, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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
SIZE=(uint2)((64+32)<<3);
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

dst[(get_global_id(0)*32*2)+0]=A.s0;
dst[(get_global_id(0)*32*2)+1]=B.s0;
dst[(get_global_id(0)*32*2)+2]=C.s0;
dst[(get_global_id(0)*32*2)+3]=D.s0;
dst[(get_global_id(0)*32*2)+4]=E.s0;
dst[(get_global_id(0)*32*2)+5]=F.s0;
dst[(get_global_id(0)*32*2)+6]=G.s0;
dst[(get_global_id(0)*32*2)+7]=H.s0;
dst[(get_global_id(0)*32*2)+8]=IPA.s0;
dst[(get_global_id(0)*32*2)+9]=IPB.s0;
dst[(get_global_id(0)*32*2)+10]=IPC.s0;
dst[(get_global_id(0)*32*2)+11]=IPD.s0;
dst[(get_global_id(0)*32*2)+12]=IPE.s0;
dst[(get_global_id(0)*32*2)+13]=IPF.s0;
dst[(get_global_id(0)*32*2)+14]=IPG.s0;
dst[(get_global_id(0)*32*2)+15]=IPH.s0;
dst[(get_global_id(0)*32*2)+16]=OPA.s0;
dst[(get_global_id(0)*32*2)+17]=OPB.s0;
dst[(get_global_id(0)*32*2)+18]=OPC.s0;
dst[(get_global_id(0)*32*2)+19]=OPD.s0;
dst[(get_global_id(0)*32*2)+20]=OPE.s0;
dst[(get_global_id(0)*32*2)+21]=OPF.s0;
dst[(get_global_id(0)*32*2)+22]=OPG.s0;
dst[(get_global_id(0)*32*2)+23]=OPH.s0;
dst[(get_global_id(0)*32*2)+24]=TTA.s0;
dst[(get_global_id(0)*32*2)+25]=TTB.s0;
dst[(get_global_id(0)*32*2)+26]=TTC.s0;
dst[(get_global_id(0)*32*2)+27]=TTD.s0;
dst[(get_global_id(0)*32*2)+28]=TTE.s0;
dst[(get_global_id(0)*32*2)+29]=TTF.s0;
dst[(get_global_id(0)*32*2)+30]=TTG.s0;
dst[(get_global_id(0)*32*2)+31]=TTH.s0;
dst[(get_global_id(0)*32*2)+32]=A.s1;
dst[(get_global_id(0)*32*2)+33]=B.s1;
dst[(get_global_id(0)*32*2)+34]=C.s1;
dst[(get_global_id(0)*32*2)+35]=D.s1;
dst[(get_global_id(0)*32*2)+36]=E.s1;
dst[(get_global_id(0)*32*2)+37]=F.s1;
dst[(get_global_id(0)*32*2)+38]=G.s1;
dst[(get_global_id(0)*32*2)+39]=H.s1;
dst[(get_global_id(0)*32*2)+40]=IPA.s1;
dst[(get_global_id(0)*32*2)+41]=IPB.s1;
dst[(get_global_id(0)*32*2)+42]=IPC.s1;
dst[(get_global_id(0)*32*2)+43]=IPD.s1;
dst[(get_global_id(0)*32*2)+44]=IPE.s1;
dst[(get_global_id(0)*32*2)+45]=IPF.s1;
dst[(get_global_id(0)*32*2)+46]=IPG.s1;
dst[(get_global_id(0)*32*2)+47]=IPH.s1;
dst[(get_global_id(0)*32*2)+48]=OPA.s1;
dst[(get_global_id(0)*32*2)+49]=OPB.s1;
dst[(get_global_id(0)*32*2)+50]=OPC.s1;
dst[(get_global_id(0)*32*2)+51]=OPD.s1;
dst[(get_global_id(0)*32*2)+52]=OPE.s1;
dst[(get_global_id(0)*32*2)+53]=OPF.s1;
dst[(get_global_id(0)*32*2)+54]=OPG.s1;
dst[(get_global_id(0)*32*2)+55]=OPH.s1;
dst[(get_global_id(0)*32*2)+56]=TTA.s1;
dst[(get_global_id(0)*32*2)+57]=TTB.s1;
dst[(get_global_id(0)*32*2)+58]=TTC.s1;
dst[(get_global_id(0)*32*2)+59]=TTD.s1;
dst[(get_global_id(0)*32*2)+60]=TTE.s1;
dst[(get_global_id(0)*32*2)+61]=TTF.s1;
dst[(get_global_id(0)*32*2)+62]=TTG.s1;
dst[(get_global_id(0)*32*2)+63]=TTH.s1;


}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint2 a1,b1,c1,d1,e1,f1,g1,h1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint2 A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint2 m = 0x00FF00FF;
uint2 m2 = 0xFF00FF00;
uint2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


A.s0=dst[(get_global_id(0)*32*2)+0];
B.s0=dst[(get_global_id(0)*32*2)+1];
C.s0=dst[(get_global_id(0)*32*2)+2];
D.s0=dst[(get_global_id(0)*32*2)+3];
E.s0=dst[(get_global_id(0)*32*2)+4];
F.s0=dst[(get_global_id(0)*32*2)+5];
G.s0=dst[(get_global_id(0)*32*2)+6];
H.s0=dst[(get_global_id(0)*32*2)+7];
IPA.s0=dst[(get_global_id(0)*32*2)+8];
IPB.s0=dst[(get_global_id(0)*32*2)+9];
IPC.s0=dst[(get_global_id(0)*32*2)+10];
IPD.s0=dst[(get_global_id(0)*32*2)+11];
IPE.s0=dst[(get_global_id(0)*32*2)+12];
IPF.s0=dst[(get_global_id(0)*32*2)+13];
IPG.s0=dst[(get_global_id(0)*32*2)+14];
IPH.s0=dst[(get_global_id(0)*32*2)+15];
OPA.s0=dst[(get_global_id(0)*32*2)+16];
OPB.s0=dst[(get_global_id(0)*32*2)+17];
OPC.s0=dst[(get_global_id(0)*32*2)+18];
OPD.s0=dst[(get_global_id(0)*32*2)+19];
OPE.s0=dst[(get_global_id(0)*32*2)+20];
OPF.s0=dst[(get_global_id(0)*32*2)+21];
OPG.s0=dst[(get_global_id(0)*32*2)+22];
OPH.s0=dst[(get_global_id(0)*32*2)+23];
TTA.s0=dst[(get_global_id(0)*32*2)+24];
TTB.s0=dst[(get_global_id(0)*32*2)+25];
TTC.s0=dst[(get_global_id(0)*32*2)+26];
TTD.s0=dst[(get_global_id(0)*32*2)+27];
TTE.s0=dst[(get_global_id(0)*32*2)+28];
TTF.s0=dst[(get_global_id(0)*32*2)+29];
TTG.s0=dst[(get_global_id(0)*32*2)+30];
TTH.s0=dst[(get_global_id(0)*32*2)+31];
A.s1=dst[(get_global_id(0)*32*2)+32];
B.s1=dst[(get_global_id(0)*32*2)+33];
C.s1=dst[(get_global_id(0)*32*2)+34];
D.s1=dst[(get_global_id(0)*32*2)+35];
E.s1=dst[(get_global_id(0)*32*2)+36];
F.s1=dst[(get_global_id(0)*32*2)+37];
G.s1=dst[(get_global_id(0)*32*2)+38];
H.s1=dst[(get_global_id(0)*32*2)+39];
IPA.s1=dst[(get_global_id(0)*32*2)+40];
IPB.s1=dst[(get_global_id(0)*32*2)+41];
IPC.s1=dst[(get_global_id(0)*32*2)+42];
IPD.s1=dst[(get_global_id(0)*32*2)+43];
IPE.s1=dst[(get_global_id(0)*32*2)+44];
IPF.s1=dst[(get_global_id(0)*32*2)+45];
IPG.s1=dst[(get_global_id(0)*32*2)+46];
IPH.s1=dst[(get_global_id(0)*32*2)+47];
OPA.s1=dst[(get_global_id(0)*32*2)+48];
OPB.s1=dst[(get_global_id(0)*32*2)+49];
OPC.s1=dst[(get_global_id(0)*32*2)+50];
OPD.s1=dst[(get_global_id(0)*32*2)+51];
OPE.s1=dst[(get_global_id(0)*32*2)+52];
OPF.s1=dst[(get_global_id(0)*32*2)+53];
OPG.s1=dst[(get_global_id(0)*32*2)+54];
OPH.s1=dst[(get_global_id(0)*32*2)+55];
TTA.s1=dst[(get_global_id(0)*32*2)+56];
TTB.s1=dst[(get_global_id(0)*32*2)+57];
TTC.s1=dst[(get_global_id(0)*32*2)+58];
TTD.s1=dst[(get_global_id(0)*32*2)+59];
TTE.s1=dst[(get_global_id(0)*32*2)+60];
TTF.s1=dst[(get_global_id(0)*32*2)+61];
TTG.s1=dst[(get_global_id(0)*32*2)+62];
TTH.s1=dst[(get_global_id(0)*32*2)+63];

// We now have the first HMAC. Iterate to find the rest
for (ic=0;ic<1000;ic++)
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
SIZE=(uint2)(64+32)<<3;
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
P(A, B, C, D, E, F, G, H,w8, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

SIZE=(uint2)(64+32)<<3;
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF^=F;TTG^=G;TTH^=H;
}

dst[(get_global_id(0)*32*2)+0]=A.s0;
dst[(get_global_id(0)*32*2)+1]=B.s0;
dst[(get_global_id(0)*32*2)+2]=C.s0;
dst[(get_global_id(0)*32*2)+3]=D.s0;
dst[(get_global_id(0)*32*2)+4]=E.s0;
dst[(get_global_id(0)*32*2)+5]=F.s0;
dst[(get_global_id(0)*32*2)+6]=G.s0;
dst[(get_global_id(0)*32*2)+7]=H.s0;
dst[(get_global_id(0)*32*2)+8]=IPA.s0;
dst[(get_global_id(0)*32*2)+9]=IPB.s0;
dst[(get_global_id(0)*32*2)+10]=IPC.s0;
dst[(get_global_id(0)*32*2)+11]=IPD.s0;
dst[(get_global_id(0)*32*2)+12]=IPE.s0;
dst[(get_global_id(0)*32*2)+13]=IPF.s0;
dst[(get_global_id(0)*32*2)+14]=IPG.s0;
dst[(get_global_id(0)*32*2)+15]=IPH.s0;
dst[(get_global_id(0)*32*2)+16]=OPA.s0;
dst[(get_global_id(0)*32*2)+17]=OPB.s0;
dst[(get_global_id(0)*32*2)+18]=OPC.s0;
dst[(get_global_id(0)*32*2)+19]=OPD.s0;
dst[(get_global_id(0)*32*2)+20]=OPE.s0;
dst[(get_global_id(0)*32*2)+21]=OPF.s0;
dst[(get_global_id(0)*32*2)+22]=OPG.s0;
dst[(get_global_id(0)*32*2)+23]=OPH.s0;
dst[(get_global_id(0)*32*2)+24]=TTA.s0;
dst[(get_global_id(0)*32*2)+25]=TTB.s0;
dst[(get_global_id(0)*32*2)+26]=TTC.s0;
dst[(get_global_id(0)*32*2)+27]=TTD.s0;
dst[(get_global_id(0)*32*2)+28]=TTE.s0;
dst[(get_global_id(0)*32*2)+29]=TTF.s0;
dst[(get_global_id(0)*32*2)+30]=TTG.s0;
dst[(get_global_id(0)*32*2)+31]=TTH.s0;
dst[(get_global_id(0)*32*2)+32]=A.s1;
dst[(get_global_id(0)*32*2)+33]=B.s1;
dst[(get_global_id(0)*32*2)+34]=C.s1;
dst[(get_global_id(0)*32*2)+35]=D.s1;
dst[(get_global_id(0)*32*2)+36]=E.s1;
dst[(get_global_id(0)*32*2)+37]=F.s1;
dst[(get_global_id(0)*32*2)+38]=G.s1;
dst[(get_global_id(0)*32*2)+39]=H.s1;
dst[(get_global_id(0)*32*2)+40]=IPA.s1;
dst[(get_global_id(0)*32*2)+41]=IPB.s1;
dst[(get_global_id(0)*32*2)+42]=IPC.s1;
dst[(get_global_id(0)*32*2)+43]=IPD.s1;
dst[(get_global_id(0)*32*2)+44]=IPE.s1;
dst[(get_global_id(0)*32*2)+45]=IPF.s1;
dst[(get_global_id(0)*32*2)+46]=IPG.s1;
dst[(get_global_id(0)*32*2)+47]=IPH.s1;
dst[(get_global_id(0)*32*2)+48]=OPA.s1;
dst[(get_global_id(0)*32*2)+49]=OPB.s1;
dst[(get_global_id(0)*32*2)+50]=OPC.s1;
dst[(get_global_id(0)*32*2)+51]=OPD.s1;
dst[(get_global_id(0)*32*2)+52]=OPE.s1;
dst[(get_global_id(0)*32*2)+53]=OPF.s1;
dst[(get_global_id(0)*32*2)+54]=OPG.s1;
dst[(get_global_id(0)*32*2)+55]=OPH.s1;
dst[(get_global_id(0)*32*2)+56]=TTA.s1;
dst[(get_global_id(0)*32*2)+57]=TTB.s1;
dst[(get_global_id(0)*32*2)+58]=TTC.s1;
dst[(get_global_id(0)*32*2)+59]=TTD.s1;
dst[(get_global_id(0)*32*2)+60]=TTE.s1;
dst[(get_global_id(0)*32*2)+61]=TTF.s1;
dst[(get_global_id(0)*32*2)+62]=TTG.s1;
dst[(get_global_id(0)*32*2)+63]=TTH.s1;

}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint2 a1,b1,c1,d1,e1,f1,g1,h1; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint2 A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint2 m = 0x00FF00FF;
uint2 m2 = 0xFF00FF00;
uint2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;



A.s0=input[(get_global_id(0)*32*2)+0];
B.s0=input[(get_global_id(0)*32*2)+1];
C.s0=input[(get_global_id(0)*32*2)+2];
D.s0=input[(get_global_id(0)*32*2)+3];
E.s0=input[(get_global_id(0)*32*2)+4];
F.s0=input[(get_global_id(0)*32*2)+5];
G.s0=input[(get_global_id(0)*32*2)+6];
H.s0=input[(get_global_id(0)*32*2)+7];
IPA.s0=input[(get_global_id(0)*32*2)+8];
IPB.s0=input[(get_global_id(0)*32*2)+9];
IPC.s0=input[(get_global_id(0)*32*2)+10];
IPD.s0=input[(get_global_id(0)*32*2)+11];
IPE.s0=input[(get_global_id(0)*32*2)+12];
IPF.s0=input[(get_global_id(0)*32*2)+13];
IPG.s0=input[(get_global_id(0)*32*2)+14];
IPH.s0=input[(get_global_id(0)*32*2)+15];
OPA.s0=input[(get_global_id(0)*32*2)+16];
OPB.s0=input[(get_global_id(0)*32*2)+17];
OPC.s0=input[(get_global_id(0)*32*2)+18];
OPD.s0=input[(get_global_id(0)*32*2)+19];
OPE.s0=input[(get_global_id(0)*32*2)+20];
OPF.s0=input[(get_global_id(0)*32*2)+21];
OPG.s0=input[(get_global_id(0)*32*2)+22];
OPH.s0=input[(get_global_id(0)*32*2)+23];
TTA.s0=input[(get_global_id(0)*32*2)+24];
TTB.s0=input[(get_global_id(0)*32*2)+25];
TTC.s0=input[(get_global_id(0)*32*2)+26];
TTD.s0=input[(get_global_id(0)*32*2)+27];
TTE.s0=input[(get_global_id(0)*32*2)+28];
TTF.s0=input[(get_global_id(0)*32*2)+29];
TTG.s0=input[(get_global_id(0)*32*2)+30];
TTH.s0=input[(get_global_id(0)*32*2)+31];
A.s1=input[(get_global_id(0)*32*2)+32];
B.s1=input[(get_global_id(0)*32*2)+33];
C.s1=input[(get_global_id(0)*32*2)+34];
D.s1=input[(get_global_id(0)*32*2)+35];
E.s1=input[(get_global_id(0)*32*2)+36];
F.s1=input[(get_global_id(0)*32*2)+37];
G.s1=input[(get_global_id(0)*32*2)+38];
H.s1=input[(get_global_id(0)*32*2)+39];
IPA.s1=input[(get_global_id(0)*32*2)+40];
IPB.s1=input[(get_global_id(0)*32*2)+41];
IPC.s1=input[(get_global_id(0)*32*2)+42];
IPD.s1=input[(get_global_id(0)*32*2)+43];
IPE.s1=input[(get_global_id(0)*32*2)+44];
IPF.s1=input[(get_global_id(0)*32*2)+45];
IPG.s1=input[(get_global_id(0)*32*2)+46];
IPH.s1=input[(get_global_id(0)*32*2)+47];
OPA.s1=input[(get_global_id(0)*32*2)+48];
OPB.s1=input[(get_global_id(0)*32*2)+49];
OPC.s1=input[(get_global_id(0)*32*2)+50];
OPD.s1=input[(get_global_id(0)*32*2)+51];
OPE.s1=input[(get_global_id(0)*32*2)+52];
OPF.s1=input[(get_global_id(0)*32*2)+53];
OPG.s1=input[(get_global_id(0)*32*2)+54];
OPH.s1=input[(get_global_id(0)*32*2)+55];
TTA.s1=input[(get_global_id(0)*32*2)+56];
TTB.s1=input[(get_global_id(0)*32*2)+57];
TTC.s1=input[(get_global_id(0)*32*2)+58];
TTD.s1=input[(get_global_id(0)*32*2)+59];
TTE.s1=input[(get_global_id(0)*32*2)+60];
TTF.s1=input[(get_global_id(0)*32*2)+61];
TTG.s1=input[(get_global_id(0)*32*2)+62];
TTH.s1=input[(get_global_id(0)*32*2)+63];

// We now have the first HMAC. Iterate to find the rest
for (ic=0;ic<salt.sA;ic++)
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
SIZE=(uint2)(64+32)<<3;
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
P(A, B, C, D, E, F, G, H,w8, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

SIZE=(uint2)(64+32)<<3;
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF^=F;TTG^=G;TTH^=H;
}

Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);

if (all(TTA!=(uint2)singlehash.s0)) return;
if (all(TTB!=(uint2)singlehash.s1)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*4)] = (uint4)(TTA.s0,TTB.s0,TTC.s0,TTD.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(TTE.s0,TTF.s0,TTG.s0,TTH.s0);
dst[(get_global_id(0)*4)+2] = (uint4)(TTA.s1,TTB.s1,TTC.s1,TTD.s1);
dst[(get_global_id(0)*4)+3] = (uint4)(TTE.s1,TTF.s1,TTG.s1,TTH.s1);

}


#else

__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint m = 0x00FF00FF;
uint m2 = 0xFF00FF00;
uint IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(uint)0;

a1=input[get_global_id(0)*8];
b1=input[get_global_id(0)*8+1];
c1=input[get_global_id(0)*8+2];
d1=input[get_global_id(0)*8+3];
e1=input[get_global_id(0)*8+4];
f1=input[get_global_id(0)*8+5];
g1=input[get_global_id(0)*8+6];
h1=input[get_global_id(0)*8+7];



// Calculate sha1(ipad^key)
w0=a1^(uint)0x36363636;
w1=b1^(uint)0x36363636;
w2=c1^(uint)0x36363636;
w3=d1^(uint)0x36363636;
w4=e1^(uint)0x36363636;
w5=f1^(uint)0x36363636;
w6=g1^(uint)0x36363636;
w7=h1^(uint)0x36363636;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x36363636;


A=(uint)H0;
B=(uint)H1;
C=(uint)H2;
D=(uint)H3;
E=(uint)H4;
F=(uint)H5;
G=(uint)H6;
H=(uint)H7;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
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
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

IPA=A+(uint)H0;
IPB=B+(uint)H1;
IPC=C+(uint)H2;
IPD=D+(uint)H3;
IPE=E+(uint)H4;
IPF=F+(uint)H5;
IPG=G+(uint)H6;
IPH=H+(uint)H7;



// Calculate sha1(opad^key)
w0=a1^(uint)0x5c5c5c5c;
w1=b1^(uint)0x5c5c5c5c;
w2=c1^(uint)0x5c5c5c5c;
w3=d1^(uint)0x5c5c5c5c;
w4=e1^(uint)0x5c5c5c5c;
w5=f1^(uint)0x5c5c5c5c;
w6=g1^(uint)0x5c5c5c5c;
w7=h1^(uint)0x5c5c5c5c;

w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x5c5c5c5c;

A=(uint)H0;
B=(uint)H1;
C=(uint)H2;
D=(uint)H3;
E=(uint)H4;
F=(uint)H5;
G=(uint)H6;
H=(uint)H7;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
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
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

OPA=A+(uint)H0;
OPB=B+(uint)H1;
OPC=C+(uint)H2;
OPD=D+(uint)H3;
OPE=E+(uint)H4;
OPF=F+(uint)H5;
OPG=G+(uint)H6;
OPH=H+(uint)H7;




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
w4=(uint)0x80000000;

SIZE=(uint)(12+64+4)<<3;
w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;
Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P0(D, E, F, G, H, A, B, C, 0x59F111F1);
P0(C, D, E, F, G, H, A, B, 0x923F82A4);
P0(B, C, D, E, F, G, H, A, 0xAB1C5ED5);
P0(A, B, C, D, E, F, G, H, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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
SIZE=(uint)((64+32)<<3);
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

dst[(get_global_id(0)*32)+0]=A;
dst[(get_global_id(0)*32)+1]=B;
dst[(get_global_id(0)*32)+2]=C;
dst[(get_global_id(0)*32)+3]=D;
dst[(get_global_id(0)*32)+4]=E;
dst[(get_global_id(0)*32)+5]=F;
dst[(get_global_id(0)*32)+6]=G;
dst[(get_global_id(0)*32)+7]=H;
dst[(get_global_id(0)*32)+8]=IPA;
dst[(get_global_id(0)*32)+9]=IPB;
dst[(get_global_id(0)*32)+10]=IPC;
dst[(get_global_id(0)*32)+11]=IPD;
dst[(get_global_id(0)*32)+12]=IPE;
dst[(get_global_id(0)*32)+13]=IPF;
dst[(get_global_id(0)*32)+14]=IPG;
dst[(get_global_id(0)*32)+15]=IPH;
dst[(get_global_id(0)*32)+16]=OPA;
dst[(get_global_id(0)*32)+17]=OPB;
dst[(get_global_id(0)*32)+18]=OPC;
dst[(get_global_id(0)*32)+19]=OPD;
dst[(get_global_id(0)*32)+20]=OPE;
dst[(get_global_id(0)*32)+21]=OPF;
dst[(get_global_id(0)*32)+22]=OPG;
dst[(get_global_id(0)*32)+23]=OPH;
dst[(get_global_id(0)*32)+24]=TTA;
dst[(get_global_id(0)*32)+25]=TTB;
dst[(get_global_id(0)*32)+26]=TTC;
dst[(get_global_id(0)*32)+27]=TTD;
dst[(get_global_id(0)*32)+28]=TTE;
dst[(get_global_id(0)*32)+29]=TTF;
dst[(get_global_id(0)*32)+30]=TTG;
dst[(get_global_id(0)*32)+31]=TTH;

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint m = 0x00FF00FF;
uint m2 = 0xFF00FF00;
uint IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


A=dst[(get_global_id(0)*32)+0];
B=dst[(get_global_id(0)*32)+1];
C=dst[(get_global_id(0)*32)+2];
D=dst[(get_global_id(0)*32)+3];
E=dst[(get_global_id(0)*32)+4];
F=dst[(get_global_id(0)*32)+5];
G=dst[(get_global_id(0)*32)+6];
H=dst[(get_global_id(0)*32)+7];
IPA=dst[(get_global_id(0)*32)+8];
IPB=dst[(get_global_id(0)*32)+9];
IPC=dst[(get_global_id(0)*32)+10];
IPD=dst[(get_global_id(0)*32)+11];
IPE=dst[(get_global_id(0)*32)+12];
IPF=dst[(get_global_id(0)*32)+13];
IPG=dst[(get_global_id(0)*32)+14];
IPH=dst[(get_global_id(0)*32)+15];
OPA=dst[(get_global_id(0)*32)+16];
OPB=dst[(get_global_id(0)*32)+17];
OPC=dst[(get_global_id(0)*32)+18];
OPD=dst[(get_global_id(0)*32)+19];
OPE=dst[(get_global_id(0)*32)+20];
OPF=dst[(get_global_id(0)*32)+21];
OPG=dst[(get_global_id(0)*32)+22];
OPH=dst[(get_global_id(0)*32)+23];
TTA=dst[(get_global_id(0)*32)+24];
TTB=dst[(get_global_id(0)*32)+25];
TTC=dst[(get_global_id(0)*32)+26];
TTD=dst[(get_global_id(0)*32)+27];
TTE=dst[(get_global_id(0)*32)+28];
TTF=dst[(get_global_id(0)*32)+29];
TTG=dst[(get_global_id(0)*32)+30];
TTH=dst[(get_global_id(0)*32)+31];

// We now have the first HMAC. Iterate to find the rest
for (ic=0;ic<1000;ic++)
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
SIZE=(uint)(64+32)<<3;
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
P(A, B, C, D, E, F, G, H,w8, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

SIZE=(uint)(64+32)<<3;
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF^=F;TTG^=G;TTH^=H;
}

dst[(get_global_id(0)*32)+0]=A;
dst[(get_global_id(0)*32)+1]=B;
dst[(get_global_id(0)*32)+2]=C;
dst[(get_global_id(0)*32)+3]=D;
dst[(get_global_id(0)*32)+4]=E;
dst[(get_global_id(0)*32)+5]=F;
dst[(get_global_id(0)*32)+6]=G;
dst[(get_global_id(0)*32)+7]=H;
dst[(get_global_id(0)*32)+8]=IPA;
dst[(get_global_id(0)*32)+9]=IPB;
dst[(get_global_id(0)*32)+10]=IPC;
dst[(get_global_id(0)*32)+11]=IPD;
dst[(get_global_id(0)*32)+12]=IPE;
dst[(get_global_id(0)*32)+13]=IPF;
dst[(get_global_id(0)*32)+14]=IPG;
dst[(get_global_id(0)*32)+15]=IPH;
dst[(get_global_id(0)*32)+16]=OPA;
dst[(get_global_id(0)*32)+17]=OPB;
dst[(get_global_id(0)*32)+18]=OPC;
dst[(get_global_id(0)*32)+19]=OPD;
dst[(get_global_id(0)*32)+20]=OPE;
dst[(get_global_id(0)*32)+21]=OPF;
dst[(get_global_id(0)*32)+22]=OPG;
dst[(get_global_id(0)*32)+23]=OPH;
dst[(get_global_id(0)*32)+24]=TTA;
dst[(get_global_id(0)*32)+25]=TTB;
dst[(get_global_id(0)*32)+26]=TTC;
dst[(get_global_id(0)*32)+27]=TTD;
dst[(get_global_id(0)*32)+28]=TTE;
dst[(get_global_id(0)*32)+29]=TTF;
dst[(get_global_id(0)*32)+30]=TTG;
dst[(get_global_id(0)*32)+31]=TTH;
}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ib,ic,id;  
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp, SIZE;
uint m = 0x00FF00FF;
uint m2 = 0xFF00FF00;
uint IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
uint OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


A=input[(get_global_id(0)*32)+0];
B=input[(get_global_id(0)*32)+1];
C=input[(get_global_id(0)*32)+2];
D=input[(get_global_id(0)*32)+3];
E=input[(get_global_id(0)*32)+4];
F=input[(get_global_id(0)*32)+5];
G=input[(get_global_id(0)*32)+6];
H=input[(get_global_id(0)*32)+7];
IPA=input[(get_global_id(0)*32)+8];
IPB=input[(get_global_id(0)*32)+9];
IPC=input[(get_global_id(0)*32)+10];
IPD=input[(get_global_id(0)*32)+11];
IPE=input[(get_global_id(0)*32)+12];
IPF=input[(get_global_id(0)*32)+13];
IPG=input[(get_global_id(0)*32)+14];
IPH=input[(get_global_id(0)*32)+15];
OPA=input[(get_global_id(0)*32)+16];
OPB=input[(get_global_id(0)*32)+17];
OPC=input[(get_global_id(0)*32)+18];
OPD=input[(get_global_id(0)*32)+19];
OPE=input[(get_global_id(0)*32)+20];
OPF=input[(get_global_id(0)*32)+21];
OPG=input[(get_global_id(0)*32)+22];
OPH=input[(get_global_id(0)*32)+23];
TTA=input[(get_global_id(0)*32)+24];
TTB=input[(get_global_id(0)*32)+25];
TTC=input[(get_global_id(0)*32)+26];
TTD=input[(get_global_id(0)*32)+27];
TTE=input[(get_global_id(0)*32)+28];
TTF=input[(get_global_id(0)*32)+29];
TTG=input[(get_global_id(0)*32)+30];
TTH=input[(get_global_id(0)*32)+31];

// We now have the first HMAC. Iterate to find the rest
for (ic=0;ic<salt.sA;ic++)
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
SIZE=(uint)(64+32)<<3;
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
P(A, B, C, D, E, F, G, H,w8, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

SIZE=(uint)(64+32)<<3;
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
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
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

TTA^=A;TTB^=B;TTC^=C;TTD^=D;TTE^=E;TTF^=F;TTG^=G;TTH^=H;
}

Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);

if ((TTA!=(uint)singlehash.s0)) return;
if ((TTB!=(uint)singlehash.s1)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*2)] = (uint4)(TTA,TTB,TTC,TTD);
dst[(get_global_id(0)*2)+1] = (uint4)(TTE,TTF,TTG,TTH);

}


#endif
