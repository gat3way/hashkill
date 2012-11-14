#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = select((uint)(ai2>>(32U-t1)),0U,(uint)(t1==0));\
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

#define Ca 0x67452301  
#define Cb 0xefcdab89  
#define Cc 0x98badcfe  
#define Cd 0x10325476  

#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { (a) = (a)+x+bitselect((d),(c),(b)); (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { (a) = (a)+bitselect((d),(c),(b));(a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) {(a) = (a) +  AC + bitselect((c),(b),((d)^(c))) +x  ; (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {(a) = (a) + bitselect((c),(b),((d)^(c))) + AC; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) { (a) = (a)  + x + AD + ((b) ^ (c) ^ (d)); (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {(a) = (a) + AD + ((b) ^ (c) ^ (d)); (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND3_EVEN(a,b,c,d,x,s) { tmp2 = (b) ^ (c);(a) = (a)  + x + AD + (tmp2 ^ (d)); (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL_EVEN(a,b,c,d,s) {tmp2 = (b) ^ (c); (a) = (a) + AD + (tmp2 ^ (d)); (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND3_ODD(a,b,c,d,x,s) { (a) = (a)  + x + AD + ((b) ^ tmp2); (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL_ODD(a,b,c,d,s) {(a) = (a) + AD + ((b) ^ tmp2); (a) = rotate((a), (s)); }



#ifndef GCN

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str,uint16 str1,uint16 str2)
{
uint8 SIZE;  
uint i,ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14;  
uint8 AC, AD;
uint xl,xr,yl,yr,zl,zr,wl,wr;  
uint x0,x1,x2,x3,x4,x5,x6,x7;
uint t1,elem;
uint8 u0,u1,u2,u3,u4,u5,u6,u7;
__local uint inpc[64][14];

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
SET_AB(inpc[GLI],str.s0,SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC),0);
u0.s0=inpc[GLI][0];
u1.s0=inpc[GLI][1];
u2.s0=inpc[GLI][2];
u3.s0=inpc[GLI][3];
u4.s0=inpc[GLI][4];
u5.s0=inpc[GLI][5];
u6.s0=inpc[GLI][6];
u7.s0=inpc[GLI][7];
SIZE.s0 = (SIZE.s0+str.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s4,SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD),0);
u0.s1=inpc[GLI][0];
u1.s1=inpc[GLI][1];
u2.s1=inpc[GLI][2];
u3.s1=inpc[GLI][3];
u4.s1=inpc[GLI][4];
u5.s1=inpc[GLI][5];
u6.s1=inpc[GLI][6];
u7.s1=inpc[GLI][7];
SIZE.s1 = (SIZE.s1+str.sD)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s8,SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE),0);
u0.s2=inpc[GLI][0];
u1.s2=inpc[GLI][1];
u2.s2=inpc[GLI][2];
u3.s2=inpc[GLI][3];
u4.s2=inpc[GLI][4];
u5.s2=inpc[GLI][5];
u6.s2=inpc[GLI][6];
u7.s2=inpc[GLI][7];
SIZE.s2 = (SIZE.s2+str.sE)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s0,SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC),0);
u0.s3=inpc[GLI][0];
u1.s3=inpc[GLI][1];
u2.s3=inpc[GLI][2];
u3.s3=inpc[GLI][3];
u4.s3=inpc[GLI][4];
u5.s3=inpc[GLI][5];
u6.s3=inpc[GLI][6];
u7.s3=inpc[GLI][7];
SIZE.s3 = (SIZE.s3+str1.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s4,SIZE.s4,0);
SET_AB(inpc[GLI],str1.s5,SIZE.s4+4,0);
SET_AB(inpc[GLI],str1.s6,SIZE.s4+8,0);
SET_AB(inpc[GLI],str1.s7,SIZE.s4+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s4+str1.sD),0);
u0.s4=inpc[GLI][0];
u1.s4=inpc[GLI][1];
u2.s4=inpc[GLI][2];
u3.s4=inpc[GLI][3];
u4.s4=inpc[GLI][4];
u5.s4=inpc[GLI][5];
u6.s4=inpc[GLI][6];
u7.s4=inpc[GLI][7];
SIZE.s4 = (SIZE.s4+str1.sD)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s8,SIZE.s5,0);
SET_AB(inpc[GLI],str1.s9,SIZE.s5+4,0);
SET_AB(inpc[GLI],str1.sA,SIZE.s5+8,0);
SET_AB(inpc[GLI],str1.sB,SIZE.s5+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s5+str1.sE),0);
u0.s5=inpc[GLI][0];
u1.s5=inpc[GLI][1];
u2.s5=inpc[GLI][2];
u3.s5=inpc[GLI][3];
u4.s5=inpc[GLI][4];
u5.s5=inpc[GLI][5];
u6.s5=inpc[GLI][6];
u7.s5=inpc[GLI][7];
SIZE.s5 = (SIZE.s5+str1.sE)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str2.s0,SIZE.s6,0);
SET_AB(inpc[GLI],str2.s1,SIZE.s6+4,0);
SET_AB(inpc[GLI],str2.s2,SIZE.s6+8,0);
SET_AB(inpc[GLI],str2.s3,SIZE.s6+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s6+str2.sC),0);
u0.s6=inpc[GLI][0];
u1.s6=inpc[GLI][1];
u2.s6=inpc[GLI][2];
u3.s6=inpc[GLI][3];
u4.s6=inpc[GLI][4];
u5.s6=inpc[GLI][5];
u6.s6=inpc[GLI][6];
u7.s6=inpc[GLI][7];
SIZE.s6 = (SIZE.s6+str2.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str2.s4,SIZE.s7,0);
SET_AB(inpc[GLI],str2.s5,SIZE.s7+4,0);
SET_AB(inpc[GLI],str2.s6,SIZE.s7+8,0);
SET_AB(inpc[GLI],str2.s7,SIZE.s7+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s7+str2.sD),0);
u0.s7=inpc[GLI][0];
u1.s7=inpc[GLI][1];
u2.s7=inpc[GLI][2];
u3.s7=inpc[GLI][3];
u4.s7=inpc[GLI][4];
u5.s7=inpc[GLI][5];
u6.s7=inpc[GLI][6];
u7.s7=inpc[GLI][7];
SIZE.s7 = (SIZE.s7+str2.sD)<<4;



w0=((u0&255))|(((u0>>8)&255)<<16);
w1=(((u0>>16)&255))|(((u0>>24)&255)<<16);
w2=((u1&255))|(((u1>>8)&255)<<16);
w3=(((u1>>16)&255))|(((u1>>24)&255)<<16);
w4=((u2&255))|(((u2>>8)&255)<<16);
w5=(((u2>>16)&255))|(((u2>>24)&255)<<16);
w6=((u3&255))|(((u3>>8)&255)<<16);
w7=(((u3>>16)&255))|(((u3>>24)&255)<<16);
w8=((u4&255))|(((u4>>8)&255)<<16);
w9=(((u4>>16)&255))|(((u4>>24)&255)<<16);
w10=((u5&255))|(((u5>>8)&255)<<16);
w11=(((u5>>16)&255))|(((u5>>24)&255)<<16);
w12=((u6&255))|(((u6>>8)&255)<<16);
w13=(((u6>>16)&255))|(((u6>>24)&255)<<16);


w14=SIZE;  



AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 
a=Ca;b=Cb;c=Cc;d=Cd;


ntlmSTEP_ROUND1 (a, b, c, d, w0, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w1, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w2, S13); 
ntlmSTEP_ROUND1 (b, c, d, a, w3, S14); 
ntlmSTEP_ROUND1 (a, b, c, d, w4, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w5, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w6, S13); 
ntlmSTEP_ROUND1 (b, c, d, a, w7, S14); 
ntlmSTEP_ROUND1 (a, b, c, d, w8, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w9, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w10, S13);
ntlmSTEP_ROUND1 (b, c, d, a, w11, S14);
ntlmSTEP_ROUND1 (a, b, c, d, w12, S11);
ntlmSTEP_ROUND1 (d, a, b, c, w13, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 

ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w8, S23); 
ntlmSTEP_ROUND2 (b, c, d, a, w12, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w9, S23); 
ntlmSTEP_ROUND2 (b, c, d, a, w13, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w2, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w6, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w10, S23);
ntlmSTEP_ROUND2 (b, c, d, a, w14, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w3, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w7, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w11, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);

ntlmSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w8, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w12, S34); 
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w13, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w11, S32);
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
#ifdef SINGLE_MODE
if (all((uint8)singlehash.x!=a)) return;
if (all((uint8)singlehash.y!=b)) return;
#endif
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
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

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

void ntlmblock( __global uint4 *dst,uint x0,uint x1,uint x2,uint x3,uint x4,uint x5,uint x6,uint x7,uint x8,uint x9,uint x10,uint x11,uint x12,uint x13,uint size, __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash,uint offset)
{
uint SIZE;  
uint i,ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14;  
uint AC, AD;

w0=x0;
w1=x1;
w2=x2;
w3=x3;
w4=x4;
w5=x5;
w6=x6;
w7=x7;
w8=x8;
w9=x9;
w10=x10;
w11=x11;
w12=x12;
w13=x13;
w14=size;

AC = (uint)0x5a827999; 
AD = (uint)0x6ed9eba1; 
a=Ca;b=Cb;c=Cc;d=Cd;


ntlmSTEP_ROUND1 (a, b, c, d, w0, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w1, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w2, S13); 
ntlmSTEP_ROUND1 (b, c, d, a, w3, S14); 
ntlmSTEP_ROUND1 (a, b, c, d, w4, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w5, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w6, S13); 
ntlmSTEP_ROUND1 (b, c, d, a, w7, S14); 
ntlmSTEP_ROUND1 (a, b, c, d, w8, S11); 
ntlmSTEP_ROUND1 (d, a, b, c, w9, S12); 
ntlmSTEP_ROUND1 (c, d, a, b, w10, S13);
ntlmSTEP_ROUND1 (b, c, d, a, w11, S14);
ntlmSTEP_ROUND1 (a, b, c, d, w12, S11);
ntlmSTEP_ROUND1 (d, a, b, c, w13, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 

ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w8, S23); 
ntlmSTEP_ROUND2 (b, c, d, a, w12, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w9, S23); 
ntlmSTEP_ROUND2 (b, c, d, a, w13, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w2, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w6, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w10, S23);
ntlmSTEP_ROUND2 (b, c, d, a, w14, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w3, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w7, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w11, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);

ntlmSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w8, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w12, S34); 
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w13, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_ODD (d, a, b, c, w11, S32);
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
#ifdef SINGLE_MODE
if (((uint)singlehash.x!=a)) return;
if (((uint)singlehash.y!=b)) return;
#endif
#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
else return;
#endif
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*8)+offset] = (uint4)(a,b,c,d);


}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint16 str,uint16 str1,uint16 str2)
{
uint8 SIZE;  
uint i,ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14;  
uint8 AC, AD;
uint xl,xr,yl,yr,zl,zr,wl,wr;  
uint x0,x1,x2,x3,x4,x5,x6,x7;
uint t1,elem;
uint8 u0,u1,u2,u3,u4,u5,u6,u7;
__local uint inpc[64][14];

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
SET_AB(inpc[GLI],str.s0,SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC),0);
u0.s0=inpc[GLI][0];
u1.s0=inpc[GLI][1];
u2.s0=inpc[GLI][2];
u3.s0=inpc[GLI][3];
u4.s0=inpc[GLI][4];
u5.s0=inpc[GLI][5];
u6.s0=inpc[GLI][6];
u7.s0=inpc[GLI][7];
SIZE.s0 = (SIZE.s0+str.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s4,SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD),0);
u0.s1=inpc[GLI][0];
u1.s1=inpc[GLI][1];
u2.s1=inpc[GLI][2];
u3.s1=inpc[GLI][3];
u4.s1=inpc[GLI][4];
u5.s1=inpc[GLI][5];
u6.s1=inpc[GLI][6];
u7.s1=inpc[GLI][7];
SIZE.s1 = (SIZE.s1+str.sD)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s8,SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE),0);
u0.s2=inpc[GLI][0];
u1.s2=inpc[GLI][1];
u2.s2=inpc[GLI][2];
u3.s2=inpc[GLI][3];
u4.s2=inpc[GLI][4];
u5.s2=inpc[GLI][5];
u6.s2=inpc[GLI][6];
u7.s2=inpc[GLI][7];
SIZE.s2 = (SIZE.s2+str.sE)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s0,SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC),0);
u0.s3=inpc[GLI][0];
u1.s3=inpc[GLI][1];
u2.s3=inpc[GLI][2];
u3.s3=inpc[GLI][3];
u4.s3=inpc[GLI][4];
u5.s3=inpc[GLI][5];
u6.s3=inpc[GLI][6];
u7.s3=inpc[GLI][7];
SIZE.s3 = (SIZE.s3+str1.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s4,SIZE.s4,0);
SET_AB(inpc[GLI],str1.s5,SIZE.s4+4,0);
SET_AB(inpc[GLI],str1.s6,SIZE.s4+8,0);
SET_AB(inpc[GLI],str1.s7,SIZE.s4+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s4+str1.sD),0);
u0.s4=inpc[GLI][0];
u1.s4=inpc[GLI][1];
u2.s4=inpc[GLI][2];
u3.s4=inpc[GLI][3];
u4.s4=inpc[GLI][4];
u5.s4=inpc[GLI][5];
u6.s4=inpc[GLI][6];
u7.s4=inpc[GLI][7];
SIZE.s4 = (SIZE.s4+str1.sD)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str1.s8,SIZE.s5,0);
SET_AB(inpc[GLI],str1.s9,SIZE.s5+4,0);
SET_AB(inpc[GLI],str1.sA,SIZE.s5+8,0);
SET_AB(inpc[GLI],str1.sB,SIZE.s5+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s5+str1.sE),0);
u0.s5=inpc[GLI][0];
u1.s5=inpc[GLI][1];
u2.s5=inpc[GLI][2];
u3.s5=inpc[GLI][3];
u4.s5=inpc[GLI][4];
u5.s5=inpc[GLI][5];
u6.s5=inpc[GLI][6];
u7.s5=inpc[GLI][7];
SIZE.s5 = (SIZE.s5+str1.sE)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str2.s0,SIZE.s6,0);
SET_AB(inpc[GLI],str2.s1,SIZE.s6+4,0);
SET_AB(inpc[GLI],str2.s2,SIZE.s6+8,0);
SET_AB(inpc[GLI],str2.s3,SIZE.s6+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s6+str2.sC),0);
u0.s6=inpc[GLI][0];
u1.s6=inpc[GLI][1];
u2.s6=inpc[GLI][2];
u3.s6=inpc[GLI][3];
u4.s6=inpc[GLI][4];
u5.s6=inpc[GLI][5];
u6.s6=inpc[GLI][6];
u7.s6=inpc[GLI][7];
SIZE.s6 = (SIZE.s6+str2.sC)<<4;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str2.s4,SIZE.s7,0);
SET_AB(inpc[GLI],str2.s5,SIZE.s7+4,0);
SET_AB(inpc[GLI],str2.s6,SIZE.s7+8,0);
SET_AB(inpc[GLI],str2.s7,SIZE.s7+12,0);
SET_AB(inpc[GLI],0x80,(SIZE.s7+str2.sD),0);
u0.s7=inpc[GLI][0];
u1.s7=inpc[GLI][1];
u2.s7=inpc[GLI][2];
u3.s7=inpc[GLI][3];
u4.s7=inpc[GLI][4];
u5.s7=inpc[GLI][5];
u6.s7=inpc[GLI][6];
u7.s7=inpc[GLI][7];
SIZE.s7 = (SIZE.s7+str2.sD)<<4;



w0=((u0&255))|(((u0>>8)&255)<<16);
w1=(((u0>>16)&255))|(((u0>>24)&255)<<16);
w2=((u1&255))|(((u1>>8)&255)<<16);
w3=(((u1>>16)&255))|(((u1>>24)&255)<<16);
w4=((u2&255))|(((u2>>8)&255)<<16);
w5=(((u2>>16)&255))|(((u2>>24)&255)<<16);
w6=((u3&255))|(((u3>>8)&255)<<16);
w7=(((u3>>16)&255))|(((u3>>24)&255)<<16);
w8=((u4&255))|(((u4>>8)&255)<<16);
w9=(((u4>>16)&255))|(((u4>>24)&255)<<16);
w10=((u5&255))|(((u5>>8)&255)<<16);
w11=(((u5>>16)&255))|(((u5>>24)&255)<<16);
w12=((u6&255))|(((u6>>8)&255)<<16);
w13=(((u6>>16)&255))|(((u6>>24)&255)<<16);

ntlmblock(dst,w0.s0,w1.s0,w2.s0,w3.s0,w4.s0,w5.s0,w6.s0,w7.s0,w8.s0,w9.s0,w10.s0,w11.s0,w12.s0,w13.s0,SIZE.s0,found_ind,bitmaps,found,singlehash,0);
ntlmblock(dst,w0.s1,w1.s1,w2.s1,w3.s1,w4.s1,w5.s1,w6.s1,w7.s1,w8.s1,w9.s1,w10.s1,w11.s1,w12.s1,w13.s1,SIZE.s1,found_ind,bitmaps,found,singlehash,1);
ntlmblock(dst,w0.s2,w1.s2,w2.s2,w3.s2,w4.s2,w5.s2,w6.s2,w7.s2,w8.s2,w9.s2,w10.s2,w11.s2,w12.s2,w13.s2,SIZE.s2,found_ind,bitmaps,found,singlehash,2);
ntlmblock(dst,w0.s3,w1.s3,w2.s3,w3.s3,w4.s3,w5.s3,w6.s3,w7.s3,w8.s3,w9.s3,w10.s3,w11.s3,w12.s3,w13.s3,SIZE.s3,found_ind,bitmaps,found,singlehash,3);
ntlmblock(dst,w0.s4,w1.s4,w2.s4,w3.s4,w4.s4,w5.s4,w6.s4,w7.s4,w8.s4,w9.s4,w10.s4,w11.s4,w12.s4,w13.s4,SIZE.s4,found_ind,bitmaps,found,singlehash,4);
ntlmblock(dst,w0.s5,w1.s5,w2.s5,w3.s5,w4.s5,w5.s5,w6.s5,w7.s5,w8.s5,w9.s5,w10.s5,w11.s5,w12.s5,w13.s5,SIZE.s5,found_ind,bitmaps,found,singlehash,5);
ntlmblock(dst,w0.s6,w1.s6,w2.s6,w3.s6,w4.s6,w5.s6,w6.s6,w7.s6,w8.s6,w9.s6,w10.s6,w11.s6,w12.s6,w13.s6,SIZE.s6,found_ind,bitmaps,found,singlehash,6);
ntlmblock(dst,w0.s7,w1.s7,w2.s7,w3.s7,w4.s7,w5.s7,w6.s7,w7.s7,w8.s7,w9.s7,w10.s7,w11.s7,w12.s7,w13.s7,SIZE.s7,found_ind,bitmaps,found,singlehash,7);

}



#endif
