#define Sl 8U
#define Sr 24U 
#define m 0x00FF00FFU
#define m2 0xFF00FF00U
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); } 
#define GLI (get_local_id(0))

// Dummy one
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
uint a,tmp1,tmp2,elem,l;

size[get_global_id(0)]=sizein[get_global_id(0)];
a=inp[get_global_id(0)*24];
Endian_Reverse32(a);
dst[get_global_id(0)*24]=a;
a=inp[get_global_id(0)*24+1];
Endian_Reverse32(a);
dst[get_global_id(0)*24+1]=a;
a=inp[get_global_id(0)*24+2];
Endian_Reverse32(a);
dst[get_global_id(0)*24+2]=a;
a=inp[get_global_id(0)*24+3];
Endian_Reverse32(a);
dst[get_global_id(0)*24+3]=a;
a=inp[get_global_id(0)*24+4];
Endian_Reverse32(a);
dst[get_global_id(0)*24+4]=a;
a=inp[get_global_id(0)*24+5];
Endian_Reverse32(a);
dst[get_global_id(0)*24+5]=a;
a=inp[get_global_id(0)*24+6];
Endian_Reverse32(a);
dst[get_global_id(0)*24+6]=a;
a=inp[get_global_id(0)*24+7];
Endian_Reverse32(a);
dst[get_global_id(0)*24+7]=a;
a=inp[get_global_id(0)*24+8];
Endian_Reverse32(a);
dst[get_global_id(0)*24+8]=a;
a=inp[get_global_id(0)*24+9];
Endian_Reverse32(a);
dst[get_global_id(0)*24+9]=a;
a=inp[get_global_id(0)*24+10];
Endian_Reverse32(a);
dst[get_global_id(0)*24+10]=a;
a=inp[get_global_id(0)*24+11];
Endian_Reverse32(a);
dst[get_global_id(0)*24+11]=a;
a=inp[get_global_id(0)*24+12];
Endian_Reverse32(a);
dst[get_global_id(0)*24+12]=a;
a=inp[get_global_id(0)*24+13];
Endian_Reverse32(a);
dst[get_global_id(0)*24+13]=a;
a=inp[get_global_id(0)*24+14];
Endian_Reverse32(a);
dst[get_global_id(0)*24+14]=a;
a=inp[get_global_id(0)*24+15];
Endian_Reverse32(a);
dst[get_global_id(0)*24+15]=a;
a=inp[get_global_id(0)*24+16];
Endian_Reverse32(a);
dst[get_global_id(0)*24+16]=a;
a=inp[get_global_id(0)*24+17];
Endian_Reverse32(a);
dst[get_global_id(0)*24+17]=a;
a=inp[get_global_id(0)*24+18];
Endian_Reverse32(a);
dst[get_global_id(0)*24+18]=a;
a=inp[get_global_id(0)*24+19];
Endian_Reverse32(a);
dst[get_global_id(0)*24+19]=a;
a=inp[get_global_id(0)*24+20];
Endian_Reverse32(a);
dst[get_global_id(0)*24+20]=a;
a=inp[get_global_id(0)*24+21];
Endian_Reverse32(a);
dst[get_global_id(0)*24+21]=a;
a=inp[get_global_id(0)*24+22];
Endian_Reverse32(a);
dst[get_global_id(0)*24+22]=a;
a=inp[get_global_id(0)*24+23];
Endian_Reverse32(a);
dst[get_global_id(0)*24+23]=a;
}


#define Endian_Reverse64(a)  (((a) & 0x00000000000000FFL) << 56L | ((a) & 0x000000000000FF00L) << 40L | \
                              ((a) & 0x0000000000FF0000L) << 24L | ((a) & 0x00000000FF000000L) << 8L | \
                              ((a) & 0x000000FF00000000L) >> 8L | ((a) & 0x0000FF0000000000L) >> 24L | \
                              ((a) & 0x00FF000000000000L) >> 40L | ((a) & 0xFF00000000000000L) >> 56L)


#define SET_AB(ai1,ii1,bb) { \
	ai1[(ii1)>>3] |= (((ulong)(bb)) << ((7-((ii1)&7))<<3)); \
	}


#define SET_AIF(ai1,ai2,ii1,ii2) { \
	ai1[(ii1)>>3] = (ai2); \
	}

#define SET_AIS(ai1,ai2,ii1,ii2) { \
        tmp1=(ulong)(((ii1)&7)<<3); \
        elem=(ulong)((ii1)>>3); \
        tmp2 = (ulong)ai1[elem]; \
        ai1[elem] = (ulong)(tmp2 |((ai2)>>tmp1)); \
	ai1[elem+1] = select(ai2<<(64-tmp1),(ulong)0,(ulong)(tmp1==0));\
        }

#define SET_ABR(ai1,ai2,ii1) { \
        elem=ii1>>2; \
        tmp1=(ii1&3)<<3; \
        ai1[elem] = ai1[elem]|(ai2>>(tmp1)); \
        ai1[elem+1] = select(ai2<<(32-tmp1),0U,(tmp1==0));\
    }


#define ROTATE(b,x)     (((x) >> (b)) | ((x) << (64UL - (b))))
#define R(b,x)          ((x) >> (b))
#define Ch(x,y,z)       ((z)^((x)&((y)^(z))))
#define Maj(x,y,z)      (((x) & (y)) | ((z)&((x)|(y))))


#define Sigma0_512(x)   (ROTATE(28UL, (x)) ^ ROTATE(34UL, (x)) ^ ROTATE(39UL, (x)))
#define Sigma1_512(x)   (ROTATE(14UL, (x)) ^ ROTATE(18UL, (x)) ^ ROTATE(41UL, (x)))
#define sigma0_512(x)   (ROTATE( 1UL, (x)) ^ ROTATE( 8UL, (x)) ^ R( 7UL,   (x)))
#define sigma1_512(x)   (ROTATE(19UL, (x)) ^ ROTATE(61UL, (x)) ^ R( 6UL,   (x)))


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


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,ulong8 singlehash)
{
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,ulong8 singlehash)
{
ulong A,B,C,D,E,F,G,H,jj,T1;
uint tmp1,tmp2,elem,l,sz;
__local uint x[64][30];
uint a1,a2,a3,a4,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16,c1,c2,c3,c4,i,ic;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16; 
ulong SIZE;


a1=input[get_global_id(0)*24];
a2=input[get_global_id(0)*24+1];
a3=input[get_global_id(0)*24+2];
a4=input[get_global_id(0)*24+3];

b1=input[get_global_id(0)*24+4];
b2=input[get_global_id(0)*24+5];
b3=input[get_global_id(0)*24+6];
b4=input[get_global_id(0)*24+7];
b5=input[get_global_id(0)*24+8];
b6=input[get_global_id(0)*24+9];
b7=input[get_global_id(0)*24+10];
b8=input[get_global_id(0)*24+11];
b9=input[get_global_id(0)*24+12];
b10=input[get_global_id(0)*24+13];
b11=input[get_global_id(0)*24+14];
b12=input[get_global_id(0)*24+15];
b13=input[get_global_id(0)*24+16];
b14=input[get_global_id(0)*24+17];
b15=input[get_global_id(0)*24+18];
b16=input[get_global_id(0)*24+19];

c1=input[get_global_id(0)*24+20];
c2=input[get_global_id(0)*24+21];
c3=input[get_global_id(0)*24+22];
c4=input[get_global_id(0)*24+23];

sz = salt.sC;


for (i=salt.sA;i<salt.sB;i++)
{
x[GLI][0]=x[GLI][1]=x[GLI][2]=x[GLI][3]=x[GLI][4]=x[GLI][5]=x[GLI][6]=x[GLI][7]=0;
x[GLI][8]=x[GLI][9]=x[GLI][10]=x[GLI][11]=x[GLI][12]=x[GLI][13]=x[GLI][14]=x[GLI][15]=0;
x[GLI][16]=x[GLI][17]=x[GLI][18]=x[GLI][19]=x[GLI][20]=x[GLI][21]=x[GLI][22]=x[GLI][23]=0;
x[GLI][24]=x[GLI][25]=x[GLI][26]=x[GLI][27]=x[GLI][28]=x[GLI][29]=0;
ic=0;
if ((i&1)==0)
{
x[GLI][0]=b1;
x[GLI][1]=b2;
x[GLI][2]=b3;
x[GLI][3]=b4;
x[GLI][4]=b5;
x[GLI][5]=b6;
x[GLI][6]=b7;
x[GLI][7]=b8;
x[GLI][8]=b9;
x[GLI][9]=b10;
x[GLI][10]=b11;
x[GLI][11]=b12;
x[GLI][12]=b13;
x[GLI][13]=b14;
x[GLI][14]=b15;
x[GLI][15]=b16;
ic=64;
}
else
{
x[GLI][0]=c1;
x[GLI][1]=c2;
x[GLI][2]=c3;
x[GLI][3]=c4;
ic=sz;
}

if ((i%3)!=0)
{
SET_ABR(x[GLI],a1,ic);
SET_ABR(x[GLI],a2,ic+4);
SET_ABR(x[GLI],a3,ic+8);
SET_ABR(x[GLI],a4,ic+12);
ic+=salt.sD;
}
if ((i%7)!=0)
{
SET_ABR(x[GLI],c1,ic);
SET_ABR(x[GLI],c2,ic+4);
SET_ABR(x[GLI],c3,ic+8);
SET_ABR(x[GLI],c4,ic+12);
ic+=sz;
}
if ((i&1)==0)
{
SET_ABR(x[GLI],c1,ic);
SET_ABR(x[GLI],c2,ic+4);
SET_ABR(x[GLI],c3,ic+8);
SET_ABR(x[GLI],c4,ic+12);
ic+=sz;
}
else
{
SET_ABR(x[GLI],b1,ic);
SET_ABR(x[GLI],b2,ic+4);
SET_ABR(x[GLI],b3,ic+8);
SET_ABR(x[GLI],b4,ic+12);
SET_ABR(x[GLI],b5,ic+16);
SET_ABR(x[GLI],b6,ic+20);
SET_ABR(x[GLI],b7,ic+24);
SET_ABR(x[GLI],b8,ic+28);
SET_ABR(x[GLI],b9,ic+32);
SET_ABR(x[GLI],b10,ic+36);
SET_ABR(x[GLI],b11,ic+40);
SET_ABR(x[GLI],b12,ic+44);
SET_ABR(x[GLI],b13,ic+48);
SET_ABR(x[GLI],b14,ic+52);
SET_ABR(x[GLI],b15,ic+56);
SET_ABR(x[GLI],b16,ic+60);
ic+=64;
}

SET_ABR(x[GLI],0x80000000,ic);


w0=x[GLI][0];
w0=w0<<32;
w0|=x[GLI][1];
w1=x[GLI][2];
w1=w1<<32;
w1|=x[GLI][3];
w2=x[GLI][4];
w2=w2<<32;
w2|=x[GLI][5];
w3=x[GLI][6];
w3=w3<<32;
w3|=x[GLI][7];
w4=x[GLI][8];
w4=w4<<32;
w4|=x[GLI][9];
w5=x[GLI][10];
w5=w5<<32;
w5|=x[GLI][11];
w6=x[GLI][12];
w6=w6<<32;
w6|=x[GLI][13];
w7=x[GLI][14];
w7=w7<<32;
w7|=x[GLI][15];
w8=x[GLI][16];
w8=w8<<32;
w8|=x[GLI][17];
w9=x[GLI][18];
w9=w9<<32;
w9|=x[GLI][19];
w10=x[GLI][20];
w10=w10<<32;
w10|=x[GLI][21];
w11=x[GLI][22];
w11=w11<<32;
w11|=x[GLI][23];
w12=x[GLI][24];
w12=w12<<32;
w12|=x[GLI][25];
w13=x[GLI][26];
w13=w13<<32;
w13|=x[GLI][27];
w14=x[GLI][28];
w14=w13<<32;
w14|=x[GLI][29];
SIZE = ic<<3;


A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;


ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,w7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,w8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,w9);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC11,w10);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC12,w11);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC13,w12);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC14,w13);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC15,w14);
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

A+=(ulong)H0;
B+=(ulong)H1;
C+=(ulong)H2;
D+=(ulong)H3;
E+=(ulong)H4;
F+=(ulong)H5;
G+=(ulong)H6;
H+=(ulong)H7;

b2 = (uint)((ulong)A/*&0xFFFFFFFF*/);
b1 = (uint)((ulong)A>>32);
b4 = (uint)((ulong)B/*&0xFFFFFFFF*/);
b3 = (uint)((ulong)B>>32);
b6 = (uint)((ulong)C/*&0xFFFFFFFF*/);
b5 = (uint)((ulong)C>>32);
b8 = (uint)((ulong)D/*&0xFFFFFFFF*/);
b7 = (uint)((ulong)D>>32);
b10 = (uint)((ulong)E/*&0xFFFFFFFF*/);
b9 = (uint)((ulong)E>>32);
b12 = (uint)((ulong)F/*&0xFFFFFFFF*/);
b11 = (uint)((ulong)F>>32);
b14 = (uint)((ulong)G/*&0xFFFFFFFF*/);
b13 = (uint)((ulong)G>>32);
b16 = (uint)((ulong)H/*&0xFFFFFFFF*/);
b15 = (uint)((ulong)H>>32);
}


dst[get_global_id(0)*24+4]=b1;
dst[get_global_id(0)*24+5]=b2;
dst[get_global_id(0)*24+6]=b3;
dst[get_global_id(0)*24+7]=b4;
dst[get_global_id(0)*24+8]=b5;
dst[get_global_id(0)*24+9]=b6;
dst[get_global_id(0)*24+10]=b7;
dst[get_global_id(0)*24+11]=b8;
dst[get_global_id(0)*24+12]=b9;
dst[get_global_id(0)*24+13]=b10;
dst[get_global_id(0)*24+14]=b11;
dst[get_global_id(0)*24+15]=b12;
dst[get_global_id(0)*24+16]=b13;
dst[get_global_id(0)*24+17]=b14;
dst[get_global_id(0)*24+18]=b15;
dst[get_global_id(0)*24+19]=b16;

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global ulong8 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 salt,ulong8 singlehash)
{
ulong A,B,C,D,E,F,G,H;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint tmp1,tmp2,elem,l;

b1=input[get_global_id(0)*24+4];
b2=input[get_global_id(0)*24+5];
b3=input[get_global_id(0)*24+6];
b4=input[get_global_id(0)*24+7];
b5=input[get_global_id(0)*24+8];
b6=input[get_global_id(0)*24+9];
b7=input[get_global_id(0)*24+10];
b8=input[get_global_id(0)*24+11];
b9=input[get_global_id(0)*24+12];
b10=input[get_global_id(0)*24+13];
b11=input[get_global_id(0)*24+14];
b12=input[get_global_id(0)*24+15];
b13=input[get_global_id(0)*24+16];
b14=input[get_global_id(0)*24+17];
b15=input[get_global_id(0)*24+18];
b16=input[get_global_id(0)*24+19];

Endian_Reverse32(b1);
Endian_Reverse32(b2);
Endian_Reverse32(b3);
Endian_Reverse32(b4);
Endian_Reverse32(b5);
Endian_Reverse32(b6);
Endian_Reverse32(b7);
Endian_Reverse32(b8);
Endian_Reverse32(b9);
Endian_Reverse32(b10);
Endian_Reverse32(b11);
Endian_Reverse32(b12);
Endian_Reverse32(b13);
Endian_Reverse32(b14);
Endian_Reverse32(b15);
Endian_Reverse32(b16);


A=b2;
A=A<<32;
A|=b1;
B=b4;
B=B<<32;
B|=b3;
C=b6;
C=C<<32;
C|=b5;
D=b8;
D=D<<32;
D|=b7;
E=b10;
E=E<<32;
E|=b9;
F=b12;
F=F<<32;
F|=b11;
G=b14;
G=G<<32;
G|=b13;
H=b16;
H=H<<32;
H|=b15;

if ((ulong)singlehash.s0!=A) return;
if ((ulong)singlehash.s1!=B) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (ulong8)(A,B,C,D,E,F,G,H);

}
