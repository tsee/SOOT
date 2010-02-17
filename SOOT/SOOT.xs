
/* must load polluting ROOT stuff veeery early due to pollution */
#undef Copy

#include <TROOT.h>
#include <TClass.h>
#include <TMethod.h>
#include <Reflex/Scope.h>
#include <CallFunc.h>
#include <Class.h>
#include <TBaseClass.h>
#include <TList.h>
#include <TSystem.h>
#include <TApplication.h>
#include <TRandom.h>
#include <TBenchmark.h>
#include <TPad.h>
#include <TStyle.h>
#include <TDirectory.h>
#include <TCanvas.h>
#include <TVirtualPad.h>

// manually include headers for classes with explicit wrappers
// rootclasses.h was auto-generated to include all ROOT headers
// for which there is a ROOT_XSP/...xsp file
#include "rootclasses.h"

#include "CPerlTypeConversion.h"
#include "PerlCTypeConversion.h"
#include "ClassGenerator.h"
#include "TObjectEncapsulation.h"
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

#include "const-c.inc"

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

INCLUDE: const-xs.inc

INCLUDE: XS/SOOTBOOT.xs

INCLUDE: XS/SOOTAPI.xs

INCLUDE: XS/TObject.xs

INCLUDE: rootclasses.xsinclude

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
    RETVAL = SOOT::CallMethod(aTHX_ className, methodName, arguments);
  OUTPUT: RETVAL

