#ifndef OLD_ATI

#pragma OPENCL EXTENSION cl_amd_media_ops : enable

mysql_old1( __global uint4 *dst, uint4 input, uint size, uint8 chbase,  __global uint *found_ind, __global  uint *bitmaps, __global uint *found, uint i, uint4 singlehash, uint8 precalc, uint factor) 
{  

#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
//#define m 0x00FF00FF
//#define m2 0xFF00FF00
uint8 m = 0x00FF00FF;
m = m;

#ifndef GCN
#ifdef OLD_ATI
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 
#else
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=bitselect(tmp2,tmp1,m); }
#endif
#else
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=bitselect(tmp2,tmp1,m); }
#endif


uint ib,ic,id,b1,b2,b3;  
uint8 a,b,c,d,tmp,tmp1,tmp2,A,B; 
uint8 l; 
uint8 a1,a2,a3,a4; 

ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

a = input.x;
b = input.y;
c = input.z;

//a1 = a ^ (mad24(((a & 63) + c), chbase,  (a << 8)));
a1 = precalc;
c += chbase;
a2 = a1 ^ (mad24(((a1 & 63) + c), ib,  (a1 << 8)));
c += ib;
a3 = a2 ^ (mad24(((a2 & 63) + c), ic,  (a2 << 8)));
c += ic;
a4 = a3 ^ (mad24(((a3 & 63) + c), id,  (a3 << 8)));


A=a4&0x7FFFFFFF;
Endian_Reverse32(A);

#ifdef SINGLE_MODE
id = 0;
if (all((uint8)(singlehash.x)!=A)) return;
#endif

b += (b << 8) ^ a1;
b += (b << 8) ^ a2;
b += (b << 8) ^ a3;
b += (b << 8) ^ a4;

B=b&0x7FFFFFFF;
Endian_Reverse32(B);

#ifdef SINGLE_MODE
if (all((uint8)(singlehash.y)!=B)) return;
id=1;
#endif

#ifndef SINGLE_MODE

id = 0;
b1=A.s0;b2=B.s0;
b3=(singlehash.x >> (B.s0&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s1;b2=B.s1;
b3=(singlehash.x >> (B.s1&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s2;b2=B.s2;
b3=(singlehash.x >> (B.s2&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s3;b2=B.s3;
b3=(singlehash.x >> (B.s3&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}


#ifdef DOUBLE
dst[(get_global_id(0)<<3)+factor] = (uint4)(A.s0,B.s0,A.s1,B.s1);
dst[(get_global_id(0)<<3)+1+factor] = (uint4)(A.s2,B.s2,A.s3,B.s3);
dst[(get_global_id(0)<<3)+2+factor] = (uint4)(A.s4,B.s4,A.s5,B.s5);
dst[(get_global_id(0)<<3)+3+factor] = (uint4)(A.s6,B.s6,A.s7,B.s7);
#else
dst[(get_global_id(0)<<2)] = (uint4)(A.s0,B.s0,A.s1,B.s1);
dst[(get_global_id(0)<<2)+1] = (uint4)(A.s2,B.s2,A.s3,B.s3);
dst[(get_global_id(0)<<2)+2] = (uint4)(A.s4,B.s4,A.s5,B.s5);
dst[(get_global_id(0)<<2)+3] = (uint4)(A.s6,B.s6,A.s7,B.s7);
#endif


}


__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
mysql_old( __global uint4 *dst, uint4 input, uint size, uint16 chbase,  __global uint *found_ind, __global  uint *bitmaps, __global uint *found, __global  uint *table, uint4 singlehash, uint16 precalc) 
{
uint i;
uint8 chbase1, precalc1, precalc2;
i = table[get_global_id(0)];

chbase1 = (uint8)(chbase.s0,chbase.s1,chbase.s2,chbase.s3,chbase.s4,chbase.s5,chbase.s6,chbase.s7);

precalc1 = (uint8)(precalc.s0,precalc.s1,precalc.s2,precalc.s3,precalc.s4,precalc.s5,precalc.s6,precalc.s7);
precalc2 = (uint8)(precalc.s8,precalc.s9,precalc.sA,precalc.sB,precalc.sC,precalc.sD,precalc.sE,precalc.sF);

mysql_old1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,precalc1,0);
#ifdef DOUBLE
chbase1 = (uint8)(chbase.s8,chbase.s9,chbase.sA,chbase.sB,chbase.sC,chbase.sD,chbase.sE,chbase.sF);
precalc1 = (uint8)(precalc.s8,precalc.s9,precalc.sA,precalc.sB,precalc.sC,precalc.sD,precalc.sE,precalc.sF);
mysql_old1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,precalc1,4);
#endif

}


#else


__kernel void mysql_old( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global  uint *table,  uint4 singlehash) 
{  


#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
#define m 0x00FF00FF
#define m2 0xFF00FF00
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

uint4 l;  
uint i,ib,ic,id,b1,b2,b3;  
uint4 mOne;
uint4 a,b,c,d, tmp,tmp1,tmp2,A,B,chbase1; 
chbase1=(uint4)(chbase.s4,chbase.s5,chbase.s6,chbase.s7);
chbase1+=(uint4)(chbase.s8,chbase.s9,chbase.sA,chbase.sB);
chbase1+=(uint4)(chbase.sC,chbase.sD,chbase.sE,chbase.sF);
chbase1>>=8;

chbase1=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);
i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

a = input.x;
b = input.y;
c = input.z;


a = a ^ (mad24(((a & 63) + c), chbase1,  (a << 8)));
b += (b << 8) ^ a;
c += chbase1;
a = a ^ (mad24(((a & 63) + c), ib,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
a = a ^ (mad24(((a & 63) + c), ic,  (a << 8)));
b += (b << 8) ^ a;
c += ic;
a = a ^ (mad24(((a & 63) + c), id,  (a << 8)));
b += (b << 8) ^ a;
c += id;
A=a&0x7FFFFFFF;

Endian_Reverse32(A);


#ifdef SINGLE_MODE
id = 0;
if (all((uint4)(singlehash.x)!=A)) return;
B=b&0x7FFFFFFF;
Endian_Reverse32(B);

if ((singlehash.x==A.s0)&&(singlehash.y==B.s0)) id=1;
if ((singlehash.x==A.s1)&&(singlehash.y==B.s1)) id=1;
if ((singlehash.x==A.s2)&&(singlehash.y==B.s2)) id=1;
if ((singlehash.x==A.s3)&&(singlehash.y==B.s3)) id=1;
if (id==0) return;
#endif

#ifndef SINGLE_MODE

id = 0;
b1=A.s0;b2=B.s0;
b3=(singlehash.x >> (B.s0&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s1;b2=B.s1;
b3=(singlehash.x >> (B.s1&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s2;b2=B.s2;
b3=(singlehash.x >> (B.s2&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s3;b2=B.s3;
b3=(singlehash.x >> (B.s3&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)<<1)] = (uint4)(A.s0,B.s0,A.s1,B.s1);
dst[(get_global_id(0)<<1)+1] = (uint4)(A.s2,B.s2,A.s3,B.s3);

}

#endif
