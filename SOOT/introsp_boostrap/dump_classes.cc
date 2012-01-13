#include "dump_classes.h"

#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
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

#include <SOOTCppType.h>
#include <SOOTMethodArg.h>
#include <SOOTMethod.h>
#include <SOOTClass.h>

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
using namespace SOOTbootstrap;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ClassIterator::ClassIterator()
  : fClassNo(0)
{}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
namespace SOOTbootstrap {
  // FIXME "Warning in <TClass::TClass>: no dictionary for class iterator<bidirectional_iterator_tag,TObject*,long,const TObject**,const TObject*&> is available"
  static TPRegexp gBadClassRegexp("T(?:Btree|List|Map|ObjArray|OrdCollection|RefArray)Iter");
  static TPRegexp gCIntegerType("^(?:unsigned|(?:unsigned )?(?:short|int|char|long(?: long)?))$"); // char, too?
  static TPRegexp gStringType("^(?:char|U?(?:Byte|Char)_t)$"); // FIXME TString?
  static TPRegexp gROOTIntegerType("^(?:Bool_t|U?(?:Short|Int|Long64|Long|Char|Seek|Byte|Font|Style|Marker|Width|Color|SCoord|SSiz|Version|Option)_t)$");
  static TPRegexp gFloatType("^(?:double|float|(?:(?:Float|Double)(?:16|32|64)?|Real|Axis|Stat|Coord|Angle|Size)_t)$"); // FIXME Size_t a float, really? According to Rtypes.h, yes.

}

const char*
ClassIterator::next()
{
  if ((int)fClassNo < gClassTable->Classes()) {
    const char* name = gClassTable->At(fClassNo++);
    TString cn(name);
    if (cn.Contains("<") || cn.Contains("::") || SOOTbootstrap::gBadClassRegexp.MatchB(cn)) {// FIXME optimize
      if (SOOTbootstrapDebug >= 2)
        cout << "Class deemed invalid, skipping: '" << cn << "'\n";
      return next();
    }
    return name;
  }
  return NULL;
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void
SOOTMethodDisambiguator::Dump()
  const
{
  // FIXME inlined to avoid having to compile ../src
  const char* basicTypeStrings[13] = {
    "UNDEF",
    "INTEGER",
    "FLOAT",
    "STRING",
    "INTEGER_ARRAY",
    "FLOAT_ARRAY",
    "STRING_ARRAY",
    "INVALID_ARRAY",
    "HASH",
    "CODE",
    "REF",
    "TOBJECT",
    "INVALID",
  };

  cout << "  Class:  " << fClass->fName << " Method: " << fMethodName << endl;
  for (unsigned int i = 0; i < fMethodsByNArgsActual.size(); ++i) {
    const vector<SOOTMethod*>& methods = fMethodsByNArgsActual[i];
    if (methods.size() == 0)
      continue;
    cout << "  Candidates for " << i << " arguments:" << "\n";
    for (unsigned int j = 0; j < methods.size(); ++j) {
      SOOTMethod *meth = methods[j];
      cout << "  - NArgsTotal: " << meth->fNArgsTotal << " NArgsOpt: " << meth->fNArgsOpt << "\n"
           << "    RetType: " << meth->fReturnType << "\n";

      const vector<SOOTMethodArg>& args = meth->fMethodArgs;
      if (args.size() != 0) {
        cout << "    Args: ";
      }
      for (unsigned int k = 0; k < args.size(); ++k) {
        const SOOTMethodArg& ma = args[k];
        const SOOTCppType& type = ma.fType;
        cout << k << ") " << type.ToString();
        if (ma.fDefaultValue != string("")) {
          cout << "(="<<ma.fDefaultValue<<")";
        }
        const set<SOOT::BasicType>& btypes = type.fSOOTTypes;
        set<SOOT::BasicType>::iterator it;
        cout << " [";
        for (it = btypes.begin(); it != btypes.end(); it++) {
          cout << basicTypeStrings[*it];// FIXME
          cout << "|";
        }
        cout << "]\n";
        if (k != args.size()-1)
          cout << "    ";
      }
    }
  }
}

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
  sm.fIsStatic = m->Property() & kIsStatic;

  TIter nextMethodArg(m->GetListOfMethodArgs());
  TMethodArg *ma;
  while ((ma = (TMethodArg*) nextMethodArg())) {
    sm.fMethodArgs.push_back( ExtractMethodArg(ma) );
  } // end iterating over method args

  return sm;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SOOTClass*
ExtractClass(TClass* theClass)
{
  if (SOOTbootstrapDebug >= 2)
    cout << "Scanning class '" << theClass->GetName() << "'" << endl;

  TList *allMethods = theClass->GetListOfAllPublicMethods();
  //TList *allMethods = theClass->GetListOfMethods();

  SOOTClass *cl = new SOOTClass();
  cl->fName = string(theClass->GetName());

  TIter nextMethod(allMethods);
  TMethod *m;
  while ((m = (TMethod*) nextMethod())) {
    if (!(m->Property() & kIsPublic))
      continue;

    SOOTMethod sm = ExtractMethod(m);
    sm.fClass = cl;
    cl->fMethods[sm.fName].push_back(sm); // there can be many methods of the same name in C++, yay
  } // end iterating over methods

  return cl;
}

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

  map<string, SOOTClass *> classMap;

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

  map<string, SOOTClass *>::iterator clEnd = classMap.end();
  for (map<string, SOOTClass *>::iterator clIt = classMap.begin(); clIt != clEnd; ++clIt) {
    const string& className = clIt->first;
    SOOTClass& sclass = *(clIt->second);

    map<string, vector<SOOTMethod> >::iterator meEnd = sclass.fMethods.end();
    for (map<string, vector<SOOTMethod> >::iterator meIt = sclass.fMethods.begin(); meIt != meEnd; ++meIt) {
      const string& methodName = meIt->first;
      vector<SOOTMethod>& methodsWithThisName = meIt->second;

      SOOTMethodDisambiguator& disamb = disambiguators[pair<string, string>(className, methodName)];
      for (unsigned int imeth = 0; imeth < methodsWithThisName.size(); ++ imeth) {
        SOOTMethod& smethod = methodsWithThisName[imeth];
        if (methodsWithThisName.size() == 1)
          smethod.GenerateUnambiguousXSUB(); // FIXME testing

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
        //if (sclass.fName == string("TGraphErrors")) {
        //  disamb.Dump();
        //}
      } // end foreach method with the same name
    } // end foreach method name
  } // end foreach class

}


