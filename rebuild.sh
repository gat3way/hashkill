#!/bin/bash
#rm configure
#autoscan ; autoconf ; aclocal ;
libtoolize --force ; autoreconf -vi ; automake --add-missing ; autoconf
#aclocal ; autoheader ; automake ; autoconf