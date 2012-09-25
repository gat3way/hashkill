#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define bitselect(a,b,c) (((a)&(b))|((~a)&(c)))
#define bitselect1(a,b,c) (c^(a&(b^c)))
#define bitselect2(a,b,c) (b^(c&(a^b)))


#ifndef SM21

void md5_short1( __global uint4 *dst, uint4 input, uint size,  uint chbase,  __global uint *found_ind, __global  uint *bitmaps, __global uint *found, uint i,  uint4 singlehash, uint factor) 
{

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 7  
#define S12 12 
#define S13 17 
#define S14 22 
#define S21 5  
#define S22 9  
#define S23 14 
#define S24 20 
#define S31 4  
#define S32 11 
#define S33 16 
#define S34 23 
#define S41 6  
#define S42 10 
#define S43 15 
#define S44 21 


uint SIZE;  
uint ib,ic,id,ie;
uint mOne, mCa, mCb, mCc, mCd;
uint a,b,c,d, tmp1;  
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint x0,x1,x2,x3; 


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



mOne = (uint)0xFFFFFFFF;
mCa = (uint)Ca;
mCb = (uint)Cb;
mCc = (uint)Cc;
mCd = (uint)Cd;
ic = size+4;
id = ic*8; 
SIZE = (uint)id; 


x0 = (uint)input.x; 
x1 = (uint)input.y; 
x2 = (uint)input.z; 
x3 = (uint)input.w; 


ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255);  


if (size==1) {x0=chbase|(ib<<8)|(ic<<16)|(id<<24);x1=ie|(0x80<<8);}
else if (size==2) {x0|=(chbase<<8)|(ib<<16)|(ic<<24);x1=(id)|(ie<<8)|(0x80<<16);}  
else if (size==3) {x0|=(chbase<<16)|(ib<<24);x1=ic|(id<<8)|(ie<<16)|(0x80<<24);}
else if (size==4) {x0|=(chbase<<24);x1=(ib)|(ic<<8)|(id<<16)|(ie<<24);x2=(0x80);}  
else if (size==5) {x1=chbase|(ib<<8)|(ic<<16)|(id<<24);x2=(ie)|(0x80<<8);} 
else if (size==6) {x1|=(chbase<<8)|(ib<<16)|(ic<<24);x2=(id)|(ie<<8)|(0x80<<16);}  
else if (size==7) {x1|=(chbase<<16)|(ib<<24);x2=(ic)|(id<<8)|(ie<<16)|(0x80<<24);} 
else if (size==8) {x1|=(chbase<<24);x2=(ib)|(ic<<8)|(id<<16)|(ie<<24);x3=(0x80);}  
else if (size==9) {x2=(chbase)|(ib<<8)|(ic<<16)|(id<<24);x3=(ie)|(0x80<<8);}
else if (size==10) {x2|=(chbase<<8)|(ib<<16)|(ic<<24);x3=(id)|(ie<<8)|(0x80<<16);} 
else if (size==11) {x2|=(chbase<<16)|(ib<<24);x3=(ic)|(id<<8)|(ie<<16)|(0x80<<24);}

a = mCa; b = mCb; c = mCc; d = mCd;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect1((b),(c),(d));(a) = ROTATE(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect1((b),(c),(d));(a) = ROTATE(a,s)+(b);

#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = ROTATE(a,s)+(b);

a = ROTATE((uint)(0xd76aa477) + x0, S11) + b;
//MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x3, S14);  
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
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);


#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect2((d),(b),(c));(a) = ROTATE(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect2((d),(b),(c)); (a) = ROTATE(a,s)+(b);


MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3(a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = ROTATE(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);

MD5STEP_ROUND3_NULL(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC35, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3 (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_NULL (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC39, S33);
MD5STEP_ROUND3_NULL (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC41, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL (b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL (d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC47, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = ROTATE(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);

#ifdef SINGLE_MODE
id=singlehash.x - mCa;
if ((id!=a)) return;
#endif

MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

id = 0;

#ifdef SINGLE_MODE
if ((singlehash.y==b)&&(singlehash.z==c)&&(singlehash.w==d)) id = 1; 
if (id==0) return;
#else
id = 0;

b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}


#ifdef DOUBLE
dst[(get_global_id(0)<<1)+factor] = (uint4)(a,b,c,d);
#else
dst[(get_global_id(0)<<3)] = (uint4)(a,b,c,d);
#endif



}

__kernel void __attribute__((reqd_work_group_size(128, 1, 1))) 
 md5_short( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global  uint *bitmaps, __global uint *found, __global   uint *table,  uint4 singlehash) 
{
uint i;
uint chbase1;
i = table[get_global_id(0)];
chbase1 = (uint)(chbase.s0);
md5_short1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,0);
#ifdef DOUBLE
chbase1 = (uint)(chbase.s1);
md5_short1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,8);
#endif
}



#else

__kernel void 
__attribute__((reqd_work_group_size(128, 1, 1)))
md5_short( __global uint4 *dst, uint4 input, uint size,  uint16 chbase,  __global uint *found_ind, __global  uint *bitmaps, __global uint *found, __global   uint *table,  uint4 singlehash) 
{

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 7  
#define S12 12 
#define S13 17 
#define S14 22 
#define S21 5  
#define S22 9  
#define S23 14 
#define S24 20 
#define S31 4  
#define S32 11 
#define S33 16 
#define S34 23 
#define S41 6  
#define S42 10 
#define S43 15 
#define S44 21 


uint4 SIZE,chbase1;  
uint i,ib,ic,id,ie;
uint4 mOne, mCa, mCb, mCc, mCd;
uint4 a,b,c,d, tmp1;  
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 x0,x1,x2,x3; 


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




mOne = (uint4)(0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF);
mCa = (uint4)(Ca,Ca,Ca,Ca);
mCb = (uint4)(Cb,Cb,Cb,Cb);
mCc = (uint4)(Cc,Cc,Cc,Cc);
mCd = (uint4)(Cd,Cd,Cd,Cd);
ic = size+4;
id = ic*8; 
SIZE = (uint4)(id,id,id,id); 
chbase1=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);


x0 = (uint4)(input.x,input.x,input.x,input.x); 
x1 = (uint4)(input.y,input.y,input.y,input.y); 
x2 = (uint4)(input.z,input.z,input.z,input.z); 
x3 = (uint4)(input.w,input.w,input.w,input.w); 


i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255);  

if (size==1) {x0=chbase1|(ib<<8)|(ic<<16)|(id<<24);x1=ie|(0x80<<8);}
else if (size==2) {x0|=(chbase1<<8)|(ib<<16)|(ic<<24);x1=(id)|(ie<<8)|(0x80<<16);}  
else if (size==3) {x0|=(chbase1<<16)|(ib<<24);x1=ic|(id<<8)|(ie<<16)|(0x80<<24);}
else if (size==4) {x0|=(chbase1<<24);x1=(ib)|(ic<<8)|(id<<16)|(ie<<24);x2=(0x80);}  
else if (size==5) {x1=chbase1|(ib<<8)|(ic<<16)|(id<<24);x2=(ie)|(0x80<<8);} 
else if (size==6) {x1|=(chbase1<<8)|(ib<<16)|(ic<<24);x2=(id)|(ie<<8)|(0x80<<16);}  
else if (size==7) {x1|=(chbase1<<16)|(ib<<24);x2=(ic)|(id<<8)|(ie<<16)|(0x80<<24);} 
else if (size==8) {x1|=(chbase1<<24);x2=(ib)|(ic<<8)|(id<<16)|(ie<<24);x3=(0x80);}  
else if (size==9) {x2=(chbase1)|(ib<<8)|(ic<<16)|(id<<24);x3=(ie)|(0x80<<8);}
else if (size==10) {x2|=(chbase1<<8)|(ib<<16)|(ic<<24);x3=(id)|(ie<<8)|(0x80<<16);} 
else if (size==11) {x2|=(chbase1<<16)|(ib<<24);x3=(ic)|(id<<8)|(ie<<16)|(0x80<<24);}

a = mCa; b = mCb; c = mCc; d = mCd;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = ROTATE(a,s);(a) = (a)+(b);  
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);  
MD5STEP_ROUND1(a, b, c, d, mAC1, x0, S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x1, S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x2, S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x3, S14);  
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
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);


#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = ROTATE(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);
MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC18, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC21, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22, S22);
MD5STEP_ROUND2_NULL(c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC24, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC25, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC28, S24);
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC31, S23);
MD5STEP_ROUND2_NULL(b, c, d, a, mAC32, S24);


#define MD5STEP_ROUND3(a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = ROTATE(a,s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);

MD5STEP_ROUND3_NULL(a, b, c, d, mAC33, S31);
MD5STEP_ROUND3_NULL(d, a, b, c, mAC34, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC35, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3 (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_NULL (d, a, b, c, mAC38, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC39, S33);
MD5STEP_ROUND3_NULL (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC41, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_NULL (b, c, d, a, mAC44, S34);
MD5STEP_ROUND3_NULL (a, b, c, d, mAC45, S31);
MD5STEP_ROUND3_NULL (d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL (c, d, a, b, mAC47, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC48, x2, S34);


#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = ROTATE(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)) & mOne; tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = ROTATE(a,s); (a) = (a)+(b);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC50, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4_NULL (b, c, d, a, mAC52, S44);
MD5STEP_ROUND4_NULL(a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC57, S41);
MD5STEP_ROUND4_NULL(d, a, b, c, mAC58, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC59, S43);
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC61, S41);

#ifdef SINGLE_MODE
id=singlehash.x - mCa.s0;
if ((id!=a.s0)&&(id!=a.s1)&&(id!=a.s2)&&(id!=a.s3)) return;
#endif

MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

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
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
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