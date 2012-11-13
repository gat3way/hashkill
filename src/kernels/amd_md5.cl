#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }


#ifndef GCN

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1, uint16 str2) 
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
__local uint inpc[64][14];
uint elem,t1;
uint w0,w1,w2,w3,w4,w5,w6,w7;

mCa  = (uint8)Ca;
mCb  = (uint8)Cb;
mCc  = (uint8)Cc;
mCd  = (uint8)Cd;

id=get_global_id(0);
SIZE=(uint8)sizein[GGI];
w0 = inp[GGI*8+0];
w1 = inp[GGI*8+1];
w2 = inp[GGI*8+2];
w3 = inp[GGI*8+3];
w4 = inp[GGI*8+4];
w5 = inp[GGI*8+5];
w6 = inp[GGI*8+6];
w7 = inp[GGI*8+7];


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str.s0,SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC),0);
x0.s0=inpc[GLI][0];
x1.s0=inpc[GLI][1];
x2.s0=inpc[GLI][2];
x3.s0=inpc[GLI][3];
x4.s0=inpc[GLI][4];
x5.s0=inpc[GLI][5];
x6.s0=inpc[GLI][6];
x7.s0=inpc[GLI][7];
SIZE.s0 = (SIZE.s0+str.sC)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str.s4,SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD),0);
x0.s1=inpc[GLI][0];
x1.s1=inpc[GLI][1];
x2.s1=inpc[GLI][2];
x3.s1=inpc[GLI][3];
x4.s1=inpc[GLI][4];
x5.s1=inpc[GLI][5];
x6.s1=inpc[GLI][6];
x7.s1=inpc[GLI][7];
SIZE.s1 = (SIZE.s1+str.sD)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str.s8,SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE),0);
x0.s2=inpc[GLI][0];
x1.s2=inpc[GLI][1];
x2.s2=inpc[GLI][2];
x3.s2=inpc[GLI][3];
x4.s2=inpc[GLI][4];
x5.s2=inpc[GLI][5];
x6.s2=inpc[GLI][6];
x7.s2=inpc[GLI][7];
SIZE.s2 = (SIZE.s2+str.sE)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str1.s0,SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC),0);
x0.s3=inpc[GLI][0];
x1.s3=inpc[GLI][1];
x2.s3=inpc[GLI][2];
x3.s3=inpc[GLI][3];
x4.s3=inpc[GLI][4];
x5.s3=inpc[GLI][5];
x6.s3=inpc[GLI][6];
x7.s3=inpc[GLI][7];
SIZE.s3 = (SIZE.s3+str1.sC)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str1.s4,SIZE.s4,0);
SET_AB(inpc[GLI],str1.s5,SIZE.s4+4,0);
SET_AB(inpc[GLI],str1.s6,SIZE.s4+8,0);
SET_AB(inpc[GLI],str1.s7,SIZE.s4+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s4+str1.sD),0);
x0.s4=inpc[GLI][0];
x1.s4=inpc[GLI][1];
x2.s4=inpc[GLI][2];
x3.s4=inpc[GLI][3];
x4.s4=inpc[GLI][4];
x5.s4=inpc[GLI][5];
x6.s4=inpc[GLI][6];
x7.s4=inpc[GLI][7];
SIZE.s4 = (SIZE.s4+str1.sD)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str1.s8,SIZE.s5,0);
SET_AB(inpc[GLI],str1.s9,SIZE.s5+4,0);
SET_AB(inpc[GLI],str1.sA,SIZE.s5+8,0);
SET_AB(inpc[GLI],str1.sB,SIZE.s5+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s5+str1.sE),0);
x0.s5=inpc[GLI][0];
x1.s5=inpc[GLI][1];
x2.s5=inpc[GLI][2];
x3.s5=inpc[GLI][3];
x4.s5=inpc[GLI][4];
x5.s5=inpc[GLI][5];
x6.s5=inpc[GLI][6];
x7.s5=inpc[GLI][7];
SIZE.s5 = (SIZE.s5+str1.sE)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str2.s0,SIZE.s6,0);
SET_AB(inpc[GLI],str2.s1,SIZE.s6+4,0);
SET_AB(inpc[GLI],str2.s2,SIZE.s6+8,0);
SET_AB(inpc[GLI],str2.s3,SIZE.s6+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s6+str2.sC),0);
x0.s6=inpc[GLI][0];
x1.s6=inpc[GLI][1];
x2.s6=inpc[GLI][2];
x3.s6=inpc[GLI][3];
x4.s6=inpc[GLI][4];
x5.s6=inpc[GLI][5];
x6.s6=inpc[GLI][6];
x7.s6=inpc[GLI][7];
SIZE.s6 = (SIZE.s6+str2.sC)<<3;


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;

SET_AB(inpc[GLI],str2.s4,SIZE.s7,0);
SET_AB(inpc[GLI],str2.s5,SIZE.s7+4,0);
SET_AB(inpc[GLI],str2.s6,SIZE.s7+8,0);
SET_AB(inpc[GLI],str2.s7,SIZE.s7+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s7+str2.sD),0);
x0.s7=inpc[GLI][0];
x1.s7=inpc[GLI][1];
x2.s7=inpc[GLI][2];
x3.s7=inpc[GLI][3];
x4.s7=inpc[GLI][4];
x5.s7=inpc[GLI][5];
x6.s7=inpc[GLI][6];
x7.s7=inpc[GLI][7];
SIZE.s7 = (SIZE.s7+str2.sD)<<3;





a = mCa; b = mCb; c = mCc; d = mCd;  

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);


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



#define MD5STEP_ROUND3_EVEN( a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL_EVEN( a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD( a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_ODD( a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3( a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL( a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND3_NULL_EVEN( a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD( d, a, b, c, mAC34, S32); 
MD5STEP_ROUND3_NULL_EVEN ( c, d, a, b, mAC35, S33);
MD5STEP_ROUND3_ODD ( b, c, d, a, mAC36, SIZE, S34);
MD5STEP_ROUND3_EVEN ( a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_NULL_ODD ( d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN ( c, d, a, b, mAC39, S33);
MD5STEP_ROUND3_NULL_ODD ( b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN ( a, b, c, d, mAC41, S31);
MD5STEP_ROUND3_ODD ( d, a, b, c, mAC42, x0, S32); 
MD5STEP_ROUND3_EVEN ( c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL_ODD ( b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL_EVEN ( a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL_ODD( d, a, b, c, mAC46, S32); 
MD5STEP_ROUND3_NULL_EVEN( c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD ( b, c, d, a, mAC48, x2, S34);

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
#ifndef SINGLE_MODE
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s4;b2=b.s4;b3=c.s4;b4=d.s4;
b5=(singlehash.x >> (b.s4&31))&1;
b6=(singlehash.y >> (c.s4&31))&1;
b7=(singlehash.z >> (d.s4&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s5;b2=b.s5;b3=c.s5;b4=d.s5;
b5=(singlehash.x >> (b.s5&31))&1;
b6=(singlehash.y >> (c.s5&31))&1;
b7=(singlehash.z >> (d.s5&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s6;b2=b.s6;b3=c.s6;b4=d.s6;
b5=(singlehash.x >> (b.s6&31))&1;
b6=(singlehash.y >> (c.s6&31))&1;
b7=(singlehash.z >> (d.s6&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s7;b2=b.s7;b3=c.s7;b4=d.s7;
b5=(singlehash.x >> (b.s7&31))&1;
b6=(singlehash.y >> (c.s7&31))&1;
b7=(singlehash.z >> (d.s7&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44); 

a=a+mCa;
b=b+mCb;
c=c+mCc;
d=d+mCd; 

id = 0;

#ifdef SINGLE_MODE
if (all((uint8)singlehash.x!=a)) return;
if (all((uint8)singlehash.y!=b)) return;
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

void md5_block(uint x0,uint x1,uint x2, uint x3, uint x4, uint x5, uint x6, uint x7, uint SIZE,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,__global uint4 *dst,  uint4 singlehash,uint offset)
{
#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 (uint)7
#define S12 (uint)12
#define S13 (uint)17
#define S14 (uint)22
#define S21 (uint)5
#define S22 (uint)9
#define S23 (uint)14
#define S24 (uint)20
#define S31 (uint)4
#define S32 (uint)11
#define S33 (uint)16
#define S34 (uint)23
#define S41 (uint)6
#define S42 (uint)10
#define S43 (uint)15
#define S44 (uint)21

uint i ,ib ,ic ,id, ie;
uint mOne, mCa, mCb, mCc, mCd;
uint a,b,c,d, tmp1,tmp2;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16; 

uint mAC1 = (uint)0xd76aa478; 
uint mAC2 = (uint)0xe8c7b756; 
uint mAC3 = (uint)0x242070db; 
uint mAC4 = (uint)0xc1bdceee; 
uint mAC5 = (uint)0xf57c0faf; 
uint mAC6 = (uint)0x4787c62a; 
uint mAC7 = (uint)0xa8304613; 
uint mAC8 = (uint)0xfd469501; 
uint mAC9 = (uint)0x698098d8; 
uint mAC10= (uint)0x8b44f7af; 
uint mAC11= (uint)0xffff5bb1; 
uint mAC12= (uint)0x895cd7be; 
uint mAC13= (uint)0x6b901122; 
uint mAC14= (uint)0xfd987193; 
uint mAC15= (uint)0xa679438e; 
uint mAC16= (uint)0x49b40821; 
uint mAC17= (uint)0xf61e2562; 
uint mAC18= (uint)0xc040b340; 
uint mAC19= (uint)0x265e5a51; 
uint mAC20= (uint)0xe9b6c7aa; 
uint mAC21= (uint)0xd62f105d; 
uint mAC22= (uint)0x02441453; 
uint mAC23= (uint)0xd8a1e681; 
uint mAC24= (uint)0xe7d3fbc8; 
uint mAC25= (uint)0x21e1cde6; 
uint mAC26= (uint)0xc33707d6; 
uint mAC27= (uint)0xf4d50d87; 
uint mAC28= (uint)0x455a14ed; 
uint mAC29= (uint)0xa9e3e905; 
uint mAC30= (uint)0xfcefa3f8; 
uint mAC31= (uint)0x676f02d9; 
uint mAC32= (uint)0x8d2a4c8a; 
uint mAC33= (uint)0xfffa3942; 
uint mAC34= (uint)0x8771f681; 
uint mAC35= (uint)0x6d9d6122; 
uint mAC36= (uint)0xfde5380c; 
uint mAC37= (uint)0xa4beea44; 
uint mAC38= (uint)0x4bdecfa9; 
uint mAC39= (uint)0xf6bb4b60; 
uint mAC40= (uint)0xbebfbc70; 
uint mAC41= (uint)0x289b7ec6; 
uint mAC42= (uint)0xeaa127fa; 
uint mAC43= (uint)0xd4ef3085; 
uint mAC44= (uint)0x04881d05; 
uint mAC45= (uint)0xd9d4d039; 
uint mAC46= (uint)0xe6db99e5; 
uint mAC47= (uint)0x1fa27cf8; 
uint mAC48= (uint)0xc4ac5665; 
uint mAC49= (uint)0xf4292244; 
uint mAC50= (uint)0x432aff97; 
uint mAC51= (uint)0xab9423a7; 
uint mAC52= (uint)0xfc93a039; 
uint mAC53= (uint)0x655b59c3; 
uint mAC54= (uint)0x8f0ccc92; 
uint mAC55= (uint)0xffeff47d; 
uint mAC56= (uint)0x85845dd1; 
uint mAC57= (uint)0x6fa87e4f; 
uint mAC58= (uint)0xfe2ce6e0; 
uint mAC59= (uint)0xa3014314; 
uint mAC60= (uint)0x4e0811a1; 
uint mAC61= (uint)0xf7537e82; 
uint mAC62= (uint)0xbd3af235; 
uint mAC63= (uint)0x2ad7d2bb; 
uint mAC64= (uint)0xeb86d391; 

mCa  = (uint)Ca;
mCb  = (uint)Cb;
mCc  = (uint)Cc;
mCd  = (uint)Cd;


a = mCa; b = mCb; c = mCc; d = mCd;  

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);


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



#define MD5STEP_ROUND3_EVEN( a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL_EVEN( a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD( a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_ODD( a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3( a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL( a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND3_NULL_EVEN( a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD( d, a, b, c, mAC34, S32); 
MD5STEP_ROUND3_NULL_EVEN ( c, d, a, b, mAC35, S33);
MD5STEP_ROUND3_ODD ( b, c, d, a, mAC36, SIZE, S34);
MD5STEP_ROUND3_EVEN ( a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_NULL_ODD ( d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN ( c, d, a, b, mAC39, S33);
MD5STEP_ROUND3_NULL_ODD ( b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN ( a, b, c, d, mAC41, S31);
MD5STEP_ROUND3_ODD ( d, a, b, c, mAC42, x0, S32); 
MD5STEP_ROUND3_EVEN ( c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL_ODD ( b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL_EVEN ( a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL_ODD( d, a, b, c, mAC46, S32); 
MD5STEP_ROUND3_NULL_EVEN( c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD ( b, c, d, a, mAC48, x2, S34);

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
id=singlehash.x - mCa;
if (((uint)id != a)) return;
#endif

MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);  
#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44); 

a=a+mCa;
b=b+mCb;
c=c+mCc;
d=d+mCd; 

id = 0;

#ifdef SINGLE_MODE
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;
#endif 

found[0] = 1;
found_ind[get_global_id(0)] = 1;
dst[(get_global_id(0)*8)+offset] = (uint4)(a,b,c,d);
}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1, uint16 str2) 
{
uint SIZE,size;
uint i ,ib ,ic ,id, ie;
uint a,b,c,d, tmp1,tmp2;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16; 
uint x0,x1,x2,x3,x4,x5,x6,x7; 
uint w0,w1,w2,w3,w4,w5,w6,w7; 
__local uint inpc[64][14];
uint elem,t1;


id=get_global_id(0);
size=(uint)sizein[GGI];
w0 = inp[GGI*8+0];
w1 = inp[GGI*8+1];
w2 = inp[GGI*8+2];
w3 = inp[GGI*8+3];
w4 = inp[GGI*8+4];
w5 = inp[GGI*8+5];
w6 = inp[GGI*8+6];
w7 = inp[GGI*8+7];


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str.s0,size,0);
SET_AB(inpc[GLI],str.s1,size+4,0);
SET_AB(inpc[GLI],str.s2,size+8,0);
SET_AB(inpc[GLI],str.s3,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sC),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str.sC)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,0);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str.s4,size,0);
SET_AB(inpc[GLI],str.s5,size+4,0);
SET_AB(inpc[GLI],str.s6,size+8,0);
SET_AB(inpc[GLI],str.s7,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sD),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str.sD)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,1);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str.s8,size,0);
SET_AB(inpc[GLI],str.s9,size+4,0);
SET_AB(inpc[GLI],str.sA,size+8,0);
SET_AB(inpc[GLI],str.sB,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str.sE),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str.sE)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,2);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str1.s0,size,0);
SET_AB(inpc[GLI],str1.s1,size+4,0);
SET_AB(inpc[GLI],str1.s2,size+8,0);
SET_AB(inpc[GLI],str1.s3,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str1.sC),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str1.sC)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,3);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str1.s4,size,0);
SET_AB(inpc[GLI],str1.s5,size+4,0);
SET_AB(inpc[GLI],str1.s6,size+8,0);
SET_AB(inpc[GLI],str1.s7,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str1.sD),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str1.sD)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,4);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str1.s8,size,0);
SET_AB(inpc[GLI],str1.s9,size+4,0);
SET_AB(inpc[GLI],str1.sA,size+8,0);
SET_AB(inpc[GLI],str1.sB,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str1.sE),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str1.sE)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,5);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str2.s0,size,0);
SET_AB(inpc[GLI],str2.s1,size+4,0);
SET_AB(inpc[GLI],str2.s2,size+8,0);
SET_AB(inpc[GLI],str2.s3,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str2.sC),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str2.sC)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,6);


inpc[GLI][0]=w0;
inpc[GLI][1]=w1;
inpc[GLI][2]=w2;
inpc[GLI][3]=w3;
inpc[GLI][4]=w4;
inpc[GLI][5]=w5;
inpc[GLI][6]=w6;
inpc[GLI][7]=w7;
SET_AB(inpc[GLI],str2.s4,size,0);
SET_AB(inpc[GLI],str2.s5,size+4,0);
SET_AB(inpc[GLI],str2.s6,size+8,0);
SET_AB(inpc[GLI],str2.s7,size+12,0);
SET_AB(inpc[GLI],0x80,(size+str2.sD),0);
x0=inpc[GLI][0];
x1=inpc[GLI][1];
x2=inpc[GLI][2];
x3=inpc[GLI][3];
x4=inpc[GLI][4];
x5=inpc[GLI][5];
x6=inpc[GLI][6];
x7=inpc[GLI][7];
SIZE = (size+str2.sD)<<3;
md5_block(x0,x1,x2,x3,x4,x5,x6,x7,SIZE,found_ind,bitmaps,found,dst,singlehash,7);

}


#endif