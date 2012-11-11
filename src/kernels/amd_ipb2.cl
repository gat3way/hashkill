#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tt1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tt1)); \
    ai1[elem+1] = (tt1==0) ? 0 : ai2>>(32-tt1);\
}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
ipb2( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt, uint16 str, uint16 str1)
{
__local uint inpc[64][14];
uint elem,tt1;
uint4 mCa= (uint4)0x67452301;
uint4 mCb= (uint4)0xefcdab89;
uint4 mCc= (uint4)0x98badcfe;
uint4 mCd= (uint4)0x10325476;
uint4 S11= (uint4)7; 
uint4 S12= (uint4)12;
uint4 S13= (uint4)17;
uint4 S14= (uint4)22;
uint4 S21= (uint4)5; 
uint4 S22= (uint4)9; 
uint4 S23= (uint4)14;
uint4 S24= (uint4)20;
uint4 S31= (uint4)4; 
uint4 S32= (uint4)11;
uint4 S33= (uint4)16;
uint4 S34= (uint4)23;
uint4 S41= (uint4)6; 
uint4 S42= (uint4)10;
uint4 S43= (uint4)15;
uint4 S44= (uint4)21;
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
uint4 SIZE;  
uint i,ib,ic,id,ie;  
uint4 t1,t2,t3,t4;
uint4 a,b,c,d, tmp1, tmp2; 
uint4 x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint u0,u1,u2,u3,u4,u5,u6,u7;
uint4 chbase1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


SIZE = (uint4)salt.sF; 
x0 = (uint4)salt.s0;
x1 = (uint4)salt.s1;
x2 = (uint4)salt.s2;
x3 = (uint4)salt.s3;
x4 = (uint4)salt.s4;
x5=x6=x7=x8=x9=x10=x11=x12=(uint4)0;
a = mCa; b = mCb; c = mCc; d = mCd;
id=0;

MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x3, S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x4, S11); 
MD5STEP_ROUND1_NULL(d, a, b, c, mAC6, S12); 
MD5STEP_ROUND1_NULL(c, d, a, b, mAC7, S13); 
MD5STEP_ROUND1_NULL(b, c, d, a, mAC8, S14); 
MD5STEP_ROUND1_NULL(a, b, c, d, mAC9, S11); 
MD5STEP_ROUND1_NULL(d, a, b, c, mAC10, S12);
MD5STEP_ROUND1_NULL(c, d, a, b, mAC11, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12, S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13, S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


b1=(a.x&255)&15;b2=(a.x&255)>>4;b3=((a.x>>8)&255)&15;b4=((a.x>>8)&255)>>4; 
b5=(a.y&255)&15;b6=(a.y&255)>>4;b7=((a.y>>8)&255)&15;b8=((a.y>>8)&255)>>4; 
b9=(a.z&255)&15;b10=(a.z&255)>>4;b11=((a.z>>8)&255)&15;b12=((a.z>>8)&255)>>4;  
b13=(a.w&255)&15;b14=(a.w&255)>>4;b15=((a.w>>8)&255)&15;b16=((a.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 


w0=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((a.x>>16)&255)&15;b2=((a.x>>16)&255)>>4;b3=((a.x>>24)&255)&15;b4=((a.x>>24)&255)>>4;
b5=((a.y>>16)&255)&15;b6=((a.y>>16)&255)>>4;b7=((a.y>>24)&255)&15;b8=((a.y>>24)&255)>>4;
b9=((a.z>>16)&255)&15;b10=((a.z>>16)&255)>>4;b11=((a.z>>24)&255)&15;b12=((a.z>>24)&255)>>4;
b13=((a.w>>16)&255)&15;b14=((a.w>>16)&255)>>4;b15=((a.w>>24)&255)&15;b16=((a.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w1=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(b.x&255)&15;b2=(b.x&255)>>4;b3=((b.x>>8)&255)&15;b4=((b.x>>8)&255)>>4; 
b5=(b.y&255)&15;b6=(b.y&255)>>4;b7=((b.y>>8)&255)&15;b8=((b.y>>8)&255)>>4; 
b9=(b.z&255)&15;b10=(b.z&255)>>4;b11=((b.z>>8)&255)&15;b12=((b.z>>8)&255)>>4;  
b13=(b.w&255)&15;b14=(b.w&255)>>4;b15=((b.w>>8)&255)&15;b16=((b.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 

w2=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((b.x>>16)&255)&15;b2=((b.x>>16)&255)>>4;b3=((b.x>>24)&255)&15;b4=((b.x>>24)&255)>>4;
b5=((b.y>>16)&255)&15;b6=((b.y>>16)&255)>>4;b7=((b.y>>24)&255)&15;b8=((b.y>>24)&255)>>4;
b9=((b.z>>16)&255)&15;b10=((b.z>>16)&255)>>4;b11=((b.z>>24)&255)&15;b12=((b.z>>24)&255)>>4;
b13=((b.w>>16)&255)&15;b14=((b.w>>16)&255)>>4;b15=((b.w>>24)&255)&15;b16=((b.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 

w3=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(c.x&255)&15;b2=(c.x&255)>>4;b3=((c.x>>8)&255)&15;b4=((c.x>>8)&255)>>4; 
b5=(c.y&255)&15;b6=(c.y&255)>>4;b7=((c.y>>8)&255)&15;b8=((c.y>>8)&255)>>4; 
b9=(c.z&255)&15;b10=(c.z&255)>>4;b11=((c.z>>8)&255)&15;b12=((c.z>>8)&255)>>4;  
b13=(c.w&255)&15;b14=(c.w&255)>>4;b15=((c.w>>8)&255)&15;b16=((c.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w4=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );


b1=((c.x>>16)&255)&15;b2=((c.x>>16)&255)>>4;b3=((c.x>>24)&255)&15;b4=((c.x>>24)&255)>>4;
b5=((c.y>>16)&255)&15;b6=((c.y>>16)&255)>>4;b7=((c.y>>24)&255)&15;b8=((c.y>>24)&255)>>4;
b9=((c.z>>16)&255)&15;b10=((c.z>>16)&255)>>4;b11=((c.z>>24)&255)&15;b12=((c.z>>24)&255)>>4;
b13=((c.w>>16)&255)&15;b14=((c.w>>16)&255)>>4;b15=((c.w>>24)&255)&15;b16=((c.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w5=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(d.x&255)&15;b2=(d.x&255)>>4;b3=((d.x>>8)&255)&15;b4=((d.x>>8)&255)>>4; 
b5=(d.y&255)&15;b6=(d.y&255)>>4;b7=((d.y>>8)&255)&15;b8=((d.y>>8)&255)>>4; 
b9=(d.z&255)&15;b10=(d.z&255)>>4;b11=((d.z>>8)&255)&15;b12=((d.z>>8)&255)>>4;  
b13=(d.w&255)&15;b14=(d.w&255)>>4;b15=((d.w>>8)&255)&15;b16=((d.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w6=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((d.x>>16)&255)&15;b2=((d.x>>16)&255)>>4;b3=((d.x>>24)&255)&15;b4=((d.x>>24)&255)>>4;
b5=((d.y>>16)&255)&15;b6=((d.y>>16)&255)>>4;b7=((d.y>>24)&255)&15;b8=((d.y>>24)&255)>>4;
b9=((d.z>>16)&255)&15;b10=((d.z>>16)&255)>>4;b11=((d.z>>24)&255)&15;b12=((d.z>>24)&255)>>4;
b13=((d.w>>16)&255)&15;b14=((d.w>>16)&255)>>4;b15=((d.w>>24)&255)&15;b16=((d.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w7=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
u0 = inp[GGI*8+0];
u1 = inp[GGI*8+1];
u2 = inp[GGI*8+2];
u3 = inp[GGI*8+3];
u4 = inp[GGI*8+4];
u5 = inp[GGI*8+5];
u6 = inp[GGI*8+6];
u7 = inp[GGI*8+7];


inpc[GLI][0]=u0;
inpc[GLI][1]=u1;
inpc[GLI][2]=u2;
inpc[GLI][3]=u3;
inpc[GLI][4]=u4;
inpc[GLI][5]=u5;
inpc[GLI][6]=u6;
inpc[GLI][7]=u7;
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


inpc[GLI][0]=u0;
inpc[GLI][1]=u1;
inpc[GLI][2]=u2;
inpc[GLI][3]=u3;
inpc[GLI][4]=u4;
inpc[GLI][5]=u5;
inpc[GLI][6]=u6;
inpc[GLI][7]=u7;
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


inpc[GLI][0]=u0;
inpc[GLI][1]=u1;
inpc[GLI][2]=u2;
inpc[GLI][3]=u3;
inpc[GLI][4]=u4;
inpc[GLI][5]=u5;
inpc[GLI][6]=u6;
inpc[GLI][7]=u7;

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


inpc[GLI][0]=u0;
inpc[GLI][1]=u1;
inpc[GLI][2]=u2;
inpc[GLI][3]=u3;
inpc[GLI][4]=u4;
inpc[GLI][5]=u5;
inpc[GLI][6]=u6;
inpc[GLI][7]=u7;

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


x15=(uint4)0;
x14=SIZE;
x8=x9=x10=x11=x12=x13=(uint4)0;

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


b1=(a.x&255)&15;b2=(a.x&255)>>4;b3=((a.x>>8)&255)&15;b4=((a.x>>8)&255)>>4; 
b5=(a.y&255)&15;b6=(a.y&255)>>4;b7=((a.y>>8)&255)&15;b8=((a.y>>8)&255)>>4; 
b9=(a.z&255)&15;b10=(a.z&255)>>4;b11=((a.z>>8)&255)&15;b12=((a.z>>8)&255)>>4;  
b13=(a.w&255)&15;b14=(a.w&255)>>4;b15=((a.w>>8)&255)&15;b16=((a.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 

w8=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((a.x>>16)&255)&15;b2=((a.x>>16)&255)>>4;b3=((a.x>>24)&255)&15;b4=((a.x>>24)&255)>>4;
b5=((a.y>>16)&255)&15;b6=((a.y>>16)&255)>>4;b7=((a.y>>24)&255)&15;b8=((a.y>>24)&255)>>4;
b9=((a.z>>16)&255)&15;b10=((a.z>>16)&255)>>4;b11=((a.z>>24)&255)&15;b12=((a.z>>24)&255)>>4;
b13=((a.w>>16)&255)&15;b14=((a.w>>16)&255)>>4;b15=((a.w>>24)&255)&15;b16=((a.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;

b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w9=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(b.x&255)&15;b2=(b.x&255)>>4;b3=((b.x>>8)&255)&15;b4=((b.x>>8)&255)>>4; 
b5=(b.y&255)&15;b6=(b.y&255)>>4;b7=((b.y>>8)&255)&15;b8=((b.y>>8)&255)>>4; 
b9=(b.z&255)&15;b10=(b.z&255)>>4;b11=((b.z>>8)&255)&15;b12=((b.z>>8)&255)>>4;  
b13=(b.w&255)&15;b14=(b.w&255)>>4;b15=((b.w>>8)&255)&15;b16=((b.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 

w10=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((b.x>>16)&255)&15;b2=((b.x>>16)&255)>>4;b3=((b.x>>24)&255)&15;b4=((b.x>>24)&255)>>4;
b5=((b.y>>16)&255)&15;b6=((b.y>>16)&255)>>4;b7=((b.y>>24)&255)&15;b8=((b.y>>24)&255)>>4;
b9=((b.z>>16)&255)&15;b10=((b.z>>16)&255)>>4;b11=((b.z>>24)&255)&15;b12=((b.z>>24)&255)>>4;
b13=((b.w>>16)&255)&15;b14=((b.w>>16)&255)>>4;b15=((b.w>>24)&255)&15;b16=((b.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 

w11=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(c.x&255)&15;b2=(c.x&255)>>4;b3=((c.x>>8)&255)&15;b4=((c.x>>8)&255)>>4; 
b5=(c.y&255)&15;b6=(c.y&255)>>4;b7=((c.y>>8)&255)&15;b8=((c.y>>8)&255)>>4; 
b9=(c.z&255)&15;b10=(c.z&255)>>4;b11=((c.z>>8)&255)&15;b12=((c.z>>8)&255)>>4;  
b13=(c.w&255)&15;b14=(c.w&255)>>4;b15=((c.w>>8)&255)&15;b16=((c.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w12=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );


b1=((c.x>>16)&255)&15;b2=((c.x>>16)&255)>>4;b3=((c.x>>24)&255)&15;b4=((c.x>>24)&255)>>4;
b5=((c.y>>16)&255)&15;b6=((c.y>>16)&255)>>4;b7=((c.y>>24)&255)&15;b8=((c.y>>24)&255)>>4;
b9=((c.z>>16)&255)&15;b10=((c.z>>16)&255)>>4;b11=((c.z>>24)&255)&15;b12=((c.z>>24)&255)>>4;
b13=((c.w>>16)&255)&15;b14=((c.w>>16)&255)>>4;b15=((c.w>>24)&255)&15;b16=((c.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w13=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(d.x&255)&15;b2=(d.x&255)>>4;b3=((d.x>>8)&255)&15;b4=((d.x>>8)&255)>>4; 
b5=(d.y&255)&15;b6=(d.y&255)>>4;b7=((d.y>>8)&255)&15;b8=((d.y>>8)&255)>>4; 
b9=(d.z&255)&15;b10=(d.z&255)>>4;b11=((d.z>>8)&255)&15;b12=((d.z>>8)&255)>>4;  
b13=(d.w&255)&15;b14=(d.w&255)>>4;b15=((d.w>>8)&255)&15;b16=((d.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w14=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((d.x>>16)&255)&15;b2=((d.x>>16)&255)>>4;b3=((d.x>>24)&255)&15;b4=((d.x>>24)&255)>>4;
b5=((d.y>>16)&255)&15;b6=((d.y>>16)&255)>>4;b7=((d.y>>24)&255)&15;b8=((d.y>>24)&255)>>4;
b9=((d.z>>16)&255)&15;b10=((d.z>>16)&255)>>4;b11=((d.z>>24)&255)&15;b12=((d.z>>24)&255)>>4;
b13=((d.w>>16)&255)&15;b14=((d.w>>16)&255)>>4;b15=((d.w>>24)&255)&15;b16=((d.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
b1 +=  (b1>57) ? 39 : 0; 
b2 +=  (b2>57) ? 39 : 0; 
b3 +=  (b3>57) ? 39 : 0; 
b4 +=  (b4>57) ? 39 : 0; 
b5 +=  (b5>57) ? 39 : 0; 
b6 +=  (b6>57) ? 39 : 0; 
b7 +=  (b7>57) ? 39 : 0; 
b8 +=  (b8>57) ? 39 : 0; 
b9 +=  (b9>57) ? 39 : 0; 
b10 +=  (b10>57) ? 39 : 0; 
b11 +=  (b11>57) ? 39 : 0; 
b12 +=  (b12>57) ? 39 : 0; 
b13 +=  (b13>57) ? 39 : 0; 
b14 +=  (b14>57) ? 39 : 0; 
b15 +=  (b15>57) ? 39 : 0; 
b16 +=  (b16>57) ? 39 : 0; 
w15=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );


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

t1=a;t2=b;t3=c;t4=d;

x0=(uint4)0x80;
x1=x2=x3=x4=x5=x6=x7=x8=x9=x10=x11=x12=x13=x15=(uint4)0;
x14=(uint4)(64<<3);


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


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}



