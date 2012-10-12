#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
size[GGI] = (SIZE+str.sF)<<3;

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];


}




#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 (uint8)7
#define S12 (uint8)12
#define S13 (uint8)17
#define S14 (uint8)22
#define S21 (uint8)5
#define S22 (uint8)9
#define S23 (uint8)14
#define S24 (uint8)20
#define S31 (uint8)4
#define S32 (uint8)11
#define S33 (uint8)16
#define S34 (uint8)23
#define S41 (uint8)6
#define S42 (uint8)10
#define S43 (uint8)15
#define S44 (uint8)21

uint8 SIZE;
uint i ,ib ,ic ,id, ie;
uint8 mOne, mCa, mCb, mCc, mCd;
uint8 a,b,c,d, tmp1,tmp2;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16; 
uint8 x0,x1,x2,x3,x4,x5,x6,x7; 

uint8 mAC1 = (uint8)0xd76aa478; 
uint8 mAC2 = (uint8)0xe8c7b756; 
uint8 mAC3 = (uint8)0x242070db; 
uint8 mAC4 = (uint8)0xc1bdceee; 
uint8 mAC5 = (uint8)0xf57c0faf; 
uint8 mAC6 = (uint8)0x4787c62a; 
uint8 mAC7 = (uint8)0xa8304613; 
uint8 mAC8 = (uint8)0xfd469501; 
uint8 mAC9 = (uint8)0x698098d8; 
uint8 mAC10= (uint8)0x8b44f7af; 
uint8 mAC11= (uint8)0xffff5bb1; 
uint8 mAC12= (uint8)0x895cd7be; 
uint8 mAC13= (uint8)0x6b901122; 
uint8 mAC14= (uint8)0xfd987193; 
uint8 mAC15= (uint8)0xa679438e; 
uint8 mAC16= (uint8)0x49b40821; 
uint8 mAC17= (uint8)0xf61e2562; 
uint8 mAC18= (uint8)0xc040b340; 
uint8 mAC19= (uint8)0x265e5a51; 
uint8 mAC20= (uint8)0xe9b6c7aa; 
uint8 mAC21= (uint8)0xd62f105d; 
uint8 mAC22= (uint8)0x02441453; 
uint8 mAC23= (uint8)0xd8a1e681; 
uint8 mAC24= (uint8)0xe7d3fbc8; 
uint8 mAC25= (uint8)0x21e1cde6; 
uint8 mAC26= (uint8)0xc33707d6; 
uint8 mAC27= (uint8)0xf4d50d87; 
uint8 mAC28= (uint8)0x455a14ed; 
uint8 mAC29= (uint8)0xa9e3e905; 
uint8 mAC30= (uint8)0xfcefa3f8; 
uint8 mAC31= (uint8)0x676f02d9; 
uint8 mAC32= (uint8)0x8d2a4c8a; 
uint8 mAC33= (uint8)0xfffa3942; 
uint8 mAC34= (uint8)0x8771f681; 
uint8 mAC35= (uint8)0x6d9d6122; 
uint8 mAC36= (uint8)0xfde5380c; 
uint8 mAC37= (uint8)0xa4beea44; 
uint8 mAC38= (uint8)0x4bdecfa9; 
uint8 mAC39= (uint8)0xf6bb4b60; 
uint8 mAC40= (uint8)0xbebfbc70; 
uint8 mAC41= (uint8)0x289b7ec6; 
uint8 mAC42= (uint8)0xeaa127fa; 
uint8 mAC43= (uint8)0xd4ef3085; 
uint8 mAC44= (uint8)0x04881d05; 
uint8 mAC45= (uint8)0xd9d4d039; 
uint8 mAC46= (uint8)0xe6db99e5; 
uint8 mAC47= (uint8)0x1fa27cf8; 
uint8 mAC48= (uint8)0xc4ac5665; 
uint8 mAC49= (uint8)0xf4292244; 
uint8 mAC50= (uint8)0x432aff97; 
uint8 mAC51= (uint8)0xab9423a7; 
uint8 mAC52= (uint8)0xfc93a039; 
uint8 mAC53= (uint8)0x655b59c3; 
uint8 mAC54= (uint8)0x8f0ccc92; 
uint8 mAC55= (uint8)0xffeff47d; 
uint8 mAC56= (uint8)0x85845dd1; 
uint8 mAC57= (uint8)0x6fa87e4f; 
uint8 mAC58= (uint8)0xfe2ce6e0; 
uint8 mAC59= (uint8)0xa3014314; 
uint8 mAC60= (uint8)0x4e0811a1; 
uint8 mAC61= (uint8)0xf7537e82; 
uint8 mAC62= (uint8)0xbd3af235; 
uint8 mAC63= (uint8)0x2ad7d2bb; 
uint8 mAC64= (uint8)0xeb86d391; 


mCa  = (uint8)Ca;
mCb  = (uint8)Cb;
mCc  = (uint8)Cc;
mCd  = (uint8)Cd;

id=get_global_id(0);
SIZE.s0=size[id*8]; 
SIZE.s1=size[id*8+1]; 
SIZE.s2=size[id*8+2]; 
SIZE.s3=size[id*8+3]; 
SIZE.s4=size[id*8+4]; 
SIZE.s5=size[id*8+5]; 
SIZE.s6=size[id*8+6]; 
SIZE.s7=size[id*8+7]; 


x0.s0=input[id*8*8];
x1.s0=input[id*8*8+1];
x2.s0=input[id*8*8+2];
x3.s0=input[id*8*8+3];
x4.s0=input[id*8*8+4];
x5.s0=input[id*8*8+5];
x6.s0=input[id*8*8+6];
x7.s0=input[id*8*8+7];
x0.s1=input[id*8*8+8];
x1.s1=input[id*8*8+9];
x2.s1=input[id*8*8+10];
x3.s1=input[id*8*8+11];
x4.s1=input[id*8*8+12];
x5.s1=input[id*8*8+13];
x6.s1=input[id*8*8+14];
x7.s1=input[id*8*8+15];
x0.s2=input[id*8*8+16];
x1.s2=input[id*8*8+17];
x2.s2=input[id*8*8+18];
x3.s2=input[id*8*8+19];
x4.s2=input[id*8*8+20];
x5.s2=input[id*8*8+21];
x6.s2=input[id*8*8+22];
x7.s2=input[id*8*8+23];
x0.s3=input[id*8*8+24];
x1.s3=input[id*8*8+25];
x2.s3=input[id*8*8+26];
x3.s3=input[id*8*8+27];
x4.s3=input[id*8*8+28];
x5.s3=input[id*8*8+29];
x6.s3=input[id*8*8+30];
x7.s3=input[id*8*8+31];
x0.s4=input[id*8*8+32];
x1.s4=input[id*8*8+33];
x2.s4=input[id*8*8+34];
x3.s4=input[id*8*8+35];
x4.s4=input[id*8*8+36];
x5.s4=input[id*8*8+37];
x6.s4=input[id*8*8+38];
x7.s4=input[id*8*8+39];
x0.s5=input[id*8*8+40];
x1.s5=input[id*8*8+41];
x2.s5=input[id*8*8+42];
x3.s5=input[id*8*8+43];
x4.s5=input[id*8*8+44];
x5.s5=input[id*8*8+45];
x6.s5=input[id*8*8+46];
x7.s5=input[id*8*8+47];
x0.s6=input[id*8*8+48];
x1.s6=input[id*8*8+49];
x2.s6=input[id*8*8+50];
x3.s6=input[id*8*8+51];
x4.s6=input[id*8*8+52];
x5.s6=input[id*8*8+53];
x6.s6=input[id*8*8+54];
x7.s6=input[id*8*8+55];
x0.s7=input[id*8*8+56];
x1.s7=input[id*8*8+57];
x2.s7=input[id*8*8+58];
x3.s7=input[id*8*8+59];
x4.s7=input[id*8*8+60];
x5.s7=input[id*8*8+61];
x6.s7=input[id*8*8+62];
x7.s7=input[id*8*8+63];



a = mCa; b = mCb; c = mCc; d = mCd;  

#ifndef GCN
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif


MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);
MD5STEP_ROUND1(d, a, b, c, mAC2, x1, S12);
MD5STEP_ROUND1(c, d, a, b, mAC3, x2, S13);
MD5STEP_ROUND1(b, c, d, a, mAC4, x3, S14);
MD5STEP_ROUND1(a, b, c, d, mAC5, x4, S11);
MD5STEP_ROUND1(d, a, b, c, mAC6, x5, S12);
MD5STEP_ROUND1(c, d, a, b, mAC7, x6, S13);
MD5STEP_ROUND1(b, c, d, a, mAC8, x7, S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC9, S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC10, S12);
MD5STEP_ROUND1_NULL(c, d, a, b, mAC11, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12, S14);  
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13, S11);  
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);  
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);  


MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22); 
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);  
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21); 
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22); 
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23); 
MD5STEP_ROUND2(b, c, d, a, mAC24, x4, S24); 
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21); 
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);  
MD5STEP_ROUND2_NULL(b, c, d, a, mAC28, S24); 
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23); 
MD5STEP_ROUND2_NULL(b, c, d, a, mAC32, S24);  

#define MD5STEP_ROUND3(a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND3(a, b, c, d, mAC33, x5, S31);
MD5STEP_ROUND3_NULL(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL(c, d, a, b, mAC35, S33);
MD5STEP_ROUND3(b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3(a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3(d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3(c, d, a, b, mAC39, x7, S33);
MD5STEP_ROUND3_NULL (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC41, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3(b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL (d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC47, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44); 
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);  
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43); 
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);  
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41); 
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);  
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43); 
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);  
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41); 

#ifdef SINGLE_MODE
id=singlehash.x - mCa.s0;
if (all((uint8)id != a)) return;
#endif

MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44); 

a=a+mCa;
b=b+mCb;
c=c+mCc;
d=d+mCd; 

id = 0;

#ifdef SINGLE_MODE
if (all((uint8)singlehash.x!=a)) return;
if (all((uint8)singlehash.y!=b)) return;
if (all((uint8)singlehash.z!=c)) return;

#else
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s4;b2=b.s4;b3=c.s4;b4=d.s4;
b5=(singlehash.x >> (b.s4&31))&1;
b6=(singlehash.y >> (c.s4&31))&1;
b7=(singlehash.z >> (d.s4&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s5;b2=b.s5;b3=c.s5;b4=d.s5;
b5=(singlehash.x >> (b.s5&31))&1;
b6=(singlehash.y >> (c.s5&31))&1;
b7=(singlehash.z >> (d.s5&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s6;b2=b.s6;b3=c.s6;b4=d.s6;
b5=(singlehash.x >> (b.s6&31))&1;
b6=(singlehash.y >> (c.s6&31))&1;
b7=(singlehash.z >> (d.s6&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s7;b2=b.s7;b3=c.s7;b4=d.s7;
b5=(singlehash.x >> (b.s7&31))&1;
b6=(singlehash.y >> (c.s7&31))&1;
b7=(singlehash.z >> (d.s7&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)*8)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*8)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*8)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*8)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
dst[(get_global_id(0)*8)+4] = (uint4)(a.s4,b.s4,c.s4,d.s4);
dst[(get_global_id(0)*8)+5] = (uint4)(a.s5,b.s5,c.s5,d.s5);
dst[(get_global_id(0)*8)+6] = (uint4)(a.s6,b.s6,c.s6,d.s6);
dst[(get_global_id(0)*8)+7] = (uint4)(a.s7,b.s7,c.s7,d.s7);

}

#else
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash) 
{


#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 (uint4)7
#define S12 (uint4)12
#define S13 (uint4)17
#define S14 (uint4)22
#define S21 (uint4)5
#define S22 (uint4)9
#define S23 (uint4)14
#define S24 (uint4)20
#define S31 (uint4)4
#define S32 (uint4)11
#define S33 (uint4)16
#define S34 (uint4)23
#define S41 (uint4)6
#define S42 (uint4)10
#define S43 (uint4)15
#define S44 (uint4)21

uint4 SIZE;
uint i ,ib ,ic ,id, ie;
uint4 mOne, mCa, mCb, mCc, mCd;
uint4 a,b,c,d, tmp1,tmp2;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16; 
uint4 x0 ,x1 ,x2 ,x3 ; 

uint4 mAC1 = (uint4)0xd76aa478; 
uint4 mAC2 = (uint4)0xe8c7b756; 
uint4 mAC3 = (uint4)0x242070db; 
uint4 mAC4 = (uint4)0xc1bdceee; 
uint4 mAC5 = (uint4)0xf57c0faf; 
uint4 mAC6 = (uint4)0x4787c62a; 
uint4 mAC7 = (uint4)0xa8304613; 
uint4 mAC8 = (uint4)0xfd469501; 
uint4 mAC9 = (uint4)0x698098d8; 
uint4 mAC10= (uint4)0x8b44f7af; 
uint4 mAC11= (uint4)0xffff5bb1; 
uint4 mAC12= (uint4)0x895cd7be; 
uint4 mAC13= (uint4)0x6b901122; 
uint4 mAC14= (uint4)0xfd987193; 
uint4 mAC15= (uint4)0xa679438e; 
uint4 mAC16= (uint4)0x49b40821; 
uint4 mAC17= (uint4)0xf61e2562; 
uint4 mAC18= (uint4)0xc040b340; 
uint4 mAC19= (uint4)0x265e5a51; 
uint4 mAC20= (uint4)0xe9b6c7aa; 
uint4 mAC21= (uint4)0xd62f105d; 
uint4 mAC22= (uint4)0x02441453; 
uint4 mAC23= (uint4)0xd8a1e681; 
uint4 mAC24= (uint4)0xe7d3fbc8; 
uint4 mAC25= (uint4)0x21e1cde6; 
uint4 mAC26= (uint4)0xc33707d6; 
uint4 mAC27= (uint4)0xf4d50d87; 
uint4 mAC28= (uint4)0x455a14ed; 
uint4 mAC29= (uint4)0xa9e3e905; 
uint4 mAC30= (uint4)0xfcefa3f8; 
uint4 mAC31= (uint4)0x676f02d9; 
uint4 mAC32= (uint4)0x8d2a4c8a; 
uint4 mAC33= (uint4)0xfffa3942; 
uint4 mAC34= (uint4)0x8771f681; 
uint4 mAC35= (uint4)0x6d9d6122; 
uint4 mAC36= (uint4)0xfde5380c; 
uint4 mAC37= (uint4)0xa4beea44; 
uint4 mAC38= (uint4)0x4bdecfa9; 
uint4 mAC39= (uint4)0xf6bb4b60; 
uint4 mAC40= (uint4)0xbebfbc70; 
uint4 mAC41= (uint4)0x289b7ec6; 
uint4 mAC42= (uint4)0xeaa127fa; 
uint4 mAC43= (uint4)0xd4ef3085; 
uint4 mAC44= (uint4)0x04881d05; 
uint4 mAC45= (uint4)0xd9d4d039; 
uint4 mAC46= (uint4)0xe6db99e5; 
uint4 mAC47= (uint4)0x1fa27cf8; 
uint4 mAC48= (uint4)0xc4ac5665; 
uint4 mAC49= (uint4)0xf4292244; 
uint4 mAC50= (uint4)0x432aff97; 
uint4 mAC51= (uint4)0xab9423a7; 
uint4 mAC52= (uint4)0xfc93a039; 
uint4 mAC53= (uint4)0x655b59c3; 
uint4 mAC54= (uint4)0x8f0ccc92; 
uint4 mAC55= (uint4)0xffeff47d; 
uint4 mAC56= (uint4)0x85845dd1; 
uint4 mAC57= (uint4)0x6fa87e4f; 
uint4 mAC58= (uint4)0xfe2ce6e0; 
uint4 mAC59= (uint4)0xa3014314; 
uint4 mAC60= (uint4)0x4e0811a1; 
uint4 mAC61= (uint4)0xf7537e82; 
uint4 mAC62= (uint4)0xbd3af235; 
uint4 mAC63= (uint4)0x2ad7d2bb; 
uint4 mAC64= (uint4)0xeb86d391; 



mOne  = (uint4)0xFFFFFFFF;
mCa  = (uint4)Ca;
mCb  = (uint4)Cb;
mCc  = (uint4)Cc;
mCd  = (uint4)Cd;

id=get_global_id(0);
/*
SIZE.s0=size[id*8]; 
SIZE.s1=size[id*8+1]; 
SIZE.s2=size[id*8+2]; 
SIZE.s3=size[id*8+3]; 
*/
SIZE.s0=size[id];

/*
x0.s0=input[id*8*4];
x1.s0=input[id*8*4+1];
x2.s0=input[id*8*4+2];
x3.s0=input[id*8*4+3];

x0.s1=input[id*8*4+4];
x1.s1=input[id*8*4+5];
x2.s1=input[id*8*4+6];
x3.s1=input[id*8*4+7];

x0.s2=input[id*8*4+8];
x1.s2=input[id*8*4+9];
x2.s2=input[id*8*4+10];
x3.s2=input[id*8*4+11];

x0.s3=input[id*8*4+12];
x1.s3=input[id*8*4+13];
x2.s3=input[id*8*4+14];
x3.s3=input[id*8*4+15];
*/
x0.s0=input[id];
//Endian_Reverse32(x0);
x1.s0=input[id+1];
x2.s0=input[id+2];
x3.s0=input[id+3];



a = mCa; b = mCb; c = mCc; d = mCd;  


#define MD5STEP_ROUND1(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);
#define MD5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
MD5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);
MD5STEP_ROUND1(F, d, a, b, c, mAC2, x1, S12);
MD5STEP_ROUND1(F, c, d, a, b, mAC3, x2, S13);
MD5STEP_ROUND1(F, b, c, d, a, mAC4, x3, S14);
MD5STEP_ROUND1_NULL(F, a, b, c, d, mAC5, S11);
MD5STEP_ROUND1_NULL(F, d, a, b, c, mAC6, S12);
MD5STEP_ROUND1_NULL(F, c, d, a, b, mAC7, S13);
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC8, S14);
MD5STEP_ROUND1_NULL(F, a, b, c, d, mAC9, S11);
MD5STEP_ROUND1_NULL(F, d, a, b, c, mAC10, S12);
MD5STEP_ROUND1_NULL(F, c, d, a, b, mAC11, S13);  
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC12, S14);  
MD5STEP_ROUND1_NULL(F, a, b, c, d, mAC13, S11);  
MD5STEP_ROUND1_NULL(F, d, a, b, c, mAC14, S12);  
MD5STEP_ROUND1 (F, c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14);  


#define MD5STEP_ROUND2(f, a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
MD5STEP_ROUND2 (G, a, b, c, d, mAC17, x1, S21);  
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC18, S22); 
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23); 
MD5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24);  
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC21, S21); 
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22); 
MD5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23); 
MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC24, S24); 
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21); 
MD5STEP_ROUND2 (G, d, a, b, c, mAC26, SIZE, S22);
MD5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23);  
MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC28, S24); 
MD5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21);  
MD5STEP_ROUND2 (G, d, a, b, c, mAC30, x2, S22);  
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC31, S23); 
MD5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24);  

#define MD5STEP_ROUND3(f, a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND3_NULL(H, a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL(H, d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL (H, c, d, a, b, mAC35, S33);
MD5STEP_ROUND3 (H, b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3 (H, a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_NULL (H, d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL (H, c, d, a, b, mAC39, S33);
MD5STEP_ROUND3_NULL (H, b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL (H, a, b, c, d, mAC41, S31);
MD5STEP_ROUND3 (H, d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3 (H, c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL (H, b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL (H, a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL (H, d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL (H, c, d, a, b, mAC47, S33);
MD5STEP_ROUND3 (H, b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(f, a, b, c, d, AC, x, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND4_NULL(f, a, b, c, d, AC, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 

MD5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41);  
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC50, S42); 
MD5STEP_ROUND4 (I, c, d, a, b, mAC51, SIZE, S43);
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC52, S44); 
MD5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41);  
MD5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42);  
MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43); 
MD5STEP_ROUND4 (I, b, c, d, a, mAC56, x1, S44);  
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC57, S41); 
MD5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42);  
MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC59, S43); 
MD5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44);  
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC61, S41); 

#ifdef SINGLE_MODE
id=singlehash.x - mCa.s0;
if (all((uint4)id != a)) return;
#endif

MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42); 
MD5STEP_ROUND4 (I, c, d, a, b, mAC63, x2, S43);  
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44); 

a=a+mCa;
b=b+mCb;
c=c+mCc;
d=d+mCd; 

id = 0;

#ifdef SINGLE_MODE
if ((singlehash.x==a.s0)&&(singlehash.y==b.s0)&&(singlehash.z==c.s0)&&(singlehash.w==d.s0)) id = 1; 
if ((singlehash.x==a.s1)&&(singlehash.y==b.s1)&&(singlehash.z==c.s1)&&(singlehash.w==d.s1)) id = 1; 
if ((singlehash.x==a.s2)&&(singlehash.y==b.s2)&&(singlehash.z==c.s2)&&(singlehash.w==d.s2)) id = 1; 
if ((singlehash.x==a.s3)&&(singlehash.y==b.s3)&&(singlehash.z==c.s3)&&(singlehash.w==d.s3)) id = 1; 
if (id==0) return;

#else
id = 0;

b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)*4)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*4)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*4)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}

#endif