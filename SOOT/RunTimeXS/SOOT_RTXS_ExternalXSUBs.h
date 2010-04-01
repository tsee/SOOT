#ifndef _SOOT_RTXS_ExternalXSUBs_h_
#define _SOOT_RTXS_ExternalXSUBs_h_
#include "SOOT_RTXS_macros.h"

#define SOOT_RTXS_EXTERNAL_XSUB(name) \
  extern "C" void SOOT_RTXS_SUBNAME(name)(pTHX_ CV* cv)

SOOT_RTXS_EXTERNAL_XSUB(access_struct_Bool_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Char_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_UChar_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Short_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_UShort_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Int_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_UInt_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Long_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_ULong_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Long64_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_ULong64_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Float_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_Double_t);
SOOT_RTXS_EXTERNAL_XSUB(access_struct_CharStar);

#undef SOOT_RTXS_EXTERNAL_XSUB

#endif

