
/* must load ROOT crap veeery early due to pollution */
#undef Copy

#include <TROOT.h>
#include <TClass.h>
#include <TMethod.h>
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

SV*
CallMethod(className, methodName, argv)
    char* className
    char* methodName
    SV* argv
  INIT:
    STRLEN len;
    AV* arguments;
  CODE:
  /*
   * Strategy:
   * - Is it a class or object method call?
   *   => if first argument is an eSTRING, it's a class method call
   *   => otherwise, object method (double check with eTOBJECT)
   * - If it's a class method, check for constructor
   * - convert parameters to cproto
   * - resolve method via CINT
   * - resolve return type via CINT
   * - caching?
   * - convert arguments to state suitebable for CINT
   * - call method
   * - convert return type to SV*
   * - return
   * 
   */
    /* not a reference to an array of arguments? */
    if (!SvROK(argv) || SvTYPE(SvRV(argv)) != SVt_PVAV)
      croak("Need array reference as third argument");
    arguments = (AV*)SvRV(argv);
    RETVAL = gResolver.CallMethod(aTHX_ className, methodName, arguments);
  OUTPUT: RETVAL

SV*
type(sv)
    SV* sv
  INIT:
    SOOT::BasicType type;
  PPCODE:
    dXSTARG;
    type = GuessType(aTHX_ sv);
    if (type == eARRAY) {
      const char* type_str = SOOT::gCompositeTypeStrings[GuessCompositeType(aTHX_ sv)];
      XPUSHp(type_str, strlen(type_str));
    }
    else {
      const char* type_str = SOOT::gBasicTypeStrings[type];
      XPUSHp(type_str, strlen(type_str));
    }

SV*
cproto(sv)
    SV* sv
  INIT:
    SOOT::BasicType type;
  PPCODE:
    dXSTARG;
    type = GuessType(aTHX_ sv);
    STRLEN len;
    const char* cproto = CProtoFromType(aTHX_ sv, len, type);
    XPUSHp(cproto, len);

