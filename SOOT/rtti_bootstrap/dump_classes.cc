#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <map>
#include <cmath>
#include <algorithm>

#include <TROOT.h>
#include <TSystem.h>
#include <TClass.h>
#include <TClassTable.h>
#include <TMethod.h>
#include <TMethodArg.h>
#include <TPRegexp.h>
#include <TList.h>


const unsigned int SOOTbootstrapDebug =
#ifdef DEBUG3
3;
#elif defined DEBUG2
2;
#elif defined DEBUG
1;
#else
0;
#endif

using namespace std;

namespace SOOTbootstrap {
  // FIXME "Warning in <TClass::TClass>: no dictionary for class iterator<bidirectional_iterator_tag,TObject*,long,const TObject**,const TObject*&> is available"
  static TPRegexp gBadClassRegexp("T(?:Btree|List|Map|ObjArray|OrdCollection|RefArray)Iter");

  class ClassIterator {
  public:
    ClassIterator()
      : fClassNo(0)
    {}

    /// Return next class name or NULL when none left
    const char*
    next()
    {
      if ((int)fClassNo < gClassTable->Classes()) {
        const char* name = gClassTable->At(fClassNo++);
        TString cn(name);
        if (cn.Contains("<") || cn.Contains("::") || gBadClassRegexp.MatchB(cn)) {// FIXME optimize
          if (SOOTbootstrapDebug >= 2)
            cout << "Class deemed invalid, skipping: '" << cn << "'\n";
          return next();
        }
        return name;
      }
      return NULL;
    }
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
    string fTypeName;
    bool fIsClass;
    bool fIsStruct;
    bool fIsPointer; // foo *
    bool fIsConstant; // const foo
    bool fIsConstPointer; // foo const *
    bool fIsReference; // foo&

    SOOTCppType() {};
    SOOTCppType(const string& typeName, const Long_t props)
      : fTypeName(typeName)
    {
      fIsClass = props & kIsClass;
      fIsStruct = props & kIsStruct;
      fIsPointer = props & kIsPointer;
      fIsConstant = props & kIsConstant;
      fIsConstPointer = props & kIsConstPointer;
      fIsReference = props & kIsReference;
      // default is not part of the type
      //fHasDefault = props & kIsDefault;
    }
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTMethodArg {
  public:
    SOOTMethodArg() {}

    string fDefaultValue;
    SOOTCppType fType;
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Sadly, we'll have handle static methods from the get-go: they can collide in name!
  // TODO how do functions tie in?
  class SOOTMethod {
  public:
    SOOTMethod() {}

    string fName;
    SOOTClass* fClass; // backref, so ptr
    bool fIsStatic;
    unsigned int fNArgsTotal;
    unsigned int fNArgsOpt;
    string fReturnType;
    vector<SOOTMethodArg> fMethodArgs;
    // parameters
    // TMethod* fROOTMethod ?
  };

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTClass {
  public:
    SOOTClass() {}

    string fName;
    // list<SOOTClass*> fSuperClasses;
    // list<SOOTClass*> fInheritingClasses;
    map<string, SOOTMethod> fMethods;
    // TClass* fROOTClass ?
  };
  

} // end namespace SOOTbootstrap
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -



using namespace SOOTbootstrap;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SOOTMethodArg
ExtractMethodArg(TMethodArg* ma)
{
  SOOTMethodArg sma;
  sma.fDefaultValue = string( ma->GetDefault() == NULL ? "" : ma->GetDefault() );
  sma.fType = SOOTCppType(ma->GetTypeName(), ma->Property());

  if (SOOTbootstrapDebug >= 3) {
    cout << "param: default=" << sma.fDefaultValue << " type=" << ma->GetTypeName() << " fulltype=" << ma->GetFullTypeName() << " props=" << ma->Property() << "\n";
    ma->Print();
    ma->Dump();
    cout << "        kIsClass=" << (ma->Property() & kIsClass ? 1 : 0) << "\n"
         << "        kIsStruct=" << (ma->Property() & kIsStruct ? 1 : 0) << "\n"
         << "        kIsUnion=" << (ma->Property() & kIsUnion ? 1 : 0) << "\n"
         << "        kIsEnum=" << (ma->Property() & kIsEnum ? 1 : 0) << "\n"
         << "        kIsNamespace=" << (ma->Property() & kIsNamespace ? 1 : 0) << "\n"
         << "        kIsTypedef=" << (ma->Property() & kIsTypedef ? 1 : 0) << "\n"
         << "        kIsFundamental=" << (ma->Property() & kIsFundamental ? 1 : 0) << "\n"
         << "        kIsAbstract=" << (ma->Property() & kIsAbstract ? 1 : 0) << "\n"
         << "        kIsVirtual=" << (ma->Property() & kIsVirtual ? 1 : 0) << "\n"
         << "        kIsPureVirtual=" << (ma->Property() & kIsPureVirtual ? 1 : 0) << "\n"
         << "        kIsPublic=" << (ma->Property() & kIsPublic ? 1 : 0) << "\n"
         << "        kIsProtected=" << (ma->Property() & kIsProtected ? 1 : 0) << "\n"
         << "        kIsPrivate=" << (ma->Property() & kIsPrivate ? 1 : 0) << "\n"
         << "        kIsPointer=" << (ma->Property() & kIsPointer ? 1 : 0) << "\n"
         << "        kIsArray=" << (ma->Property() & kIsArray ? 1 : 0) << "\n"
         << "        kIsStatic=" << (ma->Property() & kIsStatic ? 1 : 0) << "\n"
         << "        kIsDefault=" << (ma->Property() & kIsDefault ? 1 : 0) << "\n"
         << "        kIsReference=" << (ma->Property() & kIsReference ? 1 : 0) << "\n"
         << "        kIsConstant=" << (ma->Property() & kIsConstant ? 1 : 0) << "\n"
         << "        kIsConstPointer=" << (ma->Property() & kIsConstPointer ? 1 : 0) << "\n"
         << "        kIsMethConst=" << (ma->Property() & kIsMethConst ? 1 : 0) << "\n";
  } // end debug

  return sma;
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SOOTMethod
ExtractMethod(TMethod* m)
{
  if (SOOTbootstrapDebug >= 3) {
    cout << "Scanning method '" << m->GetName()
         << "' nargs=" << m->GetNargs() << " nargsopt=" << m->GetNargsOpt() << "\n";
  }

  SOOTMethod sm;
  sm.fName = m->GetName();
  sm.fNArgsTotal = m->GetNargs();
  sm.fNArgsOpt = m->GetNargsOpt();
  sm.fReturnType = string(m->GetReturnTypeName());

  TIter nextMethodArg(m->GetListOfMethodArgs());
  TMethodArg *ma;
  while ((ma = (TMethodArg*) nextMethodArg())) {
    sm.fMethodArgs.push_back( ExtractMethodArg(ma) );
  } // end iterating over method args

  return sm;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SOOTClass
ExtractClass(TClass* theClass)
{
  if (SOOTbootstrapDebug >= 2)
    cout << "Scanning class '" << theClass->GetName() << "'" << endl;

  TList *allMethods = theClass->GetListOfAllPublicMethods();
  //TList *allMethods = theClass->GetListOfMethods();

  SOOTClass cl;
  cl.fName = string(theClass->GetName());

  TIter nextMethod(allMethods);
  TMethod *m;
  while ((m = (TMethod*) nextMethod())) {
    if (!(m->Property() & kIsPublic))
      continue;

    SOOTMethod sm = ExtractMethod(m);
    cl.fMethods[sm.fName] = sm;
  } // end iterating over methods

  return cl;
}

typedef struct SOOTMethodDisambiguator {
  SOOTClass* fClass;
  string fMethodName;
  vector< vector<SOOTMethod*> > fMethodsByNArgsActual;
} SOOTMethodDisambiguator;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
int
main(int argc, char** argv)
{
  if (SOOTbootstrapDebug)
    cout << "Starting to load extra libraries..." << endl;
  if (SOOTbootstrapDebug >= 3)
    gSystem->ListLibraries();
  for (unsigned int ilib = 1; ilib < argc; ++ilib) {
    if (SOOTbootstrapDebug >= 2)
      cout << "Loading library " << argv[ilib] << endl;
    if (0 == gROOT->LoadClass("", argv[ilib], 0)) {
      //cout << "Failed to load this library!" << endl;
    }
  }
  if (SOOTbootstrapDebug >= 2)
    gSystem->ListLibraries();

  if (SOOTbootstrapDebug)
    cout << "Starting to scan classes and methods..." << endl;

  map<string, SOOTClass> classMap;

  // Iterate over all classes and do the class=>methods=>methargs conversion
  ClassIterator citer;
  while (1) {
    const char *className = citer.next();
    if (className == NULL)
      break;
    TClass *theClass = TClass::GetClass(className);
    
    classMap[string(className)] = ExtractClass(theClass);
  }



  if (SOOTbootstrapDebug)
    cout << "Starting to build lookup tables for classes and methods..." << endl;

  // Now iterate over all classes again to create a class/methodname lookup
  map< pair<string, string>, SOOTMethodDisambiguator > disambiguators;

  map<string, SOOTClass>::iterator clEnd = classMap.end(); 
  for (map<string, SOOTClass>::iterator clIt = classMap.begin(); clIt != clEnd; ++clIt) {
    const string& className = clIt->first;
    SOOTClass& sclass = clIt->second;
    
    map<string, SOOTMethod>::iterator meEnd = sclass.fMethods.end(); 
    for (map<string, SOOTMethod>::iterator meIt = sclass.fMethods.begin(); meIt != meEnd; ++meIt) {
      const string& methodName = meIt->first;
      SOOTMethod& smethod= meIt->second;

      SOOTMethodDisambiguator& disamb = disambiguators[pair<string, string>(className, methodName)];
      
      const unsigned int maxNArgs = smethod.fNArgsTotal;
      const unsigned int minNArgs = maxNArgs - smethod.fNArgsOpt;
      if (disamb.fMethodName == string("")) { // need init
        disamb.fMethodName = methodName;
        disamb.fClass = &sclass;
      }

      vector< vector<SOOTMethod*> >& methsByNArgsActual = disamb.fMethodsByNArgsActual;
      if (methsByNArgsActual.size() <= maxNArgs)
        methsByNArgsActual.resize(maxNArgs+1);

      for (unsigned int nargs = minNArgs; nargs <= maxNArgs; ++nargs) {
        methsByNArgsActual[nargs].push_back(&smethod);
      }
    } // end foreach method

  } // end foreach class

}


