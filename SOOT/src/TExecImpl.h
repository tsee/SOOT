
#ifndef __TExecImpl_h_
#define __TExecImpl_h_

#include <TObject.h>
namespace SOOT {

  class TExecImpl {
  private:
    TExecImpl() {}
  public:
    static void TestAlive();
    static void RunPerlCallback(const unsigned long id);
    ClassDef(TExecImpl, 1);
  };
} // end namespace SOOT

#endif

