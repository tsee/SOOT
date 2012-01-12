#ifndef sb_SOOTCppType_h_
#define sb_SOOTCppType_h_

#include <set>
#include <string>

#include <TROOT.h>
#include "../ROOTIncludes.h"
#include <SOOTTypes.h>

namespace SOOTbootstrap {
  class SOOTCppType {
  public:
    SOOTCppType() {};
    SOOTCppType(const std::string& typeName, const Long_t props);

    std::string fTypeName;
    bool fIsClass;
    bool fIsStruct;
    bool fIsPointer; // foo *
    bool fIsConstant; // const foo
    bool fIsConstPointer; // foo const *
    bool fIsReference; // foo&

    // the following are just derived members for caching
    std::set<SOOT::BasicType> fSOOTTypes;

    inline bool IsPerlBasicType() {
      return !fSOOTTypes.empty();
    }
    std::string ToString() const;

  private:
    void IntuitSOOTBasicTypes();
  };

} // end namespace SOOTbootstrap

#endif
