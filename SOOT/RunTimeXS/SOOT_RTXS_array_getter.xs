#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "SOOT_RTXS.h"
#include "SOOT_RTXS_macros.h"
#include "CPerlTypeConversion.h"

#define SOOT_ToIntegerAV(type) \
  XPUSHs(sv_2mortal(           \
    SOOT::IntegerVecToAV<type>(aTHX_ (type*)dataAddr, idxdata.maxIndex) \
  ));
#define SOOT_ToUIntegerAV(type) \
  XPUSHs(sv_2mortal(            \
    SOOT::UIntegerVecToAV<type>(aTHX_ (type*)dataAddr, idxdata.maxIndex) \
  ));
#define SOOT_ToFloatAV(type) \
  XPUSHs(sv_2mortal(         \
    SOOT::FloatVecToAV<type>(aTHX_ (type*)dataAddr, idxdata.maxIndex) \
  ));

MODULE = SOOT        PACKAGE = SOOT::RTXS
PROTOTYPES: DISABLE


void
get_struct_array_Bool_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToIntegerAV(Bool_t)

void
get_struct_array_Char_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    XPUSHs(sv_2mortal(
      newSVpvn((char*)dataAddr, idxdata.maxIndex)
    ));

void
get_struct_array_UChar_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToUIntegerAV(UChar_t)

void
get_struct_array_Short_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToIntegerAV(Short_t)

void
get_struct_array_UShort_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToUIntegerAV(UShort_t)

void
get_struct_array_Int_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToIntegerAV(Int_t)

void
get_struct_array_UInt_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToUIntegerAV(UInt_t)

void
get_struct_array_Long_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToIntegerAV(Long_t)

void
get_struct_array_ULong_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToUIntegerAV(ULong_t)

void
get_struct_array_Long64_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToIntegerAV(Long64_t)

void
get_struct_array_ULong64_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToUIntegerAV(ULong64_t)

void
get_struct_array_Float_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToFloatAV(Float_t)

void
get_struct_array_Double_t(self)
    SV* self;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
  PPCODE:
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_ToFloatAV(Double_t)

#undef SOOT_ToFloatAV
#undef SOOT_ToUIntegerAV
#undef SOOT_ToIntegerAV


