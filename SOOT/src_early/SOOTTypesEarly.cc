
#include "SOOTTypesEarly.h"
#include <SOOTDebug.h>

#include <string>
#include <iostream>
#include <sstream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

namespace SOOT {
  const char* gBasicTypeStrings[13] = {
    "UNDEF",
    "INTEGER",
    "FLOAT",
    "STRING",
    "INTEGER_ARRAY",
    "FLOAT_ARRAY",
    "STRING_ARRAY",
    "INVALID_ARRAY",
    "HASH",
    "CODE",
    "REF",
    "TOBJECT",
    "INVALID",
  };


  char*
  JoinCProto(const std::vector<std::string>& cproto, const unsigned int nSkip)
  {
    const unsigned int n = cproto.size();
    if (nSkip >= n)
      return NULL;
    ostringstream str;
    for (unsigned int i = nSkip; i < n; i++) {
      str << cproto[i];
      if (i != n-1)
         str << ",";
    }
    return strdup(str.str().c_str());
  }

  /* Heavily inspired by RubyROOT! */
  BasicType
  GuessTypeFromProto(const char* proto)
  {
    char* typestr = strdup(proto);
    char* ptr = typestr;
    int ptr_level = 0;
    BasicType type;

    while (*(ptr++)) {
      if (*ptr == '*')
        ptr_level++;
    }

    ptr--;

    // FIXME I think this can break on stuff like
    //       char* const* where the *'s aren't all at the end
    if (ptr_level > 0)
        *(ptr - ptr_level) = '\0';

    if (!strncmp(ptr-3, "int", 3) ||
        !strncmp(ptr-4, "long", 4) ||
        !strncmp(ptr-5, "short", 5)) {
      if (ptr_level)
        type = eARRAY_INTEGER;
      else
        type = eINTEGER;
    }
    else if (!strncmp(ptr-6, "double", 6) ||
             !strncmp(ptr-5, "float", 5)) {
      if (ptr_level)
        type = eARRAY_FLOAT;
      else
        type = eFLOAT;
    }
    else if (!strncmp(ptr-5, "char", 4)) {
      if (ptr_level == 1)
        type = eSTRING;
      else if (ptr_level == 2)
        type = eARRAY_STRING;
      else
        type = eINTEGER;
    }
    else if (!strncmp(ptr-4, "void", 4))
      type = eUNDEF; // FIXME check validity
    else if (!strncmp(ptr-4, "bool", 4))
      type = eINTEGER; // FIXME Do we need a eBOOL type?
    else
      type = eTOBJECT;
    /*else if (ptr_level)
      type = eTOBJECT; // FIXME, umm, really?
    else if (!strncmp(ptr-13, "TFitResultPtr", 13))
      type = eTOBJECT;
    else
      type = eINVALID;
    */

    free(typestr);

    return type;
  }

} // end namespace SOOT

