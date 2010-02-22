/*
 * This is a customised version of the pointer table implementation in sv.c.
 * First customized by chocolateboy 2009-02-25,
 * later for SOOT by Steffen Mueller
 */

#ifndef __PtrTable_h_
#define __PtrTable_h_
#include <TObject.h>
#undef Copy

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#ifdef __cplusplus
}
#endif

namespace SOOT {

  typedef struct PtrAnnotation {
    int temp;
  } PtrAnnotation;

  typedef void (*PtrTableEntryValueDtor)(pTHX_ PtrAnnotation*);

  typedef struct PtrTableEntry {
      struct PtrTableEntry* next;
      const TObject* key;
      PtrAnnotation* value;
  } PtrTableEntry;

  class PtrTable {
  public:
    PtrTable(UV size, NV threshold);
    ~PtrTable();

    PtrAnnotation* Fetch(const TObject* key);
    PtrAnnotation* Delete(TObject* key);
    PtrAnnotation* Store(const TObject* key, PtrAnnotation* value);
    PtrTableEntry* Find(const TObject* key);

    void Clear(pTHX_ PtrTableEntryValueDtor dtor);
  private:
    /// Double the size of the array
    void Grow();

    struct PtrTableEntry **fArray;
    UV fSize;
    UV fItems;
    NV fThreshold;

#if PTRSIZE == 8
    /*
     * This is one of Thomas Wang's hash functions for 64-bit integers from:
     * http://www.concentric.net/~Ttwang/tech/inthash.htm
     */
    static inline U32 hash(PTRV u) {
        u = (~u) + (u << 18);
        u = u ^ (u >> 31);
        u = u * 21;
        u = u ^ (u >> 11);
        u = u + (u << 6);
        u = u ^ (u >> 22);
        return (U32)u;
    }
#else
    /*
     * This is one of Bob Jenkins' hash functions for 32-bit integers
     * from: http://burtleburtle.net/bob/hash/integer.html
     */
    static inline U32 PtrTable::hash(PTRV u) {
        u = (u + 0x7ed55d16) + (u << 12);
        u = (u ^ 0xc761c23c) ^ (u >> 19);
        u = (u + 0x165667b1) + (u << 5);
        u = (u + 0xd3a2646c) ^ (u << 9);
        u = (u + 0xfd7046c5) + (u << 3);
        u = (u ^ 0xb55a4f09) ^ (u >> 16);
        return u;
    }
#endif
  };

} // end namespace SOOT::PtrTable

#endif

