
__kernel  
void  __attribute__((reqd_work_group_size(64, 1, 1)))
test_long( __global uint *dst,__global uint* input) 
{  
uint a,b,c,d;
a=input[get_global_id(0)]%7;

dst[(get_global_id(0))] = (uint)(a);

}



