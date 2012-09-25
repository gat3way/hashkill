#ifndef SM21

void ntlm_markov1( __global uint *dst,const uint4 input,const uint size, const uint chbase, __global uint *found_ind, __global const uint *bitmaps, __global uint *found, const uint i, const uint4 singlehash, uint factor) 
{  

uint SIZE;  
uint ib,ic,id;  
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint AC, AD;
uint yl,yr,zl,zr,wl,wr;



ic = (size+3)<<1;
id = ic<<3; 
SIZE = (uint)id; 


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


ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

w0 = ib|(ic<<16);  
w1 = (id)|(chbase<<16);
w14=SIZE;  

if (size==1) w2 |= 0x80;
else if (size==2) w2 |= (0x80<<16);
else if (size==3) w3 |= (0x80);
else if (size==4) w3 |= (0x80<<16);
else if (size==5) w4 |= (0x80);
else if (size==6) w4 |= (0x80<<16);
else if (size==7) w4 |= (0x80);
else if (size==8) w4 |= (0x80<<16);



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

#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1+x; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1; (a) = rotate((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = rotate((a),(s));}
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = rotate((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = rotate((a), (s)); }


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


ntlmSTEP_ROUND3 (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_NULL(b, c, d, a, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
#ifdef SINGLE_MODE
id=singlehash.x;
if ((a+w1)!=id) return;
#endif
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
#ifdef SINGLE_MODE
id = 0;
if ((singlehash.y==b)&&(singlehash.z==c)) id = 1; 
if (id==0) return;
#endif
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w7, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;



#ifndef SINGLE_MODE
id = 0;
b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

#ifdef DOUBLE
dst[(get_global_id(0)*16)+factor] = a;
dst[(get_global_id(0)*16)+1+factor] = b;
dst[(get_global_id(0)*16)+2+factor] = c;
dst[(get_global_id(0)*16)+3+factor] = d;
#else
dst[(get_global_id(0)*4)] = a;
dst[(get_global_id(0)*4)+1] = b;
dst[(get_global_id(0)*4)+2] = c;
dst[(get_global_id(0)*4)+3] = d;
#endif

}



__kernel  void ntlm_markov( __global uint *dst,const uint4 input,const uint size, const uint16 chbase, global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
{
uint i;
i = table[get_global_id(0)];

ntlm_markov1(dst, input, size, chbase.s0, found_ind, bitmaps, found, i, singlehash, 0);
#ifdef DOUBLE
ntlm_markov1(dst, input, size, chbase.s1, found_ind, bitmaps, found, i, singlehash, 4);
ntlm_markov1(dst, input, size, chbase.s2, found_ind, bitmaps, found, i, singlehash, 8);
ntlm_markov1(dst, input, size, chbase.s3, found_ind, bitmaps, found, i, singlehash, 12);
#endif
}


#else


__kernel  void ntlm_markov( __global uint4 *dst,const uint4 input,const uint size, const uint16 chbase, __global uint *found_ind, __global const uint *bitmaps, __global uint *found, __global const uint *table, const uint4 singlehash) 
{  

uint4 SIZE;  
uint i,ib,ic,id;  
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 w0, w1, w2, w3, w4, w5, w6, w7, w14;
uint4 AC, AD, chbase1;
uint4 yl,yr,zl,zr,wl,wr;



ic = (size+3)<<1;
id = ic<<3; 
SIZE = (uint4)id; 


yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
//wl = (input.w&255)|(((input.w>>8)&255)<<16);
//wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);


w2 = (uint4)yl; 
w3 = (uint4)yr; 
w4 = (uint4)zl; 
w5 = (uint4)zr; 
w6 = (uint4)wl; 
w7 = (uint4)wr; 
w6=w7=(uint4)0;

i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

chbase1=(uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);

w0 = ib|(ic<<16);  
w1 = (id)|(chbase1<<16);
w14=SIZE;  

if (size==1) w2 |= 0x80;
else if (size==2) w2 |= (0x80<<16);
else if (size==3) w3 |= (0x80);
else if (size==4) w3 |= (0x80<<16);
else if (size==5) w4 |= (0x80);
else if (size==6) w4 |= (0x80<<16);
else if (size==7) w4 |= (0x80);
else if (size==8) w4 |= (0x80<<16);



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

#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))
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


ntlmSTEP_ROUND3 (a, b, c, d, w0, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w4, S33); 
ntlmSTEP_ROUND3_NULL(b, c, d, a, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
#ifdef SINGLE_MODE
id=singlehash.x;
if (all((a+w1)!=(uint4)id)) return;
#endif
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
#ifdef SINGLE_MODE
id = 1;
if (all(b!=(uint4)singlehash.y)) return;
if (all(c!=(uint4)singlehash.z)) return;
#endif
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
ntlmSTEP_ROUND3_NULL(d, a, b, c, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w7, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;



#ifndef SINGLE_MODE
id = 0;
b1=a.s0;b2=b.s0;b3=c.s0;b4=d.s0;
b5=(singlehash.x >> (b.s0&31))&1;
b6=(singlehash.y >> (c.s0&31))&1;
b7=(singlehash.z >> (d.s0&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;


#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)*4)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*4)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*4)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}  


#endif