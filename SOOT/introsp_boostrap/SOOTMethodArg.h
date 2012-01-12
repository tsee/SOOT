#ifndef sb_SOOTMethodArg_h_
#define sb_SOOTMethodArg_h_

#include <string>
#include <SOOTCppType.h>

namespace SOOTbootstrap {
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  class SOOTMethodArg {
  public:
    SOOTMethodArg() {}

    std::string fDefaultValue;
    SOOTCppType fType;
  };

} // end namespace SOOTbootstrap

#endif
