#define rotate(x,y) ((x) << (y)) + ((x) >> (32-(y)))


#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str)
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
size[GGI] = (SIZE+str.sF);

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);


dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];

}


__kernel  
void  __attribute__((reqd_work_group_size(64, 1, 1)))
pixmd5( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash)
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

uint SIZE;  
uint i,ib,ic,id,t1,t2;  
uint mOne;
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint x0,x1,x2,x3,x4,x5,x6,x7,x8;  
uint chbase1;

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


ic = 16;
id = ic<<3; 
SIZE = (uint)id; 

id = get_global_id(0);
x0=input[(id*8)];
x1=input[(id*8)+1];
x2=input[(id*8)+2];
x3=input[(id*8)+3];
x4=(uint)0x80;


a = mCa; b = mCb; c = mCc; d = mCd;

#ifndef OLD_ATI
#define pixmd5STEP_ROUND1(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#else
#define pixmd5STEP_ROUND1(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);
#define pixmd5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define pixmd5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif

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

#ifndef GCN
#ifdef OLD_ATI
#define pixmd5STEP_ROUND2(f, a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define pixmd5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#else
#define pixmd5STEP_ROUND2(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif
#else
#define pixmd5STEP_ROUND2(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define pixmd5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif


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
a&=(uint)0x00FFFFFF;
b&=(uint)0x00FFFFFF;
c&=(uint)0x00FFFFFF;
d&=(uint)0x00FFFFFF;


#ifdef SINGLE_MODE
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;
if (((uint)singlehash.z!=c)) return;
if (((uint)singlehash.w!=d)) return;
#else
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);

}



