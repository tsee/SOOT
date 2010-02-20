
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
    for (unsigned int iClass = 0; iClass < gNClassNames; ++iClass) {
      const char* className = gClassNames[iClass];
      MakeClassStub(aTHX_ className);
    }
  }

  void
  MakeClassStub(pTHX_ const char* className) {
    if (strEQ(className, "TObject"))
      return;
    TClass* c = TClass::GetClass(className);
    if (c == NULL) {
      // TODO handle classes that haven't been loaded yet (as shared library)
      // => Add special AUTOLOAD that will trigger a new invocation of SetupClassInheritance
      return;
    }
    SetupClassInheritance(aTHX_ className, c);
    //SetupAUTOLOAD(aTHX_ className);
  }


  void
  SetupClassInheritance(pTHX_ const char* className, TClass* theClass)
  {
    // FIXME the base classes can be template classes. That screws up Perl pretty bad.
    // FIXME for now, we just skip the base classes that are template classes.
    ostringstream str;
    str << className << "::ISA";
    AV* isa = get_av(str.str().c_str(), 1);
    av_clear(isa);
    TIter next(theClass->GetListOfBases());
    TBaseClass* base;
    while ((base = (TBaseClass*)next())) {
      TString name(base->GetName());
      if (!name.Contains("<")) { // skip template classes. FIXME optimize
        av_push(isa, newSVpv(base->GetName(), 0));
      }
    }
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
  InitializeGlobals(pTHX)
  {
    if (!gApplication)
      gApplication = new TApplication("SOOT App", NULL, NULL);
    SetPerlGlobal(aTHX_ "SOOT::gApplication", gApplication);
    SetPerlGlobal(aTHX_ "SOOT::gSystem", gSystem);
    SetPerlGlobal(aTHX_ "SOOT::gRandom", gRandom);
    SetPerlGlobal(aTHX_ "SOOT::gROOT", gROOT);
    //SetPerlGlobal(aTHX_ "SOOT::gBenchmark", gBenchmark); // FIXME gBenchmark crashes
    SetPerlGlobal(aTHX_ "SOOT::gStyle", gStyle);
    SetPerlGlobal(aTHX_ "SOOT::gDirectory", gDirectory);
    SetPerlGlobalDelayedInit(aTHX_ "SOOT::gPad", (TObject**)&gPad, "TVirtualPad"); // gPad NULL at this time!
  }


  void
  SetPerlGlobal(pTHX_ const char* variable, TObject* cobj, const char* className)
  {
    SV* global = get_sv(variable, 1);
    sv_setsv(global,
             sv_2mortal(SOOT::EncapsulateObject(aTHX_ cobj,
                                                (className==NULL ? cobj->ClassName() : className))));
    global = get_sv(variable, 1); // FIXME this silences the "used only once" warning, but it is a awful solution
    SOOT::PreventDestruction(aTHX_ global);
  }

  void
  SetPerlGlobalDelayedInit(pTHX_ const char* variable, TObject** cobj, const char* className)
  {
    SV* global = get_sv(variable, 1);
    SV* obj = sv_2mortal(SOOT::MakeDelayedInitObject(aTHX_ cobj, className));
    sv_setsv(global, obj);
    global = get_sv(variable, 1); // FIXME this silences the "used only once" warning, but it is a awful solution
    SOOT::PreventDestruction(aTHX_ global);
  }
} // end namespace SOOT

