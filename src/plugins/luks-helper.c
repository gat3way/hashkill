#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/types.h>
#include <errno.h>


void XORblock(char *src1, char *src2, char *dst, int n)
{
    int j;
    
    for(j=0; j<n; j++)
    dst[j] = src1[j] ^ src2[j];
}



static void diffuse(unsigned char *src, unsigned char *dst, int size)
{
	uint32_t i;
	uint32_t IV;	/* host byte order independend hash IV */
	
	int fullblocks = size/20;
	int padding = size%20;
	unsigned char final[20];

	for (i=0; i < fullblocks; i++) {
		IV = htonl(i);
		/*sha1_hash((const char *)&IV,sizeof(IV),&ctx);
		sha1_hash(src+SHA1_DIGEST_SIZE*i,SHA1_DIGEST_SIZE,&ctx);
		sha1_end(dst+SHA1_DIGEST_SIZE*i,&ctx);*/
	}
	
	if(padding) {
		IV = htonl(i);
		/*sha1_hash((const char *)&IV,sizeof(IV),&ctx);
		sha1_hash(src+SHA1_DIGEST_SIZE*i,padding,&ctx);
		sha1_end(final,&ctx);*/
		memcpy(dst+20*i,final,padding);
	}
}



extern int AF_merge(char *src, char *dst, int blocksize, int blocknumbers)
{
	int i;
	char *bufblock;

	if((bufblock = malloc(blocksize)) == NULL) return -1;

	memset(bufblock,0,blocksize);
	for(i=0; i<blocknumbers-1; i++) {
		XORblock(src+(blocksize*i),bufblock,bufblock,blocksize);
		diffuse(bufblock,bufblock,blocksize);
	}
	XORblock(src+(i*blocksize),bufblock,dst,blocksize);

	free(bufblock);	
	return 0;
}

