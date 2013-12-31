/* sessions.c
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
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>
#include <dirent.h>
#include <pwd.h>
#include <openssl/evp.h>
#include <openssl/bio.h>
#include <openssl/buffer.h>
#include "ocl-threads.h"
#include "err.h"
#include "threads.h"
#include "hashinterface.h"
#include "plugins.h"
#include "loadfiles.h"
#include "hashgen.h"
#include "sessions.h"

#ifdef HAVE_JSON_JSON_H
#include <json/json.h>
#endif



/* Function prototypes */
hash_stat session_init_file(FILE **sessionfile);
void session_close_file(FILE *sessionfile);
void session_close_file_ocl(FILE *sessionfile);
void session_unlink_file();
void session_unlink_file_ocl();
hash_stat session_write_hashlist(FILE *sessionfile);
hash_stat session_write_crackedlist(FILE *sessionfile);
hash_stat session_write_bruteforce_parm(int start, int end, char *prefix, char *suffix, char *charset, int curlen, char *curstr, uint64_t progress, FILE *sessionfile);
hash_stat session_write_rule_parm(char *rulename, uint64_t current, uint64_t overall, FILE *sessionfile);
void session_put_commandline(char *argv[]);
hash_stat session_write_parameters(char *plugin, attack_method_t attacktype, uint64_t progress, FILE *sessionfile);
hash_stat print_sessions_summary(void);
hash_stat print_session_detailed(char *sessionname);
hash_stat session_restore(char *sessionname);

#ifdef HAVE_JSON_JSON_H
static json_object *root_node;
static json_object *main_header_node;
static json_object *attack_header_node;
static json_object *hash_list_node;
static json_object *cracked_list_node;
static json_object *scheduler_node;
#endif

extern int b64_pton(char *src,unsigned char *target,size_t targsize);



/* init session file */
hash_stat session_init_file(FILE **sessionfile)
{
#ifdef HAVE_JSON_JSON_H
    char fname[512];
    int fd;
    struct stat filest;
    struct passwd *pwd;

    pwd=getpwuid(getuid());
    // make sure ~/.hashkill exists..
    snprintf(fname, 256, "%s/.hashkill", pwd->pw_dir);
    if(stat(fname, &filest) == -1 && errno == ENOENT){
       if(mkdir(fname, S_IRWXU))
       {
           printf("\n");
           elog("Cannot create directory: %s - check permissons!!!\n", fname);
       }
    }

    // make sure ~/.hashkill/sessions exists..
    snprintf(fname, 255, "%s/.hashkill/sessions", pwd->pw_dir);
    if(stat(fname, &filest) == -1 && errno == ENOENT){
       if(mkdir(fname, S_IRWXU)){
           printf("\n");
           elog("Cannot create directory: %s - check permissons!!!\n", fname);
       }
    }

    snprintf(fname, 255, "%s/.hashkill/sessions/session.tmp", pwd->pw_dir);

    fd = open(fname, O_WRONLY | O_NOFOLLOW | O_CREAT | O_TRUNC, 0640);
    *sessionfile = fdopen(fd, "w");
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
	fclose(*sessionfile);
	return hash_err;
    }
    if (!(*sessionfile))
    {
	printf("\n");
	elog("Cannot open session file %s for writing (%s)!\n", fname, strerror(errno));
	return hash_err;
    }

    root_node = json_object_new_object();
#endif

    return hash_ok;
}



/* close session file */
void session_close_file(FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H
    FILE *sf; // valgrind!
    uid_t uid;
    struct passwd *pwd;
    char fname[512];
    char fname2[512];
    int fd;
    struct stat filest;
    char *jsonbuf;

    sf = sessionfile;
    jsonbuf = malloc(strlen(json_object_to_json_string(root_node))+1);
    strcpy(jsonbuf,json_object_to_json_string(root_node));
    fputs(jsonbuf,sf);
    free(jsonbuf);
    fclose(sf);
    json_object_put(root_node);
    uid = getuid();
    pwd = getpwuid(uid);
    if (!pwd)
    {
	elog("Cannot get username for uid %d (%s)\n", (int)uid, strerror(errno));
	return;
    }
    snprintf(fname, 255, "%s/.hashkill/sessions/session.tmp", pwd->pw_dir);
    snprintf(fname2, 255, "%s/.hashkill/sessions/%d.session", pwd->pw_dir,  getpid());

    fd = open(fname2, O_WRONLY | O_NOFOLLOW | O_CREAT | O_TRUNC, 0640);
    sessionfile = fdopen(fd, "w");
    if (fstat(fd, &filest) != 0) 
    {
	printf("\n");
	elog("Cannot stat session file :%s - probably a symlink attack!!!\n", fname);
	return;
    }
    if (filest.st_nlink > 1) 
    {
	printf("\n");
	elog("Hardlink attack attempted! File: %s Owner UID: %d! Please remove the hardlink manually!\n", fname, filest.st_uid);
	fclose(sessionfile);
	return;
    }
    if (!(sessionfile))
    {
	printf("\n");
	elog("Cannot open session file %s for writing (%s)!\n", fname, strerror(errno));
	return;
    }
    endpwent();
    fclose(sessionfile);
    unlink(fname2);
    rename(fname, fname2);
    unlink(fname);
#endif
}



/* close session file - OpenCL version*/
void session_close_file_ocl(FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H

    FILE *sf; // valgrind!
    uid_t uid;
    struct passwd *pwd;
    char fname[512];
    char fname2[512];
    int fd;
    struct stat filest;
    char *jsonbuf;

    sf = sessionfile;
    jsonbuf = malloc(strlen(json_object_to_json_string(root_node))+1);
    memset(jsonbuf,0,strlen(json_object_to_json_string(root_node))+1);
    strcpy(jsonbuf,json_object_to_json_string(root_node));
    fputs(jsonbuf,sf);
    free(jsonbuf);
    fclose(sf);
    json_object_put(root_node);

    uid = getuid();
    pwd = getpwuid(uid);
    if (!pwd)
    {
	elog("Cannot get username for uid %d (%s)\n", (int)uid, strerror(errno));
	return;
    }
    snprintf(fname, 255, "%s/.hashkill/sessions/session.tmp", pwd->pw_dir);
    snprintf(fname2, 255, "%s/.hashkill/sessions/%d-gpu.session", pwd->pw_dir, getpid());

    fd = open(fname2, O_WRONLY | O_NOFOLLOW | O_CREAT | O_TRUNC, 0640);
    sessionfile = fdopen(fd, "w");
    if (fstat(fd, &filest) != 0) 
    {
	printf("\n");
	elog("Cannot stat session file :%s - probably a symlink attack!!!\n", fname);
	return;
    }
    if (filest.st_nlink > 1) 
    {
	printf("\n");
	elog("Hardlink attack attempted! File: %s Owner UID: %d! Please remove the hardlink manually!\n", fname, filest.st_uid);
	fclose(sessionfile);
	return;
    }
    if (!(sessionfile))
    {
	printf("\n");
	elog("Cannot open session file %s for writing (%s)!\n", fname, strerror(errno));
	return;
    }
    endpwent();
    fclose(sessionfile);
    unlink(fname2);
    rename(fname, fname2);
    unlink(fname);
#endif
}


/* delete session file */
void session_unlink_file()
{
    struct passwd *pwd;
    char fname[255];

    pwd = getpwuid(getuid());
    if (!pwd)
    {
	elog("Cannot get username for uid %d (%s)\n", (int)getuid(), strerror(errno));
    }
    snprintf(fname, 255, "%s/.hashkill/sessions/%d.session", pwd->pw_dir, getpid());

    unlink(fname);
    endpwent();
}


/* delete session file - OpenCL version */
void session_unlink_file_ocl()
{
    struct passwd *pwd;
    char fname[512];

    pwd = getpwuid(getuid());
    if (!pwd)
    {
	elog("Cannot get username for uid %d (%s)\n", (int)getuid(), strerror(errno));
    }
    snprintf(fname, 255, "%s/.hashkill/sessions/%d-gpu.session", pwd->pw_dir, getpid());

    unlink(fname);
    endpwent();
}



/* Write hash list to session file */
hash_stat session_write_hashlist(FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H

    json_object *jobj;
    json_object *jchild;
    struct hash_list_s *mylist;
    char buff[1024];

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);
    if (get_hashes_num()>100000) 
    {
	hash_list_node = json_object_new_array();
	json_object_object_add(root_node,"hashlist", hash_list_node);
	return(hash_ok);
    }

    hash_list_node = json_object_new_array();
    pthread_mutex_lock(&listmutex);
    mylist = hash_list;
    while ((mylist)&&(mylist->username))
    {
	jchild = json_object_new_object();
	jobj = json_object_new_string(mylist->username);
	json_object_object_add(jchild,"username", jobj);
	str2hex(mylist->hash, buff, hash_ret_len);
	jobj = json_object_new_string(buff);
	json_object_object_add(jchild,"hash", jobj);
	jobj = json_object_new_string(mylist->salt);
	json_object_object_add(jchild,"salt", jobj);
	jobj = json_object_new_string(mylist->salt);
	json_object_object_add(jchild,"salt", jobj);
	jobj = json_object_new_string(mylist->salt2);
	json_object_object_add(jchild,"salt2", jobj);
	json_object_array_add(hash_list_node,jchild);
	mylist = mylist->next;
    }
    pthread_mutex_unlock(&listmutex);
    json_object_object_add(root_node,"hashlist", hash_list_node);
#endif
    return hash_ok;
}



/* write cracked list to session file */
hash_stat session_write_crackedlist(FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H
    json_object *jobj;
    json_object *jchild;
    struct hash_list_s *mylist;
    char buff[1024];

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);

    cracked_list_node = json_object_new_array();
    pthread_mutex_lock(&crackedmutex);
    mylist = cracked_list;
    while ((mylist)&&(mylist->username))
    {
	jchild = json_object_new_object();
	if (!jchild) return hash_err;
	jobj = json_object_new_string(mylist->username);
	json_object_object_add(jchild,"username", jobj);
	str2hex(mylist->hash, buff, hash_ret_len);
	jobj = json_object_new_string(buff);
	json_object_object_add(jchild,"hash", jobj);
	jobj = json_object_new_string(mylist->salt);
	json_object_object_add(jchild,"salt", jobj);
	jobj = json_object_new_string(mylist->salt);
	json_object_object_add(jchild,"salt", jobj);
	jobj = json_object_new_string(mylist->salt2);
	json_object_object_add(jchild,"salt2", jobj);
	json_object_array_add(cracked_list_node,jchild);
	mylist = mylist->next;
    }
    pthread_mutex_unlock(&crackedmutex);
    json_object_object_add(root_node,"crackedlist", cracked_list_node);
#endif
    return hash_ok;
}




/* write bruteforce attack parameters to session file */
hash_stat session_write_bruteforce_parm(int start, int end, char *prefix, char *suffix, char *charset, int curlen, char *curstr, uint64_t progress, FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H

    json_object *jobj;
    char ltemp[32];

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);

    attack_header_node = json_object_new_object();
    jobj = json_object_new_int(start);
    json_object_object_add(attack_header_node,"start", jobj);
    jobj = json_object_new_int(end);
    json_object_object_add(attack_header_node,"end", jobj);
    jobj = json_object_new_string(charset);
    json_object_object_add(attack_header_node,"charset", jobj);
    jobj = json_object_new_int(curlen);
    json_object_object_add(attack_header_node,"currentlen", jobj);
    jobj = json_object_new_string(curstr);
    json_object_object_add(attack_header_node,"currentstr", jobj);
    sprintf(ltemp,"%llu",progress);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentelem", jobj);
    sprintf(ltemp,"%llu",attack_overall_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"overallcount", jobj);
    sprintf(ltemp,"%llu",attack_current_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentcount", jobj);
    json_object_object_add(root_node,"bruteforce", attack_header_node);
#endif
    return hash_ok;
}


/* write Markov attack parameters to session file */
hash_stat session_write_markov_parm(char *statfile, int threshold, int len, uint64_t count, uint64_t current_elem, char *current_str, FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H

    json_object *jobj;
    char ltemp[32];

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);

    attack_header_node = json_object_new_object();
    jobj = json_object_new_string(statfile);
    json_object_object_add(attack_header_node,"statfile", jobj);
    jobj = json_object_new_int(threshold);
    json_object_object_add(attack_header_node,"threshold", jobj);
    jobj = json_object_new_int(len);
    json_object_object_add(attack_header_node,"maxlen", jobj);
    sprintf(ltemp,"%llu",count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"maxcount", jobj);
    sprintf(ltemp,"%llu",current_elem);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentelem", jobj);
    jobj = json_object_new_string(current_str);
    json_object_object_add(attack_header_node,"currentstr", jobj);
    sprintf(ltemp,"%llu",attack_overall_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"overallcount", jobj);
    sprintf(ltemp,"%llu",attack_current_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentcount", jobj);
    json_object_object_add(root_node,"markov", attack_header_node);
#endif
    return hash_ok;
}


hash_stat session_write_rule_parm(char *rulename, uint64_t current, uint64_t overall, FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H

    json_object *jobj;
    char ltemp[32];

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);

    attack_header_node = json_object_new_object();
    jobj = json_object_new_string(rulename);
    json_object_object_add(attack_header_node,"rulefile", jobj);
    sprintf(ltemp,"%llu",current);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentelem", jobj);
    sprintf(ltemp,"%llu",overall);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"overall", jobj);
    sprintf(ltemp,"%llu",attack_overall_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"overallcount", jobj);
    sprintf(ltemp,"%llu",attack_current_count);
    jobj = json_object_new_string(ltemp);
    json_object_object_add(attack_header_node,"currentcount", jobj);

    json_object_object_add(root_node,"rule", attack_header_node);
#endif
    return hash_ok;
}



/* Put argv[] to session file */
void session_put_commandline(char *argv[])
{
    return;
}



hash_stat session_write_scheduler_parameters()
{
#ifdef HAVE_JSON_JSON_H

    json_object *jobj;
    json_object *jobjarr, *jobjarr1;
    json_object *jobj1;
    int a,b;

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);
    scheduler_node = json_object_new_object();

    /* startlen */
    jobj = json_object_new_int(scheduler.startlen);
    json_object_object_add(scheduler_node,"startlen", jobj);
    /* len */
    jobj = json_object_new_int(scheduler.len);
    json_object_object_add(scheduler_node,"len", jobj);
    /* maxlen */
    jobj = json_object_new_int(scheduler.maxlen);
    json_object_object_add(scheduler_node,"maxlen", jobj);
    /* charset_size */
    jobj = json_object_new_int(scheduler.charset_size);
    json_object_object_add(scheduler_node,"charset_size", jobj);
    /* charset_size2 */
    jobj = json_object_new_int(scheduler.charset_size2);
    json_object_object_add(scheduler_node,"charset_size2", jobj);
    /* markov_l1 */
    jobj = json_object_new_int(scheduler.markov_l1);
    json_object_object_add(scheduler_node,"markov_l1", jobj);
    /* markov_l2_1 */
    jobj = json_object_new_int(scheduler.markov_l2_1);
    json_object_object_add(scheduler_node,"markov_l2_1", jobj);
    /* markov_l2_2 */
    jobj = json_object_new_int(scheduler.markov_l2_2);
    json_object_object_add(scheduler_node,"markov_l2_2", jobj);
    /* markov_l3_1 */
    jobj = json_object_new_int(scheduler.markov_l3_1);
    json_object_object_add(scheduler_node,"markov_l3_1", jobj);
    /* markov_l3_2 */
    jobj = json_object_new_int(scheduler.markov_l3_2);
    json_object_object_add(scheduler_node,"markov_l3_2", jobj);
    /* markov_l3_3 */
    jobj = json_object_new_int(scheduler.markov_l3_3);
    json_object_object_add(scheduler_node,"markov_l3_3", jobj);
    /* currentqueued */
    jobj = json_object_new_int(scheduler.currentqueued); // for accuracy
    json_object_object_add(scheduler_node,"currentqueued", jobj);
    /* currentrule */
    jobj = json_object_new_int(scheduler.currentrule);
    json_object_object_add(scheduler_node,"currentrule", jobj);
    /* bitmap1 */
    jobj = json_object_new_int(scheduler.bitmap1);
    json_object_object_add(scheduler_node,"bitmap1", jobj);
    /* ebitmap1 */
    jobj = json_object_new_int(scheduler.ebitmap1);
    json_object_object_add(scheduler_node,"ebitmap1", jobj);
    /* bitmap2[] */
    jobjarr = json_object_new_array();
    for (a=0;a<128;a++)
    {
	jobj1 = json_object_new_int(scheduler.bitmap2[a]);
	json_object_array_add(jobjarr,jobj1);

    }
    json_object_object_add(scheduler_node,"bitmap2", jobjarr);
    /* ebitmap2[] */
    jobjarr = json_object_new_array();
    for (a=0;a<128;a++)
    {
	jobj1 = json_object_new_int(scheduler.bitmap2[a]);
	json_object_array_add(jobjarr,jobj1);

    }
    json_object_object_add(scheduler_node,"ebitmap2", jobjarr);
    /* bitmap3[][] */
    jobjarr = json_object_new_array();
    for (a=0;a<128;a++)
    {
	jobjarr1 = json_object_new_array();
	for (b=0;b<128;b++)
	{
	    jobj1 = json_object_new_int(scheduler.bitmap3[a][b]);
	    json_object_array_add(jobjarr1,jobj1);
	}
	json_object_array_add(jobjarr,jobjarr1);

    }
    json_object_object_add(scheduler_node,"bitmap3", jobjarr);
    /* ebitmap3[][] */
    jobjarr = json_object_new_array();
    for (a=0;a<128;a++)
    {
	jobjarr1 = json_object_new_array();
	for (b=0;b<128;b++)
	{
	    jobj1 = json_object_new_int(scheduler.ebitmap3[a][b]);
	    json_object_array_add(jobjarr1,jobj1);
	}
	json_object_array_add(jobjarr,jobjarr1);

    }
    json_object_object_add(scheduler_node,"ebitmap3", jobjarr);
    /* Add to root node */
    json_object_object_add(root_node,"scheduler", scheduler_node);
#endif
    return hash_ok;
}



hash_stat session_load_scheduler_parameters()
{
#ifdef HAVE_JSON_JSON_H
    json_object *jobj;
    json_object *jobjarr, *jobjarr1;
    int a,b;

    scheduler_node = json_object_object_get(root_node,"scheduler");
    scheduler.startlen = json_object_get_int(json_object_object_get(scheduler_node,"startlen"));
    scheduler.len = json_object_get_int(json_object_object_get(scheduler_node,"len"));
    scheduler.currentqueued = json_object_get_int(json_object_object_get(scheduler_node,"currentqueued"));
    scheduler.currentrule = json_object_get_int(json_object_object_get(scheduler_node,"currentrule"));
    scheduler.maxlen = json_object_get_int(json_object_object_get(scheduler_node,"maxlen"));
    scheduler.charset_size = json_object_get_int(json_object_object_get(scheduler_node,"charset_size"));
    scheduler.charset_size2 = json_object_get_int(json_object_object_get(scheduler_node,"charset_size2"));
    scheduler.markov_l1 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l1"));
    scheduler.markov_l2_1 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l2_1"));
    scheduler.markov_l2_2 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l2_2"));
    scheduler.markov_l3_1 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l3_1"));
    scheduler.markov_l3_2 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l3_2"));
    scheduler.markov_l3_3 = json_object_get_int(json_object_object_get(scheduler_node,"markov_l3_3"));
    scheduler.bitmap1 = json_object_get_int(json_object_object_get(scheduler_node,"bitmap1"));
    scheduler.ebitmap1 = json_object_get_int(json_object_object_get(scheduler_node,"ebitmap1"));

    jobjarr = json_object_object_get(scheduler_node,"bitmap2");
    for (a=0;a<128;a++)
    {
	jobj = json_object_array_get_idx(jobjarr, a);
	if (jobj) scheduler.bitmap2[a] = json_object_get_int(jobj);
    }
    jobjarr = json_object_object_get(scheduler_node,"ebitmap2");
    for (a=0;a<128;a++)
    {
	jobj = json_object_array_get_idx(jobjarr, a);
	if (jobj) scheduler.ebitmap2[a] = json_object_get_int(jobj);
    }

    jobjarr = json_object_object_get(scheduler_node,"bitmap3");
    for (a=0;a<128;a++)
    {
	jobjarr1 = json_object_array_get_idx(jobjarr, a);
	for (b=0;b<128;b++)
	{
	    jobj = json_object_array_get_idx(jobjarr1, b);
	    if (jobj) scheduler.bitmap3[a][b] = json_object_get_int(jobj);
	}
    }
    jobjarr = json_object_object_get(scheduler_node,"ebitmap3");
    for (a=0;a<128;a++)
    {
	jobjarr1 = json_object_array_get_idx(jobjarr, a);
	for (b=0;b<128;b++)
	{
	    jobj = json_object_array_get_idx(jobjarr1, b);
	    if (jobj) scheduler.ebitmap3[a][b] = json_object_get_int(jobj);
	}
    }
#endif
    return hash_ok;
}



/* Put general attack parameters to session file */
hash_stat session_write_parameters(char *plugin, attack_method_t attacktype, uint64_t progress, FILE *sessionfile)
{
#ifdef HAVE_JSON_JSON_H
    time_t myclock;
    json_object *jobj;
    char buf[4096*2];
    int cnt;
    char *space=" ";
    struct tm *lotime;

    if (get_cracked_num()==get_hashes_num()) return(hash_ok);
    main_header_node = json_object_new_object();
    cnt=0;
    memset(buf,0,4096);
    while ((session_argv[cnt])&&(cnt<MAXARGV-1)) 
    {
	strcat(buf,session_argv[cnt]);
	strcat(buf,space);
	cnt++;
    }

    jobj = json_object_new_string(buf);
    json_object_object_add(main_header_node,"commandline", jobj);
    jobj = json_object_new_string(plugin);
    json_object_object_add(main_header_node,"plugin", jobj);
    jobj = json_object_new_string(additional_options);
    json_object_object_add(main_header_node,"addopts", jobj);
    jobj = json_object_new_string(padditional_options);
    json_object_object_add(main_header_node,"paddopts", jobj);
    jobj = json_object_new_int((int)progress);
    json_object_object_add(main_header_node,"progress", jobj);
    jobj = json_object_new_int(attack_method);
    json_object_object_add(main_header_node,"attacktype", jobj);
    jobj = json_object_new_int(ocl_gpu_platform);
    json_object_object_add(main_header_node,"gpuplatform", jobj);
    jobj = json_object_new_int(hash_crack_speed);
    json_object_object_add(main_header_node,"attackspeed", jobj);
    myclock=time(NULL);
    if (myclock == ((time_t) -1)) return hash_err;
    lotime = localtime(&myclock);
    if (!lotime) return hash_err;
    jobj = json_object_new_string(asctime(lotime));
    json_object_object_add(main_header_node,"timestamp", jobj);
    jobj = json_object_new_string(getcwd((char *)&buf, 4095));
    json_object_object_add(main_header_node,"workdir", jobj);
    jobj = json_object_new_int(hash_ret_len);
    json_object_object_add(main_header_node,"hashlen", jobj);
    jobj = json_object_new_string(hashlist_file);
    json_object_object_add(main_header_node,"hashlistfile", jobj);
    if (out_cracked_file) jobj = json_object_new_string(out_cracked_file);
    else jobj = json_object_new_string("");
    json_object_object_add(main_header_node,"outcrackedfile", jobj);
    if (out_uncracked_file) jobj = json_object_new_string(out_uncracked_file);
    jobj = json_object_new_string("");
    json_object_object_add(main_header_node,"outuncrackedfile", jobj);
    json_object_object_add(root_node,"main", main_header_node);
    session_write_scheduler_parameters();
#endif
    return hash_ok;
}



/* Print to stdout sessions summary */
hash_stat print_sessions_summary(void)
{
#ifdef HAVE_JSON_JSON_H

    DIR *dir;
    FILE *sesfile;
    struct passwd *pwd;
    struct dirent *dentry;
    char sesname[1024];
    int progress;
    char plugin[256];
    char gmtime[256];
    char shortsesname[256];
    int cnt=0;
    
    char sessiondir[255];
    pwd = getpwuid(getuid());
    snprintf(sessiondir, 255, "%s/.hashkill/sessions", pwd->pw_dir);
    
    dir=opendir(sessiondir);
    if (!dir)
    {
        elog("Cannot open sessions dir: %s", sessiondir);
        return hash_err;
    }
    hlog("Sessions list: %s\n\n","");
    printf("Session name: \t\tSession ends at: \t\tSession type: \tProgress: \tPlugin: \n"
	    "-----------------------------------------------------------------------------------------------\n");
    do
    {
        errno = 0;
        if ((dentry = readdir(dir)) != NULL)
        {
            if ((dentry->d_type == DT_REG) && (strstr(dentry->d_name, ".session")))
            {
                pwd = getpwuid(getuid());
                snprintf(sesname,1024,"%s/%s", sessiondir, dentry->d_name);
                /* Parse the <session>..</session> info */
                sesfile = fopen(sesname, "r");
                if (!sesfile)
                {
            	    goto next;
            	}
            	fclose(sesfile);
            	root_node = json_object_from_file(sesname);
            	if (!root_node) goto next;
		main_header_node = json_object_object_get(root_node,"main");
		attack_method=json_object_get_int(json_object_object_get(main_header_node,"attacktype"));
		strcpy(plugin,json_object_get_string(json_object_object_get(main_header_node,"plugin")));
		progress = json_object_get_int(json_object_object_get(main_header_node,"progress"));
		strcpy(gmtime,json_object_get_string(json_object_object_get(main_header_node,"timestamp")));
		gmtime[strlen(gmtime)-1] = 0;
        	cnt = 0;
        	while (dentry->d_name[cnt] != '.')
        	{
        	    shortsesname[cnt] = dentry->d_name[cnt];
        	    cnt++;
        	}
        	shortsesname[cnt] = 0;
		/* Print out details */
		printf("\033[1;33m%s\033[1;0m              \t",shortsesname);
		printf("%s \t",gmtime);
		switch (attack_method)
		{
		    case attack_method_simple_bruteforce: printf("Bruteforce \t");break;
		    case attack_method_markov: printf("Markov \t\t");break;
		    case attack_method_rule: printf("Rule-based \t");break;
		    default: printf("Unknown \t");break;
                }
                if (progress > 100) printf("Unknown \t");
                else printf("%d%% \t\t",progress);
                printf("%s ",plugin);
                printf("\n");

                next:
    		usleep(10);
            }
        }
    } while (dentry != NULL);
    closedir(dir);
    printf("\n");
    return hash_ok;
#else
    wlog("This build does not support sessions. Please reconfigure with --with-json and rebuild%s\n","");
    return hash_err;
#endif
}



/* Print to stdout detailed session summary */
hash_stat print_session_detailed(char *sessionname)
{
#ifdef HAVE_JSON_JSON_H
    FILE *sesfile;
    struct passwd *pwd;
    char sesname[1024];
    int cnt=0;
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char rawhash[HASHFILE_MAX_LINE_LENGTH];
    char rawhash2[HASHFILE_MAX_LINE_LENGTH*2];
    char plugin_used[HASHFILE_MAX_LINE_LENGTH*2];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    int flag = 0;
    json_object *jobj;
    
    printf("\nDetailed information about session: %s\n"
	    "-----------------------------------------------\n",sessionname);
    pwd = getpwuid(getuid());
    snprintf(sesname, 1024, "%s/.hashkill/sessions/%s.session", pwd->pw_dir, sessionname);
    /* Parse the <session>..</session> info */
    sesfile = fopen(sesname, "r");
    if (!sesfile)
    {
        elog("Cannot open session file : %s\n",sesname);
        return hash_err;
    }
    printf("Session file: \t%s\n",sesname);

    fclose(sesfile);
    root_node = json_object_from_file(sesname);
    main_header_node = json_object_object_get(root_node,"main");
    switch (json_object_get_int(json_object_object_get(main_header_node,"attacktype")))
    {
	case attack_method_simple_bruteforce:
	    printf("Attack type: \tBruteforce\n");
	    break;
	case attack_method_markov:
	    printf("Attack type: \tMarkov\n");
	    break;
	case attack_method_rule:
	    printf("Attack type: \tRule-based\n");
	    break;
	default:
	    printf("Attack type: \tUNKNOWN!\n");
	    break;
    }
    attack_method=json_object_get_int(json_object_object_get(main_header_node,"attacktype"));
    printf("Plugin: \t%s\n",json_object_get_string(json_object_object_get(main_header_node,"plugin")));
    printf("Progress: \t%d%%\n",json_object_get_int(json_object_object_get(main_header_node,"progress")));
    printf("Session ends: \t%s",json_object_get_string(json_object_object_get(main_header_node,"timestamp")));
    printf("Hashlist file: \t%s\n",json_object_get_string(json_object_object_get(main_header_node,"hashlistfile")));
    printf("Command line: \t%s\n",json_object_get_string(json_object_object_get(main_header_node,"commandline")));

    switch (attack_method)
    {
	case attack_method_simple_bruteforce:
	    attack_header_node = json_object_object_get(root_node,"bruteforce");
	    printf("\nBruteforce attack parameters:\n"
	             "-----------------------------\n");
	    printf("Start length: \t%d\n",json_object_get_int(json_object_object_get(attack_header_node,"start")));
	    printf("End length: \t%d\n",json_object_get_int(json_object_object_get(attack_header_node,"end")));
	    printf("Charset: \t%s\n",json_object_get_string(json_object_object_get(attack_header_node,"charset")));
	    printf("Current str: \t%s\n",json_object_get_string(json_object_object_get(attack_header_node,"currentstr")));
	break;
	case attack_method_markov:
	    attack_header_node = json_object_object_get(root_node,"markov");
	    printf("\nMarkov attack parameters:\n"
	             "-------------------------\n");
	    printf("Statfile: \t%s\n",json_object_get_string(json_object_object_get(attack_header_node,"statfile")));
	    printf("Threshold: \t%d\n",json_object_get_int(json_object_object_get(attack_header_node,"threshold")));
	    printf("End length: \t%d\n",json_object_get_int(json_object_object_get(attack_header_node,"maxlen")));
	    printf("Current str: \t%s\n",json_object_get_string(json_object_object_get(attack_header_node,"currentstr")));
	break;
	case attack_method_rule:
	    attack_header_node = json_object_object_get(root_node,"rule");
	    printf("\nRule attack parameters:\n"
	             "-----------------------\n");
	    printf("Rule file: \t%s\n",json_object_get_string(json_object_object_get(attack_header_node,"rulefile")));
	break;

    }
    printf("\nHashes list (username:hash:salt):\n---------------------------------\n");
    hash_list_node = json_object_object_get(root_node,"hashlist");
    flag = json_object_array_length(hash_list_node);
    for (cnt=0;cnt<flag;cnt++)
    {
	jobj = json_object_array_get_idx(hash_list_node, cnt);
	strcpy(username, json_object_get_string(json_object_object_get(jobj,"username")));
	strcpy(hash, json_object_get_string(json_object_object_get(jobj,"hash")));
	strcpy(salt, json_object_get_string(json_object_object_get(jobj,"salt")));
	// This is idiotic I know
	if ((strncmp(plugin_used,"md5unix",8)==0) || (strncmp(plugin_used,"sha512unix",10)==0) ||(strncmp(plugin_used,"phpbb3",6)==0) || (strncmp(plugin_used,"wordpress",9)==0) || (strncmp(plugin_used,"apr1",4)==0))
	{
	    b64_pton(hash,(unsigned char *)rawhash,512);
	    printf("%s:%s%s\n", username, salt, rawhash);
	}
	else if (  (strncmp(plugin_used,"desunix",7)==0)
		 || (strncmp(plugin_used,"ldap-sha",8)==0) || (strncmp(plugin_used,"ldap-ssha",9)==0))
	{
	    b64_pton(hash,(unsigned char *)rawhash,512);
	    printf("%s:%s:%s\n", username, rawhash, salt);
	}
	else
	{
	    str2hex(rawhash,rawhash2, (strlen(hash)*100)/147);
	    printf("%s:%s:%s\n", username, rawhash2, salt);
	}
    }
    cracked_list_node = json_object_object_get(root_node,"crackedlist");
    if (cracked_list_node)
    {
	cnt = json_object_array_length(cracked_list_node);
    }
    else
    {
	cnt=0;
    }
    printf("\n%d passwords cracked.\n",cnt);
    printf("\n");
    hlog("Session %s dumped successfully\n\n", sessionname);
    return hash_ok;
#else
    wlog("This build does not support sessions. Please reconfigure with --with-json and rebuild%s\n","");
    return hash_err;
#endif
}



/*
    Restore a session
    Threads must be setup and spawned manually after that
*/
hash_stat session_restore(char *sessionname)
{
#ifdef HAVE_JSON_JSON_H

    FILE *sesfile;
    char sesname[1024];
    char readline[512];
    char username[HASHFILE_MAX_LINE_LENGTH];
    char hash[HASHFILE_MAX_LINE_LENGTH];
    char salt[HASHFILE_MAX_LINE_LENGTH];
    char salt2[HASHFILE_MAX_LINE_LENGTH];
    uid_t uid;
    struct passwd *pwd;
    char fname[255];
    int flag = 0;
    int cnt;
    json_object *jobj;

    pwd = getpwuid(getuid());
    snprintf(sesname,1024,"%s/.hashkill/sessions/%s.session", pwd->pw_dir, sessionname);

    /* Parse the <session>..</session> info */
    sesfile = fopen(sesname, "r");
    if (!sesfile)
    {
        elog("Cannot open session file : %s\n",sesname);
        return hash_err;
    }
    hlog("Restoring session from: %s\n",sesname);
    fclose(sesfile);
    
    root_node = json_object_from_file(sesname);
    main_header_node = json_object_object_get(root_node,"main");
    set_current_plugin(json_object_get_string(json_object_object_get(main_header_node,"plugin")));
    if (load_plugin() == hash_err) exit(EXIT_FAILURE);
    attack_method  = json_object_get_int(json_object_object_get(main_header_node,"attacktype"));

    free(padditional_options);
    padditional_options = malloc(strlen(json_object_get_string(json_object_object_get(main_header_node,"paddopts")))+1);
    strcpy(padditional_options,json_object_get_string(json_object_object_get(main_header_node,"paddopts")));
    process_addopts((char*)json_object_get_string(json_object_object_get(main_header_node,"paddopts")));

    free(additional_options);
    padditional_options = malloc(strlen(json_object_get_string(json_object_object_get(main_header_node,"addopts")))+1);
    strcpy(padditional_options,json_object_get_string(json_object_object_get(main_header_node,"addopts")));

    out_cracked_file=malloc(strlen(json_object_get_string(json_object_object_get(main_header_node,"outcrackedfile")))+1);
    out_uncracked_file=malloc(strlen(json_object_get_string(json_object_object_get(main_header_node,"outuncrackedfile")))+1);

    if (strlen(json_object_get_string(json_object_object_get(main_header_node,"outcrackedfile")))>1) strcpy(out_cracked_file,json_object_get_string(json_object_object_get(main_header_node,"outcrackedfile")));
    else
    {
	free(out_cracked_file);
	out_cracked_file=NULL;
    }
    if (strlen(json_object_get_string(json_object_object_get(main_header_node,"outuncrackedfile")))>1) strcpy(out_uncracked_file,json_object_get_string(json_object_object_get(main_header_node,"outuncrackedfile")));
    else
    {
	free(out_uncracked_file);
	out_uncracked_file=NULL;
    }
    
    strcpy(readline,json_object_get_string(json_object_object_get(main_header_node,"workdir")));
    if (chdir(readline) != 0)
    {
	elog("Cannot set working directory to %s\n",readline);
	return hash_err;
    }
    else
    {
	hlog("Change to working directory: %s\n",readline);
    }
    hash_ret_len = json_object_get_int(json_object_object_get(main_header_node,"hashlen"));
    ocl_gpu_platform = json_object_get_int(json_object_object_get(main_header_node,"gpuplatform"));
    strcpy(hashlist_file, json_object_get_string(json_object_object_get(main_header_node,"hashlistfile")));
    if (hash_plugin_is_special()) load_hashes_file(hashlist_file);
    switch (json_object_get_int(json_object_object_get(main_header_node,"attacktype")))
    {
	case attack_method_simple_bruteforce:
	    attack_header_node = json_object_object_get(root_node,"bruteforce");
	    bruteforce_start=json_object_get_int(json_object_object_get(attack_header_node,"start"));
	    bruteforce_end=json_object_get_int(json_object_object_get(attack_header_node,"end"));
	    strcpy(bruteforce_charset, json_object_get_string(json_object_object_get(attack_header_node,"charset")));
	    attack_current_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"currentcount")));
	    attack_overall_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"overallcount")));
	    break;

	case attack_method_markov:
	    attack_header_node = json_object_object_get(root_node,"markov");
	    strcpy(markov_statfile,json_object_get_string(json_object_object_get(attack_header_node,"statfile")));
	    markov_threshold = json_object_get_int(json_object_object_get(attack_header_node,"threshold"));
	    markov_max_len = json_object_get_int(json_object_object_get(attack_header_node,"maxlen"));
	    attack_current_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"currentcount")));
	    attack_overall_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"overallcount")));
	    break;

	case attack_method_rule:
	    attack_header_node = json_object_object_get(root_node,"rule");
	    rule_file=malloc(strlen(json_object_get_string(json_object_object_get(attack_header_node,"rulefile")))+1);
	    strcpy(rule_file,json_object_get_string(json_object_object_get(attack_header_node,"rulefile")));
	    rule_current_elem = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"currentelem")));
	    rule_overall_elem = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"overall")));
	    attack_current_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"currentcount")));
	    attack_overall_count = (uint64_t)atoll(json_object_get_string(json_object_object_get(attack_header_node,"overallcount")));
	    
	    break;

	default:
	    elog("Unknown attack type%s!\n","");
	    return hash_err;
	    break;
    }

    if (hash_plugin_is_special() == 0)
    {
	hash_list_node = json_object_object_get(root_node,"hashlist");
	flag = json_object_array_length(hash_list_node);
	for (cnt=0;cnt<flag;cnt++)
	{
	    jobj = json_object_array_get_idx(hash_list_node, cnt);
	    strcpy(username, json_object_get_string(json_object_object_get(jobj,"username")));
	    strcpy(readline, json_object_get_string(json_object_object_get(jobj,"hash")));
	    hex2str(hash, readline, hash_ret_len*2);
	    strcpy(salt, json_object_get_string(json_object_object_get(jobj,"salt")));
	    if (add_hash_list(username, hash, salt, "") == hash_err) 
	    {
		wlog("Wrong session file hashlist (corrupted session file?)%s\n","");
		exit(EXIT_FAILURE);
	    }
	}
	if (flag<1) load_hashes_file(hashlist_file);
	cracked_list_node = json_object_object_get(root_node,"crackedlist");
	if (cracked_list_node) flag = json_object_array_length(cracked_list_node);
	if (cracked_list_node) 
	for (cnt=0;cnt<flag;cnt++)
	{
	    jobj = json_object_array_get_idx(cracked_list_node, cnt);

	    strcpy(username, json_object_get_string(json_object_object_get(jobj,"username")));
	    strcpy(readline, json_object_get_string(json_object_object_get(jobj,"hash")));
	    hex2str(hash,readline,hash_ret_len*2);
	    strcpy(salt, json_object_get_string(json_object_object_get(jobj,"salt")));
	    if (add_hash_list(username, hash, salt, "") == hash_err) 
	    {
		wlog("Wrong session file hashlist (corrupted session file?)%s\n","");
		exit(EXIT_FAILURE);
	    }
	    strcpy(readline, json_object_get_string(json_object_object_get(jobj,"salt2")));
	    strcpy(salt2, readline);
	    if (add_cracked_list(username, hash, salt, salt2) == hash_err) 
	    {
		wlog("Wrong session file hashlist (corrupted session file?)%s\n","");
		exit(EXIT_FAILURE);
	    }
	}
    }


    cpuonly=1;
    if (strstr(sessionname, "-gpu"))
    {
	cpuonly=0;
        /* rename session */
        uid = getuid();
        if (!pwd)
        {
            elog("Cannot get username for uid %d (%s)\n", (int)uid, strerror(errno));
            return hash_err;
        }

        snprintf(fname, 255, "%s/.hashkill/sessions/%s.session", pwd->pw_dir, sessionname);
        unlink(fname);
        hlog("Session %s will be renamed to %d-gpu\n", sessionname, getpid());
        session_restore_flag = 1;
        endpwent();
        /* Load scheduler data */
	session_load_scheduler_parameters();
        return hash_ok;
    }

    /* Load scheduler data */
    session_load_scheduler_parameters();


    /* rename session */
    uid = getuid();
    pwd = getpwuid(uid);
    if (!pwd)
    {
        elog("Cannot get username for uid %d (%s)\n", (int)uid, strerror(errno));
        return hash_err;
    }
    snprintf(fname, 255, "%s/.hashkill/sessions/%s.session", pwd->pw_dir, sessionname);
    unlink(fname);
    hlog("Session %s will be renamed to %d\n", sessionname,  getpid());
    session_restore_flag = 1;
    endpwent();
    return hash_ok;
#else
    wlog("This build does not support sessions. Please reconfigure with --with-json and rebuild%s\n","");
    return hash_err;
#endif

}






