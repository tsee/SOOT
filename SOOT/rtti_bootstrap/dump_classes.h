#ifndef dump_classes_h_
#define dump_classes_h_

#include <map>
#include <vector>
#include <string>

#include <TROOT.h>

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
    std::string fTypeName;
    bool fIsClass;
    bool fIsStruct;
    bool fIsPointer; // foo *
    bool fIsConstant; // const foo
    bool fIsConstPointer; // foo const *
    bool fIsReference; // foo&

    SOOTCppType() {};
    SOOTCppType(const std::string& typeName, const Long_t props);
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
