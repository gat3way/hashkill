ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif


LZMA_SRC = ../../lzma/7zFile.c ../../lzma/7zStream.c ../../lzma/LzmaDec.c ../../lzma/LzmaEnc.c ../../lzma/Alloc.c ../../lzma/LzFind.c ../../lzma/lzma.c -I../..
OPENCL_SRC = ../../ocl-base.c

all: build

%: %.c compiler.c
	$(CC) -o $@ compiler.c $< $(LZMA_SRC) $(OPENCL_SRC) -Wno-unused-result -D_7ZIP_ST -ldl


build_amd: amd_ipb2_long amd_ipb2 amd_md5_long amd_md5 amd_sha1 amd_sha1_long amd_ntlm amd_ntlm_long \
amd_md4 amd_md4_long amd_pixmd5 amd_pixmd5_long amd_sha256 amd_sha256_long amd_lm amd_lm_long \
amd_md5md5 amd_md5md5_long amd_md5_passsalt amd_md5_passsalt_long amd_mysql5 amd_mysql5_long \
amd_sha1_passsalt amd_sha1_passsalt_long amd_sha1_passsaltu amd_sha1_passsaltu_long  \
amd_oracle_old amd_oracle_old_long amd_vbulletin amd_vbulletin_long amd_md5_saltpass amd_md5_saltpass_long \
amd_sha1_saltpass amd_sha1_saltpass_long amd_desunix amd_desunix_long amd_phpass amd_md5unix \
amd_sha512 amd_sha512_long amd_osxlion amd_osxlion_long amd_sha1_passsalt_ulong amd_mscash amd_mscash_long \
amd_mscash2 amd_wpa amd_wpa2 amd_zip amd_zip_long amd_zipu amd_zips amd_sha512unix amd_rar amd_dmg \
amd_osx_old amd_osx_old_long amd_bfunix amd_phpass512 amd_django256 amd_sha256unix amd_o5logon amd_o5logon_long \
amd_sha512_passsaltu amd_sha512_passsaltu_long amd_msoffice2007 amd_msoffice2010 amd_msoffice2013 \
amd_luks128 amd_luks256 amd_ripemd160 amd_ripemd160_long amd_whirlpool amd_whirlpool_long \
amd_truecrypt amd_lastpass amd_keepass amd_keepass2 amd_mozilla amd_mozilla_long amd_pwsafe \
amd_keyring amd_kwallet amd_msoffice_old amd_msoffice_old_md5 amd_pdf2 amd_pdf3 amd_pdf4 amd_pdf5 \
amd_sha384 amd_sha384_long amd_pdf6 amd_odf amd_odf2 amd_grub2 amd_androidfde amd_osxml amd_a51


build_nvidia: nvidia_ipb2_long nvidia_ipb2 nvidia_md5_long nvidia_md5 nvidia_sha1 nvidia_sha1_long nvidia_ntlm nvidia_ntlm_long \
nvidia_md4 nvidia_md4_long nvidia_pixmd5 nvidia_pixmd5_long nvidia_sha256 nvidia_sha256_long nvidia_lm nvidia_lm_long \
nvidia_md5md5 nvidia_md5md5_long nvidia_md5_passsalt nvidia_md5_passsalt_long nvidia_mysql5 nvidia_mysql5_long \
nvidia_sha1_passsalt nvidia_sha1_passsalt_long nvidia_sha1_passsaltu nvidia_sha1_passsaltu_long  \
nvidia_oracle_old nvidia_oracle_old_long nvidia_vbulletin nvidia_vbulletin_long nvidia_md5_saltpass nvidia_md5_saltpass_long \
nvidia_sha1_saltpass nvidia_sha1_saltpass_long nvidia_desunix nvidia_desunix_long nvidia_phpass nvidia_md5unix \
nvidia_sha512 nvidia_sha512_long nvidia_osxlion nvidia_osxlion_long nvidia_sha1_passsalt_ulong nvidia_mscash nvidia_mscash_long \
nvidia_mscash2 nvidia_wpa nvidia_wpa2 nvidia_zip nvidia_zip_long nvidia_zipu nvidia_zips nvidia_sha512unix nvidia_rar nvidia_dmg \
nvidia_osx_old nvidia_osx_old_long nvidia_bfunix nvidia_phpass512 nvidia_django256 nvidia_sha256unix nvidia_o5logon nvidia_o5logon_long \
nvidia_sha512_passsaltu nvidia_sha512_passsaltu_long nvidia_msoffice2007 nvidia_msoffice2010 nvidia_msoffice2013 \
nvidia_luks128 nvidia_luks256 nvidia_ripemd160 nvidia_ripemd160_long nvidia_whirlpool nvidia_whirlpool_long \
nvidia_truecrypt nvidia_lastpass nvidia_keepass nvidia_keepass2 nvidia_mozilla nvidia_mozilla_long nvidia_pwsafe \
nvidia_keyring nvidia_kwallet nvidia_msoffice_old nvidia_msoffice_old_md5 nvidia_pdf2 nvidia_pdf3 nvidia_pdf4 nvidia_pdf5 \
nvidia_sha384 nvidia_sha384_long nvidia_pdf6 nvidia_odf nvidia_odf2 nvidia_grub2 nvidia_androidfde nvidia_osxml


build: build_amd build_nvidia


install: 
	@echo "Copying kernels..."
	@mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/kernels
	@touch placeholder_kernel.dummy
	@cp  *_*.* $(IDESTDIR)$(IDATADIR)/hashkill/kernels;
	@echo Done.

clean:
	#rm *.bin

distclean:
	-rm -f *.bin
	-rm -f *.ptx

distclean: clean

maintainer-clean: clean


amd_ipb2_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ipb2_long__Juniper.bin ]; then ./amd-compiler amd_ipb2_long n ;fi; \
		fi

amd_ipb2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ipb2__Juniper.bin ]; then ./amd-compiler amd_ipb2 n ;fi; \
		fi

amd_md5_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5_long__Juniper.bin ]; then ./amd-compiler amd_md5_long ns ;fi; \
		fi

amd_md5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5__Juniper.bin ]; then ./amd-compiler amd_md5 ns ;fi; \
		fi

amd_sha1: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1__Juniper.bin ]; then ./amd-compiler amd_sha1 ns ;fi; \
		fi

amd_sha1_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_long__Juniper.bin ]; then ./amd-compiler amd_sha1_long ns ;fi; \
		fi

amd_ntlm: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ntlm__Juniper.bin ]; then ./amd-compiler amd_ntlm ns ;fi; \
		fi

amd_ntlm_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ntlm_long__Juniper.bin ]; then ./amd-compiler amd_ntlm_long ns ;fi; \
		fi

amd_md4: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md4__Juniper.bin ]; then ./amd-compiler amd_md4 ns ;fi; \
		fi

amd_md4_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md4_long__Juniper.bin ]; then ./amd-compiler amd_md4_long ns ;fi; \
		fi

amd_pixmd5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pixmd5__Juniper.bin ]; then ./amd-compiler amd_pixmd5 ns ;fi; \
		fi

amd_pixmd5_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pixmd5_long__Juniper.bin ]; then ./amd-compiler amd_pixmd5_long ns ;fi; \
		fi

amd_sha256: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha256__Juniper.bin ]; then ./amd-compiler amd_sha256 ns ;fi; \
		fi

amd_sha256_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha256_long__Juniper.bin ]; then ./amd-compiler amd_sha256_long ns ;fi; \
		fi

amd_lm: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_lm__Juniper.bin ]; then ./amd-compiler amd_lm ns ;fi; \
		fi

amd_lm_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_lm_long__Juniper.bin ]; then ./amd-compiler amd_lm_long ns ;fi; \
		fi

amd_md5md5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5md5__Juniper.bin ]; then ./amd-compiler amd_md5md5 ns ;fi; \
		fi

amd_md5md5_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5md5_long__Juniper.bin ]; then ./amd-compiler amd_md5md5_long ns ;fi; \
		fi

amd_md5_passsalt: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5_passsalt__Juniper.bin ]; then ./amd-compiler amd_md5_passsalt n ;fi; \
		fi

amd_md5_passsalt_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5_passsalt_long__Juniper.bin ]; then ./amd-compiler amd_md5_passsalt_long n ;fi; \
		fi

amd_mysql5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mysql5__Juniper.bin ]; then ./amd-compiler amd_mysql5 ns ;fi; \
		fi

amd_mysql5_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mysql5_long__Juniper.bin ]; then ./amd-compiler amd_mysql5_long ns ;fi; \
		fi

amd_sha1_passsalt: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsalt__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt n ;fi; \
		fi

amd_sha1_passsalt_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsalt_long__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt_long n ;fi; \
		fi

amd_sha1_passsaltu: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsaltu__Juniper.bin ]; then ./amd-compiler amd_sha1_passsaltu n ;fi; \
		fi

amd_sha1_passsaltu_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsaltu_long__Juniper.bin ]; then ./amd-compiler amd_sha1_passsaltu_long n ;fi; \
		fi

amd_sha1_passsaltul_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsaltul_long__Juniper.bin ]; then ./amd-compiler amd_sha1_passsaltul_long n ;fi; \
		fi

amd_oracle_old: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_oracle_old__Juniper.bin ]; then ./amd-compiler amd_oracle_old n ;fi; \
		fi

amd_oracle_old_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_oracle_old_long__Juniper.bin ]; then ./amd-compiler amd_oracle_old_long n ;fi; \
		fi

amd_vbulletin: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_vbulletin__Juniper.bin ]; then ./amd-compiler amd_vbulletin n ;fi; \
		fi

amd_vbulletin_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_vbulletin_long__Juniper.bin ]; then ./amd-compiler amd_vbulletin_long n ;fi; \
		fi

amd_md5_saltpass: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5_saltpass__Juniper.bin ]; then ./amd-compiler amd_md5_saltpass n ;fi; \
		fi

amd_md5_saltpass_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5_saltpass_long__Juniper.bin ]; then ./amd-compiler amd_md5_saltpass_long n ;fi; \
		fi

amd_sha1_saltpass: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_saltpass__Juniper.bin ]; then ./amd-compiler amd_sha1_saltpass n ;fi; \
		fi

amd_sha1_saltpass_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_saltpass_long__Juniper.bin ]; then ./amd-compiler amd_sha1_saltpass_long n ;fi; \
		fi

amd_desunix: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_desunix__Juniper.bin ]; then ./amd-compiler amd_desunix n ;fi; \
		fi

amd_desunix_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_desunix_long__Juniper.bin ]; then ./amd-compiler amd_desunix_long n ;fi; \
		fi

amd_phpass: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_phpass__Juniper.bin ]; then ./amd-compiler amd_phpass n ;fi; \
		fi

amd_md5unix: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_md5unix__Juniper.bin ]; then ./amd-compiler amd_md5unix n ;fi; \
		fi

amd_sha512: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha512__Juniper.bin ]; then ./amd-compiler amd_sha512 ns ;fi; \
		fi

amd_sha512_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha512_long__Juniper.bin ]; then ./amd-compiler amd_sha512_long ns ;fi; \
		fi

amd_osxlion: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_osxlion__Juniper.bin ]; then ./amd-compiler amd_osxlion n ;fi; \
		fi

amd_osxlion_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_osxlion_long__Juniper.bin ]; then ./amd-compiler amd_osxlion_long n ;fi; \
		fi

amd_sha1_passsalt_ulong: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha1_passsalt_ulong__Juniper.bin ]; then ./amd-compiler amd_sha1_passsalt_ulong n ;fi; \
		fi

amd_mscash: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mscash__Juniper.bin ]; then ./amd-compiler amd_mscash n ;fi; \
		fi

amd_mscash_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mscash_long__Juniper.bin ]; then ./amd-compiler amd_mscash_long n ;fi; \
		fi

amd_mscash2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mscash2__Juniper.bin ]; then ./amd-compiler amd_mscash2 n ;fi; \
		fi

amd_wpa: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_wpa__Juniper.bin ]; then ./amd-compiler amd_wpa n ;fi; \
		fi

amd_wpa2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_wpa2__Juniper.bin ]; then ./amd-compiler amd_wpa2 n ;fi; \
		fi

amd_zip: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_zip__Juniper.bin ]; then ./amd-compiler amd_zip n ;fi; \
		fi

amd_zip_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_zip_long__Juniper.bin ]; then ./amd-compiler amd_zip_long n ;fi; \
		fi

amd_zipu: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_zipu__Juniper.bin ]; then ./amd-compiler amd_zipu n ;fi; \
		fi

amd_zips: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_zips__Juniper.bin ]; then ./amd-compiler amd_zips n ;fi; \
		fi

amd_sha512unix: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha512unix__Juniper.bin ]; then ./amd-compiler amd_sha512unix n ;fi; \
		fi

amd_rar: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_rar__Juniper.bin ]; then ./amd-compiler amd_rar n ;fi; \
		fi

amd_dmg: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_dmg__Juniper.bin ]; then ./amd-compiler amd_dmg n ;fi; \
		fi

amd_osx_old: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_osx_old__Juniper.bin ]; then ./amd-compiler amd_osx_old n ;fi; \
		fi

amd_osx_old_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_osx_old_long__Juniper.bin ]; then ./amd-compiler amd_osx_old_long n ;fi; \
		fi

amd_bfunix: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_bfunix__Juniper.bin ]; then ./amd-compiler amd_bfunix n ;fi; \
		fi

amd_phpass512: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_phpass512__Juniper.bin ]; then ./amd-compiler amd_phpass512 n ;fi; \
		fi

amd_django256: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_django256__Juniper.bin ]; then ./amd-compiler amd_django256 n ;fi; \
		fi

amd_sha256unix: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha256unix__Juniper.bin ]; then ./amd-compiler amd_sha256unix n ;fi; \
		fi

amd_o5logon: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_o5logon__Juniper.bin ]; then ./amd-compiler amd_o5logon n ;fi; \
		fi

amd_o5logon_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_o5logon_long__Juniper.bin ]; then ./amd-compiler amd_o5logon_long n ;fi; \
		fi

amd_sha512_passsaltu: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha512_passsaltu__Juniper.bin ]; then ./amd-compiler amd_sha512_passsaltu n ;fi; \
		fi

amd_sha512_passsaltu_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha512_passsaltu_long__Juniper.bin ]; then ./amd-compiler amd_sha512_passsaltu_long n ;fi; \
		fi

amd_msoffice2007: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_msoffice2007__Juniper.bin ]; then ./amd-compiler amd_msoffice2007 n ;fi; \
		fi

amd_msoffice2010: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_msoffice2010__Juniper.bin ]; then ./amd-compiler amd_msoffice2010 no ;fi; \
		fi

amd_msoffice2013: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_msoffice2013__Juniper.bin ]; then ./amd-compiler amd_msoffice2013 n ;fi; \
		fi

amd_luks128: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_luks128__Juniper.bin ]; then ./amd-compiler amd_luks128 n ;fi; \
		fi

amd_luks256: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_luks256__Juniper.bin ]; then ./amd-compiler amd_luks256 n ;fi; \
		fi

amd_ripemd160: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ripemd160__Juniper.bin ]; then ./amd-compiler amd_ripemd160 ns ;fi; \
		fi

amd_ripemd160_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_ripemd160_long__Juniper.bin ]; then ./amd-compiler amd_ripemd160_long ns ;fi; \
		fi

amd_whirlpool: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_whirlpool__Juniper.bin ]; then ./amd-compiler amd_whirlpool ns ;fi; \
		fi

amd_whirlpool_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_whirlpool_long__Juniper.bin ]; then ./amd-compiler amd_whirlpool_long nso ;fi; \
		fi

amd_truecrypt: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_truecrypt__Juniper.bin ]; then ./amd-compiler amd_truecrypt no ;fi; \
		fi

amd_lastpass: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_lastpass__Juniper.bin ]; then ./amd-compiler amd_lastpass n ;fi; \
		fi

amd_keepass: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_keepass__Juniper.bin ]; then ./amd-compiler amd_keepass n ;fi; \
		fi

amd_keepass2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_keepass2__Juniper.bin ]; then ./amd-compiler amd_keepass2 n ;fi; \
		fi

amd_mozilla: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mozilla__Juniper.bin ]; then ./amd-compiler amd_mozilla n ;fi; \
		fi

amd_mozilla_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_mozilla_long__Juniper.bin ]; then ./amd-compiler amd_mozilla_long n ;fi; \
		fi

amd_pwsafe: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pwsafe__Juniper.bin ]; then ./amd-compiler amd_pwsafe n ;fi; \
		fi

amd_keyring: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_keyring__Juniper.bin ]; then ./amd-compiler amd_keyring n ;fi; \
		fi

amd_kwallet: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_kwallet__Juniper.bin ]; then ./amd-compiler amd_kwallet n ;fi; \
		fi

amd_msoffice_old: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_msoffice_old__Juniper.bin ]; then ./amd-compiler amd_msoffice_old n ;fi; \
		fi

amd_msoffice_old_md5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_msoffice_old_md5__Juniper.bin ]; then ./amd-compiler amd_msoffice_old_md5 n ;fi; \
		fi

amd_pdf2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pdf2__Juniper.bin ]; then ./amd-compiler amd_pdf2 n ;fi; \
		fi

amd_pdf3: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pdf3__Juniper.bin ]; then ./amd-compiler amd_pdf3 n ;fi; \
		fi

amd_pdf4: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pdf4__Juniper.bin ]; then ./amd-compiler amd_pdf4 n ;fi; \
		fi

amd_pdf5: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pdf5__Juniper.bin ]; then ./amd-compiler amd_pdf5 n ;fi; \
		fi

amd_sha384: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha384__Juniper.bin ]; then ./amd-compiler amd_sha384 ns ;fi; \
		fi

amd_sha384_long: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_sha384_long__Juniper.bin ]; then ./amd-compiler amd_sha384_long ns ;fi; \
		fi

amd_pdf6: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_pdf6__Juniper.bin ]; then ./amd-compiler amd_pdf6 n ;fi; \
		fi

amd_odf: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_odf__Juniper.bin ]; then ./amd-compiler amd_odf n ;fi; \
		fi

amd_odf2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_odf2__Juniper.bin ]; then ./amd-compiler amd_odf2 n ;fi; \
		fi

amd_grub2: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_grub2__Juniper.bin ]; then ./amd-compiler amd_grub2 n ;fi; \
		fi

amd_androidfde: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_androidfde__Juniper.bin ]; then ./amd-compiler amd_androidfde n ;fi; \
		fi

amd_osxml: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_osxml__Juniper.bin ]; then ./amd-compiler amd_osxml n ;fi; \
		fi

amd_a51: amd-compiler
		@if [ "$(CL_AMDFLAGS)" = "yes" ]; then \
		if [ ! -e amd_a51__Juniper.bin ]; then ./amd-compiler amd_a51 n ;fi; \
		fi



nvidia_ipb2_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ipb2_long__sm10.ptx ]; then ./nvidia-compiler nvidia_ipb2_long n ;fi; \
		fi

nvidia_ipb2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ipb2__sm10.ptx ]; then ./nvidia-compiler nvidia_ipb2 n ;fi; \
		fi

nvidia_md5_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_long ns ;fi; \
		fi

nvidia_md5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5__sm10.ptx ]; then ./nvidia-compiler nvidia_md5 ns ;fi; \
		fi

nvidia_sha1: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1 ns ;fi; \
		fi

nvidia_sha1_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_long ns ;fi; \
		fi

nvidia_ntlm: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ntlm__sm10.ptx ]; then ./nvidia-compiler nvidia_ntlm ns ;fi; \
		fi

nvidia_ntlm_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ntlm_long__sm10.ptx ]; then ./nvidia-compiler nvidia_ntlm_long ns ;fi; \
		fi

nvidia_md4: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md4__sm10.ptx ]; then ./nvidia-compiler nvidia_md4 ns ;fi; \
		fi

nvidia_md4_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md4_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md4_long ns ;fi; \
		fi

nvidia_pixmd5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pixmd5__sm10.ptx ]; then ./nvidia-compiler nvidia_pixmd5 ns ;fi; \
		fi

nvidia_pixmd5_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pixmd5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_pixmd5_long ns ;fi; \
		fi

nvidia_sha256: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha256__sm10.ptx ]; then ./nvidia-compiler nvidia_sha256 ns ;fi; \
		fi

nvidia_sha256_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha256_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha256_long ns ;fi; \
		fi

nvidia_lm: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_lm__sm10.ptx ]; then ./nvidia-compiler nvidia_lm ns ;fi; \
		fi

nvidia_lm_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_lm_long__sm10.ptx ]; then ./nvidia-compiler nvidia_lm_long ns ;fi; \
		fi

nvidia_md5md5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5md5__sm10.ptx ]; then ./nvidia-compiler nvidia_md5md5 ns ;fi; \
		fi

nvidia_md5md5_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5md5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5md5_long ns ;fi; \
		fi

nvidia_md5_passsalt: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5_passsalt__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_passsalt n ;fi; \
		fi

nvidia_md5_passsalt_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5_passsalt_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_passsalt_long n ;fi; \
		fi

nvidia_mysql5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mysql5__sm10.ptx ]; then ./nvidia-compiler nvidia_mysql5 ns ;fi; \
		fi

nvidia_mysql5_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mysql5_long__sm10.ptx ]; then ./nvidia-compiler nvidia_mysql5_long ns ;fi; \
		fi

nvidia_sha1_passsalt: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsalt__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt n ;fi; \
		fi

nvidia_sha1_passsalt_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsalt_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt_long n ;fi; \
		fi

nvidia_sha1_passsaltu: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsaltu__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsaltu n ;fi; \
		fi

nvidia_sha1_passsaltu_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsaltu_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsaltu_long n ;fi; \
		fi

nvidia_sha1_passsaltul_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsaltul_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsaltul_long n ;fi; \
		fi

nvidia_oracle_old: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_oracle_old__sm10.ptx ]; then ./nvidia-compiler nvidia_oracle_old n ;fi; \
		fi

nvidia_oracle_old_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_oracle_old_long__sm10.ptx ]; then ./nvidia-compiler nvidia_oracle_old_long n ;fi; \
		fi

nvidia_vbulletin: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_vbulletin__sm10.ptx ]; then ./nvidia-compiler nvidia_vbulletin n ;fi; \
		fi

nvidia_vbulletin_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_vbulletin_long__sm10.ptx ]; then ./nvidia-compiler nvidia_vbulletin_long n ;fi; \
		fi

nvidia_md5_saltpass: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5_saltpass__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_saltpass n ;fi; \
		fi

nvidia_md5_saltpass_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5_saltpass_long__sm10.ptx ]; then ./nvidia-compiler nvidia_md5_saltpass_long n ;fi; \
		fi

nvidia_sha1_saltpass: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_saltpass__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_saltpass n ;fi; \
		fi

nvidia_sha1_saltpass_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_saltpass_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_saltpass_long n ;fi; \
		fi

nvidia_desunix: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_desunix__sm10.ptx ]; then ./nvidia-compiler nvidia_desunix n ;fi; \
		fi

nvidia_desunix_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_desunix_long__sm10.ptx ]; then ./nvidia-compiler nvidia_desunix_long n ;fi; \
		fi

nvidia_phpass: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_phpass__sm10.ptx ]; then ./nvidia-compiler nvidia_phpass n ;fi; \
		fi

nvidia_md5unix: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_md5unix__sm10.ptx ]; then ./nvidia-compiler nvidia_md5unix n ;fi; \
		fi

nvidia_sha512: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha512__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512 ns ;fi; \
		fi

nvidia_sha512_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha512_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512_long ns ;fi; \
		fi

nvidia_osxlion: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_osxlion__sm10.ptx ]; then ./nvidia-compiler nvidia_osxlion n ;fi; \
		fi

nvidia_osxlion_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_osxlion_long__sm10.ptx ]; then ./nvidia-compiler nvidia_osxlion_long n ;fi; \
		fi

nvidia_sha1_passsalt_ulong: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha1_passsalt_ulong__sm10.ptx ]; then ./nvidia-compiler nvidia_sha1_passsalt_ulong n ;fi; \
		fi

nvidia_mscash: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mscash__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash n ;fi; \
		fi

nvidia_mscash_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mscash_long__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash_long n ;fi; \
		fi

nvidia_mscash2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mscash2__sm10.ptx ]; then ./nvidia-compiler nvidia_mscash2 n ;fi; \
		fi

nvidia_wpa: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_wpa__sm10.ptx ]; then ./nvidia-compiler nvidia_wpa n ;fi; \
		fi

nvidia_wpa2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_wpa2__sm10.ptx ]; then ./nvidia-compiler nvidia_wpa2 n ;fi; \
		fi

nvidia_zip: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_zip__sm10.ptx ]; then ./nvidia-compiler nvidia_zip n ;fi; \
		fi

nvidia_zip_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_zip_long__sm10.ptx ]; then ./nvidia-compiler nvidia_zip_long n ;fi; \
		fi

nvidia_zipu: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_zipu__sm10.ptx ]; then ./nvidia-compiler nvidia_zipu n ;fi; \
		fi

nvidia_zips: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_zips__sm10.ptx ]; then ./nvidia-compiler nvidia_zips n ;fi; \
		fi

nvidia_sha512unix: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha512unix__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512unix n ;fi; \
		fi

nvidia_rar: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_rar__sm10.ptx ]; then ./nvidia-compiler nvidia_rar n ;fi; \
		fi

nvidia_dmg: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_dmg__sm10.ptx ]; then ./nvidia-compiler nvidia_dmg n ;fi; \
		fi

nvidia_osx_old: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_osx_old__sm10.ptx ]; then ./nvidia-compiler nvidia_osx_old n ;fi; \
		fi

nvidia_osx_old_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_osx_old_long__sm10.ptx ]; then ./nvidia-compiler nvidia_osx_old_long n ;fi; \
		fi

nvidia_bfunix: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_bfunix__sm10.ptx ]; then ./nvidia-compiler nvidia_bfunix n ;fi; \
		fi

nvidia_phpass512: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_phpass512__sm10.ptx ]; then ./nvidia-compiler nvidia_phpass512 n ;fi; \
		fi

nvidia_django256: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_django256__sm10.ptx ]; then ./nvidia-compiler nvidia_django256 n ;fi; \
		fi

nvidia_sha256unix: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha256unix__sm10.ptx ]; then ./nvidia-compiler nvidia_sha256unix n ;fi; \
		fi

nvidia_o5logon: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_o5logon__sm10.ptx ]; then ./nvidia-compiler nvidia_o5logon n ;fi; \
		fi

nvidia_o5logon_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_o5logon_long__sm10.ptx ]; then ./nvidia-compiler nvidia_o5logon_long n ;fi; \
		fi

nvidia_sha512_passsaltu: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha512_passsaltu__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512_passsaltu n ;fi; \
		fi

nvidia_sha512_passsaltu_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha512_passsaltu_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha512_passsaltu_long n ;fi; \
		fi

nvidia_msoffice2007: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_msoffice2007__sm10.ptx ]; then ./nvidia-compiler nvidia_msoffice2007 n ;fi; \
		fi

nvidia_msoffice2010: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_msoffice2010__sm10.ptx ]; then ./nvidia-compiler nvidia_msoffice2010 n ;fi; \
		fi

nvidia_msoffice2013: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_msoffice2013__sm10.ptx ]; then ./nvidia-compiler nvidia_msoffice2013 n ;fi; \
		fi

nvidia_luks128: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_luks128__sm10.ptx ]; then ./nvidia-compiler nvidia_luks128 n ;fi; \
		fi

nvidia_luks256: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_luks256__sm10.ptx ]; then ./nvidia-compiler nvidia_luks256 n ;fi; \
		fi

nvidia_ripemd160: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ripemd160__sm10.ptx ]; then ./nvidia-compiler nvidia_ripemd160 ns ;fi; \
		fi

nvidia_ripemd160_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_ripemd160_long__sm10.ptx ]; then ./nvidia-compiler nvidia_ripemd160_long ns ;fi; \
		fi

nvidia_whirlpool: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_whirlpool__sm10.ptx ]; then ./nvidia-compiler nvidia_whirlpool ns ;fi; \
		fi

nvidia_whirlpool_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_whirlpool_long__sm10.ptx ]; then ./nvidia-compiler nvidia_whirlpool_long ns ;fi; \
		fi

nvidia_truecrypt: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_truecrypt__sm10.ptx ]; then ./nvidia-compiler nvidia_truecrypt n ;fi; \
		fi

nvidia_lastpass: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_lastpass__sm10.ptx ]; then ./nvidia-compiler nvidia_lastpass n ;fi; \
		fi

nvidia_keepass: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_keepass__sm10.ptx ]; then ./nvidia-compiler nvidia_keepass n ;fi; \
		fi

nvidia_keepass2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_keepass2__sm10.ptx ]; then ./nvidia-compiler nvidia_keepass2 n ;fi; \
		fi

nvidia_mozilla: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mozilla__sm10.ptx ]; then ./nvidia-compiler nvidia_mozilla n ;fi; \
		fi

nvidia_mozilla_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_mozilla_long__sm10.ptx ]; then ./nvidia-compiler nvidia_mozilla_long n ;fi; \
		fi

nvidia_pwsafe: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pwsafe__sm10.ptx ]; then ./nvidia-compiler nvidia_pwsafe n ;fi; \
		fi

nvidia_keyring: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_keyring__sm10.ptx ]; then ./nvidia-compiler nvidia_keyring n ;fi; \
		fi

nvidia_kwallet: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_kwallet__sm10.ptx ]; then ./nvidia-compiler nvidia_kwallet n ;fi; \
		fi

nvidia_msoffice_old: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_msoffice_old__sm10.ptx ]; then ./nvidia-compiler nvidia_msoffice_old n ;fi; \
		fi

nvidia_msoffice_old_md5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_msoffice_old_md5__sm10.ptx ]; then ./nvidia-compiler nvidia_msoffice_old_md5 n ;fi; \
		fi

nvidia_pdf2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pdf2__sm10.ptx ]; then ./nvidia-compiler nvidia_pdf2 n ;fi; \
		fi

nvidia_pdf3: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pdf3__sm10.ptx ]; then ./nvidia-compiler nvidia_pdf3 n ;fi; \
		fi

nvidia_pdf4: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pdf4__sm10.ptx ]; then ./nvidia-compiler nvidia_pdf4 n ;fi; \
		fi

nvidia_pdf5: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pdf5__sm10.ptx ]; then ./nvidia-compiler nvidia_pdf5 n ;fi; \
		fi

nvidia_sha384: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha384__sm10.ptx ]; then ./nvidia-compiler nvidia_sha384 ns ;fi; \
		fi

nvidia_sha384_long: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_sha384_long__sm10.ptx ]; then ./nvidia-compiler nvidia_sha384_long ns ;fi; \
		fi

nvidia_pdf6: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_pdf6__sm10.ptx ]; then ./nvidia-compiler nvidia_pdf6 n ;fi; \
		fi

nvidia_odf: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_odf__sm10.ptx ]; then ./nvidia-compiler nvidia_odf n ;fi; \
		fi

nvidia_odf2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_odf2__sm10.ptx ]; then ./nvidia-compiler nvidia_odf2 n ;fi; \
		fi

nvidia_grub2: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_grub2__sm10.ptx ]; then ./nvidia-compiler nvidia_grub2 n ;fi; \
		fi

nvidia_androidfde: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_androidfde__sm10.ptx ]; then ./nvidia-compiler nvidia_androidfde n ;fi; \
		fi

nvidia_osxml: nvidia-compiler
		@if [ "$(CL_NVFLAGS)" = "yes" ]; then \
		if [ ! -e nvidia_osxml__sm10.ptx ]; then ./nvidia-compiler nvidia_osxml n ;fi; \
		fi
