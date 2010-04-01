
#include "RawROOTPerlConversion.h"
#include "CPerlTypeConversion.h"
#include "PerlCTypeConversion.h"
#include "SOOTDebug.h"


using namespace SOOT;
using namespace std;

namespace SOOT {

  SV*
  InstallDataMemberToPerlConverter(pTHX_ TDataMember* dm, void* baseAddr)
  {
    int aryDim = dm->GetArrayDim();
    if (aryDim > 1)
      croak("Invalid array dimension: We only support "
            "direct access to simple types and 1-dim. arrays");
    else if (aryDim == 1)
      return InstallArrayDataMemberToPerlConverter(aTHX_ dm, baseAddr);

    Long_t offset = dm->GetOffset();
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)baseAddr + offset);
    //string name = string("ClassName::") + string("MemberName");
    //INSTALL_NEW_CV_ARRAY_OBJ(name.c_str(), SOOT_RTXS_SUBNAME(get_struct_Bool_t), offset);

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
  InstallArrayDataMemberToPerlConverter(pTHX_ TDataMember* dm, void* baseAddr)
  {
    Long_t offset = dm->GetOffset();
    int maxIndex = dm->GetMaxIndex(0);
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)baseAddr + offset);

    switch (type) {
      SOOT_ToIntegerAV(Bool_t);
      //SOOT_ToIntegerAV(Char_t);
      case kChar_t: return newSVpvn((char*)dataAddr, maxIndex);
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
    };
    return &PL_sv_undef; // not reached!
  }
#undef SOOT_ToFloatAV
#undef SOOT_ToUIntegerAV
#undef SOOT_ToIntegerAV


  void
  InstallSVToDataMemberConverter(pTHX_ TDataMember* dm, void* targetBaseAddr, SV* src)
  {
    int aryDim = dm->GetArrayDim();
    if (aryDim > 1)
      croak("Invalid array dimension: We only support "
            "direct access to simple types and 1-dim. arrays");
    else if (aryDim == 1)
      return InstallArrayDataMemberToPerlConverter(aTHX_ dm, targetBaseAddr, src);

    Long_t offset = dm->GetOffset();
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)targetBaseAddr + offset);
    char* buf;

    switch (type) {
      case kBool_t:    *((Bool_t*)dataAddr)    = (Bool_t)SvIV(src);    return;
      case kChar_t:    *((Char_t*)dataAddr)    = (Char_t)SvIV(src);    return;
      case kUChar_t:   *((UChar_t*)dataAddr)   = (UChar_t)SvUV(src);   return;
      case kShort_t:   *((Short_t*)dataAddr)   = (Short_t)SvIV(src);   return;
      case kUShort_t:  *((UShort_t*)dataAddr)  = (UShort_t)SvUV(src);  return;
      case kInt_t:     *((Int_t*)dataAddr)     = (Int_t)SvIV(src);     return;
      case kUInt_t:    *((UInt_t*)dataAddr)    = (UInt_t)SvUV(src);    return;
      case kLong_t:    *((Long_t*)dataAddr)    = (Long_t)SvIV(src);    return;
      case kULong_t:   *((ULong_t*)dataAddr)   = (ULong_t)SvUV(src);   return;
      case kLong64_t:  *((Long64_t*)dataAddr)  = (Long64_t)SvIV(src);  return;
      case kULong64_t: *((ULong64_t*)dataAddr) = (ULong64_t)SvUV(src); return;
      case kFloat_t:   *((Float_t*)dataAddr)   = (Float_t)SvNV(src);   return;
      case kDouble_t:  *((Double_t*)dataAddr)  = (Double_t)SvNV(src);  return;
      case kCharStar:
        // FIXME investigate null-padding issues. In general the Char_t[5] thingies might not need it
        free(*((char**)dataAddr));
        buf = strdup(SvPV_nolen(src));
        dataAddr = (void*)&buf;
        return;
      default:
        croak("Invalid data member type");
    };
    return;
  }


#define SOOT_AVToIntegerAry(type) case k##type: \
  SOOT::AVToIntegerVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, maxIndex); return
#define SOOT_AVToUIntegerAry(type) case k##type: \
  SOOT::AVToUIntegerVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, maxIndex); return
#define SOOT_AVToFloatAry(type) case k##type: \
  SOOT::AVToFloatVecInPlace<type>(aTHX_ (AV*)SvRV(src), len, (type*)dataAddr, maxIndex); return
  void
  InstallSVToArrayDataMemberConverter(pTHX_ TDataMember* dm, void* targetBaseAddr, SV* src)
  {
    Long_t offset = dm->GetOffset();
    int maxIndex = dm->GetMaxIndex(0);
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)targetBaseAddr + offset);
    size_t len;
    char* buf;

    switch (type) {
      SOOT_AVToIntegerAry(Bool_t);
      //SOOT_AVToIntegerAry(Char_t);
      case kChar_t:
        // FIXME investigate null-padding issues. In general the Char_t[5] thingies might not need it
        buf = SvPV(src, len);
        if (maxIndex < (int)len)
          len = maxIndex;
        strncpy( (char*)dataAddr, buf, len );
        ((char*)dataAddr)[len] = '\0'; // FIXME is this right?
        return;
      SOOT_AVToUIntegerAry(UChar_t);
      SOOT_AVToIntegerAry(Short_t);
      SOOT_AVToUIntegerAry(UShort_t);
      SOOT_AVToIntegerAry(Int_t);
      SOOT_AVToUIntegerAry(UInt_t);
      SOOT_AVToIntegerAry(Long_t);
      SOOT_AVToUIntegerAry(ULong_t);
      SOOT_AVToIntegerAry(Long64_t);
      SOOT_AVToUIntegerAry(ULong64_t);
      SOOT_AVToFloatAry(Float_t);
      SOOT_AVToFloatAry(Double_t);
    default:
      croak("Invalid type of array for member");
    };
    return;
  }
#undef SOOT_AVToIntegerAry
#undef SOOT_AVToUIntegerAry
#undef SOOT_AVToFloatAry
} // end namespace SOOT

