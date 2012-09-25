AC_DEFUN([AX_CHECK_CURL],
#
# Handle user hints
#
[AC_MSG_CHECKING(if libcurl is available)
AC_ARG_WITH(curl,
[  --with-curl=DIR	  root directory path of curllib installation ]
[  --without-curl	  to disable curllib usage completely],
[if test "$withval" != no ; then
  curllib_places="/usr/local /usr /opt/local /sw"
  AC_MSG_RESULT(yes)
  if test -d "$withval"
  then
    curllib_places="$withval $curllib_places"
  else
    AC_MSG_WARN([Sorry, $withval does not exist, checking usual places])
  fi
else
  AC_MSG_RESULT(no)
fi],
[AC_MSG_RESULT(yes)])

CURL_CFLAGS="-lcurl -DHAVE_CURL_CURL_H"
CURL_LIBS="-lcurl"


#
# Locate curllib, if wanted
#
if test -n "${curllib_places}"
then
	# check the user supplied or any other more or less 'standard' place:
	#   Most UNIX systems      : /usr/local and /usr
	#   MacPorts / Fink on OSX : /opt/local respectively /sw
	for CURLLIB_HOME in ${curllib_places} ; do
	  if test -f "/usr/include/curl/curl.h"; then break; fi
	  CURLLIB_HOME=""
	done


        CURLLIB_OLD_LDFLAGS=$LDFLAGS
        CURLLIB_OLD_CPPFLAGS=$LDFLAGS
        LDFLAGS="$LDFLAGS"
        AC_LANG_SAVE
        AC_LANG_C
        AC_CHECK_LIB(curl, curl_version, [curllib_cv_libcurl=yes], [curllib_cv_libcurl=no])
        AC_CHECK_HEADER(curl.h, [curllib_cv_curllib_h=yes], [curllib_cv_curllib_h=no])
        AC_LANG_RESTORE
        if test "$curllib_cv_libcurl" = "yes" -a "$curllib_cv_curllib_h" = "yes"
        then
                #
                # If both library and header were found, use them
                #
                AC_CHECK_LIB(curl, curl_version)
                AC_MSG_CHECKING(curllib in ${CURLLIB_HOME})
                AC_MSG_RESULT(ok)
                AC_SUBST([CURL_CFLAGS])
                AC_SUBST([CURL_LIBS])
        else
                #
                # If either header or library was not found, revert and bomb
                #
                AC_MSG_CHECKING(curllib in ${CURLLIB_HOME})
                AC_MSG_RESULT(failed)
        fi
fi

])

