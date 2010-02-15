
#ifndef __TObjectEncapsulation_h_
#define __TObjectEncapsulation_h_

#include <TROOT.h>
#include <TObject.h>

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
} // end namespace SOOT

#endif

