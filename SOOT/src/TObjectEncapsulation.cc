
#include "TObjectEncapsulation.h"

#include <string>
#include <iostream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

#include "PtrTable.h"

namespace SOOT {
  PtrTable* gSOOTObjects = NULL;

  // Inspired by XS::Variable::Magic
  MGVTBL gIndestructibleMagicVTable = {
      NULL, /* get */
      NULL, /* set */
      NULL, /* len */
      NULL, /* clear */
      NULL, /* free */
#if MGf_COPY
      NULL, /* copy */
#endif /* MGf_COPY */
#if MGf_DUP
      NULL, /* dup */
#endif /* MGf_DUP */
#if MGf_LOCAL
      NULL, /* local */
#endif /* MGf_LOCAL */
  };


  // Inspired by XS::Variable::Magic
  MGVTBL gDelayedInitMagicVTable= {
      NULL, /* get */
      NULL, /* set */
      NULL, /* len */
      NULL, /* clear */
      NULL, /* free */
#if MGf_COPY
      NULL, /* copy */
#endif /* MGf_COPY */
#if MGf_DUP
      NULL, /* dup */
#endif /* MGf_DUP */
#if MGf_LOCAL
      NULL, /* local */
#endif /* MGf_LOCAL */
  };


  SV*
  RegisterObject(pTHX_ TObject* theROOTObject, const char* className)
  {
    if (className == NULL)
      className = theROOTObject->ClassName();

    // Fetch the reference pad for this TObject
    PtrAnnotation* storage = gSOOTObjects->FetchOrCreate(theROOTObject);

    storage->fNReferences++;
    SV* newref = newSV(0);
    sv_setref_pv(newref, className, (void*)theROOTObject );
    storage->fPerlObjects.push_back(newref);
    return newref;
  }


  void
  UnregisterObject(pTHX_ SV* thePerlObject)
  {
    SV* inner = (SV*)SvRV(thePerlObject);
    TObject* obj = INT2PTR(TObject*, SvIV(inner));

    // Fetch the reference pad for this TObject
    PtrAnnotation* storage = gSOOTObjects->Fetch(obj);
    if (!storage)
      return;

    storage->fNReferences--;
    sv_setiv(inner, 0);
    sv_setsv_nomg(thePerlObject, &PL_sv_undef);

    if (storage->fNReferences == 0) {
      gSOOTObjects->Delete(obj);
      if (obj->TestBit(kCanDelete)) {
        //gDirectory->Remove(obj); // TODO investigate Remove vs. RecursiveRemove -- Investigate necessity, too.
        //obj->SetBit(kMustCleanup);
        delete obj;
      }
    }

    return;
  }


  SV*
  EncapsulateObject(pTHX_ TObject* theROOTObject, const char* className)
  {
    SV* ref = newSV(0);
    sv_setref_pv(ref, className, (void*)theROOTObject );
    // Not necessary?
    //theROOTObject->SetBit(kMustCleanup);
    return ref;
  }


  TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject, char*& className)
  {
    DoDelayedInit(aTHX_ thePerlObject);
    SV* inner = (SV*)SvRV(thePerlObject);
    className = (char*)sv_reftype(inner, TRUE);
    return INT2PTR(TObject*, SvIV(inner));
  }


  TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject)
  {
    DoDelayedInit(aTHX_ thePerlObject);
    SV* inner = (SV*)SvRV(thePerlObject);
    return INT2PTR(TObject*, SvIV(inner));
  }


  void
  ClearObject(pTHX_ SV* thePerlObject)
  {
    if (SvROK(thePerlObject)) {
      SV* inner = (SV*)SvRV(thePerlObject);
      if (SvIOK(inner) && !IsIndestructible(aTHX_ inner)) {
        TObject* obj = INT2PTR(TObject*, SvIV(inner));
        if (obj->TestBit(kCanDelete)) {
          //gDirectory->Remove(obj); // TODO investigate Remove vs. RecursiveRemove -- Investigate necessity, too.
          obj->SetBit(kMustCleanup);
          delete obj;
        }
        sv_setiv(inner, 0);
      }
    }
  }


  inline void
  CastObject(pTHX_ SV* thePerlObject, const char* newType)
  {
    sv_bless(thePerlObject, gv_stashpv(newType, GV_ADD));
  }


  SV*
  CopyWeaken(pTHX_ SV* thePerlObject, const char* newType)
  {
    TObject* rootObj;
    char* className;
    if (newType == NULL)
      rootObj = LobotomizeObject(aTHX_ thePerlObject, className);
    else {
      className = (char*)newType;
      rootObj = LobotomizeObject(aTHX_ thePerlObject);
    }
    PreventDestruction(aTHX_ thePerlObject);
    return EncapsulateObject(aTHX_ rootObj, className);
  }


  void
  PreventDestruction(pTHX_ SV* thePerlObject) {
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      SV* inner = SvRV(thePerlObject);
      if (!IsIndestructible(aTHX_ inner))
        sv_magicext(inner, NULL, PERL_MAGIC_ext, &gIndestructibleMagicVTable, 0, 0 );
    }
    else {
      croak("bad");
    }
  }


  inline bool
  IsIndestructible(pTHX_ SV* derefPObj) {
    // My hat goes off to XS::Variable::Magic.
    // Essentially, we just check whether the attached magic is *exactly* the type
    // (and value, we use gIndestructibleMagicVTable as an identifier) of our destruction-prevention
    // magic.
    MAGIC *mg;
    if (SvTYPE(derefPObj) >= SVt_PVMG) {
      for (mg = SvMAGIC(derefPObj); mg; mg = mg->mg_moremagic) {
        if (
            (mg->mg_type == PERL_MAGIC_ext)
            &&
            (mg->mg_virtual == &gIndestructibleMagicVTable)
        ) {
          return true;
        }
      }
    }

    return false;
  }


  SV*
  MakeDelayedInitObject(pTHX_ TObject** cobj, const char* className) {
    SV* ref = newSV(0);
    sv_setref_pv(ref, className, (void*)cobj);
    sv_magicext(SvRV(ref), NULL, PERL_MAGIC_ext, &gDelayedInitMagicVTable, 0, 0 );
    return ref;
  }


  inline void
  DoDelayedInit(pTHX_ SV* thePerlObj) {
    // My hat goes off to XS::Variable::Magic.
    // Essentially, we just check whether the attached magic is *exactly* the type
    // (and value, we use g as an identifier) of our destruction-prevention
    // magic.
    SV* derefPObj = SvRV(thePerlObj);
    MAGIC *mg;
    if (SvTYPE(derefPObj) >= SVt_PVMG) {
      bool isIndestructible = false;
      for (mg = SvMAGIC(derefPObj); mg; mg = mg->mg_moremagic) {
        if ((mg->mg_type == PERL_MAGIC_ext)) {
          if (mg->mg_virtual == &gIndestructibleMagicVTable) {
            isIndestructible = true;
          }
          else if (mg->mg_virtual == &gDelayedInitMagicVTable) {
            TObject* ptr = *INT2PTR(TObject**, SvIV(derefPObj));
            sv_setpviv(derefPObj, PTR2IV(ptr));
            sv_unmagic(derefPObj, PERL_MAGIC_ext);
            if (isIndestructible)
              sv_magicext(derefPObj, NULL, PERL_MAGIC_ext, &gIndestructibleMagicVTable, 0, 0 ); // Same as PreventDestruction
          }
        } // end is PERL_MAGIC_ext magic
      } // end foreach magic
    } // end if magical
  }

} // end namespace SOOT

