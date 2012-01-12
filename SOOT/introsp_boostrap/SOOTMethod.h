#ifndef sb_SOOTMethod_h_
#define sb_SOOTMethod_h_

#include <vector>
#include <string>

#include <TROOT.h>
#include <SOOTTypes.h>

#include <SOOTMethodArg.h>

namespace SOOTbootstrap {
  class SOOTClass;
  class SOOTMethodArg;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Sadly, we'll have handle static methods from the get-go: they can collide in name!
  // TODO how do functions tie in?
  class SOOTMethod {
  public:
    SOOTMethod() {}
    inline unsigned int GetNRequiredArgs() const {return fNArgsTotal - fNArgsOpt;}
    /// Comparison function to sort a set of methods of the same name
    /// in order of resolution preference (ascending order == descending preference)
    static bool cmp(const SOOTMethod& l, const SOOTMethod& r);

    std::string fName;
    SOOTClass* fClass; // backref, so ptr
    bool fIsStatic;
    unsigned int fNArgsTotal;
    unsigned int fNArgsOpt;
    std::string fReturnType;
    std::vector<SOOTMethodArg> fMethodArgs;
    // parameters
    // TMethod* fROOTMethod ?

    std::string GenerateUnambiguousXSUB() const;
  };
} // end namespace SOOTbootstrap

#endif
