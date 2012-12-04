#ifdef GCN

#define getglobalid(a) (mad24(get_group_id(0), 64U, get_local_id(0)))


void ntlm_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash, uint x0) 
{  
uint SIZE;  
uint a,b,c,d, tmp1, tmp2; 
uint w0, w1, w2, w3, w4, w5, w6, w7, w14,x1,x2,x3;
uint AC, AD;
uint yl,yr,zl,zr,wl,wr,id;


SIZE = (uint)size; 
x1=input.y;
x2=input.z;
x3=input.w;

yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
wl = (input.w&255)|(((input.w>>8)&255)<<16);
wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);

w2 = (uint)yl; 
w3 = (uint)yr; 
w4 = (uint)zl; 
w5 = (uint)zr; 
w6 = (uint)wl; 
w7 = (uint)wr; 

w0 = (x0&255)|(((x0>>8)&255)<<16);
w1 = ((x0>>16)&255)|(((x0>>24)&255)<<16);
w14=SIZE;  



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
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1_NULL (c, d, a, b, S13);
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14);
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 


ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w2, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w6, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2 (b, c, d, a, w14, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w3, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w7, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);


ntlmSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
#ifdef SINGLE_MODE
id=singlehash.x;
tmp1=a+w1;
if (((uint)id != tmp1)) return; 
#endif
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b,w6, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
#ifdef SINGLE_MODE
if (((uint)singlehash.y!=b)) return;
if (((uint)singlehash.z!=c)) return;
#endif
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
id=1;
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;




uint res = atomic_inc(found);
hashes[res] = (uint4)(a,b,c,d);
plains[res] = (uint4)(x0,x1,x2,x3);

}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);




input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s0,chbase3.s1,chbase3.s2,chbase3.s3);
singlehash=(uint4)(chbase4.s0,chbase4.s1,chbase4.s2,chbase4.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s4,chbase3.s5,chbase3.s6,chbase3.s7);
singlehash=(uint4)(chbase4.s4,chbase4.s5,chbase4.s6,chbase4.s7);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.s8,chbase3.s9,chbase3.sA,chbase3.sB);
singlehash=(uint4)(chbase4.s8,chbase4.s9,chbase4.sA,chbase4.sB);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase3.sC,chbase3.sD,chbase3.sE,chbase3.sF);
singlehash=(uint4)(chbase4.sC,chbase4.sD,chbase4.sE,chbase4.sF);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}



#endif

#if (!OLD_ATI && !GCN)
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#define getglobalid(a) (mad24(get_group_id(0), 64U, get_local_id(0)))

void ntlm_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash,uint8 x0) 
{

uint8 SIZE;  
uint8 a,b,c,d, tmp1, tmp2; 
uint8 w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint8 AC, AD;
uint yl,yr,zl,zr,wl,wr,id;


SIZE = (uint8)size; 


yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
wl = (input.w&255)|(((input.w>>8)&255)<<16);
wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);

w2 = (uint8)yl; 
w3 = (uint8)yr; 
w4 = (uint8)zl; 
w5 = (uint8)zr; 
w6 = (uint8)wl; 
w7 = (uint8)wr; 

w0 = (x0&255)|(((x0>>8)&255)<<16);
w1 = ((x0>>16)&255)|(((x0>>24)&255)<<16);
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
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1_NULL (c, d, a, b, S13);
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14);
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 


ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w2, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w6, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2 (b, c, d, a, w14, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w3, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w7, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);


ntlmSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
#ifdef SINGLE_MODE
id=singlehash.x;
tmp1=a+w1;
if (all((uint8)id != tmp1)) return; 
#endif
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b,w6, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
#ifdef SINGLE_MODE
if (all((uint8)singlehash.y!=b)) return;
if (all((uint8)singlehash.z!=c)) return;
#endif
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
id=1;
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s4;b2=b.s4;b3=c.s4;b4=d.s4;
b5=(singlehash.x >> (b.s4&31))&1;
b6=(singlehash.y >> (c.s4&31))&1;
b7=(singlehash.z >> (d.s4&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s5;b2=b.s5;b3=c.s5;b4=d.s5;
b5=(singlehash.x >> (b.s5&31))&1;
b6=(singlehash.y >> (c.s5&31))&1;
b7=(singlehash.z >> (d.s5&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s6;b2=b.s6;b3=c.s6;b4=d.s6;
b5=(singlehash.x >> (b.s6&31))&1;
b6=(singlehash.y >> (c.s6&31))&1;
b7=(singlehash.z >> (d.s6&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s7;b2=b.s7;b3=c.s7;b4=d.s7;
b5=(singlehash.x >> (b.s7&31))&1;
b6=(singlehash.y >> (c.s7&31))&1;
b7=(singlehash.z >> (d.s7&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;



uint res = atomic_inc(found);
hashes[res*8] = (uint4)(a.s0,b.s0,c.s0,d.s0);
hashes[res*8+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
hashes[res*8+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
hashes[res*8+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
hashes[res*8+4] = (uint4)(a.s4,b.s4,c.s4,d.s4);
hashes[res*8+5] = (uint4)(a.s5,b.s5,c.s5,d.s5);
hashes[res*8+6] = (uint4)(a.s6,b.s6,c.s6,d.s6);
hashes[res*8+7] = (uint4)(a.s7,b.s7,c.s7,d.s7);

uint8 x1,x2,x3;
x1=(uint8)input.y;
x2=(uint8)input.z;
x3=(uint8)input.w;
plains[res*8] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*8+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*8+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*8+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
plains[res*8+4] = (uint4)(x0.s4,x1.s4,x2.s4,x3.s4);
plains[res*8+5] = (uint4)(x0.s5,x1.s5,x2.s5,x3.s5);
plains[res*8+6] = (uint4)(x0.s6,x1.s6,x2.s6,x3.s6);
plains[res*8+7] = (uint4)(x0.s7,x1.s7,x2.s7,x3.s7);
}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint8 i;
uint j;
uint8 k;
uint8 c0,x0;
uint8 d0,d1,d2;
uint8 t1,t2,t3;
uint8 x1,SIZE;
uint8 c1,c2,x2;
uint8 t4;
uint4 input;
uint4 singlehash; 


SIZE = (uint8)(size); 
i.s0=table[get_global_id(1)*8];
i.s1=table[get_global_id(1)*8+1];
i.s2=table[get_global_id(1)*8+2];
i.s3=table[get_global_id(1)*8+3];
i.s4=table[get_global_id(1)*8+4];
i.s5=table[get_global_id(1)*8+5];
i.s6=table[get_global_id(1)*8+6];
i.s7=table[get_global_id(1)*8+7];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint8 i,k;
uint j;
uint8 c0,x0;
uint8 d0,d1,d2;
uint8 t1,t2,t3;
uint8 x1,SIZE;
uint8 c1,c2,x2;
uint8 t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint8)(size); 
i.s0=table[get_global_id(1)*8];
i.s1=table[get_global_id(1)*8+1];
i.s2=table[get_global_id(1)*8+2];
i.s3=table[get_global_id(1)*8+3];
i.s4=table[get_global_id(1)*8+4];
i.s5=table[get_global_id(1)*8+5];
i.s6=table[get_global_id(1)*8+6];
i.s7=table[get_global_id(1)*8+7];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}




#endif
#ifdef OLD_ATI



void ntlm_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found,  uint4 singlehash,uint4 x0)
{  
uint4 SIZE;  
uint4 a,b,c,d, tmp1, tmp2; 
uint4 w0, w1, w2, w3, w4, w5, w6, w7, w14,x1,x2,x3;
uint4 AC, AD;
uint4 yl,yr,zl,zr,wl,wr;
uint id;


SIZE = (uint4)size; 

x1=input.y;
x2=input.z;
x3=input.w;
yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
wl = (input.w&255)|(((input.w>>8)&255)<<16);
wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);

w2 = (uint4)yl; 
w3 = (uint4)yr; 
w4 = (uint4)zl; 
w5 = (uint4)zr; 
w6 = (uint4)wl; 
w7 = (uint4)wr; 

w0 = (x0&255)|(((x0>>8)&255)<<16);
w1 = ((x0>>16)&255)|(((x0>>24)&255)<<16);
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
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1_NULL (c, d, a, b, S13);
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14);
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 


ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w2, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w6, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2 (b, c, d, a, w14, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w3, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w7, S22); 
ntlmSTEP_ROUND2_NULL (c, d, a, b, S23);
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);


ntlmSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
#ifdef SINGLE_MODE
id=singlehash.x;
tmp1=a+w1;
if (all((uint4)id != tmp1)) return; 
#endif
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b,w6, S33); 
ntlmSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
#ifdef SINGLE_MODE
if (all((uint4)singlehash.y!=b)) return;
if (all((uint4)singlehash.z!=c)) return;
#endif
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
ntlmSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
ntlmSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
#ifndef SINGLE_MODE
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
id=1;
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if (((b7) & (b5) & (b6)) &&  ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*8*65535)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*8*65535)+(b4>>10)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif
ntlmSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;




//uint res = atomic_inc(found);
uint res=found[0];
found[0]++;

hashes[res*4] = (uint4)(a.s0,b.s0,c.s0,d.s0);
hashes[res*4+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
hashes[res*4+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
hashes[res*4+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

plains[res*4] = (uint4)(x0.s0,x1.s0,x2.s0,x3.s0);
plains[res*4+1] = (uint4)(x0.s1,x1.s1,x2.s1,x3.s1);
plains[res*4+2] = (uint4)(x0.s2,x1.s2,x2.s2,x3.s2);
plains[res*4+3] = (uint4)(x0.s3,x1.s3,x2.s3,x3.s3);
}





__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i;
uint j;
uint4 k;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 


SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
ntlm_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *bitmaps, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4) 
{
uint4 i,k;
uint j;
uint4 c0,x0;
uint4 d0,d1,d2;
uint4 t1,t2,t3;
uint4 x1,SIZE;
uint4 c1,c2,x2;
uint4 t4;
uint4 input;
uint4 singlehash; 



SIZE = (uint4)(size); 
i.s0=table[get_global_id(1)*4];
i.s1=table[get_global_id(1)*4+1];
i.s2=table[get_global_id(1)*4+2];
i.s3=table[get_global_id(1)*4+3];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
ntlm_long1(hashes,input, size, plains, bitmaps, found, singlehash,k);
}


#endif
