#define GGI (get_global_id(0))
#define GLI (get_global_id(0))
#define PUT(buf, ind, val) (buf)[(ind)>>2] = ((buf)[(ind)>>2] & ~(0xffU << (((ind) & 3) << 3))) + ((val) << (((ind) & 3) << 3))
#define GET(buf, ind) (((buf)[(ind)>>2] >> (((ind) & 3) << 3)) & 0xffU)


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
add_x80( __global uint4 *dst,  __global uint *inp, __global uint *size, const uint4 add)
{
__local uint inpc[64][8];
uint SIZE;

inpc[GLI][0] = inp[GGI/(8)+0];
inpc[GLI][1] = inp[GGI/(8)+1];
inpc[GLI][2] = inp[GGI/(8)+2];
inpc[GLI][3] = inp[GGI/(8)+3];
inpc[GLI][4] = inp[GGI/(8)+4];
inpc[GLI][5] = inp[GGI/(8)+5];
inpc[GLI][6] = inp[GGI/(8)+6];
inpc[GLI][7] = inp[GGI/(8)+7];
SIZE=size[GGI];

PUT(inpc[GLI],SIZE,0x80);

dst[GGI/8+0] = inpc[GLI][0];
dst[GGI/8+1] = inpc[GLI][1];
dst[GGI/8+2] = inpc[GLI][2];
dst[GGI/8+3] = inpc[GLI][3];
dst[GGI/8+4] = inpc[GLI][4];
dst[GGI/8+5] = inpc[GLI][5];
dst[GGI/8+6] = inpc[GLI][6];
dst[GGI/8+7] = inpc[GLI][7];

}


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
add_word( __global uint4 *dst,  __global uint *inp, __global uint *size, const uint4 add)
{
__local uint inpc[64][8];
uint SIZE;
uint WORDSIZE;
__local uint word[4];
uint cnt,res,bt;

vstore4(add,0,word);
WORDSIZE=add.w;
inpc[GLI][0] = inp[GGI/(8)+0];
inpc[GLI][1] = inp[GGI/(8)+1];
inpc[GLI][2] = inp[GGI/(8)+2];
inpc[GLI][3] = inp[GGI/(8)+3];
inpc[GLI][4] = inp[GGI/(8)+4];
inpc[GLI][5] = inp[GGI/(8)+5];
inpc[GLI][6] = inp[GGI/(8)+6];
inpc[GLI][7] = inp[GGI/(8)+7];
SIZE=size[GGI];

res=SIZE+WORDSIZE;
cnt=SIZE;
while ((cnt<32)&&(cnt<=res))
{
bt=GET(word,cnt);
PUT(inpc[GLI],cnt,bt);
cnt++;
}

size[GGI]=cnt;
dst[GGI/8+0] = inpc[GLI][0];
dst[GGI/8+1] = inpc[GLI][1];
dst[GGI/8+2] = inpc[GLI][2];
dst[GGI/8+3] = inpc[GLI][3];
dst[GGI/8+4] = inpc[GLI][4];
dst[GGI/8+5] = inpc[GLI][5];
dst[GGI/8+6] = inpc[GLI][6];
dst[GGI/8+7] = inpc[GLI][7];

}