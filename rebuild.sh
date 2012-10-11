#!/bin/bash
#rm configure
#autoscan ; autoconf ; aclocal ;
find m4/ |xargs --replace=as unlink "as" 2>/dev/null
if [ -e ltmain.sh ];then unlink ltmain.sh; fi
rm -f autom4te.cache/*
rm -f libtool
rm -f configure.status
rm -f config.status
rm -f configure
rm -f src/*.lo
rm -f src/*.la
rm -f src/.libs/*
rm -f src/Makefile.in
libtoolize --force ; autoreconf -vi ; automake --add-missing ;automake; autoconf
#aclocal ; autoheader ; automake ; autoconf