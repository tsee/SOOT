
#include "RawROOTPerlConversion.h"
#include "CPerlTypeConversion.h"
#include "PerlCTypeConversion.h"
#include "SOOTDebug.h"


using namespace SOOT;
using namespace std;

namespace SOOT {

#define SOOT_ToInteger(type) case k##type##: \
  return SOOT::IntegerVecToAV<##type##>(aTHX_ (##type##*)dataAddr, maxIndex)
  SV*
  ConvertDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr)
  {
    int aryDim = dm->GetArrayDim();
    if (aryDim > 1)
      croak("Invalid array dimension: We only support "
            "direct access to simple types and 1-dim. arrays");
    else if (aryDim == 1)
      return ConvertArrayDataMemberToPerl(aTHX_ dm, baseAddr);

    Long_t offset = dm->GetOffset();
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)baseAddr + offset);

    switch (type) {
      case kBool_t:    return newSViv((IV) *((Bool_t*)dataAddr));
      case kChar_t:    return newSViv((IV) *((Char_t*)dataAddr));
      case kUChar_t:   return newSVuv((UV) *((UChar_t*)dataAddr));
      case kShort_t:   return newSViv((IV) *((Short_t*)dataAddr));
      case kUShort_t:  return newSVuv((UV) *((UShort_t*)dataAddr));
      case kInt_t:     return newSViv((IV) *((Int_t*)dataAddr));
      case kUInt_t:    return newSVuv((UV) *((UInt_t*)dataAddr));
      case kLong_t:    return newSViv((IV) *((Long_t*)dataAddr));
      case kULong_t:   return newSVuv((UV) *((ULong_t*)dataAddr));
      case kLong64_t:  return newSViv((IV) *((Long64_t*)dataAddr));
      case kULong64_t: return newSVuv((UV) *((ULong64_t*)dataAddr));
      case kFloat_t:   return newSVnv((NV) *((Float_t*)dataAddr));
      case kDouble_t:  return newSVnv((NV) *((Double_t*)dataAddr));
      case kCharStar:  return newSVpvn(*((char**)dataAddr), strlen(*((char**)dataAddr)));
      default:
        croak("Invalid data member type");
    };
    return &PL_sv_undef;
  }

#define SOOT_ToIntegerAV(type) case k##type: \
  return SOOT::IntegerVecToAV<type>(aTHX_ (type*)dataAddr, maxIndex)
#define SOOT_ToUIntegerAV(type) case k##type: \
  return SOOT::UIntegerVecToAV<type>(aTHX_ (type*)dataAddr, maxIndex)
#define SOOT_ToFloatAV(type) case k##type: \
  return SOOT::FloatVecToAV<type>(aTHX_ (type*)dataAddr, maxIndex)
  SV*
  ConvertArrayDataMemberToPerl(pTHX_ TDataMember* dm, void* baseAddr)
  {
    Long_t offset = dm->GetOffset();
    int maxIndex = dm->GetMaxIndex(0);
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)baseAddr + offset);

    switch (type) {
      SOOT_ToIntegerAV(Bool_t);
      //SOOT_ToIntegerAV(Char_t);
      case kChar_t: return newSVpvn(*((char**)dataAddr), maxIndex);
      SOOT_ToUIntegerAV(UChar_t);
      SOOT_ToIntegerAV(Short_t);
      SOOT_ToUIntegerAV(UShort_t);
      SOOT_ToIntegerAV(Int_t);
      SOOT_ToUIntegerAV(UInt_t);
      SOOT_ToIntegerAV(Long_t);
      SOOT_ToUIntegerAV(ULong_t);
      SOOT_ToIntegerAV(Long64_t);
      SOOT_ToUIntegerAV(ULong64_t);
      SOOT_ToFloatAV(Float_t);
      SOOT_ToFloatAV(Double_t);
    default:
        croak("Invalid type of array for member");
        return &PL_sv_undef; // not reached!
        break;
    };
    return &PL_sv_undef; // not reached!
  }
#undef SOOT_ToFloatAV
#undef SOOT_ToUIntegerAV
#undef SOOT_ToIntegerAV

} // end namespace SOOT

