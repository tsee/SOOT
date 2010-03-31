## we want hv_fetch but with the U32 hash argument of hv_fetch_ent, so do it ourselves...

#ifdef hv_common_key_len
#define CXSA_HASH_FETCH(hv, key, len, hash) hv_common_key_len((hv), (key), (len), HV_FETCH_JUST_SV, NULL, (hash))
#else
#define CXSA_HASH_FETCH(hv, key, len, hash) hv_fetch(hv, key, len, 0)
#endif

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

void
getter(self)
    SV* self;
  ALIAS:
  INIT:
    /* Get the const hash key struct from the global storage */
    /* ix is the magic integer variable that is set by the perl guts for us.
     * We uses it to identify the currently running alias of the accessor. Gollum! */
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
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
    const autoxs_hashkey readfrom = CXSAccessor_hashkeys[ix];
  PPCODE:
    if (NULL == hv_store((HV*)SvRV(self), readfrom.key, readfrom.len, newSVsv(newvalue), readfrom.hash))
      croak("Failed to write new value to hash.");
    PUSHs(newvalue);

void
newxs_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    INSTALL_NEW_CV_HASH_OBJ(name, CXAH(getter_init), key);

void
newxs_setter(name, key, chained)
  char* name;
  char* key;
  bool chained;
  PPCODE:
    if (chained)
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(chained_setter_init), key);
    else
      INSTALL_NEW_CV_HASH_OBJ(name, CXAH(setter_init), key);

