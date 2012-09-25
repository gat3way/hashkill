AC_DEFUN([AX_CHECK_JSONLIB],
#
# Handle user hints
#
[AC_MSG_CHECKING(if json-c is available)
AC_ARG_WITH(json,
[  --with-json=DIR	  root directory path of jsonlib installation]
[  --without-json	  disable json (no session functionality)],
[if test "$withval" != no ; then
  jsonlib_places="/usr/local /usr /opt/local /sw"
  AC_MSG_RESULT(yes)
  if test -d "$withval"
  then
    jsonlib_places="$withval $jsonlib_places"
  else
    AC_MSG_WARN([Sorry, $withval does not exist, checking usual places])
  fi
  
else
  AC_MSG_RESULT(no)
  ADDON="";
fi],
[AC_MSG_RESULT(yes)])

#JS_CFLAGS="-ljson"
JS_LIBS="-ljson"
LIBS=""

#
# Locate jsonlib, if wanted
#
if test -n "${jsonlib_places}"
then
	# check the user supplied or any other more or less 'standard' place:
	#   Most UNIX systems      : /usr/local and /usr
	#   MacPorts / Fink on OSX : /opt/local respectively /sw
	for JSONLIB_HOME in ${jsonlib_places} ; do
	  if test -f "/usr/include/json/json.h"; then break; fi
	  JSONLIB_HOME=""
	done
fi

        JSONLIB_OLD_LDFLAGS=$LDFLAGS
        JSONLIB_OLD_CPPFLAGS=$CPPFLAGS
        LDFLAGS="$LDFLAGS"
        AC_LANG_SAVE
        AC_LANG_C
        AC_CHECK_LIB(json, json_tokener_parse, [jsonlib_cv_libjson=yes], [jsonlib_cv_libjson=no])
    	AC_CHECK_HEADER(json/json.h, [jsonlib_cv_jsonlib_h=yes], [jsonlib_cv_jsonlib_h=no])
        AC_LANG_RESTORE
        if test "$jsonlib_cv_libjson" = "yes" -a "$jsonlib_cv_jsonlib_h" = "yes"
        then
                #
                # If both library and header were found, use them
                #
                JS_CFLAGS="-DHAVE_JSON_JSON_H"
                #AC_CHECK_LIB(json, json_tokener_parse)
                AC_MSG_CHECKING(jsonlib in ${JSONLIB_HOME})
                AC_MSG_RESULT(ok)
                AC_SUBST([JS_CFLAGS])
                AC_SUBST([JS_LIBS])
        else
                #
                # If either header or library was not found, revert and bomb
                #
                AC_MSG_CHECKING(jsonlib in ${JSONLIB_HOME})
                AC_MSG_RESULT(failed)
        fi

])

