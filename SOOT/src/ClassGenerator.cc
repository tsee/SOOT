
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
  }
  
  void
  SetupClassInheritance(pTHX_ const char* className, TClass* theClass)
  {
    ostringstream str;
    str << className << "::ISA";
    AV* isa = get_av(str.str().c_str(), 1);
    av_clear(isa);
    TIter next(theClass->GetListOfBases());
    TBaseClass* base;
    while ((base = (TBaseClass*)next())) {
      av_push(isa, newSVpv(base->GetName(), 0));
    }
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
    //SetPerlGlobal(aTHX_ "SOOT::gPad", gPad); // gPad NULL at this time...
  }

  void
  SetPerlGlobal(pTHX_ const char* variable, TObject* cobj, const char* className)
  {
    SV* global = get_sv(variable, 1);
    sv_setsv(global,
             sv_2mortal(SOOT::EncapsulateObject(aTHX_ cobj,
                                                (className==NULL ? cobj->ClassName() : className))));
    SOOT::PreventDestruction(aTHX_ global);
  }
} // end namespace SOOT

