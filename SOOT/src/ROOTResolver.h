
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
    eARRAY,
    eHASH,
    eCODE,
    eREF,
    eTOBJECT,
    eINVALID,
  };
  enum CompositeType {
    eA_INTEGER = 0,
    eA_FLOAT,
    eA_STRING,
    eA_INVALID,
  };
  extern const char* gBasicTypeStrings[10];
  extern const char* gCompositeTypeStrings[4];

  BasicType GuessType(pTHX_ SV* const sv);
  CompositeType GuessCompositeType(pTHX_ SV* const sv);

  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len, BasicType type);
  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len);
  
  class ROOTResolver {
    public:
      ROOTResolver() {};
      ~ROOTResolver() {};
      
      void FindMethod(pTHX_ const char* className, const char* methName, AV* args) const;
    
  };
} // end namespace SOOT

#endif

