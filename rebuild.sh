#!/bin/bash
autoscan && autoconf && aclocal && autoreconf -vi && automake --add-missing && autoconf
#aclocal && autoheader && automake && autoconf