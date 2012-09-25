
__kernel  
void  __attribute__((reqd_work_group_size(64, 1, 1)))
md5md5_long( __global uint4 *dst,const uint4 input,const uint size, const uint8 chbase, __global uint *found_ind, __global uint *bitmaps, __global uint *found, __global uint *table, const uint4 singlehash) 
{  
uchar4 a,b,c,d;
__private uchar bull[256];
uint i;
uchar dor;
for (i=0;i<256;i++) bull[i]=found_ind[get_global_id(0)]&255;
dor=bull[2];
a^=(uchar4)dor;

dst[(get_global_id(0)*4)] = (uint4)(a.s0,b.s0,c.s0,d.s0);
dst[(get_global_id(0)*4)+1] = (uint4)(a.s1,b.s1,c.s1,d.s1);
dst[(get_global_id(0)*4)+2] = (uint4)(a.s2,b.s2,c.s2,d.s2);
dst[(get_global_id(0)*4)+3] = (uint4)(a.s3,b.s3,c.s3,d.s3);

}



