/* main.c
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


#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>
#include <signal.h>
#include <openssl/pem.h>
#include <alloca.h>
#include "loadfiles.h"
#include "hashinterface.h"
#include "plugins.h"
#include "threads.h"
#include "sessions.h"
#include "hashgen.h"
#include "cpu-feat.h"
#include "ocl-threads.h"
#include "ocl-base.h"
#include "cpu-twofish.h"


/* Function prototypes */
static void usage(const char *progname);
static char* strupr(char* ioString);
static hash_stat parse_bruteforce_args(char *bruteargs);
static time_t time1,time2;
int main(int argc, char *argv[]);



/* Display program usage */
static void usage(const char *progname)
{
    printf("\nUsage: %s [options]\n",progname);
    printf("\nOptions:\n-------------\n");
    printf("-P<plugin>, --plugin-info[=..] \t  Show plugins summary or detailed plugin information if <plugin> is provided\n");
    printf("-p <plugin>, --plugin          \t  Use plugin (default plugin is 'md5')\n");
    printf("-S<session>, --session-info[=..]  Display sessions summary/detailed info on <session>\n");
    printf("-s <session>, --session        \t  Load <session> (you may list sessions using -S)\n");
    printf("-f <hashfile>, --hashfile     \t  Load hashes from file \'hashfile\'\n");
    printf("-b<ruleset>, --brute[=...]    \t  Enables bruteforce mode, load ruleset  \'ruleset\' (default: \'1:8:lalphanum\')\n");
    printf("-o <filename>, --outfile     \t  Write cracked hashes to <filename> upon completion\n");
    printf("-O <filename>, --uncrackedfile \t  Write uncracked hashes to <filename> upon completion\n");
    printf("-M, --markov-info[=...]      \t  Show available Markov stats files summary\n");
    printf("-m <statfile>, --markov    \t  Enable Markov attack, use <statfile>\n");
    printf("-n <threshold>,--markov-threshold Set Markov attack threshold\n");
    printf("-N <limit>, --markov-limit \t  Set Markov attack password length limit (<=10, default 8)\n");
    printf("-c, --cpu \t\t\t  Use CPU even if GPU acceleration is enabled\n");
    printf("-F, --fast-markov \t\t  Faster markov attack (when using GPU)\n");
    printf("-G, --gpu-threads \t\t  Number of GPU threads (up to 4). Increases load/memory utilization, but may improve speeds.\n");
    printf("-C, --cpu-threads \t\t  Number of CPU worker threads.\n");
    printf("-D, --gpu-double \t\t  GPU 2x mode. Better speeds, but less scallable. \n");
    printf("-T, --gpu-temp \t\t\t  GPU temperature threshold (default:90 deg celsius). \n");
    printf("-t, --gpu-platform \t\t  OpenCL platform (default:0). \n");
    printf("-i, --interactive-mode \t\t  Interactive mode (reduce flicker and tearing). \n");
    printf("-a, --add-opts \t\t\t  Additional options (for rule-based attacks). \n");


    printf("\nRuleset format: \'start_len:end_len:predefined_set:additional_args\'\n\n");
    printf("start_len:  \t  generated plaintexts are equal in length or longer than that value\n"
	   "end_len:  \t  generated plaintexts are equal in length or shorter than that value\n"
	   "predefined_set:   one of \'alpha\', \'ualpha\', \'lalpha\', \'lalphanum\', \'ualphanum\', \'alphanum\', \'ascii\', \'none\'\n"
	   "additional_args:  additional characters, e.g \'+()\'\n\n"
	   "Example:\n\n -t hello -b1:2:lalpha:* - try all permutations of length 1-2, comprised of lower alphabetical chars and \'*\'\n");
    printf("\n");
}



/* Uppercase a string */
static char* strupr(char* ioString)
{
    int i;
    int theLength = (int)strlen(ioString);

    for(i=0; i<theLength; ++i) {ioString[i] = toupper(ioString[i]);}
    return ioString;
}


/* Parse brute-force arguments */
static hash_stat parse_bruteforce_args(char *bruteargs)
{
    char *arg1, *arg2, *arg3, *arg4, *argtmp;
    int tmp1=0, tmp2=0, counter, counter2, flag = 0;
    char *hexcharset="0123456789abcdef";
    
    bzero(bruteforce_charset,255);
    arg3 = malloc(128);

    arg1 = strtok(bruteargs, ":");
    
    if (arg1) tmp1 = atoi(arg1);
    arg2 = strtok(NULL, ":");
    if (arg2) tmp2 = atoi(arg2);
    argtmp = strtok(NULL,":");
    bzero(arg3,128); // Make valgrind happy
    if (argtmp) 
    {
	strcpy(bruteforce_set1,argtmp);
	strcpy(arg3, strupr(argtmp));
    }

    arg4 = strtok(NULL,":");
    if (arg4)
    {
	strcpy(bruteforce_set2,arg4);
    }

    if ((tmp2 == 0))
    {
	elog("Bad bruteforce parameters (end=%d)!\n",tmp1);
	if (arg3) free(arg3);
	return hash_err;
    }
    if (tmp1>tmp2)
    {
	elog("Bad bruteforce parameters, start>end (start=end=%d)!\n",tmp1);
	if (arg3) free(arg3);
	return hash_err;
    }
    else
    {
	bruteforce_start = tmp1;
	bruteforce_end = tmp2;
    }
    
    
    if (strcmp(arg3,"LALPHA") == 0)
    {
	strcpy(arg3,"abcdefghijklmnopqrstuvwxyz");
    }
    else if (strcmp(arg3,"UALPHA") == 0)
    {
	strcpy(arg3,"ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }
    else if (strcmp(arg3,"ALPHA") == 0)
    {
	strcpy(arg3,"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }
    else if (strcmp(arg3,"NUM") == 0)
    {
	strcpy(arg3,"0123456789");
    }
    else if (strcmp(arg3,"LALPHANUM") == 0)
    {
	strcpy(arg3,"abcdefghijklmnopqrstuvwxyz0123456789");
    }
    else if (strcmp(arg3,"UALPHANUM") == 0)
    {
	strcpy(arg3,"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
    }
    else if (strcmp(arg3,"ALPHANUM") == 0)
    {
	strcpy(arg3,"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }
    else if (strcmp(arg3,"ASCII") == 0)
    {
	strcpy(arg3,"abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()-_=+[]{}|\\\'\";:`~<>,./?");
    }
    else bzero(arg3,10);
    
    
    if (arg4) for (counter = 0; counter < (int)strlen(arg4); counter++)
    {
	flag = 0;
	for (counter2 = 0; counter2 < (int)strlen(arg3); counter2++) 
	{
	    if (*(arg3+counter2) == *(arg4+counter)) flag = 1;
	}
	
	/* Handle the hex-charset case */
	if ((*(arg4+counter)=='0') && (*(arg4+counter+1)=='x'))
	{
	    char fp,sp,val,tmp1=0,tmp2=0;
	    int cnt;
	    fp = *(arg4+counter+2);
	    sp = *(arg4+counter+3);
	    for (cnt=0;cnt<16;cnt++) if (hexcharset[cnt] == fp) tmp1 = cnt;
	    for (cnt=0;cnt<16;cnt++) if (hexcharset[cnt] == sp) tmp2 = cnt;
	    val = 0;
	    val |= (tmp1 << 4);
	    val |= tmp2;
	    strncat(arg3, &val, 1);
	    flag=1;
	    counter+=3;
	}
	
	if (flag ==0) 
	{
	    strncat(arg3, (arg4+counter), 1);
	    strcat(arg3,"");
	}
    }
    
    
    if (strlen(arg3)==0)
    {
	elog("Empty bruteforce charset!\n%s","");
	if (arg3) free(arg3);
	return hash_err;
    }
    else
    {
	strcpy(bruteforce_charset, arg3);
    }
    if (arg3) free(arg3);
    
    return hash_ok;

}



/* SIGINT/SIGTERM handler */
void sigint_handler(int val)
{
    printf("\n");
    wlog("Interrupted by user request!%s","");
    printf("\n");
    attack_over = 2;
    ctrl_c_pressed=1;
}


static void detect_pipe()
{
    if (!isatty(fileno(stdin)))
    {
	wlog("Please do not pipe to hashkill's stdin, use the 'add pipe' rule instead!\n\n%s","");
	//exit(1);
    }
}


static hash_stat check_out_file(char *filename)
{
    FILE *outfile;

    outfile = fopen(filename, "w");
    if (!outfile)
    {
        hlog("Cannot write to output hashes list file: %s\n",filename);
        return hash_err;
    }
    return hash_ok;
}


/* Program entrypoint */
int main(int argc, char *argv[])
{
    unsigned long tempqueuesize=0;
    char *fvalue = NULL;
    char *dvalue = NULL;
    int option,option_index;
    int pflag=0, bflag = 0, rflag=0;
    int cpu_thread_factor=0;
    int cnt;
    int hash_num_threads=0;
    struct option long_options[] = 
    {
	{"plugin-info", 2, 0, 'P'},
	{"plugin", 1, 0, 'p'},
	{"session-info", 2, 0, 'S'},
	{"session", 1, 0, 's'},
	{"hashlist", 1, 0, 'f'},
	{"brute", 2, 0, 'b'},
	{"outfile", 1, 0, 'o'},
	{"uncrackedfile", 1, 0, 'O'},
	{"markov-info", 0, 0, 'M'},
	{"markov", 1, 0, 'm'},
	{"markov-threshold", 1, 0, 'n'},
	{"markov-limit", 1, 0, 'N'},
	{"rule", 1, 0, 'r'},
	{"rule-print", 1, 0, 'R'},
	{"help", 0, 0, 'h'},
	{"cpu", 0, 0, 'c'},
	{"fast-markov",0,0,'F'},
	{"gpu-threads", 1, 0, 'G'},
	{"cpu-threads", 1, 0, 'C'},
	{"gpu-double", 0, 0, 'D'},
	{"gpu-temp", 0, 0, 'T'},
	{"gpu-platform", 0, 0, 't'},
	{"add-opts", 0, 0, 'a'},
	{"plugin-opts", 0, 0, 'A'},
	{0, 0, 0, 0}
    };


    /* initialize */
    printf("\n");
    hlog("Version %s\n", PACKAGE_VERSION);
    session_restore_flag = 0;
    hash_plugin_parse_hash = NULL;
    hash_plugin_check_hash = NULL;
    hash_list = NULL;
    cracked_list = NULL;
    attack_method = -1;
    markov_attack_init();
    attack_method = attack_method_markov;
    OpenSSL_add_all_algorithms();
    fast_markov = 0;
    cpuonly=0;
    hashgen_stdout_mode=0; 
    cnt=0;
    out_cracked_file=NULL;
    out_uncracked_file=NULL;
    markovstat = NULL;
    attack_checkpoints=0;
    attack_avgspeed=0;
    additional_options=malloc(1);
    additional_options[0]=0;
    padditional_options=malloc(1);
    padditional_options[0]=0;


    /* Detect CPU features and setup optimized routines */
    if (cpu_feat_setup() == hash_err)
    {
        elog("No x86 CPU found! %s\n","");
        exit(1);
    }

    while ((argv[cnt])&&(cnt<MAXARGV))
    {
	session_argv[cnt]=malloc(strlen(argv[cnt])+1);
	strcpy(session_argv[cnt],argv[cnt]);
	cnt++;
    }
    have_ocl=0;
    nwthreads=0;

    /* Init scheduler */
    scheduler_init();
    ocl_user_threads=0;
    ocl_gpu_double=0;
    ocl_gpu_tempthreshold=90;
    ocl_gpu_platform=100;
    interactive_mode=0;

    /* Set AMD OpenCL secret envvars */
    //setenv("GPU_MAX_ALLOC_PERCENT","100",1);
    //setenv("GPU_USE_SYNC_OBJECTS","1",1);
    // Bug in AMD Catalyst 13.4
    setenv("GPU_FLUSH_ON_EXECUTION","1",1);

    /* See if someone tried to pipe to stdin */
    detect_pipe();
    disable_term_linebuffer();

#ifndef HAVE_JSON_JSON_H
    wlog("This hashkill build has session save/restore support disabled. Please reconfigure with --with-json and rebuild\n%s","");
#endif

    /* now store the command line parameters to be used by sessions module */
    attack_over = 0;
    ctrl_c_pressed=0;
    session_put_commandline(argv);

    /* install SIGINT handler */
    signal(SIGINT, sigint_handler);
    signal(SIGTERM, sigint_handler);

    opterr = 0;
    while ((option = getopt_long(argc, argv, "p:f:d:P::b::t:T:S::s:o:O:N:n:M::m:hicFDG:C:a:T:r:RA:",long_options, &option_index)) != -1)
    switch (option)
    {
	case 'r':
	    if (optarg) 
	    {
		hlog("Rule based attack, using rule:%s\n",optarg);
		attack_method = attack_method_rule;
		rflag=1;
		rule_file=alloca(1024);
		strcpy(rule_file,optarg);
	    }
	    else
	    {
		usage(argv[0]);
		exit(EXIT_FAILURE);
	    }
    	    rflag = 1;
	    break;

	case 'R':
	    hashgen_stdout_mode=1;
	    break;


	case 'h':
	    usage(argv[0]);
	    exit(EXIT_SUCCESS);
	    break;
	case 'G':
	    ocl_user_threads = atoi(optarg);
	    if (ocl_user_threads>8) ocl_user_threads = 0;
	    break;
	case 'C':
	    cpu_thread_factor = atoi(optarg);
	    if ((cpu_thread_factor>256)||(cpu_thread_factor<1)) cpu_thread_factor=16;
	    break;

	case 's':
	    if (!optarg) {
		usage(argv[0]);
		exit(EXIT_FAILURE);
	    }
	    else {
		if (session_restore(optarg) == hash_err) exit(EXIT_FAILURE);
		pflag = 1;
	    }
	break;


	case 'P':
	    if (!optarg) (void)print_plugins_summary(DATADIR"/hashkill/plugins");
	    else print_plugin_detailed(optarg);
    	    exit(EXIT_SUCCESS);
	break;

	case 'a':
	    free(padditional_options);
	    padditional_options = malloc(strlen(optarg)+1);
	    strcpy(padditional_options,optarg);
	    process_addopts(optarg);
	break;

	case 'A':
	    free(additional_options);
	    additional_options = malloc(strlen(optarg)+1);
	    strcpy(additional_options,optarg);
	break;

	case 'c':
	    cpuonly = 1;
	break;

	case 'i':
	    hlog("interactive mode turned on!%s\n","");
	    interactive_mode = 1;
	break;

	case 'F':
	    fast_markov = 1;
	break;
	case 'T':
	    ocl_gpu_tempthreshold=atoi(optarg);
	break;
	case 'b':
	    if (optarg) 
	    {
		if (parse_bruteforce_args(optarg) == hash_err)
		{
		    exit(EXIT_FAILURE);
		}
	    }
	    else
	    {
		char *tempopt = NULL;
		tempopt = malloc(100);
		strcpy(tempopt,"1:8:lalphanum:");
		if (parse_bruteforce_args(tempopt) == hash_err)
		{
		    free(tempopt);
		    exit(EXIT_FAILURE);
		}
		free(tempopt);
		hlog("Using 1:8:lalpha defaults. Use -b<params> (no whitespaces) to specify them%s\n","");
	    }
    	    bflag = 1;
	    break;
	
	case 'm':
	    if (optarg) 
	    {
		if (markov_load_statfile(optarg) == hash_err)
		{
		    exit(EXIT_FAILURE);
		}
		else
		{
		    markovstat = malloc(64);
		    strcpy(markovstat,optarg);
		    attack_method = attack_method_markov;
		}
	    }
	    else
	    {
		usage(argv[0]);
		exit(EXIT_FAILURE);
	    }
	    break;


	case 'S':
	    if (!optarg) (void)print_sessions_summary();
	    else print_session_detailed(optarg);
	    exit(EXIT_SUCCESS);
	break;


	
	case 'p':
	    set_current_plugin(optarg);
            if (load_plugin()==hash_err)
	    {
    	        elog("Cannot load plugin (%s)\n",optarg);
    		exit(EXIT_FAILURE);
    	    }
	    pflag=1;
	break;

        case 'N':
	    markov_max_len = atoi(optarg);
	break;

        case 'D':
	    ocl_gpu_double = 1;
	    //setenv("GPU_MAX_HEAP_SIZE", "196", 1);
	    hlog("Using GPU double mode\n%s","");
	break;

        case 'n':
	    markov_threshold = atoi(optarg);
	break;

        case 't':
	    ocl_gpu_platform = atoi(optarg);
	break;

        
        case 'M':
	    markov_print_statfiles();
	    exit(EXIT_SUCCESS);
	break;
        
	case 'f':
	    fvalue = optarg;
	break;
        
	case 'd':
	    dvalue = optarg;
	break;

	case 'o':
	    out_cracked_file=malloc(strlen(optarg)+1);
	    strcpy(out_cracked_file,optarg);
	break;

	case 'O':
	    out_uncracked_file=malloc(strlen(optarg)+1);
	    strcpy(out_uncracked_file,optarg);
	break;


        case '?':
	    if ((optopt == 'f') || (optopt == 'P') || (optopt == 'd'))
	    {
		fprintf(stderr, "Option -%c requires an argument.\n", optopt);
    	    }
	
	default:
	break;
    }


    /* First check if out_cracked_file and out_uncracked_file are good */
    if (out_cracked_file)
    if (hash_err == check_out_file(out_cracked_file)) exit(1);
    if (out_uncracked_file)
    if (hash_err == check_out_file(out_uncracked_file)) exit(1);


    if (fvalue) 
    {
	strncpy(hashlist_file,fvalue,254);
	hashlist_file[254] = 0;
	if (pflag==0) 
	{
	    if (detect_plugin(DATADIR"/hashkill/plugins",hashlist_file,NULL) == hash_err)
	    {
    		elog("Cannot detect hash type%s\n","");
    		exit(EXIT_FAILURE);
	    }
	}
	(void)load_hashes_file(fvalue);
    }


    /* Do we have argument (hash)? */
    if (argv[optind]) 
    {
	if (pflag==0) 
	{
	    if (detect_plugin(DATADIR"/hashkill/plugins",NULL,argv[optind])==hash_err)
	    {
    		elog("Cannot detect hash type%s\n","");
    		exit(EXIT_FAILURE);
	    }
	}
	strncpy(hash_cmdline,argv[optind],HASHFILE_MAX_LINE_LENGTH);
	if (load_single_hash(hash_cmdline) == hash_err)
	{
	    if (!fvalue) 
	    {
		elog("Cannot load hash: %s\n",argv[optind]);
		exit(EXIT_FAILURE);
	    }
	}
    }


    if (strcmp(get_current_plugin(),"bitcoin")!=0)
    {

	/* Hashes num */
	hashes_count = get_hashes_num();

	/* Bruteforce? */
	if ((bflag)&&(!dvalue)&&(!rflag))
	{
	    fast_markov = 0; // do not mess with the charset in the opencl code
	    attack_method = attack_method_simple_bruteforce;
	}

    
	/* sl3 plugin is an exception: bruteforce only! */
	if (strcmp(get_current_plugin(),"sl3")==0)
	{
	    attack_method = attack_method_simple_bruteforce;
	}

	if ((attack_method != attack_method_simple_bruteforce) && ((attack_method != attack_method_markov)) && (attack_method != attack_method_rule))
	{
	    usage(argv[0]);
	    exit(EXIT_FAILURE);
	}
    
	/* threads sizing */
	if ((get_hashes_num() == 0)&&(hashgen_stdout_mode==0))
	{
	    elog("No hashes loaded!%s (try --help)\n","");
	    exit(EXIT_FAILURE);
	}
    
	if (cpu_thread_factor==0) 
	{
	    hash_num_threads = hash_num_cpu();
	}
	else hash_num_threads = cpu_thread_factor;
    }
    else attack_method = attack_method_simple_bruteforce;
    time1=time(NULL);

    /* CPU optimize single hacks */
    if (strcmp(get_current_plugin(),"md5")==0)
    {
	if ((attack_method==attack_method_simple_bruteforce)&&(bruteforce_end>7)) cpu_optimize_single=2;
	else if ((attack_method==attack_method_markov)&&(markov_max_len>7)) cpu_optimize_single=2;
    }
    if ((hash_list)&&(hash_list->next)) cpu_optimize_single=0;

    have_ocl = initialize_opencl();
    if ((have_ocl==hash_ok)&&(cpuonly==0)) have_ocl = ocl_get_device();

    if (cpuonly==1)
    {
	wlog("GPU acceleration available, but -c option was provided. Running on CPUs would likely be slower.\n%s","");
    }



    /* Markov? */
    if (attack_method == attack_method_markov) 
    {
	if (!markovstat) 
	{
	    markov_load_statfile("rockyou");
	    markovstat = malloc(64);
	    strcpy(markovstat,"rockyou");
	}

    	if ((cpuonly==0) && (have_ocl == hash_ok))
    	{
    	    if ((ocl_markov() != hash_ok) && (attack_over==0))
    	    {
    	    	if (tempqueuesize > HASHKILL_MAXQUEUESIZE) tempqueuesize = HASHKILL_MAXQUEUESIZE;
    		(void)main_thread_markov(hash_num_threads);
    	    }
    	}
	else main_thread_markov(hash_num_threads);
    }

    

    /* Rule-based */
    if (attack_method == attack_method_rule) 
    {
    	if (hash_err==rule_preprocess(rule_file)) {exit(1);}
    	if ((cpuonly==0) && (have_ocl == hash_ok))
    	{
    	    if ((ocl_rule() != hash_ok) && (attack_over==0))
    	    {
    	    	nwthreads = hash_num_threads;
    	    	if (tempqueuesize > HASHKILL_MAXQUEUESIZE) tempqueuesize = HASHKILL_MAXQUEUESIZE;
    		main_thread_rule(hash_num_threads);
    	    }
    	}
	else main_thread_rule(hash_num_threads);
    }


    /* Bruteforce? */
    if (attack_method == attack_method_simple_bruteforce) 
    {
	if (strcmp(get_current_plugin(),"bitcoin")!=0) hlog("Bruteforce charset (size=%d): %s\n",strlen(bruteforce_charset),bruteforce_charset);
	if ((have_ocl == hash_ok) && (cpuonly==0))
	{
	    if ( (ocl_bruteforce() != hash_ok) && (attack_over==0))
	    {
		if (tempqueuesize > HASHKILL_MAXQUEUESIZE) tempqueuesize = HASHKILL_MAXQUEUESIZE;
		(void)main_thread_bruteforce(hash_num_threads);
	    }
	}
	else main_thread_bruteforce(hash_num_threads);
    }


    /* We delete session file ONLY when attack is over */
    if (ctrl_c_pressed==0)
    {
        session_unlink_file();
	if (have_ocl==hash_ok) session_unlink_file_ocl();
    }
    

    if (get_cracked_num() > 0) print_cracked_list();    

    if (out_cracked_file)
    {
        print_cracked_list_to_file(out_cracked_file);
    }
    
    if ((hash_plugin_is_special)&&(hash_plugin_is_special()==0))
    {
    
	if (out_uncracked_file)
	{
	    print_uncracked_list_to_file(out_uncracked_file);
	}
    }

    time2=time(NULL);
    printf("\n");
    hlog("Attack took %u seconds.\n",(unsigned int)(time2-time1));

    hlog("Bye bye :)\n\n%s","");
//    thread_attack_cleanup();
//    cleanup_lists();

    return 0;
}
