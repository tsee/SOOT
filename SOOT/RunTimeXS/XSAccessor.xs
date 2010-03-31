#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "SOOT_RTXS.h"

#define CXAA(name) XS_Class__XSAccessor__Array_ ## name
#define CXAH(name) XS_Class__XSAccessor_ ## name

/*#else*/ /* CXA_ENABLE_ENTERSUB_OPTIMIZATION */
#define CXAH_OPTIMIZE_ENTERSUB_TEST(name)
#define CXAH_OPTIMIZE_ENTERSUB(name)
#define CXAA_OPTIMIZE_ENTERSUB(name)
#define CXAH_GENERATE_ENTERSUB_TEST(name)
#define CXAH_GENERATE_ENTERSUB(name)
#define CXAA_GENERATE_ENTERSUB(name)
/*#endif*/

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
  CXSAccessor_arrayindices[function_index] = obj_array_index;                \
} STMT_END


/* Install a new XSUB under 'name' and set the function index attribute
 * for hash-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_HASH_OBJ(name, xsub, obj_hash_key)                    \
STMT_START {                                                                 \
  autoxs_hashkey hashkey;                                                    \
  const U32 key_len = strlen(obj_hash_key);                                  \
  const U32 function_index = get_hashkey_index(aTHX_ obj_hash_key, key_len); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  Newx(hashkey.key, key_len+1, char);                                        \
  Copy(obj_hash_key, hashkey.key, key_len, char);                            \
  hashkey.key[key_len] = 0;                                                  \
  hashkey.len = key_len;                                                     \
  PERL_HASH(hashkey.hash, obj_hash_key, key_len);                            \
  CXSAccessor_hashkeys[function_index] = hashkey;                            \
} STMT_END

#ifdef CXA_ENABLE_ENTERSUB_OPTIMIZATION
static Perl_ppaddr_t CXA_DEFAULT_ENTERSUB = NULL;

/* predeclare the XSUBs so we can refer to them in the optimized entersubs */

XS(CXAH(getter));
XS(CXAH(getter_init));
CXAH_GENERATE_ENTERSUB(getter);

XS(CXAH(setter));
XS(CXAH(setter_init));
CXAH_GENERATE_ENTERSUB(setter);

XS(CXAH(chained_setter));
XS(CXAH(chained_setter_init));
CXAH_GENERATE_ENTERSUB(chained_setter);

XS(CXAH(accessor));
XS(CXAH(accessor_init));
CXAH_GENERATE_ENTERSUB(accessor);

XS(CXAH(chained_accessor));
XS(CXAH(chained_accessor_init));
CXAH_GENERATE_ENTERSUB(chained_accessor);

XS(CXAH(predicate));
XS(CXAH(predicate_init));
CXAH_GENERATE_ENTERSUB(predicate);

XS(CXAH(constructor));
XS(CXAH(constructor_init));
CXAH_GENERATE_ENTERSUB(constructor);

XS(CXAH(constant_false));
XS(CXAH(constant_false_init));
CXAH_GENERATE_ENTERSUB(constant_false);

XS(CXAH(constant_true));
XS(CXAH(constant_true_init));
CXAH_GENERATE_ENTERSUB(constant_true);

XS(CXAH(test));
XS(CXAH(test_init));
CXAH_GENERATE_ENTERSUB_TEST(test);

XS(CXAA(getter));
XS(CXAA(getter_init));
CXAA_GENERATE_ENTERSUB(getter);

XS(CXAA(setter));
XS(CXAA(setter_init));
CXAA_GENERATE_ENTERSUB(setter);

XS(CXAA(chained_setter));
XS(CXAA(chained_setter_init));
CXAA_GENERATE_ENTERSUB(chained_setter);

XS(CXAA(accessor));
XS(CXAA(accessor_init));
CXAA_GENERATE_ENTERSUB(accessor);

XS(CXAA(chained_accessor));
XS(CXAA(chained_accessor_init));
CXAA_GENERATE_ENTERSUB(chained_accessor);

XS(CXAA(predicate));
XS(CXAA(predicate_init));
CXAA_GENERATE_ENTERSUB(predicate);

XS(CXAA(constructor));
XS(CXAA(constructor_init));
CXAA_GENERATE_ENTERSUB(constructor);

#endif /* CXA_ENABLE_ENTERSUB_OPTIMIZATION */

MODULE = Class::XSAccessor        PACKAGE = Class::XSAccessor
PROTOTYPES: DISABLE

BOOT:
#ifdef USE_ITHREADS
_init_cxsa_lock(&CXSAccessor_lock); /* cf. CXSAccessor.h */
#endif /* USE_ITHREADS */

void
END()
    PROTOTYPE:
    CODE:
        if (CXSAccessor_reverse_hashkeys) {
            CXSA_HashTable_free(CXSAccessor_reverse_hashkeys);
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

