#define rotate(x,y) ((x) << (y)) + ((x) >> (32-(y)))

#ifndef SM21

#define getglobalid(a) (mad24(get_group_id(0), 64U, get_local_id(0)))

void sha256_long1( __global uint *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint x0) 
{
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
uint i,ib,ic,id,x1,x2,x3;  
uint A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp, SIZE;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint m= 0x00FF00FF;
uint m2= 0xFF00FF00;

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


SIZE = (uint)size;

w1 = (uint)input.y;
w2 = (uint)input.z;
w3 = (uint)input.w;
w0=x0;
x1=w1;
x2=w2;
x3=w3;


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


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

A=(uint)H0;
B=(uint)H1;
C=(uint)H2;
D=(uint)H3;
E=(uint)H4;
F=(uint)H5;
G=(uint)H6;
H=(uint)H7;


//Endian_Reverse32(w0);
//Endian_Reverse32(w1);
//Endian_Reverse32(w2);
//Endian_Reverse32(w3);

#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))
#define F00(x,y,z) ((x & y) | (z & (x | y)))

#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}



P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P0(E, F, G, H, A, B, C, D, 0x3956C25BU);
P0(D, E, F, G, H, A, B, C, 0x59F111F1U);
P0(C, D, E, F, G, H, A, B, 0x923F82A4U);
P0(B, C, D, E, F, G, H, A, 0xAB1C5ED5U);
P0(A, B, C, D, E, F, G, H, 0xD807AA98U);
P0(H, A, B, C, D, E, F, G, 0x12835B01U);
P0(G, H, A, B, C, D, E, F, 0x243185BEU);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3U);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74U);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FEU);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1U);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786U);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6U);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CCU);
w3=S1(w1)+w13+S0(w5)+0+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6FU);
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
#ifdef SINGLE_MODE
if (((uint)singlehash.w != D)) return;
#endif
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEBU);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7U);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2U);

#ifdef SINGLE_MODE
id=0;
if (((uint)singlehash.x!=A)) return;
if (((uint)singlehash.y!=B)) return;
#endif
#ifndef SINGLE_MODE
id = 0;
b1=A;b2=B;b3=C;b4=D;
b5=(singlehash.x >> (B&31))&1;
b6=(singlehash.y >> (C&31))&1;
b7=(singlehash.z >> (D&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

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


Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res*8] = (uint)(A);
hashes[res*8+1] = (uint)(B);
hashes[res*8+2] = (uint)(C);
hashes[res*8+3] = (uint)(D);
hashes[res*8+4] = (uint)(E);
hashes[res*8+5] = (uint)(F);
hashes[res*8+6] = (uint)(G);
hashes[res*8+7] = (uint)(H);
plains[res] = (uint4)(x0,x1,x2,x3);

}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
sha256_long_double( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s0,chbase3.s1,chbase3.s2,chbase3.s3);
singlehash=(uint4)(chbase4.s0,chbase4.s1,chbase4.s2,chbase4.s3);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s4,chbase3.s5,chbase3.s6,chbase3.s7);
singlehash=(uint4)(chbase4.s4,chbase4.s5,chbase4.s6,chbase4.s7);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s8,chbase3.s9,chbase3.sA,chbase3.sB);
singlehash=(uint4)(chbase4.s8,chbase4.s9,chbase4.sA,chbase4.sB);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.sC,chbase3.sD,chbase3.sE,chbase3.sF);
singlehash=(uint4)(chbase4.sC,chbase4.sD,chbase4.sE,chbase4.sF);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);

}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
sha256_long_normal( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}



#else

void sha256_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash,uint4 x0) 
{
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,x1,x2,x3;
uint i,ib,ic,id;  
uint4 A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp, SIZE;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 m= 0x00FF00FF;
uint4 m2= 0xFF00FF00;

#define H0 0x6A09E667
#define H1 0xBB67AE85
#define H2 0x3C6EF372
#define H3 0xA54FF53A
#define H4 0x510E527F
#define H5 0x9B05688C
#define H6 0x1F83D9AB
#define H7 0x5BE0CD19

#define Sl 8
#define Sr 24


SIZE = (uint4)size;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
w3 = (uint4)input.w;
w0=x0;
x1=w1;
x2=w2;
x3=w3;


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


#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

A=(uint4)H0;
B=(uint4)H1;
C=(uint4)H2;
D=(uint4)H3;
E=(uint4)H4;
F=(uint4)H5;
G=(uint4)H6;
H=(uint4)H7;


//Endian_Reverse32(w0);
//Endian_Reverse32(w1);
//Endian_Reverse32(w2);
//Endian_Reverse32(w3);

#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))
#define F00(x,y,z) ((x & y) | (z & (x | y)))

#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}



P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P0(E, F, G, H, A, B, C, D, 0x3956C25B);
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
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+0+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
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
#ifdef SINGLE_MODE
if (all((uint4)singlehash.w != D)) return;
#endif
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

#ifdef SINGLE_MODE
id=0;
if (all((uint4)singlehash.x!=A)) return;
if (all((uint4)singlehash.y!=B)) return;
#endif
#ifndef SINGLE_MODE
id = 0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif


A=A+(uint4)H0;
B=B+(uint4)H1;
C=C+(uint4)H2;
D=D+(uint4)H3;
E=E+(uint4)H4;
F=F+(uint4)H5;
G=G+(uint4)H6;
H=H+(uint4)H7;

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);
Endian_Reverse32(F);
Endian_Reverse32(G);
Endian_Reverse32(H);


#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res*8] = (uint4)(A.s0,B.s0,C.s0,D.s0);
hashes[res*8+1] = (uint4)(E.s0,F.s0,G.s0,H.s0);
hashes[res*8+2] = (uint4)(A.s1,B.s1,C.s1,D.s1);
hashes[res*8+3] = (uint4)(E.s1,F.s1,G.s1,H.s1);
hashes[res*8+4] = (uint4)(A.s2,B.s2,C.s2,D.s2);
hashes[res*8+5] = (uint4)(E.s2,F.s2,G.s2,H.s2);
hashes[res*8+6] = (uint4)(A.s3,B.s3,C.s3,D.s3);
hashes[res*8+7] = (uint4)(E.s3,F.s3,G.s3,H.s3);

Endian_Reverse32(x0);
Endian_Reverse32(x1);
Endian_Reverse32(x2);
Endian_Reverse32(x3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
sha256_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
uint4 k;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 


SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
sha256_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i,k;
uint j;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
sha256_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}




#endif
