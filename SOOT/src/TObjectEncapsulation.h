
#ifndef __TObjectEncapsulation_h_
#define __TObjectEncapsulation_h_

#include <TROOT.h>
#include <TObject.h>
#include <TVirtualPad.h>
#undef Copy

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
  class PtrTable;

  extern MGVTBL gIndestructibleMagicVTable; // used for identification of our PreventDestruction magic
  extern MGVTBL gDelayedInitMagicVTable; // used for identification of our DelayedInit magic
  extern PtrTable* gSOOTObjects;

  /** Creates a new Perl object which is a reference to a scalar blessed into
   *  the class. The scalar itself holds a pointer to the ROOT object.
   */
  SV* EncapsulateObject(pTHX_ TObject* theROOTObject, const char* className);

  /** Given a Perl object (SV*) that's known to be one of our mock TObject like
   *  creatures, fetch the class name and the ROOT object.
   */
  TObject* LobotomizeObject(pTHX_ SV* thePerlObject, char*& className);
  /// Same as the other LobotomizeObject but ignoring the class name
  TObject* LobotomizeObject(pTHX_ SV* thePerlObject);

  /// Free the underlying TObject, set pointer to zero
  void ClearObject(pTHX_ SV* thePerlObject);
  
  /// This corresponds to a C cast "(NewType*)obj"
  void CastObject(pTHX_ SV* thePerlObject, const char* newType);
  
  /** Returns a new copy of the perl (T)Object that points to the same C TObject.
   *  The ORIGINAL will get destruction-prevention magic attached (PreventDestruction),
   *  so that the copy will dictate when the underlying TObject is freed.
   *  If newType is not NULL, the new perl object will be blessed into the class newType.
   *  FIXME This is a poor replacement for reference counting...
   */
  SV* CopyWeaken(pTHX_ SV* thePerlObject, const char* newType);

  /// Prevents destruction of an object by adding magic that is checked during ClearObject
  void PreventDestruction(pTHX_ SV* thePerlObject);

  /// Returns whether the given dereferenced Perl object may be destroyed
  bool IsIndestructible(pTHX_ SV* derefPObj);

  /// Creates a new Perl TObject wrapper (as with EncapsulateObject) that dereferences itself on first access
  SV* MakeDelayedInitObject(pTHX_ TObject** cobj, const char* className);

  /// Replaces the object with its C-level dereference and removes the DelayedInit magic
  void DoDelayedInit(pTHX_ SV* derefPObj);
} // end namespace SOOT

#endif

