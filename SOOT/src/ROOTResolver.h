
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
  /** The various types of variables that matter to the ROOT
   * prototype guessing.
   */
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
  extern const char* gBasicTypeStrings[10];
  /** "Second level" nested types.
   */
  enum CompositeType {
    eA_INTEGER = 0,
    eA_FLOAT,
    eA_STRING,
    eA_INVALID,
  };
  extern const char* gCompositeTypeStrings[4];

  /// Determine and return the BasicType of the given parameter
  BasicType GuessType(pTHX_ SV* const sv);
  /// GuessCompositeType assumes it's known to be an eARRAY (BasicType)!
  CompositeType GuessCompositeType(pTHX_ SV* const sv);

  /// Converts the given SV or basic type to the corresponding C (proto)type
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

