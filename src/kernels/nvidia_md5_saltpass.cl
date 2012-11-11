#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5_saltpass( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind,  __global uint *found,  uint4 singlehash, uint16 salt, uint16 str, uint16 str1) 
{

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
uint4 a,b,c,d, tmp1, tmp2; 
uint4 x0,x1,x2,x3; 
uint4 x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,temp; 
uint elem,t1;
__local uint inpc[64][24];
uint w0,w1,w2,w3,w4,w5,w6,w7;

id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
w0 = inp[GGI*8+0];
w1 = inp[GGI*8+1];
w2 = inp[GGI*8+2];
w3 = inp[GGI*8+3];
w4 = inp[GGI*8+4];
w5 = inp[GGI*8+5];
w6 = inp[GGI*8+6];
w7 = inp[GGI*8+7];

inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s0+str.sC+salt.sF)>56) {SIZE.s0=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],w0,salt.sF,0);
SET_AB(inpc[GLI],w1,salt.sF+4,0);
SET_AB(inpc[GLI],w2,salt.sF+8,0);
SET_AB(inpc[GLI],w3,salt.sF+12,0);
SET_AB(inpc[GLI],w4,salt.sF+16,0);
SET_AB(inpc[GLI],w5,salt.sF+20,0);
SET_AB(inpc[GLI],w6,salt.sF+24,0);
SET_AB(inpc[GLI],w7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s0,salt.sF+SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,salt.sF+SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,salt.sF+SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,salt.sF+SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC+salt.sF),0);
SIZE.s0 = (SIZE.s0+str.sC+salt.sF)<<3;
x0.s0=inpc[GLI][0];
x1.s0=inpc[GLI][1];
x2.s0=inpc[GLI][2];
x3.s0=inpc[GLI][3];
x4.s0=inpc[GLI][4];
x5.s0=inpc[GLI][5];
x6.s0=inpc[GLI][6];
x7.s0=inpc[GLI][7];
x8.s0=inpc[GLI][8];
x9.s0=inpc[GLI][9];
x10.s0=inpc[GLI][10];
x11.s0=inpc[GLI][11];
x12.s0=inpc[GLI][12];
x13.s0=inpc[GLI][13];



inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s1+str.sD+salt.sF)>56) {SIZE.s1=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],w0,salt.sF,0);
SET_AB(inpc[GLI],w1,salt.sF+4,0);
SET_AB(inpc[GLI],w2,salt.sF+8,0);
SET_AB(inpc[GLI],w3,salt.sF+12,0);
SET_AB(inpc[GLI],w4,salt.sF+16,0);
SET_AB(inpc[GLI],w5,salt.sF+20,0);
SET_AB(inpc[GLI],w6,salt.sF+24,0);
SET_AB(inpc[GLI],w7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s4,salt.sF+SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,salt.sF+SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,salt.sF+SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,salt.sF+SIZE.s1+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD+salt.sF),0);
x0.s1=inpc[GLI][0];
x1.s1=inpc[GLI][1];
x2.s1=inpc[GLI][2];
x3.s1=inpc[GLI][3];
x4.s1=inpc[GLI][4];
x5.s1=inpc[GLI][5];
x6.s1=inpc[GLI][6];
x7.s1=inpc[GLI][7];
x8.s1=inpc[GLI][8];
x9.s1=inpc[GLI][9];
x10.s1=inpc[GLI][10];
x11.s1=inpc[GLI][11];
x12.s1=inpc[GLI][12];
x13.s1=inpc[GLI][13];
SIZE.s1 = (SIZE.s1+str.sD+salt.sF)<<3;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s2+str.sE+salt.sF)>56) {SIZE.s2=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],w0,salt.sF,0);
SET_AB(inpc[GLI],w1,salt.sF+4,0);
SET_AB(inpc[GLI],w2,salt.sF+8,0);
SET_AB(inpc[GLI],w3,salt.sF+12,0);
SET_AB(inpc[GLI],w4,salt.sF+16,0);
SET_AB(inpc[GLI],w5,salt.sF+20,0);
SET_AB(inpc[GLI],w6,salt.sF+24,0);
SET_AB(inpc[GLI],w7,salt.sF+28,0);
SET_AB(inpc[GLI],str.s8,salt.sF+SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,salt.sF+SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,salt.sF+SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,salt.sF+SIZE.s2+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE+salt.sF),0);
x0.s2=inpc[GLI][0];
x1.s2=inpc[GLI][1];
x2.s2=inpc[GLI][2];
x3.s2=inpc[GLI][3];
x4.s2=inpc[GLI][4];
x5.s2=inpc[GLI][5];
x6.s2=inpc[GLI][6];
x7.s2=inpc[GLI][7];
x8.s2=inpc[GLI][8];
x9.s2=inpc[GLI][9];
x10.s2=inpc[GLI][10];
x11.s2=inpc[GLI][11];
x12.s2=inpc[GLI][12];
x13.s2=inpc[GLI][13];
SIZE.s2 = (SIZE.s2+str.sE+salt.sF)<<3;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=inpc[GLI][4]=inpc[GLI][5]=0;
inpc[GLI][6]=inpc[GLI][7]==0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
if ((SIZE.s3+str1.sC+salt.sF)>56) {SIZE.s3=(uint)0;}
SET_AB(inpc[GLI],salt.s0,0,0);
SET_AB(inpc[GLI],salt.s1,4,0);
SET_AB(inpc[GLI],salt.s2,8,0);
SET_AB(inpc[GLI],salt.s3,12,0);
SET_AB(inpc[GLI],salt.s4,16,0);
SET_AB(inpc[GLI],salt.s5,20,0);
SET_AB(inpc[GLI],salt.s6,24,0);
SET_AB(inpc[GLI],salt.s7,28,0);
SET_AB(inpc[GLI],w0,salt.sF,0);
SET_AB(inpc[GLI],w1,salt.sF+4,0);
SET_AB(inpc[GLI],w2,salt.sF+8,0);
SET_AB(inpc[GLI],w3,salt.sF+12,0);
SET_AB(inpc[GLI],w4,salt.sF+16,0);
SET_AB(inpc[GLI],w5,salt.sF+20,0);
SET_AB(inpc[GLI],w6,salt.sF+24,0);
SET_AB(inpc[GLI],w7,salt.sF+28,0);
SET_AB(inpc[GLI],str1.s0,salt.sF+SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,salt.sF+SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,salt.sF+SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,salt.sF+SIZE.s3+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC+salt.sF),0);
x0.s3=inpc[GLI][0];
x1.s3=inpc[GLI][1];
x2.s3=inpc[GLI][2];
x3.s3=inpc[GLI][3];
x4.s3=inpc[GLI][4];
x5.s3=inpc[GLI][5];
x6.s3=inpc[GLI][6];
x7.s3=inpc[GLI][7];
x8.s3=inpc[GLI][8];
x9.s3=inpc[GLI][9];
x10.s3=inpc[GLI][10];
x11.s3=inpc[GLI][11];
x12.s3=inpc[GLI][12];
x13.s3=inpc[GLI][13];
SIZE.s3 = (SIZE.s3+str1.sC+salt.sF)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
id=0;
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

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
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);


MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x11,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x10,S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x13, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x12, S24);


#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 


MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x11, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x10, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41, x13, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x12, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x12, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x10, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x13, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x11, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}



