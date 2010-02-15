
#ifndef __ClassGenerator_h_
#define __ClassGenerator_h_

#include <TBaseClass.h>
#include <TClass.h>
#include <TList.h>

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
} // end namespace SOOT

#endif

