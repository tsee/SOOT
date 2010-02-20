
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
#include <TPad.h>
#include <TStyle.h>
#include <TDirectory.h>
#include <TCanvas.h>
#include <TVirtualPad.h>

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
  void SetupAUTOLOAD(pTHX_ const char* className);

  /// Create stub for a given class. Calls SetupClassInheritance to set up the inheritance chain
  void MakeClassStub(pTHX_ const char* className);

  /// Iterates over all known classes (cf. buildtools/ in SOOT) and calls MakeClassStub
  void GenerateClassStubs(pTHX);

  /// Initializes a bunch of globals such as gROOT, etc
  void InitializeGlobals(pTHX);

  /** Fetches the given perl global variable and creates a new object holding
   *  the given TObject. The global is made magical with the PreventDestruction
   *  function from TObjectEncapsulation. className is the class into which the
   *  Perl global will be blessed. (Defaults to cobj->ClassName)
   */
  void SetPerlGlobal(pTHX_ const char* variable, TObject* cobj, const char* className = NULL);

  /** Some globals (gPad!) are still NULL at this time. Therefore, we create the Perl
   *  global as usual, but store a pointer to the pointer to the C-global adn make
   *  the object magical via MakeDelayedInitObject. This magic is checked on
   *  access and if found, the global is re-initialized with a proper TObject wrapper.
   *  Also assignes PreventDestruction magic.
   */
  void SetPerlGlobalDelayedInit(pTHX_ const char* variable, TObject** cobj, const char* className);
} // end namespace SOOT

#endif

