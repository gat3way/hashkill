#define ROTATE(a,b) ((a) << (b)) + ((a) >> (32-(b)))


#ifdef SM21

void ntlm_short1( __global uint4 *dst,const uint4 input,const uint size, const uint4 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, uint i, const uint4 singlehash, uint factor) 
{  

uint4 SIZE;  
uint ib,ic,id,ie;
uint4 a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint4 w0, w1, w2, w3, w4, w5, w6, w7, w8, w9 ,w10, w11, w14; 
uint4 AC, AD;
uint xl,xr,yl,yr,zl,zr,wl,wr;  


ic = (size+4)*2;
id = ic*8; 
SIZE = (uint4)id; 


xl = (input.x&255)|(((input.x>>8)&255)<<16);
xr = ((input.x>>16)&255)|(((input.x>>24)&255)<<16);
yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
wl = (input.w&255)|(((input.w>>8)&255)<<16);
wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);

w0 = (uint4)xl; 
w1 = (uint4)xr; 
w2 = (uint4)yl; 
w3 = (uint4)yr; 
w4 = (uint4)zl; 
w5 = (uint4)zr; 
w6 = (uint4)wl; 
w7 = (uint4)wr; 
w8=w9=w10=w11=(uint4)0;

ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255);  


if (size==1) {w0 = chbase|(ib<<16);w1=(ic)|(id<<16);w2=ie|(0x80<<16);} 
else if (size==2) {w0 = (w0)|(chbase<<16);w1=(ib)|(ic<<16);w2=id|(ie<<16);w3=0x80;} 
else if (size==3) {w1 = chbase|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==4) {w1 = (w1)|(chbase<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==5) {w2 = chbase|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==6) {w2 = (w1)|(chbase<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==7) {w3 = chbase|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==8) {w3 = (w1)|(chbase<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==9) {w4 = chbase|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==10) {w4 = (w1)|(chbase<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==11) {w5 = chbase|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 


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
#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1+x; (a) = ROTATE((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1; (a) = ROTATE((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = ROTATE((a),(s));}
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = ROTATE((a),(s));}
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = ROTATE((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = ROTATE((a), (s)); }


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
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 

ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w8, S23); 
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w9, S23); 
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
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
ntlmSTEP_ROUND3_NULL(b, c, d, a, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
#ifdef SINGLE_MODE
id=singlehash.x - Ca;
if (all((uint4)id != a)) return;
#endif
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
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s1;b2=b.s1;b3=c.s1;b4=d.s1;
b5=(singlehash.x >> (b.s1&31))&1;
b6=(singlehash.y >> (c.s1&31))&1;
b7=(singlehash.z >> (d.s1&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s2;b2=b.s2;b3=c.s2;b4=d.s2;
b5=(singlehash.x >> (b.s2&31))&1;
b6=(singlehash.y >> (c.s2&31))&1;
b7=(singlehash.z >> (d.s2&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
b1=a.s3;b2=b.s3;b3=c.s3;b4=d.s3;
b5=(singlehash.x >> (b.s3&31))&1;
b6=(singlehash.y >> (c.s3&31))&1;
b7=(singlehash.z >> (d.s3&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

#ifdef DOUBLE
dst[(get_global_id(0)<<3)+factor] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<3)+1+factor] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<3)+2+factor] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<3)+3+factor] = (uint4)(a.s3,b.s3,c.s3,d.s3);
#else
dst[(get_global_id(0)<<2)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)<<2)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)<<2)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)<<2)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);
#endif
}  

__kernel 
__attribute__((reqd_work_group_size(128, 1, 1)))
void ntlm_short( __global uint4 *dst,const uint4 input,const uint size, const uint16 chbase, __global uint *found_ind, __global const uint *bitmaps, __global uint *found, __global const uint *table, const uint4 singlehash) 
{
uint i;
uint4 chbase1;
i = table[get_global_id(0)];
chbase1 = (uint4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);
ntlm_short1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,0);
#ifdef DOUBLE
chbase1 = (uint4)(chbase.s4,chbase.s5,chbase.s6,chbase.s7);
ntlm_short1(dst,input, size, chbase1, found_ind, bitmaps, found, i, singlehash,4);
#endif

}


#else


__kernel __attribute__((reqd_work_group_size(128, 1, 1)))
void ntlm_short( __global uint4 *dst,const uint4 input,const uint size, const uint16 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
{  

uint SIZE,chbase1;  
uint i,ib,ic,id,ie;
uint a,b,c,d, tmp1, tmp2; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint w0, w1, w2, w3, w4, w5, w6, w7, w8, w9 ,w10, w11, w14; 
uint AC, AD;
uint xl,xr,yl,yr,zl,zr,wl,wr;  


ic = (size+4)*2;
id = ic*8; 
SIZE = (uint)id; 
chbase1=(uint)(chbase.s0);

xl = (input.x&255)|(((input.x>>8)&255)<<16);
xr = ((input.x>>16)&255)|(((input.x>>24)&255)<<16);
yl = (input.y&255)|(((input.y>>8)&255)<<16);
yr = ((input.y>>16)&255)|(((input.y>>24)&255)<<16);
zl = (input.z&255)|(((input.z>>8)&255)<<16);
zr = ((input.z>>16)&255)|(((input.z>>24)&255)<<16);
wl = (input.w&255)|(((input.w>>8)&255)<<16);
wr = ((input.w>>16)&255)|(((input.w>>24)&255)<<16);

w0 = (uint)xl; 
w1 = (uint)xr; 
w2 = (uint)yl; 
w3 = (uint)yr; 
w4 = (uint)zl; 
w5 = (uint)zr; 
w6 = (uint)wl; 
w7 = (uint)wr; 
w8=w9=w10=w11=(uint)0;

i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  
ie = (uint)((i>>24)&255);  


if (size==1) {w0 = chbase1|(ib<<16);w1=(ic)|(id<<16);w2=ie|(0x80<<16);} 
else if (size==2) {w0 = (w0)|(chbase1<<16);w1=(ib)|(ic<<16);w2=id|(ie<<16);w3=0x80;} 
else if (size==3) {w1 = chbase1|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==4) {w1 = (w1)|(chbase1<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==5) {w2 = chbase1|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==6) {w2 = (w1)|(chbase1<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==7) {w3 = chbase1|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==8) {w3 = (w1)|(chbase1<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==9) {w4 = chbase1|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 
else if (size==10) {w4 = (w1)|(chbase1<<16);w2=(ib)|(ic<<16);w3=id|(ie<<16);w4=0x80;} 
else if (size==11) {w5 = chbase1|(ib<<16);w2=ic|(id<<16);w3=ie|(0x80<<16);} 


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
#define ntlmSTEP_ROUND1(a,b,c,d,x,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1+x; (a) = ROTATE((a), (s)); }
#define ntlmSTEP_ROUND1_NULL(a,b,c,d,s) { tmp1 = (((c) ^ (d))&(b))^(d); (a) = (a)+tmp1; (a) = ROTATE((a), (s)); }
#define ntlmSTEP_ROUND2(a,b,c,d,x,s) { tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+x+AC; (a) = ROTATE((a),(s));}
#define ntlmSTEP_ROUND2_NULL(a,b,c,d,s) {tmp1 = (b) & (c);tmp1 = tmp1 | (d);tmp2 = (b) | (c);tmp1 = tmp1 & tmp2;(a) = (a)+ tmp1+AC; (a) = ROTATE((a),(s));}
#define ntlmSTEP_ROUND3(a,b,c,d,x,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + x + AD; (a) = ROTATE((a), (s)); }  
#define ntlmSTEP_ROUND3_NULL(a,b,c,d,s) {tmp1 = (b) ^ (c);tmp1 = tmp1 ^ (d);(a) = (a) + tmp1 + AD; (a) = ROTATE((a), (s)); }


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
ntlmSTEP_ROUND1_NULL (a, b, c, d, S11);
ntlmSTEP_ROUND1_NULL (d, a, b, c, S12);
ntlmSTEP_ROUND1 (c, d, a, b, w14, S13); 
ntlmSTEP_ROUND1_NULL (b, c, d, a, S14); 

ntlmSTEP_ROUND2 (a, b, c, d, w0, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w4, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w8, S23); 
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
ntlmSTEP_ROUND2 (a, b, c, d, w1, S21); 
ntlmSTEP_ROUND2 (d, a, b, c, w5, S22); 
ntlmSTEP_ROUND2 (c, d, a, b, w9, S23); 
ntlmSTEP_ROUND2_NULL (b, c, d, a, S24);
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
ntlmSTEP_ROUND3_NULL(b, c, d, a, S34); 
ntlmSTEP_ROUND3 (a, b, c, d, w2, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w10, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w6, S33); 
ntlmSTEP_ROUND3 (b, c, d, a, w14, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w1, S31); 
ntlmSTEP_ROUND3 (d, a, b, c, w9, S32); 
ntlmSTEP_ROUND3 (c, d, a, b, w5, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);
ntlmSTEP_ROUND3 (a, b, c, d, w3, S31); 
#ifdef SINGLE_MODE
id=singlehash.x - Ca;
if (((uint)id != a)) return;
#endif
ntlmSTEP_ROUND3 (d, a, b, c, w11, S32);
ntlmSTEP_ROUND3 (c, d, a, b, w7, S33); 
ntlmSTEP_ROUND3_NULL (b, c, d, a, S34);

a=a+Ca;b=b+Cb;c=c+Cc;d=d+Cd;

id = 0;

#ifdef SINGLE_MODE
if ((singlehash.x==a)&&(singlehash.y==b)&&(singlehash.z==c)&&(singlehash.w==d)) id = 1; 
if (id==0) return;

#else
id = 0;

b1=a;b2=b;b3=c;b4=d;
b5=(singlehash.x >> (b&31))&1;
b6=(singlehash.y >> (c&31))&1;
b7=(singlehash.z >> (d&31))&1;
if ((b7) && (b5) && (b6)) if ( ((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1) ) id=1;
if (id==0) return;
#endif

if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0))] = (uint4)(a,b,c,d);

}

#endif
