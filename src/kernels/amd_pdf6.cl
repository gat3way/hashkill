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
__local uint inpc[64][22];
uint SIZE;
uint elem,tmp1,i,j;


inpc[GLI][0]=inpc[GLI][1]=inpc[GLI][2]=inpc[GLI][3]=0;
inpc[GLI][4]=inpc[GLI][5]=inpc[GLI][6]=inpc[GLI][7]=0;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=0;
inpc[GLI][12]=inpc[GLI][13]=inpc[GLI][14]=inpc[GLI][15]=0;

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
SIZE+=str.sF;


sizein[GGI] = (SIZE);
dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}



#define S1H0 0x6A09E667U
#define S1H1 0xBB67AE85U
#define S1H2 0x3C6EF372U
#define S1H3 0xA54FF53AU
#define S1H4 0x510E527FU
#define S1H5 0x9B05688CU
#define S1H6 0x1F83D9ABU
#define S1H7 0x5BE0CD19U

#define Sl 8U
#define Sr 24U
#define M 0x00FF00FFU

#define  SHR(x,n) ((x) >> n)
#define ROTR(x,n) (rotate(x,(32-n)))

#define S0(x) (ROTR(x, 7U) ^  SHR(x, 3U)^ ROTR(x,18U) )
#define S1(x) (ROTR(x,17U) ^  SHR(x,10U)^ ROTR(x,19U) )
#define S2(x) (ROTR(x, 2U) ^ ROTR(x,22U)^ ROTR(x,13U) )
#define S3(x) (ROTR(x, 6U) ^ ROTR(x,25U)^ ROTR(x,11U) )

#define F1(x,y,z) (bitselect(z,y,x))
#define F0(x,y,z) (bitselect(y, x,(z^y)))


#define P(a,b,c,d,e,f,g,h,x,K) {tmp1 =  F1(e,f,g) +  S3(e) + h + K +x;tmp2 = F0(a,b,c) + S2(a);d += tmp1; h = tmp1 + tmp2;}
#define P0(a,b,c,d,e,f,g,h,K) {tmp1 = S3(e) + F1(e,f,g) + h + K;tmp2 = S2(a) + F0(a,b,c);d += tmp1; h = tmp1 + tmp2;}

#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,M); }


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



#define S2H0 0xcbbb9d5dc1059ed8L
#define S2H1 0x629a292a367cd507L
#define S2H2 0x9159015a3070dd17L
#define S2H3 0x152fecd8f70e5939L
#define S2H4 0x67332667ffc00b31L
#define S2H5 0x8eb44a8768581511L
#define S2H6 0xdb0c2e0d64f98fa7L
#define S2H7 0x47b5481dbefa4fa4L

#define S3H0 0x6a09e667f3bcc908L
#define S3H1 0xbb67ae8584caa73bL
#define S3H2 0x3c6ef372fe94f82bL
#define S3H3 0xa54ff53a5f1d36f1L
#define S3H4 0x510e527fade682d1L
#define S3H5 0x9b05688c2b3e6c1fL
#define S3H6 0x1f83d9abfb41bd6bL
#define S3H7 0x5be0cd19137e2179L

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






__constant uint Te[256] = {
    0xc66363a5U, 0xf87c7c84U, 0xee777799U, 0xf67b7b8dU,
    0xfff2f20dU, 0xd66b6bbdU, 0xde6f6fb1U, 0x91c5c554U,
    0x60303050U, 0x02010103U, 0xce6767a9U, 0x562b2b7dU,
    0xe7fefe19U, 0xb5d7d762U, 0x4dababe6U, 0xec76769aU,
    0x8fcaca45U, 0x1f82829dU, 0x89c9c940U, 0xfa7d7d87U,
    0xeffafa15U, 0xb25959ebU, 0x8e4747c9U, 0xfbf0f00bU,
    0x41adadecU, 0xb3d4d467U, 0x5fa2a2fdU, 0x45afafeaU,
    0x239c9cbfU, 0x53a4a4f7U, 0xe4727296U, 0x9bc0c05bU,
    0x75b7b7c2U, 0xe1fdfd1cU, 0x3d9393aeU, 0x4c26266aU,
    0x6c36365aU, 0x7e3f3f41U, 0xf5f7f702U, 0x83cccc4fU,
    0x6834345cU, 0x51a5a5f4U, 0xd1e5e534U, 0xf9f1f108U,
    0xe2717193U, 0xabd8d873U, 0x62313153U, 0x2a15153fU,
    0x0804040cU, 0x95c7c752U, 0x46232365U, 0x9dc3c35eU,
    0x30181828U, 0x379696a1U, 0x0a05050fU, 0x2f9a9ab5U,
    0x0e070709U, 0x24121236U, 0x1b80809bU, 0xdfe2e23dU,
    0xcdebeb26U, 0x4e272769U, 0x7fb2b2cdU, 0xea75759fU,
    0x1209091bU, 0x1d83839eU, 0x582c2c74U, 0x341a1a2eU,
    0x361b1b2dU, 0xdc6e6eb2U, 0xb45a5aeeU, 0x5ba0a0fbU,
    0xa45252f6U, 0x763b3b4dU, 0xb7d6d661U, 0x7db3b3ceU,
    0x5229297bU, 0xdde3e33eU, 0x5e2f2f71U, 0x13848497U,
    0xa65353f5U, 0xb9d1d168U, 0x00000000U, 0xc1eded2cU,
    0x40202060U, 0xe3fcfc1fU, 0x79b1b1c8U, 0xb65b5bedU,
    0xd46a6abeU, 0x8dcbcb46U, 0x67bebed9U, 0x7239394bU,
    0x944a4adeU, 0x984c4cd4U, 0xb05858e8U, 0x85cfcf4aU,
    0xbbd0d06bU, 0xc5efef2aU, 0x4faaaae5U, 0xedfbfb16U,
    0x864343c5U, 0x9a4d4dd7U, 0x66333355U, 0x11858594U,
    0x8a4545cfU, 0xe9f9f910U, 0x04020206U, 0xfe7f7f81U,
    0xa05050f0U, 0x783c3c44U, 0x259f9fbaU, 0x4ba8a8e3U,
    0xa25151f3U, 0x5da3a3feU, 0x804040c0U, 0x058f8f8aU,
    0x3f9292adU, 0x219d9dbcU, 0x70383848U, 0xf1f5f504U,
    0x63bcbcdfU, 0x77b6b6c1U, 0xafdada75U, 0x42212163U,
    0x20101030U, 0xe5ffff1aU, 0xfdf3f30eU, 0xbfd2d26dU,
    0x81cdcd4cU, 0x180c0c14U, 0x26131335U, 0xc3ecec2fU,
    0xbe5f5fe1U, 0x359797a2U, 0x884444ccU, 0x2e171739U,
    0x93c4c457U, 0x55a7a7f2U, 0xfc7e7e82U, 0x7a3d3d47U,
    0xc86464acU, 0xba5d5de7U, 0x3219192bU, 0xe6737395U,
    0xc06060a0U, 0x19818198U, 0x9e4f4fd1U, 0xa3dcdc7fU,
    0x44222266U, 0x542a2a7eU, 0x3b9090abU, 0x0b888883U,
    0x8c4646caU, 0xc7eeee29U, 0x6bb8b8d3U, 0x2814143cU,
    0xa7dede79U, 0xbc5e5ee2U, 0x160b0b1dU, 0xaddbdb76U,
    0xdbe0e03bU, 0x64323256U, 0x743a3a4eU, 0x140a0a1eU,
    0x924949dbU, 0x0c06060aU, 0x4824246cU, 0xb85c5ce4U,
    0x9fc2c25dU, 0xbdd3d36eU, 0x43acacefU, 0xc46262a6U,
    0x399191a8U, 0x319595a4U, 0xd3e4e437U, 0xf279798bU,
    0xd5e7e732U, 0x8bc8c843U, 0x6e373759U, 0xda6d6db7U,
    0x018d8d8cU, 0xb1d5d564U, 0x9c4e4ed2U, 0x49a9a9e0U,
    0xd86c6cb4U, 0xac5656faU, 0xf3f4f407U, 0xcfeaea25U,
    0xca6565afU, 0xf47a7a8eU, 0x47aeaee9U, 0x10080818U,
    0x6fbabad5U, 0xf0787888U, 0x4a25256fU, 0x5c2e2e72U,
    0x381c1c24U, 0x57a6a6f1U, 0x73b4b4c7U, 0x97c6c651U,
    0xcbe8e823U, 0xa1dddd7cU, 0xe874749cU, 0x3e1f1f21U,
    0x964b4bddU, 0x61bdbddcU, 0x0d8b8b86U, 0x0f8a8a85U,
    0xe0707090U, 0x7c3e3e42U, 0x71b5b5c4U, 0xcc6666aaU,
    0x904848d8U, 0x06030305U, 0xf7f6f601U, 0x1c0e0e12U,
    0xc26161a3U, 0x6a35355fU, 0xae5757f9U, 0x69b9b9d0U,
    0x17868691U, 0x99c1c158U, 0x3a1d1d27U, 0x279e9eb9U,
    0xd9e1e138U, 0xebf8f813U, 0x2b9898b3U, 0x22111133U,
    0xd26969bbU, 0xa9d9d970U, 0x078e8e89U, 0x339494a7U,
    0x2d9b9bb6U, 0x3c1e1e22U, 0x15878792U, 0xc9e9e920U,
    0x87cece49U, 0xaa5555ffU, 0x50282878U, 0xa5dfdf7aU,
    0x038c8c8fU, 0x59a1a1f8U, 0x09898980U, 0x1a0d0d17U,
    0x65bfbfdaU, 0xd7e6e631U, 0x844242c6U, 0xd06868b8U,
    0x824141c3U, 0x299999b0U, 0x5a2d2d77U, 0x1e0f0f11U,
    0x7bb0b0cbU, 0xa85454fcU, 0x6dbbbbd6U, 0x2c16163aU,
};



__constant uint Td[256] = {
    0x51f4a750U, 0x7e416553U, 0x1a17a4c3U, 0x3a275e96U,
    0x3bab6bcbU, 0x1f9d45f1U, 0xacfa58abU, 0x4be30393U,
    0x2030fa55U, 0xad766df6U, 0x88cc7691U, 0xf5024c25U,
    0x4fe5d7fcU, 0xc52acbd7U, 0x26354480U, 0xb562a38fU,
    0xdeb15a49U, 0x25ba1b67U, 0x45ea0e98U, 0x5dfec0e1U,
    0xc32f7502U, 0x814cf012U, 0x8d4697a3U, 0x6bd3f9c6U,
    0x038f5fe7U, 0x15929c95U, 0xbf6d7aebU, 0x955259daU,
    0xd4be832dU, 0x587421d3U, 0x49e06929U, 0x8ec9c844U,
    0x75c2896aU, 0xf48e7978U, 0x99583e6bU, 0x27b971ddU,
    0xbee14fb6U, 0xf088ad17U, 0xc920ac66U, 0x7dce3ab4U,
    0x63df4a18U, 0xe51a3182U, 0x97513360U, 0x62537f45U,
    0xb16477e0U, 0xbb6bae84U, 0xfe81a01cU, 0xf9082b94U,
    0x70486858U, 0x8f45fd19U, 0x94de6c87U, 0x527bf8b7U,
    0xab73d323U, 0x724b02e2U, 0xe31f8f57U, 0x6655ab2aU,
    0xb2eb2807U, 0x2fb5c203U, 0x86c57b9aU, 0xd33708a5U,
    0x302887f2U, 0x23bfa5b2U, 0x02036abaU, 0xed16825cU,
    0x8acf1c2bU, 0xa779b492U, 0xf307f2f0U, 0x4e69e2a1U,
    0x65daf4cdU, 0x0605bed5U, 0xd134621fU, 0xc4a6fe8aU,
    0x342e539dU, 0xa2f355a0U, 0x058ae132U, 0xa4f6eb75U,
    0x0b83ec39U, 0x4060efaaU, 0x5e719f06U, 0xbd6e1051U,
    0x3e218af9U, 0x96dd063dU, 0xdd3e05aeU, 0x4de6bd46U,
    0x91548db5U, 0x71c45d05U, 0x0406d46fU, 0x605015ffU,
    0x1998fb24U, 0xd6bde997U, 0x894043ccU, 0x67d99e77U,
    0xb0e842bdU, 0x07898b88U, 0xe7195b38U, 0x79c8eedbU,
    0xa17c0a47U, 0x7c420fe9U, 0xf8841ec9U, 0x00000000U,
    0x09808683U, 0x322bed48U, 0x1e1170acU, 0x6c5a724eU,
    0xfd0efffbU, 0x0f853856U, 0x3daed51eU, 0x362d3927U,
    0x0a0fd964U, 0x685ca621U, 0x9b5b54d1U, 0x24362e3aU,
    0x0c0a67b1U, 0x9357e70fU, 0xb4ee96d2U, 0x1b9b919eU,
    0x80c0c54fU, 0x61dc20a2U, 0x5a774b69U, 0x1c121a16U,
    0xe293ba0aU, 0xc0a02ae5U, 0x3c22e043U, 0x121b171dU,
    0x0e090d0bU, 0xf28bc7adU, 0x2db6a8b9U, 0x141ea9c8U,
    0x57f11985U, 0xaf75074cU, 0xee99ddbbU, 0xa37f60fdU,
    0xf701269fU, 0x5c72f5bcU, 0x44663bc5U, 0x5bfb7e34U,
    0x8b432976U, 0xcb23c6dcU, 0xb6edfc68U, 0xb8e4f163U,
    0xd731dccaU, 0x42638510U, 0x13972240U, 0x84c61120U,
    0x854a247dU, 0xd2bb3df8U, 0xaef93211U, 0xc729a16dU,
    0x1d9e2f4bU, 0xdcb230f3U, 0x0d8652ecU, 0x77c1e3d0U,
    0x2bb3166cU, 0xa970b999U, 0x119448faU, 0x47e96422U,
    0xa8fc8cc4U, 0xa0f03f1aU, 0x567d2cd8U, 0x223390efU,
    0x87494ec7U, 0xd938d1c1U, 0x8ccaa2feU, 0x98d40b36U,
    0xa6f581cfU, 0xa57ade28U, 0xdab78e26U, 0x3fadbfa4U,
    0x2c3a9de4U, 0x5078920dU, 0x6a5fcc9bU, 0x547e4662U,
    0xf68d13c2U, 0x90d8b8e8U, 0x2e39f75eU, 0x82c3aff5U,
    0x9f5d80beU, 0x69d0937cU, 0x6fd52da9U, 0xcf2512b3U,
    0xc8ac993bU, 0x10187da7U, 0xe89c636eU, 0xdb3bbb7bU,
    0xcd267809U, 0x6e5918f4U, 0xec9ab701U, 0x834f9aa8U,
    0xe6956e65U, 0xaaffe67eU, 0x21bccf08U, 0xef15e8e6U,
    0xbae79bd9U, 0x4a6f36ceU, 0xea9f09d4U, 0x29b07cd6U,
    0x31a4b2afU, 0x2a3f2331U, 0xc6a59430U, 0x35a266c0U,
    0x744ebc37U, 0xfc82caa6U, 0xe090d0b0U, 0x33a7d815U,
    0xf104984aU, 0x41ecdaf7U, 0x7fcd500eU, 0x1791f62fU,
    0x764dd68dU, 0x43efb04dU, 0xccaa4d54U, 0xe49604dfU,
    0x9ed1b5e3U, 0x4c6a881bU, 0xc12c1fb8U, 0x4665517fU,
    0x9d5eea04U, 0x018c355dU, 0xfa877473U, 0xfb0b412eU,
    0xb3671d5aU, 0x92dbd252U, 0xe9105633U, 0x6dd64713U,
    0x9ad7618cU, 0x37a10c7aU, 0x59f8148eU, 0xeb133c89U,
    0xcea927eeU, 0xb761c935U, 0xe11ce5edU, 0x7a47b13cU,
    0x9cd2df59U, 0x55f2733fU, 0x1814ce79U, 0x73c737bfU,
    0x53f7cdeaU, 0x5ffdaa5bU, 0xdf3d6f14U, 0x7844db86U,
    0xcaaff381U, 0xb968c43eU, 0x3824342cU, 0xc2a3405fU,
    0x161dc372U, 0xbce2250cU, 0x283c498bU, 0xff0d9541U,
    0x39a80171U, 0x080cb3deU, 0xd8b4e49cU, 0x6456c190U,
    0x7bcb8461U, 0xd532b670U, 0x486c5c74U, 0xd0b85742U,
};


__constant uint TdK[256] = {
    0x52U, 0x09U, 0x6aU, 0xd5U, 0x30U, 0x36U, 0xa5U, 0x38U,
    0xbfU, 0x40U, 0xa3U, 0x9eU, 0x81U, 0xf3U, 0xd7U, 0xfbU,
    0x7cU, 0xe3U, 0x39U, 0x82U, 0x9bU, 0x2fU, 0xffU, 0x87U,
    0x34U, 0x8eU, 0x43U, 0x44U, 0xc4U, 0xdeU, 0xe9U, 0xcbU,
    0x54U, 0x7bU, 0x94U, 0x32U, 0xa6U, 0xc2U, 0x23U, 0x3dU,
    0xeeU, 0x4cU, 0x95U, 0x0bU, 0x42U, 0xfaU, 0xc3U, 0x4eU,
    0x08U, 0x2eU, 0xa1U, 0x66U, 0x28U, 0xd9U, 0x24U, 0xb2U,
    0x76U, 0x5bU, 0xa2U, 0x49U, 0x6dU, 0x8bU, 0xd1U, 0x25U,
    0x72U, 0xf8U, 0xf6U, 0x64U, 0x86U, 0x68U, 0x98U, 0x16U,
    0xd4U, 0xa4U, 0x5cU, 0xccU, 0x5dU, 0x65U, 0xb6U, 0x92U,
    0x6cU, 0x70U, 0x48U, 0x50U, 0xfdU, 0xedU, 0xb9U, 0xdaU,
    0x5eU, 0x15U, 0x46U, 0x57U, 0xa7U, 0x8dU, 0x9dU, 0x84U,
    0x90U, 0xd8U, 0xabU, 0x00U, 0x8cU, 0xbcU, 0xd3U, 0x0aU,
    0xf7U, 0xe4U, 0x58U, 0x05U, 0xb8U, 0xb3U, 0x45U, 0x06U,
    0xd0U, 0x2cU, 0x1eU, 0x8fU, 0xcaU, 0x3fU, 0x0fU, 0x02U,
    0xc1U, 0xafU, 0xbdU, 0x03U, 0x01U, 0x13U, 0x8aU, 0x6bU,
    0x3aU, 0x91U, 0x11U, 0x41U, 0x4fU, 0x67U, 0xdcU, 0xeaU,
    0x97U, 0xf2U, 0xcfU, 0xceU, 0xf0U, 0xb4U, 0xe6U, 0x73U,
    0x96U, 0xacU, 0x74U, 0x22U, 0xe7U, 0xadU, 0x35U, 0x85U,
    0xe2U, 0xf9U, 0x37U, 0xe8U, 0x1cU, 0x75U, 0xdfU, 0x6eU,
    0x47U, 0xf1U, 0x1aU, 0x71U, 0x1dU, 0x29U, 0xc5U, 0x89U,
    0x6fU, 0xb7U, 0x62U, 0x0eU, 0xaaU, 0x18U, 0xbeU, 0x1bU,
    0xfcU, 0x56U, 0x3eU, 0x4bU, 0xc6U, 0xd2U, 0x79U, 0x20U,
    0x9aU, 0xdbU, 0xc0U, 0xfeU, 0x78U, 0xcdU, 0x5aU, 0xf4U,
    0x1fU, 0xddU, 0xa8U, 0x33U, 0x88U, 0x07U, 0xc7U, 0x31U,
    0xb1U, 0x12U, 0x10U, 0x59U, 0x27U, 0x80U, 0xecU, 0x5fU,
    0x60U, 0x51U, 0x7fU, 0xa9U, 0x19U, 0xb5U, 0x4aU, 0x0dU,
    0x2dU, 0xe5U, 0x7aU, 0x9fU, 0x93U, 0xc9U, 0x9cU, 0xefU,
    0xa0U, 0xe0U, 0x3bU, 0x4dU, 0xaeU, 0x2aU, 0xf5U, 0xb0U,
    0xc8U, 0xebU, 0xbbU, 0x3cU, 0x83U, 0x53U, 0x99U, 0x61U,
    0x17U, 0x2bU, 0x04U, 0x7eU, 0xbaU, 0x77U, 0xd6U, 0x26U,
    0xe1U, 0x69U, 0x14U, 0x63U, 0x55U, 0x21U, 0x0cU, 0x7dU,
};

__constant uint rcon[] = {
	0x01000000, 0x02000000, 0x04000000, 0x08000000,
	0x10000000, 0x20000000, 0x40000000, 0x80000000,
	0x1B000000, 0x36000000 
};


#define lTe1(x) (ROTR(lTe[((x))],8U))
#define lTe2(x) (ROTR(lTe[((x))],16U))
#define lTe3(x) (ROTR(lTe[((x))],24U))
#define lTd1(x) (ROTR(lTd[((x))],8U))
#define lTd2(x) (ROTR(lTd[((x))],16U))
#define lTd3(x) (ROTR(lTd[((x))],24U))


#define AES128_ODD_ROUND { \
s0 = lTe[t0 >> 24] ^ lTe1((t1 >> 16) & 0xff) ^ lTe2((t2 >>  8) & 0xff) ^ lTe3(t3 & 0xff) ^ k0; \
s1 = lTe[t1 >> 24] ^ lTe1((t2 >> 16) & 0xff) ^ lTe2((t3 >>  8) & 0xff) ^ lTe3(t0 & 0xff) ^ k1; \
s2 = lTe[t2 >> 24] ^ lTe1((t3 >> 16) & 0xff) ^ lTe2((t0 >>  8) & 0xff) ^ lTe3(t1 & 0xff) ^ k2; \
s3 = lTe[t3 >> 24] ^ lTe1((t0 >> 16) & 0xff) ^ lTe2((t1 >>  8) & 0xff) ^ lTe3(t2 & 0xff) ^ k3; \
}

#define AES128_EVEN_ROUND { \
t0 = lTe[s0 >> 24] ^ lTe1((s1 >> 16) & 0xff) ^ lTe2((s2 >>  8) & 0xff) ^ lTe3(s3 & 0xff) ^ k0; \
t1 = lTe[s1 >> 24] ^ lTe1((s2 >> 16) & 0xff) ^ lTe2((s3 >>  8) & 0xff) ^ lTe3(s0 & 0xff) ^ k1; \
t2 = lTe[s2 >> 24] ^ lTe1((s3 >> 16) & 0xff) ^ lTe2((s0 >>  8) & 0xff) ^ lTe3(s1 & 0xff) ^ k2; \
t3 = lTe[s3 >> 24] ^ lTe1((s0 >> 16) & 0xff) ^ lTe2((s1 >>  8) & 0xff) ^ lTe3(s2 & 0xff) ^ k3; \
}



#define AES128_GET_KEYS1 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS2 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS3 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS4 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS5 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS6 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS7 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS8 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[7]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS9 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[8]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS10 { \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[9]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}



#define AES128_FINAL { \
s0 = \
    ((lTe2((t0 >> 24))) & 0xff000000) ^ \
    ((lTe3((t1 >> 16) & 0xff)) & 0x00ff0000) ^ \
    ((lTe[(t2 >>  8) & 0xff]) & 0x0000ff00) ^ \
    ((lTe1((t3) & 0xff) ) & 0x000000ff) ^ k0; \
s1 = \
    ((lTe2((t1 >> 24))) & 0xff000000) ^ \
    ((lTe3((t2 >> 16) & 0xff)) & 0x00ff0000) ^ \
    ((lTe[(t3 >>  8) & 0xff]) & 0x0000ff00) ^ \
    ((lTe1((t0) & 0xff) ) & 0x000000ff) ^ k1; \
s2 = \
    ((lTe2((t2 >> 24))) & 0xff000000) ^ \
    ((lTe3((t3 >> 16) & 0xff)) & 0x00ff0000) ^ \
    ((lTe[(t0 >>  8) & 0xff]) & 0x0000ff00) ^ \
    ((lTe1((t1) & 0xff) ) & 0x000000ff) ^ k2; \
s3 = \
    ((lTe2((t3 >> 24))) & 0xff000000) ^ \
    ((lTe3((t0 >> 16) & 0xff)) & 0x00ff0000) ^ \
    ((lTe[(t1 >>  8) & 0xff]) & 0x0000ff00) ^ \
    ((lTe1((t2) & 0xff) ) & 0x000000ff) ^ k3; \
}






__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16;
__private uint x[18];
uint A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,id,SIZE;
uint TA,TB,TC,TD,TE,TF,TG,TH;
uint elem,i,j,k;


a1=input[get_global_id(0)*8];
b1=input[get_global_id(0)*8+1];
c1=input[get_global_id(0)*8+2];
d1=input[get_global_id(0)*8+3];
e1=input[get_global_id(0)*8+4];
f1=input[get_global_id(0)*8+5];
g1=input[get_global_id(0)*8+6];
h1=input[get_global_id(0)*8+7];

x[8]=x[9]=x[10]=x[11]=x[12]=x[13]=x[14]=x[15]=x[16]=x[17]=0;
x[0]=a1;
x[1]=b1;
x[2]=c1;
x[3]=d1;
x[4]=e1;
x[5]=f1;
x[6]=g1;
x[7]=h1;
k=size[get_global_id(0)];
SET_AB(x,singlehash.s8,k,0);
SET_AB(x,singlehash.s9,k+4,0);
SET_AB(x,0x80U,k+8,0);
k+=8;

w0=x[0];
w1=x[1];
w2=x[2];
w3=x[3];
w4=x[4];
w5=x[5];
w6=x[6];
w7=x[7];
w8=x[8];
w9=x[9];
w10=x[10];
w11=w12=w13=w14=0U;
SIZE=k<<3;

Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
Endian_Reverse32(w8);
Endian_Reverse32(w9);
Endian_Reverse32(w10);

A=(uint)S1H0;
B=(uint)S1H1;
C=(uint)S1H2;
D=(uint)S1H3;
E=(uint)S1H4;
F=(uint)S1H5;
G=(uint)S1H6;
H=(uint)S1H7;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25BU);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1U);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4U);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5U);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98U);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01U);
P(G, H, A, B, C, D, E, F, w10, 0x243185BEU);
P0(F, G, H, A, B, C, D, E, 0x550C7DC3U);
P0(E, F, G, H, A, B, C, D, 0x72BE5D74U);
P0(D, E, F, G, H, A, B, C, 0x80DEB1FEU);
P0(C, D, E, F, G, H, A, B, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
w16=S0(w1)+w0; P(A, B, C, D, E, F, G, H, w16, 0xE49B69C1U);
w0=S1(SIZE)+S0(w2)+w1; P(H, A, B, C, D, E, F, G, w0,  0xEFBE4786U);
w1=S1(w16)+S0(w3)+w2;  P(G, H, A, B, C, D, E, F, w1, 0x0FC19DC6U);
w2=S1(w0)+S0(w4)+w3; P(F, G, H, A, B, C, D, E, w2, 0x240CA1CCU);
w3=S1(w1)+w13+S0(w5)+w4; P(E, F, G, H, A, B, C, D, w3, 0x2DE92C6FU);
w4=S1(w2)+w14+S0(w6)+w5; P(D, E, F, G, H, A, B, C, w4, 0x4A7484AAU);
w5=S1(w3)+SIZE+S0(w7)+w6; P(C, D, E, F, G, H, A, B, w5, 0x5CB0A9DCU);
w6=S1(w4)+w16+S0(w8)+w7; P(B, C, D, E, F, G, H, A, w6, 0x76F988DAU);
w7=S1(w5)+w0+S0(w9)+w8; P(A, B, C, D, E, F, G, H, w7, 0x983E5152U);
w8=S1(w6)+w1+S0(w10)+w9; P(H, A, B, C, D, E, F, G, w8, 0xA831C66DU);
w9=S1(w7)+w2+S0(w11)+w10; P(G, H, A, B, C, D, E, F, w9, 0xB00327C8U);
w10=S1(w8)+w3+S0(w12)+w11; P(F, G, H, A, B, C, D, E, w10, 0xBF597FC7U);
w11=S1(w9)+w4+S0(w13)+w12; P(E, F, G, H, A, B, C, D, w11, 0xC6E00BF3U);
w12=S1(w10)+w5+S0(w14)+w13; P(D, E, F, G, H, A, B, C, w12, 0xD5A79147U);
w13=S1(w11)+w6+S0(SIZE)+w14; P(C, D, E, F, G, H, A, B, w13, 0x06CA6351U);
w14=S1(w12)+w7+S0(w16)+SIZE; P(B, C, D, E, F, G, H, A, w14, 0x14292967U);
SIZE=S1(w13)+w8+S0(w0)+w16; P(A, B, C, D, E, F, G, H, SIZE, 0x27B70A85U);
w16=S1(w14)+w9+S0(w1)+w0; P(H, A, B, C, D, E, F, G, w16, 0x2E1B2138U);
w0=S1(SIZE)+w10+S0(w2)+w1; P(G, H, A, B, C, D, E, F, w0, 0x4D2C6DFCU);
w1=S1(w16)+w11+S0(w3)+w2; P(F, G, H, A, B, C, D, E, w1, 0x53380D13U);
w2=S1(w0)+w12+S0(w4)+w3; P(E, F, G, H, A, B, C, D, w2, 0x650A7354U);
w3=S1(w1)+w13+S0(w5)+w4; P(D, E, F, G, H, A, B, C, w3, 0x766A0ABBU);
w4=S1(w2)+w14+S0(w6)+w5; P(C, D, E, F, G, H, A, B, w4, 0x81C2C92EU);
w5=S1(w3)+SIZE+S0(w7)+w6; P(B, C, D, E, F, G, H, A, w5, 0x92722C85U);
w6=S1(w4)+w16+S0(w8)+w7; P(A, B, C, D, E, F, G, H, w6, 0xA2BFE8A1U);
w7=S1(w5)+w0+S0(w9)+w8; P(H, A, B, C, D, E, F, G, w7, 0xA81A664BU);
w8=S1(w6)+w1+S0(w10)+w9; P(G, H, A, B, C, D, E, F, w8, 0xC24B8B70U);
w9=S1(w7)+w2+S0(w11)+w10; P(F, G, H, A, B, C, D, E, w9, 0xC76C51A3U);
w10=S1(w8)+w3+S0(w12)+w11; P(E, F, G, H, A, B, C, D, w10, 0xD192E819U);
w11=S1(w9)+w4+S0(w13)+w12; P(D, E, F, G, H, A, B, C, w11, 0xD6990624U);
w12=S1(w10)+w5+S0(w14)+w13; P(C, D, E, F, G, H, A, B, w12, 0xF40E3585U);
w13=S1(w11)+w6+S0(SIZE)+w14; P(B, C, D, E, F, G, H, A, w13, 0x106AA070U);
w14=S1(w12)+w7+S0(w16)+SIZE; P(A, B, C, D, E, F, G, H, w14, 0x19A4C116U);
SIZE=S1(w13)+w8+S0(w0)+w16; P(H, A, B, C, D, E, F, G, SIZE, 0x1E376C08U);
w16=S1(w14)+w9+S0(w1)+w0; P(G, H, A, B, C, D, E, F, w16, 0x2748774CU);
w0=S1(SIZE)+w10+S0(w2)+w1; P(F, G, H, A, B, C, D, E, w0, 0x34B0BCB5U);
w1=S1(w16)+w11+S0(w3)+w2; P(E, F, G, H, A, B, C, D, w1, 0x391C0CB3U);
w2=S1(w0)+w12+S0(w4)+w3; P(D, E, F, G, H, A, B, C, w2, 0x4ED8AA4AU);
w3=S1(w1)+w13+S0(w5)+w4; P(C, D, E, F, G, H, A, B, w3, 0x5B9CCA4FU);
w4=S1(w2)+w14+S0(w6)+w5; P(B, C, D, E, F, G, H, A, w4, 0x682E6FF3U);
w5=S1(w3)+SIZE+S0(w7)+w6; P(A, B, C, D, E, F, G, H, w5, 0x748F82EEU);
w6=S1(w4)+w16+S0(w8)+w7; P(H, A, B, C, D, E, F, G, w6, 0x78A5636FU);
w7=S1(w5)+w0+S0(w9)+w8; P(G, H, A, B, C, D, E, F, w7, 0x84C87814U);
w8=S1(w6)+w1+S0(w10)+w9; P(F, G, H, A, B, C, D, E, w8, 0x8CC70208U);
w9=S1(w7)+w2+S0(w11)+w10; P(E, F, G, H, A, B, C, D, w9, 0x90BEFFFAU);
w10=S1(w8)+w3+S0(w12)+w11; P(D, E, F, G, H, A, B, C, w10, 0xA4506CEBU);
w11=S1(w9)+w4+S0(w13)+w12; P(C, D, E, F, G, H, A, B, w11, 0xBEF9A3F7U);
w12=S1(w10)+w5+S0(w14)+w13; P(B, C, D, E, F, G, H, A, w12, 0xC67178F2U);

A=A+(uint)S1H0;
B=B+(uint)S1H1;
C=C+(uint)S1H2;
D=D+(uint)S1H3;
E=E+(uint)S1H4;
F=F+(uint)S1H5;
G=G+(uint)S1H6;
H=H+(uint)S1H7;

Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);
Endian_Reverse32(F);
Endian_Reverse32(G);
Endian_Reverse32(H);

dst[(get_global_id(0)*18)+0]=A;
dst[(get_global_id(0)*18)+1]=B;
dst[(get_global_id(0)*18)+2]=C;
dst[(get_global_id(0)*18)+3]=D;
dst[(get_global_id(0)*18)+4]=E;
dst[(get_global_id(0)*18)+5]=F;
dst[(get_global_id(0)*18)+6]=G;
dst[(get_global_id(0)*18)+7]=H;
dst[(get_global_id(0)*18)+8]=0;
dst[(get_global_id(0)*18)+9]=0;
dst[(get_global_id(0)*18)+10]=0;
dst[(get_global_id(0)*18)+11]=0;
dst[(get_global_id(0)*18)+12]=0;
dst[(get_global_id(0)*18)+13]=0;
dst[(get_global_id(0)*18)+14]=0;
dst[(get_global_id(0)*18)+15]=0;
dst[(get_global_id(0)*18)+16]=0;
dst[(get_global_id(0)*18)+17]=32;
}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void block( __global uint *dst,  __global uint *input,__global uint *input1, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint ia,ib,ic,id,ie;  
uint a1,b1,c1,d1,e1,f1,g1,h1; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,SIZE;
ulong ww0, ww1, ww2, ww3, ww4, ww5, ww6, ww7,ww8,ww9,ww10,ww11,ww12,ww13,ww14,ww16,wSIZE;
uint A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp;
uint sA,sB,sC,sD,sE,sF,sG,sH;
ulong wA,wB,wC,wD,wE,wF,wG,wH,wl,wtmp1,wtmp2,wtemp,T1;
ulong wwA,wwB,wwC,wwD,wwE,wwF,wwG,wwH;
uint rk0,rk1,rk2,rk3,rk4,rk5;
uint r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
uint k0,k1,k2,k3,k4,k5,k6,k7;
uint s0, s1, s2, s3, t0, t1, t2, t3;
uint ir0,ir1,ir2,ir3;
uint A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14,A15,A16,bs,lc;
uint B1,B2,B3,B4,B5,B6,B7,B8;
__local uint block[64][64];
uint sz,bsz,elem;
__local uint lTe[256];
uint I1,I2,I3,I4;

elem = input[get_global_id(0)*18+16];

if ((singlehash.sE>=64)&&(singlehash.sE>=(elem+32))) return;

lTe[GLI]=Te[GLI];
lTe[64+GLI]=Te[64+GLI];
lTe[128+GLI]=Te[128+GLI];
lTe[192+GLI]=Te[192+GLI];
barrier(CLK_LOCAL_MEM_FENCE);

A1=input[get_global_id(0)*18];
A2=input[get_global_id(0)*18+1];
A3=input[get_global_id(0)*18+2];
A4=input[get_global_id(0)*18+3];
A5=input[get_global_id(0)*18+4];
A6=input[get_global_id(0)*18+5];
A7=input[get_global_id(0)*18+6];
A8=input[get_global_id(0)*18+7];
A9=input[get_global_id(0)*18+8];
A10=input[get_global_id(0)*18+9];
A11=input[get_global_id(0)*18+10];
A12=input[get_global_id(0)*18+11];
A13=input[get_global_id(0)*18+12];
A14=input[get_global_id(0)*18+13];
A15=input[get_global_id(0)*18+14];
A16=input[get_global_id(0)*18+15];
bs=input[get_global_id(0)*18+17];
B1=input1[get_global_id(0)*8];
B2=input1[get_global_id(0)*8+1];
B3=input1[get_global_id(0)*8+2];
B4=input1[get_global_id(0)*8+3];
B5=input1[get_global_id(0)*8+4];
B6=input1[get_global_id(0)*8+5];
B7=input1[get_global_id(0)*8+6];
B8=input1[get_global_id(0)*8+7];

sz=0;
bsz = size[get_global_id(0)];
block[GLI][0]=block[GLI][1]=block[GLI][2]=block[GLI][3]=0;
block[GLI][4]=block[GLI][5]=block[GLI][6]=block[GLI][7]=0;
block[GLI][8]=block[GLI][9]=block[GLI][10]=block[GLI][11]=0;
block[GLI][12]=block[GLI][13]=block[GLI][14]=block[GLI][15]=0;


// Get first block
SET_AB(block[GLI],B1,0,0);
SET_AB(block[GLI],B2,4,0);
SET_AB(block[GLI],B3,8,0);
SET_AB(block[GLI],B4,12,0);
SET_AB(block[GLI],B5,16,0);
SET_AB(block[GLI],B6,20,0);
SET_AB(block[GLI],B7,24,0);
SET_AB(block[GLI],B8,28,0);
SET_AB(block[GLI],A1,bsz,0);
SET_AB(block[GLI],A2,bsz+4,0);
SET_AB(block[GLI],A3,bsz+8,0);
SET_AB(block[GLI],A4,bsz+12,0);
SET_AB(block[GLI],A5,bsz+16,0);
SET_AB(block[GLI],A6,bsz+20,0);
SET_AB(block[GLI],A7,bsz+24,0);
SET_AB(block[GLI],A8,bsz+28,0);


// Encrypt first block to get algo type (wasteful...)
rk0=A1;
rk1=A2;
rk2=A3;
rk3=A4;
Endian_Reverse32(rk0);
Endian_Reverse32(rk1);
Endian_Reverse32(rk2);
Endian_Reverse32(rk3);

AES128_GET_KEYS1;
ir0=block[GLI][0]^A5;
ir1=block[GLI][1]^A6;
ir2=block[GLI][2]^A7;
ir3=block[GLI][3]^A8;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;

AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;


ic = (s0&255)+((s0>>8)&255)+((s0>>16)&255)+((s0>>24)&255);
ic += ((s1&255)+((s1>>8)&255)+((s1>>16)&255)+((s1>>24)&255));
ic += ((s2&255)+((s2>>8)&255)+((s2>>16)&255)+((s2>>24)&255));
ic += ((s3&255)+((s3>>8)&255)+((s3>>16)&255)+((s3>>24)&255));
ic = 32 + (ic%3)*16;
// ic determines hash function (64 - SHA512, 48 - SHA384, 32 - SHA256)


if (ic==64)
{
ib = 0;
// I1..I4 now holds the CBC IV
I1=A5;I2=A6;I3=A7;I4=A8;
block[GLI][0]=block[GLI][1]=block[GLI][2]=block[GLI][3]=0;
block[GLI][4]=block[GLI][5]=block[GLI][6]=block[GLI][7]=0;
block[GLI][8]=block[GLI][9]=block[GLI][10]=block[GLI][11]=0;
block[GLI][12]=block[GLI][13]=block[GLI][14]=block[GLI][15]=0;
block[GLI][16]=block[GLI][17]=block[GLI][18]=block[GLI][19]=0;
block[GLI][20]=block[GLI][21]=block[GLI][22]=block[GLI][23]=0;
block[GLI][24]=block[GLI][25]=block[GLI][26]=block[GLI][27]=0;
block[GLI][28]=block[GLI][29]=block[GLI][30]=block[GLI][31]=0;
block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;
block[GLI][48]=block[GLI][49]=block[GLI][50]=block[GLI][51]=0;
block[GLI][52]=block[GLI][53]=block[GLI][54]=block[GLI][55]=0;
block[GLI][56]=block[GLI][57]=block[GLI][58]=block[GLI][59]=0;
block[GLI][60]=block[GLI][61]=block[GLI][62]=block[GLI][63]=0;
wwA=wA=S3H0;
wwB=wB=S3H1;
wwC=wC=S3H2;
wwD=wD=S3H3;
wwE=wE=S3H4;
wwF=wF=S3H5;
wwG=wG=S3H6;
wwH=wH=S3H7;

// Concatenate password+block 64 times
for (id=0;id<64;id++)
{

SET_AB(block[GLI],B1,ib,0);
SET_AB(block[GLI],B2,ib+4,0);
SET_AB(block[GLI],B3,ib+8,0);
SET_AB(block[GLI],B4,ib+12,0);
SET_AB(block[GLI],B5,ib+16,0);
SET_AB(block[GLI],B6,ib+20,0);
SET_AB(block[GLI],B7,ib+24,0);
SET_AB(block[GLI],B8,ib+28,0);
SET_AB(block[GLI],A1,ib+bsz,0);
SET_AB(block[GLI],A2,ib+bsz+4,0);
SET_AB(block[GLI],A3,ib+bsz+8,0);
SET_AB(block[GLI],A4,ib+bsz+12,0);
SET_AB(block[GLI],A5,ib+bsz+16,0);
SET_AB(block[GLI],A6,ib+bsz+20,0);
SET_AB(block[GLI],A7,ib+bsz+24,0);
SET_AB(block[GLI],A8,ib+bsz+28,0);
SET_AB(block[GLI],A9,ib+bsz+32,0);
SET_AB(block[GLI],A10,ib+bsz+36,0);
SET_AB(block[GLI],A11,ib+bsz+40,0);
SET_AB(block[GLI],A12,ib+bsz+44,0);
SET_AB(block[GLI],A13,ib+bsz+48,0);
SET_AB(block[GLI],A14,ib+bsz+52,0);
SET_AB(block[GLI],A15,ib+bsz+56,0);
SET_AB(block[GLI],A16,ib+bsz+60,0);
ib+=(bsz+bs);

// Full block?
if (ib>=128)
{
for (ie=0;ie<8;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}
ib -= 128;


// Do the SHA operation
ww0 = block[GLI][1];
ww0 = ww0<<32;
ww0 |= block[GLI][0];
ww1 = block[GLI][3];
ww1 = ww1<<32;
ww1 |= block[GLI][2];
ww2 = block[GLI][5];
ww2 = ww2<<32;
ww2 |= block[GLI][4];
ww3 = block[GLI][7];
ww3 = ww3<<32;
ww3 |= block[GLI][6];
ww4 = block[GLI][9];
ww4 = ww4<<32;
ww4 |= block[GLI][8];
ww5 = block[GLI][11];
ww5 = ww5<<32;
ww5 |= block[GLI][10];
ww6 = block[GLI][13];
ww6 = ww6<<32;
ww6 |= block[GLI][12];
ww7 = block[GLI][15];
ww7 = ww7<<32;
ww7 |= block[GLI][14];
ww8 = block[GLI][17];
ww8 = ww8<<32;
ww8 |= block[GLI][16];
ww9 = block[GLI][19];
ww9 = ww9<<32;
ww9 |= block[GLI][18];
ww10 = block[GLI][21];
ww10 = ww10<<32;
ww10 |= block[GLI][20];
ww11 = block[GLI][23];
ww11 = ww11<<32;
ww11 |= block[GLI][22];
ww12 = block[GLI][25];
ww12 = ww12<<32;
ww12 |= block[GLI][24];
ww13 = block[GLI][27];
ww13 = ww13<<32;
ww13 |= block[GLI][26];
ww14 = block[GLI][29];
ww14 = ww14<<32;
ww14 |= block[GLI][28];
wSIZE = block[GLI][31];
wSIZE = wSIZE<<32;
wSIZE |= block[GLI][30];

block[GLI][0]=block[GLI][32];
block[GLI][1]=block[GLI][33];
block[GLI][2]=block[GLI][34];
block[GLI][3]=block[GLI][35];
block[GLI][4]=block[GLI][36];
block[GLI][5]=block[GLI][37];
block[GLI][6]=block[GLI][38];
block[GLI][7]=block[GLI][39];
block[GLI][8]=block[GLI][40];
block[GLI][9]=block[GLI][41];
block[GLI][10]=block[GLI][42];
block[GLI][11]=block[GLI][43];
block[GLI][12]=block[GLI][44];
block[GLI][13]=block[GLI][45];
block[GLI][14]=block[GLI][46];
block[GLI][15]=block[GLI][47];
block[GLI][16]=block[GLI][48];
block[GLI][17]=block[GLI][49];
block[GLI][18]=block[GLI][50];
block[GLI][19]=block[GLI][51];
block[GLI][20]=block[GLI][52];
block[GLI][21]=block[GLI][53];
block[GLI][22]=block[GLI][54];
block[GLI][23]=block[GLI][55];
block[GLI][24]=block[GLI][56];
block[GLI][25]=block[GLI][57];
block[GLI][26]=block[GLI][58];
block[GLI][27]=block[GLI][59];
block[GLI][28]=block[GLI][60];
block[GLI][29]=block[GLI][61];
block[GLI][30]=block[GLI][62];
block[GLI][31]=block[GLI][63];


block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;
block[GLI][48]=block[GLI][49]=block[GLI][50]=block[GLI][51]=0;
block[GLI][52]=block[GLI][53]=block[GLI][54]=block[GLI][55]=0;
block[GLI][56]=block[GLI][57]=block[GLI][58]=block[GLI][59]=0;
block[GLI][60]=block[GLI][61]=block[GLI][62]=block[GLI][63]=0;

wA=(ulong)wwA;
wB=(ulong)wwB;
wC=(ulong)wwC;
wD=(ulong)wwD;
wE=(ulong)wwE;
wF=(ulong)wwF;
wG=(ulong)wwG;
wH=(ulong)wwH;

Endian_Reverse64(ww0);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC1,ww0);
Endian_Reverse64(ww1);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC2,ww1);
Endian_Reverse64(ww2);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC3,ww2);
Endian_Reverse64(ww3);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC4,ww3);
Endian_Reverse64(ww4);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC5,ww4);
Endian_Reverse64(ww5);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC6,ww5);
Endian_Reverse64(ww6);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC7,ww6);
Endian_Reverse64(ww7);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,AC8,ww7);
Endian_Reverse64(ww8);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC9,ww8);
Endian_Reverse64(ww9);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC10,ww9);
Endian_Reverse64(ww10);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC11,ww10);
Endian_Reverse64(ww11);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC12,ww11);
Endian_Reverse64(ww12);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC13,ww12);
Endian_Reverse64(ww13);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC14,ww13);
Endian_Reverse64(ww14);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC15,ww14);
Endian_Reverse64(wSIZE);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,wSIZE,AC16);


ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww16,AC17);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww0,AC18);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww1,AC19);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww2,AC20);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww3,AC21);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww4,AC22);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww5,AC23);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww6,AC24);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww7,AC25);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww8,AC26);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww9,AC27);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww10,AC28);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww11,AC29);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww12,AC30);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww13,AC31);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww14,AC32);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,wSIZE,AC33);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww16,AC34);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww0,AC35);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww1,AC36);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww2,AC37);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww3,AC38);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww4,AC39);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww5,AC40);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww6,AC41);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww7,AC42);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww8,AC43);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww9,AC44);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww10,AC45);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww11,AC46);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww12,AC47);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww13,AC48);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww14,AC49);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,wSIZE,AC50);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww16,AC51);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww0,AC52);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww1,AC53);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww2,AC54);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww3,AC55);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww4,AC56);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww5,AC57);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww6,AC58);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww7,AC59);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww8,AC60);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww9,AC61);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww10,AC62);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww11,AC63);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww12,AC64);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww13,AC65);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww14,AC66);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,wSIZE,AC67);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww16,AC68);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww0,AC69);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww1,AC70);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww2,AC71);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww3,AC72);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww4,AC73);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww5,AC74);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww6,AC75);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww7,AC76);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww8,AC77);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww9,AC78);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww10,AC79);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww11,AC80);

wA+=(ulong)wwA;
wB+=(ulong)wwB;
wC+=(ulong)wwC;
wD+=(ulong)wwD;
wE+=(ulong)wwE;
wF+=(ulong)wwF;
wG+=(ulong)wwG;
wH+=(ulong)wwH;
wwA=wA;wwB=wB;wwC=wC;wwD=wD;wwE=wE;wwF=wF;wwG=wG;wwH=wH;
}
}

// when password has odd length, additional 64 bytes need to be accounted for

for (ie=0;ie<(ib>0) ? 4 : 0;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}


// Put the 0x80 end marker, do the final SHA calculation
SET_AB(block[GLI],0x80,ib,0);

wA=(ulong)wwA;
wB=(ulong)wwB;
wC=(ulong)wwC;
wD=(ulong)wwD;
wE=(ulong)wwE;
wF=(ulong)wwF;
wG=(ulong)wwG;
wH=(ulong)wwH;


ww0 = block[GLI][1];
ww0 = ww0<<32;
ww0 |= block[GLI][0];
ww1 = block[GLI][3];
ww1 = ww1<<32;
ww1 |= block[GLI][2];
ww2 = block[GLI][5];
ww2 = ww2<<32;
ww2 |= block[GLI][4];
ww3 = block[GLI][7];
ww3 = ww3<<32;
ww3 |= block[GLI][6];
ww4 = block[GLI][9];
ww4 = ww4<<32;
ww4 |= block[GLI][8];
ww5 = block[GLI][11];
ww5 = ww5<<32;
ww5 |= block[GLI][10];
ww6 = block[GLI][13];
ww6 = ww6<<32;
ww6 |= block[GLI][12];
ww7 = block[GLI][15];
ww7 = ww7<<32;
ww7 |= block[GLI][14];
ww8 = block[GLI][17];
ww8 = ww8<<32;
ww8 |= block[GLI][16];
ww9 = block[GLI][19];
ww9 = ww9<<32;
ww9 |= block[GLI][18];
ww10 = block[GLI][21];
ww10 = ww10<<32;
ww10 |= block[GLI][20];
ww11 = block[GLI][23];
ww11 = ww11<<32;
ww11 |= block[GLI][22];
ww12 = block[GLI][25];
ww12 = ww12<<32;
ww12 |= block[GLI][24];
ww13 = block[GLI][27];
ww13 = ww13<<32;
ww13 |= block[GLI][26];
ww14=(ulong)0;
wSIZE=(ulong)(64*(bsz+bs))<<3;


Endian_Reverse64(ww0);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC1,ww0);
Endian_Reverse64(ww1);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC2,ww1);
Endian_Reverse64(ww2);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC3,ww2);
Endian_Reverse64(ww3);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC4,ww3);
Endian_Reverse64(ww4);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC5,ww4);
Endian_Reverse64(ww5);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC6,ww5);
Endian_Reverse64(ww6);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC7,ww6);
Endian_Reverse64(ww7);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,AC8,ww7);
Endian_Reverse64(ww8);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC9,ww8);
Endian_Reverse64(ww9);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC10,ww9);
Endian_Reverse64(ww10);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC11,ww10);
Endian_Reverse64(ww11);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC12,ww11);
Endian_Reverse64(ww12);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC13,ww12);
Endian_Reverse64(ww13);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC14,ww13);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC15,ww14);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,wSIZE,AC16);


ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww16,AC17);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww0,AC18);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww1,AC19);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww2,AC20);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww3,AC21);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww4,AC22);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww5,AC23);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww6,AC24);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww7,AC25);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww8,AC26);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww9,AC27);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww10,AC28);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww11,AC29);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww12,AC30);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww13,AC31);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww14,AC32);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,wSIZE,AC33);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww16,AC34);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww0,AC35);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww1,AC36);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww2,AC37);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww3,AC38);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww4,AC39);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww5,AC40);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww6,AC41);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww7,AC42);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww8,AC43);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww9,AC44);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww10,AC45);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww11,AC46);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww12,AC47);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww13,AC48);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww14,AC49);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,wSIZE,AC50);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww16,AC51);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww0,AC52);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww1,AC53);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww2,AC54);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww3,AC55);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww4,AC56);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww5,AC57);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww6,AC58);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww7,AC59);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww8,AC60);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww9,AC61);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww10,AC62);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww11,AC63);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww12,AC64);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww13,AC65);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww14,AC66);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,wSIZE,AC67);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww16,AC68);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww0,AC69);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww1,AC70);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww2,AC71);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww3,AC72);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww4,AC73);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww5,AC74);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww6,AC75);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww7,AC76);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww8,AC77);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww9,AC78);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww10,AC79);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww11,AC80);

wA+=(ulong)wwA;
wB+=(ulong)wwB;
wC+=(ulong)wwC;
wD+=(ulong)wwD;
wE+=(ulong)wwE;
wF+=(ulong)wwF;
wG+=(ulong)wwG;
wH+=(ulong)wwH;

// We need just 32 bytes of the output
Endian_Reverse64(wA);
Endian_Reverse64(wB);
Endian_Reverse64(wC);
Endian_Reverse64(wD);
Endian_Reverse64(wE);
Endian_Reverse64(wF);
Endian_Reverse64(wG);
Endian_Reverse64(wH);
A1 = (uint)(wA&0xFFFFFFFF);
wA = wA>>32;
A2 = (uint)(wA&0xFFFFFFFF);
A3 = (uint)(wB&0xFFFFFFFF);
wB = wB>>32;
A4 = (uint)(wB&0xFFFFFFFF);
A5 = (uint)(wC&0xFFFFFFFF);
wC = wC>>32;
A6 = (uint)(wC&0xFFFFFFFF);
A7 = (uint)(wD&0xFFFFFFFF);
wD = wD>>32;
A8 = (uint)(wD&0xFFFFFFFF);
A9 = (uint)(wE&0xFFFFFFFF);
wE = wE>>32;
A10 = (uint)(wE&0xFFFFFFFF);
A11 = (uint)(wF&0xFFFFFFFF);
wF = wF>>32;
A12 = (uint)(wF&0xFFFFFFFF);
A13 = (uint)(wG&0xFFFFFFFF);
wG = wG>>32;
A14 = (uint)(wG&0xFFFFFFFF);
A15 = (uint)(wH&0xFFFFFFFF);
wH = wH>>32;
A16 = (uint)(wH&0xFFFFFFFF);
bs=64;
}

else if (ic==48)
{
ib = 0;
// I1..I4 now holds the CBC IV
I1=A5;I2=A6;I3=A7;I4=A8;
block[GLI][0]=block[GLI][1]=block[GLI][2]=block[GLI][3]=0;
block[GLI][4]=block[GLI][5]=block[GLI][6]=block[GLI][7]=0;
block[GLI][8]=block[GLI][9]=block[GLI][10]=block[GLI][11]=0;
block[GLI][12]=block[GLI][13]=block[GLI][14]=block[GLI][15]=0;
block[GLI][16]=block[GLI][17]=block[GLI][18]=block[GLI][19]=0;
block[GLI][20]=block[GLI][21]=block[GLI][22]=block[GLI][23]=0;
block[GLI][24]=block[GLI][25]=block[GLI][26]=block[GLI][27]=0;
block[GLI][28]=block[GLI][29]=block[GLI][30]=block[GLI][31]=0;
block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;
block[GLI][48]=block[GLI][49]=block[GLI][50]=block[GLI][51]=0;
block[GLI][52]=block[GLI][53]=block[GLI][54]=block[GLI][55]=0;
block[GLI][56]=block[GLI][57]=block[GLI][58]=block[GLI][59]=0;
block[GLI][60]=block[GLI][61]=block[GLI][62]=block[GLI][63]=0;
wwA=wA=S2H0;
wwB=wB=S2H1;
wwC=wC=S2H2;
wwD=wD=S2H3;
wwE=wE=S2H4;
wwF=wF=S2H5;
wwG=wG=S2H6;
wwH=wH=S2H7;

// Concatenate password+block 64 times
for (id=0;id<64;id++)
{

SET_AB(block[GLI],B1,ib,0);
SET_AB(block[GLI],B2,ib+4,0);
SET_AB(block[GLI],B3,ib+8,0);
SET_AB(block[GLI],B4,ib+12,0);
SET_AB(block[GLI],B5,ib+16,0);
SET_AB(block[GLI],B6,ib+20,0);
SET_AB(block[GLI],B7,ib+24,0);
SET_AB(block[GLI],B8,ib+28,0);
SET_AB(block[GLI],A1,ib+bsz,0);
SET_AB(block[GLI],A2,ib+bsz+4,0);
SET_AB(block[GLI],A3,ib+bsz+8,0);
SET_AB(block[GLI],A4,ib+bsz+12,0);
SET_AB(block[GLI],A5,ib+bsz+16,0);
SET_AB(block[GLI],A6,ib+bsz+20,0);
SET_AB(block[GLI],A7,ib+bsz+24,0);
SET_AB(block[GLI],A8,ib+bsz+28,0);
SET_AB(block[GLI],A9,ib+bsz+32,0);
SET_AB(block[GLI],A10,ib+bsz+36,0);
SET_AB(block[GLI],A11,ib+bsz+40,0);
SET_AB(block[GLI],A12,ib+bsz+44,0);
SET_AB(block[GLI],A13,ib+bsz+48,0);
SET_AB(block[GLI],A14,ib+bsz+52,0);
SET_AB(block[GLI],A15,ib+bsz+56,0);
SET_AB(block[GLI],A16,ib+bsz+60,0);
ib+=(bsz+bs);

// Full block?
if (ib>=128)
{
for (ie=0;ie<8;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}
ib -= 128;


// Do the SHA operation
ww0 = block[GLI][1];
ww0 = ww0<<32;
ww0 |= block[GLI][0];
ww1 = block[GLI][3];
ww1 = ww1<<32;
ww1 |= block[GLI][2];
ww2 = block[GLI][5];
ww2 = ww2<<32;
ww2 |= block[GLI][4];
ww3 = block[GLI][7];
ww3 = ww3<<32;
ww3 |= block[GLI][6];
ww4 = block[GLI][9];
ww4 = ww4<<32;
ww4 |= block[GLI][8];
ww5 = block[GLI][11];
ww5 = ww5<<32;
ww5 |= block[GLI][10];
ww6 = block[GLI][13];
ww6 = ww6<<32;
ww6 |= block[GLI][12];
ww7 = block[GLI][15];
ww7 = ww7<<32;
ww7 |= block[GLI][14];
ww8 = block[GLI][17];
ww8 = ww8<<32;
ww8 |= block[GLI][16];
ww9 = block[GLI][19];
ww9 = ww9<<32;
ww9 |= block[GLI][18];
ww10 = block[GLI][21];
ww10 = ww10<<32;
ww10 |= block[GLI][20];
ww11 = block[GLI][23];
ww11 = ww11<<32;
ww11 |= block[GLI][22];
ww12 = block[GLI][25];
ww12 = ww12<<32;
ww12 |= block[GLI][24];
ww13 = block[GLI][27];
ww13 = ww13<<32;
ww13 |= block[GLI][26];
ww14 = block[GLI][29];
ww14 = ww14<<32;
ww14 |= block[GLI][28];
wSIZE = block[GLI][31];
wSIZE = wSIZE<<32;
wSIZE |= block[GLI][30];

block[GLI][0]=block[GLI][32];
block[GLI][1]=block[GLI][33];
block[GLI][2]=block[GLI][34];
block[GLI][3]=block[GLI][35];
block[GLI][4]=block[GLI][36];
block[GLI][5]=block[GLI][37];
block[GLI][6]=block[GLI][38];
block[GLI][7]=block[GLI][39];
block[GLI][8]=block[GLI][40];
block[GLI][9]=block[GLI][41];
block[GLI][10]=block[GLI][42];
block[GLI][11]=block[GLI][43];
block[GLI][12]=block[GLI][44];
block[GLI][13]=block[GLI][45];
block[GLI][14]=block[GLI][46];
block[GLI][15]=block[GLI][47];
block[GLI][16]=block[GLI][48];
block[GLI][17]=block[GLI][49];
block[GLI][18]=block[GLI][50];
block[GLI][19]=block[GLI][51];
block[GLI][20]=block[GLI][52];
block[GLI][21]=block[GLI][53];
block[GLI][22]=block[GLI][54];
block[GLI][23]=block[GLI][55];
block[GLI][24]=block[GLI][56];
block[GLI][25]=block[GLI][57];
block[GLI][26]=block[GLI][58];
block[GLI][27]=block[GLI][59];
block[GLI][28]=block[GLI][60];
block[GLI][29]=block[GLI][61];
block[GLI][30]=block[GLI][62];
block[GLI][31]=block[GLI][63];


block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;
block[GLI][48]=block[GLI][49]=block[GLI][50]=block[GLI][51]=0;
block[GLI][52]=block[GLI][53]=block[GLI][54]=block[GLI][55]=0;
block[GLI][56]=block[GLI][57]=block[GLI][58]=block[GLI][59]=0;
block[GLI][60]=block[GLI][61]=block[GLI][62]=block[GLI][63]=0;

wA=(ulong)wwA;
wB=(ulong)wwB;
wC=(ulong)wwC;
wD=(ulong)wwD;
wE=(ulong)wwE;
wF=(ulong)wwF;
wG=(ulong)wwG;
wH=(ulong)wwH;

Endian_Reverse64(ww0);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC1,ww0);
Endian_Reverse64(ww1);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC2,ww1);
Endian_Reverse64(ww2);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC3,ww2);
Endian_Reverse64(ww3);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC4,ww3);
Endian_Reverse64(ww4);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC5,ww4);
Endian_Reverse64(ww5);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC6,ww5);
Endian_Reverse64(ww6);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC7,ww6);
Endian_Reverse64(ww7);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,AC8,ww7);
Endian_Reverse64(ww8);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC9,ww8);
Endian_Reverse64(ww9);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC10,ww9);
Endian_Reverse64(ww10);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC11,ww10);
Endian_Reverse64(ww11);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC12,ww11);
Endian_Reverse64(ww12);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC13,ww12);
Endian_Reverse64(ww13);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC14,ww13);
Endian_Reverse64(ww14);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC15,ww14);
Endian_Reverse64(wSIZE);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,wSIZE,AC16);


ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww16,AC17);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww0,AC18);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww1,AC19);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww2,AC20);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww3,AC21);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww4,AC22);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww5,AC23);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww6,AC24);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww7,AC25);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww8,AC26);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww9,AC27);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww10,AC28);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww11,AC29);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww12,AC30);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww13,AC31);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww14,AC32);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,wSIZE,AC33);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww16,AC34);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww0,AC35);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww1,AC36);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww2,AC37);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww3,AC38);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww4,AC39);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww5,AC40);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww6,AC41);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww7,AC42);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww8,AC43);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww9,AC44);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww10,AC45);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww11,AC46);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww12,AC47);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww13,AC48);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww14,AC49);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,wSIZE,AC50);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww16,AC51);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww0,AC52);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww1,AC53);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww2,AC54);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww3,AC55);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww4,AC56);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww5,AC57);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww6,AC58);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww7,AC59);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww8,AC60);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww9,AC61);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww10,AC62);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww11,AC63);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww12,AC64);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww13,AC65);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww14,AC66);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,wSIZE,AC67);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww16,AC68);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww0,AC69);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww1,AC70);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww2,AC71);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww3,AC72);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww4,AC73);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww5,AC74);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww6,AC75);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww7,AC76);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww8,AC77);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww9,AC78);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww10,AC79);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww11,AC80);

wA+=(ulong)wwA;
wB+=(ulong)wwB;
wC+=(ulong)wwC;
wD+=(ulong)wwD;
wE+=(ulong)wwE;
wF+=(ulong)wwF;
wG+=(ulong)wwG;
wH+=(ulong)wwH;
wwA=wA;wwB=wB;wwC=wC;wwD=wD;wwE=wE;wwF=wF;wwG=wG;wwH=wH;
}
}

// when password has odd length, additional 64 bytes need to be accounted for

for (ie=0;ie<(ib>0) ? 4 : 0;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}


// Put the 0x80 end marker, do the final SHA calculation
SET_AB(block[GLI],0x80,ib,0);

wA=(ulong)wwA;
wB=(ulong)wwB;
wC=(ulong)wwC;
wD=(ulong)wwD;
wE=(ulong)wwE;
wF=(ulong)wwF;
wG=(ulong)wwG;
wH=(ulong)wwH;


ww0 = block[GLI][1];
ww0 = ww0<<32;
ww0 |= block[GLI][0];
ww1 = block[GLI][3];
ww1 = ww1<<32;
ww1 |= block[GLI][2];
ww2 = block[GLI][5];
ww2 = ww2<<32;
ww2 |= block[GLI][4];
ww3 = block[GLI][7];
ww3 = ww3<<32;
ww3 |= block[GLI][6];
ww4 = block[GLI][9];
ww4 = ww4<<32;
ww4 |= block[GLI][8];
ww5 = block[GLI][11];
ww5 = ww5<<32;
ww5 |= block[GLI][10];
ww6 = block[GLI][13];
ww6 = ww6<<32;
ww6 |= block[GLI][12];
ww7 = block[GLI][15];
ww7 = ww7<<32;
ww7 |= block[GLI][14];
ww8 = block[GLI][17];
ww8 = ww8<<32;
ww8 |= block[GLI][16];
ww9 = block[GLI][19];
ww9 = ww9<<32;
ww9 |= block[GLI][18];
ww10 = block[GLI][21];
ww10 = ww10<<32;
ww10 |= block[GLI][20];
ww11 = block[GLI][23];
ww11 = ww11<<32;
ww11 |= block[GLI][22];
ww12 = block[GLI][25];
ww12 = ww12<<32;
ww12 |= block[GLI][24];
ww13 = block[GLI][27];
ww13 = ww13<<32;
ww13 |= block[GLI][26];
ww14=(ulong)0;
wSIZE=(ulong)(64*(bsz+bs))<<3;


Endian_Reverse64(ww0);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC1,ww0);
Endian_Reverse64(ww1);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC2,ww1);
Endian_Reverse64(ww2);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC3,ww2);
Endian_Reverse64(ww3);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC4,ww3);
Endian_Reverse64(ww4);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC5,ww4);
Endian_Reverse64(ww5);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC6,ww5);
Endian_Reverse64(ww6);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC7,ww6);
Endian_Reverse64(ww7);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,AC8,ww7);
Endian_Reverse64(ww8);
ROUND512_0_TO_15(wA,wB,wC,wD,wE,wF,wG,wH,AC9,ww8);
Endian_Reverse64(ww9);
ROUND512_0_TO_15(wH,wA,wB,wC,wD,wE,wF,wG,AC10,ww9);
Endian_Reverse64(ww10);
ROUND512_0_TO_15(wG,wH,wA,wB,wC,wD,wE,wF,AC11,ww10);
Endian_Reverse64(ww11);
ROUND512_0_TO_15(wF,wG,wH,wA,wB,wC,wD,wE,AC12,ww11);
Endian_Reverse64(ww12);
ROUND512_0_TO_15(wE,wF,wG,wH,wA,wB,wC,wD,AC13,ww12);
Endian_Reverse64(ww13);
ROUND512_0_TO_15(wD,wE,wF,wG,wH,wA,wB,wC,AC14,ww13);
ROUND512_0_TO_15(wC,wD,wE,wF,wG,wH,wA,wB,AC15,ww14);
ROUND512_0_TO_15(wB,wC,wD,wE,wF,wG,wH,wA,wSIZE,AC16);


ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww16,AC17);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww0,AC18);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww1,AC19);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww2,AC20);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww3,AC21);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww4,AC22);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww5,AC23);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww6,AC24);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww7,AC25);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww8,AC26);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww9,AC27);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww10,AC28);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww11,AC29);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww12,AC30);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww13,AC31);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww14,AC32);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,wSIZE,AC33);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww16,AC34);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww0,AC35);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww1,AC36);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww2,AC37);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww3,AC38);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww4,AC39);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww5,AC40);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww6,AC41);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww7,AC42);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww8,AC43);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww9,AC44);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww10,AC45);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww11,AC46);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww12,AC47);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww13,AC48);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww14,AC49);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,wSIZE,AC50);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww16,AC51);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww0,AC52);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww1,AC53);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww2,AC54);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww3,AC55);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww4,AC56);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww5,AC57);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww6,AC58);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww7,AC59);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww8,AC60);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww9,AC61);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww10,AC62);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww11,AC63);
ww12 = sigma1_512(ww10)+ww5+sigma0_512(ww14)+ww13; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww12,AC64);
ww13 = sigma1_512(ww11)+ww6+sigma0_512(wSIZE)+ww14; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww13,AC65);
ww14 = sigma1_512(ww12)+ww7+sigma0_512(ww16)+wSIZE; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww14,AC66);
wSIZE = sigma1_512(ww13)+ww8+sigma0_512(ww0)+ww16; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,wSIZE,AC67);
ww16 = sigma1_512(ww14)+ww9+sigma0_512(ww1)+ww0; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww16,AC68);
ww0 = sigma1_512(wSIZE)+ww10+sigma0_512(ww2)+ww1; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww0,AC69);
ww1 = sigma1_512(ww16)+ww11+sigma0_512(ww3)+ww2; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww1,AC70);
ww2 = sigma1_512(ww0)+ww12+sigma0_512(ww4)+ww3; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww2,AC71);
ww3 = sigma1_512(ww1)+ww13+sigma0_512(ww5)+ww4; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww3,AC72);
ww4 = sigma1_512(ww2)+ww14+sigma0_512(ww6)+ww5; ROUND512(wA,wB,wC,wD,wE,wF,wG,wH,ww4,AC73);
ww5 = sigma1_512(ww3)+wSIZE+sigma0_512(ww7)+ww6; ROUND512(wH,wA,wB,wC,wD,wE,wF,wG,ww5,AC74);
ww6 = sigma1_512(ww4)+ww16+sigma0_512(ww8)+ww7; ROUND512(wG,wH,wA,wB,wC,wD,wE,wF,ww6,AC75);
ww7 = sigma1_512(ww5)+ww0+sigma0_512(ww9)+ww8; ROUND512(wF,wG,wH,wA,wB,wC,wD,wE,ww7,AC76);
ww8 = sigma1_512(ww6)+ww1+sigma0_512(ww10)+ww9; ROUND512(wE,wF,wG,wH,wA,wB,wC,wD,ww8,AC77);
ww9 = sigma1_512(ww7)+ww2+sigma0_512(ww11)+ww10; ROUND512(wD,wE,wF,wG,wH,wA,wB,wC,ww9,AC78);
ww10 = sigma1_512(ww8)+ww3+sigma0_512(ww12)+ww11; ROUND512(wC,wD,wE,wF,wG,wH,wA,wB,ww10,AC79);
ww11 = sigma1_512(ww9)+ww4+sigma0_512(ww13)+ww12; ROUND512(wB,wC,wD,wE,wF,wG,wH,wA,ww11,AC80);

wA+=(ulong)wwA;
wB+=(ulong)wwB;
wC+=(ulong)wwC;
wD+=(ulong)wwD;
wE+=(ulong)wwE;
wF+=(ulong)wwF;
wG+=(ulong)wwG;
wH+=(ulong)wwH;

// We need just 32 bytes of the output
Endian_Reverse64(wA);
Endian_Reverse64(wB);
Endian_Reverse64(wC);
Endian_Reverse64(wD);
Endian_Reverse64(wE);
Endian_Reverse64(wF);
A1 = (uint)(wA&0xFFFFFFFF);
wA = wA>>32;
A2 = (uint)(wA&0xFFFFFFFF);
A3 = (uint)(wB&0xFFFFFFFF);
wB = wB>>32;
A4 = (uint)(wB&0xFFFFFFFF);
A5 = (uint)(wC&0xFFFFFFFF);
wC = wC>>32;
A6 = (uint)(wC&0xFFFFFFFF);
A7 = (uint)(wD&0xFFFFFFFF);
wD = wD>>32;
A8 = (uint)(wD&0xFFFFFFFF);
A9 = (uint)(wE&0xFFFFFFFF);
wE = wE>>32;
A10 = (uint)(wE&0xFFFFFFFF);
A11 = (uint)(wF&0xFFFFFFFF);
wF = wF>>32;
A12 = (uint)(wF&0xFFFFFFFF);
A13=A14=A15=A16=0;
bs=48;
}




else if (ic==32)
{
ib = 0;
// I1..I4 now holds the CBC IV
I1=A5;I2=A6;I3=A7;I4=A8;
block[GLI][0]=block[GLI][1]=block[GLI][2]=block[GLI][3]=0;
block[GLI][4]=block[GLI][5]=block[GLI][6]=block[GLI][7]=0;
block[GLI][8]=block[GLI][9]=block[GLI][10]=block[GLI][11]=0;
block[GLI][12]=block[GLI][13]=block[GLI][14]=block[GLI][15]=0;
block[GLI][16]=block[GLI][17]=block[GLI][18]=block[GLI][19]=0;
block[GLI][20]=block[GLI][21]=block[GLI][22]=block[GLI][23]=0;
block[GLI][24]=block[GLI][25]=block[GLI][26]=block[GLI][27]=0;
block[GLI][28]=block[GLI][29]=block[GLI][30]=block[GLI][31]=0;
block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;
block[GLI][48]=block[GLI][49]=block[GLI][50]=block[GLI][51]=0;
block[GLI][52]=block[GLI][53]=block[GLI][54]=block[GLI][55]=0;
block[GLI][56]=block[GLI][57]=block[GLI][58]=block[GLI][59]=0;
block[GLI][60]=block[GLI][61]=block[GLI][62]=block[GLI][63]=0;

sA=A=S1H0;
sB=B=S1H1;
sC=C=S1H2;
sD=D=S1H3;
sE=E=S1H4;
sF=F=S1H5;
sG=G=S1H6;
sH=H=S1H7;

// Concatenate password+block 64 times
for (id=0;id<64;id++)
{
SET_AB(block[GLI],B1,ib,0);
SET_AB(block[GLI],B2,ib+4,0);
SET_AB(block[GLI],B3,ib+8,0);
SET_AB(block[GLI],B4,ib+12,0);
SET_AB(block[GLI],B5,ib+16,0);
SET_AB(block[GLI],B6,ib+20,0);
SET_AB(block[GLI],B7,ib+24,0);
SET_AB(block[GLI],B8,ib+28,0);
SET_AB(block[GLI],A1,ib+bsz,0);
SET_AB(block[GLI],A2,ib+bsz+4,0);
SET_AB(block[GLI],A3,ib+bsz+8,0);
SET_AB(block[GLI],A4,ib+bsz+12,0);
SET_AB(block[GLI],A5,ib+bsz+16,0);
SET_AB(block[GLI],A6,ib+bsz+20,0);
SET_AB(block[GLI],A7,ib+bsz+24,0);
SET_AB(block[GLI],A8,ib+bsz+28,0);
SET_AB(block[GLI],A9,ib+bsz+32,0);
SET_AB(block[GLI],A10,ib+bsz+36,0);
SET_AB(block[GLI],A11,ib+bsz+40,0);
SET_AB(block[GLI],A12,ib+bsz+44,0);
SET_AB(block[GLI],A13,ib+bsz+48,0);
SET_AB(block[GLI],A14,ib+bsz+52,0);
SET_AB(block[GLI],A15,ib+bsz+56,0);
SET_AB(block[GLI],A16,ib+bsz+60,0);
ib+=(bsz+bs);

// Full block?
if (ib>=64)
{
for (ie=0;ie<4;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}
ib -= 64;


// Do the SHA operation

w0 = block[GLI][0];
w1 = block[GLI][1];
w2 = block[GLI][2];
w3 = block[GLI][3];
w4 = block[GLI][4];
w5 = block[GLI][5];
w6 = block[GLI][6];
w7 = block[GLI][7];
w8 = block[GLI][8];
w9 = block[GLI][9];
w10 = block[GLI][10];
w11 = block[GLI][11];
w12 = block[GLI][12];
w13 = block[GLI][13];
w14 = block[GLI][14];
SIZE = block[GLI][15];

Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
Endian_Reverse32(w8);
Endian_Reverse32(w9);
Endian_Reverse32(w10);
Endian_Reverse32(w11);
Endian_Reverse32(w12);
Endian_Reverse32(w13);
Endian_Reverse32(w14);
Endian_Reverse32(SIZE);


block[GLI][0]=block[GLI][16];
block[GLI][1]=block[GLI][17];
block[GLI][2]=block[GLI][18];
block[GLI][3]=block[GLI][19];
block[GLI][4]=block[GLI][20];
block[GLI][5]=block[GLI][21];
block[GLI][6]=block[GLI][22];
block[GLI][7]=block[GLI][23];
block[GLI][8]=block[GLI][24];
block[GLI][9]=block[GLI][25];
block[GLI][10]=block[GLI][26];
block[GLI][11]=block[GLI][27];
block[GLI][12]=block[GLI][28];
block[GLI][13]=block[GLI][29];
block[GLI][14]=block[GLI][30];
block[GLI][15]=block[GLI][31];
block[GLI][16]=block[GLI][17]=block[GLI][18]=block[GLI][19]=0;
block[GLI][20]=block[GLI][21]=block[GLI][22]=block[GLI][23]=0;
block[GLI][24]=block[GLI][25]=block[GLI][26]=block[GLI][27]=0;
block[GLI][28]=block[GLI][29]=block[GLI][30]=block[GLI][31]=0;


A=(uint)sA;
B=(uint)sB;
C=(uint)sC;
D=(uint)sD;
E=(uint)sE;
F=(uint)sF;
G=(uint)sG;
H=(uint)sH;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25BU);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1U);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4U);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5U);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98U);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01U);
P(G, H, A, B, C, D, E, F, w10, 0x243185BEU);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3U);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74U);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FEU);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
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


sA=A+(uint)sA;
sB=B+(uint)sB;
sC=C+(uint)sC;
sD=D+(uint)sD;
sE=E+(uint)sE;
sF=F+(uint)sF;
sG=G+(uint)sG;
sH=H+(uint)sH;

}

// Again full block?
if (ib>=64)
{
for (ie=0;ie<4;ie++)
{
AES128_GET_KEYS1;
ir0=block[GLI][4*ie+0]^I1;
ir1=block[GLI][4*ie+1]^I2;
ir2=block[GLI][4*ie+2]^I3;
ir3=block[GLI][4*ie+3]^I4;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ rk0;
s1 = ir1 ^ rk1;
s2 = ir2 ^ rk2;
s3 = ir3 ^ rk3;
AES128_EVEN_ROUND;
AES128_GET_KEYS2;
AES128_ODD_ROUND;
AES128_GET_KEYS3;
AES128_EVEN_ROUND;
AES128_GET_KEYS4;
AES128_ODD_ROUND;
AES128_GET_KEYS5;
AES128_EVEN_ROUND;
AES128_GET_KEYS6;
AES128_ODD_ROUND;
AES128_GET_KEYS7;
AES128_EVEN_ROUND;
AES128_GET_KEYS8;
AES128_ODD_ROUND;
AES128_GET_KEYS9;
AES128_EVEN_ROUND;
AES128_GET_KEYS10;
AES128_FINAL;
Endian_Reverse32(s0);
Endian_Reverse32(s1);
Endian_Reverse32(s2);
Endian_Reverse32(s3);
I1=s0;
I2=s1;
I3=s2;
I4=s3;
block[GLI][4*ie+0]=I1;block[GLI][4*ie+1]=I2;block[GLI][4*ie+2]=I3;block[GLI][4*ie+3]=I4;
lc=(I4>>24);
}
ib -= 64;


// Do the SHA operation

w0 = block[GLI][0];
w1 = block[GLI][1];
w2 = block[GLI][2];
w3 = block[GLI][3];
w4 = block[GLI][4];
w5 = block[GLI][5];
w6 = block[GLI][6];
w7 = block[GLI][7];
w8 = block[GLI][8];
w9 = block[GLI][9];
w10 = block[GLI][10];
w11 = block[GLI][11];
w12 = block[GLI][12];
w13 = block[GLI][13];
w14 = block[GLI][14];
SIZE = block[GLI][15];

Endian_Reverse32(w0);
Endian_Reverse32(w1);
Endian_Reverse32(w2);
Endian_Reverse32(w3);
Endian_Reverse32(w4);
Endian_Reverse32(w5);
Endian_Reverse32(w6);
Endian_Reverse32(w7);
Endian_Reverse32(w8);
Endian_Reverse32(w9);
Endian_Reverse32(w10);
Endian_Reverse32(w11);
Endian_Reverse32(w12);
Endian_Reverse32(w13);
Endian_Reverse32(w14);
Endian_Reverse32(SIZE);


block[GLI][0]=block[GLI][32];
block[GLI][1]=block[GLI][33];
block[GLI][2]=block[GLI][34];
block[GLI][3]=block[GLI][35];
block[GLI][4]=block[GLI][36];
block[GLI][5]=block[GLI][37];
block[GLI][6]=block[GLI][38];
block[GLI][7]=block[GLI][39];
block[GLI][32]=block[GLI][33]=block[GLI][34]=block[GLI][35]=0;
block[GLI][36]=block[GLI][37]=block[GLI][38]=block[GLI][39]=0;
block[GLI][40]=block[GLI][41]=block[GLI][42]=block[GLI][43]=0;
block[GLI][44]=block[GLI][45]=block[GLI][46]=block[GLI][47]=0;


A=(uint)sA;
B=(uint)sB;
C=(uint)sC;
D=(uint)sD;
E=(uint)sE;
F=(uint)sF;
G=(uint)sG;
H=(uint)sH;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25BU);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1U);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4U);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5U);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98U);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01U);
P(G, H, A, B, C, D, E, F, w10, 0x243185BEU);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3U);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74U);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FEU);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
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


sA=A+(uint)sA;
sB=B+(uint)sB;
sC=C+(uint)sC;
sD=D+(uint)sD;
sE=E+(uint)sE;
sF=F+(uint)sF;
sG=G+(uint)sG;
sH=H+(uint)sH;

}

}


// Put the 0x80 end marker, do the final SHA calculation
w0=0x80000000U;
w1 = 0;
w2 = 0;
w3 = 0;
w4 = 0;
w5 = 0;
w6 = 0;
w7 = 0;
w8 = 0;
w9 = 0;
w10 = 0;
w11 = 0;
w12 = 0;
w13 = 0;
w14 = 0;
SIZE = (64*(bsz+bs))<<3;


A=(uint)sA;
B=(uint)sB;
C=(uint)sC;
D=(uint)sD;
E=(uint)sE;
F=(uint)sF;
G=(uint)sG;
H=(uint)sH;


P(A, B, C, D, E, F, G, H, w0, 0x428A2F98U);
P(H, A, B, C, D, E, F, G, w1, 0x71374491U);
P(G, H, A, B, C, D, E, F, w2, 0xB5C0FBCFU);
P(F, G, H, A, B, C, D, E, w3, 0xE9B5DBA5U);
P(E, F, G, H, A, B, C, D, w4, 0x3956C25BU);
P(D, E, F, G, H, A, B, C, w5, 0x59F111F1U);
P(C, D, E, F, G, H, A, B, w6, 0x923F82A4U);
P(B, C, D, E, F, G, H, A, w7, 0xAB1C5ED5U);
P(A, B, C, D, E, F, G, H, w8, 0xD807AA98U);
P(H, A, B, C, D, E, F, G, w9, 0x12835B01U);
P(G, H, A, B, C, D, E, F, w10, 0x243185BEU);
P(F, G, H, A, B, C, D, E, w11, 0x550C7DC3U);
P(E, F, G, H, A, B, C, D, w12, 0x72BE5D74U);
P(D, E, F, G, H, A, B, C, w13, 0x80DEB1FEU);
P(C, D, E, F, G, H, A, B, w14, 0x9BDC06A7U);
P(B, C, D, E, F, G, H, A, SIZE, 0xC19BF174U);
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


sA=A+(uint)sA;
sB=B+(uint)sB;
sC=C+(uint)sC;
sD=D+(uint)sD;
sE=E+(uint)sE;
sF=F+(uint)sF;
sG=G+(uint)sG;
sH=H+(uint)sH;


// We need the hash output (32 bytes)
Endian_Reverse32(sA);
Endian_Reverse32(sB);
Endian_Reverse32(sC);
Endian_Reverse32(sD);
Endian_Reverse32(sE);
Endian_Reverse32(sF);
Endian_Reverse32(sG);
Endian_Reverse32(sH);
A1=sA;
A2=sB;
A3=sC;
A4=sD;
A5=sE;
A6=sF;
A7=sG;
A8=sH;
A9=A10=A11=A12=A13=A14=A15=A16=0;
bs=32;
}


input[(get_global_id(0)*18)+0]=A1;
input[(get_global_id(0)*18)+1]=A2;
input[(get_global_id(0)*18)+2]=A3;
input[(get_global_id(0)*18)+3]=A4;
input[(get_global_id(0)*18)+4]=A5;
input[(get_global_id(0)*18)+5]=A6;
input[(get_global_id(0)*18)+6]=A7;
input[(get_global_id(0)*18)+7]=A8;
input[(get_global_id(0)*18)+8]=A9;
input[(get_global_id(0)*18)+9]=A10;
input[(get_global_id(0)*18)+10]=A11;
input[(get_global_id(0)*18)+11]=A12;
input[(get_global_id(0)*18)+12]=A13;
input[(get_global_id(0)*18)+13]=A14;
input[(get_global_id(0)*18)+14]=A15;
input[(get_global_id(0)*18)+15]=A16;
input[(get_global_id(0)*18)+16]=lc;
input[(get_global_id(0)*18)+17]=bs;

}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final( __global uint8 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 singlehash,uint16 salt)
{
uint d1,d2,d3,d4,d5,d6,d7,d8;

d1=input[(get_global_id(0)*18)+0];
d2=input[(get_global_id(0)*18)+1];
d3=input[(get_global_id(0)*18)+2];
d4=input[(get_global_id(0)*18)+3];


if ((d1!=singlehash.s0)) return;
if ((d2!=singlehash.s1)) return;
if ((d3!=singlehash.s2)) return;
if ((d4!=singlehash.s3)) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint8)(d1,d2,d3,d4,d5,d6,d7,d8);

}



