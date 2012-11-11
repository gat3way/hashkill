#define GGI (get_global_id(0))
#define GLI (get_local_id(0))
#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }


__kernel __attribute__((reqd_work_group_size(64, 1, 1)))
void mscash( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt, uint16 str, uint16 str1)
{  

uint4 SIZE;  
uint ib,ic,id;  
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14;
uint4 AC, AD;
uint yl,yr,zl,zr,wl,wr;
uint x0,x1,x2,x3,x4,x5,x6,x7;
uint4 u0,u1,u2,u3,u4,u5,u6,u7;
__local inpc[64][14];
uint elem, t1;

id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
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

#define mscashSTEP_ROUND1(a,b,c,d,x,s) { (a) = (a)+x+bitselect((d),(c),(b)); (a) = rotate((a), (s)); }
#define mscashSTEP_ROUND1_NULL(a,b,c,d,s) { (a) = (a)+bitselect((d),(c),(b));(a) = rotate((a), (s)); }
#define mscashSTEP_ROUND2(a,b,c,d,x,s) {(a) = (a) +  AC + bitselect((c),(b),((d)^(c))) +x  ; (a) = rotate((a), (s)); }  
#define mscashSTEP_ROUND2_NULL(a,b,c,d,s) {(a) = (a) + bitselect((c),(b),((d)^(c))) + AC; (a) = rotate((a), (s)); }
#define mscashSTEP_ROUND3(a,b,c,d,x,s) { (a) = (a)  + x + AD + ((b) ^ (c) ^ (d)); (a) = rotate((a), (s)); }  
#define mscashSTEP_ROUND3_NULL(a,b,c,d,s) {(a) = (a) + AD + ((b) ^ (c) ^ (d)); (a) = rotate((a), (s)); }
#define mscashSTEP_ROUND3_EVEN(a,b,c,d,x,s) { tmp2 = (b) ^ (c);(a) = (a)  + x + AD + (tmp2 ^ (d)); (a) = rotate((a), (s)); }  
#define mscashSTEP_ROUND3_NULL_EVEN(a,b,c,d,s) {tmp2 = (b) ^ (c); (a) = (a) + AD + (tmp2 ^ (d)); (a) = rotate((a), (s)); }
#define mscashSTEP_ROUND3_ODD(a,b,c,d,x,s) { (a) = (a)  + x + AD + ((b) ^ tmp2); (a) = rotate((a), (s)); }  
#define mscashSTEP_ROUND3_NULL_ODD(a,b,c,d,s) {(a) = (a) + AD + ((b) ^ tmp2); (a) = rotate((a), (s)); }



AC = (uint4)0x5a827999; 
AD = (uint4)0x6ed9eba1; 
a=Ca;b=Cb;c=Cc;d=Cd;
mscashSTEP_ROUND1 (a, b, c, d, w0, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w1, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w2, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w3, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w4, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w5, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w6, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w7, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w8, S11);
mscashSTEP_ROUND1 (d, a, b, c, w9, S12);
mscashSTEP_ROUND1 (c, d, a, b, w10, S13);
mscashSTEP_ROUND1 (b, c, d, a, w11, S14);
mscashSTEP_ROUND1 (a, b, c, d, w12, S11);
mscashSTEP_ROUND1 (d, a, b, c, w13, S12);
mscashSTEP_ROUND1 (c, d, a, b, w14, S13); 
mscashSTEP_ROUND1_NULL (b, c, d, a, S14); 


mscashSTEP_ROUND2 (a, b, c, d, w0, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w4, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w8, S23);
mscashSTEP_ROUND2 (b, c, d, a, w12, S24);
mscashSTEP_ROUND2 (a, b, c, d, w1, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w5, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w9, S23);
mscashSTEP_ROUND2 (b, c, d, a, w13, S24);
mscashSTEP_ROUND2 (a, b, c, d, w2, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w6, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w10, S23);
mscashSTEP_ROUND2 (b, c, d, a, w14, S24);
mscashSTEP_ROUND2 (a, b, c, d, w3, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w7, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w11, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);


mscashSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w8, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
mscashSTEP_ROUND3_ODD(b, c, d, a, w12, S34); 
mscashSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w10, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w9, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a,w13, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c,w11, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;


w0=a;
w1=b;
w2=c;
w3=d;
w4=salt.s0;
w5=salt.s1;
w6=salt.s2;
w7=salt.s3;
w8=salt.s4;
w9=salt.s5;
w10=salt.s6;
w11=salt.s7;
w12=salt.s8;
w13=salt.s9;
w14=salt.sF;

AC = (uint4)0x5a827999; 
AD = (uint4)0x6ed9eba1; 
a=Ca;b=Cb;c=Cc;d=Cd;

mscashSTEP_ROUND1 (a, b, c, d, w0, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w1, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w2, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w3, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w4, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w5, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w6, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w7, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w8, S11);
mscashSTEP_ROUND1 (d, a, b, c, w9, S12);
mscashSTEP_ROUND1 (c, d, a, b, w10, S13);
mscashSTEP_ROUND1 (b, c, d, a, w11, S14);
mscashSTEP_ROUND1 (a, b, c, d, w12, S11);
mscashSTEP_ROUND1 (d, a, b, c, w13, S12);
mscashSTEP_ROUND1 (c, d, a, b, w14, S13); 
mscashSTEP_ROUND1_NULL (b, c, d, a, S14); 


mscashSTEP_ROUND2 (a, b, c, d, w0, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w4, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w8, S23);
mscashSTEP_ROUND2 (b, c, d, a, w12, S24);
mscashSTEP_ROUND2 (a, b, c, d, w1, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w5, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w9, S23);
mscashSTEP_ROUND2 (b, c, d, a, w13, S24);
mscashSTEP_ROUND2 (a, b, c, d, w2, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w6, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w10, S23);
mscashSTEP_ROUND2 (b, c, d, a, w14, S24);
mscashSTEP_ROUND2 (a, b, c, d, w3, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w7, S22); 
mscashSTEP_ROUND2 (c, d, a, b, w11, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);


mscashSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w8, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
mscashSTEP_ROUND3_ODD(b, c, d, a, w12, S34); 
mscashSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w10, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
mscashSTEP_ROUND3_ODD(d, a, b, c, w9, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a,w13, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
if (all((uint4)singlehash.x!=a)) return;
mscashSTEP_ROUND3_ODD(d, a, b, c,w11, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
if (all((uint4)singlehash.y!=b)) return;

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)<<2)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
}  



