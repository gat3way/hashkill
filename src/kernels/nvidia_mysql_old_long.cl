#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))


#ifdef SM21


__kernel void mysql_old( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global  uint *table,  uint4 singlehash) 
{  


#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
#define m 0x00FF00FF
#define m2 0xFF00FF00
#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

uint4 l;  
uint i,ib,ic,id,b1,b2,b3;  
uint4 mOne;
uint4 a,b,c,d, tmp,tmp1,tmp2,A,B,chbase1; 

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



#else


__kernel void mysql_old( __global uint2 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global  uint *table,  uint4 singlehash) 
{  


#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
#define m 0x00FF00FF
#define m2 0xFF00FF00
#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 

uint l;  
uint i,ib,ic,id,b1,b2,b3;  
uint mOne;
uint a,b,c,d, tmp,tmp1,tmp2,A,B,chbase1; 

chbase1=(uint)(chbase.s0);
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
if (((uint)(singlehash.x)!=A)) return;
B=b&0x7FFFFFFF;
Endian_Reverse32(B);

if ((singlehash.x==A)&&(singlehash.y==B)) id=1;
if (id==0) return;
#endif

#ifndef SINGLE_MODE

id = 0;
b1=A;b2=B;
b3=(singlehash.x >> (B&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0))] = (uint2)(A,B);

}

#endif
