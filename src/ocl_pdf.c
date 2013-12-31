/*
 * ocl_pdf.c
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
#include <ctype.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <sys/types.h>
#include "err.h"
#include "ocl-base.h"
#include "ocl-threads.h"
#include "plugins.h"
#include "hashinterface.h"
#include "sessions.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"


static int hash_ret_len1=32;


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


char* strlow(char* ioString)
{
    int i;
    int theLength = (int)strlen(ioString);

    for(i=0; i<theLength; ++i) {ioString[i] = tolower(ioString[i]);}
    return ioString;
}


/* Milen: Do the parsing inside the plugin instead */
static hash_stat load_pdf(char *filename)
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
    return hash_ok;

    out:
    free(buf);
    return hash_err;
}




static cl_uint16 get_singlehash()
{
    unsigned char sh[64];
    cl_uint16 t;

    if (cs.R<5)
    {
	memset(sh,0,32);
	memcpy(sh, cs.u, (cs.length_u>32) ? 32 : cs.length_u);
	t.s0 = (sh[0])|(sh[1]<<8)|(sh[2]<<16)|(sh[3]<<24);
	t.s1 = (sh[4])|(sh[5]<<8)|(sh[6]<<16)|(sh[7]<<24);
	t.s2 = (sh[8])|(sh[9]<<8)|(sh[10]<<16)|(sh[11]<<24);
	t.s3 = (sh[12])|(sh[13]<<8)|(sh[14]<<16)|(sh[15]<<24);
	t.s4 = (sh[16])|(sh[17]<<8)|(sh[18]<<16)|(sh[19]<<24);
	t.s5 = (sh[20])|(sh[21]<<8)|(sh[22]<<16)|(sh[23]<<24);
	t.s6 = (sh[24])|(sh[25]<<8)|(sh[26]<<16)|(sh[27]<<24);
	t.s7 = (sh[28])|(sh[29]<<8)|(sh[30]<<16)|(sh[31]<<24);
    }
    else
    {
	memset(sh,0,64);
	memcpy(sh, cs.u, (cs.length_u>40) ? 40 : cs.length_u);
	t.s0 = (sh[0])|(sh[1]<<8)|(sh[2]<<16)|(sh[3]<<24);
	t.s1 = (sh[4])|(sh[5]<<8)|(sh[6]<<16)|(sh[7]<<24);
	t.s2 = (sh[8])|(sh[9]<<8)|(sh[10]<<16)|(sh[11]<<24);
	t.s3 = (sh[12])|(sh[13]<<8)|(sh[14]<<16)|(sh[15]<<24);
	t.s4 = (sh[16])|(sh[17]<<8)|(sh[18]<<16)|(sh[19]<<24);
	t.s5 = (sh[20])|(sh[21]<<8)|(sh[22]<<16)|(sh[23]<<24);
	t.s6 = (sh[24])|(sh[25]<<8)|(sh[26]<<16)|(sh[27]<<24);
	t.s7 = (sh[28])|(sh[29]<<8)|(sh[30]<<16)|(sh[31]<<24);
	t.s8 = (sh[32])|(sh[33]<<8)|(sh[34]<<16)|(sh[35]<<24);
	t.s9 = (sh[36])|(sh[37]<<8)|(sh[38]<<16)|(sh[39]<<24);
    }

    return t;
}


/* Crack callback */
static void ocl_pdf_crack_callback(char *line, int self)
{
    int a;
    int *found;
    int err;
    char plain[MAX];
    cl_uint16 addline;
    cl_uint16 salt;
    cl_uint16 singlehash;
    size_t gws,gws1;

    /* setup addline */
    addline.s0=addline.s1=addline.s2=addline.s3=addline.s4=addline.s5=addline.s6=addline.s7=addline.sF=0;
    addline.sF=strlen(line);
    addline.s0=line[0]|(line[1]<<8)|(line[2]<<16)|(line[3]<<24);
    addline.s1=line[4]|(line[5]<<8)|(line[6]<<16)|(line[7]<<24);
    addline.s2=line[8]|(line[9]<<8)|(line[10]<<16)|(line[11]<<24);
    addline.s3=line[12]|(line[13]<<8)|(line[14]<<16)|(line[15]<<24);

    singlehash = get_singlehash();

    /* setup salt */
    salt.s0=(cs.o[0])|(cs.o[1]<<8)|(cs.o[2]<<16)|(cs.o[3]<<24);
    salt.s1=(cs.o[4])|(cs.o[5]<<8)|(cs.o[6]<<16)|(cs.o[7]<<24);
    salt.s2=(cs.o[8])|(cs.o[9]<<8)|(cs.o[10]<<16)|(cs.o[11]<<24);
    salt.s3=(cs.o[12])|(cs.o[13]<<8)|(cs.o[14]<<16)|(cs.o[15]<<24);
    salt.s4=(cs.o[16])|(cs.o[17]<<8)|(cs.o[18]<<16)|(cs.o[19]<<24);
    salt.s5=(cs.o[20])|(cs.o[21]<<8)|(cs.o[22]<<16)|(cs.o[23]<<24);
    salt.s6=(cs.o[24])|(cs.o[25]<<8)|(cs.o[26]<<16)|(cs.o[27]<<24);
    salt.s7=(cs.o[28])|(cs.o[29]<<8)|(cs.o[30]<<16)|(cs.o[31]<<24);
    salt.s8=(cs.o[32])|(cs.o[33]<<8)|(cs.o[34]<<16)|(cs.o[35]<<24);
    salt.s9=(cs.o[36])|(cs.o[37]<<8)|(cs.o[38]<<16)|(cs.o[39]<<24);

    salt.sA=(cs.id[0])|(cs.id[1]<<8)|(cs.id[2]<<16)|(cs.id[3]<<24);
    salt.sB=(cs.id[4])|(cs.id[5]<<8)|(cs.id[6]<<16)|(cs.id[7]<<24);
    salt.sC=(cs.id[8])|(cs.id[9]<<8)|(cs.id[10]<<16)|(cs.id[11]<<24);
    salt.sD=(cs.id[12])|(cs.id[13]<<8)|(cs.id[14]<<16)|(cs.id[15]<<24);
    salt.sF=cs.P;
    salt.sE=cs.encrypt_metadata;

    if (attack_over!=0) pthread_exit(NULL);
    pthread_mutex_lock(&wthreads[self].tempmutex);
    pthread_mutex_unlock(&wthreads[self].tempmutex);

    _clSetKernelArg(rule_kernelmod[self], 0, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 1, sizeof(cl_mem), (void*) &rule_images_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelmod[self], 3, sizeof(cl_uint16), (void*) &addline);
    _clSetKernelArg(rule_kernelmod[self], 4, sizeof(cl_uint16), (void*) &salt);
    _clSetKernelArg(rule_kernelpre1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 1, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernelpre1[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernelpre1[self], 6, sizeof(cl_uint16), (void*) &salt);
    if (cs.R==6)
    {
	_clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_images2_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_mem), (void*) &rule_found_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &singlehash);
	_clSetKernelArg(rule_kernelbl1[self], 7, sizeof(cl_uint16), (void*) &salt);
    }
    else
    {
	_clSetKernelArg(rule_kernelbl1[self], 0, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
	_clSetKernelArg(rule_kernelbl1[self], 5, sizeof(cl_uint16), (void*) &singlehash);
	_clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &salt);
    }
    _clSetKernelArg(rule_kernellast[self], 0, sizeof(cl_mem), (void*) &rule_buffer[self]);
    _clSetKernelArg(rule_kernellast[self], 1, sizeof(cl_mem), (void*) &rule_images3_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 2, sizeof(cl_mem), (void*) &rule_sizes_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 3, sizeof(cl_mem), (void*) &rule_found_ind_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 4, sizeof(cl_mem), (void*) &rule_found_buf[self]);
    _clSetKernelArg(rule_kernellast[self], 5, sizeof(cl_uint16), (void*) &singlehash);
    _clSetKernelArg(rule_kernellast[self], 6, sizeof(cl_uint16), (void*) &salt);


    if (rule_counts[self][0]==-1) return;
    gws = (rule_counts[self][0] / wthreads[self].vectorsize);
    while ((gws%64)!=0) gws++;
    gws1 = gws*wthreads[self].vectorsize;
    if (gws1==0) gws1=64;
    if (gws==0) gws=64;

    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelmod[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);
    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelpre1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
    _clFinish(rule_oclqueue[self]);

    if (cs.R==6)
    {
	for (a=0;a<256+32;a++)
	{
	    if (attack_over!=0) return;
	    singlehash.sE = a;
	    _clSetKernelArg(rule_kernelbl1[self], 6, sizeof(cl_uint16), (void*) &singlehash);
	    _clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	    _clFinish(rule_oclqueue[self]);
	    wthreads[self].tries+=(gws)/(256+32);
	}
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);

    }
    else if (cs.R<5)
    {
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernelbl1[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
	_clEnqueueNDRangeKernel(rule_oclqueue[self], rule_kernellast[self], 1, NULL, &gws, rule_local_work_size, 0, NULL, NULL);
	_clFinish(rule_oclqueue[self]);
    }

    found = _clEnqueueMapBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE,CL_MAP_READ, 0, 4, 0, 0, NULL, &err);
    if (cs.R!=6) wthreads[self].tries+=(gws);
    if (*found>0) 
    {
        _clEnqueueReadBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_TRUE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
    	for (a=0;a<ocl_rule_workset[self];a++)
	if (rule_found_ind[self][a]==1)
	{
    	    {
                strcpy(plain,&rule_images[self][0]+(a*MAX));
                strcat(plain,line);
                pthread_mutex_lock(&crackedmutex);
                if (!cracked_list)
                {
        	    pthread_mutex_unlock(&crackedmutex);
            	    add_cracked_list(hash_list->username, hash_list->hash, hash_list->salt, plain);
        	}
        	else pthread_mutex_unlock(&crackedmutex);
    	    }
	}
	bzero(rule_found_ind[self],ocl_rule_workset[self]*sizeof(cl_uint));
    	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_ind_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*sizeof(cl_uint), rule_found_ind[self], 0, NULL, NULL);
        *found = 0;
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_FALSE, 0, 4, found, 0, NULL, NULL);
    }
    _clEnqueueUnmapMemObject(rule_oclqueue[self],rule_found_buf[self],(void *)found,0,NULL,NULL);
}



static void ocl_pdf_callback(char *line, int self)
{
    if ((rule_counts[self][0]==-1)&&(line[0]==0x01)) return;
    rule_counts[self][0]++;
    rule_sizes[self][rule_counts[self][0]] = strlen(line);
    strcpy(&rule_images[self][0]+(rule_counts[self][0]*MAX),line);

    if ((rule_counts[self][0]>=(ocl_rule_workset[self]*wthreads[self].vectorsize-1))||(line[0]==0x01))
    {
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_images_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, rule_images[self], 0, NULL, NULL);
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_sizes_buf[self], CL_FALSE, 0, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int), rule_sizes[self], 0, NULL, NULL);
	rule_offload_perform(ocl_pdf_crack_callback,self);
    	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_counts[self][0]=-1;
    }
    if (attack_over==2) pthread_exit(NULL);
}




/* Worker thread - rule attack */
void* ocl_rule_pdf_thread(void *arg)
{
    cl_int err;
    int found=0;
    size_t nvidia_local_work_size[3]={64,1,1};
    size_t amd_local_work_size[3]={64,1,1};
    int self;

    memcpy(&self,arg,sizeof(int));
    pthread_mutex_lock(&biglock);

    if (wthreads[self].ocl_have_sm10 == 1) 
    {
	wlog("This plugin is not supported on compute capability 1.0 hardware. Try CPU attack (-c) instead!\n%s","");
	return NULL;
    }
    if (wthreads[self].type==nv_thread) rule_local_work_size = nvidia_local_work_size;
    else rule_local_work_size = amd_local_work_size;
    ocl_rule_workset[self]=256*256;
    if (wthreads[self].ocl_have_gcn) ocl_rule_workset[self]*=2;
    if (ocl_gpu_double) ocl_rule_workset[self]*=2;
    if (interactive_mode==1) ocl_rule_workset[self]/=8;
    
    rule_ptr[self] = malloc(ocl_rule_workset[self]*hash_ret_len1*wthreads[self].vectorsize);
    rule_counts[self][0]=0;

    rule_kernelmod[self] = _clCreateKernel(program[self], "strmodify", &err );
    rule_kernelpre1[self] = _clCreateKernel(program[self], "prepare", &err );
    if ((cs.R==3)||(cs.R==4))
    {
	if (cs.length==40) rule_kernelbl1[self] = _clCreateKernel(program[self], "block2", &err );
	else rule_kernelbl1[self] = _clCreateKernel(program[self], "block", &err );
    }
    else
    {
	rule_kernelbl1[self] = _clCreateKernel(program[self], "block", &err );
    }
    rule_kernellast[self] = _clCreateKernel(program[self], "final", &err );

    rule_oclqueue[self] = _clCreateCommandQueue(context[self], wthreads[self].cldeviceid, 0, &err );
    rule_buffer[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*wthreads[self].vectorsize*hash_ret_len1, NULL, &err );
    rule_found_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, 4, NULL, &err );

    if (cs.R!=6)
    {
	rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
	bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]*wthreads[self].vectorsize);
	rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize, NULL, &err );
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
	rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
	rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
	rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
	rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
	rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    }
    else
    {
	wlog("Warning: this is a PDF R6 file, you are very likely better off using the CPU to crack it. Use -c option for that\n%s","");
	rule_found_ind[self]=malloc(ocl_rule_workset[self]*sizeof(cl_uint));
	bzero(rule_found_ind[self],sizeof(uint)*ocl_rule_workset[self]*wthreads[self].vectorsize);
	rule_found_ind_buf[self] = _clCreateBuffer(context[self], CL_MEM_WRITE_ONLY, ocl_rule_workset[self]*sizeof(cl_uint)*wthreads[self].vectorsize, NULL, &err );
	_clEnqueueWriteBuffer(rule_oclqueue[self], rule_found_buf[self], CL_TRUE, 0, 4, &found, 0, NULL, NULL);
	rule_images_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*MAX, NULL, &err );
	rule_images2_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*32, NULL, &err );
	rule_images3_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*72, NULL, &err );
	rule_sizes_buf[self] = _clCreateBuffer(context[self], CL_MEM_READ_WRITE, ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint), NULL, &err );
	rule_sizes[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(int));
	rule_images[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	rule_images2[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	rule_images3[self]=malloc(ocl_rule_workset[self]*wthreads[self].vectorsize*72);
	bzero(&rule_images[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*MAX);
	bzero(&rule_images2[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*32);
	bzero(&rule_images3[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*72);
	bzero(&rule_sizes[self][0],ocl_rule_workset[self]*wthreads[self].vectorsize*sizeof(cl_uint));
    }

    pthread_mutex_unlock(&biglock); 

    worker_gen(self,ocl_pdf_callback);

    return hash_ok;
}




hash_stat ocl_bruteforce_pdf(void)
{
    suggest_rule_attack();
    return hash_ok;
}



hash_stat ocl_markov_pdf(void)
{
    suggest_rule_attack();
    return hash_ok;
}





/* Main thread - rule */
hash_stat ocl_rule_pdf(void)
{
    int a,i;
    int err;
    int worker_thread_keys[32];



    /* setup initial OpenCL vars */
    int numplatforms=0;
    _clGetPlatformIDs(4, platform, (cl_uint *)&numplatforms);
    if (hash_err==load_pdf(hashlist_file)) return hash_err;

    for (i=0;i<nwthreads;i++) if (wthreads[i].type!=cpu_thread)
    {
	_clGetDeviceIDs(platform[wthreads[i].platform], CL_DEVICE_TYPE_GPU, 64, device, (cl_uint *)&devicesnum);
        context[i] = _clCreateContext(NULL, 1, &device[wthreads[i].deviceid], NULL, NULL, &err);
        if (wthreads[i].type != nv_thread)
        {
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    if (cs.R==2) sprintf(kernelfile,"%s/hashkill/kernels/amd_pdf2__%s.bin",DATADIR,pbuf);
    	    else if (cs.R==3) sprintf(kernelfile,"%s/hashkill/kernels/amd_pdf3__%s.bin",DATADIR,pbuf);
    	    else if (cs.R==4) sprintf(kernelfile,"%s/hashkill/kernels/amd_pdf4__%s.bin",DATADIR,pbuf);
    	    else if (cs.R==5) sprintf(kernelfile,"%s/hashkill/kernels/amd_pdf5__%s.bin",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/amd_pdf6__%s.bin",DATADIR,pbuf);

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            if (!fp) 
            {
                elog("Can't open kernel: %s\n",kernelfile);
                exit(1);
            }
            
            fseek(fp, 0, SEEK_END);
            binary_size = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            binary=malloc(binary_size);
            fread(binary,binary_size,1,fp);
            fclose(fp);
            unlink(ofname);
            free(ofname);
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], "", NULL, NULL );
            free(binary);
        }
        else
        {
            #define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
            #define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
            char *binary;
            size_t binary_size;
            FILE *fp;
            char pbuf[100];
            bzero(pbuf,100);
            char kernelfile[255];
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    cl_uint compute_capability_major, compute_capability_minor;
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
            _clGetDeviceInfo(device[wthreads[i].deviceid], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
            if ((compute_capability_major==1)&&(compute_capability_minor==0)) sprintf(pbuf,"sm10");
            if ((compute_capability_major==1)&&(compute_capability_minor==1)) sprintf(pbuf,"sm11");
            if ((compute_capability_major==1)&&(compute_capability_minor==2)) sprintf(pbuf,"sm12");
            if ((compute_capability_major==1)&&(compute_capability_minor==3)) sprintf(pbuf,"sm13");
            if ((compute_capability_major==2)&&(compute_capability_minor==0)) sprintf(pbuf,"sm20");
            if ((compute_capability_major==2)&&(compute_capability_minor==1)) sprintf(pbuf,"sm21");
	    if ((compute_capability_major==3)&&(compute_capability_minor==0)) sprintf(pbuf,"sm30");
    	    if (cs.R==2) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_pdf2__%s.ptx",DATADIR,pbuf);
    	    else if (cs.R==3) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_pdf3__%s.ptx",DATADIR,pbuf);
    	    else if (cs.R==4) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_pdf4__%s.ptx",DATADIR,pbuf);
    	    else if (cs.R==5) sprintf(kernelfile,"%s/hashkill/kernels/nvidia_pdf5__%s.ptx",DATADIR,pbuf);
    	    else sprintf(kernelfile,"%s/hashkill/kernels/nvidia_pdf6__%s.ptx",DATADIR,pbuf);

    	    char *ofname = kernel_decompress(kernelfile);
            if (!ofname) return hash_err;
            fp=fopen(ofname,"r");
            if (!fp) 
            {
                elog("Can't open kernel: %s\n",kernelfile);
                exit(1);
            }
            
            fseek(fp, 0, SEEK_END);
            binary_size = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            binary=malloc(binary_size);
            fread(binary,binary_size,1,fp);
            fclose(fp);
            unlink(ofname);
            free(ofname);
            if (wthreads[i].first==1) hlog("Loading kernel: %s\n",kernelfile);
            program[i] = _clCreateProgramWithBinary(context[i], 1, &device[wthreads[i].deviceid], (size_t *)&binary_size, (const unsigned char **)&binary, NULL, &err );
            _clBuildProgram(program[i], 1, &device[wthreads[i].deviceid], NULL, NULL, NULL );
            free(binary);
        }
    }


    pthread_mutex_init(&biglock, NULL);

    for (a=0;a<nwthreads;a++)
    {
        worker_thread_keys[a]=a;
        pthread_create(&crack_threads[a], NULL, ocl_rule_pdf_thread, &worker_thread_keys[a]);
    }
    rule_gen_parse(rule_file,ocl_pdf_callback,nwthreads,SELF_THREAD);

    for (a=0;a<nwthreads;a++) pthread_join(crack_threads[a], NULL);
    attack_over=2;
    printf("\n");
    hlog("Done!\n%s","");
    return hash_ok;
}

