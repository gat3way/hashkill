__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
a51( __global uint *hashes, __global uint *input,  __global uint *found,  uint ks, uint ks1) 
{
__local uint vec[32];
uint cand=0,cand1=0;
uint ggi = get_global_id(0);
uint gli1 = get_local_id(0)&31U;
uint gli = get_local_id(0);
uint t_ggi = ggi>>(13-5);
uint i,t,maj;
__private uint out[32];


uint v00,v01,v10,v11,v20,v21,v30,v31,v40,v41;
uint l10,l11,l12,l13,l14,l15,l16,l17,l18,l19,l110,l111,l112,l113,l114,l115,l116,l117,l118;
uint l20,l21,l22,l23,l24,l25,l26,l27,l28,l29,l210,l211,l212,l213,l214,l215,l216,l217,l218,l219,l220,l221;
uint l30,l31,l32,l33,l34,l35,l36,l37,l38,l39,l310,l311,l312,l313,l314,l315,l316,l317,l318,l319,l320,l321,l322;
uint t1,t2,u1,u2;


vec[gli&31]=input[t_ggi*32+gli1];

mem_fence(CLK_LOCAL_MEM_FENCE);

cand = vec[13*2];
cand1 = vec[13*2+1];


if (((ggi)&1U)==1U)
{
cand ^= vec[10];
cand1  ^= vec[11];
}

for (i=6;i<13;i++) if (((ggi>>(i-5))&1U)==1U)
{
cand ^= vec[i*2];
cand1  ^= vec[i*2+1];
}



v00=vec[0];
v01=vec[1];
v10=vec[2];
v11=vec[3];
v20=vec[4];
v21=vec[5];
v30=vec[6];
v31=vec[7];
v40=vec[8];
v41=vec[9];

t1=u1=cand;
t2=u2=cand1;

l10=l11=l12=l13=l14=l15=l16=l17=l18=l19=l110=l111=l112=l113=l114=l115=l116=l117=l118=0;
l20=l21=l22=l23=l24=l25=l26=l27=l28=l29=l210=l211=l212=l213=l214=l215=l216=l217=l218=l219=l220=l221=0;
l30=l31=l32=l33=l34=l35=l36=l37=l38=l39=l310=l311=l312=l313=l314=l315=l316=l317=l318=l319=l320=l321=l322=0;


// setup slices
t1=u1;t2=u2;

l10 = bitselect(l10,t1,1U);
l11 = bitselect(l11,t1,1U<<1);
l12 = bitselect(l12,t1,1U<<2);
l13 = bitselect(l13,t1,1U<<3);
l14 = bitselect(l14,t1,1U<<4);
l15 = bitselect(l15,t1,1U<<5);
l16 = bitselect(l16,t1,1U<<6);
l17 = bitselect(l17,t1,1U<<7);
l18 = bitselect(l18,t1,1U<<8);
l19 = bitselect(l19,t1,1U<<9);
l110 = bitselect(l110,t1,1U<<10);
l111 = bitselect(l111,t1,1U<<11);
l112 = bitselect(l112,t1,1U<<12);
l113 = bitselect(l113,t1,1U<<13);
l114 = bitselect(l114,t1,1U<<14);
l115 = bitselect(l115,t1,1U<<15);
l116 = bitselect(l116,t1,1U<<16);
l117 = bitselect(l117,t1,1U<<17);
l118 = bitselect(l118,t1,1U<<18);

l20 = bitselect(l20,t1,1U<<19);
l21 = bitselect(l21,t1,1U<<20);
l22 = bitselect(l22,t1,1U<<21);
l23 = bitselect(l23,t1,1U<<22);
l24 = bitselect(l24,t1,1U<<23);
l25 = bitselect(l25,t1,1U<<24);
l26 = bitselect(l26,t1,1U<<25);
l27 = bitselect(l27,t1,1U<<26);
l28 = bitselect(l28,t1,1U<<27);
l29 = bitselect(l29,t1,1U<<28);
l210 = bitselect(l210,t1,1U<<29);
l211 = bitselect(l211,t1,1U<<30);
l212 = bitselect(l212,t1,1U<<31);

l213 = bitselect(l213,t2,1U);
l214 = bitselect(l214,t2,1U<<1);
l215 = bitselect(l215,t2,1U<<2);
l216 = bitselect(l216,t2,1U<<3);
l217 = bitselect(l217,t2,1U<<4);
l218 = bitselect(l218,t2,1U<<5);
l219 = bitselect(l219,t2,1U<<6);
l220 = bitselect(l220,t2,1U<<7);
l221 = bitselect(l221,t2,1U<<8);

l30 = bitselect(l30,t2,1U<<9);
l31 = bitselect(l31,t2,1U<<10);
l32 = bitselect(l32,t2,1U<<11);
l33 = bitselect(l33,t2,1U<<12);
l34 = bitselect(l34,t2,1U<<13);
l35 = bitselect(l35,t2,1U<<14);
l36 = bitselect(l36,t2,1U<<15);
l37 = bitselect(l37,t2,1U<<16);
l38 = bitselect(l38,t2,1U<<17);
l39 = bitselect(l39,t2,1U<<18);
l310 = bitselect(l310,t2,1U<<19);
l311 = bitselect(l311,t2,1U<<20);
l312 = bitselect(l312,t2,1U<<21);
l313 = bitselect(l313,t2,1U<<22);
l314 = bitselect(l314,t2,1U<<23);
l315 = bitselect(l315,t2,1U<<24);
l316 = bitselect(l316,t2,1U<<25);
l317 = bitselect(l317,t2,1U<<26);
l318 = bitselect(l318,t2,1U<<27);
l319 = bitselect(l319,t2,1U<<28);
l320 = bitselect(l320,t2,1U<<29);
l321 = bitselect(l321,t2,1U<<30);
l322 = bitselect(l322,t2,1U<<31);


for (i=1;i<32;i++)
{

t1=u1;t2=u2;
t1^=(i&1)?v00:0;
t2^=(i&1)?v01:0;
t1^=((i>>1)&1)?v10:0;
t2^=((i>>1)&1)?v11:0;
t1^=((i>>2)&1)?v20:0;
t2^=((i>>2)&1)?v21:0;
t1^=((i>>3)&1)?v30:0;
t2^=((i>>3)&1)?v31:0;
t1^=((i>>4)&1)?v40:0;
t2^=((i>>4)&1)?v41:0;

t1=rotate(t1,i);
t2=rotate(t2,i);

l10 = bitselect(l10,t1,rotate((uint)1,i));
l11 = bitselect(l11,t1,rotate((uint)1<<1,i));
l12 = bitselect(l12,t1,rotate((uint)1<<2,i));
l13 = bitselect(l13,t1,rotate((uint)1<<3,i));
l14 = bitselect(l14,t1,rotate((uint)1<<4,i));
l15 = bitselect(l15,t1,rotate((uint)1<<5,i));
l16 = bitselect(l16,t1,rotate((uint)1<<6,i));
l17 = bitselect(l17,t1,rotate((uint)1<<7,i));
l18 = bitselect(l18,t1,rotate((uint)1<<8,i));
l19 = bitselect(l19,t1,rotate((uint)1<<9,i));
l110 = bitselect(l110,t1,rotate((uint)1<<10,i));
l111 = bitselect(l111,t1,rotate((uint)1<<11,i));
l112 = bitselect(l112,t1,rotate((uint)1<<12,i));
l113 = bitselect(l113,t1,rotate((uint)1<<13,i));
l114 = bitselect(l114,t1,rotate((uint)1<<14,i));
l115 = bitselect(l115,t1,rotate((uint)1<<15,i));
l116 = bitselect(l116,t1,rotate((uint)1<<16,i));
l117 = bitselect(l117,t1,rotate((uint)1<<17,i));
l118 = bitselect(l118,t1,rotate((uint)1<<18,i));

l20 = bitselect(l20,t1,rotate((uint)1<<19,i));
l21 = bitselect(l21,t1,rotate((uint)1<<20,i));
l22 = bitselect(l22,t1,rotate((uint)1<<21,i));
l23 = bitselect(l23,t1,rotate((uint)1<<22,i));
l24 = bitselect(l24,t1,rotate((uint)1<<23,i));
l25 = bitselect(l25,t1,rotate((uint)1<<24,i));
l26 = bitselect(l26,t1,rotate((uint)1<<25,i));
l27 = bitselect(l27,t1,rotate((uint)1<<26,i));
l28 = bitselect(l28,t1,rotate((uint)1<<27,i));
l29 = bitselect(l29,t1,rotate((uint)1<<28,i));
l210 = bitselect(l210,t1,rotate((uint)1<<29,i));
l211 = bitselect(l211,t1,rotate((uint)1<<30,i));
l212 = bitselect(l212,t1,rotate((uint)1<<31,i));

l213 = bitselect(l213,t2,rotate((uint)1,i));
l214 = bitselect(l214,t2,rotate((uint)1<<1,i));
l215 = bitselect(l215,t2,rotate((uint)1<<2,i));
l216 = bitselect(l216,t2,rotate((uint)1<<3,i));
l217 = bitselect(l217,t2,rotate((uint)1<<4,i));
l218 = bitselect(l218,t2,rotate((uint)1<<5,i));
l219 = bitselect(l219,t2,rotate((uint)1<<6,i));
l220 = bitselect(l220,t2,rotate((uint)1<<7,i));
l221 = bitselect(l221,t2,rotate((uint)1<<8,i));

l30 = bitselect(l30,t2,rotate((uint)1<<9,i));
l31 = bitselect(l31,t2,rotate((uint)1<<10,i));
l32 = bitselect(l32,t2,rotate((uint)1<<11,i));
l33 = bitselect(l33,t2,rotate((uint)1<<12,i));
l34 = bitselect(l34,t2,rotate((uint)1<<13,i));
l35 = bitselect(l35,t2,rotate((uint)1<<14,i));
l36 = bitselect(l36,t2,rotate((uint)1<<15,i));
l37 = bitselect(l37,t2,rotate((uint)1<<16,i));
l38 = bitselect(l38,t2,rotate((uint)1<<17,i));
l39 = bitselect(l39,t2,rotate((uint)1<<18,i));
l310 = bitselect(l310,t2,rotate((uint)1<<19,i));
l311 = bitselect(l311,t2,rotate((uint)1<<20,i));
l312 = bitselect(l312,t2,rotate((uint)1<<21,i));
l313 = bitselect(l313,t2,rotate((uint)1<<22,i));
l314 = bitselect(l314,t2,rotate((uint)1<<23,i));
l315 = bitselect(l315,t2,rotate((uint)1<<24,i));
l316 = bitselect(l316,t2,rotate((uint)1<<25,i));
l317 = bitselect(l317,t2,rotate((uint)1<<26,i));
l318 = bitselect(l318,t2,rotate((uint)1<<27,i));
l319 = bitselect(l319,t2,rotate((uint)1<<28,i));
l320 = bitselect(l320,t2,rotate((uint)1<<29,i));
l321 = bitselect(l321,t2,rotate((uint)1<<30,i));
l322 = bitselect(l322,t2,rotate((uint)1<<31,i));
}

l11=rotate(l11,31U);
l12=rotate(l12,30U);
l13=rotate(l13,29U);
l14=rotate(l14,28U);
l15=rotate(l15,27U);
l16=rotate(l16,26U);
l17=rotate(l17,25U);
l18=rotate(l18,24U);
l19=rotate(l19,23U);
l110=rotate(l110,22U);
l111=rotate(l111,21U);
l112=rotate(l112,20U);
l113=rotate(l113,19U);
l114=rotate(l114,18U);
l115=rotate(l115,17U);
l116=rotate(l116,16U);
l117=rotate(l117,15U);
l118=rotate(l118,14U);


l20=rotate(l20,13U);
l21=rotate(l21,12U);
l22=rotate(l22,11U);
l23=rotate(l23,10U);
l24=rotate(l24,9U);
l25=rotate(l25,8U);
l26=rotate(l26,7U);
l27=rotate(l27,6U);
l28=rotate(l28,5U);
l29=rotate(l29,4U);
l210=rotate(l210,3U);
l211=rotate(l211,2U);
l212=rotate(l212,1U);

l214=rotate(l214,31U);
l215=rotate(l215,30U);
l216=rotate(l216,29U);
l217=rotate(l217,28U);
l218=rotate(l218,27U);
l219=rotate(l219,26U);
l220=rotate(l220,25U);
l221=rotate(l221,24U);

l30=rotate(l30,23U);
l31=rotate(l31,22U);
l32=rotate(l32,21U);
l33=rotate(l33,20U);
l34=rotate(l34,19U);
l35=rotate(l35,18U);
l36=rotate(l36,17U);
l37=rotate(l37,16U);
l38=rotate(l38,15U);
l39=rotate(l39,14U);
l310=rotate(l310,13U);
l311=rotate(l311,12U);
l312=rotate(l312,11U);
l313=rotate(l313,10U);
l314=rotate(l314,9U);
l315=rotate(l315,8U);
l316=rotate(l316,7U);
l317=rotate(l317,6U);
l318=rotate(l318,5U);
l319=rotate(l319,4U);
l320=rotate(l320,3U);
l321=rotate(l321,2U);
l322=rotate(l322,1U);



// Do first 32 forward clockings
for (i=0;i<32;i++)
{

// majority
maj = bitselect(l210,l18,(l210^l310));

// Clock LFSR1 according to majority rule
uint cv=(maj^l18);
uint cv1=(l118^l117^l116^l113);
l118=bitselect(l117,l118,cv);
l117=bitselect(l116,l117,cv);
l116=bitselect(l115,l116,cv);
l115=bitselect(l114,l115,cv);
l114=bitselect(l113,l114,cv);
l113=bitselect(l112,l113,cv);
l112=bitselect(l111,l112,cv);
l111=bitselect(l110,l111,cv);
l110=bitselect(l19,l110,cv);
l19=bitselect(l18,l19,cv);
l18=bitselect(l17,l18,cv);
l17=bitselect(l16,l17,cv);
l16=bitselect(l15,l16,cv);
l15=bitselect(l14,l15,cv);
l14=bitselect(l13,l14,cv);
l13=bitselect(l12,l13,cv);
l12=bitselect(l11,l12,cv);
l11=bitselect(l10,l11,cv);
l10=bitselect(cv1,l10,cv);


// Clock LFSR2 according to majority rule
cv=(maj^l210);
cv1=(l221^l220);
l221=bitselect(l220,l221,cv);
l220=bitselect(l219,l220,cv);
l219=bitselect(l218,l219,cv);
l218=bitselect(l217,l218,cv);
l217=bitselect(l216,l217,cv);
l216=bitselect(l215,l216,cv);
l215=bitselect(l214,l215,cv);
l214=bitselect(l213,l214,cv);
l213=bitselect(l212,l213,cv);
l212=bitselect(l211,l212,cv);
l211=bitselect(l210,l211,cv);
l210=bitselect(l29,l210,cv);
l29=bitselect(l28,l29,cv);
l28=bitselect(l27,l28,cv);
l27=bitselect(l26,l27,cv);
l26=bitselect(l25,l26,cv);
l25=bitselect(l24,l25,cv);
l24=bitselect(l23,l24,cv);
l23=bitselect(l22,l23,cv);
l22=bitselect(l21,l22,cv);
l21=bitselect(l20,l21,cv);
l20=bitselect(cv1,l20,cv);


// Clock LFSR3 according to majority rule
cv=(maj^l310);
cv1=(l322^l321^l320^l37);

l322=bitselect(l321,l322,cv);
l321=bitselect(l320,l321,cv);
l320=bitselect(l319,l320,cv);
l319=bitselect(l318,l319,cv);
l318=bitselect(l317,l318,cv);
l317=bitselect(l316,l317,cv);
l316=bitselect(l315,l316,cv);
l315=bitselect(l314,l315,cv);
l314=bitselect(l313,l314,cv);
l313=bitselect(l312,l313,cv);
l312=bitselect(l311,l312,cv);
l311=bitselect(l310,l311,cv);
l310=bitselect(l39,l310,cv);
l39=bitselect(l38,l39,cv);
l38=bitselect(l37,l38,cv);
l37=bitselect(l36,l37,cv);
l36=bitselect(l35,l36,cv);
l35=bitselect(l34,l35,cv);
l34=bitselect(l33,l34,cv);
l33=bitselect(l32,l33,cv);
l32=bitselect(l31,l32,cv);
l31=bitselect(l30,l31,cv);
l30=bitselect(cv1,l30,cv);

// Commit to out array
out[i]=(l118^l221^l322);

}


// Check if we have a match
uint out1,out2;
out1=out2=0;
for (i=0;i<32;i++)
{
out1=~(((ks>>(31-i))&1)-1);
out2|=(out[i]^out1);
}

// 32 elements yield no fun, bail out
if (out2==0xffffffffU) return;





// Do first 32 forward clockings
for (i=0;i<32;i++)
{

// majority
maj = bitselect(l210,l18,(l210^l310));

// Clock LFSR1 according to majority rule
uint cv=(maj^l18);
uint cv1=(l118^l117^l116^l113);
l118=bitselect(l117,l118,cv);
l117=bitselect(l116,l117,cv);
l116=bitselect(l115,l116,cv);
l115=bitselect(l114,l115,cv);
l114=bitselect(l113,l114,cv);
l113=bitselect(l112,l113,cv);
l112=bitselect(l111,l112,cv);
l111=bitselect(l110,l111,cv);
l110=bitselect(l19,l110,cv);
l19=bitselect(l18,l19,cv);
l18=bitselect(l17,l18,cv);
l17=bitselect(l16,l17,cv);
l16=bitselect(l15,l16,cv);
l15=bitselect(l14,l15,cv);
l14=bitselect(l13,l14,cv);
l13=bitselect(l12,l13,cv);
l12=bitselect(l11,l12,cv);
l11=bitselect(l10,l11,cv);
l10=bitselect(cv1,l10,cv);


// Clock LFSR2 according to majority rule
cv=(maj^l210);
cv1=(l221^l220);
l221=bitselect(l220,l221,cv);
l220=bitselect(l219,l220,cv);
l219=bitselect(l218,l219,cv);
l218=bitselect(l217,l218,cv);
l217=bitselect(l216,l217,cv);
l216=bitselect(l215,l216,cv);
l215=bitselect(l214,l215,cv);
l214=bitselect(l213,l214,cv);
l213=bitselect(l212,l213,cv);
l212=bitselect(l211,l212,cv);
l211=bitselect(l210,l211,cv);
l210=bitselect(l29,l210,cv);
l29=bitselect(l28,l29,cv);
l28=bitselect(l27,l28,cv);
l27=bitselect(l26,l27,cv);
l26=bitselect(l25,l26,cv);
l25=bitselect(l24,l25,cv);
l24=bitselect(l23,l24,cv);
l23=bitselect(l22,l23,cv);
l22=bitselect(l21,l22,cv);
l21=bitselect(l20,l21,cv);
l20=bitselect(cv1,l20,cv);


// Clock LFSR3 according to majority rule
cv=(maj^l310);
cv1=(l322^l321^l320^l37);

l322=bitselect(l321,l322,cv);
l321=bitselect(l320,l321,cv);
l320=bitselect(l319,l320,cv);
l319=bitselect(l318,l319,cv);
l318=bitselect(l317,l318,cv);
l317=bitselect(l316,l317,cv);
l316=bitselect(l315,l316,cv);
l315=bitselect(l314,l315,cv);
l314=bitselect(l313,l314,cv);
l313=bitselect(l312,l313,cv);
l312=bitselect(l311,l312,cv);
l311=bitselect(l310,l311,cv);
l310=bitselect(l39,l310,cv);
l39=bitselect(l38,l39,cv);
l38=bitselect(l37,l38,cv);
l37=bitselect(l36,l37,cv);
l36=bitselect(l35,l36,cv);
l35=bitselect(l34,l35,cv);
l34=bitselect(l33,l34,cv);
l33=bitselect(l32,l33,cv);
l32=bitselect(l31,l32,cv);
l31=bitselect(l30,l31,cv);
l30=bitselect(cv1,l30,cv);

// Commit to out array
out[i]=(l118^l221^l322);

}


// Check if we have a match
out1,out2;
out1=out2=0;
for (i=0;i<32;i++)
{
out1=~(((ks1>>(31-i))&1)-1);
out2|=(out[i]^out1);
}

// 32 elements yield no fun, bail out
if (out2==0xffffffffU) return;



// Since we are here, let's recreate all candidates and put them in output
for (i=0;i<32;i++)
{
t1=u1;t2=u2;
t1^=(i&1)?v00:0;
t2^=(i&1)?v01:0;
t1^=((i>>1)&1)?v10:0;
t2^=((i>>1)&1)?v11:0;
t1^=((i>>2)&1)?v20:0;
t2^=((i>>2)&1)?v21:0;
t1^=((i>>3)&1)?v30:0;
t2^=((i>>3)&1)?v31:0;
t1^=((i>>4)&1)?v40:0;
t2^=((i>>4)&1)?v41:0;

uint res = atomic_inc(found);
hashes[res*2]=t1;
hashes[res*2+1]=t2;
}

}
