
#ifndef __ClassIterator_h_
#define __ClassIterator_h_

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
  class ClassIterator {
  public:
    ClassIterator();

    const char* next();
  private:
    unsigned int fClassNo;
  };

} // end namespace SOOT

#endif

