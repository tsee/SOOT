
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






/* lifted from autobox */

#define SOOT_TYPE_RETURN(type) STMT_START { *len = (sizeof(type) - 1); return type; } STMT_END

static const char*
soot_type(pTHX_ SV * const sv, STRLEN *len) {
    switch (SvTYPE(sv)) {
        case SVt_NULL:
            SOOT_TYPE_RETURN("UNDEF");
        case SVt_IV:
            SOOT_TYPE_RETURN("INTEGER");
        case SVt_PVIV:
            if (SvIOK(sv)) {
                SOOT_TYPE_RETURN("INTEGER");
            } else {
                SOOT_TYPE_RETURN("STRING");
            }
        case SVt_NV:
            if (SvIOK(sv)) {
                SOOT_TYPE_RETURN("INTEGER");
            } else {
                SOOT_TYPE_RETURN("FLOAT");
            }
        case SVt_PVNV:
            if (SvNOK(sv)) {
                SOOT_TYPE_RETURN("FLOAT");
            } else if (SvIOK(sv)) {
                SOOT_TYPE_RETURN("INTEGER");
            } else {
                SOOT_TYPE_RETURN("STRING");
            }
#ifdef SVt_RV /* no longer defined by default if PERL_CORE is defined */
        case SVt_RV:
#endif
        case SVt_PV:
        case SVt_PVMG:
#ifdef SvVOK
            if (SvVOK(sv)) {
                SOOT_TYPE_RETURN("VSTRING");
            }
#endif
            if (SvROK(sv)) {
                SOOT_TYPE_RETURN("REF");
            } else {
                SOOT_TYPE_RETURN("STRING");
            }
        case SVt_PVLV:
            if (SvROK(sv)) {
                SOOT_TYPE_RETURN("REF");
            } else if (LvTYPE(sv) == 't' || LvTYPE(sv) == 'T') { /* tied lvalue */
                if (SvIOK(sv)) {
                    SOOT_TYPE_RETURN("INTEGER");
                } else if (SvNOK(sv)) {
                    SOOT_TYPE_RETURN("FLOAT");
                } else {
                    SOOT_TYPE_RETURN("STRING");
                }
            } else {
                SOOT_TYPE_RETURN("LVALUE");
            }
        case SVt_PVAV:
            SOOT_TYPE_RETURN("ARRAY");
        case SVt_PVHV:
            SOOT_TYPE_RETURN("HASH");
        case SVt_PVCV:
            SOOT_TYPE_RETURN("CODE");
        case SVt_PVGV:
            SOOT_TYPE_RETURN("GLOB");
        case SVt_PVFM:
            SOOT_TYPE_RETURN("FORMAT");
        case SVt_PVIO:
            SOOT_TYPE_RETURN("IO");
#ifdef SVt_BIND
        case SVt_BIND:
            SOOT_TYPE_RETURN("BIND");
#endif
#ifdef SVt_REGEXP
        case SVt_REGEXP:
            SOOT_TYPE_RETURN("REGEXP");
#endif
        default:
            SOOT_TYPE_RETURN("UNKNOWN");
    }
}




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
  PPCODE:
    dXSTARG;
    STRLEN len;
    const char* reftype = soot_type(aTHX_ sv, &len);
    XPUSHp(reftype, len);

