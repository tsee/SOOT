
#include "ClassGenerator.h"

#include "SOOTClassnames.h"
#include "TObjectEncapsulation.h"
#include <string>
#include <iostream>
#include <sstream>

using namespace std;

namespace SOOT {
  void
  GenerateClassStubs(pTHX)
  {
    // To be removed soon
    /*for (unsigned int iClass = 0; iClass < gNClassNames; ++iClass) {
      const char* className = gClassNames[iClass];
      MakeClassStub(aTHX_ className, NULL);
    }*/
    vector<const char*> classes;
    const int nClasses = gClassTable->Classes();
    TPRegexp bad("T(?:Btree|List|Map|ObjArray|OrdCollection|RefArray)Iter"); // FIXME "Warning in <TClass::TClass>: no dictionary for class iterator<bidirectional_iterator_tag,TObject*,long,const TObject**,const TObject*&> is available"
    for (unsigned int iClass = 0; iClass < nClasses; ++iClass) {
      const char* className = gClassTable->At(iClass);
      TString cn(className);
      if (cn.Contains("<") || cn.Contains("::") || bad.MatchB(cn))
        continue;
      classes.push_back(className);
    }
    for (unsigned int iClass = 0; iClass < classes.size(); ++iClass) {
      //cout << classes[iClass] << endl;
      vector<TString> c = MakeClassStub(aTHX_ classes[iClass], NULL);
      //for (unsigned int i = 0; i < c.size(); i++) {
      //  cout << "  => " << c[i] << endl;
      //}
    }
    // ENOTWORKING
    /*
    TIter clIter( gROOT->GetListOfClasses() );
    TClass* cl;
    while ((cl = (TClass*)clIter.Next())) {
      cout << cl->GetName() << endl;
      MakeClassStub(aTHX_ cl->GetName(), cl);
    }*/

  }

  std::vector<TString>
  MakeClassStub(pTHX_ const char* className, TClass* theClass) {
    vector<TString> retval;
    if (strEQ(className, "TObject"))
      return retval;
    if (theClass == NULL)
      theClass = TClass::GetClass(className);
    if (theClass == NULL) {
      // TODO handle classes that haven't been loaded yet (as shared library)
      // => Add special AUTOLOAD that will trigger a new invocation of SetupClassInheritance
      return retval;
    }
  
    // Check whether this class has been ROOTified before
    string isROOTName = string(className) + string("::isROOT");
    SV* isROOT = get_sv(isROOTName.c_str(), 0);
    if (isROOT != NULL) // done before
      return retval;

    // Note that this class is now ROOTified
    get_sv(isROOTName.c_str(), 1);
    get_sv(isROOTName.c_str(), 1); // FIXME there has to be a better way to silence 'used only once' warning
    retval.push_back(className);

    SetupTObjectMethods(aTHX_ className);

    vector<TString> baseClasses = SetupClassInheritance(aTHX_ className, theClass);
    retval.reserve(retval.size()+baseClasses.size());
    retval.insert(retval.end(), baseClasses.begin(), baseClasses.end());

    //SetupAUTOLOAD(aTHX_ className);
  }

// Note: Keep that header in sync.
#include "ExternalXSUBs.h"

  void
  SetupTObjectMethods(pTHX_ const char* className)
  {
#if (PERL_REVISION == 5 && PERL_VERSION < 9)
    char* file = __FILE__;
#else
    const char* file = __FILE__;
#endif
    // Note: *AUTOLOAD done in pure Perl
    string clN(className);
    newXS((clN+string("::DESTROY")).c_str(), XS_TObject_DESTROY, file);
    newXS((clN+string("::keep")).c_str(), XS_TObject_keep, file);
    newXS((clN+string("::as")).c_str(), XS_TObject_as, file);
    newXS((clN+string("::delete")).c_str(), XS_TObject_delete, file);
  }

  std::vector<TString>
  SetupClassInheritance(pTHX_ const char* className, TClass* theClass)
  {
    vector<TString> retval;
    // FIXME the base classes can be template classes. That screws up
    //       Perl pretty badly. For now, we just skip the base classes that are template classes.
    // FIXME We don't make the TH* classes descendants of the TArray classes for now because
    //       the TArray classes have overridden (XSP!) constructors. We want the autoloading
    //       to kick in for the TH* classes. This needs some consideration and a more general
    //       solution.
    if (theClass == NULL) {
      theClass = TClass::GetClass(className);
      if (theClass == NULL)
        return retval;
    }
    AV* isa = get_av((string(className)+string("::ISA")).c_str(), 1);
    av_clear(isa);
    TIter next(theClass->GetListOfBases());
    TBaseClass* base;
    bool isTH1 = theClass->InheritsFrom("TH1");
    while ((base = (TBaseClass*)next())) {
      TString name(base->GetName());
      if (!name.Contains("<")
          && (!isTH1 || !name.BeginsWith("TArray")))
      { // skip template classes. FIXME optimize
        vector<TString> sub = MakeClassStub(aTHX_ name.Data(), NULL);
        retval.reserve(retval.size()+sub.size());
        retval.insert(retval.end(), sub.begin(), sub.end());
        av_push(isa, newSVpv(base->GetName(), 0));
      }
    }

    return retval;
  }


  void
  SetupAUTOLOAD(pTHX_ const char* className)
  {
    croak("FIXME SetupAUTOLOAD awaits non-buggy implementation");
/*    ostringstream str;
    str << className << "::AUTOLOAD";
    const string s = str.str();
    GV* gv = gv_fetchpvn_flags(s.c_str(), s.length(), GV_ADD, SVt_PVGV);
    if (gv == NULL)
      cout << "BAD GV" << endl;
    GV* srcgv = gv_fetchpvn_flags("TObject::AUTOLOAD", strlen("TObject::AUTOLOAD"), 0, SVt_PVCV);
    //CV* cv = get_cvn_flags("TObject::AUTOLOAD", strlen("TObject::AUTOLOAD"), 0);
    //if (cv == NULL)
    //  cout << "BAD CV" << endl;
    if (srcgv == NULL)
      cout << "BAD SRC GV" << endl;
    sv_setsv((SV*)gv, (SV*)newSVrv((SV*)cv, NULL));
    */
  }


  void
  InitializePerlGlobals(pTHX)
  {
    if (!gApplication)
      gApplication = new TApplication("SOOT App", NULL, NULL);
    SetPerlGlobal(aTHX_ "SOOT::gApplication", gApplication);
    SetPerlGlobal(aTHX_ "SOOT::gSystem", gSystem);
    SetPerlGlobal(aTHX_ "SOOT::gRandom", gRandom);
    SetPerlGlobal(aTHX_ "SOOT::gROOT", gROOT);
    SetPerlGlobal(aTHX_ "SOOT::gStyle", gStyle);
    SetPerlGlobal(aTHX_ "SOOT::gEnv", gEnv);
    SetPerlGlobal(aTHX_ "SOOT::gDirectory", gDirectory);
    SetPerlGlobalDelayedInit(aTHX_ "SOOT::gPad", (TObject**)&gPad, "TVirtualPad"); // gPad NULL at this time!
    // Initialized in SOOT.pm to band-aid a SEGV:
    //SetPerlGlobalDelayedInit(aTHX_ "SOOT::gBenchmark", (TObject**)&gBenchmark, "TBenchmark");
  }


  void
  SetPerlGlobal(pTHX_ const char* variable, TObject* cobj, const char* className)
  {
    SV* global = get_sv(variable, 1);
    SOOT::RegisterObject(aTHX_ cobj,
                         (className==NULL ? cobj->ClassName() : className),
                         global);
    global = get_sv(variable, 1); // FIXME this silences the "used only once" warning, but it is a awful solution
    SOOT::PreventDestruction(aTHX_ cobj);
  }

  void
  SetPerlGlobalDelayedInit(pTHX_ const char* variable, TObject** cobj, const char* className)
  {
    SV* global = get_sv(variable, 1);
    SV* obj = sv_2mortal(SOOT::MakeDelayedInitObject(aTHX_ cobj, className));
    sv_setsv(global, obj);
    global = get_sv(variable, 1); // FIXME this silences the "used only once" warning, but it is a awful solution
  }
} // end namespace SOOT

