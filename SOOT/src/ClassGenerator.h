
#ifndef __ClassGenerator_h_
#define __ClassGenerator_h_

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
  class ClassGenerator {
    public:
      ClassGenerator() {};
      ~ClassGenerator() {};
      
      void Generate(pTHX) const;

      static void MakeClass(pTHX_ const char* className);
  };
} // end namespace SOOT

#endif

