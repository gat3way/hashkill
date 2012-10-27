#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
size[GGI] = (SIZE+str.sF);

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






#ifdef SM21
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
prepare( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint4 t1,t2,t3,t4;
uint4 a,b,c,d, tmp1, tmp2; 
uint4 x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint4 y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;




SIZE.x=(size[(get_global_id(0)*4)]); 
SIZE.y=(size[(get_global_id(0)*4)+1]); 
SIZE.z=(size[(get_global_id(0)*4)+2]); 
SIZE.w=(size[(get_global_id(0)*4)+3]); 

tsize=SIZE;


x2.x=input[(get_global_id(0)*32)];
x3.x=input[(get_global_id(0)*32)+1];
x4.x=input[(get_global_id(0)*32)+2];
x5.x=input[(get_global_id(0)*32)+3];
x6.x=input[(get_global_id(0)*32)+4];
x7.x=input[(get_global_id(0)*32)+5];
x8.x=input[(get_global_id(0)*32)+6];
x9.x=input[(get_global_id(0)*32)+7];


x2.y=input[(get_global_id(0)*32)+8];
x3.y=input[(get_global_id(0)*32)+9];
x4.y=input[(get_global_id(0)*32)+10];
x5.y=input[(get_global_id(0)*32)+11];
x6.y=input[(get_global_id(0)*32)+12];
x7.y=input[(get_global_id(0)*32)+13];
x8.y=input[(get_global_id(0)*32)+14];
x9.y=input[(get_global_id(0)*32)+15];

x2.z=input[(get_global_id(0)*32)+16];
x3.z=input[(get_global_id(0)*32)+17];
x4.z=input[(get_global_id(0)*32)+18];
x5.z=input[(get_global_id(0)*32)+19];
x6.z=input[(get_global_id(0)*32)+20];
x7.z=input[(get_global_id(0)*32)+21];
x8.z=input[(get_global_id(0)*32)+22];
x9.z=input[(get_global_id(0)*32)+23];

x2.w=input[(get_global_id(0)*32)+24];
x3.w=input[(get_global_id(0)*32)+25];
x4.w=input[(get_global_id(0)*32)+26];
x5.w=input[(get_global_id(0)*32)+27];
x6.w=input[(get_global_id(0)*32)+28];
x7.w=input[(get_global_id(0)*32)+29];
x8.w=input[(get_global_id(0)*32)+30];
x9.w=input[(get_global_id(0)*32)+31];

x10=x11=x12=x13=x15=(uint4)0;
x14=(uint4)(SIZE+8)<<3;

x0=(uint4)salt.sE;
x1=(uint4)salt.sF;
y0=x2;
y1=x3;
y2=x4;
y3=x5;
y4=x6;
y5=x7;
y6=x8;
y7=x9;

{
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
MD5STEP_ROUND1_NULL(c, d, a, b, mAC11,S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,x14, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22,S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
}

dst[get_global_id(0)<<2]=(uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<2)+1]=(uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<2)+2]=(uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<2)+3]=(uint4)(a.s3,b.s3,c.s3,d.s3);

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
phpass( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint4 t1,t2,t3,t4;
uint4 a,b,c,d, tmp1, tmp2; 
uint4 x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint4 y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;


SIZE.x=(size[(get_global_id(0)*4)]); 
SIZE.y=(size[(get_global_id(0)*4)+1]); 
SIZE.z=(size[(get_global_id(0)*4)+2]); 
SIZE.w=(size[(get_global_id(0)*4)+3]); 

tsize=SIZE;

a.s0=dst[(get_global_id(0)*16)];
b.s0=dst[(get_global_id(0)*16)+1];
c.s0=dst[(get_global_id(0)*16)+2];
d.s0=dst[(get_global_id(0)*16)+3];
a.s1=dst[(get_global_id(0)*16)+4];
b.s1=dst[(get_global_id(0)*16)+5];
c.s1=dst[(get_global_id(0)*16)+6];
d.s1=dst[(get_global_id(0)*16)+7];
a.s2=dst[(get_global_id(0)*16)+8];
b.s2=dst[(get_global_id(0)*16)+9];
c.s2=dst[(get_global_id(0)*16)+10];
d.s2=dst[(get_global_id(0)*16)+11];
a.s3=dst[(get_global_id(0)*16)+12];
b.s3=dst[(get_global_id(0)*16)+13];
c.s3=dst[(get_global_id(0)*16)+14];
d.s3=dst[(get_global_id(0)*16)+15];


x2.x=input[(get_global_id(0)*32)];
x3.x=input[(get_global_id(0)*32)+1];
x4.x=input[(get_global_id(0)*32)+2];
x5.x=input[(get_global_id(0)*32)+3];
x6.x=input[(get_global_id(0)*32)+4];
x7.x=input[(get_global_id(0)*32)+5];
x8.x=input[(get_global_id(0)*32)+6];
x9.x=input[(get_global_id(0)*32)+7];


x2.y=input[(get_global_id(0)*32)+8];
x3.y=input[(get_global_id(0)*32)+9];
x4.y=input[(get_global_id(0)*32)+10];
x5.y=input[(get_global_id(0)*32)+11];
x6.y=input[(get_global_id(0)*32)+12];
x7.y=input[(get_global_id(0)*32)+13];
x8.y=input[(get_global_id(0)*32)+14];
x9.y=input[(get_global_id(0)*32)+15];

x2.z=input[(get_global_id(0)*32)+16];
x3.z=input[(get_global_id(0)*32)+17];
x4.z=input[(get_global_id(0)*32)+18];
x5.z=input[(get_global_id(0)*32)+19];
x6.z=input[(get_global_id(0)*32)+20];
x7.z=input[(get_global_id(0)*32)+21];
x8.z=input[(get_global_id(0)*32)+22];
x9.z=input[(get_global_id(0)*32)+23];

x2.w=input[(get_global_id(0)*32)+24];
x3.w=input[(get_global_id(0)*32)+25];
x4.w=input[(get_global_id(0)*32)+26];
x5.w=input[(get_global_id(0)*32)+27];
x6.w=input[(get_global_id(0)*32)+28];
x7.w=input[(get_global_id(0)*32)+29];
x8.w=input[(get_global_id(0)*32)+30];
x9.w=input[(get_global_id(0)*32)+31];


x10=x11=x12=x13=x15=(uint4)0;
x14=(uint4)(SIZE+8)<<3;

x0=(uint4)salt.sE;
x1=(uint4)salt.sF;
y0=x2;
y1=x3;
y2=x4;
y3=x5;
y4=x6;
y5=x7;
y6=x8;
y7=x9;
tsize=(16+tsize)<<3;



for (i=0;i<1024;i++)
{

x14=tsize;
x0=a;
x1=b;
x2=c;
x3=d;
x4=y0;
x5=y1;
x6=y2;
x7=y3;
x8=y4;
x9=y5;
x10=y6;
x11=y7;

{
a = mCa; b = mCb; c = mCc; d = mCd;


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
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, x14, S13);  
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
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x11, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
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

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
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
MD5STEP_ROUND4 (d, a, b, c, mAC62, x11, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
}

}


dst[(get_global_id(0)*16)]=a.s0;
dst[(get_global_id(0)*16)+1]=b.s0;
dst[(get_global_id(0)*16)+2]=c.s0;
dst[(get_global_id(0)*16)+3]=d.s0;
dst[(get_global_id(0)*16)+4]=a.s1;
dst[(get_global_id(0)*16)+5]=b.s1;
dst[(get_global_id(0)*16)+6]=c.s1;
dst[(get_global_id(0)*16)+7]=d.s1;
dst[(get_global_id(0)*16)+8]=a.s2;
dst[(get_global_id(0)*16)+9]=b.s2;
dst[(get_global_id(0)*16)+10]=c.s2;
dst[(get_global_id(0)*16)+11]=d.s2;
dst[(get_global_id(0)*16)+12]=a.s3;
dst[(get_global_id(0)*16)+13]=a.s3;
dst[(get_global_id(0)*16)+14]=a.s3;
dst[(get_global_id(0)*16)+15]=a.s3;

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
{
uint4 a,b,c,d;

a.s0=input[(get_global_id(0)*16)];
b.s0=input[(get_global_id(0)*16)+1];
c.s0=input[(get_global_id(0)*16)+2];
d.s0=input[(get_global_id(0)*16)+3];
a.s1=input[(get_global_id(0)*16)+4];
b.s1=input[(get_global_id(0)*16)+5];
c.s1=input[(get_global_id(0)*16)+6];
d.s1=input[(get_global_id(0)*16)+7];
a.s2=input[(get_global_id(0)*16)+8];
b.s2=input[(get_global_id(0)*16)+9];
c.s2=input[(get_global_id(0)*16)+10];
d.s2=input[(get_global_id(0)*16)+11];
a.s3=input[(get_global_id(0)*16)+12];
b.s3=input[(get_global_id(0)*16)+13];
c.s3=input[(get_global_id(0)*16)+14];
d.s3=input[(get_global_id(0)*16)+15];


if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);


}


#else

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
prepare( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
uint a,b,c,d, tmp1, tmp2; 
uint x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;




SIZE=(size[(get_global_id(0))]); 

tsize=SIZE;


x2=input[(get_global_id(0)*8)];
x3=input[(get_global_id(0)*8)+1];
x4=input[(get_global_id(0)*8)+2];
x5=input[(get_global_id(0)*8)+3];
x6=input[(get_global_id(0)*8)+4];
x7=input[(get_global_id(0)*8)+5];
x8=input[(get_global_id(0)*8)+6];
x9=input[(get_global_id(0)*8)+7];

x10=x11=x12=x13=x15=(uint)0;
x14=(uint)(SIZE+8)<<3;

x0=(uint)salt.sE;
x1=(uint)salt.sF;
y0=x2;
y1=x3;
y2=x4;
y3=x5;
y4=x6;
y5=x7;
y6=x8;
y7=x9;

{
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
MD5STEP_ROUND1_NULL(c, d, a, b, mAC11,S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,x14, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x1, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x6, S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x0, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x5, S21);
MD5STEP_ROUND2_NULL (d, a, b, c, mAC22,S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x4, S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x9, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x1, S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x4, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x7, S33);  
MD5STEP_ROUND3_NULL_ODD (b, c, d, a, mAC40, S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x0, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x3, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x6, S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x9, S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x2, S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x5, S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x3, S42);
MD5STEP_ROUND4_NULL (c, d, a, b, mAC55, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x1, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x8, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x6, S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
}

dst[get_global_id(0)]=(uint4)(a,b,c,d);

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
phpass( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
uint a,b,c,d, tmp1, tmp2; 
uint x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15; 
uint y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;


SIZE=(size[(get_global_id(0))]); 

tsize=SIZE;

a=dst[(get_global_id(0)*4)];
b=dst[(get_global_id(0)*4)+1];
c=dst[(get_global_id(0)*4)+2];
d=dst[(get_global_id(0)*4)+3];


x2=input[(get_global_id(0)*8)];
x3=input[(get_global_id(0)*8)+1];
x4=input[(get_global_id(0)*8)+2];
x5=input[(get_global_id(0)*8)+3];
x6=input[(get_global_id(0)*8)+4];
x7=input[(get_global_id(0)*8)+5];
x8=input[(get_global_id(0)*8)+6];
x9=input[(get_global_id(0)*8)+7];


x10=x11=x12=x13=x15=(uint)0;
x14=(uint)(SIZE+8)<<3;

x0=(uint)salt.sE;
x1=(uint)salt.sF;
y0=x2;
y1=x3;
y2=x4;
y3=x5;
y4=x6;
y5=x7;
y6=x8;
y7=x9;
tsize=(16+tsize)<<3;



for (i=0;i<1024;i++)
{

x14=tsize;
x0=a;
x1=b;
x2=c;
x3=d;
x4=y0;
x5=y1;
x6=y2;
x7=y3;
x8=y4;
x9=y5;
x10=y6;
x11=y7;

{
a = mCa; b = mCb; c = mCc; d = mCd;


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
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, x14, S13);  
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
MD5STEP_ROUND2 (d, a, b, c, mAC26, x14, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x3, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x8, S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29, S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x2, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x7, S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x5,  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x8, S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x11, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, x14, S34);  
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

MD5STEP_ROUND4 (a, b, c, d, mAC49, x0, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x7, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, x14, S43);  
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
MD5STEP_ROUND4 (d, a, b, c, mAC62, x11, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
}

}


dst[(get_global_id(0)*4)]=a;
dst[(get_global_id(0)*4)+1]=b;
dst[(get_global_id(0)*4)+2]=c;
dst[(get_global_id(0)*4)+3]=d;

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
final( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
{
uint a,b,c,d;

a=input[(get_global_id(0)*4)];
b=input[(get_global_id(0)*4)+1];
c=input[(get_global_id(0)*4)+2];
d=input[(get_global_id(0)*4)+3];


if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);


}


#endif
