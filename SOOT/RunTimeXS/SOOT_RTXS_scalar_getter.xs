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
get_struct_Bool_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Bool_t*)dataAddr))
    ));

void
get_struct_Char_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Char_t*)dataAddr))
    ));

void
get_struct_UChar_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVuv((UV) *((UChar_t*)dataAddr))
    ));

void
get_struct_Short_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Short_t*)dataAddr))
    ));

void
get_struct_UShort_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVuv((UV) *((UShort_t*)dataAddr))
    ));

void
get_struct_Int_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Int_t*)dataAddr))
    ));

void
get_struct_UInt_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVuv((UV) *((UInt_t*)dataAddr))
    ));

void
get_struct_Long_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Long_t*)dataAddr))
    ));

void
get_struct_ULong_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVuv((UV) *((ULong_t*)dataAddr))
    ));

void
get_struct_Long64_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSViv((IV) *((Long64_t*)dataAddr))
    ));

void
get_struct_ULong64_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVuv((UV) *((ULong64_t*)dataAddr))
    ));

void
get_struct_Float_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVnv((NV) *((Float_t*)dataAddr))
    ));

void
get_struct_Double_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVnv((NV) *((Double_t*)dataAddr))
    ));

void
get_struct_CharStar(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT
  PPCODE:
    SOOT_RTXS_CALCADDRESS
    XPUSHs(sv_2mortal(
      newSVpvn(*((char**)dataAddr), strlen(*((char**)dataAddr)))
    ));

