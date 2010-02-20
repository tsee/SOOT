
#include "ClassIterator.h"

#include "SOOTClassnames.h"

namespace SOOT {
  ClassIterator::ClassIterator()
    : fClassNo(0)
  {}


  const char*
  ClassIterator::next()
  {
    if (fClassNo < gNClassNames)
      return gClassNames[fClassNo++];
    return NULL;
  }

} // end namespace SOOT

