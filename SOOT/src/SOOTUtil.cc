
#include "SOOTUtil.h"
#include "SOOTDebug.h"

namespace SOOT {
  
  void
  SOOTcroak(pTHX_ char* msg)
  {
    const char* argv[2]; argv[0] = msg; argv[1] = 0;
    call_argv( "Carp::croak", G_VOID|G_DISCARD, (char**)argv );
  }
} // end namespace SOOT

