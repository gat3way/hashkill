#define rotate(x,y) ((x) << (y)) + ((x) >> (32-(y)))
#define bitselect1(a,b,c) (c^(a&(b^c)))
#define bitselect2(a,b,c) (b^(c&(a^b)))

#ifndef SM21

void md5_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint factor,uint x0, uint x1, uint x2, uint SIZE, uint c0, uint c1,uint c2, uint d0, uint d1, uint d2, uint t1, uint t2, uint t3,uint t4) 
{  
uint a=(uint)0x67452301;
uint b=(uint)0xefcdab89;
uint c=(uint)0x98badcfe;
uint d=(uint)0x10325476;
uint mCb= (uint)0xefcdab89;
uint mCc= (uint)0x98badcfe;
uint mCd= (uint)0x10325476;
uint mCa= (uint)0x67452301;
uint S11= (uint)7 ;
uint S12= (uint)12;
uint S13= (uint)17;
uint S14= (uint)22;
uint S21= (uint)5 ;
uint S22= (uint)9 ;
uint S23= (uint)14;
uint S24= (uint)20;
uint S31= (uint)4 ;
uint S32= (uint)11;
uint S33= (uint)16;
uint S34= (uint)23;
uint S41= (uint)6 ;
uint S42= (uint)10;
uint S43= (uint)15;
uint S44= (uint)21;

#define mAC1  (uint)0xd76aa478 
#define mAC2  (uint)0xe8c7b756 
#define mAC3  (uint)0x242070db 
#define mAC4  (uint)0xc1bdceee 
#define mAC5  (uint)0xf57c0faf 
#define mAC6  (uint)0x4787c62a 
#define mAC7  (uint)0xa8304613 
#define mAC8  (uint)0xfd469501 
#define mAC9  (uint)0x698098d8 
#define mAC10 (uint)0x8b44f7af 
#define mAC11 (uint)0xffff5bb1 
#define mAC12 (uint)0x895cd7be 
#define mAC13 (uint)0x6b901122 
#define mAC14 (uint)0xfd987193 
#define mAC15 (uint)0xa679438e 
#define mAC16 (uint)0x49b40821 
#define mAC17 (uint)0xf61e2562 
#define mAC18 (uint)0xc040b340 
#define mAC19 (uint)0x265e5a51 
#define mAC20 (uint)0xe9b6c7aa 
#define mAC21 (uint)0xd62f105d 
#define mAC22 (uint)0x02441453 
#define mAC23 (uint)0xd8a1e681 
#define mAC24 (uint)0xe7d3fbc8 
#define mAC25 (uint)0x21e1cde6 
#define mAC26 (uint)0xc33707d6 
#define mAC27 (uint)0xf4d50d87 
#define mAC28 (uint)0x455a14ed 
#define mAC29 (uint)0xa9e3e905 
#define mAC30 (uint)0xfcefa3f8 
#define mAC31 (uint)0x676f02d9 
#define mAC32 (uint)0x8d2a4c8a 
#define mAC33 (uint)0xfffa3942 
#define mAC34 (uint)0x8771f681 
#define mAC35 (uint)0x6d9d6122 
#define mAC36 (uint)0xfde5380c 
#define mAC37 (uint)0xa4beea44 
#define mAC38 (uint)0x4bdecfa9 
#define mAC39 (uint)0xf6bb4b60 
#define mAC40 (uint)0xbebfbc70 
#define mAC41 (uint)0x289b7ec6 
#define mAC42 (uint)0xeaa127fa 
#define mAC43 (uint)0xd4ef3085 
#define mAC44 (uint)0x04881d05 
#define mAC45 (uint)0xd9d4d039 
#define mAC46 (uint)0xe6db99e5 
#define mAC47 (uint)0x1fa27cf8 
#define mAC48 (uint)0xc4ac5665 
#define mAC49 (uint)0xf4292244 
#define mAC50 (uint)0x432aff97 
#define mAC51 (uint)0xab9423a7 
#define mAC52 (uint)0xfc93a039 
#define mAC53 (uint)0x655b59c3 
#define mAC54 (uint)0x8f0ccc92 
#define mAC55 (uint)0xffeff47d 
#define mAC56 (uint)0x85845dd1 
#define mAC57 (uint)0x6fa87e4f 
#define mAC58 (uint)0xfe2ce6e0 
#define mAC59 (uint)0xa3014314 
#define mAC60 (uint)0x4e0811a1 
#define mAC61 (uint)0xf7537e82 
#define mAC62 (uint)0xbd3af235 
#define mAC63 (uint)0x2ad7d2bb 
#define mAC64 (uint)0xeb86d391 


uint tmp1, tmp2;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NOC(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);

a = rotate((uint)(0xd76aa477) + x0, S11) + b;
MD5STEP_ROUND1_NOC(d, a, b, c, mAC2, x1, S12);
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
MD5STEP_ROUND1_NOC (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2S(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(x);(a) = rotate(a,s)+(b);

MD5STEP_ROUND2S (a, b, c, d, mAC17-mAC2, c1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2S (b, c, d, a, mAC20, c0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2S (d, a, b, c, mAC26-mAC15, c2, S22);  
MD5STEP_ROUND2_NULL (c, d, a, b, mAC27, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC30, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(AC)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_EVENS(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);(a) = (a)+(AC)+(tmp2 ^ (d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) (a) = (a)+(AC)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_ODDS(a, b, c, d, AC, x, s) (a) = (a)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  (a) = (a)+(AC)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b); 

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODDS (b, c, d, a, mAC36-mAC15, d2, S34);  
MD5STEP_ROUND3_EVENS (a, b, c, d, mAC37-mAC2, d1, S31);
MD5STEP_ROUND3_NULL_ODD (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODDS (d, a, b, c, mAC42, d0, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC43, S33);

#ifdef SINGLE_MODE
if ((t3 != c)) return;
#endif
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if ((t2 != b)) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if ((t1 != a)) return;
uint id=1;
#endif
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC48, S34);

#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC54, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC63, S43);
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint id=1;
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+(uint)0x67452301;b=b+(uint)0xefcdab89;c=c+(uint)0x98badcfe;d=d+(uint)0x10325476;



#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res] = (uint4)(a,b,c,d);
plains[res] = (uint4)(x0,x1-mAC2,x2-mAC3,0);

}



void md5_long2( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint factor,uint x0, uint x1, uint x2, uint x3, uint SIZE, uint c0, uint c1,uint c2, uint d0, uint d1, uint d2, uint t1, uint t2, uint t3,uint t4) 
{  
uint a=(uint)0x67452301;
uint b=(uint)0xefcdab89;
uint c=(uint)0x98badcfe;
uint d=(uint)0x10325476;
uint mCb= (uint)0xefcdab89;
uint mCc= (uint)0x98badcfe;
uint mCd= (uint)0x10325476;
uint mCa= (uint)0x67452301;
uint S11= (uint)7 ;
uint S12= (uint)12;
uint S13= (uint)17;
uint S14= (uint)22;
uint S21= (uint)5 ;
uint S22= (uint)9 ;
uint S23= (uint)14;
uint S24= (uint)20;
uint S31= (uint)4 ;
uint S32= (uint)11;
uint S33= (uint)16;
uint S34= (uint)23;
uint S41= (uint)6 ;
uint S42= (uint)10;
uint S43= (uint)15;
uint S44= (uint)21;

#define mAC1  (uint)0xd76aa478 
#define mAC2  (uint)0xe8c7b756 
#define mAC3  (uint)0x242070db 
#define mAC4  (uint)0xc1bdceee 
#define mAC5  (uint)0xf57c0faf 
#define mAC6  (uint)0x4787c62a 
#define mAC7  (uint)0xa8304613 
#define mAC8  (uint)0xfd469501 
#define mAC9  (uint)0x698098d8 
#define mAC10 (uint)0x8b44f7af 
#define mAC11 (uint)0xffff5bb1 
#define mAC12 (uint)0x895cd7be 
#define mAC13 (uint)0x6b901122 
#define mAC14 (uint)0xfd987193 
#define mAC15 (uint)0xa679438e 
#define mAC16 (uint)0x49b40821 
#define mAC17 (uint)0xf61e2562 
#define mAC18 (uint)0xc040b340 
#define mAC19 (uint)0x265e5a51 
#define mAC20 (uint)0xe9b6c7aa 
#define mAC21 (uint)0xd62f105d 
#define mAC22 (uint)0x02441453 
#define mAC23 (uint)0xd8a1e681 
#define mAC24 (uint)0xe7d3fbc8 
#define mAC25 (uint)0x21e1cde6 
#define mAC26 (uint)0xc33707d6 
#define mAC27 (uint)0xf4d50d87 
#define mAC28 (uint)0x455a14ed 
#define mAC29 (uint)0xa9e3e905 
#define mAC30 (uint)0xfcefa3f8 
#define mAC31 (uint)0x676f02d9 
#define mAC32 (uint)0x8d2a4c8a 
#define mAC33 (uint)0xfffa3942 
#define mAC34 (uint)0x8771f681 
#define mAC35 (uint)0x6d9d6122 
#define mAC36 (uint)0xfde5380c 
#define mAC37 (uint)0xa4beea44 
#define mAC38 (uint)0x4bdecfa9 
#define mAC39 (uint)0xf6bb4b60 
#define mAC40 (uint)0xbebfbc70 
#define mAC41 (uint)0x289b7ec6 
#define mAC42 (uint)0xeaa127fa 
#define mAC43 (uint)0xd4ef3085 
#define mAC44 (uint)0x04881d05 
#define mAC45 (uint)0xd9d4d039 
#define mAC46 (uint)0xe6db99e5 
#define mAC47 (uint)0x1fa27cf8 
#define mAC48 (uint)0xc4ac5665 
#define mAC49 (uint)0xf4292244 
#define mAC50 (uint)0x432aff97 
#define mAC51 (uint)0xab9423a7 
#define mAC52 (uint)0xfc93a039 
#define mAC53 (uint)0x655b59c3 
#define mAC54 (uint)0x8f0ccc92 
#define mAC55 (uint)0xffeff47d 
#define mAC56 (uint)0x85845dd1 
#define mAC57 (uint)0x6fa87e4f 
#define mAC58 (uint)0xfe2ce6e0 
#define mAC59 (uint)0xa3014314 
#define mAC60 (uint)0x4e0811a1 
#define mAC61 (uint)0xf7537e82 
#define mAC62 (uint)0xbd3af235 
#define mAC63 (uint)0x2ad7d2bb 
#define mAC64 (uint)0xeb86d391 


uint tmp1, tmp2;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NOC(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);

a = rotate((uint)(0xd76aa477) + x0, S11) + b;
MD5STEP_ROUND1_NOC(d, a, b, c, mAC2, x1, S12);
MD5STEP_ROUND1_NOC(c, d, a, b, mAC3, x2, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC4, x3, S14);
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
MD5STEP_ROUND1_NOC (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2S(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(x);(a) = rotate(a,s)+(b);

MD5STEP_ROUND2S (a, b, c, d, mAC17-mAC2, c1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2S (b, c, d, a, mAC20, c0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2S (d, a, b, c, mAC26-mAC15, c2, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27,x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30-mAC3, x2, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(AC)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_EVENS(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);(a) = (a)+(AC)+(tmp2 ^ (d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) (a) = (a)+(AC)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_ODDS(a, b, c, d, AC, x, s) (a) = (a)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  (a) = (a)+(AC)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b); 

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODDS (b, c, d, a, mAC36-mAC15, d2, S34);  
MD5STEP_ROUND3_EVENS (a, b, c, d, mAC37-mAC2, d1, S31);
MD5STEP_ROUND3_NULL_ODD (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODDS (d, a, b, c, mAC42, d0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43,x3, S33);

#ifdef SINGLE_MODE
if ((t3 != c)) return;
#endif
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if ((t2 != b)) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if ((t1 != a)) return;
uint id=1;
#endif
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48-mAC3, x2, S34);



#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63-mAC3, x2, S43);
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint id=1;
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);


a=a+(uint)0x67452301;b=b+(uint)0xefcdab89;c=c+(uint)0x98badcfe;d=d+(uint)0x10325476;


#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res] = (uint4)(a,b,c,d);
plains[res] = (uint4)(x0,x1-mAC2,x2-mAC3,x3);

}





__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
x0=(i|j);
c0=x0+(uint)0xe9b6c7aa;
d0=x0+(uint)0xeaa127fa;
c2=SIZE+(uint)0xc33707d6-(uint)0xa679438e;
d2=SIZE+(uint)0xfde5380c-(uint)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s0,chbase3.s1,chbase3.s2,chbase3.s3);
singlehash=(uint4)(chbase4.s0,chbase4.s1,chbase4.s2,chbase4.s3);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s4,chbase3.s5,chbase3.s6,chbase3.s7);
singlehash=(uint4)(chbase4.s4,chbase4.s5,chbase4.s6,chbase4.s7);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s8,chbase3.s9,chbase3.sA,chbase3.sB);
singlehash=(uint4)(chbase4.s8,chbase4.s9,chbase4.sA,chbase4.sB);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.sC,chbase3.sD,chbase3.sE,chbase3.sF);
singlehash=(uint4)(chbase4.sC,chbase4.sD,chbase4.sE,chbase4.sF);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);

}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
x0=(i|j);
c0=x0+(uint)0xe9b6c7aa;
d0=x0+(uint)0xeaa127fa;
c2=SIZE+(uint)0xc33707d6-(uint)0xa679438e;
d2=SIZE+(uint)0xfde5380c-(uint)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);

x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
x1 = (uint)input.y; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_double8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2,x3;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
x0=(i|j);
c0=x0+(uint)0xe9b6c7aa;
d0=x0+(uint)0xeaa127fa;
c2=SIZE+(uint)0xc33707d6-(uint)0xa679438e;
d2=SIZE+(uint)0xfde5380c-(uint)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s0,chbase3.s1,chbase3.s2,chbase3.s3);
singlehash=(uint4)(chbase4.s0,chbase4.s1,chbase4.s2,chbase4.s3);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s4,chbase3.s5,chbase3.s6,chbase3.s7);
singlehash=(uint4)(chbase4.s4,chbase4.s5,chbase4.s6,chbase4.s7);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.s8,chbase3.s9,chbase3.sA,chbase3.sB);
singlehash=(uint4)(chbase4.s8,chbase4.s9,chbase4.sA,chbase4.sB);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase3.sC,chbase3.sD,chbase3.sE,chbase3.sF);
singlehash=(uint4)(chbase4.sC,chbase4.sD,chbase4.sE,chbase4.sF);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);

}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_normal8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2,x3;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
x0=(i|j);
c0=x0+(uint)0xe9b6c7aa;
d0=x0+(uint)0xeaa127fa;
c2=SIZE+(uint)0xc33707d6-(uint)0xa679438e;
d2=SIZE+(uint)0xfde5380c-(uint)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);

x1 = (uint)input.y;
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 
c1=x1+(uint)0xf61e2562-(uint)0xe8c7b756;
t4=(uint)(singlehash.z^singlehash.w);
d1=x1+(uint)0xa4beea44-(uint)0xe8c7b756; 
t1=(uint)(singlehash.x)-x0; 
t2=(uint)(singlehash.y)-(t4^t1);
t3=(uint)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}


#else


void md5_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint factor,uint4 x0, uint4 x1, uint4 x2, uint4 SIZE, uint4 c0, uint4 c1,uint4 c2, uint4 d0, uint4 d1, uint4 d2, uint4 t1, uint4 t2, uint4 t3,uint4 t4) 
{  

uint4 a=(uint4)0x67452301;
uint4 b=(uint4)0xefcdab89;
uint4 c=(uint4)0x98badcfe;
uint4 d=(uint4)0x10325476;
const uint mCb=(uint)0xefcdab89;
const uint mCc=(uint)0x98badcfe;
const uint mCd=(uint)0x10325476;
const uint mCa=(uint)0x67452301;

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


uint4 tmp1, tmp2;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect1((b),(c),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NOC(a, b, c, d, AC, x, s)  (a)=(a)+(x)+bitselect1((b),(c),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect1((b),(c),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);

a = rotate((uint4)(0xd76aa477) + x0, S11) + b;
MD5STEP_ROUND1_NOC(d, a, b, c, mAC2, x1, S12);
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
MD5STEP_ROUND1_NOC (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect2((b),(c),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect2((b),(c),(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect2((b),(c),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2S(a, b, c, d, AC, x, s)  (a)=(a)+(x)+bitselect2((b),(c),(d));(a) = rotate(a,s)+(b);

MD5STEP_ROUND2S (a, b, c, d, mAC17-mAC2, c1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2S (b, c, d, a, mAC20, c0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2S (d, a, b, c, mAC26-mAC15, c2, S22);  
MD5STEP_ROUND2_NULL (c, d, a, b, mAC27, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC30, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(AC)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_EVENS(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);(a) = (a)+(AC)+(tmp2 ^ (d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) (a) = (a)+(AC)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_ODDS(a, b, c, d, AC, x, s) (a) = (a)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  (a) = (a)+(AC)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b); 

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODDS (b, c, d, a, mAC36-mAC15, d2, S34);  
MD5STEP_ROUND3_EVENS (a, b, c, d, mAC37-mAC2, d1, S31);
MD5STEP_ROUND3_NULL_ODD (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODDS (d, a, b, c, mAC42, d0, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC43, S33);

#ifdef SINGLE_MODE

if (all(t3 != c)) return;
#endif
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if (all(t2 != b)) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if (all(t1 != a)) return;
uint id=1;
#endif
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC48, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC54, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC63, S43);
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint id=1;
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+(uint4)0x67452301;b=b+(uint4)0xefcdab89;c=c+(uint4)0x98badcfe;d=d+(uint4)0x10325476;


#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res*4] = (uint4)(a.s0,b.s0,c.s0,d.s0);
hashes[res*4+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
hashes[res*4+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
hashes[res*4+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

plains[res*4] = (uint4)(x0.s0,x1.s0-mAC2,x2.s0-mAC3,0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1-mAC2,x2.s1-mAC3,0);
plains[res*4+2] = (uint4)(x0.s2,x1.s2-mAC2,x2.s2-mAC3,0);
plains[res*4+3] = (uint4)(x0.s3,x1.s3-mAC2,x2.s3-mAC3,0);
}



void md5_long2( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint factor,uint4 x0, uint4 x1, uint4 x2, uint4 x3, uint4 SIZE, uint4 c0, uint4 c1,uint4 c2, uint4 d0, uint4 d1, uint4 d2, uint4 t1, uint4 t2, uint4 t3,uint4 t4) 
{  

uint4 a=(uint4)0x67452301;
uint4 b=(uint4)0xefcdab89;
uint4 c=(uint4)0x98badcfe;
uint4 d=(uint4)0x10325476;
const uint mCb=(uint)0xefcdab89;
const uint mCc=(uint)0x98badcfe;
const uint mCd=(uint)0x10325476;
const uint mCa=(uint)0x67452301;

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


uint4 tmp1, tmp2;


#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NOC(a, b, c, d, AC, x, s)  (a)=(a)+bitselect1((b),(c),(d))+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect1((b),(c),(d))+(AC);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);

a = rotate((uint4)(0xd76aa477) + x0, S11) + b;
MD5STEP_ROUND1_NOC(d, a, b, c, mAC2, x1, S12);
MD5STEP_ROUND1_NOC(c, d, a, b, mAC3, x2, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC4, x3, S14);
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
MD5STEP_ROUND1_NOC (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC)+(x);(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+bitselect2((b),(c),(d))+(AC); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2S(a, b, c, d, AC, x, s)  (a)=(a)+bitselect2((b),(c),(d))+(x);(a) = rotate(a,s)+(b);

MD5STEP_ROUND2S (a, b, c, d, mAC17-mAC2, c1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2S (b, c, d, a, mAC20, c0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2S (d, a, b, c, mAC26-mAC15, c2, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27,x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30-mAC3, x2, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(AC)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_EVENS(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);(a) = (a)+(x)+(tmp2^(d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);(a) = (a)+(AC)+(tmp2 ^ (d)); (a) = rotate(a,s)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) (a) = (a)+(AC)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_ODDS(a, b, c, d, AC, x, s) (a) = (a)+(x)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  (a) = (a)+(AC)+(tmp2 ^ (b)); (a) = rotate(a,s)+(b); 

MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODDS (b, c, d, a, mAC36-mAC15, d2, S34);  
MD5STEP_ROUND3_EVENS (a, b, c, d, mAC37-mAC2, d1, S31);
MD5STEP_ROUND3_NULL_ODD (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC39, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODDS (d, a, b, c, mAC42, d0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43,x3, S33);

#ifdef SINGLE_MODE
if (all(t3 != c)) return;
#endif
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC44, S34);
#ifdef SINGLE_MODE
if (all(t2 != b)) return;
#endif
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC45, S31);  
#ifdef SINGLE_MODE
if (all(t1 != a)) return;
uint id=1;
#endif
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48-mAC3, x2, S34);



#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);


MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51-mAC15, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56-mAC2, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63-mAC3, x2, S43);
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint id=1;
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+(uint4)0x67452301;b=b+(uint4)0xefcdab89;c=c+(uint4)0x98badcfe;d=d+(uint4)0x10325476;


#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res*4] = (uint4)(a.s0,b.s0,c.s0,d.s0);
hashes[res*4+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
hashes[res*4+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
hashes[res*4+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

plains[res*4] = (uint4)(x0.s0,x1.s0-mAC2,x2.s0-mAC3,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1-mAC2,x2.s1-mAC3,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2-mAC2,x2.s2-mAC3,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3-mAC2,x2.s3-mAC3,x3.s3);
}





__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
__global uint *k;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 


SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

x0=(i|j);
c0=x0+(uint4)0xe9b6c7aa;
d0=x0+(uint4)0xeaa127fa;
c2=SIZE+(uint4)0xc33707d6-(uint4)0xa679438e;
d2=SIZE+(uint4)0xfde5380c-(uint4)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint4)input.y; 
c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint4)input.y; 
c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

x0=(i|j);
c0=x0+(uint4)0xe9b6c7aa;
d0=x0+(uint4)0xeaa127fa;
c2=SIZE+(uint4)0xc33707d6-(uint4)0xa679438e;
d2=SIZE+(uint4)0xfde5380c-(uint4)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint4)input.y; 
c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long1(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_double8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
__global uint *k;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2,x3;
uint4 t4;
uint4 input;
uint4 singlehash; 


SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

x0=(i|j);
c0=x0+(uint4)0xe9b6c7aa;
d0=x0+(uint4)0xeaa127fa;
c2=SIZE+(uint4)0xc33707d6-(uint4)0xa679438e;
d2=SIZE+(uint4)0xfde5380c-(uint4)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint4)input.y; 
x2 = (uint4)input.z; 
x3 = (uint4)input.w; 

c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
x1 = (uint4)input.y; 
x2 = (uint4)input.z; 
x3 = (uint4)input.w; 

c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_long_normal8( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2,x3;
uint4 t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

x0=(i|j);
c0=x0+(uint4)0xe9b6c7aa;
d0=x0+(uint4)0xeaa127fa;
c2=SIZE+(uint4)0xc33707d6-(uint4)0xa679438e;
d2=SIZE+(uint4)0xfde5380c-(uint4)0xa679438e;


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
x1 = (uint4)input.y; 
x2 = (uint4)input.z; 
x3 = (uint4)input.w; 

c1=x1+(uint4)0xf61e2562-(uint4)0xe8c7b756;
t4=(uint4)(singlehash.z^singlehash.w);
d1=x1+(uint4)0xa4beea44-(uint4)0xe8c7b756; 
t1=(uint4)(singlehash.x)-x0; 
t2=(uint4)(singlehash.y)-(t4^t1);
t3=(uint4)(input.x)-(t1^t2^singlehash.w);
md5_long2(hashes,input, size, plains, bitmaps, found, singlehash,0,x0,x1,x2,x3,SIZE,c0,c1,c2,d0,d1,d2,t1,t2,t3,t4);
}

#endif
