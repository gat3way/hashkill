// Dummy one
__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
size[get_global_id(0)]=sizein[get_global_id(0)];
}


#ifndef GCN
#define Endian_Reverse64(a)  (((a) & 0x00000000000000FFL) << 56 | ((a) & 0x000000000000FF00L) << 40 | \
                              ((a) & 0x0000000000FF0000L) << 24 | ((a) & 0x00000000FF000000L) << 8 | \
                              ((a) & 0x000000FF00000000L) >> 8 | ((a) & 0x0000FF0000000000L) >> 24 | \
                              ((a) & 0x00FF000000000000L) >> 40 | ((a) & 0xFF00000000000000L) >> 56)
#else
#define Endian_Reverse64(n)       (as_ulong(as_uchar8(n).s76543210))
#endif


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
	ai1[elem+1] = (tmp1==0) ? (ulong)0 : (ai2<<(64-tmp1));\
        }





#define gli (get_local_id(0))

__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform00( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;


elem=input[(get_global_id(0)*12)];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)]=elem;
elem=input[(get_global_id(0)*12)+1];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+1]=elem;
elem=input[(get_global_id(0)*12)+2];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+2]=elem;
input1[(get_global_id(0)*8)+0]=elem;
elem=input[(get_global_id(0)*12)+3];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+3]=elem;
input1[(get_global_id(0)*8)+1]=elem;
elem=input[(get_global_id(0)*12)+4];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+4]=elem;
input1[(get_global_id(0)*8)+2]=elem;
elem=input[(get_global_id(0)*12)+5];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+5]=elem;
input1[(get_global_id(0)*8)+3]=elem;
elem=input[(get_global_id(0)*12)+6];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+6]=elem;
input1[(get_global_id(0)*8)+4]=elem;
elem=input[(get_global_id(0)*12)+7];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+7]=elem;
input1[(get_global_id(0)*8)+5]=elem;
elem=input[(get_global_id(0)*12)+8];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+8]=elem;
input1[(get_global_id(0)*8)+6]=elem;
elem=input[(get_global_id(0)*12)+9];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+9]=elem;
input1[(get_global_id(0)*8)+7]=elem;
elem=input[(get_global_id(0)*12)+10];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+10]=elem;
elem=input[(get_global_id(0)*12)+11];
elem=Endian_Reverse64(elem);
input[(get_global_id(0)*12)+11]=elem;

}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform0( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];



w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)0;

w[gli][0]=A;
w[gli][1]=B;
w[gli][2]=C;
w[gli][3]=D;
w[gli][4]=E;
w[gli][5]=F;
w[gli][6]=G;
w[gli][7]=H;
ii=(uint)64;

jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;

SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform03( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];


w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)0;

w[gli][0]=A;
w[gli][1]=B;
w[gli][2]=C;
w[gli][3]=D;
w[gli][4]=E;
w[gli][5]=F;
w[gli][6]=G;
w[gli][7]=H;
ii=(uint)64;

jj=ii;
SET_AIS(w[gli],sbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],sbytes[gli][1],ii,8);ii+=8;
ii=jj+ssize;

jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;

SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);




dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform07( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];

w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)0;

w[gli][0]=A;
w[gli][1]=B;
w[gli][2]=C;
w[gli][3]=D;
w[gli][4]=E;
w[gli][5]=F;
w[gli][6]=G;
w[gli][7]=H;
ii=(uint)64;


jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;
jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;

SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform037( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];


w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)0;

w[gli][0]=A;
w[gli][1]=B;
w[gli][2]=C;
w[gli][3]=D;
w[gli][4]=E;
w[gli][5]=F;
w[gli][6]=G;
w[gli][7]=H;
ii=(uint)64;

jj=ii;
SET_AIS(w[gli],sbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],sbytes[gli][1],ii,8);ii+=8;
ii=jj+ssize;

jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;


jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=8;
ii=jj+psize;

SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform1( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];


w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)psize;

w[gli][0]=pbytes[gli][0];
w[gli][1]=pbytes[gli][1];



SET_AIS(w[gli],alt[0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],alt[1],ii,8);ii+=(uint)8;
SET_AIS(w[gli],alt[2],ii,16);ii+=(uint)8;
SET_AIS(w[gli],alt[3],ii,24);ii+=(uint)8;
SET_AIS(w[gli],alt[4],ii,32);ii+=(uint)8;
SET_AIS(w[gli],alt[5],ii,40);ii+=(uint)8;
SET_AIS(w[gli],alt[6],ii,48);ii+=(uint)8;
SET_AIS(w[gli],alt[7],ii,56);ii+=(uint)8;


SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform13( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];

w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)psize;

w[gli][0]=pbytes[gli][0];
w[gli][1]=pbytes[gli][1];

jj=ii;
SET_AIS(w[gli],sbytes[gli][0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],sbytes[gli][1],ii,8);ii+=(uint)8;
ii=jj+ssize;


SET_AIS(w[gli],alt[0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],alt[1],ii,8);ii+=(uint)8;
SET_AIS(w[gli],alt[2],ii,16);ii+=(uint)8;
SET_AIS(w[gli],alt[3],ii,24);ii+=(uint)8;
SET_AIS(w[gli],alt[4],ii,32);ii+=(uint)8;
SET_AIS(w[gli],alt[5],ii,40);ii+=(uint)8;
SET_AIS(w[gli],alt[6],ii,48);ii+=(uint)8;
SET_AIS(w[gli],alt[7],ii,56);ii+=(uint)8;


SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform17( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];

w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)psize;

w[gli][0]=pbytes[gli][0];
w[gli][1]=pbytes[gli][1];

jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=(uint)8;
ii=jj+psize;

SET_AIS(w[gli],alt[0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],alt[1],ii,8);ii+=(uint)8;
SET_AIS(w[gli],alt[2],ii,16);ii+=(uint)8;
SET_AIS(w[gli],alt[3],ii,24);ii+=(uint)8;
SET_AIS(w[gli],alt[4],ii,32);ii+=(uint)8;
SET_AIS(w[gli],alt[5],ii,40);ii+=(uint)8;
SET_AIS(w[gli],alt[6],ii,48);ii+=(uint)8;
SET_AIS(w[gli],alt[7],ii,56);ii+=(uint)8;


SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
transform137( __global ulong8 *dst,  __global ulong *input,__global ulong *input1,uint psize,uint ssize)
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
__local ulong w[64][17]; 
ulong alt[8]; 
ulong SIZE;

sbytes[gli][0]=input[(get_global_id(0)*12)];
sbytes[gli][1]=input[(get_global_id(0)*12)+1];
pbytes[gli][0]=input[(get_global_id(0)*12)+10];
pbytes[gli][1]=input[(get_global_id(0)*12)+11];
A=alt[0]=input1[(get_global_id(0)*8)];
B=alt[1]=input1[(get_global_id(0)*8)+1];
C=alt[2]=input1[(get_global_id(0)*8)+2];
D=alt[3]=input1[(get_global_id(0)*8)+3];
E=alt[4]=input1[(get_global_id(0)*8)+4];
F=alt[5]=input1[(get_global_id(0)*8)+5];
G=alt[6]=input1[(get_global_id(0)*8)+6];
H=alt[7]=input1[(get_global_id(0)*8)+7];

w[gli][0]=w[gli][1]=w[gli][2]=w[gli][3]=w[gli][4]=w[gli][5]=w[gli][6]=w[gli][7]=w[gli][8]=w[gli][9]=w[gli][10]=w[gli][11]=w[gli][12]=w[gli][13]=w[gli][14]=w[gli][16]=(ulong)0;
ii=0;

ii=(uint)psize;

w[gli][0]=pbytes[gli][0];
w[gli][1]=pbytes[gli][1];

jj=ii;
SET_AIS(w[gli],sbytes[gli][0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],sbytes[gli][1],ii,8);ii+=(uint)8;
ii=jj+ssize;

jj=ii;
SET_AIS(w[gli],pbytes[gli][0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],pbytes[gli][1],ii,8);ii+=(uint)8;
ii=jj+psize;

SET_AIS(w[gli],alt[0],ii,0);ii+=(uint)8;
SET_AIS(w[gli],alt[1],ii,8);ii+=(uint)8;
SET_AIS(w[gli],alt[2],ii,16);ii+=(uint)8;
SET_AIS(w[gli],alt[3],ii,24);ii+=(uint)8;
SET_AIS(w[gli],alt[4],ii,32);ii+=(uint)8;
SET_AIS(w[gli],alt[5],ii,40);ii+=(uint)8;
SET_AIS(w[gli],alt[6],ii,48);ii+=(uint)8;
SET_AIS(w[gli],alt[7],ii,56);ii+=(uint)8;


SET_AB(w[gli],ii,(ulong)0x80);
SIZE=(ulong)(ii<<3);

dst[(get_global_id(0)*2)] = (ulong8)(w[gli][0],w[gli][1],w[gli][2],w[gli][3],w[gli][4],w[gli][5],w[gli][6],w[gli][7]);
dst[(get_global_id(0)*2)+1] = (ulong8)(w[gli][8],w[gli][9],w[gli][10],w[gli][11],w[gli][12],w[gli][13],w[gli][14],SIZE);
}





#define gli get_local_id(0)


#define ROTATE(b,x)     (((x) >> (b)) | ((x) << (64L - (b))))
#define R(b,x)          ((x) >> (b))
#define Ch(x,y,z)       ((z)^((x)&((y)^(z))))
#define Maj(x,y,z)      (((x) & (y)) | ((z)&((x)|(y))))


#define Sigma0_512(x)   (ROTATE(28L, (x)) ^ ROTATE(34L, (x)) ^ ROTATE(39L, (x)))
#define Sigma1_512(x)   (ROTATE(14L, (x)) ^ ROTATE(18L, (x)) ^ ROTATE(41L, (x)))
#define sigma0_512(x)   (ROTATE( 1L, (x)) ^ ROTATE( 8L, (x)) ^ R( 7L,   (x)))
#define sigma1_512(x)   (ROTATE(19L, (x)) ^ ROTATE(61L, (x)) ^ R( 6L,   (x)))


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
sha512unixm( __global ulong8 *dst,  __global ulong *input,   __global uint *found_ind, __global uint *found,  ulong8 singlehash, uint salt) 
{

ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16; 
ulong SIZE;

w0=input[(get_global_id(0)*16)];
w1=input[(get_global_id(0)*16)+1];
w2=input[(get_global_id(0)*16)+2];
w3=input[(get_global_id(0)*16)+3];
w4=input[(get_global_id(0)*16)+4];
w5=input[(get_global_id(0)*16)+5];
w6=input[(get_global_id(0)*16)+6];
w7=input[(get_global_id(0)*16)+7];
w8=input[(get_global_id(0)*16)+8];
w9=input[(get_global_id(0)*16)+9];
w10=input[(get_global_id(0)*16)+10];
w11=input[(get_global_id(0)*16)+11];
w12=input[(get_global_id(0)*16)+12];
w13=input[(get_global_id(0)*16)+13];
w14=input[(get_global_id(0)*16)+14];
SIZE=input[(get_global_id(0)*16)+15];


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

dst[(get_global_id(0))] = (ulong8)(A,B,C,D,E,F,G,H);
}




__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
sha512unixe( __global ulong8 *dst,  __global ulong *input,   __global uint *found_ind, __global uint *found,  ulong8 singlehash, uint salt) 
{
ulong A,B,C,D,E,F,G,H,jj,T1,tmp2,ii,tmp1,elem;
__local ulong sbytes[64][2];
__local ulong pbytes[64][2];
uint ic;
ulong w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16; 
ulong alt[8]; 
ulong SIZE;

w0=input[(get_global_id(0)*16)];
w1=input[(get_global_id(0)*16)+1];
w2=input[(get_global_id(0)*16)+2];
w3=input[(get_global_id(0)*16)+3];
w4=input[(get_global_id(0)*16)+4];
w5=input[(get_global_id(0)*16)+5];
w6=input[(get_global_id(0)*16)+6];
w7=input[(get_global_id(0)*16)+7];
w8=input[(get_global_id(0)*16)+8];
w9=input[(get_global_id(0)*16)+9];
w10=input[(get_global_id(0)*16)+10];
w11=input[(get_global_id(0)*16)+11];
w12=input[(get_global_id(0)*16)+12];
w13=input[(get_global_id(0)*16)+13];
w14=input[(get_global_id(0)*16)+14];
SIZE=input[(get_global_id(0)*16)+15];


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


A=Endian_Reverse64(A);
B=Endian_Reverse64(B);
C=Endian_Reverse64(C);
D=Endian_Reverse64(D);
E=Endian_Reverse64(E);
F=Endian_Reverse64(F);
G=Endian_Reverse64(G);
H=Endian_Reverse64(H);

if ((ulong)singlehash.s0!=A) return;
if ((ulong)singlehash.s1!=B) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (ulong8)(A,B,C,D,E,F,G,H);
}

