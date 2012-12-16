#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))

#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint4)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint4)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint4)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);

#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint4)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint4)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint4)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);



#ifndef GCN
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
ripemd160( __global uint4 *dst,  __global uint *inp, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1) 
{

uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint x0,x1,x2,x3,x4,x5,x6,x7; 
uint i,ib,ic,id;  
uint4 A,B,C,D,E,K,l,tmp1,tmp2, SIZE; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint t1,elem;
__local uint inpc[64][14];
uint4 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;


id=get_global_id(0);
SIZE=(uint4)size[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s0,SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC),0);
w0.s0=inpc[GLI][0];
w1.s0=inpc[GLI][1];
w2.s0=inpc[GLI][2];
w3.s0=inpc[GLI][3];
w4.s0=inpc[GLI][4];
w5.s0=inpc[GLI][5];
w6.s0=inpc[GLI][6];
w7.s0=inpc[GLI][7];
SIZE.s0 = (SIZE.s0+str.sC)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s4,SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD),0);
w0.s1=inpc[GLI][0];
w1.s1=inpc[GLI][1];
w2.s1=inpc[GLI][2];
w3.s1=inpc[GLI][3];
w4.s1=inpc[GLI][4];
w5.s1=inpc[GLI][5];
w6.s1=inpc[GLI][6];
w7.s1=inpc[GLI][7];
SIZE.s1 = (SIZE.s1+str.sD)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s8,SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE),0);
w0.s2=inpc[GLI][0];
w1.s2=inpc[GLI][1];
w2.s2=inpc[GLI][2];
w3.s2=inpc[GLI][3];
w4.s2=inpc[GLI][4];
w5.s2=inpc[GLI][5];
w6.s2=inpc[GLI][6];
w7.s2=inpc[GLI][7];
SIZE.s2 = (SIZE.s2+str.sE)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s0,SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC),0);
w0.s3=inpc[GLI][0];
w1.s3=inpc[GLI][1];
w2.s3=inpc[GLI][2];
w3.s3=inpc[GLI][3];
w4.s3=inpc[GLI][4];
w5.s3=inpc[GLI][5];
w6.s3=inpc[GLI][6];
w7.s3=inpc[GLI][7];
SIZE.s3 = (SIZE.s3+str1.sC)<<3;

w8=w9=w10=w11=w12=w13=w15=(uint4)0;


aa=(uint4)0x67452301;
bb=(uint4)0xefcdab89;
cc=(uint4)0x98badcfe;
dd=(uint4)0x10325476;
ee=(uint4)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;


FF(aa, bb, cc, dd, ee, w0, (uint4)11);
FF(ee, aa, bb, cc, dd, w1, (uint4)14);
FF(dd, ee, aa, bb, cc, w2, (uint4)15);
FF(cc, dd, ee, aa, bb, w3, (uint4)12);
FF(bb, cc, dd, ee, aa, w4, (uint4)5);
FF(aa, bb, cc, dd, ee, w5,  (uint4)8);
FF(ee, aa, bb, cc, dd, w6,  (uint4)7);
FF(dd, ee, aa, bb, cc, w7,  (uint4)9);
FF(cc, dd, ee, aa, bb, w8, (uint4)11);
FF(bb, cc, dd, ee, aa, w9, (uint4)13);
FF(aa, bb, cc, dd, ee, w10, (uint4)14);
FF(ee, aa, bb, cc, dd, w11, (uint4)15);
FF(dd, ee, aa, bb, cc, w12,  (uint4)6);
FF(cc, dd, ee, aa, bb, w13,  (uint4)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint4)9);
FF(aa, bb, cc, dd, ee, w15,  (uint4)8);

GG(ee, aa, bb, cc, dd, w7,  (uint4)7);
GG(dd, ee, aa, bb, cc, w4,  (uint4)6);
GG(cc, dd, ee, aa, bb, w13,  (uint4)8);
GG(bb, cc, dd, ee, aa, w1, (uint4)13);
GG(aa, bb, cc, dd, ee, w10, (uint4)11);
GG(ee, aa, bb, cc, dd, w6,  (uint4)9);
GG(dd, ee, aa, bb, cc, w15,  (uint4)7);
GG(cc, dd, ee, aa, bb, w3, (uint4)15);
GG(bb, cc, dd, ee, aa, w12,  (uint4)7);
GG(aa, bb, cc, dd, ee, w0, (uint4)12);
GG(ee, aa, bb, cc, dd, w9, (uint4)15);
GG(dd, ee, aa, bb, cc, w5,  (uint4)9);
GG(cc, dd, ee, aa, bb, w2, (uint4)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint4)7);
GG(aa, bb, cc, dd, ee, w11, (uint4)13);
GG(ee, aa, bb, cc, dd, w8, (uint4)12);

HH(dd, ee, aa, bb, cc, w3, (uint4)11);
HH(cc, dd, ee, aa, bb, w10, (uint4)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint4)6);
HH(aa, bb, cc, dd, ee, w4, (uint4)7);
HH(ee, aa, bb, cc, dd, w9, (uint4)14);
HH(dd, ee, aa, bb, cc, w15, (uint4)9);
HH(cc, dd, ee, aa, bb, w8, (uint4)13);
HH(bb, cc, dd, ee, aa, w1, (uint4)15);
HH(aa, bb, cc, dd, ee, w2, (uint4)14);
HH(ee, aa, bb, cc, dd, w7, (uint4)8);
HH(dd, ee, aa, bb, cc, w0, (uint4)13);
HH(cc, dd, ee, aa, bb, w6, (uint4)6);
HH(bb, cc, dd, ee, aa, w13, (uint4)5);
HH(aa, bb, cc, dd, ee, w11, (uint4)12);
HH(ee, aa, bb, cc, dd, w5, (uint4)7);
HH(dd, ee, aa, bb, cc, w12, (uint4)5);

II(cc, dd, ee, aa, bb, w1, (uint4)11);
II(bb, cc, dd, ee, aa, w9, (uint4)12);
II(aa, bb, cc, dd, ee, w11, (uint4)14);
II(ee, aa, bb, cc, dd, w10, (uint4)15);
II(dd, ee, aa, bb, cc, w0, (uint4)14);
II(cc, dd, ee, aa, bb, w8, (uint4)15);
II(bb, cc, dd, ee, aa, w12, (uint4)9);
II(aa, bb, cc, dd, ee, w4, (uint4)8);
II(ee, aa, bb, cc, dd, w13, (uint4)9);
II(dd, ee, aa, bb, cc, w3, (uint4)14);
II(cc, dd, ee, aa, bb, w7, (uint4)5);
II(bb, cc, dd, ee, aa, w15, (uint4)6);
II(aa, bb, cc, dd, ee, SIZE, (uint4)8);
II(ee, aa, bb, cc, dd, w5, (uint4)6);
II(dd, ee, aa, bb, cc, w6, (uint4)5);
II(cc, dd, ee, aa, bb, w2, (uint4)12);

JJ(bb, cc, dd, ee, aa, w4, (uint4)9);
JJ(aa, bb, cc, dd, ee, w0, (uint4)15);
JJ(ee, aa, bb, cc, dd, w5, (uint4)5);
JJ(dd, ee, aa, bb, cc, w9, (uint4)11);
JJ(cc, dd, ee, aa, bb, w7, (uint4)6);
JJ(bb, cc, dd, ee, aa, w12, (uint4)8);
JJ(aa, bb, cc, dd, ee, w2, (uint4)13);
JJ(ee, aa, bb, cc, dd, w10, (uint4)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint4)5);
JJ(cc, dd, ee, aa, bb, w1, (uint4)12);
JJ(bb, cc, dd, ee, aa, w3, (uint4)13);
JJ(aa, bb, cc, dd, ee, w8, (uint4)14);
JJ(ee, aa, bb, cc, dd, w11, (uint4)11);
JJ(dd, ee, aa, bb, cc, w6, (uint4)8);
JJ(cc, dd, ee, aa, bb, w15, (uint4)5);
JJ(bb, cc, dd, ee, aa, w13, (uint4)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint4)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint4)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint4)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint4)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint4)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint4)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint4)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint4)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint4)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint4)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint4)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint4)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint4)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint4)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint4)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint4)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint4)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint4)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint4)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint4)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint4)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint4)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint4)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint4)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint4)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint4)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint4)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint4)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint4)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint4)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint4)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint4)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint4)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint4)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint4)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint4)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint4)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint4)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint4)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint4)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint4)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint4)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint4)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint4)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint4)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint4)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint4)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint4)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint4)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint4)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint4)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint4)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint4)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint4)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint4)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint4)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint4)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint4)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint4)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint4)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint4)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint4)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint4)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint4)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint4)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint4)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint4)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint4)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint4)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint4)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint4)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint4)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint4)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint4)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint4)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint4)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint4)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint4)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint4)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint4)11);


tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);




#ifdef SINGLE_MODE
if (all((uint4)singlehash.z!=cocc)) return;
if (all((uint4)singlehash.w!=codd)) return;
#endif
#ifndef SINGLE_MODE
id=0;
b1=coaa.s0;b2=cobb.s0;b3=cocc.s0;b4=codd.s0;
b5=(singlehash.x >> (cobb.s0&31))&1;
b6=(singlehash.y >> (cocc.s0&31))&1;
b7=(singlehash.z >> (codd.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=coaa.s1;b2=cobb.s1;b3=cocc.s1;b4=codd.s1;
b5=(singlehash.x >> (cobb.s1&31))&1;
b6=(singlehash.y >> (cocc.s1&31))&1;
b7=(singlehash.z >> (codd.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=coaa.s2;b2=cobb.s2;b3=cocc.s2;b4=codd.s2;
b5=(singlehash.x >> (cobb.s2&31))&1;
b6=(singlehash.y >> (cocc.s2&31))&1;
b7=(singlehash.z >> (codd.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=coaa.s3;b2=cobb.s3;b3=cocc.s3;b4=codd.s3;
b5=(singlehash.x >> (cobb.s3&31))&1;
b6=(singlehash.y >> (cocc.s3&31))&1;
b7=(singlehash.z >> (codd.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif



found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*5)] = (uint4)(coaa.s0,cobb.s0,cocc.s0,codd.s0);  
dst[(get_global_id(0)*5)+1] = (uint4)(coee.s0,coaa.s1,cobb.s1,cocc.s1);
dst[(get_global_id(0)*5)+2] = (uint4)(codd.s1,coee.s1,coaa.s2,cobb.s2);
dst[(get_global_id(0)*5)+3] = (uint4)(cocc.s2,codd.s2,coee.s2,coaa.s3);
dst[(get_global_id(0)*5)+4] = (uint4)(cobb.s3,cocc.s3,codd.s3,coee.s3);

}


#else

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))

#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);

#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);


void ripemd160_block(__global uint *dst,uint w0,uint w1,uint w2,uint w3, uint w4, uint w5, uint w6,uint w7,uint SIZE, __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint offset)
{
uint w8,w9,w10,w11,w12,w13,w14,w15; 
uint A,B,C,D,E,K,l,tmp1,tmp2,id; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;


w8=w9=w10=w11=w12=w13=w15=(uint)0;


aa=(uint)0x67452301;
bb=(uint)0xefcdab89;
cc=(uint)0x98badcfe;
dd=(uint)0x10325476;
ee=(uint)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;


FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);


tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

#ifdef SINGLE_MODE
if (((uint)singlehash.z!=cocc)) return;
#endif
#ifndef SINGLE_MODE
id=0;
b1=cocc;b2=cobb;b3=cocc;b4=codd;
b5=(singlehash.x >> (cobb&31))&1;
b6=(singlehash.y >> (cocc&31))&1;
b7=(singlehash.z >> (codd&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*20)+offset]=coaa;
dst[(get_global_id(0)*20)+offset+1]=cobb;
dst[(get_global_id(0)*20)+offset+2]=cocc;
dst[(get_global_id(0)*20)+offset+3]=codd;
dst[(get_global_id(0)*20)+offset+4]=coee;
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
ripemd160( __global uint *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1) 
{
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w15; 
uint x0,x1,x2,x3,x4,x5,x6,x7; 
uint i,ib,ic,id;  
uint A,B,C,D,E,K,l,tmp1,tmp2, SIZE,size; 
uint t1,elem;
__local uint inpc[64][14];


id=get_global_id(0);
size=(uint)sizein[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s0,size,0);
SET_AB(inpc[GLI],str.s1,size+4,0);
SET_AB(inpc[GLI],str.s2,size+8,0);
SET_AB(inpc[GLI],str.s3,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sC),0);
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sC)<<3;

ripemd160_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,0);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s4,size,0);
SET_AB(inpc[GLI],str.s5,size+4,0);
SET_AB(inpc[GLI],str.s6,size+8,0);
SET_AB(inpc[GLI],str.s7,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sD),0);
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sD)<<3;

ripemd160_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,5);

inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s8,size,0);
SET_AB(inpc[GLI],str.s9,size+4,0);
SET_AB(inpc[GLI],str.sA,size+8,0);
SET_AB(inpc[GLI],str.sB,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sE),0);
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sE)<<3;

ripemd160_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,10);

inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s0,size,0);
SET_AB(inpc[GLI],str1.s1,size+4,0);
SET_AB(inpc[GLI],str1.s2,size+8,0);
SET_AB(inpc[GLI],str1.s3,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str1.sC),0);
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str1.sC)<<3;

ripemd160_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,15);

}


#endif




