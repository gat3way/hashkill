/* 
 * hashgen-mangle.c
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

#define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/types.h>
#include <ctype.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <errno.h>
#include "err.h"
#include "hashinterface.h"
#include "ocl-threads.h"
#include "hashgen.h"
#include "hashgen-mangle.h"



#define BREAKPOINT(line1,line2,index,self) \
			if (attack_over!=0) \
			{ \
			    if (((index)==0)||(hashgen_stdout_mode==1)) return; \
			    else  \
			    { \
				pthread_exit(NULL); \
			    } \
			} \
			else if (ops[(self)][0].chainlen>((index)+1)) \
			{ \
			    ops[(self)][(index)+1].parsefn((line1),(line2),(index)+1,(self)); \
			} \
			else ops[(self)][0].crack_callback((line1),(self));



static char *ualpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char *vowels="eEuUiIoOaA";
static char *cons="qwrtypsdfghjklzxcvbnmQWRTYPSDFGHJKLZXCVBNM";
static int is_preprocess=0;
static int curthread=0;



/* helper - string reverse */
static inline char *strrev(char *s,int n)
{
    int i=0;
    while (i<n/2)
    {
	*(s+n) = *(s+i);       
        *(s+i) = *(s + n - i -1);
        *(s+n-i-1) = *(s+n);
        i++;
    }
    *(s+n) = '\0';
    return s;
}


static inline void numtostr(int num, int format, char *dest)
{
    int t,u,div=10,i,j;
    char lookup[10]="0123456789";
    char tmp;
    
    i=1;
    dest[0] = lookup[num%10];
    u=(num/div);
    t=u%10;
    while (u!=0)
    {
	dest[i]=lookup[t];
	div*=10;
	i++;
	u=(num/div);
	t=u%10;
    }
    dest[i]=0;
    /*
    for (j=i;j<format;j++) dest[j]='0';
    */
    j=0;i--;
    while ((i>j))
    {
	tmp=dest[j];
	dest[j]=dest[i];
	dest[i]=tmp;
	i--;j++;
    }
}


/* end node - output results */
inline void node_final(char *line, char *stack, int ind, int self)
{
    ops[self][0].crack_callback(line,self);
}


/* end node - push all results */
void node_final_push(char *line, char *stack, int ind, int self)
{
    ops[self][0].crack_callback(line,self);
}



/* Add string hook */
void node_add_str(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,line);
    	    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	cline[0]=0;
	strcpy(cline,line);
	strcat(cline,ops[self][ind].params);
	BREAKPOINT(cline,stack,ind,self);
	//ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
    	    //ops[self][ind+1].parsefn(line,cline,ind+1,self);
	}
	cline[0]=0;
	strcpy(cline,stack);
	strcat(cline,ops[self][ind].params);
	//ops[self][ind+1].parsefn(line,cline,ind+1,self);
	BREAKPOINT(line,cline,ind,self);
    }
}


/* Add reverse string hook */
void node_add_revstr(char *line, char *stack,int ind,int self)
{
    int i,j;
    char tmp;
    char cline[MAXCAND];
    char mline[MAXCAND];
    
    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,line);
    	    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	cline[0]=0;
	strcpy(cline,line);
	strcpy(mline,line);
	j=0;i=strlen(line)-1;
	while ((i>j))
	{
	    tmp=mline[j];
	    mline[j]=mline[i];
	    mline[i]=tmp;
	    i--;j++;
	}
	strcat(cline,mline);
	//ops[self][ind+1].parsefn(cline,stack,ind+1,self);
	BREAKPOINT(cline,stack,ind,self);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
    	    //ops[self][ind+1].parsefn(line,cline,ind+1,self);
    	    BREAKPOINT(line,cline,ind,self);
	}
	cline[0]=0;
	strcpy(mline,stack);
	j=0;i=strlen(stack)-1;
	while ((i>j))
	{
	    tmp=mline[j];
	    mline[j]=mline[i];
	    mline[i]=tmp;
	    i--;j++;
	}
	strcpy(cline,stack);
	strcat(cline,mline);
	//ops[self][ind+1].parsefn(line,cline,ind+1,self);
	BREAKPOINT(line,cline,ind,self);
    }
}


/* Add same string hook */
void node_add_samestr(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,line);
    	    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	cline[0]=0;
	strcpy(cline,line);
	strcat(cline,line);
	//ops[self][ind+1].parsefn(cline,stack,ind+1,self);
	BREAKPOINT(cline,stack,ind,self);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
    	    //ops[self][ind+1].parsefn(line,cline,ind+1,self);
    	    BREAKPOINT(line,cline,ind,self);
	}
	cline[0]=0;
	strcpy(cline,stack);
	strcat(cline,stack);
	//ops[self][ind+1].parsefn(line,cline,ind+1,self);
	BREAKPOINT(line,cline,ind,self);
    }
}


/* Add last char hook */
void node_add_lastchar(char *line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,line);
    	    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	cline[0]=0;
	strcpy(cline,line);
	a=strlen(cline);
	cline[a]=cline[a-1];
	cline[a+1]=0;
	//ops[self][ind+1].parsefn(cline,stack,ind+1,self);
	BREAKPOINT(cline,stack,ind,self);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
    	    //ops[self][ind+1].parsefn(line,cline,ind+1,self);
    	    BREAKPOINT(line,cline,ind,self);
	}
	cline[0]=0;
	strcpy(cline,stack);
	a=strlen(cline);
	cline[a]=cline[a-1];
	cline[a+1]=0;
	//ops[self][ind+1].parsefn(line,cline,ind+1,self);
	BREAKPOINT(line,cline,ind,self);
    }
}


/* Add char hook */
void node_add_char(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    int a;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    a=strlen(line);
    cline[a]=ops[self][ind].params[0];
    cline[a+1]=0;
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}




/* Add dictionary hook */
void node_add_dict(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    char rline[MAXCAND];
    FILE *fp;
    char nextname[1024];
    int *map;
    int mapped=0;
    int fd=0;
    struct stat st;


    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}
	
	if (ind==0)
	{
	    sprintf(nextname,ops[self][ind].params);
	    if (lstat(nextname,&st) != 0)
	    {
	        sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
		if (stat(nextname,&st) != 0)
		{
		    hg_elog("Could not open dictionary: %s\n",nextname);
		    exit(1);
		}
	    }
	    if (st.st_size<MAX_MMAP_INITIAL)
	    {
		fd = open(nextname, O_RDONLY|O_LARGEFILE);
		if (fd<0)
		{
		    elog("Cannot open %s?!?\n",nextname);
		}
		map = mmap(0, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
		if (map==MAP_FAILED)
		{
		    hg_elog("Could not mmap dictionary: %s\n",nextname);
		    exit(1);
		}
		fp=fmemopen((char *)map,st.st_size,"r");
		if (!fp)
		{
		    hg_elog("Could not mmap dictionary: %s\n",nextname);
		    exit(1);
		}
		mapped=1;
	    }
	    else 
	    {
		fp=fopen(nextname,"r");
		if (!fp)
		{
		    hg_elog("Could not mmap dictionary: %s\n",nextname);
		    exit(1);
		}
	    }
	}
	else
	{
	    sprintf(nextname,ops[self][ind].params);
	    if (lstat(nextname,&st) != 0)
	    {
	        sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
		if (stat(nextname,&st) != 0)
		{
		    hg_elog("Could not open dictionary: %s\n",nextname);
		    exit(1);
		}
	    }
	    fp=fopen(nextname,"r");
	    if (!fp)
	    {
	        hg_elog("Could not mmap dictionary: %s\n",nextname);
	        exit(1);
	    }
	}

	while (!feof(fp))
	{
            fgets(rline,MAXCAND,fp);
            rline[MAXCAND-1]=0;
            if (rline[strlen(rline)-1]=='\n') rline[strlen(rline)-1]=0;
            if (rline[strlen(rline)-1]=='\r') rline[strlen(rline)-1]=0;

    	    bzero(cline,32);
    	    strcpy(cline,line);
    	    strcat(cline,rline);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	fclose(fp);
	if (mapped==1) munmap(map,st.st_size);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
	}

	fp=fopen(ops[self][ind].params,"r");
	if (!fp) 
	{
	    sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
	    fp=fopen(nextname,"r");
	    if (!fp)
	    {
		hg_elog("Could not open dictionary: %s\n",nextname);
		exit(1);
	    }
	}
	if (!fp)
	{
	    hg_elog("Could not open dictionary: %s\n",ops[self][ind].params);
	    exit(1);
	}

	while (!feof(fp))
	{
            fgets(rline,MAXCAND,fp);
            rline[strlen(rline)-1]=0;
            cline[MAXCAND-1]=0;
            cline[MAXCAND-1]=0;
            bzero(cline,strlen(cline));
            strcpy(cline,stack);
            strcat(cline,rline);
            BREAKPOINT(line,cline,ind,self);
	}
	fclose(fp);
    }

}


/* Add pipe hook */
void node_add_pipe(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    char rline[MAXCAND];
    FILE *fp;

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	fp=popen(ops[self][ind].params,"r");
	if (!fp) 
	{
	    hg_elog("Could not fork command: %s\n",ops[self][ind].params);
	    exit(1);
	}
	
	while (!feof(fp))
	{
	    fgets(rline,MAXCAND,fp);
	    rline[strlen(rline)-1]=0;
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    strcat(cline,rline);
	    BREAKPOINT(cline,stack,ind,self);
	}
	pclose(fp);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
	}

	fp=popen(ops[self][ind].params,"r");
	if (!fp) 
	{
	    hg_elog("Could not fork command: %s\n",ops[self][ind].params);
	    exit(1);
	}

	while (!feof(fp))
	{
	    fgets(rline,MAXCAND,fp);
	    rline[strlen(rline)-1]=0;
	    cline[MAXCAND-1]=0;
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    strcat(cline,rline);
	    BREAKPOINT(line,cline,ind,self);
	}
	pclose(fp);
    }

}



/* Add phrases hook */
void node_add_phrases(char *line, char *stack,int ind,int self)
{
    char cline[65535];
    char rline[65535];
    FILE *fp;
    char nextname[1024];
    int a,b;
    char *words[4096];
    int wc;
    char *saveptr;

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	fp=fopen(ops[self][ind].params,"r");
	if (!fp) 
	{
	    sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
	    fp=fopen(nextname,"r");
	    if (!fp)
	    {
		hg_elog("Could not open dictionary: %s\n",nextname);
		exit(1);
	    }
	}
	if (!fp)
	{
	    hg_elog("Could not open dictionary: %s\n",ops[self][ind].params);
	    exit(1);
	}

	while (!feof(fp))
	{
            fgets(rline,65535,fp);
            rline[65534]=0;
            if (rline[strlen(rline)-1]=='\n') rline[strlen(rline)-1]=0;
            if (rline[strlen(rline)-1]=='\r') rline[strlen(rline)-1]=0;
	    for (a=0;a<strlen(rline);a++) if ((rline[a]=='.')||(rline[a]==',')||(rline[a]=='-')||(rline[a]==';')||(rline[a]=='!')||(rline[a]=='?')||(rline[a]==':'))
		rline[a]=' ';
	    for (a=0;a<4096;a++) words[a]=NULL;
	    wc=0;
	    words[0]=strtok_r(rline," ",&saveptr);
	    while (words[wc]!=NULL)
	    {
		wc++;
		words[wc]=strtok_r(NULL," ",&saveptr);
	    }
	    for (a=0;a<wc;a++)
	    {
        	bzero(cline,MAXCAND);
        	strncpy(cline,line,MAXCAND);
		for (b=0;b<ops[self][ind].start-1;b++)
		if (words[a+b]!=NULL)
		{
		    if (b>0) strncat(cline,ops[self][ind].charset,1);
		    strncat(cline,words[a+b],MAXCAND);
		}
		for (;b<ops[self][ind].end;b++)
		if (words[a+b]!=NULL)
		{
		    if (b>0) strncat(cline,ops[self][ind].charset,1);
		    strncat(cline,words[a+b],MAXCAND);
        	    cline[MAXCAND]=0;
        	    BREAKPOINT(cline,stack,ind,self);
		}
    	    }
	}
	fclose(fp);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	fp=fopen(ops[self][ind].params,"r");
	if (!fp) 
	{
	    sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
	    fp=fopen(nextname,"r");
	    if (!fp)
	    {
		hg_elog("Could not open dictionary: %s\n",nextname);
		exit(1);
	    }
	}
	if (!fp)
	{
	    hg_elog("Could not open dictionary: %s\n",ops[self][ind].params);
	    exit(1);
	}

	while (!feof(fp))
	{
            fgets(rline,65535,fp);
            rline[65534]=0;
            if (rline[strlen(rline)-1]=='\n') rline[strlen(rline)-1]=0;
            if (rline[strlen(rline)-1]=='\r') rline[strlen(rline)-1]=0;
	    for (a=0;a<strlen(rline);a++) if ((rline[a]=='.')||(rline[a]==',')||(rline[a]=='-')||(rline[a]==';')||(rline[a]=='!')||(rline[a]=='?')||(rline[a]==':'))
		rline[a]=' ';
	    for (a=0;a<4096;a++) words[a]=NULL;
	    wc=0;
	    words[0]=strtok_r(rline," ",&saveptr);
	    while (words[wc]!=NULL)
	    {
		wc++;
		words[wc]=strtok_r(NULL," ",&saveptr);
	    }
	    for (a=0;a<wc;a++)
	    {
        	bzero(cline,MAXCAND);
        	strncpy(cline,stack,MAXCAND);
		for (b=0;b<ops[self][ind].start-1;b++)
		if (words[a+b]!=NULL)
		{
		    if (b>0) strncat(cline,ops[self][ind].charset,1);
		    strncat(cline,words[a+b],MAXCAND);
		}
		for (;b<ops[self][ind].end;b++)
		if (words[a+b]!=NULL)
		{
		    if (b>0) strncat(cline,ops[self][ind].charset,1);
		    strncat(cline,words[a+b],MAXCAND);
        	    cline[MAXCAND]=0;
        	    BREAKPOINT(line,cline,ind,self);
		}
	    }
	}
	fclose(fp);
    }
}




/* Add usernames hook */
void node_add_usernames(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    struct hash_list_s *mylist;

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	mylist = hash_list;
	while (mylist)
	{
	    if (strcmp(mylist->username,"N/A")!=0)
	    {
		bzero(cline,strlen(mylist->username));
		strcpy(cline,line);
		strcat(cline,mylist->username);
		BREAKPOINT(cline,stack,ind,self);
		mylist=mylist->next;
	    }
	    else
	    {
		bzero(cline,strlen(mylist->username));
		strcpy(cline,line);
		BREAKPOINT(cline,stack,ind,self);
		mylist=mylist->next;
	    }
	}
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
	}
	mylist = hash_list;
	while (mylist)
	{
	    if (strcmp(mylist->username,"N/A")!=0)
	    {
		bzero(cline,strlen(mylist->username));
		strcpy(cline,stack);
		strcat(cline,mylist->username);
		BREAKPOINT(line,cline,ind,self);
		mylist=mylist->next;
	    }
	    else 
	    {
		bzero(cline,strlen(mylist->username));
		strcpy(cline,stack);
		BREAKPOINT(line,cline,ind,self);
		mylist=mylist->next;
	    }
	}
    }
}



/* Add passwords hook */
void node_add_passwords(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    struct hash_list_s *mylist;

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	mylist = cracked_list;
	while (mylist)
	{
	    if (!mylist->salt2) {return;}
	    if (strcmp(mylist->salt2,"")!=0)
	    {
		bzero(cline,strlen(mylist->salt2));
		strcpy(cline,line);
		strcat(cline,mylist->salt2);
		BREAKPOINT(cline,stack,ind,self);
		mylist=mylist->next;
	    }
	    else
	    {
		mylist=mylist->next;
	    }
	}
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
	}
	mylist = cracked_list;
	while (mylist)
	{
	    if (!mylist->salt2) {return;}
	    if (strcmp(mylist->salt2,"")!=0)
	    {
		bzero(cline,strlen(mylist->salt2));
		strcpy(cline,stack);
		strcat(cline,mylist->salt2);
		BREAKPOINT(line,cline,ind,self);
		mylist=mylist->next;
	    }
	    else 
	    {
		mylist=mylist->next;
	    }
	}
    }
}





/* Add binstrings hook */
void node_add_binstrings(char *line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];
    char mline[MAXCAND];
    int fd,readb,readw;
    char nextname[1024];
    char buf[4096];

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}

	fd=open(ops[self][ind].params,O_RDONLY|O_LARGEFILE);
	if (fd<0) 
	{
	    sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
	    fd=open(nextname,O_RDONLY|O_LARGEFILE);
	    if (fd<0)
	    {
		hg_elog("Could not open binfile: %s\n",nextname);
		exit(1);
	    }
	}
	
	if (fd<0)
	{
	    hg_elog("Could not open binfile: %s\n",ops[self][ind].params);
	    exit(1);
	}
	
	readb=1;readw=0;
	while (readb>0)
	{
	    readb=read(fd,buf,4096);
	    for (a=0;a<readb;a++) 
	    {
		if ((buf[a]<32)||(buf[a]>126)||(buf[a]=='\n')||(readw==MAXCAND-1))
		{
		    if (readw>3)
		    {
			bzero(cline,strlen(cline));
			strcpy(cline,line);
			strcat(cline,mline);
			BREAKPOINT(cline,stack,ind,self);
			readw=0;
			bzero(mline,MAXCAND);
		    }
		    else
		    {
			readw=0;
		    }
		}
		else 
		{
		    mline[readw]=buf[a];
		    readw++;
		}
	    }
	}
	close(fd);
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[MAXCAND-1]=0;
	    bzero(cline,strlen(cline));
	    strcpy(cline,stack);
	    BREAKPOINT(line,cline,ind,self);
	}

	fd=open(ops[self][ind].params,O_RDONLY|O_LARGEFILE);
	if (fd<0) 
	{
	    sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
	    fd=open(nextname,O_RDONLY|O_LARGEFILE);
	    if (fd<0)
	    {
		hg_elog("Could not open binfile: %s\n",nextname);
		exit(1);
	    }
	}
	
	if (fd<0)
	{
	    hg_elog("Could not open binfile: %s\n",ops[self][ind].params);
	    exit(1);
	}
	
	readb=1;readw=0;
	while (readb>0)
	{
	    readb=read(fd,buf,4096);
	    for (a=0;a<readb;a++) 
	    {
		if ((buf[a]<32)||(buf[a]>126)||(buf[a]=='\n')||(readw==MAXCAND-1))
		{
		    if (readw>3)
		    {
			bzero(cline,strlen(cline));
			strcpy(cline,stack);
			strcat(cline,mline);
			BREAKPOINT(line,cline,ind,self);
			readw=0;
			bzero(mline,MAXCAND);
		    }
		    else
		    {
			readw=0;
		    }
		}
		else 
		{
		    mline[readw]=buf[a];
		    readw++;
		}
	    }
	}
	close(fd);
    }
}




/* Add insertp string hook */
void node_insertp_str(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND*2];
    int len,len1;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    len=strlen(line);
    len1=len;
    if ((strlen(line)+strlen(ops[self][ind].params))>=MAXCAND) return;
    else for (a=0;a<=len1;a++)
    {
	len=strlen(ops[self][ind].params);
	for (b=0;b<a;b++) cline[b]=line[b];
	for (b=0;b<len;b++) cline[b+a]=ops[self][ind].params[b];
	for (b=a;b<len1;b++) cline[len+b]=line[b];
	cline[len+a+b-1]=0;
	BREAKPOINT(cline,stack,ind,self);
    }
}


/* Add insertp numrange hook */
void node_insertp_numrange(char *line, char *stack,int ind,int self)
{
    int a,b,len,len1;
    char cline[MAXCAND];
    char mline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    for (len=ops[self][ind].start;len<=ops[self][ind].end;len++)
    {
	bzero(cline,strlen(cline));
	numtostr(len,0,mline);
	len=strlen(line);
	for (a=0;a<=len;a++)
	{
	    for (b=0;b<a;b++) cline[b]=line[b];
	    len1=strlen(mline);
	    for (b=0;b<len1;b++) cline[b+a]=mline[b];
	    for (b=a;b<len;b++) cline[strlen(mline)+b]=line[b];
	    cline[strlen(mline)+a+b+1]=0;
	    BREAKPOINT(cline,stack,ind,self);
	}
    }
}



/* Add insertp usernames hook */
void node_insertp_usernames(char *line, char *stack,int ind,int self)
{
    int a,b,len,len1;
    char cline[MAXCAND];
    char *mline;
    struct hash_list_s *mylist;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    mylist = hash_list;
    while (mylist)
    {
	bzero(cline,MAXCAND);
	mline = mylist->username;
	len=strlen(line);
	for (a=0;a<=len;a++)
	{
	    for (b=0;b<a;b++) cline[b]=line[b];
	    len1=strlen(mline);
	    for (b=0;b<len1;b++) cline[b+a]=mline[b];
	    for (b=a;b<len;b++) cline[strlen(mline)+b]=line[b];
	    cline[len1+a+b+1]=0;
	    BREAKPOINT(cline,stack,ind,self);
	}
	mylist=mylist->next;
    }
}



/* Add insertp dict hook */
void node_insertp_dict(char *line, char *stack,int ind,int self)
{
    int a,b,len,len1;
    char cline[MAXCAND];
    char mline[MAXCAND];
    char nextname[1024];
    FILE *fp;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    fp=fopen(ops[self][ind].params,"r");
    if (!fp) 
    {
        sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
        fp=fopen(nextname,"r");
        if (!fp)
        {
    	    hg_elog("Could not open dictionary: %s\n",nextname);
	    exit(1);
	}
    }

    if (!fp)
    {
        hg_elog("Could not open dictionary: %s\n",ops[self][ind].params);
        exit(1);
    }


    while (!feof(fp))
    {
	bzero(cline,strlen(cline));
	fgets(mline,MAXCAND/2,fp);
	mline[MAXCAND/2]=0;
	mline[strlen(mline)-1]=0;
	len=strlen(line);
	for (a=0;a<=len;a++)
	{
	    for (b=0;b<a;b++) cline[b]=line[b];
	    len1=strlen(mline);
	    for (b=0;b<len1;b++) cline[b+a]=mline[b];
	    for (b=a;b<len;b++) cline[strlen(mline)+b]=line[b];
	    cline[len1+a+b+1]=0;
	    BREAKPOINT(cline,stack,ind,self);
	}
    }
    fclose(fp);
}


/* Add deletep hook */
void node_deletep(char *line, char *stack,int ind,int self)
{
    int a,b,len;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    bzero(cline,strlen(cline));
    len=strlen(line);
    for (a=0;a<=len;a++)
    {
	for (b=0;b<len;b++) 
	{
	    if (a!=b)
	    {
		if (a>=b) cline[b]=line[b];
		else cline[b-1]=line[b]; 
	    }
	}
	BREAKPOINT(cline,stack,ind,self);
    }
}






/* helper - generate leet combinations */
void leet_permute(char* __restrict s, int num, int end, int ind, parsefn_t nextfn, char *stack,int self)
{
    if (num == end) nextfn(s,stack,ind+1,self);
    else
    {
	// Ordered by the relative frequency in English
	if (s[num]=='e') 
	{
	    s[num]='3';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='e';
	}
	else if (s[num]=='t') 
	{
	    s[num]='7';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='t';
	}
	else if (s[num]=='a') 
	{
	    s[num]='4';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='@';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='a';
	}
	else if (s[num]=='o') 
	{
	    s[num]='0';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='o';
	}
	else if (s[num]=='i') 
	{
	    s[num]='1';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='i';
	}
	else if (s[num]=='s') 
	{
	    s[num]='5';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='$';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='s';
	}
	else if (s[num]=='l') 
	{
	    s[num]='1';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='l';
	}
	else if (s[num]=='A') 
	{
	    s[num]='4';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='@';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='A';
	}
	else if (s[num]=='E') 
	{
	    s[num]='3';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='E';
	}
	else if (s[num]=='O') 
	{
	    s[num]='0';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='O';
	}
	else if (s[num]=='T') 
	{
	    s[num]='7';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='T';
	}
	else if (s[num]=='I') 
	{
	    s[num]='1';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='I';
	}
	else if (s[num]=='L') 
	{
	    s[num]='1';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='L';
	}
	else if (s[num]=='S') 
	{
	    s[num]='5';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='$';
	    leet_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]='A';
	}
	leet_permute(s,num+1,end,ind,nextfn,stack,self);
    }
}


/* helper - generate togglecase combinations */
void togglecase_permute(char *s, int num, int end, int ind, parsefn_t nextfn, char *stack,int self)
{
    if (num == end) nextfn(s,stack, ind+1,self);
    else
    {
	if ((s[num] - 'a') < 26U)
	{
	    s[num]=toupper(s[num]);
	    togglecase_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]=tolower(s[num]);
	}
	else if ((s[num] - 'A') < 26U)
	{
	    s[num]=tolower(s[num]);
	    togglecase_permute(s,num+1,end,ind,nextfn,stack,self);
	    s[num]=toupper(s[num]);
	}
	togglecase_permute(s,num+1,end,ind,nextfn,stack,self);
    }
}



/* Generate Markov candidates */
void node_add_markov(char* line, char* stack,int ind,int self)
{
    FILE *fd;
    char buf[255];
    int cnt1,cnt2;
    char markov_statfile[1024];
    int markov_threshold;
    int markov0[88];
    int markov1[88][88];
    char markov_charset[88]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!{}@#$%^&*()-+[]|\\;':,./";
    int c1,c2,c3,c4,c5,c6,c7,c8;
    char str[MAXCAND];
    int len;
    int start;
    char zelem;


    strcpy(markov_statfile, ops[self][ind].params);
    sprintf(buf,DATADIR"/hashkill/markov/%s.stat",markov_statfile);
    fd = fopen(buf,"r");
    if (!fd)
    {
        sprintf(buf,"%s.stat",markov_statfile);
	fd = fopen(buf,"r");
	if (!fd)
	{
    	    hg_elog("Cannot open Markov statfile: %s\n",buf);
    	    return;
    	}
    }
    fgets(buf, 255, fd);
    buf[strlen(buf)-1] = 0;
    fgets(buf, 255, fd);
    markov_threshold=ops[self][ind].max;
    if (markov_threshold==0) markov_threshold = atoi(buf);
    for (cnt1=0;cnt1<88;cnt1++) fscanf(fd, "%c %d\n", (char *)&c1, &markov0[cnt1]);
    for (cnt1=0;cnt1<88;cnt1++) 
    for (cnt2=0;cnt2<88;cnt2++) 
    {
        fscanf(fd, "%c %c %d\n", (char *)&c1, (char *)&c2, &markov1[cnt1][cnt2]);
    }
    fclose(fd);

    
    if (ops[self][ind].push==0)
    {
	strcpy(str,line);
	len=strlen(str);
	zelem=str[0];
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++)
	switch (start)
	{
	    case 1:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 4:
	 	for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		
		break;
	    case 5:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		for (c7=0;c7<88;c7++) if (markov1[c6][c7]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = markov_charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		for (c7=0;c7<88;c7++) if (markov1[c6][c7]>markov_threshold)
		for (c8=0;c8<88;c8++) if (markov1[c7][c8]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = markov_charset[c7];
    		    str[len+7] = markov_charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    default:
		BREAKPOINT(str,stack,ind,self);
		break;
	}
    }
    else
    {
	strcpy(str,stack);
	len=strlen(str);
	zelem=str[0];
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++)
	switch (start)
	{
	    case 1:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		for (c7=0;c7<88;c7++) if (markov1[c6][c7]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = markov_charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<88;c1++) if (markov0[c1]>markov_threshold)
		for (c2=0;c2<88;c2++) if (markov1[c1][c2]>markov_threshold)
		for (c3=0;c3<88;c3++) if (markov1[c2][c3]>markov_threshold)
		for (c4=0;c4<88;c4++) if (markov1[c3][c4]>markov_threshold)
		for (c5=0;c5<88;c5++) if (markov1[c4][c5]>markov_threshold)
		for (c6=0;c6<88;c6++) if (markov1[c5][c6]>markov_threshold)
		for (c7=0;c7<88;c7++) if (markov1[c6][c7]>markov_threshold)
		for (c8=0;c8<88;c8++) if (markov1[c7][c8]>markov_threshold)
		{
    		    str[0]=zelem;
    		    str[len+0] = markov_charset[c1];
    		    str[len+1] = markov_charset[c2];
    		    str[len+2] = markov_charset[c3];
    		    str[len+3] = markov_charset[c4];
    		    str[len+4] = markov_charset[c5];
    		    str[len+5] = markov_charset[c6];
    		    str[len+6] = markov_charset[c7];
    		    str[len+7] = markov_charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    default:
		BREAKPOINT(line,str,ind,self);
		break;
	}
    }
}



/* Generate combination candidates */
void node_add_cset(char *line, char *stack,int ind,int self)
{
    int c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12;
    char str[MAXCAND];
    int len,len1=0;
    int start;
    char zelem;


    if (ops[self][ind].push==0)
    {
	strcpy(str,line);
	len=strlen(str);
	zelem=str[0];
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++)
	len1=strlen(ops[self][ind].charset);
	switch (start)
	{
	    case 1:
		for (c1=0;c1<len1;c1++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1)
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 9:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 10:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 11:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<len1;c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 12:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<len1;c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		for (c12=0;c12<len1;c12++) 
		if ((c12!=c1)&&(c12!=c2)&&(c12!=c3)&&(c12!=c4)&&(c12!=c5)&&(c12!=c6)&&(c12!=c7)&&(c12!=c8)&&(c12!=c9)&&(c12!=c10)&&(c12!=c11))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = ops[self][ind].charset[c12];
    		    str[len+12] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    default:
		BREAKPOINT(str,stack,ind,self);
		break;
	}
    }
    else
    {
	strcpy(str,stack);
	len=strlen(str);
	zelem=str[0];
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++)
	len1=strlen(ops[self][ind].charset);
	switch (start)
	{
	    case 1:
		for (c1=0;c1<len1;c1++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1)
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 7:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 8:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 9:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 10:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 11:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<len1;c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 12:
		len1=strlen(ops[self][ind].charset); // GCC!!!!
		for (c1=0;c1<len1;c1++) 
		for (c2=0;c2<len1;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<len1;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<len1;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<len1;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<len1;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<len1;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<len1;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<len1;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<len1;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<len1;c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		for (c12=0;c12<len1;c12++) 
		if ((c12!=c1)&&(c12!=c2)&&(c12!=c3)&&(c12!=c4)&&(c12!=c5)&&(c12!=c6)&&(c12!=c7)&&(c12!=c8)&&(c12!=c9)&&(c12!=c10)&&(c12!=c11))
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = ops[self][ind].charset[c12];
    		    str[len+12] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    default:
		BREAKPOINT(line,str,ind,self);
		break;
	}
    }
}




/* Generate permutation candidates */
void node_add_set(char* __restrict line,char *stack,int ind,int self)
{
    int c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12;
    char str[MAXCAND];
    int len;
    int start;
    int cslen = strlen(ops[self][ind].charset);
    char zelem;

    if (ops[self][ind].push==0)
    {
	strcpy(str,line);
	zelem=str[0];
	len=strlen(str);
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++) 
	switch (start)
	{
	    case 1:
		for (c1=0;c1<cslen;c1++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 9:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 10:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 11:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		for (c11=0;c11<cslen;c11++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 12:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		for (c11=0;c11<cslen;c11++) 
		for (c12=0;c12<cslen;c12++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = ops[self][ind].charset[c12];
    		    str[len+12] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    default:
		BREAKPOINT(str,stack,ind,self);
		break;
	}
    }
    else
    {
	strcpy(str,stack);
	len=strlen(str);
	zelem=str[0];
	for (start=ops[self][ind].start;start<=ops[self][ind].end;start++)
	switch (start)
	{
	    case 1:
		for (c1=0;c1<cslen;c1++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 9:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 10:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 11:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		for (c11=0;c11<cslen;c11++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    case 12:
		for (c1=0;c1<cslen;c1++) 
		for (c2=0;c2<cslen;c2++) 
		for (c3=0;c3<cslen;c3++) 
		for (c4=0;c4<cslen;c4++) 
		for (c5=0;c5<cslen;c5++) 
		for (c6=0;c6<cslen;c6++) 
		for (c7=0;c7<cslen;c7++) 
		for (c8=0;c8<cslen;c8++) 
		for (c9=0;c9<cslen;c9++) 
		for (c10=0;c10<cslen;c10++) 
		for (c11=0;c11<cslen;c11++) 
		for (c12=0;c12<cslen;c12++) 
		{
    		    str[0]=zelem;
    		    str[len+0] = ops[self][ind].charset[c1];
    		    str[len+1] = ops[self][ind].charset[c2];
    		    str[len+2] = ops[self][ind].charset[c3];
    		    str[len+3] = ops[self][ind].charset[c4];
    		    str[len+4] = ops[self][ind].charset[c5];
    		    str[len+5] = ops[self][ind].charset[c6];
    		    str[len+6] = ops[self][ind].charset[c7];
    		    str[len+7] = ops[self][ind].charset[c8];
    		    str[len+8] = ops[self][ind].charset[c9];
    		    str[len+9] = ops[self][ind].charset[c10];
    		    str[len+10] = ops[self][ind].charset[c11];
    		    str[len+11] = ops[self][ind].charset[c12];
    		    str[len+12] = 0;
    		    BREAKPOINT(line,str,ind,self);
		}
		break;
	    default:
		BREAKPOINT(line,str,ind,self);
		break;
	}
    }
}




/* Leetify hook */
void node_leetify(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    leet_permute(cline,0,strlen(cline),ind,ops[self][ind+1].parsefn,stack,self);
}


/* upcase hook */
void node_upcase(char *line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    for (a=0;a<strlen(cline);a++) cline[a]=toupper(cline[a]);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}


/* upcaseat hook */
void node_upcaseat(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    cline[ops[self][ind].start]=toupper(cline[ops[self][ind].start]);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}


/* lowcaseat hook */
void node_lowcaseat(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    cline[ops[self][ind].start]=tolower(cline[ops[self][ind].start]);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}




/* Toggle-case hook */
void node_togglecase(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }
    strcpy(cline,line);
    togglecase_permute(cline,0,strlen(line),ind,ops[self][ind+1].parsefn,stack,self);
}



/* lowcase hook */
void node_lowcase(char *line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    for (a=0;a<strlen(cline);a++) cline[a]=tolower(cline[a]);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}



/* Reverse hook */
void node_reverse(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];
    char tmp;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    
    a=0;b=strlen(cline)-1;
    while ((b-a)>1) 
    {
	tmp=cline[a];
	cline[a]=cline[b];
	cline[b]=tmp;
	a++;
	b--;
    }
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}


/* Shuffle2 hook */
void node_shuffle2(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];
    char tmp;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    
    a=0;b=strlen(cline)-1;
    while ((b-a)>0) 
    {
	tmp=cline[a];
	cline[a]=cline[b];
	cline[b]=tmp;
	//ops[self][ind+1].parsefn(cline,stack,ind+1,self);
	BREAKPOINT(cline,stack,ind,self);
	tmp=cline[a];
	cline[a]=cline[b];
	cline[b]=tmp;
	a++;
	b--;
    }
}


/* Rot13 hook */
void node_rot13(char *line, char *stack,int ind,int self)
{
    int b;
    char cline[MAXCAND];
    char a,c,d;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    
    for (b=0;b<strlen(cline);b++) 
    {
	a=cline[b];
	c = a&64&&(d=a&159)&&d<27?((d+12)%26+1)|(a&96):a;
	cline[b]=c;
    }
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}



/* PastTense hook */
void node_pasttense(char *line, char *stack,int ind,int self)
{
    int i,l;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    l=strlen(cline);
    
    if (cline[l-1]=='e')
    {
	cline[l]='d';
	cline[l+1]=0;
    }
    else if (cline[l-1]=='e')
    {
	cline[l]='D';
	cline[l+1]=0;
    }
    else if (cline[l-1]=='y')
    {
	int flag=0;
	for (i=0;i<strlen(vowels);i++) if (vowels[i]==cline[l-2]) {flag=1;break;}
	if (flag==1) {cline[l]='e';cline[l+1]='d';cline[l+2]=0;}
	else {cline[l-1]='i';cline[l]='e';cline[l+1]='d';cline[l+2]=0;}
    }
    else if (cline[l-1]=='Y')
    {
	int flag=0;
	for (i=0;i<strlen(vowels);i++) if (vowels[i]==cline[l-2]) {flag=1;break;}
	if (flag==1) {cline[l]='E';cline[l+1]='D';cline[l+2]=0;}
	else {cline[l-1]='I';cline[l]='E';cline[l+1]='D';cline[l+2]=0;}
    }
    else
    {
	int flag=0,flag1=0,flag2=0,uflag=0;
	for (i=0;i<strlen(cons);i++) if (cons[i]==cline[l-4]) {flag2=1;break;}
	for (i=0;i<strlen(vowels);i++) if (vowels[i]==cline[l-3]) {flag=1;break;}
	for (i=0;i<strlen(cons);i++) if (cons[i]==cline[l-2]) {flag1=1;break;}
	for (i=0;i<strlen(ualpha);i++) if (ualpha[i]==cline[l-1]) {uflag=1;break;}
	if (uflag)
	{
	    if ((flag1==1)&&(flag==1)&&(flag2==1)) {cline[l]=cline[l-1];cline[l+1]='E';cline[l+2]='D';cline[l+3]=0;}
	    else {cline[l]='E';cline[l+1]='D';cline[l+2]=0;}
	}
	else
	{
	    if ((flag1==1)&&(flag==1)&&(flag2==1)) {cline[l]=cline[l-1];cline[l+1]='e';cline[l+2]='d';cline[l+3]=0;}
	    else {cline[l]='e';cline[l+1]='d';cline[l+2]=0;}
	}
    }
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}


/* Present continuous hook */
void node_conttense(char *line, char *stack,int ind,int self)
{
    int i,l;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    cline[0]=0;
    strcpy(cline,line);
    l=strlen(cline);
    
    if ((cline[l-1]=='i')&&(cline[l-1]=='e'))
    {
	cline[l-2]='y';cline[l-1]='i';cline[l]='n';cline[l+1]='g';cline[l+2]=0;
    }
    else if ((cline[l-1]=='I')&&(cline[l-1]=='E'))
    {
	cline[l-2]='Y';cline[l-1]='I';cline[l]='N';cline[l+1]='G';cline[l+2]=0;
    }
    else
    {
	int flag=0,flag1=0,flag2=0,uflag=0;
	for (i=0;i<strlen(vowels);i++) if (vowels[i]==cline[l-3]) {flag2=1;break;}
	for (i=0;i<strlen(cons);i++) if (cons[i]==cline[l-2]) {flag=1;break;}
	if ((cline[l-1]=='e')||(cline[l-1]=='E')) {flag1=1;}
	for (i=0;i<strlen(ualpha);i++) if (ualpha[i]==cline[l-1]) {uflag=1;break;}
	if (uflag)
	{
	    if ((flag1==1)&&(flag==1)&&(flag2==1)) {cline[l-1]='I';cline[l]='N';cline[l+1]='G';cline[l+2]=0;}
	    else {cline[l]='I';cline[l+1]='N';cline[l+2]='G';cline[l+3]=0;}
	}
	else
	{
	    if ((flag1==1)&&(flag==1)&&(flag2==1)) {cline[l-1]='i';cline[l]='n';cline[l+1]='g';cline[l+2]=0;}
	    else {cline[l]='i';cline[l+1]='n';cline[l+2]='g';cline[l+3]=0;}
	}
    }
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}




/* Generate permutations */
void node_permute(char *line, char *stack,int ind,int self)
{
    register int c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12;
    char str[MAXCAND];
    int start=strlen(line);

    if (ops[self][ind].mode==0)
    {
	str[0]=0;
	strcpy(str,line);
        //ops[self][ind+1].parsefn(str,stack,ind+1,self);
        BREAKPOINT(str,stack,ind,self);
    }


    if (ops[self][ind].push==0)
    {
	bzero(str,MAXCAND);
	start=strlen(line);
	switch (start)
	{
	    case 1:
		for (c1=0;c1<start;c1++) 
		{
    		    str[0] = line[c1];
    		    str[1] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 2:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1)
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 3:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 4:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 5:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 6:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 7:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<start;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 8:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<start;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<start;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = line[c8];
    		    str[8] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 9:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<start;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<start;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<start;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = line[c8];
    		    str[8] = line[c9];
    		    str[9] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 10:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<start;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<start;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<start;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<start;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = line[c8];
    		    str[8] = line[c9];
    		    str[9] = line[c10];
    		    str[10] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 11:
		for (c1=0;c1<start;c1++) 
		for (c2=0;c2<start;c2++) 
		if (c2!=c1) 
		for (c3=0;c3<start;c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<start;c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<start;c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<start;c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<start;c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<start;c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<start;c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<start;c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<start;c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = line[c8];
    		    str[8] = line[c9];
    		    str[9] = line[c10];
    		    str[10] = line[c11];
    		    str[11] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    case 12:
		for (c1=0;c1<strlen(ops[self][ind].charset);c1++) 
		for (c2=0;c2<strlen(ops[self][ind].charset);c2++) 
		if (c2!=c1) 
		for (c3=0;c3<strlen(ops[self][ind].charset);c3++) 
		if ((c3!=c1)&&(c3!=c2))
		for (c4=0;c4<strlen(ops[self][ind].charset);c4++) 
		if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
		for (c5=0;c5<strlen(ops[self][ind].charset);c5++) 
		if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
		for (c6=0;c6<strlen(ops[self][ind].charset);c6++) 
		if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
		for (c7=0;c7<strlen(ops[self][ind].charset);c7++) 
		if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
		for (c8=0;c8<strlen(ops[self][ind].charset);c8++) 
		if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
		for (c9=0;c9<strlen(ops[self][ind].charset);c9++) 
		if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
		for (c10=0;c10<strlen(ops[self][ind].charset);c10++) 
		if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
		for (c11=0;c11<strlen(ops[self][ind].charset);c11++) 
		if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
		for (c12=0;c12<strlen(ops[self][ind].charset);c12++) 
		if ((c12!=c1)&&(c12!=c2)&&(c12!=c3)&&(c12!=c4)&&(c12!=c5)&&(c12!=c6)&&(c12!=c7)&&(c12!=c8)&&(c12!=c9)&&(c12!=c10)&&(c12!=c11))		for (c1=0;c1<start;c1++) 
		{
    		    str[0] = line[c1];
    		    str[1] = line[c2];
    		    str[2] = line[c3];
    		    str[3] = line[c4];
    		    str[4] = line[c5];
    		    str[5] = line[c6];
    		    str[6] = line[c7];
    		    str[7] = line[c8];
    		    str[8] = line[c9];
    		    str[9] = line[c10];
    		    str[10] = line[c11];
    		    str[11] = line[c12];
    		    str[12] = 0;
    		    BREAKPOINT(str,stack,ind,self);
		}
		break;
	    default:
		BREAKPOINT(str,stack,ind,self);
		break;
	}
    }
}


/* Truncate hook */
void node_truncate(char *line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }

    a=0;
    while ((a<strlen(line))&&(a<ops[self][ind].start)) 
    {
	cline[a]=line[a];
	a++;
    }
    cline[a]=0;
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}





/* Delete char hook */
void node_delete_char(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }


    cline[0]=0;
    if ((ops[self][ind].end>=0)&&((ops[self][ind].end+ops[self][ind].start)<strlen(line)))
    {
	for (a=0;a<ops[self][ind].end;a++) cline[a]=line[a];
	for (b=a+ops[self][ind].start;b<strlen(line);b++) cline[b-ops[self][ind].start]=line[b];
	cline[b]=0;
    }
    else if ((int)(ops[self][ind].end+strlen(line))>0)
    {
	for (a=0;a<strlen(line)+ops[self][ind].end;a++) cline[a]=line[a];
	for (b=a+ops[self][ind].start;b<strlen(line);b++) cline[b-ops[self][ind].start]=line[b];
	cline[b]=0;
    }
    if (strlen(line)>0) {BREAKPOINT(cline,stack,ind,self);}
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
}


/* Delete match hook */
void node_delete_match(char *line, char *stack,int ind,int self)
{
    int a,b,pos;
    char cline[MAXCAND];
    char *ptr;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
        BREAKPOINT(cline,stack,ind,self);
    }


    cline[0]=0;
    ptr = strstr(line,ops[self][ind].params);
    if ((int)(ptr-line)>0)
    {
	pos=(int)(ptr-line);
	for (a=0;a<pos;a++) cline[a]=line[a];
	for (b=a+strlen(ops[self][ind].params);b<strlen(line);b++) cline[b-strlen(ops[self][ind].params)]=line[b];
    }

    if (strlen(line)>0) {BREAKPOINT(cline,stack,ind,self);}
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
}


/* Delete repeating hook */
void node_delete_repeating(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];
    int a,b;

    if (ops[self][ind].mode==0)
    {
	cline[0]=0;
	strcpy(cline,line);
	BREAKPOINT(cline,stack,ind,self);
        //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    }

    cline[0]=line[0];b=1;
    for (a=1;a<strlen(line);a++)
    {
	if (line[a]!=line[a-1])
	{
	    cline[b]=line[a];
	    b++;
	}
    }
    cline[b]=0;

    BREAKPOINT(cline,stack,ind,self);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
}


/* Remove match hook */
void node_remove_match(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    if (strstr(line,ops[self][ind].params)) return;
    strcpy(cline,line);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}


/* insert str hook */
void node_insert_str(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND*2];

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    if ((ops[self][ind].start)<strlen(line))
    {
	a = ops[self][ind].start;
	for (b=0;b<a;b++) cline[b]=line[b];
	for (b=0;b<strlen(ops[self][ind].params);b++) cline[b+a]=ops[self][ind].params[b];
	for (b=a;b<strlen(line);b++) cline[strlen(ops[self][ind].params)+b]=line[b];
	cline[strlen(ops[self][ind].params)+a+b-1]=0;
	BREAKPOINT(cline,stack,ind,self);
    }
}




/* Insert dict hook */
void node_insert_dict(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];
    char mline[MAXCAND];
    char nextname[1024];
    FILE *fp;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    fp=fopen(ops[self][ind].params,"r");
    if (!fp) 
    {
        sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].params);
        fp=fopen(nextname,"r");
        if (!fp)
        {
    	    hg_elog("Could not open dictionary: %s\n",nextname);
	    exit(1);
	}
    }

    if (!fp)
    {
        hg_elog("Could not open dictionary: %s\n",ops[self][ind].params);
        exit(1);
    }


    while (!feof(fp))
    {
	bzero(cline,strlen(cline));
	fgets(mline,MAXCAND/2,fp);
	mline[MAXCAND/2]=0;
	mline[strlen(mline)-1]=0;
	a = ops[self][ind].start;
	for (b=0;b<a;b++) cline[b]=line[b];
	for (b=0;b<strlen(mline);b++) cline[b+a]=mline[b];
	for (b=a;b<strlen(line);b++) cline[strlen(mline)+b]=line[b];
	cline[strlen(mline)+a+b+1]=0;
	BREAKPOINT(cline,stack,ind,self);
    }
    fclose(fp);
}



/* Insert usernames hook */
void node_insert_usernames(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];
    char mline[MAXCAND];
    struct hash_list_s *mylist;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    mylist = hash_list;
    while (mylist)
    {
	bzero(cline,strlen(cline));
	if (mylist->username)
	{
	    strcpy(mline,mylist->username);
	    a = ops[self][ind].start;
	    for (b=0;b<a;b++) cline[b]=line[b];
	    for (b=0;b<strlen(mline);b++) cline[b+a]=mline[b];
	    for (b=a;b<strlen(line);b++) cline[strlen(mline)+b]=line[b];
	    cline[strlen(mline)+a+b+1]=0;
	    BREAKPOINT(cline,stack,ind,self);
	}
	mylist=mylist->next;
    }
}


/* Insert passwords hook */
void node_insert_passwords(char *line, char *stack,int ind,int self)
{
    int a,b;
    char cline[MAXCAND];
    char mline[MAXCAND];
    struct hash_list_s *mylist;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    
    mylist = cracked_list;
    while (mylist)
    {
	bzero(cline,strlen(cline));
	if (mylist->salt2)
	{
	    strcpy(mline,mylist->salt2);
	    a = ops[self][ind].start;
	    for (b=0;b<a;b++) cline[b]=line[b];
	    for (b=0;b<strlen(mline);b++) cline[b+a]=mline[b];
	    for (b=a;b<strlen(line);b++) cline[strlen(mline)+b]=line[b];
	    cline[strlen(mline)+a+b+1]=0;
	    BREAKPOINT(cline,stack,ind,self);
	}
	mylist=mylist->next;
    }
}




/* Add stack */
void node_pop_add(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND];

    cline[0]=0;
    strcpy(cline,line);
    strcat(cline,stack);
    //ops[self][ind+1].parsefn(cline,stack,ind+1,self);
    BREAKPOINT(cline,stack,ind,self);
}



/* helper - generate tablechar combinations */
void tablechar_permute(char* __restrict s, int num, int end, int ind, char *stack,int self)
{
    int i,j;
    char tmp;
    if (unlikely(num == end)) {BREAKPOINT(s,stack,ind,self);}
    else
    {
	j=0;
	while (tablechar[self][j].active==1)  
	{
	    int len = strlen(tablechar[self][j].outstr);
	    if ((tablechar[self][j].inchar==s[num]))
	    for (i=0;i<len;i++)
	    {
		tmp=s[num];
		s[num]=tablechar[self][j].outstr[i];
		tablechar_permute(s,num+1,end,ind,stack,self);
		s[num]=tmp;
	    }
	    j++;
	}
	tablechar_permute(s,num+1,end,ind,stack,self);
    }
}



/* replace table char hook */
void node_replace_table_char(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND*2];

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }

    strcpy(cline,line);
    tablechar_permute(cline,0,strlen(cline),ind,stack,self);
}



/* replace str hook */
void node_replace_str(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND*2];
    char mline[MAXCAND*2];
    char *saveptr;
    char *pos;

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }
    

    if (strstr(line,ops[self][ind].params))
    {
	cline[0]=0;
	strcpy(mline,line);
    
	pos=strtok_r(mline,ops[self][ind].params,&saveptr);
	if (pos) 
	{
	    if (mline[0]==line[0]) strcpy(cline,pos);
	    else
	    {
		strcpy(cline,ops[self][ind].charset);
		strcat(cline,mline);
	    }
	}
    
	while (pos)
	{
	    pos=strtok_r(NULL,ops[self][ind].params,&saveptr);
	    if (pos) 
	    {
		strcat(cline,ops[self][ind].charset);
		strcat(cline,pos);
	    }
	}
    
	if (line[strlen(line)-1]!=cline[strlen(cline)-1]) 
	{
    	    strcat(cline,ops[self][ind].charset);
	}
	BREAKPOINT(cline,stack,ind,self);
    }
    else
    {
	if (ops[self][ind].mode!=0)
	{
	    strcpy(cline,line);
	    BREAKPOINT(cline,stack,ind,self);
	}
    }
}



/* replace str hook */
void node_replace_dict(char *line, char *stack,int ind,int self)
{
    char cline[MAXCAND*2];
    char mline[MAXCAND*2];
    char rline[MAXCAND*2];
    char nextname[MAXCAND*4];
    char *saveptr;
    char *pos;
    FILE *fp;
    

    if (ops[self][ind].mode==0)
    {
        cline[MAXCAND-1]=0;
        bzero(cline,strlen(cline));
        strcpy(cline,line);
        BREAKPOINT(cline,stack,ind,self);
    }
    

    fp=fopen(ops[self][ind].charset,"r");
    if (!fp) 
    {
        sprintf(nextname,DATADIR"/hashkill/dict/%s",ops[self][ind].charset);
        fp=fopen(nextname,"r");
        if (!fp)
        {
    	    hg_elog("Could not open dictionary: %s\n",nextname);
	    exit(1);
	}
    }

    if (!fp)
    {
        hg_elog("Could not open dictionary: %s\n",ops[self][ind].charset);
        exit(1);
    }

    while (!feof(fp))
    {
	fgets(rline,MAXCAND,fp);
	rline[MAXCAND]=0;
	rline[strlen(rline)-1]=0;

	cline[0]=0;
	strcpy(mline,line);

	pos=strtok_r(mline,ops[self][ind].params,&saveptr);
	if (pos) 
	{
	    if (mline[0]==line[0]) strcpy(cline,pos);
	    else
	    {
		strcpy(cline,rline);
		strcat(cline,mline);
	    }
	}
	
	while (pos)
	{
	    pos=strtok_r(NULL,ops[self][ind].params,&saveptr);
	    if (pos) 
	    {
		strcat(cline,rline);
		strcat(cline,pos);
	    }
	}
    
	if (line[strlen(line)-1]!=cline[strlen(cline)-1]) 
	{
    	    strcat(cline,rline);
	}
	BREAKPOINT(cline,stack,ind,self);

    }
    fclose(fp);
}





/* numrange hook */
void node_add_numrange(char* __restrict  line, char *stack,int ind,int self)
{
    int a;
    char cline[MAXCAND];

    if (ops[self][ind].push==0)
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,line);
    	    BREAKPOINT(cline,stack,ind,self);
	}
	for (a=ops[self][ind].start;a<=ops[self][ind].end;a++)
	{
	    cline[0]=0;
	    strcpy(cline,line);
	    numtostr(a,0,&cline[strlen(line)]);
	    //sprintf(cline,"%s%d",line,a);
	    BREAKPOINT(cline,stack,ind,self);
	}
    }
    else
    {
	if (ops[self][ind].mode==0)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
    	    BREAKPOINT(line,cline,ind,self);
	}
	for (a=ops[self][ind].start;a<=ops[self][ind].end;a++)
	{
	    cline[0]=0;
	    strcpy(cline,stack);
	    numtostr(a,0,&cline[strlen(stack)]);
	    BREAKPOINT(line,cline,ind,self);
	}
    }
}


static void genham_final(int *mask,char *line, char *stack, int ind,int self)
{
    int a,len;
    char candidate[MAXCAND];

    bzero(candidate,MAXCAND);
    len=strlen(line);
    for (a=0;a<len;a++) 
    {
	if (mask[a]==0) candidate[a]=line[a];
	else candidate[a]=mask[a];
    }
    BREAKPOINT(candidate,stack,ind,self);
}

static void genham_recursive(int *mask, int pos,int start, int max,char *line,char *stack, int ind,int self)
{
    int a,b,len;

    len = strlen(ops[self][ind].charset);

    if ((start==0)||(pos==max)) genham_final(mask,line,stack,ind,self);
    else for (a=pos;a<max;a++)
    {
	for (b=0;b<len;b++)
	{
	    mask[a]=ops[self][ind].charset[b];
	    genham_recursive(mask,pos+1,start-1,max,line,stack,ind,self);
	}
	mask[a]=0;
    }
}

/* generate Hamming distance hook */
void node_genham(char *line, char *stack,int ind,int self)
{
    int mask[MAXCAND];
    int a,len;

    len=strlen(line);
    for (a=0;a<MAXCAND;a++) mask[a]=0;
    genham_recursive(mask,0,ops[self][ind].start,len,line,stack,ind,self);
}



static void genlev_final(int *mask,char *line, char *stack, int ind,int self)
{
    int a;
    char candidate[MAXCAND*2];
    int sp=0;
    char next;
    char prev;
    int lp=0;
    int mp=0;
    int cp=0;

    bzero(candidate,MAXCAND);
    next=line[lp];
    prev=line[lp];

    while ((next)||(prev))
    {
	next=line[lp];
	prev=line[lp-1];
	if (mask[mp]==0) 
	{
	    for (a=0;a<sp;a++)
	    {
		candidate[cp]=line[lp];
		cp++;
		mp++;
		lp++;
	    }
	    sp=0;
	    candidate[cp]=line[lp];
	    cp++;
	    lp++;
	    mp++;
	}
	else if (mask[mp]==2000)
	{
	    if (sp>0) sp--;
	    lp++;
	    mp++;
	}
	else if ((mask[mp]>0)&&(mask[mp]<255))
	{
	    for (a=0;a<sp;a++)
	    {
		candidate[cp]=line[lp];
		cp++;
		mp++;
		lp++;
	    }
	    sp=0;
	    candidate[cp]=mask[mp];
	    cp++;
	    mp++;
	    lp++;
	}
	else if ((mask[mp]>1000)&&(mask[mp]<1255))
	{
	    candidate[cp]=mask[mp]-1000;
	    cp++;
	    mp++;
	    sp++;
	}
    }
    for (a=0;a<sp;a++)
    {
	candidate[cp]=line[lp];
	cp++;
	mp++;
	lp++;
    }
    sp=0;
    if (strcmp(line,candidate)!=0) {BREAKPOINT(candidate,stack,ind,self);}
}

static void genlev_recursive(int *mask, int pos,int start, int max,int inserts,char *line,char *stack, int ind,int self)
{
    int a,b,len;

    len = strlen(ops[self][ind].charset);
    if ((start==0)||(pos==max)) genlev_final(mask,line,stack,ind,self);
    else 
    {
	// Substitute
	for (a=pos;a<max;a++)
	{
	    for (b=0;b<len;b++)
	    {
		mask[a]=ops[self][ind].charset[b];
		genlev_recursive(mask,pos+1,start-1,max,inserts,line,stack,ind,self);
	    }
	    mask[a]=0;
	}
	// Delete
	for (a=pos;a<max;a++)
	{
	    mask[a]=2000;
	    genlev_recursive(mask,pos+1,start-1,max,inserts,line,stack,ind,self);
	    mask[a]=0;
	}
	// Insert
	if ((inserts==1)&&(pos>=max)) {}
	else
	for (a=pos;a<=max+inserts;a++)
	{
	    for (b=0;b<len;b++)
	    {
		mask[a]=1000+ops[self][ind].charset[b];
		genlev_recursive(mask,pos+1,start-1,max,inserts+1,line,stack,ind,self);
	    }
	    mask[a]=0;
	}
    }
}

/* generate Levenshtein distance hook */
void node_genlev(char *line, char *stack,int ind,int self)
{
    int mask[MAXCAND*2];
    int a,len;

    len=strlen(line);
    for (a=0;a<MAXCAND*2;a++) mask[a]=0;
    genlev_recursive(mask,0,ops[self][ind].start,len,0,line,stack,ind,self);
}



static void genlevdam_final(int *mask,char *line, char *stack, int ind,int self)
{
    int a;
    char candidate[MAXCAND*2];
    int sp=0;
    char next;
    char prev;
    char swap;
    int lp=0;
    int mp=0;
    int cp=0;

    bzero(candidate,MAXCAND);
    next=line[lp];
    prev=line[lp];

    while ((next)||(prev))
    {
	next=line[lp];
	prev=line[lp-1];
	if (mask[mp]==0) 
	{
	    for (a=0;a<sp;a++)
	    {
		candidate[cp]=line[lp];
		cp++;
		mp++;
		lp++;
	    }
	    sp=0;
	    candidate[cp]=line[lp];
	    cp++;
	    lp++;
	    mp++;
	}
	else if (mask[mp]==2000)
	{
	    if (sp>0) sp--;
	    lp++;
	    mp++;
	}
	else if (mask[mp]==3000)
	{
	    for (a=0;a<sp;a++)
	    {
		candidate[cp]=line[lp];
		cp++;
		mp++;
		lp++;
	    }
	    sp=0;
	    candidate[cp]=line[lp];
	    if (cp!=0)
	    {
		swap=candidate[cp];
		candidate[cp]=candidate[cp-1];
		candidate[cp-1]=swap;
	    }
	    cp++;
	    lp++;
	    mp++;
	}
	else if ((mask[mp]>0)&&(mask[mp]<255))
	{
	    for (a=0;a<sp;a++)
	    {
		candidate[cp]=line[lp];
		cp++;
		mp++;
		lp++;
	    }
	    sp=0;
	    candidate[cp]=mask[mp];
	    cp++;
	    mp++;
	    lp++;
	}
	else if ((mask[mp]>1000)&&(mask[mp]<1255))
	{
	    candidate[cp]=mask[mp]-1000;
	    cp++;
	    mp++;
	    sp++;
	}
    }
    for (a=0;a<sp;a++)
    {
	candidate[cp]=line[lp];
	cp++;
	mp++;
	lp++;
    }
    sp=0;
    if (strcmp(line,candidate)!=0) {BREAKPOINT(candidate,stack,ind,self);}
}

static void genlevdam_recursive(int *mask, int pos,int start, int max,int inserts,char *line,char *stack, int ind,int self)
{
    int a,b,len;

    len = strlen(ops[self][ind].charset);
    if ((start==0)||(pos==max)) genlevdam_final(mask,line,stack,ind,self);
    else 
    {
	// Substitute
	for (a=pos;a<max;a++)
	{
	    for (b=0;b<len;b++)
	    {
		mask[a]=ops[self][ind].charset[b];
		genlevdam_recursive(mask,pos+1,start-1,max,inserts,line,stack,ind,self);
	    }
	    mask[a]=0;
	}
	// Delete
	for (a=pos;a<max;a++)
	{
	    mask[a]=2000;
	    genlevdam_recursive(mask,pos+1,start-1,max,inserts,line,stack,ind,self);
	    mask[a]=0;
	}
	// Permute
	for (a=pos;a<max;a++)
	{
	    if (mask[a-1]!=3000)
	    {
		mask[a]=3000;
		genlevdam_recursive(mask,pos+1,start-1,max,inserts,line,stack,ind,self);
		mask[a]=0;
	    }
	}
	// Insert
	if ((inserts==1)&&(pos>=max)) {}
	else
	for (a=pos;a<=max+inserts;a++)
	{
	    for (b=0;b<len;b++)
	    {
		mask[a]=1000+ops[self][ind].charset[b];
		genlevdam_recursive(mask,pos+1,start-1,max,inserts+1,line,stack,ind,self);
	    }
	    mask[a]=0;
	}
    }
}

/* generate Levenshtein-Damerau distance hook */
void node_genlevdam(char *line, char *stack,int ind,int self)
{
    int mask[MAXCAND*2];
    int a,len;

    len=strlen(line);
    for (a=0;a<MAXCAND*2;a++) mask[a]=0;
    genlevdam_recursive(mask,0,ops[self][ind].start,len,1,line,stack,ind,self);
}




/* print stdout hook */
void node_print_stdout(char *line, char *stack,int ind,int self)
{
    if (attack_over>0) return;
    printf("%s\n",line);
}


/* dequeue hook */
void node_dequeue(char *line, char *stack,int lind,int self)
{
    char *myline, *mystack;
    int ind=2;

    while (attack_over==0)
    {
	while ((attack_over==0)&&(rule_queue[self].pushready==0)) sched_yield();
	if (rule_queue[self].line[0]==1) 
	{
	    char endline[MAX];
	    endline[0]=1;
	    endline[1]=0;
	    ops[self][0].crack_callback(line,self);
	    ops[self][0].crack_callback(endline,self);
	}
	else
	{
	    myline = rule_queue[self].line;
	    mystack = rule_queue[self].stack;
	    BREAKPOINT(myline,mystack,ind,self);
	}
	rule_queue[self].pushready=0;
    }
}



/* dequeue hook */
void node_queue_end(char *line, char *stack,int ind,int self)
{
    char myline[32], mystack[32];
    mystack[0]=0;myline[0]=0;
    if (attack_over==0)
    {
	bzero(mystack,32);
	bzero(myline,32);
	myline[0]=0x01;
	BREAKPOINT(myline,mystack,ind,self);
    }
}



/* count hook */
void node_count(char *line, char *stack,int ind,int self)
{
    attack_overall_count++;
    if (attack_over>0) pthread_exit(NULL);
}



/* queue hook */
void node_queue(char *line, char *stack,int ind,int self)
{
    int flag=0;

    currentqueued++;
    if (session_restore_flag==1)
    {
	if (currentqueued<scheduler.currentqueued) return;
	else scheduler.currentqueued=currentqueued;
    }
    else scheduler.currentqueued=currentqueued;

    while ((flag==0)&&(attack_over==0))
    {
	if (curthread==nwthreads)
	{
	    curthread=0;
	    //sched_yield();
	}
	if (rule_queue[curthread].pushready==0)
	{
	    line[MAXCAND-1]=0;
	    strcpy(rule_queue[curthread].line,line);
	    strcpy(rule_queue[curthread].stack,stack);
	    attack_current_count++;
	    rule_current_elem++;
	    flag=1;
	    rule_queue[curthread].pushready=1;
	}
	curthread++;
    }
}


/* wait until queues are emptied */
void node_wait_queues()
{
    int flag=1;
    int a;

    while ((flag==1)&&(attack_over==0))
    {
	flag=0;
	for (a=0;a<nwthreads;a++) if (rule_queue[a].pushready>0) flag=1;
	usleep(10000);
    }
    for (a=0;a<nwthreads;a++)
    {
	rule_queue[a].line[0]=1;
	rule_queue[a].line[1]=0;
	rule_queue[a].stack[0]=1;
	rule_queue[a].stack[1]=0;
	rule_queue[a].pushready=1;
    }
    flag=1;
    while ((flag==1)&&(attack_over==0))
    {
	flag=0;
	for (a=0;a<nwthreads;a++)
	if (rule_queue[curthread].pushready==1) flag=1;
	usleep(10000);
    }
}


