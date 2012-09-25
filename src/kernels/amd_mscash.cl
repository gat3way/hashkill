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
size[GGI] = (SIZE+str.sF)<<4;

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


__kernel __attribute__((reqd_work_group_size(64, 1, 1)))
void mscash( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt)
{  

uint4 SIZE;  
uint ib,ic,id;  
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14;
uint4 AC, AD;
uint yl,yr,zl,zr,wl,wr;
uint w[8];


id=get_global_id(0);
SIZE.s0=(size[id*4]); 
SIZE.s1=(size[id*4+1]); 
SIZE.s2=(size[id*4+2]); 
SIZE.s3=(size[id*4+3]); 
w14=SIZE;


w[0]=input[id*4*8];
w[1]=input[id*4*8+1];
w[2]=input[id*4*8+2];
w[3]=input[id*4*8+3];
w[4]=input[id*4*8+4];
w[5]=input[id*4*8+5];
w[6]=input[id*4*8+6];
w[7]=input[id*4*8+7];
w0.s0=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s0=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s0=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s0=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s0=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s0=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s0=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s0=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s0=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s0=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s0=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s0=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s0=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s0=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);


w[0]=input[id*4*8+8];
w[1]=input[id*4*8+9];
w[2]=input[id*4*8+10];
w[3]=input[id*4*8+11];
w[4]=input[id*4*8+12];
w[5]=input[id*4*8+13];
w[6]=input[id*4*8+14];
w[7]=input[id*4*8+15];
w0.s1=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s1=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s1=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s1=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s1=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s1=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s1=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s1=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s1=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s1=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s1=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s1=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s1=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s1=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);

w[0]=input[id*4*8+16];
w[1]=input[id*4*8+17];
w[2]=input[id*4*8+18];
w[3]=input[id*4*8+19];
w[4]=input[id*4*8+20];
w[5]=input[id*4*8+21];
w[6]=input[id*4*8+22];
w[7]=input[id*4*8+23];
w0.s2=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s2=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s2=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s2=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s2=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s2=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s2=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s2=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s2=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s2=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s2=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s2=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s2=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s2=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);

w[0]=input[id*4*8+24];
w[1]=input[id*4*8+25];
w[2]=input[id*4*8+26];
w[3]=input[id*4*8+27];
w[4]=input[id*4*8+28];
w[5]=input[id*4*8+29];
w[6]=input[id*4*8+30];
w[7]=input[id*4*8+31];
w0.s3=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s3=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s3=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s3=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s3=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s3=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s3=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s3=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s3=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s3=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s3=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s3=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s3=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s3=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);



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



