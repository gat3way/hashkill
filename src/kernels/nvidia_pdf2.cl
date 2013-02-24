#ifndef SM10
#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__constant uchar cpadding[32] = {
			            0x28, 0xbf, 0x4e, 0x5e, 0x4e, 0x75, 0x8a, 0x41,
		                    0x64, 0x00, 0x4e, 0x56, 0xff, 0xfa, 0x01, 0x08,
	                            0x2e, 0x2e, 0x00, 0xb6, 0xd0, 0x68, 0x3e, 0x80,
        	                    0x2f, 0x0c, 0xa9, 0xfe, 0x64, 0x53, 0x69, 0x7a
                                };

__constant uint cipadding[8] = {
				  0x5e4ebf28U, 0x418a754eU, 0x564e0064U, 0x0801faffU,
				  0xb6002e2eU, 0x803e68d0U, 0xfea90c2fU, 0x7a695364U
                                };



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][22];
uint SIZE;
uint elem,tmp1,i,j;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=0;
inpc[GLI][4]=inpc[GLI][5]=inpc[GLI][6]=inpc[GLI][7]=0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=0;
inpc[GLI][12]=inpc[GLI][13]=inpc[GLI][14]=inpc[GLI][15]=0;

inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);
SIZE+=str.sF;

j=0;
for (i=SIZE;i<36;i+=4)
{
SET_AB(inpc[GLI],cipadding[j],i,0);
j++;
}

sizein[GGI] = (SIZE);
dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}


#define MD5STEP_ROUND1(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((d),(c),(b));(a) = rotate((a),s)+(b);
#define MD5STEP_ROUND1_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((d),(c),(b));(a) = rotate((a),s)+(b);
#define MD5STEP_ROUND2(a, b, c, d, AC, x, s)  (a)=(a)+(AC)+(x)+bitselect((c),(b),(d));(a) = rotate((a),s)+(b);
#define MD5STEP_ROUND2_NULL(a, b, c, d, AC, s)  (a)=(a)+(AC)+bitselect((c),(b),(d)); (a) = rotate((a),s)+(b);
#define MD5STEP_ROUND3(a, b, c, d, AC, x, s) tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC);(a) = (a)+(x); (a) = rotate((a),s); (a) = (a)+(b); 
#define MD5STEP_ROUND3_NULL(a, b, c, d, AC, s)  tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate(a,s); (a) = (a)+(b);
#define MD5STEP_ROUND4(a, b, c, d, AC, x, s)  tmp1 = (~(d)); tmp1 = (b) | tmp1; tmp1 = tmp1 ^ (c); (a) = (a)+tmp1; (a) = (a)+(AC); (a) = (a)+(x); (a) = rotate((a),s); (a) = (a)+(b);  
#define MD5STEP_ROUND4_NULL(a, b, c, d, AC, s)  tmp1 = (~(d)); tmp1 = (b) | tmp1; tmp1 = tmp1 ^ (c); (a) = (a)+tmp1; (a) = (a)+(AC); (a) = rotate((a),s); (a) = (a)+(b);

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  
#define S11 7U
#define S12 12U
#define S13 17U
#define S14 22U
#define S21 5U
#define S22 9U
#define S23 14U
#define S24 20U
#define S31 4U
#define S32 11U
#define S33 16U
#define S34 23U
#define S41 6U
#define S42 10U
#define S43 15U
#define S44 21U

#define PUTCHAR(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2] & ~(0xffU << (((index) & 3) << 3))) + ((val) << (((index) & 3) << 3))
#define GETCHAR(buf, index) (((buf)[(index)>>2] >> (((index)&3)<<3))&255)

__constant uint ident[64] =
{
0x03020100U, 0x07060504U, 0x0b0a0908U, 0x0f0e0d0cU, 
0x13121110U, 0x17161514U, 0x1b1a1918U, 0x1f1e1d1cU,
0x23222120U, 0x27262524U, 0x2b2a2928U, 0x2f2e2d2cU,
0x33323130U, 0x37363534U, 0x3b3a3938U, 0x3f3e3d3cU,
0x43424140U, 0x47464544U, 0x4b4a4948U, 0x4f4e4d4cU,
0x53525150U, 0x57565554U, 0x5b5a5958U, 0x5f5e5d5cU,
0x63626160U, 0x67666564U, 0x6b6a6968U, 0x6f6e6d6cU,
0x73727170U, 0x77767574U, 0x7b7a7978U, 0x7f7e7d7cU,
0x83828180U, 0x87868584U, 0x8b8a8988U, 0x8f8e8d8cU,
0x93929190U, 0x97969594U, 0x9b9a9998U, 0x9f9e9d9cU,
0xa3a2a1a0U, 0xa7a6a5a4U, 0xabaaa9a8U, 0xafaeadacU,
0xb3b2b1b0U, 0xb7b6b5b4U, 0xbbbab9b8U, 0xbfbebdbcU,
0xc3c2c1c0U, 0xc7c6c5c4U, 0xcbcac9c8U, 0xcfcecdccU,
0xd3d2d1d0U, 0xd7d6d5d4U, 0xdbdad9d8U, 0xdfdedddcU,
0xe3e2e1e0U, 0xe7e6e5e4U, 0xebeae9e8U, 0xefeeedecU,
0xf3f2f1f0U, 0xf7f6f5f4U, 0xfbfaf9f8U, 0xfffefdfcU
};




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint i,ib,ic,id;  
uint mCa, mCb, mCc, mCd;
uint a,b,c,d,A,B,C,D, tmp1,tmp2;
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,SIZE,w15;
uint x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;
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

a1=input[get_global_id(0)*8];
b1=input[get_global_id(0)*8+1];
c1=input[get_global_id(0)*8+2];
d1=input[get_global_id(0)*8+3];
e1=input[get_global_id(0)*8+4];
f1=input[get_global_id(0)*8+5];
g1=input[get_global_id(0)*8+6];
h1=input[get_global_id(0)*8+7];


w0=a1;
w1=b1;
w2=c1;
w3=d1;
w4=e1;
w5=f1;
w6=g1;
w7=h1;
w8=salt.s0;
w9=salt.s1;
w10=salt.s2;
w11=salt.s3;
w12=salt.s4;
w13=salt.s5;
SIZE=salt.s6;
w15=salt.s7;

a=(uint)Ca;
b=(uint)Cb;
c=(uint)Cc;
d=(uint)Cd;

MD5STEP_ROUND1 (a, b, c, d, mAC1, w0, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC2, w1, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC3, w2, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC4, w3, S14);
MD5STEP_ROUND1 (a, b, c, d, mAC5, w4, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC6, w5, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC7, w6, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC8, w7, S14);
MD5STEP_ROUND1 (a, b, c, d, mAC9, w8, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC10, w9, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC11, w10,S13);  
MD5STEP_ROUND1 (b, c, d, a, mAC12, w11,S14);  
MD5STEP_ROUND1 (a, b, c, d, mAC13, w12,S11);  
MD5STEP_ROUND1 (d, a, b, c, mAC14, w13,S12);  
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC16, w15, S14);  
MD5STEP_ROUND2 (a, b, c, d, mAC17, w1, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC18, w6, S22); 
MD5STEP_ROUND2 (c, d, a, b, mAC19, w11, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC20, w0, S24);  
MD5STEP_ROUND2 (a, b, c, d, mAC21, w5, S21); 
MD5STEP_ROUND2 (d, a, b, c, mAC22, w10,S22); 
MD5STEP_ROUND2 (c, d,  a, b, mAC23, w15, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC24, w4, S24); 
MD5STEP_ROUND2 (a, b, c, d, mAC25, w9, S21); 
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC27, w3, S23);  
MD5STEP_ROUND2 (b, c, d, a, mAC28, w8, S24); 
MD5STEP_ROUND2 (a, b, c, d, mAC29, w13, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC30, w2, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC31, w7, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC32, w12, S24);  
MD5STEP_ROUND3 (a, b, c, d, mAC33, w5, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC34, w8, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC35, w11, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3 (a, b, c, d, mAC37, w1, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC38, w4, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC39, w7, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC40, w10, S34);
MD5STEP_ROUND3 (a, b, c, d, mAC41, w13, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC42, w0, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC43, w3, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC44, w6, S34);
MD5STEP_ROUND3 (a, b, c, d, mAC45, w9, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC46, w12, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC47, w15, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC48, w2, S34);
MD5STEP_ROUND4 (a, b, c, d, mAC49, w0, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC50, w7, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC52, w5, S44); 
MD5STEP_ROUND4 (a, b, c, d, mAC53, w12, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC54, w3, S42);  
MD5STEP_ROUND4 (c, d, a, b, mAC55, w10, S43); 
MD5STEP_ROUND4 (b, c, d, a, mAC56, w1, S44);  
MD5STEP_ROUND4 (a, b, c, d, mAC57, w8, S41); 
MD5STEP_ROUND4 (d, a, b, c, mAC58, w15, S42);  
MD5STEP_ROUND4 (c, d, a, b, mAC59, w6, S43); 
MD5STEP_ROUND4 (b, c, d, a, mAC60, w13, S44);  
MD5STEP_ROUND4 (a, b, c, d, mAC61, w4, S41); 
MD5STEP_ROUND4 (d, a, b, c, mAC62, w11, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC63, w2, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC64, w9, S44); 
A=a+(uint)Ca;
B=b+(uint)Cb;
C=c+(uint)Cc;
D=d+(uint)Cd;


w0=salt.sF;
w1=salt.sA;
w2=salt.sB;
w3=salt.sC;
w4=salt.sD;
w5=0x80;

w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint)0;
SIZE = (uint)84<<3;

a=(uint)A;
b=(uint)B;
c=(uint)C;
d=(uint)D;

MD5STEP_ROUND1 (a, b, c, d, mAC1, w0, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC2, w1, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC3, w2, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC4, w3, S14);
MD5STEP_ROUND1 (a, b, c, d, mAC5, w4, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC6, w5, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC7, w6, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC8, w7, S14);
MD5STEP_ROUND1 (a, b, c, d, mAC9, w8, S11);
MD5STEP_ROUND1 (d, a, b, c, mAC10, w9, S12);
MD5STEP_ROUND1 (c, d, a, b, mAC11, w10,S13);  
MD5STEP_ROUND1 (b, c, d, a, mAC12, w11,S14);  
MD5STEP_ROUND1 (a, b, c, d, mAC13, w12,S11);  
MD5STEP_ROUND1 (d, a, b, c, mAC14, w13,S12);  
MD5STEP_ROUND1 (c, d, a, b, mAC15, SIZE, S13);
MD5STEP_ROUND1 (b, c, d, a, mAC16, w15, S14);  
MD5STEP_ROUND2 (a, b, c, d, mAC17, w1, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC18, w6, S22); 
MD5STEP_ROUND2 (c, d, a, b, mAC19, w11, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC20, w0, S24);  
MD5STEP_ROUND2 (a, b, c, d, mAC21, w5, S21); 
MD5STEP_ROUND2 (d, a, b, c, mAC22, w10,S22); 
MD5STEP_ROUND2 (c, d,  a, b, mAC23, w15, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC24, w4, S24); 
MD5STEP_ROUND2 (a, b, c, d, mAC25, w9, S21); 
MD5STEP_ROUND2 (d, a, b, c, mAC26, SIZE, S22);
MD5STEP_ROUND2 (c, d, a, b, mAC27, w3, S23);  
MD5STEP_ROUND2 (b, c, d, a, mAC28, w8, S24); 
MD5STEP_ROUND2 (a, b, c, d, mAC29, w13, S21);  
MD5STEP_ROUND2 (d, a, b, c, mAC30, w2, S22);  
MD5STEP_ROUND2 (c, d, a, b, mAC31, w7, S23); 
MD5STEP_ROUND2 (b, c, d, a, mAC32, w12, S24);  
MD5STEP_ROUND3 (a, b, c, d, mAC33, w5, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC34, w8, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC35, w11, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC36, SIZE, S34);  
MD5STEP_ROUND3 (a, b, c, d, mAC37, w1, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC38, w4, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC39, w7, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC40, w10, S34);
MD5STEP_ROUND3 (a, b, c, d, mAC41, w13, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC42, w0, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC43, w3, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC44, w6, S34);
MD5STEP_ROUND3 (a, b, c, d, mAC45, w9, S31);
MD5STEP_ROUND3 (d, a, b, c, mAC46, w12, S32);
MD5STEP_ROUND3 (c, d, a, b, mAC47, w15, S33);
MD5STEP_ROUND3 (b, c, d, a, mAC48, w2, S34);
MD5STEP_ROUND4 (a, b, c, d, mAC49, w0, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC50, w7, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC51, SIZE, S43);
MD5STEP_ROUND4 (b, c, d, a, mAC52, w5, S44); 
MD5STEP_ROUND4 (a, b, c, d, mAC53, w12, S41);  
MD5STEP_ROUND4 (d, a, b, c, mAC54, w3, S42);  
MD5STEP_ROUND4 (c, d, a, b, mAC55, w10, S43); 
MD5STEP_ROUND4 (b, c, d, a, mAC56, w1, S44);  
MD5STEP_ROUND4 (a, b, c, d, mAC57, w8, S41); 
MD5STEP_ROUND4 (d, a, b, c, mAC58, w15, S42);  
MD5STEP_ROUND4 (c, d, a, b, mAC59, w6, S43); 
MD5STEP_ROUND4 (b, c, d, a, mAC60, w13, S44);  
MD5STEP_ROUND4 (a, b, c, d, mAC61, w4, S41); 
MD5STEP_ROUND4 (d, a, b, c, mAC62, w11, S42); 
MD5STEP_ROUND4 (c, d, a, b, mAC63, w2, S43);  
MD5STEP_ROUND4 (b, c, d, a, mAC64, w9, S44); 
a+=(uint)A;
b+=(uint)B;
c+=(uint)C;
d+=(uint)D;

dst[(get_global_id(0)*8)+0]=a;
dst[(get_global_id(0)*8)+1]=b;
dst[(get_global_id(0)*8)+2]=c;
dst[(get_global_id(0)*8)+3]=d;
}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint w0,w1,w2,w3,w4,w5,w6,w7;
uint i,j,k,id,a,b,c,d,e,f,g,h,v,shiftj,sj,u,si,sw,tmp,tmp1,elem;
__local uint state[64][64];
__private uint key[5];
__private uint out[9];

#pragma unroll 32
for (i=0;i<64;i++) state[GLI][i]=ident[i];


i=input[(get_global_id(0)*8)+0];
j=input[(get_global_id(0)*8)+1]&255;

key[0]=i&255;
key[1]=(i>>8)&255;
key[2]=(i>>16)&255;
key[3]=(i>>24)&255;
key[4]=(j)&255;


j=0;
for (i=0;i<256;i+=4)
{
si=state[GLI][i>>2];

u=si&0xff;
j=(j+(key[i%5])+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v,si,0xffffff00U);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>8)&0xff;
j=(j+(key[(i+1)%5])+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<8,si,0xffff00ffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>16)&0xff;
j=(j+(key[(i+2)%5])+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<16,si,0xff00ffffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>24)&0xff;
j=(j+(key[(i+3)%5])+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<24,si,0x00ffffffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

state[GLI][i>>2]=si;
}


i=0;
j=0;
for (k=0;k<32;k++)
{
i=(i+1)&255;
v=GETCHAR(state[GLI],i);
j=(j+v)&255;
shiftj=GETCHAR(state[GLI],j);
PUTCHAR(state[GLI],i,shiftj);
PUTCHAR(state[GLI],j,v);
PUTCHAR(out,k,GETCHAR(state[GLI],(v+shiftj)&255));
}


a=out[0]^cipadding[0];
b=out[1]^cipadding[1];
c=out[2]^cipadding[2];
d=out[3]^cipadding[3];
e=out[4]^cipadding[4];
f=out[5]^cipadding[5];
g=out[6]^cipadding[6];
h=out[7]^cipadding[7];

dst[(get_global_id(0)*8)+0]=a;
dst[(get_global_id(0)*8)+1]=b;
dst[(get_global_id(0)*8)+2]=c;
dst[(get_global_id(0)*8)+3]=d;
dst[(get_global_id(0)*8)+4]=e;
dst[(get_global_id(0)*8)+5]=f;
dst[(get_global_id(0)*8)+6]=g;
dst[(get_global_id(0)*8)+7]=h;

}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint8 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint d1,d2,d3,d4,d5,d6,d7,d8;

d1=input[(get_global_id(0)*8)+0];
d2=input[(get_global_id(0)*8)+1];
d3=input[(get_global_id(0)*8)+2];
d4=input[(get_global_id(0)*8)+3];
d5=input[(get_global_id(0)*8)+4];
d6=input[(get_global_id(0)*8)+5];
d7=input[(get_global_id(0)*8)+6];
d8=input[(get_global_id(0)*8)+7];


if ((d1!=singlehash.s0)) return;
if ((d2!=singlehash.s1)) return;
if ((d3!=singlehash.s2)) return;
if ((d4!=singlehash.s3)) return;
if ((d5!=singlehash.s4)) return;
if ((d6!=singlehash.s5)) return;
if ((d7!=singlehash.s6)) return;
if ((d8!=singlehash.s7)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint8)(d1,d2,d3,d4,d5,d6,d7,d8);

}


#endif