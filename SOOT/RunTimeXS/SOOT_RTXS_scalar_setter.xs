#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "SOOT_RTXS.h"
#include "SOOT_RTXS_macros.h"

MODULE = SOOT        PACKAGE = SOOT::RTXS
PROTOTYPES: DISABLE

void
set_struct_Bool_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Bool_t*)dataAddr)    = (Bool_t)SvIV(src);

void
set_struct_Char_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Char_t*)dataAddr)    = (Char_t)SvIV(src);

void
set_struct_UChar_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((UChar_t*)dataAddr)    = (UChar_t)SvUV(src);

void
set_struct_Short_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Short_t*)dataAddr)    = (Short_t)SvIV(src);

void
set_struct_UShort_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((UShort_t*)dataAddr)    = (UShort_t)SvUV(src);

void
set_struct_Int_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Int_t*)dataAddr)    = (Int_t)SvIV(src);

void
set_struct_UInt_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((UInt_t*)dataAddr)    = (UInt_t)SvUV(src);

void
set_struct_Long_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Long_t*)dataAddr)    = (Long_t)SvIV(src);

void
set_struct_ULong_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((ULong_t*)dataAddr)    = (ULong_t)SvUV(src);

void
set_struct_Long64_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Long64_t*)dataAddr)    = (Long64_t)SvIV(src);

void
set_struct_ULong64_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((ULong64_t*)dataAddr)    = (ULong64_t)SvUV(src);

void
set_struct_Float_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Float_t*)dataAddr)    = (Float_t)SvUV(src);

void
set_struct_Double_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    *((Double_t*)dataAddr)    = (Double_t)SvUV(src);

void
set_struct_CharStar(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    char* buf;
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    // FIXME investigate null-padding issues. In general the Char_t[5] thingies might not need it
    free(*((char**)dataAddr));
    buf = strdup(SvPV_nolen(src));
    dataAddr = (void*)&buf;

