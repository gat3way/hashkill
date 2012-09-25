#ifdef GCN

#define getglobalid(a) (mad24(get_group_id(0), 64U, get_local_id(0)))


void mscash_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains,  __global uint *found,  uint4 singlehash, uint k, uint16 salt) 
{  
uint SIZE;  
uint ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13, w14;
uint AC, AD;
uint yl,yr,zl,zr,wl,wr;
uint xx0,xx1,xx2,xx3;

SIZE = (uint)(size<<1); 

w2 = (input.y&255)|(((input.y>>8)&255)<<16);
w3 = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
w4 = (input.z&255)|(((input.z>>8)&255)<<16);
w5 = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
w6 = (input.w&255)|(((input.w>>8)&255)<<16);
w7 = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);


xx0=k;
xx1=(uint)input.y;
xx2=(uint)input.z;
xx3=(uint)input.w;

w0 = (k&255)|(((k>>8)&255)<<16);
w1 = ((k>>16)&255)|(((k>>24)&255)<<16);
w14=SIZE;  


if (size==(4<<3)) w2 |= 0x80;
else if (size==(5<<3)) w2 |= (0x80<<16);
else if (size==(6<<3)) w3 |= (0x80);
else if (size==(7<<3)) w3 |= (0x80<<16);
else if (size==(8<<3)) w4 |= (0x80);
else if (size==(9<<3)) w4 |= (0x80<<16);
else if (size==(10<<3)) w5 |= (0x80);
else if (size==(11<<3)) w5 |= (0x80<<16);
else if (size==(12<<3)) w6 |= (0x80);
else if (size==(13<<3)) w6 |= (0x80<<16);
else if (size==(14<<3)) w7 |= (0x80);
else if (size==(15<<3)) w7 |= (0x80<<16);



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


AC = (uint)0x5a827999; 
AD = (uint)0x6ed9eba1; 

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



a=Ca;b=Cb;c=Cc;d=Cd;

mscashSTEP_ROUND1 (a, b, c, d, w0, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w1, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w2, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w3, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w4, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w5, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w6, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w7, S14); 
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1_NULL (c, d, a, b, S13);
mscashSTEP_ROUND1_NULL (b, c, d, a, S14);
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1 (c, d, a, b, w14, S13); 
mscashSTEP_ROUND1_NULL (b, c, d, a, S14); 


mscashSTEP_ROUND2 (a, b, c, d, w0, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w4, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w1, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w5, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w2, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w6, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2 (b, c, d, a, w14, S24);
mscashSTEP_ROUND2 (a, b, c, d, w3, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w7, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);

mscashSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
mscashSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
mscashSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
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


AC = (uint)0x5a827999; 
AD = (uint)0x6ed9eba1; 
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
if (((uint)singlehash.x!=a)) return;
mscashSTEP_ROUND3_ODD(d, a, b, c,w11, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
if (((uint)singlehash.y!=b)) return;
a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;


uint res = atomic_inc(found);
hashes[res] = (uint4)(a,b,c,d);
plains[res] = (uint4)(xx0,xx1,xx2,xx3);


}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
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
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
mscash_long1(hashes,input, size, plains,  found, singlehash,k,chbase4);


input=(uint4)(chbase1.s8,chbase1.s9,chbase1.sA,chbase1.sB);
singlehash=(uint4)(chbase2.s8,chbase2.s9,chbase2.sA,chbase2.sB);
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase5);


input=(uint4)(chbase1.sC,chbase1.sD,chbase1.sE,chbase1.sF);
singlehash=(uint4)(chbase2.sC,chbase2.sD,chbase2.sE,chbase2.sF);
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase6);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
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
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);



input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase4);

}



#endif

#if (!OLD_ATI && !GCN)

void mscash_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *found,  uint4 singlehash,uint8 k, uint16 salt) 
{
uint8 SIZE;  
uint ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13, w14;
uint8 AC, AD;
uint yl,yr,zl,zr,wl,wr;
uint8 xx0,xx1,xx2,xx3;

SIZE = (uint8)(size<<1); 

w2 = (input.y&255)|(((input.y>>8)&255)<<16);
w3 = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
w4 = (input.z&255)|(((input.z>>8)&255)<<16);
w5 = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
w6 = (input.w&255)|(((input.w>>8)&255)<<16);
w7 = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);


xx0=k;
xx1=(uint8)input.y;
xx2=(uint8)input.z;
xx3=(uint8)input.w;

w0 = (k&255)|(((k>>8)&255)<<16);
w1 = ((k>>16)&255)|(((k>>24)&255)<<16);
w14=SIZE;  


if (size==(4<<3)) w2 |= 0x80;
else if (size==(5<<3)) w2 |= (0x80<<16);
else if (size==(6<<3)) w3 |= (0x80);
else if (size==(7<<3)) w3 |= (0x80<<16);
else if (size==(8<<3)) w4 |= (0x80);
else if (size==(9<<3)) w4 |= (0x80<<16);
else if (size==(10<<3)) w5 |= (0x80);
else if (size==(11<<3)) w5 |= (0x80<<16);
else if (size==(12<<3)) w6 |= (0x80);
else if (size==(13<<3)) w6 |= (0x80<<16);
else if (size==(14<<3)) w7 |= (0x80);
else if (size==(15<<3)) w7 |= (0x80<<16);



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


AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 

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



a=Ca;b=Cb;c=Cc;d=Cd;

mscashSTEP_ROUND1 (a, b, c, d, w0, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w1, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w2, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w3, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w4, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w5, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w6, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w7, S14); 
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1_NULL (c, d, a, b, S13);
mscashSTEP_ROUND1_NULL (b, c, d, a, S14);
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1 (c, d, a, b, w14, S13); 
mscashSTEP_ROUND1_NULL (b, c, d, a, S14); 


mscashSTEP_ROUND2 (a, b, c, d, w0, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w4, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w1, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w5, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w2, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w6, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2 (b, c, d, a, w14, S24);
mscashSTEP_ROUND2 (a, b, c, d, w3, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w7, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);

mscashSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
mscashSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
mscashSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
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


AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 
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
if (all((uint8)singlehash.x!=a)) return;
mscashSTEP_ROUND3_ODD(d, a, b, c,w11, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
if (all((uint8)singlehash.y!=b)) return;
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

plains[res*8] = (uint4)(xx0.s0,xx1.s0,xx2.s0,xx3.s0);
plains[res*8+1] = (uint4)(xx0.s1,xx1.s1,xx2.s1,xx3.s1);
plains[res*8+2] = (uint4)(xx0.s2,xx1.s2,xx2.s2,xx3.s2);
plains[res*8+3] = (uint4)(xx0.s3,xx1.s3,xx2.s3,xx3.s3);
plains[res*8+4] = (uint4)(xx0.s4,xx1.s4,xx2.s4,xx3.s4);
plains[res*8+5] = (uint4)(xx0.s5,xx1.s5,xx2.s5,xx3.s5);
plains[res*8+6] = (uint4)(xx0.s6,xx1.s6,xx2.s6,xx3.s6);
plains[res*8+7] = (uint4)(xx0.s7,xx1.s7,xx2.s7,xx3.s7);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint8 i;
uint j;
uint8 k;
uint4 input;
uint4 singlehash; 


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
{
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);
}

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
{
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase4);
}

}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint8 i,k;
uint j;
uint4 input;
uint4 singlehash; 

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
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);

}




#endif
#ifdef OLD_ATI

void mscash_long1( __global uint4 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *found,  uint4 singlehash,uint8 k, uint16 salt) 
{
uint8 SIZE;  
uint ib,ic,id;  
uint8 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint8 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13, w14;
uint8 AC, AD;
uint yl,yr,zl,zr,wl,wr;
uint8 xx0,xx1,xx2,xx3;

SIZE = (uint8)(size<<1); 

w2 = (input.y&255)|(((input.y>>8)&255)<<16);
w3 = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
w4 = (input.z&255)|(((input.z>>8)&255)<<16);
w5 = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
w6 = (input.w&255)|(((input.w>>8)&255)<<16);
w7 = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);


xx0=k;
xx1=(uint8)input.y;
xx2=(uint8)input.z;
xx3=(uint8)input.w;

w0 = (k&255)|(((k>>8)&255)<<16);
w1 = ((k>>16)&255)|(((k>>24)&255)<<16);
w14=SIZE;  


if (size==(4<<3)) w2 |= 0x80;
else if (size==(5<<3)) w2 |= (0x80<<16);
else if (size==(6<<3)) w3 |= (0x80);
else if (size==(7<<3)) w3 |= (0x80<<16);
else if (size==(8<<3)) w4 |= (0x80);
else if (size==(9<<3)) w4 |= (0x80<<16);
else if (size==(10<<3)) w5 |= (0x80);
else if (size==(11<<3)) w5 |= (0x80<<16);
else if (size==(12<<3)) w6 |= (0x80);
else if (size==(13<<3)) w6 |= (0x80<<16);
else if (size==(14<<3)) w7 |= (0x80);
else if (size==(15<<3)) w7 |= (0x80<<16);



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


AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 

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



a=Ca;b=Cb;c=Cc;d=Cd;

mscashSTEP_ROUND1 (a, b, c, d, w0, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w1, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w2, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w3, S14); 
mscashSTEP_ROUND1 (a, b, c, d, w4, S11); 
mscashSTEP_ROUND1 (d, a, b, c, w5, S12); 
mscashSTEP_ROUND1 (c, d, a, b, w6, S13); 
mscashSTEP_ROUND1 (b, c, d, a, w7, S14); 
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1_NULL (c, d, a, b, S13);
mscashSTEP_ROUND1_NULL (b, c, d, a, S14);
mscashSTEP_ROUND1_NULL (a, b, c, d, S11);
mscashSTEP_ROUND1_NULL (d, a, b, c, S12);
mscashSTEP_ROUND1 (c, d, a, b, w14, S13); 
mscashSTEP_ROUND1_NULL (b, c, d, a, S14); 


mscashSTEP_ROUND2 (a, b, c, d, w0, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w4, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w1, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w5, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);
mscashSTEP_ROUND2 (a, b, c, d, w2, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w6, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2 (b, c, d, a, w14, S24);
mscashSTEP_ROUND2 (a, b, c, d, w3, S21); 
mscashSTEP_ROUND2 (d, a, b, c, w7, S22); 
mscashSTEP_ROUND2_NULL (c, d, a, b, S23);
mscashSTEP_ROUND2_NULL (b, c, d, a, S24);

mscashSTEP_ROUND3_EVEN (a, b, c, d, w0, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w4, S33); 
mscashSTEP_ROUND3_NULL_ODD(b, c, d, a, S34); 
mscashSTEP_ROUND3_EVEN (a, b, c, d, w2, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w6, S33); 
mscashSTEP_ROUND3_ODD (b, c, d, a, w14, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w1, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w5, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
mscashSTEP_ROUND3_EVEN (a, b, c, d, w3, S31); 
mscashSTEP_ROUND3_NULL_ODD(d, a, b, c, S32); 
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


AC = (uint8)0x5a827999; 
AD = (uint8)0x6ed9eba1; 
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
if (all((uint8)singlehash.x!=a)) return;
mscashSTEP_ROUND3_ODD(d, a, b, c,w11, S32); 
mscashSTEP_ROUND3_EVEN (c, d, a, b, w7, S33); 
mscashSTEP_ROUND3_NULL_ODD (b, c, d, a, S34);
if (all((uint8)singlehash.y!=b)) return;
a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;



uint res = found[0];
found[0]++;
hashes[res*8] = (uint4)(a.s0,b.s0,c.s0,d.s0);
hashes[res*8+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
hashes[res*8+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
hashes[res*8+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
hashes[res*8+4] = (uint4)(a.s4,b.s4,c.s4,d.s4);
hashes[res*8+5] = (uint4)(a.s5,b.s5,c.s5,d.s5);
hashes[res*8+6] = (uint4)(a.s6,b.s6,c.s6,d.s6);
hashes[res*8+7] = (uint4)(a.s7,b.s7,c.s7,d.s7);

plains[res*8] = (uint4)(xx0.s0,xx1.s0,xx2.s0,xx3.s0);
plains[res*8+1] = (uint4)(xx0.s1,xx1.s1,xx2.s1,xx3.s1);
plains[res*8+2] = (uint4)(xx0.s2,xx1.s2,xx2.s2,xx3.s2);
plains[res*8+3] = (uint4)(xx0.s3,xx1.s3,xx2.s3,xx3.s3);
plains[res*8+4] = (uint4)(xx0.s4,xx1.s4,xx2.s4,xx3.s4);
plains[res*8+5] = (uint4)(xx0.s5,xx1.s5,xx2.s5,xx3.s5);
plains[res*8+6] = (uint4)(xx0.s6,xx1.s6,xx2.s6,xx3.s6);
plains[res*8+7] = (uint4)(xx0.s7,xx1.s7,xx2.s7,xx3.s7);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_double( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint8 i;
uint j;
uint8 k;
uint4 input;
uint4 singlehash; 


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
{
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);
}

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
{
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase4);
}

}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
mscash_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint8 i,k;
uint j;
uint4 input;
uint4 singlehash; 

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
mscash_long1(hashes,input, size, plains, found, singlehash,k,chbase3);

}

#endif
