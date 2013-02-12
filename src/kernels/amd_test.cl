#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }


// borrowed from JtR's rar kernel
#define PUTCHAR(buf, index, val) (buf)[(index)>>2] = ((buf)[(index)>>2] & ~(0xffU << (((index) & 3) << 3))) + ((val) << (((index) & 3) << 3))
#define GETCHAR(buf, index) (((buf)[(index)>>2] >> (((index)&3)<<3))&255)

__constant uint ident[64] =
{
0x03020100U, 0x07060504U, 0x0b0a0908U, 0x0f0e0d0cU, 
0x13121110U, 0x17161514U, 0x1b1a1918U, 0x1f1e1d1cU,
0x23222120U, 0x27262524U, 0x2b2a2928U, 0x2f2e2d2cU,
0x33323130U, 0x37363534U, 0x3b3a3938U, 0x3f3e3d3cU,
0x43424140U, 0x47464544U, 0x4b4a4948U, 0x4f4e4d4cU,
0x53525150U, 0x57565554U, 0x5b5a5958U, 0x5f5e5d5cU,
0x63626160U, 0x67666564U, 0x6b6a6968U, 0x6f6e6d6cU,
0x73727170U, 0x77767574U, 0x7b7a7978U, 0x7f7e7d7cU,
0x83828180U, 0x87868584U, 0x8b8a8988U, 0x8f8e8d8cU,
0x93929190U, 0x97969594U, 0x9b9a9998U, 0x9f9e9d9cU,
0xa3a2a1a0U, 0xa7a6a5a4U, 0xabaaa9a8U, 0xafaeadacU,
0xb3b2b1b0U, 0xb7b6b5b4U, 0xbbbab9b8U, 0xbfbebdbcU,
0xc3c2c1c0U, 0xc7c6c5c4U, 0xcbcac9c8U, 0xcfcecdccU,
0xd3d2d1d0U, 0xd7d6d5d4U, 0xdbdad9d8U, 0xdfdedddcU,
0xe3e2e1e0U, 0xe7e6e5e4U, 0xebeae9e8U, 0xefeeedecU,
0xf3f2f1f0U, 0xf7f6f5f4U, 0xfbfaf9f8U, 0xfffefdfcU
};



__kernel void __attribute__((reqd_work_group_size(64, 1, 1)))
test( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash, uint16 salt,uint16 str, uint16 str1) 
{
uint w0,w1,w2,w3,w4,w5,w6,w7;
uint i,j,k,id,a,b,c,d,v,shiftj,sj,u,si,sw,tmp;
__local uint state[64][64];
__private uint key[4];
__private uint out[4];

#pragma unroll 32
for (i=0;i<64;i++) state[GLI][i]=ident[i];

/*
j=0;
for (i=0;i<256;i+=4)
{
si=state[GLI][i>>2];

u=si&0xff;
j=(j+((key[i>>2])&255)+u)&0xff;
sj=state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si=(si&0xffffff00)|v;
sj=(sj& ~(0xffu<<shiftj))|(u<<shiftj);
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? (si& ~(0xffu<<shiftj))|(u<<shiftj) : si;


u=(si>>8)&0xff;
j=(j+((key[i>>2]>>8)&255)+u)&0xff;
sj=state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si=(si&0xffff00ff)|(v<<8);
sj=(sj& ~(0xffu<<shiftj))|(u<<shiftj);
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? (si& ~(0xffu<<shiftj))|(u<<shiftj) : si;

u=(si>>16)&0xff;
j=(j+((key[i>>2]>>16)&255)+u)&0xff;
sj=state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si=(si&0xff00ffff)|(v<<16);
sj=(sj& ~(0xffu<<shiftj))|(u<<shiftj);
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? (si& ~(0xffu<<shiftj))|(u<<shiftj) : si;

u=(si>>24)&0xff;
j=(j+((key[i>>2]>>24)&255)+u)&0xff;
sj=state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si=(si&0x00ffffff)|(v<<24);
sj=(sj& ~(0xffu<<shiftj))|(u<<shiftj);
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? (si& ~(0xffu<<shiftj))|(u<<shiftj) : si;

state[GLI][i>>2]=si;
}
*/

j=0;
for (i=0;i<256;i+=4)
{
si=state[GLI][i>>2];

u=si&0xff;
j=(j+(key[i>>2])+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v,si,0xffffff00U);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>8)&0xff;
j=(j+(key[i>>2]>>8)+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<8,si,0xffff00ffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>16)&0xff;
j=(j+(key[i>>2]>>16)+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<16,si,0xff00ffffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

u=(si>>24)&0xff;
j=(j+(key[i>>2]>>24)+u)&0xff;
sj=((j>>2)==(i>>2)) ? si : state[GLI][j>>2];
shiftj=(j&3)<<3;
v=(sj>>shiftj)&0xff;
si = bitselect(v<<24,si,0x00ffffffU);
sj = bitselect(u<<shiftj,sj,~(0xffu<<shiftj));
state[GLI][j>>2] = sj;
si = ((j>>2)==(i>>2)) ? bitselect(u<<shiftj,si,~(0xffu<<shiftj)) : si;

state[GLI][i>>2]=si;
}


i=0;
j=0;
for (k=0;k<8;k++)
{
i=(i+1)&255;
v=GETCHAR(state[GLI],i);
j=(j+v)&255;
shiftj=GETCHAR(state[GLI],j);
PUTCHAR(out,k,GETCHAR(state[GLI],(v+shiftj)&255));
}


a=out[0];
b=out[1];
c=out[2];
d=out[3];


/*
id=get_global_id(0);
w0 = inp[GGI*8+0];
w1 = inp[GGI*8+1];
w2 = inp[GGI*8+2];
w3 = inp[GGI*8+3];
w4 = inp[GGI*8+4];
w5 = inp[GGI*8+5];
w6 = inp[GGI*8+6];
w7 = inp[GGI*8+7];
*/


if (((uint)singlehash.x != a)) return; 
if (((uint)singlehash.y != b)) return; 


found[0] = 1;
found_ind[get_global_id(0)] = 1;


dst[(get_global_id(0))] = (uint4)(a,b,c,d);

}


