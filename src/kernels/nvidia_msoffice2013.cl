
/* Not supported on 4xxx */
#ifndef OLD_ATI

#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1) { \
    elem=ii1>>2; \
    tt1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tt1)); \
    ai1[elem+1] = (tt1==0) ? 0 : ai2>>(32-tt1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *size, __global uint *sizein, uint16 str, uint16 salt)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tt1;

inpc[GLI][0] = inp[GGI*(8)+0];
inpc[GLI][1] = inp[GGI*(8)+1];
inpc[GLI][2] = inp[GGI*(8)+2];
inpc[GLI][3] = inp[GGI*(8)+3];
inpc[GLI][4] = inp[GGI*(8)+4];
inpc[GLI][5] = inp[GGI*(8)+5];
inpc[GLI][6] = inp[GGI*(8)+6];
inpc[GLI][7] = inp[GGI*(8)+7];

SIZE=sizein[GGI];
size[GGI] = (SIZE+str.sF);

SET_AB(inpc[GLI],str.s0,SIZE);
SET_AB(inpc[GLI],str.s1,SIZE+4);
SET_AB(inpc[GLI],str.s2,SIZE+8);
SET_AB(inpc[GLI],str.s3,SIZE+12);


dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
}



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


#define Sl (uint)8
#define Sr (uint)24
#define Endian_Reverse32(aa) { tl=(aa);ttmp1=rotate(tl,Sl);ttmp2=rotate(tl,Sr); (aa)=bitselect(ttmp2,ttmp1,m); }
#define ROTR(x,n) (rotate(x,(32-n)))

#define lTe1(x) (ROTR(lTe[((x))],8U))
#define lTe2(x) (ROTR(lTe[((x))],16U))
#define lTe3(x) (ROTR(lTe[((x))],24U))
#define lTd1(x) (ROTR(lTd[((x))],8U))
#define lTd2(x) (ROTR(lTd[((x))],16U))
#define lTd3(x) (ROTR(lTd[((x))],24U))

#define AES256_INV_MIX { \
k0 = lTd[lTe1((k0 >> 24)) & 0xff] ^ lTd1(lTe1((k0 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k0 >> 8) & 0xff) & 0xff) ^ lTd3(lTe1((k0) & 0xff) & 0xff); \
k1 = lTd[lTe1((k1 >> 24)) & 0xff] ^ lTd1(lTe1((k1 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k1 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k1) & 0xff) & 0xff); \
k2 = lTd[lTe1((k2 >> 24)) & 0xff] ^ lTd1(lTe1((k2 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k2 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k2) & 0xff) & 0xff); \
k3 = lTd[lTe1((k3 >> 24)) & 0xff] ^ lTd1(lTe1((k3 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k3 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k3) & 0xff) & 0xff); \
}


#define AES256_EVEN_ROUND { \
t0 = lTd[s0 >> 24] ^ lTd1((s3 >> 16) & 0xff) ^ lTd2((s2 >>  8) & 0xff) ^ lTd3(s1 & 0xff) ^ k0; \
t1 = lTd[s1 >> 24] ^ lTd1((s0 >> 16) & 0xff) ^ lTd2((s3 >>  8) & 0xff) ^ lTd3(s2 & 0xff) ^ k1; \
t2 = lTd[s2 >> 24] ^ lTd1((s1 >> 16) & 0xff) ^ lTd2((s0 >>  8) & 0xff) ^ lTd3(s3 & 0xff) ^ k2; \
t3 = lTd[s3 >> 24] ^ lTd1((s2 >> 16) & 0xff) ^ lTd2((s1 >>  8) & 0xff) ^ lTd3(s0 & 0xff) ^ k3; \
}

#define AES256_ODD_ROUND { \
s0 = lTd[t0 >> 24] ^ lTd1((t3 >> 16) & 0xff) ^ lTd2((t2 >>  8) & 0xff) ^ lTd3(t1 & 0xff) ^ k0; \
s1 = lTd[t1 >> 24] ^ lTd1((t0 >> 16) & 0xff) ^ lTd2((t3 >>  8) & 0xff) ^ lTd3(t2 & 0xff) ^ k1; \
s2 = lTd[t2 >> 24] ^ lTd1((t1 >> 16) & 0xff) ^ lTd2((t0 >>  8) & 0xff) ^ lTd3(t3 & 0xff) ^ k2; \
s3 = lTd[t3 >> 24] ^ lTd1((t2 >> 16) & 0xff) ^ lTd2((t1 >>  8) & 0xff) ^ lTd3(t0 & 0xff) ^ k3; \
}

#define AES256_GET_KEYS0 { \
temp = rk7; \
r8 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r9= rk1 ^ r8; \
r10= rk2 ^ r9; \
r11= rk3 ^ r10; \
temp = r11; \
r12 = rk4 ^ (lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = rk5 ^ r12; \
r14 = rk6 ^ r13; \
r15 = rk7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3;kcache4=r4;kcache5=r5;kcache6=r6;kcache7=r7; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS1 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}


#define AES256_GET_KEYS2 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS3 { \
temp = rk7; \
r8 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r9= rk1 ^ r8; \
r10= rk2 ^ r9; \
r11= rk3 ^ r10; \
temp = r11; \
r12 = rk4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = rk5 ^ r12; \
r14 = rk6 ^ r13; \
r15 = rk7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3;kcache4=r4;kcache5=r5;kcache6=r6;kcache7=r7; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}


#define AES256_GET_KEYS4 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES256_GET_KEYS5 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}

#define AES256_GET_KEYS6 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS7 { \
temp = rk7; \
r8 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r9= rk1 ^ r8; \
r10= rk2 ^ r9; \
r11= rk3 ^ r10; \
temp = r11; \
r12 = rk4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = rk5 ^ r12; \
r14 = rk6 ^ r13; \
r15 = rk7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3;kcache4=r4;kcache5=r5;kcache6=r6;kcache7=r7; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}

#define AES256_GET_KEYS8 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
temp = r7; \
r8 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r9= r1 ^ r8; \
r10= r2 ^ r9; \
r11= r3 ^ r10; \
temp = r11; \
r12 = r4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = r5 ^ r12; \
r14 = r6 ^ r13; \
r15 = r7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS9 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}

#define AES256_GET_KEYS10 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5;r6=kcache6;r7=kcache7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS11 { \
temp = rk7; \
r8 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r9= rk1 ^ r8; \
r10= rk2 ^ r9; \
r11= rk3 ^ r10; \
temp = r11; \
r12 = rk4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = rk5 ^ r12; \
r14 = rk6 ^ r13; \
r15 = rk7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r4;k1=r5;k2=r6;k3=r7; \
}


#define AES256_GET_KEYS12 { \
temp = rk7; \
r8 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r9= rk1 ^ r8; \
r10= rk2 ^ r9; \
r11= rk3 ^ r10; \
temp = r11; \
r12 = rk4 ^(lTe2((temp >> 24) & 0xff) & 0xff000000) ^ (lTe3((temp >> 16) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp>>8) & 0xff] & 0x0000ff00) ^ (lTe1((temp & 0xff)) & 0x000000ff); \
r13 = rk5 ^ r12; \
r14 = rk6 ^ r13; \
r15 = rk7 ^ r14; \
r0=r8;r1=r9;r2=r10;r3=r11;r4=r12;r5=r13;r6=r14;r7=r15; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES256_GET_KEYS13 { \
k0=rk4;k1=rk5;k2=rk6;k3=rk7; \
}

#define AES256_GET_KEYS14 { \
k0=rk0;k1=rk1;k2=rk2;k3=rk3; \
}

#define AES256_FINAL { \
s0 = \
    (lTdK[(t0 >> 24)] << 24) ^ \
    (lTdK[(t3 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t2 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t1) & 0xff] ) ^ rk0; \
Endian_Reverse32(s0); \
s1 = \
    (lTdK[(t1 >> 24)] << 24) ^ \
    (lTdK[(t0 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t3 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t2) & 0xff] ) ^ rk1; \
Endian_Reverse32(s1); \
s2 = \
    (lTdK[(t2 >> 24)] << 24) ^ \
    (lTdK[(t1 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t0 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t3) & 0xff] ) ^ rk2; \
Endian_Reverse32(s2); \
s3 = \
    (lTdK[(t3 >> 24)] << 24) ^ \
    (lTdK[(t2 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t1 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t0) & 0xff] ) ^ rk3; \
Endian_Reverse32(s3); \
}


#define AES128_INV_MIX { \
k0 = lTd[lTe1((k0 >> 24)) & 0xff] ^ lTd1(lTe1((k0 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k0 >> 8) & 0xff) & 0xff) ^ lTd3(lTe1((k0) & 0xff) & 0xff); \
k1 = lTd[lTe1((k1 >> 24)) & 0xff] ^ lTd1(lTe1((k1 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k1 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k1) & 0xff) & 0xff); \
k2 = lTd[lTe1((k2 >> 24)) & 0xff] ^ lTd1(lTe1((k2 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k2 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k2) & 0xff) & 0xff); \
k3 = lTd[lTe1((k3 >> 24)) & 0xff] ^ lTd1(lTe1((k3 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k3 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k3) & 0xff) & 0xff); \
}


#define AES128_EVEN_ROUND { \
t0 = lTd[s0 >> 24] ^ lTd1((s3 >> 16) & 0xff) ^ lTd2((s2 >>  8) & 0xff) ^ lTd3(s1 & 0xff) ^ k0; \
t1 = lTd[s1 >> 24] ^ lTd1((s0 >> 16) & 0xff) ^ lTd2((s3 >>  8) & 0xff) ^ lTd3(s2 & 0xff) ^ k1; \
t2 = lTd[s2 >> 24] ^ lTd1((s1 >> 16) & 0xff) ^ lTd2((s0 >>  8) & 0xff) ^ lTd3(s3 & 0xff) ^ k2; \
t3 = lTd[s3 >> 24] ^ lTd1((s2 >> 16) & 0xff) ^ lTd2((s1 >>  8) & 0xff) ^ lTd3(s0 & 0xff) ^ k3; \
}

#define AES128_ODD_ROUND { \
s0 = lTd[t0 >> 24] ^ lTd1((t3 >> 16) & 0xff) ^ lTd2((t2 >>  8) & 0xff) ^ lTd3(t1 & 0xff) ^ k0; \
s1 = lTd[t1 >> 24] ^ lTd1((t0 >> 16) & 0xff) ^ lTd2((t3 >>  8) & 0xff) ^ lTd3(t2 & 0xff) ^ k1; \
s2 = lTd[t2 >> 24] ^ lTd1((t1 >> 16) & 0xff) ^ lTd2((t0 >>  8) & 0xff) ^ lTd3(t3 & 0xff) ^ k2; \
s3 = lTd[t3 >> 24] ^ lTd1((t2 >> 16) & 0xff) ^ lTd2((t1 >>  8) & 0xff) ^ lTd3(t0 & 0xff) ^ k3; \
}

#define AES128_GET_KEYS0 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[7]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[8]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[9]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES128_GET_KEYS1 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS2 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[7]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS3 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS4 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS5 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS6 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS7 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS8 { \
temp = rk3; \
r4 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r5= rk1 ^ r4; \
r6= rk2 ^ r5; \
r7= rk3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3; \
temp = r3; \
r4 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r5= r1 ^ r4; \
r6= r2 ^ r5; \
r7= r3 ^ r6; \
r0=r4;r1=r5;r2=r6;r3=r7; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS9 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES128_GET_KEYS10 { \
k0=rk0;k1=rk1;k2=rk2;k3=rk3; \
}


#define AES128_FINAL { \
s0 = \
    (lTdK[(t0 >> 24)] << 24) ^ \
    (lTdK[(t3 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t2 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t1) & 0xff] ) ^ rk0; \
Endian_Reverse32(s0); \
s1 = \
    (lTdK[(t1 >> 24)] << 24) ^ \
    (lTdK[(t0 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t3 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t2) & 0xff] ) ^ rk1; \
Endian_Reverse32(s1); \
s2 = \
    (lTdK[(t2 >> 24)] << 24) ^ \
    (lTdK[(t1 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t0 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t3) & 0xff] ) ^ rk2; \
Endian_Reverse32(s2); \
s3 = \
    (lTdK[(t3 >> 24)] << 24) ^ \
    (lTdK[(t2 >> 16) & 0xff] << 16) ^ \
    (lTdK[(t1 >>  8) & 0xff] << 8) ^ \
    (lTdK[(t0) & 0xff] ) ^ rk3; \
Endian_Reverse32(s3); \
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officeprep( __global ulong *dst,  __global uint *inp, __global uint *size, uint16 salt)
{
uint TSIZE,SIZE;  
uint ib,ic,id;  
uint tt1,elem; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w15,w16;
uint t1,t2,t3;
__local uint inpc[64][25];
uint y0,y1,y2,y3,y4,y5,y6,y7;
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SSIZE;


id=get_global_id(0);

SIZE=(uint)size[GGI];
y0 = inp[GGI*8+0];
y1 = inp[GGI*8+1];
y2 = inp[GGI*8+2];
y3 = inp[GGI*8+3];
y4 = inp[GGI*8+4];
y5 = inp[GGI*8+5];
y6 = inp[GGI*8+6];
y7 = inp[GGI*8+7];

inpc[GLI][0]=salt.s0;
inpc[GLI][1]=salt.s1;
inpc[GLI][2]=salt.s2;
inpc[GLI][3]=salt.s3;
inpc[GLI][4]=salt.s4;
inpc[GLI][5]=salt.s5;
inpc[GLI][6]=salt.s6;
inpc[GLI][7]=salt.s7;

inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=inpc[GLI][14]=(uint)0;
inpc[GLI][15]=inpc[GLI][16]=inpc[GLI][17]=inpc[GLI][18]=inpc[GLI][19]=inpc[GLI][20]=inpc[GLI][21]=(uint)0;
inpc[GLI][22]=inpc[GLI][23]=inpc[GLI][24]=(uint)0;


t1=y0;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF);
SET_AB(inpc[GLI],t3,salt.sF+4);
t1=y1;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+8);
SET_AB(inpc[GLI],t3,salt.sF+12);
t1=y2;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+16);
SET_AB(inpc[GLI],t3,salt.sF+20);
t1=y3;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+24);
SET_AB(inpc[GLI],t3,salt.sF+28);
t1=y4;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+32);
SET_AB(inpc[GLI],t3,salt.sF+36);
t1=y5;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+40);
SET_AB(inpc[GLI],t3,salt.sF+44);
t1=y6;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+48);
SET_AB(inpc[GLI],t3,salt.sF+52);
t1=y7;
t2=(((t1)&255))|(((t1>>8)&255)<<16);
t3=(((t1>>16)&255))|(((t1>>24)&255)<<16);
SET_AB(inpc[GLI],t2,salt.sF+56);
SET_AB(inpc[GLI],t3,salt.sF+60);
TSIZE=(SIZE)*2+salt.sF;

SET_AB(inpc[GLI],0x80,TSIZE);


x0=(ulong)inpc[GLI][1];
x0=(x0<<32)|(ulong)inpc[GLI][0];
x1=(ulong)inpc[GLI][3];
x1=(x1<<32)|(ulong)inpc[GLI][2];
x2=(ulong)inpc[GLI][5];
x2=(x2<<32)|(ulong)inpc[GLI][4];
x3=(ulong)inpc[GLI][7];
x3=(x3<<32)|(ulong)inpc[GLI][6];
x4=(ulong)inpc[GLI][9];
x4=(x4<<32)|(ulong)inpc[GLI][8];
x5=(ulong)inpc[GLI][11];
x5=(x5<<32)|(ulong)inpc[GLI][10];
x6=(ulong)inpc[GLI][13];
x6=(x6<<32)|(ulong)inpc[GLI][12];
x7=(ulong)inpc[GLI][15];
x7=(x7<<32)|(ulong)inpc[GLI][14];
x8=(ulong)inpc[GLI][17];
x8=(x8<<32)|(ulong)inpc[GLI][16];
x9=(ulong)inpc[GLI][19];
x9=(x9<<32)|(ulong)inpc[GLI][18];
x10=(ulong)inpc[GLI][21];
x10=(x10<<32)|(ulong)inpc[GLI][20];
x11=(ulong)inpc[GLI][23];
x11=(x11<<32)|(ulong)inpc[GLI][22];
x12=(ulong)inpc[GLI][24];


x13=x14=x15=x16=(ulong)0;
SSIZE=TSIZE<<3;


A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
Endian_Reverse64(x0);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
Endian_Reverse64(x1);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
Endian_Reverse64(x2);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
Endian_Reverse64(x3);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
Endian_Reverse64(x4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
Endian_Reverse64(x5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
Endian_Reverse64(x6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
Endian_Reverse64(x7);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
Endian_Reverse64(x8);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
Endian_Reverse64(x9);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
Endian_Reverse64(x10);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC11,x10);
Endian_Reverse64(x11);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC12,x11);
Endian_Reverse64(x12);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC13,x12);
Endian_Reverse64(x13);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC14,x13);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SSIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SSIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SSIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SSIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SSIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SSIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SSIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SSIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SSIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A+=(ulong)H0;
B+=(ulong)H1;
C+=(ulong)H2;
D+=(ulong)H3;
E+=(ulong)H4;
F+=(ulong)H5;
G+=(ulong)H6;
H+=(ulong)H7;

dst[get_global_id(0)*8]=(ulong)A;
dst[get_global_id(0)*8+1]=(ulong)B;
dst[get_global_id(0)*8+2]=(ulong)C;
dst[get_global_id(0)*8+3]=(ulong)D;
dst[get_global_id(0)*8+4]=(ulong)E;
dst[get_global_id(0)*8+5]=(ulong)F;
dst[get_global_id(0)*8+6]=(ulong)G;
dst[get_global_id(0)*8+7]=(ulong)H;


}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officeiter( __global ulong *dst,  __global ulong *inp, uint16 salt)
{
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,temp,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SIZE;
uint i;


A=inp[(GGI*8)];
B=inp[(GGI*8)+1];
C=inp[(GGI*8)+2];
D=inp[(GGI*8)+3];
E=inp[(GGI*8)+4];
F=inp[(GGI*8)+5];
G=inp[(GGI*8)+6];
H=inp[(GGI*8)+7];


for (i=salt.s8;i<salt.s8+1000;i++)
{
x0=(ulong)i;
Endian_Reverse64(x0);
x0=x0|(A>>32);
x1=(A<<32)|(B>>32);
x2=(B<<32)|(C>>32);
x3=(C<<32)|(D>>32);
x4=(D<<32)|(E>>32);
x5=(E<<32)|(F>>32);
x6=(F<<32)|(G>>32);
x7=(G<<32)|(H>>32);
x8=(H<<32)|0x80000000;

SIZE=(ulong)68<<3;
x9=x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = /*sigma1_512(x14)+x9+*/sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+/*x10+*/sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+/*x11+*/sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+/*x12+*/sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+/*x13+*/sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+/*x14+*/sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+/*sigma0_512(x9)+*/x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1/*+sigma0_512(x10)+x9*/; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2/*+sigma0_512(x11)+x10*/; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3/*+sigma0_512(x12)+x11*/; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4/*+sigma0_512(x13)+x12*/; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5/*+sigma0_512(x14)+x13*/; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)/*+x14*/; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);
A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

}

dst[GGI*8]=(ulong)A;
dst[GGI*8+1]=(ulong)B;
dst[GGI*8+2]=(ulong)C;
dst[GGI*8+3]=(ulong)D;
dst[GGI*8+4]=(ulong)E;
dst[GGI*8+5]=(ulong)F;
dst[GGI*8+6]=(ulong)G;
dst[GGI*8+7]=(ulong)H;
}



__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officefinal256( __global uint4 *dst,  __global ulong *inp, uint16 salt,uint16 salt2,__global uint *found_ind, __global uint *found)
{
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong SSA,SSB,SSC,SSD,SSE,SSF,SSG,SSH;
ulong SSSA,SSSB,SSSC,SSSD,SSSE,SSSF,SSSG,SSSH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SIZE;
uint i;
uint m = 0x00FF00FFU;
uint m2 = 0xFF00FF00U;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
__local uint lTe[256];
__local uint lTd[256];
__local uint lTdK[256];
uint rk0,rk1,rk2,rk3,rk4,rk5,rk6,rk7,temp;
uint r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15;
uint k0,k1,k2,k3,k4,k5,k6,k7;
uint s0, s1, s2, s3, t0, t1, t2, t3;
uint kcache0,kcache1,kcache2,kcache3,kcache4,kcache5,kcache6,kcache7;
uint ir0,ir1,ir2,ir3;
uint ttmp1,ttmp2,tl;
uint a,b,c,d;

// Setup tables
lTe[GLI]=Te[GLI];
lTe[64+GLI]=Te[64+GLI];
lTe[128+GLI]=Te[128+GLI];
lTe[192+GLI]=Te[192+GLI];
lTd[GLI]=Td[GLI];
lTd[64+GLI]=Td[64+GLI];
lTd[128+GLI]=Td[128+GLI];
lTd[192+GLI]=Td[192+GLI];
lTdK[GLI]=TdK[GLI];
lTdK[64+GLI]=TdK[64+GLI];
lTdK[128+GLI]=TdK[128+GLI];
lTdK[192+GLI]=TdK[192+GLI];
barrier(CLK_LOCAL_MEM_FENCE);


SA=inp[(GGI*8)];
SB=inp[(GGI*8)+1];
SC=inp[(GGI*8)+2];
SD=inp[(GGI*8)+3];
SE=inp[(GGI*8)+4];
SF=inp[(GGI*8)+5];
SG=inp[(GGI*8)+6];
SH=inp[(GGI*8)+7];


x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt2.sA);
x8=(x8<<32)|(salt2.s9);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

SSA=A;
SSB=B;
SSC=C;
SSD=D;
SSE=E;
SSF=F;
SSG=G;
SSH=H;




x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt2.sC);
x8=(x8<<32)|(salt2.sB);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

SSSA=A;
SSSB=B;
SSSC=C;
SSSD=D;
SSSE=E;
SSSF=F;
SSSG=G;
SSSH=H;


/* Initial key for AES-256 */
TTA=(uint)((ulong)(SSA&0xFFFFFFFF));
TTB=(uint)((ulong)(SSA>>32));
TTC=(uint)(((ulong)SSB&0xFFFFFFFF));
TTD=(uint)((ulong)(SSB>>32));
TTE=(uint)((ulong)(SSC&0xFFFFFFFF));
TTF=(uint)((ulong)(SSC>>32));
TTG=(uint)((ulong)(SSD&0xFFFFFFFF));
TTH=(uint)((ulong)(SSD>>32));


Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);


rk0=TTA;
rk1=TTB;
rk2=TTC;
rk3=TTD;
rk4=TTE;
rk5=TTF;
rk6=TTG;
rk7=TTH;


/* Setup s0..s3 */
AES256_GET_KEYS0;
ir0=salt.s4;
ir1=salt.s5;
ir2=salt.s6;
ir3=salt.s7;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ k0;
s1 = ir1 ^ k1;
s2 = ir2 ^ k2;
s3 = ir3 ^ k3;

AES256_GET_KEYS1;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS2;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS3;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS4;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS5;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS6;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS7;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS8;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS9;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS10;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS11;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS12;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS13;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS14;
AES256_FINAL;

a=salt.s0;
b=salt.s1;
c=salt.s2;
d=salt.s3;

s0=s0^a;
s1=s1^b;
s2=s2^c;
s3=s3^d;



x0=s1;
x0=(x0<<32);
x0|=s0;
x1=s3;
x1=(x1<<32);
x1|=s2;
x2=(0x80L);
Endian_Reverse64(x0);
Endian_Reverse64(x1);
Endian_Reverse64(x2);
x3=x4=x5=x6=x7=x8=x9=x10=x11=x12=x13=x14=x16=(ulong)0;

SIZE=(ulong)16<<3;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC4);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC5);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC6);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC7);
ROUND512_0_TO_15_NL(B,C,D,E,F,G,H,A,AC8);
ROUND512_0_TO_15_NL(A,B,C,D,E,F,G,H,AC9);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);



/* Initial key for AES-256 */
TTA=(uint)(SSSA&0xFFFFFFFF);
TTB=(uint)((SSSA>>32));
TTC=(uint)(SSSB&0xFFFFFFFF);
TTD=(uint)((SSSB>>32));
TTE=(uint)(SSSC&0xFFFFFFFF);
TTF=(uint)((SSSC>>32));
TTG=(uint)(SSSD&0xFFFFFFFF);
TTH=(uint)((SSSD>>32));

Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);
Endian_Reverse32(TTE);
Endian_Reverse32(TTF);
Endian_Reverse32(TTG);
Endian_Reverse32(TTH);

rk0=TTA;
rk1=TTB;
rk2=TTC;
rk3=TTD;
rk4=TTE;
rk5=TTF;
rk6=TTG;
rk7=TTH;


/* Setup s0..s3 */
AES256_GET_KEYS0;
ir0=salt.s8;
ir1=salt.s9;
ir2=salt.sA;
ir3=salt.sB;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ k0;
s1 = ir1 ^ k1;
s2 = ir2 ^ k2;
s3 = ir3 ^ k3;

AES256_GET_KEYS1;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS2;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS3;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS4;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS5;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS6;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS7;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS8;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS9;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS10;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS11;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS12;
AES256_INV_MIX;
AES256_ODD_ROUND;

AES256_GET_KEYS13;
AES256_INV_MIX;
AES256_EVEN_ROUND;

AES256_GET_KEYS14;
AES256_FINAL;

a=salt.s0;
b=salt.s1;
c=salt.s2;
d=salt.s3;

s0=s0^a;
s1=s1^b;
s2=s2^c;
s3=s3^d;

a=(A&0xFFFFFFFF);
b=(A>>32);
c=(B&0xFFFFFFFF);
d=(B>>32);


if ((s0!=(uint)a)) return;
if ((s1!=(uint)b)) return;
if ((s2!=(uint)c)) return;
if ((s3!=(uint)d)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(s0,s1,s2,s3);

}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void officefinal128( __global uint4 *dst,  __global ulong *inp, uint16 salt,uint16 salt2,__global uint *found_ind, __global uint *found)
{
ulong A,B,C,D,E,F,G,H,l,tmp1,tmp2,T1;
ulong SA,SB,SC,SD,SE,SF,SG,SH;
ulong SSA,SSB,SSC,SSD,SSE,SSF,SSG,SSH;
ulong SSSA,SSSB,SSSC,SSSD,SSSE,SSSF,SSSG,SSSH;
ulong x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,SIZE;
uint i;
uint m = 0x00FF00FFU;
uint m2 = 0xFF00FF00U;
uint TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
__local uint lTe[256];
__local uint lTd[256];
__local uint lTdK[256];
uint rk0,rk1,rk2,rk3,rk4,rk5,rk6,rk7,temp;
uint r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15;
uint k0,k1,k2,k3,k4,k5,k6,k7;
uint s0, s1, s2, s3, t0, t1, t2, t3;
uint kcache0,kcache1,kcache2,kcache3,kcache4,kcache5,kcache6,kcache7;
uint ir0,ir1,ir2,ir3;
uint ttmp1,ttmp2,tl;
uint a,b,c,d;

// Setup tables
lTe[GLI]=Te[GLI];
lTe[64+GLI]=Te[64+GLI];
lTe[128+GLI]=Te[128+GLI];
lTe[192+GLI]=Te[192+GLI];
lTd[GLI]=Td[GLI];
lTd[64+GLI]=Td[64+GLI];
lTd[128+GLI]=Td[128+GLI];
lTd[192+GLI]=Td[192+GLI];
lTdK[GLI]=TdK[GLI];
lTdK[64+GLI]=TdK[64+GLI];
lTdK[128+GLI]=TdK[128+GLI];
lTdK[192+GLI]=TdK[192+GLI];
barrier(CLK_LOCAL_MEM_FENCE);


SA=inp[(GGI*8)];
SB=inp[(GGI*8)+1];
SC=inp[(GGI*8)+2];
SD=inp[(GGI*8)+3];
SE=inp[(GGI*8)+4];
SF=inp[(GGI*8)+5];
SG=inp[(GGI*8)+6];
SH=inp[(GGI*8)+7];


x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt2.sA);
x8=(x8<<32)|(salt2.s9);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

SSA=A;
SSB=B;
SSC=C;
SSD=D;
SSE=E;
SSF=F;
SSG=G;
SSH=H;




x0=SA;
x1=SB;
x2=SC;
x3=SD;
x4=SE;
x5=SF;
x6=SG;
x7=SH;
x8=(salt2.sC);
x8=(x8<<32)|(salt2.sB);
Endian_Reverse64(x8);
x9=(0x80000000);
x9=x9<<32;

SIZE=(ulong)72<<3;

x10=x11=x12=x13=x14=x16=(ulong)0;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15(F,G,H,A,B,C,D,E,AC4,x3);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,x4);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,x5);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,x6);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,AC8,x7);
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC9,x8);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC10,x9);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);

SSSA=A;
SSSB=B;
SSSC=C;
SSSD=D;
SSSE=E;
SSSF=F;
SSSG=G;
SSSH=H;


/* Initial key for AES-256 */
TTA=(uint)((ulong)(SSA&0xFFFFFFFF));
TTB=(uint)((ulong)(SSA>>32));
TTC=(uint)(((ulong)SSB&0xFFFFFFFF));
TTD=(uint)((ulong)(SSB>>32));


Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);


rk0=TTA;
rk1=TTB;
rk2=TTC;
rk3=TTD;


/* Setup s0..s3 */
AES128_GET_KEYS0;
ir0=salt.s4;
ir1=salt.s5;
ir2=salt.s6;
ir3=salt.s7;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ k0;
s1 = ir1 ^ k1;
s2 = ir2 ^ k2;
s3 = ir3 ^ k3;

AES128_GET_KEYS1;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS2;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS3;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS4;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS5;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS6;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS7;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS8;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS9;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS10;
AES128_FINAL;

a=salt.s0;
b=salt.s1;
c=salt.s2;
d=salt.s3;

s0=s0^a;
s1=s1^b;
s2=s2^c;
s3=s3^d;



x0=s1;
x0=(x0<<32);
x0|=s0;
x1=s3;
x1=(x1<<32);
x1|=s2;
x2=(0x80L);
Endian_Reverse64(x0);
Endian_Reverse64(x1);
Endian_Reverse64(x2);
x3=x4=x5=x6=x7=x8=x9=x10=x11=x12=x13=x14=x16=(ulong)0;

SIZE=(ulong)16<<3;

A=(ulong)H0;
B=(ulong)H1;
C=(ulong)H2;
D=(ulong)H3;
E=(ulong)H4;
F=(ulong)H5;
G=(ulong)H6;
H=(ulong)H7;
ROUND512_0_TO_15(A,B,C,D,E,F,G,H,AC1,x0);
ROUND512_0_TO_15(H,A,B,C,D,E,F,G,AC2,x1);
ROUND512_0_TO_15(G,H,A,B,C,D,E,F,AC3,x2);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC4);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC5);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC6);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC7);
ROUND512_0_TO_15_NL(B,C,D,E,F,G,H,A,AC8);
ROUND512_0_TO_15_NL(A,B,C,D,E,F,G,H,AC9);
ROUND512_0_TO_15_NL(H,A,B,C,D,E,F,G,AC10);
ROUND512_0_TO_15_NL(G,H,A,B,C,D,E,F,AC11);
ROUND512_0_TO_15_NL(F,G,H,A,B,C,D,E,AC12);
ROUND512_0_TO_15_NL(E,F,G,H,A,B,C,D,AC13);
ROUND512_0_TO_15_NL(D,E,F,G,H,A,B,C,AC14);
ROUND512_0_TO_15_NL(C,D,E,F,G,H,A,B,AC15);
ROUND512_0_TO_15(B,C,D,E,F,G,H,A,SIZE,AC16);

x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(A,B,C,D,E,F,G,H,x16,AC17);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(H,A,B,C,D,E,F,G,x0,AC18);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(G,H,A,B,C,D,E,F,x1,AC19);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(F,G,H,A,B,C,D,E,x2,AC20);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(E,F,G,H,A,B,C,D,x3,AC21);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(D,E,F,G,H,A,B,C,x4,AC22);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(C,D,E,F,G,H,A,B,x5,AC23);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(B,C,D,E,F,G,H,A,x6,AC24);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(A,B,C,D,E,F,G,H,x7,AC25);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(H,A,B,C,D,E,F,G,x8,AC26);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(G,H,A,B,C,D,E,F,x9,AC27);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(F,G,H,A,B,C,D,E,x10,AC28);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(E,F,G,H,A,B,C,D,x11,AC29);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(D,E,F,G,H,A,B,C,x12,AC30);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(C,D,E,F,G,H,A,B,x13,AC31);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(B,C,D,E,F,G,H,A,x14,AC32);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(A,B,C,D,E,F,G,H,SIZE,AC33);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(H,A,B,C,D,E,F,G,x16,AC34);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(G,H,A,B,C,D,E,F,x0,AC35);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(F,G,H,A,B,C,D,E,x1,AC36);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(E,F,G,H,A,B,C,D,x2,AC37);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(D,E,F,G,H,A,B,C,x3,AC38);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(C,D,E,F,G,H,A,B,x4,AC39);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(B,C,D,E,F,G,H,A,x5,AC40);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(A,B,C,D,E,F,G,H,x6,AC41);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(H,A,B,C,D,E,F,G,x7,AC42);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(G,H,A,B,C,D,E,F,x8,AC43);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(F,G,H,A,B,C,D,E,x9,AC44);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(E,F,G,H,A,B,C,D,x10,AC45);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(D,E,F,G,H,A,B,C,x11,AC46);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(C,D,E,F,G,H,A,B,x12,AC47);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(B,C,D,E,F,G,H,A,x13,AC48);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(A,B,C,D,E,F,G,H,x14,AC49);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(H,A,B,C,D,E,F,G,SIZE,AC50);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(G,H,A,B,C,D,E,F,x16,AC51);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(F,G,H,A,B,C,D,E,x0,AC52);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(E,F,G,H,A,B,C,D,x1,AC53);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(D,E,F,G,H,A,B,C,x2,AC54);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(C,D,E,F,G,H,A,B,x3,AC55);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(B,C,D,E,F,G,H,A,x4,AC56);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(A,B,C,D,E,F,G,H,x5,AC57);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(H,A,B,C,D,E,F,G,x6,AC58);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(G,H,A,B,C,D,E,F,x7,AC59);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(F,G,H,A,B,C,D,E,x8,AC60);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(E,F,G,H,A,B,C,D,x9,AC61);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(D,E,F,G,H,A,B,C,x10,AC62);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(C,D,E,F,G,H,A,B,x11,AC63);
x12 = sigma1_512(x10)+x5+sigma0_512(x14)+x13; ROUND512(B,C,D,E,F,G,H,A,x12,AC64);
x13 = sigma1_512(x11)+x6+sigma0_512(SIZE)+x14; ROUND512(A,B,C,D,E,F,G,H,x13,AC65);
x14 = sigma1_512(x12)+x7+sigma0_512(x16)+SIZE; ROUND512(H,A,B,C,D,E,F,G,x14,AC66);
SIZE = sigma1_512(x13)+x8+sigma0_512(x0)+x16; ROUND512(G,H,A,B,C,D,E,F,SIZE,AC67);
x16 = sigma1_512(x14)+x9+sigma0_512(x1)+x0; ROUND512(F,G,H,A,B,C,D,E,x16,AC68);
x0 = sigma1_512(SIZE)+x10+sigma0_512(x2)+x1; ROUND512(E,F,G,H,A,B,C,D,x0,AC69);
x1 = sigma1_512(x16)+x11+sigma0_512(x3)+x2; ROUND512(D,E,F,G,H,A,B,C,x1,AC70);
x2 = sigma1_512(x0)+x12+sigma0_512(x4)+x3; ROUND512(C,D,E,F,G,H,A,B,x2,AC71);
x3 = sigma1_512(x1)+x13+sigma0_512(x5)+x4; ROUND512(B,C,D,E,F,G,H,A,x3,AC72);
x4 = sigma1_512(x2)+x14+sigma0_512(x6)+x5; ROUND512(A,B,C,D,E,F,G,H,x4,AC73);
x5 = sigma1_512(x3)+SIZE+sigma0_512(x7)+x6; ROUND512(H,A,B,C,D,E,F,G,x5,AC74);
x6 = sigma1_512(x4)+x16+sigma0_512(x8)+x7; ROUND512(G,H,A,B,C,D,E,F,x6,AC75);
x7 = sigma1_512(x5)+x0+sigma0_512(x9)+x8; ROUND512(F,G,H,A,B,C,D,E,x7,AC76);
x8 = sigma1_512(x6)+x1+sigma0_512(x10)+x9; ROUND512(E,F,G,H,A,B,C,D,x8,AC77);
x9 = sigma1_512(x7)+x2+sigma0_512(x11)+x10; ROUND512(D,E,F,G,H,A,B,C,x9,AC78);
x10 = sigma1_512(x8)+x3+sigma0_512(x12)+x11; ROUND512(C,D,E,F,G,H,A,B,x10,AC79);
x11 = sigma1_512(x9)+x4+sigma0_512(x13)+x12; ROUND512(B,C,D,E,F,G,H,A,x11,AC80);

A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;F=F+H5;G=G+H6;H=H+H7;

Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);



/* Initial key for AES-256 */
TTA=(uint)(SSSA&0xFFFFFFFF);
TTB=(uint)((SSSA>>32));
TTC=(uint)(SSSB&0xFFFFFFFF);
TTD=(uint)((SSSB>>32));

Endian_Reverse32(TTA);
Endian_Reverse32(TTB);
Endian_Reverse32(TTC);
Endian_Reverse32(TTD);

rk0=TTA;
rk1=TTB;
rk2=TTC;
rk3=TTD;


/* Setup s0..s3 */
AES128_GET_KEYS0;
ir0=salt.s8;
ir1=salt.s9;
ir2=salt.sA;
ir3=salt.sB;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);
s0 = ir0 ^ k0;
s1 = ir1 ^ k1;
s2 = ir2 ^ k2;
s3 = ir3 ^ k3;

AES128_GET_KEYS1;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS2;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS3;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS4;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS5;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS6;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS7;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS8;
AES128_INV_MIX;
AES128_ODD_ROUND;

AES128_GET_KEYS9;
AES128_INV_MIX;
AES128_EVEN_ROUND;

AES128_GET_KEYS10;
AES128_FINAL;

a=salt.s0;
b=salt.s1;
c=salt.s2;
d=salt.s3;

s0=s0^a;
s1=s1^b;
s2=s2^c;
s3=s3^d;

a=(A&0xFFFFFFFF);
b=(A>>32);
c=(B&0xFFFFFFFF);
d=(B>>32);


if ((s0!=(uint)a)) return;
if ((s1!=(uint)b)) return;
if ((s2!=(uint)c)) return;
if ((s3!=(uint)d)) return;


found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(s0,s1,s2,s3);

}



#endif
