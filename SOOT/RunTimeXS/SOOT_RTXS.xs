#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "SOOT_RTXS.h"

/* This is all based on Class::XSAccessor code */

#define SOOT_RTXS_SUBNAME(name) XS_SOOT__RTXS_ ## name

/* Install a new XSUB under 'name' and automatically set the file name */
#define INSTALL_NEW_CV(name, xsub)                                            \
STMT_START {                                                                  \
  if (newXS(name, xsub, (char*)__FILE__) == NULL)                             \
    croak("ARG! Something went really wrong while installing a new XSUB!");   \
} STMT_END

/* Install a new XSUB under 'name' and set the function index attribute
 * Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index)               \
STMT_START {                                                                \
  CV* cv = newXS(name, xsub, (char*)__FILE__);                              \
  if (cv == NULL)                                                           \
    croak("ARG! Something went really wrong while installing a new XSUB!"); \
  XSANY.any_i32 = function_index;                                           \
} STMT_END

/* Install a new XSUB under 'name' and set the function index attribute
 * for array-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_ARRAY_OBJ(name, xsub, obj_array_index)                \
STMT_START {                                                                 \
  const U32 function_index = get_internal_array_index((I32)obj_array_index); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  SOOT_RTXS_arrayindices[function_index] = obj_array_index;                \
} STMT_END


/* Install a new XSUB under 'name' and set the function index attribute
 * for hash-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_HASH_OBJ(name, xsub, obj_hash_key)                    \
STMT_START {                                                                 \
  soot_rtxs_hashkey hashkey;                                                    \
  const U32 key_len = strlen(obj_hash_key);                                  \
  const U32 function_index = get_hashkey_index(aTHX_ obj_hash_key, key_len); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  Newx(hashkey.key, key_len+1, char);                                        \
  Copy(obj_hash_key, hashkey.key, key_len, char);                            \
  hashkey.key[key_len] = 0;                                                  \
  hashkey.len = key_len;                                                     \
  PERL_HASH(hashkey.hash, obj_hash_key, key_len);                            \
  SOOT_RTXS_hashkeys[function_index] = hashkey;                            \
} STMT_END

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

/*## we want hv_fetch but with the U32 hash argument of hv_fetch_ent, so do it ourselves...*/

#ifdef hv_common_key_len
#define CXSA_HASH_FETCH(hv, key, len, hash) hv_common_key_len((hv), (key), (len), HV_FETCH_JUST_SV, NULL, (hash))
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

void
newxs_getter(name, key)
  char* name;
  char* key;
  PPCODE:
    INSTALL_NEW_CV_HASH_OBJ(name, SOOT_RTXS_SUBNAME(getter), key);

void
newxs_setter(name, key)
  char* name;
  char* key;
  PPCODE:
      INSTALL_NEW_CV_HASH_OBJ(name, SOOT_RTXS_SUBNAME(setter), key);

