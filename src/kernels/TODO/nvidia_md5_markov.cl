#ifndef SM21

void md5_markov1( __global uint *dst,const uint4 input,const uint size, const uint chbase, global uint *found_ind, __global uint *bitmaps, __global uint *found, uint i, const uint4 singlehash, uint factor) 
{  
uint mCa= 0x67452301;
uint mCb= 0xefcdab89;
uint mCc= 0x98badcfe;
uint mCd= 0x10325476;
uint S11= 7; 
uint S12= 12;
uint S13= 17;
uint S14= 22;
uint S21= 5; 
uint S22= 9; 
uint S23= 14;
uint S24= 20;
uint S31= 4; 
uint S32= 11;
uint S33= 16;
uint S34= 23;
uint S41= 6; 
uint S42= 10;
uint S43= 15;
uint S44= 21;

uint SIZE;  
uint ib,ic,id,t1,t2,t3;  
uint mOne;
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint x0,x1,x2,x3; 

uint mAC1 = 0xd76aa478; 
uint mAC2 = 0xe8c7b756; 
uint mAC3 = 0x242070db; 
uint mAC4 = 0xc1bdceee; 
uint mAC5 = 0xf57c0faf; 
uint mAC6 = 0x4787c62a; 
uint mAC7 = 0xa8304613; 
uint mAC8 = 0xfd469501; 
uint mAC9 = 0x698098d8; 
uint mAC10= 0x8b44f7af; 
uint mAC11= 0xffff5bb1; 
uint mAC12= 0x895cd7be; 
uint mAC13= 0x6b901122; 
uint mAC14= 0xfd987193; 
uint mAC15= 0xa679438e; 
uint mAC16= 0x49b40821; 
uint mAC17= 0xf61e2562; 
uint mAC18= 0xc040b340; 
uint mAC19= 0x265e5a51; 
uint mAC20= 0xe9b6c7aa; 
uint mAC21= 0xd62f105d; 
uint mAC22= 0x02441453; 
uint mAC23= 0xd8a1e681; 
uint mAC24= 0xe7d3fbc8; 
uint mAC25= 0x21e1cde6; 
uint mAC26= 0xc33707d6; 
uint mAC27= 0xf4d50d87; 
uint mAC28= 0x455a14ed; 
uint mAC29= 0xa9e3e905; 
uint mAC30= 0xfcefa3f8; 
uint mAC31= 0x676f02d9; 
uint mAC32= 0x8d2a4c8a; 
uint mAC33= 0xfffa3942; 
uint mAC34= 0x8771f681; 
uint mAC35= 0x6d9d6122; 
uint mAC36= 0xfde5380c; 
uint mAC37= 0xa4beea44;
uint mAC38= 0x4bdecfa9; 
uint mAC39= 0xf6bb4b60; 
uint mAC40= 0xbebfbc70; 
uint mAC41= 0x289b7ec6; 
uint mAC42= 0xeaa127fa; 
uint mAC43= 0xd4ef3085; 
uint mAC44= 0x04881d05; 
uint mAC45= 0xd9d4d039; 
uint mAC46= 0xe6db99e5; 
uint mAC47= 0x1fa27cf8; 
uint mAC48= 0xc4ac5665; 
uint mAC49= 0xf4292244; 
uint mAC50= 0x432aff97; 
uint mAC51= 0xab9423a7; 
uint mAC52= 0xfc93a039; 
uint mAC53= 0x655b59c3; 
uint mAC54= 0x8f0ccc92; 
uint mAC55= 0xffeff47d; 
uint mAC56= 0x85845dd1; 
uint mAC57= 0x6fa87e4f; 
uint mAC58= 0xfe2ce6e0; 
uint mAC59= 0xa3014314; 
uint mAC60= 0x4e0811a1; 
uint mAC61= 0xf7537e82; 
uint mAC62= 0xbd3af235; 
uint mAC63= 0x2ad7d2bb; 
uint mAC64= 0xeb86d391; 


SIZE = size; 
x1 = input.y; 
x2 = input.z; 
//x3 = input.w; 

x0 = i|(chbase<<24); 

a = mCa; b = mCb; c = mCc; d = mCd;

//#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define rotate(a,b) (mad((a),(1<<b),((a) >> (32-(b)))))

#define MD5STEP_ROUND1(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  
#define MD5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND1_NOC(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  


MD5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1_NOC(F, d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1_NOC(F, c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC4, S14);  

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
MD5STEP_ROUND1_NOC (F, c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(f, a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND2 (G, a, b, c, d, mAC17-mAC2, x1, S21);
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (G, d, a, b, c, mAC26-mAC15, SIZE, S22);  
//MD5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC27, S23);

MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (G, d, a, b, c, mAC30-mAC3, x2, S22);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(f, a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(f, a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(f, a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  

#define MD5STEP_ROUND3_NULL_ODD(f, a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 


MD5STEP_ROUND3_NULL_EVEN(H, a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (H, b, c, d, a, mAC36-mAC15, SIZE, S34);  
MD5STEP_ROUND3_EVEN (H, a, b, c, d, mAC37-mAC2, x1, S31);
MD5STEP_ROUND3_NULL_ODD (H, d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (H, d, a, b, c, mAC42, x0, S32);
//MD5STEP_ROUND3_EVEN (H, c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC43, S33);

#ifdef SINGLE_MODE
t1=(singlehash.x)-x0; 
t2=(singlehash.y)-(t1^(singlehash.z^singlehash.w));
t3=(input.x)-(t1^t2^(singlehash.w));
if (t3 != c) return;
id=1;
#endif
MD5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if (t2 != b) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if (t1 != a) return;
#endif
MD5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(H, c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (H, b, c, d, a, mAC48-mAC3, x2, S34);

#define MD5STEP_ROUND4(f, a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(f, a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (I, c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41);
//MD5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC54, S42);

MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (I, b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (I, c, d, a, b, mAC63-mAC3, x2, S43);
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
else return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}
#ifdef DOUBLE
dst[(get_global_id(0)*16)+factor] = a;
dst[(get_global_id(0)*16)+1+factor] = b;
dst[(get_global_id(0)*16)+2+factor] = c;
dst[(get_global_id(0)*16)+3+factor] = d;
#else
dst[(get_global_id(0)*4)] = a;
dst[(get_global_id(0)*4)+1] = b;
dst[(get_global_id(0)*4)+2] = c;
dst[(get_global_id(0)*4)+3] = d;
#endif

}



__kernel  void md5_markov( __global uint *dst,const uint4 input,const uint size, const uint16 chbase, global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
{
    uint i;
    i = table[get_global_id(0)];
    md5_markov1(dst, input, size, chbase.s0, found_ind, bitmaps, found, i, singlehash, 0);
#ifdef DOUBLE
    md5_markov1(dst, input, size, chbase.s1, found_ind, bitmaps, found, i, singlehash, 4);
    md5_markov1(dst, input, size, chbase.s2, found_ind, bitmaps, found, i, singlehash, 8);
    md5_markov1(dst, input, size, chbase.s3, found_ind, bitmaps, found, i, singlehash, 12);
#endif
}



#else

__kernel  void md5_markov( __global uint4 *dst,const uint4 input,const uint size, const uint16 chbase, global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
{  
uint4 mCa= 0x67452301;
uint4 mCb= 0xefcdab89;
uint4 mCc= 0x98badcfe;
uint4 mCd= 0x10325476;
uint4 S11= 7; 
uint4 S12= 12;
uint4 S13= 17;
uint4 S14= 22;
uint4 S21= 5; 
uint4 S22= 9; 
uint4 S23= 14;
uint4 S24= 20;
uint4 S31= 4; 
uint4 S32= 11;
uint4 S33= 16;
uint4 S34= 23;
uint4 S41= 6; 
uint4 S42= 10;
uint4 S43= 15;
uint4 S44= 21;

uint4 SIZE;  
uint i,ib,ic,id;
uint4 chbase1,t1,t2,t3;  
uint4 a,b,c,d, tmp1, tmp2; 
uint4 b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 x0,x1,x2,x3; 

uint4 mAC1 = 0xd76aa478; 
uint4 mAC2 = 0xe8c7b756; 
uint4 mAC3 = 0x242070db; 
uint4 mAC4 = 0xc1bdceee; 
uint4 mAC5 = 0xf57c0faf; 
uint4 mAC6 = 0x4787c62a; 
uint4 mAC7 = 0xa8304613; 
uint4 mAC8 = 0xfd469501; 
uint4 mAC9 = 0x698098d8; 
uint4 mAC10= 0x8b44f7af; 
uint4 mAC11= 0xffff5bb1; 
uint4 mAC12= 0x895cd7be; 
uint4 mAC13= 0x6b901122; 
uint4 mAC14= 0xfd987193; 
uint4 mAC15= 0xa679438e; 
uint4 mAC16= 0x49b40821; 
uint4 mAC17= 0xf61e2562; 
uint4 mAC18= 0xc040b340; 
uint4 mAC19= 0x265e5a51; 
uint4 mAC20= 0xe9b6c7aa; 
uint4 mAC21= 0xd62f105d; 
uint4 mAC22= 0x02441453; 
uint4 mAC23= 0xd8a1e681; 
uint4 mAC24= 0xe7d3fbc8; 
uint4 mAC25= 0x21e1cde6; 
uint4 mAC26= 0xc33707d6; 
uint4 mAC27= 0xf4d50d87; 
uint4 mAC28= 0x455a14ed; 
uint4 mAC29= 0xa9e3e905; 
uint4 mAC30= 0xfcefa3f8; 
uint4 mAC31= 0x676f02d9; 
uint4 mAC32= 0x8d2a4c8a; 
uint4 mAC33= 0xfffa3942; 
uint4 mAC34= 0x8771f681; 
uint4 mAC35= 0x6d9d6122; 
uint4 mAC36= 0xfde5380c; 
uint4 mAC37= 0xa4beea44;
uint4 mAC38= 0x4bdecfa9; 
uint4 mAC39= 0xf6bb4b60; 
uint4 mAC40= 0xbebfbc70; 
uint4 mAC41= 0x289b7ec6; 
uint4 mAC42= 0xeaa127fa; 
uint4 mAC43= 0xd4ef3085; 
uint4 mAC44= 0x04881d05; 
uint4 mAC45= 0xd9d4d039; 
uint4 mAC46= 0xe6db99e5; 
uint4 mAC47= 0x1fa27cf8; 
uint4 mAC48= 0xc4ac5665; 
uint4 mAC49= 0xf4292244; 
uint4 mAC50= 0x432aff97; 
uint4 mAC51= 0xab9423a7; 
uint4 mAC52= 0xfc93a039; 
uint4 mAC53= 0x655b59c3; 
uint4 mAC54= 0x8f0ccc92; 
uint4 mAC55= 0xffeff47d; 
uint4 mAC56= 0x85845dd1; 
uint4 mAC57= 0x6fa87e4f; 
uint4 mAC58= 0xfe2ce6e0; 
uint4 mAC59= 0xa3014314; 
uint4 mAC60= 0x4e0811a1; 
uint4 mAC61= 0xf7537e82; 
uint4 mAC62= 0xbd3af235; 
uint4 mAC63= 0x2ad7d2bb; 
uint4 mAC64= 0xeb86d391; 

chbase1=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);
SIZE = size; 
x1 = input.y; 
x2 = input.z; 
//x3 = input.w; 
i = table[get_global_id(0)];
/*
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
x0 = ib|(ic<<8)|(id<<16)|(chbase1<<24); 
*/
x0 = i|(chbase1<<24); 


a = mCa; b = mCb; c = mCc; d = mCd;

#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define MD5STEP_ROUND1(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  
#define MD5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND1_NOC(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  


MD5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1_NOC(F, d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1_NOC(F, c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC4, S14);  
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
MD5STEP_ROUND1_NOC (F, c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(f, a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

MD5STEP_ROUND2 (G, a, b, c, d, mAC17-mAC2, x1, S21);
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (G, d, a, b, c, mAC26-mAC15, SIZE, S22);  
//MD5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC27, S23);

MD5STEP_ROUND2_NULL (G, b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (G, d, a, b, c, mAC30-mAC3, x2, S22);
MD5STEP_ROUND2_NULL (G, c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(f, a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(f, a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(f, a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  

#define MD5STEP_ROUND3_NULL_ODD(f, a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 


MD5STEP_ROUND3_NULL_EVEN(H, a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (H, b, c, d, a, mAC36-mAC15, SIZE, S34);  
MD5STEP_ROUND3_EVEN (H, a, b, c, d, mAC37-mAC2, x1, S31);
MD5STEP_ROUND3_NULL_ODD (H, d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (H, d, a, b, c, mAC42, x0, S32);
//MD5STEP_ROUND3_EVEN (H, c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL_EVEN (H, c, d, a, b, mAC43, S33);

#ifdef SINGLE_MODE
t1=(singlehash.x)-x0; 
t2=(singlehash.y)-(t1^(singlehash.z^singlehash.w));
t3=(input.x)-(t1^t2^(singlehash.w));
if (all(t3 != c)) return;
id=1;
#endif
MD5STEP_ROUND3_NULL_ODD (H, b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if (all(t2 != b)) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (H, a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if (all(t1 != a)) return;
#endif
MD5STEP_ROUND3_NULL_ODD(H, d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(H, c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (H, b, c, d, a, mAC48-mAC3, x2, S34);

#define MD5STEP_ROUND4(f, a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(f, a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (I, c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41);
//MD5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC54, S42);

MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (I, b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (I, c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (I, a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (I, c, d, a, b, mAC63-mAC3, x2, S43);
MD5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

#ifndef SINGLE_MODE
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
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
