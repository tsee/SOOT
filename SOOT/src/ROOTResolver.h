
#ifndef __ROOTResolver_h_
#define __ROOTResolver_h_

#include <TROOT.h>
#include <TClass.h>
#include <TCint.h>
#include <TMethod.h>

#include <CallFunc.h>
#include <Class.h>

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
  /** The various types of variables that matter to the ROOT
   * prototype guessing.
   */
  enum BasicType {
    eUNDEF = 0,
    eINTEGER,
    eFLOAT,
    eSTRING,
    eARRAY_INTEGER,
    eARRAY_FLOAT,
    eARRAY_STRING,
    eARRAY_INVALID,
    eHASH,
    eCODE,
    eREF,
    eTOBJECT,
    eINVALID,
  };
  extern const char* gBasicTypeStrings[13];

  /// Determine and return the BasicType of the given parameter
  BasicType GuessType(pTHX_ SV* const sv);
  /// Determine and return the BasicType of the given c-type
  BasicType GuessTypeFromProto(const char* proto);

  /// _GuessCompositeType assumes it's known to be an RV-to-AV (this is called by GuessType)
  BasicType _GuessCompositeType(pTHX_ SV* const sv);

  /// Determine and return the BasicType-s of all arguments
  std::vector<BasicType> GuessTypes(pTHX_ AV* av);

  /// Converts the given SV or basic type to the corresponding C (proto)type
  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len, BasicType type);
  const char* CProtoFromType(pTHX_ SV* const sv, STRLEN& len);
  char* CProtoFromAV(pTHX_ AV* av, const unsigned int nSkip);
  /** Calculate the C-type strings and the BasicTypes for all
   *  arguments in av and push them into the supplied containers
   */
  void CProtoAndTypesFromAV(pTHX_ AV* av, std::vector<BasicType>& avtypes,
                            std::vector<std::string>& cproto, const unsigned int nSkip);
  /// Given a vector of strings, concatenates them to a single C string. Skips the first one by default.
  char* JoinCProto(const std::vector<std::string>& cproto, const unsigned int nSkip);

  /// Map any int* types to float*'s
  bool CProtoIntegerToFloat(std::vector<std::string>& cproto);

  void SetMethodArguments(pTHX_ G__CallFunc& theFunc, AV* args,
                          const std::vector<BasicType>& argTypes, const unsigned int nSkip);

  SV* ProcessReturnValue(pTHX_ const BasicType& retType, long addr, double addrD, const char* retTypeStr);
      
  SV* CallMethod(pTHX_ const char* className, char* methName, AV* args);

} // end namespace SOOT

#endif

