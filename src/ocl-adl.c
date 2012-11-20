#define LINUX

#include <dlfcn.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include "err.h"
#include "hashinterface.h"
#include "ocl-adl.h"
#include "ocl-threads.h"



#define ADL_MAX_PATH 256
#define ADL_OK 0

/* ADL structs */
typedef struct ADLPMActivity
{
        int iSize;
        int iEngineClock;
        int iMemoryClock;
        int iVddc;
        int iActivityPercent;
        int iCurrentPerformanceLevel;
        int iCurrentBusSpeed;
        int iCurrentBusLanes;
        int iMaximumBusLanes;
        int iReserved;
} ADLPMActivity;

typedef struct AdapterInfo
{
    int iSize;
    int iAdapterIndex;
    char strUDID[ADL_MAX_PATH]; 
    int iBusNumber;
    int iDeviceNumber;
    int iFunctionNumber;
    int iVendorID;
    char strAdapterName[ADL_MAX_PATH];
    char strDisplayName[ADL_MAX_PATH];
    int iPresent;
#if defined (_WIN32) || defined (_WIN64)
    int iExist;
    char strDriverPath[ADL_MAX_PATH];
    char strDriverPathExt[ADL_MAX_PATH];
    char strPNPString[ADL_MAX_PATH];
    int iOSDisplayIndex;
#endif
#if defined (LINUX)
    int iXScreenNum;
    int iDrvIndex;
    char strXScreenConfigName[ADL_MAX_PATH];
#endif
} AdapterInfo, *LPAdapterInfo;

typedef struct ADLTemperature
{
  int iSize;    
  int iTemperature;  
} ADLTemperature;

AdapterInfo adapterinfo[64];
pthread_mutex_t adlmutex = PTHREAD_MUTEX_INITIALIZER;

typedef int ( *ADL_OVERDRIVE5_CURRENTACTIVITY_GET ) ( int, ADLPMActivity*);
typedef int ( *ADL_ADAPTER_ADAPTERINFO_GET ) (LPAdapterInfo, int);
typedef int ( *ADL_OVERDRIVE5_TEMPERATURE_GET ) (int,int,ADLTemperature*);
void *dll;
ADL_OVERDRIVE5_CURRENTACTIVITY_GET ADL_Overdrive5_CurrentActivity_Get = NULL;
ADL_ADAPTER_ADAPTERINFO_GET  ADL_Adapter_AdapterInfo_Get  = NULL;
ADL_OVERDRIVE5_TEMPERATURE_GET ADL_Overdrive5_Temperature_Get = NULL;


typedef struct nvmlDevice_st* nvmlDevice_t;

typedef int ( *NVMLINIT ) ();
typedef int ( *NVMLSHUTDOWN ) ();
typedef int ( *NVMLDEVICEGETCOUNT ) (unsigned int *);
typedef int ( *NVMLDEVICEGETHANDLEBYINDEX ) (unsigned int, nvmlDevice_t*);
typedef int ( *NVMLDEVICEGETTEMPERATURE )( nvmlDevice_t, int, unsigned int *);
typedef int ( *NVMLDEVICEGETNAME )(nvmlDevice_t, char*, unsigned int);

void *nvdll;
NVMLINIT nvmlInit = NULL;
NVMLSHUTDOWN nvmlShutdown = NULL;
NVMLDEVICEGETCOUNT nvmlDeviceGetCount = NULL;
NVMLDEVICEGETHANDLEBYINDEX nvmlDeviceGetHandleByIndex = NULL;
NVMLDEVICEGETTEMPERATURE nvmlDeviceGetTemperature = NULL;
NVMLDEVICEGETNAME nvmlDeviceGetName = NULL;



static void * GetProcAddress( void * pLibrary, const char * name)
{
    return dlsym( pLibrary, name);
}


/* Initialize ADL/NVLM */
int setup_adl(void)
{
    int cnt,curdev,realdev=0,a;
    char dispname[255];
    void *dll;
    ADLPMActivity activity;
    ADLTemperature temperature;
    int libfound=0;


    if (ocl_gpu_tempthreshold)
    {
	hlog("Temperature threshold set to %d degrees C\n",ocl_gpu_tempthreshold);
    }
    else
    {
	hlog("Thermal monitoring disabled.\n%s","");
	return 3;
    }
    // Probe ADL
    dll = dlopen( "libatiadlxx.so", RTLD_LAZY|RTLD_GLOBAL);
    if (!dll)
    {
	goto nvidia;
    }
    
    ADL_Overdrive5_CurrentActivity_Get = (ADL_OVERDRIVE5_CURRENTACTIVITY_GET) GetProcAddress(dll,"ADL_Overdrive5_CurrentActivity_Get");
    if (!ADL_Overdrive5_CurrentActivity_Get)
    {
	goto nvidia;
    }
    ADL_Adapter_AdapterInfo_Get = (ADL_ADAPTER_ADAPTERINFO_GET) GetProcAddress(dll,"ADL_Adapter_AdapterInfo_Get");
    if (!ADL_Adapter_AdapterInfo_Get)
    {
	goto nvidia;
    }
    ADL_Overdrive5_Temperature_Get = (ADL_OVERDRIVE5_TEMPERATURE_GET) GetProcAddress(dll,"ADL_Overdrive5_Temperature_Get");
    if (!ADL_Overdrive5_Temperature_Get)
    {
	goto nvidia;
    }

    ADL_Adapter_AdapterInfo_Get(adapterinfo, sizeof(adapterinfo)*64);
    curdev=-1;
    realdev=0;
    strcpy(dispname,"NONE");
    for (cnt=0;cnt<64;cnt++)
    {
	if (adapterinfo[cnt].strUDID)
	if ((ADL_OK==ADL_Overdrive5_CurrentActivity_Get(cnt,&activity))&&(curdev!=(adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100)))
	{
	    curdev=adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100;
	    strcpy(dispname,adapterinfo[cnt].strUDID);
	    ADL_Overdrive5_Temperature_Get(cnt,0,&temperature);
	    hlog("GPU%d: %s [busy:%d%%] [temp:%dC]\n",realdev,adapterinfo[cnt].strAdapterName,activity.iActivityPercent,temperature.iTemperature/1000);
	    for (a=0;a<nwthreads;a++)
	    if ((wthreads[a].type==amd_thread)&&(wthreads[a].deviceid==realdev)) 
	    {
		wthreads[a].temperature=temperature.iTemperature/1000;
		wthreads[a].activity=activity.iActivityPercent;
	    }
	    realdev++;
	}
    }
    libfound=1;

    nvidia:

    nvdll = dlopen( "libnvidia-ml.so", RTLD_LAZY|RTLD_GLOBAL);
    if (!nvdll)
    {
	return libfound;
    }

    nvmlInit = (NVMLINIT) GetProcAddress(nvdll,"nvmlInit");
    if (!nvmlInit)
    {
	return libfound;
    }
    nvmlShutdown = (NVMLSHUTDOWN) GetProcAddress(nvdll,"nvmlShutdown");
    if (!nvmlShutdown)
    {
	return libfound;
    }
    nvmlDeviceGetCount = (NVMLDEVICEGETCOUNT) GetProcAddress(nvdll,"nvmlDeviceGetCount");
    if (!nvmlDeviceGetCount)
    {
	return libfound;
    }
    nvmlDeviceGetHandleByIndex = (NVMLDEVICEGETHANDLEBYINDEX) GetProcAddress(nvdll,"nvmlDeviceGetHandleByIndex");
    if (!nvmlDeviceGetHandleByIndex)
    {
	return libfound;
    }
    nvmlDeviceGetTemperature = (NVMLDEVICEGETTEMPERATURE) GetProcAddress(nvdll,"nvmlDeviceGetTemperature");
    if (!nvmlDeviceGetTemperature)
    {
	return libfound;
    }
    nvmlDeviceGetName = (NVMLDEVICEGETNAME) GetProcAddress(nvdll,"nvmlDeviceGetName");
    if (!nvmlDeviceGetName)
    {
	return libfound;
    }


    if (nvmlInit()!=0) return hash_err;
    unsigned int devnum;
    unsigned int nvtemp;
    nvmlDevice_t device;
    char cdispname[255];
    nvmlDeviceGetCount(&devnum);
    strcpy(dispname,"NONE");
    for (cnt=0;cnt<devnum;cnt++)
    {
	nvmlDeviceGetHandleByIndex(cnt,&device);
	nvmlDeviceGetTemperature(device,0,&nvtemp);
	nvmlDeviceGetName(device,cdispname,254);
	strcpy(dispname,cdispname);
	hlog("GPU%d: %s [temp:%dC]\n",cnt+realdev,cdispname,nvtemp);
	for (a=0;a<nwthreads;a++)
	if ((wthreads[a].type==nv_thread)&&(wthreads[a].deviceid==cnt)) 
	{
	    wthreads[a].temperature=nvtemp;
	    wthreads[a].activity=0;
	}
    }
    nvmlShutdown();
    if (libfound==1) libfound=3;
    else libfound=2;
    return libfound;
}



/* Get temps -ADL/NVML */
void adl_getstats(void)
{
    int cnt,curdev,realdev=0,a;
    char dispname[255];

    ADLPMActivity activity;
    ADLTemperature temperature;

    if (!ocl_gpu_tempthreshold) return;

    //ADL_Overdrive5_CurrentActivity_Get = (ADL_OVERDRIVE5_CURRENTACTIVITY_GET) GetProcAddress(dll,"ADL_Overdrive5_CurrentActivity_Get");
    if (!ADL_Overdrive5_CurrentActivity_Get)
    {
	goto nvidia;
    }
    //ADL_Adapter_AdapterInfo_Get = (ADL_ADAPTER_ADAPTERINFO_GET) GetProcAddress(dll,"ADL_Adapter_AdapterInfo_Get");
    if (!ADL_Adapter_AdapterInfo_Get)
    {
	goto nvidia;
    }
    //ADL_Overdrive5_Temperature_Get = (ADL_OVERDRIVE5_TEMPERATURE_GET) GetProcAddress(dll,"ADL_Overdrive5_Temperature_Get");
    if (!ADL_Overdrive5_Temperature_Get)
    {
	goto nvidia;
    }

    pthread_mutex_lock(&adlmutex);
    if (ADL_OK!=ADL_Adapter_AdapterInfo_Get(adapterinfo, sizeof(adapterinfo)*64)) goto nvidia;
    curdev=-1;
    realdev=0;
    for (cnt=0;cnt<64;cnt++)
    {
	if (adapterinfo[cnt].strUDID)
	if ((ADL_OK==ADL_Overdrive5_CurrentActivity_Get(cnt,&activity))&&(curdev!=(adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100)))
	{
	    curdev=adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100;
	    strcpy(dispname,adapterinfo[cnt].strUDID);
	    ADL_Overdrive5_Temperature_Get(cnt,0,&temperature);
	    for (a=0;a<nwthreads;a++)
	    if ((wthreads[a].type==amd_thread)&&(wthreads[a].deviceid==realdev)) 
	    {
		wthreads[a].temperature=temperature.iTemperature/1000;
		wthreads[a].activity=activity.iActivityPercent;
	    }
	    realdev++;
	}
    }
    pthread_mutex_unlock(&adlmutex);

    nvidia:
    if (!nvmlInit) return;
    if (!nvmlDeviceGetCount) return;
    if (!nvmlDeviceGetHandleByIndex) return;
    if (!nvmlDeviceGetTemperature) return;
    if (!nvmlShutdown) return;

    if (nvmlInit()!=0) return;
    unsigned int devnum;
    unsigned int nvtemp;
    nvmlDevice_t device;

    nvmlDeviceGetCount(&devnum);
    strcpy(dispname,"NONE");
    for (cnt=0;cnt<devnum;cnt++)
    {
	nvmlDeviceGetHandleByIndex(cnt,&device);
	nvmlDeviceGetTemperature(device,0,&nvtemp);
	for (a=0;a<nwthreads;a++)
	if ((wthreads[a].type==nv_thread)&&(wthreads[a].deviceid==cnt)) 
	{
	    wthreads[a].temperature=nvtemp;
	    wthreads[a].activity=0;
	}
    }
    nvmlShutdown();
}


void do_adl(void)
{
    int cnt,curdev,realcnt=0,a,realdev=0;
    ADLPMActivity activity;
    ADLTemperature temperature;

    if (!ocl_gpu_tempthreshold) return;

    //ADL_Overdrive5_CurrentActivity_Get = (ADL_OVERDRIVE5_CURRENTACTIVITY_GET) GetProcAddress(dll,"ADL_Overdrive5_CurrentActivity_Get");
    if (!ADL_Overdrive5_CurrentActivity_Get)
    {
	goto nvidia;
    }
    //ADL_Adapter_AdapterInfo_Get = (ADL_ADAPTER_ADAPTERINFO_GET) GetProcAddress(dll,"ADL_Adapter_AdapterInfo_Get");
    if (!ADL_Adapter_AdapterInfo_Get)
    {
	goto nvidia;
    }
    //ADL_Overdrive5_Temperature_Get = (ADL_OVERDRIVE5_TEMPERATURE_GET) GetProcAddress(dll,"ADL_Overdrive5_Temperature_Get");
    if (!ADL_Overdrive5_Temperature_Get)
    {
	goto nvidia;
    }

    pthread_mutex_lock(&adlmutex);
    ADL_Adapter_AdapterInfo_Get(adapterinfo, sizeof(adapterinfo)*64);
    pthread_mutex_unlock(&adlmutex);
    curdev=-1;
    char dispname[255];
    strcpy(dispname,"NONE");


    /* Locked AMD threads? Unlock them... */
    for (a=0;a<nwthreads;a++) if ((wthreads[a].templocked)&&(wthreads[a].type==amd_thread))
    {
	pthread_mutex_unlock(&wthreads[a].tempmutex);
	wthreads[a].templocked=0;
    }

    curdev=-1;
    realdev=0;
    pthread_mutex_lock(&adlmutex);
    for (cnt=0;cnt<64;cnt++)
    {
	if (adapterinfo[cnt].strUDID)
	if ((ADL_OK==ADL_Overdrive5_CurrentActivity_Get(cnt,&activity))&&(curdev!=(adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100)))
	{
	    curdev=adapterinfo[cnt].iDeviceNumber+adapterinfo[cnt].iBusNumber*100;
	    strcpy(dispname,adapterinfo[cnt].strUDID);
	    ADL_Overdrive5_Temperature_Get(cnt,0,&temperature);
	    for (a=0;a<nwthreads;a++)
	    if ((wthreads[a].type==amd_thread)&&(wthreads[a].deviceid==realdev)) 
	    {
		wthreads[a].temperature=temperature.iTemperature/1000;
		wthreads[a].activity=activity.iActivityPercent;
		if ((temperature.iTemperature/1000)>ocl_gpu_tempthreshold)
		{
		    printf("\n");
		    if (wthreads[a].first==1) wlog("Adapter%d: going beyond temperature threshold, temporarily disabling\n",realdev);
		    wthreads[a].templocked=1;
		    pthread_mutex_lock(&wthreads[a].tempmutex);
		}
	    }
	    realdev++;
	}
    }
    pthread_mutex_unlock(&adlmutex);

    nvidia:
    if (!nvmlInit) return;
    if (!nvmlDeviceGetCount) return;
    if (!nvmlDeviceGetHandleByIndex) return;
    if (!nvmlDeviceGetTemperature) return;
    if (!nvmlShutdown) return;

    if (nvmlInit()!=0) return;
    unsigned int devnum;
    unsigned int nvtemp;
    nvmlDevice_t device;


    /* Locked NVidia threads? Unlock them... */
    for (a=0;a<nwthreads;a++) if ((wthreads[a].templocked)&&(wthreads[a].type==nv_thread))
    {
	pthread_mutex_unlock(&wthreads[a].tempmutex);
	wthreads[a].templocked=0;
    }

    nvmlDeviceGetCount(&devnum);
    for (cnt=0;cnt<devnum;cnt++)
    {
	nvmlDeviceGetHandleByIndex(cnt,&device);
	nvmlDeviceGetTemperature(device,0,&nvtemp);
	for (a=0;a<nwthreads;a++)
	if ((wthreads[a].type==nv_thread)&&(wthreads[a].deviceid==cnt)) 
	{
	    wthreads[a].temperature=nvtemp;
	    wthreads[a].activity=0;
	    if (nvtemp>ocl_gpu_tempthreshold)
	    {
		printf("\n");
		wlog("Adapter%d: going beyond temperature threshold, temporarily disabling\n",realcnt+realdev);
		wthreads[a].templocked=1;
		pthread_mutex_lock(&wthreads[a].tempmutex);
	    }
	}
    }
    nvmlShutdown();
}



