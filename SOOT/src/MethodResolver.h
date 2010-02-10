
#ifndef __MethodResolver_h_
#define __MethodResolver_h_

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#undef Copy
#undef Size_t
#undef Stat_t
#undef Atof
#undef STATIC
#ifdef __cplusplus
}
#endif

namespace SOOT {
  class MethodResolver {
    public:
      MethodResolver() {};
      ~MethodResolver() {};
      
      void FindMethod(pTHX_ char* className, char* methName, AV* args) const;
  };
} // end namespace SOOT

#endif

