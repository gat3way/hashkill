ifneq ($(DESTDIR),"")
    IDESTDIR=$(DESTDIR)/
endif


CFLAGS += -Wall -I../ -shared -g -O3 -fpic  -fomit-frame-pointer -funroll-loops -minline-all-stringops  -momit-leaf-frame-pointer -Wno-unused-result
#CFLAGS = -Wall -I../ -shared  -O2 -fpic  -fomit-frame-pointer -minline-all-stringops  -Wall -funroll-loops -m32


CC = gcc


all: plugin_md5 plugin_md5md5 plugin_joomla plugin_sha1 plugin_smf plugin_md4 \
     plugin_ntlm plugin_desunix plugin_oscommerce plugin_mysql5 plugin_ipb2 plugin_vbulletin \
     plugin_mssql-2000 plugin_mssql-2005 plugin_phpbb3 plugin_wordpress plugin_sha256 \
     plugin_sha512 plugin_apr1 plugin_md5unix plugin_sha512unix plugin_privkey plugin_oracle11g \
     plugin_pixmd5 plugin_ripemd160 plugin_sha1sha1 plugin_lm plugin_oracle-old \
     plugin_nsldap plugin_nsldaps plugin_sapg plugin_mscash plugin_mediawiki plugin_zip plugin_osxlion \
     plugin_mscash2 plugin_wpa plugin_rar plugin_dmg plugin_osx-old plugin_bfunix plugin_drupal7 \
     plugin_django256 plugin_sha256unix plugin_o5logon plugin_mssql2012 plugin_msoffice \
     plugin_msoffice-old plugin_luks plugin_whirlpool plugin_truecrypt plugin_lastpass \
     plugin_keepass plugin_pdf plugin_keyring plugin_pwsafe plugin_mozilla plugin_kwallet \
     plugin_sha384 plugin_odf plugin_grub2 plugin_androidfde plugin_androidpin plugin_samsungpin \
     plugin_osx-ml plugin_a51
     #plugin_bitcoin  plugin_mysql-old plugin_test 


plugin_md5:
	@if [ ! -e md5.so ]; then  $(CC)  plugin.c md5.c -o md5.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_md4:
	@if [ ! -e md4.so ]; then  $(CC)  plugin.c md4.c -o md4.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_md5md5:
	@if [ ! -e md5md5.so ]; then  $(CC)  plugin.c md5md5.c -o md5md5.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_oscommerce:
	@if [ ! -e oscommerce.so ]; then  $(CC)  plugin.c oscommerce.c -o oscommerce.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_joomla:
	@if [ ! -e joomla.so ]; then  $(CC)  plugin.c joomla.c -o joomla.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_sha1:
	@if [ ! -e sha1.so ]; then  $(CC)  plugin.c sha1.c -o sha1.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_sha256:
	@if [ ! -e sha256.so ]; then  $(CC)  plugin.c sha256.c -o sha256.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_sha512:
	@if [ ! -e sha512.so ]; then  $(CC)  plugin.c sha512.c -o sha512.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_osxlion:
	@if [ ! -e osxlion.so ]; then  $(CC)  plugin.c osxlion.c -o osxlion.so $(CFLAGS) $(LDFLAGS) ;fi


plugin_ipb2:
	@if [ ! -e ipb2.so ]; then  $(CC)  plugin.c ipb2.c -o ipb2.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_mysql5:
	@if [ ! -e mysql5.so ]; then  $(CC)  plugin.c mysql5.c -o mysql5.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_md5unix:
	@if [ ! -e md5unix.so ]; then  $(CC)  plugin.c md5unix.c sha256-crypt.c sha512-crypt.c md5-crypt.c -o md5unix.so $(CFLAGS) $(LDFLAGS) -w -funroll-all-loops ;fi

plugin_sha512unix:
	@if [ ! -e sha512unix.so ]; then  $(CC)  plugin.c sha512unix.c sha256-crypt.c sha512-crypt.c md5-crypt.c -o sha512unix.so $(CFLAGS) $(LDFLAGS) -w -funroll-all-loops ;fi

plugin_sha256unix:
	@if [ ! -e sha256unix.so ]; then  $(CC)  plugin.c sha256unix.c sha256-crypt.c sha512-crypt.c md5-crypt.c -o sha256unix.so $(CFLAGS) $(LDFLAGS) -w -funroll-all-loops ;fi


plugin_desunix:
	@if [ ! -e desunix.so ]; then  $(CC)  plugin.c desunix.c -o desunix.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_smf:
	@if [ ! -e smf.so ]; then  $(CC)  plugin.c smf.c -o smf.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_vbulletin:
	@if [ ! -e vbulletin.so ]; then  $(CC)  plugin.c vbulletin.c -o vbulletin.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_wordpress:
	@if [ ! -e wordpress.so ]; then  $(CC)  plugin.c wordpress.c phpass.c -o wordpress.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_phpbb3:
	@if [ ! -e phpbb3.so ]; then  $(CC)  plugin.c phpbb3.c phpass.c -o phpbb3.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_mysql-old:
	@if [ ! -e mysql-old.so ]; then  $(CC)  plugin.c mysql-old.c password-mysql.c -o mysql-old.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_privkey:
	@if [ ! -e privkey.so ]; then  $(CC)  plugin.c privkey.c -o privkey.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_ripemd160:
	@if [ ! -e ripemd160.so ]; then  $(CC)  plugin.c ripemd160.c -o ripemd160.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_sha1sha1:
	@if [ ! -e sha1sha1.so ]; then  $(CC)  plugin.c sha1sha1.c -o sha1sha1.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_ntlm:
	@if [ ! -e ntlm.so ]; then  $(CC)  plugin.c ntlm.c -o ntlm.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_lm:
	@if [ ! -e lm.so ]; then  $(CC)  plugin.c lm.c -o lm.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_oracle11g:
	@if [ ! -e oracle11g.so ]; then  $(CC)  plugin.c oracle11g.c -o oracle11g.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_oracle-old:
	@if [ ! -e oracle-old.so ]; then  $(CC)  plugin.c oracle-old.c -o oracle-old.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_apr1:
	@if [ ! -e apr1.so ]; then  $(CC)  plugin.c apr1.c apr1-crypt.c  -o apr1.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_pixmd5:
	@if [ ! -e pixmd5.so ]; then  $(CC)  plugin.c pixmd5.c -o pixmd5.so -w $(CFLAGS) $(LDFLAGS) ;fi

plugin_mssql-2000:
	@if [ ! -e mssql-2000.so ]; then  $(CC)  plugin.c mssql-2000.c  -o mssql-2000.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_mssql-2005:
	@if [ ! -e mssql-2005.so ]; then  $(CC)  plugin.c mssql-2005.c  -o mssql-2005.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_rar:
	@if [ ! -e rar.so ]; then  $(CC) -fPIC -shared plugin.c rar.c unrar.c  -o rar.so $(CFLAGS) -lcrypto -Wno-unused-value -Wno-unused-function -Wno-switch $(LDFLAGS) ;fi

plugin_null:
	@if [ ! -e null.so ]; then  $(CC)  plugin.c null.c -o null.so $(CFLAGS) $(LDFLAGS)  -O0 ;fi

plugin_nsldap:
	@if [ ! -e nsldap.so ]; then  $(CC)  plugin.c nsldap.c base64.c -o nsldap.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_nsldaps:
	@if [ ! -e nsldaps.so ]; then  $(CC)  plugin.c nsldaps.c base64.c -o nsldaps.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_sapg:
	@if [ ! -e sapg.so ]; then  $(CC)  plugin.c sapg.c -o sapg.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_mscash:
	@if [ ! -e mscash.so ]; then  $(CC)  plugin.c mscash.c -o mscash.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_mscash2:
	@if [ ! -e mscash2.so ]; then  $(CC)  plugin.c mscash2.c -o mscash2.so $(CFLAGS) $(LDFLAGS)   ;fi


plugin_mediawiki:
	@if [ ! -e mediawiki.so ]; then  $(CC)  plugin.c mediawiki.c -o mediawiki.so $(CFLAGS) $(LDFLAGS)   ;fi

plugin_zip:
	@if [ ! -e zip.so ]; then  $(CC)  plugin.c zip.c -o zip.so $(CFLAGS) $(LDFLAGS) -lz ;fi

plugin_bitcoin:
	@if [ ! -e bitcoin.so ]; then  $(CC)  plugin.c bitcoin.c -o bitcoin.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_wpa:
	@if [ ! -e wpa.so ]; then  $(CC)  plugin.c wpa.c -o wpa.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_dmg:
	@if [ ! -e dmg.so ]; then  $(CC)  -fPIC plugin.c dmg.c -o dmg.so $(CFLAGS) $(LDFLAGS) -lcrypto -O3;fi

plugin_osx-old:
	@if [ ! -e osx-old.so ]; then  $(CC)  plugin.c osx-old.c -o osx-old.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_bfunix:
	@if [ ! -e bfunix.so ]; then  $(CC)  plugin.c bfunix.c bf-crypt.c -o bfunix.so $(CFLAGS) $(LDFLAGS) -w -funroll-all-loops;fi

plugin_drupal7:
	@if [ ! -e drupal7.so ]; then  $(CC)  plugin.c drupal7.c phpass-512.c -o drupal7.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_django256:
	@if [ ! -e django256.so ]; then  $(CC)  plugin.c django256.c base64.c -o django256.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_o5logon:
	@if [ ! -e o5logon.so ]; then  $(CC)  plugin.c o5logon.c -o o5logon.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_mssql2012:
	@if [ ! -e mssql-2012.so ]; then  $(CC)  plugin.c mssql-2012.c -o mssql-2012.so $(CFLAGS) $(LDFLAGS)  ;fi

plugin_msoffice:
	@if [ ! -e msoffice.so ]; then  $(CC)  plugin.c msoffice.c base64.c -o msoffice.so $(CFLAGS) $(LDFLAGS) -w -funroll-all-loops ;fi

plugin_msoffice-old:
	@if [ ! -e msoffice-old.so ]; then  $(CC)  plugin.c msoffice-old.c base64.c -o msoffice-old.so $(CFLAGS) $(LDFLAGS) -lcrypto -w -funroll-all-loops ;fi

plugin_luks:
	@if [ ! -e luks.so ]; then  $(CC)  plugin.c luks.c -o luks.so $(CFLAGS) $(LDFLAGS) -lcrypto -Wall -funroll-all-loops ;fi

plugin_whirlpool:
	@if [ ! -e whirlpool.so ]; then  $(CC)  plugin.c whirlpool.c -o whirlpool.so $(CFLAGS) $(LDFLAGS) -Wall -funroll-all-loops ;fi

plugin_truecrypt:
	@if [ ! -e truecrypt.so ]; then  $(CC)  plugin.c truecrypt.c -o truecrypt.so $(CFLAGS) $(LDFLAGS) -Wall -funroll-all-loops -lcrypto;fi

plugin_lastpass:
	@if [ ! -e lastpass.so ]; then  $(CC)  plugin.c lastpass.c -o lastpass.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_keepass:
	@if [ ! -e keepass.so ]; then  $(CC)  plugin.c keepass.c -o keepass.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_pdf:
	@if [ ! -e pdf.so ]; then  $(CC)  plugin.c pdf.c -o pdf.so $(CFLAGS) $(LDFLAGS) -Wall -lcrypto;fi

plugin_mozilla:
	@if [ ! -e mozilla.so ]; then  $(CC)  plugin.c mozilla.c -o mozilla.so $(CFLAGS) $(LDFLAGS) -Wall -lcrypto;fi

plugin_keyring:
	@if [ ! -e keyring.so ]; then  $(CC)  plugin.c keyring.c -o keyring.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_pwsafe:
	@if [ ! -e pwsafe.so ]; then  $(CC)  plugin.c pwsafe.c -o pwsafe.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_kwallet:
	@if [ ! -e kwallet.so ]; then  $(CC)  plugin.c kwallet.c -o kwallet.so $(CFLAGS) $(LDFLAGS) -lcrypto -Wall ;fi

plugin_sha384:
	@if [ ! -e sha384.so ]; then  $(CC)  plugin.c sha384.c -o sha384.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_odf:
	@if [ ! -e odf.so ]; then  $(CC)  base64.c plugin.c odf.c -o odf.so $(CFLAGS) $(LDFLAGS) -Wall -lz -lcrypto ;fi

plugin_grub2:
	@if [ ! -e grub2.so ]; then  $(CC)  plugin.c grub2.c -o grub2.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_osx-ml:
	@if [ ! -e osx-ml.so ]; then  $(CC)  plugin.c osx-ml.c -o osx-ml.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_androidpin:
	@if [ ! -e androidpin.so ]; then  $(CC)  plugin.c androidpin.c -o androidpin.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_samsungpin:
	@if [ ! -e samsungpin.so ]; then  $(CC)  plugin.c samsungpin.c -o samsungpin.so $(CFLAGS) $(LDFLAGS) -Wall ;fi

plugin_androidfde:
	@if [ ! -e androidfde.so ]; then  $(CC)  plugin.c androidfde.c -o androidfde.so $(CFLAGS) $(LDFLAGS) -lcrypto -Wall ;fi


plugin_test:
	@if [ ! -e test.so ]; then  $(CC)  plugin.c test.c -o test.so $(CFLAGS) $(LDFLAGS) ;fi

plugin_a51:
	@if [ ! -e a51.so ]; then  $(CC)  plugin.c a51.c -o a51.so $(CFLAGS) $(LDFLAGS) ;fi



install:
	@echo Copying plugins...
	@mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/plugins
	@cp -vf *.so $(IDESTDIR)$(IDATADIR)/hashkill/plugins
	@echo Done

install-strip:
	@echo Copying plugins...
	-strip *.so
	@mkdir -p $(IDESTDIR)$(IDATADIR)/hashkill/plugins
	@cp -vf *.so $(IDESTDIR)$(IDATADIR)/hashkill/plugins
	@echo Done


clean:
	-rm -f *.so

uninstall:
	-rm -rf /usr/share/hashkill

distclean: clean

maintainer-clean: clean
