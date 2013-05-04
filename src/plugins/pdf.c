/* pdf.c
 *
 * Add support for cracking PDF files
 * Copyright (C) 2013 Dhiru Kholia <dhiru at openwall.com>
 *
 * pdf.c uses code from Sumatra PDF and MuPDF which are under GPL
 *
 * hashkill - a hash cracking tool
 * Copyright (C) 2010 Milen Rangelov <gat3way@gat3way.eu>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <alloca.h>
#include <sys/types.h>
#include <openssl/sha.h>
#include <openssl/md5.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include "plugin.h"
#include "rc4.c"
#include "err.h"
#include "hashinterface.h"


char myfilename[255];
int vectorsize;

static struct custom_salt {
	int V;
	int R;
	int P;
	char encrypt_metadata;
	unsigned char u[127];
	unsigned char o[127];
	unsigned char ue[32];
	unsigned char oe[32];
	unsigned char id[32];
	int length;
	int length_id;
	int length_u;
	int length_o;
	int length_ue;
	int length_oe;
} cs;


char *hash_plugin_summary(void)
{
	return ("pdf \t\tPDF documents password plugin");
}


char *hash_plugin_detailed(void)
{
	return ("pdf - PDF documents password plugin\n"
	    "------------------------------------------------\n"
	    "Use this module to crack pdf files\n"
	    "Input should be a pdf document file (specified with -f)\n"
	    "\nAuthor: Dhiru Kholia <dhiru at openwall.com>\n");
}



/*
hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
	if (!hashline) return hash_err;
	if (strlen(hashline)<3) return hash_err;
	char *ctcopy = strdup(hashline);
	char *keeptr = ctcopy;
	char *p;

	if ((p = strtok(ctcopy, ":")) == NULL)
		goto err;
	strcpy(myfilename, p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	if (strncmp(p, "$pdf$", 5) != 0)
		goto err;
	p += 5;
	cs.V = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.R = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.length = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.P = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.encrypt_metadata = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.length_id = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	hex2str((char *) cs.id, p, cs.length_id * 2);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.length_u = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	hex2str((char *) cs.u, p, cs.length_u * 2);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	cs.length_o = atoi(p);
	if ((p = strtok(NULL, "*")) == NULL)
		goto err;
	hex2str((char *) cs.o, p, cs.length_o * 2);
	free(keeptr);

	(void) hash_add_username(myfilename);
	(void) hash_add_hash("pdf file    \0", 0);
	(void) hash_add_salt("123");
	(void) hash_add_salt2("                              ");
	return hash_ok;
err:
	free(keeptr);
	return hash_err;
}
*/


/* Milen: Do the parsing inside the plugin instead */
hash_stat hash_plugin_parse_hash(char *hashline, char *filename)
{
    int fd;
    int a,flag;
    char *buf;
    char *match=NULL;
    size_t size;
    int ver,rel;
    char *trailer;
    char *encdict;
    char *end;
    int trailersize;
    int encdictsize;
    char *tok;
    char *tok1;
    char *object1;
    char *object;
    char finalobject[1024];
    char id[255];
    char ostr[255],ustr[255];
    int v,r,length,p,meta;
    size_t hashsize,usize,osize;
    //size_t uesize,oesize;

    //oesize=uesize=0;
    osize=usize=0;
    fd = open(filename,O_RDONLY);
    size = lseek(fd,0,SEEK_END);
    lseek(fd,0,SEEK_SET);
    buf = malloc(size);
    read(fd,buf,size);
    close(fd);
    match = memmem(buf,size,"PDF-",4);
    if (!match) goto out;
    ver=atoi(match+4);
    rel=atoi(match+6);
    trailer = memmem(buf,size,"trailer",strlen("trailer"));
    if (!trailer) 
    {
        trailer = memmem(buf,size,"DecodeParms",strlen("DecodeParms"));
        if (!trailer) goto out;
        trailer+=strlen("DecodeParms");
        end = memmem(trailer,size-(trailer-buf),"stream",strlen("stream"));
        if (!end) goto out;
        trailersize = end-trailer;
    }
    else
    {
        trailer+=strlen("trailer");
        end = memmem(trailer,size-(trailer-buf),">>",strlen(">>"));
        if (!end) goto out;
        trailersize = end-trailer;
    }

    object = memmem(trailer,trailersize,"Encrypt ",strlen("Encrypt "));
    if (!object) goto out;
    object+=strlen("Encrypt ");
    object1 = malloc(trailersize);
    memcpy(object1,object,16);
    tok = strtok(object1," ");
    tok1 = strtok(NULL," ");
    sprintf(finalobject,"%s %s obj",tok,tok1);
    free(object1);

    encdict = memmem(buf,size,finalobject,strlen(finalobject));
    if (!encdict) goto out;
    encdict+=strlen(finalobject);
    end = memmem(encdict,size-(encdict-buf),"endobj",strlen("endobj"));
    if (!end) goto out;
    encdictsize = end-encdict;


    tok = memmem(encdict,encdictsize,"/V ",strlen("/V "));
    if (!tok) goto out;
    tok+=strlen("/V ");
    v=atoi(tok);
    tok = memmem(encdict,encdictsize,"/R ",strlen("/R "));
    if (!tok) goto out;
    tok+=strlen("/R ");
    r=atoi(tok);
    length=0;
    tok = memmem(encdict,encdictsize,"/Length ",strlen("/Length "));
    if (!tok) goto out;
    tok+=strlen("/Length ");
    length=atoi(tok);
    while (tok)
    {
	tok = memmem(tok,encdictsize-(tok-encdict),"/Length ",strlen("/Length "));
	if (tok)
	{
	    tok+=strlen("/Length ");
	    a=atoi(tok);
	    if (a>length) length = a;
	}
    }
    
    tok = memmem(encdict,encdictsize,"/P ",strlen("/P "));
    if (!tok) goto out;
    tok+=strlen("/P ");
    p=atoi(tok);

    tok = memmem(encdict,encdictsize,"/EncryptMetadata",strlen("/EncryptMetadata"));
    meta=1;
    if (!tok) meta=1;
    else
    {
        tok+=strlen("/EncryptMetadata");
        if ((tok[0]==' ')||(tok[0]=='\r')||(tok[0]=='\n')||(tok[0]=='\t'))
        {
            if (memcmp(tok+1,"false",strlen("false"))==0) meta=0;
            else meta=1;
        }
    }

    tok = memmem(trailer,trailersize,"/ID",strlen("/ID"));
    if (!tok) goto out;
    tok = memmem(tok,trailersize,"<",strlen("<"));
    if (!tok) goto out;
    tok+=strlen("<");
    tok1 = memmem(tok,trailersize - (tok-trailer),">",1);
    if (!tok1) goto out;
    hashsize=tok1-tok;
    bzero(id,255);
    if (hashsize>255) hashsize=255;
    memcpy(id,tok,hashsize);

    if ((ver==1)&&(rel==7))
    {
        // Search for 'U' in letters
        tok = memmem(encdict,encdictsize,"/U(",strlen("/U("));
        if (!tok) goto out;
        tok+=strlen("/U(");
        a=0;flag=0;usize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : ustr[usize]='\n';break;
            	    case 'r' : ustr[usize]='\r';break;
            	    case 't' : ustr[usize]='\t';break;
            	    case 'v' : ustr[usize]='\v';break;
            	    case 'f' : ustr[usize]='\f';break;
            	    case 'b' : ustr[usize]='\b';break;
            	    case 'a' : ustr[usize]='\a';break;
            	    case ')' : ustr[usize]=')';break;
            	    case '(' : ustr[usize]='(';break;
            	    case '\\' : ustr[usize]='\\';break;
            	    case '0' : ustr[usize]=0;break;
            	}
                usize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                ustr[usize]=tok[a];
                a++;
                usize++;
            }
            if (usize==255) flag=1;
        }
        // Search for 'O' in letters
        tok = memmem(encdict,encdictsize,"/O(",strlen("/O("));
        if (!tok) goto out;
        tok+=strlen("/O(");
        a=0;flag=0;osize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : ostr[osize]='\n';break;
            	    case 'r' : ostr[osize]='\r';break;
            	    case 't' : ostr[osize]='\t';break;
            	    case 'v' : ostr[osize]='\v';break;
            	    case 'f' : ostr[osize]='\f';break;
            	    case 'b' : ostr[osize]='\b';break;
            	    case 'a' : ostr[osize]='\a';break;
            	    case ')' : ostr[osize]=')';break;
            	    case '(' : ostr[osize]='(';break;
            	    case '\\' : ostr[osize]='\\';break;
            	    case '0' : ostr[osize]=0;break;
            	}
                osize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                ostr[osize]=tok[a];
                a++;
                osize++;
            }
            if (osize==255) flag=1;
        }
	/*
        // Search for 'UE' in letters
        tok = memmem(encdict,encdictsize,"/UE(",strlen("/UE("));
        if (!tok) goto out;
        tok+=strlen("/UE(");
        a=0;flag=0;uesize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : uestr[uesize]='\n';break;
            	    case 'r' : uestr[uesize]='\r';break;
            	    case 't' : uestr[uesize]='\t';break;
            	    case 'v' : uestr[uesize]='\v';break;
            	    case 'f' : uestr[uesize]='\f';break;
            	    case 'b' : uestr[uesize]='\b';break;
            	    case 'a' : uestr[uesize]='\a';break;
            	    case ')' : uestr[uesize]=')';break;
            	    case '(' : uestr[uesize]='(';break;
            	    case '\\' : uestr[uesize]='\\';break;
            	    case '0' : uestr[uesize]=0;break;
            	}
                uesize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                uestr[uesize]=tok[a];
                a++;
                uesize++;
            }
            if (uesize==255) flag=1;
        }
        // Search for 'OE' in letters
        tok = memmem(encdict,encdictsize,"/OE(",strlen("/OE("));
        if (!tok) goto out;
        tok+=strlen("/OE(");
        a=0;flag=0;oesize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : oestr[oesize]='\n';break;
            	    case 'r' : oestr[oesize]='\r';break;
            	    case 't' : oestr[oesize]='\t';break;
            	    case 'v' : oestr[oesize]='\v';break;
            	    case 'f' : oestr[oesize]='\f';break;
            	    case 'b' : oestr[oesize]='\b';break;
            	    case 'a' : oestr[oesize]='\a';break;
            	    case ')' : oestr[oesize]=')';break;
            	    case '(' : oestr[oesize]='(';break;
            	    case '\\' : oestr[oesize]='\\';break;
            	    case '0' : oestr[oesize]=0;break;
            	}
                oesize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                oestr[oesize]=tok[a];
                a++;
                oesize++;
            }
            if (oesize==255) flag=1;
        }
        */
    }
    else
    {
        // Search for 'U' in letters
        tok = memmem(encdict,encdictsize,"/U(",strlen("/U("));
        if (!tok) goto out;
        tok+=strlen("/U(");
        a=0;flag=0;usize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : ustr[usize]='\n';break;
            	    case 'r' : ustr[usize]='\r';break;
            	    case 't' : ustr[usize]='\t';break;
            	    case 'v' : ustr[usize]='\v';break;
            	    case 'f' : ustr[usize]='\f';break;
            	    case 'b' : ustr[usize]='\b';break;
            	    case 'a' : ustr[usize]='\a';break;
            	    case ')' : ustr[usize]=')';break;
            	    case '(' : ustr[usize]='(';break;
            	    case '\\' : ustr[usize]='\\';break;
            	    case '0' : ustr[usize]=0;break;
            	}
                usize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                ustr[usize]=tok[a];
                a++;
                usize++;
            }
            if (usize==255) flag=1;
        }
        // Search for 'O' in letters
        tok = memmem(encdict,encdictsize,"/O(",strlen("/O("));
        if (!tok) goto out;
        tok+=strlen("/O(");
        a=0;flag=0;osize=0;
        while (flag==0)
        {
            if (tok[a]=='\\') 
            {
                a++;
                switch (tok[a])
                {
            	    case 'n' : ostr[osize]='\n';break;
            	    case 'r' : ostr[osize]='\r';break;
            	    case 't' : ostr[osize]='\t';break;
            	    case 'v' : ostr[osize]='\v';break;
            	    case 'f' : ostr[osize]='\f';break;
            	    case 'b' : ostr[osize]='\b';break;
            	    case 'a' : ostr[osize]='\a';break;
            	    case ')' : ostr[osize]=')';break;
            	    case '(' : ostr[osize]='(';break;
            	    case '\\' : ostr[osize]='\\';break;
            	    case '0' : ostr[osize]=0;break;
            	}
                osize++;
                a++;
            }
            else if ((tok[a]==')')&&(tok[a-1]!='\\')) flag=1;
            else 
            {
                ostr[osize]=tok[a];
                a++;
                osize++;
            }
            if (osize==255) flag=1;
        }
    }

    cs.V=v;
    cs.R=r;
    cs.length = length;
    cs.P = p;
    cs.encrypt_metadata = meta;
    cs.length_id = hashsize/2;
    hex2str((char *) cs.id, strlow(id), cs.length_id * 2);
    cs.length_u = usize;
    memcpy(cs.u,ustr,usize);
    cs.length_o = osize;
    memcpy(cs.o,ostr,osize);

    free(buf);
    (void) hash_add_username(filename);
    (void) hash_add_hash("PDF File          \0", 0);
    (void) hash_add_salt("123");
    (void) hash_add_salt2("                              ");
    return hash_ok;

    out:
    free(buf);
    return hash_err;
}




static const unsigned char padding[32] = {
	0x28, 0xbf, 0x4e, 0x5e, 0x4e, 0x75, 0x8a, 0x41,
	0x64, 0x00, 0x4e, 0x56, 0xff, 0xfa, 0x01, 0x08,
	0x2e, 0x2e, 0x00, 0xb6, 0xd0, 0x68, 0x3e, 0x80,
	0x2f, 0x0c, 0xa9, 0xfe, 0x64, 0x53, 0x69, 0x7a
};

/* Compute an encryption key (PDF 1.7 algorithm 3.2) */
static void pdf_compute_encryption_key(unsigned char **password, int *pwlen, unsigned char **key)
{
	unsigned char *buf[VECTORSIZE];
	unsigned int p;
	unsigned int lens[VECTORSIZE];
	int n,a,i;

	n = cs.length / 8;
	
	for (a=0;a<vectorsize;a++)
	{
	    buf[a]=alloca(128);
	    /* Step 1 - copy and pad password string */
	    /* Step 2 - init md5 and pass value of step 1 */
	    if (pwlen[a] > 32)
		pwlen[a] = 32;
	    memcpy(buf[a], password[a], pwlen[a]);
	    memcpy(buf[a] + pwlen[a], padding, 32 - pwlen[a]);

	    /* Step 3 - pass O value */
	    memcpy(buf[a] + 32, cs.o, 32);

	    /* Step 4 - pass P value as unsigned int, low-order byte first */
	    p = (unsigned int) cs.P;
	    buf[a][64] = (p) & 0xFF;
	    buf[a][65] = (p >> 8) & 0xFF;
	    buf[a][66] = (p >> 16) & 0xFF;
	    buf[a][67] = (p >> 24) & 0xFF;

	    /* Step 5 - pass first element of ID array */
	    memcpy(buf[a] + 68, cs.id, cs.length_id);
	    lens[a]=68+cs.length_id;

	    /* Step 6 (revision 4 or greater) - if metadata is not encrypted pass 0xFFFFFFFF */
	    if (cs.R >= 4) {
		if (!cs.encrypt_metadata) {
			buf[a][lens[a]] = 0xFF;
			buf[a][lens[a]+1] = 0xFF;
			buf[a][lens[a]+2] = 0xFF;
			buf[a][lens[a]+3] = 0xFF;
			lens[a]+=4;
		}
	    }
	}

	/* Step 7 - finish the hash */
	hash_md5_unicode_slow((const char **)buf,(char **)buf,(int*)lens);

	for (a=0;a<vectorsize;a++) 
	{
	    lens[a]=16;
	    memset(buf[a]+16,0,48);
	}

	/* Step 8 (revision 3 or greater) - do some voodoo 50 times */
	if (cs.R >= 3) {
		 for (i = 0; i < 50; i++)
		   {
			hash_md5_unicode((const char **)buf,(char**)buf,(int*)lens);
		   } 
	}
	/* Step 9 - the key is the first 'n' bytes of the result */
	for (a=0;a<vectorsize;a++)
	{
	    memcpy(key[a], buf[a], n);
	}
}


/* Compute an encryption key (PDF 1.7 ExtensionLevel 3 algorithm 3.2a) */
static void pdf_compute_encryption_key_r5 (unsigned char *password[VECTORSIZE], int pwlen[VECTORSIZE], int ownerkey, unsigned char *validationkey[VECTORSIZE])
{
	unsigned char *buffer[VECTORSIZE];
	int lens[VECTORSIZE];
	int a;

	for (a=0;a<vectorsize;a++)
	{
	    buffer[a]=alloca(128 + 8 + 48);
	    /* Step 2 - truncate UTF-8 password to 127 characters */
	    if (pwlen[a] > 127) pwlen[a] = 127;
	}


	for (a=0;a<vectorsize;a++)
	{
	    /* Step 3/4 - test password against owner/user key and compute encryption key */
	    memcpy(buffer[a], password[a], pwlen[a]);
	    memcpy(buffer[a] + pwlen[a], cs.u + 32, 8);
	    lens[a] = pwlen[a] + 8;
	}
	hash_sha256_unicode((const char **)buffer, (char **)validationkey, lens);
}

/* SumatraPDF: support crypt version 5 revision 6 */
/*
 * Compute an encryption key (PDF 1.7 ExtensionLevel 8 algorithm 3.2b)
 * http://esec-lab.sogeti.com/post/The-undocumented-password-validation-algorithm-of-Adobe-Reader-X
 */
static void pdf_compute_hardened_hash_r6(unsigned char *password[VECTORSIZE], int pwlen[VECTORSIZE], unsigned char salt[8],unsigned char *ownerkey, unsigned char *hash[VECTORSIZE])
{
    unsigned char data[(128 + 64 + 48) * 64];
    unsigned char block[64];
    int block_size = 32;
    int data_len = 0;
    int i, j, sum,a;
    SHA256_CTX sha256;
    SHA512_CTX sha384;
    SHA512_CTX sha512;
    AES_KEY aes;

    for (a=0;a<vectorsize;a++)
    {
        /* Step 1: calculate initial data block */
        SHA256_Init(&sha256);
        SHA256_Update(&sha256, password[a], pwlen[a]);
        SHA256_Update(&sha256, salt, 8);
        SHA256_Final(block, &sha256);

        for (i = 0; i < 64 || i < data[data_len * 64 - 1] + 32; i++) {
                /* Step 2: repeat password and data block 64 times */
                memcpy(data, password[a], pwlen[a]);
                memcpy(data + pwlen[a], block, block_size);
                data_len = pwlen[a] + block_size;
                for (j = 1; j < 64; j++)
                        memcpy(data + j * data_len, data, data_len);


                /* Step 3: encrypt data using data block as key and iv */
                hash_aes_set_encrypt_key(block, 128, &aes);
                hash_aes_cbc_encrypt(data, data, data_len * 64, &aes, block + 16, AES_ENCRYPT);

                /* Step 4: determine SHA-2 hash size for this round */
                for (j = 0, sum = 0; j < 16; j++)
                        sum += data[j];

                /* Step 5: calculate data block for next round */
                block_size = 32 + (sum % 3) * 16;
                switch (block_size) {
                case 32:
                        SHA256_Init(&sha256);
                        SHA256_Update(&sha256, data, data_len * 64);
                        SHA256_Final(block, &sha256);
                        break;
                case 48:
                        SHA384_Init(&sha384);
                        SHA384_Update(&sha384, data, data_len * 64);
                        SHA384_Final(block, &sha384);
                        break;
                case 64:
                        SHA512_Init(&sha512);
                        SHA512_Update(&sha512, data, data_len * 64);
                        SHA512_Final(block, &sha512);
                        break;
                }
        }
        memset(data, 0, sizeof(data));
        memcpy(hash[a], block, 32);
    }
}


/* Computing the user password (PDF 1.7 algorithm 3.4 and 3.5) */

static void pdf_compute_user_password(unsigned char *password[VECTORSIZE], unsigned char *output[VECTORSIZE])
{
	int pwlen[VECTORSIZE];
	int lens[VECTORSIZE];
	unsigned char *key[VECTORSIZE];
	unsigned char *buf[VECTORSIZE];
	int a;

	if (cs.R == 2) 
	{
	    RC4_KEY arc4;
	    int n;

	    n = cs.length / 8;
	    for (a=0;a<vectorsize;a++)
	    {
		
		pwlen[a] = strlen((char *) password[a]);
		key[a] = alloca(128);
	    }
	    pdf_compute_encryption_key(password, pwlen, key);
	    for (a=0;a<vectorsize;a++)
	    {
		RC4_set_key(&arc4, n, key[a]);
		RC4(&arc4, 32, padding, output[a]);
	    }
	}
	else if (cs.R == 3 || cs.R == 4) 
	{
	    unsigned char xor[32];
	    unsigned char *digest[VECTORSIZE];
	    int i, x, n;
	    RC4_KEY arc4;

	    n = cs.length / 8;
	    for (a=0;a<vectorsize;a++)
	    {
		key[a] = alloca(128);
		buf[a] = alloca(64);
		digest[a] = alloca(16);
		pwlen[a] = strlen((char *) password[a]);
	    }
	    pdf_compute_encryption_key(password, pwlen, key);
	    for (a=0;a<vectorsize;a++)
	    {
		memcpy(buf[a],padding,32);
		memcpy(buf[a]+32,cs.id,cs.length_id);
		lens[a]=32+cs.length_id;
	    }
	    hash_md5_unicode_slow((const char **)buf,(char **)digest,lens);
	    for (a=0;a<vectorsize;a++)
	    {
		RC4_set_key(&arc4, n, key[a]);
		RC4(&arc4, 16, digest[a], output[a]);
		for (x = 1; x <= 19; x++) {
			for (i = 0; i < n; i++)
				xor[i] = key[a][i] ^ x;
			RC4_set_key(&arc4, n, xor);
			RC4(&arc4, 16, output[a], output[a]);
		}
		memcpy(output[a] + 16, padding, 16);
	    }
	}
	else if (cs.R == 5) 
	{
	    for (a=0;a<vectorsize;a++)
	    {
		pwlen[a] = strlen((char *) password[a]);
	    }
	    pdf_compute_encryption_key_r5(password, pwlen, 0, output);
	}

	/* SumatraPDF: support crypt version 5 revision 6 */
	else if (cs.R == 6)
	{
	    for (a=0;a<vectorsize;a++)
	    {
		pwlen[a] = strlen((char *) password[a]);
	    }
	    pdf_compute_hardened_hash_r6(password, pwlen, cs.u + 32, NULL, output);
	}
}


hash_stat hash_plugin_check_hash(const char *hash, const char *password[VECTORSIZE], const char *salt,
    char *salt2[VECTORSIZE], const char *username, int *num, int threadid)
{
	char *buf[VECTORSIZE];
	int a;

	for (a = 0; a < vectorsize; a++) {
		buf[a] = alloca(32);
	}

	pdf_compute_user_password((unsigned char **)password, (unsigned char **)buf);
	for (a = 0; a < vectorsize; a++) {
		
		if (cs.R == 3 || cs.R == 4)
			if (memcmp(buf[a], cs.u, 16) == 0) {
				*num = a;
				return hash_ok;
			}
		if (cs.R == 2 || cs.R == 5 || cs.R == 6)
			if (memcmp(buf[a], cs.u, 32) == 0) {
				*num = a;
				return hash_ok;
			}
	}

	return hash_err;
}


int hash_plugin_hash_length(void)
{
	return 16;
}

int hash_plugin_is_raw(void)
{
	return 0;
}

int hash_plugin_is_special(void)
{
	return 1;
}

void get_vector_size(int size)
{
	vectorsize = size;
}

int get_salt_size(void)
{
	return 4;
}
