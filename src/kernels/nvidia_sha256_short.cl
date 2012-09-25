#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#ifdef SM21

__kernel __attribute__((reqd_work_group_size(128, 1, 1)))
void sha256_short( __global uint4 *dst, uint4 input, uint size,  uint8 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table,  uint4 singlehash) 
{  

uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;

uint i,ib,ic,id,ie;  
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


uint4 chbase1=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);


ic = size+4;
id = ic*8; 
SIZE = (uint4)id; 


w0 = (uint4)input.x;
w1 = (uint4)input.y;
w2 = (uint4)input.z;
w3 = (uint4)input.w;


i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255); 

if (size==1) {w0=chbase1|(ib<<8)|(ic<<16)|(id<<24);w1=ie|(0x80<<8);}
else if (size==2) {w0|=(chbase1<<8)|(ib<<16)|(ic<<24);w1=(id)|(ie<<8)|(0x80<<16);}  
else if (size==3) {w0|=(chbase1<<16)|(ib<<24);w1=ic|(id<<8)|(ie<<16)|(0x80<<24);}
else if (size==4) {w0|=(chbase1<<24);w1=(ib)|(ic<<8)|(id<<16)|(ie<<24);w2=(0x80);}  
else if (size==5) {w1=chbase1|(ib<<8)|(ic<<16)|(id<<24);w2=(ie)|(0x80<<8);} 
else if (size==6) {w1|=(chbase1<<8)|(ib<<16)|(ic<<24);w2=(id)|(ie<<8)|(0x80<<16);}  
else if (size==7) {w1|=(chbase1<<16)|(ib<<24);w2=(ic)|(id<<8)|(ie<<16)|(0x80<<24);} 
else if (size==8) {w1|=(chbase1<<24);w2=(ib)|(ic<<8)|(id<<16)|(ie<<24);w3=(0x80);}  
else if (size==9) {w2=(chbase1)|(ib<<8)|(ic<<16)|(id<<24);w3=(ie)|(0x80<<8);}
else if (size==10) {w2|=(chbase1<<8)|(ib<<16)|(ic<<24);w3=(id)|(ie<<8)|(0x80<<16);} 
else if (size==11) {w2|=(chbase1<<16)|(ib<<24);w3=(ic)|(id<<8)|(ie<<16)|(0x80<<24);}


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


#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

A=(uint4)H0;
B=(uint4)H1;
C=(uint4)H2;
D=(uint4)H3;
E=(uint4)H4;
F=(uint4)H5;
G=(uint4)H6;
H=(uint4)H7;


Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);

#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (ROTATE(x,(32-n)))

#define S0(x) (ROTR(x, 7) ^  SHR(x, 3)^ ROTR(x,18) )
#define S1(x) (ROTR(x,17) ^  SHR(x,10)^ ROTR(x,19) )
#define S2(x) (ROTR(x, 2) ^ ROTR(x,22)^ ROTR(x,13) )
#define S3(x) (ROTR(x, 6) ^ ROTR(x,25)^ ROTR(x,11) )

#define F1(x,y,z) (z ^ (x & (y ^ z)))
#define F00(x,y,z) ((x & y) | (z & (x | y)))
#define F0(x,y,z) ((x & y) | (z & (x | y)))

#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}
#define PI(a,b,c,d,e,f,g,h,x,K) {tmp1 = h + S3(e) + F1(e,f,g) + K + x;tmp2 = S2(a) + F00(a,b,c);d += tmp1; h = tmp1 + tmp2;}



PI(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
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

#ifdef SINGLE_MODE
id=0;
if ((singlehash.x==A.s0)&&(singlehash.y==B.s0)&&(singlehash.z==C.s0)&&(singlehash.w==D.s0)) id = 1; 
if ((singlehash.x==A.s1)&&(singlehash.y==B.s1)&&(singlehash.z==C.s1)&&(singlehash.w==D.s1)) id = 1; 
if ((singlehash.x==A.s2)&&(singlehash.y==B.s2)&&(singlehash.z==C.s2)&&(singlehash.w==D.s2)) id = 1; 
if ((singlehash.x==A.s3)&&(singlehash.y==B.s3)&&(singlehash.z==C.s3)&&(singlehash.w==D.s3)) id = 1; 
if (id==0) return;
#endif


#ifndef SINGLE_MODE
id=0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
if (id==0) return;
#endif



if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)*8)] = (uint4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*8)+1] = (uint4)(E.s0,F.s0,G.s0,H.s0);
dst[(get_global_id(0)*8)+2] = (uint4)(A.s1,B.s1,C.s1,D.s1);  
dst[(get_global_id(0)*8)+3] = (uint4)(E.s1,F.s1,G.s1,H.s1);
dst[(get_global_id(0)*8)+4] = (uint4)(A.s2,B.s2,C.s2,D.s2);  
dst[(get_global_id(0)*8)+5] = (uint4)(E.s2,F.s2,G.s2,H.s2);
dst[(get_global_id(0)*8)+6] = (uint4)(A.s3,B.s3,C.s3,D.s3);  
dst[(get_global_id(0)*8)+7] = (uint4)(E.s3,F.s3,G.s3,H.s3);


}


#else


__kernel __attribute__((reqd_work_group_size(128, 1, 1)))
void sha256_short( __global uint4 *dst, uint4 input, uint size,  uint8 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table,  uint4 singlehash) 
{  

uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;

uint i,ib,ic,id,ie;  
uint A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp, SIZE;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint m= 0x00FF00FF;
uint m2= 0xFF00FF00;

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


uint chbase1=(uint)(chbase.s0);

ic = size+4;
id = ic*8; 
SIZE = (uint)id; 


w0 = (uint)input.x;
w1 = (uint)input.y;
w2 = (uint)input.z;
w3 = (uint)input.w;


i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255); 

if (size==1) {w0=chbase1|(ib<<8)|(ic<<16)|(id<<24);w1=ie|(0x80<<8);}
else if (size==2) {w0|=(chbase1<<8)|(ib<<16)|(ic<<24);w1=(id)|(ie<<8)|(0x80<<16);}  
else if (size==3) {w0|=(chbase1<<16)|(ib<<24);w1=ic|(id<<8)|(ie<<16)|(0x80<<24);}
else if (size==4) {w0|=(chbase1<<24);w1=(ib)|(ic<<8)|(id<<16)|(ie<<24);w2=(0x80);}  
else if (size==5) {w1=chbase1|(ib<<8)|(ic<<16)|(id<<24);w2=(ie)|(0x80<<8);} 
else if (size==6) {w1|=(chbase1<<8)|(ib<<16)|(ic<<24);w2=(id)|(ie<<8)|(0x80<<16);}  
else if (size==7) {w1|=(chbase1<<16)|(ib<<24);w2=(ic)|(id<<8)|(ie<<16)|(0x80<<24);} 
else if (size==8) {w1|=(chbase1<<24);w2=(ib)|(ic<<8)|(id<<16)|(ie<<24);w3=(0x80);}  
else if (size==9) {w2=(chbase1)|(ib<<8)|(ic<<16)|(id<<24);w3=(ie)|(0x80<<8);}
else if (size==10) {w2|=(chbase1<<8)|(ib<<16)|(ic<<24);w3=(id)|(ie<<8)|(0x80<<16);} 
else if (size==11) {w2|=(chbase1<<16)|(ib<<24);w3=(ic)|(id<<8)|(ie<<16)|(0x80<<24);}


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


#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

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

#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (ROTATE(x,(32-n)))

#define S0(x) (ROTR(x, 7) ^  SHR(x, 3)^ ROTR(x,18) )
#define S1(x) (ROTR(x,17) ^  SHR(x,10)^ ROTR(x,19) )
#define S2(x) (ROTR(x, 2) ^ ROTR(x,22)^ ROTR(x,13) )
#define S3(x) (ROTR(x, 6) ^ ROTR(x,25)^ ROTR(x,11) )

#define F1(x,y,z) (z ^ (x & (y ^ z)))
#define F00(x,y,z) ((x & y) | (z & (x | y)))
#define F0(x,y,z) ((x & y) | (z & (x | y)))

#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}
#define PI(a,b,c,d,e,f,g,h,x,K) {tmp1 = h + S3(e) + F1(e,f,g) + K + x;tmp2 = S2(a) + F00(a,b,c);d += tmp1; h = tmp1 + tmp2;}



PI(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
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
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
if (id==0) return;
#endif



if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)*8)] = (uint4)(A,B,C,D);  
dst[(get_global_id(0)*8)+1] = (uint4)(E,F,G,H);


}
#endif