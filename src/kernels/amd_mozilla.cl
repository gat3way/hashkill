#define GGI (get_global_id(0))
#define GLI (get_local_id(0))

#define SET_AB(ai1,ai2,ii1,ii2) { \
    elem=ii1>>2; \
    temp1=(ii1&3)<<3; \
    ai1[elem] = ai1[elem]|(ai2<<(temp1)); \
    ai1[elem+1] = (temp1==0) ? 0 : ai2>>(32-temp1);\
}

#define Endian_Reverse32(aa) { l=(aa);tmp1=rotate(l,Sl);tmp2=rotate(l,Sr); (aa)=bitselect(tmp2,tmp1,m); }

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



__constant uint cdes_skb[8][64]=
{{
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


#define F_00_19(bb,cc,dd) (bitselect((dd),(cc),(bb)))
#define F_20_39(bb,cc,dd)  ((bb) ^ (cc) ^ (dd))  
#define F_40_59(bb,cc,dd) (bitselect((cc), (bb), ((dd)^(cc))))
#define F_60_79(bb,cc,dd)  F_20_39((bb),(cc),(dd)) 

#define S1 1U
#define S2 5U
#define S3 30U
#define Sl 8U
#define Sr 24U

#define ROTATE1(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + (x); (ee) = (ee) + K; (bb) = rotate((bb),S3) 
#define ROTATE1_NULL(aa, bb, cc, dd, ee)  (ee) = (ee) + rotate((aa),S2) + F_00_19((bb),(cc),(dd)) + K; (bb) = rotate((bb),S3)
#define ROTATE2_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_20_39((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3) 
#define ROTATE3_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_40_59((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)
#define ROTATE4_F(aa, bb, cc, dd, ee, x) (ee) = (ee) + rotate((aa),S2) + F_60_79((bb),(cc),(dd)) + (x) + K; (bb) = rotate((bb),S3)


__kernel void __attribute__((reqd_work_group_size(64, 1, 1))) 
strmodify( __global uint *dst,  __global uint *inp, __global uint *sizein, uint16 salt, uint16 str)
{
__local uint inpc[64][14];
uint SIZE;
uint elem,temp1;

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

SET_AB(inpc[GLI],0x80,(SIZE+str.sF),0);

dst[GGI*8+0] = inpc[GLI][0];
dst[GGI*8+1] = inpc[GLI][1];
dst[GGI*8+2] = inpc[GLI][2];
dst[GGI*8+3] = inpc[GLI][3];
dst[GGI*8+4] = inpc[GLI][4];
dst[GGI*8+5] = inpc[GLI][5];
dst[GGI*8+6] = inpc[GLI][6];
dst[GGI*8+7] = inpc[GLI][7];
sizein[GGI] = SIZE+str.sF;
}




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
        PERM_OP(r,l,tt, 4,0x0f0f0f0fU); \
        PERM_OP(l,r,tt,16,0x0000ffffU); \
        PERM_OP(r,l,tt, 2,0x33333333U); \
        PERM_OP(l,r,tt, 8,0x00ff00ffU); \
        PERM_OP(r,l,tt, 1,0x55555555U); \
        }

#define FP(l,r) \
        { \
        uint tt; \
        PERM_OP(l,r,tt, 1,0x55555555U); \
        PERM_OP(r,l,tt, 8,0x00ff00ffU); \
        PERM_OP(l,r,tt, 2,0x33333333U); \
        PERM_OP(r,l,tt,16,0x0000ffffU); \
        PERM_OP(l,r,tt, 4,0x0f0f0f0fU); \
        }

#define ROTATE(a,n) (rotate(a,32-n))

#define D_ENCRYPT(LL,R,S,SS1,SS2) {\
        u=R^SS1; \
        t=R^SS2; \
        t=ROTATE(t,4U); \
        LL^=\
        DES_SPtrans[0][(u>> 2U)&0x3f]^ \
        DES_SPtrans[2][(u>>10U)&0x3f]^ \
        DES_SPtrans[4][(u>>18U)&0x3f]^ \
        DES_SPtrans[6][(u>>26U)&0x3f]^ \
        DES_SPtrans[1][(t>> 2U)&0x3f]^ \
        DES_SPtrans[3][(t>>10U)&0x3f]^ \
        DES_SPtrans[5][(t>>18U)&0x3f]^ \
        DES_SPtrans[7][(t>>26U)&0x3f]; \
	}


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

#define DES_ecb_encrypt(input1,input2,output1,output2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
ll1=input1; \
ll2=input2; \
DES_encrypt1(ll1,ll2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31); \
output1 = ll1; \
output2 = ll2; \
} 


#define DES_decrypt1(data1,data2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) { \
r=data1; \
l=data2; \
IP(r,l); \
r=ROTATE(r,29U); \
l=ROTATE(l,29U); \
D_ENCRYPT(l,r,30,k30,k31); \
D_ENCRYPT(r,l,28,k28,k29); \
D_ENCRYPT(l,r,26,k26,k27); \
D_ENCRYPT(r,l,24,k24,k25); \
D_ENCRYPT(l,r,22,k22,k23); \
D_ENCRYPT(r,l,20,k20,k21); \
D_ENCRYPT(l,r,18,k18,k19); \
D_ENCRYPT(r,l,16,k16,k17); \
D_ENCRYPT(l,r,14,k14,k15); \
D_ENCRYPT(r,l,12,k12,k13); \
D_ENCRYPT(l,r,10,k10,k11); \
D_ENCRYPT(r,l,8,k8,k9); \
D_ENCRYPT(l,r,6,k6,k7); \
D_ENCRYPT(r,l,4,k4,k5); \
D_ENCRYPT(l,r,2,k2,k3); \
D_ENCRYPT(r,l,0,k0,k1); \
l=ROTATE(l,3U); \
r=ROTATE(r,3U); \
FP(r,l); \
data1=l; \
data2=r; \
}

#define DES_ecb_decrypt(input1,input2,output1,output2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
ll1=input1; \
ll2=input2; \
DES_decrypt1(ll1,ll2,k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31); \
output1 = ll1; \
output2 = ll2; \
} 


#define DES_set_key(in1, in2, k0,k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15,k16,k17,k18,k19,k20,k21,k22,k23,k24,k25,k26,k27,k28,k29,k30,k31) \
{ \
d=c=t=s=t2=0; \
c=in1; \
d=in2; \
PERM_OP (d,c,t,4,0x0f0f0f0f); \
HPERM_OP1(c,t,-2,0xcccc0000); \
HPERM_OP1(d,t,-2,0xcccc0000); \
PERM_OP (d,c,t,1,0x55555555); \
PERM_OP (c,d,t,8,0x00ff00ff); \
PERM_OP (d,c,t,1,0x55555555); \
d=(((d&0x000000ff)<<16)| (d&0x0000ff00) | ((d&0x00ff0000)>>16)|((c&0xf0000000)>>4)); \
c&=0x0fffffff; \
c = ((c>>1)|(c<<27)); \
d = ((d>>1)|(d<<27)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k0=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k1=ROTATE(t2,26U); \
c = ((c>>1)|(c<<27)); \
d = ((d>>1)|(d<<27)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30U)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k2=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k3=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k4=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k5=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k6=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k7=ROTATE(t2,26U); \
c =  ((c>>2)|(c<<26)); \
d =  ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k8=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k9=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k10=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k11=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k12=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k13=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k14=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k15=ROTATE(t2,26U); \
c = ((c>>1)|(c<<27)); \
d = ((d>>1)|(d<<27)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k16=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k17=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k18=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k19=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k20=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k21=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k22=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k23=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k24=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k25=ROTATE(t2,26U); \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k26=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k27=ROTATE(t2,26U);  \
c = ((c>>2)|(c<<26)); \
d = ((d>>2)|(d<<26)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k28=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k29=ROTATE(t2,26U); \
c = ((c>>1)|(c<<27)); \
d = ((d>>1)|(d<<27)); \
c&=0x0fffffff; \
d&=0x0fffffff; \
s=des_skb[0][(c)&0x3f]|des_skb[1][((c>> 6)&0x03)|((c>> 7)&0x3c)]|des_skb[2][((c>>13)&0x0f)|((c>>14)&0x30)]|des_skb[3][((c>>20)&0x01)|((c>>21)&0x06)|((c>>22)&0x38)];  \
t=des_skb[4][(d)&0x3f]|des_skb[5][((d>> 7)&0x03)|((d>> 8)&0x3c)]|des_skb[6][((d>>15)&0x3f)]|des_skb[7][((d>>21)&0x0f)|((d>>22)&0x30)]; \
t2=((t<<16)|(s&0x0000ffff)); \
k30=ROTATE(t2,30U); \
t2=((s>>16)|(t&0xffff0000)); \
k31=ROTATE(t2,26U); \
}




__kernel 
__attribute__((reqd_work_group_size(64, 1, 1)))
void prepare( __global uint4 *dst,  __global uint *input, __global uint *size,  __global uint *found_ind, __global uint *found, uint16 data1, uint16 data2)
{
uint m=0x00FF00FFU;
uint m2=0xFF00FF00U;
uint table1;
uint K0 = (uint)0x5A827999;
uint K1 = (uint)0x6ED9EBA1;
uint K2 = (uint)0x8F1BBCDC;
uint K3 = (uint)0xCA62C1D6;
uint H0 = (uint)0x67452301;
uint H1 = (uint)0xEFCDAB89;
uint H2 = (uint)0x98BADCFE;
uint H3 = (uint)0x10325476;
uint H4 = (uint)0xC3D2E1F0;
uint xx0,xx1,xx2,xx3;
uint w0,w1,w2,w3,w4,w5,w6,w7,w8,w9,w10,w11,w12,w13,w14,w16; 
uint i,ib,ic,id;  
uint A,B,C,D,E,F,G,H,K,l,tmp1,tmp2, SIZE; 
uint b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15;
uint IPA,IPB,IPC,IPD,IPE; 
uint OPA,OPB,OPC,OPD,OPE; 
uint NPA,NPB,NPC,NPD,NPE; 
uint j,bli1,bli2,blo11,blo12,blo21,blo22,blo31,blo32,blo41,blo42;
uint o11,o12,o21,o22,o31,o32,o41,o42;
uint u1,u2,u3,u4,u5,u6,u7,u8;
uint r,t,u;
uint ll1,ll2;
uint key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31;
uint c,d,s,t2;
__local uint DES_SPtrans[8][64];
__local uint des_skb[8][64];
uint keys[6];


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

A=input[(get_global_id(0)*8)+0];
B=input[(get_global_id(0)*8)+1];
C=input[(get_global_id(0)*8)+2];
D=input[(get_global_id(0)*8)+3];
E=input[(get_global_id(0)*8)+4];
F=input[(get_global_id(0)*8)+5];
G=input[(get_global_id(0)*8)+6];
H=input[(get_global_id(0)*8)+7];





SIZE = (uint)(size[get_global_id(0)]+20)<<3; 
w0 = data1.s4; 
w1 = data1.s5;
w2 = data1.s6;
w3 = data1.s7;
w4 = data1.s8;
w5 = A;
w6 = B;
w7 = C;
w8 = D;
w9 = E;
w10 = F;
w11 = G;
w12 = H;

w13=w14=w16=(uint)0;


A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  

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
ROTATE1_NULL(C, D, E, A, B);
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


SIZE = (uint)40<<3; 
w0 = A; 
w1 = B;
w2 = C;
w3 = D;
w4 = E;
w5 = data2.s4;
w6 = data2.s5;
w7 = data2.s6;
w8 = data2.s7;
w9 = data2.s8;
w10=0x80000000;
w11=w12=w13=w14=w16=(uint)0;


A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
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
ROTATE1(A, B, C, D, E, w10);
ROTATE1_NULL(E, A, B, C, D);
ROTATE1_NULL(D, E, A, B, C);
ROTATE1_NULL(C, D, E, A, B);
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

NPA=A+H0;NPB=B+H1;NPC=C+H2;NPD=D+H3;NPE=E+H4;


w0 = NPA^0x36363636U; 
w1 = NPB^0x36363636U;
w2 = NPC^0x36363636U;
w3 = NPD^0x36363636U;
w4 = NPE^0x36363636U;
w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x36363636U;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

IPA=A+H0;IPB=B+H1;IPC=C+H2;IPD=D+H3;IPE=E+H4;



w0 = NPA^0x5c5c5c5cU; 
w1 = NPB^0x5c5c5c5cU;
w2 = NPC^0x5c5c5c5cU;
w3 = NPD^0x5c5c5c5cU;
w4 = NPE^0x5c5c5c5cU;
w5=w6=w7=w8=w9=w10=w11=w12=w13=w14=SIZE=(uint)0x5c5c5c5cU;

A=H0;  
B=H1;  
C=H2;  
D=H3;  
E=H4;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

OPA=A+H0;OPB=B+H1;OPC=C+H2;OPD=D+H3;OPE=E+H4;



w0 = data2.s4; 
w1 = data2.s5; 
w2 = data2.s6; 
w3 = data2.s7; 
w4 = data2.s8; 
w5 = data2.s4; 
w6 = data2.s5; 
w7 = data2.s6; 
w8 = data2.s7; 
w9 = data2.s8; 
w10=0x80000000;
SIZE=(40+64)<<3;
w11=w12=w13=w14=(uint)0;

A=IPA;  
B=IPB;  
C=IPC;  
D=IPD;  
E=IPE;  

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
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;


w0 = A; 
w1 = B; 
w2 = C; 
w3 = D; 
w4 = E; 
w5=0x80000000;
SIZE=(20+64)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;

A=OPA;  
B=OPB;  
C=OPC;  
D=OPD;  
E=OPE;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

b0=A+OPA;b1=B+OPB;b2=C+OPC;b3=D+OPD;b4=E+OPE;





w0 = data2.s4; 
w1 = data2.s5; 
w2 = data2.s6; 
w3 = data2.s7; 
w4 = data2.s8; 
w5=0x80000000;
SIZE=(20+64)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;

A=IPA;  
B=IPB;  
C=IPC;  
D=IPD;  
E=IPE;  

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
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;


w0 = A; 
w1 = B; 
w2 = C; 
w3 = D; 
w4 = E; 
w5=0x80000000;
SIZE=(20+64)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;

A=OPA;  
B=OPB;  
C=OPC;  
D=OPD;  
E=OPE;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

A=A+OPA;B=B+OPB;C=C+OPC;D=D+OPD;E=E+OPE;



w0 = A; 
w1 = B; 
w2 = C; 
w3 = D; 
w4 = E; 
w5 = data2.s4; 
w6 = data2.s5; 
w7 = data2.s6; 
w8 = data2.s7; 
w9 = data2.s8; 
w10=0x80000000;
SIZE=(40+64)<<3;
w11=w12=w13=w14=(uint)0;

A=IPA;  
B=IPB;  
C=IPC;  
D=IPD;  
E=IPE;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
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
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

A=A+IPA;B=B+IPB;C=C+IPC;D=D+IPD;E=E+IPE;


w0 = A; 
w1 = B; 
w2 = C; 
w3 = D; 
w4 = E; 
w5=0x80000000;
SIZE=(20+64)<<3;
w6=w7=w8=w9=w10=w11=w12=w13=w14=(uint)0;

A=OPA;  
B=OPB;  
C=OPC;  
D=OPD;  
E=OPE;  

K = K0;
ROTATE1(A, B, C, D, E, w0);
ROTATE1(E, A, B, C, D, w1);
ROTATE1(D, E, A, B, C, w2);
ROTATE1(C, D, E, A, B, w3);
ROTATE1(B, C, D, E, A, w4);
ROTATE1(A, B, C, D, E, w5);
ROTATE1(E, A, B, C, D, w6);
ROTATE1(D, E, A, B, C, w7);
ROTATE1(C, D, E, A, B, w8);
ROTATE1(B, C, D, E, A, w9);
ROTATE1(A, B, C, D, E, w10);
ROTATE1(E, A, B, C, D, w11);
ROTATE1(D, E, A, B, C, w12);
ROTATE1(C, D, E, A, B, w13);
ROTATE1(B, C, D, E, A, w14);
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

b5=A+OPA;b6=B+OPB;b7=C+OPC;b8=D+OPD;b9=E+OPE;

Endian_Reverse32(b0);
Endian_Reverse32(b1);
Endian_Reverse32(b2);
Endian_Reverse32(b3);
Endian_Reverse32(b4);
Endian_Reverse32(b5);
Endian_Reverse32(b6);
Endian_Reverse32(b7);
Endian_Reverse32(b8);
Endian_Reverse32(b9);


keys[0]=b4;
keys[1]=b2;
keys[2]=b0;
keys[3]=b5;
keys[4]=b3;
keys[5]=b1;

blo11=data1.s9;
blo12=data1.sA;
blo21=data1.sB;
blo22=data1.sC;


for (i=0;i<3;i++)
{
DES_set_key(keys[i],keys[i+3], key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
if (i==1)
{
DES_ecb_encrypt(blo11,blo12,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_encrypt(blo21,blo22,blo21,blo22, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}
else
{
DES_ecb_decrypt(blo11,blo12,blo11,blo12, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
DES_ecb_decrypt(blo21,blo22,blo21,blo22, key0,key1,key2,key3,key4,key5,key6,key7,key8,key9,key10,key11,key12,key13,key14,key15,key16,key17,key18,key19,key20,key21,key22,key23,key24,key25,key26,key27,key28,key29,key30,key31);
}
}


blo11^=b8;
blo12^=b9;
blo21^=data1.s9;
blo22^=data1.sA;


if (blo11!=data2.s9) return;
if (blo12!=data2.sA) return;

found[0] = 1;
found_ind[get_global_id(0)] = 1;

dst[(get_global_id(0))] = (uint4)(blo11,blo12,blo21,blo22);

}



