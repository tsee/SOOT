#ifndef dump_classes_h_
#define dump_classes_h_

#include <map>
#include <set>
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
  class SOOTMethodArg;
  class SOOTCppType;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTCppType {
  public:
    SOOTCppType() {};
    SOOTCppType(const std::string& typeName, const Long_t props);

    inline bool IsPerlBasicType() {
      return(
           fTypeName == std::string("int")
        || fTypeName == std::string("char")
        || fTypeName == std::string("double")
        || fTypeName == std::string("float")
        || fTypeName == std::string("short")
        || fTypeName == std::string("long")
        || ( fTypeName.substr(0, 8) == std::string("unsigned")
             && (    fTypeName.length() == 8
                  || fTypeName.substr(8) == std::string(" int")
                  || fTypeName.substr(8) == std::string(" long")
                  || fTypeName.substr(8) == std::string(" short")
                  || fTypeName.substr(8) == std::string(" char") )
           )
        || fTypeName == std::string("long long")
      );
    }

    std::string fTypeName;
    bool fIsClass;
    bool fIsStruct;
    bool fIsPointer; // foo *
    bool fIsConstant; // const foo
    bool fIsConstPointer; // foo const *
    bool fIsReference; // foo&

    // the following are just derived members for caching
    std::set<SOOT::BasicType> fSOOTTypes;
    
  private:
    void IntuitSOOTBasicTypes();
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTMethodArg {
  public:
    SOOTMethodArg() {}

    std::string fDefaultValue;
    SOOTCppType fType;
  };

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
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTClass {
  public:
    SOOTClass() {}

    std::string fName;
    // list<SOOTClass*> fSuperClasses;
    // list<SOOTClass*> fInheritingClasses;
    std::map<std::string, SOOTMethod> fMethods;
    // TClass* fROOTClass ?
  };
  
  typedef struct SOOTMethodDisambiguator {
    SOOTClass* fClass;
    std::string fMethodName;
    std::vector< std::vector<SOOTMethod*> > fMethodsByNArgsActual;
  } SOOTMethodDisambiguator;


} // end namespace SOOTbootstrap

#endif
