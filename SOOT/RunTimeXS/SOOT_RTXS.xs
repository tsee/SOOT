#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "SOOT_RTXS.h"
#include "SOOT_RTXS_macros.h"

MODULE = SOOT        PACKAGE = SOOT::RTXS
PROTOTYPES: DISABLE

BOOT:
#ifdef USE_ITHREADS
_init_soot_rtxs_lock(&SOOT_RTXS_lock); /* cf. SOOT_RTXS.h */
#endif /* USE_ITHREADS */

void
END()
    PROTOTYPE:
    CODE:
        if (SOOT_RTXS_reverse_hashkeys) {
            SOOT_RTXS_HashTable_free(SOOT_RTXS_reverse_hashkeys);
        }

## we want hv_fetch but with the U32 hash argument of hv_fetch_ent, so do it ourselves...

#ifdef hv_common_key_len
#define CXSA_HASH_FETCH(hv, key, len, hash) (SV**)hv_common_key_len((hv), (key), (len), HV_FETCH_JUST_SV, NULL, (hash))
#else
#define CXSA_HASH_FETCH(hv, key, len, hash) hv_fetch(hv, key, len, 0)
#endif

void
getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const soot_rtxs_hashkey readfrom = SOOT_RTXS_hashkeys[ix];
    SV** he;
  PPCODE:
    if ((he = CXSA_HASH_FETCH((HV *)SvRV(self), readfrom.key, readfrom.len, readfrom.hash)))
      PUSHs(*he);
    else
      XSRETURN_UNDEF;

void
setter(self, newvalue)
    SV* self;
    SV* newvalue;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const soot_rtxs_hashkey readfrom = SOOT_RTXS_hashkeys[ix];
  PPCODE:
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(newvalue);

##    INSTALL_NEW_CV_HASH_OBJ(name, SOOT_RTXS_SUBNAME(getter), key);

##    INSTALL_NEW_CV_HASH_OBJ(name, SOOT_RTXS_SUBNAME(setter), key);

#define SOOT_RTXS_INIT                                             \
    void* dataAddr;                                                \
    const I32 offset = SOOT_RTXS_arrayindices[ix];

#define SOOT_RTXS_CALCADDRESS                                      \
    dataAddr = INT2PTR(void*,                                      \
      PTR2UV( (void*)SOOT::LobotomizeObject(aTHX_ self) )          \
      + offset                                                     \
    );

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

