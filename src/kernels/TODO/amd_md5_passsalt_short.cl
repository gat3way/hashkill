//#pragma OPENCL EXTENSION cl_amd_printf : enable

__kernel void 
md5_passsalt( __global uint4 *dst, uint4 input, uint size,  uint8 chbase,  __global uint *found_ind, uint16 salt, __global uint *found, __global  uint *table,  uint4 singlehash) 
{  

uint8 mCa= (uint8)0x67452301;
uint8 mCb= (uint8)0xefcdab89;
uint8 mCc= (uint8)0x98badcfe;
uint8 mCd= (uint8)0x10325476;
uint8 S11= (uint8)7; 
uint8 S12= (uint8)12;
uint8 S13= (uint8)17;
uint8 S14= (uint8)22;
uint8 S21= (uint8)5; 
uint8 S22= (uint8)9; 
uint8 S23= (uint8)14;
uint8 S24= (uint8)20;
uint8 S31= (uint8)4; 
uint8 S32= (uint8)11;
uint8 S33= (uint8)16;
uint8 S34= (uint8)23;
uint8 S41= (uint8)6; 
uint8 S42= (uint8)10;
uint8 S43= (uint8)15;
uint8 S44= (uint8)21;

uint8 mAC1 = (uint8)0xd76aa478; 
uint8 mAC2 = (uint8)0xe8c7b756; 
uint8 mAC3 = (uint8)0x242070db; 
uint8 mAC4 = (uint8)0xc1bdceee; 
uint8 mAC5 = (uint8)0xf57c0faf; 
uint8 mAC6 = (uint8)0x4787c62a; 
uint8 mAC7 = (uint8)0xa8304613; 
uint8 mAC8 = (uint8)0xfd469501; 
uint8 mAC9 = (uint8)0x698098d8; 
uint8 mAC10= (uint8)0x8b44f7af; 
uint8 mAC11= (uint8)0xffff5bb1; 
uint8 mAC12= (uint8)0x895cd7be; 
uint8 mAC13= (uint8)0x6b901122; 
uint8 mAC14= (uint8)0xfd987193; 
uint8 mAC15= (uint8)0xa679438e; 
uint8 mAC16= (uint8)0x49b40821; 
uint8 mAC17= (uint8)0xf61e2562; 
uint8 mAC18= (uint8)0xc040b340; 
uint8 mAC19= (uint8)0x265e5a51; 
uint8 mAC20= (uint8)0xe9b6c7aa; 
uint8 mAC21= (uint8)0xd62f105d; 
uint8 mAC22= (uint8)0x02441453; 
uint8 mAC23= (uint8)0xd8a1e681; 
uint8 mAC24= (uint8)0xe7d3fbc8; 
uint8 mAC25= (uint8)0x21e1cde6; 
uint8 mAC26= (uint8)0xc33707d6; 
uint8 mAC27= (uint8)0xf4d50d87; 
uint8 mAC28= (uint8)0x455a14ed; 
uint8 mAC29= (uint8)0xa9e3e905; 
uint8 mAC30= (uint8)0xfcefa3f8; 
uint8 mAC31= (uint8)0x676f02d9; 
uint8 mAC32= (uint8)0x8d2a4c8a; 
uint8 mAC33= (uint8)0xfffa3942; 
uint8 mAC34= (uint8)0x8771f681; 
uint8 mAC35= (uint8)0x6d9d6122; 
uint8 mAC36= (uint8)0xfde5380c; 
uint8 mAC37= (uint8)0xa4beea44; 
uint8 mAC38= (uint8)0x4bdecfa9; 
uint8 mAC39= (uint8)0xf6bb4b60; 
uint8 mAC40= (uint8)0xbebfbc70; 
uint8 mAC41= (uint8)0x289b7ec6; 
uint8 mAC42= (uint8)0xeaa127fa; 
uint8 mAC43= (uint8)0xd4ef3085; 
uint8 mAC44= (uint8)0x04881d05; 
uint8 mAC45= (uint8)0xd9d4d039; 
uint8 mAC46= (uint8)0xe6db99e5; 
uint8 mAC47= (uint8)0x1fa27cf8; 
uint8 mAC48= (uint8)0xc4ac5665; 
uint8 mAC49= (uint8)0xf4292244; 
uint8 mAC50= (uint8)0x432aff97; 
uint8 mAC51= (uint8)0xab9423a7; 
uint8 mAC52= (uint8)0xfc93a039; 
uint8 mAC53= (uint8)0x655b59c3; 
uint8 mAC54= (uint8)0x8f0ccc92; 
uint8 mAC55= (uint8)0xffeff47d; 
uint8 mAC56= (uint8)0x85845dd1; 
uint8 mAC57= (uint8)0x6fa87e4f; 
uint8 mAC58= (uint8)0xfe2ce6e0; 
uint8 mAC59= (uint8)0xa3014314; 
uint8 mAC60= (uint8)0x4e0811a1; 
uint8 mAC61= (uint8)0xf7537e82; 
uint8 mAC62= (uint8)0xbd3af235; 
uint8 mAC63= (uint8)0x2ad7d2bb; 
uint8 mAC64= (uint8)0xeb86d391; 


uint8 SIZE;  
uint i,ib,ic,id,ie;  
uint8 mOne;
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 x0,x1,x2,x3; 
uint8 x4,x5,x6,x7,x8,x9,x10,x11,x12; 


mOne = (uint8)(0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF,0xFFFFFFFF);
mCa = (uint8)(Ca,Ca,Ca,Ca,Ca,Ca,Ca,Ca);
mCb = (uint8)(Cb,Cb,Cb,Cb,Cb,Cb,Cb,Cb);
mCc = (uint8)(Cc,Cc,Cc,Cc,Cc,Cc,Cc,Cc);
mCd = (uint8)(Cd,Cd,Cd,Cd,Cd,Cd,Cd,Cd);
ic = size+4;
id = ic*8; 
SIZE = (uint8)( id,id,id,id,id,id,id,id ); 


x0 = (uint8)(input.x,input.x,input.x,input.x,input.x,input.x,input.x,input.x); 
x1 = (uint8)(input.y,input.y,input.y,input.y,input.y,input.y,input.y,input.y,); 
x2 = (uint8)(input.z,input.z,input.z,input.z,input.z,input.z,input.z,input.z); 
x3 = (uint8)(input.w,input.w,input.w,input.w,input.w,input.w,input.w,input.w,); 
x4=x5=x6=x7=x8=x9=x10=x11=x12=0;


i = table[get_global_id(0)];
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



if (size==1)
{
    switch (salt.sF)
    {
	case 1:
	    x0=chbase|(ib<<8)|(ic<<16)|(id<<24);
	    x1=ie|((salt.s0&255)<<8)|(0x80<<16);
	    break;
	case 2:
	    x0=chbase|(ib<<8)|(ic<<16)|(id<<24);
	    x1=ie|((salt.s0&255)<<8)|(((salt.s0>>8)&255)<<16)|(0x80<<24);
	    break;

    }
}



a = mCa; b = mCb; c = mCc; d = mCd;
id=0;

#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s);(a) = (a)+(b);  
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  tmp1 = (c)^(d); tmp1 = tmp1&(b); tmp1 = tmp1^(d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);  

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
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);


#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  tmp1 = (b) ^ (c); tmp1 = tmp1 & (d); tmp1 = tmp1 ^ (c);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 & (d);tmp1 = tmp1 ^ (c);(a) = (a)+tmp1;(a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);

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
MD5STEP_ROUND2_NULL(a, b, c, d, mAC29, S21);
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
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
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
MD5STEP_ROUND4_NULL(b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x4, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x11, S42);
id=singlehash.w;
if (all((uint8)id != d)) return; 
MD5STEP_ROUND4 (c, d, a, b, mAC63, x2, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x9, S44);

id=0;
if ((singlehash.x==a.s0)&&(singlehash.y==b.s0)&&(singlehash.z==c.s0)&&(singlehash.w==d.s0)) id = 1; 
if ((singlehash.x==a.s1)&&(singlehash.y==b.s1)&&(singlehash.z==c.s1)&&(singlehash.w==d.s1)) id = 1; 
if ((singlehash.x==a.s2)&&(singlehash.y==b.s2)&&(singlehash.z==c.s2)&&(singlehash.w==d.s2)) id = 1; 
if ((singlehash.x==a.s3)&&(singlehash.y==b.s3)&&(singlehash.z==c.s3)&&(singlehash.w==d.s3)) id = 1; 
if ((singlehash.x==a.s4)&&(singlehash.y==b.s4)&&(singlehash.z==c.s4)&&(singlehash.w==d.s4)) id = 1; 
if ((singlehash.x==a.s5)&&(singlehash.y==b.s5)&&(singlehash.z==c.s5)&&(singlehash.w==d.s5)) id = 1; 
if ((singlehash.x==a.s6)&&(singlehash.y==b.s6)&&(singlehash.z==c.s6)&&(singlehash.w==d.s6)) id = 1; 
if ((singlehash.x==a.s7)&&(singlehash.y==b.s7)&&(singlehash.z==c.s7)&&(singlehash.w==d.s7)) id = 1; 
if (id==0) return;


a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}


dst[(get_global_id(0)<<3)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<3)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<3)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<3)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
dst[(get_global_id(0)<<3)+4] = (uint4)(a.s4,b.s4,c.s4,d.s4);
dst[(get_global_id(0)<<3)+5] = (uint4)(a.s5,b.s5,c.s5,d.s5);
dst[(get_global_id(0)<<3)+6] = (uint4)(a.s6,b.s6,c.s6,d.s6);
dst[(get_global_id(0)<<3)+7] = (uint4)(a.s7,b.s7,c.s7,d.s7);

}

