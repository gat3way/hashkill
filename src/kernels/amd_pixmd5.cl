#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
    }




__kernel  
void  __attribute__((reqd_work_group_size(64, 1, 1)))
pixmd5( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1)
{
__local uint inpc[64][14];
uint elem,temp1;
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
uint4 SIZE;  
uint i,ib,ic,id,t1,t2;  
uint4 mOne;
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 x0,x1,x2,x3,x4,x5,x6,x7,x8;  
uint4 chbase1;
uint w0,w1,w2,w3,w4,w5,w6,w7;

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


id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
w0 = inp[GGI*8+0];
w1 = inp[GGI*8+1];
w2 = inp[GGI*8+2];
w3 = inp[GGI*8+3];


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
x0.s0=inpc[GLI][0];
x1.s0=inpc[GLI][1];
x2.s0=inpc[GLI][2];
x3.s0=inpc[GLI][3];
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
SIZE.s3 = (SIZE.s3+str1.sC)<<3;


ic = 16;
id = ic<<3; 
SIZE = (uint4)id; 
x4=(uint4)0x80;



a = mCa; b = mCb; c = mCc; d = mCd;

#define pixmd5STEP_ROUND1(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);

pixmd5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);
pixmd5STEP_ROUND1(F, d, a, b, c, mAC2, x1, S12);
pixmd5STEP_ROUND1(F, c, d, a, b, mAC3, x2, S13);
pixmd5STEP_ROUND1(F, b, c, d, a, mAC4, x3, S14);
pixmd5STEP_ROUND1(F, a, b, c, d, mAC5, x4, S11);  
pixmd5STEP_ROUND1_NULL(F, d, a, b, c, mAC6, S12);  
pixmd5STEP_ROUND1_NULL(F, c, d, a, b, mAC7, S13);  
pixmd5STEP_ROUND1_NULL(F, b, c, d, a, mAC8, S14);  
pixmd5STEP_ROUND1_NULL(F, a, b, c, d, mAC9, S11);  
pixmd5STEP_ROUND1_NULL(F, d, a, b, c, mAC10, S12); 
pixmd5STEP_ROUND1_NULL(F, c, d, a, b, mAC11, S13); 
pixmd5STEP_ROUND1_NULL(F, b, c, d, a, mAC12, S14); 
pixmd5STEP_ROUND1_NULL(F, a, b, c, d, mAC13, S11); 
pixmd5STEP_ROUND1_NULL(F, d, a, b, c, mAC14, S12); 
pixmd5STEP_ROUND1 (F, c, d, a, b, mAC15, SIZE, S13);
pixmd5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14); 

#define pixmd5STEP_ROUND2(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);

pixmd5STEP_ROUND2 (G, a, b, c, d, mAC17, x1, S21); 
pixmd5STEP_ROUND2_NULL (G, d, a, b, c, mAC18, S22);
pixmd5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23);
pixmd5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24); 
pixmd5STEP_ROUND2_NULL (G, a, b, c, d, mAC21,  S21);
pixmd5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22);
pixmd5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23);
pixmd5STEP_ROUND2 (G, b, c, d, a, mAC24, x4, S24);
pixmd5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21);
pixmd5STEP_ROUND2 (G, d, a, b, c, mAC26, SIZE, S22);
pixmd5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23); 
pixmd5STEP_ROUND2_NULL (G, b, c, d, a, mAC28, S24);
pixmd5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21); 
pixmd5STEP_ROUND2 (G, d, a, b, c, mAC30, x2, S22); 
pixmd5STEP_ROUND2_NULL (G, c, d, a, b, mAC31, S23);
pixmd5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24); 


#define pixmd5STEP_ROUND3_EVEN(f, a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define pixmd5STEP_ROUND3_NULL_EVEN(f, a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define pixmd5STEP_ROUND3_ODD(f, a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define pixmd5STEP_ROUND3_NULL_ODD(f, a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define pixmd5STEP_ROUND3(f, a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define pixmd5STEP_ROUND3_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

pixmd5STEP_ROUND3_NULL_EVEN(H, a, b, c, d, mAC33, S31);
pixmd5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC34, S32); 
pixmd5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC35, S33);
pixmd5STEP_ROUND3_ODD (H, b, c, d, a, mAC36, SIZE, S34);
pixmd5STEP_ROUND3_EVEN (H, a, b, c, d, mAC37, x1, S31);
pixmd5STEP_ROUND3_ODD (H, d, a, b, c, mAC38, x4, S32);
pixmd5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC39, S33);
pixmd5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC40, S34);
pixmd5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC41, S31);
pixmd5STEP_ROUND3_ODD (H, d, a, b, c, mAC42, x0, S32); 
pixmd5STEP_ROUND3_EVEN (H, c, d, a, b, mAC43, x3, S33);
pixmd5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC44, S34);
pixmd5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC45, S31);
pixmd5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC46, S32); 
pixmd5STEP_ROUND3_NULL_EVEN(H, c, d, a, b, mAC47, S33);
pixmd5STEP_ROUND3_ODD (H, b, c, d, a, mAC48, x2, S34); 

#define pixmd5STEP_ROUND4(f, a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define pixmd5STEP_ROUND4_NULL(f, a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


pixmd5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41); 
pixmd5STEP_ROUND4_NULL (I, d, a, b, c, mAC50, S42);
pixmd5STEP_ROUND4 (I, c, d, a, b, mAC51, SIZE, S43);
pixmd5STEP_ROUND4_NULL (I, b, c, d, a, mAC52, S44);
pixmd5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41); 
pixmd5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42); 
pixmd5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43);
pixmd5STEP_ROUND4 (I, b, c, d, a, mAC56, x1, S44); 
pixmd5STEP_ROUND4_NULL (I, a, b, c, d, mAC57, S41);
pixmd5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42); 
pixmd5STEP_ROUND4_NULL (I, c, d, a, b, mAC59, S43);
pixmd5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44); 
pixmd5STEP_ROUND4 (I, a, b, c, d, mAC61, x4, S41);
pixmd5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42);
pixmd5STEP_ROUND4 (I, c, d, a, b, mAC63, x2, S43); 
pixmd5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
a&=(uint4)0x00FFFFFF;
b&=(uint4)0x00FFFFFF;
c&=(uint4)0x00FFFFFF;
d&=(uint4)0x00FFFFFF;


#ifdef SINGLE_MODE
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;
if (all((uint4)singlehash.z!=c)) return;
if (all((uint4)singlehash.w!=d)) return;
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


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)*4)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*4)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*4)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}



