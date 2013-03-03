#define rotate(a,b) ((a) << (b)) + ((a) >> (32-(b)))

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *sizein, uint16 str, uint16 salt)
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

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);


dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}

#define Sl 8U
#define Sr 24U
#define m 0x00FF00FFU
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }


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
void prepare( __global ulong *dst,  __global uint *input, __global ulong *input1, uint16 str, uint16 salt)
{
ulong SIZE;  
uint ib,ic,id;  
uint ta,tb,tc,td,te,tf,tg,th;
uint tmp1,tmp2,l,t1; 
ulong w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
ulong A,B,C,D,E,F,G,H,T1;
ulong IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;

TTA=TTB=TTC=TTD=TTE=(ulong)0;

ta=input[get_global_id(0)*8];
tb=input[get_global_id(0)*8+1];
tc=input[get_global_id(0)*8+2];
td=input[get_global_id(0)*8+3];
te=input[get_global_id(0)*8+4];
tf=input[get_global_id(0)*8+5];
tg=input[get_global_id(0)*8+6];
th=input[get_global_id(0)*8+7];


// Initial HMAC (for PBKDF2)
// Calculate sha1(ipad^key)
w0 = 0x36363636 ^ (ulong)(tb);
w0 = (w0<<32)|(0x36363636 ^ (ulong)(ta));
w1 = 0x36363636 ^ (ulong)(td);
w1 = (w1<<32)|(0x36363636 ^ (ulong)(tc));
w2 = 0x36363636 ^ (ulong)(tf);
w2 = (w2<<32)|(0x36363636 ^ (ulong)(te));
w3 = 0x36363636 ^ (ulong)(th);
w3 = (w3<<32)|(0x36363636 ^ (ulong)(tg));
w4 =   0x3636363636363636L;
w5 =   0x3636363636363636L;
w6 =   0x3636363636363636L;
w7 =   0x3636363636363636L;
w8 =   0x3636363636363636L;
w9 =   0x3636363636363636L;
w10 =  0x3636363636363636L;
w11 =  0x3636363636363636L;
w12 =  0x3636363636363636L;
w13 =  0x3636363636363636L;
w14 =  0x3636363636363636L;
SIZE = 0x3636363636363636L;



A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;

Endian_Reverse64(w0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
Endian_Reverse64(w1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
Endian_Reverse64(w2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
Endian_Reverse64(w3);
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

IPA=A;
IPB=B;
IPC=C;
IPD=D;
IPE=E;
IPF=F;
IPG=G;
IPH=H;


w0 = 0x5c5c5c5c ^ (ulong)(tb);
w0 = (w0<<32)|(0x5c5c5c5c ^ (ulong)(ta));
w1 = 0x5c5c5c5c ^ (ulong)(td);
w1 = (w1<<32)|(0x5c5c5c5c ^ (ulong)(tc));
w2 = 0x5c5c5c5c ^ (ulong)(tf);
w2 = (w2<<32)|(0x5c5c5c5c ^ (ulong)(te));
w3 = 0x5c5c5c5c ^ (ulong)(th);
w3 = (w3<<32)|(0x5c5c5c5c ^ (ulong)(tg));
w4 = 0x5c5c5c5c5c5c5c5cL;
w5 = 0x5c5c5c5c5c5c5c5cL;
w6 = 0x5c5c5c5c5c5c5c5cL;
w7 = 0x5c5c5c5c5c5c5c5cL;
w8 = 0x5c5c5c5c5c5c5c5cL;
w9 = 0x5c5c5c5c5c5c5c5cL;
w10 = 0x5c5c5c5c5c5c5c5cL;
w11 = 0x5c5c5c5c5c5c5c5cL;
w12 = 0x5c5c5c5c5c5c5c5cL;
w13 = 0x5c5c5c5c5c5c5c5cL;
w14 = 0x5c5c5c5c5c5c5c5cL;
SIZE = 0x5c5c5c5c5c5c5c5cL;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;

Endian_Reverse64(w0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
Endian_Reverse64(w1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
Endian_Reverse64(w2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
Endian_Reverse64(w3);
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

OPA=A;
OPB=B;
OPC=C;
OPD=D;
OPE=E;
OPF=F;
OPG=G;
OPH=H;




// calculate hash sum 1

w0 = (ulong)salt.s1;
w0 = (w0<<32)|((ulong)salt.s0);
w1 = (ulong)salt.s3;
w1 = (w1<<32)|((ulong)salt.s2);
w2 = (ulong)salt.s5;
w2 = (w2<<32)|((ulong)salt.s4);
w3 = (ulong)salt.s7;
w3 = (w3<<32)|((ulong)salt.s6);
w4 = (ulong)salt.s9;
w4 = (w4<<32)|((ulong)salt.s8);
w5 = (ulong)salt.sB;
w5 = (w5<<32)|((ulong)salt.sA);
w6 = (ulong)salt.sD;
w6 = (w6<<32)|((ulong)salt.sC);
w7 = (ulong)salt.sF;
w7 = (w7<<32)|((ulong)salt.sE);
t1=(uint)(0x01000000U);
//Endian_Reverse32(t1);
w8=0x80;
w8=(w8<<32)|(ulong)(t1);
w9=w10=w11=w12=w13=w14=(ulong)0;
SIZE=(ulong)(128+64+4)<<3;


A=(ulong)IPA;
B=(ulong)IPB;
C=(ulong)IPC;
D=(ulong)IPD;
E=(ulong)IPE;
F=(ulong)IPF;
G=(ulong)IPG;
H=(ulong)IPH;

Endian_Reverse64(w0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
Endian_Reverse64(w1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
Endian_Reverse64(w2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
Endian_Reverse64(w3);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
Endian_Reverse64(w4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
Endian_Reverse64(w5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
Endian_Reverse64(w6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
Endian_Reverse64(w7);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,w7);
Endian_Reverse64(w8);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,w8);
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

A+=(ulong)IPA;
B+=(ulong)IPB;
C+=(ulong)IPC;
D+=(ulong)IPD;
E+=(ulong)IPE;
F+=(ulong)IPF;
G+=(ulong)IPG;
H+=(ulong)IPH;





// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(ulong)0x8000000000000000L;
w9=w10=w11=w12=w13=w14=w16=(ulong)0;
SIZE=(ulong)((128+64)<<3);
A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;


ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,w7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,w8);
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


A=A+OPA;
B=B+OPB;
C=C+OPC;
D=D+OPD;
E=E+OPE;
F=F+OPF;
G=G+OPG;
H=H+OPH;

TTA=A;TTB=B;TTC=C;TTD=D;TTE=E;TTF=F;TTG=G;TTH=H;


input1[get_global_id(0)*2*8+0]=IPA;
input1[get_global_id(0)*2*8+1]=IPB;
input1[get_global_id(0)*2*8+2]=IPC;
input1[get_global_id(0)*2*8+3]=IPD;
input1[get_global_id(0)*2*8+4]=IPE;
input1[get_global_id(0)*2*8+5]=IPF;
input1[get_global_id(0)*2*8+6]=IPG;
input1[get_global_id(0)*2*8+7]=IPH;
input1[get_global_id(0)*2*8+8]=OPA;
input1[get_global_id(0)*2*8+9]=OPB;
input1[get_global_id(0)*2*8+10]=OPC;
input1[get_global_id(0)*2*8+11]=OPD;
input1[get_global_id(0)*2*8+12]=OPE;
input1[get_global_id(0)*2*8+13]=OPF;
input1[get_global_id(0)*2*8+14]=OPG;
input1[get_global_id(0)*2*8+15]=OPH;


dst[get_global_id(0)*2*8+0]=TTA;
dst[get_global_id(0)*2*8+1]=TTB;
dst[get_global_id(0)*2*8+2]=TTC;
dst[get_global_id(0)*2*8+3]=TTD;
dst[get_global_id(0)*2*8+4]=TTE;
dst[get_global_id(0)*2*8+5]=TTF;
dst[get_global_id(0)*2*8+6]=TTG;
dst[get_global_id(0)*2*8+7]=TTH;
dst[get_global_id(0)*2*8+8]=TTA;
dst[get_global_id(0)*2*8+9]=TTB;
dst[get_global_id(0)*2*8+10]=TTC;
dst[get_global_id(0)*2*8+11]=TTD;
dst[get_global_id(0)*2*8+12]=TTE;
dst[get_global_id(0)*2*8+13]=TTF;
dst[get_global_id(0)*2*8+14]=TTG;
dst[get_global_id(0)*2*8+15]=TTH;

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf( __global ulong *dst,  __global ulong *input, __global ulong *input1, uint16 str, uint16 salt)
{
ulong SIZE;  
uint ib,ic,id;  
uint a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
ulong w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
ulong A,B,C,D,E,F,G,H,T1;
ulong IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


TTA=dst[get_global_id(0)*2*8+0];
TTB=dst[get_global_id(0)*2*8+1];
TTC=dst[get_global_id(0)*2*8+2];
TTD=dst[get_global_id(0)*2*8+3];
TTE=dst[get_global_id(0)*2*8+4];
TTF=dst[get_global_id(0)*2*8+5];
TTG=dst[get_global_id(0)*2*8+6];
TTH=dst[get_global_id(0)*2*8+7];
A=dst[get_global_id(0)*2*8+8];
B=dst[get_global_id(0)*2*8+9];
C=dst[get_global_id(0)*2*8+10];
D=dst[get_global_id(0)*2*8+11];
E=dst[get_global_id(0)*2*8+12];
F=dst[get_global_id(0)*2*8+13];
G=dst[get_global_id(0)*2*8+14];
H=dst[get_global_id(0)*2*8+15];

IPA=input1[get_global_id(0)*2*8+0];
IPB=input1[get_global_id(0)*2*8+1];
IPC=input1[get_global_id(0)*2*8+2];
IPD=input1[get_global_id(0)*2*8+3];
IPE=input1[get_global_id(0)*2*8+4];
IPF=input1[get_global_id(0)*2*8+5];
IPG=input1[get_global_id(0)*2*8+6];
IPH=input1[get_global_id(0)*2*8+7];
OPA=input1[get_global_id(0)*2*8+8];
OPB=input1[get_global_id(0)*2*8+9];
OPC=input1[get_global_id(0)*2*8+10];
OPD=input1[get_global_id(0)*2*8+11];
OPE=input1[get_global_id(0)*2*8+12];
OPF=input1[get_global_id(0)*2*8+13];
OPG=input1[get_global_id(0)*2*8+14];
OPH=input1[get_global_id(0)*2*8+15];


// We now have the first HMAC. Iterate to find the rest
for (ic=str.sA;ic<str.sB;ic++)
{

// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(ulong)0x8000000000000000L;
SIZE=(ulong)(128+64)<<3;
w9=w10=w11=w12=w13=w14=(ulong)0;

A=IPA;
B=IPB;
C=IPC;
D=IPD;
E=IPE;
F=IPF;
G=IPG;
H=IPH;

ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,w7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,w8);
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

A+=(ulong)IPA;
B+=(ulong)IPB;
C+=(ulong)IPC;
D+=(ulong)IPD;
E+=(ulong)IPE;
F+=(ulong)IPF;
G+=(ulong)IPG;
H+=(ulong)IPH;



// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(ulong)0x8000000000000000L;
SIZE=(ulong)(128+64)<<3;
w9=w10=w11=w12=w13=w14=(ulong)0;

A=OPA;
B=OPB;
C=OPC;
D=OPD;
E=OPE;
F=OPF;
G=OPG;
H=OPH;

ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,w0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,w1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,w2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,w3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,w7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,w8);
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

A+=(ulong)OPA;
B+=(ulong)OPB;
C+=(ulong)OPC;
D+=(ulong)OPD;
E+=(ulong)OPE;
F+=(ulong)OPF;
G+=(ulong)OPG;
H+=(ulong)OPH;


TTA ^= A;
TTB ^= B;
TTC ^= C;
TTD ^= D;
TTE ^= E;
TTF ^= F;
TTG ^= G;
TTH ^= H;

}

dst[get_global_id(0)*2*8+0]=TTA;
dst[get_global_id(0)*2*8+1]=TTB;
dst[get_global_id(0)*2*8+2]=TTC;
dst[get_global_id(0)*2*8+3]=TTD;
dst[get_global_id(0)*2*8+4]=TTE;
dst[get_global_id(0)*2*8+5]=TTF;
dst[get_global_id(0)*2*8+6]=TTG;
dst[get_global_id(0)*2*8+7]=TTH;
dst[get_global_id(0)*2*8+8]=A;
dst[get_global_id(0)*2*8+9]=B;
dst[get_global_id(0)*2*8+10]=C;
dst[get_global_id(0)*2*8+11]=D;
dst[get_global_id(0)*2*8+12]=E;
dst[get_global_id(0)*2*8+13]=F;
dst[get_global_id(0)*2*8+14]=G;
dst[get_global_id(0)*2*8+15]=H;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global ulong *dst,  __global ulong *input, __global ulong *input1, __global uint *found, __global uint *found_ind,ulong8 singlehash)
{
ulong TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,TTTF,TTTG,TTTH,l,tmp1,tmp2;

TTTA=input[get_global_id(0)*2*8+0];
TTTB=input[get_global_id(0)*2*8+1];
TTTC=input[get_global_id(0)*2*8+2];
TTTD=input[get_global_id(0)*2*8+3];
TTTE=input[get_global_id(0)*2*8+4];
TTTF=input[get_global_id(0)*2*8+5];
TTTG=input[get_global_id(0)*2*8+6];
TTTH=input[get_global_id(0)*2*8+7];

Endian_Reverse64(TTTA);
Endian_Reverse64(TTTB);
Endian_Reverse64(TTTC);
Endian_Reverse64(TTTD);
Endian_Reverse64(TTTE);
Endian_Reverse64(TTTF);
Endian_Reverse64(TTTG);
Endian_Reverse64(TTTH);

if ((TTTA!=(ulong)singlehash.s0)) return;
//if ((TTTB!=(ulong)singlehash.s1)) return;
//if ((TTTC!=(ulong)singlehash.s2)) return;
//if ((TTTD!=(ulong)singlehash.s3)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;



dst[(get_global_id(0)*8)]=TTTA;
dst[(get_global_id(0)*8)+1]=TTTB;
dst[(get_global_id(0)*8)+2]=TTTC;
dst[(get_global_id(0)*8)+3]=TTTD;
dst[(get_global_id(0)*8)+4]=TTTE;
dst[(get_global_id(0)*8)+5]=TTTF;
dst[(get_global_id(0)*8)+6]=TTTG;
dst[(get_global_id(0)*8)+7]=TTTH;

}

