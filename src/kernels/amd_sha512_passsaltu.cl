#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tt1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tt1)); \
    ai1[elem+1] = (tt1==0) ? 0 : ai2>>(32-tt1);\
    }

#define TOUPPERCHAR(y) ( (((y)<='z')&&((y)>='a')) ? ((y)-32) : (y))
#define TOUPPERDWORD(x) (TOUPPERCHAR((x)&255)|((TOUPPERCHAR(((x)>>8) & 0xFF))<<8)|((TOUPPERCHAR(((x)>>16) & 0xFF))<<16)|((TOUPPERCHAR(((x)>>24) & 0xFF))<<24))

#define Endian_Reverse64(a) { (a) = ((a) & 0x00000000000000FFL) << 56L | ((a) & 0x000000000000FF00L) << 40L | \
                              ((a) & 0x0000000000FF0000L) << 24L | ((a) & 0x00000000FF000000L) << 8L | \
                              ((a) & 0x000000FF00000000L) >> 8L | ((a) & 0x0000FF0000000000L) >> 24L | \
                              ((a) & 0x00FF000000000000L) >> 40L | ((a) & 0xFF00000000000000L) >> 56L; }


#define ROTATE(b,x)     (((x) >> (b)) | ((x) << (64 - (b))))
#define R(b,x)          ((x) >> (b))
//#define Ch(x,y,z)     (((x) & (y)) ^ ((~(x)) & (z)))
//#define Maj(x,y,z)    (((x) & (y)) ^ ((x) & (z)) ^ ((y) & (z)))
#define Ch(x,y,z)       ((z)^((x)&((y)^(z))))
#define Maj(x,y,z)      (((x) & (y)) | ((z)&((x)|(y))))

#define Sigma0_512(x)   (ROTATE(28, (x)) ^ ROTATE(34, (x)) ^ ROTATE(39, (x)))
#define Sigma1_512(x)   (ROTATE(14, (x)) ^ ROTATE(18, (x)) ^ ROTATE(41, (x)))
#define sigma0_512(x)   (ROTATE( 1, (x)) ^ ROTATE( 8, (x)) ^ R( 7,   (x)))
#define sigma1_512(x)   (ROTATE(19, (x)) ^ ROTATE(61, (x)) ^ R( 6,   (x)))


#define ROUND512_0_TO_15(a,b,c,d,e,f,g,h,AC,x) T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC + x; \
                                                (d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c))

#define ROUND512_0_TO_15_NL(a,b,c,d,e,f,g,h,AC) T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC; \
                                                (d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c))


#define ROUND512(a,b,c,d,e,f,g,h,AC,x)  T1 = (h) + Sigma1_512(e) + Ch((e), (f), (g)) + AC + x;\
                                        (d) += T1; (h) = T1 + Sigma0_512(a) + Maj((a), (b), (c));




#define H0 0x6a09e667f3bcc908L
#define H1 0xbb67ae8584caa73bL
#define H2 0x3c6ef372fe94f82bL
#define H3 0xa54ff53a5f1d36f1L
#define H4 0x510e527fade682d1L
#define H5 0x9b05688c2b3e6c1fL
#define H6 0x1f83d9abfb41bd6bL
#define H7 0x5be0cd19137e2179L

#define AC1  0x428a2f98d728ae22L
#define AC2  0x7137449123ef65cdL
#define AC3  0xb5c0fbcfec4d3b2fL
#define AC4  0xe9b5dba58189dbbcL
#define AC5  0x3956c25bf348b538L
#define AC6  0x59f111f1b605d019L
#define AC7  0x923f82a4af194f9bL
#define AC8  0xab1c5ed5da6d8118L
#define AC9  0xd807aa98a3030242L
#define AC10 0x12835b0145706fbeL
#define AC11 0x243185be4ee4b28cL
#define AC12 0x550c7dc3d5ffb4e2L
#define AC13 0x72be5d74f27b896fL
#define AC14 0x80deb1fe3b1696b1L
#define AC15 0x9bdc06a725c71235L
#define AC16 0xc19bf174cf692694L
#define AC17 0xe49b69c19ef14ad2L
#define AC18 0xefbe4786384f25e3L
#define AC19 0x0fc19dc68b8cd5b5L
#define AC20 0x240ca1cc77ac9c65L
#define AC21 0x2de92c6f592b0275L
#define AC22 0x4a7484aa6ea6e483L
#define AC23 0x5cb0a9dcbd41fbd4L
#define AC24 0x76f988da831153b5L
#define AC25 0x983e5152ee66dfabL
#define AC26 0xa831c66d2db43210L
#define AC27 0xb00327c898fb213fL
#define AC28 0xbf597fc7beef0ee4L
#define AC29 0xc6e00bf33da88fc2L
#define AC30 0xd5a79147930aa725L
#define AC31 0x06ca6351e003826fL
#define AC32 0x142929670a0e6e70L
#define AC33 0x27b70a8546d22ffcL
#define AC34 0x2e1b21385c26c926L
#define AC35 0x4d2c6dfc5ac42aedL
#define AC36 0x53380d139d95b3dfL
#define AC37 0x650a73548baf63deL
#define AC38 0x766a0abb3c77b2a8L
#define AC39 0x81c2c92e47edaee6L
#define AC40 0x92722c851482353bL
#define AC41 0xa2bfe8a14cf10364L
#define AC42 0xa81a664bbc423001L
#define AC43 0xc24b8b70d0f89791L
#define AC44 0xc76c51a30654be30L
#define AC45 0xd192e819d6ef5218L
#define AC46 0xd69906245565a910L
#define AC47 0xf40e35855771202aL
#define AC48 0x106aa07032bbd1b8L
#define AC49 0x19a4c116b8d2d0c8L
#define AC50 0x1e376c085141ab53L
#define AC51 0x2748774cdf8eeb99L
#define AC52 0x34b0bcb5e19b48a8L
#define AC53 0x391c0cb3c5c95a63L
#define AC54 0x4ed8aa4ae3418acbL
#define AC55 0x5b9cca4f7763e373L
#define AC56 0x682e6ff3d6b2b8a3L
#define AC57 0x748f82ee5defb2fcL
#define AC58 0x78a5636f43172f60L
#define AC59 0x84c87814a1f0ab72L
#define AC60 0x8cc702081a6439ecL
#define AC61 0x90befffa23631e28L
#define AC62 0xa4506cebde82bde9L
#define AC63 0xbef9a3f7b2c67915L
#define AC64 0xc67178f2e372532bL
#define AC64 0xc67178f2e372532bL
#define AC65 0xca273eceea26619cL
#define AC66 0xd186b8c721c0c207L
#define AC67 0xeada7dd6cde0eb1eL
#define AC68 0xf57d4f7fee6ed178L
#define AC69 0x06f067aa72176fbaL
#define AC70 0x0a637dc5a2c898a6L
#define AC71 0x113f9804bef90daeL
#define AC72 0x1b710b35131c471bL
#define AC73 0x28db77f523047d84L
#define AC74 0x32caab7b40c72493L
#define AC75 0x3c9ebe0a15c9bebcL
#define AC76 0x431d67c49c100d4cL
#define AC77 0x4cc5d4becb3e42b6L
#define AC78 0x597f299cfc657e2aL
#define AC79 0x5fcb6fab3ad6faecL
#define AC80 0x6c44198c4a475817L




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
sha512_passsalt( __global ulong4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  ulong4 singlehash, uint16 salt, uint16 str) 
{
uint4 ww0,ww1,ww2,ww3,ww4,ww5,ww6,ww7,ww8,ww9,ww10,ww11,ww12,ww13,ww14,ww16; 
uint i,ib,ic,id,ie;  
uint2 wSIZE,TSIZE; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint elem,temp1;
uint t1,t2,t3,tt1;
__local uint inpc[64][24];
uint x0,x1,x2,x3,x4,x5,x6,x7;
uint y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12,y13;
ulong2 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,SIZE;
ulong2 A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;


id=get_global_id(0);
wSIZE=(uint2)sizein[GGI];

if ((wSIZE.s0+str.sC)>23) str.sC=0;
if ((wSIZE.s1+str.sD)>23) str.sD=0;
if (all(wSIZE>(uint2)23)) wSIZE=(uint2)0;

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
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str.s0,wSIZE.s0,0);
SET_AB(inpc[GLI],str.s1,wSIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,wSIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,wSIZE.s0+12,0);
y0=inpc[GLI][0];
y1=inpc[GLI][1];
y2=inpc[GLI][2];
y3=inpc[GLI][3];
y4=inpc[GLI][4];
y5=inpc[GLI][5];
y6=inpc[GLI][6];
y7=inpc[GLI][7];
y8=inpc[GLI][8];
y9=inpc[GLI][9];
y10=inpc[GLI][10];
y11=inpc[GLI][11];
y12=inpc[GLI][12];
y13=inpc[GLI][13];
t1=y0;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][0] = t2;
inpc[GLI][1] = t3;
t1=y1;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][2] = t2;
inpc[GLI][3] = t3;
t1=y2;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][4] = t2;
inpc[GLI][5] = t3;
t1=y3;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][6] = t2;
inpc[GLI][7] = t3;
t1=y4;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][8] = t2;
inpc[GLI][9] = t3;
t1=y5;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][10] = t2;
inpc[GLI][11] = t3;
inpc[GLI][12] = 0;
inpc[GLI][13] = 0;
TSIZE.s0=(wSIZE.s0+str.sC)*2;
SET_AB(inpc[GLI],salt.s0,TSIZE.s0,0);
SET_AB(inpc[GLI],salt.s1,TSIZE.s0+4,0);
SET_AB(inpc[GLI],salt.s2,TSIZE.s0+8,0);
SET_AB(inpc[GLI],salt.s3,TSIZE.s0+12,0);
SET_AB(inpc[GLI],salt.s4,TSIZE.s0+16,0);
SET_AB(inpc[GLI],salt.s5,TSIZE.s0+20,0);
SET_AB(inpc[GLI],salt.s6,TSIZE.s0+24,0);
SET_AB(inpc[GLI],salt.s7,TSIZE.s0+28,0);
SET_AB(inpc[GLI],0x80,(TSIZE.s0+salt.sF),0);
ww0.s0=inpc[GLI][0];
ww1.s0=inpc[GLI][1];
ww2.s0=inpc[GLI][2];
ww3.s0=inpc[GLI][3];
ww4.s0=inpc[GLI][4];
ww5.s0=inpc[GLI][5];
ww6.s0=inpc[GLI][6];
ww7.s0=inpc[GLI][7];
ww8.s0=inpc[GLI][8];
ww9.s0=inpc[GLI][9];
ww10.s0=inpc[GLI][10];
ww11.s0=inpc[GLI][11];
ww12.s0=inpc[GLI][12];
ww13.s0=inpc[GLI][13];
SIZE.s0 = (ulong)(TSIZE.s0+salt.sF)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str.s4,wSIZE.s1,0);
SET_AB(inpc[GLI],str.s5,wSIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,wSIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,wSIZE.s1+12,0);
y0=inpc[GLI][0];
y1=inpc[GLI][1];
y2=inpc[GLI][2];
y3=inpc[GLI][3];
y4=inpc[GLI][4];
y5=inpc[GLI][5];
y6=inpc[GLI][6];
y7=inpc[GLI][7];
y8=inpc[GLI][8];
y9=inpc[GLI][9];
y10=inpc[GLI][10];
y11=inpc[GLI][11];
y12=inpc[GLI][12];
y13=inpc[GLI][13];
t1=y0;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][0] = t2;
inpc[GLI][1] = t3;
t1=y1;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][2] = t2;
inpc[GLI][3] = t3;
t1=y2;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][4] = t2;
inpc[GLI][5] = t3;
t1=y3;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][6] = t2;
inpc[GLI][7] = t3;
t1=y4;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][8] = t2;
inpc[GLI][9] = t3;
t1=y5;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
inpc[GLI][10] = t2;
inpc[GLI][11] = t3;
inpc[GLI][12] = 0;
inpc[GLI][13] = 0;
TSIZE.s1=(wSIZE.s1+str.sD)*2;
SET_AB(inpc[GLI],salt.s0,TSIZE.s1,0);
SET_AB(inpc[GLI],salt.s1,TSIZE.s1+4,0);
SET_AB(inpc[GLI],salt.s2,TSIZE.s1+8,0);
SET_AB(inpc[GLI],salt.s3,TSIZE.s1+12,0);
SET_AB(inpc[GLI],salt.s4,TSIZE.s1+16,0);
SET_AB(inpc[GLI],salt.s5,TSIZE.s1+20,0);
SET_AB(inpc[GLI],salt.s6,TSIZE.s1+24,0);
SET_AB(inpc[GLI],salt.s7,TSIZE.s1+28,0);
SET_AB(inpc[GLI],0x80,(TSIZE.s1+salt.sF),0);
ww0.s1=inpc[GLI][0];
ww1.s1=inpc[GLI][1];
ww2.s1=inpc[GLI][2];
ww3.s1=inpc[GLI][3];
ww4.s1=inpc[GLI][4];
ww5.s1=inpc[GLI][5];
ww6.s1=inpc[GLI][6];
ww7.s1=inpc[GLI][7];
ww8.s1=inpc[GLI][8];
ww9.s1=inpc[GLI][9];
ww10.s1=inpc[GLI][10];
ww11.s1=inpc[GLI][11];
ww12.s1=inpc[GLI][12];
ww13.s1=inpc[GLI][13];
SIZE.s1 = (ulong)(TSIZE.s1+salt.sF)<<3;


w0.s0=(ulong)ww1.s0;
w0.s0=(w0.s0<<32);
w0.s0|=(ulong)ww0.s0;
w1.s0=(ulong)ww3.s0;
w1.s0=(w1.s0<<32);
w1.s0|=(ulong)ww2.s0;
w2.s0=(ulong)ww5.s0;
w2.s0=(w2.s0<<32);
w2.s0|=(ulong)ww4.s0;
w3.s0=(ulong)ww7.s0;
w3.s0=(w3.s0<<32);
w3.s0|=(ulong)ww6.s0;
w4.s0=(ulong)ww9.s0;
w4.s0=(w4.s0<<32);
w4.s0|=(ulong)ww8.s0;
w5.s0=(ulong)ww11.s0;
w5.s0=(w5.s0<<32);
w5.s0|=(ulong)ww10.s0;
w6.s0=(ulong)ww13.s0;
w6.s0=(w6.s0<<32);
w6.s0|=(ulong)ww12.s0;


w0.s1=(ulong)ww1.s1;
w0.s1=w0.s1<<32;
w0.s1|=(ulong)ww0.s1;
w1.s1=(ulong)ww3.s1;
w1.s1=w1.s1<<32;
w1.s1|=(ulong)ww2.s1;
w2.s1=(ulong)ww5.s1;
w2.s1=w2.s1<<32;
w2.s1|=(ulong)ww4.s1;
w3.s1=(ulong)ww7.s1;
w3.s1=w3.s1<<32;
w3.s1|=(ulong)ww6.s1;
w4.s1=(ulong)ww9.s1;
w4.s1=w4.s1<<32;
w4.s1|=(ulong)ww8.s1;
w5.s1=(ulong)ww11.s1;
w5.s1=w5.s1<<32;
w5.s1|=(ulong)ww10.s1;
w6.s1=(ulong)ww13.s1;
w6.s1=w6.s1<<32;
w6.s1|=(ulong)ww12.s1;



w7=w8=w9=w10=w11=w12=w13=w14=w16=(ulong2)0;



A=(ulong2)H0;
B=(ulong2)H1;
C=(ulong2)H2;
D=(ulong2)H3;
E=(ulong2)H4;
F=(ulong2)H5;
G=(ulong2)H6;
H=(ulong2)H7;


Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);


ROUND512_0_TO_15(A,B,C,D,E,F,G,H,w0,AC1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,w1,AC2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,w2,AC3);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,w3,AC4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,w4,AC5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,w5,AC6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,w6,AC7);
ROUND512_0_TO_15_NL(B,C,D,E,F,G,H,A,AC8);
ROUND512_0_TO_15_NL(A,B,C,D,E,F,G,H,AC9);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);


w16 = sigma1_512(w14)+w9+sigma0_512(w1)+w0; ROUND512(A,B,C,D,E,F,G,H,w16,AC17);
w0 = sigma1_512(SIZE)+w10+sigma0_512(w2)+w1; ROUND512(H,A,B,C,D,E,F,G,w0,AC18);
w1 = sigma1_512(w16)+w11+sigma0_512(w3)+w2; ROUND512(G,H,A,B,C,D,E,F,w1,AC19);
w2 = sigma1_512(w0)+w12+sigma0_512(w4)+w3; ROUND512(F,G,H,A,B,C,D,E,w2,AC20);
w3 = sigma1_512(w1)+w13+sigma0_512(w5)+w4; ROUND512(E,F,G,H,A,B,C,D,w3,AC21);
w4 = sigma1_512(w2)+w14+sigma0_512(w6)+w5; ROUND512(D,E,F,G,H,A,B,C,w4,AC22);
w5 = sigma1_512(w3)+SIZE+sigma0_512(w7)+w6; ROUND512(C,D,E,F,G,H,A,B,w5,AC23);
w6 = sigma1_512(w4)+w16+sigma0_512(w8)+w7; ROUND512(B,C,D,E,F,G,H,A,w6,AC24);
w7 = sigma1_512(w5)+w0+sigma0_512(w9)+w8; ROUND512(A,B,C,D,E,F,G,H,w7,AC25);
w8 = sigma1_512(w6)+w1+sigma0_512(w10)+w9; ROUND512(H,A,B,C,D,E,F,G,w8,AC26);
w9 = sigma1_512(w7)+w2+sigma0_512(w11)+w10; ROUND512(G,H,A,B,C,D,E,F,w9,AC27);
w10 = sigma1_512(w8)+w3+sigma0_512(w12)+w11; ROUND512(F,G,H,A,B,C,D,E,w10,AC28);
w11 = sigma1_512(w9)+w4+sigma0_512(w13)+w12; ROUND512(E,F,G,H,A,B,C,D,w11,AC29);
w12 = sigma1_512(w10)+w5+sigma0_512(w14)+w13; ROUND512(D,E,F,G,H,A,B,C,w12,AC30);
w13 = sigma1_512(w11)+w6+sigma0_512(SIZE)+w14; ROUND512(C,D,E,F,G,H,A,B,w13,AC31);
w14 = sigma1_512(w12)+w7+sigma0_512(w16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,w14,AC32);
SIZE = sigma1_512(w13)+w8+sigma0_512(w0)+w16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
w16 = sigma1_512(w14)+w9+sigma0_512(w1)+w0; ROUND512(H,A,B,C,D,E,F,G,w16,AC34);
w0 = sigma1_512(SIZE)+w10+sigma0_512(w2)+w1; ROUND512(G,H,A,B,C,D,E,F,w0,AC35);
w1 = sigma1_512(w16)+w11+sigma0_512(w3)+w2; ROUND512(F,G,H,A,B,C,D,E,w1,AC36);
w2 = sigma1_512(w0)+w12+sigma0_512(w4)+w3; ROUND512(E,F,G,H,A,B,C,D,w2,AC37);
w3 = sigma1_512(w1)+w13+sigma0_512(w5)+w4; ROUND512(D,E,F,G,H,A,B,C,w3,AC38);
w4 = sigma1_512(w2)+w14+sigma0_512(w6)+w5; ROUND512(C,D,E,F,G,H,A,B,w4,AC39);
w5 = sigma1_512(w3)+SIZE+sigma0_512(w7)+w6; ROUND512(B,C,D,E,F,G,H,A,w5,AC40);
w6 = sigma1_512(w4)+w16+sigma0_512(w8)+w7; ROUND512(A,B,C,D,E,F,G,H,w6,AC41);
w7 = sigma1_512(w5)+w0+sigma0_512(w9)+w8; ROUND512(H,A,B,C,D,E,F,G,w7,AC42);
w8 = sigma1_512(w6)+w1+sigma0_512(w10)+w9; ROUND512(G,H,A,B,C,D,E,F,w8,AC43);
w9 = sigma1_512(w7)+w2+sigma0_512(w11)+w10; ROUND512(F,G,H,A,B,C,D,E,w9,AC44);
w10 = sigma1_512(w8)+w3+sigma0_512(w12)+w11; ROUND512(E,F,G,H,A,B,C,D,w10,AC45);
w11 = sigma1_512(w9)+w4+sigma0_512(w13)+w12; ROUND512(D,E,F,G,H,A,B,C,w11,AC46);
w12 = sigma1_512(w10)+w5+sigma0_512(w14)+w13; ROUND512(C,D,E,F,G,H,A,B,w12,AC47);
w13 = sigma1_512(w11)+w6+sigma0_512(SIZE)+w14; ROUND512(B,C,D,E,F,G,H,A,w13,AC48);
w14 = sigma1_512(w12)+w7+sigma0_512(w16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,w14,AC49);
SIZE = sigma1_512(w13)+w8+sigma0_512(w0)+w16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
w16 = sigma1_512(w14)+w9+sigma0_512(w1)+w0; ROUND512(G,H,A,B,C,D,E,F,w16,AC51);
w0 = sigma1_512(SIZE)+w10+sigma0_512(w2)+w1; ROUND512(F,G,H,A,B,C,D,E,w0,AC52);
w1 = sigma1_512(w16)+w11+sigma0_512(w3)+w2; ROUND512(E,F,G,H,A,B,C,D,w1,AC53);
w2 = sigma1_512(w0)+w12+sigma0_512(w4)+w3; ROUND512(D,E,F,G,H,A,B,C,w2,AC54);
w3 = sigma1_512(w1)+w13+sigma0_512(w5)+w4; ROUND512(C,D,E,F,G,H,A,B,w3,AC55);
w4 = sigma1_512(w2)+w14+sigma0_512(w6)+w5; ROUND512(B,C,D,E,F,G,H,A,w4,AC56);
w5 = sigma1_512(w3)+SIZE+sigma0_512(w7)+w6; ROUND512(A,B,C,D,E,F,G,H,w5,AC57);
w6 = sigma1_512(w4)+w16+sigma0_512(w8)+w7; ROUND512(H,A,B,C,D,E,F,G,w6,AC58);
w7 = sigma1_512(w5)+w0+sigma0_512(w9)+w8; ROUND512(G,H,A,B,C,D,E,F,w7,AC59);
w8 = sigma1_512(w6)+w1+sigma0_512(w10)+w9; ROUND512(F,G,H,A,B,C,D,E,w8,AC60);
w9 = sigma1_512(w7)+w2+sigma0_512(w11)+w10; ROUND512(E,F,G,H,A,B,C,D,w9,AC61);
w10 = sigma1_512(w8)+w3+sigma0_512(w12)+w11; ROUND512(D,E,F,G,H,A,B,C,w10,AC62);
w11 = sigma1_512(w9)+w4+sigma0_512(w13)+w12; ROUND512(C,D,E,F,G,H,A,B,w11,AC63);
w12 = sigma1_512(w10)+w5+sigma0_512(w14)+w13; ROUND512(B,C,D,E,F,G,H,A,w12,AC64);
w13 = sigma1_512(w11)+w6+sigma0_512(SIZE)+w14; ROUND512(A,B,C,D,E,F,G,H,w13,AC65);
w14 = sigma1_512(w12)+w7+sigma0_512(w16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,w14,AC66);
SIZE = sigma1_512(w13)+w8+sigma0_512(w0)+w16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
w16 = sigma1_512(w14)+w9+sigma0_512(w1)+w0; ROUND512(F,G,H,A,B,C,D,E,w16,AC68);
w0 = sigma1_512(SIZE)+w10+sigma0_512(w2)+w1; ROUND512(E,F,G,H,A,B,C,D,w0,AC69);
w1 = sigma1_512(w16)+w11+sigma0_512(w3)+w2; ROUND512(D,E,F,G,H,A,B,C,w1,AC70);
w2 = sigma1_512(w0)+w12+sigma0_512(w4)+w3; ROUND512(C,D,E,F,G,H,A,B,w2,AC71);
w3 = sigma1_512(w1)+w13+sigma0_512(w5)+w4; ROUND512(B,C,D,E,F,G,H,A,w3,AC72);
w4 = sigma1_512(w2)+w14+sigma0_512(w6)+w5; ROUND512(A,B,C,D,E,F,G,H,w4,AC73);
w5 = sigma1_512(w3)+SIZE+sigma0_512(w7)+w6; ROUND512(H,A,B,C,D,E,F,G,w5,AC74);
w6 = sigma1_512(w4)+w16+sigma0_512(w8)+w7; ROUND512(G,H,A,B,C,D,E,F,w6,AC75);
w7 = sigma1_512(w5)+w0+sigma0_512(w9)+w8; ROUND512(F,G,H,A,B,C,D,E,w7,AC76);
w8 = sigma1_512(w6)+w1+sigma0_512(w10)+w9; ROUND512(E,F,G,H,A,B,C,D,w8,AC77);
w9 = sigma1_512(w7)+w2+sigma0_512(w11)+w10; ROUND512(D,E,F,G,H,A,B,C,w9,AC78);
w10 = sigma1_512(w8)+w3+sigma0_512(w12)+w11; ROUND512(C,D,E,F,G,H,A,B,w10,AC79);
w11 = sigma1_512(w9)+w4+sigma0_512(w13)+w12; ROUND512(B,C,D,E,F,G,H,A,w11,AC80);


A+=(ulong2)H0;
B+=(ulong2)H1;
C+=(ulong2)H2;
D+=(ulong2)H3;
E+=(ulong2)H4;
F+=(ulong2)H5;
G+=(ulong2)H6;
H+=(ulong2)H7;


Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);



dst[(get_global_id(0)*4)] = (ulong4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*4)+1] = (ulong4)(E.s0,F.s0,G.s0,H.s0);
dst[(get_global_id(0)*4)+2] = (ulong4)(A.s1,B.s1,C.s1,D.s1);  
dst[(get_global_id(0)*4)+3] = (ulong4)(E.s1,F.s1,G.s1,H.s1);

if (all((ulong2)singlehash.x!=A)) return;
if (all((ulong2)singlehash.y!=B)) return;



found[0] = (uint)1;
found_ind[get_global_id(0)] = (uint)1;




}

