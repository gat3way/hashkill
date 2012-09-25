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



#ifndef OLD_ATI

__kernel  
void ntlm( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash)
{

uint8 SIZE;  
uint i,ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14;  
uint8 AC, AD;
uint w[8];
uint xl,xr,yl,yr,zl,zr,wl,wr;  



id=get_global_id(0);
SIZE.s0=size[id*8]; 
SIZE.s1=size[id*8+1]; 
SIZE.s2=size[id*8+2]; 
SIZE.s3=size[id*8+3]; 
SIZE.s4=size[id*8+4]; 
SIZE.s5=size[id*8+5]; 
SIZE.s6=size[id*8+6]; 
SIZE.s7=size[id*8+7]; 


w[0]=input[id*8*8];
w[1]=input[id*8*8+1];
w[2]=input[id*8*8+2];
w[3]=input[id*8*8+3];
w[4]=input[id*8*8+4];
w[5]=input[id*8*8+5];
w[6]=input[id*8*8+6];
w[7]=input[id*8*8+7];
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

w[0]=input[id*8*8+8];
w[1]=input[id*8*8+9];
w[2]=input[id*8*8+10];
w[3]=input[id*8*8+11];
w[4]=input[id*8*8+12];
w[5]=input[id*8*8+13];
w[6]=input[id*8*8+14];
w[7]=input[id*8*8+15];
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

w[0]=input[id*8*8+16];
w[1]=input[id*8*8+17];
w[2]=input[id*8*8+18];
w[3]=input[id*8*8+19];
w[4]=input[id*8*8+20];
w[5]=input[id*8*8+21];
w[6]=input[id*8*8+22];
w[7]=input[id*8*8+23];
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

w[0]=input[id*8*8+24];
w[1]=input[id*8*8+25];
w[2]=input[id*8*8+26];
w[3]=input[id*8*8+27];
w[4]=input[id*8*8+28];
w[5]=input[id*8*8+29];
w[6]=input[id*8*8+30];
w[7]=input[id*8*8+31];
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


w[0]=input[id*8*8+32];
w[1]=input[id*8*8+33];
w[2]=input[id*8*8+34];
w[3]=input[id*8*8+35];
w[4]=input[id*8*8+36];
w[5]=input[id*8*8+37];
w[6]=input[id*8*8+38];
w[7]=input[id*8*8+39];
w0.s4=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s4=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s4=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s4=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s4=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s4=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s4=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s4=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s4=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s4=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s4=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s4=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s4=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s4=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);

w[0]=input[id*8*8+40];
w[1]=input[id*8*8+41];
w[2]=input[id*8*8+42];
w[3]=input[id*8*8+43];
w[4]=input[id*8*8+44];
w[5]=input[id*8*8+45];
w[6]=input[id*8*8+46];
w[7]=input[id*8*8+47];
w0.s5=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s5=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s5=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s5=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s5=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s5=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s5=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s5=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s5=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s5=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s5=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s5=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s5=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s5=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);

w[0]=input[id*8*8+48];
w[1]=input[id*8*8+49];
w[2]=input[id*8*8+50];
w[3]=input[id*8*8+51];
w[4]=input[id*8*8+52];
w[5]=input[id*8*8+53];
w[6]=input[id*8*8+54];
w[7]=input[id*8*8+55];
w0.s6=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s6=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s6=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s6=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s6=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s6=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s6=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s6=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s6=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s6=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s6=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s6=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s6=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s6=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);


w[0]=input[id*8*8+56];
w[1]=input[id*8*8+57];
w[2]=input[id*8*8+58];
w[3]=input[id*8*8+59];
w[4]=input[id*8*8+60];
w[5]=input[id*8*8+61];
w[6]=input[id*8*8+62];
w[7]=input[id*8*8+63];
w0.s7=((w[0]&255))|(((w[0]>>8)&255)<<16);
w1.s7=(((w[0]>>16)&255))|(((w[0]>>24)&255)<<16);
w2.s7=((w[1]&255))|(((w[1]>>8)&255)<<16);
w3.s7=(((w[1]>>16)&255))|(((w[1]>>24)&255)<<16);
w4.s7=((w[2]&255))|(((w[2]>>8)&255)<<16);
w5.s7=(((w[2]>>16)&255))|(((w[2]>>24)&255)<<16);
w6.s7=((w[3]&255))|(((w[3]>>8)&255)<<16);
w7.s7=(((w[3]>>16)&255))|(((w[3]>>24)&255)<<16);
w8.s7=((w[4]&255))|(((w[4]>>8)&255)<<16);
w9.s7=(((w[4]>>16)&255))|(((w[4]>>24)&255)<<16);
w10.s7=((w[5]&255))|(((w[5]>>8)&255)<<16);
w11.s7=(((w[5]>>16)&255))|(((w[5]>>24)&255)<<16);
w12.s7=((w[6]&255))|(((w[6]>>8)&255)<<16);
w13.s7=(((w[6]>>16)&255))|(((w[6]>>24)&255)<<16);



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

#define F(x, y, z)(((x) & (y)) | (((~x) & (z))))
#define G(x, y, z)((((x) & (y)) | (z)) & ((x) | (y)))  
#define H(x, y, z)((x) ^ (y) ^ (z))
#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1+x; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = rotate((a), (s)); }


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

ntlmSTEP_ROUND3 (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w8, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3(b, c, d, a, w12, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w13, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w11, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w7, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

id = 0;
#ifdef SINGLE_MODE
if (all((uint8)singlehash.x!=a)) return;
if (all((uint8)singlehash.y!=b)) return;
#else
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s4;b2=b.s4;b3=c.s4;b4=d.s4;
b5=(singlehash.x >> (b.s4&31))&1;
b6=(singlehash.y >> (c.s4&31))&1;
b7=(singlehash.z >> (d.s4&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s5;b2=b.s5;b3=c.s5;b4=d.s5;
b5=(singlehash.x >> (b.s5&31))&1;
b6=(singlehash.y >> (c.s5&31))&1;
b7=(singlehash.z >> (d.s5&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s6;b2=b.s6;b3=c.s6;b4=d.s6;
b5=(singlehash.x >> (b.s6&31))&1;
b6=(singlehash.y >> (c.s6&31))&1;
b7=(singlehash.z >> (d.s6&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s7;b2=b.s7;b3=c.s7;b4=d.s7;
b5=(singlehash.x >> (b.s7&31))&1;
b6=(singlehash.y >> (c.s7&31))&1;
b7=(singlehash.z >> (d.s7&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
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

__kernel  
void ntlm( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  uint4 singlehash)
{

uint4 SIZE;  
uint i,ib,ic,id;  
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14;  
uint4 AC, AD;
uint xl,xr,yl,yr,zl,zr,wl,wr;  
uint w[8];



id=get_global_id(0);
SIZE.s0=size[id*4]; 
SIZE.s1=size[id*4+1]; 
SIZE.s2=size[id*4+2]; 
SIZE.s3=size[id*4+3]; 


w[0]=input[id*8*8];
w[1]=input[id*8*8+1];
w[2]=input[id*8*8+2];
w[3]=input[id*8*8+3];
w[4]=input[id*8*8+4];
w[5]=input[id*8*8+5];
w[6]=input[id*8*8+6];
w[7]=input[id*8*8+7];
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

w[0]=input[id*8*8+8];
w[1]=input[id*8*8+9];
w[2]=input[id*8*8+10];
w[3]=input[id*8*8+11];
w[4]=input[id*8*8+12];
w[5]=input[id*8*8+13];
w[6]=input[id*8*8+14];
w[7]=input[id*8*8+15];
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

w[0]=input[id*8*8+16];
w[1]=input[id*8*8+17];
w[2]=input[id*8*8+18];
w[3]=input[id*8*8+19];
w[4]=input[id*8*8+20];
w[5]=input[id*8*8+21];
w[6]=input[id*8*8+22];
w[7]=input[id*8*8+23];
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

w[0]=input[id*8*8+24];
w[1]=input[id*8*8+25];
w[2]=input[id*8*8+26];
w[3]=input[id*8*8+27];
w[4]=input[id*8*8+28];
w[5]=input[id*8*8+29];
w[6]=input[id*8*8+30];
w[7]=input[id*8*8+31];
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

#define F(x, y, z)(((x) & (y)) | (((~x) & (z))))
#define G(x, y, z)((((x) & (y)) | (z)) & ((x) | (y)))  
#define H(x, y, z)((x) ^ (y) ^ (z))
#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1+x; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = rotate((a), (s)); }


AC = (uint4)0x5a827999; 
AD = (uint4)0x6ed9eba1; 
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

ntlmSTEP_ROUND3 (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w8, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3(b, c, d, a, w12, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w13, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w11, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w7, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

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
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && (
(bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0)*4)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*4)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*4)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}  


#endif
