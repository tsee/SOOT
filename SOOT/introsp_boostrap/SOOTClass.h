#ifndef sb_SOOTClass_h_
#define sb_SOOTClass_h_

#include <map>
#include <vector>
#include <string>

#include <SOOTMethod.h>

namespace SOOTbootstrap {
  class SOOTClass {
  public:
    SOOTClass() {}
    inline const std::string& PerlName() const { return fName; };

    std::string fName;
    // list<SOOTClass*> fSuperClasses;
    // list<SOOTClass*> fInheritingClasses;
    std::map<std::string, std::vector<SOOTMethod> > fMethods;
    // TClass* fROOTClass ?
  };
} // end namespace SOOTbootstrap

#endif
