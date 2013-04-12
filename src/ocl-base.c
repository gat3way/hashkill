/* 
 * ocl-base.c
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
#include <dlfcn.h>
#include <stdlib.h>
#include "err.h"
#include "ocl-base.h"
#include "hashinterface.h"

void *dll;


/* OpenCL original protos */
typedef cl_int (*CLENQUEUEREADBUFFER)(cl_command_queue,cl_mem,cl_bool,size_t,size_t,void*,cl_uint,const cl_event*,cl_event*);
typedef cl_int (*CLSETKERNELARG)(cl_kernel,cl_uint,size_t,const void *);
typedef cl_int (*CLENQUEUENDRANGEKERNEL)(cl_command_queue,cl_kernel,cl_uint,const size_t *,const size_t *,const size_t *,cl_uint,const cl_event *,cl_event *);
typedef void * (*CLENQUEUEMAPBUFFER)(cl_command_queue,cl_mem,cl_bool,cl_map_flags,size_t,size_t,cl_uint,const cl_event *,cl_event *,cl_int *);
typedef cl_int (*CLENQUEUEWRITEBUFFER)(cl_command_queue,cl_mem,cl_bool,size_t,size_t,const void *,cl_uint ,const cl_event *,cl_event *);
typedef void * (*CLENQUEUEUNMAPMEMOBJECT)(cl_command_queue, cl_mem,void *,cl_uint,const cl_event *,cl_event *);
typedef cl_kernel (*CLCREATEKERNEL)(cl_program,const char *,cl_int *);
typedef cl_mem (*CLCREATEBUFFER)(cl_context,cl_mem_flags,size_t,void *,cl_int *);
typedef cl_command_queue (*CLCREATECOMMANDQUEUE)(cl_context,cl_device_id,cl_command_queue_properties,cl_int *);
typedef cl_context (*CLCREATECONTEXT)(cl_context_properties *,cl_uint,const cl_device_id *,void *pfn_notify (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *,cl_int *);
typedef cl_context (*CLCREATECONTEXTFROMTYPE)(cl_context_properties *properties,cl_device_type  device_type,void  (*pfn_notify) (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *user_data,cl_int *errcode_ret);
typedef cl_int (*CLGETDEVICEINFO)(cl_device_id device,cl_device_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
typedef cl_int (*CLGETDEVICEIDS)(cl_platform_id platform,cl_device_type device_type,cl_uint num_entries,cl_device_id *devices,cl_uint *num_devices);
typedef cl_program (*CLCREATEPROGRAMWITHBINARY)(cl_context context,cl_uint num_devices,const cl_device_id *device_list,const size_t *lengths,const unsigned char **binaries,cl_int *binary_status,cl_int *errcode_ret);
typedef cl_int (*CLBUILDPROGRAM)(cl_program program,cl_uint num_devices,const cl_device_id *device_list,const char *options,void (*pfn_notify)(cl_program, void *user_data),void *user_data);
typedef cl_int (*CLGETPLATFORMIDS)(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms);
typedef cl_program (*CLCREATEPROGRAMWITHSOURCE)(cl_context context,cl_uint count,const char **strings,const size_t *lengths,cl_int *errcode_ret);
typedef cl_int (*CLGETPROGRAMINFO)(cl_program program,cl_program_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
typedef cl_int (*CLGETPROGRAMBUILDINFO)(cl_program  program,cl_device_id  device,cl_program_build_info  param_name,size_t  param_value_size,void  *param_value,size_t  *param_value_size_ret);
typedef cl_int (*CLRELEASECONTEXT)(cl_context context);
typedef cl_int (*CLUNLOADCOMPILER)(void);
typedef cl_int (*CLRELEASEPROGRAM)(cl_program program);
typedef cl_int (*CLRELEASEKERNEL)(cl_kernel kernel);
typedef cl_int (*CLFLUSH)(cl_command_queue queue);
typedef cl_int (*CLFINISH)(cl_command_queue queue);
typedef cl_int (*CLGETPLATFORMINFO)(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret);



/* OpenCL functions used */
cl_int _clEnqueueReadBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_read,size_t offset,size_t cb,void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
cl_int _clSetKernelArg(cl_kernel kernel,cl_uint arg_index,size_t arg_size,const void *arg_value);
cl_int _clEnqueueNDRangeKernel(cl_command_queue command_queue,  cl_kernel kernel,cl_uint work_dim,const size_t *global_work_offset,const size_t *global_work_size,const size_t *local_work_size,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
void * _clEnqueueMapBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_map,cl_map_flags map_flags,size_t offset,size_t cb,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event,cl_int *errcode_ret);
cl_int _clEnqueueWriteBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_write,size_t offset,size_t cb,const void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
void * _clEnqueueUnmapMemObject(cl_command_queue command_queue, cl_mem memobj,void *mapped_ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
cl_kernel _clCreateKernel(cl_program  program,const char *kernel_name,cl_int *errcode_ret);
cl_mem _clCreateBuffer(cl_context context,cl_mem_flags flags,size_t size,void *host_ptr,cl_int *errcode_ret);
cl_command_queue _clCreateCommandQueue(cl_context context,cl_device_id device,cl_command_queue_properties properties,cl_int *errcode_ret);
cl_context _clCreateContext(cl_context_properties *properties,cl_uint num_devices,const cl_device_id *devices,void *pfn_notify (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *user_data,cl_int *errcode_ret);
cl_context _clCreateContextFromType(cl_context_properties *properties,cl_device_type  device_type,void  (*pfn_notify) (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *user_data,cl_int *errcode_ret);
cl_int _clGetDeviceInfo(cl_device_id device,cl_device_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
cl_int _clGetDeviceInfoNoErr(cl_device_id device,cl_device_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
cl_int _clGetDeviceIDs(cl_platform_id platform,cl_device_type device_type,cl_uint num_entries,cl_device_id *devices,cl_uint *num_devices);
cl_int _clGetDeviceIDsNoErr(cl_platform_id platform,cl_device_type device_type,cl_uint num_entries,cl_device_id *devices,cl_uint *num_devices);
cl_program _clCreateProgramWithBinary(cl_context context,cl_uint num_devices,const cl_device_id *device_list,const size_t *lengths,const unsigned char **binaries,cl_int *binary_status,cl_int *errcode_ret);
cl_int _clBuildProgram(cl_program program,cl_uint num_devices,const cl_device_id *device_list,const char *options,void (*pfn_notify)(cl_program, void *user_data),void *user_data);
cl_int _clBuildProgramNoErr(cl_program program,cl_uint num_devices,const cl_device_id *device_list,const char *options,void (*pfn_notify)(cl_program, void *user_data),void *user_data);
cl_int _clGetPlatformIDs(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms);
cl_program _clCreateProgramWithSource(cl_context context,cl_uint count,const char **strings,const size_t *lengths,cl_int *errcode_ret);
cl_int _clGetProgramInfo(cl_program program,cl_program_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
cl_int _clGetProgramBuildInfo(cl_program  program,cl_device_id  device,cl_program_build_info  param_name,size_t  param_value_size,void  *param_value,size_t  *param_value_size_ret);
cl_int _clReleaseContext(cl_context context);
cl_int _clReleaseProgram(cl_program program);
cl_int _clReleaseKernel(cl_kernel kernel);
cl_int _clFlush(cl_command_queue queue);
cl_int _clFinish(cl_command_queue queue);
cl_int _clUnloadCompiler(void);
cl_int _clGetPlatformInfo(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret);
cl_int _clGetPlatformInfoNoErr(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret);
cl_int _clGetPlatformIDsNoErr(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms);
static void checkErr(char *func, cl_int err);
hash_stat initialize_ocl(void);



CLENQUEUEREADBUFFER clEnqueueReadBuffer = NULL;
CLSETKERNELARG clSetKernelArg = NULL;
CLENQUEUENDRANGEKERNEL clEnqueueNDRangeKernel = NULL;
CLENQUEUEMAPBUFFER clEnqueueMapBuffer = NULL;
CLENQUEUEWRITEBUFFER clEnqueueWriteBuffer = NULL;
CLENQUEUEUNMAPMEMOBJECT clEnqueueUnmapMemObject = NULL;
CLCREATEKERNEL clCreateKernel = NULL;
CLCREATEBUFFER clCreateBuffer = NULL;
CLCREATECOMMANDQUEUE clCreateCommandQueue = NULL;
CLCREATECONTEXT clCreateContext = NULL;
CLCREATECONTEXTFROMTYPE clCreateContextFromType = NULL;
CLGETDEVICEINFO clGetDeviceInfo = NULL;
CLGETDEVICEIDS clGetDeviceIDs = NULL;
CLCREATEPROGRAMWITHSOURCE clCreateProgramWithSource = NULL;
CLCREATEPROGRAMWITHBINARY clCreateProgramWithBinary = NULL;
CLBUILDPROGRAM clBuildProgram = NULL;
CLGETPLATFORMIDS clGetPlatformIDs = NULL;
CLGETPROGRAMINFO clGetProgramInfo = NULL;
CLGETPROGRAMBUILDINFO clGetProgramBuildInfo = NULL;
CLRELEASECONTEXT clReleaseContext = NULL;
CLRELEASEKERNEL clReleaseKernel = NULL;
CLFLUSH clFlush = NULL;
CLFINISH clFinish = NULL;
CLRELEASEPROGRAM clReleaseProgram = NULL;
CLGETPLATFORMINFO clGetPlatformInfo = NULL;
CLUNLOADCOMPILER clUnloadCompiler = NULL;



static void * GetProcAddress( void * pLibrary, const char * name)
{
    return dlsym( pLibrary, name);
}


hash_stat initialize_opencl(void)
{
    dll = dlopen( "libOpenCL.so", RTLD_LAZY/*|RTLD_GLOBAL*/);
    if (!dll)
    {
	dll = dlopen( "libOpenCL.so.1", RTLD_LAZY/*|RTLD_GLOBAL*/);
	if (!dll)
	{
	    return hash_err;
	}
    }

    clEnqueueReadBuffer = (CLENQUEUEREADBUFFER)GetProcAddress(dll,"clEnqueueReadBuffer");
    if (!clEnqueueReadBuffer)
    {
	dlclose(dll);
	return hash_err;
    }
    clSetKernelArg = (CLSETKERNELARG)GetProcAddress(dll,"clSetKernelArg");
    if (!clSetKernelArg)
    {
	dlclose(dll);
	return hash_err;
    }
    clEnqueueNDRangeKernel = (CLENQUEUENDRANGEKERNEL)GetProcAddress(dll,"clEnqueueNDRangeKernel");
    if (!clEnqueueNDRangeKernel)
    {
	dlclose(dll);
	return hash_err;
    }
    clEnqueueMapBuffer = (CLENQUEUEMAPBUFFER)GetProcAddress(dll,"clEnqueueMapBuffer");
    if (!clEnqueueMapBuffer)
    {
	dlclose(dll);
	return hash_err;
    }
    clEnqueueWriteBuffer = (CLENQUEUEWRITEBUFFER)GetProcAddress(dll,"clEnqueueWriteBuffer");
    if (!clEnqueueWriteBuffer)
    {
	dlclose(dll);
	return hash_err;
    }
    clEnqueueUnmapMemObject = (CLENQUEUEUNMAPMEMOBJECT)GetProcAddress(dll,"clEnqueueUnmapMemObject");
    if (!clEnqueueUnmapMemObject)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateKernel = (CLCREATEKERNEL)GetProcAddress(dll,"clCreateKernel");
    if (!clCreateKernel)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateBuffer = (CLCREATEBUFFER)GetProcAddress(dll,"clCreateBuffer");
    if (!clCreateBuffer)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateCommandQueue = (CLCREATECOMMANDQUEUE)GetProcAddress(dll,"clCreateCommandQueue");
    if (!clCreateCommandQueue)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateContext = (CLCREATECONTEXT)GetProcAddress(dll,"clCreateContext");
    if (!clCreateContext)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateContextFromType = (CLCREATECONTEXTFROMTYPE)GetProcAddress(dll,"clCreateContextFromType");
    if (!clCreateContextFromType)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetDeviceInfo = (CLGETDEVICEINFO)GetProcAddress(dll,"clGetDeviceInfo");
    if (!clGetDeviceInfo)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetDeviceIDs = (CLGETDEVICEIDS)GetProcAddress(dll,"clGetDeviceIDs");
    if (!clGetDeviceIDs)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateProgramWithSource = (CLCREATEPROGRAMWITHSOURCE)GetProcAddress(dll,"clCreateProgramWithSource");
    if (!clCreateProgramWithSource)
    {
	dlclose(dll);
	return hash_err;
    }
    clCreateProgramWithBinary = (CLCREATEPROGRAMWITHBINARY)GetProcAddress(dll,"clCreateProgramWithBinary");
    if (!clCreateProgramWithBinary)
    {
	dlclose(dll);
	return hash_err;
    }
    clBuildProgram = (CLBUILDPROGRAM)GetProcAddress(dll,"clBuildProgram");
    if (!clBuildProgram)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetPlatformIDs = (CLGETPLATFORMIDS)GetProcAddress(dll,"clGetPlatformIDs");
    if (!clGetPlatformIDs)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetProgramInfo = (CLGETPROGRAMINFO)GetProcAddress(dll,"clGetProgramInfo");
    if (!clGetProgramInfo)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetProgramBuildInfo = (CLGETPROGRAMBUILDINFO)GetProcAddress(dll,"clGetProgramBuildInfo");
    if (!clGetProgramBuildInfo)
    {
	dlclose(dll);
	return hash_err;
    }
    clReleaseContext = (CLRELEASECONTEXT)GetProcAddress(dll,"clReleaseContext");
    if (!clReleaseContext)
    {
	dlclose(dll);
	return hash_err;
    }
    clReleaseKernel = (CLRELEASEKERNEL)GetProcAddress(dll,"clReleaseKernel");
    if (!clReleaseKernel)
    {
	dlclose(dll);
	return hash_err;
    }
    clFlush = (CLFLUSH)GetProcAddress(dll,"clFlush");
    if (!clFlush)
    {
	dlclose(dll);
	return hash_err;
    }
    clFinish = (CLFLUSH)GetProcAddress(dll,"clFinish");
    if (!clFinish)
    {
	dlclose(dll);
	return hash_err;
    }
    clReleaseProgram = (CLRELEASEPROGRAM)GetProcAddress(dll,"clReleaseProgram");
    if (!clReleaseProgram)
    {
	dlclose(dll);
	return hash_err;
    }
    clGetPlatformInfo = (CLGETPLATFORMINFO)GetProcAddress(dll,"clGetPlatformInfo");
    if (!clGetPlatformInfo)
    {
	return hash_err;
    }
    clUnloadCompiler = (CLUNLOADCOMPILER)GetProcAddress(dll,"clUnloadCompiler");
    if (!clUnloadCompiler)
    {
	return hash_err;
    }
    return hash_ok;
}



static void checkErr(char *func, cl_int err)
{
    if( err != CL_SUCCESS )
    {
        switch( err )
        {
    	    case CL_DEVICE_NOT_FOUND:  		elog("%s: CL_DEVICE_NOT_FOUND",func); break;
    	    case CL_DEVICE_NOT_AVAILABLE:  	elog("%s: CL_DEVICE_NOT_AVAILABLE",func); break;
    	    case CL_MEM_OBJECT_ALLOCATION_FAILURE: elog("%s: CL_MEM_OBJECT_ALLOCATION_FAILURE",func); break;
    	    case CL_OUT_OF_RESOURCES: 		elog("%s: CL_OUT_OF_RESOURCES",func); break;
    	    case CL_OUT_OF_HOST_MEMORY: 	elog("%s: CL_OUT_OF_HOST_MEMORY",func); break;
    	    case CL_MAP_FAILURE: 		elog("%s: CL_MAP_FAILURE",func); break;
    	    case CL_COMPILE_PROGRAM_FAILURE: elog("%s: CL_COMPILE_PROGRAM_FAILURE",func); break;
    	    case CL_BUILD_PROGRAM_FAILURE:  	elog("%s: CL_BUILD_PROGRAM_FAILURE",func); break;
    	    case CL_COMPILER_NOT_AVAILABLE: 	elog("%s: CL_COMPILER_NOT_AVAILABLE",func); break;
    	    case CL_INVALID_BINARY:         	elog("%s: CL_INVALID_BINARY",func); break;
    	    case CL_INVALID_BUILD_OPTIONS:  	elog("%s: CL_INVALID_BUILD_OPTIONS",func); break;
    	    case CL_INVALID_CONTEXT:        	elog("%s: CL_INVALID_CONTEXT",func); break;
    	    case CL_INVALID_DEVICE:         	elog("%s: CL_INVALID_DEVICE",func); break;
    	    case CL_INVALID_DEVICE_TYPE:    	elog("%s: CL_INVALID_DEVICE_TYPE",func); break;
    	    case CL_INVALID_OPERATION:      	elog("%s: CL_INVALID_OPERATION",func); break;
    	    case CL_INVALID_PLATFORM:       	elog("%s: CL_INVALID_PLATFORM",func); break;
    	    case CL_INVALID_PROGRAM:        	elog("%s: CL_INVALID_PROGRAM",func); break;
    	    case CL_INVALID_VALUE:          	elog("%s: CL_INVALID_VALUE",func); break;
    	    case CL_INVALID_KERNEL_NAME:    	elog("%s: CL_INVALID_KERNEL_NAME",func); break;
    	    case CL_INVALID_COMMAND_QUEUE:  	elog("%s: CL_INVALID_COMMAND_QUEUE",func); break;
    	    case CL_INVALID_KERNEL_ARGS:    	elog("%s: CL_INVALID_KERNEL_ARGS",func); break;
    	    case CL_INVALID_WORK_DIMENSION: 	elog("%s: CL_INVALID_WORK_DIMENSION",func); break;
    	    case CL_INVALID_WORK_GROUP_SIZE:	elog("%s: CL_INVALID_WORK_GROUP_SIZE",func); break;
    	    case CL_INVALID_WORK_ITEM_SIZE: 	elog("%s: CL_INVALID_WORK_ITEM_SIZE",func); break;
    	    case CL_INVALID_BUFFER_SIZE:	elog("%s: CL_INVALID_BUFFER_SIZE",func); break;
    	    case CL_INVALID_GLOBAL_WORK_SIZE:   elog("%s: CL_INVALID_GLOBAL_WORK_SIZE",func); break;
    	    case CL_INVALID_COMPILER_OPTIONS:   elog("%s: CL_INVALID_COMPILER_OPTIONS",func); break;
    	    case CL_PLATFORM_NOT_FOUND_KHR:   	elog("%s: PLATFORM_NOT_FOUND_KHR",func); break;
    	    default:                            elog("%s: Unknown error code: %d", func,err); break;
        }
        printf("\n\n");
        exit(1);
    }
}



cl_int _clEnqueueReadBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_read,size_t offset,size_t cb,void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event)
{
    cl_int err;

    err = clEnqueueReadBuffer(command_queue,buffer,blocking_read,offset,cb,ptr,num_events_in_wait_list,event_wait_list,event);
    checkErr("clEnqueueReadBuffer",err);
    return err;
}


cl_int _clSetKernelArg(cl_kernel kernel,cl_uint arg_index,size_t arg_size,const void *arg_value)
{
    cl_int err;

    err = clSetKernelArg(kernel, arg_index, arg_size, arg_value);
    checkErr("clSetKernelArg",err);
    return err;
}


cl_int _clEnqueueNDRangeKernel(cl_command_queue command_queue,  cl_kernel kernel,cl_uint work_dim,const size_t *global_work_offset,const size_t *global_work_size,const size_t *local_work_size,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event)
{
    cl_int err;

    err = clEnqueueNDRangeKernel(command_queue,kernel,work_dim,global_work_offset,global_work_size,local_work_size,num_events_in_wait_list,event_wait_list,event);
    checkErr("clEnqueueNDRangeKernel",err);
    return err;
}


void * _clEnqueueMapBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_map,cl_map_flags map_flags,size_t offset,size_t cb,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event,cl_int *errcode_ret)
{
    void *dst;
    dst =  clEnqueueMapBuffer(command_queue,buffer,blocking_map,map_flags,offset,cb,num_events_in_wait_list,event_wait_list,event,errcode_ret);
    if (!dst) 
    {
	checkErr("clEnqueueNDRangeKernel",*errcode_ret);
    }
    return dst;
}


cl_int _clEnqueueWriteBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_write,size_t offset,size_t cb,const void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event)
{
    cl_int err;

    err = clEnqueueWriteBuffer(command_queue,buffer,blocking_write,offset,cb,ptr,num_events_in_wait_list,event_wait_list,event);
    checkErr("clEnqueueWriteBuffer",err);
    return err;
}


void * _clEnqueueUnmapMemObject(cl_command_queue command_queue, cl_mem memobj,void *mapped_ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event)
{
    clEnqueueUnmapMemObject(command_queue,memobj,mapped_ptr,num_events_in_wait_list,event_wait_list,event);
    return NULL;
}


cl_kernel _clCreateKernel(cl_program  program,const char *kernel_name,cl_int *errcode_ret)
{
    cl_kernel kernel;
    cl_int err;

    kernel = clCreateKernel(program,kernel_name,&err);
    checkErr("clCreateKernel",err);
    return kernel;
}

cl_mem _clCreateBuffer(cl_context context,cl_mem_flags flags,size_t size,void *host_ptr,cl_int *errcode_ret)
{
    cl_mem mem;
    cl_int err;

    mem = clCreateBuffer(context,flags,size,host_ptr,&err);
    checkErr("clCreateBuffer",err);
    return mem;
}


cl_command_queue _clCreateCommandQueue(cl_context context,cl_device_id device,cl_command_queue_properties properties,cl_int *errcode_ret)
{
    cl_command_queue queue;
    cl_int err;

    queue = clCreateCommandQueue(context,device,properties,&err);
    checkErr("clCreateCommandQueue",err);
    return queue;
}


cl_context _clCreateContext(cl_context_properties *properties,cl_uint num_devices,const cl_device_id *devices,void *pfn_notify (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *user_data,cl_int *errcode_ret)
{
    cl_context context;
    cl_int err;

    context = clCreateContext(properties,num_devices,devices,NULL,user_data,&err);
    checkErr("clCreateContext",err);
    return context;
}


cl_context _clCreateContextFromType(cl_context_properties *properties,cl_device_type  device_type,void (*pfn_notify) (const char *errinfo,const void *private_info,size_t cb,void *user_data),void *user_data,cl_int *errcode_ret)
{
    cl_context context;
    cl_int err;

    context = clCreateContextFromType(properties,device_type,NULL,user_data,&err);
    checkErr("clCreateContextFromType",err);
    return context;
}


cl_int _clGetDeviceInfo(cl_device_id device,cl_device_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret)
{
    cl_int err;

    err = clGetDeviceInfo(device,param_name,param_value_size,param_value,param_value_size_ret);
    checkErr("clGetDeviceInfo",err);
    return err;
}

cl_int _clGetDeviceInfoNoErr(cl_device_id device,cl_device_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret)
{
    cl_int err;

    err = clGetDeviceInfo(device,param_name,param_value_size,param_value,param_value_size_ret);
    return err;
}


cl_int _clGetDeviceIDs(cl_platform_id platform,cl_device_type device_type,cl_uint num_entries,cl_device_id *devices,cl_uint *num_devices)
{
    cl_int err;

    err = clGetDeviceIDs(platform,device_type,num_entries,devices,num_devices);
    checkErr("clGetDeviceIDs",err);
    return err;
}

cl_int _clGetDeviceIDsNoErr(cl_platform_id platform,cl_device_type device_type,cl_uint num_entries,cl_device_id *devices,cl_uint *num_devices)
{
    cl_int err;

    err = clGetDeviceIDs(platform,device_type,num_entries,devices,num_devices);
    return err;
}


cl_program _clCreateProgramWithBinary(cl_context context,cl_uint num_devices,const cl_device_id *device_list,const size_t *lengths,const unsigned char **binaries,cl_int *binary_status,cl_int *errcode_ret)
{
    cl_program program;
    cl_int err;

    program = clCreateProgramWithBinary(context,num_devices,device_list,lengths,binaries,binary_status,&err);
    checkErr("clCreateProgramWithBinary",err);
    return program;
}


cl_int _clBuildProgram(cl_program program,cl_uint num_devices,const cl_device_id *device_list,const char *options,void (*pfn_notify)(cl_program, void *user_data),void *user_data)
{
    cl_int err;

    err = clBuildProgram(program,num_devices,device_list,options,pfn_notify,user_data);
    checkErr("clBuildProgram",err);
    return err;
}

cl_int _clBuildProgramNoErr(cl_program program,cl_uint num_devices,const cl_device_id *device_list,const char *options,void (*pfn_notify)(cl_program, void *user_data),void *user_data)
{
    cl_int err;

    err = clBuildProgram(program,num_devices,device_list,options,pfn_notify,user_data);
    return err;
}


cl_int _clGetPlatformIDs(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms)
{
    cl_int err;

    err = clGetPlatformIDs(num_entries,platforms,num_platforms);
    checkErr("clGetPlatformIDs",err);
    return err;
}

cl_int _clGetPlatformIDsNoErr(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms)
{
    cl_int err;

    err = clGetPlatformIDs(num_entries,platforms,num_platforms);
    return err;
}


cl_program _clCreateProgramWithSource(cl_context context,cl_uint count,const char **strings,const size_t *lengths,cl_int *errcode_ret)
{
    cl_program program;
    cl_int err;

    program = clCreateProgramWithSource(context,count,strings,lengths,&err);
    checkErr("clCreateProgramWithSource",err);
    return program;
}


cl_int _clGetProgramInfo(cl_program program,cl_program_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret)
{
    cl_int err;

    err = clGetProgramInfo(program,param_name,param_value_size,param_value,param_value_size_ret);
    checkErr("clGetProgramInfo",err);
    return err;
}


cl_int _clGetProgramBuildInfo(cl_program  program,cl_device_id  device,cl_program_build_info  param_name,size_t  param_value_size,void  *param_value,size_t  *param_value_size_ret)
{
    cl_int err;

    err = clGetProgramBuildInfo(program,device,param_name,param_value_size,param_value,param_value_size_ret);
    checkErr("clGetProgramBuildInfo",err);
    return err;
}


cl_int _clReleaseContext(cl_context context)
{
    cl_int err;

    err = clReleaseContext(context);
    checkErr("clReleaseContext",err);
    return err;
}

cl_int _clReleaseKernel(cl_kernel kernel)
{
    cl_int err;

    err = clReleaseKernel(kernel);
    checkErr("clReleaseKernel",err);
    return err;
}

cl_int _clFlush(cl_command_queue queue)
{
    cl_int err;

    err = clFlush(queue);
    checkErr("clFlush",err);
    return err;
}
cl_int _clFinish(cl_command_queue queue)
{
    cl_int err;

    err = clFinish(queue);
    checkErr("clFinish",err);
    return err;
}

cl_int _clUnloadCompiler(void)
{
    cl_int err;

    err = clUnloadCompiler();
    checkErr("clUnloadCompiler",err);
    return err;
}



cl_int _clReleaseProgram(cl_program program)
{
    cl_int err;

    err = clReleaseProgram(program);
    checkErr("clReleaseProgram",err);
    return err;
}

cl_int _clGetPlatformInfo(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret)
{
    cl_int err;

    err = clGetPlatformInfo(platform,param_name,param_value_size,param_value,param_value_size_ret);
    checkErr("clGetPlatformInfo",err);
    return err;
}

cl_int _clGetPlatformInfoNoErr(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret)
{
    cl_int err;

    err = clGetPlatformInfo(platform,param_name,param_value_size,param_value,param_value_size_ret);
    return err;
}
