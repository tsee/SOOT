#include "SOOTClass.h"

#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <cmath>

#include <dump_classes.h>

using namespace std;
using namespace SOOTbootstrap;

SOOTCppType
SOOTClass::MakeType(const bool isPtr, const bool isConst)
  const
{
  SOOTCppType t;
  t.fTypeName = fName;
  t.fIsClass = true;
  t.fIsStruct = false;
  t.fIsPointer = isPtr;
  t.fIsConstant = isConst;
  t.fIsConstPointer = false;
  t.fIsReference = false;
  t.IntuitSOOTBasicTypes();
  return t;
}

