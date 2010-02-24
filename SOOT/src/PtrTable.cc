#include "PtrTable.h"
#include "TObjectEncapsulation.h"

using namespace std;
using namespace SOOT;

#define P_DEBUG 1
#undef P_DEBUG

#define PTRTABLE_HASH(ptr) PtrTable::hash(PTR2nat(ptr))

namespace SOOT {
  void
  ClearAnnotation(pTHX_ PtrAnnotation* pa) {
    // Iterate over the stored references and nuke them
    // FIXME Skip this and let the kernel handle it for now...
    /*for (std::set<SV*>::iterator it = (pa->fPerlObjects).begin();
         it != (pa->fPerlObjects).end(); ++it)
    {
      SOOT::UnregisterObject(aTHX_ *it, true);
    }
    */
#ifdef P_DEBUG
    cout << "ClearAnnotation: deleting PtrAnnotation* '" << pa << "'" << endl;
#endif    
    delete pa; // Needed since UnregisterObject can not free the annotation
  }
} // end namespace SOOT


PtrTable::PtrTable(pTHX_ UV size, PtrTableEntryValueDtor dtor, NV threshold)
  : fSize(size), fItems(0), fThreshold(threshold), fPerl(aTHX), fDtor(dtor)
{
  if ((size < 2) || (size & (size - 1)))
    croak("invalid ptr table size: expected a power of 2 (>= 2), got %u", (unsigned int)size);

  if (!((threshold > 0) && (threshold < 1)))
    croak("invalid threshold: expected 0.0 < threshold < 1.0, got %f", threshold);

  Newxz(fArray, size, PtrTableEntry*);
}


/*****************************************************************************/
PtrTable::~PtrTable()
{
#ifdef P_DEBUG
  cout << "~PtrTable(): Safefree'ing fArray: '" << fArray << "'" << endl;
#endif
  Clear();
  Safefree(fArray);
  fArray = NULL;
  fSize = 0;
}

/*****************************************************************************/
bool
PtrTable::Delete(TObject* key)
{
#ifdef P_DEBUG 
  cout << "PtrTable::Delete: DELETING TObject " << key << " from PtrTable." << endl;
#endif
  PtrTableEntry* entry;
  PtrTableEntry* prev = NULL;
  UV index = PTRTABLE_HASH(key) & (fSize - 1);

  bool deleted = false;
  for (entry = fArray[index]; entry; prev = entry, entry = entry->next) {
    if (entry->key == key) {
      if (prev)
        prev->next = entry->next;
      else
        fArray[index] = entry->next;

      --fItems;
#ifdef P_DEBUG 
      cout << "PtrTable::Delete: delete PtrAnnotation* '" << entry->value << "'." << endl;
#endif
      deleted = true;
      delete entry->value;
#ifdef P_DEBUG 
      cout << "PtrTable::Delete: Safefree(PtrTableEntry* '" << entry << "')." << endl;
#endif
      Safefree(entry);
      break;
    }
  } // end foreach entry in collision list

  return deleted;
}


/*****************************************************************************/
PtrAnnotation*
PtrTable::Fetch(const TObject* key)
{
  PtrTableEntry const * const entry = Find(key);

  return entry ? entry->value : NULL;
}


/*****************************************************************************/
PtrAnnotation* PtrTable::FetchOrCreate(const TObject* key)
{
  PtrTableEntry* entry = Find(key);

  if (entry) {
    return entry->value;
  } else {
    PtrAnnotation* annotation = new PtrAnnotation();
    annotation->fNReferences = 0;
    annotation->fDoNotDestroy = false;
    Store(key, annotation);
    return annotation;
  }
}


/*****************************************************************************/
PtrAnnotation* PtrTable::Store(const TObject* key, PtrAnnotation* value)
{
  PtrAnnotation* annotation = NULL;
  PtrTableEntry* entry = Find(key);

  if (entry) {
    annotation = entry->value;
    entry->value = value;
  } else {
    const UV index = PTRTABLE_HASH(key) & (fSize - 1);
    Newx(entry, 1, PtrTableEntry);

    entry->key = key;
    entry->value = value;
    entry->next = fArray[index];

    fArray[index] = entry;
    ++fItems;

    if (((NV)fItems / (NV)fSize) > fThreshold)
      Grow();
  }

  return annotation;
}


/*****************************************************************************/
PtrTableEntry*
PtrTable::Find(const TObject* key)
{
  if (fSize == 0)
    return NULL;
  PtrTableEntry* entry;
  UV index = PTRTABLE_HASH(key) & (fSize - 1);
  for (entry = fArray[index]; entry; entry = entry->next) {
    if (entry->key == key)
      break;
  }

  return entry;
}


/*****************************************************************************/
/* double the size of the array */
void
PtrTable::Grow()
{
  PtrTableEntry **array = fArray;
  const UV oldsize = fSize;
  UV newsize = oldsize * 2;
  UV i;

  Renew(array, newsize, PtrTableEntry*);
  Zero(&fArray[oldsize], newsize - oldsize, PtrTableEntry*);
  fSize = newsize;
  fArray = array;

  for (i = 0; i < oldsize; ++i, ++array) {
    PtrTableEntry **current_entry_ptr, **entry_ptr, *entry;

    if (!*array)
      continue;

    current_entry_ptr = array + oldsize;

    for (entry_ptr = array, entry = *array; entry; entry = *entry_ptr) {
      UV index = PTRTABLE_HASH(entry->key) & (newsize - 1);

      if (index != i) {
        *entry_ptr = entry->next;
        entry->next = *current_entry_ptr;
        *current_entry_ptr = entry;
        continue;
      }
      else
        entry_ptr = &entry->next;
    } // end foreach entry in collision list
  } // end foreach old entry
}


/*****************************************************************************/
void
PtrTable::Clear() {
  if (fItems) {
    PtrTableEntry** const array = fArray;
    UV riter = fSize - 1;

    do {
      PtrTableEntry* entry = array[riter];

      while (entry) {
        PtrTableEntry* const temp = entry;
        entry = entry->next;
        fDtor(aTHX_ temp->value);
#ifdef P_DEBUG 
        cout << "PtrTable::Clear: Safefree(PtrTableEntry* '" << temp << "')." << endl;
#endif
        Safefree(temp);
      }

      /* chocolateboy 2008-01-08
       *
       * make sure we clear the array entry, so that subsequent probes fail
       */

      array[riter] = NULL;
    } while (riter--);

    fItems = 0;
  } // end if have items
}


void
PtrTable::PrintStats()
{
  cout << "==================================================================\n"
       << "=                      PtrTable::PrintStats()                    =\n"
       << "==================================================================\n"
       << "\n"
       << "== Globals ==\n"
       << "Size="<<fSize<<"\nStored TObjects="<<fItems<<"\nThreshold="<<fThreshold<<"\n"
       << "Perl ptr="<<(void*)fPerl<<"\n"<<endl;
  if (fSize==0 || fItems==0)
    return;

  cout << "== Entries / RefPads ==" << endl;

  UV iter = 0;
  do {
    PtrTableEntry* entry = fArray[iter];

    while (entry) {
      PtrTableEntry* const temp = entry;
      entry = entry->next;

      // entry info
      cout << "= Entry " << (void*)temp << " =\n";
      cout << "  Contains TObject* '" << (void*)temp->key << "' of class " << temp->key->ClassName() << "\n"
           << "  PtrAnnotation* is '" << (void*)temp->value <<"'"<<endl;
      PtrAnnotation* ann = temp->value;
      cout << "    NReferences="<<ann->fNReferences<<endl;
      cout << "    Must " << (ann->fDoNotDestroy ? "NOT " : "") << "be destroyed by SOOT\n";
      for (std::set<SV*>::iterator it = (ann->fPerlObjects).begin();
           it != (ann->fPerlObjects).end(); ++it)
        cout << "    SV* " << (void*)(*it) << endl;
      cout << endl;
    }
  } while (++iter != fSize);

  cout << "== End of RefPads ==\n"<< endl;
}

#undef P_DEBUG
#undef PTRTABLE_HASH

