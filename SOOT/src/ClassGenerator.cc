
#include "ClassGenerator.h"

#include "SOOTClassnames.h"
#include <string>
#include <iostream>
#include <sstream>


using namespace SOOT;
using namespace std;

void
ClassGenerator::Generate(pTHX)
  const
{
  for (unsigned int iClass = 0; iClass < gNClassNames; ++iClass) {
    const char* className = gClassNames[iClass];
    MakeClass(aTHX_ className);
  }
}

void
ClassGenerator::MakeClass(pTHX_ const char* className) {
  ostringstream str;
  str << className << "::ISA";
  AV* isa = get_av(str.str().c_str(), 1);
  av_clear(isa);
  av_push(isa, newSVpvs("SOOT::Base"));
}

