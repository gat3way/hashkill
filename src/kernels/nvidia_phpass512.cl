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
size[GGI] = (SIZE+str.sF);

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

#ifndef GCN
#define Endian_Reverse64(a) { (a) = ((a) & 0x00000000000000FFL) << 56 | ((a) & 0x000000000000FF00L) << 40 | \
                              ((a) & 0x0000000000FF0000L) << 24 | ((a) & 0x00000000FF000000L) << 8 | \
                              ((a) & 0x000000FF00000000L) >> 8 | ((a) & 0x0000FF0000000000L) >> 24 | \
                              ((a) & 0x00FF000000000000L) >> 40 | ((a) & 0xFF00000000000000L) >> 56; }
#else
#define Endian_Reverse64(n)       ((n) = as_ulong(as_uchar8(n).s76543210))
#endif

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




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
prepare( __global ulong *dst,  __global ulong *input, __global uint *size,  __global uint *found_ind, __global uint *found,  ulong4 singlehash, uint16 salt) 
{

ulong SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16; 
ulong y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
ulong A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;


A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;



i=size[(get_global_id(0))]; 
SIZE=i;
tsize=SIZE;


x1=input[(get_global_id(0)*4)];
x2=input[(get_global_id(0)*4)+1];
x3=input[(get_global_id(0)*4)+2];
x4=input[(get_global_id(0)*4)+3];


x5=x6=x7=x8=x9=x10=x11=x12=x13=x14=x16=(ulong)0;
SIZE=(ulong)(tsize+8)<<3;

x0=salt.sF;
x0=x0<<32;
x0|=salt.sE;
y0=x1;
y1=x2;
y2=x3;
y3=x4;

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
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC6);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC7);
ROUND512_0_TO_15_NL(B,C,D,E,F,G,H,A,AC8);
ROUND512_0_TO_15_NL(A,B,C,D,E,F,G,H,AC9);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
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

A+=(ulong)H0;
B+=(ulong)H1;
C+=(ulong)H2;
D+=(ulong)H3;
E+=(ulong)H4;
F+=(ulong)H5;
G+=(ulong)H6;
H+=(ulong)H7;


dst[(get_global_id(0)*8)]=A;
dst[(get_global_id(0)*8)+1]=B;
dst[(get_global_id(0)*8)+2]=C;
dst[(get_global_id(0)*8)+3]=D;
dst[(get_global_id(0)*8)+4]=E;
dst[(get_global_id(0)*8)+5]=F;
dst[(get_global_id(0)*8)+6]=G;
dst[(get_global_id(0)*8)+7]=H;

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
phpass( __global ulong *dst,  __global ulong *input, __global uint *size,  __global uint *found_ind, __global uint *found,  ulong4 singlehash, uint16 salt) 
{

ulong SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16; 
ulong y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
ulong A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;


A=dst[(get_global_id(0)*8)];
B=dst[(get_global_id(0)*8)+1];
C=dst[(get_global_id(0)*8)+2];
D=dst[(get_global_id(0)*8)+3];
E=dst[(get_global_id(0)*8)+4];
F=dst[(get_global_id(0)*8)+5];
G=dst[(get_global_id(0)*8)+6];
H=dst[(get_global_id(0)*8)+7];

x1=input[(get_global_id(0)*4)];
x2=input[(get_global_id(0)*4)+1];
x3=input[(get_global_id(0)*4)+2];
x4=input[(get_global_id(0)*4)+3];


y0=x1;
y1=x2;
y2=x3;
y3=x4;
i=size[(get_global_id(0))]; 
SIZE=i;
tsize=SIZE;


tsize=(64+tsize)<<3;
for (i=0;i<512;i++)
{

SIZE=tsize;
x0=A;
x1=B;
x2=C;
x3=D;
x4=E;
x5=F;
x6=G;
x7=H;
x8=y0;
x9=y1;
x10=y2;
x11=y3;
x12=x13=x14=x16=(ulong)0;
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
Endian_Reverse64(x8);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
Endian_Reverse64(x9);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
Endian_Reverse64(x10);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC11,x10);
Endian_Reverse64(x11);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC12,x11);
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

A+=(ulong)H0;
B+=(ulong)H1;
C+=(ulong)H2;
D+=(ulong)H3;
E+=(ulong)H4;
F+=(ulong)H5;
G+=(ulong)H6;
H+=(ulong)H7;
}

dst[(get_global_id(0)*8)]=A;
dst[(get_global_id(0)*8)+1]=B;
dst[(get_global_id(0)*8)+2]=C;
dst[(get_global_id(0)*8)+3]=D;
dst[(get_global_id(0)*8)+4]=E;
dst[(get_global_id(0)*8)+5]=F;
dst[(get_global_id(0)*8)+6]=G;
dst[(get_global_id(0)*8)+7]=H;


}

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
final (__global ulong4 *dst,  __global ulong *input, __global uint *size,  __global uint *found_ind, __global uint *found,  ulong4 singlehash, uint16 salt) 
{

ulong SIZE,tsize;  
uint i,ib,ic,id,ie;  
uint t1,t2,t3,t4;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16; 
ulong y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w15; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
ulong A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;


A=input[(get_global_id(0)*8)];
B=input[(get_global_id(0)*8)+1];
C=input[(get_global_id(0)*8)+2];
D=input[(get_global_id(0)*8)+3];
E=input[(get_global_id(0)*8)+4];
F=input[(get_global_id(0)*8)+5];
G=input[(get_global_id(0)*8)+6];
H=input[(get_global_id(0)*8)+7];


Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

id=0;
if (((ulong)singlehash.x!=A)) return;
if (((ulong)singlehash.y!=B)) return;
if (((ulong)singlehash.z!=C)) return;
if (((ulong)singlehash.w!=D)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0)<<1)] = (ulong4)(A,B,C,D);
dst[(get_global_id(0)<<1)+1] = (ulong4)(E,F,G,H);

}
