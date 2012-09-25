__kernel  void md5md5_short( __global uint4 *dst,const uint4 input,const uint size, const uint8 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
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


uint4 SIZE;  
uint i,ib,ic,id,ie;
uint4 mOne, mCa, mCb, mCc, mCd;
uint4 a,b,c,d, tmp1;  
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 x0,x1,x2,x3,x4,x5,x6,x7,x8,chbase1;  

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

mOne = (uint4)0xFFFFFFFF;
mCa = (uint4)Ca;
mCb = (uint4)Cb;
mCc = (uint4)Cc;
mCd = (uint4)Cd;

ic = size+4;
id = ic*8; 
SIZE = (uint4)id; 


x0 = (uint4)input.x;
x1 = (uint4)input.y;
x2 = (uint4)input.z;
x3 = (uint4)input.w;

chbase1 = (uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);

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


#ifndef GCN
#ifndef OLD_ATI
#define md5md5STEP_ROUND1(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#else
#define md5md5STEP_ROUND1(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);
#define md5md5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif
#else
#define md5md5STEP_ROUND1(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND1_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND1A(f, a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif
#ifndef GCN
#ifdef OLD_ATI
#define md5md5STEP_ROUND2(f, a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#else
#define md5md5STEP_ROUND2(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif
#else
#define md5md5STEP_ROUND2(f, a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define md5md5STEP_ROUND2_NULL(f, a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif
#define md5md5STEP_ROUND3_EVEN(f, a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b); 
#define md5md5STEP_ROUND3_NULL_EVEN(f, a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND3_ODD(f, a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND3_NULL_ODD(f, a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  
#define md5md5STEP_ROUND3(f, a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define md5md5STEP_ROUND3_NULL(f, a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND4(f, a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define md5md5STEP_ROUND4_NULL(f, a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);





x4=x5=x6=x7=(uint4)(0,0,0,0);  

md5md5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);
md5md5STEP_ROUND1(F, d, a, b, c, mAC2, x1, S12);
md5md5STEP_ROUND1(F, c, d, a, b, mAC3, x2, S13);
md5md5STEP_ROUND1(F, b, c, d, a, mAC4, x3, S14);
md5md5STEP_ROUND1(F, a, b, c, d, mAC5, x4, S11);
md5md5STEP_ROUND1(F, d, a, b, c, mAC6, x5, S12);
md5md5STEP_ROUND1(F, c, d, a, b, mAC7, x6, S13);
md5md5STEP_ROUND1(F, b, c, d, a, mAC8, x7, S14);
md5md5STEP_ROUND1_NULL(F, a, b, c, d, mAC9, S11);  
md5md5STEP_ROUND1_NULL(F, d, a, b, c, mAC10, S12); 
md5md5STEP_ROUND1_NULL(F, c, d, a, b, mAC11, S13); 
md5md5STEP_ROUND1_NULL(F, b, c, d, a, mAC12, S14); 
md5md5STEP_ROUND1_NULL(F, a, b, c, d, mAC13, S11); 
md5md5STEP_ROUND1_NULL(F, d, a, b, c, mAC14, S12); 
md5md5STEP_ROUND1 (F, c, d, a, b, mAC15, SIZE, S13);
md5md5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14); 

md5md5STEP_ROUND2 (G, a, b, c, d, mAC17, x1, S21); 
md5md5STEP_ROUND2 (G, d, a, b, c, mAC18, x6, S22); 
md5md5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23);
md5md5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24); 
md5md5STEP_ROUND2 (G, a, b, c, d, mAC21, x5, S21); 
md5md5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22);
md5md5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23);
md5md5STEP_ROUND2 (G, b, c, d, a, mAC24, x4, S24); 
md5md5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21);
md5md5STEP_ROUND2 (G, d, a, b, c, mAC26, SIZE, S22);
md5md5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23); 
md5md5STEP_ROUND2_NULL (G, b, c, d, a, mAC28, S24);
md5md5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21); 
md5md5STEP_ROUND2 (G, d, a, b, c, mAC30, x2, S22); 
md5md5STEP_ROUND2 (G, c, d, a, b, mAC31, x7, S23); 
md5md5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24); 

md5md5STEP_ROUND3(H, a, b, c, d, mAC33, x5, S31);  
md5md5STEP_ROUND3_NULL(H, d, a, b, c, mAC34, S32); 
md5md5STEP_ROUND3_NULL (H, c, d, a, b, mAC35, S33);
md5md5STEP_ROUND3 (H, b, c, d, a, mAC36, SIZE, S34);
md5md5STEP_ROUND3 (H, a, b, c, d, mAC37, x1, S31); 
md5md5STEP_ROUND3 (H, d, a, b, c, mAC38,x4, S32);  
md5md5STEP_ROUND3 (H, c, d, a, b, mAC39,x7, S33);  
md5md5STEP_ROUND3_NULL (H, b, c, d, a, mAC40, S34);
md5md5STEP_ROUND3_NULL(H, a, b, c, d, mAC41, S31); 
md5md5STEP_ROUND3 (H, d, a, b, c, mAC42, x0, S32); 
md5md5STEP_ROUND3 (H, c, d, a, b, mAC43, x3, S33); 
md5md5STEP_ROUND3 (H, b, c, d, a, mAC44,x6, S34);  
md5md5STEP_ROUND3_NULL (H, a, b, c, d, mAC45, S31);
md5md5STEP_ROUND3_NULL(H, d, a, b, c, mAC46, S32); 
md5md5STEP_ROUND3_NULL(H, c, d, a, b, mAC47, S33); 
md5md5STEP_ROUND3 (H, b, c, d, a, mAC48, x2, S34); 

md5md5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41); 
md5md5STEP_ROUND4 (I, d, a, b, c, mAC50, x7, S42); 
md5md5STEP_ROUND4 (I, c, d, a, b, mAC51, SIZE, S43);
md5md5STEP_ROUND4 (I, b, c, d, a, mAC52, x5, S44); 
md5md5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41); 
md5md5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42); 
md5md5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43);
md5md5STEP_ROUND4 (I, b, c, d, a, mAC56, x1, S44); 
md5md5STEP_ROUND4_NULL (I, a, b, c, d, mAC57, S41);
md5md5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42); 
md5md5STEP_ROUND4 (I, c, d, a, b, mAC59, x6, S43); 
md5md5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44); 
md5md5STEP_ROUND4 (I, a, b, c, d, mAC61, x4, S41); 
md5md5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42);
md5md5STEP_ROUND4 (I, c, d, a, b, mAC63, x2, S43); 
md5md5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

b1=(a.x&255)&15;b2=(a.x&255)>>4;b3=((a.x>>8)&255)&15;b4=((a.x>>8)&255)>>4; 
b5=(a.y&255)&15;b6=(a.y&255)>>4;b7=((a.y>>8)&255)&15;b8=((a.y>>8)&255)>>4; 
b9=(a.z&255)&15;b10=(a.z&255)>>4;b11=((a.z>>8)&255)&15;b12=((a.z>>8)&255)>>4;  
b13=(a.w&255)&15;b14=(a.w&255)>>4;b15=((a.w>>8)&255)&15;b16=((a.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x0=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((a.x>>16)&255)&15;b2=((a.x>>16)&255)>>4;b3=((a.x>>24)&255)&15;b4=((a.x>>24)&255)>>4;
b5=((a.y>>16)&255)&15;b6=((a.y>>16)&255)>>4;b7=((a.y>>24)&255)&15;b8=((a.y>>24)&255)>>4;
b9=((a.z>>16)&255)&15;b10=((a.z>>16)&255)>>4;b11=((a.z>>24)&255)&15;b12=((a.z>>24)&255)>>4;
b13=((a.w>>16)&255)&15;b14=((a.w>>16)&255)>>4;b15=((a.w>>24)&255)&15;b16=((a.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x1=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(b.x&255)&15;b2=(b.x&255)>>4;b3=((b.x>>8)&255)&15;b4=((b.x>>8)&255)>>4; 
b5=(b.y&255)&15;b6=(b.y&255)>>4;b7=((b.y>>8)&255)&15;b8=((b.y>>8)&255)>>4; 
b9=(b.z&255)&15;b10=(b.z&255)>>4;b11=((b.z>>8)&255)&15;b12=((b.z>>8)&255)>>4;  
b13=(b.w&255)&15;b14=(b.w&255)>>4;b15=((b.w>>8)&255)&15;b16=((b.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x2=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((b.x>>16)&255)&15;b2=((b.x>>16)&255)>>4;b3=((b.x>>24)&255)&15;b4=((b.x>>24)&255)>>4;
b5=((b.y>>16)&255)&15;b6=((b.y>>16)&255)>>4;b7=((b.y>>24)&255)&15;b8=((b.y>>24)&255)>>4;
b9=((b.z>>16)&255)&15;b10=((b.z>>16)&255)>>4;b11=((b.z>>24)&255)&15;b12=((b.z>>24)&255)>>4;
b13=((b.w>>16)&255)&15;b14=((b.w>>16)&255)>>4;b15=((b.w>>24)&255)&15;b16=((b.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x3=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(c.x&255)&15;b2=(c.x&255)>>4;b3=((c.x>>8)&255)&15;b4=((c.x>>8)&255)>>4; 
b5=(c.y&255)&15;b6=(c.y&255)>>4;b7=((c.y>>8)&255)&15;b8=((c.y>>8)&255)>>4; 
b9=(c.z&255)&15;b10=(c.z&255)>>4;b11=((c.z>>8)&255)&15;b12=((c.z>>8)&255)>>4;  
b13=(c.w&255)&15;b14=(c.w&255)>>4;b15=((c.w>>8)&255)&15;b16=((c.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x4=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((c.x>>16)&255)&15;b2=((c.x>>16)&255)>>4;b3=((c.x>>24)&255)&15;b4=((c.x>>24)&255)>>4;
b5=((c.y>>16)&255)&15;b6=((c.y>>16)&255)>>4;b7=((c.y>>24)&255)&15;b8=((c.y>>24)&255)>>4;
b9=((c.z>>16)&255)&15;b10=((c.z>>16)&255)>>4;b11=((c.z>>24)&255)&15;b12=((c.z>>24)&255)>>4;
b13=((c.w>>16)&255)&15;b14=((c.w>>16)&255)>>4;b15=((c.w>>24)&255)&15;b16=((c.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x5=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=(d.x&255)&15;b2=(d.x&255)>>4;b3=((d.x>>8)&255)&15;b4=((d.x>>8)&255)>>4; 
b5=(d.y&255)&15;b6=(d.y&255)>>4;b7=((d.y>>8)&255)&15;b8=((d.y>>8)&255)>>4; 
b9=(d.z&255)&15;b10=(d.z&255)>>4;b11=((d.z>>8)&255)&15;b12=((d.z>>8)&255)>>4;  
b13=(d.w&255)&15;b14=(d.w&255)>>4;b15=((d.w>>8)&255)&15;b16=((d.w>>8)&255)>>4; 
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x6=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );

b1=((d.x>>16)&255)&15;b2=((d.x>>16)&255)>>4;b3=((d.x>>24)&255)&15;b4=((d.x>>24)&255)>>4;
b5=((d.y>>16)&255)&15;b6=((d.y>>16)&255)>>4;b7=((d.y>>24)&255)&15;b8=((d.y>>24)&255)>>4;
b9=((d.z>>16)&255)&15;b10=((d.z>>16)&255)>>4;b11=((d.z>>24)&255)&15;b12=((d.z>>24)&255)>>4;
b13=((d.w>>16)&255)&15;b14=((d.w>>16)&255)>>4;b15=((d.w>>24)&255)&15;b16=((d.w>>24)&255)>>4;
b1+=48;b2+=48;b3+=48;b4+=48;b5+=48;b6+=48;b7+=48;b8+=48;b9+=48;b10+=48;b11+=48;b12+=48;b13+=48;b14+=48;b15+=48;b16+=48;
if (b1>57) b1+=39; 
if (b2>57) b2+=39; 
if (b3>57) b3+=39; 
if (b4>57) b4+=39; 
if (b5>57) b5+=39; 
if (b6>57) b6+=39; 
if (b7>57) b7+=39; 
if (b8>57) b8+=39; 
if (b9>57) b9+=39; 
if (b10>57) b10+=39;
if (b11>57) b11+=39;
if (b12>57) b12+=39;
if (b13>57) b13+=39;
if (b14>57) b14+=39;
if (b15>57) b15+=39;
if (b16>57) b16+=39;
x7=(uint4)( b2|(b1<<8)|(b4<<16)|(b3<<24) ,b6|(b5<<8)|(b8<<16)|(b7<<24), b10|(b9<<8)|(b12<<16)|(b11<<24), b14|(b13<<8)|(b16<<16)|(b15<<24) );
x8=(uint4)(0x80,0x80,0x80,0x80);
SIZE = (uint4)(32*8,32*8,32*8,32*8);

a = mCa; b = mCb; c = mCc; d = mCd;
md5md5STEP_ROUND1(F, a, b, c, d, mAC1, x0, S11);
md5md5STEP_ROUND1(F, d, a, b, c, mAC2, x1, S12);
md5md5STEP_ROUND1(F, c, d, a, b, mAC3, x2, S13);
md5md5STEP_ROUND1(F, b, c, d, a, mAC4, x3, S14);
md5md5STEP_ROUND1(F, a, b, c, d, mAC5, x4, S11);
md5md5STEP_ROUND1(F, d, a, b, c, mAC6, x5, S12);
md5md5STEP_ROUND1(F, c, d, a, b, mAC7, x6, S13);
md5md5STEP_ROUND1(F, b, c, d, a, mAC8, x7, S14);
md5md5STEP_ROUND1(F, a, b, c, d, mAC9, x8, S11);
md5md5STEP_ROUND1_NULL(F, d, a, b, c, mAC10, S12); 
md5md5STEP_ROUND1_NULL(F, c, d, a, b, mAC11, S13); 
md5md5STEP_ROUND1_NULL(F, b, c, d, a, mAC12, S14); 
md5md5STEP_ROUND1_NULL(F, a, b, c, d, mAC13, S11); 
md5md5STEP_ROUND1_NULL(F, d, a, b, c, mAC14, S12); 
md5md5STEP_ROUND1 (F, c, d, a, b, mAC15, SIZE, S13);
md5md5STEP_ROUND1_NULL(F, b, c, d, a, mAC16, S14); 

md5md5STEP_ROUND2 (G, a, b, c, d, mAC17, x1, S21); 
md5md5STEP_ROUND2 (G, d, a, b, c, mAC18, x6, S22); 
md5md5STEP_ROUND2_NULL (G, c, d, a, b, mAC19, S23);
md5md5STEP_ROUND2 (G, b, c, d, a, mAC20, x0, S24); 
md5md5STEP_ROUND2 (G, a, b, c, d, mAC21, x5, S21); 
md5md5STEP_ROUND2_NULL (G, d, a, b, c, mAC22, S22);
md5md5STEP_ROUND2_NULL(G, c, d,  a, b, mAC23, S23);
md5md5STEP_ROUND2 (G, b, c, d, a, mAC24, x4, S24); 
md5md5STEP_ROUND2_NULL (G, a, b, c, d, mAC25, S21);
md5md5STEP_ROUND2 (G, d, a, b, c, mAC26, SIZE, S22);
md5md5STEP_ROUND2 (G, c, d, a, b, mAC27, x3, S23); 
md5md5STEP_ROUND2 (G, b, c, d, a, mAC28,x8, S24);  
md5md5STEP_ROUND2_NULL(G, a, b, c, d, mAC29, S21); 
md5md5STEP_ROUND2 (G, d, a, b, c, mAC30, x2, S22); 
md5md5STEP_ROUND2 (G, c, d, a, b, mAC31, x7, S23); 
md5md5STEP_ROUND2_NULL(G, b, c, d, a, mAC32, S24); 

md5md5STEP_ROUND3(H, a, b, c, d, mAC33, x5, S31);  
md5md5STEP_ROUND3(H, d, a, b, c, mAC34, x8, S32);  
md5md5STEP_ROUND3_NULL (H, c, d, a, b, mAC35, S33);
md5md5STEP_ROUND3 (H, b, c, d, a, mAC36, SIZE, S34);
md5md5STEP_ROUND3 (H, a, b, c, d, mAC37, x1, S31); 
md5md5STEP_ROUND3 (H, d, a, b, c, mAC38,x4, S32);  
md5md5STEP_ROUND3 (H, c, d, a, b, mAC39,x7, S33);  
md5md5STEP_ROUND3_NULL (H, b, c, d, a, mAC40, S34);
md5md5STEP_ROUND3_NULL(H, a, b, c, d, mAC41, S31); 
md5md5STEP_ROUND3 (H, d, a, b, c, mAC42, x0, S32); 
md5md5STEP_ROUND3 (H, c, d, a, b, mAC43, x3, S33); 
md5md5STEP_ROUND3 (H, b, c, d, a, mAC44,x6, S34);  
md5md5STEP_ROUND3_NULL (H, a, b, c, d, mAC45, S31);
md5md5STEP_ROUND3_NULL(H, d, a, b, c, mAC46, S32); 
md5md5STEP_ROUND3_NULL(H, c, d, a, b, mAC47, S33); 
md5md5STEP_ROUND3 (H, b, c, d, a, mAC48, x2, S34); 
md5md5STEP_ROUND4 (I, a, b, c, d, mAC49, x0, S41); 
md5md5STEP_ROUND4 (I, d, a, b, c, mAC50, x7, S42); 
md5md5STEP_ROUND4 (I, c, d, a, b, mAC51, SIZE, S43);
md5md5STEP_ROUND4 (I, b, c, d, a, mAC52, x5, S44); 
md5md5STEP_ROUND4_NULL(I, a, b, c, d, mAC53, S41); 
md5md5STEP_ROUND4 (I, d, a, b, c, mAC54, x3, S42); 
md5md5STEP_ROUND4_NULL (I, c, d, a, b, mAC55, S43);
md5md5STEP_ROUND4 (I, b, c, d, a, mAC56, x1, S44); 
md5md5STEP_ROUND4 (I, a, b, c, d, mAC57,x8, S41);  
md5md5STEP_ROUND4_NULL(I, d, a, b, c, mAC58, S42); 
md5md5STEP_ROUND4 (I, c, d, a, b, mAC59, x6, S43); 
md5md5STEP_ROUND4_NULL(I, b, c, d, a, mAC60, S44); 
md5md5STEP_ROUND4 (I, a, b, c, d, mAC61, x4, S41); 
md5md5STEP_ROUND4_NULL (I, d, a, b, c, mAC62, S42);
md5md5STEP_ROUND4 (I, c, d, a, b, mAC63, x2, S43); 
md5md5STEP_ROUND4_NULL (I, b, c, d, a, mAC64, S44);


a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;



id = 0;

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

