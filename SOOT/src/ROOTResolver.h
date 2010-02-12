
#ifndef __ROOTResolver_h_
#define __ROOTResolver_h_

#include <TROOT.h>
#include <TClass.h>
#include <Reflex/Scope.h>

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

namespace SOOT {
  enum BasicType {
    eUNDEF = 0,
    eINTEGER,
    eFLOAT,
    eSTRING,
    eREF,
    eARRAY,
    eHASH,
    eCODE,
    eINVALID,
  };
  enum CompositeType {
    eA_INTEGER = 0,
    eA_FLOAT,
    eA_STRING,
    eA_INVALID,
  };
  extern const char* gBasicTypeStrings[9];
  extern const char* gCompositeTypeStrings[4];

  BasicType GuessType(pTHX_ SV* const sv);
  
  class ROOTResolver {
    public:
      ROOTResolver() {};
      ~ROOTResolver() {};
      
      void FindMethod(pTHX_ const char* className, const char* methName, AV* args) const;
    
  };
} // end namespace SOOT

#endif

