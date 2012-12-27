AC_ARG_ENABLE(amd-ocl,
  [  --disable-amd-ocl	 Disable compilation of AMD OpenCL kernels],
  [case "${enableval}" in
     yes | no ) CL_AMDFLAGS="${enableval}" ;;
     *) AC_MSG_ERROR(bad value ${enableval} for --disable-amd-ocl) ;;
   esac],
  [CL_AMDFLAGS="yes"]
)

AC_ARG_ENABLE(nv-ocl,
  [  --disable-nv-ocl	 Disable compilation of NVidia OpenCL kernels],
  [case "${enableval}" in
     yes | no ) CL_NVFLAGS="${enableval}" ;;
     *) AC_MSG_ERROR(bad value ${enableval} for --disable-nv-ocl) ;;
   esac],
  [CL_NVFLAGS="yes"]
)

AC_SUBST([CL_AMDFLAGS])
AC_SUBST([CL_NVFLAGS])

