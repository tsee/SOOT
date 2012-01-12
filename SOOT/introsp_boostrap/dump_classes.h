#ifndef dump_classes_h_
#define dump_classes_h_

#include <vector>
#include <string>

#include <TROOT.h>
#include "../ROOTIncludes.h"
#include <SOOTTypes.h>

namespace SOOTbootstrap {
  class ClassIterator {
  public:
    ClassIterator();
    /// Return next class name or NULL when none left
    const char* next();
  private:
    unsigned int fClassNo;
  };

  class SOOTClass;
  class SOOTMethod;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTMethodDisambiguator {
  public:
    SOOTClass* fClass;
    std::string fMethodName;
    std::vector< std::vector<SOOTMethod*> > fMethodsByNArgsActual;

    SOOTMethodDisambiguator(SOOTClass * cl, const std::string& methname)
      : fClass(cl), fMethodName(methname)
    {}
    SOOTMethodDisambiguator() {}
    void Dump() const;
  };


} // end namespace SOOTbootstrap

#endif
