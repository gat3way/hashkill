/*
 * ocl-threads.c
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
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <alloca.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "err.h"
#include "ocl-base.h"
#include "hashinterface.h"
#include "plugins.h"
#include "ocl-threads.h"
#include "ocl_support.h"
#include "ocl-adl.h"
#include "hashgen.h"
#include "sessions.h"

/* Local variables */
static time_t time1;


/* supported plugins */
struct ocl_supported_plugins_s ocl_supported_plugins[] =
                        { 
                            {1,"md5",&ocl_bruteforce_md5, &ocl_markov_md5, &ocl_rule_md5},
                            {1,"sha1",&ocl_bruteforce_sha1, &ocl_markov_sha1, &ocl_rule_sha1},
                            {1,"md4",&ocl_bruteforce_md4, &ocl_markov_md4, &ocl_rule_md4},
                            {1,"ntlm",&ocl_bruteforce_ntlm, &ocl_markov_ntlm, &ocl_rule_ntlm},
                            {1,"md5md5",&ocl_bruteforce_md5md5, &ocl_markov_md5md5, &ocl_rule_md5md5},
                            {1,"mysql5",&ocl_bruteforce_mysql5, &ocl_markov_mysql5, &ocl_rule_mysql5},
                            //{1,"mysql-old",&ocl_bruteforce_mysql_old, &ocl_markov_mysql_old, &ocl_rule_mysql_old},
                            //{1,"test",&ocl_bruteforce_test, &ocl_markov_test, &ocl_rule_test},
                            {1,"sha256",&ocl_bruteforce_sha256, &ocl_markov_sha256, &ocl_rule_sha256},
                            {1,"sha512",&ocl_bruteforce_sha512, &ocl_markov_sha512, &ocl_rule_sha512},
                            {1,"lm",&ocl_bruteforce_lm, &ocl_markov_lm, &ocl_rule_lm},
                            {1,"nsldap",&ocl_bruteforce_nsldap, &ocl_markov_nsldap, &ocl_rule_nsldap},
                            {1,"joomla",&ocl_bruteforce_joomla, &ocl_markov_joomla, &ocl_rule_joomla},
                            {1,"oscommerce",&ocl_bruteforce_oscommerce, &ocl_markov_oscommerce, &ocl_rule_oscommerce},
                            {1,"ipb2",&ocl_bruteforce_ipb2, &ocl_markov_ipb2, &ocl_rule_ipb2},
                            {1,"vbulletin",&ocl_bruteforce_vbulletin, &ocl_markov_vbulletin, &ocl_rule_vbulletin},
                            {1,"smf",&ocl_bruteforce_smf, &ocl_markov_smf, &ocl_rule_smf},
                            {1,"oracle11g",&ocl_bruteforce_oracle11g, &ocl_markov_oracle11g, &ocl_rule_oracle11g},
                            {1,"mssql-2000",&ocl_bruteforce_mssql_2000, &ocl_markov_mssql_2000, &ocl_rule_mssql_2000},
                            {1,"mssql-2005",&ocl_bruteforce_mssql_2005, &ocl_markov_mssql_2005, &ocl_rule_mssql_2005},
                            {1,"nsldaps",&ocl_bruteforce_nsldaps, &ocl_markov_nsldaps, &ocl_rule_nsldaps},
                            {1,"osx-old",&ocl_bruteforce_osx_old, &ocl_markov_osx_old, &ocl_rule_osx_old},
                            {1,"osxlion",&ocl_bruteforce_osxlion, &ocl_markov_osxlion, &ocl_rule_osxlion},
                            {1,"desunix",&ocl_bruteforce_desunix, &ocl_markov_desunix, &ocl_rule_desunix},
                            {1,"oracle-old",&ocl_bruteforce_oracle_old, &ocl_markov_oracle_old, &ocl_rule_oracle_old},
                            {1,"mscash",&ocl_bruteforce_mscash, &ocl_markov_mscash, &ocl_rule_mscash},
                            {1,"pixmd5",&ocl_bruteforce_pixmd5, &ocl_markov_pixmd5, &ocl_rule_pixmd5},
                            {1,"phpbb3",&ocl_bruteforce_phpbb3, &ocl_markov_phpbb3, &ocl_rule_phpbb3},
                            {1,"wordpress",&ocl_bruteforce_wordpress, &ocl_markov_wordpress, &ocl_rule_wordpress},
                            {1,"md5unix",&ocl_bruteforce_md5unix, &ocl_markov_md5unix, &ocl_rule_md5unix},
                            {1,"sha512unix",&ocl_bruteforce_sha512unix, &ocl_markov_sha512unix, &ocl_rule_sha512unix},
                            {1,"mscash2",&ocl_bruteforce_mscash2, &ocl_markov_mscash2, &ocl_rule_mscash2},
                            {1,"apr1",&ocl_bruteforce_apr1, &ocl_markov_apr1, &ocl_rule_apr1},
                            {1,"wpa",&ocl_bruteforce_wpa, &ocl_markov_wpa, &ocl_rule_wpa},
                            {1,"dmg",&ocl_bruteforce_dmg, &ocl_markov_dmg, &ocl_rule_dmg},
                            {1,"rar",&ocl_bruteforce_rar, &ocl_markov_rar, &ocl_rule_rar},
                            {1,"zip",&ocl_bruteforce_zip, &ocl_markov_zip, &ocl_rule_zip},
                            {1,"bfunix",&ocl_bruteforce_bfunix, &ocl_markov_bfunix, &ocl_rule_bfunix},
                            {1,"drupal7",&ocl_bruteforce_drupal7, &ocl_markov_drupal7, &ocl_rule_drupal7},
                            {1,"django256",&ocl_bruteforce_django256, &ocl_markov_django256, &ocl_rule_django256},
                            {1,"sha256unix",&ocl_bruteforce_sha256unix, &ocl_markov_sha256unix, &ocl_rule_sha256unix},
                            {1,"o5logon",&ocl_bruteforce_o5logon, &ocl_markov_o5logon, &ocl_rule_o5logon},
                            {1,"mssql-2012",&ocl_bruteforce_mssql_2012, &ocl_markov_mssql_2012, &ocl_rule_mssql_2012},
                            {1,"msoffice",&ocl_bruteforce_msoffice, &ocl_markov_msoffice, &ocl_rule_msoffice},
                            {1,"luks",&ocl_bruteforce_luks, &ocl_markov_luks, &ocl_rule_luks},
                            {1,"ripemd160",&ocl_bruteforce_ripemd160, &ocl_markov_ripemd160, &ocl_rule_ripemd160},
                            {1,"whirlpool",&ocl_bruteforce_whirlpool, &ocl_markov_whirlpool, &ocl_rule_whirlpool},
                            {1,"truecrypt",&ocl_bruteforce_truecrypt, &ocl_markov_truecrypt, &ocl_rule_truecrypt},
                            {1,"lastpass",&ocl_bruteforce_lastpass, &ocl_markov_lastpass, &ocl_rule_lastpass},
                            {1,"keepass",&ocl_bruteforce_keepass, &ocl_markov_keepass, &ocl_rule_keepass},
                            {1,"mozilla",&ocl_bruteforce_mozilla, &ocl_markov_mozilla, &ocl_rule_mozilla},
                            {1,"pwsafe",&ocl_bruteforce_pwsafe, &ocl_markov_pwsafe, &ocl_rule_pwsafe},
                            {1,"keyring",&ocl_bruteforce_keyring, &ocl_markov_keyring, &ocl_rule_keyring},
                            {1,"kwallet",&ocl_bruteforce_kwallet, &ocl_markov_kwallet, &ocl_rule_kwallet},
                            {1,"msoffice-old",&ocl_bruteforce_msoffice_old, &ocl_markov_msoffice_old, &ocl_rule_msoffice_old},
                            {1,"pdf",&ocl_bruteforce_pdf, &ocl_markov_pdf, &ocl_rule_pdf},
                            {1,"sha384",&ocl_bruteforce_sha384, &ocl_markov_sha384, &ocl_rule_sha384},
                            {1,"odf",&ocl_bruteforce_odf, &ocl_markov_odf, &ocl_rule_odf},
                            {1,"grub2",&ocl_bruteforce_grub2, &ocl_markov_grub2, &ocl_rule_grub2},
                            {1,"osx-ml",&ocl_bruteforce_osx_ml, &ocl_markov_osx_ml, &ocl_rule_osx_ml},
                            {1,"androidfde",&ocl_bruteforce_androidfde, &ocl_markov_androidfde, &ocl_rule_androidfde},
                            {1,"androidpin",&ocl_bruteforce_androidpin, &ocl_markov_androidpin, &ocl_rule_androidpin},
                            {1,"a51",&ocl_bruteforce_a51, &ocl_markov_a51, &ocl_rule_a51},
                            {0, "", NULL, NULL, NULL}
                        };


extern void session_close_file_ocl(FILE *sessionfile);
static pthread_t monitorinfothread;



/* Is that plugin supported? */
hash_stat ocl_is_supported_plugin(char *plugin)
{
    int index,supported;
    
    index=supported=0;
    while (ocl_supported_plugins[index].bruteforce_routine)
    {
	if (strcmp(plugin, ocl_supported_plugins[index].plugin_name)==0)
	{
	    return hash_ok;
	}
	index++;
    }
    return hash_err;
}


/* SIGINT/SIGTERM handler - needs to be reinstalled as AMD SDK 2.3 fucks it up*/
static void ocl_sigint_handler(int val)
{
    int a;
    printf("\n");
    wlog("Interrupted by user request!%s","");
    printf("\n");
    ctrl_c_pressed = 1;
    attack_over = 2;
    for (a=0;a<nwthreads;a++) if (wthreads[a].templocked==1)
    {
	wthreads[a].templocked=0;
	pthread_mutex_unlock(&wthreads[a].tempmutex);
    }
    pthread_cancel(monitorinfothread);
}


/* Probe for OpenCL-enabled device if any */
hash_stat ocl_get_device()
{
    cl_device_id device_id[16];
    cl_uint num_of_devices;
    cl_int err;
    cl_platform_id platforms[4];
    cl_uint num_platforms;
    char *devicename = alloca(255);
    char *platformname = alloca(255);
    char *devicevendor = alloca(255);
    int a,b,i,splatform,eplatform;
    int ocl_vectororig;
    int loops;
    int ocl_dev_nvidia;
    int ocl_dev_amd;
    int ocl_vector=1;
    int ocl_have_old_ati;
    int ocl_have_sm21;
    int ocl_have_sm10;
    int ocl_have_69xx;
    int ocl_have_gcn;

    /* We are printing rule-generated output - do not go through GPU codepath */
    if (hashgen_stdout_mode==1) return hash_err;

    /* Get platforms */
    ocl_dev_nvidia = ocl_dev_amd = 0;
    _clGetPlatformIDsNoErr(4, platforms, &num_platforms);
    if (ocl_gpu_platform==100) 
    {
	splatform=0;
	eplatform=num_platforms;
    }
    else
    {
	splatform=ocl_gpu_platform;
	eplatform=ocl_gpu_platform+1;
    }

    for (i=splatform;i<eplatform;i++)
    {
	_clGetPlatformInfoNoErr(platforms[i],CL_PLATFORM_VERSION,255,platformname,NULL);
	err = _clGetDeviceIDsNoErr(platforms[i], CL_DEVICE_TYPE_GPU, 16, device_id, &num_of_devices);
	if (err!=CL_SUCCESS) continue;
	for (a=0;a<num_of_devices;a++)
	{
	    ocl_have_old_ati = 0;
	    ocl_dev_nvidia = 0;
	    ocl_have_sm21 = 0;
	    ocl_have_sm10 = 0;
	    ocl_have_69xx = 0;
	    ocl_have_gcn = 0;
	    ocl_threads = 2;
	    switch (err)
	    {
		case CL_INVALID_PLATFORM:
		    elog("Invalid OpenCL platform!%s\n","");
		    return hash_err;
		    break;
		case CL_DEVICE_NOT_FOUND:
		    elog("No suitable GPU devices found!%s\n","");
		    return hash_err;
		    break;
		default: 
		    _clGetDeviceInfo( device_id[a], CL_DEVICE_NAME, 254, devicename,  NULL);
		    _clGetDeviceInfo( device_id[a], CL_DEVICE_VENDOR, 254, devicevendor,  NULL);
		    hlog("Found GPU device: %s - %s\n", devicevendor,devicename);
		    if (strstr(devicevendor,"IDIA")) {ocl_dev_nvidia = 1;ocl_vector=1;}
		    if (strstr(devicevendor,"idia")) {ocl_dev_nvidia = 1;ocl_vector=1;}
		    if (strstr(devicevendor,"dvanced Micro")) {ocl_dev_amd = 1;ocl_vector=8;}
		    if (strstr(devicevendor,"ATI")) {ocl_dev_amd = 1;ocl_vector=8;}
		    if (strstr(devicename,"RV7")) {ocl_have_old_ati=1;}
		    if (strstr(devicename,"Cayman")) {ocl_have_69xx=1;}
		    if (strstr(devicename,"Pitcairn")) {ocl_have_gcn=1;}
		    if (strstr(devicename,"Capeverde")) {ocl_have_gcn=1;}
		    if (strstr(devicename,"Tahiti")) {ocl_have_gcn=1;}

        	    if (ocl_dev_nvidia==1)
        	    {
        		#define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
            		#define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
        		int compute_capability_major,compute_capability_minor;
        		_clGetDeviceInfoNoErr(device_id[a], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
            		_clGetDeviceInfoNoErr(device_id[a], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
            		if ((compute_capability_major==2)&&(compute_capability_minor==1)) ocl_have_sm21 = 1;
            		if ((compute_capability_major==1)&&(compute_capability_minor==0)) ocl_have_sm10 = 1;
			break;
		    }
	    }
	    loops=1;

	    /* Default values: VLIW: vectors4/loops1 GCN: vectors1/loops4 SM21: vectors4/loops1 NV: vectors1/loops4 */
	    if ((attack_method!=attack_method_rule)&&(((!ocl_have_gcn)&&(!ocl_dev_nvidia)) || ((ocl_have_sm21==1)&&(ocl_dev_nvidia==1))))
	    {
    		ocl_vector=8;
    		loops=1;
	    }

	    if ((attack_method!=attack_method_rule)&&(((!ocl_dev_nvidia)&&(ocl_have_gcn==1))||((ocl_dev_nvidia==1)&&(!ocl_have_sm21))))
	    {
		loops=4;
		ocl_vector=1;
	    }

	    /* set -G opt */
	    if (ocl_user_threads!=0) ocl_threads = ocl_user_threads;

    	    /* VLIW vector hacks */
    	    if ((!ocl_have_gcn)&&(!ocl_dev_nvidia))
    	    {
		if ((strcmp(get_current_plugin(),"sha1")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"sha256")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ripemd160")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"md5md5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mysql5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"nsldap")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"nsldaps")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ipb2")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"smf")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"vbulletin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"pixmd5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2012")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"mssql-2000")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2005")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"lm")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"desunix")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"phpbb3")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"sha512")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha384")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"osx-old")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"zip")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"o5logon")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"mozilla")==0)) {ocl_vector=1;loops=1;}
	    }
	    /* GCN loops hacks */
	    if ((ocl_have_gcn==1)&&(!ocl_dev_nvidia))
	    {
		if ((strcmp(get_current_plugin(),"sha1")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"ripemd160")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"nsldap")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"nsldaps")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"smf")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2000")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2005")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2012")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"lm")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"desunix")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"sha512")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"sha384")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"osx-old")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mscash")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"o5logon")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"mozilla")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"vbulletin")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"ipb2")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"joomla")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"androidpin")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oscommerce")==0)) loops=2;
	    }

	    /* AMD rule quirks */
	    if ((attack_method==attack_method_rule)&&(ocl_dev_nvidia==0))
	    {
		/* Global */
		if ((strcmp(get_current_plugin(),"test")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"msoffice-old")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"lm")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"desunix")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha512")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha384")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"joomla")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"androidpin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oscommerce")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ipb2")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"sha256")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"smf")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2000")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2005")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2012")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"nsldaps")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"nsldap")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"vbulletin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"joomla")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"androidpin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oscommerce")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"osx-old")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"mscash")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"pixmd5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"bfunix")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"drupal7")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"sha256unix")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"sha512unix")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"grub2")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"osx-ml")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) {ocl_vector=1;loops=2;}
		if ((strcmp(get_current_plugin(),"mysql5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mscash")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"md5")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"md4")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"sha1")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ripemd160")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ntlm")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"md5md5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"o5logon")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"keepass")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"mozilla")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"pdf")==0)) ocl_vector=1;

		/* GCN/VLIW-specific */
		if ((strcmp(get_current_plugin(),"phpbb3")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"phpbb3")==0)&&(!ocl_have_gcn)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"wordpress")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"wordpress")==0)&&(!ocl_have_gcn)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"md5unix")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"md5unix")==0)&&(!ocl_have_gcn)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"apr1")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"apr1")==0)&&(!ocl_have_gcn)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mscash2")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"mscash2")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"wpa")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"wpa")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"luks")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"luks")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"androidfde")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"androidfde")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"truecrypt")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"truecrypt")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"dmg")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"dmg")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"odf")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"odf")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"rar")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"rar")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"django256")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"django256")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"pwsafe")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"pwsafe")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"keyring")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"keyring")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"kwallet")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"kwallet")==0)&&(ocl_have_gcn)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"lastpass")==0)&&(!ocl_have_gcn)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"lastpass")==0)&&(ocl_have_gcn)) ocl_vector=1;
	    }


	    /* All nvidias */
	    if (ocl_dev_nvidia==1)
	    {
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) {loops=1;ocl_vector=1;}
		if ((strcmp(get_current_plugin(),"rar")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"msoffice-old")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"keepass")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"mozilla")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"osxlion")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"mscash")==0)) {loops=2;ocl_vector=1;}
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) {ocl_vector=1;loops=2;}
		if ((strcmp(get_current_plugin(),"smf")==0)) {ocl_vector=1;loops=2;}
	    }

	    /* SM21 hacks */
	    if ((ocl_have_sm21==1)&&(ocl_dev_nvidia==1))
	    {
		ocl_vector=4;
		if ((strcmp(get_current_plugin(),"desunix")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"bfunix")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"drupal7")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"sha512unix")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"grub2")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"osx-ml")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) {ocl_vector=2;loops=1;}
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) {ocl_vector=4;loops=1;}
		if ((strcmp(get_current_plugin(),"lm")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha512")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"sha384")==0)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) {ocl_vector=2;loops=1;}
		if ((strcmp(get_current_plugin(),"zip")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"mscash")==0)) {loops=1;ocl_vector=8;}
		if ((strcmp(get_current_plugin(),"smf")==0)) {ocl_vector=4;loops=1;}
		if ((strcmp(get_current_plugin(),"django256")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"pwsafe")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"keyring")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"kwallet")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"lastpass")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"rar")==0)) ocl_vector=2;
	    }
	    else if (ocl_dev_nvidia==1)
	    {
		if ((strcmp(get_current_plugin(),"sha1")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"ripemd160")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"nsldap")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"nsldaps")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"smf")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2000")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2005")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mssql-2012")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"lm")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"desunix")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"sha512")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"sha384")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"osx-old")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"mscash")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oracle-old")==0)) loops=1;
		if ((strcmp(get_current_plugin(),"o5logon")==0)) {ocl_vector=1;loops=1;}
		if ((strcmp(get_current_plugin(),"vbulletin")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"ipb2")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"joomla")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"androidpin")==0)) loops=2;
		if ((strcmp(get_current_plugin(),"oscommerce")==0)) loops=2;
	    }

	    /* Specific nvidia rule quirks */
	    if ((attack_method==attack_method_rule)&&(ocl_dev_nvidia==1))
	    {
		loops=1;
		ocl_vector=1;
		if ((strcmp(get_current_plugin(),"phpbb3")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"phpbb3")==0)&&(ocl_have_sm21)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"wordpress")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"wordpress")==0)&&(ocl_have_sm21)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"md5unix")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"md5unix")==0)&&(ocl_have_sm21)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"apr1")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"apr1")==0)&&(ocl_have_sm21)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mscash2")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"mscash2")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"wpa")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"wpa")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"luks")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"luks")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"androidfde")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"androidfde")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"truecrypt")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"truecrypt")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"dmg")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"dmg")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"odf")==0)&&(!ocl_have_sm21)) ocl_vector=1;
		if ((strcmp(get_current_plugin(),"odf")==0)&&(ocl_have_sm21)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"md5")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"md4")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"sha1")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ripemd160")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"lm")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha256")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"sha512")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"sha384")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"whirlpool")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"ntlm")==0)) ocl_vector=8;
		if ((strcmp(get_current_plugin(),"md5md5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mysql5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"joomla")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"androidpin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oscommerce")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"nsldap")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"ipb2")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"desunix")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"mscash")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"oracle11g")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"nsldaps")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2000")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2005")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"mssql-2012")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"osxlion")==0)) ocl_vector=2;
		if ((strcmp(get_current_plugin(),"osx-old")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"pixmd5")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"smf")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"vbulletin")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"o5logon")==0)) ocl_vector=4;
		if ((strcmp(get_current_plugin(),"pdf")==0)) ocl_vector=1;
	    }

	    /* Zip (non-rule) exception for NVidia */
	    if ((ocl_dev_nvidia==1) && (ocl_have_sm21==0) && (strcmp(get_current_plugin(),"zip")==0)) loops=4;

	    /* save old vectorsize */
	    ocl_vectororig = ocl_vector;

	    /* GPU double mode? - ATI */
	    if ((ocl_gpu_double)&&(attack_method!=attack_method_rule)) 
	    {
		loops*=2;
	    }
	
	    /* Now add collected information to wthreads */
	    for (b=0;b<ocl_threads;b++)
	    {
		if (b==0) wthreads[nwthreads].first=1;
		else wthreads[nwthreads].first=0;
		wthreads[nwthreads].vectorsize=ocl_vectororig;
		if (ocl_dev_nvidia==1) wthreads[nwthreads].type=nv_thread;
		else wthreads[nwthreads].type=amd_thread;
		wthreads[nwthreads].platform = i;
		wthreads[nwthreads].deviceid = a;
		wthreads[nwthreads].loops = loops;
		wthreads[nwthreads].cldeviceid = device_id[a];
		wthreads[nwthreads].ocl_have_sm21 = ocl_have_sm21;
		wthreads[nwthreads].ocl_have_sm10 = ocl_have_sm10;
		wthreads[nwthreads].ocl_have_vliw4 = ocl_have_69xx;
		wthreads[nwthreads].ocl_have_gcn = ocl_have_gcn;
		wthreads[nwthreads].ocl_have_old_ati = ocl_have_old_ati;
		wthreads[nwthreads].temperature = 0;
		wthreads[nwthreads].oldtries = 0;
		wthreads[nwthreads].templocked = 0;
		sprintf(wthreads[nwthreads].adaptername,"%s", devicename);
		nwthreads++;
	    }
	}
    }

    a=setup_adl();
    switch (a)
    {
	case 0:
	     wlog("ADL/NVML not found!\n%s","");
	     break;
	case 1:
	    // Are we going to print smth?
	    break;
	case 2:
	    break;
    }

    return hash_ok;
}



/* GPU bruteforce attack */
hash_stat ocl_bruteforce()
{
    int index = 0; // ocl_supported_plugins[] index
    int supported = 0;
    struct hash_list_s *amylist=hash_list;
    int flag=0,count=0;


    while (ocl_supported_plugins[index].bruteforce_routine)
    {
	if (strcmp(get_current_plugin(), ocl_supported_plugins[index].plugin_name)==0)
	{
	    while (amylist)
	    {
    		if (strlen(amylist->salt) > 0) flag = 1;
    		amylist = amylist->next;
    		count++;
	    }

	    if (((flag == 0)||(count<2))&&(salt_size<2)) hlog("Attack has O(1) complexity%s\n","");
	    else hlog("Attack has O(N) complexity%s\n","");

	    hlog("This plugin supports GPU acceleration.\n%s","");
	    ocl_spawn_threads(0,0);
	    ocl_supported_plugins[index].bruteforce_routine();
	    supported = 1;
	    return hash_ok;
	}
	index++;
    }
    if (supported==0) return hash_err;

    /* Display timing stats */
    static time_t time2;
    time2 = time(NULL);
    index=time2; //warning supress
    hlog("Bruteforce attack complete.%s\n","");
    return hash_ok;
}



/* GPU Markov attack */
hash_stat ocl_markov()
{
    int index = 0; // ocl_supported_plugins[] index
    int supported = 0;
    struct hash_list_s *amylist=hash_list;
    int flag=0,count=0;


    while (ocl_supported_plugins[index].bruteforce_routine)
    {
	if (strcmp(get_current_plugin(), ocl_supported_plugins[index].plugin_name)==0)
	{
	    hlog("This plugin supports GPU acceleration.\n%s","");
	    while (amylist)
	    {
    		if (strlen(amylist->salt) > 0) flag = 1;
    		amylist = amylist->next;
    		count++;
	    }

	    if (((flag == 0)||(count<2))&&(salt_size<2)) hlog("Attack has O(1) complexity%s\n","");
	    else hlog("Attack has O(N) complexity%s\n","");

	    ocl_spawn_threads(0,0);
	    ocl_supported_plugins[index].markov_routine();
	    supported = 1;
	    return hash_ok;
	}
	index++;
    }
    if (supported==0) {return hash_err;}

    /* Display timing stats */
    static time_t time2;
    time2 = time(NULL);
    index=time2; //warning supress
    hlog("Markov attack complete. %s\n","");

    return hash_ok;
}



/* GPU rule attack */
hash_stat ocl_rule()
{
    int index = 0; 
    int supported = 0;
    struct hash_list_s *amylist=hash_list;
    int flag=0,count=0;


    while (ocl_supported_plugins[index].bruteforce_routine)
    {
	if ((strcmp(get_current_plugin(), ocl_supported_plugins[index].plugin_name)==0))
	{
	    while (amylist)
	    {
    		if (strlen(amylist->salt) > 0) flag = 1;
    		amylist = amylist->next;
    		count++;
	    }

	    if (((flag == 0)||(count<2))&&(salt_size<2)) hlog("Attack has O(1) complexity%s\n","");
	    else hlog("Attack has O(N) complexity%s\n","");
	    if (hashgen_stdout_mode==0) rule_stats_parse();
	    ocl_spawn_threads(0,0);
	    ocl_supported_plugins[index].rule_routine();
	    supported=1;
	}
	index++;
    }
    if (supported==0) return hash_err;
    
    /* Display timing stats */
    
    static time_t time2;
    time2 = time(NULL);
    index=time2; //warning supress
    hlog("Rule attack complete. %s\n","");
    return hash_ok;
}



/* Start ocl monitor thread */
static void * ocl_start_monitor_thread(void *arg)
{

    uint64_t sum;
    int cracked;
    FILE *sessionfile;
    char *attack_current_str = "abcdeffsd";
    int installed=0;
    int a;

    while ((wthreads[0].tries==0)&&(attack_over==0)) usleep(10000);
    printf("\n");


    while (attack_over == 0)
    {
        sleep(3);
        attack_checkpoints++;
        if (installed == 0) 
        {
    	    signal(SIGINT, ocl_sigint_handler);
    	    signal(SIGTERM, ocl_sigint_handler);
    	    installed=1;
    	}
        sum = 0;
        if (attack_over != 2)
        {
            cracked = get_cracked_num();
    	    if ((attack_method == attack_method_simple_bruteforce))
    	    {
    	        for (a=0;a<nwthreads;a++) 
    	        {
    	    	    sum+=wthreads[a].tries;
    	    	    wthreads[a].oldtries = wthreads[a].tries;
    	    	    wthreads[a].tries=0;
    	    	}
    	    	if (attack_checkpoints==1) attack_avgspeed = sum;
    	    	else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
    	    }
    	    if (attack_method==attack_method_markov)
    	    { 
    	        for (a=0;a<nwthreads;a++) 
    	        {
    	    	    sum+=wthreads[a].tries;
    	    	    wthreads[a].oldtries = wthreads[a].tries;
    	    	    wthreads[a].tries=0;
    	    	}
    	    	if (attack_checkpoints==1) attack_avgspeed = sum;
    	    	else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
    	    }
    	    if (attack_method==attack_method_rule)
    	    {
    	    	for (a=0;a<nwthreads;a++) 
    	    	{
    	    	    sum+=wthreads[a].tries;
    	    	    wthreads[a].oldtries = wthreads[a].tries;
    	    	    wthreads[a].tries=0;
    	    	}
    	    	if (attack_checkpoints==1) attack_avgspeed = sum;
    	    	else attack_avgspeed=(attack_avgspeed*attack_checkpoints+(sum))/(attack_checkpoints+1);
    		if (attack_overall_count <= 1)
    		{
            	    if ((sum / 30000000) > 20) printf("\rSpeed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
            	    else if ((sum / 3000) > 20) printf("\rSpeed: %lldK c/s (avg: %lldK c/s)   Cracked: %d passwords   ", (sum / 3000),(attack_avgspeed/3000) ,cracked);
            	    else printf("\rSpeed: %lld c/s (avg: %lld c/s)  Cracked: %d passwords   ", (sum / 3),(attack_avgspeed/3), cracked);
    		}
    		else
    		{
            	    if ( ((attack_current_count*100) / attack_overall_count) > 100)
            	    {
        		if (sum>30000000) printf("\rProgress: 100%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000000),(attack_avgspeed/3000000) ,cracked);
            		else printf("\rProgress: 100%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000),(attack_avgspeed/3000) ,cracked);
            	    }
            	    else  
            	    {
            		if (sum>30000000) printf("\rProgress: %lld%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", ((attack_current_count*100)/attack_overall_count) ,(sum / 3000000),(attack_avgspeed/3000000) ,cracked);
            		else if ((sum / 3000) > 20) printf("\rProgress: %lld%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ", (uint64_t)((attack_current_count*100)/attack_overall_count) ,(sum / 3000),(attack_avgspeed/3000) ,cracked);
        		else printf("\rProgress: %lld%%   Speed: %lld c/s (avg: %lld c/s)  Cracked: %d passwords   ",(uint64_t)((attack_current_count*100)/attack_overall_count), (sum / 3),(attack_avgspeed/3), cracked);
        	    }
    		}
    		if (cracked >= hashes_count) attack_over = 2;
    		fflush(stdout);
    		invocations=0;
    	    }
	    else
	    {
    		if (attack_overall_count == 1)
    		{
            	    if ((sum / 30000000) > 20) 	printf("\rSpeed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
            	    else if ((sum / 3000) > 20) printf("\rSpeed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ", (sum / 3000),(attack_avgspeed/3000), cracked);
            	    else printf("\rSpeed: %lld c/s (avg: %lld c/s)   Cracked: %d passwords  ", (sum / 3),(attack_avgspeed/3), cracked);
    		}
    		else
    		{
            	    if ( ((attack_current_count*100) / attack_overall_count) > 100)
            	    {
        		if (sum>30000000) printf("\rProgress: 100%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000000),(attack_avgspeed/3000000), cracked);
            		else printf("\rProgress: 100%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords  (please wait...)   ", (sum / 3000),(attack_avgspeed/3000), cracked);
            	    }
            	    else  
            	    {
            		if (sum>30000000) 	printf("\rProgress: %lld%%   Speed: %lldM c/s (avg: %lldM c/s)  Cracked: %d passwords   ",((attack_current_count*100)/attack_overall_count) ,(sum / 3000000),(attack_avgspeed/3000000), cracked);
            		else if ((sum / 3000) > 20) printf("\rProgress: %lld%%   Speed: %lldK c/s (avg: %lldK c/s)  Cracked: %d passwords   ",((attack_current_count*100)/attack_overall_count) , (sum / 3000),(attack_avgspeed/3000), cracked);
            		else printf("\rProgress: %lld%%   Speed: %lld c/s (avg: %lld c/s)   Cracked: %d passwords   ",(uint64_t)((attack_current_count*100)/attack_overall_count), (sum / 3),(attack_avgspeed/3), cracked);
        	    }
    		}
    	    }
    	    printf("                        ");
    	    fflush(stdout);
    	    printf("\r\e[?25l");
    	    fflush(stdout);

            if (session_init_file(&sessionfile) == hash_ok)
            {
                if (attack_overall_count<2) session_write_parameters(get_current_plugin(), attack_method, 0 , sessionfile);
                else session_write_parameters(get_current_plugin(), attack_method, ((attack_current_count*100)/(attack_overall_count+1)), sessionfile);
                if (attack_method == attack_method_simple_bruteforce)
                {
                    // FIXME: add real start and curstr
                    session_write_bruteforce_parm(bruteforce_start, bruteforce_end, "", "", bruteforce_charset, 0, "", attack_current_count, sessionfile);
                }
                else if (attack_method == attack_method_markov)
                {
                    session_write_markov_parm(markov_statfile, markov_threshold, markov_max_len, attack_overall_count, attack_current_count, attack_current_str,  sessionfile);
                }
                else if (attack_method == attack_method_rule)
                {
                    session_write_rule_parm(rule_file, attack_current_count, attack_overall_count, sessionfile);
                }


                if (attack_over==0)
                {
                    session_write_hashlist(sessionfile);
                    session_write_crackedlist(sessionfile);
                }
                session_close_file_ocl(sessionfile);
            }

            if (cracked >= hashes_count) attack_over = 2;
        }
    }
    printf("\n");
    pthread_cancel(monitorinfothread);
    pthread_exit(NULL);
    return 0;
}






/* Start monitor info thread (this actually just waits for keyboard input and prints out stats*/
static void * ocl_start_monitor_info_thread(void *arg)
{
    int key;
    uint64_t timeest;
    static time_t time2;
    char *stringest = alloca(200);
    char *stringest1 = alloca(100);
    uint64_t ttries,ttries1;
    char *devname;
    int activity=0;
    int temperature;
    int found;
    int a,b;

    // No stats if plugin is bitcoin
    if (strcmp(get_current_plugin(),"bitcoin")==0) return NULL;

    while (attack_over==0)
    {
        key = tolower(getchar());
        printf("\n");
        if (key=='\n')
        {
    	    print_cracked_list();
    	    hlog(" -= End list =-%s\n","");
    	}
    	if ((key!='t')&&(key!=EOF))
    	{
    	    time2 = time(NULL);
    	    bzero(stringest,200);
    	    stringest[199]=activity&255; // Just to shutup GCC
    	    timeest = (((attack_overall_count-attack_current_count)*(time2-time1))/(attack_current_count+1));
    	    if ((attack_overall_count == 1))
    	    {
        	strcpy(stringest, "Time remaining: UNKNOWN");
    	    }
    	    else
    	    {
        	strcpy(stringest, "Time remaining: ");
        	if ((timeest / (60*60*24*30*12))>1)
        	{
            	    sprintf(stringest1,"%lld years ",(timeest / (60*60*24*30*12)));
            	    strcat(stringest, stringest1);
        	}
        	if ((timeest / (60*60*24*30))>1)
        	{
            	    sprintf(stringest1,"%lld months ",(timeest / (60*60*24*30))%(12));
            	    strcat(stringest, stringest1);
        	}
        	if ((timeest / (60*60*24))>1)
        	{
            	    sprintf(stringest1,"%lld days ",(timeest / (60*60*24))%(30));
            	    strcat(stringest, stringest1);
        	}
        	if ((timeest / (60*60))>1)
        	{
            	    sprintf(stringest1,"%lld hours ",(timeest / (60*60))%(24));
            	    strcat(stringest, stringest1);
        	}
        	if ((timeest / (60))>1)
        	{
            	    sprintf(stringest1,"%lld minutes ",(timeest / (60))%60);
            	    strcat(stringest, stringest1);
        	}
        	else
        	{
            	    sprintf(stringest1,"%lld sec ",(timeest));
            	    strcat(stringest, stringest1);
        	}
    	    }
    	    hlog("%s\n\n", stringest);
        }
        if ((key=='\n')||(key=='t'))
        {
    	    adl_getstats();

	    /* Loop the wthreads, amd first */
	    int c=0;
	    for (a=0;a<64;a++)
	    {
		ttries=0;
		found=0;
		temperature=0;
		activity=0;
		devname=NULL;
		for (b=0;b<nwthreads;b++) 
		if (wthreads[b].type==amd_thread)
		if (wthreads[b].deviceid==a)
		{
		    found=1;
		    ttries+=wthreads[b].oldtries;
		    temperature = wthreads[b].temperature;
		    activity = wthreads[b].activity;
		    devname = wthreads[b].adaptername;
		}
		if (found==1)
		{
            	    c++;
            	    if ((ttries / 30000000) > 20) 
            	    {
            		ttries1=(ttries / 3000000);
            		hlog("GPU%d: %lldM c/s [Temp]: %dC  (%s)\n",c,ttries1,temperature,devname);
            	    }
            	    else if ((ttries / 3000) > 20) 
            	    {
            		ttries1=(ttries / 3000);
            		hlog("GPU%d: %lldK c/s [Temp]: %dC  (%s)\n",c,ttries1,temperature,devname);
            	    }
            	    else 
            	    {
            		ttries1=(ttries / 3);
            		hlog("GPU%d: %lld c/s [Temp]: %dC   (%s)\n",c,ttries1,temperature,devname);
		    }
		}
	    }

	    /* Loop the wthreads, nv next */
	    for (a=0;a<64;a++)
	    {
		ttries=0;
		found=0;
		temperature=0;
		activity=0;
		devname=NULL;
		for (b=0;b<nwthreads;b++) 
		if (wthreads[b].type==nv_thread)
		if (wthreads[b].deviceid==a)
		{
		    found=1;
		    ttries+=wthreads[b].oldtries;
		    temperature = wthreads[b].temperature;
		    activity = wthreads[b].activity;
		    devname = wthreads[b].adaptername;
		}
		if (found==1)
		{
            	    c++;
            	    if ((ttries / 30000000) > 20) 
            	    {
            		ttries1=(ttries / 3000000);
            		hlog("GPU%d: %lldM c/s [Temp]: %dC  (%s)\n",c,ttries1,temperature,devname);
            	    }
            	    else if ((ttries / 3000) > 20) 
            	    {
            		ttries1=(ttries / 3000);
            		hlog("GPU%d: %lldK c/s [Temp]: %dC  (%s)\n",c,ttries1,temperature,devname);
            	    }
            	    else 
            	    {
            		ttries1=(ttries / 3);
            		hlog("GPU%d: %lld c/s [Temp]: %dC   (%s)\n",c,ttries1,temperature,devname);
		    }
		}
	    }
	}
	printf("\n\n");
    }
    return NULL;
}


/* Star temp monitor thread */
static void * ocl_temp_thread(void *arg)
{
    while (attack_over!=2)
    {
        sleep(60);
        do_adl();
    }
    return NULL;
}


static uint64_t markov_calculate_overall(int n)
{
    int a,b,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11;
    uint64_t overall = 0;
    int reduced_size;
    int markov2[88][88];
    int markov_csize;

    /* wait until the threads started cracking */
    attack_overall_count=1;
    //while (wthreads[0].tries==0) usleep(1000);
    reduced_size=0;
    markov_csize = strlen(markov_charset);
    if ((fast_markov==1)) markov_csize-=23;

    for (a=0;a<markov_csize;a++) if (markov0[a]>markov_threshold)
    {
        // Create markov2 table
        for (b=0;b<strlen(markov_charset);b++) markov2[reduced_size][b] = markov1[a][b];
        reduced_size++;
    }

    switch (n)
    {

        case 1:
            for (a1=0;a1<reduced_size;a1++)
            {overall++; }
        break;

        case 2:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            {overall++; }
        break;

        case 3:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            {overall++; }
        break;

        case 4:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            {overall++;} 
        break;

        case 5:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            {overall++; }
        break;

        case 6:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            {overall++; }
        break;

        case 7:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            {overall++; }
        break;

        case 8:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            {overall++; }
        break;

        case 9:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold) )
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            {overall++; }
        break;

        case 10:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            for (a10=0;a10<markov_csize;a10++) if (markov1[a9][a10]>markov_threshold)
            {overall++; }
        break;

        case 11:
            for (a1=0;a1<reduced_size;a1++)
            for (a2=0;a2<markov_csize;a2++) if ( (markov2[a1][a2]>markov_threshold))
            for (a3=0;a3<markov_csize;a3++) if (markov1[a2][a3]>markov_threshold)
            for (a4=0;a4<markov_csize;a4++) if (markov1[a3][a4]>markov_threshold)
            for (a5=0;a5<markov_csize;a5++) if (markov1[a4][a5]>markov_threshold)
            for (a6=0;a6<markov_csize;a6++) if (markov1[a5][a6]>markov_threshold)
            for (a7=0;a7<markov_csize;a7++) if (markov1[a6][a7]>markov_threshold)
            for (a8=0;a8<markov_csize;a8++) if (markov1[a7][a8]>markov_threshold)
            for (a9=0;a9<markov_csize;a9++) if (markov1[a8][a9]>markov_threshold)
            for (a10=0;a10<markov_csize;a10++) if (markov1[a9][a10]>markov_threshold)
            for (a11=0;a11<markov_csize;a11++) if (markov1[a10][a11]>markov_threshold)
            {overall++; }
        break;

    }
    return overall;
}

static void *calculate_markov_thread(void *arg)
{
    int cnt;
    uint64_t overall=0;

    for (cnt=5;cnt<=markov_max_len;cnt++) 
    {
        overall += markov_calculate_overall(cnt-4);
    }
    attack_overall_count = overall;
    pthread_exit(NULL);
}





hash_stat ocl_spawn_threads(unsigned int num, unsigned int queue_size)
{
    unsigned int cnt;
    pthread_t monitorthread;
    pthread_mutexattr_t mutexattr;
    pthread_t calc_thread;
    pthread_t temp_thread;
    pthread_attr_t thread_attr;
    struct sched_param thread_param;

    create_hash_indexes();

    pthread_mutexattr_init(&mutexattr);
    pthread_mutexattr_settype(&mutexattr, PTHREAD_MUTEX_ADAPTIVE_NP);
    pthread_mutexattr_setpshared(&mutexattr, PTHREAD_PROCESS_PRIVATE);


    if (pthread_mutex_init(&listmutex, &mutexattr))
    {
        elog("Cannot create list mutex %s\n","");
        return hash_err;
    }
    if (pthread_mutex_init(&crackedmutex, &mutexattr))
    {
        elog("Cannot create list mutex %s\n", "");
        return hash_err;
    }
    
    if ((attack_method == attack_method_markov)&&(strcmp(get_current_plugin(),"a51")!=0))
    {
        hlog("Markov max len: %d threshold:%d\n",markov_max_len, markov_threshold);
        hlog("Progress indicator will be available once Markov calculations are done...\n%s","");
        if (session_restore_flag==0) 
        {
    	    attack_overall_count = 1;
    	    pthread_create(&calc_thread, NULL, calculate_markov_thread, NULL);
    	}
    }

    hash_len = hash_plugin_hash_length();
    /* Unless user pressed ctrl-c BEFORE we have initialized workthreads...*/
    if (attack_over == 0) 
    {
    	pthread_attr_init(&thread_attr);
    	pthread_attr_setschedpolicy(&thread_attr, SCHED_RR);
    	thread_param.sched_priority = 50;
    	pthread_attr_setschedparam(&thread_attr, &thread_param);
    	pthread_attr_setinheritsched(&thread_attr,PTHREAD_EXPLICIT_SCHED); 
    	if (pthread_create(&monitorthread, &thread_attr, ocl_start_monitor_thread, &cnt)!=0)
    	{
        	pthread_create(&monitorthread, NULL, ocl_start_monitor_thread, &cnt);
    	}
	pthread_create(&monitorinfothread, NULL, ocl_start_monitor_info_thread, &cnt);
    }
    time1 = time(NULL);
    pthread_create(&temp_thread, NULL, ocl_temp_thread, NULL);
    return hash_ok;
}


void rule_offload_add_none(callback_final_t cb, int self)
{
    char str[32];

    memset(str,0,32);
    cb(str,self);
}


void rule_offload_add_set(callback_final_t cb, int self)
{
    char *charset;
    int len,start,end,cslen;
    int c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12;
    char str[32];

    charset = rule_optimize[self].charset;
    start = rule_optimize[self].start;
    end = rule_optimize[self].end;
    cslen = strlen(charset);
    bzero(str,32);

    for (len=start;len<=end;len++)
    {
        switch (len)
        {
            case 1:
                for (c1=0;c1<cslen;c1++) 
                {
                    str[0] = charset[c1];
                    str[1] = 0;
                    cb(str,self);
                }
                break;
            case 2:
                for (c1=0;c1<cslen;c1++) 
                for (c2=0;c2<cslen;c2++) 
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = 0;
                    cb(str,self);
                }
                break;
            case 3:
                for (c1=0;c1<cslen;c1++) 
                for (c2=0;c2<cslen;c2++) 
                for (c3=0;c3<cslen;c3++) 
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = 0;
                    cb(str,self);
                }
                break;
            case 4:
                for (c1=0;c1<cslen;c1++) 
                for (c2=0;c2<cslen;c2++) 
                for (c3=0;c3<cslen;c3++) 
                for (c4=0;c4<cslen;c4++) 
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = 0;
                    cb(str,self);
                }
                break;
            case 5:
                for (c1=0;c1<cslen;c1++) 
                for (c2=0;c2<cslen;c2++) 
                for (c3=0;c3<cslen;c3++) 
                for (c4=0;c4<cslen;c4++) 
                for (c5=0;c5<cslen;c5++) 
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = charset[c11];
                    str[11] = 0;
                    cb(str,self);
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
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = charset[c11];
                    str[11] = charset[c12];
                    str[12] = 0;
                    cb(str,self);
                }
                break;
        }
    }
    bzero(str,32);
    cb(str,self);
}

void rule_offload_may_add_set(callback_final_t cb, int self)
{
    char str[32];

    bzero(str,32);
    cb(str,self);
    rule_offload_add_set(cb, self);
}



void rule_offload_add_cset(callback_final_t cb, int self)
{
    char *charset;
    int len,start,end;
    int c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12;
    char str[32];

    charset = rule_optimize[self].charset;
    start = rule_optimize[self].start;
    end = rule_optimize[self].end;
    bzero(str,32);

    for (len=start;len<=end;len++)
    {
	switch (len)
	{
    	    case 1:
                for (c1=0;c1<strlen(charset);c1++) 
                {
                    str[0] = charset[c1];
                    str[1] = 0;
                    cb(str,self);
                }
                break;
            case 2:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = 0;
                    cb(str,self);
                }
                break;
            case 3:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = 0;
                    cb(str,self);
                }
                break;
           case 4:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = 0;
                    cb(str,self);
                }
                break;
            case 5:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = 0;
                    cb(str,self);
                }
                break;
           case 6:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = 0;
                    cb(str,self);
                }
                break;
            case 7:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = 0;
                    cb(str,self);
                }
                break;
            case 8:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                for (c8=0;c8<strlen(charset);c8++) 
                if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = 0;
                    cb(str,self);
                }
                break;
            case 9:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                for (c8=0;c8<strlen(charset);c8++) 
                if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
                for (c9=0;c9<strlen(charset);c9++) 
                if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = 0;
                    cb(str,self);
                }
                break;
            case 10:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                for (c8=0;c8<strlen(charset);c8++) 
                if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
                for (c9=0;c9<strlen(charset);c9++) 
                if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
                for (c10=0;c10<strlen(charset);c10++) 
                if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = 0;
                    cb(str,self);
                }
                break;
            case 11:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                for (c8=0;c8<strlen(charset);c8++) 
                if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
                for (c9=0;c9<strlen(charset);c9++) 
                if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
                for (c10=0;c10<strlen(charset);c10++) 
                if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
                for (c11=0;c11<strlen(charset);c11++) 
                if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = charset[c11];
                    str[11] = 0;
                    cb(str,self);
                }
		break;
            case 12:
                for (c1=0;c1<strlen(charset);c1++) 
                for (c2=0;c2<strlen(charset);c2++) 
                if (c2!=c1) 
                for (c3=0;c3<strlen(charset);c3++) 
                if ((c3!=c1)&&(c3!=c2))
                for (c4=0;c4<strlen(charset);c4++) 
                if ((c4!=c1)&&(c4!=c2)&&(c4!=c3))
                for (c5=0;c5<strlen(charset);c5++) 
                if ((c5!=c1)&&(c5!=c2)&&(c5!=c3)&&(c5!=c4))
                for (c6=0;c6<strlen(charset);c6++) 
                if ((c6!=c1)&&(c6!=c2)&&(c6!=c3)&&(c6!=c4)&&(c6!=c5))
                for (c7=0;c7<strlen(charset);c7++) 
                if ((c7!=c1)&&(c7!=c2)&&(c7!=c3)&&(c7!=c4)&&(c7!=c5)&&(c7!=c6))
                for (c8=0;c8<strlen(charset);c8++) 
                if ((c8!=c1)&&(c8!=c2)&&(c8!=c3)&&(c8!=c4)&&(c8!=c5)&&(c8!=c6)&&(c8!=c7))
                for (c9=0;c9<strlen(charset);c9++) 
                if ((c9!=c1)&&(c9!=c2)&&(c9!=c3)&&(c9!=c4)&&(c9!=c5)&&(c9!=c6)&&(c9!=c7)&&(c9!=c8))
                for (c10=0;c10<strlen(charset);c10++) 
                if ((c10!=c1)&&(c10!=c2)&&(c10!=c3)&&(c10!=c4)&&(c10!=c5)&&(c10!=c6)&&(c10!=c7)&&(c10!=c8)&&(c10!=c9))
                for (c11=0;c11<strlen(charset);c11++) 
                if ((c11!=c1)&&(c11!=c2)&&(c11!=c3)&&(c11!=c4)&&(c11!=c5)&&(c11!=c6)&&(c11!=c7)&&(c11!=c8)&&(c11!=c9)&&(c11!=c10))
                for (c12=0;c12<strlen(charset);c12++) 
                if ((c12!=c1)&&(c12!=c2)&&(c12!=c3)&&(c12!=c4)&&(c12!=c5)&&(c12!=c6)&&(c12!=c7)&&(c12!=c8)&&(c12!=c9)&&(c12!=c10)&&(c12!=c11))
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = charset[c9];
                    str[9] = charset[c10];
                    str[10] = charset[c11];
                    str[11] = charset[c12];
                    str[12] = 0;
                    cb(str,self);
                }
                break;
            default:
                cb(str,self);
                break;
        }
    }
    bzero(str,32);
    cb(str,self);
}


void rule_offload_may_add_cset(callback_final_t cb, int self)
{
    char str[32];

    bzero(str,32);
    cb(str,self);
    rule_offload_add_cset(cb, self);
}



void rule_offload_add_markov(callback_final_t cb, int self)
{
    char *charset;
    int len,start,end;
    int c1,c2,c3,c4,c5,c6,c7,c8;
    char str[32];
    int markov0[88];
    int markov1[88][88];
    char markov_statfile[1024];
    char buf[1024];
    int cnt1,cnt2;
    int threshold;
    FILE *fd;

    charset = markov_charset;
    start = rule_optimize[self].start;
    end = rule_optimize[self].end;
    threshold = rule_optimize[self].threshold;

    strcpy(markov_statfile, rule_optimize[self].statfile);
    sprintf(buf,DATADIR"/hashkill/markov/%s.stat",markov_statfile);
    fd = fopen(buf,"r");
    if (!fd)
    {
        sprintf(buf,"%s.stat",markov_statfile);
        fd = fopen(buf,"r");
        if (!fd)
        {
            elog("Cannot open Markov statfile: %s\n",buf);
            return;
        }
    }
    fgets(buf, 255, fd);
    buf[strlen(buf)-1] = 0;
    fgets(buf, 255, fd);
    if (threshold==0) threshold = atoi(buf);
    for (cnt1=0;cnt1<88;cnt1++) fscanf(fd, "%c %d\n", (char *)&c1, &markov0[cnt1]);
    for (cnt1=0;cnt1<88;cnt1++) 
    for (cnt2=0;cnt2<88;cnt2++) 
    {
        fscanf(fd, "%c %c %d\n", (char *)&c1, (char *)&c2, &markov1[cnt1][cnt2]);
    }
    fclose(fd);
    bzero(str,32);

    for (len=start;len<=end;len++)
    {
        switch (len)
        {
            case 1:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = 0;
                    cb(str,self);
                }
                break;
            case 2:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = 0;
                    cb(str,self);
                }
                break;
            case 3:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = 0;
                    cb(str,self);
                }
                break;
            case 4:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                for (c4=0;c4<88;c4++) if (markov1[c3][c4]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = 0;
                    cb(str,self);
                }
                break;
            case 5:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                for (c4=0;c4<88;c4++) if (markov1[c3][c4]>threshold)
                for (c5=0;c5<88;c5++) if (markov1[c4][c5]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = 0;
                    cb(str,self);
                }
                break;
            case 6:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                for (c4=0;c4<88;c4++) if (markov1[c3][c4]>threshold)
                for (c5=0;c5<88;c5++) if (markov1[c4][c5]>threshold)
                for (c6=0;c6<88;c6++) if (markov1[c5][c6]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = 0;
                    cb(str,self);
                }
                break;
            case 7:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                for (c4=0;c4<88;c4++) if (markov1[c3][c4]>threshold)
                for (c5=0;c5<88;c5++) if (markov1[c4][c5]>threshold)
                for (c6=0;c6<88;c6++) if (markov1[c5][c6]>threshold)
                for (c7=0;c7<88;c7++) if (markov1[c6][c7]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = 0;
                    cb(str,self);
                }
                break;
            case 8:
                for (c1=0;c1<88;c1++) if (markov0[c1]>threshold)
                for (c2=0;c2<88;c2++) if (markov1[c1][c2]>threshold)
                for (c3=0;c3<88;c3++) if (markov1[c2][c3]>threshold)
                for (c4=0;c4<88;c4++) if (markov1[c3][c4]>threshold)
                for (c5=0;c5<88;c5++) if (markov1[c4][c5]>threshold)
                for (c6=0;c6<88;c6++) if (markov1[c5][c6]>threshold)
                for (c7=0;c7<88;c7++) if (markov1[c6][c7]>threshold)
                for (c8=0;c8<88;c8++) if (markov1[c7][c8]>threshold)
                {
                    str[0] = charset[c1];
                    str[1] = charset[c2];
                    str[2] = charset[c3];
                    str[3] = charset[c4];
                    str[4] = charset[c5];
                    str[5] = charset[c6];
                    str[6] = charset[c7];
                    str[7] = charset[c8];
                    str[8] = 0;
                    cb(str,self);
                }
                break;
            default:
                cb(str,self);
                break;
        }
    }
    bzero(str,32);
    cb(str,self);
}


void rule_offload_may_add_markov(callback_final_t cb, int self)
{
    char str[32];

    bzero(str,32);
    cb(str,self);
    rule_offload_add_markov(cb, self);
}




/* helper function for numrange gpu offload */
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
    j=0;i--;
    while ((i>j))
    {
        tmp=dest[j];
        dest[j]=dest[i];
        dest[i]=tmp;
        i--;j++;
    }
}


void rule_offload_add_numrange(callback_final_t cb, int self)
{
    int len,start,end;
    char str[32];

    start = rule_optimize[self].start;
    end = rule_optimize[self].end;
    bzero(str,32);

    for (len=start;len<=end;len++)
    {
        str[0]=0;
        numtostr(len,0,str);
        cb(str,self);
    }
    bzero(str,32);
    cb(str,self);
}


void rule_offload_may_add_numrange(callback_final_t cb, int self)
{
    char str[32];

    bzero(str,32);
    cb(str,self);
    rule_offload_add_numrange(cb, self);
}


void rule_offload_add_fastdict(callback_final_t cb, int self)
{
    FILE *fp=NULL;
    char str[16];
    char filename[1024];
    struct stat st;
    int len;

    strcpy(filename,rule_optimize[self].statfile);
    bzero(str,32);
    if (lstat(filename,&st) != 0)
    {
	sprintf(filename,DATADIR"/hashkill/dict/%s",rule_optimize[self].statfile);
        if (stat(filename,&st) != 0)
        {
    	    elog("Could not open dictionary: %s\n",filename);
            exit(1);
        }
    }
    fp=fopen(filename,"r");
    if (!fp)
    {
        elog("Could not open dictionary: %s\n",filename);
        exit(1);
    }
    while (!feof(fp))
    {
	bzero(str,16);
	fgets(str,16,fp);
	len=strlen(str)-1;
	if (str[len]=='\n') str[len]=0;
	if (str[len-1]=='\r') str[len-1]=0;
	cb(str,self);
    }
    bzero(str,16);
    cb(str,self);
}


void rule_offload_may_add_fastdict(callback_final_t cb, int self)
{
    char str[16];

    bzero(str,16);
    cb(str,self);
    rule_offload_add_fastdict(cb, self);
}




void rule_offload_perform(callback_final_t cb, int self)
{
        switch (rule_optimize[self].type)
        {
            case optimize_add_set: 
                rule_offload_add_set(cb,self);
                break;
            case optimize_may_add_set: 
                rule_offload_may_add_set(cb,self);
                break;
            case optimize_add_cset: 
                rule_offload_add_cset(cb,self);
                break;
            case optimize_may_add_cset: 
                rule_offload_may_add_cset(cb,self);
                break;
            case optimize_add_markov: 
                rule_offload_add_markov(cb,self);
                break;
            case optimize_may_add_markov: 
                rule_offload_may_add_markov(cb,self);
                break;
            case optimize_add_numrange: 
                rule_offload_add_numrange(cb,self);
                break;
            case optimize_may_add_numrange: 
                rule_offload_may_add_numrange(cb,self);
                break;
            case optimize_add_fastdict: 
                rule_offload_add_fastdict(cb,self);
                break;
            case optimize_may_add_fastdict: 
                rule_offload_may_add_fastdict(cb,self);
                break;

            default:
                rule_offload_add_none(cb,self);
        }
}



void suggest_rule_attack(void)
{
    wlog("Markov/bruteforce attacks on GPU are not practical for that plugin. Use rule-based attack instead!\n%s","");
    if (attack_method == attack_method_simple_bruteforce)
    {
	if (strlen(hashlist_file)>1)
	{
	    wlog("If you intend to try bruteforce attack anyway, try the following:\n%s","");
	    wlog("hashkill -p %s -f %s -r brute -a %d:%d:%s:%s\n",get_current_plugin(),hashlist_file,bruteforce_start,bruteforce_end,bruteforce_set1,bruteforce_set2);
	}
	else
	{
	    wlog("If you intend to try bruteforce attack anyway, try the following:\n%s","");
	    wlog("hashkill -p %s '%s' -r brute -a %d:%d:%s:%s\n",get_current_plugin(),hash_cmdline,bruteforce_start,bruteforce_end,bruteforce_set1,bruteforce_set2);
	}
    }

    if (attack_method == attack_method_markov)
    {
	if (strlen(hashlist_file)>1)
	{
	    wlog("If you intend to try bruteforce attack anyway, try the following:\n%s","");
	    wlog("hashkill -p %s -f %s -r markov -a 1:%d:%s:%d\n",get_current_plugin(),hashlist_file,markov_max_len,markovstat,markov_threshold);
	}
	else
	{
	    wlog("If you intend to try bruteforce attack anyway, try the following:\n%s","");
	    wlog("hashkill -p %s' %s' -r markov -a 1:%d:%s:%d\n",get_current_plugin(),hash_cmdline,markov_max_len,markovstat,markov_threshold);
	}
    }
}

void cancel_crack_threads(void)
{
    int a;

    for (a=0;a<nwthreads;a++) pthread_cancel(crack_threads[a]);
}

