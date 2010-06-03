
#ifndef __SOOTLock_h_
#define __SOOTLock_h_

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
  class ScopeLock;

  class GlobalLock {
  public:
    GlobalLock(pTHX);
    ~GlobalLock() {};

    ScopeLock GetLock(pTHX);
  private:
    friend class ScopeLock;
#ifdef USE_ITHREADS
    perl_mutex fMutex;
    perl_cond fCond;
    unsigned int fLocks;
#endif /* USE_ITHREADS */
  };

  class ScopeLock {
  public:
    ~ScopeLock();
    void Release(pTHX);

  private:
    ScopeLock(pTHX_ GlobalLock& theLock);
    
    GlobalLock* fLock;
    bool fLocked;

    friend class GlobalLock;
  };

  extern GlobalLock* gSOOTGlobalLock;
} // end namespace SOOT

#endif

