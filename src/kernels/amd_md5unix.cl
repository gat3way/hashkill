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


inpc[GLI][0] = inp[GGI*(4)+0];
inpc[GLI][1] = inp[GGI*(4)+1];
inpc[GLI][2] = inp[GGI*(4)+2];
inpc[GLI][3] = inp[GGI*(4)+3];

SIZE=salt.sB;
//size[GGI] = (SIZE+str.sF);

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

//SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

dst[GGI*4+0] = inpc[GLI][0];
dst[GGI*4+1] = inpc[GLI][1];
dst[GGI*4+2] = inpc[GLI][2];
dst[GGI*4+3] = inpc[GLI][3];
}



#ifndef GCN


#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable



#define SET_AIS(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] |= ( ( ((ai2[ii2>>2]) >> ((ii2&3)<<3)) &255) << ((ii1.x&3)<<3)); \
	}

#define SET_AIT(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] |= ( (((ai2[ii2>>2]) >> (((ii2>>1)&1)<<4)) &0xFFFF) << (((ii1.x>>1)&1)<<4)); \
	}

#define SET_AIF(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] = ai2[ii2>>2]; \
	}
#else
#define SET_AIS(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] |= ( ( ((ai2[ii2>>2]) >> ((ii2&3)<<3)) &255) << ((ii1.x&3)<<3)); \
	}

#define SET_AIT(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] |= ( ( ((ai2[ii2>>2]) >> (((ii2>>1)&1)<<4)) &0xFFFF) << (((ii1.x>>1)&1)<<4)); \
	}

#define SET_AIF(ai1,ai2,ii1,ii2) { \
	ai1[(ii1.x)>>2] = ai2[ii2>>2]; \
	}


#endif

#define SET_AB(ai1,ii1,bb) { \
	ai1[(ii1.x)>>2] |= ((bb) << ((ii1.x&3)<<3)); \
	}

#define gli get_local_id(0)

#ifndef OLD_ATI
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif

#ifndef OLD_ATI
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif

#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 

#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix15( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,e,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint elem;
__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)15;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][3].x=input[(get_global_id(0)*16)+3];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][3].y=input[(get_global_id(0)*16)+7];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][3].z=input[(get_global_id(0)*16)+11];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3].w=input[(get_global_id(0)*16)+15];

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;

SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;



// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix14( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];


tsize=(uint4)14;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][3].x=input[(get_global_id(0)*16)+3];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][3].y=input[(get_global_id(0)*16)+7];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][3].z=input[(get_global_id(0)*16)+11];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3].w=input[(get_global_id(0)*16)+15];

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint4)2;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint4)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint4)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint4)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint4)2;
SET_AIT(x,alt,ii,2);ii+=(uint4)2;
SET_AIT(x,alt,ii,4);ii+=(uint4)2;
SET_AIT(x,alt,ii,6);ii+=(uint4)2;
SET_AIT(x,alt,ii,8);ii+=(uint4)2;
SET_AIT(x,alt,ii,10);ii+=(uint4)2;
SET_AIT(x,alt,ii,12);ii+=(uint4)2;
SET_AIT(x,alt,ii,14);ii+=(uint4)2;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix13( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)13;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][3].x=input[(get_global_id(0)*16)+3];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][3].y=input[(get_global_id(0)*16)+7];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][3].z=input[(get_global_id(0)*16)+11];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3].w=input[(get_global_id(0)*16)+15];

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix12( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)12;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][3].x=input[(get_global_id(0)*16)+3];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][3].y=input[(get_global_id(0)*16)+7];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][3].z=input[(get_global_id(0)*16)+11];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3].w=input[(get_global_id(0)*16)+15];

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint4)4;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint4)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint4)4;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint4)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint4)4;
SET_AIF(x,alt,ii,4);ii+=(uint4)4;
SET_AIF(x,alt,ii,8);ii+=(uint4)4;
SET_AIF(x,alt,ii,12);ii+=(uint4)4;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix11( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];


tsize=(uint4)11;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3]=(uint4)0;


ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix10( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];


tsize=(uint4)10;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;

SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint4)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint4)2;
SET_AIT(x,alt,ii,2);ii+=(uint4)2;
SET_AIT(x,alt,ii,4);ii+=(uint4)2;
SET_AIT(x,alt,ii,6);ii+=(uint4)2;
SET_AIT(x,alt,ii,8);ii+=(uint4)2;
SET_AIT(x,alt,ii,10);ii+=(uint4)2;
SET_AIT(x,alt,ii,12);ii+=(uint4)2;
SET_AIT(x,alt,ii,14);ii+=(uint4)2;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;

a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix9( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)9;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);


a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix8( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];


tsize=(uint4)8;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint4)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint4)4;
SET_AIF(x,alt,ii,4);ii+=(uint4)4;
SET_AIF(x,alt,ii,8);ii+=(uint4)4;
SET_AIF(x,alt,ii,12);ii+=(uint4)4;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix7( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)7;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix6( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)6;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint4)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint4)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint4)2;
SET_AIT(x,alt,ii,2);ii+=(uint4)2;
SET_AIT(x,alt,ii,4);ii+=(uint4)2;
SET_AIT(x,alt,ii,6);ii+=(uint4)2;
SET_AIT(x,alt,ii,8);ii+=(uint4)2;
SET_AIT(x,alt,ii,10);ii+=(uint4)2;
SET_AIT(x,alt,ii,12);ii+=(uint4)2;
SET_AIT(x,alt,ii,14);ii+=(uint4)2;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix5( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)5;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][2].x=input[(get_global_id(0)*16)+2];
str[gli][3].x=input[(get_global_id(0)*16)+3];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][2].y=input[(get_global_id(0)*16)+6];
str[gli][3].y=input[(get_global_id(0)*16)+7];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][2].z=input[(get_global_id(0)*16)+10];
str[gli][3].z=input[(get_global_id(0)*16)+11];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2].w=input[(get_global_id(0)*16)+14];
str[gli][3].w=input[(get_global_id(0)*16)+15];

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<5;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = 5; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix4( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)4;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][1].x=input[(get_global_id(0)*16)+1];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][1].y=input[(get_global_id(0)*16)+5];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][1].z=input[(get_global_id(0)*16)+9];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1].w=input[(get_global_id(0)*16)+13];
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;

for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}


SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
ii=jj+tsize;

SIZE=(uint4)(ii)<<3;
SET_AB(x,ii,0x80);ii+=(uint4)1;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint4)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint4)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint4)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint4)4;
SET_AIF(x,alt,ii,4);ii+=(uint4)4;
SET_AIF(x,alt,ii,8);ii+=(uint4)4;
SET_AIF(x,alt,ii,12);ii+=(uint4)4;


SIZE=(uint4)(ii)<<3;
SET_AB(x,ii,0x80);ii+=(uint4)1;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix3( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];


tsize=(uint4)3;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1]=(uint4)0;
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix2( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)2;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1]=(uint4)0;
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint4)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint4)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint4)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint4)2;
SET_AIT(x,alt,ii,2);ii+=(uint4)2;
SET_AIT(x,alt,ii,4);ii+=(uint4)2;
SET_AIT(x,alt,ii,6);ii+=(uint4)2;
SET_AIT(x,alt,ii,8);ii+=(uint4)2;
SET_AIT(x,alt,ii,10);ii+=(uint4)2;
SET_AIT(x,alt,ii,12);ii+=(uint4)2;
SET_AIT(x,alt,ii,14);ii+=(uint4)2;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix1( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint4 SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint4 t1,t2,t3,t4;
uint4 a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint4 x[14]; 
uint4 alt[4]; 
__local uint4 str[64][4];
uint4 ssalt[2];



tsize=(uint4)1;
ssize=(uint4)salt.sC;
msize=(uint4)salt.s9;
str[gli][0].x=input[(get_global_id(0)*16)];
str[gli][0].y=input[(get_global_id(0)*16)+4];
str[gli][0].z=input[(get_global_id(0)*16)+8];
str[gli][0].w=input[(get_global_id(0)*16)+12];
str[gli][1]=(uint4)0;
str[gli][2]=(uint4)0;
str[gli][3]=(uint4)0;

ssalt[0]=(uint4)salt.sE;
ssalt[1]=(uint4)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;

SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
//SET_AIS(x,str[gli],ii,1);ii+=(uint4)1;
ii=(uint4)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint4)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;
ii=(uint4)0;
x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint4)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint4)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint4)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint4)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
for (i=0;i<tsize.x;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint4)1;
}

for (i = tsize.x; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii.x)>>2] |= (jj << (((ii.x)&3)<<3));
    ii+=(uint4)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint4)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint4)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint4)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint4)0;

x[0]=str[gli][0];
x[1]=(uint4)0;
x[2]=(uint4)0;
x[3]=(uint4)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint4)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint4)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint4)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint4)1;
SET_AIS(x,alt,ii,1);ii+=(uint4)1;
SET_AIS(x,alt,ii,2);ii+=(uint4)1;
SET_AIS(x,alt,ii,3);ii+=(uint4)1;
SET_AIS(x,alt,ii,4);ii+=(uint4)1;
SET_AIS(x,alt,ii,5);ii+=(uint4)1;
SET_AIS(x,alt,ii,6);ii+=(uint4)1;
SET_AIS(x,alt,ii,7);ii+=(uint4)1;
SET_AIS(x,alt,ii,8);ii+=(uint4)1;
SET_AIS(x,alt,ii,9);ii+=(uint4)1;
SET_AIS(x,alt,ii,10);ii+=(uint4)1;
SET_AIS(x,alt,ii,11);ii+=(uint4)1;
SET_AIS(x,alt,ii,12);ii+=(uint4)1;
SET_AIS(x,alt,ii,13);ii+=(uint4)1;
SET_AIS(x,alt,ii,14);ii+=(uint4)1;
SET_AIS(x,alt,ii,15);ii+=(uint4)1;

SET_AB(x,ii,0x80);

SIZE=(uint4)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


} 

id=0;
if (all((uint4)singlehash.x!=a)) return;
if (all((uint4)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<2)] = (uint4)(a.x,b.x,c.x,d.x);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.y,b.y,c.y,d.y);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.z,b.z,c.z,d.z);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.w,b.w,c.w,d.w);
}



//dummy
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix0( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
{
}


#else


#define SET_AIS(ai1,ai2,ii1,ii2) { \
	ai1[(ii1)>>2] |= ( ( ((ai2[ii2>>2]) >> ((ii2&3)<<3)) &255) << ((ii1&3)<<3)); \
	}



#define SET_AIT(ai1,ai2,ii1,ii2) { \
	ai1[(ii1)>>2] |= ( (((ai2[ii2>>2]) >> (((ii2>>1)&1)<<4)) &0xFFFF) << (((ii1>>1)&1)<<4)); \
	}


#define SET_AIF(ai1,ai2,ii1,ii2) { \
	ai1[(ii1)>>2] = ai2[ii2>>2]; \
	}



#define SET_AB(ai1,ii1,bb) { \
	ai1[(ii1)>>2] |= ((bb) << ((ii1&3)<<3)); \
	}

#define gli get_local_id(0)

#ifndef OLD_ATI
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND1A(a, b, c, d, AC, x, s)  tmp1 = (c)^(d);tmp1 = tmp1 & (b);tmp1 = tmp1 ^ (d);(a) = (a)+(tmp1); (a) = (a) + (AC);(a) = (a)+(x);(a) = rotate(a,s)+(b);
#endif
#ifndef OLD_ATI
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#else
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate(a,s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate(a,s)+(b);
#endif
#define MD5STEP_ROUND3_EVEN(a, b, c, d, AC, x, s) tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_NULL_EVEN(a, b, c, d, AC, s)  tmp2 = (b) ^ (c);tmp1 = tmp2 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND3_ODD(a, b, c, d, AC, x, s) tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND3_NULL_ODD(a, b, c, d, AC, s)  tmp1 = tmp2 ^ (b);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b); 

#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate(a,s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = b | tmp1; tmp1 = tmp1 ^ c; (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix15( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,e,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint elem;
__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)15;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=input[(get_global_id(0)*4)+3];

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;

SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;



// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
SET_AIS(x,str[gli],ii,13);ii+=(uint)1;
SET_AIS(x,str[gli],ii,14);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix14( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];


tsize=(uint)14;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=input[(get_global_id(0)*4)+3];

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint)2;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
SET_AIT(x,str[gli],ii,10);ii+=(uint)2;
SET_AIT(x,str[gli],ii,12);ii+=(uint)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint)2;
SET_AIT(x,alt,ii,2);ii+=(uint)2;
SET_AIT(x,alt,ii,4);ii+=(uint)2;
SET_AIT(x,alt,ii,6);ii+=(uint)2;
SET_AIT(x,alt,ii,8);ii+=(uint)2;
SET_AIT(x,alt,ii,10);ii+=(uint)2;
SET_AIT(x,alt,ii,12);ii+=(uint)2;
SET_AIT(x,alt,ii,14);ii+=(uint)2;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix13( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)13;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=input[(get_global_id(0)*4)+3];

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
SET_AIS(x,str[gli],ii,11);ii+=(uint)1;
SET_AIS(x,str[gli],ii,12);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix12( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)12;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=input[(get_global_id(0)*4)+3];

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint)4;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint)4;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
SET_AIF(x,str[gli],ii,8);ii+=(uint)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint)4;
SET_AIF(x,alt,ii,4);ii+=(uint)4;
SET_AIF(x,alt,ii,8);ii+=(uint)4;
SET_AIF(x,alt,ii,12);ii+=(uint)4;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix11( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];


tsize=(uint)11;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
SET_AIS(x,str[gli],ii,9);ii+=(uint)1;
SET_AIS(x,str[gli],ii,10);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix10( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];


tsize=(uint)10;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;

SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
SET_AIT(x,str[gli],ii,6);ii+=(uint)2;
SET_AIT(x,str[gli],ii,8);ii+=(uint)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint)2;
SET_AIT(x,alt,ii,2);ii+=(uint)2;
SET_AIT(x,alt,ii,4);ii+=(uint)2;
SET_AIT(x,alt,ii,6);ii+=(uint)2;
SET_AIT(x,alt,ii,8);ii+=(uint)2;
SET_AIT(x,alt,ii,10);ii+=(uint)2;
SET_AIT(x,alt,ii,12);ii+=(uint)2;
SET_AIT(x,alt,ii,14);ii+=(uint)2;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;

a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix9( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)9;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=input[(get_global_id(0)*4)+2];
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12],S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);


a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
SET_AIS(x,str[gli],ii,7);ii+=(uint)1;
SET_AIS(x,str[gli],ii,8);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46,x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix8( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];


tsize=(uint)8;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
SET_AIF(x,str[gli],ii,4);ii+=(uint)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint)4;
SET_AIF(x,alt,ii,4);ii+=(uint)4;
SET_AIF(x,alt,ii,8);ii+=(uint)4;
SET_AIF(x,alt,ii,12);ii+=(uint)4;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix7( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)7;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
SET_AIS(x,str[gli],ii,5);ii+=(uint)1;
SET_AIS(x,str[gli],ii,6);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix6( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)6;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
SET_AIT(x,str[gli],ii,2);ii+=(uint)2;
SET_AIT(x,str[gli],ii,4);ii+=(uint)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint)2;
SET_AIT(x,alt,ii,2);ii+=(uint)2;
SET_AIT(x,alt,ii,4);ii+=(uint)2;
SET_AIT(x,alt,ii,6);ii+=(uint)2;
SET_AIT(x,alt,ii,8);ii+=(uint)2;
SET_AIT(x,alt,ii,10);ii+=(uint)2;
SET_AIT(x,alt,ii,12);ii+=(uint)2;
SET_AIT(x,alt,ii,14);ii+=(uint)2;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13],S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, x[13], mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, x[12], mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35,x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_EVEN(c, d, a, b, mAC47,x[12], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62,x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix5( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)5;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<5;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = 5; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
SET_AIS(x,str[gli],ii,3);ii+=(uint)1;
SET_AIS(x,str[gli],ii,4);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;
MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);
a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix4( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)4;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=input[(get_global_id(0)*4)+1];
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;

for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}


SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
ii=jj+tsize;
}

jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
ii=jj+tsize;

SIZE=(uint)(ii)<<3;
SET_AB(x,ii,0x80);ii+=(uint)1;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIF(x,ssalt,ii,0);ii+=(uint)4;
SET_AIF(x,ssalt,ii,4);ii+=(uint)4;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIF(x,str[gli],ii,0);ii+=(uint)4;
ii=jj+tsize;
}

SET_AIF(x,alt,ii,0);ii+=(uint)4;
SET_AIF(x,alt,ii,4);ii+=(uint)4;
SET_AIF(x,alt,ii,8);ii+=(uint)4;
SET_AIF(x,alt,ii,12);ii+=(uint)4;


SIZE=(uint)(ii)<<3;
SET_AB(x,ii,0x80);ii+=(uint)1;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 


id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix3( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];


tsize=(uint)3;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=0;
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
SET_AIS(x,str[gli],ii,1);ii+=(uint)1;
SET_AIS(x,str[gli],ii,2);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix2( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)2;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=0;
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
ii=jj+tsize;
}

jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIT(x,ssalt,ii,0);ii+=(uint)2;
SET_AIT(x,ssalt,ii,2);ii+=(uint)2;
SET_AIT(x,ssalt,ii,4);ii+=(uint)2;
SET_AIT(x,ssalt,ii,6);ii+=(uint)2;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIT(x,str[gli],ii,0);ii+=(uint)2;
ii=jj+tsize;
}

SET_AIT(x,alt,ii,0);ii+=(uint)2;
SET_AIT(x,alt,ii,2);ii+=(uint)2;
SET_AIT(x,alt,ii,4);ii+=(uint)2;
SET_AIT(x,alt,ii,6);ii+=(uint)2;
SET_AIT(x,alt,ii,8);ii+=(uint)2;
SET_AIT(x,alt,ii,10);ii+=(uint)2;
SET_AIT(x,alt,ii,12);ii+=(uint)2;
SET_AIT(x,alt,ii,14);ii+=(uint)2;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;

} 



id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}





__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix1( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
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


uint SIZE,tsize,ssize,msize;  
uint i,j,ib,ic,id,ie,i1,i2,i3,i4;
uint t1,t2,t3,t4;
uint a,b,c,d,tmp1,tmp2,ii,jj; 

uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

__private uint x[14]; 
uint alt[4]; 
__local uint str[64][4];
uint ssalt[2];



tsize=(uint)1;
ssize=(uint)salt.sC;
msize=(uint)salt.s9;
str[gli][0]=input[(get_global_id(0)*4)];
str[gli][1]=0;
str[gli][2]=0;
str[gli][3]=0;

ssalt[0]=(uint)salt.sE;
ssalt[1]=(uint)salt.sF;



// Calculate alternate sum (pass+salt+pass)
x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;

ii=tsize;

jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;

SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
ii=(uint)ssize+2*tsize;

SET_AB(x,ii,0x80);
SIZE=(uint)((ssize+2*tsize)<<3);


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

alt[0]=a+mCa;alt[1]=b+mCb;alt[2]=c+mCc;alt[3]=d+mCd;



x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;
ii=(uint)0;
x[0]=str[gli][0];
x[1]=(uint)0;
x[2]=(uint)0;
x[3]=(uint)0;
ii=tsize;

SET_AB(x,ii,'$');ii+=(uint)1;
jj=ii;
SET_AB(x,ii,salt.sA&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>8)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>16)&255);ii+=(uint)1;
SET_AB(x,ii,(salt.sA>>24)&255);ii+=(uint)1;
ii=jj+msize;
SET_AB(x,ii,'$');ii+=(uint)1;


jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
for (i=0;i<tsize;i++) 
{
SET_AIS(x,alt,ii,i);ii+=(uint)1;
}

for (i = tsize; i > 0; i >>= 1)
{
    jj = (i&1) != 0 ?  0x00 : str[gli][0]&255;
    x[(ii)>>2] |= (jj << (((ii)&3)<<3));
    ii+=(uint)1;
}

SET_AB(x,ii,0x80);
SIZE=(uint)(ii)<<3;



a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1(b, c, d, a, mAC12,x[11],S14);
MD5STEP_ROUND1(a, b, c, d, mAC13,x[12],S11);
MD5STEP_ROUND1(d, a, b, c, mAC14,x[13], S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC19, x[11],S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC29, x[13],S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC32, x[12], S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC35, x[11], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC41,x[13], S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_ODD(d, a, b, c, mAC46, x[12], S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC53, x[12], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC60, x[13], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC62, x[11], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


// We've got int0, let's do some 1000 md5 iterations
for (ic=0;ic<1000;ic+=2)
{

x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=a;
x[1]=b;
x[2]=c;
x[3]=d;
ii=(uint)16;

if (ic % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}


if (ic % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
ii=jj+tsize;
}

jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
ii=jj+tsize;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32,S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;


x[0]=x[1]=x[2]=x[3]=x[4]=x[5]=x[6]=x[7]=x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=(uint)0;

alt[0]=a;
alt[1]=b;
alt[2]=c;
alt[3]=d;
ii=(uint)0;

x[0]=str[gli][0];
x[1]=str[gli][1];
x[2]=str[gli][2];
x[3]=str[gli][3];

ii=tsize;

if ((ic+1) % 3 != 0)
{
jj=ii;
SET_AIS(x,ssalt,ii,0);ii+=(uint)1;
SET_AIS(x,ssalt,ii,1);ii+=(uint)1;
SET_AIS(x,ssalt,ii,2);ii+=(uint)1;
SET_AIS(x,ssalt,ii,3);ii+=(uint)1;
SET_AIS(x,ssalt,ii,4);ii+=(uint)1;
SET_AIS(x,ssalt,ii,5);ii+=(uint)1;
SET_AIS(x,ssalt,ii,6);ii+=(uint)1;
SET_AIS(x,ssalt,ii,7);ii+=(uint)1;
ii=jj+ssize;
}

if ((ic+1) % 7 != 0)
{
jj=ii;
SET_AIS(x,str[gli],ii,0);ii+=(uint)1;
ii=jj+tsize;
}

SET_AIS(x,alt,ii,0);ii+=(uint)1;
SET_AIS(x,alt,ii,1);ii+=(uint)1;
SET_AIS(x,alt,ii,2);ii+=(uint)1;
SET_AIS(x,alt,ii,3);ii+=(uint)1;
SET_AIS(x,alt,ii,4);ii+=(uint)1;
SET_AIS(x,alt,ii,5);ii+=(uint)1;
SET_AIS(x,alt,ii,6);ii+=(uint)1;
SET_AIS(x,alt,ii,7);ii+=(uint)1;
SET_AIS(x,alt,ii,8);ii+=(uint)1;
SET_AIS(x,alt,ii,9);ii+=(uint)1;
SET_AIS(x,alt,ii,10);ii+=(uint)1;
SET_AIS(x,alt,ii,11);ii+=(uint)1;
SET_AIS(x,alt,ii,12);ii+=(uint)1;
SET_AIS(x,alt,ii,13);ii+=(uint)1;
SET_AIS(x,alt,ii,14);ii+=(uint)1;
SET_AIS(x,alt,ii,15);ii+=(uint)1;

SET_AB(x,ii,0x80);

SIZE=(uint)(ii)<<3;


a = mCa; b = mCb; c = mCc; d = mCd;

MD5STEP_ROUND1(a, b, c, d, mAC1, x[0], S11);  
MD5STEP_ROUND1(d, a, b, c, mAC2, x[1], S12);  
MD5STEP_ROUND1(c, d, a, b, mAC3, x[2], S13);  
MD5STEP_ROUND1(b, c, d, a, mAC4, x[3], S14);  
MD5STEP_ROUND1(a, b, c, d, mAC5, x[4], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC6, x[5], S12); 
MD5STEP_ROUND1(c, d, a, b, mAC7, x[6], S13); 
MD5STEP_ROUND1(b, c, d, a, mAC8, x[7], S14); 
MD5STEP_ROUND1(a, b, c, d, mAC9, x[8], S11); 
MD5STEP_ROUND1(d, a, b, c, mAC10,x[9], S12);
MD5STEP_ROUND1(c, d, a, b, mAC11,x[10],S13);
MD5STEP_ROUND1_NULL(b, c, d, a, mAC12,S14);
MD5STEP_ROUND1_NULL(a, b, c, d, mAC13,S11);
MD5STEP_ROUND1_NULL(d, a, b, c, mAC14,S12);
MD5STEP_ROUND1(c, d, a, b, mAC15,SIZE, S13);  
MD5STEP_ROUND1_NULL(b, c, d, a, mAC16, S14);

MD5STEP_ROUND2 (a, b, c, d, mAC17, x[1], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC18, x[6], S22);
MD5STEP_ROUND2_NULL (c, d, a, b, mAC19,S23);
MD5STEP_ROUND2 (b, c, d, a, mAC20, x[0], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC21, x[5], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC22, x[10],S22);
MD5STEP_ROUND2_NULL (c, d,  a, b, mAC23, S23);
MD5STEP_ROUND2 (b, c, d, a, mAC24, x[4], S24);
MD5STEP_ROUND2 (a, b, c, d, mAC25, x[9], S21);
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC27, x[3], S23);
MD5STEP_ROUND2 (b, c, d, a, mAC28, x[8], S24);
MD5STEP_ROUND2_NULL (a, b, c, d, mAC29,S21);
MD5STEP_ROUND2 (d, a, b, c, mAC30, x[2], S22);
MD5STEP_ROUND2 (c, d, a, b, mAC31, x[7], S23);
MD5STEP_ROUND2_NULL (b, c, d, a, mAC32, S24);

MD5STEP_ROUND3_EVEN(a, b, c, d, mAC33, x[5],  S31);
MD5STEP_ROUND3_ODD(d, a, b, c, mAC34, x[8], S32);
MD5STEP_ROUND3_NULL_EVEN (c, d, a, b, mAC35, S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC37, x[1], S31);
MD5STEP_ROUND3_ODD (d, a, b, c, mAC38, x[4], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC39,x[7], S33);  
MD5STEP_ROUND3_ODD (b, c, d, a, mAC40, x[10], S34);
MD5STEP_ROUND3_NULL_EVEN (a, b, c, d, mAC41, S31);  
MD5STEP_ROUND3_ODD (d, a, b, c, mAC42, x[0], S32);
MD5STEP_ROUND3_EVEN (c, d, a, b, mAC43, x[3], S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC44, x[6], S34);
MD5STEP_ROUND3_EVEN (a, b, c, d, mAC45, x[9], S31);  
MD5STEP_ROUND3_NULL_ODD(d, a, b, c, mAC46, S32);
MD5STEP_ROUND3_NULL_EVEN(c, d, a, b, mAC47, S33);
MD5STEP_ROUND3_ODD (b, c, d, a, mAC48, x[2], S34);

MD5STEP_ROUND4 (a, b, c, d, mAC49, x[0], S41);
MD5STEP_ROUND4 (d, a, b, c, mAC50, x[7], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC52, x[5], S44);
MD5STEP_ROUND4_NULL (a, b, c, d, mAC53, S41);
MD5STEP_ROUND4 (d, a, b, c, mAC54, x[3], S42);
MD5STEP_ROUND4 (c, d, a, b, mAC55, x[10], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC56, x[1], S44);
MD5STEP_ROUND4 (a, b, c, d, mAC57, x[8], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC58, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC59, x[6], S43);
MD5STEP_ROUND4_NULL (b, c, d, a, mAC60, S44);
MD5STEP_ROUND4 (a, b, c, d, mAC61, x[4], S41);
MD5STEP_ROUND4_NULL (d, a, b, c, mAC62, S42);
MD5STEP_ROUND4 (c, d, a, b, mAC63, x[2], S43);
MD5STEP_ROUND4 (b, c, d, a, mAC64, x[9], S44);

a=a+mCa;b=b+mCb;c=c+mCc;d=d+mCd;
} 

id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;



found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);
}



// Dummy kernel
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
md5unix0( __global uint4 *dst,  __global uint *input,   __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt) 
{
}



#endif