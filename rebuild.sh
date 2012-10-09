#!/bin/bash

rm aclocal.m4
rm ltmain.sh
#rm configure
autoscan ; autoconf ; aclocal ;libtoolize --force ; autoreconf -vi ; automake --add-missing ; autoconf
#aclocal ; autoheader ; automake ; autoconf