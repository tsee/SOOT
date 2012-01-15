
#ifndef __SOOTTypesEarly_h_
#define __SOOTTypesEarly_h_

#include <vector>
#include <string>

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

  // more in src/SOOTTypes.h

  /// Determine and return the BasicType of the given c-type
  BasicType GuessTypeFromProto(const char* proto);

  BasicType GuessTypeFromProtoForCodeGen(const std::string& proto);

  /// Given a vector of strings, concatenates them to a single C string. Skips the first one by default.
  char* JoinCProto(const std::vector<std::string>& cproto, const unsigned int nSkip = 1);
} // end namespace SOOT

#endif

