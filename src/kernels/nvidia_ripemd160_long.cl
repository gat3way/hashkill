#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))


#ifndef SM21

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



#define MAX8
void ripemd160_long1( __global uint *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint16 xors) 
{  
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w15;
uint x0,x1,x2,x3;
uint ib,ic,id;  
uint l,tmp1,tmp2,SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint table1;
uint aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint m=(uint)0x00FF00FF;
uint m2=(uint)0xFF00FF00;


SIZE = (uint)(size);
size1=SIZE;

w1 = (uint)input.y;
w2 = (uint)input.z;
#ifndef MAX8
w3 = (uint)input.w;
#else
w3=(uint)0;
#endif
w0=(uint)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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
w15=(uint)0;


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
if ((coaa!=(uint)singlehash.x)) return;
if ((cobb!=(uint)singlehash.y)) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=coaa;b2=cobb;b3=cocc;b4=codd;
b5=(singlehash.x >> (cobb&31))&1;
b6=(singlehash.y >> (cocc&31))&1;
b7=(singlehash.z >> (codd&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif

#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif


hashes[res*5] = (uint)coaa;
hashes[res*5+1] = (uint)cobb;
hashes[res*5+2] = (uint)cocc;
hashes[res*5+3] = (uint)codd;
hashes[res*5+4] = (uint)coee;

plains[res] = (uint4)(x0,x1,x2,x3);

}


#undef MAX8

void ripemd160_long2( __global uint *hashes, uint4 input, uint size , __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint16 xors) 
{  
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w15;
uint x0,x1,x2,x3;
uint ib,ic,id;  
uint l,tmp1,tmp2,SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint table1;
uint aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint m=(uint)0x00FF00FF;
uint m2=(uint)0xFF00FF00;


SIZE = (uint)(size);
size1=SIZE;

w1 = (uint)input.y;
w2 = (uint)input.z;
#ifndef MAX8
w3 = (uint)input.w;
#else
w3=(uint)0;
#endif
w0=(uint)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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
w15=(uint)0;


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
if ((coaa!=(uint)singlehash.x)) return;
if ((cobb!=(uint)singlehash.y)) return;
#endif

#ifndef SINGLE_MODE
id=0;
b1=coaa;b2=cobb;b3=cocc;b4=codd;
b5=(singlehash.x >> (cobb&31))&1;
b6=(singlehash.y >> (cocc&31))&1;
b7=(singlehash.z >> (codd&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif

#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif


hashes[res*5] = (uint)coaa;
hashes[res*5+1] = (uint)cobb;
hashes[res*5+2] = (uint)cocc;
hashes[res*5+3] = (uint)codd;
hashes[res*5+4] = (uint)coee;

plains[res] = (uint4)(x0,x1,x2,x3);

}





__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_double( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
xors=xors3;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
xors=xors4;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}


__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_normal( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);


}



__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_double8( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
xors=xors3;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
xors=xors4;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}


__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_normal8( __global uint *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint i;
uint j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k=table[get_global_id(1)];
j=table[get_global_id(0)]<<16;
i=(k|j);
input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}

#endif



#if (SM21)

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))

#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint4)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint4)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint4)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);

#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint4)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint4)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint4)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint4)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10);

#define MAX8
void ripemd160_long1( __global uint4 *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint4 i,  uint4 singlehash, uint16 xors) 
{  
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w15;
uint4 x0,x1,x2,x3;
uint ib,ic,id;  
uint4 l,tmp1,tmp2,SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 table1;
uint4 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint4 m=(uint4)0x00FF00FF;
uint4 m2=(uint4)0xFF00FF00;


SIZE = (uint4)(size);
size1=SIZE;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
#ifndef MAX8
w3 = (uint4)input.w;
#else
w3=(uint4)0;
#endif
w0=(uint4)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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
w15=(uint4)0;


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
if (all(coaa!=(uint4)singlehash.x)) return;
if (all(cobb!=(uint4)singlehash.y)) return;
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

#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif


hashes[res*5] = (uint4)(coaa.s0,cobb.s0,cocc.s0,codd.s0);
hashes[res*5+1] = (uint4)(coee.s0,coaa.s1,cobb.s1,cocc.s1);
hashes[res*5+2] = (uint4)(codd.s1,coee.s1,coaa.s2,cobb.s2);
hashes[res*5+3] = (uint4)(cocc.s2,codd.s2,coee.s2,coaa.s3);
hashes[res*5+4] = (uint4)(cobb.s3,cocc.s3,codd.s3,coee.s3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}


#undef MAX8
void ripemd160_long2( __global uint4 *hashes, uint4 input, uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, uint4 i,  uint4 singlehash, uint16 xors) 
{  
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w15;
uint4 x0,x1,x2,x3;
uint ib,ic,id;  
uint4 l,tmp1,tmp2,SIZE,size1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 table1;
uint4 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint4 m=(uint4)0x00FF00FF;
uint4 m2=(uint4)0xFF00FF00;


SIZE = (uint4)(size);
size1=SIZE;

w1 = (uint4)input.y;
w2 = (uint4)input.z;
#ifndef MAX8
w3 = (uint4)input.w;
#else
w3=(uint4)0;
#endif
w0=(uint4)i;
x0=w0;x1=w1;x2=w2;x3=w3;


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
w15=(uint4)0;


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
if (all(coaa!=(uint4)singlehash.x)) return;
if (all(cobb!=(uint4)singlehash.y)) return;
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

#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif


hashes[res*5] = (uint4)(coaa.s0,cobb.s0,cocc.s0,codd.s0);
hashes[res*5+1] = (uint4)(coee.s0,coaa.s1,cobb.s1,cocc.s1);
hashes[res*5+2] = (uint4)(codd.s1,coee.s1,coaa.s2,cobb.s2);
hashes[res*5+3] = (uint4)(cocc.s2,codd.s2,coee.s2,coaa.s3);
hashes[res*5+4] = (uint4)(cobb.s3,cocc.s3,codd.s3,coee.s3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}



__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}


__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long1(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

}



__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_double8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;


k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);

input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
//singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
xors=xors2;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}


__kernel 
void  __attribute__((reqd_work_group_size(128, 1, 1))) 
ripemd160_long_normal8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 xors1, uint16 xors2,uint16 xors3, uint16 xors4) 
{
uint4 i;
uint4 j,k;
uint c0;
uint d0,d1,d2;
uint t1,t2,t3;
uint c1,c2;
uint t4;
uint4 input;
uint4 singlehash;
uint16 xors;

k.s0=table[get_global_id(1)*4];
k.s1=table[get_global_id(1)*4+1];
k.s2=table[get_global_id(1)*4+2];
k.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;
i=(k|j);
input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
xors=xors1;
ripemd160_long2(hashes, input, size, plains, bitmaps, found, i, singlehash, xors);
}

#endif
