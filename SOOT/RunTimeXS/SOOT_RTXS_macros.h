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
  SOOT_RTXS_arrayindices[function_index] = obj_array_index;                  \
} STMT_END


/* Install a new XSUB under 'name' and set the function index attribute
 * for hash-based objects. Requires a previous declaration of a CV* cv!
 **/
#define INSTALL_NEW_CV_HASH_OBJ(name, xsub, obj_hash_key)                    \
STMT_START {                                                                 \
  soot_rtxs_hashkey hashkey;                                                 \
  const U32 key_len = strlen(obj_hash_key);                                  \
  const U32 function_index = get_hashkey_index(aTHX_ obj_hash_key, key_len); \
  INSTALL_NEW_CV_WITH_INDEX(name, xsub, function_index);                     \
  Newx(hashkey.key, key_len+1, char);                                        \
  Copy(obj_hash_key, hashkey.key, key_len, char);                            \
  hashkey.key[key_len] = 0;                                                  \
  hashkey.len = key_len;                                                     \
  PERL_HASH(hashkey.hash, obj_hash_key, key_len);                            \
  SOOT_RTXS_hashkeys[function_index] = hashkey;                              \
} STMT_END


