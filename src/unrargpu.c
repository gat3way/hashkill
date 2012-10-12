/*
 *  unrargpu.c is part of hashkill 
 *
 *    Based on clamav unrar code
 *    Copyright (C) 2005-2006 trog@uncon.org
 *
 *  Based on the work of Alexander L. Roshal (C)
 *
 *  The unRAR sources may be used in any software to handle RAR
 *  archives without limitations free of charge, but cannot be used
 *  to re-create the RAR compression algorithm, which is proprietary.
 *  Distribution of modified unRAR sources in separate form or as a
 *  part of other software is permitted, provided that it is clearly
 *  stated in the documentation and source comments that the code may
 *  not be used to develop a RAR (WinRAR) compatible archiver.
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


#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
//#include <openssl/aes.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#include "unrargpu.h"
#include "cpu-feat.h"

#define int64to32(x) ((unsigned int)(x))
#define RAR_MAX_ALLOCATION 1024*1024*32

#define VMCF_OP0             0
#define VMCF_OP1             1
#define VMCF_OP2             2
#define VMCF_OPMASK          3
#define VMCF_BYTEMODE        4
#define VMCF_JUMP            8
#define VMCF_PROC           16
#define VMCF_USEFLAGS       32
#define VMCF_CHFLAGS        64

static uint8_t vm_cmdflags[]=
{
  /* VM_MOV   */ VMCF_OP2 | VMCF_BYTEMODE                                ,
  /* VM_CMP   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_ADD   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_SUB   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_JZ    */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JNZ   */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_INC   */ VMCF_OP1 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_DEC   */ VMCF_OP1 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_JMP   */ VMCF_OP1 | VMCF_JUMP                                    ,
  /* VM_XOR   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_AND   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_OR    */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_TEST  */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_JS    */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JNS   */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JB    */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JBE   */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JA    */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_JAE   */ VMCF_OP1 | VMCF_JUMP | VMCF_USEFLAGS                    ,
  /* VM_PUSH  */ VMCF_OP1                                                ,
  /* VM_POP   */ VMCF_OP1                                                ,
  /* VM_CALL  */ VMCF_OP1 | VMCF_PROC                                    ,
  /* VM_RET   */ VMCF_OP0 | VMCF_PROC                                    ,
  /* VM_NOT   */ VMCF_OP1 | VMCF_BYTEMODE                                ,
  /* VM_SHL   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_SHR   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_SAR   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_NEG   */ VMCF_OP1 | VMCF_BYTEMODE | VMCF_CHFLAGS                 ,
  /* VM_PUSHA */ VMCF_OP0                                                ,
  /* VM_POPA  */ VMCF_OP0                                                ,
  /* VM_PUSHF */ VMCF_OP0 | VMCF_USEFLAGS                                ,
  /* VM_POPF  */ VMCF_OP0 | VMCF_CHFLAGS                                 ,
  /* VM_MOVZX */ VMCF_OP2                                                ,
  /* VM_MOVSX */ VMCF_OP2                                                ,
  /* VM_XCHG  */ VMCF_OP2 | VMCF_BYTEMODE                                ,
  /* VM_MUL   */ VMCF_OP2 | VMCF_BYTEMODE                                ,
  /* VM_DIV   */ VMCF_OP2 | VMCF_BYTEMODE                                ,
  /* VM_ADC   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_USEFLAGS | VMCF_CHFLAGS ,
  /* VM_SBB   */ VMCF_OP2 | VMCF_BYTEMODE | VMCF_USEFLAGS | VMCF_CHFLAGS ,
  /* VM_PRINT */ VMCF_OP0
};

#define UINT32(x)  (sizeof(uint32_t)==4 ? (uint32_t)(x):((x)&0xffffffff))


#ifdef RAR_HIGH_DEBUG
#define rar_dbgmsg printf
#else
static void rar_dbgmsg(const char* fmt,...){}
#endif

static __thread  char *filebuffer;
static __thread int fileoffset;
static int filesize;

static void insert_old_dist(unpack_data_t *unpack_data, unsigned int distance)
{
	unpack_data->old_dist[3] = unpack_data->old_dist[2];
	unpack_data->old_dist[2] = unpack_data->old_dist[1];
	unpack_data->old_dist[1] = unpack_data->old_dist[0];
	unpack_data->old_dist[0] = distance;
}

static void insert_last_match(unpack_data_t *unpack_data, unsigned int length, unsigned int distance)
{
	unpack_data->last_dist = distance;
	unpack_data->last_length = length;
}

static void copy_string(unpack_data_t *unpack_data, unsigned int length, unsigned int distance)
{
	unsigned int dest_ptr;
	
	dest_ptr = unpack_data->unp_ptr - distance;
	if (dest_ptr < MAXWINSIZE-260 && unpack_data->unp_ptr < MAXWINSIZE - 260) {
		unpack_data->window[unpack_data->unp_ptr++] = unpack_data->window[dest_ptr++];
		while (--length > 0) {
			unpack_data->window[unpack_data->unp_ptr++] = unpack_data->window[dest_ptr++];
		}
	} else {
		while (length--) {
			unpack_data->window[unpack_data->unp_ptr] =
						unpack_data->window[dest_ptr++ & MAXWINMASK];
			unpack_data->unp_ptr = (unpack_data->unp_ptr + 1) & MAXWINMASK;
		}
	}
}

void rar_addbits(unpack_data_t *unpack_data, int bits)
{

	/*rar_dbgmsg("rar_addbits: in_addr=%d in_bit=%d\n", unpack_data->in_addr, unpack_data->in_bit);*/
	bits += unpack_data->in_bit;
	unpack_data->in_addr += bits >> 3;
	unpack_data->in_bit = bits & 7;
}

unsigned int rar_getbits(unpack_data_t *unpack_data)
{
	unsigned int bit_field;

	/*rar_dbgmsg("rar_getbits: in_addr=%d in_bit=%d\n", unpack_data->in_addr, unpack_data->in_bit);*/
	bit_field = (unsigned int) unpack_data->in_buf[unpack_data->in_addr] << 16;
	bit_field |= (unsigned int) unpack_data->in_buf[unpack_data->in_addr+1] << 8;
	bit_field |= (unsigned int) unpack_data->in_buf[unpack_data->in_addr+2];
	bit_field >>= (8-unpack_data->in_bit);
	/*rar_dbgmsg("rar_getbits return(%d)\n", BitField & 0xffff);*/
	return(bit_field & 0xffff);
}

int rar_unp_read_buf(unsigned char *key, unsigned char *iv, int fd, unpack_data_t *unpack_data)
{
	int data_size, retval;
	unsigned int read_size;

	data_size = unpack_data->read_top - unpack_data->in_addr;
	if (data_size < 0) {
		return FALSE;
	}
	
	/* Is buffer read pos more than half way? */
	if (unpack_data->in_addr > MAX_BUF_SIZE/2) {
		if (data_size > 0) {
			memmove(unpack_data->in_buf, unpack_data->in_buf+unpack_data->in_addr,
					data_size);
		}
		unpack_data->in_addr = 0;
		unpack_data->read_top = data_size;
	} else {
		data_size = unpack_data->read_top;
	}
	/* RAR2 depends on us only reading upto the end of the current compressed file */
	if (unpack_data->pack_size < ((MAX_BUF_SIZE-data_size)&~0xf)) {
		read_size = unpack_data->pack_size;
	} else {
		read_size = (MAX_BUF_SIZE-data_size)&~0xf;
	}
        AES_KEY keyu;
        unsigned char buf[33000];
        //retval = read(fd, buf, read_size);
        int savedoffset=fileoffset;
        fileoffset+=read_size;
        if (fileoffset>filesize) retval=(fileoffset-filesize);
        else retval=read_size;

        if (retval>0)
        {
    	    //printf("key=%02x%02x%02x%02x retval=%d\n",key[0],key[1],key[2],key[3],retval);
    	    memcpy(buf,filebuffer+savedoffset,retval);
    	    OAES_SET_DECRYPT_KEY(key, 16*8, &keyu);
    	    OAES_CBC_ENCRYPT(buf, unpack_data->in_buf+data_size, read_size, &keyu, iv, 0);
    	}

	if (retval > 0) {
		unpack_data->read_top += retval;
		unpack_data->pack_size -= retval;
	}
        

	unpack_data->read_border = unpack_data->read_top - 30;
	if(unpack_data->read_border < unpack_data->in_addr) {
		const ssize_t fill = ((unpack_data->read_top + 30) < MAX_BUF_SIZE) ? 30 : (MAX_BUF_SIZE - unpack_data->read_top);
		if(fill)
			memset(unpack_data->in_buf + unpack_data->read_top, 0, fill);
	}
	return (retval!=-1);
}

unsigned int rar_get_char(unsigned char *key, unsigned char *iv,int fd, unpack_data_t *unpack_data)
{
	if (unpack_data->in_addr > MAX_BUF_SIZE-30) {
		if (!rar_unp_read_buf(key,iv,fd, unpack_data)) {
			rar_dbgmsg("rar_get_char: rar_unp_read_buf FAILED\n"); /* FIXME: cli_errmsg */
			return -1;
		}
	}
	rar_dbgmsg("rar_get_char = %u\n", unpack_data->in_buf[unpack_data->in_addr]);
	return(unpack_data->in_buf[unpack_data->in_addr++]);
}

static void unp_write_data(unpack_data_t *unpack_data, uint8_t *data, int size)
{
	rar_dbgmsg("in unp_write_data length=%d\n", size);
	//write(unpack_data->ofd, data, size);
	unpack_data->written_size += size;
	unpack_data->unp_crc = rar_crc(unpack_data->unp_crc, data, size);
}

static void unp_write_area(unpack_data_t *unpack_data, unsigned int start_ptr, unsigned int end_ptr)
{
	if (end_ptr < start_ptr) {
		unp_write_data(unpack_data, &unpack_data->window[start_ptr], -start_ptr & MAXWINMASK);
		unp_write_data(unpack_data, unpack_data->window, end_ptr);
	} else {
		unp_write_data(unpack_data, &unpack_data->window[start_ptr], end_ptr-start_ptr);
	}
}

void rar_unp_write_buf_old(unpack_data_t *unpack_data)
{
	rar_dbgmsg("in rar_unp_write_buf_old\n");
	if (unpack_data->unp_ptr < unpack_data->wr_ptr) {
		unp_write_data(unpack_data, &unpack_data->window[unpack_data->wr_ptr],
				-unpack_data->wr_ptr & MAXWINMASK);
		unp_write_data(unpack_data, unpack_data->window, unpack_data->unp_ptr);
	} else {
		unp_write_data(unpack_data, &unpack_data->window[unpack_data->wr_ptr],
				unpack_data->unp_ptr - unpack_data->wr_ptr);
	}
	unpack_data->wr_ptr = unpack_data->unp_ptr;
}

static void execute_code(unpack_data_t *unpack_data, struct rarvm_prepared_program *prg)
{
	rar_dbgmsg("in execute_code\n");
	rar_dbgmsg("global_size: %ld\n", prg->global_size);
	if (prg->global_size > 0) {
		prg->init_r[6] = int64to32(unpack_data->written_size);
		rarvm_set_value(FALSE, (unsigned int *)&prg->global_data[0x24],
				int64to32(unpack_data->written_size));
		rarvm_set_value(FALSE, (unsigned int *)&prg->global_data[0x28],
				int64to32(unpack_data->written_size>>32));
		rarvm_execute(&unpack_data->rarvm_data, prg);
	}
}

		
static void unp_write_buf(unpack_data_t *unpack_data)
{
	unsigned int written_border, part_length, filtered_size;
	unsigned int write_size, block_start, block_length, block_end;
	struct UnpackFilter *flt, *next_filter;
	struct rarvm_prepared_program *prg, *next_prg;
	uint8_t *filtered_data;
	int i, j;
	
	rar_dbgmsg("in unp_write_buf\n");
	written_border = unpack_data->wr_ptr;
	write_size = (unpack_data->unp_ptr - written_border) & MAXWINMASK;
	for (i=0 ; i < unpack_data->PrgStack.num_items ; i++) {
		flt = unpack_data->PrgStack.array[i];
		if (flt == NULL) {
			continue;
		}
		if (flt->next_window) {
			flt->next_window = FALSE;
			continue;
		}
		block_start = flt->block_start;
		block_length = flt->block_length;
		if (((block_start-written_border)&MAXWINMASK) < write_size) {
			if (written_border != block_start) {
				unp_write_area(unpack_data, written_border, block_start);
				written_border = block_start;
				write_size = (unpack_data->unp_ptr - written_border) & MAXWINMASK;
			}
			if (block_length <= write_size) {
				block_end = (block_start + block_length) & MAXWINMASK;
				if (block_start < block_end || block_end==0) {
					rarvm_set_memory(&unpack_data->rarvm_data, 0,
							unpack_data->window+block_start, block_length);
				} else {
					part_length = MAXWINMASK - block_start;
					rarvm_set_memory(&unpack_data->rarvm_data, 0,
							unpack_data->window+block_start, part_length);
					rarvm_set_memory(&unpack_data->rarvm_data, part_length,
							unpack_data->window, block_end);
				}
				prg = &flt->prg;
				execute_code(unpack_data, prg);
				
				filtered_data = prg->filtered_data;
				filtered_size = prg->filtered_data_size;
				
				rar_filter_delete(unpack_data->PrgStack.array[i]);
				unpack_data->PrgStack.array[i] = NULL;
				while (i+1 < unpack_data->PrgStack.num_items) {
					next_filter = unpack_data->PrgStack.array[i+1];
					if (next_filter==NULL ||
							next_filter->block_start!=block_start ||
							next_filter->block_length!=filtered_size ||
							next_filter->next_window) {
						break;
					}
					rarvm_set_memory(&unpack_data->rarvm_data, 0,
							filtered_data, filtered_size);
					next_prg = &unpack_data->PrgStack.array[i+1]->prg;
					execute_code(unpack_data, next_prg);
					filtered_data = next_prg->filtered_data;
					filtered_size = next_prg->filtered_data_size;
					i++;
					rar_filter_delete(unpack_data->PrgStack.array[i]);
					unpack_data->PrgStack.array[i] = NULL;
				}
				unp_write_data(unpack_data, filtered_data, filtered_size);
				written_border = block_end;
				write_size = (unpack_data->unp_ptr - written_border) & MAXWINMASK;
			} else {
				for (j=i ; j < unpack_data->PrgStack.num_items ; j++) {
					flt = unpack_data->PrgStack.array[j];
					if (flt != NULL && flt->next_window) {
						flt->next_window = FALSE;
					}
				}
				unpack_data->wr_ptr = written_border;
				return;
				
			}
		}
	}
	unp_write_area(unpack_data, written_border, unpack_data->unp_ptr);
	unpack_data->wr_ptr = unpack_data->unp_ptr;
}

void rar_make_decode_tables(unsigned char *len_tab, struct Decode *decode, int size)
{
	int len_count[16], tmp_pos[16], i;
	long m,n;
	
	memset(len_count, 0, sizeof(len_count));
	memset(decode->DecodeNum,0,size*sizeof(*decode->DecodeNum));
	for (i=0 ; i < size ; i++) {
		len_count[len_tab[i] & 0x0f]++;
	}
	
	len_count[0]=0;
	for (tmp_pos[0]=decode->DecodePos[0]=decode->DecodeLen[0]=0,n=0,i=1;i<16;i++) {
		n=2*(n+len_count[i]);
		m=n<<(15-i);
		if (m>0xFFFF) {
			m=0xFFFF;
		}
		decode->DecodeLen[i]=(unsigned int)m;
		tmp_pos[i]=decode->DecodePos[i]=decode->DecodePos[i-1]+len_count[i-1];
	}
	
	for (i=0;i<size;i++) {
		if (len_tab[i]!=0) {
			decode->DecodeNum[tmp_pos[len_tab[i] & 0x0f]++]=i;
		}
	}
	decode->MaxNum=size;
}

int rar_decode_number(unpack_data_t *unpack_data, struct Decode *decode)
{
	unsigned int bits, bit_field, n;
	
	bit_field = rar_getbits(unpack_data) & 0xfffe;
	rar_dbgmsg("rar_decode_number BitField=%u\n", bit_field);
	if (bit_field < decode->DecodeLen[8])
		if (bit_field < decode->DecodeLen[4])
			if (bit_field < decode->DecodeLen[2])
				if (bit_field < decode->DecodeLen[1])
					bits=1;
				else
					bits=2;
			else
				if (bit_field < decode->DecodeLen[3])
					bits=3;
				else
					bits=4;
		else
			if (bit_field < decode->DecodeLen[6])
				if (bit_field < decode->DecodeLen[5])
					bits=5;
				else
					bits=6;
			else
				if (bit_field < decode->DecodeLen[7])
					bits=7;
				else
					bits=8;
	else
		if (bit_field < decode->DecodeLen[12])
			if (bit_field < decode->DecodeLen[10])
				if (bit_field < decode->DecodeLen[9])
					bits=9;
				else
					bits=10;
			else
				if (bit_field < decode->DecodeLen[11])
					bits=11;
				else
					bits=12;
		else
			if (bit_field < decode->DecodeLen[14])
				if (bit_field < decode->DecodeLen[13])
					bits=13;
				else
					bits=14;
			else
				bits=15;

	rar_dbgmsg("rar_decode_number: bits=%d\n", bits);

	rar_addbits(unpack_data, bits);
	n=decode->DecodePos[bits]+((bit_field-decode->DecodeLen[bits-1])>>(16-bits));
	if (n >= decode->MaxNum) {
		n=0;
		return -1;
	}
	/*rar_dbgmsg("rar_decode_number return(%d)\n", decode->DecodeNum[n]);*/

	return(decode->DecodeNum[n]);
}

static int read_tables(unsigned char *key, unsigned char *iv,int fd, unpack_data_t *unpack_data)
{
	uint8_t bit_length[BC];
	unsigned char table[HUFF_TABLE_SIZE];
	unsigned int bit_field;
	int i, length, zero_count, number, n;
	const int table_size=HUFF_TABLE_SIZE;
	
	//rar_dbgmsg("in read_tables Offset=%ld in_addr=%d read_top=%d\n", lseek(fd, 0, SEEK_CUR),
	//			unpack_data->in_addr, unpack_data->read_top);
	if (unpack_data->in_addr > unpack_data->read_top-25) {
		if (!rar_unp_read_buf(key, iv,fd, unpack_data)) {
			rar_dbgmsg("ERROR: read_tables rar_unp_read_buf failed\n");
			return FALSE;
		}
	}
	rar_addbits(unpack_data, (8-unpack_data->in_bit) & 7);
	bit_field = rar_getbits(unpack_data);
	rar_dbgmsg("BitField = 0x%x\n", bit_field);
	if (bit_field & 0x8000) {
		unpack_data->unp_block_type = BLOCK_PPM;
		rar_dbgmsg("Calling ppm_decode_init\n");
		if(!ppm_decode_init(key,iv,&unpack_data->ppm_data, fd, unpack_data, &unpack_data->ppm_esc_char)) {
		    rar_dbgmsg("unrar: read_tables: ppm_decode_init failed\n");
		    return FALSE;
		}
		return(TRUE);
	}
	unpack_data->unp_block_type = BLOCK_LZ;
	unpack_data->prev_low_dist = 0;
	unpack_data->low_dist_rep_count = 0;

	if (!(bit_field & 0x4000)) {
		memset(unpack_data->unp_old_table, 0, sizeof(unpack_data->unp_old_table));
	}
	rar_addbits(unpack_data, 2);
	
	for (i=0 ; i < BC ; i++) {
		length = (uint8_t)(rar_getbits(unpack_data) >> 12);
		rar_addbits(unpack_data, 4);
		if (length == 15) {
			zero_count = (uint8_t)(rar_getbits(unpack_data) >> 12);
			rar_addbits(unpack_data, 4);
			if (zero_count == 0) {
				bit_length[i] = 15;
			} else {
				zero_count += 2;
				while (zero_count-- > 0 &&
						i<sizeof(bit_length)/sizeof(bit_length[0])) {
					bit_length[i++]=0;
				}
				i--;
			}
		} else {
			bit_length[i] = length;
		}
	}
	rar_make_decode_tables(bit_length,(struct Decode *)&unpack_data->BD,BC);
	
	for (i=0;i<table_size;) {
		if (unpack_data->in_addr > unpack_data->read_top-5) {
			if (!rar_unp_read_buf(key,iv,fd, unpack_data)) {
				rar_dbgmsg("ERROR: read_tables rar_unp_read_buf failed 2\n");
				return FALSE;
			}
		}
		number = rar_decode_number(unpack_data, (struct Decode *)&unpack_data->BD);
		if (number<0) return FALSE;
		if (number < 16) {
			table[i] = (number+unpack_data->unp_old_table[i]) & 0xf;
			i++;
		} else if (number < 18) {
			if (number == 16) {
				n = (rar_getbits(unpack_data) >> 13) + 3;
				rar_addbits(unpack_data, 3);
			} else {
				n = (rar_getbits(unpack_data) >> 9) + 11;
				rar_addbits(unpack_data, 7);
			}
			while (n-- > 0 && i < table_size) {
				table[i] = table[i-1];
				i++;
			}
		} else {
			if (number == 18) {
				n = (rar_getbits(unpack_data) >> 13) + 3;
				rar_addbits(unpack_data, 3);
			} else {
				n = (rar_getbits(unpack_data) >> 9) + 11;
				rar_addbits(unpack_data, 7);
			}
			while (n-- > 0 && i < table_size) {
				table[i++] = 0;
			}
		}
	}
	unpack_data->tables_read = TRUE;
	if (unpack_data->in_addr > unpack_data->read_top) {
		rar_dbgmsg("ERROR: read_tables check failed\n");
		return FALSE;
	}
	rar_make_decode_tables(&table[0], (struct Decode *)&unpack_data->LD,NC);
	rar_make_decode_tables(&table[NC], (struct Decode *)&unpack_data->DD,DC);
	rar_make_decode_tables(&table[NC+DC], (struct Decode *)&unpack_data->LDD,LDC);
	rar_make_decode_tables(&table[NC+DC+LDC], (struct Decode *)&unpack_data->RD,RC);
	memcpy(unpack_data->unp_old_table,table,sizeof(unpack_data->unp_old_table));
	

	/*dump_tables(unpack_data);*/
	rar_dbgmsg("ReadTables finished\n");
  	return TRUE;
}

static int read_end_of_block(unsigned char *key, unsigned char *iv,int fd, unpack_data_t *unpack_data)
{
	unsigned int bit_field;
	int new_table, new_file=FALSE;
	
	bit_field = rar_getbits(unpack_data);
	if (bit_field & 0x8000) {
		new_table = TRUE;
		rar_addbits(unpack_data, 1);
	} else {
		new_file = TRUE;
		new_table = (bit_field & 0x4000);
		rar_addbits(unpack_data, 2);
	}
	unpack_data->tables_read = !new_table;
	rar_dbgmsg("NewFile=%d NewTable=%d TablesRead=%d\n", new_file,
			new_table, unpack_data->tables_read);
	return !(new_file || (new_table && !read_tables(key,iv,fd, unpack_data)));
}

void rar_init_filters(unpack_data_t *unpack_data)
{	
	if (unpack_data->old_filter_lengths) {
		free(unpack_data->old_filter_lengths);
		unpack_data->old_filter_lengths = NULL;
	}
	unpack_data->old_filter_lengths_size = 0;
	unpack_data->last_filter = 0;
	
	rar_filter_array_reset(&unpack_data->Filters);
	rar_filter_array_reset(&unpack_data->PrgStack);
}

static int add_vm_code(unpack_data_t *unpack_data, unsigned int first_byte,
			unsigned char *vmcode, int code_size)
{
	rarvm_input_t rarvm_input;
	unsigned int filter_pos, new_filter, block_start, init_mask, cur_size;
	struct UnpackFilter *filter, *stack_filter;
	int i, empty_count, stack_pos, vm_codesize, static_size, data_size;
	unsigned char *vm_code, *global_data;
	
	rar_dbgmsg("in add_vm_code first_byte=0x%x code_size=%d\n", first_byte, code_size);
	rarvm_input.in_buf = vmcode;
	rarvm_input.buf_size = code_size;
	rarvm_input.in_addr = 0;
	rarvm_input.in_bit = 0;

	if (first_byte & 0x80) {
		filter_pos = rarvm_read_data(&rarvm_input);
		if (filter_pos == 0) {
			rar_init_filters(unpack_data);
		} else {
			filter_pos--;
		}
	} else {
		filter_pos = unpack_data->last_filter;
	}
	rar_dbgmsg("filter_pos = %u\n", filter_pos);
	if (filter_pos > unpack_data->Filters.num_items ||
			filter_pos > unpack_data->old_filter_lengths_size) {
		rar_dbgmsg("filter_pos check failed\n");
		return FALSE;
	}
	unpack_data->last_filter = filter_pos;
	new_filter = (filter_pos == unpack_data->Filters.num_items);
	rar_dbgmsg("Filters.num_items=%d\n", unpack_data->Filters.num_items);
	rar_dbgmsg("new_filter=%d\n", new_filter);
	if (new_filter) {
		if (!rar_filter_array_add(&unpack_data->Filters, 1)) {
			rar_dbgmsg("rar_filter_array_add failed\n");
			return FALSE;
		}
		unpack_data->Filters.array[unpack_data->Filters.num_items-1] =
					filter = rar_filter_new();
		if (!unpack_data->Filters.array[unpack_data->Filters.num_items-1]) {
			rar_dbgmsg("rar_filter_new failed\n");
			return FALSE;
		}	
		unpack_data->old_filter_lengths_size++;
		unpack_data->old_filter_lengths = (int *) rar_realloc2(unpack_data->old_filter_lengths,
				sizeof(int) * unpack_data->old_filter_lengths_size);
		if(!unpack_data->old_filter_lengths) {
		    rar_dbgmsg("unrar: add_vm_code: rar_realloc2 failed for unpack_data->old_filter_lengths\n");
		    return FALSE;
		}
		unpack_data->old_filter_lengths[unpack_data->old_filter_lengths_size-1] = 0;
		filter->exec_count = 0;
	} else {
		filter = unpack_data->Filters.array[filter_pos];
		filter->exec_count++;
	}
	
	stack_filter = rar_filter_new();

	empty_count = 0;
	for (i=0 ; i < unpack_data->PrgStack.num_items; i++) {
		unpack_data->PrgStack.array[i-empty_count] = unpack_data->PrgStack.array[i];
		if (unpack_data->PrgStack.array[i] == NULL) {
			empty_count++;
		}
		if (empty_count > 0) {
			unpack_data->PrgStack.array[i] = NULL;
		}
	}
	
	if (empty_count == 0) {
		rar_filter_array_add(&unpack_data->PrgStack, 1);
		empty_count = 1;
	}
	stack_pos = unpack_data->PrgStack.num_items - empty_count;
	unpack_data->PrgStack.array[stack_pos] = stack_filter;
	stack_filter->exec_count = filter->exec_count;
	
	block_start = rarvm_read_data(&rarvm_input);
	rar_dbgmsg("block_start=%u\n", block_start);
	if (first_byte & 0x40) {
		block_start += 258;
	}
	stack_filter->block_start = (block_start + unpack_data->unp_ptr) & MAXWINMASK;
	if (first_byte & 0x20) {
		stack_filter->block_length = rarvm_read_data(&rarvm_input);
	} else {
		stack_filter->block_length = filter_pos < unpack_data->old_filter_lengths_size ?
				unpack_data->old_filter_lengths[filter_pos] : 0;
	}
	rar_dbgmsg("block_length=%u\n", stack_filter->block_length);
	stack_filter->next_window = unpack_data->wr_ptr != unpack_data->unp_ptr &&
		((unpack_data->wr_ptr - unpack_data->unp_ptr) & MAXWINMASK) <= block_start;
		
	unpack_data->old_filter_lengths[filter_pos] = stack_filter->block_length;
	
	memset(stack_filter->prg.init_r, 0, sizeof(stack_filter->prg.init_r));
	stack_filter->prg.init_r[3] = VM_GLOBALMEMADDR;
	stack_filter->prg.init_r[4] = stack_filter->block_length;
	stack_filter->prg.init_r[5] = stack_filter->exec_count;
	if (first_byte & 0x10) {
		init_mask = rarvm_getbits(&rarvm_input) >> 9;
		rarvm_addbits(&rarvm_input, 7);
		for (i=0 ; i<7 ; i++) {
			if (init_mask & (1<<i)) {
				stack_filter->prg.init_r[i] =
					rarvm_read_data(&rarvm_input);
				rar_dbgmsg("prg.init_r[%d] = %u\n", i, stack_filter->prg.init_r[i]);
			}
		}
	}
	if (new_filter) {
		vm_codesize = rarvm_read_data(&rarvm_input);
		if (vm_codesize >= 0x1000 || vm_codesize == 0 || (vm_codesize > rarvm_input.buf_size)) {
			rar_dbgmsg("ERROR: vm_codesize=0x%x buf_size=0x%x\n", vm_codesize, rarvm_input.buf_size);
			return FALSE;
		}
		vm_code = (unsigned char *) rar_malloc(vm_codesize);
		if(!vm_code) {
		    rar_dbgmsg("unrar: add_vm_code: rar_malloc failed for vm_code\n");
		    return FALSE;
		}
		for (i=0 ; i < vm_codesize ; i++) {
			vm_code[i] = rarvm_getbits(&rarvm_input) >> 8;
			rarvm_addbits(&rarvm_input, 8);
		}
		if(!rarvm_prepare(&unpack_data->rarvm_data, &rarvm_input, &vm_code[0], vm_codesize, &filter->prg)) {
		    rar_dbgmsg("unrar: add_vm_code: rarvm_prepare failed\n");
		    free(vm_code);
		    return FALSE;
		}
		free(vm_code);
	}
	stack_filter->prg.alt_cmd = &filter->prg.cmd.array[0];
	stack_filter->prg.cmd_count = filter->prg.cmd_count;
	
	static_size = filter->prg.static_size;
	if (static_size > 0 && static_size < VM_GLOBALMEMSIZE) {
		stack_filter->prg.static_data = rar_malloc(static_size);
		if(!stack_filter->prg.static_data) {
		    rar_dbgmsg("unrar: add_vm_code: rar_malloc failed for stack_filter->prg.static_data\n");
		    return FALSE;
		}
		memcpy(stack_filter->prg.static_data, filter->prg.static_data, static_size);
	}
	
	if (stack_filter->prg.global_size < VM_FIXEDGLOBALSIZE) {
		free(stack_filter->prg.global_data);
		stack_filter->prg.global_data = rar_malloc(VM_FIXEDGLOBALSIZE);
		if(!stack_filter->prg.global_data) {
		    rar_dbgmsg("unrar: add_vm_code: rar_malloc failed for stack_filter->prg.global_data\n");
		    return FALSE;
		}
		memset(stack_filter->prg.global_data, 0, VM_FIXEDGLOBALSIZE);
		stack_filter->prg.global_size = VM_FIXEDGLOBALSIZE;
	}
	global_data = &stack_filter->prg.global_data[0];
	for (i=0 ; i<7 ; i++) {
		rar_dbgmsg("init_r[%d]=%u\n", i, stack_filter->prg.init_r[i]);
		rarvm_set_value(FALSE, (unsigned int *)&global_data[i*4],
				stack_filter->prg.init_r[i]);
	}
	rarvm_set_value(FALSE, (unsigned int *)&global_data[0x1c], stack_filter->block_length);
	rarvm_set_value(FALSE, (unsigned int *)&global_data[0x20], 0);
	rarvm_set_value(FALSE, (unsigned int *)&global_data[0x2c], stack_filter->exec_count);
	memset(&global_data[0x30], 0, 16);
	for (i=0 ; i< 30 ; i++) {
		rar_dbgmsg("global_data[%d] = %d\n", i, global_data[i]);
	}
	if (first_byte & 8) {
		data_size = rarvm_read_data(&rarvm_input);
		if (data_size >= 0x10000) {
			return FALSE;
		}
		cur_size = stack_filter->prg.global_size;
		if (cur_size < data_size+VM_FIXEDGLOBALSIZE) {
			stack_filter->prg.global_size += data_size+VM_FIXEDGLOBALSIZE-cur_size;
			stack_filter->prg.global_data = rar_realloc2(stack_filter->prg.global_data,
				stack_filter->prg.global_size);
			if(!stack_filter->prg.global_data) {
			    rar_dbgmsg("unrar: add_vm_code: rar_realloc2 failed for stack_filter->prg.global_data\n");
			    return FALSE;
			}
		}
		global_data = &stack_filter->prg.global_data[VM_FIXEDGLOBALSIZE];
		for (i=0 ; i< data_size ; i++) {
			if ((rarvm_input.in_addr+2) > rarvm_input.buf_size) {
				rar_dbgmsg("Buffer truncated\n");
				return FALSE;
			}
			global_data[i] = rarvm_getbits(&rarvm_input) >> 8;
			rar_dbgmsg("global_data[%d] = %d\n", i, global_data[i]);
			rarvm_addbits(&rarvm_input, 8);
		}
	}
	return TRUE;
}

static int read_vm_code(unsigned char *key, unsigned char *iv,unpack_data_t *unpack_data, int fd)
{
	unsigned int first_byte;
	int length, i, retval;
	unsigned char *vmcode;
	
	first_byte = rar_getbits(unpack_data)>>8;
	rar_addbits(unpack_data, 8);
	length = (first_byte & 7) + 1;
	if (length == 7) {
		length = (rar_getbits(unpack_data) >> 8) + 7;
		rar_addbits(unpack_data, 8);
	} else if (length == 8) {
		length = rar_getbits(unpack_data);
		rar_addbits(unpack_data, 16);
	}
	vmcode = (unsigned char *) rar_malloc(length + 2);
	rar_dbgmsg("VM code length: %d\n", length);
	if (!vmcode) {
		return FALSE;
	}
	for (i=0 ; i < length ; i++) {
		if (unpack_data->in_addr >= unpack_data->read_top-1 &&
				!rar_unp_read_buf(key,iv,fd, unpack_data) && i<length-1) {
			return FALSE;
		}
		vmcode[i] = rar_getbits(unpack_data) >> 8;
		rar_addbits(unpack_data, 8);
	}
	retval = add_vm_code(unpack_data, first_byte, vmcode, length);
	free(vmcode);
	return retval;
}

static int read_vm_code_PPM(unsigned char *key, unsigned char *iv,unpack_data_t *unpack_data, int fd)
{
	unsigned int first_byte;
	int length, i, ch, retval, b1, b2;
	unsigned char *vmcode;
	
	first_byte = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
	if ((int)first_byte == -1) {
		return FALSE;
	}
	length = (first_byte & 7) + 1;
	if (length == 7) {
		b1 = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
		if (b1 == -1) {
			return FALSE;
		}
		length = b1 + 7;
	} else if (length == 8) {
		b1 = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
		if (b1 == -1) {
			return FALSE;
		}
		b2 = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
		if (b2 == -1) {
			return FALSE;
		}
		length = b1*256 + b2;
	}
	vmcode = (unsigned char *) rar_malloc(length + 2);
	rar_dbgmsg("VM PPM code length: %d\n", length);
	if (!vmcode) {
		return FALSE;
	}
	for (i=0 ; i < length ; i++) {
		ch = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
		if (ch == -1) {
			free(vmcode);
			return FALSE;
		}
		vmcode[i] = ch;
	}
	retval = add_vm_code(unpack_data, first_byte, vmcode, length);
	free(vmcode);
	return retval;
}

void rar_unpack_init_data(int solid, unpack_data_t *unpack_data)
{
	if (!solid) {
		unpack_data->tables_read = FALSE;
		memset(unpack_data->old_dist, 0, sizeof(unpack_data->old_dist));
		unpack_data->old_dist_ptr= 0;
		memset(unpack_data->unp_old_table, 0, sizeof(unpack_data->unp_old_table));
		unpack_data->last_dist= 0;
		unpack_data->last_length=0;
		unpack_data->ppm_esc_char = 2;
		unpack_data->unp_ptr = 0;
		unpack_data->wr_ptr = 0;
		rar_init_filters(unpack_data);
	}
	unpack_data->in_bit = 0;
	unpack_data->in_addr = 0;
	unpack_data->read_top = 0;
	unpack_data->ppm_error = FALSE;
	
	unpack_data->written_size = 0;
	rarvm_init(&unpack_data->rarvm_data);
	unpack_data->unp_crc = 0xffffffff;
	
}

static int rar_unpack29(unsigned char *key, unsigned char *iv, int fd, int solid, unpack_data_t *unpack_data)
{
	unsigned char ldecode[]={0,1,2,3,4,5,6,7,8,10,12,14,16,20,24,28,
			32,40,48,56,64,80,96,112,128,160,192,224};
	unsigned char lbits[]=  {0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5};
	int ddecode[DC]={0,1,2,3,4,6,8,12,16,24,32,48,64,96,128,192,256,384,512,768,1024,
		1536,2048,3072,4096,6144,8192,12288,16384,24576,32768,49152,65536,
		98304,131072,196608,262144,327680,393216,458752,524288,589824,655360,
		720896,786432,851968,917504,983040,1048576,1310720,1572864,
		1835008,2097152,2359296,2621440,2883584,3145728,3407872,3670016,3932160};
	uint8_t dbits[DC]= {0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,
		11,11,12,12,13,13,14,14,15,15,16,16,16,16,16,16,16,16,16,
		16,16,16,16,16,18,18,18,18,18,18,18,18,18,18,18,18};
	unsigned char sddecode[]={0,4,8,16,32,64,128,192};
	unsigned char sdbits[]=  {2,2,3, 4, 5, 6,  6,  6};
	unsigned int bits, distance;
	int retval=TRUE, i,  length, dist_number, low_dist, ch, next_ch;
	int number;
	int length_number, failed;

	//rar_dbgmsg("Offset: %ld\n", lseek(fd, 0, SEEK_CUR));
	if (!solid) {
		rar_dbgmsg("Not solid\n");
	}
	rar_unpack_init_data(solid, unpack_data);
	if (!rar_unp_read_buf(key,iv,fd, unpack_data)) {
		return TRUE;
	}
	if (!solid || !unpack_data->tables_read) {
		rar_dbgmsg("Read tables\n");
		if (!read_tables(key,iv,fd, unpack_data)) {
			return TRUE;
		}
	}

	rar_dbgmsg("init done\n");
	while(1) {
		unpack_data->unp_ptr &= MAXWINMASK;
		rar_dbgmsg("UnpPtr = %d\n", unpack_data->unp_ptr);
		if (unpack_data->in_addr > unpack_data->read_border) {
			if (!rar_unp_read_buf(key,iv,fd, unpack_data)) {
				if (solid==1) retval = FALSE;
				return FALSE;
				break;
			}
		}
		if (((unpack_data->wr_ptr - unpack_data->unp_ptr) & MAXWINMASK) < 260 &&
				unpack_data->wr_ptr != unpack_data->unp_ptr) {
			unp_write_buf(unpack_data);
		}

		if (unpack_data->unp_block_type == BLOCK_PPM) {
			ch = ppm_decode_char(key,iv,&unpack_data->ppm_data, fd, unpack_data);
			rar_dbgmsg("PPM char: %d\n", ch);
			if (ch == -1) {
				retval = FALSE;
				unpack_data->ppm_error = TRUE;
				return FALSE;
				break;
			}
			if (ch == unpack_data->ppm_esc_char) {
				next_ch = ppm_decode_char(key,iv,&unpack_data->ppm_data,
							fd, unpack_data);
				rar_dbgmsg("PPM next char: %d\n", next_ch);
				if (next_ch == -1) {
					retval = FALSE;
					unpack_data->ppm_error = TRUE;
					return FALSE;
					break;
				}
				if (next_ch == 0) {
					if (!read_tables(key,iv,fd, unpack_data)) {
						retval = FALSE;
						return FALSE;
						break;
					}
					continue;
				}
				if (next_ch == 2 || next_ch == -1) {
					return FALSE;
					break;
				}
				if (next_ch == 3) {
					if (!read_vm_code_PPM(key,iv,unpack_data, fd)) {
						retval = FALSE;
						return FALSE;
						break;
					}
					continue;
				}
				if (next_ch == 4) {
					unsigned int length;
					distance = 0;
					failed = FALSE;
					for (i=0 ; i < 4 && !failed; i++) {
						ch = ppm_decode_char(key,iv,&unpack_data->ppm_data,
								fd, unpack_data);
						if (ch == -1) {
							failed = TRUE;
						} else {
							if (i==3) {
								length = (uint8_t)ch;
							} else {
								distance = (distance << 8) +
										(uint8_t)ch;
							}
						}
					}
					if (failed) {
						retval = FALSE;
						return FALSE;
						break;
					}
					copy_string(unpack_data, length+32, distance+2);
					continue;
				}
				if (next_ch == 5) {
					int length = ppm_decode_char(key,iv,&unpack_data->ppm_data,
								fd, unpack_data);
					rar_dbgmsg("PPM length: %d\n", length);
					if (length == -1) {
						retval = FALSE;
						return FALSE;
						break;
					}
					copy_string(unpack_data, length+4, 1);
					continue;
				}
			}
			unpack_data->window[unpack_data->unp_ptr++] = ch;
			continue;
		} //else {

			number = rar_decode_number(unpack_data, (struct Decode *)&unpack_data->LD);
			if (number<0) return FALSE;
			rar_dbgmsg("number = %d\n", number);
			
			if (number < 256) {
				unpack_data->window[unpack_data->unp_ptr++] = (uint8_t) number;
				continue;
			}
			if (number >= 271) {
				length = ldecode[number-=271]+3;
				if ((bits=lbits[number]) > 0) {
					length += rar_getbits(unpack_data) >> (16-bits);
					rar_addbits(unpack_data, bits);
				}
				dist_number = rar_decode_number(unpack_data,
							(struct Decode *)&unpack_data->DD);
				distance = ddecode[dist_number] + 1;
				if ((bits = dbits[dist_number]) > 0) {
					if (dist_number > 9) {
						if (bits > 4) {
							distance += ((rar_getbits(unpack_data) >>
									(20-bits)) << 4);
							rar_addbits(unpack_data, bits-4);
						}
						if (unpack_data->low_dist_rep_count > 0) {
							unpack_data->low_dist_rep_count--;
							distance += unpack_data->prev_low_dist;
						} else {
							low_dist = rar_decode_number(unpack_data,
								(struct Decode *) &unpack_data->LDD);
							if (low_dist == 16) {
								unpack_data->low_dist_rep_count =
									LOW_DIST_REP_COUNT-1;
								distance += unpack_data->prev_low_dist;
							} else {
								distance += low_dist;
								unpack_data->prev_low_dist = low_dist;
							}
						}
					} else {
						distance += rar_getbits(unpack_data) >> (16-bits);
						rar_addbits(unpack_data, bits);
					}
				}
				
				if (distance >= 0x2000) {
					length++;
					if (distance >= 0x40000L) {
						length++;
					}
				}
				
				insert_old_dist(unpack_data, distance);
				insert_last_match(unpack_data, length, distance);
				copy_string(unpack_data, length, distance);
				continue;
			}
			if (number == 256) {
				if (!read_end_of_block(key,iv,fd, unpack_data)) {
					break;
				}
				continue;
			}
			if (number == 257) {
				if (!read_vm_code(key,iv,unpack_data, fd)) {
					retval = FALSE;
					return FALSE;
					break;
				}
				continue;
			}
			if (number == 258) {
				if (unpack_data->last_length != 0) {
					copy_string(unpack_data, unpack_data->last_length,
							unpack_data->last_dist);
				}
				continue;
			}
			if (number < 263) {
				dist_number = number-259;
				distance = unpack_data->old_dist[dist_number];
				for (i=dist_number ; i > 0 ; i--) {
					unpack_data->old_dist[i] = unpack_data->old_dist[i-1];
				}
				unpack_data->old_dist[0] = distance;
				
				length_number = rar_decode_number(unpack_data,
							(struct Decode *)&unpack_data->RD);
				length = ldecode[length_number]+2;
				if ((bits = lbits[length_number]) > 0) {
					length += rar_getbits(unpack_data) >> (16-bits);
					rar_addbits(unpack_data, bits);
				}
				insert_last_match(unpack_data, length, distance);
				copy_string(unpack_data, length, distance);
				continue;
			}
			if (number < 272) {
				distance = sddecode[number-=263]+1;
				if ((bits = sdbits[number]) > 0) {
					distance += rar_getbits(unpack_data) >> (16-bits);
					rar_addbits(unpack_data, bits);
				}
				insert_old_dist(unpack_data, distance);
				insert_last_match(unpack_data, 2, distance);
				copy_string(unpack_data, 2, distance);
				continue;
			}
	
		}
	//}
	if (retval) {
		unp_write_buf(unpack_data);
	}
	rar_dbgmsg("Finished length: %ld\n", unpack_data->written_size);
	return retval;
}

int rar_unpack(unsigned char *key, unsigned char *iv, char *buffer, int method, int solid, unpack_data_t *unpack_data, int compfilesize)
{
	int retval = FALSE;
	filebuffer = buffer;
	fileoffset = 0;
	filesize=compfilesize;
	switch(method) {
	case 29:
		retval = rar_unpack29(key, iv, retval, solid, unpack_data);
		break;
	default:
		fprintf(stderr, "UNRAR: ERROR: Unknown RAR pack method: %d\n", method);
		break;
	}
	rarvm_free(&unpack_data->rarvm_data);
	return retval;
}

void rar_cmd_array_init(rar_cmd_array_t *cmd_a)
{
	cmd_a->array = NULL;
	cmd_a->num_items = 0;
}

void rar_cmd_array_reset(rar_cmd_array_t *cmd_a)
{	
	if (!cmd_a) {
		return;
	}
	if (cmd_a->array) {
		free(cmd_a->array);
	}
	cmd_a->array = NULL;
	cmd_a->num_items = 0;
}

int rar_cmd_array_add(rar_cmd_array_t *cmd_a, int num)
{
	cmd_a->num_items += num;
	cmd_a->array = (struct rarvm_prepared_command *) rar_realloc2(cmd_a->array,
			cmd_a->num_items * sizeof(struct rarvm_prepared_command));
	if (cmd_a->array == NULL) {
		return FALSE;
	}
	memset(&cmd_a->array[cmd_a->num_items-1], 0, sizeof(struct rarvm_prepared_command));
	return TRUE;
}

void rar_filter_array_init(rar_filter_array_t *filter_a)
{
	filter_a->array = NULL;
	filter_a->num_items = 0;
}

void rar_filter_array_reset(rar_filter_array_t *filter_a)
{
	int i;
	
	if (!filter_a) {
		return;
	}
	for (i=0 ; i < filter_a->num_items ; i++) {
		rar_filter_delete(filter_a->array[i]);
	}
	if (filter_a->array) {
		free(filter_a->array);
	}
	filter_a->array = NULL;
	filter_a->num_items = 0;
}

int rar_filter_array_add(rar_filter_array_t *filter_a, int num)
{
	filter_a->num_items += num;
	filter_a->array = (struct UnpackFilter **) rar_realloc2(filter_a->array,
			filter_a->num_items * sizeof(struct UnpackFilter **));
	if (filter_a->array == NULL) {
		filter_a->num_items=0;
		return FALSE;
	}
	filter_a->array[filter_a->num_items-1] = NULL;
	return TRUE;
}

struct UnpackFilter *rar_filter_new(void)
{
	struct UnpackFilter *filter;
	
	filter = (struct UnpackFilter *) rar_malloc(sizeof(struct UnpackFilter));
	if (!filter) {
		return NULL;
	}
	filter->block_start = 0;
  	filter->block_length = 0;
  	filter->exec_count = 0;
  	filter->next_window = 0;
  	
   	rar_cmd_array_init(&filter->prg.cmd);
	filter->prg.global_data = NULL;
	filter->prg.static_data = NULL;
	filter->prg.global_size = filter->prg.static_size = 0;
	filter->prg.filtered_data = NULL;
	filter->prg.filtered_data_size = 0;
  	return filter;
}

void rar_filter_delete(struct UnpackFilter *filter)
{
	if (!filter) {
		return;
	}
	if (filter->prg.global_data) {
		free(filter->prg.global_data);
	}
	if (filter->prg.static_data) {
		free(filter->prg.static_data);
	}
	rar_cmd_array_reset(&filter->prg.cmd);
	free(filter);
}



void *rar_malloc(size_t size)
{
	void *alloc;


    if(!size || size > RAR_MAX_ALLOCATION) {
	//fprintf(stderr, "UNRAR: rar_malloc(): Problem brato! Attempt to allocate %u bytes. Please report to http://bugs.clamav.net\n", size);
	return NULL;
    }

#define _DEBUG
#if defined(_MSC_VER) && defined(_DEBUG)
    alloc = _malloc_dbg(size, _NORMAL_BLOCK, __FILE__, __LINE__);
#else
    alloc = malloc(size);
#endif

    if(!alloc) {
	//fprintf(stderr, "UNRAR: rar_malloc(): Can't allocate memory (%u bytes).\n", size);
	perror("malloc_problem");
	return NULL;
    } else return alloc;
}

void *rar_realloc2(void *ptr, size_t size)
{
	void *alloc;


    if(!size || size > RAR_MAX_ALLOCATION) {
	//fprintf(stderr, "UNRAR: rar_realloc2(): Attempt to allocate %u bytes. Please report to http://bugs.clamav.net\n", size);
	return NULL;
    }

    alloc = realloc(ptr, size);

    if(!alloc) {
	//fprintf(stderr, "UNRAR: rar_realloc2(): Can't allocate memory (%u bytes).\n", size);
	perror("rar_realloc2");
	if(ptr)
	    free(ptr);
	return NULL;
    } else return alloc;
}


#define MAX(a,b)    (((a) > (b)) ? (a) : (b))
#define MAX_O 64

const unsigned int UNIT_SIZE=MAX(sizeof(struct ppm_context), sizeof(struct rar_mem_blk_tag));
const unsigned int FIXED_UNIT_SIZE=12;
const int INT_BITS=7, PERIOD_BITS=7, TOT_BITS=14;
const int INTERVAL=1 << 7, BIN_SCALE=1 << 14, MAX_FREQ=124;
const unsigned int TOP=1 << 24, BOT=1 << 15;

/************* Start of Allocator code block ********************/
static void sub_allocator_init(sub_allocator_t *sub_alloc)
{
	sub_alloc->sub_allocator_size = 0;
}

static void sub_allocator_insert_node(sub_allocator_t *sub_alloc, void *p, int indx)
{
	((struct rar_node *) p)->next = sub_alloc->free_list[indx].next;
	sub_alloc->free_list[indx].next = (struct rar_node *) p;
}

static void *sub_allocator_remove_node(sub_allocator_t *sub_alloc, int indx)
{
	struct rar_node *ret_val;
	
	ret_val = sub_alloc->free_list[indx].next;
	sub_alloc->free_list[indx].next = ret_val->next;
	return ret_val;
}

static int sub_allocator_u2b(int nu)
{
	return UNIT_SIZE*nu;
}

static rar_mem_blk_t* sub_allocator_mbptr(rar_mem_blk_t* base_ptr, int items)
{
        return ((rar_mem_blk_t*) (((unsigned char *)(base_ptr)) + sub_allocator_u2b(items) ));
}

static void sub_allocator_split_block(sub_allocator_t *sub_alloc, void *pv,
				int old_indx, int new_indx)
{
	int i, udiff;
	uint8_t *p;
	
	udiff = sub_alloc->indx2units[old_indx] - sub_alloc->indx2units[new_indx];
	p = ((uint8_t *) pv) + sub_allocator_u2b(sub_alloc->indx2units[new_indx]);
	if (sub_alloc->indx2units[i=sub_alloc->units2indx[udiff-1]] != udiff) {
		sub_allocator_insert_node(sub_alloc, p, --i);
		p += sub_allocator_u2b(i=sub_alloc->indx2units[i]);
		udiff -= i;
	}
	sub_allocator_insert_node(sub_alloc, p, sub_alloc->units2indx[udiff-1]);
}

static long sub_allocator_get_allocated_memory(sub_allocator_t *sub_alloc)
{
	return sub_alloc->sub_allocator_size;
}

static void sub_allocator_stop_sub_allocator(sub_allocator_t *sub_alloc)
{
	if (sub_alloc->sub_allocator_size) {
		sub_alloc->sub_allocator_size = 0;
		free(sub_alloc->heap_start);
		//printf("free heap_start\n");
	}
}

static int sub_allocator_start_sub_allocator(sub_allocator_t *sub_alloc, int sa_size)
{
	unsigned int t, alloc_size;
	
	t = sa_size << 20;
	if (sub_alloc->sub_allocator_size == t) {
		return TRUE;
	}
	sub_allocator_stop_sub_allocator(sub_alloc);
	alloc_size = t/FIXED_UNIT_SIZE*UNIT_SIZE+UNIT_SIZE;
#if defined(__sparc) || defined(sparc) || defined(__sparcv9)
	/* Allow for aligned access requirements */
	alloc_size += UNIT_SIZE;
#endif
	if ((sub_alloc->heap_start = (uint8_t *) rar_malloc(alloc_size)) == NULL) {
		rar_dbgmsg("sub_alloc start failed\n");
		return FALSE;
	}
	//printf("malloc heap_start\n");
	sub_alloc->heap_end = sub_alloc->heap_start + alloc_size - UNIT_SIZE;
	sub_alloc->sub_allocator_size = t;
	return TRUE;
}

static void sub_allocator_init_sub_allocator(sub_allocator_t *sub_alloc)
{
	int i, k;
	unsigned int size1, real_size1, size2, real_size2;

	memset(sub_alloc->free_list, 0, sizeof(sub_alloc->free_list));
	sub_alloc->ptext = sub_alloc->heap_start;
	
	size2 = FIXED_UNIT_SIZE*(sub_alloc->sub_allocator_size/8/FIXED_UNIT_SIZE*7);
	real_size2 = size2/FIXED_UNIT_SIZE*UNIT_SIZE;
	size1 = sub_alloc->sub_allocator_size - size2;
	real_size1 = size1/FIXED_UNIT_SIZE*UNIT_SIZE+size1%FIXED_UNIT_SIZE;
#if defined(__sparc) || defined(sparc) || defined(__sparcv9)
	/* Allow for aligned access requirements */
	if (size1%FIXED_UNIT_SIZE != 0) {
		real_size1 += UNIT_SIZE - size1%FIXED_UNIT_SIZE;
	}
#endif
	sub_alloc->hi_unit = sub_alloc->heap_start + sub_alloc->sub_allocator_size;
	sub_alloc->lo_unit = sub_alloc->units_start = sub_alloc->heap_start + real_size1;
	sub_alloc->fake_units_start = sub_alloc->heap_start + size1;
	sub_alloc->hi_unit = sub_alloc->lo_unit + real_size2;
	
	for (i=0,k=1; i < N1 ; i++, k+=1) {
		sub_alloc->indx2units[i] = k;
	}
	for (k++; i < N1+N2 ; i++, k+=2) {
		sub_alloc->indx2units[i] = k;
	}
	for (k++; i < N1+N2+N3 ; i++, k+=3) {
		sub_alloc->indx2units[i] = k;
	}
	for (k++; i < N1+N2+N3+N4 ; i++, k+=4) {
		sub_alloc->indx2units[i] = k;
	}
	
	for (sub_alloc->glue_count=k=i=0; k < 128; k++) {
		i += (sub_alloc->indx2units[i] < k+1);
		sub_alloc->units2indx[k] = i;
	}
}

static void rar_mem_blk_insertAt(rar_mem_blk_t *a, rar_mem_blk_t *p)
{
	a->next = (a->prev=p)->next;
	p->next = a->next->prev = a;
}

static void rar_mem_blk_remove(rar_mem_blk_t *a)
{
	a->prev->next = a->next;
	a->next->prev = a->prev;
}

static void sub_allocator_glue_free_blocks(sub_allocator_t *sub_alloc)
{
	rar_mem_blk_t s0, *p, *p1;
	int i, k, sz;
	
	if (sub_alloc->lo_unit != sub_alloc->hi_unit) {
		*sub_alloc->lo_unit = 0;
	}
	for (i=0, s0.next=s0.prev=&s0; i < N_INDEXES; i++) {
		while (sub_alloc->free_list[i].next) {
			p = (rar_mem_blk_t *) sub_allocator_remove_node(sub_alloc, i);
			rar_mem_blk_insertAt(p, &s0);
			p->stamp = 0xFFFF;
			p->nu = sub_alloc->indx2units[i];
		}
	}
	
	for (p=s0.next ; p != &s0 ; p=p->next) {
		while ((p1 = sub_allocator_mbptr(p,p->nu))->stamp == 0xFFFF &&
				((int)p->nu)+p1->nu < 0x10000) {
			rar_mem_blk_remove(p1);
			p->nu += p1->nu;
		}
	}
	
	while ((p=s0.next) != &s0) {
		for (rar_mem_blk_remove(p), sz=p->nu; sz > 128; sz-=128, p=sub_allocator_mbptr(p, 128)) {
			sub_allocator_insert_node(sub_alloc, p, N_INDEXES-1);
		}
		if (sub_alloc->indx2units[i=sub_alloc->units2indx[sz-1]] != sz) {
			k = sz-sub_alloc->indx2units[--i];
			sub_allocator_insert_node(sub_alloc, sub_allocator_mbptr(p,sz-k), k-1);
		}
		sub_allocator_insert_node(sub_alloc, p, i);
	}
}

static void *sub_allocator_alloc_units_rare(sub_allocator_t *sub_alloc, int indx)
{
	int i, j;
	void *ret_val;
	
	if (!sub_alloc->glue_count) {
		sub_alloc->glue_count = 255;
		sub_allocator_glue_free_blocks(sub_alloc);
		if (sub_alloc->free_list[indx].next) {
			return sub_allocator_remove_node(sub_alloc, indx);
		}
	}
	i=indx;
	do {
		if (++i == N_INDEXES) {
			sub_alloc->glue_count--;
			i = sub_allocator_u2b(sub_alloc->indx2units[indx]);
			j = 12 * sub_alloc->indx2units[indx];
			if (sub_alloc->fake_units_start - sub_alloc->ptext > j) {
				sub_alloc->fake_units_start -= j;
				sub_alloc->units_start -= i;
				return sub_alloc->units_start;
			}
			return NULL;
		}
	} while ( !sub_alloc->free_list[i].next);
	ret_val = sub_allocator_remove_node(sub_alloc, i);
	sub_allocator_split_block(sub_alloc, ret_val, i, indx);
	return ret_val;
}

static void *sub_allocator_alloc_units(sub_allocator_t *sub_alloc, int nu)
{
	int indx;
	void *ret_val;
	
	indx = sub_alloc->units2indx[nu-1];
	if (sub_alloc->free_list[indx].next) {
		return sub_allocator_remove_node(sub_alloc, indx);
	}
	ret_val = sub_alloc->lo_unit;
	sub_alloc->lo_unit += sub_allocator_u2b(sub_alloc->indx2units[indx]);
	if (sub_alloc->lo_unit <= sub_alloc->hi_unit) {
		return ret_val;
	}
	sub_alloc->lo_unit -= sub_allocator_u2b(sub_alloc->indx2units[indx]);
	return sub_allocator_alloc_units_rare(sub_alloc, indx);
}

static void *sub_allocator_alloc_context(sub_allocator_t *sub_alloc)
{
	if (sub_alloc->hi_unit != sub_alloc->lo_unit) {
		return (sub_alloc->hi_unit -= UNIT_SIZE);
	}
	if (sub_alloc->free_list->next) {
		return sub_allocator_remove_node(sub_alloc, 0);
	}
	return sub_allocator_alloc_units_rare(sub_alloc, 0);
}

static void *sub_allocator_expand_units(sub_allocator_t *sub_alloc, void *old_ptr, int old_nu)
{
	int i0, i1;
	void *ptr;
	
	i0 = sub_alloc->units2indx[old_nu-1];
	i1 = sub_alloc->units2indx[old_nu];
	if (i0 == i1) {
		return old_ptr;
	}
	ptr = sub_allocator_alloc_units(sub_alloc, old_nu+1);
	if (ptr) {
		memcpy(ptr, old_ptr, sub_allocator_u2b(old_nu));
		sub_allocator_insert_node(sub_alloc, old_ptr, i0);
	}
	return ptr;
}

static void *sub_allocator_shrink_units(sub_allocator_t *sub_alloc, void *old_ptr,
			int old_nu, int new_nu)
{
	int i0, i1;
	void *ptr;
	
	i0 = sub_alloc->units2indx[old_nu-1];
	i1 = sub_alloc->units2indx[new_nu-1];
	if (i0 == i1) {
		return old_ptr;
	}
	if (sub_alloc->free_list[i1].next) {
		ptr = sub_allocator_remove_node(sub_alloc, i1);
		memcpy(ptr, old_ptr, sub_allocator_u2b(new_nu));
		sub_allocator_insert_node(sub_alloc, old_ptr, i0);
		return ptr;
	} else {
		sub_allocator_split_block(sub_alloc, old_ptr, i0, i1);
		return old_ptr;
	}
}

static void  sub_allocator_free_units(sub_allocator_t *sub_alloc, void *ptr, int old_nu)
{
	sub_allocator_insert_node(sub_alloc, ptr, sub_alloc->units2indx[old_nu-1]);
}

/************** End of Allocator code block *********************/

/************** Start of Range Coder code block *********************/
static void range_coder_init_decoder(unsigned char *key, unsigned char *iv,range_coder_t *coder, int fd,
			unpack_data_t *unpack_data)
{
	int i;
	coder->low = coder->code = 0;
	coder->range = (unsigned int) -1;
	
	for (i=0; i < 4 ; i++) {
		coder->code = (coder->code << 8) | rar_get_char(key,iv,fd, unpack_data);
	}
}

static int coder_get_current_count(range_coder_t *coder)
{
	return (coder->code - coder->low) / (coder->range /= coder->scale);
}

static unsigned int  coder_get_current_shift_count(range_coder_t *coder, unsigned int shift)
{
	return (coder->code - coder->low) / (coder->range >>= shift);
}

#define ARI_DEC_NORMALISE(key,iv,fd, unpack_data, code, low, range)					\
{												\
	while ((low^(low+range)) < TOP || (range < BOT && ((range=-low&(BOT-1)),1))) {		\
		code = (code << 8) | rar_get_char(key,iv,fd, unpack_data);				\
		range <<= 8;									\
		low <<= 8;									\
	}											\
}

static void coder_decode(range_coder_t *coder)
{
	coder->low += coder->range * coder->low_count;
	coder->range *= coder->high_count - coder->low_count;
}

/******(******** End of Range Coder code block ***********(**********/

static void see2_init(struct see2_context_tag *see2_cont, int init_val)
{
	see2_cont->summ = init_val << (see2_cont->shift=PERIOD_BITS-4);
	see2_cont->count = 4;
}

static unsigned int get_mean(struct see2_context_tag *see2_cont)
{
	unsigned int ret_val;
	
	ret_val = see2_cont->summ >> see2_cont->shift;
	see2_cont->summ -= ret_val;
	return ret_val + (ret_val == 0);
}

static void update(struct see2_context_tag *see2_cont)
{
	if (see2_cont->shift < PERIOD_BITS && --see2_cont->count == 0) {
		see2_cont->summ += see2_cont->summ;
		see2_cont->count = 3 << see2_cont->shift++;
	}
}

static int restart_model_rare(ppm_data_t *ppm_data)
{
	int i, k, m;
	static const uint16_t init_bin_esc[] = {
		0x3cdd, 0x1f3f, 0x59bf, 0x48f3, 0x64a1, 0x5abc, 0x6632, 0x6051
	};
	rar_dbgmsg("in restart_model_rare\n");
	memset(ppm_data->char_mask, 0, sizeof(ppm_data->char_mask));
	
	sub_allocator_init_sub_allocator(&ppm_data->sub_alloc);
	
	ppm_data->init_rl=-(ppm_data->max_order < 12 ? ppm_data->max_order:12)-1;
	ppm_data->min_context = ppm_data->max_context =
		(struct ppm_context *) sub_allocator_alloc_context(&ppm_data->sub_alloc);
	if(!ppm_data->min_context) {
	    rar_dbgmsg("unrar: restart_model_rare: sub_allocator_alloc_context failed\n"); /* FIXME: cli_errmsg */
	    return FALSE;
	}
	ppm_data->min_context->suffix = NULL;
	ppm_data->order_fall = ppm_data->max_order;
	ppm_data->min_context->con_ut.u.summ_freq = (ppm_data->min_context->num_stats=256)+1;
	ppm_data->found_state = ppm_data->min_context->con_ut.u.stats=
		(struct state_tag *)sub_allocator_alloc_units(&ppm_data->sub_alloc, 256/2);
	if(!ppm_data->found_state) {
	    rar_dbgmsg("unrar: restart_model_rare: sub_allocator_alloc_units failed\n"); /* FIXME: cli_errmsg */
	    return FALSE;
	}
	for (ppm_data->run_length = ppm_data->init_rl, ppm_data->prev_success=i=0; i < 256 ; i++) {
		ppm_data->min_context->con_ut.u.stats[i].symbol = i;
		ppm_data->min_context->con_ut.u.stats[i].freq = 1;
		ppm_data->min_context->con_ut.u.stats[i].successor = NULL;
	}
	
	for (i=0 ; i < 128 ; i++) {
		for (k=0 ; k < 8 ; k++) {
			for (m=0 ; m < 64 ; m+=8) {
				ppm_data->bin_summ[i][k+m]=BIN_SCALE-init_bin_esc[k]/(i+2);
			}
		}
	}
	for (i=0; i < 25; i++) {
		for (k=0 ; k < 16 ; k++) {
			see2_init(&ppm_data->see2cont[i][k], 5*i+10);
		}
	}

	return TRUE;
}
	
static int start_model_rare(ppm_data_t *ppm_data, int max_order)
{
	int i, k, m, step;
	
	ppm_data->esc_count = 1;
	ppm_data->max_order = max_order;
	
	if (!restart_model_rare(ppm_data)) {
	    rar_dbgmsg("unrar: start_model_rare: restart_model_rare failed\n");
	    return FALSE;
	}
	
	ppm_data->ns2bsindx[0] = 2*0;
	ppm_data->ns2bsindx[1] = 2*1;
	
	memset(ppm_data->ns2bsindx+2, 2*2, 9);
	memset(ppm_data->ns2bsindx+11, 2*3, 256-11);
	
	for (i=0 ; i < 3; i++) {
		ppm_data->ns2indx[i] = i;
	}
	for (m=i, k=step=1; i < 256; i++) {
		ppm_data->ns2indx[i]=m;
		if (!--k) {
			k = ++step;
			m++;
		}
	}
	memset(ppm_data->hb2flag, 0, 0x40);
	memset(ppm_data->hb2flag+0x40, 0x08, 0x100-0x40);
	ppm_data->dummy_sse2cont.shift = PERIOD_BITS;
	return TRUE;
}

	
/* ****************** PPM Code ***************/

static void ppmd_swap(struct state_tag *p0, struct state_tag *p1)
{
	struct state_tag tmp;
	
	tmp = *p0;
	*p0 = *p1;
	*p1 = tmp;
}

static void rescale(ppm_data_t *ppm_data, struct ppm_context *context)
{
	int old_ns, i, adder, esc_freq, n0, n1;
	struct state_tag *p1, *p;
	
	rar_dbgmsg("in rescale\n");
	old_ns = context->num_stats;
	i = context->num_stats-1;
	
	for (p=ppm_data->found_state ; p != context->con_ut.u.stats ; p--) {
		ppmd_swap(&p[0], &p[-1]);
	}
	context->con_ut.u.stats->freq += 4;
	context->con_ut.u.summ_freq += 4;
	esc_freq = context->con_ut.u.summ_freq - p->freq;
	adder = (ppm_data->order_fall != 0);
	context->con_ut.u.summ_freq = (p->freq = (p->freq+adder) >> 1);
	do {
		esc_freq -= (++p)->freq;
		context->con_ut.u.summ_freq += (p->freq = (p->freq + adder) >> 1);
		if (p[0].freq > p[-1].freq) {
			struct state_tag tmp = *(p1=p);
			do {
				p1[0] = p1[-1];
			} while (--p1 != context->con_ut.u.stats && tmp.freq > p1[-1].freq);
			*p1 = tmp;
		}
	} while (--i);
	
	if (p->freq == 0) {
		do {
			i++;
		} while ((--p)->freq == 0);
		esc_freq += i;
		if ((context->num_stats -= i) == 1) {
			struct state_tag tmp = *context->con_ut.u.stats;
			do {
				tmp.freq -= (tmp.freq >> 1);
				esc_freq >>= 1;
			} while (esc_freq > 1);
			sub_allocator_free_units(&ppm_data->sub_alloc,
					context->con_ut.u.stats, (old_ns+1)>>1);
			*(ppm_data->found_state=&context->con_ut.one_state)=tmp;
			return;
		}
	}
	context->con_ut.u.summ_freq += (esc_freq -= (esc_freq >> 1));
	n0 = (old_ns+1) >> 1;
	n1 = (context->num_stats+1) >> 1;
	if (n0 != n1) {
		context->con_ut.u.stats = (struct state_tag *) sub_allocator_shrink_units(&ppm_data->sub_alloc,
						context->con_ut.u.stats, n0, n1);
	}
	ppm_data->found_state = context->con_ut.u.stats;
}

static struct ppm_context *create_child(ppm_data_t *ppm_data, struct ppm_context *context,
				struct state_tag *pstats, struct state_tag *first_state)
{
	struct ppm_context *pc;
	rar_dbgmsg("in create_child\n");
	pc = (struct ppm_context *) sub_allocator_alloc_context(&ppm_data->sub_alloc);
	if (pc) {
		pc->num_stats = 1;
		pc->con_ut.one_state = *first_state;
		pc->suffix = context;
		pstats->successor = pc;
	}
	return pc;
}

static struct ppm_context *create_successors(ppm_data_t *ppm_data,
			int skip, struct state_tag *p1)
{
	struct state_tag up_state;
	struct ppm_context *pc, *up_branch;
	struct state_tag *p, *ps[MAX_O], **pps;
	unsigned int cf, s0;
	
	rar_dbgmsg("in create_successors\n");
	pc = ppm_data->min_context;
	up_branch = ppm_data->found_state->successor;
	pps = ps;
	
	if (!skip) {
		*pps++ = ppm_data->found_state;
		if (!pc->suffix) {
			goto NO_LOOP;
		}
	}
	if (p1) {
		p = p1;
		pc = pc->suffix;
		goto LOOP_ENTRY;
	}
	do {
		pc = pc->suffix;
		if (pc->num_stats != 1) {
			if ((p=pc->con_ut.u.stats)->symbol != ppm_data->found_state->symbol) {
				do {
					p++;
				} while (p->symbol != ppm_data->found_state->symbol);
			}
		} else {
			p = &(pc->con_ut.one_state);
		}
LOOP_ENTRY:
		if (p->successor != up_branch) {
			pc = p->successor;
			break;
		}
		*pps++ = p;
	} while (pc->suffix);
NO_LOOP:
	if (pps == ps) {
		return pc;
	}
	up_state.symbol= *(uint8_t *) up_branch;
	up_state.successor = (struct ppm_context *) (((uint8_t *) up_branch)+1);
	if (pc->num_stats != 1) {
		if ((uint8_t *) pc <= ppm_data->sub_alloc.ptext) {
			return NULL;
		}
		if ((p=pc->con_ut.u.stats)->symbol != up_state.symbol) {
			do {
				p++;
			} while (p->symbol != up_state.symbol);
		}
		cf = p->freq - 1;
		s0 = pc->con_ut.u.summ_freq - pc->num_stats - cf;
		up_state.freq = 1 + ((2*cf <= s0)?(5*cf > s0):((2*cf+3*s0-1)/(2*s0)));
	} else {
		up_state.freq = pc->con_ut.one_state.freq;
	}
	do {
		pc = create_child(ppm_data, pc, *--pps, &up_state);
		if (!pc) {
			rar_dbgmsg("create_child failed\n");
			return NULL;
		}
	} while (pps != ps);
	return pc;
}

static int update_model(ppm_data_t *ppm_data)
{
	struct state_tag fs, *p;
	struct ppm_context *pc, *successor;
	unsigned int ns1, ns, cf, sf, s0;
	
	rar_dbgmsg("in update_model\n");
	fs = *ppm_data->found_state;
	p = NULL;

	if (fs.freq < MAX_FREQ/4 && (pc=ppm_data->min_context->suffix) != NULL) {
		if (pc->num_stats != 1) {
			if ((p=pc->con_ut.u.stats)->symbol != fs.symbol) {
				do {
					p++;
				} while (p->symbol != fs.symbol);
				if (p[0].freq >= p[-1].freq) {
					ppmd_swap(&p[0], &p[-1]);
					p--;
				}
			}
			if (p->freq < MAX_FREQ-9) {
				p->freq += 2;
				pc->con_ut.u.summ_freq += 2;
			}
		} else {
			p = &(pc->con_ut.one_state);
			p->freq += (p->freq < 32);
		}
	}
	if (!ppm_data->order_fall) {
		ppm_data->min_context = ppm_data->max_context =
			ppm_data->found_state->successor = create_successors(ppm_data, TRUE, p);
		if (!ppm_data->min_context) {
			goto RESTART_MODEL;
		}
		return TRUE;
	}
	*ppm_data->sub_alloc.ptext++ = fs.symbol;
	successor = (struct ppm_context *) ppm_data->sub_alloc.ptext;
	if (ppm_data->sub_alloc.ptext >= ppm_data->sub_alloc.fake_units_start) {
		goto RESTART_MODEL;
	}
	if (fs.successor) {
		if ((uint8_t *)fs.successor <= ppm_data->sub_alloc.ptext &&
				(fs.successor = create_successors(ppm_data, FALSE, p)) == NULL) {
			goto RESTART_MODEL;
		}
		if (!--ppm_data->order_fall) {
			successor = fs.successor;
			ppm_data->sub_alloc.ptext -= (ppm_data->max_context != ppm_data->min_context);
		}
	} else {
		ppm_data->found_state->successor = successor;
		fs.successor = ppm_data->min_context;
	}
	s0 = ppm_data->min_context->con_ut.u.summ_freq-(ns=ppm_data->min_context->num_stats)-(fs.freq-1);
	for (pc=ppm_data->max_context; pc != ppm_data->min_context ; pc=pc->suffix) {
		if ((ns1=pc->num_stats) != 1) {
			if ((ns1 & 1) == 0) {
				pc->con_ut.u.stats = (struct state_tag *)
					sub_allocator_expand_units(&ppm_data->sub_alloc,
								pc->con_ut.u.stats, ns1>>1);
				if (!pc->con_ut.u.stats) {
					goto RESTART_MODEL;
				}
			}
			pc->con_ut.u.summ_freq += (2*ns1 < ns)+2*((4*ns1 <= ns) & (pc->con_ut.u.summ_freq <= 8*ns1));
		} else {
			p = (struct state_tag *) sub_allocator_alloc_units(&ppm_data->sub_alloc, 1);
			if (!p) {
				goto RESTART_MODEL;
			}
			*p = pc->con_ut.one_state;
			pc->con_ut.u.stats = p;
			if (p->freq < MAX_FREQ/4-1) {
				p->freq += p->freq;
			} else {
				p->freq = MAX_FREQ - 4;
			}
			pc->con_ut.u.summ_freq = p->freq + ppm_data->init_esc + (ns > 3);
		}
		cf = 2*fs.freq*(pc->con_ut.u.summ_freq+6);
		sf = s0 + pc->con_ut.u.summ_freq;
		if (cf < 6*sf) {
			cf = 1 + (cf > sf) + (cf >= 4*sf);
			pc->con_ut.u.summ_freq += 3;
		} else {
			cf = 4 + (cf >= 9*sf) + (cf >= 12*sf) + (cf >= 15*sf);
			pc->con_ut.u.summ_freq += cf;
		}
		p = pc->con_ut.u.stats + ns1;
		p->successor = successor;
		p->symbol = fs.symbol;
		p->freq = cf;
		pc->num_stats = ++ns1;
	}
	ppm_data->max_context = ppm_data->min_context = fs.successor;
	return TRUE;
	
RESTART_MODEL:
	if (!restart_model_rare(ppm_data)) {
	    rar_dbgmsg("unrar: update_model: restart_model_rare: failed\n");
	    return FALSE;
	}
	ppm_data->esc_count = 0;
	return TRUE;
}

static void update1(ppm_data_t *ppm_data, struct state_tag *p, struct ppm_context *context)
{
	rar_dbgmsg("in update1\n");
	(ppm_data->found_state=p)->freq += 4;
	context->con_ut.u.summ_freq += 4;
	if (p[0].freq > p[-1].freq) {
		ppmd_swap(&p[0], &p[-1]);
		ppm_data->found_state = --p;
		if (p->freq > MAX_FREQ) {
			rescale(ppm_data, context);
		}
	}
}

static int ppm_decode_symbol1(ppm_data_t *ppm_data, struct ppm_context *context)
{
	struct state_tag *p;
	int i, hi_cnt, count;
	
	rar_dbgmsg("in ppm_decode_symbol1\n");
	ppm_data->coder.scale = context->con_ut.u.summ_freq;
	p = context->con_ut.u.stats;
	count = coder_get_current_count(&ppm_data->coder);
	if (count >= ppm_data->coder.scale) {
		return FALSE;
	}
	if (count < (hi_cnt = p->freq)) {
		ppm_data->prev_success = (2 * (ppm_data->coder.high_count=hi_cnt) >
						ppm_data->coder.scale);
		ppm_data->run_length += ppm_data->prev_success;
		(ppm_data->found_state=p)->freq=(hi_cnt += 4);
		context->con_ut.u.summ_freq += 4;
		if (hi_cnt > MAX_FREQ) {
			rescale(ppm_data, context);
		}
		ppm_data->coder.low_count = 0;
		return TRUE;
	} else if (ppm_data->found_state == NULL) {
		return FALSE;
	}
	ppm_data->prev_success = 0;
	i = context->num_stats-1;
	while ((hi_cnt += (++p)->freq) <= count) {
		if (--i == 0) {
			ppm_data->hi_bits_flag = ppm_data->hb2flag[ppm_data->found_state->symbol];
			ppm_data->coder.low_count = hi_cnt;
			ppm_data->char_mask[p->symbol] = ppm_data->esc_count;
			i = (ppm_data->num_masked=context->num_stats) - 1;
			ppm_data->found_state = NULL;
			do {
				ppm_data->char_mask[(--p)->symbol] = ppm_data->esc_count;
			} while (--i);
			ppm_data->coder.high_count = ppm_data->coder.scale;
			return TRUE;
		}
	}
	ppm_data->coder.low_count = (ppm_data->coder.high_count = hi_cnt) - p->freq;
	update1(ppm_data, p, context);
	return TRUE;
}

static const uint8_t ExpEscape[16]={ 25,14, 9, 7, 5, 5, 4, 4, 4, 3, 3, 3, 2, 2, 2, 2 };
#define GET_MEAN(SUMM,SHIFT,ROUND) ((SUMM+(1 << (SHIFT-ROUND))) >> (SHIFT))

static void ppm_decode_bin_symbol(ppm_data_t *ppm_data, struct ppm_context *context)
{
	struct state_tag *rs;
	uint16_t *bs;
	
	rar_dbgmsg("in ppm_decode_bin_symbol\n");
	
	rs = &context->con_ut.one_state;
	
	ppm_data->hi_bits_flag = ppm_data->hb2flag[ppm_data->found_state->symbol];
	bs = &ppm_data->bin_summ[rs->freq-1][ppm_data->prev_success +
		ppm_data->ns2bsindx[context->suffix->num_stats-1] +
		ppm_data->hi_bits_flag+2*ppm_data->hb2flag[rs->symbol] +
		((ppm_data->run_length >> 26) & 0x20)];
	if (coder_get_current_shift_count(&ppm_data->coder, TOT_BITS) < *bs) {
		ppm_data->found_state = rs;
		rs->freq += (rs->freq < 128);
		ppm_data->coder.low_count = 0;
		ppm_data->coder.high_count = *bs;
		*bs = (uint16_t) (*bs + INTERVAL - GET_MEAN(*bs, PERIOD_BITS, 2));
		ppm_data->prev_success = 1;
		ppm_data->run_length++;
	} else {
		ppm_data->coder.low_count = *bs;
		*bs = (uint16_t) (*bs - GET_MEAN(*bs, PERIOD_BITS, 2));
		ppm_data->coder.high_count = BIN_SCALE;
		ppm_data->init_esc = ExpEscape[*bs >> 10];
		ppm_data->num_masked = 1;
		ppm_data->char_mask[rs->symbol] = ppm_data->esc_count;
		ppm_data->prev_success = 0;
		ppm_data->found_state = NULL;
	}
}

static void update2(ppm_data_t *ppm_data, struct state_tag *p, struct ppm_context *context)
{
	rar_dbgmsg("in update2\n");
	(ppm_data->found_state = p)->freq += 4;
	context->con_ut.u.summ_freq += 4;
	if (p->freq > MAX_FREQ) {
		rescale(ppm_data, context);
	}
	ppm_data->esc_count++;
	ppm_data->run_length = ppm_data->init_rl;
}

static struct see2_context_tag *make_esc_freq(ppm_data_t *ppm_data,
			struct ppm_context *context, int diff)
{
	struct see2_context_tag *psee2c;
	
	if (context->num_stats != 256) {
		psee2c = ppm_data->see2cont[ppm_data->ns2indx[diff-1]] +
			(diff < context->suffix->num_stats-context->num_stats) +
			2 * (context->con_ut.u.summ_freq < 11*context->num_stats)+4*
			(ppm_data->num_masked > diff) +	ppm_data->hi_bits_flag;
		ppm_data->coder.scale = get_mean(psee2c);
	} else {
		psee2c = &ppm_data->dummy_sse2cont;
		ppm_data->coder.scale = 1;
	}
	return psee2c;
}

static int ppm_decode_symbol2(ppm_data_t *ppm_data, struct ppm_context *context)
{
	int count, hi_cnt, i;
	struct see2_context_tag *psee2c;
	struct state_tag *ps[256], **pps, *p;
	
	rar_dbgmsg("in ppm_decode_symbol2\n");
	i = context->num_stats - ppm_data->num_masked;
	psee2c = make_esc_freq(ppm_data, context, i);
	pps = ps;
	p = context->con_ut.u.stats - 1;
	hi_cnt = 0;
	
	do {
		do {
			p++;
		} while (ppm_data->char_mask[p->symbol] == ppm_data->esc_count);
		hi_cnt += p->freq;
		*pps++ = p;
	} while (--i);
	ppm_data->coder.scale += hi_cnt;
	count = coder_get_current_count(&ppm_data->coder);
	if (count >= ppm_data->coder.scale) {
		return FALSE;
	}
	p=*(pps=ps);
	if (count < hi_cnt) {
		hi_cnt = 0;
		while ((hi_cnt += p->freq) <= count) {
			p=*++pps;
		}
		ppm_data->coder.low_count = (ppm_data->coder.high_count=hi_cnt) - p->freq;
		update(psee2c);
		update2(ppm_data, p, context);
	} else {
		ppm_data->coder.low_count = hi_cnt;
		ppm_data->coder.high_count = ppm_data->coder.scale;
		i = context->num_stats - ppm_data->num_masked;
		pps--;
		do {
			ppm_data->char_mask[(*++pps)->symbol] = ppm_data->esc_count;
		} while (--i);
		psee2c->summ += ppm_data->coder.scale;
		ppm_data->num_masked = context->num_stats;
	}
	return TRUE;
}

static void clear_mask(ppm_data_t *ppm_data)
{
	ppm_data->esc_count = 1;
	memset(ppm_data->char_mask, 0, sizeof(ppm_data->char_mask));
}

void ppm_constructor(ppm_data_t *ppm_data)
{
	sub_allocator_init(&ppm_data->sub_alloc);
	ppm_data->min_context = NULL;
	ppm_data->max_context = NULL;
}

void ppm_destructor(ppm_data_t *ppm_data)
{
	sub_allocator_stop_sub_allocator(&ppm_data->sub_alloc);
}

int ppm_decode_init(unsigned char *key, unsigned char *iv,ppm_data_t *ppm_data, int fd, unpack_data_t *unpack_data, int *EscChar)
{
	int max_order, Reset, MaxMB;
	
	max_order = rar_get_char(key,iv,fd, unpack_data);
	if (max_order>63) return FALSE;
	rar_dbgmsg("ppm_decode_init max_order=%d\n", max_order);
	Reset = (max_order & 0x20) ? 1 : 0;
	rar_dbgmsg("ppm_decode_init Reset=%d\n", Reset);
	if (Reset) {
		MaxMB = rar_get_char(key,iv,fd, unpack_data);
		if (MaxMB>127) return FALSE;
		rar_dbgmsg("ppm_decode_init MaxMB=%d\n", MaxMB);
	} else {
		return FALSE;
		if (sub_allocator_get_allocated_memory(&ppm_data->sub_alloc) == 0) {
			return FALSE;
		}
	}
	if (max_order & 0x40) {
		*EscChar = rar_get_char(key,iv,fd, unpack_data);
		rar_dbgmsg("ppm_decode_init EscChar=%d\n", *EscChar);
	}
	range_coder_init_decoder(key,iv,&ppm_data->coder, fd, unpack_data);
	if (Reset) {
		max_order = (max_order & 0x1f) + 1;
		if (max_order > 16) {
			max_order = 16 + (max_order - 16) * 3;
		}
		if (max_order == 1) {
			sub_allocator_stop_sub_allocator(&ppm_data->sub_alloc);
			return FALSE;
		}
		if(!sub_allocator_start_sub_allocator(&ppm_data->sub_alloc, MaxMB+1)) {
		    sub_allocator_stop_sub_allocator(&ppm_data->sub_alloc);
		    return FALSE;
		}
		if (!start_model_rare(ppm_data, max_order)) {
		    sub_allocator_stop_sub_allocator(&ppm_data->sub_alloc);
		    return FALSE;
		}
	}
	rar_dbgmsg("ppm_decode_init done: %d\n", ppm_data->min_context != NULL);
	return (ppm_data->min_context != NULL);
}

int ppm_decode_char(unsigned char *key, unsigned char *iv,ppm_data_t *ppm_data, int fd, unpack_data_t *unpack_data)
{
	int symbol;

	if ((uint8_t *) ppm_data->min_context <= ppm_data->sub_alloc.ptext ||
			(uint8_t *)ppm_data->min_context > ppm_data->sub_alloc.heap_end) {
		return -1;
	}
	if (ppm_data->min_context->num_stats != 1) {
		if ((uint8_t *) ppm_data->min_context->con_ut.u.stats <= ppm_data->sub_alloc.ptext ||
			(uint8_t *) ppm_data->min_context->con_ut.u.stats > ppm_data->sub_alloc.heap_end) {
			return -1;
		}
		if (!ppm_decode_symbol1(ppm_data, ppm_data->min_context)) {
			return -1;
		}
	} else {
		ppm_decode_bin_symbol(ppm_data, ppm_data->min_context);
	}
	coder_decode(&ppm_data->coder);
	
	while (!ppm_data->found_state) {
		ARI_DEC_NORMALISE(key,iv,fd, unpack_data, ppm_data->coder.code, 
				ppm_data->coder.low, ppm_data->coder.range);
		do {
			ppm_data->order_fall++;
			ppm_data->min_context = ppm_data->min_context->suffix;
			if ((uint8_t *)ppm_data->min_context <= ppm_data->sub_alloc.ptext ||
					(uint8_t *)ppm_data->min_context >
					ppm_data->sub_alloc.heap_end) {
				return -1;
			}
		} while (ppm_data->min_context->num_stats == ppm_data->num_masked);
		if (!ppm_decode_symbol2(ppm_data, ppm_data->min_context)) {
			return -1;
		}
		coder_decode(&ppm_data->coder);
	}
	
	symbol = ppm_data->found_state->symbol;
	if (!ppm_data->order_fall && (uint8_t *) ppm_data->found_state->successor > ppm_data->sub_alloc.ptext) {
		ppm_data->min_context = ppm_data->max_context = ppm_data->found_state->successor;
	} else {
		if(!update_model(ppm_data)) {
		    rar_dbgmsg("unrar: ppm_decode_char: update_model failed\n");
		    return -1;
		}

		if (ppm_data->esc_count == 0) {
			clear_mask(ppm_data);
		}
	}
	ARI_DEC_NORMALISE(key,iv,fd, unpack_data, ppm_data->coder.code, ppm_data->coder.low,
				ppm_data->coder.range);
	return symbol;
}



#if WORDS_BIGENDIAN == 0
#define GET_VALUE(byte_mode,addr) ((byte_mode) ? (*(unsigned char *)(addr)) : UINT32((*(unsigned int *)(addr))))
#else
#define GET_VALUE(byte_mode,addr) rarvm_get_value(byte_mode, (unsigned int *)addr)
#endif

void rarvm_set_value(int byte_mode, unsigned int *addr, unsigned int value)
{
	if (byte_mode) {
		*(unsigned char *)addr=value;
	} else {
#if WORDS_BIGENDIAN == 0
		*(uint32_t *)addr = value;
#else
		((unsigned char *)addr)[0]=(unsigned char)value;
		((unsigned char *)addr)[1]=(unsigned char)(value>>8);
		((unsigned char *)addr)[2]=(unsigned char)(value>>16);
		((unsigned char *)addr)[3]=(unsigned char)(value>>24);
#endif
	}
}

		
#if WORDS_BIGENDIAN == 0
#define SET_VALUE(byte_mode,addr,value) ((byte_mode) ? (*(unsigned char *)(addr)=(value)):(*(uint32_t *)(addr)=((uint32_t)(value))))
#else
#define SET_VALUE(byte_mode,addr,value) rarvm_set_value(byte_mode, (unsigned int *)addr, value);
#endif

uint32_t crc_tab[256];

static void rar_crc_init()
{
	int i, j;
	unsigned int c;
	
	for (i=0 ; i < 256 ; i++) {
		c = i;
		for (j = 0 ; j < 8 ; j++) {
			c = (c & 1) ? (c >> 1) ^ 0xedb88320L : (c>>1);
		}
		crc_tab[i] = c;
	}
}

uint32_t rar_crc(uint32_t start_crc, void *addr, uint32_t size)
{
	unsigned char *data;
	int i;

	data = addr;
#if WORDS_BIGENDIAN == 0
	while (size > 0 && (*(int *)data & 7))
	{
		start_crc = crc_tab[(unsigned char)(start_crc^data[0])]^(start_crc>>8);
		size--;
		data++;
	}
	while (size >= 8)
	{
		start_crc ^= *(uint32_t *) data;
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc ^= *(uint32_t *)(data+4);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		start_crc = crc_tab[(unsigned char)start_crc] ^ (start_crc>>8);
		data += 8;
		size -= 8;
	}
#endif
	for (i=0 ; i < size ; i++) {
		start_crc = crc_tab[(unsigned char)(start_crc^data[i])]^(start_crc >> 8);
	}
	return start_crc;
}

int rarvm_init(rarvm_data_t *rarvm_data)
{
	rarvm_data->mem = (uint8_t *) rar_malloc(RARVM_MEMSIZE+4);
	//printf("malloc datamem\n");
	rar_crc_init();
	if (!rarvm_data->mem) {
		return FALSE;
	}
	return TRUE;
}

void rarvm_free(rarvm_data_t *rarvm_data)
{
	//printf("free datamemvm\n");
	if (rarvm_data && rarvm_data->mem) {
		free(rarvm_data->mem);
		rarvm_data->mem = NULL;
	}
}

void rarvm_addbits(rarvm_input_t *rarvm_input, int bits)
{
	bits += rarvm_input->in_bit;
	rarvm_input->in_addr += bits >> 3;
	rarvm_input->in_bit = bits & 7;
}

unsigned int rarvm_getbits(rarvm_input_t *rarvm_input)
{
	unsigned int bit_field;

	bit_field = (unsigned int) rarvm_input->in_buf[rarvm_input->in_addr] << 16;
	bit_field |= (unsigned int) rarvm_input->in_buf[rarvm_input->in_addr+1] << 8;
	bit_field |= (unsigned int) rarvm_input->in_buf[rarvm_input->in_addr+2];
	bit_field >>= (8-rarvm_input->in_bit);

	return (bit_field & 0xffff);
}

unsigned int rarvm_read_data(rarvm_input_t *rarvm_input)
{
	unsigned int data;
	
	data = rarvm_getbits(rarvm_input);
	rar_dbgmsg("rarvm_read_data getbits=%u\n", data);
	switch (data & 0xc000) {
	case 0:
		rarvm_addbits(rarvm_input,6);
		rar_dbgmsg("rarvm_read_data=%u\n", ((data>>10)&0x0f));
		return ((data>>10)&0x0f);
	case 0x4000:
		if ((data & 0x3c00) == 0) {
			data = 0xffffff00 | ((data>>2) & 0xff);
			rarvm_addbits(rarvm_input,14);
		} else {
			data = (data >> 6) &0xff;
			rarvm_addbits(rarvm_input,10);
		}
		rar_dbgmsg("rarvm_read_data=%u\n", data);
		return data;
	case 0x8000:
		rarvm_addbits(rarvm_input,2);
		data = rarvm_getbits(rarvm_input);
		rarvm_addbits(rarvm_input,16);
		rar_dbgmsg("rarvm_read_data=%u\n", data);
		return data;
	default:
		rarvm_addbits(rarvm_input,2);
		data = (rarvm_getbits(rarvm_input) << 16);
		rarvm_addbits(rarvm_input,16);
		data |= rarvm_getbits(rarvm_input);
		rarvm_addbits(rarvm_input,16);
		rar_dbgmsg("rarvm_read_data=%u\n", data);
		return data;
	}
}

static rarvm_standard_filters_t is_standard_filter(unsigned char *code, int code_size)
{
	uint32_t code_crc;
	int i;

	struct standard_filter_signature
	{
		int length;
		uint32_t crc;
		rarvm_standard_filters_t type;
	} std_filt_list[] = {
		{53,  0xad576887, VMSF_E8},
		{57,  0x3cd7e57e, VMSF_E8E9},
		{120, 0x3769893f, VMSF_ITANIUM},
		{29,  0x0e06077d, VMSF_DELTA},
		{149, 0x1c2c5dc8, VMSF_RGB},
 		{216, 0xbc85e701, VMSF_AUDIO},
		{40,  0x46b9c560, VMSF_UPCASE}
	};
	
	code_crc = rar_crc(0xffffffff, code, code_size)^0xffffffff;
	rar_dbgmsg("code_crc=%u\n", code_crc);
	for (i=0 ; i<sizeof(std_filt_list)/sizeof(std_filt_list[0]) ; i++) {
		if (std_filt_list[i].crc == code_crc && std_filt_list[i].length == code_size) {
			return std_filt_list[i].type;
		}
	}
	return VMSF_NONE;
}

void rarvm_set_memory(rarvm_data_t *rarvm_data, unsigned int pos, uint8_t *data, unsigned int data_size)
{
	if (pos<RARVM_MEMSIZE && data!=rarvm_data->mem+pos) {
		memmove(rarvm_data->mem+pos, data, MIN(data_size, RARVM_MEMSIZE-pos));
	}
}

static unsigned int *rarvm_get_operand(rarvm_data_t *rarvm_data,
				struct rarvm_prepared_operand *cmd_op)
{
	if (cmd_op->type == VM_OPREGMEM) {
		return ((unsigned int *)&rarvm_data->mem[(*cmd_op->addr+cmd_op->base) & RARVM_MEMMASK]);
	} else {
		return cmd_op->addr;
	}
}

static unsigned int filter_itanium_getbits(unsigned char *data, int bit_pos, int bit_count)
{
	int in_addr=bit_pos/8;
	int in_bit=bit_pos&7;
	unsigned int bit_field=(unsigned int)data[in_addr++];
	bit_field|=(unsigned int)data[in_addr++] << 8;
	bit_field|=(unsigned int)data[in_addr++] << 16;
	bit_field|=(unsigned int)data[in_addr] << 24;
	bit_field >>= in_bit;
	return(bit_field & (0xffffffff>>(32-bit_count)));
}

static void filter_itanium_setbits(unsigned char *data, unsigned int bit_field, int bit_pos, int bit_count)
{
	int i, in_addr=bit_pos/8;
	int in_bit=bit_pos&7;
	unsigned int and_mask=0xffffffff>>(32-bit_count);
	and_mask=~(and_mask<<in_bit);

	bit_field<<=in_bit;

	for (i=0 ; i<4 ; i++) {
		data[in_addr+i]&=and_mask;
		data[in_addr+i]|=bit_field;
		and_mask=(and_mask>>8)|0xff000000;
		bit_field>>=8;
	}
}

static void execute_standard_filter(rarvm_data_t *rarvm_data, rarvm_standard_filters_t filter_type)
{
	unsigned char *data, cmp_byte2, cur_byte, *src_data, *dest_data;
	int i, j, data_size, channels, src_pos, dest_pos, border, width, PosR;
	int op_type, cur_channel, byte_count, start_pos, pa, pb, pc;
	unsigned int file_offset, cur_pos, predicted;
	int32_t offset, addr;
	const int file_size=0x1000000;

	switch(filter_type) {
	case VMSF_E8:
	case VMSF_E8E9:
		data=rarvm_data->mem;
		data_size = rarvm_data->R[4];
		file_offset = rarvm_data->R[6];

		if ((data_size >= VM_GLOBALMEMADDR) || (data_size < 4)) {
			break;
		}

		cmp_byte2 = filter_type==VMSF_E8E9 ? 0xe9:0xe8;
		for (cur_pos = 0 ; cur_pos < data_size-4 ; ) {
			cur_byte = *(data++);
			cur_pos++;
			if (cur_byte==0xe8 || cur_byte==cmp_byte2) {
				offset = cur_pos+file_offset;
				addr = GET_VALUE(FALSE, data);
				if (addr < 0) {
					if (addr+offset >=0 ) {
						SET_VALUE(FALSE, data, addr+file_size);
					}
				} else {
					if (addr<file_size) {
						SET_VALUE(FALSE, data, addr-offset);
					}
				}
				data += 4;
				cur_pos += 4;
			}
		}
		break;
	case VMSF_ITANIUM:
		data=rarvm_data->mem;
		data_size = rarvm_data->R[4];
		file_offset = rarvm_data->R[6];
		
		if ((data_size >= VM_GLOBALMEMADDR) || (data_size < 21)) {
			break;
		}
		
		cur_pos = 0;
		
		file_offset>>=4;
		
		while (cur_pos < data_size-21) {
			int Byte = (data[0] & 0x1f) - 0x10;
			if (Byte >= 0) {
				static unsigned char masks[16]={4,4,6,6,0,0,7,7,4,4,0,0,4,4,0,0};
				unsigned char cmd_mask = masks[Byte];
				
				if (cmd_mask != 0) {
					for (i=0 ; i <= 2 ; i++) {
						if (cmd_mask & (1<<i)) {
							start_pos = i*41+5;
							op_type = filter_itanium_getbits(data,
									start_pos+37, 4);
							if (op_type == 5) {
								offset = filter_itanium_getbits(data,
										start_pos+13, 20);
								filter_itanium_setbits(data,
									(offset-file_offset)
									&0xfffff,start_pos+13,20);
							}
						}
					}
				}
			}
			data += 16;
			cur_pos += 16;
			file_offset++;
		}
		break;
	case VMSF_DELTA:
		data_size = rarvm_data->R[4];
		channels = rarvm_data->R[0];
		src_pos = 0;
		border = data_size*2;
		
		SET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x20], data_size);
		if (data_size >= VM_GLOBALMEMADDR/2) {
			break;
		}
		for (cur_channel=0 ; cur_channel < channels ; cur_channel++) {
			unsigned char prev_byte = 0;
			for (dest_pos=data_size+cur_channel ; dest_pos<border ; dest_pos+=channels) {
				rarvm_data->mem[dest_pos] = (prev_byte -= rarvm_data->mem[src_pos++]);
			}
		}
		break;
	case VMSF_RGB: {
		const int channels=3;
		data_size = rarvm_data->R[4];
		width = rarvm_data->R[0] - 3;
		PosR = rarvm_data->R[1];
		src_data = rarvm_data->mem;
		dest_data = src_data + data_size;
		
		SET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x20], data_size);
		if (data_size >= VM_GLOBALMEMADDR/2) {
			break;
		}
		for (cur_channel=0 ; cur_channel < channels; cur_channel++) {
			unsigned int prev_byte = 0;
			for (i=cur_channel ; i<data_size ; i+=channels) {
				int upper_pos=i-width;
				if (upper_pos >= 3) {
					unsigned char *upper_data = dest_data+upper_pos;
					unsigned int upper_byte = *upper_data;
					unsigned int upper_left_byte = *(upper_data-3);
					predicted = prev_byte+upper_byte-upper_left_byte;
					pa = abs((int)(predicted-prev_byte));
					pb = abs((int)(predicted-upper_byte));
					pc = abs((int)(predicted-upper_left_byte));
					if (pa <= pb && pa <= pc) {
						predicted = prev_byte;
					} else {
						if (pb <= pc) {
							predicted = upper_byte;
						} else {
							predicted = upper_left_byte;
						}
					}
				} else {
					predicted = prev_byte;
				}
				dest_data[i] = prev_byte = (unsigned char)(predicted-*(src_data++));
			}
		}
		for (i=PosR,border=data_size-2 ; i < border ; i+=3) {
			unsigned char g=dest_data[i+1];
			dest_data[i] += g;
			dest_data[i+2] += g;
		}
		break;
	}
	case VMSF_AUDIO: {
		int channels=rarvm_data->R[0];
		data_size = rarvm_data->R[4];
		src_data = rarvm_data->mem;
		dest_data = src_data + data_size;
		
		SET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x20], data_size);
		if (data_size >= VM_GLOBALMEMADDR/2) {
			break;
		}
		for (cur_channel=0 ; cur_channel < channels ; cur_channel++) {
			unsigned int prev_byte = 0, prev_delta=0, Dif[7];
			int D, D1=0, D2=0, D3=0, K1=0, K2=0, K3=0;
			
			memset(Dif, 0, sizeof(Dif));
			
			for (i=cur_channel, byte_count=0 ; i<data_size ; i+=channels, byte_count++) {
				D3=D2;
				D2 = prev_delta-D1;
				D1 = prev_delta;
				
				predicted = 8*prev_byte+K1*D1+K2*D2+K3*D3;
				predicted = (predicted>>3) & 0xff;
				
				cur_byte = *(src_data++);
				
				predicted -= cur_byte;
				dest_data[i] = predicted;
				prev_delta = (signed char)(predicted-prev_byte);
				prev_byte = predicted;
				
				D=((signed char)cur_byte) << 3;
				
				Dif[0] += abs(D);
				Dif[1] += abs(D-D1);
				Dif[2] += abs(D+D1);
				Dif[3] += abs(D-D2);
				Dif[4] += abs(D+D2);
				Dif[5] += abs(D-D3);
				Dif[6] += abs(D+D3);
				
				if ((byte_count & 0x1f) == 0) {
					unsigned int min_dif=Dif[0], num_min_dif=0;
					Dif[0]=0;
					for (j=1 ; j<sizeof(Dif)/sizeof(Dif[0]) ; j++) {
						if (Dif[j] < min_dif) {
							min_dif = Dif[j];
							num_min_dif = j;
						}
						Dif[j]=0;
					}
					switch(num_min_dif) {
					case 1: if (K1>=-16) K1--; break;
					case 2: if (K1 < 16) K1++; break;
					case 3: if (K2>=-16) K2--; break;
					case 4: if (K2 < 16) K2++; break;
					case 5: if (K3>=-16) K3--; break;
					case 6: if (K3 < 16) K3++; break;
					}
				}
			}
		}
		break;
	}
	case VMSF_UPCASE:
		data_size = rarvm_data->R[4];
		src_pos = 0;
		dest_pos = data_size;
		if (data_size >= VM_GLOBALMEMADDR/2) {
			break;
		}
		while (src_pos < data_size) {
			cur_byte = rarvm_data->mem[src_pos++];
			if (cur_byte==2 && (cur_byte=rarvm_data->mem[src_pos++]) != 2) {
				cur_byte -= 32;
			}
			rarvm_data->mem[dest_pos++]=cur_byte;
		}
		SET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x1c], dest_pos-data_size);
		SET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x20], data_size);
		break;
	}
}
				
#define SET_IP(IP)                      \
  if ((IP)>=code_size)                   \
    return TRUE;                       \
  if (--max_ops<=0)                  \
    return FALSE;                      \
  cmd=prepared_code+(IP);

static int rarvm_execute_code(rarvm_data_t *rarvm_data,
		struct rarvm_prepared_command *prepared_code, int code_size)
{
	int max_ops=25000000, i, SP;
	struct rarvm_prepared_command *cmd;
	unsigned int value1, value2, result, divider, FC, *op1, *op2;
	const int reg_count=sizeof(rarvm_data->R)/sizeof(rarvm_data->R[0]);
	
	rar_dbgmsg("in rarvm_execute_code\n");
	cmd = prepared_code;
	while (1) {
		if (cmd > (prepared_code + code_size)) {
			rar_dbgmsg("RAR: code overrun detected\n");
			return FALSE;
		}
		if (cmd < prepared_code) {
			rar_dbgmsg("RAR: code underrun detected\n");
                        return FALSE;
                }
		op1 = rarvm_get_operand(rarvm_data, &cmd->op1);
		op2 = rarvm_get_operand(rarvm_data, &cmd->op2);
		rar_dbgmsg("op(%d) op_code: %d, op1=%u, op2=%u\n", 25000000-max_ops,
					cmd->op_code, op1, op2);
		switch(cmd->op_code) {
		case VM_MOV:
			SET_VALUE(cmd->byte_mode, op1, GET_VALUE(cmd->byte_mode, op2));
			break;
		case VM_MOVB:
			SET_VALUE(TRUE, op1, GET_VALUE(TRUE, op2));
			break;
		case VM_MOVD:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE, op2));
			break;
		case VM_CMP:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(value1 - GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : (result>value1)|(result&VM_FS);
			break;
		case VM_CMPB:
			value1 = GET_VALUE(TRUE, op1);
			result = UINT32(value1 - GET_VALUE(TRUE, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : (result>value1)|(result&VM_FS);
			break;
		case VM_CMPD:
			value1 = GET_VALUE(FALSE, op1);
			result = UINT32(value1 - GET_VALUE(FALSE, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : (result>value1)|(result&VM_FS);
			break;
		case VM_ADD:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(value1 + GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : (result<value1)|(result&VM_FS);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_ADDB:
			SET_VALUE(TRUE, op1, GET_VALUE(TRUE, op1)+GET_VALUE(TRUE, op2));
			break;
		case VM_ADDD:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE, op1)+GET_VALUE(FALSE, op2));
			break;
		case VM_SUB:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(value1 - GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : (result>value1)|(result&VM_FS);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_SUBB:
			SET_VALUE(TRUE, op1, GET_VALUE(TRUE, op1)-GET_VALUE(TRUE, op2));
			break;
		case VM_SUBD:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE, op1)-GET_VALUE(FALSE, op2));
			break;
		case VM_JZ:
			if ((rarvm_data->Flags & VM_FZ) != 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JNZ:
			if ((rarvm_data->Flags & VM_FZ) == 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_INC:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)+1);
			SET_VALUE(cmd->byte_mode, op1, result);
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			break;
		case VM_INCB:
			SET_VALUE(TRUE, op1, GET_VALUE(TRUE, op1)+1);
			break;
		case VM_INCD:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE, op1)+1);
			break;
		case VM_DEC:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)-1);
			SET_VALUE(cmd->byte_mode, op1, result);
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			break;
		case VM_DECB:
			SET_VALUE(TRUE, op1, GET_VALUE(TRUE, op1)-1);
			break;
		case VM_DECD:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE, op1)-1);
			break;
		case VM_JMP:
			SET_IP(GET_VALUE(FALSE, op1));
			continue;
		case VM_XOR:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)^GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_AND:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)&GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_OR:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)|GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_TEST:
			result = UINT32(GET_VALUE(cmd->byte_mode, op1)&GET_VALUE(cmd->byte_mode, op2));
			rarvm_data->Flags = result==0 ? VM_FZ : result&VM_FS;
			break;
		case VM_JS:
			if ((rarvm_data->Flags & VM_FS) != 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JNS:
			if ((rarvm_data->Flags & VM_FS) == 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JB:
			if ((rarvm_data->Flags & VM_FC) != 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JBE:
			if ((rarvm_data->Flags & (VM_FC|VM_FZ)) != 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JA:
			if ((rarvm_data->Flags & (VM_FC|VM_FZ)) == 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_JAE:
			if ((rarvm_data->Flags & VM_FC) == 0) {
				SET_IP(GET_VALUE(FALSE, op1));
				continue;
			}
			break;
		case VM_PUSH:
			rarvm_data->R[7] -= 4;
			SET_VALUE(FALSE, (unsigned int *)&rarvm_data->mem[rarvm_data->R[7] &
				RARVM_MEMMASK],	GET_VALUE(FALSE, op1));
			break;
		case VM_POP:
			SET_VALUE(FALSE, op1, GET_VALUE(FALSE,
				(unsigned int *)&rarvm_data->mem[rarvm_data->R[7] & RARVM_MEMMASK]));
			rarvm_data->R[7] += 4;
			break;
		case VM_CALL:
			rarvm_data->R[7] -= 4;
			SET_VALUE(FALSE, (unsigned int *)&rarvm_data->mem[rarvm_data->R[7] &
					RARVM_MEMMASK], cmd-prepared_code+1);
			SET_IP(GET_VALUE(FALSE, op1));
			continue;
		case VM_NOT:
			SET_VALUE(cmd->byte_mode, op1, ~GET_VALUE(cmd->byte_mode, op1));
			break;
		case VM_SHL:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			value2 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(value1 << value2);
			rarvm_data->Flags = (result==0 ? VM_FZ : (result&VM_FS))|
				((value1 << (value2-1))&0x80000000 ? VM_FC:0);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_SHR:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			value2 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(value1 >> value2);
			rarvm_data->Flags = (result==0 ? VM_FZ : (result&VM_FS))|
				((value1 >> (value2-1)) & VM_FC);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_SAR:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			value2 = GET_VALUE(cmd->byte_mode, op1);
			result = UINT32(((int)value1) >> value2);
			rarvm_data->Flags = (result==0 ? VM_FZ : (result&VM_FS))|
				((value1 >> (value2-1)) & VM_FC);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_NEG:
			result = UINT32(-GET_VALUE(cmd->byte_mode, op1));
			rarvm_data->Flags = result==0 ? VM_FZ:VM_FC|(result&VM_FS);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_NEGB:
			SET_VALUE(TRUE, op1, -GET_VALUE(TRUE, op1));
			break;
		case VM_NEGD:
			SET_VALUE(FALSE, op1, -GET_VALUE(FALSE, op1));
			break;
		case VM_PUSHA:
			for (i=0, SP=rarvm_data->R[7]-4 ; i<reg_count ; i++, SP-=4) {
				SET_VALUE(FALSE,
					(unsigned int *)&rarvm_data->mem[SP & RARVM_MEMMASK],
					rarvm_data->R[i]);
			}
			rarvm_data->R[7] -= reg_count*4;
			break;
		case VM_POPA:
			for (i=0,SP=rarvm_data->R[7] ; i<reg_count ; i++, SP+=4) {
				rarvm_data->R[7-i] = GET_VALUE(FALSE,
					(unsigned int *)&rarvm_data->mem[SP & RARVM_MEMMASK]);
			}
			break;
		case VM_PUSHF:
			rarvm_data->R[7] -= 4;
			SET_VALUE(FALSE,
				(unsigned int *)&rarvm_data->mem[rarvm_data->R[7] & RARVM_MEMMASK],
				rarvm_data->Flags);
			break;
		case VM_POPF:
			rarvm_data->Flags = GET_VALUE(FALSE,
				(unsigned int *)&rarvm_data->mem[rarvm_data->R[7] & RARVM_MEMMASK]);
			rarvm_data->R[7] += 4;
			break;
		case VM_MOVZX:
			SET_VALUE(FALSE, op1, GET_VALUE(TRUE, op2));
			break;
		case VM_MOVSX:
			SET_VALUE(FALSE, op1, (signed char)GET_VALUE(TRUE, op2));
			break;
		case VM_XCHG:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			SET_VALUE(cmd->byte_mode, op1, GET_VALUE(cmd->byte_mode, op2));
			SET_VALUE(cmd->byte_mode, op2, value1);
			break;
		case VM_MUL:
			result = GET_VALUE(cmd->byte_mode, op1) * GET_VALUE(cmd->byte_mode, op2);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_DIV:
			divider = GET_VALUE(cmd->byte_mode, op2);
			if (divider != 0) {
				result = GET_VALUE(cmd->byte_mode, op1) / divider;
				SET_VALUE(cmd->byte_mode, op1, result);
			}
			break;
		case VM_ADC:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			FC = (rarvm_data->Flags & VM_FC);
			result = UINT32(value1+GET_VALUE(cmd->byte_mode, op2)+FC);
			rarvm_data->Flags = result==0 ? VM_FZ:(result<value1 ||
				(result==value1 && FC))|(result&VM_FS);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_SBB:
			value1 = GET_VALUE(cmd->byte_mode, op1);
			FC = (rarvm_data->Flags & VM_FC);
			result = UINT32(value1-GET_VALUE(cmd->byte_mode, op2)-FC);
			rarvm_data->Flags = result==0 ? VM_FZ:(result>value1 ||
				(result==value1 && FC))|(result&VM_FS);
			SET_VALUE(cmd->byte_mode, op1, result);
			break;
		case VM_RET:
			if (rarvm_data->R[7] >= RARVM_MEMSIZE) {
				return TRUE;
			}
			SET_IP(GET_VALUE(FALSE, (unsigned int *)&rarvm_data->mem[rarvm_data->R[7] &
				RARVM_MEMMASK]));
			rarvm_data->R[7] += 4;
			continue;
		case VM_STANDARD:
			execute_standard_filter(rarvm_data,
					(rarvm_standard_filters_t)cmd->op1.data);
			break;
		case VM_PRINT:
			/* DEBUG */
			break;
		}
		cmd++;
		--max_ops;
	}
}

int rarvm_execute(rarvm_data_t *rarvm_data, struct rarvm_prepared_program *prg)
{
	unsigned int global_size, static_size, new_pos, new_size, data_size;
	struct rarvm_prepared_command *prepared_code;
	
	rar_dbgmsg("in rarvm_execute\n");
	memcpy(rarvm_data->R, prg->init_r, sizeof(prg->init_r));
	global_size = MIN(prg->global_size, VM_GLOBALMEMSIZE);
	if (global_size) {
		memcpy(rarvm_data->mem+VM_GLOBALMEMADDR, &prg->global_data[0], global_size);
	}
	static_size = MIN(prg->static_size, VM_GLOBALMEMSIZE-global_size);
	if (static_size) {
		memcpy(rarvm_data->mem+VM_GLOBALMEMADDR+global_size,
				&prg->static_data[0], static_size);
	}
	
	rarvm_data->R[7] = RARVM_MEMSIZE;
	rarvm_data->Flags = 0;
	
	prepared_code=prg->alt_cmd ? prg->alt_cmd : &prg->cmd.array[0];
	if(!prepared_code) {
	    rar_dbgmsg("unrar: rarvm_execute: prepared_code == NULL\n");
	    return FALSE;
	}
	if (!rarvm_execute_code(rarvm_data, prepared_code, prg->cmd_count)) {
		prepared_code[0].op_code = VM_RET;
	}
	new_pos = GET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x20])&RARVM_MEMMASK;
	new_size = GET_VALUE(FALSE, &rarvm_data->mem[VM_GLOBALMEMADDR+0x1c])&RARVM_MEMMASK;
	if (new_pos+new_size >= RARVM_MEMSIZE) {
		new_pos = new_size = 0;
	}
	prg->filtered_data = rarvm_data->mem + new_pos;
	prg->filtered_data_size = new_size;
	
	if (prg->global_data) {
		free(prg->global_data);
		//printf("free globaldatavm\n");
		prg->global_data = NULL;
		prg->global_size = 0;
	}
	data_size = MIN(GET_VALUE(FALSE,
		(unsigned int *)&rarvm_data->mem[VM_GLOBALMEMADDR+0x30]),VM_GLOBALMEMSIZE);
	if (data_size != 0) {
		prg->global_size += data_size+VM_FIXEDGLOBALSIZE;
		prg->global_data = rar_realloc2(prg->global_data, prg->global_size);
		if(!prg->global_data) {
		    rar_dbgmsg("unrar: rarvm_execute: rar_realloc2 failed for prg->global_data\n");
		    return FALSE;
		}
		memcpy(prg->global_data, &rarvm_data->mem[VM_GLOBALMEMADDR],
				data_size+VM_FIXEDGLOBALSIZE);
	}

	return TRUE;
}

void rarvm_decode_arg(rarvm_data_t *rarvm_data, rarvm_input_t *rarvm_input,
		struct rarvm_prepared_operand *op, int byte_mode)
{
	uint16_t data;
	
	data = rarvm_getbits(rarvm_input);
	if (data & 0x8000) {
		op->type = VM_OPREG;
		op->data = (data >> 12) & 7;
		op->addr = &rarvm_data->R[op->data];
		rarvm_addbits(rarvm_input,4);
	} else if ((data & 0xc000) == 0) {
		op->type = VM_OPINT;
		if (byte_mode) {
			op->data = (data>>6) & 0xff;
			rarvm_addbits(rarvm_input,10);
		} else {
			rarvm_addbits(rarvm_input,2);
			op->data = rarvm_read_data(rarvm_input);
		}
	} else {
		op->type = VM_OPREGMEM;
		if ((data & 0x2000) == 0) {
			op->data = (data >> 10) & 7;
			op->addr = &rarvm_data->R[op->data];
			op->base = 0;
			rarvm_addbits(rarvm_input,6);
		} else {
			if ((data & 0x1000) == 0) {
				op->data = (data >> 9) & 7;
				op->addr = &rarvm_data->R[op->data];
				rarvm_addbits(rarvm_input,7);
			} else {
				op->data = 0;
				rarvm_addbits(rarvm_input,4);
			}
			op->base = rarvm_read_data(rarvm_input);
		}
	}
}

void rarvm_optimize(struct rarvm_prepared_program *prg)
{
	struct rarvm_prepared_command *code, *cmd;
	int code_size, i, flags_required, j, flags;
	
	code = prg->cmd.array;
	code_size = prg->cmd_count;
	
	for (i=0 ; i < code_size ; i++) {
		cmd = &code[i];
		switch(cmd->op_code) {
			case VM_MOV:
				cmd->op_code = cmd->byte_mode ? VM_MOVB:VM_MOVD;
				continue;
			case VM_CMP:
				cmd->op_code = cmd->byte_mode ? VM_CMPB:VM_CMPD;
				continue;
		}
		if ((vm_cmdflags[cmd->op_code] & VMCF_CHFLAGS) == 0) {
			continue;
		}
		flags_required = FALSE;
		for (j=i+1 ; j < code_size ; j++) {
			flags = vm_cmdflags[code[j].op_code];
			if (flags & (VMCF_JUMP|VMCF_PROC|VMCF_USEFLAGS)) {
				flags_required=TRUE;
				break;
			}
			if (flags & VMCF_CHFLAGS) {
				break;
			}
		}
		if (flags_required) {
			continue;
		}
		switch(cmd->op_code) {
			case VM_ADD:
				cmd->op_code = cmd->byte_mode ? VM_ADDB:VM_ADDD;
				continue;
			case VM_SUB:
				cmd->op_code = cmd->byte_mode ? VM_SUBB:VM_SUBD;
				continue;
			case VM_INC:
				cmd->op_code = cmd->byte_mode ? VM_INCB:VM_INCD;
				continue;
			case VM_DEC:
				cmd->op_code = cmd->byte_mode ? VM_DECB:VM_DECD;
				continue;
			case VM_NEG:
				cmd->op_code = cmd->byte_mode ? VM_NEGB:VM_NEGD;
				continue;
		}
	}
}

int rarvm_prepare(rarvm_data_t *rarvm_data, rarvm_input_t *rarvm_input, unsigned char *code,
		int code_size, struct rarvm_prepared_program *prg)
{
	unsigned char xor_sum;
	int i, op_num, distance;
	rarvm_standard_filters_t filter_type;
	struct rarvm_prepared_command *cur_cmd;
	uint32_t data_flag, data;
 	struct rarvm_prepared_command *cmd;
 	
 	rar_dbgmsg("in rarvm_prepare code_size=%d\n", code_size);
	rarvm_input->in_addr = rarvm_input->in_bit = 0;
	memcpy(rarvm_input->in_buf, code, MIN(code_size, 0x8000));
	xor_sum = 0;
	for (i=1 ; i<code_size; i++) {
		rar_dbgmsg("code[%d]=%d\n", i, code[i]);
		xor_sum ^= code[i];
	}
	rar_dbgmsg("xor_sum=%d\n", xor_sum);
	rarvm_addbits(rarvm_input,8);
	
	prg->cmd_count = 0;
	if (xor_sum == code[0]) {
		filter_type = is_standard_filter(code, code_size);
		rar_dbgmsg("filter_type=%d\n", filter_type);
		if (filter_type != VMSF_NONE) {
			rar_cmd_array_add(&prg->cmd, 1);
			cur_cmd = &prg->cmd.array[prg->cmd_count++];
			cur_cmd->op_code = VM_STANDARD;
			cur_cmd->op1.data = filter_type;
			cur_cmd->op1.addr = &cur_cmd->op1.data;
			cur_cmd->op2.addr = &cur_cmd->op2.data;
			cur_cmd->op1.type = cur_cmd->op2.type = VM_OPNONE;
			code_size = 0;
		}

		data_flag = rarvm_getbits(rarvm_input);
		rar_dbgmsg("data_flag=%u\n", data_flag);
		rarvm_addbits(rarvm_input, 1);
		if (data_flag & 0x8000) {
			int data_size = rarvm_read_data(rarvm_input)+1;
			rar_dbgmsg("data_size=%d\n", data_size);
			prg->static_data = rar_malloc(data_size);
			if(!prg->static_data) {
			    rar_dbgmsg("unrar: rarvm_prepare: rar_malloc failed for prg->static_data\n");
			    return FALSE;
			}
			//printf("malloc staticdatavm\n");
			for (i=0 ; rarvm_input->in_addr < code_size && i < data_size ; i++) {
				prg->static_size++;
				prg->static_data = rar_realloc2(prg->static_data, prg->static_size);
				if(!prg->static_data) {
				    rar_dbgmsg("unrar: rarvm_prepare: rar_realloc2 failed for prg->static_data\n");
				    return FALSE;
				}
				prg->static_data[i] = rarvm_getbits(rarvm_input) >> 8;
				rarvm_addbits(rarvm_input, 8);
			}
		}
		while (rarvm_input->in_addr < code_size) {
			rar_cmd_array_add(&prg->cmd, 1);
			cur_cmd = &prg->cmd.array[prg->cmd_count];
			data = rarvm_getbits(rarvm_input);
			rar_dbgmsg("data: %u\n", data);
			if ((data & 0x8000) == 0) {
				cur_cmd->op_code = (rarvm_commands_t) (data>>12);
				rarvm_addbits(rarvm_input, 4);
			} else {
				cur_cmd->op_code = (rarvm_commands_t) ((data>>10)-24);
				rarvm_addbits(rarvm_input, 6);
			}
			if (vm_cmdflags[cur_cmd->op_code] & VMCF_BYTEMODE) {
				cur_cmd->byte_mode = rarvm_getbits(rarvm_input) >> 15;
				rarvm_addbits(rarvm_input, 1);
			} else {
				cur_cmd->byte_mode = 0;
			}
			cur_cmd->op1.type = cur_cmd->op2.type = VM_OPNONE;
			op_num = (vm_cmdflags[cur_cmd->op_code] & VMCF_OPMASK);
			rar_dbgmsg("op_num: %d\n", op_num);
			cur_cmd->op1.addr = cur_cmd->op2.addr = NULL;
			if (op_num > 0) {
				rarvm_decode_arg(rarvm_data, rarvm_input,
					&cur_cmd->op1, cur_cmd->byte_mode);
				if (op_num == 2) {
					rarvm_decode_arg(rarvm_data, rarvm_input,
							&cur_cmd->op2, cur_cmd->byte_mode);
				} else {
					if (cur_cmd->op1.type == VM_OPINT &&
							(vm_cmdflags[cur_cmd->op_code] &
							(VMCF_JUMP|VMCF_PROC))) {
						distance = cur_cmd->op1.data;
						rar_dbgmsg("distance = %d\n", distance);
						if (distance >= 256) {
							distance -= 256;
						} else {
							if (distance >=136) {
								distance -= 264;
							} else {
								if (distance >= 16) {
									distance -= 8;
								} else if (distance >= 8) {
									distance -= 16;
								}
							}
							distance += prg->cmd_count;
						}
						rar_dbgmsg("distance = %d\n", distance);
						cur_cmd->op1.data = distance;
					}
				}
			}
			prg->cmd_count++;
		}
	}
	rar_cmd_array_add(&prg->cmd,1);
	cur_cmd = &prg->cmd.array[prg->cmd_count++];
	cur_cmd->op_code = VM_RET;
	cur_cmd->op1.addr = &cur_cmd->op1.data;
	cur_cmd->op2.addr = &cur_cmd->op2.data;
	cur_cmd->op1.type = cur_cmd->op2.type = VM_OPNONE;
	
	for (i=0 ; i < prg->cmd_count ; i++) {
		cmd = &prg->cmd.array[i];
		rar_dbgmsg("op_code[%d]=%d\n", i, cmd->op_code);
		if (cmd->op1.addr == NULL) {
			cmd->op1.addr = &cmd->op1.data;
		}
		if (cmd->op2.addr == NULL) {
			cmd->op2.addr = &cmd->op2.data;
		}
	}

	if (code_size!=0) {
		rarvm_optimize(prg);
	}

	return TRUE;
}





