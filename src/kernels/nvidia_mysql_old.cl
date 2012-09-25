#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))


#ifdef SM21

__kernel void __attribute__((reqd_work_group_size(128, 1, 1))) 
mysql_old( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{


#define nr 1345345333
#define add 7
#define nr2 0x12345671
#define Sl 8
#define Sr 24
#define m (uint4)0x00FF00FF
#define m2 (uint4)0xFF00FF00


uint i,ie,b1,b2,b3,b4,b5,b6,b7;  
uint ia,ib,ic,id;
uint4 a,b,c,d,tmp,tmp1,tmp2,A,B; 
uint4 l; 
uint4 a1,a2,a3,a4,SIZE; 
__private uint4 x[8];

#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 



ie=get_global_id(0);
SIZE.s0=size[ie*4]; 
SIZE.s1=size[ie*4+1]; 
SIZE.s2=size[ie*4+2]; 
SIZE.s3=size[ie*4+3]; 


x[0].s0=input[ie*4*8];
x[1].s0=input[ie*4*8+1];
x[2].s0=input[ie*4*8+2];
x[3].s0=input[ie*4*8+3];
x[4].s0=input[ie*4*8+4];
x[5].s0=input[ie*4*8+5];
x[6].s0=input[ie*4*8+6];
x[7].s0=input[ie*4*8+7];
x[0].s1=input[ie*4*8+8];
x[1].s1=input[ie*4*8+9];
x[2].s1=input[ie*4*8+10];
x[3].s1=input[ie*4*8+11];
x[4].s1=input[ie*4*8+12];
x[5].s1=input[ie*4*8+13];
x[6].s1=input[ie*4*8+14];
x[7].s1=input[ie*4*8+15];
x[0].s2=input[ie*4*8+16];
x[1].s2=input[ie*4*8+17];
x[2].s2=input[ie*4*8+18];
x[3].s2=input[ie*4*8+19];
x[4].s2=input[ie*4*8+20];
x[5].s2=input[ie*4*8+21];
x[6].s2=input[ie*4*8+22];
x[7].s2=input[ie*4*8+23];
x[0].s3=input[ie*4*8+24];
x[1].s3=input[ie*4*8+25];
x[2].s3=input[ie*4*8+26];
x[3].s3=input[ie*4*8+27];
x[4].s3=input[ie*4*8+28];
x[5].s3=input[ie*4*8+29];
x[6].s3=input[ie*4*8+30];
x[7].s3=input[ie*4*8+31];


ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s0;i++)
{
ia = ((x[i>>2].s0)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s0=ib;
B.s0=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s1;i++)
{
ia = ((x[i>>2].s1)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s1=ib;
B.s1=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s2;i++)
{
ia = ((x[i>>2].s2)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s2=ib;
B.s2=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s3;i++)
{
ia = ((x[i>>2].s3)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s3=ib;
B.s3=id;

A=A & ((1 << 31) - 1);
B=B & ((1 << 31) -1);
Endian_Reverse32(A);
Endian_Reverse32(B);


#ifdef SINGLE_MODE
if (all((uint4)(singlehash.x)!=A)) return;
if (all((uint4)(singlehash.y)!=B)) return;
#endif


#ifndef SINGLE_MODE

ie = 0;
b1=A.s0;b2=B.s0;
b3=(singlehash.x >> (B.s0&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s1;b2=B.s1;
b3=(singlehash.x >> (B.s1&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s2;b2=B.s2;
b3=(singlehash.x >> (B.s2&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s3;b2=B.s3;
b3=(singlehash.x >> (B.s3&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
if (ie==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;



dst[(get_global_id(0)<<1)] = (uint4)(A.s0,B.s0,A.s1,B.s1);
dst[(get_global_id(0)<<1)+1] = (uint4)(A.s2,B.s2,A.s3,B.s3);


}


#else


__kernel void __attribute__((reqd_work_group_size(128, 1, 1))) 
mysql_old( __global uint2 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{


#define nr 1345345333
#define add 7
#define nr2 0x12345671
#define Sl 8
#define Sr 24
#define m (uint)0x00FF00FF
#define m2 (uint)0xFF00FF00


uint i,ie,b1,b2,b3,b4,b5,b6,b7;  
uint ia,ib,ic,id;
uint a,b,c,d,tmp,tmp1,tmp2,A,B; 
uint l; 
uint a1,a2,a3,a4,SIZE; 
__private uint x[8];

#define Endian_Reverse32(a) { l=(a);tmp1=ROTATE(l,Sl);tmp2=ROTATE(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 



ie=get_global_id(0);
SIZE=size[ie]; 


x[0]=input[ie*8];
x[1]=input[ie*8+1];
x[2]=input[ie*8+2];
x[3]=input[ie*8+3];
x[4]=input[ie*8+4];
x[5]=input[ie*8+5];
x[6]=input[ie*8+6];
x[7]=input[ie*8+7];


ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE;i++)
{
ia = ((x[i>>2])>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A=ib;
B=id;

A=A & ((1 << 31) - 1);
B=B & ((1 << 31) -1);
Endian_Reverse32(A);
Endian_Reverse32(B);


#ifdef SINGLE_MODE
if (all((uint)(singlehash.x)!=A)) return;
if (all((uint)(singlehash.y)!=B)) return;
#endif


#ifndef SINGLE_MODE

ie = 0;
b1=A;b2=B;
b3=(singlehash.x >> (B&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
if (ie==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;



dst[(get_global_id(0))] = (uint2)(A,B);


}



#endif