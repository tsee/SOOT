
#include "ROOTResolver.h"

#include "SOOTClassnames.h"
#include <string>
#include <iostream>
#include <sstream>

using namespace SOOT;
using namespace std;

namespace SOOT {
  const char* gBasicTypeStrings[9] = {
    "UNDEF",
    "INTEGER",
    "FLOAT",
    "STRING",
    "REF",
    "ARRAY",
    "HASH",
    "CODE",
    "INVALID",
  };
  const STRLEN gBasicTypeStringsLen[9] = {
    5,7,5,6,3,5,4,4,7
  };

  /* Lifted from autobox. My eternal gratitude goes to the
   * ever impressive Chocolateboy!
   */
  SOOT::BasicType
  GuessType(pTHX_ SV* const sv) {
    switch (SvTYPE(sv)) {
      case SVt_NULL:
        return eUNDEF;
      case SVt_IV:
        return eINTEGER;
      case SVt_PVIV:
        if (SvIOK(sv))
          return eINTEGER;
        else
          return eSTRING;
      case SVt_NV:
        if (SvIOK(sv))
          return eINTEGER;
        else
          return eFLOAT;
      case SVt_PVNV:
        if (SvNOK(sv))
          return eFLOAT;
        else if (SvIOK(sv))
          return eINTEGER;
        else
          return eSTRING;
#ifdef SVt_RV /* no longer defined by default if PERL_CORE is defined */
      case SVt_RV:
#endif
      case SVt_PV:
      case SVt_PVMG:
#ifdef SvVOK
        if (SvVOK(sv))
          return eINVALID; // VSTRING
#endif
        if (SvROK(sv)) {
          return eREF;
        } else {
          return eSTRING;
        }
      case SVt_PVLV:
        if (SvROK(sv))
          return eREF;
        else if (LvTYPE(sv) == 't' || LvTYPE(sv) == 'T') { /* tied lvalue */
          if (SvIOK(sv))
            return eINTEGER;
          else if (SvNOK(sv))
            return eFLOAT;
          else
            return eSTRING;
        } else {
          cout << "lval"<<endl;
          return eINVALID; // LVALUE
        }
      case SVt_PVAV:
      case SVt_PVHV:
      case SVt_PVCV:
        //return eARRAY;
        //return eHASH;
        //return eCODE;
        return eINVALID;
      case SVt_PVGV: // GLOB
      case SVt_PVFM: // FORMAT
      case SVt_PVIO: // IO
#ifdef SVt_BIND
      case SVt_BIND:
        return eINVALID; // BIND
#endif
#ifdef SVt_REGEXP
      case SVt_REGEXP:
        return eINVALID; // REGEXP
#endif
      default:
        if (SvROK(sv)) {
          switch (SvTYPE(SvRV(sv))) {
            case SVt_PVAV:
              return eARRAY;
            case SVt_PVHV:
              return eHASH;
            case SVt_PVCV:
              return eCODE;
            default:
              return eREF;
          }
        } else {
          return eINVALID; // UNKNOWN
        }
    }
  }

} // end namespace SOOT

void
ROOTResolver::FindMethod(pTHX_ const char* className, const char* methName, AV* args)
  const
{
  TClass *c = TClass::GetClass(className);
  if (c) {
    cout << className << " available as TClass" << endl;
    cout << "TClass has name " << c->GetName() << endl;
  }
  else {
    cout << className << " not available as TClass" << endl;
  }
  /*
   * Strategy:
   * - Is it a class or object method call?
   *   => type of first argument is REF and 
   */
}

