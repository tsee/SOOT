
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
    // FIXME assert that proto doesn't have spaces!
/*
==17614== Invalid read of size 1
==17614==    at 0x415F09: SOOT::GuessTypeFromProto(char const*) (SOOTTypesEarly.cc:93)
==17614==    by 0x41152A: SOOTbootstrap::SOOTMethod::GetOutputTypemapStringFor(std::string const&, std::string const&, std::string const&, std::string const&, bool) const (SOOTMethod.cc:146)
==17614==    by 0x41420C: SOOTbootstrap::SOOTMethod::GenerateUnambiguousXSUB() (SOOTMethod.cc:339)
==17614==    by 0x40622F: main (dump_classes.cc:298)
==17614==  Address 0x2bf3725f is 1 bytes before a block of size 4 alloc'd
==17614==    at 0x4C28F9F: malloc (vg_replace_malloc.c:236)
==17614==    by 0x5F96441: strdup (strdup.c:43)
==17614==    by 0x415DD5: SOOT::GuessTypeFromProto(char const*) (SOOTTypesEarly.cc:51)
==17614==    by 0x41152A: SOOTbootstrap::SOOTMethod::GetOutputTypemapStringFor(std::string const&, std::string const&, std::string const&, std::string const&, bool) const (SOOTMethod.cc:146)
==17614==    by 0x41420C: SOOTbootstrap::SOOTMethod::GenerateUnambiguousXSUB() (SOOTMethod.cc:339)
==17614==    by 0x40622F: main (dump_classes.cc:298)
*/
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
      cerr << "'" << proto << "' '" << ptr << "' " << (void*)ptr << " " << (void*)typestr << " " << strlen(typestr) << " " << strlen(ptr) << endl;

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
    else if (!strncmp(ptr-4, "void", 4)) // FIXME THIS IS THE INVALID READ LINE!
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

  // This variant is a lot slower, but it's safer in that it handles
  // whitespace and doesn't do invalid reads.
  BasicType
  GuessTypeFromProtoForCodeGen(const std::string& proto)
  {
    string typestr = proto;
    size_t pos;
    while (-1 != (pos = typestr.find("const")))
      typestr.erase(pos, 5);

    while (-1 != (pos = typestr.find(' ')))
      typestr.erase(pos, 1);

    int ptr_level = 0;
    while (-1 != (pos = typestr.find('&'))) {
      typestr.erase(pos, 1);
      ++ptr_level;
    }

    BasicType type;

    const size_t len = typestr.length();
    if (   (len >= 3 && typestr.substr(len-3) == "int")
        || (len >= 4 && typestr.substr(len-4) == "long")
        || (len >= 5 && typestr.substr(len-5) == "short"))
    {
      if (ptr_level)
        type = eARRAY_INTEGER;
      else
        type = eINTEGER;
    }
    else if (   (len >= 6 && typestr.substr(len-6) == "double")
             || (len >= 5 && typestr.substr(len-5) == "float"))
    {
      if (ptr_level)
        type = eARRAY_FLOAT;
      else
        type = eFLOAT;
    }
    else if (len >= 4) {
      if (typestr.substr(len-4) == "char")
      {
        if (ptr_level == 1)
          type = eSTRING;
        else if (ptr_level == 2)
          type = eARRAY_STRING;
        else
          type = eINTEGER;
      }
      else if (typestr.substr(len-4) == "void") // FIXME THIS IS THE INVALID READ LINE!
        type = eUNDEF; // FIXME check validity
      else if (typestr.substr(len-4) == "bool")
        type = eINTEGER; // FIXME Do we need a eBOOL type?
      else
        type = eTOBJECT;
    }
    else
      type = eTOBJECT;
    /*else if (ptr_level)
      type = eTOBJECT; // FIXME, umm, really?
    else if (!strncmp(ptr-13, "TFitResultPtr", 13))
      type = eTOBJECT;
    else
      type = eINVALID;
    */

    return type;
  }

} // end namespace SOOT

