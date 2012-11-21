/* 
 * hashgen.c
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
#include <stdlib.h>
#include <pthread.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <dirent.h>
#include <pwd.h>
#include <errno.h>
#include "err.h"
#include "hashinterface.h"
#include "hashgen.h"
#include "hashgen-mangle.h"
#include "threads.h"
#ifdef HAVE_CL_CL_H
#include "ocl-threads.h"
#endif

static char *lalpha="abcdefghijklmnopqrstuvwxyz";
static char *num="0123456789";
static char *none="";
static char *ualpha="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char *lalphanum="abcdefghijklmnopqrstuvwxyz0123456789";
static char *ualphanum="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
static char *alpha="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
static char *alphanum="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
static char *ascii="abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()-_=+[]{}|\\\'\";:`~<>,./?";
static char *cons="qQwWrRtTyYpPsSdDfFgGhHjJkKlLzZxXcCvVbBnNmM";
static char *vowels="eEuUiIoOaA";
static char *ucons="QWRTYPSDFGHJKLZXCVBNM";
static char *lcons="qwrtypsdfghjklzxcvbnm";
static char *lvowels="euioa";
static char *uvowels="EUIOA";
static int is_preprocess;
static FILE *prefile;
static char prename[1024];
extern char **environ;
static char currentline[1024];


static char startstring[HASHKILL_MAXTHREADS+3][256];


static void fix_line(char *line)
{
    int a;

    for (a=0;a<strlen(line);a++) 
    {
	if (line[a]==2) line [a]=' ';
    }
}



static void update_currentlinenum(int val,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	currentlinenum[MAXRULES+2]=val;
	return;
    }
    for (a=0;a<=nwthreads;a++) currentlinenum[a]=val;
    currentlinenum[SELF_THREAD]=val;
}

static void update_currentlinenum_plus1()
{
    int a;

    for (a=0;a<=nwthreads;a++) currentlinenum[a]++;
    currentlinenum[SELF_THREAD]++;
}

static void update_currentlinenum_minus1()
{
    int a;

    for (a=0;a<=nwthreads;a++) currentlinenum[a]--;
    currentlinenum[SELF_THREAD]--;
}

static void update_optimize_type(int type,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	rule_optimize[MAXRULES+2].type = type;
	return;
    }
    for (a=0;a<=nwthreads;a++) rule_optimize[a].type = type;
    rule_optimize[SELF_THREAD].type = type;
}

static void update_optimize_statfile(char *statfile,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	strcpy(rule_optimize[MAXRULES+2].statfile,statfile);
	return;
    }
    for (a=0;a<nwthreads;a++) strcpy(rule_optimize[a].statfile,statfile);
    strcpy(rule_optimize[SELF_THREAD].statfile,statfile);
}


static void update_optimize_threshold(int threshold,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	rule_optimize[MAXRULES+2].threshold = threshold;
	return;
    }
    for (a=0;a<nwthreads;a++) rule_optimize[a].threshold = threshold;
    rule_optimize[SELF_THREAD].threshold = threshold;
}


static void update_optimize_start(int start,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	rule_optimize[MAXRULES+2].start = start;
	return;
    }
    for (a=0;a<=nwthreads;a++) rule_optimize[a].start = start;
    rule_optimize[SELF_THREAD].start = start;
}

static void update_optimize_end(int end,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	rule_optimize[MAXRULES+2].end = end;
	return;
    }
    for (a=0;a<=nwthreads;a++) rule_optimize[a].end = end;
    rule_optimize[SELF_THREAD].end = end;
}

static void update_optimize_charset(char *charset,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	strcpy(rule_optimize[MAXRULES+2].charset,charset);
	return;
    }
    for (a=0;a<=nwthreads;a++) strcpy(rule_optimize[a].charset,charset);
    strcpy(rule_optimize[SELF_THREAD].charset,charset);
}





static void update_currentline(char *currentline1)
{
    int a;

    for (a=0;a<=nwthreads;a++) strcpy(currentline,currentline1);
    strcpy(currentline,currentline1);
}



static void update_parsefn(parsefn_t parsefn,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].parsefn=parsefn;
	return;
    }

    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].parsefn=parsefn;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].parsefn=parsefn;
}


static void update_crack_callback(finalfn_t crack_callback,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][0].crack_callback=crack_callback;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][0].crack_callback=crack_callback;
    ops[SELF_THREAD][0].crack_callback=crack_callback;
}


static void update_mode(int modeset,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].mode=modeset;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].mode=modeset;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].mode=modeset;
}

static void update_max(int max,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].max=max;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].max=max;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].max=max;
}

static void update_chainlen(int chainlen,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][0].chainlen=chainlen;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][0].chainlen=chainlen;
    ops[SELF_THREAD][0].chainlen=chainlen;
}



static void update_push(int push,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].push=push;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].push=push;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].push=push;
}

static void update_start(int start,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].start=start;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].start=start;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].start=start;
}


static void update_end(int end,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].end=end;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].end=end;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].end=end;
}


static void update_numth(int numth,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].numth=numth;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].numth=numth;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].numth=numth;
}

static void update_current(int current,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	ops[MAXRULES+2][currentlinenum[MAXRULES+2]].current=current;
	return;
    }
    for (a=0;a<=nwthreads;a++) ops[a][currentlinenum[a]].current=current;
    ops[SELF_THREAD][currentlinenum[SELF_THREAD]].current=current;
}

static void update_charset(char *charset,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	strcpy(ops[MAXRULES+2][currentlinenum[MAXRULES+2]].charset,charset);
	return;
    }
    for (a=0;a<=nwthreads;a++) strcpy(ops[a][currentlinenum[a]].charset,charset);
    strcpy(ops[SELF_THREAD][currentlinenum[SELF_THREAD]].charset,charset);
}


static void update_charset_plus(char *charset,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	strcat(ops[MAXRULES+2][currentlinenum[MAXRULES+2]].charset,charset);
	return;
    }
    for (a=0;a<=nwthreads;a++) strcat(ops[a][currentlinenum[a]].charset,charset);
    strcat(ops[SELF_THREAD][currentlinenum[SELF_THREAD]].charset,charset);
}


static void update_params(char *params,int mode)
{
    int a;

    if (mode==RULE_MODE_STATS) 
    {
	strcpy(ops[MAXRULES+2][currentlinenum[MAXRULES+2]].params,params);
	return;
    }
    for (a=0;a<=nwthreads;a++) strcpy(ops[a][currentlinenum[a]].params,params);
    strcpy(ops[SELF_THREAD][currentlinenum[SELF_THREAD]].params,params);
}



/* Create the preprocessed file */
static int create_preprocess_file()
{
    char fname[255];
    int fd;
    struct stat filest;
    struct passwd *pwd;

    pwd=getpwuid(getuid());
    // make sure ~/.hashkill exists..
    snprintf(fname, 255, "%s/.hashkill", pwd->pw_dir);
    if(stat(fname, &filest) == -1 && errno == ENOENT){
       if(mkdir(fname, S_IRWXU))
       {
           printf("\n");
           elog("Cannot create directory: %s - check permissons!!!\n", fname);
       }
    }

    // make sure ~/.hashkill/rules exists..
    snprintf(fname, 255, "%s/.hashkill/rules", pwd->pw_dir);
    if(stat(fname, &filest) == -1 && errno == ENOENT){
       if(mkdir(fname, S_IRWXU)){
           printf("\n");
           elog("Cannot create directory: %s - check permissons!!!\n", fname);
       }
    }


    snprintf(fname, 255, "%s/.hashkill/rules/%d.tmp", pwd->pw_dir,getpid());
    strcpy(prename,fname);
    fd = open(fname, O_WRONLY | O_NOFOLLOW | O_CREAT | O_TRUNC, 0640);
    prefile = fdopen(fd, "w");
    if (fstat(fd, &filest) != 0) 
    {
        printf("\n");
        elog("Cannot stat session file :%s - probably a symlink attack!!!\n", fname);
        return hash_err;
    }
    if (filest.st_nlink > 1) 
    {
        printf("\n");
        elog("Hardlink attack attempted! File: %s Owner UID: %d! Please remove the hardlink manually!\n", fname, filest.st_uid);
        fclose(prefile);
        return hash_err;
    }
    if (!(prefile))
    {
        printf("\n");
        elog("Cannot open session file %s for writing (%s)!\n", fname, strerror(errno));
        return hash_err;
    }
    
    return 0;
}




static void process_table(char *line, int self)
{
    char *tok1, *tok2;
    int a;
    char line1[MAXCAND*4];
    char *saveptr;

    strcpy(line1,line);
    line1[strlen(line1)-1]=0;
    tok1=strtok_r(line," ",&saveptr);
    tok1=strtok_r(NULL," ",&saveptr);

    if (tok1)
    {
	if (strcmp(tok1,"reset")==0)
	{
	    for (a=0;a<MAXCAND;a++) 
	    {
		tablechar[self][a].inchar=0;
		bzero(tablechar[self][a].outstr,MAXCAND);
		tablechar[self][a].active=0;
	    }
	}
	else 
	{
	    tok2=strtok_r(NULL," ",&saveptr);
	    if (!tok2)
	    {
		hg_elog("Line '%s' : bad table command arguments\n",line1);
	    }
	    else
	    {
		a=0;
		while ((a<MAXCAND*2)&&(tablechar[self][a].active==1)&&(tablechar[self][a].inchar!=tok1[0])) a++;
		if (a<MAXCAND*2) 
		{
		    strcpy(tablechar[self][a].outstr,tok2);
		    tablechar[self][a].inchar=tok1[0];
		    tablechar[self][a].active=1;
		}
	    }
	}
    }
    else
    {
	hg_elog("Line \"%s\": bad parameters!\n",line1);
    }

}



static void prepare_markov_from_cracked()
{
    int markov0[88];
    int markov1[88][88];
    char *charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!{}@#$%^&*()-+[]|\\;':,./";
    char *buffer=alloca(200);
    int a,b,c,d;
    FILE *fd;
    struct hash_list_s *mylist;

    for (a=0;a<88;a++) markov0[a]=0;
    for (a=0;a<88;a++)
    for (b=0;b<88;b++)
    markov1[a][b]=0;

    mylist = cracked_list;
    while (mylist)
    {
	if (mylist->salt2) strncpy(buffer,mylist->salt2,200);
	buffer[200]=0;
	a = 0;
	while ( (a<88) && (charset[a]!=buffer[0])) a++;
	markov0[a]++;
	b = 1;
	c = a;
	do 
	{
    	    a = 0;
    	    while ( (a<88) && (charset[a]!=buffer[b])) a++;
    	    markov1[c][a]++;
    	    c = a;
    	    b++;
	} while (b==strlen(buffer));
	mylist=mylist->next;
    }

    c = 0;
    d = 0;
    for (a=0;a<88;a++)
    for (b=0;b<88;b++)
    {
	c+=markov1[a][b];
	if (markov1[a][b]>d) d = markov1[a][b];
    }

    c = 0;
    d = 0;
    for (a=0;a<88;a++)
    {
	c+=markov0[a];
	if (markov0[a]>d) d = markov0[a];
    }

    fd=fopen("cracked.stat","w");
    fprintf(fd,"%s\n","Markov statfile derived from cracked passwords");
    fprintf(fd,"%d\n",(c/(88*88)));
    for (a=0;a<88;a++) fprintf(fd,"%c %d\n", charset[a], markov0[a]);
    for (a=0;a<88;a++)
    for (b=0;b<88;b++) fprintf(fd,"%c %c %d\n", charset[a], charset[b], markov1[a][b]);
    fclose(fd);

}




static void parse(char *line,int self, int precalc,int mode)
{
    char cline[MAXCAND*8];
    char *tok1, *tok2, *tok3, *tok4, *tok5;
    char *ltok1, *ltok2, *ltok3, *ltok4;
    char *saveptr;

    if (attack_over!=0) return;
    bzero(cline,MAXCAND*8);
    strcpy(cline,line);
    tok1=strtok_r(cline," ",&saveptr);
    update_currentline(line);
    update_optimize_type(optimize_none,mode);
    update_optimize_charset("",mode);
    update_optimize_start(0,mode);
    update_optimize_end(0,mode);

    // Empty line
    if (!tok1)
    {
	return;
    }

    if (strcmp(tok1,"push")==0) 
    {
	update_push(1,mode);
	tok1=strtok_r(NULL," ",&saveptr);
    }
    else update_push(0,mode);

    if (strcmp(tok1,"pop")==0)
    {
	update_parsefn(node_pop_add,mode);
	return;
    }

    
    if (strcmp(tok1,"may")==0) update_mode(0,mode);
    else update_mode(1,mode);

    tok2=strtok_r(NULL," ",&saveptr);
    if (tok2==NULL)
    {
	hg_elog("Error: line: %s not valid!\n",currentline);
	return;
    }
    
    /* We have add keyword? */
    if (strcmp(tok2,"add")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);
	if (!tok3)
	{
	    hg_elog("Error: line: %s not valid!\n",currentline);
	    return;
	}
	/* is cset? */
	if (strcmp(tok3,"cset")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
    		update_start(atoi(ltok1),mode);
    		update_optimize_start(atoi(ltok1),mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		update_end(atoi(ltok2),mode);
    		update_optimize_end(atoi(ltok2),mode);
    		ltok3=strtok_r(NULL,":",&saveptr);
    		if (strcmp(ltok3,"lalpha")==0) update_charset(lalpha,mode);
    		if (strcmp(ltok3,"ualpha")==0) update_charset(ualpha,mode);
    		if (strcmp(ltok3,"alpha")==0) update_charset(alpha,mode);
    		if (strcmp(ltok3,"alphanum")==0) update_charset(alphanum,mode);
    		if (strcmp(ltok3,"lalphanum")==0) update_charset(lalphanum,mode);
    		if (strcmp(ltok3,"ualphanum")==0) update_charset(ualphanum,mode);
    		if (strcmp(ltok3,"num")==0) update_charset(num,mode);
    		if (strcmp(ltok3,"none")==0) update_charset(none,mode);
    		if (strcmp(ltok3,"ascii")==0) update_charset(ascii,mode);
    		if (strcmp(ltok3,"cons")==0) update_charset(cons,mode);
    		if (strcmp(ltok3,"vowels")==0) update_charset(vowels,mode);
    		if (strcmp(ltok3,"lcons")==0) update_charset(lcons,mode);
    		if (strcmp(ltok3,"lvowels")==0) update_charset(lvowels,mode);
    		if (strcmp(ltok3,"ucons")==0) update_charset(ucons,mode);
    		if (strcmp(ltok3,"uvowels")==0) update_charset(uvowels,mode);

    		ltok4=strtok_r(NULL,":",&saveptr);
    		if (ltok4) update_charset_plus(ltok4,mode);
    		update_params(tok4,mode);
    		update_parsefn(node_add_cset,mode);
    		if (currentlinenum[self]>0)
    		{
    		    if (ops[0][currentlinenum[0]].mode==1) update_optimize_type(optimize_add_set,mode);
    		    else update_optimize_type(optimize_may_add_cset,mode);
    		    update_optimize_charset(ops[SELF_THREAD][currentlinenum[SELF_THREAD]].charset,mode);
    		}
    	    }
    	    else
    	    {
    		hg_elog("Line %d (%s): Bad cset!\n",currentlinenum[self], line);
    	    }
	}

	/* is set? */
	else if (strcmp(tok3,"set")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
    		update_start(atoi(ltok1),mode);
    		update_optimize_start(atoi(ltok1),mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		update_end(atoi(ltok2),mode);
    		update_optimize_end(atoi(ltok2),mode);
    		ltok3=strtok_r(NULL,":",&saveptr);
    		if (strcmp(ltok3,"lalpha")==0) update_charset(lalpha,mode);
    		if (strcmp(ltok3,"ualpha")==0) update_charset(ualpha,mode);
    		if (strcmp(ltok3,"alpha")==0) update_charset(alpha,mode);
    		if (strcmp(ltok3,"alphanum")==0) update_charset(alphanum,mode);
    		if (strcmp(ltok3,"lalphanum")==0) update_charset(lalphanum,mode);
    		if (strcmp(ltok3,"ualphanum")==0) update_charset(ualphanum,mode);
    		if (strcmp(ltok3,"num")==0) update_charset(num,mode);
    		if (strcmp(ltok3,"ascii")==0) update_charset(ascii,mode);
    		if (strcmp(ltok3,"cons")==0) update_charset(cons,mode);
    		if (strcmp(ltok3,"vowels")==0) update_charset(vowels,mode);
    		if (strcmp(ltok3,"lcons")==0) update_charset(lcons,mode);
    		if (strcmp(ltok3,"lvowels")==0) update_charset(lvowels,mode);
    		if (strcmp(ltok3,"ucons")==0) update_charset(ucons,mode);
    		if (strcmp(ltok3,"uvowels")==0) update_charset(uvowels,mode);
    		if (strcmp(ltok3,"none")==0) update_charset(none,mode);

    		ltok4=strtok_r(NULL,":",&saveptr);
    		if (ltok4) update_charset_plus(ltok4,mode);
    		update_params(tok4,mode);
    		update_parsefn(node_add_set,mode);
    		if (currentlinenum[self]>0)
    		{
    		    if (ops[0][currentlinenum[0]].mode==1) update_optimize_type(optimize_add_set,mode);
    		    else update_optimize_type(optimize_may_add_set,mode);
    		    update_optimize_charset(ops[SELF_THREAD][currentlinenum[SELF_THREAD]].charset,mode);
    		}
    	    }
	    else
    	    {
    		hg_elog("Line %d (%s): Bad set!\n",currentlinenum[self], currentline);
    	    }
	}
	
	/* is markov? */
	else if (strcmp(tok3,"markov")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
		if (!ltok1)
    		{
    		    hg_elog("Missing markov start! (line:%s) \n",currentline);
    		    exit(1);
    		}
    		update_start(atoi(ltok1),mode);
    		update_optimize_start(atoi(ltok1),mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		if (!ltok2)
    		{
    		    hg_elog("Missing markov max len! (line:%s) \n",currentline);
    		}
    		update_end(atoi(ltok2),mode);
		update_optimize_end(atoi(ltok2),mode);
    		if (ops[0][currentlinenum[0]].start>8) 
    		{
    		    hg_elog("Markov max len cannot exceed 8! (%s)\n",currentline);
    		}
    		ltok3=strtok_r(NULL,":",&saveptr);
    		if (ltok3) 
    		{
    		    update_params(ltok3,mode);
    		    update_optimize_statfile(ltok3,mode);
    		}
		ltok4=strtok_r(NULL,":",&saveptr);
		if (ltok4) 
		{
		    update_optimize_threshold(atoi(ltok4),mode);
		    update_max(atoi(ltok4),mode);
		}
		else update_optimize_threshold(0,mode);
		update_parsefn(node_add_markov,mode);
		if (currentlinenum[self]>0)
    		{
    		    if (ops[0][currentlinenum[0]].mode==1) update_optimize_type(optimize_add_markov,mode);
    		    else update_optimize_type(optimize_may_add_markov,mode);
    		}
    	    }
	}

	/* is numrange? */
	else if (strcmp(tok3,"numrange")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
		if (!ltok1)
    		{
    		    hg_elog("Missing numrange start (line:%s) \n",currentline);
    		}
		update_start(atoi(ltok1),mode);
		update_optimize_start(atoi(ltok1),mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		if (!ltok2)
    		{
    		    hg_elog("Missing numrange end (line:%s) \n",currentline);
    		}
		update_end(atoi(ltok2),mode);
		update_optimize_end(atoi(ltok2),mode);
    		update_parsefn(node_add_numrange,mode);
    		if (currentlinenum[self]>0)
    		{
    		    if (ops[0][currentlinenum[0]].mode==1) update_optimize_type(optimize_add_numrange,mode);
    		    else update_optimize_type(optimize_may_add_numrange,mode);
    		}
    	    }
	}

	/* is dict? */
	else if (strcmp(tok3,"dict")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    update_parsefn(node_add_dict,mode);
	}

	/* is fastdict? */
	else if (strcmp(tok3,"fastdict")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    update_parsefn(node_add_dict,mode);
    	    if (currentlinenum[self]>0)
    	    {
    	        update_optimize_statfile(tok4,mode);
    	        if (ops[0][currentlinenum[0]].mode==1) update_optimize_type(optimize_add_fastdict,mode);
    	        else update_optimize_type(optimize_may_add_fastdict,mode);
    	    }
	}

	/* is phrases? */
	else if (strcmp(tok3,"phrases")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
		if (!ltok1)
    		{
    		    hg_elog("Missing phrase dictionary! (line:%s) \n",currentline);
    		    exit(1);
    		}
    		update_params(ltok1,mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		if (ltok2==NULL) 
    		{
    		    hg_elog("Missing phrase separator! (line:%s) \n",currentline);
    		    exit(1);
    		}
    		else
    		{
    		    if (strcmp(ltok2,"space")==0) update_charset(" ",mode);
    		    else if (strcmp(ltok2,"none")==0) update_charset("",mode);
    		    else update_charset(ltok2,mode);
    		}
    		ltok3=strtok_r(NULL,":",&saveptr);
		if (!ltok3)
    		{
    		    hg_elog("Missing phrase min words! (line:%s) \n",currentline);
    		    exit(1);
    		}
    		update_start(atoi(ltok3),mode);
    		ltok4=strtok_r(NULL,":",&saveptr);
		if (!ltok4)
    		{
    		    hg_elog("Missing phrase max words! (line:%s) \n",currentline);
    		    exit(1);
    		}
    		update_end(atoi(ltok4),mode);
		update_parsefn(node_add_phrases,mode);
    	    }
	}


	/* is pipe? */
	else if (strcmp(tok3,"pipe")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    update_parsefn(node_add_pipe,mode);
    	    rule_stats_available=0;
	}


	/* is usernames? */
	else if (strcmp(tok3,"usernames")==0)
	{
    	    update_parsefn(node_add_usernames,mode);
	}
	
	/* is passwords? */
	else if (strcmp(tok3,"passwords")==0)
	{
    	    update_parsefn(node_add_passwords,mode);
    	    rule_stats_available=0;
	}


	/* is binstrings? */
	else if (strcmp(tok3,"binstrings")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    update_parsefn(node_add_binstrings,mode);
	}

	/* is revstr? */
	else if (strcmp(tok3,"revstr")==0)
	{
    	    update_parsefn(node_add_revstr,mode);
	}

	/* is samestr? */
	else if (strcmp(tok3,"samestr")==0)
	{
    	    update_parsefn(node_add_samestr,mode);
	}

	/* is lastchar? */
	else if (strcmp(tok3,"lastchar")==0)
	{
    	    update_parsefn(node_add_lastchar,mode);
	}

	/* is str? */
	else if (strcmp(tok3,"str")==0)
	{
	    tok4=strtok_r(NULL," ",&saveptr);
	    update_params(tok4,mode);
    	    update_parsefn(node_add_str,mode);
	}

	/* is char? */
	else if (strcmp(tok3,"char")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    update_parsefn(node_add_char,mode);
	}
	else
	{
	    hg_elog("Line '%s': Bad add \n",line);
	    return;
	}
    }

    else if (strcmp(tok2,"delete")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);

	/* is char? */
	if (strcmp(tok3,"char")==0)
	{
	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
    		if (!ltok1) hg_elog("Line %d (%s): Bad arguments!\n",currentlinenum[self], line);
    		update_start(atoi(ltok1),mode);
    		ltok2=strtok_r(NULL,":",&saveptr);
    		if (!ltok2) hg_elog("Line %d (%s): Bad arguments!\n",currentlinenum[self], line);
    		update_end(atoi(ltok2),mode);
    		update_parsefn(node_delete_char,mode);
	    }
	    else
	    {
		hg_elog("Line %d (%s): No arguments!\n",currentlinenum[self], line);
	    }
	}
	/* is match? */
	else if (strcmp(tok3,"match")==0)
	{
	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		update_params(tok4,mode);
    		update_parsefn(node_delete_match,mode);
	    }
	    else
	    {
		hg_elog("Line %d (%s): No arguments!\n",currentlinenum[self], line);
	    }
	}
	/* is repeating? */
	else if (strcmp(tok3,"repeating")==0)
	{
    	    update_parsefn(node_delete_repeating,mode);
	}
	else
	{
	    hg_elog("Line %d (%s): Bad delete line!\n",currentlinenum[self], line);
	}
    }


    /* We have insertp keyword? */
    else if (strcmp(tok2,"insertp")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);

	/* is numrange? */
	if (strcmp(tok3,"numrange")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		ltok1=strtok_r(tok4,":",&saveptr);
		if (!ltok1)
    		{
    		    hg_elog("Missing numrange start (line:%s) \n",currentline);
    		}
		update_start(atoi(ltok1),mode);
    		
    		ltok2=strtok_r(NULL,":",&saveptr);
    		if (!ltok2)
    		{
    		    hg_elog("Missing numrange end (line:%s) \n",currentline);
    		}
		update_end(atoi(ltok2),mode);
    		update_parsefn(node_insertp_numrange,mode);
    	    }
	} 


	/* is dict? */
	else if (strcmp(tok3,"dict")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
	    fix_line(tok4);
    	    update_params(tok4,mode);
    	    update_parsefn(node_insertp_dict,mode);
	} 

	/* is usernames? */
	else if (strcmp(tok3,"usernames")==0)
	{
    	    update_parsefn(node_insertp_usernames,mode);
	}

	/* is str? */
	else if (strcmp(tok3,"str")==0)
	{
	    tok4=strtok_r(NULL," ",&saveptr);
    	    fix_line(tok4);
    	    update_params(tok4,mode);
    	    update_parsefn(node_insertp_str,mode);
	}
	else
	{
	    hg_elog("Line '%s': Bad insertp \n",line);
	    return;
	}
    }


    /* We have insert keyword? */
    else if (strcmp(tok2,"insert")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);

	/* is dict? */
	if (strcmp(tok3,"dict")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    fix_line(tok4);
    	    update_params(tok4,mode);
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		update_start(atoi(tok4),mode);
    	    }
    	    else
    	    {
    		hg_elog("Line '%s': no insert offset \n",line);
    		return;
    	    }
    	    update_parsefn(node_insert_dict,mode);
	} 

	/* is usernames? */
	else if (strcmp(tok3,"usernames")==0)
	{
    	    update_parsefn(node_insert_usernames,mode);
	}

	/* is passwords? */
	else if (strcmp(tok3,"passwords")==0)
	{
    	    update_parsefn(node_insert_passwords,mode);
	}
	/* is str? */
	else if (strcmp(tok3,"str")==0)
	{
	    tok4=strtok_r(NULL," ",&saveptr);
    	    update_params(tok4,mode);
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		update_start(atoi(tok4),mode);
    	    }
    	    else
    	    {
    		hg_elog("Line '%s': no insert offset \n",line);
    		return;
    	    }
    	    update_parsefn(node_insert_str,mode);
	}
	else
	{
	    hg_elog("Line '%s': Bad insertp \n",line);
	    return;
	}
    }



    /* We have remove keyword? */
    else if (strcmp(tok2,"remove")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);

	/* is match? */
	if (strcmp(tok3,"match")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
		update_params(tok4,mode);
    		update_parsefn(node_remove_match,mode);
    	    }
    	    else
	    {
		hg_elog("Line '%s': Bad match \n",line);
		return;
	    }
	} 
    	else
	{
	    hg_elog("Line '%s': Bad remove \n",line);
	    return;
	}
    }

    /* We have replace keyword? */
    else if (strcmp(tok2,"replace")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);

	/* is table? */
	if (strcmp(tok3,"table")==0)
	{
    	    update_parsefn(node_replace_table_char,mode);
	} 

	else if (strcmp(tok3,"str")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		update_params(tok4,mode);
    		tok5=strtok_r(NULL," ",&saveptr);
    		if (tok5)
    		{
    		    update_charset(tok5,mode);
    		    update_parsefn(node_replace_str,mode);
    		}
    		else
    		{
		    hg_elog("Line '%s': Bad replace str parameters \n",line);
		    return;
    		}
    	    }
    	    else
	    {
		hg_elog("Line '%s': Bad replace str parameters \n",line);
		return;
	    }
	} 

	else if (strcmp(tok3,"dict")==0)
	{
    	    tok4=strtok_r(NULL," ",&saveptr);
    	    if (tok4)
    	    {
    		fix_line(tok4);
    		update_params(tok4,mode);
    		tok5=strtok_r(NULL," ",&saveptr);
    		if (tok5)
    		{
    		    update_charset(tok5,mode);
    		    update_parsefn(node_replace_dict,mode);
    		}
    		else
    		{
		    hg_elog("Line '%s': Bad replace dict parameters \n",line);
		    return;
    		}
    	    }
    	    else
	    {
		hg_elog("Line '%s': Bad replace dict parameters \n",line);
		return;
	    }
	} 
    	else
	{
	    hg_elog("Line '%s': Bad replace \n",line);
	    return;
	}
    }


    // deletep
    else if (strcmp(tok2,"deletep")==0)
    {
	update_parsefn(node_deletep,mode);
    }

    // trunc
    else if (strcmp(tok2,"trunc")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);
	if (!tok3)
	{
	    hg_elog("Line '%s': Missing length \n",line);
	    return;
	}
	else
	{
	    update_parsefn(node_truncate,mode);
	    update_start(atoi(tok3),mode);
	}
    }

    // upcaseat
    else if (strcmp(tok2,"upcaseat")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);
	if (!tok3)
	{
	    hg_elog("Line '%s': Missing position \n",line);
	    return;
	}
	else
	{
	    update_parsefn(node_upcaseat,mode);
	    update_start(atoi(tok3),mode);
	}
    }
    // lowcaseat
    else if (strcmp(tok2,"lowcaseat")==0)
    {
	tok3=strtok_r(NULL," ",&saveptr);
	if (!tok3)
	{
	    hg_elog("Line '%s': Missing position \n",line);
	    return;
	}
	else
	{
	    update_parsefn(node_lowcaseat,mode);
	    update_start(atoi(tok3),mode);
	}
    }

    // Leetify
    else if (strcmp(tok2,"leetify")==0)
    {
	update_parsefn(node_leetify,mode);
    }
    // Upcase
    else if (strcmp(tok2,"upcase")==0)
    {
	update_parsefn(node_upcase,mode);
    }
    // Lowcase
    else if (strcmp(tok2,"lowcase")==0)
    {
	update_parsefn(node_lowcase,mode);
    }
    // Togglecase
    else if (strcmp(tok2,"togglecase")==0)
    {
	update_parsefn(node_togglecase,mode);
    }
    // Reverse
    else if (strcmp(tok2,"reverse")==0)
    {
	update_parsefn(node_reverse,mode);
    }
    // Shuffle2
    else if (strcmp(tok2,"shuffle2")==0)
    {
	update_parsefn(node_shuffle2,mode);
    }
    // rot13
    else if (strcmp(tok2,"rot13")==0)
    {
	update_parsefn(node_rot13,mode);
    }
    // past tense
    else if (strcmp(tok2,"pasttense")==0)
    {
	update_parsefn(node_pasttense,mode);
    }
    // continuous tense
    else if (strcmp(tok2,"conttense")==0)
    {
	update_parsefn(node_conttense,mode);
    }
    // permute
    else if (strcmp(tok2,"permute")==0)
    {
	update_parsefn(node_permute,mode);
    }
    // genham
    else if (strcmp(tok2,"genham")==0)
    {
    	tok3=strtok_r(NULL," ",&saveptr);
    	if (!tok3)
    	{
    	    hg_elog("Missing Hamming distance! (line:%s) \n",currentline);
    	    exit(1);
    	}
    	update_start(atoi(tok3),mode);
    	tok4=strtok_r(NULL,":",&saveptr);
    	if (tok4)
    	{
    	    fix_line(tok4);
    	    ltok3=strtok_r(tok4,":",&saveptr);
    	    if (strcmp(ltok3,"lalpha")==0) update_charset(lalpha,mode);
    	    if (strcmp(ltok3,"ualpha")==0) update_charset(ualpha,mode);
    	    if (strcmp(ltok3,"alpha")==0) update_charset(alpha,mode);
    	    if (strcmp(ltok3,"alphanum")==0) update_charset(alphanum,mode);
    	    if (strcmp(ltok3,"lalphanum")==0) update_charset(lalphanum,mode);
    	    if (strcmp(ltok3,"ualphanum")==0) update_charset(ualphanum,mode);
    	    if (strcmp(ltok3,"num")==0) update_charset(num,mode);
    	    if (strcmp(ltok3,"ascii")==0) update_charset(ascii,mode);
    	    if (strcmp(ltok3,"cons")==0) update_charset(cons,mode);
    	    if (strcmp(ltok3,"vowels")==0) update_charset(vowels,mode);
    	    if (strcmp(ltok3,"lcons")==0) update_charset(lcons,mode);
    	    if (strcmp(ltok3,"lvowels")==0) update_charset(lvowels,mode);
    	    if (strcmp(ltok3,"ucons")==0) update_charset(ucons,mode);
    	    if (strcmp(ltok3,"uvowels")==0) update_charset(uvowels,mode);
    	    if (strcmp(ltok3,"none")==0) update_charset(none,mode);

    	    ltok4=strtok_r(NULL,":",&saveptr);
    	    if (ltok4) update_charset_plus(ltok4,mode);
    	}
    	update_parsefn(node_genham,mode);
    }
    // genlev
    else if (strcmp(tok2,"genlev")==0)
    {
    	tok3=strtok_r(NULL,":",&saveptr);
    	if (!tok3)
    	{
    	    hg_elog("Missing Levenshtein distance! (line:%s) \n",currentline);
    	    exit(1);
    	}
    	update_start(atoi(tok3),mode);
    	tok4=strtok_r(NULL,":",&saveptr);
    	if (tok4)
    	{
    	    fix_line(tok4);
    	    ltok3=strtok_r(tok4,":",&saveptr);
    	    if (strcmp(ltok3,"lalpha")==0) update_charset(lalpha,mode);
    	    if (strcmp(ltok3,"ualpha")==0) update_charset(ualpha,mode);
    	    if (strcmp(ltok3,"alpha")==0) update_charset(alpha,mode);
    	    if (strcmp(ltok3,"alphanum")==0) update_charset(alphanum,mode);
    	    if (strcmp(ltok3,"lalphanum")==0) update_charset(lalphanum,mode);
    	    if (strcmp(ltok3,"ualphanum")==0) update_charset(ualphanum,mode);
    	    if (strcmp(ltok3,"num")==0) update_charset(num,mode);
    	    if (strcmp(ltok3,"ascii")==0) update_charset(ascii,mode);
    	    if (strcmp(ltok3,"cons")==0) update_charset(cons,mode);
    	    if (strcmp(ltok3,"vowels")==0) update_charset(vowels,mode);
    	    if (strcmp(ltok3,"lcons")==0) update_charset(lcons,mode);
    	    if (strcmp(ltok3,"lvowels")==0) update_charset(lvowels,mode);
    	    if (strcmp(ltok3,"ucons")==0) update_charset(ucons,mode);
    	    if (strcmp(ltok3,"uvowels")==0) update_charset(uvowels,mode);
    	    if (strcmp(ltok3,"none")==0) update_charset(none,mode);

    	    ltok4=strtok_r(NULL,":",&saveptr);
    	    if (ltok4) update_charset_plus(ltok4,mode);
    	}
    	update_parsefn(node_genlev,mode);
    }
    // genlevdam
    else if (strcmp(tok2,"genlevdam")==0)
    {
    	tok3=strtok_r(NULL,":",&saveptr);
    	if (!tok3)
    	{
    	    hg_elog("Missing Levenshtein-Damerau distance! (line:%s) \n",currentline);
    	    exit(1);
    	}
    	update_start(atoi(tok3),mode);
    	tok4=strtok_r(NULL,":",&saveptr);
    	if (tok4)
    	{
    	    fix_line(tok4);
    	    ltok3=strtok_r(tok4,":",&saveptr);
    	    if (strcmp(ltok3,"lalpha")==0) update_charset(lalpha,mode);
    	    if (strcmp(ltok3,"ualpha")==0) update_charset(ualpha,mode);
    	    if (strcmp(ltok3,"alpha")==0) update_charset(alpha,mode);
    	    if (strcmp(ltok3,"alphanum")==0) update_charset(alphanum,mode);
    	    if (strcmp(ltok3,"lalphanum")==0) update_charset(lalphanum,mode);
    	    if (strcmp(ltok3,"ualphanum")==0) update_charset(ualphanum,mode);
    	    if (strcmp(ltok3,"num")==0) update_charset(num,mode);
    	    if (strcmp(ltok3,"ascii")==0) update_charset(ascii,mode);
    	    if (strcmp(ltok3,"cons")==0) update_charset(cons,mode);
    	    if (strcmp(ltok3,"vowels")==0) update_charset(vowels,mode);
    	    if (strcmp(ltok3,"lcons")==0) update_charset(lcons,mode);
    	    if (strcmp(ltok3,"lvowels")==0) update_charset(lvowels,mode);
    	    if (strcmp(ltok3,"ucons")==0) update_charset(ucons,mode);
    	    if (strcmp(ltok3,"uvowels")==0) update_charset(uvowels,mode);
    	    if (strcmp(ltok3,"none")==0) update_charset(none,mode);

    	    ltok4=strtok_r(NULL,":",&saveptr);
    	    if (ltok4) update_charset_plus(ltok4,mode);
    	}
    	update_parsefn(node_genlevdam,mode);
    }
    // Badline
    else 
    {
	if ((line[0]!='$')&&(line[0]!='#'))hg_elog("Bad line: %s\n",line);
    }
}


/* Add last printf node */
static void finalize(int self)
{
    update_parsefn(node_final,RULE_MODE_PARSE);

    if ((currentlinenum[0]==1)&&(hashgen_stdout_mode==0))
    {
	update_parsefn(node_queue,RULE_MODE_PARSE);
	update_currentlinenum_plus1();
	update_parsefn(node_dequeue,RULE_MODE_PARSE);
	update_currentlinenum_plus1();
    }

    if (currentlinenum[0]!=0) update_chainlen(currentlinenum[0],RULE_MODE_PARSE);
    //update_currentlinenum(0,RULE_MODE_PARSE);
}






static void gen(int self)
{
    char rootnode[MAXCAND];
    char rootstack[MAXCAND];
    bzero(rootnode,MAXCAND);
    bzero(rootstack,MAXCAND);
    strcpy(rootnode,startstring[self]);
    ops[0][0].parsefn(rootnode,rootstack,0,SELF_THREAD);
}

static void gen_stats(int self)
{
    char rootnode[MAXCAND];
    char rootstack[MAXCAND];
    bzero(rootnode,MAXCAND);
    bzero(rootstack,MAXCAND);
    ops[MAXRULES+2][0].parsefn(rootnode,rootstack,0,self);
}


void worker_gen(int self, finalfn_t callback)
{
    char rootnode[MAXCAND];
    char rootstack[MAXCAND];
    bzero(rootnode,MAXCAND);
    bzero(rootstack,MAXCAND);
    while ((ops[self][2].parsefn==NULL)&&(attack_over==0)&&(ops[self][0].chainlen==0)) usleep(10000);
    update_crack_callback(callback,RULE_MODE_PARSE);
    if ((ops[self][2].parsefn)==NULL) return;
    ops[self][2].parsefn(rootnode,rootstack,2,self);
}




void print_callback(char *line, int self)
{
    if (attack_over>0) exit(1);
    if (line[0]>1) printf("%s\n", line);
}


void rule_gen_parse(char *rulefile, finalfn_t callback, int max, int self)
{
    FILE *fp;
    char lineread[MAXCAND*8];
    int rule=0,a;
    char *line, *line1;

    if (session_restore_flag==1)
    {
	rule=scheduler.currentrule;
    }
    else 
    {
	scheduler.currentrule=0;
	rule=0;
    }

    for (a=0;a<nwthreads;a++) rule_queue[a].pushready=2;
    rule_current_elem=0;
    if (hashgen_stdout_mode==1) update_crack_callback(print_callback,RULE_MODE_PARSE);
    else update_crack_callback(callback,RULE_MODE_PARSE);
    update_current(0,RULE_MODE_PARSE);
    update_numth(max,RULE_MODE_PARSE);
    update_currentlinenum(0,RULE_MODE_PARSE);

    fp=fopen(prename,"r");
    if (!fp)
    {
	elog("Could not open rulefile: %s\n",prename);
	exit(1);
    }
    
    while (!feof(fp))
    {
	if (attack_over!=0) return;
	bzero(lineread,MAXCAND*8);
	fgets(lineread,MAXCAND*8-1,fp);
        if (strstr(lineread,"::")) line1 = str_replace(lineread,"::",":\x01:");
        else line1 = lineread;
	if (strstr(line1,": :")) line = str_replace(line1,": :",":\x02:");
        else line = line1;

	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
	if (strlen(line)==0) continue;
	if ((line[0]=='$')) {printf("\n%s\n",&line[1]);continue;}
	if ((line[0]=='#')) {continue;}
	if (strncmp(line,"genmarkov",strlen("genmarkov"))==0) {prepare_markov_from_cracked();continue;}
	if (strncmp(line,"table",strlen("table"))==0) {process_table(line,self);continue;}
	if (strncmp(line,"include",strlen("include"))==0) continue;
	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;

	if (strncmp(line,"begin",5)==0) 
	{
	    //currentqueued=0;
	    update_currentlinenum(0,RULE_MODE_PARSE);
	    update_parsefn(node_print_stdout,RULE_MODE_PARSE);
	    bzero(startstring[self],256);
	}
	else if (strncmp(line,"end",3)==0) 
	{
	    /* Handle the single "add str" case */
	    if ((hashgen_stdout_mode==0)&&(currentlinenum[self]==0)&&(startstring[self][0]!=0))
	    {
		update_parsefn(node_add_str,RULE_MODE_PARSE);
		strcpy(ops[self][0].params,startstring[self]);
		bzero(startstring[self],256);
		update_currentlinenum_plus1();
		update_parsefn(node_queue,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
		update_parsefn(node_dequeue,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
	    }
	    /* No rules at all? */
	    if (currentlinenum[0]==0)
	    {
		update_parsefn(node_queue_end,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
	    }
	    /* This is where we put GPU offload logic */
	    if ((cpuonly == 0)&&(have_ocl == hash_ok))
	    if (hashgen_stdout_mode==0)
	    if (currentlinenum[0]>2)
	    if (rule_optimize[0].type != optimize_none)
	    {
		update_currentlinenum_minus1();
	    }
	    finalize(self);
	    if (rule>=scheduler.currentrule) gen(self);
	    if ((hashgen_stdout_mode==0)&&(attack_over==0))
	    {
		rule_current_elem=0;
		node_wait_queues();
		update_parsefn(node_queue_end,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
		finalize(self);
		gen(self);
		rule_current_elem=0;
		node_wait_queues();
	    }
	}
	else 
	{
	    parse(line,self,0,RULE_MODE_PARSE);
	    /* Handle the bad "add str" ... case */
	    if ((ops[self][currentlinenum[self]].parsefn==node_add_str)&&(currentlinenum[self]==0)&&(hashgen_stdout_mode==0))
	    {
		strcat(startstring[self],ops[self][0].params);
	    }
	    else
	    {
		update_currentlinenum_plus1();
	    }
	    if ((hashgen_stdout_mode==0)&&(currentlinenum[self]==1))
	    {
		update_parsefn(node_queue,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
		update_parsefn(node_dequeue,RULE_MODE_PARSE);
		update_currentlinenum_plus1();
	    }
	}
    }
    fclose(fp);
    if (hashgen_stdout_mode==0) 
    {
	while ((attack_current_count<attack_overall_count)&&(attack_over==0)) usleep(1000);
	node_wait_queues();
    }
    attack_over=2;
}



void * rule_stats_thread(void *arg)
{
    FILE *fp;
    char lineread[MAXCAND*8];
    char *line,*line1;

    ops[MAXRULES+2][currentlinenum[MAXRULES+2]].current=0;
    ops[MAXRULES+2][currentlinenum[MAXRULES+2]].numth=0;
    currentlinenum[MAXRULES+2]=0;

    fp=fopen(prename,"r");
    if (!fp)
    {
	elog("Could not open rulefile: %s\n",prename);
	exit(1);
    }
    bzero(lineread,MAXCAND*8);
    while ((attack_over==0)&&(fgets(lineread,MAXCAND*8-1,fp)))
    {
	if (attack_over!=0) return NULL;
        if (strstr(lineread,"::")) line1 = str_replace(lineread,"::",":\x01:");
        else line1 = lineread;
	if (strstr(line1,": :")) line = str_replace(line1,": :",":\x02:");
        else line = line1;

	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
	if (strlen(line)==0) continue;
	if ((line[0]=='$')) continue;
	if ((line[0]=='#')) continue;
	if (strncmp(line,"genmarkov",strlen("genmarkov"))==0) continue;
	if (strncmp(line,"table",strlen("table"))==0) {process_table(line,MAXRULES+2);continue;}
	if (strncmp(line,"include",strlen("include"))==0) continue;
	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;

	if (strncmp(line,"begin",5)==0) 
	{
	    if (attack_over!=0) return NULL;
	    currentlinenum[MAXRULES+2]=0;
	    ops[MAXRULES+2][currentlinenum[MAXRULES+2]].parsefn=node_count;
	}
	else if (strncmp(line,"end",3)==0) 
	{
	    if (attack_over!=0) return NULL;
	    if (currentlinenum[MAXRULES+2]==0)
	    {
		currentlinenum[MAXRULES+2]=1;
		ops[MAXRULES+2][currentlinenum[MAXRULES+2]].parsefn=node_count;
	    }
	    update_chainlen(2,RULE_MODE_STATS);
	    if (session_restore_flag==0) gen_stats(MAXRULES+2);
	}
	else
	{
	    if (attack_over!=0) return NULL;
	    if (currentlinenum[MAXRULES+2]==0)
	    {
		if (currentlinenum[MAXRULES+2]==0) parse(line,MAXRULES+2,0,RULE_MODE_STATS);
		if (ops[MAXRULES+2][0].parsefn!=node_add_str)
		{
		    currentlinenum[MAXRULES+2]=1;
		    ops[MAXRULES+2][currentlinenum[MAXRULES+2]].parsefn=node_count;
		}
	    }
	}
	bzero(lineread,MAXCAND*8);
    }
    fclose(fp);
    return NULL;
}


void rule_stats_parse()
{
    pthread_t statsthread;

    if (rule_stats_available==1) pthread_create(&statsthread,NULL,rule_stats_thread,NULL);
    else attack_overall_count=1;
}





void replaceopts(char *line)
{
    char line1[MAXCAND*8];
    char repstr[MAXCAND*8];
    char *linerep;
    int a;

    strcpy(line1,line);
    
    a=0;
    while (addopts[a])
    {
	sprintf(repstr,"$%d",a+1);
	linerep = str_replace(line1,repstr,addopts[a]);
	if (linerep) 
	{
	    bzero(line1,MAXCAND*8);
	    strcpy(line1,linerep);
	    free(linerep);
	}
	a++;
    }

    bzero(line,MAXCAND*8);
    strcpy(line,line1);
}




hash_stat rule_preprocess(char *rulename)
{
    FILE *fp,*fp1;
    char line[MAXCAND*8];
    char line1[MAXCAND*8];
    char rulepath[MAXCAND*8];
    int begins;
    int ends;
    char *tok1;
    char *saveptr;

    rules_num=0;
    begins=ends=0;
    is_preprocess=1;
    rule_stats_available=1;

    /* Initial pass - includes */
    if (create_preprocess_file()==hash_err)
    {
	elog("Cannot create temporary preprocessor file%s\n","");
	exit(1);
    }
    fp = fopen(rulename,"r");
    if (!fp)
    {
	sprintf(rulepath,"%s/hashkill/rule/%s",DATADIR,rulename);
	fp = fopen(rulepath,"r");
	if (!fp)
	{
	    hg_elog("Could not open rulefile: %s\n",rulename);
	    return hash_err;
	}
    }
    bzero(line,MAXCAND*8);
    while (fgets(line,MAXCAND*8-1,fp))
    {
	if (strncmp(line,"include",7)==0)
	{
	    if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
	    tok1=strtok_r(line," ",&saveptr);
	    tok1=strtok_r(NULL," ",&saveptr);
	    if (!tok1)
	    {
		hg_elog("No include rule provided: %s\n",line);
		exit(1);
	    }
	    fp1=fopen(tok1,"r");
	    if (!fp1)
	    {
		hg_elog("Cannot open include rule provided: %s\n",tok1);
		exit(1);
	    }
	    while (fgets(line1,MAXCAND*8-1,fp1))
	    {
		if ((line1[0]!=0) && (line1[strlen(line1)-1]=='\n')) line[strlen(line1)-1]=0;
		replaceopts(line1);
		fputs(line1,prefile);
	    }
	    fclose(fp1);
	}
	else if (line[0]!=0) 
	{
	    replaceopts(line);
	    fputs(line,prefile);
	}
	bzero(line,MAXCAND*8);
    }
    fclose(prefile);


    /* Trivial check: begins == ends? */
    fp=fopen(prename,"r");
    if (!fp)
    {
	sprintf(rulepath,"%s/hashkill/rule/%s",DATADIR,rulename);
	fp = fopen(rulepath,"r");
	if (!fp)
	{
	    hg_elog("Could not open rulefile: %s\n",rulename);
	    return hash_err;
	}
    }
    bzero(line,MAXCAND*8);
    while (fgets(line,MAXCAND*8-1,fp))
    {
	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;

	if (strncmp(line,"begin",5)==0) 
	{
	    rules_num++;
	    begins++;
	}
	else if (strncmp(line,"end",3)==0) 
	{
	    rules_num++;
	    ends++;
	}
	bzero(line,MAXCAND*8);
    }
    fclose(fp);
    if (begins != ends)
    {
	hg_elog("The number of begin statements does not match the number of end ones!%s\n","");
	return hash_err;
    }



    fp=fopen(prename,"r");
    if (!fp)
    {
	sprintf(rulepath,"%s/hashkill/rule/%s",DATADIR,rulename);
	fp = fopen(rulepath,"r");
	if (!fp)
	{
	    hg_elog("Could not open rulefile: %s\n",rulename);
	    return hash_err;
	}
    }

    bzero(line,MAXCAND*8);
    while (fgets(line,MAXCAND*8-1,fp))
    {
	if (line[strlen(line)-1]=='\n') 
	if (strlen(line)==0) continue;
	if ((line[0]=='$')) continue;
	if ((line[0]=='#')) continue;
	if (strncmp(line,"begin",5)==0) continue;
	if (strncmp(line,"end",3)==0) continue;
	if (strncmp(line,"genmarkov",8)==0) {rule_stats_available=0;continue;}
	if (strncmp(line,"include",7)==0) continue;
	if (strncmp(line,"table",5)==0) {rule_stats_available=0;process_table(line,63);continue;}
	if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
	parse(line,MAXCAND-1,0,RULE_MODE_PARSE);
	bzero(line,MAXCAND*8);
    }
    fclose(fp);
    rule_current_elem=0;
    rule_overall_elem=0;
    is_preprocess=0;
    return hash_ok;
}
