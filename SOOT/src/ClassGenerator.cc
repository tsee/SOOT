
#include "ClassGenerator.h"
#include "soot_classnames.h"

using namespace SOOT;

ClassGenerator::ClassGenerator()
  : fOwnsClassNames(false), fClassNames(gClassNames),
    fNClassNames(gNClassNames)
{
}
