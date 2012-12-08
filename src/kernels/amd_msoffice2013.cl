
/* Not supported on 4xxx */
#ifndef OLD_ATI

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1) { \
    elem=ii1>>2; \
    tt1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tt1)); \
    ai1[elem+1] = (tt1==0) ? 0 : ai2>>(32-tt1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tt1;

inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
size[GGI] = (SIZE+str.sF);

SET_AB(inpc[GLI],str.s0,SIZE);
SET_AB(inpc[GLI],str.s1,SIZE+4);
SET_AB(inpc[GLI],str.s2,SIZE+8);
SET_AB(inpc[GLI],str.s3,SIZE+12);


dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}



#define Endian_Reverse64(a) { (a) = ((a) & 0x00000000000000FFL) << 56L | ((a) & 0x000000000000FF00L) << 40L | \
                              ((a) & 0x0000000000FF0000L) << 24L | ((a) & 0x00000000FF000000L) << 8L | \
                              ((a) & 0x000000FF00000000L) >> 8L | ((a) & 0x0000FF0000000000L) >> 24L | \
                              ((a) & 0x00FF000000000000L) >> 40L | ((a) & 0xFF00000000000000L) >> 56L; }

#define ROTATE(b,x)     (((x) >> (b)) | ((x) << (64 - (b))))
#define R(b,x)          ((x) >> (b))
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




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officeprep( __global ulong *dst,  __global uint *inp, __global uint *size, uint16 salt)
{
uint TSIZE,SIZE;  
uint ib,ic,id;  
uint tt1,elem; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint t1,t2,t3;
__local uint inpc[64][25];
uint y0,y1,y2,y3,y4,y5,y6,y7;
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SSIZE;


id=get_global_id(0);

SIZE=(uint)size[GGI];
y0 = inp[GGI*8+0];
y1 = inp[GGI*8+1];
y2 = inp[GGI*8+2];
y3 = inp[GGI*8+3];
y4 = inp[GGI*8+4];
y5 = inp[GGI*8+5];
y6 = inp[GGI*8+6];
y7 = inp[GGI*8+7];

inpc[GLI][0]=salt.s0;
inpc[GLI][1]=salt.s1;
inpc[GLI][2]=salt.s2;
inpc[GLI][3]=salt.s3;
inpc[GLI][4]=salt.s4;
inpc[GLI][5]=salt.s5;
inpc[GLI][6]=salt.s6;
inpc[GLI][7]=salt.s7;

inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=inpc[GLI][14]=(uint)0;
inpc[GLI][15]=inpc[GLI][16]=inpc[GLI][17]=inpc[GLI][18]=inpc[GLI][19]=inpc[GLI][20]=inpc[GLI][21]=(uint)0;
inpc[GLI][22]=inpc[GLI][23]=inpc[GLI][24]=(uint)0;


t1=y0;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF);
SET_AB(inpc[GLI],t3,salt.sF+4);
t1=y1;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+8);
SET_AB(inpc[GLI],t3,salt.sF+12);
t1=y2;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+16);
SET_AB(inpc[GLI],t3,salt.sF+20);
t1=y3;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+24);
SET_AB(inpc[GLI],t3,salt.sF+28);
t1=y4;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+32);
SET_AB(inpc[GLI],t3,salt.sF+36);
t1=y5;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+40);
SET_AB(inpc[GLI],t3,salt.sF+44);
t1=y6;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+48);
SET_AB(inpc[GLI],t3,salt.sF+52);
t1=y7;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+56);
SET_AB(inpc[GLI],t3,salt.sF+60);
TSIZE=(SIZE)*2+salt.sF;

SET_AB(inpc[GLI],0x80,TSIZE);


x0=(ulong)inpc[GLI][1];
x0=(x0<<32)|(ulong)inpc[GLI][0];
x1=(ulong)inpc[GLI][3];
x1=(x1<<32)|(ulong)inpc[GLI][2];
x2=(ulong)inpc[GLI][5];
x2=(x2<<32)|(ulong)inpc[GLI][4];
x3=(ulong)inpc[GLI][7];
x3=(x3<<32)|(ulong)inpc[GLI][6];
x4=(ulong)inpc[GLI][9];
x4=(x4<<32)|(ulong)inpc[GLI][8];
x5=(ulong)inpc[GLI][11];
x5=(x5<<32)|(ulong)inpc[GLI][10];
x6=(ulong)inpc[GLI][13];
x6=(x6<<32)|(ulong)inpc[GLI][12];
x7=(ulong)inpc[GLI][15];
x7=(x7<<32)|(ulong)inpc[GLI][14];
x8=(ulong)inpc[GLI][17];
x8=(x8<<32)|(ulong)inpc[GLI][16];
x9=(ulong)inpc[GLI][19];
x9=(x9<<32)|(ulong)inpc[GLI][18];
x10=(ulong)inpc[GLI][21];
x10=(x10<<32)|(ulong)inpc[GLI][20];
x11=(ulong)inpc[GLI][23];
x11=(x11<<32)|(ulong)inpc[GLI][22];
x12=(ulong)inpc[GLI][24];


x13=x14=x15=x16=(ulong)0;
SSIZE=TSIZE<<3;


A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
Endian_Reverse64(x0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
Endian_Reverse64(x1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
Endian_Reverse64(x2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
Endian_Reverse64(x3);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
Endian_Reverse64(x4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
Endian_Reverse64(x5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
Endian_Reverse64(x6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
Endian_Reverse64(x7);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
Endian_Reverse64(x8);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
Endian_Reverse64(x9);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
Endian_Reverse64(x10);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC11,x10);
Endian_Reverse64(x11);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC12,x11);
Endian_Reverse64(x12);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC13,x12);
Endian_Reverse64(x13);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC14,x13);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SSIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SSIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SSIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SSIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A+=(ulong)H0;
B+=(ulong)H1;
C+=(ulong)H2;
D+=(ulong)H3;
E+=(ulong)H4;
F+=(ulong)H5;
G+=(ulong)H6;
H+=(ulong)H7;

dst[get_global_id(0)*8]=(ulong)A;
dst[get_global_id(0)*8+1]=(ulong)B;
dst[get_global_id(0)*8+2]=(ulong)C;
dst[get_global_id(0)*8+3]=(ulong)D;
dst[get_global_id(0)*8+4]=(ulong)E;
dst[get_global_id(0)*8+5]=(ulong)F;
dst[get_global_id(0)*8+6]=(ulong)G;
dst[get_global_id(0)*8+7]=(ulong)H;


}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officeiter( __global ulong *dst,  __global ulong *inp, uint16 salt)
{
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SIZE;
uint i;


A=inp[(GGI*8)];
B=inp[(GGI*8)+1];
C=inp[(GGI*8)+2];
D=inp[(GGI*8)+3];
E=inp[(GGI*8)+4];
F=inp[(GGI*8)+5];
G=inp[(GGI*8)+6];
H=inp[(GGI*8)+7];


for (i=salt.s8;i<salt.s8+1000;i++)
{
x0=(ulong)i;
Endian_Reverse64(x0);
x0=x0|(A>>32);
x1=(A<<32)|(B>>32);
x2=(B<<32)|(C>>32);
x3=(C<<32)|(D>>32);
x4=(D<<32)|(E>>32);
x5=(E<<32)|(F>>32);
x6=(F<<32)|(G>>32);
x7=(G<<32)|(H>>32);
x8=(H<<32)|0x80000000;

SIZE=(ulong)68<<3;
x9=x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = /*sigma1_512(x14)+x9+*/sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+/*x10+*/sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+/*x11+*/sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+/*x12+*/sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+/*x13+*/sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+/*x14+*/sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+/*sigma0_512(x9)+*/x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1/*+sigma0_512(x10)+x9*/; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2/*+sigma0_512(x11)+x10*/; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3/*+sigma0_512(x12)+x11*/; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4/*+sigma0_512(x13)+x12*/; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5/*+sigma0_512(x14)+x13*/; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)/*+x14*/; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);
A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

}

dst[GGI*8]=(ulong)A;
dst[GGI*8+1]=(ulong)B;
dst[GGI*8+2]=(ulong)C;
dst[GGI*8+3]=(ulong)D;
dst[GGI*8+4]=(ulong)E;
dst[GGI*8+5]=(ulong)F;
dst[GGI*8+6]=(ulong)G;
dst[GGI*8+7]=(ulong)H;
}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officefinal( __global ulong4 *dst,  __global ulong *inp, uint16 salt)
{
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong SSA,SSB,SSC,SSD,SSE,SSF,SSG,SSH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SIZE;
uint i;

SA=inp[(GGI*8)];
SB=inp[(GGI*8)+1];
SC=inp[(GGI*8)+2];
SD=inp[(GGI*8)+3];
SE=inp[(GGI*8)+4];
SF=inp[(GGI*8)+5];
SG=inp[(GGI*8)+6];
SH=inp[(GGI*8)+7];

x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt.sA);
x8=(x8<<32)|(salt.s9);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

SSA=A;
SSB=B;
SSC=C;
SSD=D;
SSE=E;
SSF=F;
SSG=G;
SSH=H;



x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt.sC);
x8=(x8<<32)|(salt.sB);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);


dst[GGI*4]=(ulong4)(SSA,SSB,SSC,SSD);
dst[GGI*4+1]=(ulong4)(SSE,SSF,SSG,SSH);
dst[GGI*4+2]=(ulong4)(A,B,C,D);
dst[GGI*4+3]=(ulong4)(E,F,G,H);
}



#endif
