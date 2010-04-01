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
#define SOOT_AVToIntegerAry(type) \
  SOOT::AVToIntegerVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, idxdata.maxIndex);
#define SOOT_AVToUIntegerAry(type) \
  SOOT::AVToUIntegerVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, idxdata.maxIndex);
#define SOOT_AVToFloatAry(type) \
  SOOT::AVToFloatVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, idxdata.maxIndex);
 
MODULE = SOOT        PACKAGE = SOOT::RTXS
PROTOTYPES: DISABLE


void
set_struct_array_Bool_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToIntegerAry(Bool_t)

void
set_struct_array_Char_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
    char* buf;
  PPCODE:
    //SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    // FIXME investigate null-padding issues. In general the Char_t[5] thingies might not need it
    buf = SvPV(src, len);
    if (idxdata.maxIndex < len)
      len = idxdata.maxIndex;
    strncpy( (char*)dataAddr, buf, len );
    ((char*)dataAddr)[len] = '\0'; // FIXME is this right?

void
set_struct_array_UChar_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToUIntegerAry(UChar_t)

void
set_struct_array_Short_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToIntegerAry(Short_t)

void
set_struct_array_UShort_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToUIntegerAry(UShort_t)

void
set_struct_array_Int_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToIntegerAry(Int_t)

void
set_struct_array_UInt_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToUIntegerAry(UInt_t)

void
set_struct_array_Long_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToIntegerAry(Long_t)

void
set_struct_array_ULong_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToUIntegerAry(ULong_t)

void
set_struct_array_Long64_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToIntegerAry(Long64_t)

void
set_struct_array_ULong64_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToUIntegerAry(ULong64_t)

void
set_struct_array_Float_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToFloatAry(Float_t)

void
set_struct_array_Double_t(self, src)
    SV* self;
    SV* src;
  ALIAS:
  INIT:
    SOOT_RTXS_INIT_ARRAY
    size_t len;
  PPCODE:
    SOOT_RTXS_ASSERT_ARRAY_ARGUMENT
    SOOT_RTXS_CALCADDRESS_ARRAY
    SOOT_AVToFloatAry(Double_t)

#undef SOOT_AVToIntegerAry
#undef SOOT_AVToUIntegerAry
#undef SOOT_AVToFloatAry

