#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
    }

#define ROTR(x,y) (rotate((uint)(x),(32-(y))))
#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }
#define lTe1(x) (ROTR(lTe[((x))],8U))
#define lTe2(x) (ROTR(lTe[((x))],16U))
#define lTe3(x) (ROTR(lTe[((x))],24U))
#define lTd1(x) (ROTR(lTd[((x))],8U))
#define lTd2(x) (ROTR(lTd[((x))],16U))
#define lTd3(x) (ROTR(lTd[((x))],24U))

#define Sl 8U
#define Sr 24U  
#define m 0x00FF00FFU
#define m2 0xFF00FF00U


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





#define AES192_INV_MIX { \
k0 = lTd[lTe1((k0 >> 24)) & 0xff] ^ lTd1(lTe1((k0 >> 16) & 0xff) & 0xff) ^ \
	lTd2(lTe1((k0 >> 8) & 0xff) & 0xff) ^ lTd3(lTe1((k0) & 0xff) & 0xff); \
k1 = lTd[lTe1((k1 >> 24)) & 0xff] ^ lTd1(lTe1((k1 >> 16) & 0xff) & 0xff) ^ \
        lTd2(lTe1((k1 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k1) & 0xff) & 0xff); \
k2 = lTd[lTe1((k2 >> 24)) & 0xff] ^ lTd1(lTe1((k2 >> 16) & 0xff) & 0xff) ^ \
	lTd2(lTe1((k2 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k2) & 0xff) & 0xff); \
k3 = lTd[lTe1((k3 >> 24)) & 0xff] ^ lTd1(lTe1((k3 >> 16) & 0xff) & 0xff) ^ \
	lTd2(lTe1((k3 >>  8) & 0xff) & 0xff) ^lTd3(lTe1((k3) & 0xff) & 0xff); \
}


#define AES192_EVEN_ROUND { \
t0 = lTd[s0 >> 24] ^ lTd1((s3 >> 16) & 0xff) ^ lTd2((s2 >>  8) & 0xff) ^ lTd3(s1 & 0xff) ^ k0; \
t1 = lTd[s1 >> 24] ^ lTd1((s0 >> 16) & 0xff) ^ lTd2((s3 >>  8) & 0xff) ^ lTd3(s2 & 0xff) ^ k1; \
t2 = lTd[s2 >> 24] ^ lTd1((s1 >> 16) & 0xff) ^ lTd2((s0 >>  8) & 0xff) ^ lTd3(s3 & 0xff) ^ k2; \
t3 = lTd[s3 >> 24] ^ lTd1((s2 >> 16) & 0xff) ^ lTd2((s1 >>  8) & 0xff) ^ lTd3(s0 & 0xff) ^ k3; \
}

#define AES192_ODD_ROUND { \
s0 = lTd[t0 >> 24] ^ lTd1((t3 >> 16) & 0xff) ^ lTd2((t2 >>  8) & 0xff) ^ lTd3(t1 & 0xff) ^ k0; \
s1 = lTd[t1 >> 24] ^ lTd1((t0 >> 16) & 0xff) ^ lTd2((t3 >>  8) & 0xff) ^ lTd3(t2 & 0xff) ^ k1; \
s2 = lTd[t2 >> 24] ^ lTd1((t1 >> 16) & 0xff) ^ lTd2((t0 >>  8) & 0xff) ^ lTd3(t3 & 0xff) ^ k2; \
s3 = lTd[t3 >> 24] ^ lTd1((t2 >> 16) & 0xff) ^ lTd2((t1 >>  8) & 0xff) ^ lTd3(t0 & 0xff) ^ k3; \
}


#define AES192_GET_KEYS0 { \
temp = rk5; \
r6 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r7= rk1^ r6; \
r8= rk2^ r7; \
r9= rk3^ r8; \
r10= rk4^ r9; \
r11= rk5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[3]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3;kcache4=r4;kcache5=r5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[7]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}




#define AES192_GET_KEYS1 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r2;k1=r3;k2=r4;k3=r5; \
}


#define AES192_GET_KEYS2 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[6]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7; \
k0=r4;k1=r5;k2=r0;k3=r1; \
}


#define AES192_GET_KEYS3 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[5]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES192_GET_KEYS4 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r2;k1=r3;k2=r4;k3=r5; \
}

#define AES192_GET_KEYS5 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[4]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9; \
k0=r4;k1=r5;k2=r0;k3=r1; \
}


#define AES192_GET_KEYS6 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}


#define AES192_GET_KEYS7 { \
temp = rk5; \
r6 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r7= rk1^ r6; \
r8= rk2^ r7; \
r9= rk3^ r8; \
r10= rk4^ r9; \
r11= rk5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000) \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[1]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
kcache0=r0;kcache1=r1;kcache2=r2;kcache3=r3;kcache4=r4;kcache5=r5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r2;k1=r3;k2=r4;k3=r5; \
}


#define AES192_GET_KEYS8 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
temp = r5; \
r6 = r0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[2]; \
r7= r1^ r6; \
r8= r2^ r7; \
r9= r3^ r8; \
r10= r4^ r9; \
r11= r5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9; \
k0=r4;k1=r5;k2=r0;k3=r1; \
}

#define AES192_GET_KEYS9 { \
r0=kcache0;r1=kcache1;r2=kcache2;r3=kcache3;r4=kcache4;r5=kcache5; \
k0=r0;k1=r1;k2=r2;k3=r3; \
}

#define AES192_GET_KEYS10 { \
temp = rk5; \
r6 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r7= rk1^ r6; \
r8= rk2^ r7; \
r9= rk3^ r8; \
r10= rk4^ r9; \
r11= rk5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=r2;k1=r3;k2=r4;k3=r5; \
}

#define AES192_GET_KEYS11 { \
temp = rk5; \
r6 = rk0 ^(lTe2((temp >> 16) & 0xff) & 0xff000000) ^ (lTe3((temp >> 8) & 0xff) & 0x00ff0000)  \
^ (lTe[(temp) & 0xff] & 0x0000ff00) ^ (lTe1((temp >> 24)) & 0x000000ff) ^ rcon[0]; \
r7= rk1^ r6; \
r8= rk2^ r7; \
r9= rk3^ r8; \
r10= rk4^ r9; \
r11= rk5^ r10; \
r0=r6;r1=r7;r2=r8;r3=r9;r4=r10;r5=r11; \
k0=rk4;k1=rk5;k2=r0;k3=r1; \
}


#define AES192_GET_KEYS12 { \
k0=rk0;k1=rk1;k2=rk2;k3=rk3; \
}





#define AES192_FINAL { \
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



__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
o5logonsha( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash,uint16 salt, uint16 str,uint16 str1) 
{
uint4 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16; 
uint i,ib,ic,id,ie;  
uint4 A,B,C,D,E,K,l,tmp1,tmp2, SIZE,TSIZE; 
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16;
uint elem,temp1;
__local uint inpc[64][18];
uint x0,x1,x2,x3,x4,x5,x6,x7;

#define S1 1
#define S2 5
#define S3 30  

uint4 K0 = (uint4)0x5A827999;
uint4 K1 = (uint4)0x6ED9EBA1;
uint4 K2 = (uint4)0x8F1BBCDC;
uint4 K3 = (uint4)0xCA62C1D6;
uint4 H0 = (uint4)0x67452301;
uint4 H1 = (uint4)0xEFCDAB89;
uint4 H2 = (uint4)0x98BADCFE;
uint4 H3 = (uint4)0x10325476;
uint4 H4 = (uint4)0xC3D2E1F0;


id=get_global_id(0);
SIZE=(uint4)sizein[GGI];
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
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str.s0,SIZE.s0,0);
SET_AB(inpc[GLI],str.s1,SIZE.s0+4,0);
SET_AB(inpc[GLI],str.s2,SIZE.s0+8,0);
SET_AB(inpc[GLI],str.s3,SIZE.s0+12,0);
SET_AB(inpc[GLI],salt.sD,SIZE.s0+str.sC,0);
SET_AB(inpc[GLI],salt.sE,SIZE.s0+str.sC+4,0);
SET_AB(inpc[GLI],salt.sF,SIZE.s0+str.sC+8,0);
SET_AB(inpc[GLI],0x80,(SIZE.s0+str.sC+10),0);
w0.s0=inpc[GLI][0];
w1.s0=inpc[GLI][1];
w2.s0=inpc[GLI][2];
w3.s0=inpc[GLI][3];
w4.s0=inpc[GLI][4];
w5.s0=inpc[GLI][5];
w6.s0=inpc[GLI][6];
w7.s0=inpc[GLI][7];
w8.s0=inpc[GLI][8];
w9.s0=inpc[GLI][9];
w10.s0=inpc[GLI][10];
w11.s0=inpc[GLI][11];
w12.s0=inpc[GLI][12];
w13.s0=inpc[GLI][13];
SIZE.s0 = (SIZE.s0+str.sC+10)<<3;

inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str.s4,SIZE.s1,0);
SET_AB(inpc[GLI],str.s5,SIZE.s1+4,0);
SET_AB(inpc[GLI],str.s6,SIZE.s1+8,0);
SET_AB(inpc[GLI],str.s7,SIZE.s1+12,0);
SET_AB(inpc[GLI],salt.sD,SIZE.s1+str.sD,0);
SET_AB(inpc[GLI],salt.sE,SIZE.s1+str.sD+4,0);
SET_AB(inpc[GLI],salt.sF,SIZE.s1+str.sD+8,0);
SET_AB(inpc[GLI],0x80,(SIZE.s1+str.sD+10),0);
w0.s1=inpc[GLI][0];
w1.s1=inpc[GLI][1];
w2.s1=inpc[GLI][2];
w3.s1=inpc[GLI][3];
w4.s1=inpc[GLI][4];
w5.s1=inpc[GLI][5];
w6.s1=inpc[GLI][6];
w7.s1=inpc[GLI][7];
w8.s1=inpc[GLI][8];
w9.s1=inpc[GLI][9];
w10.s1=inpc[GLI][10];
w11.s1=inpc[GLI][11];
w12.s1=inpc[GLI][12];
w13.s1=inpc[GLI][13];
SIZE.s1 = (SIZE.s1+str.sD+10)<<3;

inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str.s8,SIZE.s2,0);
SET_AB(inpc[GLI],str.s9,SIZE.s2+4,0);
SET_AB(inpc[GLI],str.sA,SIZE.s2+8,0);
SET_AB(inpc[GLI],str.sB,SIZE.s2+12,0);
SET_AB(inpc[GLI],salt.sD,SIZE.s2+str.sE,0);
SET_AB(inpc[GLI],salt.sE,SIZE.s2+str.sE+4,0);
SET_AB(inpc[GLI],salt.sF,SIZE.s2+str.sE+8,0);
SET_AB(inpc[GLI],0x80,(SIZE.s2+str.sE+10),0);
w0.s2=inpc[GLI][0];
w1.s2=inpc[GLI][1];
w2.s2=inpc[GLI][2];
w3.s2=inpc[GLI][3];
w4.s2=inpc[GLI][4];
w5.s2=inpc[GLI][5];
w6.s2=inpc[GLI][6];
w7.s2=inpc[GLI][7];
w8.s2=inpc[GLI][8];
w9.s2=inpc[GLI][9];
w10.s2=inpc[GLI][10];
w11.s2=inpc[GLI][11];
w12.s2=inpc[GLI][12];
w13.s2=inpc[GLI][13];
SIZE.s2 = (SIZE.s2+str.sE+10)<<3;

inpc[GLI][0]=x0;
inpc[GLI][1]=x1;
inpc[GLI][2]=x2;
inpc[GLI][3]=x3;
inpc[GLI][4]=x4;
inpc[GLI][5]=x5;
inpc[GLI][6]=x6;
inpc[GLI][7]=x7;
inpc[GLI][8]=inpc[GLI][9]=inpc[GLI][10]=inpc[GLI][11]=inpc[GLI][12]=inpc[GLI][13]=0;
SET_AB(inpc[GLI],str1.s0,SIZE.s3,0);
SET_AB(inpc[GLI],str1.s1,SIZE.s3+4,0);
SET_AB(inpc[GLI],str1.s2,SIZE.s3+8,0);
SET_AB(inpc[GLI],str1.s3,SIZE.s3+12,0);
SET_AB(inpc[GLI],salt.sD,SIZE.s3+str1.sC,0);
SET_AB(inpc[GLI],salt.sE,SIZE.s3+str1.sC+4,0);
SET_AB(inpc[GLI],salt.sF,SIZE.s3+str1.sC+8,0);
SET_AB(inpc[GLI],0x80,(SIZE.s3+str1.sC+10),0);
w0.s3=inpc[GLI][0];
w1.s3=inpc[GLI][1];
w2.s3=inpc[GLI][2];
w3.s3=inpc[GLI][3];
w4.s3=inpc[GLI][4];
w5.s3=inpc[GLI][5];
w6.s3=inpc[GLI][6];
w7.s3=inpc[GLI][7];
w8.s3=inpc[GLI][8];
w9.s3=inpc[GLI][9];
w10.s3=inpc[GLI][10];
w11.s3=inpc[GLI][11];
w12.s3=inpc[GLI][12];
w13.s3=inpc[GLI][13];
SIZE.s3 = (SIZE.s3+str1.sC+10)<<3;


w14=w16=(uint4)0;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  

#define F_00_19(b,c,d) (bitselect(d,c,b))
#define F_20_39(b,c,d)  ((b) ^ (c) ^ (d))  
#define F_40_59(b,c,d) (bitselect(c,b,(d^c)))
#define F_60_79(b,c,d)  F_20_39(b,c,d) 
#define ROTATE1(a, b, c, d, e, x) e = e + rotate(a,S2) + F_00_19(b,c,d) + x; e = e + K; b = rotate(b,S3) 
#define ROTATE1_NULL(a, b, c, d, e)  e = e + rotate(a,S2) + F_00_19(b,c,d) + K; b = rotate(b,S3)
#define ROTATE2_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_20_39(b,c,d) + x + K; b = rotate(b,S3) 
#define ROTATE3_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_40_59(b,c,d) + x + K; b = rotate(b,S3)
#define ROTATE4_F(a, b, c, d, e, x) e = e + rotate(a,S2) + F_60_79(b,c,d) + x + K; b = rotate(b,S3)



K = K0;
Endian_Reverse32(w0);  
ROTATE1(A, B, C, D, E, w0);
Endian_Reverse32(w1);  
ROTATE1(E, A, B, C, D, w1);
Endian_Reverse32(w2);  
ROTATE1(D, E, A, B, C, w2);
Endian_Reverse32(w3);  
ROTATE1(C, D, E, A, B, w3);
Endian_Reverse32(w4);  
ROTATE1(B, C, D, E, A, w4);
Endian_Reverse32(w5);  
ROTATE1(A, B, C, D, E, w5);
Endian_Reverse32(w6);  
ROTATE1(E, A, B, C, D, w6);
Endian_Reverse32(w7);  
ROTATE1(D, E, A, B, C, w7);
Endian_Reverse32(w8);  
ROTATE1(C, D, E, A, B, w8);
Endian_Reverse32(w9);  
ROTATE1(B, C, D, E, A, w9);
Endian_Reverse32(w10);  
ROTATE1(A, B, C, D, E, w10);
Endian_Reverse32(w11);  
ROTATE1(E, A, B, C, D, w11);
Endian_Reverse32(w12);  
ROTATE1(D, E, A, B, C, w12);
Endian_Reverse32(w13);  
ROTATE1(C, D, E, A, B, w13);
ROTATE1_NULL(B, C, D, E, A);

ROTATE1(A, B, C, D, E, SIZE);  

w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1);ROTATE1(E,A,B,C,D,w16);
w0 = rotate((w14 ^ w9 ^ w3 ^ w1),S1);ROTATE1(D,E,A,B,C,w0); 
w1 = rotate((SIZE ^ w10 ^ w4 ^ w2),S1); ROTATE1(C,D,E,A,B,w1); 
w2 = rotate((w16 ^ w11 ^ w5 ^ w3),S1);  ROTATE1(B,C,D,E,A,w2); 


K = K1;

w3 = rotate((w0 ^ w12 ^ w6 ^ w4),S1); ROTATE2_F(A, B, C, D, E, w3);
w4 = rotate((w1 ^ w13 ^ w7 ^ w5),S1); ROTATE2_F(E, A, B, C, D, w4);
w5 = rotate((w2 ^ w14 ^ w8 ^ w6),S1); ROTATE2_F(D, E, A, B, C, w5);
w6 = rotate((w3 ^ SIZE ^ w9 ^ w7),S1);ROTATE2_F(C, D, E, A, B, w6);
w7 = rotate((w4 ^ w16 ^ w10 ^ w8),S1); ROTATE2_F(B, C, D, E, A, w7);
w8 = rotate((w5 ^ w0 ^ w11 ^ w9),S1); ROTATE2_F(A, B, C, D, E, w8);
w9 = rotate((w6 ^ w1 ^ w12 ^ w10),S1); ROTATE2_F(E, A, B, C, D, w9);
w10 = rotate((w7 ^ w2 ^ w13 ^ w11),S1); ROTATE2_F(D, E, A, B, C, w10); 
w11 = rotate((w8 ^ w3 ^ w14 ^ w12),S1); ROTATE2_F(C, D, E, A, B, w11); 
w12 = rotate((w9 ^ w4 ^ SIZE ^ w13),S1); ROTATE2_F(B, C, D, E, A, w12);
w13 = rotate((w10 ^ w5 ^ w16 ^ w14),S1); ROTATE2_F(A, B, C, D, E, w13);
w14 = rotate((w11 ^ w6 ^ w0 ^ SIZE),S1); ROTATE2_F(E, A, B, C, D, w14);
SIZE = rotate((w12 ^ w7 ^ w1 ^ w16),S1); ROTATE2_F(D, E, A, B, C, SIZE);
w16 = rotate((w13 ^ w8 ^ w2 ^ w0),S1); ROTATE2_F(C, D, E, A, B, w16);  
w0 = rotate(w14 ^ w9 ^ w3 ^ w1,S1); ROTATE2_F(B, C, D, E, A, w0);  
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2,S1); ROTATE2_F(A, B, C, D, E, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE2_F(E, A, B, C, D, w2); 
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE2_F(D, E, A, B, C, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1);ROTATE2_F(C, D, E, A, B, w4);
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE2_F(B, C, D, E, A, w5);  
K = K2;

w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(A, B, C, D, E, w6);
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(E, A, B, C, D, w7);
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(D, E, A, B, C, w8); 
w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE3_F(C, D, E, A, B, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE3_F(B, C, D, E, A, w10);  
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE3_F(A, B, C, D, E, w11);  
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE3_F(E, A, B, C, D, w12); 
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE3_F(D, E, A, B, C, w13); 
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE3_F(C, D, E, A, B, w14); 
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE3_F(B, C, D, E, A, SIZE);
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE3_F(A, B, C, D, E, w16);
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE3_F(E, A, B, C, D, w0); 
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE3_F(D, E, A, B, C, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3, S1); ROTATE3_F(C, D, E, A, B, w2);
w3 = rotate(w0 ^ w12 ^ w6 ^ w4, S1); ROTATE3_F(B, C, D, E, A, w3); 
w4 = rotate(w1 ^ w13 ^ w7 ^ w5, S1); ROTATE3_F(A, B, C, D, E, w4); 
w5 = rotate(w2 ^ w14 ^ w8 ^ w6, S1); ROTATE3_F(E, A, B, C, D, w5); 
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7, S1); ROTATE3_F(D, E, A, B, C, w6);
w7 = rotate(w4 ^ w16 ^ w10 ^ w8, S1); ROTATE3_F(C, D, E, A, B, w7);
w8 = rotate(w5 ^ w0 ^ w11 ^ w9, S1); ROTATE3_F(B, C, D, E, A, w8); 


K = K3;

w9 = rotate(w6 ^ w1 ^ w12 ^ w10, S1); ROTATE4_F(A, B, C, D, E, w9);
w10 = rotate(w7 ^ w2 ^ w13 ^ w11, S1); ROTATE4_F(E, A, B, C, D, w10);  
w11 = rotate(w8 ^ w3 ^ w14 ^ w12, S1); ROTATE4_F(D, E, A, B, C, w11);  
w12 = rotate(w9 ^ w4 ^ SIZE ^ w13, S1); ROTATE4_F(C, D, E, A, B, w12); 
w13 = rotate(w10 ^ w5 ^ w16 ^ w14, S1); ROTATE4_F(B, C, D, E, A, w13); 
w14 = rotate(w11 ^ w6 ^ w0 ^ SIZE, S1); ROTATE4_F(A, B, C, D, E, w14); 
SIZE = rotate(w12 ^ w7 ^ w1 ^ w16, S1); ROTATE4_F(E, A, B, C, D, SIZE);
w16 = rotate(w13 ^ w8 ^ w2 ^ w0, S1); ROTATE4_F(D, E, A, B, C, w16);
w0 = rotate(w14 ^ w9 ^ w3 ^ w1, S1); ROTATE4_F(C, D, E, A, B, w0); 
w1 = rotate(SIZE ^ w10 ^ w4 ^ w2, S1); ROTATE4_F(B, C, D, E, A, w1);
w2 = rotate(w16 ^ w11 ^ w5 ^ w3,S1); ROTATE4_F(A, B, C, D, E, w2); 
w3 = rotate(w0 ^ w12 ^ w6 ^ w4,S1); ROTATE4_F(E, A, B, C, D, w3);  
w4 = rotate(w1 ^ w13 ^ w7 ^ w5,S1); ROTATE4_F(D, E, A, B, C, w4);  
w5 = rotate(w2 ^ w14 ^ w8 ^ w6,S1); ROTATE4_F(C, D, E, A, B, w5);  
w6 = rotate(w3 ^ SIZE ^ w9 ^ w7,S1); ROTATE4_F(B, C, D, E, A, w6); 
w7 = rotate(w4 ^ w16 ^ w10 ^ w8,S1); ROTATE4_F(A, B, C, D, E, w7); 
w8 = rotate(w5 ^ w0 ^ w11 ^ w9,S1); ROTATE4_F(E, A, B, C, D, w8);  
w9 = rotate(w6 ^ w1 ^ w12 ^ w10,S1); ROTATE4_F(D, E, A, B, C, w9); 
w10 = rotate(w7 ^ w2 ^ w13 ^ w11,S1); ROTATE4_F(C, D, E, A, B, w10);
w11 = rotate(w8 ^ w3 ^ w14 ^ w12,S1); ROTATE4_F(B, C, D, E, A, w11);



A=A+H0;B=B+H1;C=C+H2;D=D+H3;E=E+H4;
Endian_Reverse32(A);
Endian_Reverse32(B);
Endian_Reverse32(C);
Endian_Reverse32(D);
Endian_Reverse32(E);

dst[(get_global_id(0)*5)] = (uint4)(A.s0,B.s0,C.s0,D.s0);  
dst[(get_global_id(0)*5)+1] = (uint4)(E.s0,A.s1,B.s1,C.s1);
dst[(get_global_id(0)*5)+2] = (uint4)(D.s1,E.s1,A.s2,B.s2);
dst[(get_global_id(0)*5)+3] = (uint4)(C.s2,D.s2,E.s2,A.s3);
dst[(get_global_id(0)*5)+4] = (uint4)(B.s3,C.s3,D.s3,E.s3);

}






__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
o5logonaes( __global uint4 *dst,  __global uint *inp, __global uint *sizein,  __global uint *found_ind, __global uint *found,  uint4 singlehash,uint16 salt,uint16 str,uint16 str1) 
{
uint SIZE,size;
uint i ,ib ,ic ,id, ie;
uint a,b,c,d, tmp1,tmp2;
uint b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15,b16; 
uint x0,x1,x2,x3,x4,x5,x6,x7; 
uint w0,w1,w2,w3,w4,w5,w6,w7; 
uint elem,temp1,temp,l,tmp;
__local uint lTe[256];
__local uint lTd[256];
__local uint lTdK[256];
uint rk0,rk1,rk2,rk3,rk4,rk5;
uint r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11;
uint k0,k1,k2,k3,k4,k5,k6,k7;
uint s0, s1, s2, s3, t0, t1, t2, t3;
uint kcache0,kcache1,kcache2,kcache3,kcache4,kcache5;
uint ir0,ir1,ir2,ir3;

id=get_global_id(0);
x0 = inp[GGI*5+0];
x1 = inp[GGI*5+1];
x2 = inp[GGI*5+2];
x3 = inp[GGI*5+3];
x4 = inp[GGI*5+4];
x5 = 0;


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



/* Initial key for AES-192 */
Endian_Reverse32(x0);
rk0=x0;
Endian_Reverse32(x1);
rk1=x1;
Endian_Reverse32(x2);
rk2=x2;
Endian_Reverse32(x3);
rk3=x3;
Endian_Reverse32(x4);
rk4=x4;
rk5=0;


/* Setup s0..s3 */
AES192_GET_KEYS0;

/* We expect salt (ct) values to come in BE form already */
s0 = salt.s0 ^ k0;
s1 = salt.s1 ^ k1;
s2 = salt.s2 ^ k2;
s3 = salt.s3 ^ k3;

AES192_GET_KEYS1;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS2;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS3;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS4;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS5;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS6;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS7;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS8;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS9;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS10;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS11;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS12;
AES192_FINAL;


/* Setup s0..s3 */
AES192_GET_KEYS0;
s0 = salt.s4 ^ k0;
s1 = salt.s5 ^ k1;
s2 = salt.s6 ^ k2;
s3 = salt.s7 ^ k3;

AES192_GET_KEYS1;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS2;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS3;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS4;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS5;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS6;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS7;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS8;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS9;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS10;
AES192_INV_MIX;
AES192_ODD_ROUND;

AES192_GET_KEYS11;
AES192_INV_MIX;
AES192_EVEN_ROUND;

AES192_GET_KEYS12;
AES192_FINAL;

/* CBC mode decryption (XOR ptext with prev. ctext) */
ir0=salt.s0;
ir1=salt.s1;
ir2=salt.s2;
ir3=salt.s3;
Endian_Reverse32(ir0);
Endian_Reverse32(ir1);
Endian_Reverse32(ir2);
Endian_Reverse32(ir3);

s0 = s0^ir0;
s1 = s1^ir1;
s2 = s2^ir2;
s3 = s3^ir3;

if (s3!=0x08080808) return;
if (s2!=0x08080808) return;


dst[(get_global_id(0))] = (uint4)(s0,s1,s2,s3);
found_ind[get_global_id(0)] = 1;
found[0] = 1;

}
