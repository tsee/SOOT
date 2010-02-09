
#ifndef __ClassGenerator_h_
#define __ClassGenerator_h_

namespace SOOT {
  class ClassGenerator {
    public:
      ClassGenerator();
      ~ClassGenerator();
      
    private:
      bool fOwnsClassNames;
      char** fClassNames;
      unsigned int fNClassNames;
  };
} // end namespace SOOT

#endif

