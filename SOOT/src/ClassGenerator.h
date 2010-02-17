
#ifndef __ClassGenerator_h_
#define __ClassGenerator_h_

#include <TBaseClass.h>
#include <TClass.h>
#include <TList.h>
#include <TROOT.h>
#include <TSystem.h>
#include <TRandom.h>
#include <TApplication.h>
#include <TBenchmark.h>

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#ifdef __cplusplus
}
#endif

namespace SOOT {
  /// Set up the FULL inheritance chain for the given class
  void SetupClassInheritance(pTHX_ const char* className, TClass* theClass);

  /// Create stub for a given class. Calls SetupClassInheritance to set up the inheritance chain
  void MakeClassStub(pTHX_ const char* className);

  /// Iterates over all known classes (cf. buildtools/ in SOOT) and calls MakeClassStub
  void GenerateClassStubs(pTHX);

  void InitializeGlobals(pTHX);
  void SetPerlGlobal(pTHX_ const char* variable, TObject* cobj, const char* className = NULL);
} // end namespace SOOT

#endif

