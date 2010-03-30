
#ifndef __RawROOTPerlConversion_h_
#define __RawROOTPerlConversion_h_

#include "ROOTIncludes.h"

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
  // FIXME for now, we punt on multi-dim arrays. C->Perl conversion would be trivial, but the other way, not so due to variable dimension size in Perl

  /** Converts the given ROOT TDataMember of the struct/object that lives at baseAddr
   *  to a Perl structure and returns it.
   *  Calls ConvertArrayDataMemberToPerl as appropriate.
   */
  SV* ConvertDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr);
  /// Internal to ConvertDataMemberToPerl!
  SV* ConvertArrayDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr);

  /** Converts the given source Perl structure to a ROOT TDataMember of the struct/object
   *  that lives at baseAddr.
   *  Calls ConvertSVToArrayDataMember as appropriate.
   */
  void ConvertSVToDataMember(pTHX_ TDataMember* dm, void* targetBaseAddr, SV* src);
  /// Internal to ConvertSVToDataMember!
  void ConvertSVToArrayDataMember(pTHX_ TDataMember* dm, void* targetBaseAddr, SV* src);
} // end namespace SOOT

#endif

