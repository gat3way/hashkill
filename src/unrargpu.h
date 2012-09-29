/*
 * This file is part of hashkill
 *
 * Based on clamav source
 * Copyright (C) 2005-2006 trog@uncon.org
 *
 * Based on the work of Alexander L. Roshal (C)
 *
 * The unRAR sources may be used in any software to handle RAR
 * archives without limitations free of charge, but cannot be used
 * to re-create the RAR compression algorithm, which is proprietary.
 * Distribution of modified unRAR sources in separate form or as a
 * part of other software is permitted, provided that it is clearly
 * stated in the documentation and source comments that the code may
 * not be used to develop a RAR (WinRAR) compatible archiver.
 *
 */

/*
                    unrar Exception

In addition, as a special exception, the author gives permission to
link the code of his release of hashkill with Rarlabs' "unrar"
library (or with modified versions of it that use the same license
as the "unrar" library), and distribute the linked executables. You
must obey the GNU General Public License in all respects for all of
the code used other than "unrar". If you modify this file, you may
extend this exception to your version of the file, but you are not
obligated to do so. If you do not wish to do so, delete this
exception statement from your version.
*/



#ifndef UNRAR_H
#define UNRAR_H 1


#include <sys/types.h>
#include <unistd.h>
#include <stdint.h>


#define FALSE (0)
#define TRUE (1)
#ifndef MIN
#define MIN(a,b) ((a < b) ? a : b)
#endif


#define RARVM_MEMSIZE	0x40000
#define RARVM_MEMMASK	(RARVM_MEMSIZE-1)

#define VM_GLOBALMEMADDR            0x3C000
#define VM_GLOBALMEMSIZE             0x2000
#define VM_FIXEDGLOBALSIZE               64
#define SIZEOF_MARKHEAD 7
#define SIZEOF_NEWMHD 13
#define SIZEOF_NEWLHD 32
#define SIZEOF_SHORTBLOCKHEAD 7
#define SIZEOF_LONGBLOCKHEAD 11
#define SIZEOF_SUBBLOCKHEAD 14
#define SIZEOF_COMMHEAD 13
#define SIZEOF_PROTECTHEAD 26
#define SIZEOF_AVHEAD 14
#define SIZEOF_SIGNHEAD 15
#define SIZEOF_UOHEAD 18
#define SIZEOF_MACHEAD 22
#define SIZEOF_EAHEAD 24
#define SIZEOF_BEEAHEAD 24
#define SIZEOF_STREAMHEAD 26

#define MHD_VOLUME		0x0001
#define MHD_COMMENT		0x0002
#define MHD_LOCK		0x0004
#define MHD_SOLID		0x0008
#define MHD_PACK_COMMENT	0x0010
#define MHD_NEWNUMBERING	0x0010
#define MHD_AV			0x0020
#define MHD_PROTECT		0x0040
#define MHD_PASSWORD		0x0080
#define MHD_FIRSTVOLUME		0x0100
#define MHD_ENCRYPTVER		0x0200

#define LHD_SPLIT_BEFORE	0x0001
#define LHD_SPLIT_AFTER		0x0002
#define LHD_PASSWORD		0x0004
#define LHD_COMMENT		0x0008
#define LHD_SOLID		0x0010

#define LONG_BLOCK         0x8000

#define NC                 299  /* alphabet = {0, 1, 2, ..., NC - 1} */
#define DC                 60
#define RC		    28
#define LDC		    17
#define BC		    20
#define HUFF_TABLE_SIZE    (NC+DC+RC+LDC)

#define MAX_BUF_SIZE        32768
#define MAXWINSIZE          0x400000
#define MAXWINMASK          (MAXWINSIZE-1)
#define LOW_DIST_REP_COUNT  16


struct unpack_data_tag;

typedef struct mark_header_tag
{
	unsigned char mark[SIZEOF_MARKHEAD];
} mark_header_t;

#ifndef HAVE_ATTRIB_PACKED
#define __attribute__(x)
#endif

#ifdef HAVE_PRAGMA_PACK
#pragma pack(1)
#endif

#ifdef HAVE_PRAGMA_PACK_HPPA
#pragma pack 1
#endif


typedef enum rarvm_commands
{
  VM_MOV,  VM_CMP,  VM_ADD,  VM_SUB,  VM_JZ,   VM_JNZ,  VM_INC,  VM_DEC,
  VM_JMP,  VM_XOR,  VM_AND,  VM_OR,   VM_TEST, VM_JS,   VM_JNS,  VM_JB,
  VM_JBE,  VM_JA,   VM_JAE,  VM_PUSH, VM_POP,  VM_CALL, VM_RET,  VM_NOT,
  VM_SHL,  VM_SHR,  VM_SAR,  VM_NEG,  VM_PUSHA,VM_POPA, VM_PUSHF,VM_POPF,
  VM_MOVZX,VM_MOVSX,VM_XCHG, VM_MUL,  VM_DIV,  VM_ADC,  VM_SBB,  VM_PRINT,
  VM_MOVB, VM_MOVD, VM_CMPB, VM_CMPD, VM_ADDB, VM_ADDD, VM_SUBB, VM_SUBD,
  VM_INCB, VM_INCD, VM_DECB, VM_DECD, VM_NEGB, VM_NEGD, VM_STANDARD
} rarvm_commands_t;

typedef enum rarvm_standard_filters {
  VMSF_NONE, VMSF_E8, VMSF_E8E9, VMSF_ITANIUM, VMSF_RGB, VMSF_AUDIO,
  VMSF_DELTA, VMSF_UPCASE
} rarvm_standard_filters_t;

enum VM_Flags {
	VM_FC=1,
	VM_FZ=2,
	VM_FS=0x80000000
};

enum rarvm_op_type {
	VM_OPREG,
	VM_OPINT,
	VM_OPREGMEM,
	VM_OPNONE
};


typedef enum
{
	ALL_HEAD=0,
	MARK_HEAD=0x72,
	MAIN_HEAD=0x73,
	FILE_HEAD=0x74,
	COMM_HEAD=0x75,
	AV_HEAD=0x76,
	SUB_HEAD=0x77,
	PROTECT_HEAD=0x78,
	SIGN_HEAD=0x79,
	NEWSUB_HEAD=0x7a,
	ENDARC_HEAD=0x7b
} header_type;

enum BLOCK_TYPES
{
	BLOCK_LZ,
	BLOCK_PPM
};

typedef struct rar_cmd_array_tag
{
	struct rarvm_prepared_command *array;
	size_t num_items;
} rar_cmd_array_t;

typedef struct rar_filter_array_tag
{
	struct UnpackFilter **array;
	size_t num_items;
} rar_filter_array_t;



struct rarvm_prepared_operand {
	enum rarvm_op_type type;
	unsigned int data;
	unsigned int base;
	unsigned int *addr;
};

struct rarvm_prepared_command {
	rarvm_commands_t op_code;
	int byte_mode;
	struct rarvm_prepared_operand op1, op2;
};

struct rarvm_prepared_program {
	rar_cmd_array_t cmd;
	struct rarvm_prepared_command *alt_cmd;
	int cmd_count;
	unsigned char *global_data;
	unsigned char *static_data;
	long global_size, static_size;
	unsigned int init_r[7];
	uint8_t *filtered_data;
	unsigned int filtered_data_size;
};

typedef struct rarvm_input_tag {
	unsigned char *in_buf;
	int buf_size;
	int in_addr;
	int in_bit;
} rarvm_input_t;

typedef struct rarvm_data_tag {
	uint8_t *mem;
	unsigned int R[8];
	unsigned int Flags;
} rarvm_data_t;


struct Decode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[2];
};

struct LitDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[NC];
};

struct DistDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[DC];
};

struct LowDistDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[LDC];
};

struct RepDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[RC];
};

struct BitDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[BC];
};

struct UnpackFilter
{
  unsigned int block_start;
  unsigned int block_length;
  unsigned int exec_count;
  int next_window;
  struct rarvm_prepared_program prg;
};

/* RAR2 structures */
#define MC20 257
struct MultDecode
{
  unsigned int MaxNum;
  unsigned int DecodeLen[16];
  unsigned int DecodePos[16];
  unsigned int DecodeNum[MC20];
};

struct AudioVariables
{
  int K1,K2,K3,K4,K5;
  int D1,D2,D3,D4;
  int last_delta;
  unsigned int dif[11];
  unsigned int byte_count;
  int last_char;
};
/* *************** */



#define N1 4
#define N2 4
#define N3 4
#define N4 26
#define N_INDEXES 38

typedef struct rar_mem_blk_tag
{
	uint16_t stamp, nu;
	struct rar_mem_blk_tag *next, *prev;
} rar_mem_blk_t;

struct rar_node
{
	struct rar_node *next;
};

typedef struct sub_allocator_tag
{
	long sub_allocator_size;
	int16_t indx2units[N_INDEXES], units2indx[128], glue_count;
	uint8_t *heap_start, *lo_unit, *hi_unit;
	struct rar_node free_list[N_INDEXES];
	
	uint8_t *ptext, *units_start, *heap_end, *fake_units_start;
} sub_allocator_t;

typedef struct range_coder_tag
{
	unsigned int low, code, range;
	unsigned int low_count, high_count, scale;
}range_coder_t;

struct ppm_context;

struct see2_context_tag
{
	uint16_t summ;
	uint8_t shift, count;
};

struct state_tag
{
	uint8_t symbol;
	uint8_t freq;
	struct ppm_context *successor;
};

struct freq_data_tag
{
	uint16_t summ_freq;
	struct state_tag *stats;
};

struct ppm_context {
	uint16_t num_stats;
	union {
		struct freq_data_tag u;
		struct state_tag one_state;
	} con_ut;
	struct ppm_context *suffix;
};

typedef struct ppm_data_tag
{
	sub_allocator_t sub_alloc;
	range_coder_t coder;
	int num_masked, init_esc, order_fall, max_order, run_length, init_rl;
	struct ppm_context *min_context, *max_context;
	struct state_tag *found_state;
	uint8_t char_mask[256], ns2indx[256], ns2bsindx[256], hb2flag[256];
	uint8_t esc_count, prev_success, hi_bits_flag;
	struct see2_context_tag see2cont[25][16], dummy_sse2cont;
	uint16_t bin_summ[128][64];
} ppm_data_t;





typedef struct unpack_data_tag
{
	int ofd;
	
	unsigned char in_buf[MAX_BUF_SIZE];
	uint8_t window[MAXWINSIZE];
	int in_addr;
	int in_bit;
	unsigned int unp_ptr;
	unsigned int wr_ptr;
	int tables_read;
	int read_top;
	int read_border;
	int unp_block_type;
	int prev_low_dist;
	int low_dist_rep_count;
	unsigned char unp_old_table[HUFF_TABLE_SIZE];
	struct LitDecode LD;
	struct DistDecode DD;
	struct LowDistDecode LDD;
	struct RepDecode RD;
	struct BitDecode BD;
	unsigned int old_dist[4];
	unsigned int old_dist_ptr;
	unsigned int last_dist;
	unsigned int last_length;
	ppm_data_t ppm_data;
	int ppm_esc_char;
	int ppm_error;
	rar_filter_array_t Filters;
	rar_filter_array_t PrgStack;
	int *old_filter_lengths;
	int last_filter, old_filter_lengths_size;
	int64_t written_size;
	int64_t dest_unp_size;
	uint32_t pack_size;
	rarvm_data_t rarvm_data;
	unsigned int unp_crc;
	
	/* RAR2 variables */
	int unp_cur_channel, unp_channel_delta, unp_audio_block, unp_channels;
	unsigned char unp_old_table20[MC20 * 4];
	struct MultDecode MD[4];
	struct AudioVariables audv[4];
	
	/* RAR1 variables */
	unsigned int  flag_buf, avr_plc, avr_plcb, avr_ln1, avr_ln2, avr_ln3;
	int buf60, num_huf, st_mode, lcount, flags_cnt;
	unsigned int nhfb, nlzb, max_dist3;
	unsigned int chset[256], chseta[256], chsetb[256], chsetc[256];
	unsigned int place[256], placea[256], placeb[256], placec[256];
	unsigned int ntopl[256], ntoplb[256], ntoplc[256];
} unpack_data_t;







unsigned int rarvm_getbits(rarvm_input_t *rarvm_input);
void rarvm_addbits(rarvm_input_t *rarvm_input, int bits);
int rarvm_init(rarvm_data_t *rarvm_data);
void rarvm_free(rarvm_data_t *rarvm_data);
int rarvm_prepare(rarvm_data_t *rarvm_data, rarvm_input_t *rarvm_input, unsigned char *code,
		int code_size, struct rarvm_prepared_program *prg);
void rarvm_set_memory(rarvm_data_t *rarvm_data, unsigned int pos, uint8_t *data, unsigned int data_size);
int rarvm_execute(rarvm_data_t *rarvm_data, struct rarvm_prepared_program *prg);
void rarvm_set_value(int byte_mode, unsigned int *addr, unsigned int value);
unsigned int rarvm_read_data(rarvm_input_t *rarvm_input);
uint32_t rar_crc(uint32_t start_crc, void *addr, uint32_t size);

int ppm_decode_init(unsigned char *key, unsigned char *iv,ppm_data_t *ppm_data, int fd, struct unpack_data_tag *unpack_data, int *EscChar);
int ppm_decode_init2(ppm_data_t *ppm_data, char *input, struct unpack_data_tag *unpack_data, int *EscChar);
int ppm_decode_char(unsigned char *key, unsigned char *iv,ppm_data_t *ppm_data, int fd, struct unpack_data_tag *unpack_data);
void ppm_constructor(ppm_data_t *ppm_data);
void ppm_destructor(ppm_data_t *ppm_data);
void *rar_malloc(size_t size);
void *rar_realloc2(void *ptr, size_t size);
void rar_filter_array_init(rar_filter_array_t *filter_a);
void rar_filter_array_reset(rar_filter_array_t *filter_a);
int rar_filter_array_add(rar_filter_array_t *filter_a, int num);
struct UnpackFilter *rar_filter_new(void);
void rar_filter_delete(struct UnpackFilter *filter);
void rar_cmd_array_init(rar_cmd_array_t *cmd_a);
void rar_cmd_array_reset(rar_cmd_array_t *cmd_a);
int rar_cmd_array_add(rar_cmd_array_t *cmd_a, int num);
unsigned int rar_get_char(unsigned char *key, unsigned char *iv,int fd, unpack_data_t *unpack_data);
void rar_addbits(unpack_data_t *unpack_data, int bits);
unsigned int rar_getbits(unpack_data_t *unpack_data);
int rar_unp_read_buf(unsigned char *key, unsigned char *iv,int fd, unpack_data_t *unpack_data);
void rar_unpack_init_data(int solid, unpack_data_t *unpack_data);
void rar_make_decode_tables(unsigned char *len_tab, struct Decode *decode, int size);
void rar_unp_write_buf_old(unpack_data_t *unpack_data);
int rar_decode_number(unpack_data_t *unpack_data, struct Decode *decode);
void rar_init_filters(unpack_data_t *unpack_data);
int rar_unpack(unsigned char *key, unsigned char *iv, char *buffer, int method, int solid, unpack_data_t *unpack_data,int filesize);
int rar_check(unsigned char *buffer, int solid, unpack_data_t *unpack_data);

#ifdef HAVE_PRAGMA_PACK
#pragma pack()
#endif

#ifdef HAVE_PRAGMA_PACK_HPPA
#pragma pack
#endif

#endif
