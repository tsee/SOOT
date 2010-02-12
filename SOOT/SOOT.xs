
/* must load ROOT crap veeery early due to pollution */
#undef Copy

#include <TROOT.h>
#include <TClass.h>
#include <Reflex/Scope.h>

#include "ClassGenerator.h"
#include "ROOTResolver.h"

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

#include <iostream>
#include <string>
#include <cstring>

using namespace SOOT;
using namespace std;

SOOT::ROOTResolver gResolver;

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
    char* className
    char* methodName
    SV* argv
  INIT:
    STRLEN len;
    AV* arguments;
  CODE:
    /* not a reference to an array of arguments? */
    if (!SvROK(argv) || SvTYPE(SvRV(argv)) != SVt_PVAV)
      croak("Need array reference as third argument");
    arguments = (AV*)SvRV(argv);
    gResolver.FindMethod(aTHX_ className, methodName, arguments);
    XSRETURN_UNDEF;

SV*
type(sv)
    SV* sv
  INIT:
    SOOT::BasicType type;
  PPCODE:
    dXSTARG;
    type = GuessType(aTHX_ sv);
    const char* type_str = SOOT::gBasicTypeStrings[type];
    XPUSHp(type_str, strlen(type_str));

