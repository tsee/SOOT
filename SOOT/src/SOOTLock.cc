
#include "SOOTLock.h"
#include "SOOTDebug.h"

#include <string>
#include <iostream>
#include <sstream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

GlobalLock::GlobalLock(pTHX)
  : fLocks(0)
{
  memset(&fMutex, 0, sizeof(perl_mutex));
  memset(&fCond, 0, sizeof(perl_cond));
  MUTEX_INIT(&fMutex);
  COND_INIT(&fCond);
}

ScopeLock
GlobalLock::GetLock(pTHX)
{
  return ScopeLock(aTHX, *this);
}
 
ScopeLock::ScopeLock(pTHX_ GlobalLock& theLock)
{
#ifdef USE_ITHREADS
  MUTEX_LOCK(&theLock.fMutex);
  while (theLock.fLocks != 0) {
    COND_WAIT(&theLock.fCond, &theLock.fMutex);
  }
  theLock.fLocks = 1;
  MUTEX_UNLOCK(&theLock.fMutex);

  fLock = &theLock;
  fLocked = true;
#endif
}

void
ScopeLock::Release(pTHX)
{
#ifdef USE_ITHREADS
  if (fLocked) {
    MUTEX_LOCK(&fLock->fMutex);
    fLock->fLocks = 0;
    COND_SIGNAL(&fLock->fCond);
    MUTEX_UNLOCK(&fLock->fMutex);
    fLocked = false;
  }
#endif
}

ScopeLock::~ScopeLock()
{
  dTHX;
  Release(aTHX);
}

namespace SOOT { 
  GlobalLock* gSOOTGlobalLock = NULL;
} // end namespace SOOT

