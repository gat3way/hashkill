#include "compiler.h"

int bfimagic=0;
int optdisable=0;
int big16=0;

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
        case CL_INVALID_PLATFORM:       fprintf (stderr, "CL_INVALID_PLATFORM"); break;
        case CL_INVALID_PROGRAM:        fprintf (stderr, "CL_INVALID_PROGRAM"); break;
        case CL_INVALID_VALUE:          fprintf (stderr, "CL_INVALID_VALUE"); break;
        case CL_OUT_OF_HOST_MEMORY:     fprintf (stderr, "CL_OUT_OF_HOST_MEMORY"); break;
        default:                        fprintf (stderr, "Unknown error code: %d", err); break;
        }
        fprintf (stderr, "\n");
    }
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

void usage()
{
    printf("Usage: compile kernel.cl <nsdmb>\n");
    exit(1);
}

/* Local Variables: */
/* c-basic-offset: 4 */
/* End: */
