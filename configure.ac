#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.64])
AC_INIT(hashkill, 0.3.0, gat3way@gat3way.eu)
AC_PROG_LIBTOOL
AM_INIT_AUTOMAKE(hashkill, 0.3.0)
AC_OUTPUT(Makefile src/Makefile man/Makefile)
AC_CONFIG_SRCDIR([src/threads.c])
#AC_CONFIG_HEADERS([config.h])

# Checks for programs.
SAVED_CFLAGS=$(CFLAGS)
AC_PROG_CC
CFLAGS=$(SAVED_CFLAGS)
AM_PROG_AS
AC_DISABLE_SHARED
LT_INIT([disable-shared])
AC_PROG_LIBTOOL
# Checks for libraries.

# Checks for header files.
AC_CHECK_HEADERS([termios.h sys/param.h fcntl.h stdlib.h pthread.h dlfcn.h string.h unistd.h openssl/md5.h arpa/inet.h zlib.h  openssl/sha1.h wchar.h ])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIZE_T
AC_TYPE_UINT64_T
AC_TYPE_UINT32_T
AC_TYPE_UINT16_T
AC_TYPE_SSIZE_T

AC_C_INLINE
AC_FUNC_ALLOCA
AC_HEADER_STDBOOL
AC_TYPE_UID_T

m4_include([simd.m4])
m4_include([json.m4])
#m4_include([curl.m4])
#m4_include([opencl.m4])

AX_EXT()
AX_CHECK_CL
AX_CHECK_JSONLIB

# Checks for library functions.
AC_FUNC_MALLOC
AC_CHECK_FUNCS([bzero strstr sysinfo strerror endpwent getcwd strchr strcspn strtoul memset strtol])

PKG_CHECK_MODULES(DEPS, openssl)
PKG_CHECK_MODULES(DEPS, json0)

AC_SUBST(DEPS_CFLAGS)
AC_SUBST(DEPS_LIBS)


AC_OUTPUT

