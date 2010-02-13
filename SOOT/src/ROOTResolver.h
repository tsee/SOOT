
#ifndef __ROOTResolver_h_
#define __ROOTResolver_h_

#include <TROOT.h>
#include <TClass.h>
#include <TMethod.h>

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
    eA_INTEGER,
    eA_FLOAT,
    eA_STRING,
    eA_INVALID,
    eHASH,
    eCODE,
    eREF,
    eTOBJECT,
    eINVALID,
  };
  extern const char* gBasicTypeStrings[13];
  /** "Second level" nested types.
   */

  /// Determine and return the BasicType of the given parameter
  BasicType GuessType(pTHX_ SV* const sv);
  /// GuessCompositeType assumes it's known to be an RV-to-AV (this is called by GuessType)
  BasicType GuessCompositeType(pTHX_ SV* const sv);

  /// Converts the given SV or basic type to the corresponding C (proto)type
  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len, BasicType type);
  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len);
  char* CProtoFromAV(pTHX_ AV* av, const unsigned int nSkip);
  
  class ROOTResolver {
    public:
      ROOTResolver() {};
      ~ROOTResolver() {};
      
      SV* CallMethod(pTHX_ const char* className, char* methName, AV* args) const;

      /** Creates a new Perl object which is a reference to a scalar blessed into
       *  the class. The scalar itself holds a pointer to the ROOT object.
       */
      SV* EncapsulateObject(pTHX_ TObject* theROOTObject, const char* className) const;

      /** Given a Perl object (SV*) that's known to be one of our mock TObject like
       *  creatures, fetch the class name and the ROOT object.
       */
      TObject* LobotomizeObject(pTHX_ SV* thePerlObject, char*& className) const;
  };
} // end namespace SOOT

#endif

