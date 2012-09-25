AC_DEFUN([AX_CHECK_ADL],
[AC_MSG_CHECKING(if adl is enabled)
AC_ARG_WITH(adl,
[  --with-adl=DIR	  root directory path of adl installation]
[  --without-adl		  to disable adl usage completely],
[if test "$withval" != no ; then
AC_MSG_RESULT(yes)
if test -d "$withval"
then
adl_places="$withval"
IPLACE=$withval
else
AC_MSG_WARN([Sorry, $withval does not exist])
fi
else
AC_MSG_RESULT(no)
fi],
[AC_MSG_RESULT(yes)])




#
# Locate adl

        ADL_OLD_LDFLAGS=$LDFLAGS
        ADL_OLD_CPPFLAGS=$CPPFLAGS
	ADL_CFLAGS="-I$IPLACE/include -I$ADLROOT/include "
	CPPFLAGS="-I$IPLACE/include -I$ADLROOT/include $CPPFLAGS"
	ADL_HOME=$CPPFLAGS
        LDFLAGS="$LDFLAGS"
        AC_LANG_SAVE
        AC_LANG_C
        AC_CHECK_HEADER(adl_defines.h, [adl_cv_adl_defines_h=yes], [adl_cv_adl_defines_h=no])
        AC_LANG_RESTORE
        if test "$adl_cv_adl_defines_h" = "yes"
        then
                #
                # If both library and header were found, use them
                #
                AC_MSG_CHECKING(adl in ${ADL_HOME})
                AC_MSG_RESULT(ok)
                ADL_CFLAGS="-DHAVE_ADL_DEFINES_H -I$IPLACE/include -I$ADLROOT/include "
                AC_SUBST([ADL_CFLAGS])
                AC_SUBST([ADL_LIBS])
        else
                #
                # If either header or library was not found, revert and bomb
                #
                AC_MSG_CHECKING(adl in ${ADL_HOME})
                AC_MSG_RESULT(failed)
        fi

])

