
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

  SV* ConvertDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr);
  SV* ConvertArrayDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr);

  //void ConvertSVToDataMember(pTHX_ TDataMember* dm, void* targetBaseAddr, SV* src);
} // end namespace SOOT

#endif

