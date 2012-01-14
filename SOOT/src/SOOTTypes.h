
#ifndef __SOOTTypes_h_
#define __SOOTTypes_h_

#include <TROOT.h>
#include <TClass.h>
#include <TCint.h>
#include <TMethod.h>

#include <CallFunc.h>
#include <Class.h>
#include <TVirtualPad.h>

// This has more SOOTTypes related stuff that doesn't need perl
#include <SOOTTypesEarly.h>

#include <vector>
#include <string>

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

  /// Is the given SV a SOOT object?
  bool IsTObject(pTHX_ SV* sv);

  /// Determine and return the BasicType of the given parameter
  BasicType GuessType(pTHX_ SV* const sv);

  /// _GuessCompositeType assumes it's known to be an RV-to-AV (this is called by GuessType)
  BasicType _GuessCompositeType(pTHX_ SV* const sv);

  /// Determine and return the BasicType-s of all arguments
  std::vector<BasicType> GuessTypes(pTHX_ AV* av);

  /// Converts the given SV or basic type to the corresponding C (proto)type
  std::string CProtoFromType(pTHX_ SV* const sv, BasicType type);
  std::string CProtoFromType(pTHX_ SV* const sv);
  char* CProtoFromAV(pTHX_ AV* av, const unsigned int nSkip);
  /** Calculate the C-type strings and the BasicTypes for all
   *  arguments in av and push them into the supplied containers.
   *  Returns the number of TObjects in the array.
   */
  unsigned int CProtoAndTypesFromAV(pTHX_ AV* av, std::vector<BasicType>& avtypes,
                                    std::vector<std::string>& cproto, const unsigned int nSkip = 0);

  /// Map any int* types to float*'s
  bool CProtoIntegerToFloat(std::vector<std::string>& cproto);
} // end namespace SOOT

#include "SOOTTypes.inline.h"

#endif

