#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }

#define S11 3U  
#define S12 7U  
#define S13 11U 
#define S14 19U 
#define S21 3U  
#define S22 5U  
#define S23 9U  
#define S24 13U 
#define S31 3U  
#define S32 9U  
#define S33 11U 
#define S34 15U 

#define Ca 0x67452301U  
#define Cb 0xefcdab89U  
#define Cc 0x98badcfeU  
#define Cd 0x10325476U  


#define MD4STEP_ROUND1(a,b,c,d,x,s) { tmp1 = (b) & (c); tmp2 = ((~b)&(d)); tmp1 = tmp1 | tmp2; (a) = (a)+tmp1+x; (a) = rotate((a), (s)); } 
#define MD4STEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (b) & (c); tmp2 = ((~b)&(d)); tmp1 = tmp1 | tmp2; (a) = (a)+tmp1; (a) = rotate((a), (s)); }
#define MD4STEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = rotate((a),(s));}
#define MD4STEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = rotate((a),(s));}
#define MD4STEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = rotate((a), (s)); }
#define MD4STEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = rotate((a), (s)); }


#ifndef GCN

__kernel  
void md4( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1,uint16 str2)
{
uint8 SIZE;  
uint i,ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint8 AC, AD;
__local uint inpc[64][14];
uint elem,t1;
uint x0,x1,x2,x3,x4,x5,x6,x7;


id=get_global_id(0);
SIZE=(uint8)sizein[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s0,SIZE.s0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC));
w0.s0=inpc[GLI][0];
w1.s0=inpc[GLI][1];
w2.s0=inpc[GLI][2];
w3.s0=inpc[GLI][3];
w4.s0=inpc[GLI][4];
w5.s0=inpc[GLI][5];
w6.s0=inpc[GLI][6];
w7.s0=inpc[GLI][7];
SIZE.s0 = (SIZE.s0+str.sC)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s4,SIZE.s1);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD));
w0.s1=inpc[GLI][0];
w1.s1=inpc[GLI][1];
w2.s1=inpc[GLI][2];
w3.s1=inpc[GLI][3];
w4.s1=inpc[GLI][4];
w5.s1=inpc[GLI][5];
w6.s1=inpc[GLI][6];
w7.s1=inpc[GLI][7];
SIZE.s1 = (SIZE.s1+str.sD)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s8,SIZE.s2);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE));
w0.s2=inpc[GLI][0];
w1.s2=inpc[GLI][1];
w2.s2=inpc[GLI][2];
w3.s2=inpc[GLI][3];
w4.s2=inpc[GLI][4];
w5.s2=inpc[GLI][5];
w6.s2=inpc[GLI][6];
w7.s2=inpc[GLI][7];
SIZE.s2 = (SIZE.s2+str.sE)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s0,SIZE.s3);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC));
w0.s3=inpc[GLI][0];
w1.s3=inpc[GLI][1];
w2.s3=inpc[GLI][2];
w3.s3=inpc[GLI][3];
w4.s3=inpc[GLI][4];
w5.s3=inpc[GLI][5];
w6.s3=inpc[GLI][6];
w7.s3=inpc[GLI][7];
SIZE.s3 = (SIZE.s3+str1.sC)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s4,SIZE.s4);
SET_AB(inpc[GLI],str1.s5,SIZE.s4+4);
SET_AB(inpc[GLI],str1.s6,SIZE.s4+8);
SET_AB(inpc[GLI],str1.s7,SIZE.s4+12);
SET_AB(inpc[GLI],0x80,(SIZE.s4+str1.sD));
w0.s4=inpc[GLI][0];
w1.s4=inpc[GLI][1];
w2.s4=inpc[GLI][2];
w3.s4=inpc[GLI][3];
w4.s4=inpc[GLI][4];
w5.s4=inpc[GLI][5];
w6.s4=inpc[GLI][6];
w7.s4=inpc[GLI][7];
SIZE.s4 = (SIZE.s4+str1.sD)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s8,SIZE.s5);
SET_AB(inpc[GLI],str1.s9,SIZE.s5+4);
SET_AB(inpc[GLI],str1.sA,SIZE.s5+8);
SET_AB(inpc[GLI],str1.sB,SIZE.s5+12);
SET_AB(inpc[GLI],0x80,(SIZE.s5+str1.sE));
w0.s5=inpc[GLI][0];
w1.s5=inpc[GLI][1];
w2.s5=inpc[GLI][2];
w3.s5=inpc[GLI][3];
w4.s5=inpc[GLI][4];
w5.s5=inpc[GLI][5];
w6.s5=inpc[GLI][6];
w7.s5=inpc[GLI][7];
SIZE.s5 = (SIZE.s5+str1.sE)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str2.s0,SIZE.s6);
SET_AB(inpc[GLI],str2.s1,SIZE.s6+4);
SET_AB(inpc[GLI],str2.s2,SIZE.s6+8);
SET_AB(inpc[GLI],str2.s3,SIZE.s6+12);
SET_AB(inpc[GLI],0x80,(SIZE.s6+str2.sC));
w0.s6=inpc[GLI][0];
w1.s6=inpc[GLI][1];
w2.s6=inpc[GLI][2];
w3.s6=inpc[GLI][3];
w4.s6=inpc[GLI][4];
w5.s6=inpc[GLI][5];
w6.s6=inpc[GLI][6];
w7.s6=inpc[GLI][7];
SIZE.s6 = (SIZE.s6+str2.sC)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str2.s4,SIZE.s7);
SET_AB(inpc[GLI],str2.s5,SIZE.s7+4);
SET_AB(inpc[GLI],str2.s6,SIZE.s7+8);
SET_AB(inpc[GLI],str2.s7,SIZE.s7+12);
SET_AB(inpc[GLI],0x80,(SIZE.s7+str2.sD));
w0.s7=inpc[GLI][0];
w1.s7=inpc[GLI][1];
w2.s7=inpc[GLI][2];
w3.s7=inpc[GLI][3];
w4.s7=inpc[GLI][4];
w5.s7=inpc[GLI][5];
w6.s7=inpc[GLI][6];
w7.s7=inpc[GLI][7];
SIZE.s7 = (SIZE.s7+str2.sD)<<3;


w14=SIZE;  


AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 
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
#ifndef SINGLE_MODE
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;

b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s4;b2=b.s4;b3=c.s4;b4=d.s4;
b5=(singlehash.x >> (b.s4&31))&1;
b6=(singlehash.y >> (c.s4&31))&1;
b7=(singlehash.z >> (d.s4&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s5;b2=b.s5;b3=c.s5;b4=d.s5;
b5=(singlehash.x >> (b.s5&31))&1;
b6=(singlehash.y >> (c.s5&31))&1;
b7=(singlehash.z >> (d.s5&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s6;b2=b.s6;b3=c.s6;b4=d.s6;
b5=(singlehash.x >> (b.s6&31))&1;
b6=(singlehash.y >> (c.s6&31))&1;
b7=(singlehash.z >> (d.s6&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s7;b2=b.s7;b3=c.s7;b4=d.s7;
b5=(singlehash.x >> (b.s7&31))&1;
b6=(singlehash.y >> (c.s7&31))&1;
b7=(singlehash.z >> (d.s7&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w7, S33);  
MD4STEP_ROUND3_NULL (b, c, d, a, S34); 


a=a+(uint8)Ca;b=b+(uint8)Cb;c=c+(uint8)Cc;d=d+(uint8)Cd;
id = 0;

#ifdef SINGLE_MODE
id=0;
if (all((uint8)singlehash.x!=a)) return;
if (all((uint8)singlehash.y!=b)) return;
#endif




found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*8)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*8)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*8)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*8)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
dst[(get_global_id(0)*8)+4] = (uint4)(a.s4,b.s4,c.s4,d.s4);
dst[(get_global_id(0)*8)+5] = (uint4)(a.s5,b.s5,c.s5,d.s5);
dst[(get_global_id(0)*8)+6] = (uint4)(a.s6,b.s6,c.s6,d.s6);
dst[(get_global_id(0)*8)+7] = (uint4)(a.s7,b.s7,c.s7,d.s7);

}


#else

void md4_block(__global uint4 *dst,uint w0,uint w1,uint w2,uint w3,uint w4,uint w5,uint w6,uint w7,uint SIZE,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint offset)
{
uint i,ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w14;
uint AC, AD;


w14=SIZE;  


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
#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif
MD4STEP_ROUND3_NULL(d, a, b, c, S32);  
MD4STEP_ROUND3 (c, d, a, b, w7, S33);  
MD4STEP_ROUND3_NULL (b, c, d, a, S34); 


a=a+(uint)Ca;b=b+(uint)Cb;c=c+(uint)Cc;d=d+(uint)Cd;
id = 0;

#ifdef SINGLE_MODE
id=0;
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;
#endif


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*8)+offset] = (uint4)(a,b,c,d);
}

__kernel  
void md4( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str, uint16 str1,uint16 str2)
{
uint SIZE,size;  
uint i,ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint AC, AD;
__local uint inpc[64][14];
uint elem,t1;
uint x0,x1,x2,x3,x4,x5,x6,x7;


id=get_global_id(0);
size=(uint)sizein[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s0,size);
SET_AB(inpc[GLI],str.s1,size+4);
SET_AB(inpc[GLI],str.s2,size+8);
SET_AB(inpc[GLI],str.s3,size+12);
SET_AB(inpc[GLI],0x80,(size+str.sC));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sC)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,0);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s4,size);
SET_AB(inpc[GLI],str.s5,size+4);
SET_AB(inpc[GLI],str.s6,size+8);
SET_AB(inpc[GLI],str.s7,size+12);
SET_AB(inpc[GLI],0x80,(size+str.sD));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sD)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,1);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s8,size);
SET_AB(inpc[GLI],str.s9,size+4);
SET_AB(inpc[GLI],str.sA,size+8);
SET_AB(inpc[GLI],str.sB,size+12);
SET_AB(inpc[GLI],0x80,(size+str.sE));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str.sE)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,2);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s0,size);
SET_AB(inpc[GLI],str1.s1,size+4);
SET_AB(inpc[GLI],str1.s2,size+8);
SET_AB(inpc[GLI],str1.s3,size+12);
SET_AB(inpc[GLI],0x80,(size+str1.sC));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str1.sC)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,3);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s4,size);
SET_AB(inpc[GLI],str1.s5,size+4);
SET_AB(inpc[GLI],str1.s6,size+8);
SET_AB(inpc[GLI],str1.s7,size+12);
SET_AB(inpc[GLI],0x80,(size+str1.sD));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str1.sD)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,4);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str1.s8,size);
SET_AB(inpc[GLI],str1.s9,size+4);
SET_AB(inpc[GLI],str1.sA,size+8);
SET_AB(inpc[GLI],str1.sB,size+12);
SET_AB(inpc[GLI],0x80,(size+str1.sE));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str1.sE)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,5);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str2.s0,size);
SET_AB(inpc[GLI],str2.s1,size+4);
SET_AB(inpc[GLI],str2.s2,size+8);
SET_AB(inpc[GLI],str2.s3,size+12);
SET_AB(inpc[GLI],0x80,(size+str2.sC));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str2.sC)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,6);


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str2.s4,size);
SET_AB(inpc[GLI],str2.s5,size+4);
SET_AB(inpc[GLI],str2.s6,size+8);
SET_AB(inpc[GLI],str2.s7,size+12);
SET_AB(inpc[GLI],0x80,(size+str2.sD));
w0=inpc[GLI][0];
w1=inpc[GLI][1];
w2=inpc[GLI][2];
w3=inpc[GLI][3];
w4=inpc[GLI][4];
w5=inpc[GLI][5];
w6=inpc[GLI][6];
w7=inpc[GLI][7];
SIZE = (size+str2.sD)<<3;
md4_block(dst,w0,w1,w2,w3,w4,w5,w6,w7,SIZE,found_ind,bitmaps,found,singlehash,7);


}



#endif

