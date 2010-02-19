
#include "ROOTResolver.h"
#include "TObjectEncapsulation.h"

#include "PerlCTypeConversion.h"
#include "CPerlTypeConversion.h"
#include "SOOTClassnames.h"
#include <string>
#include <iostream>
#include <sstream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

namespace SOOT {
  const char* gBasicTypeStrings[13] = {
    "UNDEF",
    "INTEGER",
    "FLOAT",
    "STRING",
    "INTEGER_ARRAY",
    "FLOAT_ARRAY",
    "STRING_ARRAY",
    "INVALID_ARRAY",
    "HASH",
    "CODE",
    "REF",
    "TOBJECT",
    "INVALID",
  };

#define IS_TOBJECT(sv) (sv_derived_from((sv), "TObject"))

  /* Lifted from autobox. My eternal gratitude goes to the
   * ever impressive Chocolateboy!
   */
  SOOT::BasicType
  GuessType(pTHX_ SV* const sv)
  {
    switch (SvTYPE(sv)) {
      case SVt_NULL:
        return eUNDEF;
      case SVt_IV:
        return eINTEGER;
      case SVt_PVIV:
        if (SvIOK(sv))
          return eINTEGER;
        else
          return eSTRING;
      case SVt_NV:
        if (SvIOK(sv))
          return eINTEGER;
        else
          return eFLOAT;
      case SVt_PVNV:
        if (SvNOK(sv))
          return eFLOAT;
        else if (SvIOK(sv))
          return eINTEGER;
        else
          return eSTRING;
#ifdef SVt_RV /* no longer defined by default if PERL_CORE is defined */
      case SVt_RV:
#endif
      case SVt_PV:
#ifdef SvVOK
        if (SvVOK(sv))
          return eINVALID; // VSTRING
#endif
        if (SvROK(sv)) {
          return eREF;
        } else {
          return eSTRING;
        }
      case SVt_PVMG:
#ifdef SvVOK
        if (SvVOK(sv))
          return eINVALID; // VSTRING
#endif
        if (SvROK(sv)) {
          return IS_TOBJECT(sv) ? eTOBJECT : eREF;
        } else {
          return eSTRING;
        }
      case SVt_PVLV:
        if (SvROK(sv))
          return IS_TOBJECT(sv) ? eTOBJECT : eREF;
        else if (LvTYPE(sv) == 't' || LvTYPE(sv) == 'T') { /* tied lvalue */
          if (SvIOK(sv))
            return eINTEGER;
          else if (SvNOK(sv))
            return eFLOAT;
          else
            return eSTRING;
        } else {
          cout << "lval"<<endl;
          return eINVALID; // LVALUE
        }
      case SVt_PVAV:
      case SVt_PVHV:
      case SVt_PVCV:
        //return eARRAY;
        //return eHASH;
        //return eCODE;
        return eINVALID;
      case SVt_PVGV: // GLOB
      case SVt_PVFM: // FORMAT
      case SVt_PVIO: // IO
#ifdef SVt_BIND
      case SVt_BIND:
        return eINVALID; // BIND
#endif
#ifdef SVt_REGEXP
      case SVt_REGEXP:
        return eINVALID; // REGEXP
#endif
      default:
        if (SvROK(sv)) {
          if (IS_TOBJECT(sv))
            return eTOBJECT;
          switch (SvTYPE(SvRV(sv))) {
            case SVt_PVAV:
              return _GuessCompositeType(aTHX_ sv);
            case SVt_PVHV:
              return eHASH;
            case SVt_PVCV:
              return eCODE;
            default:
              return eREF;
          }
        } else {
          return eINVALID; // UNKNOWN
        }
    }
  }


  SOOT::BasicType
  _GuessCompositeType(pTHX_ SV* const sv)
  {
    // sv is known to be an RV to an AV
    // We'll base the array type on the FIRST element of the
    // array only. After all we can (potentially with warnings) convert
    // any of the basic types to any other.
    AV* av = (AV*)SvRV(sv);
    const int lastElem = av_len(av);
    if (lastElem < 0) // empty
      return eARRAY_INVALID;
    SV** elem = av_fetch(av, 0, 0);
    if (elem == NULL)
      return eARRAY_INVALID;
    switch (GuessType(aTHX_ *elem)) {
      case eINTEGER:
        return eARRAY_INTEGER;
      case eFLOAT:
        return eARRAY_FLOAT;
      case eSTRING:
        return eARRAY_STRING;
      default:
        return eARRAY_INVALID;
    }
  }

  const char*
  CProtoFromType(pTHX_ SV* const sv, STRLEN& len)
  {
    return CProtoFromType(aTHX_ sv, len, GuessType(aTHX_ sv));
  }

  const char*
  CProtoFromType(pTHX_ SV* const sv, STRLEN& len, BasicType type)
  {
    std::string tmp;
    // TODO figure out references vs. pointers
    switch (type) {
      case eTOBJECT:
        tmp = std::string(sv_reftype(SvRV(sv), TRUE)) + std::string("*");
        len = tmp.length();
        return tmp.c_str();
      case eINTEGER:
        len = 3;
        return "int";
      case eFLOAT:
        len = 6;
        return "double";
      case eSTRING:
        len = 5;
        return "char*";
      case eARRAY_INTEGER:
        len = 4;
        return "int*";
      case eARRAY_FLOAT:
        len = 7;
        return "double*";
      case eARRAY_STRING:
        len = 6;
        return "char**";
      default:
        len = 0;
        return NULL;
    }
  }

  std::vector<BasicType>
  GuessTypes(pTHX_ AV* av)
  {
    vector<BasicType> types;
    const unsigned int nElem = (unsigned int)(av_len(av)+1);
    for (unsigned int iElem = 0; iElem < nElem; ++iElem) {
      SV* const* elem = av_fetch(av, iElem, 0);
      if (elem == NULL)
        croak("av_fetch failed. Severe error.");
      types.push_back(GuessType(aTHX_ *elem));
    }
    return types;
  }


  char*
  CProtoFromAV(pTHX_ AV* av, const unsigned int nSkip = 1)
  {
    vector<const char*> protos;
    vector<STRLEN> lengths;
    SV** elem;
    STRLEN len;
    unsigned int totalLen = 0;

    // convert the elements into C prototype strings
    const unsigned int nElem = (unsigned int)(av_len(av)+1);
    if (nSkip >= nElem)
      return NULL;
    for (unsigned int iElem = nSkip; iElem < nElem; ++iElem) {
      elem = av_fetch(av, iElem, 0);
      if (elem == NULL)
        croak("av_fetch failed. Severe error.");
      const char* thisCProto = CProtoFromType(aTHX_ *elem, len);
      //cout << thisCProto<<endl;
      protos.push_back(thisCProto);
      lengths.push_back(len);
      totalLen += len+1;
      //cout << len << endl;
    }
    
    char* cproto = (char*)malloc(totalLen);
    // doesn't work: ?
    //Newx((void*)cproto, totalLen, char);
    unsigned int pos = 0;
    for (unsigned int iElem = 0; iElem < protos.size(); ++iElem) {
      len = lengths[iElem];
      strncpy((char*)(cproto+pos), protos[iElem], len);
      pos += len;
      cproto[pos] = ',';
      ++pos;
    }
    cproto[pos-1] = '\0';
    return cproto;
  }

  void
  CProtoAndTypesFromAV(pTHX_ AV* av, std::vector<BasicType>& avtypes,
                       std::vector<std::string>& cproto, const unsigned int nSkip = 0)
  {
    SV** elem;
    STRLEN len;

    // convert the elements into C prototype strings
    const unsigned int nElem = (unsigned int)(av_len(av)+1);
    if (nSkip >= nElem)
      return;
    for (unsigned int iElem = nSkip; iElem < nElem; ++iElem) {
      elem = av_fetch(av, iElem, 0);
      if (elem == NULL)
        croak("av_fetch failed. Severe error.");
      BasicType type = GuessType(aTHX_ *elem);
      avtypes.push_back(type);
      cproto.push_back(CProtoFromType(aTHX_ *elem, len, type));
    }
  }

  char*
  JoinCProto(const std::vector<std::string>& cproto, const unsigned int nSkip = 1)
  {
    const unsigned int n = cproto.size();
    if (nSkip >= n)
      return NULL;
    ostringstream str;
    for (unsigned int i = nSkip; i < n; i++) {
      str << cproto[i];
      if (i != n-1)
         str << ",";
    }
    return strdup(str.str().c_str());
  }

  /* Heavily inspired by RubyROOT! */
  BasicType
  GuessTypeFromProto(const char* proto)
  {
    char* typestr = strdup(proto);
    char* ptr = typestr;
    int ptr_level = 0;
    BasicType type;

    while (*(ptr++)) {
      if (*ptr == '*')
        ptr_level++;
    }

    ptr--;

    // FIXME I think this can break on stuff like
    //       char* const* where the *'s aren't all at the end
    if (ptr_level > 0)
        *(ptr - ptr_level) = '\0';

    if (!strncmp(ptr-3, "int", 3) ||
        !strncmp(ptr-4, "long", 4) ||
        !strncmp(ptr-5, "short", 5)) {
      if (ptr_level)
        type = eARRAY_INTEGER;
      else
        type = eINTEGER;
    }
    else if (!strncmp(ptr-6, "double", 6) ||
             !strncmp(ptr-5, "float", 5)) {
      if (ptr_level)
        type = eARRAY_FLOAT;
      else
        type = eFLOAT;
    }
    else if (!strncmp(ptr-5, "char", 4)) {
      if (ptr_level == 1)
        type = eSTRING;
      else if (ptr_level == 2)
        type = eARRAY_STRING;
      else
        type = eINTEGER;
    }
    else if (!strncmp(ptr-4, "void", 4))
      type = eUNDEF; // FIXME check validity
    else if (!strncmp(ptr-4, "bool", 4))
      type = eINTEGER; // FIXME Do we need a eBOOL type?
    else if (ptr_level)
      type = eTOBJECT; // FIXME, umm, really?
    else
      type = eINVALID;

    free(typestr);

    return type;
  }

  bool
  CProtoIntegerToFloat(std::vector<std::string>& cproto)
  {
    const unsigned int nprotos = cproto.size();
    bool changed = false;
    for (unsigned int i = 0; i < nprotos; ++i) {
      if (cproto[i] == string("int*")) {
        cproto[i] = string("double*");
        changed = true;
      }
    }
    return changed;
  }

  void
  SetMethodArguments(pTHX_ G__CallFunc& theFunc, AV* args,
                     const vector<BasicType>& argTypes, const unsigned int nSkip = 1)
  {
    const unsigned int nElem = (unsigned int)(av_len(args)+1);
    for (unsigned int iElem = nSkip; iElem < nElem; ++iElem) {
      SV* const* elem = av_fetch(args, iElem, 0);
      if (elem == NULL)
        croak("av_fetch failed. Severe error.");
      size_t len;
      switch (argTypes[iElem]) {
        case eINTEGER:
          theFunc.SetArg((long)SvIV(*elem));
          break;
        case eFLOAT:
          theFunc.SetArg((double)SvNV(*elem));
          break;
        case eSTRING:
          theFunc.SetArg((long)SvPV_nolen(*elem));
          break;
        case eARRAY_INTEGER:
          // FIXME memory leak?
          // allocate C-array here and convert the AV
          theFunc.SetArg((long)SOOT::AVToIntegerVec<int>(aTHX_ (AV*)SvRV(*elem), len));
          break;
        case eARRAY_FLOAT:
          // FIXME memory leak?
          // allocate C-array here and convert the AV
          theFunc.SetArg((long)SOOT::AVToFloatVec<double>(aTHX_ (AV*)SvRV(*elem), len));
          break;
        case eARRAY_STRING:
          // FIXME memory leak?
          // allocate C-array here and convert the AV
          theFunc.SetArg((long)SOOT::AVToCStringVec(aTHX_ (AV*)SvRV(*elem), len));
          break;
        case eTOBJECT:
          theFunc.SetArg((long)LobotomizeObject(aTHX_ *elem));
          break;
        default:
          croak("BAD ARGUMENT");
      }
    }
    return;
  }


  SV*
  ProcessReturnValue(pTHX_ const BasicType& retType, long addr, double addrD, const char* retTypeStr)
  {
    char* typeStrWithoutPtr;
    char* ptr;
    unsigned int ptr_level;
    SV* retval;
    switch (retType) {
      case eINTEGER:
        return newSViv(addr);
      case eFLOAT:
        return newSVnv(addrD);
      case eSTRING:
        return newSVpv((char*)addr, strlen((char*)addr));
      case eARRAY_INTEGER:
      case eARRAY_FLOAT:
      case eARRAY_STRING:
        // allocate C-array here and convert the AV
        croak("FIXME Array return values to be implemented");
        break;
      case eTOBJECT:
        // FIXME this is so hideous it's not even funny
        typeStrWithoutPtr = strdup(retTypeStr);
        ptr = typeStrWithoutPtr;
        ptr_level = 0;
        while (*(ptr++)) {
          if (*ptr == '*')
            ++ptr_level;
        }
        --ptr;
        // FIXME I think this can break on stuff like
        //       char* const* where the *'s aren't all at the end
        if (ptr_level > 0)
          *(ptr - ptr_level) = '\0';
        retval = EncapsulateObject(aTHX_ (TObject*)addr, typeStrWithoutPtr);
        if (ptr_level > 0)
          *(ptr - ptr_level) = ' ';
        free(typeStrWithoutPtr);
        return retval;
      case eUNDEF:
        return &PL_sv_undef;
      default:
        croak("Unhandled return type '%s' (SOOT type '%s')", retTypeStr, gBasicTypeStrings[retType]);
    } // end switch ret type
  }

  SV*
  CallMethod(pTHX_ const char* className, char* methName, AV* args)
  {
    // Determine the class...
    TClass* c = TClass::GetClass(className);
    if (c == NULL)
      croak("Can't locate method \"%s\" via package \"%s\"",
            methName, className);

    vector<BasicType> argTypes;
    vector<string> cproto;
    CProtoAndTypesFromAV(aTHX_ args, argTypes, cproto);
    if (argTypes.size() == 0)
      croak("Bad invocation");

    char* cprotoStr = JoinCProto(cproto, 1); // 1 => skip first arg (the TObject)

    // Fetch the call receiver (object or class name)
    SV** elem = av_fetch(args, 0, 0);
    if (elem == 0)
      croak("CallMethod requires at least an object or class-name");
    SV* perlCallReceiver = *elem;
    BasicType receiverType = argTypes[0];
    if (receiverType != eTOBJECT && receiverType != eSTRING) {
      croak("Trying to invoke method '%s' on variable of type '%s' is not supported",
            methName, gBasicTypeStrings[receiverType]);
    }

    TObject* receiver;
    G__ClassInfo theClass(className);
    G__MethodInfo mInfo;
    long offset;
    bool constructor = false;
    if (receiverType == eSTRING) { // class method
      if (strEQ(methName, "new")) {
        // constructor
        methName = (char*)className;
        constructor = true;
      }
      mInfo = theClass.GetMethod(methName,
                         (cprotoStr == NULL ? "" : cprotoStr),
                         &offset);
      if (!mInfo.IsValid() && cprotoStr != NULL) {
        if (CProtoIntegerToFloat(cproto)) { // found int* => double*
          char* newCProtoStr = JoinCProto(cproto);
          mInfo = theClass.GetMethod(methName,
                         newCProtoStr,
                         &offset);
          free(newCProtoStr);
        }
      }
      receiver = 0;
    }
    else { // object method
      mInfo = theClass.GetMethod(methName,
                         (cprotoStr == NULL ? "" : cprotoStr),
                         &offset);
      if (!mInfo.IsValid() && cprotoStr != NULL) {
        if (CProtoIntegerToFloat(cproto)) { // found int* => double*
          char* newCProtoStr = JoinCProto(cproto);
          mInfo = theClass.GetMethod(methName,
                         newCProtoStr,
                         &offset);
          free(newCProtoStr);
        }
      }
      receiver = LobotomizeObject(aTHX_ perlCallReceiver);
    }

    free(cprotoStr);
    if (!mInfo.IsValid() || !mInfo.Name())
      CroakOnInvalidMethod(aTHX_ className, methName, c, cproto);

    // Determine return type
    char* retTypeStr = constructor ? (char*)className : (char*)mInfo.Type()->TrueName();
    // FIXME ... defies description
    BasicType retType = GuessTypeFromProto(constructor ? (string(className)+string("*")).c_str() : retTypeStr);

    // Prepare CallFunc
    G__CallFunc theFunc;
    theFunc.SetFunc(mInfo);

    SetMethodArguments(aTHX_ theFunc, args, argTypes);

    long addr;
    double addrD;
    if (retType == eFLOAT)
      addrD = theFunc.ExecInt((void*)((long)receiver + offset));
    else
      addr = theFunc.ExecDouble((void*)((long)receiver + offset));

    //cout << "RETVAL INFO FOR " <<  methName << ": cproto=" << retTypeStr << " mytype=" << gBasicTypeStrings[retType] << endl;
    return ProcessReturnValue(aTHX_ retType, addr, addrD, retTypeStr);
    return &PL_sv_undef;
  }

  void
  CroakOnInvalidMethod(pTHX_ const char* className, const char* methName, TClass* c, const std::vector<std::string>& cproto)
  {
    ostringstream msg;
    char* cprotoStr = JoinCProto(cproto);
    if (cprotoStr == NULL)
      cprotoStr = strdup("void");

    vector<string> candidates;
    TIter next(c->GetListOfAllPublicMethods());
    TMethod* meth;
    while ((meth = (TMethod*)next())) {
      if (strEQ(meth->GetName(), methName)) {
        candidates.push_back(string(meth->GetPrototype()));
      }
    }

    msg << "Can't locate method \"" << methName << "\" via package \""
        << className << "\". From the arguments you supplied, the following C prototype was calculated:\n  "
        << className << "::" << methName << "(" << cprotoStr << ")";
    free(cprotoStr);
    if (!candidates.empty()) {
      msg << "\nThere were the following methods of the same name, but with a different prototype:";
      for (unsigned int iCand = 0; iCand < candidates.size(); ++iCand) {
        msg << "\n  " << candidates[iCand];
      }
    }
    croak(msg.str().c_str());
  }

} // end namespace SOOT

