#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    tmp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(tmp1)); \
    ai1[elem+1] = (tmp1==0) ? 0 : ai2>>(32-tmp1);\
    }


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *input, __global uint *input1, uint16 str, uint16 salt,uint16 salt2, __global uint *size)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,tmp1;


inpc[GLI][0] = input[GGI*(8)+0];
inpc[GLI][1] = input[GGI*(8)+1];
inpc[GLI][2] = input[GGI*(8)+2];
inpc[GLI][3] = input[GGI*(8)+3];
inpc[GLI][4] = input[GGI*(8)+4];
inpc[GLI][5] = input[GGI*(8)+5];
inpc[GLI][6] = input[GGI*(8)+6];
inpc[GLI][7] = input[GGI*(8)+7];

SIZE = size[GGI];

SET_AB(inpc[GLI],str.s0,SIZE,0);
SET_AB(inpc[GLI],str.s1,SIZE+4,0);
SET_AB(inpc[GLI],str.s2,SIZE+8,0);
SET_AB(inpc[GLI],str.s3,SIZE+12,0);

//SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

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
#define m2 0xFF00FF00U 


#ifndef GCN

// RIPEMD-160 macros

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))
#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint2)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint2)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint2)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint2)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint2)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint2)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint2)(0x50a28be6);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define BYTE_ADD(x,y) ( ((x+y)&(uint2)255) | ((((x>>(uint2)8)+(y>>(uint2)8))&(uint2)255)<<8) | ((((x>>(uint2)16)+(y>>(uint2)16))&(uint2)255)<<(uint2)16) |((((x>>(uint2)24)+(y>>(uint2)24))&(uint2)255)<<(uint2)24)  )


// SHA-512 macros

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


// Whirlpool macros

__constant ulong CC0[256] = {
0x18186018c07830d8L, 0x23238c2305af4626L, 0xc6c63fc67ef991b8L, 0xe8e887e8136fcdfbL, 
0x878726874ca113cbL, 0xb8b8dab8a9626d11L, 0x101040108050209L, 0x4f4f214f426e9e0dL, 
0x3636d836adee6c9bL, 0xa6a6a2a6590451ffL, 0xd2d26fd2debdb90cL, 0xf5f5f3f5fb06f70eL, 
0x7979f979ef80f296L, 0x6f6fa16f5fcede30L, 0x91917e91fcef3f6dL, 0x52525552aa07a4f8L, 
0x60609d6027fdc047L, 0xbcbccabc89766535L, 0x9b9b569baccd2b37L, 0x8e8e028e048c018aL, 
0xa3a3b6a371155bd2L, 0xc0c300c603c186cL, 0x7b7bf17bff8af684L, 0x3535d435b5e16a80L, 
0x1d1d741de8693af5L, 0xe0e0a7e05347ddb3L, 0xd7d77bd7f6acb321L, 0xc2c22fc25eed999cL, 
0x2e2eb82e6d965c43L, 0x4b4b314b627a9629L, 0xfefedffea321e15dL, 0x575741578216aed5L, 
0x15155415a8412abdL, 0x7777c1779fb6eee8L, 0x3737dc37a5eb6e92L, 0xe5e5b3e57b56d79eL, 
0x9f9f469f8cd92313L, 0xf0f0e7f0d317fd23L, 0x4a4a354a6a7f9420L, 0xdada4fda9e95a944L, 
0x58587d58fa25b0a2L, 0xc9c903c906ca8fcfL, 0x2929a429558d527cL, 0xa0a280a5022145aL, 
0xb1b1feb1e14f7f50L, 0xa0a0baa0691a5dc9L, 0x6b6bb16b7fdad614L, 0x85852e855cab17d9L, 
0xbdbdcebd8173673cL, 0x5d5d695dd234ba8fL, 0x1010401080502090L, 0xf4f4f7f4f303f507L, 
0xcbcb0bcb16c08bddL, 0x3e3ef83eedc67cd3L, 0x505140528110a2dL, 0x676781671fe6ce78L, 
0xe4e4b7e47353d597L, 0x27279c2725bb4e02L, 0x4141194132588273L, 0x8b8b168b2c9d0ba7L, 
0xa7a7a6a7510153f6L, 0x7d7de97dcf94fab2L, 0x95956e95dcfb3749L, 0xd8d847d88e9fad56L, 
0xfbfbcbfb8b30eb70L, 0xeeee9fee2371c1cdL, 0x7c7ced7cc791f8bbL, 0x6666856617e3cc71L, 
0xdddd53dda68ea77bL, 0x17175c17b84b2eafL, 0x4747014702468e45L, 0x9e9e429e84dc211aL, 
0xcaca0fca1ec589d4L, 0x2d2db42d75995a58L, 0xbfbfc6bf9179632eL, 0x7071c07381b0e3fL, 
0xadad8ead012347acL, 0x5a5a755aea2fb4b0L, 0x838336836cb51befL, 0x3333cc3385ff66b6L, 
0x636391633ff2c65cL, 0x2020802100a0412L, 0xaaaa92aa39384993L, 0x7171d971afa8e2deL, 
0xc8c807c80ecf8dc6L, 0x19196419c87d32d1L, 0x494939497270923bL, 0xd9d943d9869aaf5fL, 
0xf2f2eff2c31df931L, 0xe3e3abe34b48dba8L, 0x5b5b715be22ab6b9L, 0x88881a8834920dbcL, 
0x9a9a529aa4c8293eL, 0x262698262dbe4c0bL, 0x3232c8328dfa64bfL, 0xb0b0fab0e94a7d59L, 
0xe9e983e91b6acff2L, 0xf0f3c0f78331e77L, 0xd5d573d5e6a6b733L, 0x80803a8074ba1df4L, 
0xbebec2be997c6127L, 0xcdcd13cd26de87ebL, 0x3434d034bde46889L, 0x48483d487a759032L, 
0xffffdbffab24e354L, 0x7a7af57af78ff48dL, 0x90907a90f4ea3d64L, 0x5f5f615fc23ebe9dL, 
0x202080201da0403dL, 0x6868bd6867d5d00fL, 0x1a1a681ad07234caL, 0xaeae82ae192c41b7L, 
0xb4b4eab4c95e757dL, 0x54544d549a19a8ceL, 0x93937693ece53b7fL, 0x222288220daa442fL, 
0x64648d6407e9c863L, 0xf1f1e3f1db12ff2aL, 0x7373d173bfa2e6ccL, 0x12124812905a2482L, 
0x40401d403a5d807aL, 0x808200840281048L, 0xc3c32bc356e89b95L, 0xecec97ec337bc5dfL, 
0xdbdb4bdb9690ab4dL, 0xa1a1bea1611f5fc0L, 0x8d8d0e8d1c830791L, 0x3d3df43df5c97ac8L, 
0x97976697ccf1335bL, 0x0L, 0xcfcf1bcf36d483f9L, 0x2b2bac2b4587566eL, 
0x7676c57697b3ece1L, 0x8282328264b019e6L, 0xd6d67fd6fea9b128L, 0x1b1b6c1bd87736c3L, 
0xb5b5eeb5c15b7774L, 0xafaf86af112943beL, 0x6a6ab56a77dfd41dL, 0x50505d50ba0da0eaL, 
0x45450945124c8a57L, 0xf3f3ebf3cb18fb38L, 0x3030c0309df060adL, 0xefef9bef2b74c3c4L, 
0x3f3ffc3fe5c37edaL, 0x55554955921caac7L, 0xa2a2b2a2791059dbL, 0xeaea8fea0365c9e9L, 
0x656589650fecca6aL, 0xbabad2bab9686903L, 0x2f2fbc2f65935e4aL, 0xc0c027c04ee79d8eL, 
0xdede5fdebe81a160L, 0x1c1c701ce06c38fcL, 0xfdfdd3fdbb2ee746L, 0x4d4d294d52649a1fL, 
0x92927292e4e03976L, 0x7575c9758fbceafaL, 0x6061806301e0c36L, 0x8a8a128a249809aeL, 
0xb2b2f2b2f940794bL, 0xe6e6bfe66359d185L, 0xe0e380e70361c7eL, 0x1f1f7c1ff8633ee7L, 
0x6262956237f7c455L, 0xd4d477d4eea3b53aL, 0xa8a89aa829324d81L, 0x96966296c4f43152L, 
0xf9f9c3f99b3aef62L, 0xc5c533c566f697a3L, 0x2525942535b14a10L, 0x59597959f220b2abL, 
0x84842a8454ae15d0L, 0x7272d572b7a7e4c5L, 0x3939e439d5dd72ecL, 0x4c4c2d4c5a619816L, 
0x5e5e655eca3bbc94L, 0x7878fd78e785f09fL, 0x3838e038ddd870e5L, 0x8c8c0a8c14860598L, 
0xd1d163d1c6b2bf17L, 0xa5a5aea5410b57e4L, 0xe2e2afe2434dd9a1L, 0x616199612ff8c24eL, 
0xb3b3f6b3f1457b42L, 0x2121842115a54234L, 0x9c9c4a9c94d62508L, 0x1e1e781ef0663ceeL, 
0x4343114322528661L, 0xc7c73bc776fc93b1L, 0xfcfcd7fcb32be54fL, 0x404100420140824L, 
0x51515951b208a2e3L, 0x99995e99bcc72f25L, 0x6d6da96d4fc4da22L, 0xd0d340d68391a65L, 
0xfafacffa8335e979L, 0xdfdf5bdfb684a369L, 0x7e7ee57ed79bfca9L, 0x242490243db44819L, 
0x3b3bec3bc5d776feL, 0xabab96ab313d4b9aL, 0xcece1fce3ed181f0L, 0x1111441188552299L, 
0x8f8f068f0c890383L, 0x4e4e254e4a6b9c04L, 0xb7b7e6b7d1517366L, 0xebeb8beb0b60cbe0L, 
0x3c3cf03cfdcc78c1L, 0x81813e817cbf1ffdL, 0x94946a94d4fe3540L, 0xf7f7fbf7eb0cf31cL,
0xb9b9deb9a1676f18L, 0x13134c13985f268bL, 0x2c2cb02c7d9c5851L, 0xd3d36bd3d6b8bb05L, 
0xe7e7bbe76b5cd38cL, 0x6e6ea56e57cbdc39L, 0xc4c437c46ef395aaL, 0x3030c03180f061bL, 
0x565645568a13acdcL, 0x44440d441a49885eL, 0x7f7fe17fdf9efea0L, 0xa9a99ea921374f88L, 
0x2a2aa82a4d825467L, 0xbbbbd6bbb16d6b0aL, 0xc1c123c146e29f87L, 0x53535153a202a6f1L, 
0xdcdc57dcae8ba572L, 0xb0b2c0b58271653L, 0x9d9d4e9d9cd32701L, 0x6c6cad6c47c1d82bL, 
0x3131c43195f562a4L, 0x7474cd7487b9e8f3L, 0xf6f6fff6e309f115L, 0x464605460a438c4cL, 
0xacac8aac092645a5L, 0x89891e893c970fb5L, 0x14145014a04428b4L, 0xe1e1a3e15b42dfbaL, 
0x16165816b04e2ca6L, 0x3a3ae83acdd274f7L, 0x6969b9696fd0d206L, 0x9092409482d1241L, 
0x7070dd70a7ade0d7L, 0xb6b6e2b6d954716fL, 0xd0d067d0ceb7bd1eL, 0xeded93ed3b7ec7d6L, 
0xcccc17cc2edb85e2L, 0x424215422a578468L, 0x98985a98b4c22d2cL, 0xa4a4aaa4490e55edL, 
0x2828a0285d885075L, 0x5c5c6d5cda31b886L, 0xf8f8c7f8933fed6bL, 0x8686228644a411c2L
};

__constant ulong rc[10] = {
    (0x1823c6e887b8014fL),
    (0x36a6d2f5796f9152L),
    (0x60bc9b8ea30c7b35L),
    (0x1de0d7c22e4bfe57L),
    (0x157737e59ff04adaL),
    (0x58c9290ab1a06b85L),
    (0xbd5d10f4cb3e0567L),
    (0xe427418ba77d95d8L),
    (0xfbee7c66dd17479eL),
    (0xca2dbf07ad5a8333L),
};


#define ROTR(x,b)  (((x) >> (b)) | ((x) << (64 - (b))))



#define WH_L(a) \
L0.x = C0[(K0.x >> 56)&255] ^ \
     ROTR(C0[(K7.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K6.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K5.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K4.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K3.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K2.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K1.x) &0xff],56) ^ (a); \
L0.y = C0[(K0.y >> 56L)] ^ \
     ROTR(C0[(K7.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K6.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K5.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K4.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K3.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K2.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K1.y) & 0xff],56) ^ (a); \
L1.x = C0[(K1.x >> 56)&255] ^ \
     ROTR(C0[(K0.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K7.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K6.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K5.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K4.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K3.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K2.x) &0xff],56); \
L1.y = C0[(K1.y >> 56L)] ^ \
     ROTR(C0[(K0.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K7.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K6.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K5.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K4.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K3.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K2.y) & 0xff],56); \
L2.x = C0[(K2.x >> 56)&255] ^ \
     ROTR(C0[(K1.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K0.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K7.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K6.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K5.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K4.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K3.x) &0xff],56); \
L2.y = C0[(K2.y >> 56L)] ^ \
     ROTR(C0[(K1.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K0.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K7.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K6.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K5.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K4.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K3.y) & 0xff],56); \
L3.x = C0[(K3.x >> 56)&255] ^ \
     ROTR(C0[(K2.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K1.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K0.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K7.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K6.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K5.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K4.x) &0xff],56); \
L3.y = C0[(K3.y >> 56L)] ^ \
     ROTR(C0[(K2.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K1.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K0.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K7.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K6.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K5.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K4.y) & 0xff],56); \
L4.x = C0[(K4.x >> 56)&255] ^ \
     ROTR(C0[(K3.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K2.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K1.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K0.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K7.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K6.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K5.x) &0xff],56); \
L4.y = C0[(K4.y >> 56L)] ^ \
     ROTR(C0[(K3.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K2.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K1.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K0.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K7.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K6.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K5.y) & 0xff],56); \
L5.x = C0[(K5.x >> 56)&255] ^ \
     ROTR(C0[(K4.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K3.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K2.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K1.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K0.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K7.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K6.x) &0xff],56); \
L5.y = C0[(K5.y >> 56L)] ^ \
     ROTR(C0[(K4.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K3.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K2.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K1.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K0.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K7.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K6.y) & 0xff],56); \
L6.x = C0[(K6.x >> 56)&255] ^ \
     ROTR(C0[(K5.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K4.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K3.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K2.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K1.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K0.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K7.x) &0xff],56); \
L6.y = C0[(K6.y >> 56L)] ^ \
     ROTR(C0[(K5.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K4.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K3.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K2.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K1.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K0.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K7.y) & 0xff],56); \
L7.x = C0[(K7.x >> 56)&255] ^ \
     ROTR(C0[(K6.x >> 48)&0xff],8) ^ \
     ROTR(C0[(K5.x >> 40)&0xff],16) ^ \
     ROTR(C0[(K4.x >> 32)&0xff],24) ^ \
     ROTR(C0[(K3.x >> 24)&0xff],32) ^ \
     ROTR(C0[(K2.x >> 16)&0xff],40) ^ \
     ROTR(C0[(K1.x >>  8)&0xff],48) ^ \
     ROTR(C0[(K0.x) &0xff],56); \
L7.y = C0[(K7.y >> 56L)] ^ \
     ROTR(C0[(K6.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(K5.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(K4.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(K3.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(K2.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(K1.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(K0.y) & 0xff],56);
#define WH_R() \
L0.x = C0[(A.x >> 56)&255] ^ \
     ROTR(C0[(H.x >> 48)&0xff],8) ^ \
     ROTR(C0[(G.x >> 40)&0xff],16) ^ \
     ROTR(C0[(F.x >> 32)&0xff],24) ^ \
     ROTR(C0[(E.x >> 24)&0xff],32) ^ \
     ROTR(C0[(D.x >> 16)&0xff],40) ^ \
     ROTR(C0[(C.x >>  8)&0xff],48) ^ \
     ROTR(C0[(B.x) &0xff],56) ^ K0.x; \
L0.y = C0[(A.y >> 56L)] ^ \
     ROTR(C0[(H.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(G.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(F.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(E.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(D.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(C.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(B.y) & 0xff],56) ^ K0.y; \
L1.x = C0[(B.x >> 56)&255] ^ \
     ROTR(C0[(A.x >> 48)&0xff],8) ^ \
     ROTR(C0[(H.x >> 40)&0xff],16) ^ \
     ROTR(C0[(G.x >> 32)&0xff],24) ^ \
     ROTR(C0[(F.x >> 24)&0xff],32) ^ \
     ROTR(C0[(E.x >> 16)&0xff],40) ^ \
     ROTR(C0[(D.x >>  8)&0xff],48) ^ \
     ROTR(C0[(C.x) &0xff],56) ^ K1.x; \
L1.y = C0[(B.y >> 56L)] ^ \
     ROTR(C0[(A.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(H.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(G.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(F.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(E.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(D.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(C.y) & 0xff],56) ^ K1.y; \
L2.x = C0[(C.x >> 56)&255] ^ \
     ROTR(C0[(B.x >> 48)&0xff],8) ^ \
     ROTR(C0[(A.x >> 40)&0xff],16) ^ \
     ROTR(C0[(H.x >> 32)&0xff],24) ^ \
     ROTR(C0[(G.x >> 24)&0xff],32) ^ \
     ROTR(C0[(F.x >> 16)&0xff],40) ^ \
     ROTR(C0[(E.x >>  8)&0xff],48) ^ \
     ROTR(C0[(D.x) &0xff],56) ^ K2.x; \
L2.y = C0[(C.y >> 56L)] ^ \
     ROTR(C0[(B.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(A.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(H.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(G.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(F.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(E.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(D.y) & 0xff],56) ^ K2.y; \
L3.x = C0[(D.x >> 56)&255] ^ \
     ROTR(C0[(C.x >> 48)&0xff],8) ^ \
     ROTR(C0[(B.x >> 40)&0xff],16) ^ \
     ROTR(C0[(A.x >> 32)&0xff],24) ^ \
     ROTR(C0[(H.x >> 24)&0xff],32) ^ \
     ROTR(C0[(G.x >> 16)&0xff],40) ^ \
     ROTR(C0[(F.x >>  8)&0xff],48) ^ \
     ROTR(C0[(E.x) &0xff],56) ^ K3.x; \
L3.y = C0[(D.y >> 56L)] ^ \
     ROTR(C0[(C.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(B.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(A.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(H.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(G.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(F.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(E.y) & 0xff],56) ^ K3.y; \
L4.x = C0[(E.x >> 56)&255] ^ \
     ROTR(C0[(D.x >> 48)&0xff],8) ^ \
     ROTR(C0[(C.x >> 40)&0xff],16) ^ \
     ROTR(C0[(B.x >> 32)&0xff],24) ^ \
     ROTR(C0[(A.x >> 24)&0xff],32) ^ \
     ROTR(C0[(H.x >> 16)&0xff],40) ^ \
     ROTR(C0[(G.x >>  8)&0xff],48) ^ \
     ROTR(C0[(F.x) &0xff],56) ^ K4.x; \
L4.y = C0[(E.y >> 56L)] ^ \
     ROTR(C0[(D.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(C.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(B.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(A.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(H.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(G.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(F.y) & 0xff],56) ^ K4.y; \
L5.x = C0[(F.x >> 56)&255] ^ \
     ROTR(C0[(E.x >> 48)&0xff],8) ^ \
     ROTR(C0[(D.x >> 40)&0xff],16) ^ \
     ROTR(C0[(C.x >> 32)&0xff],24) ^ \
     ROTR(C0[(B.x >> 24)&0xff],32) ^ \
     ROTR(C0[(A.x >> 16)&0xff],40) ^ \
     ROTR(C0[(H.x >>  8)&0xff],48) ^ \
     ROTR(C0[(G.x) &0xff],56) ^ K5.x; \
L5.y = C0[(F.y >> 56L)] ^ \
     ROTR(C0[(E.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(D.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(C.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(B.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(A.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(H.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(G.y) & 0xff],56) ^ K5.y; \
L6.x = C0[(G.x >> 56)&255] ^ \
     ROTR(C0[(F.x >> 48)&0xff],8) ^ \
     ROTR(C0[(E.x >> 40)&0xff],16) ^ \
     ROTR(C0[(D.x >> 32)&0xff],24) ^ \
     ROTR(C0[(C.x >> 24)&0xff],32) ^ \
     ROTR(C0[(B.x >> 16)&0xff],40) ^ \
     ROTR(C0[(A.x >>  8)&0xff],48) ^ \
     ROTR(C0[(H.x) &0xff],56) ^ K6.x; \
L6.y = C0[(G.y >> 56L)] ^ \
     ROTR(C0[(F.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(E.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(D.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(C.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(B.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(A.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(H.y) & 0xff],56) ^ K6.y; \
L7.x = C0[(H.x >> 56)&255] ^ \
     ROTR(C0[(G.x >> 48)&0xff],8) ^ \
     ROTR(C0[(F.x >> 40)&0xff],16) ^ \
     ROTR(C0[(E.x >> 32)&0xff],24) ^ \
     ROTR(C0[(D.x >> 24)&0xff],32) ^ \
     ROTR(C0[(C.x >> 16)&0xff],40) ^ \
     ROTR(C0[(B.x >>  8)&0xff],48) ^ \
     ROTR(C0[(A.x) &0xff],56) ^ K7.x; \
L7.y = C0[(H.y >> 56L)] ^ \
     ROTR(C0[(G.y >> 48L) & 0xff],8L) ^ \
     ROTR(C0[(F.y >> 40L) & 0xff],16L) ^ \
     ROTR(C0[(E.y >> 32L) & 0xff],24L) ^ \
     ROTR(C0[(D.y >> 24L) & 0xff],32L) ^ \
     ROTR(C0[(C.y >> 16L) & 0xff],40L) ^ \
     ROTR(C0[(B.y >>  8L) & 0xff],48L) ^ \
     ROTR(C0[(A.y) & 0xff],56) ^ K7.y;

#define WHIRLPOOL_ROUND(a) \
    WH_L((a)); \
    K0=L0;K1=L1;K2=L2;K3=L3;K4=L4;K5=L5;K6=L6;K7=L7; \
    WH_R(); \
    A=L0;B=L1;C=L2;D=L3;E=L4;F=L5;G=L6;H=L7; \




// This is the prepare function for RIPEMD-160
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare1( __global uint2 *dst,  __global uint *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 SIZE;  
uint ib,ic,id;  
uint2 ta,tb,tc,td,te,tf,tg,th, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w15;
uint yl,yr,zl,zr,wl,wr;
uint2 A,B,C,D,E;
uint2 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint2 IPA,IPB,IPC,IPD,IPE;
uint2 OPA,OPB,OPC,OPD,OPE;
uint2 TTA,TTB,TTC,TTD,TTE;

TTA=TTB=TTC=TTD=TTE=(uint2)0;


ta.s0=input[get_global_id(0)*2*8];
tb.s0=input[get_global_id(0)*2*8+1];
tc.s0=input[get_global_id(0)*2*8+2];
td.s0=input[get_global_id(0)*2*8+3];
te.s0=input[get_global_id(0)*2*8+4];
tf.s0=input[get_global_id(0)*2*8+5];
tg.s0=input[get_global_id(0)*2*8+6];
th.s0=input[get_global_id(0)*2*8+7];

ta.s1=input[get_global_id(0)*2*8+8];
tb.s1=input[get_global_id(0)*2*8+9];
tc.s1=input[get_global_id(0)*2*8+10];
td.s1=input[get_global_id(0)*2*8+11];
te.s1=input[get_global_id(0)*2*8+12];
tf.s1=input[get_global_id(0)*2*8+13];
tg.s1=input[get_global_id(0)*2*8+14];
th.s1=input[get_global_id(0)*2*8+15];


ta = BYTE_ADD(ta,(uint2)salt2.s0);
tb = BYTE_ADD(tb,(uint2)salt2.s1);
tc = BYTE_ADD(tc,(uint2)salt2.s2);
td = BYTE_ADD(td,(uint2)salt2.s3);
te = BYTE_ADD(te,(uint2)salt2.s4);
tf = BYTE_ADD(tf,(uint2)salt2.s5);
tg = BYTE_ADD(tg,(uint2)salt2.s6);
th = BYTE_ADD(th,(uint2)salt2.s7);


// Initial HMAC (for PBKDF2)

// Calculate sha1(ipad^key)

w0 = (uint2)0x36363636 ^ ta;
w1 = (uint2)0x36363636 ^ tb;
w2 = (uint2)0x36363636 ^ tc;
w3 = (uint2)0x36363636 ^ td;
w4 = (uint2)0x36363636 ^ te;
w5 = (uint2)0x36363636 ^ tf;
w6 = (uint2)0x36363636 ^ tg;
w7 = (uint2)0x36363636 ^ th;
w8 = (uint2)0x36363636 ^ (uint2)salt2.s8;
w9 = (uint2)0x36363636 ^ (uint2)salt2.s9;
w10 = (uint2)0x36363636 ^ (uint2)salt2.sA;
w11 = (uint2)0x36363636 ^ (uint2)salt2.sB;
w12 = (uint2)0x36363636 ^ (uint2)salt2.sC;
w13 = (uint2)0x36363636 ^ (uint2)salt2.sD;
SIZE = (uint2)0x36363636 ^ (uint2)salt2.sE;
w15 = (uint2)0x36363636 ^ (uint2)salt2.sF;


aa=(uint2)0x67452301;
bb=(uint2)0xefcdab89;
cc=(uint2)0x98badcfe;
dd=(uint2)0x10325476;
ee=(uint2)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

IPA=coaa;IPB=cobb;IPC=cocc;IPD=codd;IPE=coee;



// Calculate sha1(opad^key)
w0 = (uint2)0x5c5c5c5c ^ ta;
w1 = (uint2)0x5c5c5c5c ^ tb;
w2 = (uint2)0x5c5c5c5c ^ tc;
w3 = (uint2)0x5c5c5c5c ^ td;
w4 = (uint2)0x5c5c5c5c ^ te;
w5 = (uint2)0x5c5c5c5c ^ tf;
w6 = (uint2)0x5c5c5c5c ^ tg;
w7 = (uint2)0x5c5c5c5c ^ th;
w8 = (uint2)0x5c5c5c5c ^ (uint2)salt2.s8;
w9 = (uint2)0x5c5c5c5c ^ (uint2)salt2.s9;
w10 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sA;
w11 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sB;
w12 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sC;
w13 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sD;
SIZE = (uint2)0x5c5c5c5c ^ (uint2)salt2.sE;
w15 = (uint2)0x5c5c5c5c ^ (uint2)salt2.sF;

aa=(uint2)0x67452301;
bb=(uint2)0xefcdab89;
cc=(uint2)0x98badcfe;
dd=(uint2)0x10325476;
ee=(uint2)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

OPA=coaa;OPB=cobb;OPC=cocc;OPD=codd;OPE=coee;



// calculate hash sum 1

w0=(uint2)salt.s0;
w1=(uint2)salt.s1;
w2=(uint2)salt.s2;
w3=(uint2)salt.s3;
w4=(uint2)salt.s4;
w5=(uint2)salt.s5;
w6=(uint2)salt.s6;
w7=(uint2)salt.s7;
w8=(uint2)salt.s8;
w9=(uint2)salt.s9;
w10=(uint2)salt.sA;
w11=(uint2)salt.sB;
w12=(uint2)salt.sC;
w13=(uint2)salt.sD;
SIZE=(uint2)salt.sE;
w15=(uint2)salt.sF;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;



SIZE=(uint2)(64+64+4)<<3;
w0=(uint2)str.sC+1;
Endian_Reverse32(w0);
w1=(uint2)0x80;
w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=A;
bb=B;
cc=C;
dd=D;
ee=E;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);
ta=coaa;tb=cobb;tc=cocc;td=codd;te=coee;



// calculate hash sum 2

w0=ta;
w1=tb;
w2=tc;
w3=td;
w4=te;
w5=(uint2)0x80;
SIZE=(uint2)((64+20)<<3);
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

TTA=coaa;TTB=cobb;TTC=cocc;TTD=codd;TTE=coee;


input1[get_global_id(0)*2*5+0]=IPA;
input1[get_global_id(0)*2*5+1]=IPB;
input1[get_global_id(0)*2*5+2]=IPC;
input1[get_global_id(0)*2*5+3]=IPD;
input1[get_global_id(0)*2*5+4]=IPE;
input1[get_global_id(0)*2*5+5]=OPA;
input1[get_global_id(0)*2*5+6]=OPB;
input1[get_global_id(0)*2*5+7]=OPC;
input1[get_global_id(0)*2*5+8]=OPD;
input1[get_global_id(0)*2*5+9]=OPE;

dst[get_global_id(0)*2*5+0]=TTA;
dst[get_global_id(0)*2*5+1]=TTB;
dst[get_global_id(0)*2*5+2]=TTC;
dst[get_global_id(0)*2*5+3]=TTD;
dst[get_global_id(0)*2*5+4]=TTE;
dst[get_global_id(0)*2*5+5]=TTA;
dst[get_global_id(0)*2*5+6]=TTB;
dst[get_global_id(0)*2*5+7]=TTC;
dst[get_global_id(0)*2*5+8]=TTD;
dst[get_global_id(0)*2*5+9]=TTE;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf1( __global uint2 *dst,  __global uint2 *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 SIZE;  
uint ib,ic,id;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
uint2 A,B,C,D,E;
uint2 IPA,IPB,IPC,IPD,IPE;
uint2 OPA,OPB,OPC,OPD,OPE;
uint2 TTA,TTB,TTC,TTD,TTE;
uint2 aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;


TTA=dst[get_global_id(0)*2*5+0];
TTB=dst[get_global_id(0)*2*5+1];
TTC=dst[get_global_id(0)*2*5+2];
TTD=dst[get_global_id(0)*2*5+3];
TTE=dst[get_global_id(0)*2*5+4];
A=dst[get_global_id(0)*2*5+5];
B=dst[get_global_id(0)*2*5+6];
C=dst[get_global_id(0)*2*5+7];
D=dst[get_global_id(0)*2*5+8];
E=dst[get_global_id(0)*2*5+9];
IPA=input1[get_global_id(0)*2*5+0];
IPB=input1[get_global_id(0)*2*5+1];
IPC=input1[get_global_id(0)*2*5+2];
IPD=input1[get_global_id(0)*2*5+3];
IPE=input1[get_global_id(0)*2*5+4];
OPA=input1[get_global_id(0)*2*5+5];
OPB=input1[get_global_id(0)*2*5+6];
OPC=input1[get_global_id(0)*2*5+7];
OPD=input1[get_global_id(0)*2*5+8];
OPE=input1[get_global_id(0)*2*5+9];


// We now have the first HMAC. Iterate to find the rest
for (ic=str.sA;ic<str.sB;ic++)
{

// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint2)0x80;
SIZE=(uint2)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint2)0x80;
SIZE=(uint2)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint2)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint2)11);
FF(ee, aa, bb, cc, dd, w1, (uint2)14);
FF(dd, ee, aa, bb, cc, w2, (uint2)15);
FF(cc, dd, ee, aa, bb, w3, (uint2)12);
FF(bb, cc, dd, ee, aa, w4, (uint2)5);
FF(aa, bb, cc, dd, ee, w5,  (uint2)8);
FF(ee, aa, bb, cc, dd, w6,  (uint2)7);
FF(dd, ee, aa, bb, cc, w7,  (uint2)9);
FF(cc, dd, ee, aa, bb, w8, (uint2)11);
FF(bb, cc, dd, ee, aa, w9, (uint2)13);
FF(aa, bb, cc, dd, ee, w10, (uint2)14);
FF(ee, aa, bb, cc, dd, w11, (uint2)15);
FF(dd, ee, aa, bb, cc, w12,  (uint2)6);
FF(cc, dd, ee, aa, bb, w13,  (uint2)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint2)9);
FF(aa, bb, cc, dd, ee, w15,  (uint2)8);

GG(ee, aa, bb, cc, dd, w7,  (uint2)7);
GG(dd, ee, aa, bb, cc, w4,  (uint2)6);
GG(cc, dd, ee, aa, bb, w13,  (uint2)8);
GG(bb, cc, dd, ee, aa, w1, (uint2)13);
GG(aa, bb, cc, dd, ee, w10, (uint2)11);
GG(ee, aa, bb, cc, dd, w6,  (uint2)9);
GG(dd, ee, aa, bb, cc, w15,  (uint2)7);
GG(cc, dd, ee, aa, bb, w3, (uint2)15);
GG(bb, cc, dd, ee, aa, w12,  (uint2)7);
GG(aa, bb, cc, dd, ee, w0, (uint2)12);
GG(ee, aa, bb, cc, dd, w9, (uint2)15);
GG(dd, ee, aa, bb, cc, w5,  (uint2)9);
GG(cc, dd, ee, aa, bb, w2, (uint2)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint2)7);
GG(aa, bb, cc, dd, ee, w11, (uint2)13);
GG(ee, aa, bb, cc, dd, w8, (uint2)12);

HH(dd, ee, aa, bb, cc, w3, (uint2)11);
HH(cc, dd, ee, aa, bb, w10, (uint2)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint2)6);
HH(aa, bb, cc, dd, ee, w4, (uint2)7);
HH(ee, aa, bb, cc, dd, w9, (uint2)14);
HH(dd, ee, aa, bb, cc, w15, (uint2)9);
HH(cc, dd, ee, aa, bb, w8, (uint2)13);
HH(bb, cc, dd, ee, aa, w1, (uint2)15);
HH(aa, bb, cc, dd, ee, w2, (uint2)14);
HH(ee, aa, bb, cc, dd, w7, (uint2)8);
HH(dd, ee, aa, bb, cc, w0, (uint2)13);
HH(cc, dd, ee, aa, bb, w6, (uint2)6);
HH(bb, cc, dd, ee, aa, w13, (uint2)5);
HH(aa, bb, cc, dd, ee, w11, (uint2)12);
HH(ee, aa, bb, cc, dd, w5, (uint2)7);
HH(dd, ee, aa, bb, cc, w12, (uint2)5);

II(cc, dd, ee, aa, bb, w1, (uint2)11);
II(bb, cc, dd, ee, aa, w9, (uint2)12);
II(aa, bb, cc, dd, ee, w11, (uint2)14);
II(ee, aa, bb, cc, dd, w10, (uint2)15);
II(dd, ee, aa, bb, cc, w0, (uint2)14);
II(cc, dd, ee, aa, bb, w8, (uint2)15);
II(bb, cc, dd, ee, aa, w12, (uint2)9);
II(aa, bb, cc, dd, ee, w4, (uint2)8);
II(ee, aa, bb, cc, dd, w13, (uint2)9);
II(dd, ee, aa, bb, cc, w3, (uint2)14);
II(cc, dd, ee, aa, bb, w7, (uint2)5);
II(bb, cc, dd, ee, aa, w15, (uint2)6);
II(aa, bb, cc, dd, ee, SIZE, (uint2)8);
II(ee, aa, bb, cc, dd, w5, (uint2)6);
II(dd, ee, aa, bb, cc, w6, (uint2)5);
II(cc, dd, ee, aa, bb, w2, (uint2)12);

JJ(bb, cc, dd, ee, aa, w4, (uint2)9);
JJ(aa, bb, cc, dd, ee, w0, (uint2)15);
JJ(ee, aa, bb, cc, dd, w5, (uint2)5);
JJ(dd, ee, aa, bb, cc, w9, (uint2)11);
JJ(cc, dd, ee, aa, bb, w7, (uint2)6);
JJ(bb, cc, dd, ee, aa, w12, (uint2)8);
JJ(aa, bb, cc, dd, ee, w2, (uint2)13);
JJ(ee, aa, bb, cc, dd, w10, (uint2)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint2)5);
JJ(cc, dd, ee, aa, bb, w1, (uint2)12);
JJ(bb, cc, dd, ee, aa, w3, (uint2)13);
JJ(aa, bb, cc, dd, ee, w8, (uint2)14);
JJ(ee, aa, bb, cc, dd, w11, (uint2)11);
JJ(dd, ee, aa, bb, cc, w6, (uint2)8);
JJ(cc, dd, ee, aa, bb, w15, (uint2)5);
JJ(bb, cc, dd, ee, aa, w13, (uint2)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint2)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint2)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint2)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint2)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint2)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint2)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint2)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint2)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint2)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint2)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint2)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint2)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint2)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint2)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint2)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint2)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint2)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint2)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint2)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint2)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint2)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint2)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint2)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint2)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint2)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint2)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint2)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint2)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint2)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint2)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint2)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint2)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint2)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint2)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint2)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint2)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint2)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint2)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint2)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint2)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint2)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint2)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint2)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint2)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint2)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint2)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint2)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint2)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint2)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint2)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint2)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint2)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint2)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint2)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint2)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint2)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint2)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint2)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint2)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint2)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint2)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint2)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint2)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint2)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint2)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint2)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint2)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint2)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint2)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint2)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint2)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint2)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint2)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint2)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint2)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint2)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint2)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


TTA ^= A;
TTB ^= B;
TTC ^= C;
TTD ^= D;
TTE ^= E;

}

dst[get_global_id(0)*2*5+0]=TTA;
dst[get_global_id(0)*2*5+1]=TTB;
dst[get_global_id(0)*2*5+2]=TTC;
dst[get_global_id(0)*2*5+3]=TTD;
dst[get_global_id(0)*2*5+4]=TTE;
dst[get_global_id(0)*2*5+5]=A;
dst[get_global_id(0)*2*5+6]=B;
dst[get_global_id(0)*2*5+7]=C;
dst[get_global_id(0)*2*5+8]=D;
dst[get_global_id(0)*2*5+9]=E;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final1( __global uint *dst,  __global uint2 *input, __global uint2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint2 TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*5+0];
TTTB=input1[get_global_id(0)*2*5+1];
TTTC=input1[get_global_id(0)*2*5+2];
TTTD=input1[get_global_id(0)*2*5+3];
TTTE=input1[get_global_id(0)*2*5+4];


dst[(get_global_id(0)*100)+(str.sC)*5]=TTTA.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+1]=TTTB.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+2]=TTTC.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+3]=TTTD.s0;
dst[(get_global_id(0)*100)+(str.sC)*5+4]=TTTE.s0;

dst[(get_global_id(0)*100)+(str.sC)*5+50]=TTTA.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+1+50]=TTTB.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+2+50]=TTTC.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+3+50]=TTTD.s1;
dst[(get_global_id(0)*100)+(str.sC)*5+4+50]=TTTE.s1;
}




// This is the prepare function for SHA-512
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare2( __global ulong2 *dst,  __global uint *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 SIZE;  
uint ib,ic,id;  
uint2 ta,tb,tc,td,te,tf,tg,th;
uint2 tmp1,tmp2,l,t1; 
ulong2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
ulong2 A,B,C,D,E,F,G,H,T1;
ulong2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;

TTA=TTB=TTC=TTD=TTE=(ulong2)0;

ta.s0=input[get_global_id(0)*2*8];
tb.s0=input[get_global_id(0)*2*8+1];
tc.s0=input[get_global_id(0)*2*8+2];
td.s0=input[get_global_id(0)*2*8+3];
te.s0=input[get_global_id(0)*2*8+4];
tf.s0=input[get_global_id(0)*2*8+5];
tg.s0=input[get_global_id(0)*2*8+6];
th.s0=input[get_global_id(0)*2*8+7];

ta.s1=input[get_global_id(0)*2*8+8];
tb.s1=input[get_global_id(0)*2*8+9];
tc.s1=input[get_global_id(0)*2*8+10];
td.s1=input[get_global_id(0)*2*8+11];
te.s1=input[get_global_id(0)*2*8+12];
tf.s1=input[get_global_id(0)*2*8+13];
tg.s1=input[get_global_id(0)*2*8+14];
th.s1=input[get_global_id(0)*2*8+15];


ta = BYTE_ADD(ta,(uint2)salt2.s0);
tb = BYTE_ADD(tb,(uint2)salt2.s1);
tc = BYTE_ADD(tc,(uint2)salt2.s2);
td = BYTE_ADD(td,(uint2)salt2.s3);
te = BYTE_ADD(te,(uint2)salt2.s4);
tf = BYTE_ADD(tf,(uint2)salt2.s5);
tg = BYTE_ADD(tg,(uint2)salt2.s6);
th = BYTE_ADD(th,(uint2)salt2.s7);


// Initial HMAC (for PBKDF2)
// Calculate sha1(ipad^key)
w0 = 0x36363636 ^ (ulong2)(tb.x,tb.y);
w0 = (w0<<32)|(0x36363636 ^ (ulong2)(ta.x,ta.y));
w1 = 0x36363636 ^ (ulong2)(td.x,td.y);
w1 = (w1<<32)|(0x36363636 ^ (ulong2)(tc.x,tc.y));
w2 = 0x36363636 ^ (ulong2)(tf.x,tf.y);
w2 = (w2<<32)|(0x36363636 ^ (ulong2)(te.x,te.y));
w3 = 0x36363636 ^ (ulong2)(th.x,th.y);
w3 = (w3<<32)|(0x36363636 ^ (ulong2)(tg.x,tg.y));
w4 = 0x36363636 ^ (ulong2)salt2.s9;
w4 = (w4<<32)|(0x36363636 ^ salt2.s8);
w5 = 0x36363636 ^ (ulong2)salt2.sB;
w5 = (w5<<32)|(0x36363636 ^ salt2.sA);
w6 = 0x36363636 ^ (ulong2)salt2.sD;
w6 = (w6<<32)|(0x36363636 ^ salt2.sC);
w7 = 0x36363636 ^ (ulong2)salt2.sF;
w7 = (w7<<32)|(0x36363636 ^ salt2.sE);
w8 =   0x3636363636363636L;
w9 =   0x3636363636363636L;
w10 =  0x3636363636363636L;
w11 =  0x3636363636363636L;
w12 =  0x3636363636363636L;
w13 =  0x3636363636363636L;
w14 =  0x3636363636363636L;
SIZE = 0x3636363636363636L;

A=(ulong2)H0;
B=(ulong2)H1;
C=(ulong2)H2;
D=(ulong2)H3;
E=(ulong2)H4;
F=(ulong2)H5;
G=(ulong2)H6;
H=(ulong2)H7;

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

A+=(ulong2)H0;
B+=(ulong2)H1;
C+=(ulong2)H2;
D+=(ulong2)H3;
E+=(ulong2)H4;
F+=(ulong2)H5;
G+=(ulong2)H6;
H+=(ulong2)H7;

IPA=A;
IPB=B;
IPC=C;
IPD=D;
IPE=E;
IPF=F;
IPG=G;
IPH=H;


w0 = 0x5c5c5c5c ^ (ulong2)(tb.x,tb.y);
w0 = (w0<<32)|(0x5c5c5c5c ^ (ulong2)(ta.x,ta.y));
w1 = 0x5c5c5c5c ^ (ulong2)(td.x,td.y);
w1 = (w1<<32)|(0x5c5c5c5c ^ (ulong2)(tc.x,tc.y));
w2 = 0x5c5c5c5c ^ (ulong2)(tf.x,tf.y);
w2 = (w2<<32)|(0x5c5c5c5c ^ (ulong2)(te.x,te.y));
w3 = 0x5c5c5c5c ^ (ulong2)(th.x,th.y);
w3 = (w3<<32)|(0x5c5c5c5c ^ (ulong2)(tg.x,tg.y));
w4 = 0x5c5c5c5c ^ (ulong2)salt2.s9;
w4 = (w4<<32)|(0x5c5c5c5c ^ salt2.s8);
w5 = 0x5c5c5c5c ^ (ulong2)salt2.sB;
w5 = (w5<<32)|(0x5c5c5c5c ^ salt2.sA);
w6 = 0x5c5c5c5c ^ (ulong2)salt2.sD;
w6 = (w6<<32)|(0x5c5c5c5c ^ salt2.sC);
w7 = 0x5c5c5c5c ^ (ulong2)salt2.sF;
w7 = (w7<<32)|(0x5c5c5c5c ^ salt2.sE);
w8 = 0x5c5c5c5c5c5c5c5cL;
w9 = 0x5c5c5c5c5c5c5c5cL;
w10 = 0x5c5c5c5c5c5c5c5cL;
w11 = 0x5c5c5c5c5c5c5c5cL;
w12 = 0x5c5c5c5c5c5c5c5cL;
w13 = 0x5c5c5c5c5c5c5c5cL;
w14 = 0x5c5c5c5c5c5c5c5cL;
SIZE = 0x5c5c5c5c5c5c5c5cL;

A=(ulong2)H0;
B=(ulong2)H1;
C=(ulong2)H2;
D=(ulong2)H3;
E=(ulong2)H4;
F=(ulong2)H5;
G=(ulong2)H6;
H=(ulong2)H7;

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

A+=(ulong2)H0;
B+=(ulong2)H1;
C+=(ulong2)H2;
D+=(ulong2)H3;
E+=(ulong2)H4;
F+=(ulong2)H5;
G+=(ulong2)H6;
H+=(ulong2)H7;

OPA=A;
OPB=B;
OPC=C;
OPD=D;
OPE=E;
OPF=F;
OPG=G;
OPH=H;




// calculate hash sum 1

w0 = (ulong2)salt.s1;
w0 = (w0<<32)|((ulong2)salt.s0);
w1 = (ulong2)salt.s3;
w1 = (w1<<32)|((ulong2)salt.s2);
w2 = (ulong2)salt.s5;
w2 = (w2<<32)|((ulong2)salt.s4);
w3 = (ulong2)salt.s7;
w3 = (w3<<32)|((ulong2)salt.s6);
w4 = (ulong2)salt.s9;
w4 = (w4<<32)|((ulong2)salt.s8);
w5 = (ulong2)salt.sB;
w5 = (w5<<32)|((ulong2)salt.sA);
w6 = (ulong2)salt.sD;
w6 = (w6<<32)|((ulong2)salt.sC);
w7 = (ulong2)salt.sF;
w7 = (w7<<32)|((ulong2)salt.sE);
t1=(uint2)(str.sC+1);
Endian_Reverse32(t1);
w8=0x80;
w8=(w8<<32)|(ulong2)(t1.x,t1.y);
w9=w10=w11=w12=w13=w14=(ulong2)0;
SIZE=(ulong2)(128+64+4)<<3;

A=(ulong2)IPA;
B=(ulong2)IPB;
C=(ulong2)IPC;
D=(ulong2)IPD;
E=(ulong2)IPE;
F=(ulong2)IPF;
G=(ulong2)IPG;
H=(ulong2)IPH;

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

A+=(ulong2)IPA;
B+=(ulong2)IPB;
C+=(ulong2)IPC;
D+=(ulong2)IPD;
E+=(ulong2)IPE;
F+=(ulong2)IPF;
G+=(ulong2)IPG;
H+=(ulong2)IPH;




w0=w1=w2=w3=w4=w5=w6=w7=w8=(ulong2)0;

// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(ulong2)0x8000000000000000L;
w9=w10=w11=w12=w13=w14=w16=(ulong2)0;
SIZE=(ulong2)((128+64)<<3);
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
void pbkdf2( __global ulong2 *dst,  __global ulong2 *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 SIZE;  
uint ib,ic,id;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
ulong2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
ulong2 A,B,C,D,E,F,G,H,T1;
ulong2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;


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
w8=(ulong2)0x8000000000000000L;
SIZE=(ulong2)(128+64)<<3;
w9=w10=w11=w12=w13=w14=(ulong2)0;

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

A+=(ulong2)IPA;
B+=(ulong2)IPB;
C+=(ulong2)IPC;
D+=(ulong2)IPD;
E+=(ulong2)IPE;
F+=(ulong2)IPF;
G+=(ulong2)IPG;
H+=(ulong2)IPH;



// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;
w8=(ulong2)0x8000000000000000L;
SIZE=(ulong2)(128+64)<<3;
w9=w10=w11=w12=w13=w14=(ulong2)0;

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

A+=(ulong2)OPA;
B+=(ulong2)OPB;
C+=(ulong2)OPC;
D+=(ulong2)OPD;
E+=(ulong2)OPE;
F+=(ulong2)OPF;
G+=(ulong2)OPG;
H+=(ulong2)OPH;


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
void final2( __global ulong *dst,  __global ulong2 *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,TTTF,TTTG,TTTH,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*8+0];
TTTB=input1[get_global_id(0)*2*8+1];
TTTC=input1[get_global_id(0)*2*8+2];
TTTD=input1[get_global_id(0)*2*8+3];
TTTE=input1[get_global_id(0)*2*8+4];
TTTF=input1[get_global_id(0)*2*8+5];
TTTG=input1[get_global_id(0)*2*8+6];
TTTH=input1[get_global_id(0)*2*8+7];

Endian_Reverse64(TTTA);
Endian_Reverse64(TTTB);
Endian_Reverse64(TTTC);
Endian_Reverse64(TTTD);
Endian_Reverse64(TTTE);
Endian_Reverse64(TTTF);
Endian_Reverse64(TTTG);
Endian_Reverse64(TTTH);


dst[(get_global_id(0)*50)+(str.sC)*8]=TTTA.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+1]=TTTB.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+2]=TTTC.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+3]=TTTD.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+4]=TTTE.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+5]=TTTF.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+6]=TTTG.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+7]=TTTH.s0;

dst[(get_global_id(0)*50)+(str.sC)*8+25]=TTTA.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+1+25]=TTTB.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+2+25]=TTTC.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+3+25]=TTTD.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+4+25]=TTTE.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+5+25]=TTTF.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+6+25]=TTTG.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+7+25]=TTTH.s1;

}



// This is the prepare function for SHA-512
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare3( __global ulong2 *dst,  __global uint *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 SIZE;  
uint i;  
uint2 ta,tb,tc,td,te,tf,tg,th;
uint2 tmp1,tmp2,l,t1; 
ulong2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
ulong2 A,B,C,D,E,F,G,H,T1;
ulong2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
ulong2 tta,ttb,ttc,ttd,tte,ttf,ttg,tth;
ulong2 L0,L1,L2,L3,L4,L5,L6,L7;
ulong2 K0,K1,K2,K3,K4,K5,K6,K7;
__local ulong C0[256];


C0[get_local_id(0)]=CC0[get_local_id(0)];
C0[get_local_id(0)+64]=CC0[get_local_id(0)+64];
C0[get_local_id(0)+128]=CC0[get_local_id(0)+128];
C0[get_local_id(0)+192]=CC0[get_local_id(0)+192];
barrier(CLK_LOCAL_MEM_FENCE);


TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(ulong2)0;

ta.s0=input[get_global_id(0)*2*8];
tb.s0=input[get_global_id(0)*2*8+1];
tc.s0=input[get_global_id(0)*2*8+2];
td.s0=input[get_global_id(0)*2*8+3];
te.s0=input[get_global_id(0)*2*8+4];
tf.s0=input[get_global_id(0)*2*8+5];
tg.s0=input[get_global_id(0)*2*8+6];
th.s0=input[get_global_id(0)*2*8+7];

ta.s1=input[get_global_id(0)*2*8+8];
tb.s1=input[get_global_id(0)*2*8+9];
tc.s1=input[get_global_id(0)*2*8+10];
td.s1=input[get_global_id(0)*2*8+11];
te.s1=input[get_global_id(0)*2*8+12];
tf.s1=input[get_global_id(0)*2*8+13];
tg.s1=input[get_global_id(0)*2*8+14];
th.s1=input[get_global_id(0)*2*8+15];


ta = BYTE_ADD(ta,(uint2)salt2.s0);
tb = BYTE_ADD(tb,(uint2)salt2.s1);
tc = BYTE_ADD(tc,(uint2)salt2.s2);
td = BYTE_ADD(td,(uint2)salt2.s3);
te = BYTE_ADD(te,(uint2)salt2.s4);
tf = BYTE_ADD(tf,(uint2)salt2.s5);
tg = BYTE_ADD(tg,(uint2)salt2.s6);
th = BYTE_ADD(th,(uint2)salt2.s7);


// Initial HMAC (for PBKDF2)
// Calculate sha1(ipad^key)
w0 = 0x36363636 ^ (ulong2)(tb.x,tb.y);
w0 = (w0<<32)|(0x36363636 ^ (ulong2)(ta.x,ta.y));
w1 = 0x36363636 ^ (ulong2)(td.x,td.y);
w1 = (w1<<32)|(0x36363636 ^ (ulong2)(tc.x,tc.y));
w2 = 0x36363636 ^ (ulong2)(tf.x,tf.y);
w2 = (w2<<32)|(0x36363636 ^ (ulong2)(te.x,te.y));
w3 = 0x36363636 ^ (ulong2)(th.x,th.y);
w3 = (w3<<32)|(0x36363636 ^ (ulong2)(tg.x,tg.y));
w4 = 0x36363636 ^ (ulong2)salt2.s9;
w4 = (w4<<32)|(0x36363636 ^ salt2.s8);
w5 = 0x36363636 ^ (ulong2)salt2.sB;
w5 = (w5<<32)|(0x36363636 ^ salt2.sA);
w6 = 0x36363636 ^ (ulong2)salt2.sD;
w6 = (w6<<32)|(0x36363636 ^ salt2.sC);
w7 = 0x36363636 ^ (ulong2)salt2.sF;
w7 = (w7<<32)|(0x36363636 ^ salt2.sE);
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);


K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
A=w0;B=w1;C=w2;D=w3;E=w4=F=w5;G=w6;H=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

IPA=A;
IPB=B;
IPC=C;
IPD=D;
IPE=E;
IPF=F;
IPG=G;
IPH=H;


w0 = 0x5c5c5c5c ^ (ulong2)(tb.x,tb.y);
w0 = (w0<<32)|(0x5c5c5c5c ^ (ulong2)(ta.x,ta.y));
w1 = 0x5c5c5c5c ^ (ulong2)(td.x,td.y);
w1 = (w1<<32)|(0x5c5c5c5c ^ (ulong2)(tc.x,tc.y));
w2 = 0x5c5c5c5c ^ (ulong2)(tf.x,tf.y);
w2 = (w2<<32)|(0x5c5c5c5c ^ (ulong2)(te.x,te.y));
w3 = 0x5c5c5c5c ^ (ulong2)(th.x,th.y);
w3 = (w3<<32)|(0x5c5c5c5c ^ (ulong2)(tg.x,tg.y));
w4 = 0x5c5c5c5c ^ (ulong2)salt2.s9;
w4 = (w4<<32)|(0x5c5c5c5c ^ salt2.s8);
w5 = 0x5c5c5c5c ^ (ulong2)salt2.sB;
w5 = (w5<<32)|(0x5c5c5c5c ^ salt2.sA);
w6 = 0x5c5c5c5c ^ (ulong2)salt2.sD;
w6 = (w6<<32)|(0x5c5c5c5c ^ salt2.sC);
w7 = 0x5c5c5c5c ^ (ulong2)salt2.sF;
w7 = (w7<<32)|(0x5c5c5c5c ^ salt2.sE);
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
A=w0;B=w1;C=w2;D=w3;E=w4=F=w5;G=w6;H=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

OPA=A;
OPB=B;
OPC=C;
OPD=D;
OPE=E;
OPF=F;
OPG=G;
OPH=H;




// calculate hash sum 1

w0 = (ulong2)salt.s1;
w0 = (w0<<32)|((ulong2)salt.s0);
w1 = (ulong2)salt.s3;
w1 = (w1<<32)|((ulong2)salt.s2);
w2 = (ulong2)salt.s5;
w2 = (w2<<32)|((ulong2)salt.s4);
w3 = (ulong2)salt.s7;
w3 = (w3<<32)|((ulong2)salt.s6);
w4 = (ulong2)salt.s9;
w4 = (w4<<32)|((ulong2)salt.s8);
w5 = (ulong2)salt.sB;
w5 = (w5<<32)|((ulong2)salt.sA);
w6 = (ulong2)salt.sD;
w6 = (w6<<32)|((ulong2)salt.sC);
w7 = (ulong2)salt.sF;
w7 = (w7<<32)|((ulong2)salt.sE);
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);


K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
K0=A=IPA;
K1=B=IPB;
K2=C=IPC;
K3=D=IPD;
K4=E=IPE;
K5=F=IPF;
K6=G=IPG;
K7=H=IPH;

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^IPA;ttb=B^IPB;ttc=C^IPC;ttd=D^IPD;tte=E^IPE;ttf=F^IPF;ttg=G^IPG;tth=H^IPH;


t1=(uint2)(str.sC+1);
Endian_Reverse32(t1);
w0=0x80;
w0=(w0<<32)|(ulong2)(t1.x,t1.y);
Endian_Reverse64(w0);
w1=w2=w3=w4=w5=w6=(ulong2)0;
SIZE=(ulong2)(64+64+4)<<3;


K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;




// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
K0=A=OPA;
K1=B=OPB;
K2=C=OPC;
K3=D=OPD;
K4=E=OPE;
K5=F=OPF;
K6=G=OPG;
K7=H=OPH;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^OPA;ttb=B^OPB;ttc=C^OPC;ttd=D^OPD;tte=E^OPE;ttf=F^OPF;ttg=G^OPG;tth=H^OPH;


w0=(ulong2)0x8000000000000000L;
w1=w2=w3=w4=w5=w6=(ulong2)0;
SIZE=(ulong2)((64+64)<<3);

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;


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
void pbkdf3( __global ulong2 *dst,  __global ulong2 *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 SIZE;  
uint ib,ic,id,i;  
uint2 a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
ulong2 w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
ulong2 A,B,C,D,E,F,G,H,T1;
ulong2 IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong2 OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong2 TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
ulong2 tta,ttb,ttc,ttd,tte,ttf,ttg,tth;
ulong2 L0,L1,L2,L3,L4,L5,L6,L7;
ulong2 K0,K1,K2,K3,K4,K5,K6,K7;
__local ulong C0[256];


C0[get_local_id(0)]=CC0[get_local_id(0)];
C0[get_local_id(0)+64]=CC0[get_local_id(0)+64];
C0[get_local_id(0)+128]=CC0[get_local_id(0)+128];
C0[get_local_id(0)+192]=CC0[get_local_id(0)+192];
barrier(CLK_LOCAL_MEM_FENCE);


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

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
K0=A=IPA;
K1=B=IPB;
K2=C=IPC;
K3=D=IPD;
K4=E=IPE;
K5=F=IPF;
K6=G=IPG;
K7=H=IPH;

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^IPA;ttb=B^IPB;ttc=C^IPC;ttd=D^IPD;tte=E^IPE;ttf=F^IPF;ttg=G^IPG;tth=H^IPH;

w0=(ulong2)0x8000000000000000L;
SIZE=(ulong2)(64+64)<<3;
w1=w2=w3=w4=w5=w6=(ulong2)0;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;



// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
K0=A=OPA;
K1=B=OPB;
K2=C=OPC;
K3=D=OPD;
K4=E=OPE;
K5=F=OPF;
K6=G=OPG;
K7=H=OPH;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^OPA;ttb=B^OPB;ttc=C^OPC;ttd=D^OPD;tte=E^OPE;ttf=F^OPF;ttg=G^OPG;tth=H^OPH;


w0=(ulong2)0x8000000000000000L;
SIZE=(ulong2)(64+64)<<3;
w1=w2=w3=w4=w5=w6=(ulong2)0;


K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;


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
void final3( __global ulong *dst,  __global ulong2 *input, __global ulong2 *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong2 TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,TTTF,TTTG,TTTH,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*8+0];
TTTB=input1[get_global_id(0)*2*8+1];
TTTC=input1[get_global_id(0)*2*8+2];
TTTD=input1[get_global_id(0)*2*8+3];
TTTE=input1[get_global_id(0)*2*8+4];
TTTF=input1[get_global_id(0)*2*8+5];
TTTG=input1[get_global_id(0)*2*8+6];
TTTH=input1[get_global_id(0)*2*8+7];

Endian_Reverse64(TTTA);
Endian_Reverse64(TTTB);
Endian_Reverse64(TTTC);
Endian_Reverse64(TTTD);
Endian_Reverse64(TTTE);
Endian_Reverse64(TTTF);
Endian_Reverse64(TTTG);
Endian_Reverse64(TTTH);


dst[(get_global_id(0)*50)+(str.sC)*8]=TTTA.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+1]=TTTB.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+2]=TTTC.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+3]=TTTD.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+4]=TTTE.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+5]=TTTF.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+6]=TTTG.s0;
dst[(get_global_id(0)*50)+(str.sC)*8+7]=TTTH.s0;

dst[(get_global_id(0)*50)+(str.sC)*8+25]=TTTA.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+1+25]=TTTB.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+2+25]=TTTC.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+3+25]=TTTD.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+4+25]=TTTE.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+5+25]=TTTF.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+6+25]=TTTG.s1;
dst[(get_global_id(0)*50)+(str.sC)*8+7+25]=TTTH.s1;

}





#else

// RIPEMD-160 macros

#define F(x, y, z) ((x) ^ (y) ^ (z))
#define G(x, y, z) (bitselect((z),(y),(x)))
#define H(x, y, z) (((x) | ~(y)) ^ (z))
#define I(x, y, z) (bitselect((y),(x),(z)))
#define J(x, y, z) ((x) ^ ((y) | ~(z)))
#define rotate1(a,b) ((a<<b)+((a>>(32-b))))
#define FF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint)(0x5a827999);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint)(0x6ed9eba1);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define II(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint)(0x8f1bbcdc);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0xa953fd4e);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define FFF(a, b, c, d, e, u, s) (a) += F((b), (c), (d)) + (u); (a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define GGG(a, b, c, d, e, u, s) (a) += G((b), (c), (d)) + (u) + (uint)(0x7a6d76e9);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define HHH(a, b, c, d, e, u, s) (a) += H((b), (c), (d)) + (u) + (uint)(0x6d703ef3);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define III(a, b, c, d, e, u, s) (a) += I((b), (c), (d)) + (u) + (uint)(0x5c4dd124);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
// Driver bug, nice!
#define JJJ1(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0x50a28be6);(a) = rotate1((a), (s)) + (e);(c) = rotate((c), 10U);
#define JJJ(a, b, c, d, e, u, s) (a) += J((b), (c), (d)) + (u) + (uint)(0x50a28be6);(a) = rotate((a), (s)) + (e);(c) = rotate((c), 10U);
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define BYTE_ADD(x,y) ( ((x+y)&(uint)255) | ((((x>>(uint)8)+(y>>(uint)8))&(uint)255)<<8) | ((((x>>(uint)16)+(y>>(uint)16))&(uint)255)<<(uint)16) |((((x>>(uint)24)+(y>>(uint)24))&(uint)255)<<(uint)24)  )


// SHA-512 macros

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


// Whirlpool macros

__constant ulong CC0[256] = {
0x18186018c07830d8L, 0x23238c2305af4626L, 0xc6c63fc67ef991b8L, 0xe8e887e8136fcdfbL, 
0x878726874ca113cbL, 0xb8b8dab8a9626d11L, 0x101040108050209L, 0x4f4f214f426e9e0dL, 
0x3636d836adee6c9bL, 0xa6a6a2a6590451ffL, 0xd2d26fd2debdb90cL, 0xf5f5f3f5fb06f70eL, 
0x7979f979ef80f296L, 0x6f6fa16f5fcede30L, 0x91917e91fcef3f6dL, 0x52525552aa07a4f8L, 
0x60609d6027fdc047L, 0xbcbccabc89766535L, 0x9b9b569baccd2b37L, 0x8e8e028e048c018aL, 
0xa3a3b6a371155bd2L, 0xc0c300c603c186cL, 0x7b7bf17bff8af684L, 0x3535d435b5e16a80L, 
0x1d1d741de8693af5L, 0xe0e0a7e05347ddb3L, 0xd7d77bd7f6acb321L, 0xc2c22fc25eed999cL, 
0x2e2eb82e6d965c43L, 0x4b4b314b627a9629L, 0xfefedffea321e15dL, 0x575741578216aed5L, 
0x15155415a8412abdL, 0x7777c1779fb6eee8L, 0x3737dc37a5eb6e92L, 0xe5e5b3e57b56d79eL, 
0x9f9f469f8cd92313L, 0xf0f0e7f0d317fd23L, 0x4a4a354a6a7f9420L, 0xdada4fda9e95a944L, 
0x58587d58fa25b0a2L, 0xc9c903c906ca8fcfL, 0x2929a429558d527cL, 0xa0a280a5022145aL, 
0xb1b1feb1e14f7f50L, 0xa0a0baa0691a5dc9L, 0x6b6bb16b7fdad614L, 0x85852e855cab17d9L, 
0xbdbdcebd8173673cL, 0x5d5d695dd234ba8fL, 0x1010401080502090L, 0xf4f4f7f4f303f507L, 
0xcbcb0bcb16c08bddL, 0x3e3ef83eedc67cd3L, 0x505140528110a2dL, 0x676781671fe6ce78L, 
0xe4e4b7e47353d597L, 0x27279c2725bb4e02L, 0x4141194132588273L, 0x8b8b168b2c9d0ba7L, 
0xa7a7a6a7510153f6L, 0x7d7de97dcf94fab2L, 0x95956e95dcfb3749L, 0xd8d847d88e9fad56L, 
0xfbfbcbfb8b30eb70L, 0xeeee9fee2371c1cdL, 0x7c7ced7cc791f8bbL, 0x6666856617e3cc71L, 
0xdddd53dda68ea77bL, 0x17175c17b84b2eafL, 0x4747014702468e45L, 0x9e9e429e84dc211aL, 
0xcaca0fca1ec589d4L, 0x2d2db42d75995a58L, 0xbfbfc6bf9179632eL, 0x7071c07381b0e3fL, 
0xadad8ead012347acL, 0x5a5a755aea2fb4b0L, 0x838336836cb51befL, 0x3333cc3385ff66b6L, 
0x636391633ff2c65cL, 0x2020802100a0412L, 0xaaaa92aa39384993L, 0x7171d971afa8e2deL, 
0xc8c807c80ecf8dc6L, 0x19196419c87d32d1L, 0x494939497270923bL, 0xd9d943d9869aaf5fL, 
0xf2f2eff2c31df931L, 0xe3e3abe34b48dba8L, 0x5b5b715be22ab6b9L, 0x88881a8834920dbcL, 
0x9a9a529aa4c8293eL, 0x262698262dbe4c0bL, 0x3232c8328dfa64bfL, 0xb0b0fab0e94a7d59L, 
0xe9e983e91b6acff2L, 0xf0f3c0f78331e77L, 0xd5d573d5e6a6b733L, 0x80803a8074ba1df4L, 
0xbebec2be997c6127L, 0xcdcd13cd26de87ebL, 0x3434d034bde46889L, 0x48483d487a759032L, 
0xffffdbffab24e354L, 0x7a7af57af78ff48dL, 0x90907a90f4ea3d64L, 0x5f5f615fc23ebe9dL, 
0x202080201da0403dL, 0x6868bd6867d5d00fL, 0x1a1a681ad07234caL, 0xaeae82ae192c41b7L, 
0xb4b4eab4c95e757dL, 0x54544d549a19a8ceL, 0x93937693ece53b7fL, 0x222288220daa442fL, 
0x64648d6407e9c863L, 0xf1f1e3f1db12ff2aL, 0x7373d173bfa2e6ccL, 0x12124812905a2482L, 
0x40401d403a5d807aL, 0x808200840281048L, 0xc3c32bc356e89b95L, 0xecec97ec337bc5dfL, 
0xdbdb4bdb9690ab4dL, 0xa1a1bea1611f5fc0L, 0x8d8d0e8d1c830791L, 0x3d3df43df5c97ac8L, 
0x97976697ccf1335bL, 0x0L, 0xcfcf1bcf36d483f9L, 0x2b2bac2b4587566eL, 
0x7676c57697b3ece1L, 0x8282328264b019e6L, 0xd6d67fd6fea9b128L, 0x1b1b6c1bd87736c3L, 
0xb5b5eeb5c15b7774L, 0xafaf86af112943beL, 0x6a6ab56a77dfd41dL, 0x50505d50ba0da0eaL, 
0x45450945124c8a57L, 0xf3f3ebf3cb18fb38L, 0x3030c0309df060adL, 0xefef9bef2b74c3c4L, 
0x3f3ffc3fe5c37edaL, 0x55554955921caac7L, 0xa2a2b2a2791059dbL, 0xeaea8fea0365c9e9L, 
0x656589650fecca6aL, 0xbabad2bab9686903L, 0x2f2fbc2f65935e4aL, 0xc0c027c04ee79d8eL, 
0xdede5fdebe81a160L, 0x1c1c701ce06c38fcL, 0xfdfdd3fdbb2ee746L, 0x4d4d294d52649a1fL, 
0x92927292e4e03976L, 0x7575c9758fbceafaL, 0x6061806301e0c36L, 0x8a8a128a249809aeL, 
0xb2b2f2b2f940794bL, 0xe6e6bfe66359d185L, 0xe0e380e70361c7eL, 0x1f1f7c1ff8633ee7L, 
0x6262956237f7c455L, 0xd4d477d4eea3b53aL, 0xa8a89aa829324d81L, 0x96966296c4f43152L, 
0xf9f9c3f99b3aef62L, 0xc5c533c566f697a3L, 0x2525942535b14a10L, 0x59597959f220b2abL, 
0x84842a8454ae15d0L, 0x7272d572b7a7e4c5L, 0x3939e439d5dd72ecL, 0x4c4c2d4c5a619816L, 
0x5e5e655eca3bbc94L, 0x7878fd78e785f09fL, 0x3838e038ddd870e5L, 0x8c8c0a8c14860598L, 
0xd1d163d1c6b2bf17L, 0xa5a5aea5410b57e4L, 0xe2e2afe2434dd9a1L, 0x616199612ff8c24eL, 
0xb3b3f6b3f1457b42L, 0x2121842115a54234L, 0x9c9c4a9c94d62508L, 0x1e1e781ef0663ceeL, 
0x4343114322528661L, 0xc7c73bc776fc93b1L, 0xfcfcd7fcb32be54fL, 0x404100420140824L, 
0x51515951b208a2e3L, 0x99995e99bcc72f25L, 0x6d6da96d4fc4da22L, 0xd0d340d68391a65L, 
0xfafacffa8335e979L, 0xdfdf5bdfb684a369L, 0x7e7ee57ed79bfca9L, 0x242490243db44819L, 
0x3b3bec3bc5d776feL, 0xabab96ab313d4b9aL, 0xcece1fce3ed181f0L, 0x1111441188552299L, 
0x8f8f068f0c890383L, 0x4e4e254e4a6b9c04L, 0xb7b7e6b7d1517366L, 0xebeb8beb0b60cbe0L, 
0x3c3cf03cfdcc78c1L, 0x81813e817cbf1ffdL, 0x94946a94d4fe3540L, 0xf7f7fbf7eb0cf31cL,
0xb9b9deb9a1676f18L, 0x13134c13985f268bL, 0x2c2cb02c7d9c5851L, 0xd3d36bd3d6b8bb05L, 
0xe7e7bbe76b5cd38cL, 0x6e6ea56e57cbdc39L, 0xc4c437c46ef395aaL, 0x3030c03180f061bL, 
0x565645568a13acdcL, 0x44440d441a49885eL, 0x7f7fe17fdf9efea0L, 0xa9a99ea921374f88L, 
0x2a2aa82a4d825467L, 0xbbbbd6bbb16d6b0aL, 0xc1c123c146e29f87L, 0x53535153a202a6f1L, 
0xdcdc57dcae8ba572L, 0xb0b2c0b58271653L, 0x9d9d4e9d9cd32701L, 0x6c6cad6c47c1d82bL, 
0x3131c43195f562a4L, 0x7474cd7487b9e8f3L, 0xf6f6fff6e309f115L, 0x464605460a438c4cL, 
0xacac8aac092645a5L, 0x89891e893c970fb5L, 0x14145014a04428b4L, 0xe1e1a3e15b42dfbaL, 
0x16165816b04e2ca6L, 0x3a3ae83acdd274f7L, 0x6969b9696fd0d206L, 0x9092409482d1241L, 
0x7070dd70a7ade0d7L, 0xb6b6e2b6d954716fL, 0xd0d067d0ceb7bd1eL, 0xeded93ed3b7ec7d6L, 
0xcccc17cc2edb85e2L, 0x424215422a578468L, 0x98985a98b4c22d2cL, 0xa4a4aaa4490e55edL, 
0x2828a0285d885075L, 0x5c5c6d5cda31b886L, 0xf8f8c7f8933fed6bL, 0x8686228644a411c2L
};

__constant ulong rc[10] = {
    (0x1823c6e887b8014fL),
    (0x36a6d2f5796f9152L),
    (0x60bc9b8ea30c7b35L),
    (0x1de0d7c22e4bfe57L),
    (0x157737e59ff04adaL),
    (0x58c9290ab1a06b85L),
    (0xbd5d10f4cb3e0567L),
    (0xe427418ba77d95d8L),
    (0xfbee7c66dd17479eL),
    (0xca2dbf07ad5a8333L),
};


#define ROTR(x,b)  (((x) >> (b)) | ((x) << (64 - (b))))


#define WH_L(a) \
L0 = C0[(K0 >> 56)&255] ^ \
     ROTR(C0[(K7 >> 48)&0xff],8) ^ \
     ROTR(C0[(K6 >> 40)&0xff],16) ^ \
     ROTR(C0[(K5 >> 32)&0xff],24) ^ \
     ROTR(C0[(K4 >> 24)&0xff],32) ^ \
     ROTR(C0[(K3 >> 16)&0xff],40) ^ \
     ROTR(C0[(K2 >>  8)&0xff],48) ^ \
     ROTR(C0[(K1) &0xff],56) ^ (a); \
L1 = C0[(K1 >> 56)&255] ^ \
     ROTR(C0[(K0 >> 48)&0xff],8) ^ \
     ROTR(C0[(K7 >> 40)&0xff],16) ^ \
     ROTR(C0[(K6 >> 32)&0xff],24) ^ \
     ROTR(C0[(K5 >> 24)&0xff],32) ^ \
     ROTR(C0[(K4 >> 16)&0xff],40) ^ \
     ROTR(C0[(K3 >>  8)&0xff],48) ^ \
     ROTR(C0[(K2) &0xff],56); \
L2 = C0[(K2 >> 56)&255] ^ \
     ROTR(C0[(K1 >> 48)&0xff],8) ^ \
     ROTR(C0[(K0 >> 40)&0xff],16) ^ \
     ROTR(C0[(K7 >> 32)&0xff],24) ^ \
     ROTR(C0[(K6 >> 24)&0xff],32) ^ \
     ROTR(C0[(K5 >> 16)&0xff],40) ^ \
     ROTR(C0[(K4 >>  8)&0xff],48) ^ \
     ROTR(C0[(K3) &0xff],56); \
L3 = C0[(K3 >> 56)&255] ^ \
     ROTR(C0[(K2 >> 48)&0xff],8) ^ \
     ROTR(C0[(K1 >> 40)&0xff],16) ^ \
     ROTR(C0[(K0 >> 32)&0xff],24) ^ \
     ROTR(C0[(K7 >> 24)&0xff],32) ^ \
     ROTR(C0[(K6 >> 16)&0xff],40) ^ \
     ROTR(C0[(K5 >>  8)&0xff],48) ^ \
     ROTR(C0[(K4) &0xff],56); \
L4 = C0[(K4 >> 56)&255] ^ \
     ROTR(C0[(K3 >> 48)&0xff],8) ^ \
     ROTR(C0[(K2 >> 40)&0xff],16) ^ \
     ROTR(C0[(K1 >> 32)&0xff],24) ^ \
     ROTR(C0[(K0 >> 24)&0xff],32) ^ \
     ROTR(C0[(K7 >> 16)&0xff],40) ^ \
     ROTR(C0[(K6 >>  8)&0xff],48) ^ \
     ROTR(C0[(K5) &0xff],56); \
L5 = C0[(K5 >> 56)&255] ^ \
     ROTR(C0[(K4 >> 48)&0xff],8) ^ \
     ROTR(C0[(K3 >> 40)&0xff],16) ^ \
     ROTR(C0[(K2 >> 32)&0xff],24) ^ \
     ROTR(C0[(K1 >> 24)&0xff],32) ^ \
     ROTR(C0[(K0 >> 16)&0xff],40) ^ \
     ROTR(C0[(K7 >>  8)&0xff],48) ^ \
     ROTR(C0[(K6) &0xff],56); \
L6 = C0[(K6 >> 56)&255] ^ \
     ROTR(C0[(K5 >> 48)&0xff],8) ^ \
     ROTR(C0[(K4 >> 40)&0xff],16) ^ \
     ROTR(C0[(K3 >> 32)&0xff],24) ^ \
     ROTR(C0[(K2 >> 24)&0xff],32) ^ \
     ROTR(C0[(K1 >> 16)&0xff],40) ^ \
     ROTR(C0[(K0 >>  8)&0xff],48) ^ \
     ROTR(C0[(K7) &0xff],56); \
L7 = C0[(K7 >> 56)&255] ^ \
     ROTR(C0[(K6 >> 48)&0xff],8) ^ \
     ROTR(C0[(K5 >> 40)&0xff],16) ^ \
     ROTR(C0[(K4 >> 32)&0xff],24) ^ \
     ROTR(C0[(K3 >> 24)&0xff],32) ^ \
     ROTR(C0[(K2 >> 16)&0xff],40) ^ \
     ROTR(C0[(K1 >>  8)&0xff],48) ^ \
     ROTR(C0[(K0) &0xff],56); 

#define WH_R() \
L0 = C0[(A >> 56)&255] ^ \
     ROTR(C0[(H >> 48)&0xff],8) ^ \
     ROTR(C0[(G >> 40)&0xff],16) ^ \
     ROTR(C0[(F >> 32)&0xff],24) ^ \
     ROTR(C0[(E >> 24)&0xff],32) ^ \
     ROTR(C0[(D >> 16)&0xff],40) ^ \
     ROTR(C0[(C >>  8)&0xff],48) ^ \
     ROTR(C0[(B) &0xff],56) ^ K0; \
L1 = C0[(B >> 56)&255] ^ \
     ROTR(C0[(A >> 48)&0xff],8) ^ \
     ROTR(C0[(H >> 40)&0xff],16) ^ \
     ROTR(C0[(G >> 32)&0xff],24) ^ \
     ROTR(C0[(F >> 24)&0xff],32) ^ \
     ROTR(C0[(E >> 16)&0xff],40) ^ \
     ROTR(C0[(D >>  8)&0xff],48) ^ \
     ROTR(C0[(C) &0xff],56) ^ K1; \
L2 = C0[(C >> 56)&255] ^ \
     ROTR(C0[(B >> 48)&0xff],8) ^ \
     ROTR(C0[(A >> 40)&0xff],16) ^ \
     ROTR(C0[(H >> 32)&0xff],24) ^ \
     ROTR(C0[(G >> 24)&0xff],32) ^ \
     ROTR(C0[(F >> 16)&0xff],40) ^ \
     ROTR(C0[(E >>  8)&0xff],48) ^ \
     ROTR(C0[(D) &0xff],56) ^ K2; \
L3 = C0[(D >> 56)&255] ^ \
     ROTR(C0[(C >> 48)&0xff],8) ^ \
     ROTR(C0[(B >> 40)&0xff],16) ^ \
     ROTR(C0[(A >> 32)&0xff],24) ^ \
     ROTR(C0[(H >> 24)&0xff],32) ^ \
     ROTR(C0[(G >> 16)&0xff],40) ^ \
     ROTR(C0[(F >>  8)&0xff],48) ^ \
     ROTR(C0[(E) &0xff],56) ^ K3; \
L4 = C0[(E >> 56)&255] ^ \
     ROTR(C0[(D >> 48)&0xff],8) ^ \
     ROTR(C0[(C >> 40)&0xff],16) ^ \
     ROTR(C0[(B >> 32)&0xff],24) ^ \
     ROTR(C0[(A >> 24)&0xff],32) ^ \
     ROTR(C0[(H >> 16)&0xff],40) ^ \
     ROTR(C0[(G >>  8)&0xff],48) ^ \
     ROTR(C0[(F) &0xff],56) ^ K4; \
L5 = C0[(F >> 56)&255] ^ \
     ROTR(C0[(E >> 48)&0xff],8) ^ \
     ROTR(C0[(D >> 40)&0xff],16) ^ \
     ROTR(C0[(C >> 32)&0xff],24) ^ \
     ROTR(C0[(B >> 24)&0xff],32) ^ \
     ROTR(C0[(A >> 16)&0xff],40) ^ \
     ROTR(C0[(H >>  8)&0xff],48) ^ \
     ROTR(C0[(G) &0xff],56) ^ K5; \
L6 = C0[(G >> 56)&255] ^ \
     ROTR(C0[(F >> 48)&0xff],8) ^ \
     ROTR(C0[(E >> 40)&0xff],16) ^ \
     ROTR(C0[(D >> 32)&0xff],24) ^ \
     ROTR(C0[(C >> 24)&0xff],32) ^ \
     ROTR(C0[(B >> 16)&0xff],40) ^ \
     ROTR(C0[(A >>  8)&0xff],48) ^ \
     ROTR(C0[(H) &0xff],56) ^ K6; \
L7 = C0[(H >> 56)&255] ^ \
     ROTR(C0[(G >> 48)&0xff],8) ^ \
     ROTR(C0[(F >> 40)&0xff],16) ^ \
     ROTR(C0[(E >> 32)&0xff],24) ^ \
     ROTR(C0[(D >> 24)&0xff],32) ^ \
     ROTR(C0[(C >> 16)&0xff],40) ^ \
     ROTR(C0[(B >>  8)&0xff],48) ^ \
     ROTR(C0[(A) &0xff],56) ^ K7; 

#define WHIRLPOOL_ROUND(a) \
    WH_L((a)); \
    K0=L0;K1=L1;K2=L2;K3=L3;K4=L4;K5=L5;K6=L6;K7=L7; \
    WH_R(); \
    A=L0;B=L1;C=L2;D=L3;E=L4;F=L5;G=L6;H=L7; \


// This is the prepare function for RIPEMD-160
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare1( __global uint *dst,  __global uint *input, __global uint *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint SIZE;  
uint ib,ic,id;  
uint ta,tb,tc,td,te,tf,tg,th, tmp1, tmp2,l; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w15;
uint yl,yr,zl,zr,wl,wr;
uint A,B,C,D,E;
uint aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;
uint IPA,IPB,IPC,IPD,IPE;
uint OPA,OPB,OPC,OPD,OPE;
uint TTA,TTB,TTC,TTD,TTE;

TTA=TTB=TTC=TTD=TTE=(uint)0;


ta=input[get_global_id(0)*8];
tb=input[get_global_id(0)*8+1];
tc=input[get_global_id(0)*8+2];
td=input[get_global_id(0)*8+3];
te=input[get_global_id(0)*8+4];
tf=input[get_global_id(0)*8+5];
tg=input[get_global_id(0)*8+6];
th=input[get_global_id(0)*8+7];


ta = BYTE_ADD(ta,(uint)salt2.s0);
tb = BYTE_ADD(tb,(uint)salt2.s1);
tc = BYTE_ADD(tc,(uint)salt2.s2);
td = BYTE_ADD(td,(uint)salt2.s3);
te = BYTE_ADD(te,(uint)salt2.s4);
tf = BYTE_ADD(tf,(uint)salt2.s5);
tg = BYTE_ADD(tg,(uint)salt2.s6);
th = BYTE_ADD(th,(uint)salt2.s7);


// Initial HMAC (for PBKDF2)

// Calculate sha1(ipad^key)

w0 = (uint)0x36363636 ^ ta;
w1 = (uint)0x36363636 ^ tb;
w2 = (uint)0x36363636 ^ tc;
w3 = (uint)0x36363636 ^ td;
w4 = (uint)0x36363636 ^ te;
w5 = (uint)0x36363636 ^ tf;
w6 = (uint)0x36363636 ^ tg;
w7 = (uint)0x36363636 ^ th;
w8 = (uint)0x36363636 ^ (uint)salt2.s8;
w9 = (uint)0x36363636 ^ (uint)salt2.s9;
w10 = (uint)0x36363636 ^ (uint)salt2.sA;
w11 = (uint)0x36363636 ^ (uint)salt2.sB;
w12 = (uint)0x36363636 ^ (uint)salt2.sC;
w13 = (uint)0x36363636 ^ (uint)salt2.sD;
SIZE = (uint)0x36363636 ^ (uint)salt2.sE;
w15 = (uint)0x36363636 ^ (uint)salt2.sF;


aa=(uint)0x67452301;
bb=(uint)0xefcdab89;
cc=(uint)0x98badcfe;
dd=(uint)0x10325476;
ee=(uint)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

IPA=coaa;IPB=cobb;IPC=cocc;IPD=codd;IPE=coee;



// Calculate sha1(opad^key)
w0 = (uint)0x5c5c5c5c ^ ta;
w1 = (uint)0x5c5c5c5c ^ tb;
w2 = (uint)0x5c5c5c5c ^ tc;
w3 = (uint)0x5c5c5c5c ^ td;
w4 = (uint)0x5c5c5c5c ^ te;
w5 = (uint)0x5c5c5c5c ^ tf;
w6 = (uint)0x5c5c5c5c ^ tg;
w7 = (uint)0x5c5c5c5c ^ th;
w8 = (uint)0x5c5c5c5c ^ (uint)salt2.s8;
w9 = (uint)0x5c5c5c5c ^ (uint)salt2.s9;
w10 = (uint)0x5c5c5c5c ^ (uint)salt2.sA;
w11 = (uint)0x5c5c5c5c ^ (uint)salt2.sB;
w12 = (uint)0x5c5c5c5c ^ (uint)salt2.sC;
w13 = (uint)0x5c5c5c5c ^ (uint)salt2.sD;
SIZE = (uint)0x5c5c5c5c ^ (uint)salt2.sE;
w15 = (uint)0x5c5c5c5c ^ (uint)salt2.sF;

aa=(uint)0x67452301;
bb=(uint)0xefcdab89;
cc=(uint)0x98badcfe;
dd=(uint)0x10325476;
ee=(uint)0xc3d2e1f0;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

OPA=coaa;OPB=cobb;OPC=cocc;OPD=codd;OPE=coee;



// calculate hash sum 1

w0=(uint)salt.s0;
w1=(uint)salt.s1;
w2=(uint)salt.s2;
w3=(uint)salt.s3;
w4=(uint)salt.s4;
w5=(uint)salt.s5;
w6=(uint)salt.s6;
w7=(uint)salt.s7;
w8=(uint)salt.s8;
w9=(uint)salt.s9;
w10=(uint)salt.sA;
w11=(uint)salt.sB;
w12=(uint)salt.sC;
w13=(uint)salt.sD;
SIZE=(uint)salt.sE;
w15=(uint)salt.sF;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;



SIZE=(uint)(64+64+4)<<3;
w0=(uint)str.sC+1;
Endian_Reverse32(w0);
w1=(uint)0x80;
w2=w3=w4=w5=w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint)0;

aa=A;
bb=B;
cc=C;
dd=D;
ee=E;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);
ta=coaa;tb=cobb;tc=cocc;td=codd;te=coee;



// calculate hash sum 2

w0=ta;
w1=tb;
w2=tc;
w3=td;
w4=te;
w5=(uint)0x80;
SIZE=(uint)((64+20)<<3);
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

TTA=coaa;TTB=cobb;TTC=cocc;TTD=codd;TTE=coee;


input1[get_global_id(0)*2*5+0]=IPA;
input1[get_global_id(0)*2*5+1]=IPB;
input1[get_global_id(0)*2*5+2]=IPC;
input1[get_global_id(0)*2*5+3]=IPD;
input1[get_global_id(0)*2*5+4]=IPE;
input1[get_global_id(0)*2*5+5]=OPA;
input1[get_global_id(0)*2*5+6]=OPB;
input1[get_global_id(0)*2*5+7]=OPC;
input1[get_global_id(0)*2*5+8]=OPD;
input1[get_global_id(0)*2*5+9]=OPE;

dst[get_global_id(0)*2*5+0]=TTA;
dst[get_global_id(0)*2*5+1]=TTB;
dst[get_global_id(0)*2*5+2]=TTC;
dst[get_global_id(0)*2*5+3]=TTD;
dst[get_global_id(0)*2*5+4]=TTE;
dst[get_global_id(0)*2*5+5]=TTA;
dst[get_global_id(0)*2*5+6]=TTB;
dst[get_global_id(0)*2*5+7]=TTC;
dst[get_global_id(0)*2*5+8]=TTD;
dst[get_global_id(0)*2*5+9]=TTE;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void pbkdf1( __global uint *dst,  __global uint *input, __global uint *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint SIZE;  
uint ib,ic,id;  
uint a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
uint w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
uint A,B,C,D,E;
uint IPA,IPB,IPC,IPD,IPE;
uint OPA,OPB,OPC,OPD,OPE;
uint TTA,TTB,TTC,TTD,TTE;
uint aa,aaa,coaa,bb,bbb,cobb,cc,ccc,cocc,dd,ddd,codd,ee,eee,coee;


TTA=dst[get_global_id(0)*2*5+0];
TTB=dst[get_global_id(0)*2*5+1];
TTC=dst[get_global_id(0)*2*5+2];
TTD=dst[get_global_id(0)*2*5+3];
TTE=dst[get_global_id(0)*2*5+4];
A=dst[get_global_id(0)*2*5+5];
B=dst[get_global_id(0)*2*5+6];
C=dst[get_global_id(0)*2*5+7];
D=dst[get_global_id(0)*2*5+8];
E=dst[get_global_id(0)*2*5+9];
IPA=input1[get_global_id(0)*2*5+0];
IPB=input1[get_global_id(0)*2*5+1];
IPC=input1[get_global_id(0)*2*5+2];
IPD=input1[get_global_id(0)*2*5+3];
IPE=input1[get_global_id(0)*2*5+4];
OPA=input1[get_global_id(0)*2*5+5];
OPB=input1[get_global_id(0)*2*5+6];
OPC=input1[get_global_id(0)*2*5+7];
OPD=input1[get_global_id(0)*2*5+8];
OPE=input1[get_global_id(0)*2*5+9];


// We now have the first HMAC. Iterate to find the rest
for (ic=str.sA;ic<str.sB;ic++)
{

// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint)0x80;
SIZE=(uint)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint)0;

aa=IPA;
bb=IPB;
cc=IPC;
dd=IPD;
ee=IPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


// calculate hash sum 1
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=(uint)0x80;
SIZE=(uint)(64+20)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w15=(uint)0;

aa=OPA;
bb=OPB;
cc=OPC;
dd=OPD;
ee=OPE;
aaa=aa;
bbb=bb;
ccc=cc;
ddd=dd;
eee=ee;
coaa=aa;
cobb=bb;
cocc=cc;
codd=dd;
coee=ee;

FF(aa, bb, cc, dd, ee, w0, (uint)11);
FF(ee, aa, bb, cc, dd, w1, (uint)14);
FF(dd, ee, aa, bb, cc, w2, (uint)15);
FF(cc, dd, ee, aa, bb, w3, (uint)12);
FF(bb, cc, dd, ee, aa, w4, (uint)5);
FF(aa, bb, cc, dd, ee, w5,  (uint)8);
FF(ee, aa, bb, cc, dd, w6,  (uint)7);
FF(dd, ee, aa, bb, cc, w7,  (uint)9);
FF(cc, dd, ee, aa, bb, w8, (uint)11);
FF(bb, cc, dd, ee, aa, w9, (uint)13);
FF(aa, bb, cc, dd, ee, w10, (uint)14);
FF(ee, aa, bb, cc, dd, w11, (uint)15);
FF(dd, ee, aa, bb, cc, w12,  (uint)6);
FF(cc, dd, ee, aa, bb, w13,  (uint)7);
FF(bb, cc, dd, ee, aa, SIZE,  (uint)9);
FF(aa, bb, cc, dd, ee, w15,  (uint)8);

GG(ee, aa, bb, cc, dd, w7,  (uint)7);
GG(dd, ee, aa, bb, cc, w4,  (uint)6);
GG(cc, dd, ee, aa, bb, w13,  (uint)8);
GG(bb, cc, dd, ee, aa, w1, (uint)13);
GG(aa, bb, cc, dd, ee, w10, (uint)11);
GG(ee, aa, bb, cc, dd, w6,  (uint)9);
GG(dd, ee, aa, bb, cc, w15,  (uint)7);
GG(cc, dd, ee, aa, bb, w3, (uint)15);
GG(bb, cc, dd, ee, aa, w12,  (uint)7);
GG(aa, bb, cc, dd, ee, w0, (uint)12);
GG(ee, aa, bb, cc, dd, w9, (uint)15);
GG(dd, ee, aa, bb, cc, w5,  (uint)9);
GG(cc, dd, ee, aa, bb, w2, (uint)11);
GG(bb, cc, dd, ee, aa, SIZE, (uint)7);
GG(aa, bb, cc, dd, ee, w11, (uint)13);
GG(ee, aa, bb, cc, dd, w8, (uint)12);

HH(dd, ee, aa, bb, cc, w3, (uint)11);
HH(cc, dd, ee, aa, bb, w10, (uint)13);
HH(bb, cc, dd, ee, aa, SIZE, (uint)6);
HH(aa, bb, cc, dd, ee, w4, (uint)7);
HH(ee, aa, bb, cc, dd, w9, (uint)14);
HH(dd, ee, aa, bb, cc, w15, (uint)9);
HH(cc, dd, ee, aa, bb, w8, (uint)13);
HH(bb, cc, dd, ee, aa, w1, (uint)15);
HH(aa, bb, cc, dd, ee, w2, (uint)14);
HH(ee, aa, bb, cc, dd, w7, (uint)8);
HH(dd, ee, aa, bb, cc, w0, (uint)13);
HH(cc, dd, ee, aa, bb, w6, (uint)6);
HH(bb, cc, dd, ee, aa, w13, (uint)5);
HH(aa, bb, cc, dd, ee, w11, (uint)12);
HH(ee, aa, bb, cc, dd, w5, (uint)7);
HH(dd, ee, aa, bb, cc, w12, (uint)5);

II(cc, dd, ee, aa, bb, w1, (uint)11);
II(bb, cc, dd, ee, aa, w9, (uint)12);
II(aa, bb, cc, dd, ee, w11, (uint)14);
II(ee, aa, bb, cc, dd, w10, (uint)15);
II(dd, ee, aa, bb, cc, w0, (uint)14);
II(cc, dd, ee, aa, bb, w8, (uint)15);
II(bb, cc, dd, ee, aa, w12, (uint)9);
II(aa, bb, cc, dd, ee, w4, (uint)8);
II(ee, aa, bb, cc, dd, w13, (uint)9);
II(dd, ee, aa, bb, cc, w3, (uint)14);
II(cc, dd, ee, aa, bb, w7, (uint)5);
II(bb, cc, dd, ee, aa, w15, (uint)6);
II(aa, bb, cc, dd, ee, SIZE, (uint)8);
II(ee, aa, bb, cc, dd, w5, (uint)6);
II(dd, ee, aa, bb, cc, w6, (uint)5);
II(cc, dd, ee, aa, bb, w2, (uint)12);

JJ(bb, cc, dd, ee, aa, w4, (uint)9);
JJ(aa, bb, cc, dd, ee, w0, (uint)15);
JJ(ee, aa, bb, cc, dd, w5, (uint)5);
JJ(dd, ee, aa, bb, cc, w9, (uint)11);
JJ(cc, dd, ee, aa, bb, w7, (uint)6);
JJ(bb, cc, dd, ee, aa, w12, (uint)8);
JJ(aa, bb, cc, dd, ee, w2, (uint)13);
JJ(ee, aa, bb, cc, dd, w10, (uint)12);
JJ(dd, ee, aa, bb, cc, SIZE, (uint)5);
JJ(cc, dd, ee, aa, bb, w1, (uint)12);
JJ(bb, cc, dd, ee, aa, w3, (uint)13);
JJ(aa, bb, cc, dd, ee, w8, (uint)14);
JJ(ee, aa, bb, cc, dd, w11, (uint)11);
JJ(dd, ee, aa, bb, cc, w6, (uint)8);
JJ(cc, dd, ee, aa, bb, w15, (uint)5);
JJ(bb, cc, dd, ee, aa, w13, (uint)6);

JJJ1(aaa, bbb, ccc, ddd, eee, w5, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, SIZE, (uint)9);
JJJ(ddd, eee, aaa, bbb, ccc, w7, (uint)9);
JJJ(ccc, ddd, eee, aaa, bbb, w0, (uint)11);
JJJ(bbb, ccc, ddd, eee, aaa, w9, (uint)13);
JJJ(aaa, bbb, ccc, ddd, eee, w2, (uint)15);
JJJ(eee, aaa, bbb, ccc, ddd, w11, (uint)15);
JJJ(ddd, eee, aaa, bbb, ccc, w4,  (uint)5);
JJJ(ccc, ddd, eee, aaa, bbb, w13, (uint)7);
JJJ(bbb, ccc, ddd, eee, aaa, w6,  (uint)7);
JJJ(aaa, bbb, ccc, ddd, eee, w15, (uint)8);
JJJ(eee, aaa, bbb, ccc, ddd, w8, (uint)11);
JJJ(ddd, eee, aaa, bbb, ccc, w1, (uint)14);
JJJ(ccc, ddd, eee, aaa, bbb, w10, (uint)14);
JJJ(bbb, ccc, ddd, eee, aaa, w3, (uint)12);
JJJ(aaa, bbb, ccc, ddd, eee, w12, (uint)6);

III(eee, aaa, bbb, ccc, ddd, w6, (uint)9);
III(ddd, eee, aaa, bbb, ccc, w11, (uint)13);
III(ccc, ddd, eee, aaa, bbb, w3, (uint)15);
III(bbb, ccc, ddd, eee, aaa, w7, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w0, (uint)12);
III(eee, aaa, bbb, ccc, ddd, w13, (uint)8);
III(ddd, eee, aaa, bbb, ccc, w5, (uint)9);
III(ccc, ddd, eee, aaa, bbb, w10, (uint)11);
III(bbb, ccc, ddd, eee, aaa, SIZE, (uint)7);
III(aaa, bbb, ccc, ddd, eee, w15, (uint)7);
III(eee, aaa, bbb, ccc, ddd, w8, (uint)12);
III(ddd, eee, aaa, bbb, ccc, w12, (uint)7);
III(ccc, ddd, eee, aaa, bbb, w4, (uint)6);
III(bbb, ccc, ddd, eee, aaa, w9, (uint)15);
III(aaa, bbb, ccc, ddd, eee, w1, (uint)13);
III(eee, aaa, bbb, ccc, ddd, w2, (uint)11);

HHH(ddd, eee, aaa, bbb, ccc, w15, (uint)9);
HHH(ccc, ddd, eee, aaa, bbb, w5, (uint)7);
HHH(bbb, ccc, ddd, eee, aaa, w1, (uint)15);
HHH(aaa, bbb, ccc, ddd, eee, w3, (uint)11);
HHH(eee, aaa, bbb, ccc, ddd, w7, (uint)8);
HHH(ddd, eee, aaa, bbb, ccc, SIZE, (uint)6);
HHH(ccc, ddd, eee, aaa, bbb, w6, (uint)6);
HHH(bbb, ccc, ddd, eee, aaa, w9, (uint)14);
HHH(aaa, bbb, ccc, ddd, eee, w11, (uint)12);
HHH(eee, aaa, bbb, ccc, ddd, w8, (uint)13);
HHH(ddd, eee, aaa, bbb, ccc, w12, (uint)5);
HHH(ccc, ddd, eee, aaa, bbb, w2, (uint)14);
HHH(bbb, ccc, ddd, eee, aaa, w10, (uint)13);
HHH(aaa, bbb, ccc, ddd, eee, w0, (uint)13);
HHH(eee, aaa, bbb, ccc, ddd, w4, (uint)7);
HHH(ddd, eee, aaa, bbb, ccc, w13, (uint)5);

GGG(ccc, ddd, eee, aaa, bbb, w8, (uint)15);
GGG(bbb, ccc, ddd, eee, aaa, w6, (uint)5);
GGG(aaa, bbb, ccc, ddd, eee, w4, (uint)8);
GGG(eee, aaa, bbb, ccc, ddd, w1, (uint)11);
GGG(ddd, eee, aaa, bbb, ccc, w3, (uint)14);
GGG(ccc, ddd, eee, aaa, bbb, w11, (uint)14);
GGG(bbb, ccc, ddd, eee, aaa, w15, (uint)6);
GGG(aaa, bbb, ccc, ddd, eee, w0, (uint)14);
GGG(eee, aaa, bbb, ccc, ddd, w5, (uint)6);
GGG(ddd, eee, aaa, bbb, ccc, w12, (uint)9);
GGG(ccc, ddd, eee, aaa, bbb, w2, (uint)12);
GGG(bbb, ccc, ddd, eee, aaa, w13, (uint)9);
GGG(aaa, bbb, ccc, ddd, eee, w9, (uint)12);
GGG(eee, aaa, bbb, ccc, ddd, w7, (uint)5);
GGG(ddd, eee, aaa, bbb, ccc, w10, (uint)15);
GGG(ccc, ddd, eee, aaa, bbb, SIZE, (uint)8);

FFF(bbb, ccc, ddd, eee, aaa, w12, (uint)8);
FFF(aaa, bbb, ccc, ddd, eee, w15, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w10, (uint)12);
FFF(ddd, eee, aaa, bbb, ccc, w4, (uint)9);
FFF(ccc, ddd, eee, aaa, bbb, w1, (uint)12);
FFF(bbb, ccc, ddd, eee, aaa, w5, (uint)5);
FFF(aaa, bbb, ccc, ddd, eee, w8, (uint)14);
FFF(eee, aaa, bbb, ccc, ddd, w7, (uint)6);
FFF(ddd, eee, aaa, bbb, ccc, w6, (uint)8);
FFF(ccc, ddd, eee, aaa, bbb, w2, (uint)13);
FFF(bbb, ccc, ddd, eee, aaa, w13, (uint)6);
FFF(aaa, bbb, ccc, ddd, eee, SIZE, (uint)5);
FFF(eee, aaa, bbb, ccc, ddd, w0, (uint)15);
FFF(ddd, eee, aaa, bbb, ccc, w3, (uint)13);
FFF(ccc, ddd, eee, aaa, bbb, w9, (uint)11);
FFF(bbb, ccc, ddd, eee, aaa, w11, (uint)11);

tmp1 = (cobb + cc + ddd);
cobb = (cocc + dd + eee);
cocc = (codd + ee + aaa);
codd = (coee + aa + bbb);
coee = (coaa + bb + ccc);
coaa = (tmp1);

A=coaa;B=cobb;C=cocc;D=codd;E=coee;


TTA ^= A;
TTB ^= B;
TTC ^= C;
TTD ^= D;
TTE ^= E;

}

dst[get_global_id(0)*2*5+0]=TTA;
dst[get_global_id(0)*2*5+1]=TTB;
dst[get_global_id(0)*2*5+2]=TTC;
dst[get_global_id(0)*2*5+3]=TTD;
dst[get_global_id(0)*2*5+4]=TTE;
dst[get_global_id(0)*2*5+5]=A;
dst[get_global_id(0)*2*5+6]=B;
dst[get_global_id(0)*2*5+7]=C;
dst[get_global_id(0)*2*5+8]=D;
dst[get_global_id(0)*2*5+9]=E;
}


__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void final1( __global uint *dst,  __global uint *input, __global uint *input1, uint16 str, uint16 salt,uint16 salt2)
{
uint TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*5+0];
TTTB=input1[get_global_id(0)*2*5+1];
TTTC=input1[get_global_id(0)*2*5+2];
TTTD=input1[get_global_id(0)*2*5+3];
TTTE=input1[get_global_id(0)*2*5+4];


dst[(get_global_id(0)*50)+(str.sC)*5]=TTTA;
dst[(get_global_id(0)*50)+(str.sC)*5+1]=TTTB;
dst[(get_global_id(0)*50)+(str.sC)*5+2]=TTTC;
dst[(get_global_id(0)*50)+(str.sC)*5+3]=TTTD;
dst[(get_global_id(0)*50)+(str.sC)*5+4]=TTTE;
}




// This is the prepare function for SHA-512
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare2( __global ulong *dst,  __global uint *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
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

ta = BYTE_ADD(ta,(uint)salt2.s0);
tb = BYTE_ADD(tb,(uint)salt2.s1);
tc = BYTE_ADD(tc,(uint)salt2.s2);
td = BYTE_ADD(td,(uint)salt2.s3);
te = BYTE_ADD(te,(uint)salt2.s4);
tf = BYTE_ADD(tf,(uint)salt2.s5);
tg = BYTE_ADD(tg,(uint)salt2.s6);
th = BYTE_ADD(th,(uint)salt2.s7);


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
w4 = 0x36363636 ^ (ulong)salt2.s9;
w4 = (w4<<32)|(0x36363636 ^ salt2.s8);
w5 = 0x36363636 ^ (ulong)salt2.sB;
w5 = (w5<<32)|(0x36363636 ^ salt2.sA);
w6 = 0x36363636 ^ (ulong)salt2.sD;
w6 = (w6<<32)|(0x36363636 ^ salt2.sC);
w7 = 0x36363636 ^ (ulong)salt2.sF;
w7 = (w7<<32)|(0x36363636 ^ salt2.sE);
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
Endian_Reverse64(w4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
Endian_Reverse64(w5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
Endian_Reverse64(w6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
Endian_Reverse64(w7);
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
w4 = 0x5c5c5c5c ^ (ulong)salt2.s9;
w4 = (w4<<32)|(0x5c5c5c5c ^ salt2.s8);
w5 = 0x5c5c5c5c ^ (ulong)salt2.sB;
w5 = (w5<<32)|(0x5c5c5c5c ^ salt2.sA);
w6 = 0x5c5c5c5c ^ (ulong)salt2.sD;
w6 = (w6<<32)|(0x5c5c5c5c ^ salt2.sC);
w7 = 0x5c5c5c5c ^ (ulong)salt2.sF;
w7 = (w7<<32)|(0x5c5c5c5c ^ salt2.sE);
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
Endian_Reverse64(w4);
ROUND512_0_TO_15(E,F,G,H,A,B,C,D,AC5,w4);
Endian_Reverse64(w5);
ROUND512_0_TO_15(D,E,F,G,H,A,B,C,AC6,w5);
Endian_Reverse64(w6);
ROUND512_0_TO_15(C,D,E,F,G,H,A,B,AC7,w6);
Endian_Reverse64(w7);
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
t1=(uint)(str.sC+1);
Endian_Reverse32(t1);
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




w0=w1=w2=w3=w4=w5=w6=w7=w8=(ulong)0;

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
void pbkdf2( __global ulong *dst,  __global ulong *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
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
void final2( __global ulong *dst,  __global ulong *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,TTTF,TTTG,TTTH,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*8+0];
TTTB=input1[get_global_id(0)*2*8+1];
TTTC=input1[get_global_id(0)*2*8+2];
TTTD=input1[get_global_id(0)*2*8+3];
TTTE=input1[get_global_id(0)*2*8+4];
TTTF=input1[get_global_id(0)*2*8+5];
TTTG=input1[get_global_id(0)*2*8+6];
TTTH=input1[get_global_id(0)*2*8+7];

Endian_Reverse64(TTTA);
Endian_Reverse64(TTTB);
Endian_Reverse64(TTTC);
Endian_Reverse64(TTTD);
Endian_Reverse64(TTTE);
Endian_Reverse64(TTTF);
Endian_Reverse64(TTTG);
Endian_Reverse64(TTTH);


dst[(get_global_id(0)*25)+(str.sC)*8]=TTTA;
dst[(get_global_id(0)*25)+(str.sC)*8+1]=TTTB;
dst[(get_global_id(0)*25)+(str.sC)*8+2]=TTTC;
dst[(get_global_id(0)*25)+(str.sC)*8+3]=TTTD;
dst[(get_global_id(0)*25)+(str.sC)*8+4]=TTTE;
dst[(get_global_id(0)*25)+(str.sC)*8+5]=TTTF;
dst[(get_global_id(0)*25)+(str.sC)*8+6]=TTTG;
dst[(get_global_id(0)*25)+(str.sC)*8+7]=TTTH;

}



// This is the prepare function for SHA-512
__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare3( __global ulong *dst,  __global uint *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong SIZE;  
uint i;  
uint ta,tb,tc,td,te,tf,tg,th;
uint tmp1,tmp2,l,t1; 
ulong w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16;
ulong A,B,C,D,E,F,G,H,T1;
ulong IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
ulong tta,ttb,ttc,ttd,tte,ttf,ttg,tth;
ulong L0,L1,L2,L3,L4,L5,L6,L7;
ulong K0,K1,K2,K3,K4,K5,K6,K7;
__local ulong C0[256];


C0[get_local_id(0)]=CC0[get_local_id(0)];
C0[get_local_id(0)+64]=CC0[get_local_id(0)+64];
C0[get_local_id(0)+128]=CC0[get_local_id(0)+128];
C0[get_local_id(0)+192]=CC0[get_local_id(0)+192];
barrier(CLK_LOCAL_MEM_FENCE);

TTA=TTB=TTC=TTD=TTE=TTF=TTG=TTH=(ulong)0;

ta=input[get_global_id(0)*8];
tb=input[get_global_id(0)*8+1];
tc=input[get_global_id(0)*8+2];
td=input[get_global_id(0)*8+3];
te=input[get_global_id(0)*8+4];
tf=input[get_global_id(0)*8+5];
tg=input[get_global_id(0)*8+6];
th=input[get_global_id(0)*8+7];


ta = BYTE_ADD(ta,(uint)salt2.s0);
tb = BYTE_ADD(tb,(uint)salt2.s1);
tc = BYTE_ADD(tc,(uint)salt2.s2);
td = BYTE_ADD(td,(uint)salt2.s3);
te = BYTE_ADD(te,(uint)salt2.s4);
tf = BYTE_ADD(tf,(uint)salt2.s5);
tg = BYTE_ADD(tg,(uint)salt2.s6);
th = BYTE_ADD(th,(uint)salt2.s7);


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
w4 = 0x36363636 ^ (ulong)salt2.s9;
w4 = (w4<<32)|(0x36363636 ^ salt2.s8);
w5 = 0x36363636 ^ (ulong)salt2.sB;
w5 = (w5<<32)|(0x36363636 ^ salt2.sA);
w6 = 0x36363636 ^ (ulong)salt2.sD;
w6 = (w6<<32)|(0x36363636 ^ salt2.sC);
w7 = 0x36363636 ^ (ulong)salt2.sF;
w7 = (w7<<32)|(0x36363636 ^ salt2.sE);
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);


K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
A=w0;B=w1;C=w2;D=w3;E=w4=F=w5;G=w6;H=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

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
w4 = 0x5c5c5c5c ^ (ulong)salt2.s9;
w4 = (w4<<32)|(0x5c5c5c5c ^ salt2.s8);
w5 = 0x5c5c5c5c ^ (ulong)salt2.sB;
w5 = (w5<<32)|(0x5c5c5c5c ^ salt2.sA);
w6 = 0x5c5c5c5c ^ (ulong)salt2.sD;
w6 = (w6<<32)|(0x5c5c5c5c ^ salt2.sC);
w7 = 0x5c5c5c5c ^ (ulong)salt2.sF;
w7 = (w7<<32)|(0x5c5c5c5c ^ salt2.sE);
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
A=w0;B=w1;C=w2;D=w3;E=w4=F=w5;G=w6;H=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

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
Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);
Endian_Reverse64(w4);
Endian_Reverse64(w5);
Endian_Reverse64(w6);
Endian_Reverse64(w7);


K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
K0=A=IPA;
K1=B=IPB;
K2=C=IPC;
K3=D=IPD;
K4=E=IPE;
K5=F=IPF;
K6=G=IPG;
K7=H=IPH;

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^IPA;ttb=B^IPB;ttc=C^IPC;ttd=D^IPD;tte=E^IPE;ttf=F^IPF;ttg=G^IPG;tth=H^IPH;


t1=(uint)(str.sC+1);
Endian_Reverse32(t1);
w0=0x80;
w0=(w0<<32)|(ulong)(t1);
Endian_Reverse64(w0);
w1=w2=w3=w4=w5=w6=(ulong)0;
SIZE=(ulong)(64+64+4)<<3;


K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;




// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
K0=A=OPA;
K1=B=OPB;
K2=C=OPC;
K3=D=OPD;
K4=E=OPE;
K5=F=OPF;
K6=G=OPG;
K7=H=OPH;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^OPA;ttb=B^OPB;ttc=C^OPC;ttd=D^OPD;tte=E^OPE;ttf=F^OPF;ttg=G^OPG;tth=H^OPH;


w0=(ulong)0x8000000000000000L;
w1=w2=w3=w4=w5=w6=(ulong)0;
SIZE=(ulong)((64+64)<<3);

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;


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
void pbkdf3( __global ulong *dst,  __global ulong *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong SIZE;  
uint ib,ic,id,i;  
uint a,b,c,d,e,f,g,h, tmp1, tmp2,l; 
ulong w0, w1, w2, w3, w4, w5, w6, w7,w8,w9,w10,w11,w12,w13,w14,w16,w15;
ulong A,B,C,D,E,F,G,H,T1;
ulong IPA,IPB,IPC,IPD,IPE,IPF,IPG,IPH;
ulong OPA,OPB,OPC,OPD,OPE,OPF,OPG,OPH;
ulong TTA,TTB,TTC,TTD,TTE,TTF,TTG,TTH;
ulong tta,ttb,ttc,ttd,tte,ttf,ttg,tth;
ulong L0,L1,L2,L3,L4,L5,L6,L7;
ulong K0,K1,K2,K3,K4,K5,K6,K7;
__local ulong C0[256];


C0[get_local_id(0)]=CC0[get_local_id(0)];
C0[get_local_id(0)+64]=CC0[get_local_id(0)+64];
C0[get_local_id(0)+128]=CC0[get_local_id(0)+128];
C0[get_local_id(0)+192]=CC0[get_local_id(0)+192];
barrier(CLK_LOCAL_MEM_FENCE);
//Evade stupid GCN bug
TTA=C0[2];


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

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
K0=A=IPA;
K1=B=IPB;
K2=C=IPC;
K3=D=IPD;
K4=E=IPE;
K5=F=IPF;
K6=G=IPG;
K7=H=IPH;

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^IPA;ttb=B^IPB;ttc=C^IPC;ttd=D^IPD;tte=E^IPE;ttf=F^IPF;ttg=G^IPG;tth=H^IPH;

w0=(ulong)0x8000000000000000L;
SIZE=(ulong)(64+64)<<3;
w1=w2=w3=w4=w5=w6=(ulong)0;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;



// calculate hash sum 2
w0=A;
w1=B;
w2=C;
w3=D;
w4=E;
w5=F;
w6=G;
w7=H;

K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;
K0=A=OPA;
K1=B=OPB;
K2=C=OPC;
K3=D=OPD;
K4=E=OPE;
K5=F=OPF;
K6=G=OPG;
K7=H=OPH;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=w7;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0;
B^=w1;
C^=w2;
D^=w3;
E^=w4;
F^=w5;
G^=w6;
H^=w7;

tta=A^OPA;ttb=B^OPB;ttc=C^OPC;ttd=D^OPD;tte=E^OPE;ttf=F^OPF;ttg=G^OPG;tth=H^OPH;


w0=(ulong)0x8000000000000000L;
SIZE=(ulong)(64+64)<<3;
w1=w2=w3=w4=w5=w6=(ulong)0;


K0=K1=K2=K3=K4=K5=K6=K7=(ulong)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong)0;

K0=A=tta;
K1=B=ttb;
K2=C=ttc;
K3=D=ttd;
K4=E=tte;
K5=F=ttf;
K6=G=ttg;
K7=H=tth;

A^=w0;B^=w1;C^=w2;D^=w3;E^=w4;F^=w5;G^=w6;H^=SIZE;

for (i=0;i<10;i++)
{
WHIRLPOOL_ROUND(rc[i]);
}

A^=w0^tta;
B^=w1^ttb;
C^=w2^ttc;
D^=w3^ttd;
E^=w4^tte;
F^=w5^ttf;
G^=w6^ttg;
H^=SIZE^tth;


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
void final3( __global ulong *dst,  __global ulong *input, __global ulong *input1, uint16 str, uint16 salt,uint16 salt2)
{
ulong TTA,TTB,TTC,TTD,TTE,TTTA,TTTB,TTTC,TTTD,TTTE,TTTF,TTTG,TTTH,l,tmp1,tmp2;

TTTA=input1[get_global_id(0)*2*8+0];
TTTB=input1[get_global_id(0)*2*8+1];
TTTC=input1[get_global_id(0)*2*8+2];
TTTD=input1[get_global_id(0)*2*8+3];
TTTE=input1[get_global_id(0)*2*8+4];
TTTF=input1[get_global_id(0)*2*8+5];
TTTG=input1[get_global_id(0)*2*8+6];
TTTH=input1[get_global_id(0)*2*8+7];

Endian_Reverse64(TTTA);
Endian_Reverse64(TTTB);
Endian_Reverse64(TTTC);
Endian_Reverse64(TTTD);
Endian_Reverse64(TTTE);
Endian_Reverse64(TTTF);
Endian_Reverse64(TTTG);
Endian_Reverse64(TTTH);


dst[(get_global_id(0)*25)+(str.sC)*8]=TTTA;
dst[(get_global_id(0)*25)+(str.sC)*8+1]=TTTB;
dst[(get_global_id(0)*25)+(str.sC)*8+2]=TTTC;
dst[(get_global_id(0)*25)+(str.sC)*8+3]=TTTD;
dst[(get_global_id(0)*25)+(str.sC)*8+4]=TTTE;
dst[(get_global_id(0)*25)+(str.sC)*8+5]=TTTF;
dst[(get_global_id(0)*25)+(str.sC)*8+6]=TTTG;
dst[(get_global_id(0)*25)+(str.sC)*8+7]=TTTH;

}


#endif




