ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif


LZMA_SRC = ../../lzma/7zFile.c ../../lzma/7zStream.c ../../lzma/LzmaDec.c ../../lzma/LzmaEnc.c ../../lzma/Alloc.c ../../lzma/LzFind.c ../../lzma/lzma.c -I../..
OPENCL_SRC = ../../ocl-base.c

all: build

build: 
	# AMD
	cc -o amd-compiler amd-compiler.c $(LZMA_SRC) $(OPENCL_SRC) -D_7ZIP_ST -ldl
	cc -o nvidia-compiler nvidia-compiler.c $(LZMA_SRC) $(OPENCL_SRC) -D_7ZIP_ST -ldl
	@if [ ! -e amd_ipb2_long__Juniper.bin ]; then ./amd-compiler amd_ipb2_long n ;fi
	@if [ ! -e amd_ipb2__Juniper.bin ]; then ./amd-compiler amd_ipb2 n ;fi
	@if [ ! -e amd_md5_long__Juniper.bin ]; then ./amd-compiler amd_md5_long ns ;fi
	@if [ ! -e amd_md5__Juniper.bin ]; then ./amd-compiler amd_md5 ns ;fi
	@if [ ! -e amd_sha1_long__Juniper.bin ]; then ./amd-compiler amd_sha1_long ns ;fi
	@if [ ! -e amd_sha1__Juniper.bin ]; then ./amd-compiler amd_sha1 ns ;fi
	@if [ ! -e amd_ntlm_long__Juniper.bin ]; then ./amd-compiler amd_ntlm_long ns ;fi
	@if [ ! -e amd_ntlm__Juniper.bin ]; then ./amd-compiler amd_ntlm ns ;fi
	@if [ ! -e amd_md4_long__Juniper.bin ]; then ./amd-compiler amd_md4_long nsd ;fi
	@if [ ! -e amd_md4__Juniper.bin ]; then ./amd-compiler amd_md4 ns ;fi
	@if [ ! -e amd_pixmd5_long__Juniper.bin ]; then ./amd-compiler amd_pixmd5_long ns ;fi
	@if [ ! -e amd_pixmd5__Juniper.bin ]; then ./amd-compiler amd_pixmd5 ns ;fi
	@if [ ! -e amd_sl3__Juniper.bin ]; then ./amd-compiler amd_sl3 n ;fi
	@if [ ! -e amd_sha256_long__Juniper.bin ]; then ./amd-compiler amd_sha256_long ns ;fi
	@if [ ! -e amd_sha256__Juniper.bin ]; then ./amd-compiler amd_sha256 ns ;fi
	@if [ ! -e amd_lm_long__Juniper.bin ]; then ./amd-compiler amd_lm_long ns ;fi
	@if [ ! -e amd_lm__Juniper.bin ]; then ./amd-compiler amd_lm ns ;fi
	@if [ ! -e amd_md5md5_long__Juniper.bin ]; then ./amd-compiler amd_md5md5_long ns ;fi
	@if [ ! -e amd_md5md5__Juniper.bin ]; then ./amd-compiler amd_md5md5 ns ;fi
	@if [ ! -e amd_md5_passsalt_long__Juniper.bin ]; then ./amd-compiler amd_md5_passsalt_long n ;fi
	@if [ ! -e amd_md5_passsalt__Juniper.bin ]; then ./amd-compiler amd_md5_passsalt n ;fi
	@if [ ! -e amd_mysql5_long__Juniper.bin ]; then ./amd-compiler amd_mysql5_long ns ;fi
	@if [ ! -e amd_mysql5__Juniper.bin ]; then ./amd-compiler amd_mysql5 ns ;fi
	@if [ ! -e amd_sha1_passsalt_long__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt_long n ;fi
	@if [ ! -e amd_sha1_passsalt__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt n ;fi
	@if [ ! -e amd_sha1_passsaltu_long__Juniper.bin ]; then ./amd-compiler amd_sha1_passsaltu_long n ;fi
	@if [ ! -e amd_sha1_passsaltu__Juniper.bin ]; then ./amd-compiler amd_sha1_passsaltu n ;fi
	@if [ ! -e amd_oracle_old_long__Juniper.bin ]; then ./amd-compiler amd_oracle_old_long n ;fi
	@if [ ! -e amd_oracle_old__Juniper.bin ]; then ./amd-compiler amd_oracle_old n ;fi
	@if [ ! -e amd_vbulletin_long__Juniper.bin ]; then ./amd-compiler amd_vbulletin_long nbo ;fi
	@if [ ! -e amd_vbulletin__Juniper.bin ]; then ./amd-compiler amd_vbulletin n ;fi
	@if [ ! -e amd_md5_saltpass_long__Juniper.bin ]; then ./amd-compiler amd_md5_saltpass_long n ;fi
	@if [ ! -e amd_md5_saltpass__Juniper.bin ]; then ./amd-compiler amd_md5_saltpass n ;fi
	@if [ ! -e amd_sha1_saltpass_long__Juniper.bin ]; then ./amd-compiler amd_sha1_saltpass_long n ;fi
	@if [ ! -e amd_sha1_saltpass__Juniper.bin ]; then ./amd-compiler amd_sha1_saltpass n ;fi
	@if [ ! -e amd_desunix_long__Juniper.bin ]; then ./amd-compiler amd_desunix_long n ;fi
	@if [ ! -e amd_desunix__Juniper.bin ]; then ./amd-compiler amd_desunix n ;fi
	@if [ ! -e amd_phpass__Juniper.bin ]; then ./amd-compiler amd_phpass n ;fi
	@if [ ! -e amd_md5unix__Juniper.bin ]; then ./amd-compiler amd_md5unix n ;fi
	@if [ ! -e amd_sha512__Juniper.bin ]; then ./amd-compiler amd_sha512 ns ;fi
	@if [ ! -e amd_sha512_long__Juniper.bin ]; then ./amd-compiler amd_sha512_long ns ;fi
	@if [ ! -e amd_osxlion_long__Juniper.bin ]; then ./amd-compiler amd_osxlion_long n ;fi
	@if [ ! -e amd_osxlion__Juniper.bin ]; then ./amd-compiler amd_osxlion n ;fi
	@if [ ! -e amd_sha1_passsalt_ulong__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt_ulong n ;fi
	@if [ ! -e amd_mscash_long__Juniper.bin ]; then ./amd-compiler amd_mscash_long n ;fi
	@if [ ! -e amd_mscash__Juniper.bin ]; then ./amd-compiler amd_mscash n ;fi
	@if [ ! -e amd_mscash2__Juniper.bin ]; then ./amd-compiler amd_mscash2 n ;fi
	@if [ ! -e amd_wpa__Juniper.bin ]; then ./amd-compiler amd_wpa n ;fi
	@if [ ! -e amd_wpa2__Juniper.bin ]; then ./amd-compiler amd_wpa2 n ;fi
	@if [ ! -e amd_zip__Juniper.bin ]; then ./amd-compiler amd_zip n ;fi
	@if [ ! -e amd_zip_long__Juniper.bin ]; then ./amd-compiler amd_zip_long n ;fi
	@if [ ! -e amd_zips__Juniper.bin ]; then ./amd-compiler amd_zips n ;fi
	@if [ ! -e amd_zipu__Juniper.bin ]; then ./amd-compiler amd_zipu n ;fi
	@if [ ! -e amd_sha512unix__Juniper.bin ]; then ./amd-compiler amd_sha512unix n ;fi
	@if [ ! -e amd_rar__Juniper.bin ]; then ./amd-compiler amd_rar n ;fi
	@if [ ! -e amd_dmg__Juniper.bin ]; then ./amd-compiler amd_dmg n ;fi
	@if [ ! -e amd_osx_old_long__Juniper.bin ]; then ./amd-compiler amd_osx_old_long n ;fi
	@if [ ! -e amd_osx_old__Juniper.bin ]; then ./amd-compiler amd_osx_old n ;fi
	# NVidia
	@if [ ! -e nvidia_md5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_long ns ;fi
	@if [ ! -e nvidia_md5__sm10.ptx ]; then ./nvidia-compiler nvidia_md5 ns ;fi
	@if [ ! -e nvidia_sha1_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_long ns ;fi
	@if [ ! -e nvidia_sha1__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1 ns ;fi
	@if [ ! -e nvidia_ntlm__sm10.ptx ]; then ./nvidia-compiler nvidia_ntlm ns ;fi
	@if [ ! -e nvidia_ntlm_long__sm10.ptx ]; then ./nvidia-compiler nvidia_ntlm_long ns ;fi
	@if [ ! -e nvidia_md4__sm10.ptx ]; then ./nvidia-compiler nvidia_md4 ns ;fi
	@if [ ! -e nvidia_md4_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md4_long ns ;fi
	@if [ ! -e nvidia_lm__sm10.ptx ]; then ./nvidia-compiler nvidia_lm nbs ;fi
	@if [ ! -e nvidia_lm_long__sm10.ptx ]; then ./nvidia-compiler nvidia_lm_long ns ;fi
	@if [ ! -e nvidia_md5md5__sm10.ptx ]; then ./nvidia-compiler nvidia_md5md5 ns ;fi
	@if [ ! -e nvidia_md5md5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5md5_long ns ;fi
	@if [ ! -e nvidia_sl3__sm10.ptx ]; then ./nvidia-compiler nvidia_sl3 n ;fi
	@if [ ! -e nvidia_mysql5__sm10.ptx ]; then ./nvidia-compiler nvidia_mysql5 ns ;fi
	@if [ ! -e nvidia_mysql5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_mysql5_long ns ;fi
	@if [ ! -e nvidia_sha512__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512 ns ;fi
	@if [ ! -e nvidia_sha512_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512_long ns ;fi
	@if [ ! -e nvidia_sha256__sm10.ptx ]; then ./nvidia-compiler nvidia_sha256 ns ;fi
	@if [ ! -e nvidia_sha256_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha256_long ns ;fi
	@if [ ! -e nvidia_md5_passsalt__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_passsalt n ;fi
	@if [ ! -e nvidia_md5_passsalt_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_passsalt_long n ;fi
	@if [ ! -e nvidia_md5_saltpass__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_saltpass n ;fi
	@if [ ! -e nvidia_md5_saltpass_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_saltpass_long n ;fi
	@if [ ! -e nvidia_ipb2__sm10.ptx ]; then ./nvidia-compiler nvidia_ipb2 nb ;fi
	@if [ ! -e nvidia_ipb2_long__sm10.ptx ]; then ./nvidia-compiler nvidia_ipb2_long nb ;fi
	@if [ ! -e nvidia_vbulletin__sm10.ptx ]; then ./nvidia-compiler nvidia_vbulletin nb ;fi
	@if [ ! -e nvidia_vbulletin_long__sm10.ptx ]; then ./nvidia-compiler nvidia_vbulletin_long n ;fi
	@if [ ! -e nvidia_sha1_saltpass__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_saltpass n ;fi
	@if [ ! -e nvidia_sha1_saltpass_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_saltpass_long n ;fi
	@if [ ! -e nvidia_sha1_passsalt__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt n ;fi
	@if [ ! -e nvidia_sha1_passsalt_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt_long n ;fi
	@if [ ! -e nvidia_sha1_passsaltu__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsaltu n ;fi
	@if [ ! -e nvidia_sha1_passsaltu_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsaltu_long n ;fi
	@if [ ! -e nvidia_osx_old_long__sm10.ptx ]; then ./nvidia-compiler nvidia_osx_old_long n ;fi
	@if [ ! -e nvidia_osx_old__sm10.ptx ]; then ./nvidia-compiler nvidia_osx_old n ;fi
	@if [ ! -e nvidia_osxlion_long__sm10.ptx ]; then ./nvidia-compiler nvidia_osxlion_long n ;fi
	@if [ ! -e nvidia_osxlion__sm10.ptx ]; then ./nvidia-compiler nvidia_osxlion n ;fi
	@if [ ! -e nvidia_desunix__sm10.ptx ]; then ./nvidia-compiler nvidia_desunix n ;fi
	@if [ ! -e nvidia_desunix_long__sm10.ptx ]; then ./nvidia-compiler nvidia_desunix_long n ;fi
	@if [ ! -e nvidia_oracle_old__sm10.ptx ]; then ./nvidia-compiler nvidia_oracle_old n ;fi
	@if [ ! -e nvidia_oracle_old_long__sm10.ptx ]; then ./nvidia-compiler nvidia_oracle_old_long n ;fi
	@if [ ! -e nvidia_mscash_long__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash_long n ;fi
	@if [ ! -e nvidia_mscash__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash n ;fi
	@if [ ! -e nvidia_pixmd5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_pixmd5_long ns ;fi
	@if [ ! -e nvidia_pixmd5__sm10.ptx ]; then ./nvidia-compiler nvidia_pixmd5 ns ;fi
	@if [ ! -e nvidia_phpass__sm10.ptx ]; then ./nvidia-compiler nvidia_phpass nb ;fi
	@if [ ! -e nvidia_md5unix__sm10.ptx ]; then ./nvidia-compiler nvidia_md5unix n ;fi
	@if [ ! -e nvidia_mscash2__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash2 n ;fi
	@if [ ! -e nvidia_wpa__sm10.ptx ]; then ./nvidia-compiler nvidia_wpa n ;fi
	@if [ ! -e nvidia_wpa2__sm10.ptx ]; then ./nvidia-compiler nvidia_wpa2 n ;fi
	@if [ ! -e nvidia_dmg__sm10.ptx ]; then ./nvidia-compiler nvidia_dmg n ;fi
	@if [ ! -e nvidia_rar__sm10.ptx ]; then \
	./nvidia-compiler nvidia_rar Fn 0; \
	./nvidia-compiler nvidia_rar Fn 1; \
	./nvidia-compiler nvidia_rar Fn 2; \
	./nvidia-compiler nvidia_rar Fn 3; \
	./nvidia-compiler nvidia_rar Fn 4; \
	./nvidia-compiler nvidia_rar Fn 5; \
	./nvidia-compiler nvidia_rar Fn 6; \
	fi;
	@if [ ! -e nvidia_sha512unix__sm10.ptx ]; then \
	./nvidia-compiler nvidia_sha512unix Fn 0; \
	./nvidia-compiler nvidia_sha512unix Fn 1; \
	./nvidia-compiler nvidia_sha512unix Fn 2; \
	./nvidia-compiler nvidia_sha512unix Fn 3; \
	./nvidia-compiler nvidia_sha512unix Fn 4; \
	./nvidia-compiler nvidia_sha512unix Fn 5; \
	./nvidia-compiler nvidia_sha512unix Fn 6; \
	fi;
	@if [ ! -e nvidia_sha1_passsalt_ulong__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt_ulong n ;fi
	@if [ ! -e nvidia_zip__sm10.ptx ]; then ./nvidia-compiler nvidia_zip n ;fi
	@if [ ! -e nvidia_zip_long__sm10.ptx ]; then ./nvidia-compiler nvidia_zip_long n ;fi
	@if [ ! -e nvidia_zips__sm10.ptx ]; then ./nvidia-compiler nvidia_zips n ;fi
	@if [ ! -e nvidia_zipu__sm10.ptx ]; then ./nvidia-compiler nvidia_zipu n ;fi



install: 
	@echo "Copying kernels..."
	@mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/kernels
	@touch placeholder_kernel.dummy
	@cp  *_*.* $(IDESTDIR)$(IDATADIR)/hashkill/kernels;
	@echo Done.

clean:
	#rm *.bin

distclean:
	rm *.bin
	rm *.ptx

distclean: clean


#cc -o compile compile.c -I/opt/AMDAPP/include/ -L/opt/AMDAPP/lib/x86_64 -lOpenCL -g 