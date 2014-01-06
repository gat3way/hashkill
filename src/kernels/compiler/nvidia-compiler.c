#include "compiler.h"
#include <sys/types.h>
#include <fcntl.h>

int iter = 0;

int compile(char *filename, char *buildparams)
{
    int i = 0;
    int j=0;
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
    int smiter=0;
    char archs[8][5] = { "sm10", "sm11", "sm12", "sm13", "sm20", "sm21", "sm30", "sm35" };
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
        if( strncmp(pbuf, "NVIDIA",6) == 0 )
        {
            platform = platforms[i];
            break;
        }
        //printf("Platform found :%s\n",pbuf);
    }

    if( platform == (cl_platform_id)NULL )
    {
        fprintf( stderr, "Could not find an NVidia platform. Exiting.\n" );
        return(0);
    }


    cprops[0] = CL_CONTEXT_PLATFORM;
    cprops[1] = (cl_context_properties)platform;
    cprops[2] = (cl_context_properties)0;
    context = _clCreateContextFromType( cprops, CL_DEVICE_TYPE_GPU, NULL, NULL, &err );
    checkErr( "clCreateContextFromType", err );
    program = _clCreateProgramWithSource( context, 1, (const char**)&programSrc, NULL, &err );
    checkErr( "clCreateProgramWithSource", err );
    err = _clGetProgramInfo( program, CL_PROGRAM_NUM_DEVICES, sizeof(nDevices),&nDevices, NULL );
    checkErr( "clGetProgramInfo", err );
    devices = (cl_device_id *)malloc( sizeof(cl_device_id) * nDevices );
    err = _clGetProgramInfo( program, CL_PROGRAM_DEVICES,sizeof(cl_device_id)*nDevices, devices, NULL );
    checkErr( "clGetProgramInfo", err );


    for (smiter=0;smiter<7;smiter++)
    {
	
	#define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
	#define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
	int ccmax=0;
	int compute_capability_major,compute_capability_minor;
	for (j=0;j<nDevices;j++)
	{
	    _clGetDeviceInfo(devices[j], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
	    _clGetDeviceInfo(devices[j], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
	    if ((compute_capability_major*10+compute_capability_minor)>ccmax) ccmax=compute_capability_major*10+compute_capability_minor;
	}
	
	switch (ccmax)
	{
	    case 10: if (smiter>0) smiter=7; break;
	    case 11: if (smiter>1) smiter=7; break;
	    case 12: if (smiter>2) smiter=7; break;
	    case 13: if (smiter>3) smiter=7; break;
	    case 20: if (smiter>4) smiter=7; break;
	    case 21: if (smiter>5) smiter=7; break;
	    case 30: if (smiter>6) smiter=7; break;
	}

	for (i=0;i<1; i++)
	{
    	    j=0;
    	    cl_device_type devType;
    	    char pbuf[100];
    	    err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    checkErr( "clGetDeviceInfo", err );

	    char flags[100];
	    if (optdisable==1) sprintf(flags,"%s  -cl-nv-maxrregcount=64 ",buildparams);
	    else sprintf(flags,"%s ",buildparams);

	    switch (smiter)
	    {
		case 0:
		    sprintf(flags,"%s -cl-nv-arch sm_10 -DSM10",flags);
		    printf("%s: building for sm_10\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 1:
		    sprintf(flags,"%s -cl-nv-arch sm_11",flags);
		    printf("%s: building for sm_11\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 2:
		    sprintf(flags,"%s -cl-nv-arch sm_12",flags);
		    printf("%s: building for sm_12\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 3:
		    sprintf(flags,"%s -cl-nv-arch sm_13",flags);
		    printf("%s: building for sm_13\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 4:
		    sprintf(flags,"%s -cl-nv-arch sm_20 ",flags);
		    printf("%s: building for sm_20\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 5:
		    sprintf(flags,"%s -cl-nv-arch sm_21 -DSM21",flags);
		    printf("%s: building for sm_21\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
		case 6:
		    sprintf(flags,"%s -cl-nv-arch sm_30 ",flags);
		    printf("%s: building for sm_30\n",filename);
		    printf("%s: flags = %s\n",filename,flags);
		    break;
	    }
	    char *eflags="";
	    err = _clBuildProgramNoErr( program, 1, &devices[i], flags, NULL, NULL );
	    if (err!=CL_SUCCESS)
	    {
    		int log_size;
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, (size_t *)&log_size);
        	char *build_log = malloc(log_size+1);
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, log_size, build_log, NULL);
        	build_log[log_size] = '\0';
		checkErr( "clBuildProgram", err );
        	printf("Log:\n==============\n%s\n",build_log);
        	exit(1);
	    }

	    binary_sizes = (size_t *)malloc( sizeof(size_t));
	    binaries = (char **)malloc( sizeof(char *));

	    err = _clGetProgramInfo( program, CL_PROGRAM_BINARY_SIZES, sizeof(size_t)*(nDevices), binary_sizes, NULL );
	    checkErr( "clGetProgramInfo", err );

	    if( binary_sizes[i] != 0 )
	    {
    		binaries[i] = (char *)malloc( sizeof(char)*binary_sizes[i] );
    		switch (smiter)
    		{
    		    case 0: 
    			printf("%s: compilation for sm_10 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 1: 
    			printf("%s: compilation for sm_11 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 2: 
    			printf("%s: compilation for sm_12 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 3: 
    			printf("%s: compilation for sm_13 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 4: 
    			printf("%s: compilation for sm_20 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 5: 
    			printf("%s: compilation for sm_21 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		    case 6: 
    			printf("%s: compilation for sm_30 successful (size = %d KB)\n",filename,binary_sizes[i]/1024);
    			break;
    		}
	    }
	    else
	    {
    		binaries[i]=NULL;
	    }
	    err = _clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(char *), binaries, NULL );
	    checkErr( "clGetProgramInfo", err );

    	    FILE *output = NULL;
    	    char outfilename[100];
    	    err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    checkErr( "clGetDeviceINfo", err );
	    switch (smiter)
	    {
		case 0:
		    sprintf(pbuf,"sm10");
		    break;
		case 1:
		    sprintf(pbuf,"sm11");
		    break;
		case 2:
		    sprintf(pbuf,"sm12");
		    break;
		case 3:
		    sprintf(pbuf,"sm13");
		    break;
		case 4:
		    sprintf(pbuf,"sm20");
		    break;
		case 5:
		    sprintf(pbuf,"sm21");
		    break;
		case 6:
		    sprintf(pbuf,"sm30");
		    break;
	    }

    	    if (strstr(buildparams,"SINGLE_MODE"))
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SDM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_SD_%s.ptx", filename, pbuf );
    		}
    		else
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_S_%s.ptx", filename, pbuf );
    		}
    	    }
    	    else
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_DM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_D_%s.ptx", filename, pbuf );
    		}
    		else 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_M_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s__%s.ptx", filename, pbuf );
    		}
    	    }

            if( binary_sizes[j] != 0 )
            {
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
                int fd = open(outfilename,O_RDONLY);
                size_t fsize = lseek(fd,0,SEEK_END);
                close(fd);
                switch (smiter)
                {
            	    case 0:
            		printf("%s: compressed sm_10 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 1:
            		printf("%s: compressed sm_11 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 2:
            		printf("%s: compressed sm_12 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 3:
            		printf("%s: compressed sm_13 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 4:
            		printf("%s: compressed sm_20 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 5:
            		printf("%s: compressed sm_21 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	    case 6:
            		printf("%s: compressed sm_30 kernel (compressed size = %d KB)\n",filename,fsize/1024);
            		break;
            	}
                free(ofname);
            }

	}
	//_clReleaseContext(context);
	free(binary_sizes);
	free(binaries);
    }

    free(platforms);
    free(devices);
    return (0);
}




int compile_big16(char *filename, char *buildparams)
{
    int i = 0;
    int j=0;
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
    int smiter=0;
    char archs[7][5] = { "sm10", "sm11", "sm12", "sm13", "sm20", "sm21", "sm30" };
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
        if( strncmp(pbuf, "NVIDIA",6) == 0 )
        {
            platform = platforms[i];
            break;
        }
        //printf("Platform found :%s\n",pbuf);
    }

    if( platform == (cl_platform_id)NULL )
    {
        fprintf( stderr, "Could not find an NVidia platform. Exiting.\n" );
        return(0);
    }


    cprops[0] = CL_CONTEXT_PLATFORM;
    cprops[1] = (cl_context_properties)platform;
    cprops[2] = (cl_context_properties)0;
    context = _clCreateContextFromType( cprops, CL_DEVICE_TYPE_GPU, NULL, NULL, &err );
    checkErr( "clCreateContextFromType", err );
    program = _clCreateProgramWithSource( context, 1, (const char**)&programSrc, NULL, &err );
    checkErr( "clCreateProgramWithSource", err );
    err = _clGetProgramInfo( program, CL_PROGRAM_NUM_DEVICES, sizeof(nDevices),&nDevices, NULL );
    checkErr( "clGetProgramInfo", err );
    devices = (cl_device_id *)malloc( sizeof(cl_device_id) * nDevices );
    err = _clGetProgramInfo( program, CL_PROGRAM_DEVICES,sizeof(cl_device_id)*nDevices, devices, NULL );
    checkErr( "clGetProgramInfo", err );

    smiter = iter;
    //for (smiter=0;smiter<7;smiter++)
    {
	
	#define CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV       0x4000
	#define CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV       0x4001
	int ccmax=0;
	int compute_capability_major,compute_capability_minor;
	for (j=0;j<nDevices;j++)
	{
	    _clGetDeviceInfo(devices[j], CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, sizeof(cl_uint), &compute_capability_major, NULL);
	    _clGetDeviceInfo(devices[j], CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, sizeof(cl_uint), &compute_capability_minor, NULL);
	    if ((compute_capability_major*10+compute_capability_minor)>ccmax) ccmax=compute_capability_major*10+compute_capability_minor;
	}
	
	switch (ccmax)
	{
	    case 10: if (smiter>0) smiter=8; break;
	    case 11: if (smiter>1) smiter=8; break;
	    case 12: if (smiter>2) smiter=8; break;
	    case 13: if (smiter>3) smiter=8; break;
	    case 20: if (smiter>4) smiter=8; break;
	    case 21: if (smiter>5) smiter=8; break;
	    case 30: if (smiter>6) smiter=8; break;
	    case 35: if (smiter>7) smiter=8; break;
	}

	for (i=0;i<1; i++)
	{
    	    j=0;
    	    cl_device_type devType;
    	    char pbuf[100];
    	    err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    checkErr( "clGetDeviceInfo", err );

	    char flags[100];
	    if (optdisable==1) sprintf(flags,"%s  -cl-nv-maxrregcount=64 ",buildparams);
	    else sprintf(flags,"%s ",buildparams);

	    switch (smiter)
	    {
		case 0:
		    sprintf(flags,"%s -cl-nv-arch sm_10 -DSM10",flags);
		    break;
		case 1:
		    sprintf(flags,"%s -cl-nv-arch sm_11",flags);
		    break;
		case 2:
		    sprintf(flags,"%s -cl-nv-arch sm_12",flags);
		    break;
		case 3:
		    sprintf(flags,"%s -cl-nv-arch sm_13",flags);
		    break;
		case 4:
		    sprintf(flags,"%s -cl-nv-arch sm_20 ",flags);
		    break;
		case 5:
		    sprintf(flags,"%s -cl-nv-arch sm_21 -DSM21",flags);
		    break;
		case 6:
		    sprintf(flags,"%s -cl-nv-arch sm_30 ",flags);
		    break;
		case 7:
		    sprintf(flags,"%s -cl-nv-arch sm_35 ",flags);
		    break;
	    }
	    char *eflags="";
	    err = _clBuildProgramNoErr( program, 1, &devices[i], flags, NULL, NULL );
	    if (err!=CL_SUCCESS)
	    {
    		int log_size;
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, 0, NULL, (size_t *)&log_size);
        	char *build_log = malloc(log_size+1);
        	_clGetProgramBuildInfo(program, devices[i], CL_PROGRAM_BUILD_LOG, log_size, build_log, NULL);
        	build_log[log_size] = '\0';
		checkErr( "clBuildProgram", err );
        	printf("Log:\n==============\n%s\n",build_log);
        	exit(0);
	    }

	    binary_sizes = (size_t *)malloc( sizeof(size_t));
	    binaries = (char **)malloc( sizeof(char *));

	    err = _clGetProgramInfo( program, CL_PROGRAM_BINARY_SIZES, sizeof(size_t)*(nDevices), binary_sizes, NULL );
	    checkErr( "clGetProgramInfo", err );

	    if( binary_sizes[i] != 0 )
	    {
    		binaries[i] = (char *)malloc( sizeof(char)*binary_sizes[i] );
	    }
	    else
	    {
    		binaries[i]=NULL;
	    }
	    err = _clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(char *), binaries, NULL );
	    checkErr( "clGetProgramInfo", err );

    	    FILE *output = NULL;
    	    char outfilename[100];
    	    err = _clGetDeviceInfo( devices[i], CL_DEVICE_NAME, sizeof(pbuf),pbuf, NULL );
    	    checkErr( "clGetDeviceINfo", err );
	    switch (smiter)
	    {
		case 0:
		    sprintf(pbuf,"sm10");
		    break;
		case 1:
		    sprintf(pbuf,"sm11");
		    break;
		case 2:
		    sprintf(pbuf,"sm12");
		    break;
		case 3:
		    sprintf(pbuf,"sm13");
		    break;
		case 4:
		    sprintf(pbuf,"sm20");
		    break;
		case 5:
		    sprintf(pbuf,"sm21");
		    break;
		case 6:
		    sprintf(pbuf,"sm30");
		    break;
		case 7:
		    sprintf(pbuf,"sm35");
		    break;
	    }

    	    if (strstr(buildparams,"SINGLE_MODE"))
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SDM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_SD_%s.ptx", filename, pbuf );
    		}
    		else
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_SM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_S_%s.ptx", filename, pbuf );
    		}
    	    }
    	    else
    	    {
    		if (strstr(buildparams,"DOUBLE")) 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_DM_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s_D_%s.ptx", filename, pbuf );
    		}
    		else 
    		{
    		    if (strstr(buildparams,"MAX8")) sprintf(outfilename, "%s_M_%s.ptx", filename, pbuf );
    		    else sprintf(outfilename, "%s__%s.ptx", filename, pbuf );
    		}
    	    }

            if( binary_sizes[j] != 0 )
            {
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
	//_clReleaseContext(context);
	free(binary_sizes);
	free(binaries);
    }

    free(platforms);
    free(devices);
    return (0);
}

int main(int argc, char *argv[])
{
    int cdouble=0;
    int csingle=0;
    int cmax8=0;

    if (argc<3) usage();

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
	iter = atoi(argv[3]);
        //printf("\nCompiling %s without flags (BIG16, iter=%d)...\n",argv[1],iter);
	compile_big16(argv[1],"");
	return 0;
    }

    //printf("\nCompiling %s without flags...\n",argv[1]);
    compile(argv[1],"");
    if (csingle==1)
    {
	//printf("\nCompiling %s with SINGLE_MODE...\n",argv[1]);
	compile(argv[1],"-DSINGLE_MODE");
    }
    if (cdouble==1)
    {
	//printf("\nCompiling %s with DOUBLE...\n",argv[1]);
	compile(argv[1],"-DDOUBLE");
    }

    if (cmax8==1)
    {
	//printf("\nCompiling %s with MAX8...\n",argv[1]);
	compile(argv[1],"-DMAX8");
    }


    if ((csingle==1) && (cdouble==1))
    {
	//printf("\nCompiling %s with SINGLE_MODE and DOUBLE...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DSINGLE_MODE");
    }

    if ((csingle==1) && (cdouble==1) && (cmax8==1))
    {
	//printf("\nCompiling %s with SINGLE_MODE and DOUBLE and MAX8...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DSINGLE_MODE -DMAX8");
    }

    if ((csingle==1) && (cmax8==1))
    {
	//printf("\nCompiling %s with SINGLE_MODE and MAX8...\n",argv[1]);
	compile(argv[1],"-DSINGLE_MODE -DMAX8");
    }

    if ((cdouble==1) && (cmax8==1))
    {
	//printf("\nCompiling %s with DOUBLE and MAX8...\n",argv[1]);
	compile(argv[1],"-DDOUBLE -DMAX8");
    }
    return 0;
}
