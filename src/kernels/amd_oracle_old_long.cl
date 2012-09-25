__constant uint CDES_SPtrans[8][64]={
{
/* nibble 0 */
0x02080800, 0x00080000, 0x02000002, 0x02080802,
0x02000000, 0x00080802, 0x00080002, 0x02000002,
0x00080802, 0x02080800, 0x02080000, 0x00000802,
0x02000802, 0x02000000, 0x00000000, 0x00080002,
0x00080000, 0x00000002, 0x02000800, 0x00080800,
0x02080802, 0x02080000, 0x00000802, 0x02000800,
0x00000002, 0x00000800, 0x00080800, 0x02080002,
0x00000800, 0x02000802, 0x02080002, 0x00000000,
0x00000000, 0x02080802, 0x02000800, 0x00080002,
0x02080800, 0x00080000, 0x00000802, 0x02000800,
0x02080002, 0x00000800, 0x00080800, 0x02000002,
0x00080802, 0x00000002, 0x02000002, 0x02080000,
0x02080802, 0x00080800, 0x02080000, 0x02000802,
0x02000000, 0x00000802, 0x00080002, 0x00000000,
0x00080000, 0x02000000, 0x02000802, 0x02080800,
0x00000002, 0x02080002, 0x00000800, 0x00080802,
},{
/* nibble 1 */
0x40108010, 0x00000000, 0x00108000, 0x40100000,
0x40000010, 0x00008010, 0x40008000, 0x00108000,
0x00008000, 0x40100010, 0x00000010, 0x40008000,
0x00100010, 0x40108000, 0x40100000, 0x00000010,
0x00100000, 0x40008010, 0x40100010, 0x00008000,
0x00108010, 0x40000000, 0x00000000, 0x00100010,
0x40008010, 0x00108010, 0x40108000, 0x40000010,
0x40000000, 0x00100000, 0x00008010, 0x40108010,
0x00100010, 0x40108000, 0x40008000, 0x00108010,
0x40108010, 0x00100010, 0x40000010, 0x00000000,
0x40000000, 0x00008010, 0x00100000, 0x40100010,
0x00008000, 0x40000000, 0x00108010, 0x40008010,
0x40108000, 0x00008000, 0x00000000, 0x40000010,
0x00000010, 0x40108010, 0x00108000, 0x40100000,
0x40100010, 0x00100000, 0x00008010, 0x40008000,
0x40008010, 0x00000010, 0x40100000, 0x00108000,
},{
/* nibble 2 */
0x04000001, 0x04040100, 0x00000100, 0x04000101,
0x00040001, 0x04000000, 0x04000101, 0x00040100,
0x04000100, 0x00040000, 0x04040000, 0x00000001,
0x04040101, 0x00000101, 0x00000001, 0x04040001,
0x00000000, 0x00040001, 0x04040100, 0x00000100,
0x00000101, 0x04040101, 0x00040000, 0x04000001,
0x04040001, 0x04000100, 0x00040101, 0x04040000,
0x00040100, 0x00000000, 0x04000000, 0x00040101,
0x04040100, 0x00000100, 0x00000001, 0x00040000,
0x00000101, 0x00040001, 0x04040000, 0x04000101,
0x00000000, 0x04040100, 0x00040100, 0x04040001,
0x00040001, 0x04000000, 0x04040101, 0x00000001,
0x00040101, 0x04000001, 0x04000000, 0x04040101,
0x00040000, 0x04000100, 0x04000101, 0x00040100,
0x04000100, 0x00000000, 0x04040001, 0x00000101,
0x04000001, 0x00040101, 0x00000100, 0x04040000,
},{
/* nibble 3 */
0x00401008, 0x10001000, 0x00000008, 0x10401008,
0x00000000, 0x10400000, 0x10001008, 0x00400008,
0x10401000, 0x10000008, 0x10000000, 0x00001008,
0x10000008, 0x00401008, 0x00400000, 0x10000000,
0x10400008, 0x00401000, 0x00001000, 0x00000008,
0x00401000, 0x10001008, 0x10400000, 0x00001000,
0x00001008, 0x00000000, 0x00400008, 0x10401000,
0x10001000, 0x10400008, 0x10401008, 0x00400000,
0x10400008, 0x00001008, 0x00400000, 0x10000008,
0x00401000, 0x10001000, 0x00000008, 0x10400000,
0x10001008, 0x00000000, 0x00001000, 0x00400008,
0x00000000, 0x10400008, 0x10401000, 0x00001000,
0x10000000, 0x10401008, 0x00401008, 0x00400000,
0x10401008, 0x00000008, 0x10001000, 0x00401008,
0x00400008, 0x00401000, 0x10400000, 0x10001008,
0x00001008, 0x10000000, 0x10000008, 0x10401000,
},{
/* nibble 4 */
0x08000000, 0x00010000, 0x00000400, 0x08010420,
0x08010020, 0x08000400, 0x00010420, 0x08010000,
0x00010000, 0x00000020, 0x08000020, 0x00010400,
0x08000420, 0x08010020, 0x08010400, 0x00000000,
0x00010400, 0x08000000, 0x00010020, 0x00000420,
0x08000400, 0x00010420, 0x00000000, 0x08000020,
0x00000020, 0x08000420, 0x08010420, 0x00010020,
0x08010000, 0x00000400, 0x00000420, 0x08010400,
0x08010400, 0x08000420, 0x00010020, 0x08010000,
0x00010000, 0x00000020, 0x08000020, 0x08000400,
0x08000000, 0x00010400, 0x08010420, 0x00000000,
0x00010420, 0x08000000, 0x00000400, 0x00010020,
0x08000420, 0x00000400, 0x00000000, 0x08010420,
0x08010020, 0x08010400, 0x00000420, 0x00010000,
0x00010400, 0x08010020, 0x08000400, 0x00000420,
0x00000020, 0x00010420, 0x08010000, 0x08000020,
},{
/* nibble 5 */
0x80000040, 0x00200040, 0x00000000, 0x80202000,
0x00200040, 0x00002000, 0x80002040, 0x00200000,
0x00002040, 0x80202040, 0x00202000, 0x80000000,
0x80002000, 0x80000040, 0x80200000, 0x00202040,
0x00200000, 0x80002040, 0x80200040, 0x00000000,
0x00002000, 0x00000040, 0x80202000, 0x80200040,
0x80202040, 0x80200000, 0x80000000, 0x00002040,
0x00000040, 0x00202000, 0x00202040, 0x80002000,
0x00002040, 0x80000000, 0x80002000, 0x00202040,
0x80202000, 0x00200040, 0x00000000, 0x80002000,
0x80000000, 0x00002000, 0x80200040, 0x00200000,
0x00200040, 0x80202040, 0x00202000, 0x00000040,
0x80202040, 0x00202000, 0x00200000, 0x80002040,
0x80000040, 0x80200000, 0x00202040, 0x00000000,
0x00002000, 0x80000040, 0x80002040, 0x80202000,
0x80200000, 0x00002040, 0x00000040, 0x80200040,
},{
/* nibble 6 */
0x00004000, 0x00000200, 0x01000200, 0x01000004,
0x01004204, 0x00004004, 0x00004200, 0x00000000,
0x01000000, 0x01000204, 0x00000204, 0x01004000,
0x00000004, 0x01004200, 0x01004000, 0x00000204,
0x01000204, 0x00004000, 0x00004004, 0x01004204,
0x00000000, 0x01000200, 0x01000004, 0x00004200,
0x01004004, 0x00004204, 0x01004200, 0x00000004,
0x00004204, 0x01004004, 0x00000200, 0x01000000,
0x00004204, 0x01004000, 0x01004004, 0x00000204,
0x00004000, 0x00000200, 0x01000000, 0x01004004,
0x01000204, 0x00004204, 0x00004200, 0x00000000,
0x00000200, 0x01000004, 0x00000004, 0x01000200,
0x00000000, 0x01000204, 0x01000200, 0x00004200,
0x00000204, 0x00004000, 0x01004204, 0x01000000,
0x01004200, 0x00000004, 0x00004004, 0x01004204,
0x01000004, 0x01004200, 0x01004000, 0x00004004,
},{
/* nibble 7 */
0x20800080, 0x20820000, 0x00020080, 0x00000000,
0x20020000, 0x00800080, 0x20800000, 0x20820080,
0x00000080, 0x20000000, 0x00820000, 0x00020080,
0x00820080, 0x20020080, 0x20000080, 0x20800000,
0x00020000, 0x00820080, 0x00800080, 0x20020000,
0x20820080, 0x20000080, 0x00000000, 0x00820000,
0x20000000, 0x00800000, 0x20020080, 0x20800080,
0x00800000, 0x00020000, 0x20820000, 0x00000080,
0x00800000, 0x00020000, 0x20000080, 0x20820080,
0x00020080, 0x20000000, 0x00000000, 0x00820000,
0x20800080, 0x20020080, 0x20020000, 0x00800080,
0x20820000, 0x00000080, 0x00800080, 0x20020000,
0x20820080, 0x00800000, 0x20800000, 0x20000080,
0x00820000, 0x00020080, 0x20020080, 0x20800000,
0x00000080, 0x20820000, 0x00820080, 0x00000000,
0x20000000, 0x20800080, 0x00020000, 0x00820080,
}};

__constant uint cdes_skb[8][64]={
{
/* for C bits (numbered as per FIPS 46) 1 2 3 4 5 6 */
0x00000000,0x00000010,0x20000000,0x20000010,
0x00010000,0x00010010,0x20010000,0x20010010,
0x00000800,0x00000810,0x20000800,0x20000810,
0x00010800,0x00010810,0x20010800,0x20010810,
0x00000020,0x00000030,0x20000020,0x20000030,
0x00010020,0x00010030,0x20010020,0x20010030,
0x00000820,0x00000830,0x20000820,0x20000830,
0x00010820,0x00010830,0x20010820,0x20010830,
0x00080000,0x00080010,0x20080000,0x20080010,
0x00090000,0x00090010,0x20090000,0x20090010,
0x00080800,0x00080810,0x20080800,0x20080810,
0x00090800,0x00090810,0x20090800,0x20090810,
0x00080020,0x00080030,0x20080020,0x20080030,
0x00090020,0x00090030,0x20090020,0x20090030,
0x00080820,0x00080830,0x20080820,0x20080830,
0x00090820,0x00090830,0x20090820,0x20090830,
},{
/* for C bits (numbered as per FIPS 46) 7 8 10 11 12 13 */
0x00000000,0x02000000,0x00002000,0x02002000,
0x00200000,0x02200000,0x00202000,0x02202000,
0x00000004,0x02000004,0x00002004,0x02002004,
0x00200004,0x02200004,0x00202004,0x02202004,
0x00000400,0x02000400,0x00002400,0x02002400,
0x00200400,0x02200400,0x00202400,0x02202400,
0x00000404,0x02000404,0x00002404,0x02002404,
0x00200404,0x02200404,0x00202404,0x02202404,
0x10000000,0x12000000,0x10002000,0x12002000,
0x10200000,0x12200000,0x10202000,0x12202000,
0x10000004,0x12000004,0x10002004,0x12002004,
0x10200004,0x12200004,0x10202004,0x12202004,
0x10000400,0x12000400,0x10002400,0x12002400,
0x10200400,0x12200400,0x10202400,0x12202400,
0x10000404,0x12000404,0x10002404,0x12002404,
0x10200404,0x12200404,0x10202404,0x12202404,
},{
/* for C bits (numbered as per FIPS 46) 14 15 16 17 19 20 */
0x00000000,0x00000001,0x00040000,0x00040001,
0x01000000,0x01000001,0x01040000,0x01040001,
0x00000002,0x00000003,0x00040002,0x00040003,
0x01000002,0x01000003,0x01040002,0x01040003,
0x00000200,0x00000201,0x00040200,0x00040201,
0x01000200,0x01000201,0x01040200,0x01040201,
0x00000202,0x00000203,0x00040202,0x00040203,
0x01000202,0x01000203,0x01040202,0x01040203,
0x08000000,0x08000001,0x08040000,0x08040001,
0x09000000,0x09000001,0x09040000,0x09040001,
0x08000002,0x08000003,0x08040002,0x08040003,
0x09000002,0x09000003,0x09040002,0x09040003,
0x08000200,0x08000201,0x08040200,0x08040201,
0x09000200,0x09000201,0x09040200,0x09040201,
0x08000202,0x08000203,0x08040202,0x08040203,
0x09000202,0x09000203,0x09040202,0x09040203,
},{
/* for C bits (numbered as per FIPS 46) 21 23 24 26 27 28 */
0x00000000,0x00100000,0x00000100,0x00100100,
0x00000008,0x00100008,0x00000108,0x00100108,
0x00001000,0x00101000,0x00001100,0x00101100,
0x00001008,0x00101008,0x00001108,0x00101108,
0x04000000,0x04100000,0x04000100,0x04100100,
0x04000008,0x04100008,0x04000108,0x04100108,
0x04001000,0x04101000,0x04001100,0x04101100,
0x04001008,0x04101008,0x04001108,0x04101108,
0x00020000,0x00120000,0x00020100,0x00120100,
0x00020008,0x00120008,0x00020108,0x00120108,
0x00021000,0x00121000,0x00021100,0x00121100,
0x00021008,0x00121008,0x00021108,0x00121108,
0x04020000,0x04120000,0x04020100,0x04120100,
0x04020008,0x04120008,0x04020108,0x04120108,
0x04021000,0x04121000,0x04021100,0x04121100,
0x04021008,0x04121008,0x04021108,0x04121108,
},{
/* for D bits (numbered as per FIPS 46) 1 2 3 4 5 6 */
0x00000000,0x10000000,0x00010000,0x10010000,
0x00000004,0x10000004,0x00010004,0x10010004,
0x20000000,0x30000000,0x20010000,0x30010000,
0x20000004,0x30000004,0x20010004,0x30010004,
0x00100000,0x10100000,0x00110000,0x10110000,
0x00100004,0x10100004,0x00110004,0x10110004,
0x20100000,0x30100000,0x20110000,0x30110000,
0x20100004,0x30100004,0x20110004,0x30110004,
0x00001000,0x10001000,0x00011000,0x10011000,
0x00001004,0x10001004,0x00011004,0x10011004,
0x20001000,0x30001000,0x20011000,0x30011000,
0x20001004,0x30001004,0x20011004,0x30011004,
0x00101000,0x10101000,0x00111000,0x10111000,
0x00101004,0x10101004,0x00111004,0x10111004,
0x20101000,0x30101000,0x20111000,0x30111000,
0x20101004,0x30101004,0x20111004,0x30111004,
},{
/* for D bits (numbered as per FIPS 46) 8 9 11 12 13 14 */
0x00000000,0x08000000,0x00000008,0x08000008,
0x00000400,0x08000400,0x00000408,0x08000408,
0x00020000,0x08020000,0x00020008,0x08020008,
0x00020400,0x08020400,0x00020408,0x08020408,
0x00000001,0x08000001,0x00000009,0x08000009,
0x00000401,0x08000401,0x00000409,0x08000409,
0x00020001,0x08020001,0x00020009,0x08020009,
0x00020401,0x08020401,0x00020409,0x08020409,
0x02000000,0x0A000000,0x02000008,0x0A000008,
0x02000400,0x0A000400,0x02000408,0x0A000408,
0x02020000,0x0A020000,0x02020008,0x0A020008,
0x02020400,0x0A020400,0x02020408,0x0A020408,
0x02000001,0x0A000001,0x02000009,0x0A000009,
0x02000401,0x0A000401,0x02000409,0x0A000409,
0x02020001,0x0A020001,0x02020009,0x0A020009,
0x02020401,0x0A020401,0x02020409,0x0A020409,
},{
/* for D bits (numbered as per FIPS 46) 16 17 18 19 20 21 */
0x00000000,0x00000100,0x00080000,0x00080100,
0x01000000,0x01000100,0x01080000,0x01080100,
0x00000010,0x00000110,0x00080010,0x00080110,
0x01000010,0x01000110,0x01080010,0x01080110,
0x00200000,0x00200100,0x00280000,0x00280100,
0x01200000,0x01200100,0x01280000,0x01280100,
0x00200010,0x00200110,0x00280010,0x00280110,
0x01200010,0x01200110,0x01280010,0x01280110,
0x00000200,0x00000300,0x00080200,0x00080300,
0x01000200,0x01000300,0x01080200,0x01080300,
0x00000210,0x00000310,0x00080210,0x00080310,
0x01000210,0x01000310,0x01080210,0x01080310,
0x00200200,0x00200300,0x00280200,0x00280300,
0x01200200,0x01200300,0x01280200,0x01280300,
0x00200210,0x00200310,0x00280210,0x00280310,
0x01200210,0x01200310,0x01280210,0x01280310,
},{
/* for D bits (numbered as per FIPS 46) 22 23 24 25 27 28 */
0x00000000,0x04000000,0x00040000,0x04040000,
0x00000002,0x04000002,0x00040002,0x04040002,
0x00002000,0x04002000,0x00042000,0x04042000,
0x00002002,0x04002002,0x00042002,0x04042002,
0x00000020,0x04000020,0x00040020,0x04040020,
0x00000022,0x04000022,0x00040022,0x04040022,
0x00002020,0x04002020,0x00042020,0x04042020,
0x00002022,0x04002022,0x00042022,0x04042022,
0x00000800,0x04000800,0x00040800,0x04040800,
0x00000802,0x04000802,0x00040802,0x04040802,
0x00002800,0x04002800,0x00042800,0x04042800,
0x00002802,0x04002802,0x00042802,0x04042802,
0x00000820,0x04000820,0x00040820,0x04040820,
0x00000822,0x04000822,0x00040822,0x04040822,
0x00002820,0x04002820,0x00042820,0x04042820,
0x00002822,0x04002822,0x00042822,0x04042822,
}};



#ifdef GCN


#define PERM_OP(a,b,t,n,m) {(t)=((((a)>>(n))^(b))&(m)); \
        (b)^=(t); \
        (a)^=((t)<<(n));}

#define HPERM_OP(a,t,n,m) {(t)=((((a)<<(16-(n)))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(16-(n)));}

#define HPERM_OP1(a,t,n,m) {(t)=((((a)<<(18))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(18));}


#define IP(l,r) \
        { \
        uint tt; \
        PERM_OP(r,l,tt, 4,0x0f0f0f0fL); \
        PERM_OP(l,r,tt,16,0x0000ffffL); \
        PERM_OP(r,l,tt, 2,0x33333333L); \
        PERM_OP(l,r,tt, 8,0x00ff00ffL); \
        PERM_OP(r,l,tt, 1,0x55555555L); \
        }

#define FP(l,r) \
        { \
        uint tt; \
        PERM_OP(l,r,tt, 1,0x55555555L); \
        PERM_OP(r,l,tt, 8,0x00ff00ffL); \
        PERM_OP(l,r,tt, 2,0x33333333L); \
        PERM_OP(r,l,tt,16,0x0000ffffL); \
        PERM_OP(l,r,tt, 4,0x0f0f0f0fL); \
        }


#define D_ENCRYPT(LL,R,S,SS1,SS2) {\
        u=R^SS1; \
        t=R^SS2; \
        t=ROTATE(t,4U); \
        LL^=\
        DES_SPtrans[0][(u>> 2L)&0x3f]^ \
        DES_SPtrans[2][(u>>10L)&0x3f]^ \
        DES_SPtrans[4][(u>>18L)&0x3f]^ \
        DES_SPtrans[6][(u>>26L)&0x3f]^ \
        DES_SPtrans[1][(t>> 2L)&0x3f]^ \
        DES_SPtrans[3][(t>>10L)&0x3f]^ \
        DES_SPtrans[5][(t>>18L)&0x3f]^ \
        DES_SPtrans[7][(t>>26L)&0x3f]; \
	}

#define ROTATE(a,n)     rotate(a,32-n)


#define DES_encrypt1(data1,data2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) { \
r=data1; \
l=data2; \
IP(r,l); \
r=ROTATE(r,29U); \
l=ROTATE(l,29U); \
D_ENCRYPT(l,r,0,k0,k1); \
D_ENCRYPT(r,l,2,k2,k3); \
D_ENCRYPT(l,r,4,k4,k5); \
D_ENCRYPT(r,l,6,k6,k7); \
D_ENCRYPT(l,r,8,k8,k9); \
D_ENCRYPT(r,l,10,k10,k11); \
D_ENCRYPT(l,r,12,k12,k13); \
D_ENCRYPT(r,l,14,k14,k15); \
D_ENCRYPT(l,r,16,k16,k17); \
D_ENCRYPT(r,l,18,k18,k19); \
D_ENCRYPT(l,r,20,k20,k21); \
D_ENCRYPT(r,l,22,k22,k23); \
D_ENCRYPT(l,r,24,k24,k25); \
D_ENCRYPT(r,l,26,k26,k27); \
D_ENCRYPT(l,r,28,k28,k29); \
D_ENCRYPT(r,l,30,k30,k31); \
l=ROTATE(l,3U); \
r=ROTATE(r,3U); \
FP(r,l); \
data1=l; \
data2=r; \
}




#define DES_ecb_encrypt_orcl(r1,r2,output1,output2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
ll1=r1; \
ll2=r2; \
DES_encrypt1(ll1,ll2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31); \
output1 = ll1; \
output2 = ll2; \
} 



#define DES_set_key_orcl(k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
key0=(uint)1684312128; key1=(uint)1120813258; key2=(uint)345020504; \
key3=(uint)1183417734; key4=(uint)3300149384; key5=(uint)2214923140; \
key6=(uint)2425676856; key7=(uint)2172944718; key8=(uint)3634365680; \
key9=(uint)97257220; key10=(uint)2834311184; key11=(uint)17269962; \
key12=(uint)3359656152; key13=(uint)122322950; key14=(uint)1758987432; \
key15=(uint)117555656; key16=(uint)76604428; key17=(uint)3444130569; \
key18=(uint)2887266340; key19=(uint)3368945540; key20=(uint)616594448; \
key21=(uint)3247179909; key22=(uint)2357772344; key23=(uint)2324319362; \
key24=(uint)3225995300; key25=(uint)3246424963; key26=(uint)1275359400; \
key27=(uint)193380875; key28=(uint)1480597684; key29=(uint)3360295242; \
key30=(uint)7613516; key31=(uint)3456896068; \
}

#define DES_set_key_orcl_cust(r1,r2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
d=c=t=s=t2=0; \
c=r1; \
d=r2; \
PERM_OP (d,c,t,4,0x0f0f0f0f); \
HPERM_OP1(c,t,-2,0xcccc0000); \
HPERM_OP1(d,t,-2,0xcccc0000); \
PERM_OP (d,c,t,1,0x55555555); \
PERM_OP (c,d,t,8,0x00ff00ff); \
PERM_OP (d,c,t,1,0x55555555); \
d=(((d&0x000000ffL)<<16L)| (d&0x0000ff00L) | ((d&0x00ff0000L)>>16L)|((c&0xf0000000L)>>4L)); \
c&=0x0fffffffL; \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k0=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k1=ROTATE(t2,26U); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k2=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k3=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k4=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k5=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k6=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k7=ROTATE(t2,26U); \
c =  ((c>>2L)|(c<<26L)); \
d =  ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k8=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k9=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k10=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k11=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k12=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k13=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k14=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k15=ROTATE(t2,26U); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k16=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k17=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k18=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k19=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k20=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k21=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k22=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k23=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k24=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k25=ROTATE(t2,26U); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k26=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k27=ROTATE(t2,26U);  \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k28=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k29=ROTATE(t2,26U); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6L)&0x03)|((c>> 7L)&0x3c)]|des_skb[2][((c>>13L)&0x0f)|((c>>14L)&0x30)]|des_skb[3][((c>>20L)&0x01)|((c>>21L)&0x06)|((c>>22L)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7L)&0x03)|((d>> 8L)&0x3c)]|des_skb[6][((d>>15L)&0x3f)]|des_skb[7][((d>>21L)&0x0f)|((d>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k30=ROTATE(t2,30U); \
t2=((s>>16L)|(t&0xffff0000L)); \
k31=ROTATE(t2,26U); \
}




void oracle_old_long1( __global uint2 *hashes, const uint4 input, const uint size,  __global uint4 *plains,  __global uint *found,  uint4 singlehash, uint k, uint16 salt,__local uint DES_SPtrans[8][64],__local uint des_skb[8][64]) 
{  
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,cbase1,t0,t1,xx0,xx1,xx2,xx3;
uint id=0;
uint i,j,bli1,bli2,blo11,blo12,blo21,blo22,blo31,blo32,blo41,blo42;
uint o11,o12,o21,o22,o31,o32,o41,o42;
uint u1,u2,u3,u4,u5,u6,u7,u8;
uint ii,ia,ib,ic;
uint l,r,t,u;
uint ll1,ll2;
uint key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31;
uint c,d,s,t2; 

ia = (k&255);
ib = (k>>8)&255;
ic = (k>>16)&255;
cbase1=(k>>24);
xx0=k;
xx1=input.y;
xx2=input.z;
xx3=input.w;

w0 = (uint)salt.s0;
w1 = (uint)salt.s1;
w2 = (uint)salt.s2;
w3 = (uint)salt.s3;
w4 = (uint)salt.s4;
w5 = (uint)salt.s5;
w6 = (uint)salt.s6;
w7 = (uint)salt.s7;
w8 = (uint)salt.s8;
w9 = (uint)salt.s9;
w10 = (uint)salt.sA;


if (salt.sE==1) {w0|=(ia<<24);w1=(ib<<8)|(ic<<24);w2|=(cbase1<<8);}
else if (salt.sE==2) {w1=(ia<<8)|(ib<<24);w2=(ic<<8)|(cbase1<<24);}
else if (salt.sE==3) {w1|=(ia<<24);w2=(ib<<8)|(ic<<24);w3|=(cbase1<<8);}
else if (salt.sE==4) {w2=(ia<<8)|(ib<<24);w3=(ic<<8)|(cbase1<<24);}
else if (salt.sE==5) {w2|=(ia<<24);w3=(ib<<8)|(ic<<24);w4|=(cbase1<<8);}
else if (salt.sE==6) {w3=(ia<<8)|(ib<<24);w4=(uint)(ic<<8)|(cbase1<<24);}
else if (salt.sE==7) {w3|=(ia<<24);w4=(ib<<8)|(ic<<24);w5|=(cbase1<<8);}
else if (salt.sE==8) {w4=(ia<<8)|(ib<<24);w5=(ic<<8)|(cbase1<<24);}
else if (salt.sE==9) {w4|=(ia<<24);w5=(ib<<8)|(ic<<24);w6|=(cbase1<<8);}
else if (salt.sE==10) {w5=(ia<<8)|(ib<<24);w6=(ic<<8)|(cbase1<<24);}
else if (salt.sE==11) {w5|=(ia<<24);w6=(ib<<8)|(ic<<24);w7|=(cbase1<<8);}
else if (salt.sE==12) {w6=(ia<<8)|(ib<<24);w7=(ic<<8)|(cbase1<<24);}

salt.sF-=1;


DES_SPtrans[0][get_local_id(0)]=CDES_SPtrans[0][get_local_id(0)];
DES_SPtrans[1][get_local_id(0)]=CDES_SPtrans[1][get_local_id(0)];
DES_SPtrans[2][get_local_id(0)]=CDES_SPtrans[2][get_local_id(0)];
DES_SPtrans[3][get_local_id(0)]=CDES_SPtrans[3][get_local_id(0)];
DES_SPtrans[4][get_local_id(0)]=CDES_SPtrans[4][get_local_id(0)];
DES_SPtrans[5][get_local_id(0)]=CDES_SPtrans[5][get_local_id(0)];
DES_SPtrans[6][get_local_id(0)]=CDES_SPtrans[6][get_local_id(0)];
DES_SPtrans[7][get_local_id(0)]=CDES_SPtrans[7][get_local_id(0)];

des_skb[0][get_local_id(0)]=cdes_skb[0][get_local_id(0)];
des_skb[1][get_local_id(0)]=cdes_skb[1][get_local_id(0)];
des_skb[2][get_local_id(0)]=cdes_skb[2][get_local_id(0)];
des_skb[3][get_local_id(0)]=cdes_skb[3][get_local_id(0)];
des_skb[4][get_local_id(0)]=cdes_skb[4][get_local_id(0)];
des_skb[5][get_local_id(0)]=cdes_skb[5][get_local_id(0)];
des_skb[6][get_local_id(0)]=cdes_skb[6][get_local_id(0)];
des_skb[7][get_local_id(0)]=cdes_skb[7][get_local_id(0)];
mem_fence(CLK_LOCAL_MEM_FENCE);




if ((salt.sF>>3)==0)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint)blo11,(uint)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}

else if ((salt.sF>>3)==1)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint)blo11,(uint)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==2)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint)blo11,(uint)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==3)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint)blo11,(uint)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else return;

if ((blo11!=(uint)singlehash.x)) return;
if ((blo12!=(uint)singlehash.y)) return;


uint res = atomic_inc(found);
hashes[res] = (uint2)(blo11,blo12);

plains[res] = (uint4)(xx0,xx1,xx2,xx3);

}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_double( __global uint2 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];


SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);


input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
oracle_old_long1(hashes,input, size, plains,  found, singlehash,k,chbase4,DES_SPtrans,des_skb);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_normal( __global uint2 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint i;
uint j,k;
uint c0,x0;
uint d0,d1,d2;
uint t1,t2,t3;
uint x1,SIZE;
uint c1,c2,x2;
uint t4;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];



SIZE = (uint)(size); 
i=table[get_global_id(0)]<<16;
j=table[get_global_id(1)];
k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);

}



#endif

#if (!OLD_ATI && !GCN)

#define PERM_OP(a,b,t,n,m) {(t)=((((a)>>(n))^(b))&(m)); \
        (b)^=(t); \
        (a)^=((t)<<(n));}

#define HPERM_OP(a,t,n,m) {(t)=((((a)<<(16-(n)))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(16-(n)));}

#define HPERM_OP1(a,t,n,m) {(t)=((((a)<<(18))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(18));}


#define IP(l,r) \
        { \
        uint2 tt; \
        PERM_OP(r,l,tt, 4,0x0f0f0f0fL); \
        PERM_OP(l,r,tt,16,0x0000ffffL); \
        PERM_OP(r,l,tt, 2,0x33333333L); \
        PERM_OP(l,r,tt, 8,0x00ff00ffL); \
        PERM_OP(r,l,tt, 1,0x55555555L); \
        }

#define FP(l,r) \
        { \
        uint2 tt; \
        PERM_OP(l,r,tt, 1,0x55555555L); \
        PERM_OP(r,l,tt, 8,0x00ff00ffL); \
        PERM_OP(l,r,tt, 2,0x33333333L); \
        PERM_OP(r,l,tt,16,0x0000ffffL); \
        PERM_OP(l,r,tt, 4,0x0f0f0f0fL); \
        }


#define D_ENCRYPT(LL,R,S,SS1,SS2) {\
        u=R^SS1; \
        t=R^SS2; \
        t=ROTATE(t,4); \
        LL.x^=\
        DES_SPtrans[0][(u.x>> 2L)&0x3f]^ \
        DES_SPtrans[2][(u.x>>10L)&0x3f]^ \
        DES_SPtrans[4][(u.x>>18L)&0x3f]^ \
        DES_SPtrans[6][(u.x>>26L)&0x3f]^ \
        DES_SPtrans[1][(t.x>> 2L)&0x3f]^ \
        DES_SPtrans[3][(t.x>>10L)&0x3f]^ \
        DES_SPtrans[5][(t.x>>18L)&0x3f]^ \
        DES_SPtrans[7][(t.x>>26L)&0x3f]; \
        LL.y^=\
        DES_SPtrans[0][(u.y>> 2L)&0x3f]^ \
        DES_SPtrans[2][(u.y>>10L)&0x3f]^ \
        DES_SPtrans[4][(u.y>>18L)&0x3f]^ \
        DES_SPtrans[6][(u.y>>26L)&0x3f]^ \
        DES_SPtrans[1][(t.y>> 2L)&0x3f]^ \
        DES_SPtrans[3][(t.y>>10L)&0x3f]^ \
        DES_SPtrans[5][(t.y>>18L)&0x3f]^ \
        DES_SPtrans[7][(t.y>>26L)&0x3f];} \


#define ROTATE(a,n)     rotate(a,32-n)





#define DES_encrypt1(data1,data2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) { \
r=data1; \
l=data2; \
IP(r,l); \
r=ROTATE(r,29); \
l=ROTATE(l,29); \
D_ENCRYPT(l,r,0,k0,k1); \
D_ENCRYPT(r,l,2,k2,k3); \
D_ENCRYPT(l,r,4,k4,k5); \
D_ENCRYPT(r,l,6,k6,k7); \
D_ENCRYPT(l,r,8,k8,k9); \
D_ENCRYPT(r,l,10,k10,k11); \
D_ENCRYPT(l,r,12,k12,k13); \
D_ENCRYPT(r,l,14,k14,k15); \
D_ENCRYPT(l,r,16,k16,k17); \
D_ENCRYPT(r,l,18,k18,k19); \
D_ENCRYPT(l,r,20,k20,k21); \
D_ENCRYPT(r,l,22,k22,k23); \
D_ENCRYPT(l,r,24,k24,k25); \
D_ENCRYPT(r,l,26,k26,k27); \
D_ENCRYPT(l,r,28,k28,k29); \
D_ENCRYPT(r,l,30,k30,k31); \
l=ROTATE(l,3); \
r=ROTATE(r,3); \
FP(r,l); \
data1=l; \
data2=r; \
}




#define DES_ecb_encrypt_orcl(r1,r2,output1,output2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
ll1=r1; \
ll2=r2; \
DES_encrypt1(ll1,ll2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31); \
output1 = ll1; \
output2 = ll2; \
} 



#define DES_set_key_orcl(k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
key0=(uint2)1684312128; key1=(uint2)1120813258; key2=(uint2)345020504; \
key3=(uint2)1183417734; key4=(uint2)3300149384; key5=(uint2)2214923140; \
key6=(uint2)2425676856; key7=(uint2)2172944718; key8=(uint2)3634365680; \
key9=(uint2)97257220; key10=(uint2)2834311184; key11=(uint2)17269962; \
key12=(uint2)3359656152; key13=(uint2)122322950; key14=(uint2)1758987432; \
key15=(uint2)117555656; key16=(uint2)76604428; key17=(uint2)3444130569; \
key18=(uint2)2887266340; key19=(uint2)3368945540; key20=(uint2)616594448; \
key21=(uint2)3247179909; key22=(uint2)2357772344; key23=(uint2)2324319362; \
key24=(uint2)3225995300; key25=(uint2)3246424963; key26=(uint2)1275359400; \
key27=(uint2)193380875; key28=(uint2)1480597684; key29=(uint2)3360295242; \
key30=(uint2)7613516; key31=(uint2)3456896068; \
}

#define DES_set_key_orcl_cust(r1,r2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
d=c=t=s=t2=0; \
c=r1; \
d=r2; \
PERM_OP (d,c,t,4,0x0f0f0f0f); \
HPERM_OP1(c,t,-2,0xcccc0000); \
HPERM_OP1(d,t,-2,0xcccc0000); \
PERM_OP (d,c,t,1,0x55555555); \
PERM_OP (c,d,t,8,0x00ff00ff); \
PERM_OP (d,c,t,1,0x55555555); \
d=(((d&0x000000ffL)<<16L)| (d&0x0000ff00L) | ((d&0x00ff0000L)>>16L)|((c&0xf0000000L)>>4L)); \
c&=0x0fffffffL; \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k0=ROTATE(t2,30); \
t2=((s>>16)|(t&0xffff0000)); \
k1=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k2=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k3=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k4=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k5=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k6=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k7=ROTATE(t2,26); \
c =  ((c>>2L)|(c<<26L)); \
d =  ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k8=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k9=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k10=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k11=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k12=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k13=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k14=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k15=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k16=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k17=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k18=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k19=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k20=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k21=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k22=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k23=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k24=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k25=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k26=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k27=ROTATE(t2,26);  \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k28=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k29=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k30=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k31=ROTATE(t2,26); \
}


void oracle_old_long1( __global uint2 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *found,  uint4 singlehash,uint2 k, uint16 salt,__local uint DES_SPtrans[8][64],__local uint des_skb[8][64]) 
{
uint2 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,cbase1,t0,t1,xx0,xx1,xx2,xx3;
uint id=0;
uint2 i,j,bli1,bli2,blo11,blo12,blo21,blo22,blo31,blo32,blo41,blo42;
uint2 o11,o12,o21,o22,o31,o32,o41,o42;
uint u1,u2,u3,u4,u5,u6,u7,u8;
uint2 ii,ia,ib,ic;
uint2 l,r,t,u;
uint2 ll1,ll2;
uint2 key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31;
uint2 c,d,s,t2; 

ia = (k&255);
ib = (k>>8)&255;
ic = (k>>16)&255;
cbase1=(k>>24);
xx0=k;
xx1=input.y;
xx2=input.z;
xx3=input.w;

w0 = (uint2)salt.s0;
w1 = (uint2)salt.s1;
w2 = (uint2)salt.s2;
w3 = (uint2)salt.s3;
w4 = (uint2)salt.s4;
w5 = (uint2)salt.s5;
w6 = (uint2)salt.s6;
w7 = (uint2)salt.s7;
w8 = (uint2)salt.s8;
w9 = (uint2)salt.s9;
w10 = (uint2)salt.sA;


if (salt.sE==1) {w0|=(ia<<24);w1=(ib<<8)|(ic<<24);w2|=(cbase1<<8);}
else if (salt.sE==2) {w1=(ia<<8)|(ib<<24);w2=(ic<<8)|(cbase1<<24);}
else if (salt.sE==3) {w1|=(ia<<24);w2=(ib<<8)|(ic<<24);w3|=(cbase1<<8);}
else if (salt.sE==4) {w2=(ia<<8)|(ib<<24);w3=(ic<<8)|(cbase1<<24);}
else if (salt.sE==5) {w2|=(ia<<24);w3=(ib<<8)|(ic<<24);w4|=(cbase1<<8);}
else if (salt.sE==6) {w3=(ia<<8)|(ib<<24);w4=(uint2)(ic<<8)|(cbase1<<24);}
else if (salt.sE==7) {w3|=(ia<<24);w4=(ib<<8)|(ic<<24);w5|=(cbase1<<8);}
else if (salt.sE==8) {w4=(ia<<8)|(ib<<24);w5=(ic<<8)|(cbase1<<24);}
else if (salt.sE==9) {w4|=(ia<<24);w5=(ib<<8)|(ic<<24);w6|=(cbase1<<8);}
else if (salt.sE==10) {w5=(ia<<8)|(ib<<24);w6=(ic<<8)|(cbase1<<24);}
else if (salt.sE==11) {w5|=(ia<<24);w6=(ib<<8)|(ic<<24);w7|=(cbase1<<8);}
else if (salt.sE==12) {w6=(ia<<8)|(ib<<24);w7=(ic<<8)|(cbase1<<24);}

salt.sF-=1;


DES_SPtrans[0][get_local_id(0)]=CDES_SPtrans[0][get_local_id(0)];
DES_SPtrans[1][get_local_id(0)]=CDES_SPtrans[1][get_local_id(0)];
DES_SPtrans[2][get_local_id(0)]=CDES_SPtrans[2][get_local_id(0)];
DES_SPtrans[3][get_local_id(0)]=CDES_SPtrans[3][get_local_id(0)];
DES_SPtrans[4][get_local_id(0)]=CDES_SPtrans[4][get_local_id(0)];
DES_SPtrans[5][get_local_id(0)]=CDES_SPtrans[5][get_local_id(0)];
DES_SPtrans[6][get_local_id(0)]=CDES_SPtrans[6][get_local_id(0)];
DES_SPtrans[7][get_local_id(0)]=CDES_SPtrans[7][get_local_id(0)];

des_skb[0][get_local_id(0)]=cdes_skb[0][get_local_id(0)];
des_skb[1][get_local_id(0)]=cdes_skb[1][get_local_id(0)];
des_skb[2][get_local_id(0)]=cdes_skb[2][get_local_id(0)];
des_skb[3][get_local_id(0)]=cdes_skb[3][get_local_id(0)];
des_skb[4][get_local_id(0)]=cdes_skb[4][get_local_id(0)];
des_skb[5][get_local_id(0)]=cdes_skb[5][get_local_id(0)];
des_skb[6][get_local_id(0)]=cdes_skb[6][get_local_id(0)];
des_skb[7][get_local_id(0)]=cdes_skb[7][get_local_id(0)];
mem_fence(CLK_LOCAL_MEM_FENCE);




if ((salt.sF>>3)==0)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}

else if ((salt.sF>>3)==1)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==2)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==3)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}
else return;


if (all(blo11!=(uint2)singlehash.x)) return;
if (all(blo12!=(uint2)singlehash.y)) return;


uint res = atomic_inc(found);
hashes[res*2] = (uint2)(blo11.x,blo12.x);
hashes[res*2+1] = (uint2)(blo11.y,blo12.y);

plains[res*2] = (uint4)(xx0.s0,xx1.s0,xx2.s0,xx3.s0);
plains[res*2+1] = (uint4)(xx0.s1,xx1.s1,xx2.s1,xx3.s1);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_double( __global uint2 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint2 i;
uint j;
uint2 k;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];

i.s0=table[get_global_id(1)*2];
i.s1=table[get_global_id(1)*2+1];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
{
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);
}

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
{
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase4,DES_SPtrans,des_skb);
}
}




__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint2 i,k;
uint j;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];

i.s0=table[get_global_id(1)*2];
i.s1=table[get_global_id(1)*2+1];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);
}

#endif
#ifdef OLD_ATI

#define PERM_OP(a,b,t,n,m) {(t)=((((a)>>(n))^(b))&(m)); \
        (b)^=(t); \
        (a)^=((t)<<(n));}

#define HPERM_OP(a,t,n,m) {(t)=((((a)<<(16-(n)))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(16-(n)));}

#define HPERM_OP1(a,t,n,m) {(t)=((((a)<<(18))^(a))&(m)); \
        (a)=(a)^(t)^(t>>(18));}


#define IP(l,r) \
        { \
        uint2 tt; \
        PERM_OP(r,l,tt, 4,0x0f0f0f0fL); \
        PERM_OP(l,r,tt,16,0x0000ffffL); \
        PERM_OP(r,l,tt, 2,0x33333333L); \
        PERM_OP(l,r,tt, 8,0x00ff00ffL); \
        PERM_OP(r,l,tt, 1,0x55555555L); \
        }

#define FP(l,r) \
        { \
        uint2 tt; \
        PERM_OP(l,r,tt, 1,0x55555555L); \
        PERM_OP(r,l,tt, 8,0x00ff00ffL); \
        PERM_OP(l,r,tt, 2,0x33333333L); \
        PERM_OP(r,l,tt,16,0x0000ffffL); \
        PERM_OP(l,r,tt, 4,0x0f0f0f0fL); \
        }


#define D_ENCRYPT(LL,R,S,SS1,SS2) {\
        u=R^SS1; \
        t=R^SS2; \
        t=ROTATE(t,4); \
        LL.x^=\
        DES_SPtrans[0][(u.x>> 2L)&0x3f]^ \
        DES_SPtrans[2][(u.x>>10L)&0x3f]^ \
        DES_SPtrans[4][(u.x>>18L)&0x3f]^ \
        DES_SPtrans[6][(u.x>>26L)&0x3f]^ \
        DES_SPtrans[1][(t.x>> 2L)&0x3f]^ \
        DES_SPtrans[3][(t.x>>10L)&0x3f]^ \
        DES_SPtrans[5][(t.x>>18L)&0x3f]^ \
        DES_SPtrans[7][(t.x>>26L)&0x3f]; \
        LL.y^=\
        DES_SPtrans[0][(u.y>> 2L)&0x3f]^ \
        DES_SPtrans[2][(u.y>>10L)&0x3f]^ \
        DES_SPtrans[4][(u.y>>18L)&0x3f]^ \
        DES_SPtrans[6][(u.y>>26L)&0x3f]^ \
        DES_SPtrans[1][(t.y>> 2L)&0x3f]^ \
        DES_SPtrans[3][(t.y>>10L)&0x3f]^ \
        DES_SPtrans[5][(t.y>>18L)&0x3f]^ \
        DES_SPtrans[7][(t.y>>26L)&0x3f];} \


#define ROTATE(a,n)     rotate(a,32-n)





#define DES_encrypt1(data1,data2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) { \
r=data1; \
l=data2; \
IP(r,l); \
r=ROTATE(r,29); \
l=ROTATE(l,29); \
D_ENCRYPT(l,r,0,k0,k1); \
D_ENCRYPT(r,l,2,k2,k3); \
D_ENCRYPT(l,r,4,k4,k5); \
D_ENCRYPT(r,l,6,k6,k7); \
D_ENCRYPT(l,r,8,k8,k9); \
D_ENCRYPT(r,l,10,k10,k11); \
D_ENCRYPT(l,r,12,k12,k13); \
D_ENCRYPT(r,l,14,k14,k15); \
D_ENCRYPT(l,r,16,k16,k17); \
D_ENCRYPT(r,l,18,k18,k19); \
D_ENCRYPT(l,r,20,k20,k21); \
D_ENCRYPT(r,l,22,k22,k23); \
D_ENCRYPT(l,r,24,k24,k25); \
D_ENCRYPT(r,l,26,k26,k27); \
D_ENCRYPT(l,r,28,k28,k29); \
D_ENCRYPT(r,l,30,k30,k31); \
l=ROTATE(l,3); \
r=ROTATE(r,3); \
FP(r,l); \
data1=l; \
data2=r; \
}




#define DES_ecb_encrypt_orcl(r1,r2,output1,output2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
ll1=r1; \
ll2=r2; \
DES_encrypt1(ll1,ll2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31); \
output1 = ll1; \
output2 = ll2; \
} 



#define DES_set_key_orcl(k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
key0=(uint2)1684312128; key1=(uint2)1120813258; key2=(uint2)345020504; \
key3=(uint2)1183417734; key4=(uint2)3300149384; key5=(uint2)2214923140; \
key6=(uint2)2425676856; key7=(uint2)2172944718; key8=(uint2)3634365680; \
key9=(uint2)97257220; key10=(uint2)2834311184; key11=(uint2)17269962; \
key12=(uint2)3359656152; key13=(uint2)122322950; key14=(uint2)1758987432; \
key15=(uint2)117555656; key16=(uint2)76604428; key17=(uint2)3444130569; \
key18=(uint2)2887266340; key19=(uint2)3368945540; key20=(uint2)616594448; \
key21=(uint2)3247179909; key22=(uint2)2357772344; key23=(uint2)2324319362; \
key24=(uint2)3225995300; key25=(uint2)3246424963; key26=(uint2)1275359400; \
key27=(uint2)193380875; key28=(uint2)1480597684; key29=(uint2)3360295242; \
key30=(uint2)7613516; key31=(uint2)3456896068; \
}

#define DES_set_key_orcl_cust(r1,r2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
d=c=t=s=t2=0; \
c=r1; \
d=r2; \
PERM_OP (d,c,t,4,0x0f0f0f0f); \
HPERM_OP1(c,t,-2,0xcccc0000); \
HPERM_OP1(d,t,-2,0xcccc0000); \
PERM_OP (d,c,t,1,0x55555555); \
PERM_OP (c,d,t,8,0x00ff00ff); \
PERM_OP (d,c,t,1,0x55555555); \
d=(((d&0x000000ffL)<<16L)| (d&0x0000ff00L) | ((d&0x00ff0000L)>>16L)|((c&0xf0000000L)>>4L)); \
c&=0x0fffffffL; \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k0=ROTATE(t2,30); \
t2=((s>>16)|(t&0xffff0000)); \
k1=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k2=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k3=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k4=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k5=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k6=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k7=ROTATE(t2,26); \
c =  ((c>>2L)|(c<<26L)); \
d =  ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k8=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k9=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k10=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k11=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k12=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k13=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k14=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k15=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k16=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k17=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k18=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k19=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k20=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k21=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k22=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k23=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k24=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k25=ROTATE(t2,26); \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k26=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k27=ROTATE(t2,26);  \
c = ((c>>2L)|(c<<26L)); \
d = ((d>>2L)|(d<<26L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k28=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k29=ROTATE(t2,26); \
c = ((c>>1L)|(c<<27L)); \
d = ((d>>1L)|(d<<27L)); \
c&=0x0fffffffL; \
d&=0x0fffffffL; \
s.x=des_skb[0][(c.x)&0x3f]|des_skb[1][((c.x>> 6L)&0x03)|((c.x>> 7L)&0x3c)]|des_skb[2][((c.x>>13L)&0x0f)|((c.x>>14L)&0x30)]|des_skb[3][((c.x>>20L)&0x01)|((c.x>>21L)&0x06)|((c.x>>22L)&0x38)];  \
t.x=des_skb[4][(d.x)&0x3f]|des_skb[5][((d.x>> 7L)&0x03)|((d.x>> 8L)&0x3c)]|des_skb[6][((d.x>>15L)&0x3f)]|des_skb[7][((d.x>>21L)&0x0f)|((d.x>>22L)&0x30)]; \
s.y=des_skb[0][(c.y)&0x3f]|des_skb[1][((c.y>> 6L)&0x03)|((c.y>> 7L)&0x3c)]|des_skb[2][((c.y>>13L)&0x0f)|((c.y>>14L)&0x30)]|des_skb[3][((c.y>>20L)&0x01)|((c.y>>21L)&0x06)|((c.y>>22L)&0x38)];  \
t.y=des_skb[4][(d.y)&0x3f]|des_skb[5][((d.y>> 7L)&0x03)|((d.y>> 8L)&0x3c)]|des_skb[6][((d.y>>15L)&0x3f)]|des_skb[7][((d.y>>21L)&0x0f)|((d.y>>22L)&0x30)]; \
t2=((t<<16L)|(s&0x0000ffffL)); \
k30=ROTATE(t2,30); \
t2=((s>>16L)|(t&0xffff0000L)); \
k31=ROTATE(t2,26); \
}


void oracle_old_long1( __global uint2 *hashes, const uint4 input, const uint size,  __global uint4 *plains, __global uint *found,  uint4 singlehash,uint2 k, uint16 salt,__local uint DES_SPtrans[8][64],__local uint des_skb[8][64]) 
{
uint2 w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,cbase1,t0,t1,xx0,xx1,xx2,xx3;
uint id=0;
uint2 i,j,bli1,bli2,blo11,blo12,blo21,blo22,blo31,blo32,blo41,blo42;
uint2 o11,o12,o21,o22,o31,o32,o41,o42;
uint u1,u2,u3,u4,u5,u6,u7,u8;
uint2 ii,ia,ib,ic;
uint2 l,r,t,u;
uint2 ll1,ll2;
uint2 key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31;
uint2 c,d,s,t2; 

ia = (k&255);
ib = (k>>8)&255;
ic = (k>>16)&255;
cbase1=(k>>24);
xx0=k;
xx1=input.y;
xx2=input.z;
xx3=input.w;

w0 = (uint2)salt.s0;
w1 = (uint2)salt.s1;
w2 = (uint2)salt.s2;
w3 = (uint2)salt.s3;
w4 = (uint2)salt.s4;
w5 = (uint2)salt.s5;
w6 = (uint2)salt.s6;
w7 = (uint2)salt.s7;
w8 = (uint2)salt.s8;
w9 = (uint2)salt.s9;
w10 = (uint2)salt.sA;


if (salt.sE==1) {w0|=(ia<<24);w1=(ib<<8)|(ic<<24);w2|=(cbase1<<8);}
else if (salt.sE==2) {w1=(ia<<8)|(ib<<24);w2=(ic<<8)|(cbase1<<24);}
else if (salt.sE==3) {w1|=(ia<<24);w2=(ib<<8)|(ic<<24);w3|=(cbase1<<8);}
else if (salt.sE==4) {w2=(ia<<8)|(ib<<24);w3=(ic<<8)|(cbase1<<24);}
else if (salt.sE==5) {w2|=(ia<<24);w3=(ib<<8)|(ic<<24);w4|=(cbase1<<8);}
else if (salt.sE==6) {w3=(ia<<8)|(ib<<24);w4=(uint2)(ic<<8)|(cbase1<<24);}
else if (salt.sE==7) {w3|=(ia<<24);w4=(ib<<8)|(ic<<24);w5|=(cbase1<<8);}
else if (salt.sE==8) {w4=(ia<<8)|(ib<<24);w5=(ic<<8)|(cbase1<<24);}
else if (salt.sE==9) {w4|=(ia<<24);w5=(ib<<8)|(ic<<24);w6|=(cbase1<<8);}
else if (salt.sE==10) {w5=(ia<<8)|(ib<<24);w6=(ic<<8)|(cbase1<<24);}
else if (salt.sE==11) {w5|=(ia<<24);w6=(ib<<8)|(ic<<24);w7|=(cbase1<<8);}
else if (salt.sE==12) {w6=(ia<<8)|(ib<<24);w7=(ic<<8)|(cbase1<<24);}

salt.sF-=1;


DES_SPtrans[0][get_local_id(0)]=CDES_SPtrans[0][get_local_id(0)];
DES_SPtrans[1][get_local_id(0)]=CDES_SPtrans[1][get_local_id(0)];
DES_SPtrans[2][get_local_id(0)]=CDES_SPtrans[2][get_local_id(0)];
DES_SPtrans[3][get_local_id(0)]=CDES_SPtrans[3][get_local_id(0)];
DES_SPtrans[4][get_local_id(0)]=CDES_SPtrans[4][get_local_id(0)];
DES_SPtrans[5][get_local_id(0)]=CDES_SPtrans[5][get_local_id(0)];
DES_SPtrans[6][get_local_id(0)]=CDES_SPtrans[6][get_local_id(0)];
DES_SPtrans[7][get_local_id(0)]=CDES_SPtrans[7][get_local_id(0)];

des_skb[0][get_local_id(0)]=cdes_skb[0][get_local_id(0)];
des_skb[1][get_local_id(0)]=cdes_skb[1][get_local_id(0)];
des_skb[2][get_local_id(0)]=cdes_skb[2][get_local_id(0)];
des_skb[3][get_local_id(0)]=cdes_skb[3][get_local_id(0)];
des_skb[4][get_local_id(0)]=cdes_skb[4][get_local_id(0)];
des_skb[5][get_local_id(0)]=cdes_skb[5][get_local_id(0)];
des_skb[6][get_local_id(0)]=cdes_skb[6][get_local_id(0)];
des_skb[7][get_local_id(0)]=cdes_skb[7][get_local_id(0)];
mem_fence(CLK_LOCAL_MEM_FENCE);




if ((salt.sF>>3)==0)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}

else if ((salt.sF>>3)==1)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==2)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}


else if ((salt.sF>>3)==3)
{
t0=w0;
t1=w1;
DES_set_key_orcl(key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);

DES_set_key_orcl_cust((uint2)blo11,(uint2)blo12,key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=w0;
t1=w1;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w2;t1=blo12^w3;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w4;t1=blo12^w5;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
t0=blo11^w6;t1=blo12^w7;
DES_ecb_encrypt_orcl(t0,t1,blo11,blo12,  key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}
else return;


if (all(blo11!=(uint2)singlehash.x)) return;
if (all(blo12!=(uint2)singlehash.y)) return;


uint res = found[0];
found[0]++;
hashes[res*2] = (uint2)(blo11.x,blo12.x);
hashes[res*2+1] = (uint2)(blo11.y,blo12.y);

plains[res*2] = (uint4)(xx0.s0,xx1.s0,xx2.s0,xx3.s0);
plains[res*2+1] = (uint4)(xx0.s1,xx1.s1,xx2.s1,xx3.s1);

}



__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_double( __global uint2 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint *table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint2 i;
uint j;
uint2 k;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];

i.s0=table[get_global_id(1)*2];
i.s1=table[get_global_id(1)*2+1];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
{
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);
}

input=(uint4)(chbase1.s4,chbase1.s5,chbase1.s6,chbase1.s7);
singlehash=(uint4)(chbase2.s4,chbase2.s5,chbase2.s6,chbase2.s7);
{
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase4,DES_SPtrans,des_skb);
}
}


__kernel void  __attribute__((reqd_work_group_size(64, 1, 1))) 
oracle_old_long_normal( __global uint4 *hashes,  const uint size,  __global uint4 *plains, __global uint *found, __global const  uint * table,const uint16 chbase1,  const uint16 chbase2,uint16 chbase3,uint16 chbase4,uint16 chbase5,uint16 chbase6) 
{
uint2 i,k;
uint j;
uint4 input;
uint4 singlehash; 
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];

i.s0=table[get_global_id(1)*2];
i.s1=table[get_global_id(1)*2+1];
j=table[get_global_id(0)]<<16;

k=(i|j);


input=(uint4)(chbase1.s0,chbase1.s1,chbase1.s2,chbase1.s3);
singlehash=(uint4)(chbase2.s0,chbase2.s1,chbase2.s2,chbase2.s3);
oracle_old_long1(hashes,input, size, plains, found, singlehash,k,chbase3,DES_SPtrans,des_skb);
}

#endif
