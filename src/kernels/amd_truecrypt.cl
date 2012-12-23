#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *input, __global uint *input1, uint16 str, uint16 salt,uint16 salt2, __global uint *size)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = input[GGI*(8)+0];
inpc[GLI][1] = input[GGI*(8)+1];
inpc[GLI][2] = input[GGI*(8)+2];
inpc[GLI][3] = input[GGI*(8)+3];
inpc[GLI][4] = input[GGI*(8)+4];
inpc[GLI][5] = input[GGI*(8)+5];
inpc[GLI][6] = input[GGI*(8)+6];
inpc[GLI][7] = input[GGI*(8)+7];

SIZE = size[GGI];

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


#define Sl 8U
#define Sr 24U 
#define m 0x00FF00FFU
#define m2 0xFF00FF00U 


#ifndef GCN

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))

#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint2)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint2)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint2)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);

#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint2)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint2)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint2)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0x50a28be6);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define BYTE_ADD(x,y) ( ((x+y)&(uint2)255) | ((((x>>(uint2)8)+(y>>(uint2)8))&(uint2)255)<<8) | ((((x>>(uint2)16)+(y>>(uint2)16))&(uint2)255)<<(uint2)16) |((((x>>(uint2)24)+(y>>(uint2)24))&(uint2)255)<<(uint2)24)  )


// This is the prepare function for RIPEMD-160
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare1( __global uint2 *dst,  __global uint *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 SIZE;  
uint ib,ic,id;  
uint2 ta,tb,tc,td,te,tf,tg,th, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w15;
uint yl,yr,zl,zr,wl,wr;
uint2 A,B,C,D,E;
uint2 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint2 IPA,IPB,IPC,IPD,IPE;
uint2 OPA,OPB,OPC,OPD,OPE;
uint2 TTA,TTB,TTC,TTD,TTE;

TTA=TTB=TTC=TTD=TTE=(uint2)0;


ta.s0=input[get_global_id(0)*2*8];
tb.s0=input[get_global_id(0)*2*8+1];
tc.s0=input[get_global_id(0)*2*8+2];
td.s0=input[get_global_id(0)*2*8+3];
te.s0=input[get_global_id(0)*2*8+4];
tf.s0=input[get_global_id(0)*2*8+5];
tg.s0=input[get_global_id(0)*2*8+6];
th.s0=input[get_global_id(0)*2*8+7];

ta.s1=input[get_global_id(0)*2*8+8];
tb.s1=input[get_global_id(0)*2*8+9];
tc.s1=input[get_global_id(0)*2*8+10];
td.s1=input[get_global_id(0)*2*8+11];
te.s1=input[get_global_id(0)*2*8+12];
tf.s1=input[get_global_id(0)*2*8+13];
tg.s1=input[get_global_id(0)*2*8+14];
th.s1=input[get_global_id(0)*2*8+15];


ta = BYTE_ADD(ta,(uint2)salt2.s0);
tb = BYTE_ADD(tb,(uint2)salt2.s1);
tc = BYTE_ADD(tc,(uint2)salt2.s2);
td = BYTE_ADD(td,(uint2)salt2.s3);
te = BYTE_ADD(te,(uint2)salt2.s4);
tf = BYTE_ADD(tf,(uint2)salt2.s5);
tg = BYTE_ADD(tg,(uint2)salt2.s6);
th = BYTE_ADD(th,(uint2)salt2.s7);


// Initial HMAC (for PBKDF2)

// Calculate sha1(ipad^key)

w0 = (uint2)0x36363636 ^ ta;
w1 = (uint2)0x36363636 ^ tb;
w2 = (uint2)0x36363636 ^ tc;
w3 = (uint2)0x36363636 ^ td;
w4 = (uint2)0x36363636 ^ te;
w5 = (uint2)0x36363636 ^ tf;
w6 = (uint2)0x36363636 ^ tg;
w7 = (uint2)0x36363636 ^ th;
w8 = (uint2)0x36363636 ^ (uint2)salt2.s8;
w9 = (uint2)0x36363636 ^ (uint2)salt2.s9;
w10 = (uint2)0x36363636 ^ (uint2)salt2.sA;
w11 = (uint2)0x36363636 ^ (uint2)salt2.sB;
w12 = (uint2)0x36363636 ^ (uint2)salt2.sC;
w13 = (uint2)0x36363636 ^ (uint2)salt2.sD;
SIZE = (uint2)0x36363636 ^ (uint2)salt2.sE;
w15 = (uint2)0x36363636 ^ (uint2)salt2.sF;


aa=(uint2)0x67452301;
bb=(uint2)0xefcdab89;
cc=(uint2)0x98badcfe;
dd=(uint2)0x10325476;
ee=(uint2)0xc3d2e1f0;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

IPA=coaa;IPB=cobb;IPC=cocc;IPD=codd;IPE=coee;



// Calculate sha1(opad^key)
w0 = (uint2)0x5c5c5c5c ^ ta;
w1 = (uint2)0x5c5c5c5c ^ tb;
w2 = (uint2)0x5c5c5c5c ^ tc;
w3 = (uint2)0x5c5c5c5c ^ td;
w4 = (uint2)0x5c5c5c5c ^ te;
w5 = (uint2)0x5c5c5c5c ^ tf;
w6 = (uint2)0x5c5c5c5c ^ tg;
w7 = (uint2)0x5c5c5c5c ^ th;
w8 = (uint2)0x5c5c5c5c ^ (uint2)salt2.s8;
w9 = (uint2)0x5c5c5c5c ^ (uint2)salt2.s9;
w10 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sA;
w11 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sB;
w12 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sC;
w13 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sD;
SIZE = (uint2)0x5c5c5c5c ^ (uint2)salt2.sE;
w15 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sF;

aa=(uint2)0x67452301;
bb=(uint2)0xefcdab89;
cc=(uint2)0x98badcfe;
dd=(uint2)0x10325476;
ee=(uint2)0xc3d2e1f0;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

OPA=coaa;OPB=cobb;OPC=cocc;OPD=codd;OPE=coee;



// calculate hash sum 1

w0=(uint2)salt.s0;
w1=(uint2)salt.s1;
w2=(uint2)salt.s2;
w3=(uint2)salt.s3;
w4=(uint2)salt.s4;
w5=(uint2)salt.s5;
w6=(uint2)salt.s6;
w7=(uint2)salt.s7;
w8=(uint2)salt.s8;
w9=(uint2)salt.s9;
w10=(uint2)salt.sA;
w11=(uint2)salt.sB;
w12=(uint2)salt.sC;
w13=(uint2)salt.sD;
SIZE=(uint2)salt.sE;
w15=(uint2)salt.sF;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;



SIZE=(uint2)(64+64+4)<<3;
w0=(uint2)str.sC+1;
Endian_Reverse32(w0);
w1=(uint2)0x80;
w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=A;
bb=B;
cc=C;
dd=D;
ee=E;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);
ta=coaa;tb=cobb;tc=cocc;td=codd;te=coee;



// calculate hash sum 2

w0=ta;
w1=tb;
w2=tc;
w3=td;
w4=te;
w5=(uint2)0x80;
SIZE=(uint2)((64+20)<<3);
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

TTA=coaa;TTB=cobb;TTC=cocc;TTD=codd;TTE=coee;


input1[get_global_id(0)*2*5+0]=IPA;
input1[get_global_id(0)*2*5+1]=IPB;
input1[get_global_id(0)*2*5+2]=IPC;
input1[get_global_id(0)*2*5+3]=IPD;
input1[get_global_id(0)*2*5+4]=IPE;
input1[get_global_id(0)*2*5+5]=OPA;
input1[get_global_id(0)*2*5+6]=OPB;
input1[get_global_id(0)*2*5+7]=OPC;
input1[get_global_id(0)*2*5+8]=OPD;
input1[get_global_id(0)*2*5+9]=OPE;

dst[get_global_id(0)*3*5+0]=TTA;
dst[get_global_id(0)*3*5+1]=TTB;
dst[get_global_id(0)*3*5+2]=TTC;
dst[get_global_id(0)*3*5+3]=TTD;
dst[get_global_id(0)*3*5+4]=TTE;
dst[get_global_id(0)*3*5+10]=TTA;
dst[get_global_id(0)*3*5+11]=TTB;
dst[get_global_id(0)*3*5+12]=TTC;
dst[get_global_id(0)*3*5+13]=TTD;
dst[get_global_id(0)*3*5+14]=TTE;

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf1( __global uint2 *dst,  __global uint2 *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 SIZE;  
uint ib,ic,id;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
uint2 A,B,C,D,E;
uint2 IPA,IPB,IPC,IPD,IPE;
uint2 OPA,OPB,OPC,OPD,OPE;
uint2 TTA,TTB,TTC,TTD,TTE;
uint2 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;


TTA=dst[get_global_id(0)*3*5+0];
TTB=dst[get_global_id(0)*3*5+1];
TTC=dst[get_global_id(0)*3*5+2];
TTD=dst[get_global_id(0)*3*5+3];
TTE=dst[get_global_id(0)*3*5+4];
A=dst[get_global_id(0)*3*5+10];
B=dst[get_global_id(0)*3*5+11];
C=dst[get_global_id(0)*3*5+12];
D=dst[get_global_id(0)*3*5+13];
E=dst[get_global_id(0)*3*5+14];
IPA=input1[get_global_id(0)*2*5+0];
IPB=input1[get_global_id(0)*2*5+1];
IPC=input1[get_global_id(0)*2*5+2];
IPD=input1[get_global_id(0)*2*5+3];
IPE=input1[get_global_id(0)*2*5+4];
OPA=input1[get_global_id(0)*2*5+5];
OPB=input1[get_global_id(0)*2*5+6];
OPC=input1[get_global_id(0)*2*5+7];
OPD=input1[get_global_id(0)*2*5+8];
OPE=input1[get_global_id(0)*2*5+9];


// We now have the first HMAC. Iterate to find the rest
for (ic=str.sA;ic<str.sB;ic++)
{

// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint2)0x80;
SIZE=(uint2)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint2)0x80;
SIZE=(uint2)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
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

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


TTA ^= A;
TTB ^= B;
TTC ^= C;
TTD ^= D;
TTE ^= E;

}



dst[get_global_id(0)*3*5+0]=TTA;
dst[get_global_id(0)*3*5+1]=TTB;
dst[get_global_id(0)*3*5+2]=TTC;
dst[get_global_id(0)*3*5+3]=TTD;
dst[get_global_id(0)*3*5+4]=TTE;
dst[get_global_id(0)*3*5+10]=A;
dst[get_global_id(0)*3*5+11]=B;
dst[get_global_id(0)*3*5+12]=C;
dst[get_global_id(0)*3*5+13]=D;
dst[get_global_id(0)*3*5+14]=E;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final1( __global uint *dst,  __global uint2 *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*3*5+0];
TTTB=input1[get_global_id(0)*3*5+1];
TTTC=input1[get_global_id(0)*3*5+2];
TTTD=input1[get_global_id(0)*3*5+3];
TTTE=input1[get_global_id(0)*3*5+4];

/* Not used -->
TTA=input1[get_global_id(0)*3*5+5];
TTB=input1[get_global_id(0)*3*5+6];
TTC=input1[get_global_id(0)*3*5+7];
TTD=input1[get_global_id(0)*3*5+8];
TTE=input1[get_global_id(0)*3*5+9];
<-- */

dst[(get_global_id(0)*100)+(str.sC)*5]=TTTA.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+1]=TTTB.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+2]=TTTC.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+3]=TTTD.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+4]=TTTE.s0;

dst[(get_global_id(0)*100)+(str.sC)*5+50]=TTTA.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+1+50]=TTTB.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+2+50]=TTTC.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+3+50]=TTTD.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+4+50]=TTTE.s1;

}



#else


#endif




