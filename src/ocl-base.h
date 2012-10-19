/* ocl-base.h
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

#include <opencl-types.h>
#include <dlfcn.h>
#include "hashinterface.h"
#include "err.h"

#ifndef HASHOPENCL_H
#define HASHOPENCL_H

/* OpenCL functions used */
cl_int _clEnqueueReadBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_read,size_t offset,size_t cb,void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
cl_int _clSetKernelArg(cl_kernel kernel,cl_uint arg_index,size_t arg_size,const void *arg_value);
cl_int _clEnqueueNDRangeKernel(cl_command_queue command_queue,	cl_kernel kernel,cl_uint work_dim,const size_t *global_work_offset,const size_t *global_work_size,const size_t *local_work_size,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
void * _clEnqueueMapBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_map,cl_map_flags map_flags,size_t offset,size_t cb,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event,cl_int *errcode_ret);
cl_int _clEnqueueWriteBuffer(cl_command_queue command_queue,cl_mem buffer,cl_bool blocking_write,size_t offset,size_t cb,const void *ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
void * _clEnqueueUnmapMemObject(cl_command_queue command_queue,	cl_mem memobj,void *mapped_ptr,cl_uint num_events_in_wait_list,const cl_event *event_wait_list,cl_event *event);
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
cl_context _clCreateContextFromType(cl_context_properties *properties,cl_device_type  device_type,void  (*pfn_notify) (const char *errinfo,const void  *private_info,size_t  cb,void  *user_data),void  *user_data,cl_int  *errcode_ret);
cl_program _clCreateProgramWithSource(cl_context context,cl_uint count,const char **strings,const size_t *lengths,cl_int *errcode_ret);
cl_int _clGetProgramInfo(cl_program program,cl_program_info param_name,size_t param_value_size,void *param_value,size_t *param_value_size_ret);
cl_int _clGetProgramBuildInfo(cl_program  program,cl_device_id  device,cl_program_build_info  param_name,size_t  param_value_size,void  *param_value,size_t  *param_value_size_ret);
cl_int _clReleaseContext(cl_context context);
cl_int _clReleaseKernel(cl_kernel kernel);
cl_int _clFlush(cl_command_queue queue);
cl_int _clFinish(cl_command_queue queue);
cl_int _clGetPlatformInfo(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret);
cl_int _clGetPlatformInfoNoErr(cl_platform_id platform,cl_platform_info param_name, size_t param_value_size, void *param_value,size_t *param_value_size_ret);
cl_int _clGetPlatformIDsNoErr(cl_uint num_entries,cl_platform_id *platforms,cl_uint *num_platforms);
cl_int _clReleaseProgram(cl_program program);
cl_int _clUnloadCompiler(void);

hash_stat initialize_opencl(void);

#endif
