#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str)
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
size[GGI] = (SIZE+str.sF)<<3;

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



#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))



__kernel  
void md4( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash)
{


uint SIZE;  
uint i,ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint AC, AD;


id=get_global_id(0);
SIZE=size[id]; 


w0=input[id*8];
w1=input[id*8+1];
w2=input[id*8+2];
w3=input[id*8+3];
w4=input[id*8+4];
w5=input[id*8+5];
w6=input[id*8+6];
w7=input[id*8+7];

w14=SIZE;  


#define S11 3  
#define S12 7  
#define S13 11 
#define S14 19 
#define S21 3  
#define S22 5  
#define S23 9  
#define S24 13 
#define S31 3  
#define S32 9  
#define S33 11 
#define S34 15 

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  


#define MD4STEP_ROUND1(a,b,c,d,x,s) { tmp1 = (b) & (c); tmp2 = ((~b)&(d)); tmp1 = tmp1 | tmp2; (a) = (a)+tmp1+x; (a) = ROTATE((a), (s)); } 
#define MD4STEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (b) & (c); tmp2 = ((~b)&(d)); tmp1 = tmp1 | tmp2; (a) = (a)+tmp1; (a) = ROTATE((a), (s)); }
#define MD4STEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = ROTATE((a),(s));}
#define MD4STEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = ROTATE((a),(s));}
#define MD4STEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = ROTATE((a), (s)); }
#define MD4STEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = ROTATE((a), (s)); }
  

AC = (uint)0x5a827999; 
AD = (uint)0x6ed9eba1; 
a=Ca;b=Cb;c=Cc;d=Cd;

MD4STEP_ROUND1 (a, b, c, d, w0, S11);  
MD4STEP_ROUND1 (d, a, b, c, w1, S12);  
MD4STEP_ROUND1 (c, d, a, b, w2, S13);  
MD4STEP_ROUND1 (b, c, d, a, w3, S14);  
MD4STEP_ROUND1 (a, b, c, d, w4, S11);  
MD4STEP_ROUND1 (d, a, b, c, w5, S12);  
MD4STEP_ROUND1 (c, d, a, b, w6, S13);  
MD4STEP_ROUND1 (b, c, d, a, w7, S14);  
MD4STEP_ROUND1_NULL (a, b, c, d, S11); 
MD4STEP_ROUND1_NULL (d, a, b, c, S12); 
MD4STEP_ROUND1_NULL (c, d, a, b, S13); 
MD4STEP_ROUND1_NULL (b, c, d, a, S14); 
MD4STEP_ROUND1_NULL (a, b, c, d, S11); 
MD4STEP_ROUND1_NULL (d, a, b, c, S12); 
MD4STEP_ROUND1 (c, d, a, b, w14, S13);  
MD4STEP_ROUND1_NULL (b, c, d, a, S14);  

MD4STEP_ROUND2 (a, b, c, d, w0, S21);  
MD4STEP_ROUND2 (d, a, b, c, w4, S22);  
MD4STEP_ROUND2_NULL (c, d, a, b, S23); 
MD4STEP_ROUND2_NULL (b, c, d, a, S24); 
MD4STEP_ROUND2 (a, b, c, d, w1, S21);  
MD4STEP_ROUND2 (d, a, b, c, w5, S22);  
MD4STEP_ROUND2_NULL (c, d, a, b, S23); 
MD4STEP_ROUND2_NULL (b, c, d, a, S24); 
MD4STEP_ROUND2 (a, b, c, d, w2, S21);  
MD4STEP_ROUND2 (d, a, b, c, w6, S22);  
MD4STEP_ROUND2_NULL (c, d, a, b, S23); 
MD4STEP_ROUND2 (b, c, d, a, w14, S24); 
MD4STEP_ROUND2 (a, b, c, d, w3, S21);  
MD4STEP_ROUND2 (d, a, b, c, w7, S22);  
MD4STEP_ROUND2_NULL (c, d, a, b, S23); 
MD4STEP_ROUND2_NULL (b, c, d, a, S24); 



MD4STEP_ROUND3 (a, b, c, d, w0, S31);  
MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w4, S33);  
MD4STEP_ROUND3_NULL(b, c, d, a, S34);  
MD4STEP_ROUND3 (a, b, c, d, w2, S31);  
MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w6, S33);  
MD4STEP_ROUND3 (b, c, d, a, w14, S34); 
MD4STEP_ROUND3 (a, b, c, d, w1, S31);  
MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w5, S33);  
MD4STEP_ROUND3_NULL (b, c, d, a, S34); 
MD4STEP_ROUND3 (a, b, c, d, w3, S31);  

MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w7, S33);  
MD4STEP_ROUND3_NULL (b, c, d, a, S34); 



a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;
id = 0;

#ifdef SINGLE_MODE
id=0;
if ((singlehash.x==a)&&(singlehash.y==b)&&(singlehash.z==c)&&(singlehash.w==d)) id = 1; 
if (id==0) return;
#endif



#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(a,b,c,d);

}
