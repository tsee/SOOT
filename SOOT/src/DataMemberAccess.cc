
#include "DataMemberAccess.h"
#include "CPerlTypeConversion.h"
#include "PerlCTypeConversion.h"
#include "SOOTDebug.h"

#include "SOOT_RTXS.h"
#include "SOOT_RTXS_ExternalXSUBs.h"


using namespace SOOT;
using namespace std;

namespace SOOT {

// FIXME check mortalization of return value!
#define SOOT_AccessIntegerValue(type) case k##type: \
  INSTALL_NEW_CV_ARRAY_OBJ(fullMemberName.c_str(), SOOT_RTXS_SUBNAME(access_struct_##type), offset); \
  return newSViv((IV) *((type*)dataAddr));

#define SOOT_AccessUIntegerValue(type) case k##type: \
  INSTALL_NEW_CV_ARRAY_OBJ(fullMemberName.c_str(), SOOT_RTXS_SUBNAME(access_struct_##type), offset); \
  return newSVuv((UV) *((type*)dataAddr));

#define SOOT_AccessFloatValue(type) case k##type: \
  INSTALL_NEW_CV_ARRAY_OBJ(fullMemberName.c_str(), SOOT_RTXS_SUBNAME(access_struct_##type), offset); \
  return newSVnv((NV) *((type*)dataAddr));

  SV*
  InstallDataMemberToPerlConverter(pTHX_ TClass* theClass, const char* methName,
                                   TDataMember* dm, void* baseAddr)
  {
    const string fullMemberName = string(theClass->GetName()) + string("::") + string(methName);

    int aryDim = dm->GetArrayDim();
    if (aryDim > 1)
      croak("Invalid array dimension: We only support "
            "direct access to simple types and 1-dim. arrays");
    else if (aryDim == 1)
      return InstallArrayDataMemberToPerlConverter(aTHX_ dm, baseAddr);
      //return InstallArrayDataMemberToPerlConverter(aTHX_ fullMemberName, dm, baseAddr);

    Long_t offset = dm->GetOffset();
    EDataType type = (EDataType)dm->GetDataType()->GetType();
    void* dataAddr = (void*) ((Long_t)baseAddr + offset);
    //string name = string("ClassName::") + string("MemberName");
    //INSTALL_NEW_CV_ARRAY_OBJ(name.c_str(), SOOT_RTXS_SUBNAME(get_struct_Bool_t), offset);

    switch (type) {
      SOOT_AccessIntegerValue(Bool_t);
      SOOT_AccessIntegerValue(Char_t);
      SOOT_AccessUIntegerValue(UChar_t);
      SOOT_AccessIntegerValue(Short_t);
      SOOT_AccessUIntegerValue(UShort_t);
      SOOT_AccessIntegerValue(Int_t);
      SOOT_AccessUIntegerValue(UInt_t);
      SOOT_AccessIntegerValue(Long_t);
      SOOT_AccessUIntegerValue(ULong_t);
      SOOT_AccessIntegerValue(Long64_t);
      SOOT_AccessUIntegerValue(ULong64_t);
      SOOT_AccessFloatValue(Float_t);
      SOOT_AccessFloatValue(Double_t);
      case kCharStar:
        INSTALL_NEW_CV_ARRAY_OBJ(fullMemberName.c_str(), SOOT_RTXS_SUBNAME(access_struct_CharStar), offset);
        return newSVpvn(*((char**)dataAddr), strlen(*((char**)dataAddr))); // FIXME check mortalization
      default:
        croak("Invalid data member type");
    };
    return &PL_sv_undef;
  }
#undef SOOT_AccessIntegerValue
#undef SOOT_AccessUIntegerValue
#undef SOOT_AccessFloatValue


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
      return InstallSVToArrayDataMemberConverter(aTHX_ dm, targetBaseAddr, src);

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

