#ifndef sb_SOOTClass_h_
#define sb_SOOTClass_h_

#include <map>
#include <set>
#include <vector>
#include <string>

#include <SOOTMethod.h>
#include <SOOTCppType.h>

namespace SOOTbootstrap {
  extern std::set<std::string> gEnumRegistry;

  class SOOTClass {
  public:
    SOOTClass() {}
    inline const std::string& PerlName() const { return fName; };

    std::string fName;
    // list<SOOTClass*> fSuperClasses;
    // list<SOOTClass*> fInheritingClasses;
    std::map<std::string, std::vector<SOOTMethod> > fMethods;
    // TClass* fROOTClass ?

    SOOTCppType MakeType(const bool isPtr = true, const bool isConst = true) const;
  };
} // end namespace SOOTbootstrap

#endif
