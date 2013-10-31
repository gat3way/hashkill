INCLUDES = $(DEPS_CFLAGS) $(JS_CFLAGS) $(Z_CFLAGS)
BINDIR = $(bindir)
IDATADIR = $(datadir)
DATADIR = "$(datadir)"
MAN = $(mandir)
export CL_AMDFLAGS
export CL_NVFLAGS
export BINDIR
export DATADIR
export IDATADIR

# this lists the binaries to produce, the (non-PHONY, binary) targets in
# the previous manual Makefile
bin_PROGRAMS = hashkill



LIBTOOL = @LIBTOOL@ --silent 
lib_LTLIBRARIES = libtargets.la
libtargets_la_SOURCES = 
libtargets_la_LDFLAGS = -static -Bstatic
libtargets_la_LIBADD = \
    libxop.la \
    libaesni.la 

noinst_LTLIBRARIES = libxop.la libaesni.la 
libxop_la_SOURCES = md5_xop.c sha1_xop.c md4_xop.c des_xop.c des_nonstd_xop.c
libxop_la_CFLAGS =  -O3 -mxop -ftree-vectorize -static -fPIC -Bstatic

libaesni_la_SOURCES = aesni.c
libaesni_la_CFLAGS =  -O3 -maes -static -fPIC -Bstatic



hashkill_SOURCES = ocl-base.c base64.c plugins.c main.c loadfiles.c threads.c hashinterface.c sessions.c loadfiles.h \
threads.h hashinterface.h plugins.h sessions.h md5_sse2.c md5_sse2.h sha1_sse2.c sha1_sse2.h \
md4_sse2.c md4_sse2.h des_sse2.c ocl-threads.c  des_nonstd_sse2.c ocl_support.h \
lzma/7zFile.c lzma/7zStream.c lzma/LzmaDec.c lzma/LzmaEnc.c lzma/Alloc.c lzma/LzFind.c lzma/lzma.c \
cpu-feat.c hashgen.c hashgen.h hashgen-mangle.c hashgen-mangle.h ocl-adl.c ocl_md5.c ocl_sha1.c \
ocl_md4.c ocl_ntlm.c ocl_md5md5.c ocl_mysql5.c ocl_sha256.c ocl_sha512.c ocl_lm.c ocl_nsldap.c  \
ocl_joomla.c ocl_oscommerce.c ocl_ipb2.c ocl_vbulletin.c ocl_smf.c ocl_oracle11g.c ocl_mssql-2000.c \
ocl_mssql-2005.c ocl_nsldaps.c ocl_osx-old.c ocl_osxlion.c ocl_desunix.c ocl_oracle-old.c  ocl_mscash.c \
ocl_pixmd5.c ocl_phpbb3.c ocl_wordpress.c ocl_md5unix.c ocl_sha512unix.c ocl_mscash2.c ocl_apr1.c ocl_wpa.c \
ocl_dmg.c unrargpu.c ocl_rar.c ocl_bfunix.c ocl_drupal7.c ocl_zip.c ocl_django256.c ocl_sha256unix.c \
ocl_o5logon.c ocl_mssql-2012.c ocl_msoffice.c ocl_luks.c ocl_ripemd160.c ocl_whirlpool.c \
cpu-serpent.c cpu-twofish.c ocl_truecrypt.c ocl_lastpass.c ocl_keepass.c ocl_mozilla.c ocl_pwsafe.c \
ocl_keyring.c ocl_kwallet.c bad_blowfish.c ocl_msoffice-old.c ocl_pdf.c ocl_sha384.c ocl_odf.c \
ocl_grub2.c ocl_androidfde.c ocl_androidpin.c ocl_osx-ml.c ocl_a51.c

#ocl_test.c
# forced static linkage below
hashkill_LDFLAGS =  -static-libtool-libs -ldl -static -Bstatic -lcrypto  -L/lib  -lrt -lz -lm $(JS_LIBS)
# dynamic linkage below
#hashkill_LDFLAGS =  -ldl -lcrypto  -L/lib  -lrt -lz -lm $(JS_LIBS)

hashkill_LDADD = libtargets.la 
hashkill_CFLAGS = -fPIC -O3  -fomit-frame-pointer -momit-leaf-frame-pointer -Wall -Wno-format -ftree-vectorize -DBINDIR=\"$(BINDIR)\" -DDATADIR=\"$(IDATADIR)\" -pthread -Wno-unused-value -Wno-unused-result -Wno-switch -D_7ZIP_ST  -flto -fwhole-program -Wno-psabi 


SUBDIRS = kernels/compiler plugins markov kernels dict tools rules

