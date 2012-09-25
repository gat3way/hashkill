#ifndef OLD_ATI
void mysql_old_markov1( __global uint4 *dst, uint4 input, uint size,  uint8 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint factor) 
{  

#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
#define m 0x00FF00FF
#define m2 0xFF00FF00
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

uint8 l;  
uint ib,ic,id,b1,b2,b3;  
uint8 mOne;
uint8 a,b,c,d, tmp,tmp1,tmp2,A,B; 

ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

if (size==1)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==2)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==3)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==4)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += ((b << 8) ^ a)+b;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b = ((b << 8) ^ a)+b;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==5)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==6)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.z&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
}

else if (size==7)
{
a = (uint8)nr;
b = (uint8)nr2;
c = (uint8)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.z&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.z>>8)&255;

a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;

A=a & ((1 << 31) - 1);
B=b & ((1 << 31) -1);
}

Endian_Reverse32(A);
Endian_Reverse32(B);



#ifdef SINGLE_MODE
id = 0;
if ((singlehash.x==A.s0)&&(singlehash.y==B.s0)) id=1;
if ((singlehash.x==A.s1)&&(singlehash.y==B.s1)) id=1;
if ((singlehash.x==A.s2)&&(singlehash.y==B.s2)) id=1;
if ((singlehash.x==A.s3)&&(singlehash.y==B.s3)) id=1;
if ((singlehash.x==A.s4)&&(singlehash.y==B.s4)) id=1;
if ((singlehash.x==A.s5)&&(singlehash.y==B.s5)) id=1;
if ((singlehash.x==A.s6)&&(singlehash.y==B.s6)) id=1;
if ((singlehash.x==A.s7)&&(singlehash.y==B.s7)) id=1;

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
b1=A.s4;b2=B.s4;
b3=(singlehash.x >> (B.s4&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s5;b2=B.s5;
b3=(singlehash.x >> (B.s5&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s6;b2=B.s6;
b3=(singlehash.x >> (B.s6&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) id=1;
b1=A.s7;b2=B.s7;
b3=(singlehash.x >> (B.s7&31))&1;
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

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
mysql_old_markov( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global  uint *table,  uint4 singlehash) 
{
uint i;
uint8 chbase1;
i = table[get_global_id(0)];
chbase1 = (uint8)(chbase.s8,chbase.s9,chbase.sA,chbase.sB,chbase.sC,chbase.sD,chbase.sE,chbase.sF);
chbase1>>=24;
chbase1 += (uint8)(chbase.s0,chbase.s1,chbase.s2,chbase.s3,chbase.s4,chbase.s5,chbase.s6,chbase.s7);
mysql_old_markov1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,0);
#ifdef DOUBLE
chbase1 = (uint8)(chbase.s8,chbase.s9,chbase.sA,chbase.sB,chbase.sC,chbase.sD,chbase.sE,chbase.sF);
mysql_old_markov1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,4);
#endif


}


#else

__kernel void mysql_old_markov( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global  uint *table,  uint4 singlehash) 
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
uint4 mOne,chbase1;
uint4 a,b,c,d, tmp,tmp1,tmp2,A,B; 
chbase1=(uint4)(chbase.s4,chbase.s5,chbase.s6,chbase.s7)
+(uint4)(chbase.s8,chbase.s9,chbase.sA,chbase.sB)
+(uint4)(chbase.sC,chbase.sD,chbase.sE,chbase.sF);
chbase1>>=8;
chbase1+=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);

i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  


if (size==1)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==2)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==3)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==4)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==5)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==6)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.z&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}

if (size==7)
{
a = (uint4)nr;
b = (uint4)nr2;
c = (uint4)add;
tmp = ib;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += ib;
tmp = ic;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = id;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = chbase1;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.y&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>16)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.y>>24)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = input.z&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
tmp = (input.z>>8)&255;
a = a ^ (mad24(((a & 63) + c), tmp,  (a << 8)));
b += (b << 8) ^ a;
c += tmp;
A=a & ((1L << 31) - 1L);
B=b & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);
}




#ifdef SINGLE_MODE
id = 0;
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