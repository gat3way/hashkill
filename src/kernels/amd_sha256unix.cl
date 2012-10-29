
#define SET_AB(ai1,ii1,bb) { \
        ai1[(ii1)>>2] |= (((uint)(bb)) << ((3-((ii1)&3))<<3)); \
        }

#define m 0x00FF00FFU
#define m2 0xFF00FF00U

#define H0 0x6A09E667U
#define H1 0xBB67AE85U
#define H2 0x3C6EF372U
#define H3 0xA54FF53AU
#define H4 0x510E527FU
#define H5 0x9B05688CU
#define H6 0x1F83D9ABU
#define H7 0x5BE0CD19U

#define Sl 8U
#define Sr 24U

#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))


#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}


#define gli (get_local_id(0))


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform00( __global uint *dst,  __global uint *input,uint psize,uint ssize)
{
uint A,B,C,D,E,F,G,H,jj,tmp2,ii,tmp1,elem,l;
__local uint sbytes[64][2];
__local uint pbytes[64][2];
uint ic;
__local uint w[64][17]; 
uint alt[8]; 
uint SIZE;


Endian_Reverse32(input[(get_global_id(0)*16)+0]);
Endian_Reverse32(input[(get_global_id(0)*16)+1]);
Endian_Reverse32(input[(get_global_id(0)*16)+2]);
Endian_Reverse32(input[(get_global_id(0)*16)+3]);
Endian_Reverse32(input[(get_global_id(0)*16)+4]);
Endian_Reverse32(input[(get_global_id(0)*16)+5]);
Endian_Reverse32(input[(get_global_id(0)*16)+6]);
Endian_Reverse32(input[(get_global_id(0)*16)+7]);
Endian_Reverse32(input[(get_global_id(0)*16)+8]);
Endian_Reverse32(input[(get_global_id(0)*16)+9]);
Endian_Reverse32(input[(get_global_id(0)*16)+10]);
Endian_Reverse32(input[(get_global_id(0)*16)+11]);
Endian_Reverse32(input[(get_global_id(0)*16)+12]);
Endian_Reverse32(input[(get_global_id(0)*16)+13]);
Endian_Reverse32(input[(get_global_id(0)*16)+14]);
Endian_Reverse32(input[(get_global_id(0)*16)+15]);


dst[get_global_id(0)*8]=input[(get_global_id(0)*16)+4];
dst[(get_global_id(0)*8)+1]=input[(get_global_id(0)*16)+5];
dst[(get_global_id(0)*8)+2]=input[(get_global_id(0)*16)+6];
dst[(get_global_id(0)*8)+3]=input[(get_global_id(0)*16)+7];
dst[(get_global_id(0)*8)+4]=input[(get_global_id(0)*16)+8];
dst[(get_global_id(0)*8)+5]=input[(get_global_id(0)*16)+9];
dst[(get_global_id(0)*8)+6]=input[(get_global_id(0)*16)+10];
dst[(get_global_id(0)*8)+7]=input[(get_global_id(0)*16)+11];

}

#define SET_AIS(ai1,ai2,ii1) { \
    elem=(ii1)>>2; \
    t1=((ii1)&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2>>(t1)); \
    ai1[elem+1] = select(ai2<<(32U-t1),0U,(t1==0));\
    }



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform( __global uint *dst,  __global uint *input,uint psize,uint ssize,uint start, uint end)
{
uint A,B,C,D,E,F,G,H,jj,tmp2,ii,tmp1,elem;
uint OA,OB,OC,OD,OE,OF,OG,OH;
uint sbytes1,sbytes2,sbytes3,sbytes0;
uint pbytes1,pbytes2,pbytes3,pbytes0;
uint iter;
__local uint w[64][21]; 
uint alt0,alt1,alt2,alt3,alt4,alt5,alt6,alt7; 
uint SIZE;
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,t1;


sbytes0=input[(get_global_id(0)*16)];
sbytes1=input[(get_global_id(0)*16)+1];
sbytes2=input[(get_global_id(0)*16)+2];
sbytes3=input[(get_global_id(0)*16)+3];
pbytes0=input[(get_global_id(0)*16)+12];
pbytes1=input[(get_global_id(0)*16)+13];
pbytes2=input[(get_global_id(0)*16)+14];
pbytes3=input[(get_global_id(0)*16)+15];
A=dst[(get_global_id(0)*8)];
B=dst[(get_global_id(0)*8)+1];
C=dst[(get_global_id(0)*8)+2];
D=dst[(get_global_id(0)*8)+3];
E=dst[(get_global_id(0)*8)+4];
F=dst[(get_global_id(0)*8)+5];
G=dst[(get_global_id(0)*8)+6];
H=dst[(get_global_id(0)*8)+7];


for (iter=start;iter<end;iter++)
{

w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][15]=(uint)0;
w[gli][16]=w[gli][17]=w[gli][18]=w[gli][19]=w[gli][20]=(uint)0;


alt0=A;
alt1=B;
alt2=C;
alt3=D;
alt4=E;
alt5=F;
alt6=G;
alt7=H;

if ((iter&1)==0)
{
w[gli][0]=A;
w[gli][1]=B;
w[gli][2]=C;
w[gli][3]=D;
w[gli][4]=E;
w[gli][5]=F;
w[gli][6]=G;
w[gli][7]=H;
jj=32;
}
else
{
w[gli][0]=pbytes0;
w[gli][1]=pbytes1;
w[gli][2]=pbytes2;
w[gli][3]=pbytes3;
jj=psize;
}


if ((iter%3)!=0)
{
SET_AIS(w[gli],sbytes0,jj);
SET_AIS(w[gli],sbytes1,jj+4);
SET_AIS(w[gli],sbytes2,jj+8);
SET_AIS(w[gli],sbytes3,jj+12);
jj+=16;
}

if ((iter%7)!=0)
{
SET_AIS(w[gli],pbytes0,jj);
SET_AIS(w[gli],pbytes1,jj+4);
SET_AIS(w[gli],pbytes2,jj+8);
SET_AIS(w[gli],pbytes3,jj+12);
jj+=psize;
}


if ((iter&1)==0)
{
SET_AIS(w[gli],pbytes0,jj);
SET_AIS(w[gli],pbytes1,jj+4);
SET_AIS(w[gli],pbytes2,jj+8);
SET_AIS(w[gli],pbytes3,jj+12);
jj+=psize;
}
else
{
SET_AIS(w[gli],alt0,jj);
SET_AIS(w[gli],alt1,jj+4);
SET_AIS(w[gli],alt2,jj+8);
SET_AIS(w[gli],alt3,jj+12);
SET_AIS(w[gli],alt4,jj+16);
SET_AIS(w[gli],alt5,jj+20);
SET_AIS(w[gli],alt6,jj+24);
SET_AIS(w[gli],alt7,jj+28);
jj+=32;
}


SET_AIS(w[gli],(uint)0x80000000,jj);


w0=w[gli][0];
w1=w[gli][1];
w2=w[gli][2];
w3=w[gli][3];
w4=w[gli][4];
w5=w[gli][5];
w6=w[gli][6];
w7=w[gli][7];
w8=w[gli][8];
w9=w[gli][9];
w10=w[gli][10];
w11=w[gli][11];
w12=w[gli][12];
w13=w[gli][13];
w14=w[gli][14];
SIZE = (jj>55) ? (w[gli][15]) : ((uint)(jj<<3));
A=(uint)H0;
B=(uint)H1;
C=(uint)H2;
D=(uint)H3;
E=(uint)H4;
F=(uint)H5;
G=(uint)H6;
H=(uint)H7;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01);
P(G, H, A, B, C, D, E, F, w10, 0x243185BE);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FE);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+(uint)H0;
B=B+(uint)H1;
C=C+(uint)H2;
D=D+(uint)H3;
E=E+(uint)H4;
F=F+(uint)H5;
G=G+(uint)H6;
H=H+(uint)H7;

if (jj>55)
{
w0=w[gli][16];
w1=w[gli][17];
w2=w[gli][18];
w3=w[gli][19];
w4=w[gli][20];
w5=(uint)0;
w6=(uint)0;
w7=(uint)0;
w8=(uint)0;
w9=(uint)0;
w10=(uint)0;
w11=(uint)0;
w12=(uint)0;
w13=(uint)0;
w14=(uint)0;
SIZE = (jj<<3);
OA=A;OB=B;OC=C;OD=D;OE=E;OF=F;OG=G;OH=H;

P(A, B, C, D, E, F, G, H, w0, 0x428A2F98);
P(H, A, B, C, D, E, F, G, w1, 0x71374491);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCF);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25B);
P0(D, E, F, G, H, A, B, C, 0x59F111F1);
P0(C, D, E, F, G, H, A, B, 0x923F82A4);
P0(B, C, D, E, F, G, H, A, 0xAB1C5ED5);
P0(A, B, C, D, E, F, G, H, 0xD807AA98);
P0(H, A, B, C, D, E, F, G, 0x12835B01);
P0(G, H, A, B, C, D, E, F, 0x243185BE);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FE);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174);
w16=S1(w14)+w9+S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1);
w0=S1(SIZE)+w10+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786);
w1=S1(w16)+w11+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6);
w2=S1(w0)+w12+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CC);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6F);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AA);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DC);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DA);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66D);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFC);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABB);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92E);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664B);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774C);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4A);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4F);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EE);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636F);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFA);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEB);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2);

A=A+(uint)OA;
B=B+(uint)OB;
C=C+(uint)OC;
D=D+(uint)OD;
E=E+(uint)OE;
F=F+(uint)OF;
G=G+(uint)OG;
H=H+(uint)OH;
}
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
final( __global uint8 *dst,  __global uint *input,__global uint *found_ind, __global uint *found,uint8 singlehash)
{
uint A,B,C,D,E,F,G,H,jj,tmp2,ii,tmp1,elem,l;
uint ic;
uint SIZE;
uint w0,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14;


A=input[(get_global_id(0)*8)];
B=input[(get_global_id(0)*8)+1];
C=input[(get_global_id(0)*8)+2];
D=input[(get_global_id(0)*8)+3];
E=input[(get_global_id(0)*8)+4];
F=input[(get_global_id(0)*8)+5];
G=input[(get_global_id(0)*8)+6];
H=input[(get_global_id(0)*8)+7];

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);
Endian_Reverse32(F);
Endian_Reverse32(G);
Endian_Reverse32(H);

if (singlehash.s0!=A) return;
if (singlehash.s1!=B) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;
dst[get_global_id(0)] = (uint8)(A,B,C,D,E,F,G,H);
}


