#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,temp1;


inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];
inpc[GLI][8] = 0;
inpc[GLI][9] = 0;
inpc[GLI][10] = 0;
inpc[GLI][11] = 0;
inpc[GLI][12] = 0;

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
#endif

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
vbulletin( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind,  __global uint *found, uint4 singlehash,uint16 salt)
{
uint mCa= (uint)0x67452301;
uint mCb= (uint)0xefcdab89;
uint mCc= (uint)0x98badcfe;
uint mCd= (uint)0x10325476;
uint S11= (uint)7; 
uint S12= (uint)12;
uint S13= (uint)17;
uint S14= (uint)22;
uint S21= (uint)5; 
uint S22= (uint)9; 
uint S23= (uint)14;
uint S24= (uint)20;
uint S31= (uint)4; 
uint S32= (uint)11;
uint S33= (uint)16;
uint S34= (uint)23;
uint S41= (uint)6; 
uint S42= (uint)10;
uint S43= (uint)15;
uint S44= (uint)21;

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


uint SIZE;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
uint a,b,c,d, tmp1, tmp2; 
uint x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint chbase1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

#ifndef OLD_ATI
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif

#ifndef OLD_ATI
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif



#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 

#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);



id=get_global_id(0);
SIZE=(size[id]); 


x0=input[id*8];
x1=input[id*8+1];
x2=input[id*8+2];
x3=input[id*8+3];
x4=input[id*8+4];
x5=input[id*8+5];
x6=input[id*8+6];
x7=input[id*8+7];
x15=(uint)0;
x14=SIZE;

a = mCa; b = mCb; c = mCc; d = mCd;
id=0;

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
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22,S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39, x7, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


b1=(a&255)&15;b2=(a&255)>>4;b3=((a>>8)&255)&15;b4=((a>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 

w0=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=((a>>16)&255)&15;b2=((a>>16)&255)>>4;b3=((a>>24)&255)&15;b4=((a>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
w1=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=(b&255)&15;b2=(b&255)>>4;b3=((b>>8)&255)&15;b4=((b>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 

w2=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=((b>>16)&255)&15;b2=((b>>16)&255)>>4;b3=((b>>24)&255)&15;b4=((b>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 

w3=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=(c&255)&15;b2=(c&255)>>4;b3=((c>>8)&255)&15;b4=((c>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
w4=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));


b1=((c>>16)&255)&15;b2=((c>>16)&255)>>4;b3=((c>>24)&255)&15;b4=((c>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
w5=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=(d&255)&15;b2=(d&255)>>4;b3=((d>>8)&255)&15;b4=((d>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
w6=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));

b1=((d>>16)&255)&15;b2=((d>>16)&255)>>4;b3=((d>>24)&255)&15;b4=((d>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
w7=(uint)( b2|(b1<<8)|(b4<<16)|(b3<<24));


w8=(uint)salt.s0;
w9=(uint)salt.s1;
w10=(uint)salt.s2;
w11=(uint)salt.s3;
w12=(uint)salt.s4;
w13=(uint)salt.s5;
w14=(uint)salt.s6;
w15=(uint)salt.s7;
w14=(salt.sF<48) ? salt.sF+256 : salt.s6;
ib=(salt.sF<48) ? 1:0;


a = mCa; b = mCb; c = mCc; d = mCd;
id=0;
x0=w0;x1=w1;x2=w2;x3=w3;x4=w4;x5=w5;
x6=w6;x7=w7;x8=w8;x9=w9;x10=w10;x11=w11;
x12=w12;x13=w13;x14=w14;x15=w15;


MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x3, S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x4, S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x5, S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x6, S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x7, S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x8, S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x9, S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x10,S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x11,S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x12,S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x13, S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,x14, S13);  
MD5STEP_ROUND1(b, c, d, a, mAC16,x15, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x11,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x10,S22);
MD5STEP_ROUND2 (c, d,  a, b, mAC23, x15, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x13,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x12, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x11, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x10, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x13, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x12, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47, x15, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x12, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x10, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC58, x15, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x13, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x11, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

if (ib==1)
{
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}

else
{
t1=a;t2=b;t3=c;t4=d;

x0=(uint)0x0;
x1=x2=x3=x4=x5=x6=x7=x8=x9=x10=x11=x12=x13=x15=(uint)0;
x14=(uint)(62<<3);

MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1_NULL(d, a, b, c, mAC2, S12);  
MD5STEP_ROUND1_NULL(c, d, a, b, mAC3, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC4, S14);  
MD5STEP_ROUND1_NULL(a, b, c, d, mAC5, S11); 
MD5STEP_ROUND1_NULL(d, a, b, c, mAC6, S12); 
MD5STEP_ROUND1_NULL(c, d, a, b, mAC7, S13); 
MD5STEP_ROUND1_NULL(b, c, d, a, mAC8, S14); 
MD5STEP_ROUND1_NULL(a, b, c, d, mAC9, S11); 
MD5STEP_ROUND1_NULL(d, a, b, c, mAC10, S12);
MD5STEP_ROUND1_NULL(c, d, a, b, mAC11, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12, S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13, S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,x14, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2_NULL (a, b, c, d, mAC17, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2_NULL (c, d, a, b, mAC27, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC30, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33,  S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC37, S31);
MD5STEP_ROUND3_NULL_ODD (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC43, S33);
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC48, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC54, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC56, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC63, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);
a=a+t1;b=b+t2;c=c+t3;d=d+t4;
}

if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(a,b,c,d);

}



