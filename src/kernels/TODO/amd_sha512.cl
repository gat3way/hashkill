#ifndef OLD_ATI
#pragma OPENCL EXTENSION cl_amd_media_ops : enable
#endif


__kernel 
//__attribute__((reqd_work_group_size(64, 1, 1)))
void sha512( __global ulong4 *dst, ulong4 input, uint size,  ulong4 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table,  uint4 singlehash) 
{  

ulong4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,SIZE;

uint i,ib,ic,id;  
ulong4 A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;

uint4 m= 0x00FF00FF;
uint4 m2= 0xFF00FF00;
#define Sl 8
#define Sr 24

#define H0 0x6a09e667f3bcc908ULL
#define H1 0xbb67ae8584caa73bULL
#define H2 0x3c6ef372fe94f82bULL
#define H3 0xa54ff53a5f1d36f1ULL
#define H4 0x510e527fade682d1ULL
#define H5 0x9b05688c2b3e6c1fULL
#define H6 0x1f83d9abfb41bd6bULL
#define H7 0x5be0cd19137e2179ULL

#define AC1  0x428a2f98d728ae22ULL
#define AC2  0x7137449123ef65cdULL
#define AC3  0xb5c0fbcfec4d3b2fULL
#define AC4  0xe9b5dba58189dbbcULL
#define AC5  0x3956c25bf348b538ULL
#define AC6  0x59f111f1b605d019ULL
#define AC7  0x923f82a4af194f9bULL
#define AC8  0xab1c5ed5da6d8118ULL
#define AC9  0xd807aa98a3030242ULL
#define AC10 0x12835b0145706fbeULL
#define AC11 0x243185be4ee4b28cULL
#define AC12 0x550c7dc3d5ffb4e2ULL
#define AC13 0x72be5d74f27b896fULL
#define AC14 0x80deb1fe3b1696b1ULL
#define AC15 0x9bdc06a725c71235ULL
#define AC16 0xc19bf174cf692694ULL
#define AC17 0xe49b69c19ef14ad2ULL
#define AC18 0xefbe4786384f25e3ULL
#define AC19 0x0fc19dc68b8cd5b5ULL
#define AC20 0x240ca1cc77ac9c65ULL
#define AC21 0x2de92c6f592b0275ULL
#define AC22 0x4a7484aa6ea6e483ULL
#define AC23 0x5cb0a9dcbd41fbd4ULL
#define AC24 0x76f988da831153b5ULL
#define AC25 0x983e5152ee66dfabULL
#define AC26 0xa831c66d2db43210ULL
#define AC27 0xb00327c898fb213fULL
#define AC28 0xbf597fc7beef0ee4ULL
#define AC29 0xc6e00bf33da88fc2ULL
#define AC30 0xd5a79147930aa725ULL
#define AC31 0x06ca6351e003826fULL
#define AC32 0x142929670a0e6e70ULL
#define AC33 0x27b70a8546d22ffcULL
#define AC34 0x2e1b21385c26c926ULL
#define AC35 0x4d2c6dfc5ac42aedULL
#define AC36 0x53380d139d95b3dfULL
#define AC37 0x650a73548baf63deULL
#define AC38 0x766a0abb3c77b2a8ULL
#define AC39 0x81c2c92e47edaee6ULL
#define AC40 0x92722c851482353bULL
#define AC41 0xa2bfe8a14cf10364ULL
#define AC42 0xa81a664bbc423001ULL
#define AC43 0xc24b8b70d0f89791ULL
#define AC44 0xc76c51a30654be30ULL
#define AC45 0xd192e819d6ef5218ULL
#define AC46 0xd69906245565a910ULL
#define AC47 0xf40e35855771202aULL
#define AC48 0x106aa07032bbd1b8ULL
#define AC49 0x19a4c116b8d2d0c8ULL
#define AC50 0x1e376c085141ab53ULL
#define AC51 0x2748774cdf8eeb99ULL
#define AC52 0x34b0bcb5e19b48a8ULL
#define AC53 0x391c0cb3c5c95a63ULL
#define AC54 0x4ed8aa4ae3418acbULL
#define AC55 0x5b9cca4f7763e373ULL
#define AC56 0x682e6ff3d6b2b8a3ULL
#define AC57 0x748f82ee5defb2fcULL
#define AC58 0x78a5636f43172f60ULL
#define AC59 0x84c87814a1f0ab72ULL
#define AC60 0x8cc702081a6439ecULL
#define AC61 0x90befffa23631e28ULL
#define AC62 0xa4506cebde82bde9ULL
#define AC63 0xbef9a3f7b2c67915ULL
#define AC64 0xc67178f2e372532bULL
#define AC65 0xca273eceea26619cULL
#define AC66 0xd186b8c721c0c207ULL
#define AC67 0xeada7dd6cde0eb1eULL
#define AC68 0xf57d4f7fee6ed178ULL
#define AC69 0x06f067aa72176fbaULL
#define AC70 0x0a637dc5a2c898a6ULL
#define AC71 0x113f9804bef90daeULL
#define AC72 0x1b710b35131c471bULL
#define AC73 0x28db77f523047d84ULL
#define AC74 0x32caab7b40c72493ULL
#define AC75 0x3c9ebe0a15c9bebcULL
#define AC76 0x431d67c49c100d4cULL
#define AC77 0x4cc5d4becb3e42b6ULL
#define AC78 0x597f299cfc657e2aULL
#define AC79 0x5fcb6fab3ad6faecULL
#define AC80 0x6c44198c4a475817ULL



ulong4 chbase1=(ulong4)(chbase.s0,chbase.s1,chbase.s2,chbase.s3);


ic = size+3;
id = ic*8; 
SIZE = (ulong4)id; 


w0 = (ulong4)input.x;
w1 = (ulong4)input.y;


i = table[get_global_id(0)];
ib = (uint)i&255;  
ic = (uint)((i>>8)&255);
id = (uint)((i>>16)&255);  

if (size==1) {w0=chbase1|(0x80<<8);}  

w2=(ulong4)0;
w3=(ulong4)0;
w4=(ulong4)0;
w5=(ulong4)0;
w6=(ulong4)0;
w7=(ulong4)0;
w8=(ulong4)0;
w9=(ulong4)0;
w10=(ulong4)0;  
w11=(ulong4)0;  
w12=(ulong4)0;  
w13=(ulong4)0;  
w14=(ulong4)0;  
w16=(ulong4)0;  


#define Endian_Reverse64(a) { (a) = (a & 0x00000000000000FFUL) << 56 | (a & 0x000000000000FF00UL) << 40 | \
        		      (a & 0x0000000000FF0000UL) << 24 | (a & 0x00000000FF000000UL) << 8 | \
                	      (a & 0x000000FF00000000UL) >> 8 | (a & 0x0000FF0000000000UL) >> 24 | \
                    	      (a & 0x00FF000000000000UL) >> 40 | (a & 0xFF00000000000000UL) >> 56; }


A=(ulong4)H0;
B=(ulong4)H1;
C=(ulong4)H2;
D=(ulong4)H3;
E=(ulong4)H4;
F=(ulong4)H5;
G=(ulong4)H6;
H=(ulong4)H7;


#define ROTATE(b,x)	(((x) >> (b)) | ((x) << (64 - (b))))
#define R(b,x) 		((x) >> (b))
#define Ch(x,y,z)	(((x) & (y)) ^ ((~(x)) & (z)))
#define Maj(x,y,z)	(((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define Sigma0_512(x)	(ROTATE(28, (x)) ^ ROTATE(34, (x)) ^ ROTATE(39, (x)))
#define Sigma1_512(x)	(ROTATE(14, (x)) ^ ROTATE(18, (x)) ^ ROTATE(41, (x)))
#define sigma0_512(x)	(ROTATE( 1, (x)) ^ ROTATE( 8, (x)) ^ R( 7,   (x)))
#define sigma1_512(x)	(ROTATE(19, (x)) ^ ROTATE(61, (x)) ^ R( 6,   (x)))


#define ROUND512_0_TO_15(a,b,c,d,e,f,g,h,AC,x) T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC + x; \
	            				(d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c))

#define ROUND512_0_TO_15_NULL(a,b,c,d,e,f,g,h,AC) T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC; \
	            				(d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c))


#define ROUND512(a,b,c,d,e,f,g,h,AC,x)  T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC + x;\
		                	(d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c)); 



Endian_Reverse64(w0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
Endian_Reverse64(w1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
ROUND512_0_TO_15_NULL(E,F,G,H,A,B,C,D,AC5);
ROUND512_0_TO_15_NULL(D,E,F,G,H,A,B,C,AC6);
ROUND512_0_TO_15_NULL(C,D,E,F,G,H,A,B,AC7);
ROUND512_0_TO_15_NULL(B,C,D,E,F,G,H,A,AC8);
ROUND512_0_TO_15_NULL(A,B,C,D,E,F,G,H,AC9);
ROUND512_0_TO_15_NULL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NULL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NULL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NULL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NULL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NULL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

w16 = sigma1_512(w14)+w9+sigma0_512(w1)+w0; ROUND512(A,B,C,D,E,F,G,H,w16,AC17);
w0 = sigma1_512(SIZE)+w10+sigma0_512(w2)+w1; ROUND512(H,A,B,C,D,E,F,G,w0,AC18);
w1 = sigma1_512(w16)+w11+sigma0_512(w3)+w2; ROUND512(G,H,A,B,C,D,E,F,w1,AC19);
w2 = sigma1_512(w0)+w12+sigma0_512(w4)+w3; ROUND512(F,G,H,A,B,C,D,E,w2,AC20);
w3 = sigma1_512(w1)+w13+sigma0_512(w5)+w4; ROUND512(E,F,G,H,A,B,C,D,w3,AC21);
w4 = sigma1_512(w2)+w14+sigma0_512(w6)+w5; ROUND512(D,E,F,G,H,A,B,C,w4,AC22);
w5 = sigma1_512(w4)+SIZE+sigma0_512(w7)+w6; ROUND512(C,D,E,F,G,H,A,B,w5,AC23);
w6 = sigma1_512(w5)+w16+sigma0_512(w8)+w7; ROUND512(B,C,D,E,F,G,H,A,w6,AC24);
w7 = sigma1_512(w6)+w0+sigma0_512(w9)+w8; ROUND512(A,B,C,D,E,F,G,H,w7,AC25);
w8 = sigma1_512(w7)+w1+sigma0_512(w10)+w9; ROUND512(H,A,B,C,D,E,F,G,w8,AC26);
w9 = sigma1_512(w8)+w2+sigma0_512(w11)+w10; ROUND512(G,H,A,B,C,D,E,F,w9,AC27);
w10 = sigma1_512(w9)+w3+sigma0_512(w12)+w11; ROUND512(F,G,H,A,B,C,D,E,w10,AC28);
w11 = sigma1_512(w10)+w4+sigma0_512(w13)+w12; ROUND512(E,F,G,H,A,B,C,D,w11,AC29);
w12 = sigma1_512(w11)+w5+sigma0_512(w14)+w13; ROUND512(D,E,F,G,H,A,B,C,w12,AC30);
w13 = sigma1_512(w12)+w6+sigma0_512(SIZE)+w14; ROUND512(C,D,E,F,G,H,A,B,w13,AC31);
w14 = sigma1_512(w13)+w7+sigma0_512(w16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,w14,AC32);
SIZE = sigma1_512(w14)+w8+sigma0_512(w0)+w16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
w16 = sigma1_512(SIZE)+w9+sigma0_512(w1)+w0; ROUND512(H,A,B,C,D,E,F,G,w16,AC34);
w0 = sigma1_512(w16)+w10+sigma0_512(w2)+w1; ROUND512(G,H,A,B,C,D,E,F,w0,AC35);
w1 = sigma1_512(w0)+w11+sigma0_512(w3)+w2; ROUND512(F,G,H,A,B,C,D,E,w1,AC36);
w2 = sigma1_512(w1)+w12+sigma0_512(w4)+w3; ROUND512(E,F,G,H,A,B,C,D,w2,AC37);
w3 = sigma1_512(w2)+w13+sigma0_512(w5)+w4; ROUND512(D,E,F,G,H,A,B,C,w3,AC38);
w4 = sigma1_512(w3)+w14+sigma0_512(w6)+w5; ROUND512(C,D,E,F,G,H,A,B,w4,AC39);
w5 = sigma1_512(w4)+SIZE+sigma0_512(w7)+w6; ROUND512(B,C,D,E,F,G,H,A,w5,AC40);
w6 = sigma1_512(w5)+w16+sigma0_512(w8)+w7; ROUND512(A,B,C,D,E,F,G,H,w6,AC41);
w7 = sigma1_512(w6)+w0+sigma0_512(w9)+w8; ROUND512(H,A,B,C,D,E,F,G,w7,AC42);
w8 = sigma1_512(w7)+w1+sigma0_512(w10)+w9; ROUND512(G,H,A,B,C,D,E,F,w8,AC43);
ROUND512(F,G,H,A,B,C,D,E,w9,AC44);
ROUND512(E,F,G,H,A,B,C,D,w10,AC45);
ROUND512(D,E,F,G,H,A,B,C,w11,AC46);
ROUND512(C,D,E,F,G,H,A,B,w12,AC47);
ROUND512(B,C,D,E,F,G,H,A,w13,AC48);
ROUND512(A,B,C,D,E,F,G,H,w14,AC49);
ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
ROUND512(G,H,A,B,C,D,E,F,w16,AC51);
ROUND512(F,G,H,A,B,C,D,E,w0,AC52);
ROUND512(E,F,G,H,A,B,C,D,w1,AC53);
ROUND512(D,E,F,G,H,A,B,C,w2,AC54);
ROUND512(C,D,E,F,G,H,A,B,w3,AC55);
ROUND512(B,C,D,E,F,G,H,A,w4,AC56);
ROUND512(A,B,C,D,E,F,G,H,w5,AC57);
ROUND512(H,A,B,C,D,E,F,G,w6,AC58);
ROUND512(G,H,A,B,C,D,E,F,w7,AC59);
ROUND512(F,G,H,A,B,C,D,E,w8,AC60);
ROUND512(E,F,G,H,A,B,C,D,w9,AC61);
ROUND512(D,E,F,G,H,A,B,C,w10,AC62);
ROUND512(C,D,E,F,G,H,A,B,w11,AC63);
ROUND512(B,C,D,E,F,G,H,A,w12,AC64);
ROUND512(A,B,C,D,E,F,G,H,w13,AC65);
ROUND512(H,A,B,C,D,E,F,G,w14,AC66);
ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
ROUND512(F,G,H,A,B,C,D,E,w16,AC68);
ROUND512(E,F,G,H,A,B,C,D,w0,AC69);
ROUND512(D,E,F,G,H,A,B,C,w1,AC70);
ROUND512(C,D,E,F,G,H,A,B,w2,AC71);
ROUND512(B,C,D,E,F,G,H,A,w3,AC72);
ROUND512(A,B,C,D,E,F,G,H,w4,AC73);
ROUND512(H,A,B,C,D,E,F,G,w5,AC74);
ROUND512(G,H,A,B,C,D,E,F,w6,AC75);
ROUND512(F,G,H,A,B,C,D,E,w7,AC76);
ROUND512(E,F,G,H,A,B,C,D,w8,AC77);
ROUND512(D,E,F,G,H,A,B,C,w9,AC78);
ROUND512(C,D,E,F,G,H,A,B,w10,AC79);
ROUND512(B,C,D,E,F,G,H,A,w11,AC80);



#ifdef SINGLE_MODE
id=0;
if ((singlehash.x==A.s0)&&(singlehash.y==B.s0)&&(singlehash.z==C.s0)&&(singlehash.w==D.s0)) id = 1; 
if ((singlehash.x==A.s1)&&(singlehash.y==B.s1)&&(singlehash.z==C.s1)&&(singlehash.w==D.s1)) id = 1; 
if ((singlehash.x==A.s2)&&(singlehash.y==B.s2)&&(singlehash.z==C.s2)&&(singlehash.w==D.s2)) id = 1; 
if ((singlehash.x==A.s3)&&(singlehash.y==B.s3)&&(singlehash.z==C.s3)&&(singlehash.w==D.s3)) id = 1; 
if (id==0) return;
#endif


#ifndef SINGLE_MODE
id=0;
b1=A.s0;b2=B.s0;b3=C.s0;b4=D.s0;
b5=(singlehash.x >> (B.s0&31))&1;
b6=(singlehash.y >> (C.s0&31))&1;
b7=(singlehash.z >> (D.s0&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s1;b2=B.s1;b3=C.s1;b4=D.s1;
b5=(singlehash.x >> (B.s1&31))&1;
b6=(singlehash.y >> (C.s1&31))&1;
b7=(singlehash.z >> (D.s1&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && (
(bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s2;b2=B.s2;b3=C.s2;b4=D.s2;
b5=(singlehash.x >> (B.s2&31))&1;
b6=(singlehash.y >> (C.s2&31))&1;
b7=(singlehash.z >> (D.s2&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
b1=A.s3;b2=B.s3;b3=C.s3;b4=D.s3;
b5=(singlehash.x >> (B.s3&31))&1;
b6=(singlehash.y >> (C.s3&31))&1;
b7=(singlehash.z >> (D.s3&31))&1;
if ((b7) && (b5) && (b6)) if (((bitmaps[b1>>13]>>(b1&31))&1) && ((bitmaps[65535*8+(b2>>13)]>>(b2&31))&1) && ((bitmaps[(16*65535)+(b3>>13)]>>(b3&31))&1) && ((bitmaps[(24*65535)+(b4>>13)]>>(b4&31))&1)) id=1;
if (id==0) return;
#endif



if (id==1) 
{
found[0] = 1;
found_ind[get_global_id(0)] = 1;
}

dst[(get_global_id(0)*8)] = (ulong4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*8)+1] = (ulong4)(E.s0,F.s0,G.s0,H.s0);
dst[(get_global_id(0)*8)+2] = (ulong4)(A.s1,B.s1,C.s1,D.s1);  
dst[(get_global_id(0)*8)+3] = (ulong4)(E.s1,F.s1,G.s1,H.s1);
dst[(get_global_id(0)*8)+4] = (ulong4)(A.s2,B.s2,C.s2,D.s2);  
dst[(get_global_id(0)*8)+5] = (ulong4)(E.s2,F.s2,G.s2,H.s2);
dst[(get_global_id(0)*8)+6] = (ulong4)(A.s3,B.s3,C.s3,D.s3);  
dst[(get_global_id(0)*8)+7] = (ulong4)(E.s3,F.s3,G.s3,H.s3);


}
