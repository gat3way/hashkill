#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#endif

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
mysql_old( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{


#define nr 1345345333L
#define add 7
#define nr2 0x12345671L
#define Sl 8
#define Sr 24
#define m (uint8)0x00FF00FF
#define m2 (uint8)0xFF00FF00


uint i,ie,b1,b2,b3,b4,b5,b6,b7;  
uint ia,ib,ic,id;
uint8 a,b,c,d,tmp,tmp1,tmp2,A,B; 
uint8 l; 
uint8 a1,a2,a3,a4,SIZE; 
uint8 x[8];

#ifndef GCN
#ifdef OLD_ATI
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=(tmp1 & m)|(tmp2 & m2); } 
#else
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=bitselect(tmp2,tmp1,m); }
#endif
#else
#define Endian_Reverse32(a) { l=(a);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (a)=bitselect(tmp2,tmp1,m); }
#endif


ie=get_global_id(0);
SIZE.s0=size[ie*8]; 
SIZE.s1=size[ie*8+1]; 
SIZE.s2=size[ie*8+2]; 
SIZE.s3=size[ie*8+3]; 
SIZE.s4=size[ie*8+4]; 
SIZE.s5=size[ie*8+5]; 
SIZE.s6=size[ie*8+6]; 
SIZE.s7=size[ie*8+7]; 


x[0].s0=input[ie*8*8];
x[1].s0=input[ie*8*8+1];
x[2].s0=input[ie*8*8+2];
x[3].s0=input[ie*8*8+3];
x[4].s0=input[ie*8*8+4];
x[5].s0=input[ie*8*8+5];
x[6].s0=input[ie*8*8+6];
x[7].s0=input[ie*8*8+7];
x[0].s1=input[ie*8*8+8];
x[1].s1=input[ie*8*8+9];
x[2].s1=input[ie*8*8+10];
x[3].s1=input[ie*8*8+11];
x[4].s1=input[ie*8*8+12];
x[5].s1=input[ie*8*8+13];
x[6].s1=input[ie*8*8+14];
x[7].s1=input[ie*8*8+15];
x[0].s2=input[ie*8*8+16];
x[1].s2=input[ie*8*8+17];
x[2].s2=input[ie*8*8+18];
x[3].s2=input[ie*8*8+19];
x[4].s2=input[ie*8*8+20];
x[5].s2=input[ie*8*8+21];
x[6].s2=input[ie*8*8+22];
x[7].s2=input[ie*8*8+23];
x[0].s3=input[ie*8*8+24];
x[1].s3=input[ie*8*8+25];
x[2].s3=input[ie*8*8+26];
x[3].s3=input[ie*8*8+27];
x[4].s3=input[ie*8*8+28];
x[5].s3=input[ie*8*8+29];
x[6].s3=input[ie*8*8+30];
x[7].s3=input[ie*8*8+31];
x[0].s4=input[ie*8*8+32];
x[1].s4=input[ie*8*8+33];
x[2].s4=input[ie*8*8+34];
x[3].s4=input[ie*8*8+35];
x[4].s4=input[ie*8*8+36];
x[5].s4=input[ie*8*8+37];
x[6].s4=input[ie*8*8+38];
x[7].s4=input[ie*8*8+39];
x[0].s5=input[ie*8*8+40];
x[1].s5=input[ie*8*8+41];
x[2].s5=input[ie*8*8+42];
x[3].s5=input[ie*8*8+43];
x[4].s5=input[ie*8*8+44];
x[5].s5=input[ie*8*8+45];
x[6].s5=input[ie*8*8+46];
x[7].s5=input[ie*8*8+47];
x[0].s6=input[ie*8*8+48];
x[1].s6=input[ie*8*8+49];
x[2].s6=input[ie*8*8+50];
x[3].s6=input[ie*8*8+51];
x[4].s6=input[ie*8*8+52];
x[5].s6=input[ie*8*8+53];
x[6].s6=input[ie*8*8+54];
x[7].s6=input[ie*8*8+55];
x[0].s7=input[ie*8*8+56];
x[1].s7=input[ie*8*8+57];
x[2].s7=input[ie*8*8+58];
x[3].s7=input[ie*8*8+59];
x[4].s7=input[ie*8*8+60];
x[5].s7=input[ie*8*8+61];
x[6].s7=input[ie*8*8+62];
x[7].s7=input[ie*8*8+63];


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
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s4;i++)
{
ia = ((x[i>>2].s4)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s4=ib;
B.s4=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s5;i++)
{
ia = ((x[i>>2].s5)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s5=ib;
B.s5=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s6;i++)
{
ia = ((x[i>>2].s6)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s6=ib;
B.s6=id;
ib=(uint)nr;
ic=(uint)add;
id=(uint)nr2;
for (i=0;i<SIZE.s7;i++)
{
ia = ((x[i>>2].s7)>>((i&3)<<3))&255;
ib  ^= (((ib & 63) + ic) * ia) + (ib << 8);
id += (id << 8) ^ ib;
ic += ia;
}
A.s7=ib;
B.s7=id;

A=A & ((1L << 31) - 1L);
B=B & ((1L << 31) -1L);
Endian_Reverse32(A);
Endian_Reverse32(B);


#ifdef SINGLE_MODE
if (all((uint8)(singlehash.x)!=A)) return;
if (all((uint8)(singlehash.y)!=B)) return;
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

b1=A.s4;b2=B.s4;
b3=(singlehash.x >> (B.s4&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s5;b2=B.s5;
b3=(singlehash.x >> (B.s1&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s6;b2=B.s6;
b3=(singlehash.x >> (B.s2&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
b1=A.s7;b2=B.s7;
b3=(singlehash.x >> (B.s3&31))&1;
if (b3) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) ) ie=1;
if (ie==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;





dst[(get_global_id(0)<<2)] = (uint4)(A.s0,B.s0,A.s1,B.s1);
dst[(get_global_id(0)<<2)+1] = (uint4)(A.s2,B.s2,A.s3,B.s3);
dst[(get_global_id(0)<<2)+2] = (uint4)(A.s4,B.s4,A.s5,B.s5);
dst[(get_global_id(0)<<2)+3] = (uint4)(A.s6,B.s6,A.s7,B.s7);


}


