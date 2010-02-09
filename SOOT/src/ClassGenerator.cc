
#include "ClassGenerator.h"
#include "SOOTClassnames.h"

using namespace SOOT;

ClassGenerator::ClassGenerator()
  : fOwnsClassNames(false),
    fNClassNames(SOOT::gNClassNames)
{
  fClassNames = (char**) SOOT::gClassNames;
}

