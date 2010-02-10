
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#ifdef __cplusplus
}
#endif


#include "ClassGenerator.h"
#include <iostream>
#include <string>
#include <cstring>

using namespace SOOT;
using namespace std;

/*
void
AUTOLOAD(...)
  PPCODE:
    SV* fullname = get_sv("AUTOLOAD", 0);
    if (fullname == 0 || !SvOK(fullname))
      croak("$AUTOLOAD undefined in AUTOLOAD");
    STRLEN len;
    char* strptr = SvPV(fullname, len);
    if (len < 2)
      croak("$AUTOLOAD is empty string in AUTOLOAD");
    char* lastcolon = strptr+len;
    for (; lastcolon != strptr; --lastcolon) {
      if (*lastcolon == ':')
        break;
    }
    if (lastcolon == strptr)
      croak("Cannot autoload method call without a class");
    *(lastcolon-1) = '\0';
    SV* class_name = newSVpv(strptr, lastcolon-1-strptr);
    *(lastcolon-1) = ':';
    SV* method_name = newSVpv(lastcolon+1, strptr+len-lastcolon);
    cout << class_name << endl;
    cout << method_name << endl;
    sv_2mortal(class_name);
    sv_2mortal(method_name);
    XSRETURN_UNDEF;
*/

MODULE = SOOT		PACKAGE = SOOT

PROTOTYPES: DISABLE

INCLUDE: XS/SOOTBOOT.xs

INCLUDE_COMMAND: $^X -MExtUtils::XSpp::Cmd -e xspp -- -t typemap.xsp SOOT.xsp

MODULE = SOOT		PACKAGE = SOOT

void
CallMethod(className, methodName, argv)
    const char* className
    const char* methodName
    SV* argv
  INIT:
    STRLEN len;
    AV* arguments;
  CODE:
    /* not a reference to an array of arguments? */
    if (!SvROK(argv) || SvTYPE(SvRV(argv)) != SVt_PVAV)
      croak("Need array reference as third argument");
    arguments = (AV*)SvRV(argv);
    XSRETURN_UNDEF;

