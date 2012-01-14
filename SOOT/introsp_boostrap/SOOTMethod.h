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
    SOOTMethod()
      : fName(""), fClass(NULL), fIsStatic(false),
        fNArgsTotal(0), fNArgsOpt(0), fIsConstructor(false),
        fIsDestructor(false)
    {}
    SOOTMethod(const std::string& name, const unsigned int nArgsTotal, const unsigned int nArgsOpt,
               const std::string& retType,
               const bool isStatic = false)
      : fName(name), fClass(NULL), 
        fNArgsTotal(nArgsTotal), fNArgsOpt(nArgsOpt),
        fReturnType(retType),
        fIsStatic(isStatic), fIsConstructor(false),
        fIsDestructor(false)
    {}

    inline unsigned int GetNRequiredArgs() const {return fNArgsTotal - fNArgsOpt;}
    /// Comparison function to sort a set of methods of the same name
    /// in order of resolution preference (ascending order == descending preference)
    static bool cmp(const SOOTMethod& l, const SOOTMethod& r);

    std::string fName;
    SOOTClass* fClass; // backref, so ptr
    bool fIsStatic;
    bool fIsConstructor;
    bool fIsDestructor;

    unsigned int fNArgsTotal;
    unsigned int fNArgsOpt;
    std::string fReturnType;
    std::vector<SOOTMethodArg> fMethodArgs;
    // parameters
    // TMethod* fROOTMethod ?

    std::string GenerateUnambiguousXSUB();
    std::string FullyQualifiedPerlName() const;
    std::string PerlName() const;
    std::string GetInputTypemapStringFor(SOOTCppType& type, const std::string& cvarname,
                                         const std::string& inputvarstr, const std::string& indent) const;
    std::string GetInputTypemapStringFor(SOOTCppType& type, const std::string& cvarname,
                                         const unsigned int stackargno, const std::string& indent) const;
    std::string GetOutputTypemapStringFor(const std::string& rettype, const std::string& cvarname,
                                          const std::string& outputvarstr, const std::string& indent,
                                          bool returnsReference) const;
  };
} // end namespace SOOTbootstrap

#endif
