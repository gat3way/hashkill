#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    t1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(t1)); \
    ai1[elem+1] = (t1==0) ? 0 : ai2>>(32-t1);\
    }



#define Endian_Reverse64(a) { (a) = ((a) & 0x00000000000000FFL) << 56L | ((a) & 0x000000000000FF00L) << 40L | \
        		      ((a) & 0x0000000000FF0000L) << 24L | ((a) & 0x00000000FF000000L) << 8L | \
                	      ((a) & 0x000000FF00000000L) >> 8L | ((a) & 0x0000FF0000000000L) >> 24L | \
                    	      ((a) & 0x00FF000000000000L) >> 40L | ((a) & 0xFF00000000000000L) >> 56L; }

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

#define Endian_Reverse64(a) { (a) = ((a) & 0x00000000000000FFL) << 56L | ((a) & 0x000000000000FF00L) << 40L | \
                              ((a) & 0x0000000000FF0000L) << 24L | ((a) & 0x00000000FF000000L) << 8L | \
                              ((a) & 0x000000FF00000000L) >> 8L | ((a) & 0x0000FF0000000000L) >> 24L | \
                              ((a) & 0x00FF000000000000L) >> 40L | ((a) & 0xFF00000000000000L) >> 56L; }

#define ROTR(x,b)  (((x) >> (b)) | ((x) << (64 - (b))))




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
whirlpool( __global ulong4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *bitmaps, __global uint *found,  ulong4 singlehash,uint16 str) 
{
ulong2 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16,SIZE;
uint i,ib,ic,id;  
ulong2 A,B,C,D,E,F,G,H,K,l,tmp1,tmp2,temp,T1;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint x0,x1,x2,x3,x4,x5,x6,x7;
__local uint inpc[64][14];
ulong elem,t1,t2;
uint2 size;
ulong2 L0,L1,L2,L3,L4,L5,L6,L7;
ulong2 K0,K1,K2,K3,K4,K5,K6,K7;
__local ulong C0[256];

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


C0[get_local_id(0)]=CC0[get_local_id(0)];
C0[get_local_id(0)+64]=CC0[get_local_id(0)+64];
C0[get_local_id(0)+128]=CC0[get_local_id(0)+128];
C0[get_local_id(0)+192]=CC0[get_local_id(0)+192];
barrier(CLK_LOCAL_MEM_FENCE);


id=get_global_id(0);
size=(uint2)sizein[GGI];
x0 = inp[GGI*8+0];
x1 = inp[GGI*8+1];
x2 = inp[GGI*8+2];
x3 = inp[GGI*8+3];
x4 = inp[GGI*8+4];
x5 = inp[GGI*8+5];
x6 = inp[GGI*8+6];
x7 = inp[GGI*8+7];


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
SET_AB(inpc[GLI],str.s0,size.s0,0);
SET_AB(inpc[GLI],str.s1,size.s0+4,0);
SET_AB(inpc[GLI],str.s2,size.s0+8,0);
SET_AB(inpc[GLI],str.s3,size.s0+12,0);
SET_AB(inpc[GLI],0x80,(size.s0+str.sC),0);
w0.s0=(ulong)((inpc[GLI][0])|((ulong)inpc[GLI][1]<<32));
w1.s0=(ulong)((inpc[GLI][2])|((ulong)inpc[GLI][3]<<32));
w2.s0=(ulong)((inpc[GLI][4])|((ulong)inpc[GLI][5]<<32));
w3.s0=(ulong)((inpc[GLI][6])|((ulong)inpc[GLI][7]<<32));
size.s0 = (size.s0+str.sC)<<3;


inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;

SET_AB(inpc[GLI],str.s4,size.s1,0);
SET_AB(inpc[GLI],str.s5,size.s1+4,0);
SET_AB(inpc[GLI],str.s6,size.s1+8,0);
SET_AB(inpc[GLI],str.s7,size.s1+12,0);
SET_AB(inpc[GLI],0x80,(size.s1+str.sD),0);
w0.s1=(ulong)(inpc[GLI][0])|((ulong)inpc[GLI][1]<<32);
w1.s1=(ulong)(inpc[GLI][2])|((ulong)inpc[GLI][3]<<32);
w2.s1=(ulong)(inpc[GLI][4])|((ulong)inpc[GLI][5]<<32);
w3.s1=(ulong)(inpc[GLI][6])|((ulong)inpc[GLI][7]<<32);
size.s1 = (size.s1+str.sD)<<3;
SIZE.s0=size.s0;
SIZE.s1=size.s1;



w4=w5=w6=(ulong2)0;

Endian_Reverse64(w0);
Endian_Reverse64(w1);
Endian_Reverse64(w2);
Endian_Reverse64(w3);


K0=K1=K2=K3=K4=K5=K6=K7=(ulong2)0;
L0=L1=L2=L3=L4=L5=L6=L7=(ulong2)0;
A=w0;B=w1;C=w2;D=w3;E=w4=F=w5;G=w6;H=SIZE;


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
H^=SIZE;



Endian_Reverse64(A);
Endian_Reverse64(B);
Endian_Reverse64(C);
Endian_Reverse64(D);
Endian_Reverse64(E);
Endian_Reverse64(F);
Endian_Reverse64(G);
Endian_Reverse64(H);


#ifdef SINGLE_MODE
id=0;
if (all((ulong2)singlehash.x!=A)) return;
id=1;
#endif

#ifndef SINGLE_MODE
id=0;
b1=(uint)(A.s0&0xFFFFFFFF);b2=(uint)(A.s0>>32)&0xFFFFFFFF;b3=(uint)B.s0&0xFFFFFFFF;b4=(uint)(B.s0>>32)&0xFFFFFFFF;
b5=(singlehash.x >> (((A.s0>>32)&0xFFFFFFFF)&31))&1;
b6=(singlehash.y >> (((B.s0)&0xFFFFFFFF)&31))&1;
b7=(singlehash.z >> (((B.s0>>32)&0xFFFFFFFF)&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1)) id=1;
b1=(uint)(A.s1&0xFFFFFFFF);b2=(uint)(A.s1>>32)&0xFFFFFFFF;b3=(uint)B.s1&0xFFFFFFFF;b4=(uint)(B.s1>>32)&0xFFFFFFFF;
b5=(singlehash.x >> (((A.s1>>32)&0xFFFFFFFF)&31))&1;
b6=(singlehash.y >> (((B.s1)&0xFFFFFFFF)&31))&1;
b7=(singlehash.z >> (((B.s1>>32)&0xFFFFFFFF)&31))&1;
if (((b7) & (b5) & (b6)) && ((bitmaps[b1>>10]>>(b1&31))&1) && ((bitmaps[65535*8*8+(b2>>10)]>>(b2&31))&1) && ((bitmaps[(16*65535*8)+(b3>>10)]>>(b3&31))&1) && ((bitmaps[(24*65535*8)+(b4>>10)]>>(b4&31))&1)) id=1;
if (id==0) return;
#endif



found[0] = (uint)1;
found_ind[get_global_id(0)] = (uint)1;

dst[(get_global_id(0)*4)] = (ulong4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*4)+1] = (ulong4)(E.s0,F.s0,G.s0,H.s0);
dst[(get_global_id(0)*4)+2] = (ulong4)(A.s1,B.s1,C.s1,D.s1);  
dst[(get_global_id(0)*4)+3] = (ulong4)(E.s1,F.s1,G.s1,H.s1);
}



