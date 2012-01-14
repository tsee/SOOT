#include "SOOTCppType.h"

#include <cstdlib>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <cmath>

#include <TROOT.h>
#include <TClass.h>
#include <TPRegexp.h>

#include <SOOTClass.h>

using namespace std;
using namespace SOOTbootstrap;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
namespace SOOTbootstrap {
  // FIXME "Warning in <TClass::TClass>: no dictionary for class iterator<bidirectional_iterator_tag,TObject*,long,const TObject**,const TObject*&> is available"
  static TPRegexp gBadClassRegexp("T(?:Btree|List|Map|ObjArray|OrdCollection|RefArray)Iter");
  static TPRegexp gCIntegerType("^(?:unsigned|(?:unsigned )?(?:short|int|char|long(?: long)?)|size_t)$"); // char, too?
  static TPRegexp gStringType("^(?:char|U?(?:Byte|Char)_t|Option_t)$"); // FIXME TString?
  static TPRegexp gROOTIntegerType("^(?:Bool_t|U?(?:Short|Int|Long64|Long|Char|Seek|Byte|Font|Style|Marker|Width|Color|SCoord|SSiz|Version)_t)$");
  static TPRegexp gFloatType("^(?:double|float|(?:(?:Float|Double)(?:16|32|64)?|Real|Axis|Stat|Coord|Angle|Size)_t)$"); // FIXME Size_t a float, really? According to Rtypes.h, yes.
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SOOTCppType::SOOTCppType(const string& typeName, const Long_t props)
  : fTypeName(typeName)
{
  fIsClass = props & kIsClass;
  fIsStruct = props & kIsStruct;
  fIsPointer = props & kIsPointer;
  fIsConstant = props & kIsConstant;
  fIsConstPointer = props & kIsConstPointer;
  fIsReference = props & kIsReference;
  // default is not part of the type
  //fHasDefault = props & kIsDefault;

  IntuitSOOTBasicTypes();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void
SOOTCppType::IntuitSOOTBasicTypes()
{
  if (! fSOOTTypes.empty())
    return;

  // A TObject always goes first as such.
  // FIXME includes some plain structs, curiously
  TClass *cl = TClass::GetClass(fTypeName.c_str());
  if (cl != NULL) {
    fSOOTTypes.insert(SOOT::eTOBJECT);
  }
  // detect basic string types before other basics since they require the ptr to be set
  else if (fIsPointer && SOOTbootstrap::gStringType.MatchB(fTypeName)) {
    fSOOTTypes.insert(SOOT::eSTRING);
  }
  else if (   SOOTbootstrap::gCIntegerType.MatchB(fTypeName)
      || SOOTbootstrap::gROOTIntegerType.MatchB(fTypeName))
  {
    fSOOTTypes.insert(SOOT::eINTEGER);
  }
  else {
    TDataType* dt = gROOT->GetType(fTypeName.c_str());
    // This should catch enums
    if ( (dt != NULL && dt->GetType() == kULong_t)
         || (gEnumRegistry.count(fTypeName.c_str()) > 0) )
    {
      fSOOTTypes.insert(SOOT::eINTEGER); // FIXME want type for unsigned, too?
    }
    else if (SOOTbootstrap::gFloatType.MatchB(fTypeName))
    {
      fSOOTTypes.insert(SOOT::eFLOAT);
    }
  }
  // FIXME should all integers have an .insert(eFLOAT), too?

  return;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTCppType::ToString()
  const
{
  ostringstream s;
  if (fIsConstant)
    s << "const ";
  s << fTypeName;
  if (fIsConstPointer)
    s << " const";
  if (fIsPointer)
    s << " *";
  if (fIsReference)
    s << "&";
  return s.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTCppType::ToStringForTypemap()
  const
{
  ostringstream s;
  //if (fIsConstant)
  //  s << "const ";
  s << fTypeName;
  //if (fIsConstPointer)
  //  s << " const";
  if (fIsPointer || fIsReference)
    s << " *";
  return s.str();
}
