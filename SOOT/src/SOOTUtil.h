
#ifndef __SOOTUtil_h_
#define __SOOTUtil_h_

#include "ROOTIncludes.h"

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

  void SOOTcroak(pTHX_ char* msg);

} // end namespace SOOT

#endif

