#define rotate(x,y) ((x) << (y)) + ((x) >> (32-(y)))

#ifndef SM21

#define getglobalid(a) (mad24(get_group_id(0), 64U, get_local_id(0)))


void md5_saltpass_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains,  __global uint *found,  uint4 singlehash, uint k, uint16 salt) 
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
uint ib,ic,id,ie;  
uint i1,i2,i3,i4,i;
uint t1,t2,t3;
uint a,b,c,d, tmp1, tmp2; 
uint x0,x1,x2,x3; 
uint x4,x5,x6,x7,x8,x9,x10,x11,x12,temp; 
uint xx0,xx1,xx2,xx3;
uint x[16];

SIZE = (uint)salt.sF; 

i = k;
i1=i&255;
i2=(i>>8)&255;
i3=(i>>16)&255;
i4=(i>>24)&255;


x[0] = (uint)salt.s0;
x[1] = (uint)salt.s1;
x[2] = (uint)salt.s2;
x[3] = (uint)salt.s3;
x[4] = (uint)salt.s4;
x[5] = (uint)salt.s5;
x[6] = (uint)salt.s6;
x[7] = (uint)salt.s7;
x[8] = (uint)salt.s8;
x[9] = (uint)salt.s9;
x[10] = (uint)salt.sA;


x[salt.sE>>2] |= i1<<((salt.sE&3)<<3);
x[(salt.sE+1)>>2] |= i2<<(((salt.sE+1)&3)<<3);
x[(salt.sE+2)>>2] |= i3<<(((salt.sE+2)&3)<<3);
x[(salt.sE+3)>>2] |= i4<<(((salt.sE+3)&3)<<3);

xx0=i;
xx1=(uint)input.y;
xx2=(uint)input.z;
xx3=(uint)input.w;

x0=x[0];
x1=x[1];
x2=x[2];
x3=x[3];
x4=x[4];
x5=x[5];
x6=x[6];
x7=x[7];
x8=x[8];
x9=x[9];
x10=x[10];

a = mCa; b = mCb; c = mCc; d = mCd;
id=0;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);

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
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x10,S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,  S24);

#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 



MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x10, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x10, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;


#ifndef SM10
uint res = atomic_inc(found);
#else
uint res = found[0];
found[0]++;
#endif
hashes[res] = (uint4)(a,b,c,d);
plains[res] = (uint4)(xx0,xx1,xx2,xx3);


}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_saltpass_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
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
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase3);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
md5_saltpass_long1(hashes,input, size, plains,  found, singlehash,k,chbase4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase5);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase6);

}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_saltpass_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
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
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase3);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase4);

}

#else

void md5_saltpass_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *found,  uint4 singlehash,uint4 k, uint16 salt) 
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
uint ib,ic,id,ie;  
uint4 i1,i2,i3,i4,i;
uint4 t1,t2,t3;
uint4 a,b,c,d, tmp1, tmp2; 
uint4 x0,x1,x2,x3; 
uint4 x4,x5,x6,x7,x8,x9,x10,x11,x12,temp; 
uint4 xx0,xx1,xx2,xx3;
uint4 x[16];

SIZE = (uint4)salt.sF; 

i = k;
i1=i&255;
i2=(i>>8)&255;
i3=(i>>16)&255;
i4=(i>>24)&255;


x[0] = (uint4)salt.s0;
x[1] = (uint4)salt.s1;
x[2] = (uint4)salt.s2;
x[3] = (uint4)salt.s3;
x[4] = (uint4)salt.s4;
x[5] = (uint4)salt.s5;
x[6] = (uint4)salt.s6;
x[7] = (uint4)salt.s7;
x[8] = (uint4)salt.s8;
x[9] = (uint4)salt.s9;
x[10] = (uint4)salt.sA;


x[salt.sE>>2] |= i1<<((salt.sE&3)<<3);
x[(salt.sE+1)>>2] |= i2<<(((salt.sE+1)&3)<<3);
x[(salt.sE+2)>>2] |= i3<<(((salt.sE+2)&3)<<3);
x[(salt.sE+3)>>2] |= i4<<(((salt.sE+3)&3)<<3);

xx0=i;
xx1=(uint4)input.y;
xx2=(uint4)input.z;
xx3=(uint4)input.w;

x0=x[0];
x1=x[1];
x2=x[2];
x3=x[3];
x4=x[4];
x5=x[5];
x6=x[6];
x7=x[7];
x8=x[8];
x9=x[9];
x10=x[10];

a = mCa; b = mCb; c = mCc; d = mCd;
id=0;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);

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
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x10,S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,  S24);

#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 



MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x10, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x10, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;


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

plains[res*4] = (uint4)(xx0.s0,xx1.s0,xx2.s0,xx3.s0);
plains[res*4+1] = (uint4)(xx0.s1,xx1.s1,xx2.s1,xx3.s1);
plains[res*4+2] = (uint4)(xx0.s2,xx1.s2,xx2.s2,xx3.s2);
plains[res*4+3] = (uint4)(xx0.s3,xx1.s3,xx2.s3,xx3.s3);

}



__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_saltpass_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint4 i;
uint j;
uint4 k;
uint4 input;
uint4 singlehash; 


i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
{
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase3);
}

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
{
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase4);
}
}




__kernel void  __attribute__((reqd_work_group_size(128, 1, 1))) 
md5_saltpass_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint4 i,k;
uint j;
uint4 input;
uint4 singlehash; 

i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
md5_saltpass_long1(hashes,input, size, plains, found, singlehash,k,chbase3);
}




#endif
