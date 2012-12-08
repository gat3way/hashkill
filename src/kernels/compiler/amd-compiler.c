#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include "lzma/lzma.h"
#include "err.h"
#include "ocl-base.h"

#define CL_CONTEXT_OFFLINE_DEVICES_AMD        0x403F

void checkErr( char * func, cl_int err );


char *readProgramSrc( char * filename );
int bfimagic=0;
int optdisable=0;
int big16=0;

#define ALGO_THRESHOLD 100
#define ALGO_THRESHOLD_BIG 180
#define ALGO_THRESHOLD_XXL 280
#define ALGO_THRESHOLD_SMALL 16



static void bfi_int_magic(unsigned char *kernel, int len,int shortk)
{
    unsigned int j,i,k;
    uint64_t dword,dwordrep;
    int algo_threshold;
    unsigned int i1,i2;
    uint64_t q1,q2;
    unsigned short s1,s2;
    unsigned short entrysize,count,index;
    unsigned int ntoffset,noffset,moffset,size,offset,nindex,mindex;
    int ft=0;

    j=0;
    for (k=0;k<len-12;k++)
    {
	memcpy(&q1,&kernel[k],8);
	memcpy(&s1,&kernel[k+34],2);
	memcpy(&entrysize,&kernel[k+46],2);
	memcpy(&count,&kernel[k+48],2);
	memcpy(&index,&kernel[k+50],2);
	memcpy(&offset,&kernel[k+32],4);
	if ((q1==0x64010101464c457fLL)&&(s1==0))
	{
	    j=k;
	    moffset=offset;
	    break;
	}
    }
    mindex=j;
    j+=offset+index*entrysize+16;
    memcpy(&ntoffset,&kernel[j],4);
    memcpy(&size,&kernel[j+4],4);
    j=mindex+moffset;
    for (i=0;i<count;i++)
    {
	memcpy(&nindex,&kernel[j+i*entrysize],4);
	memcpy(&offset,&kernel[j+i*entrysize+16],4);
	memcpy(&size,&kernel[j+i*entrysize+20],4);
	//printf("nindex[%d]=%d offset[%d]=%d size[%d]=%d\n",i,nindex,i,offset,i,size);
	noffset = ntoffset+nindex;
	if (memcmp(&kernel[mindex+noffset],".text",5)==0) 
	{
	    for (k=(mindex+offset);k<(mindex+offset+size);k+=8)
	    {
		dword = *(uint64_t *)(kernel+k);
    		if ((uint64_t)(dword&0x9003f00002001000ULL)==0x0001a00000000000ULL)
    		{
        	    dwordrep = dword ^ (0x0001a00000000000ULL ^ 0x0000c00000000000ULL);
        	    *(uint64_t *)(kernel+k) = dwordrep;
    		}
	    }
	}
    }

}




static void bfi_int_magic_old(unsigned char *kernel, int len,int shortk)
{
    unsigned int j,i,k;
    uint64_t dword,dwordrep;
    int algo_threshold;
    
    if (shortk == 1) algo_threshold = 16;
    else if (shortk == 2) algo_threshold = ALGO_THRESHOLD_BIG;
    else if (shortk == 3) algo_threshold = ALGO_THRESHOLD_XXL;
    else algo_threshold = ALGO_THRESHOLD_SMALL;
    
    
    for (k=4;k<12;k++)
    {
        j=0;
        for (i=4+k;i<(len-8);i+=8)
        {
            dword = *(uint64_t *)(kernel + i);
            if  ((uint64_t)(dword&0x9003f00002001000ULL)==(uint64_t)(0x0001a00000000000ULL)) j++;
        }
        if (j>=algo_threshold)
        for (i=4+k;i<(len-8);i+=8)
        {
            dword = *(uint64_t *)(kernel + i);
            if ((uint64_t)(dword&0x9003f00002001000ULL)==0x0001a00000000000ULL)
            {
                dwordrep = dword ^ (0x0001a00000000000ULL ^ 0x0000c00000000000ULL);
                *(uint64_t *)(kernel+i) = dwordrep;
            }
            
        }
    }
}







int compile(char *filename, char *buildparams)
{

    int i = 0;
    int j=0;
    int k;
    cl_int err = CL_SUCCESS;
    char * programSrc = NULL;
    cl_int nPlatforms = 0;
    cl_platform_id *platforms = NULL;
    cl_platform_id platform = (cl_platform_id)NULL;
    cl_context_properties cprops[5];
    cl_context context;
    size_t nDevices = 0;
    cl_device_id *devices;
    cl_program program = NULL;
    size_t * binary_sizes = NULL;
    char ** binaries = NULL;
    char fullname[200];
    int cdouble=0;
    int csingle=0;
    int cmax8=0;
    char *ofname;


    sprintf(fullname,"../%s.cl",filename);
    programSrc = readProgramSrc(fullname);
    if( programSrc == NULL )
    {
        fprintf( stderr, "Unable to open %s. Exiting.\n", fullname );
        return(-1);
    }

    err = _clGetPlatformIDs( 0, NULL, &nPlatforms );
    checkErr( "clGetPlatformIDs", err );
    if( nPlatforms == 0 )
    {
        fprintf( stderr, "Cannot continue without any platforms. Exiting.\n" );
        return(-1);
    }
    platforms = (cl_platform_id *)malloc( sizeof(cl_platform_id) * nPlatforms );
    err = _clGetPlatformIDs( nPlatforms, platforms, NULL );
    checkErr( "clGetPlatformIDs", err );

    for( i = 0; i < nPlatforms; i++ )
    {
        char pbuf[100];
        err = _clGetPlatformInfo( platforms[i], CL_PLATFORM_VENDOR,
                                 sizeof(pbuf), pbuf, NULL );
        checkErr( "clGetPlatformInfo", err );
        if( strcmp(pbuf, "Advanced Micro Devices, Inc.") == 0 )
        {
            platform = platforms[i];
            break;
        }
        //printf("Platform found :%s\n",pbuf);
    }

    if( platform == (cl_platform_id)NULL )
    {
        fprintf( stderr, "Could not find an AMD platform. Exiting.\n" );
        return(0);
    }

    cprops[0] = CL_CONTEXT_PLATFORM;
    cprops[1] = (cl_context_properties)platform;
    cprops[2] = CL_CONTEXT_OFFLINE_DEVICES_AMD;
    cprops[3] = (cl_context_properties)1;
    cprops[4] = (cl_context_properties)NULL; 
    context = _clCreateContextFromType( cprops, CL_DEVICE_TYPE_GPU, NULL, NULL, &err );
    checkErr( "clCreateContextFromType", err );
    program = _clCreateProgramWithSource( context, 1, (const char**)&programSrc, NULL, &err );
    checkErr( "clCreateProgramWithSource", err );
    err = _clGetProgramInfo( program, CL_PROGRAM_NUM_DEVICES, sizeof(nDevices),&nDevices, NULL );
    checkErr( "clGetProgramInfo", err );
    devices = (cl_device_id *)malloc( sizeof(cl_device_id) * nDevices );
    err = _clGetProgramInfo( program, CL_PROGRAM_DEVICES,sizeof(cl_device_id)*nDevices, devices, NULL );
    checkErr( "clGetProgramInfo", err );
    
    for (i=0;i<nDevices; i++)
    {
        cl_device_type devType;
        char pbuf[100];
        err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
        checkErr( "clGetDeviceINfo", err );
        if (strstr(pbuf,"Dogs")) continue;
        if (strstr(pbuf,"Cats")) continue;
        if (strstr(pbuf,"Raccoons")) continue;

	printf("building for %s\n",pbuf);
	char flags[1000];
	char flags1[1000];
	//-save-temps=test
	if (strstr(pbuf,"ATI")) sprintf(flags,"-fno-bin-amdil -fno-bin-llvmir -fno-bin-source -DOLD_ATI   %s",buildparams);
	else if (strstr(pbuf,"Cayman"))  sprintf(flags,"-fno-bin-amdil -fno-bin-llvmir -fno-bin-source -DVLIW4  -Dcl_amd_media_ops2 %s",buildparams);
	else if ((strstr(pbuf,"Capeverde"))||(strstr(pbuf,"Pitcairn"))||(strstr(pbuf,"Tahiti")))  sprintf(flags,"-fno-bin-amdil -fno-bin-llvmir -fno-bin-source -DGCN  -Dcl_amd_media_ops2 %s",buildparams);
	else sprintf(flags,"-fno-bin-amdil -fno-bin-llvmir -fno-bin-source  -Dcl_amd_media_ops2  %s",buildparams);
	if (optdisable==1) sprintf(flags,"%s -cl-opt-disable -fno-bin-amdil -fno-bin-llvmir -fno-bin-source -Dcl_amd_media_ops2 -O0",flags);
	if (big16==1) 
	{
	strcpy(flags1,flags);
	for (k=0;k<16;k++)
	{
	    sprintf(flags,"%s -DLEN_%d",flags1,k);
	    err = _clBuildProgramNoErr( program, 1, &devices[i], flags, NULL, NULL );
	    if (err!=CL_SUCCESS)
	    {
		checkErr( "clBuildProgram", err );
    		int log_size;
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, (size_t *)&log_size);
        	char *build_log = malloc(log_size+1);
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, log_size, build_log, NULL);
        	build_log[log_size] = '\0';
        	printf("Log:\n==============\n%s\n",build_log);
        	exit(1);
	    }
	    binary_sizes = (size_t *)malloc( sizeof(size_t)*nDevices );
	    binaries = (char **)malloc( sizeof(char *)*nDevices );

	    err = _clGetProgramInfo( program, CL_PROGRAM_BINARY_SIZES, sizeof(size_t)*(nDevices), binary_sizes, NULL );
	    checkErr( "clGetProgramInfo", err );

	    for (j=0;j<nDevices; j++)
	    {
		if( binary_sizes[j] != 0 )
		{
    		    binaries[j] = (char *)malloc( sizeof(char)*binary_sizes[j] );
		}
		else
		{
    		    binaries[j]=NULL;
		}
		err = _clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(char *)*nDevices, binaries, NULL );
		checkErr( "clGetProgramInfo", err );

    		FILE *output = NULL;
    		char outfilename[1000];
    		cl_device_type devType;
    		char pbuf[100];
    		err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    		checkErr( "clGetDeviceINfo", err );

    		sprintf(outfilename, "%s%d__%s.bin", filename, k, pbuf );
		
    		if( binary_sizes[j] != 0 )
    		{
		    if ((!strstr(pbuf,"ATI"))&&(!strstr(pbuf,"Capeverde"))&&(!strstr(pbuf,"Tahiti"))&&(!strstr(pbuf,"Pitcairn"))&&(bfimagic!=0)) 
		    {
			bfi_int_magic(binaries[j],binary_sizes[j],0);
		    }
        	    output = fopen(outfilename, "wb" );
        	    fwrite( binaries[j], sizeof(char), binary_sizes[j], output );
        	    if( output == NULL )
        	    {
            		fprintf( stderr, "Unable to open %s for write. Exiting.\n",filename );
            		exit(-1);
        	    }
        	    fclose(output);
        	    ofname = kernel_compress(outfilename);
        	    if (!ofname) exit(1);
        	    unlink(outfilename);
        	    rename(ofname,outfilename);
        	    free(ofname);
        	    //printf("%s (%s)\n",outfilename,flags);
    		}
	    }
	    free(binary_sizes);
	    free(binaries);
	}
	goto next;
	}
	
	err = _clBuildProgramNoErr( program, 1, &devices[i], flags, NULL, NULL );
	if (err!=CL_SUCCESS)
	{
	    checkErr( "clBuildProgram", err );
    	    int log_size;
            _clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, (size_t *)&log_size);
            char *build_log = malloc(log_size+1);
            _clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, log_size, build_log, NULL);
            build_log[log_size] = '\0';
            printf("Log:\n==============\n%s\n",build_log);
            exit(1);
	}
	binary_sizes = (size_t *)malloc( sizeof(size_t)*nDevices );
	binaries = (char **)malloc( sizeof(char *)*nDevices );

	err = _clGetProgramInfo( program, CL_PROGRAM_BINARY_SIZES, sizeof(size_t)*(nDevices), binary_sizes, NULL );
	checkErr( "clGetProgramInfo", err );

	for (j=0;j<nDevices; j++)
	{
	    if( binary_sizes[j] != 0 )
	    {
    		binaries[j] = (char *)malloc( sizeof(char)*binary_sizes[j] );
	    }
	    else
	    {
    		binaries[j]=NULL;
	    }
	    err = _clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(char *)*nDevices, binaries, NULL );
	    checkErr( "clGetProgramInfo", err );

    	    FILE *output = NULL;
    	    char outfilename[1000];
    	    cl_device_type devType;
    	    char pbuf[100];
    	    err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    checkErr( "clGetDeviceINfo", err );

    	    if (strstr(buildparams,"SINGLE_MODE"))
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SDM_%s.bin", filename, pbuf );
    		    else sprintf(outfilename, "%s_SD_%s.bin", filename, pbuf );
    		}
    		else
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SM_%s.bin", filename, pbuf );
    		    else sprintf(outfilename, "%s_S_%s.bin", filename, pbuf );
    		}
    	    }
    	    else
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_DM_%s.bin", filename, pbuf );
    		    else sprintf(outfilename, "%s_D_%s.bin", filename, pbuf );
    		}
    		else 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_M_%s.bin", filename, pbuf );
    		    else sprintf(outfilename, "%s__%s.bin", filename, pbuf );
    		}
    	    }

    	    
    	    if( binary_sizes[j] != 0 )
    	    {
		if ((!strstr(pbuf,"ATI"))&&(!strstr(pbuf,"Capeverde"))&&(!strstr(pbuf,"Tahiti"))&&(!strstr(pbuf,"Pitcairn"))&&(bfimagic!=0)) 
		{
		    bfi_int_magic(binaries[j],binary_sizes[j],0);
		}
        	output = fopen(outfilename, "wb" );
        	fwrite( binaries[j], sizeof(char), binary_sizes[j], output );
        	if( output == NULL )
        	{
            	    fprintf( stderr, "Unable to open %s for write. Exiting.\n",filename );
            	    exit(-1);
        	}
        	fclose(output);
        	ofname = kernel_compress(outfilename);
        	if (!ofname) exit(1);
        	unlink(outfilename);
        	rename(ofname,outfilename);
        	free(ofname);
    	    }
	}
	free(binary_sizes);
	free(binaries);
	next:
	usleep(1000);
    }

    free(platforms);
    free(devices);
    return 0;
}

char *
readProgramSrc( char *filename )
{
    FILE * input = NULL;
    size_t size = 0;
    char * programSrc = NULL;

    input = fopen( filename, "rb" );
    if( input == NULL )
    {
        return( NULL );
    }
    fseek( input, 0L, SEEK_END );
    size = ftell( input );
    rewind( input );
    programSrc = (char *)malloc( size + 1 );
    fread( programSrc, sizeof(char), size, input );
    programSrc[size] = 0;
    fclose (input);

    return( programSrc );
}

void
checkErr( char *func, cl_int err )
{
    if( err != CL_SUCCESS )
    {
        fprintf( stderr, "%s(): ", func );
        switch( err )
        {
        case CL_BUILD_PROGRAM_FAILURE:  fprintf (stderr, "CL_BUILD_PROGRAM_FAILURE"); break;
        case CL_COMPILER_NOT_AVAILABLE: fprintf (stderr, "CL_COMPILER_NOT_AVAILABLE"); break;
        case CL_DEVICE_NOT_AVAILABLE:   fprintf (stderr, "CL_DEVICE_NOT_AVAILABLE"); break;
        case CL_DEVICE_NOT_FOUND:       fprintf (stderr, "CL_DEVICE_NOT_FOUND"); break;
        case CL_INVALID_BINARY:         fprintf (stderr, "CL_INVALID_BINARY"); break;
        case CL_INVALID_BUILD_OPTIONS:  fprintf (stderr, "CL_INVALID_BUILD_OPTIONS"); break;
        case CL_INVALID_CONTEXT:        fprintf (stderr, "CL_INVALID_CONTEXT"); break;
        case CL_INVALID_DEVICE:         fprintf (stderr, "CL_INVALID_DEVICE"); break;
        case CL_INVALID_DEVICE_TYPE:    fprintf (stderr, "CL_INVALID_DEVICE_TYPE"); break;
        case CL_INVALID_OPERATION:      fprintf (stderr, "CL_INVALID_OPERATION"); break;
        case CL_INVALID_PLATFORM:        fprintf (stderr, "CL_INVALID_PLATFORM"); break;
        case CL_INVALID_PROGRAM:        fprintf (stderr, "CL_INVALID_PROGRAM"); break;
        case CL_INVALID_VALUE:          fprintf (stderr, "CL_INVALID_VALUE"); break;
        case CL_OUT_OF_HOST_MEMORY:     fprintf (stderr, "CL_OUT_OF_HOST_MEMORY"); break;
        default:                        fprintf (stderr, "Unknown error code: %d", err); break;
        }
        fprintf (stderr, "\n");
    }
}



void usage()
{
    printf("Usage: compile kernel.cl <nsdmb>\n");
    exit(1);
}

int main(int argc, char *argv[])
{
    int cdouble=0;
    int csingle=0;
    int cmax8=0;


    if (argc!=3) usage();

    if (initialize_opencl() != hash_ok) 
    {
	printf("No OpenCL library found!\n");
	exit(0);
    }

    if (strstr(argv[2],"s")) csingle=1;
    if (strstr(argv[2],"d")) cdouble=1;
    if (strstr(argv[2],"m")) cmax8=1;
    if (strstr(argv[2],"b")) bfimagic=1;
    if (strstr(argv[2],"o")) optdisable=1;
    if (strstr(argv[2],"F")) big16=1;


    if (big16==1)
    {
	printf("\nCompiling %s with BIG16...\n",argv[1]);
	compile(argv[1],"");
	return 0;
    }

    printf("\nCompiling %s without flags...\n",argv[1]);
    compile(argv[1],"");
    if (csingle==1)
    {
	printf("\nCompiling %s with SINGLE_MODE...\n",argv[1]);
	compile(argv[1],"-DSINGLE_MODE");
    }
    if (cdouble==1)
    {
	printf("\nCompiling %s with DOUBLE...\n",argv[1]);
	compile(argv[1],"-DDOUBLE");
    }

    if (cmax8==1)
    {
	printf("\nCompiling %s with MAX8...\n",argv[1]);
	compile(argv[1],"-DMAX8");
    }


    if ((csingle==1) && (cdouble==1))
    {
	printf("\nCompiling %s with SINGLE_MODE and DOUBLE...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DSINGLE_MODE");
    }

    if ((csingle==1) && (cdouble==1) && (cmax8==1))
    {
	printf("\nCompiling %s with SINGLE_MODE and DOUBLE and MAX8...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DSINGLE_MODE -DMAX8");
    }

    if ((csingle==1) && (cmax8==1))
    {
	printf("\nCompiling %s with SINGLE_MODE and MAX8...\n",argv[1]);
	compile(argv[1],"-DSINGLE_MODE -DMAX8");
    }

    if ((cdouble==1) && (cmax8==1))
    {
	printf("\nCompiling %s with DOUBLE and MAX8...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DMAX8");
    }
    return 0;
}
