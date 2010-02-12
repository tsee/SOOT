
#include "ROOTResolver.h"

#include "SOOTClassnames.h"
#include <string>
#include <iostream>
#include <sstream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

namespace SOOT {
  const char* gBasicTypeStrings[10] = {
    "UNDEF",
    "INTEGER",
    "FLOAT",
    "STRING",
    "ARRAY",
    "HASH",
    "CODE",
    "REF",
    "TOBJECT",
    "INVALID",
  };
  const char* gCompositeTypeStrings[4] = {
    "INTEGER_ARRAY",
    "FLOAT_ARRAY",
    "STRING_ARRAY",
    "INVALID_ARRAY",
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
              return eARRAY;
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


  SOOT::CompositeType
  GuessCompositeType(pTHX_ SV* const sv)
  {
    // sv is known to be an RV to an AV
    // We'll base the array type on the FIRST element of the
    // array only. After all we can (potentially with warnings) convert
    // any of the basic types to any other.
    AV* av = (AV*)SvRV(sv);
    const int lastElem = av_len(av);
    if (lastElem < 0) // empty
      return eA_INVALID;
    SV** elem = av_fetch(av, 0, 0);
    if (elem == NULL)
      return eA_INVALID;
    switch (GuessType(aTHX_ *elem)) {
      case eINTEGER:
        return eA_INTEGER;
      case eFLOAT:
        return eA_FLOAT;
      case eSTRING:
        return eA_STRING;
      default:
        return eA_INVALID;
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
      case eARRAY:
        switch (GuessCompositeType(aTHX_ sv)) {
          case eA_INTEGER:
            len = 4;
            return "int*";
          case eA_FLOAT:
            len = 7;
            return "double*";
          case eA_STRING:
            len = 6;
            return "char**";
        }
        len = 0;
        return NULL;
        break;
      default:
        len = 0;
        return NULL;
    }
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

} // end namespace SOOT



SV*
ROOTResolver::CallMethod(pTHX_ const char* className, const char* methName, AV* args)
  const
{
  TClass* c = TClass::GetClass(className);
  if (c == NULL)
    croak("Can't locate object method \"%s\" via package \"%s\"",
          methName, className);

  cout << className << " available as TClass" << endl;
  cout << "TClass has name " << c->GetName() << endl;

  char* cproto = CProtoFromAV(aTHX_ args, 1); // 1 => skip first arg (the TObject)
  // cproto is NULL if no arguments
  TMethod* theMethod;
  if (cproto == NULL)
    theMethod = c->GetMethodWithPrototype(methName, "");
  else {
    theMethod = c->GetMethodWithPrototype(methName, cproto);
    free(cproto);
  }

  if (theMethod == NULL)
    croak("Can't locate object method \"%s\" via package \"%s\"",
          methName, className);
  const char* retType = theMethod->GetReturnTypeName();
  cout << theMethod->GetPrototype() << endl;
  return &PL_sv_undef;
}


SV*
ROOTResolver::EncapsulateObject(pTHX_ TObject* theROOTObject, const char* className)
  const
{
  SV* ref = newSV(0);
  sv_setref_pv(ref, className, (void*)theROOTObject );
  return ref;
}


    /*const unsigned int lastArg = av_len(arguments);
    for (unsigned int iArg = 0; iArg <= lastArg; ++iArg) {
      const char* cproto = SOOT::CProtoFromType();
    }*/

