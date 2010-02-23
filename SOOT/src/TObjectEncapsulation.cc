
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
  RegisterObject(pTHX_ TObject* theROOTObject, const char* className, SV* theReference)
  {
    if (className == NULL)
      className = theROOTObject->ClassName();

    // Fetch the reference pad for this TObject
    PtrAnnotation* refPad = gSOOTObjects->FetchOrCreate(theROOTObject);

    ++(refPad->fNReferences);

    if (theReference == NULL)
      theReference = newSV(0);

    sv_setref_pv(theReference, className, (void*)theROOTObject );
    (refPad->fPerlObjects).push_back(theReference);

    return theReference;
  }

  // FIXME inline
  SV*
  RegisterObject(pTHX_ SV* thePerlObject, const char* className)
  {
    return RegisterObject(aTHX_ LobotomizeObject(aTHX_ thePerlObject), className);
  }


  void
  UnregisterObject(pTHX_ SV* thePerlObject, bool mustNotClearRefPad)
  {
    if (!SvROK(thePerlObject))
      return;
    SV* inner = (SV*)SvRV(thePerlObject);
    if (!SvIOK(inner))
      return;
    //DoDelayedInit(aTHX_ thePerlObject); // FIXME not necessary?
    TObject* obj = INT2PTR(TObject*, SvIV(inner));
    if (obj == NULL)
      return;
    
    // It's global destruction
    if (SOOT::gSOOTObjects == NULL) {
      return;
    }

    // Fetch the reference pad for this TObject
    PtrAnnotation* refPad = gSOOTObjects->Fetch(obj);
    if (!refPad)
      return;

    --(refPad->fNReferences);
    sv_setiv(inner, 0);
    // FIXME doesn't work / isn't necessary?
    //sv_setsv_nomg(thePerlObject, &PL_sv_undef);
    if (refPad->fNReferences == 0) {
      gSOOTObjects->Delete(obj);
      if (!refPad->fDoNotDestroy && obj->TestBit(kCanDelete)) {
        //gDirectory->Remove(obj); // TODO investigate Remove vs. RecursiveRemove -- Investigate necessity, too.
        //obj->SetBit(kMustCleanup);
        delete obj;
      }
      if (!mustNotClearRefPad)
        delete refPad;
    }

    return;
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
      if (SvIOK(inner) && !IsIndestructible(aTHX_ thePerlObject)) {
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


  /*  ... YAGNI ...
  void
  CastObject(pTHX_ SV* thePerlObject, const char* newType)
  {
    sv_bless(thePerlObject, gv_stashpv(newType, GV_ADD));
  }
  */


  void
  PreventDestruction(pTHX_ SV* thePerlObject) {
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      SV* inner = (SV*)SvRV(thePerlObject);
      TObject* ptr = INT2PTR(TObject*, SvIV(inner));
      PtrAnnotation* refPad = gSOOTObjects->Fetch(ptr);
      if (ptr == NULL || refPad == NULL) {
        // late intialization always prevents destruction
        return;
      }
      else {
        // Normal encapsulated TObject
        refPad->fDoNotDestroy = true;
      }
    } // end if it's a good object
    else
      croak("BAD");
  }

  /// FIXME inline?
  bool
  IsIndestructible(pTHX_ SV* thePerlObject) {
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      PtrAnnotation* refPad = gSOOTObjects->Fetch(LobotomizeObject(aTHX_ thePerlObject));
      if (!refPad)
        croak("SOOT::IsIndestructible: Not an encapsulated ROOT object!");
      return refPad->fDoNotDestroy;
    }
    else
      croak("BAD");
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
    // (and value, we use g as an identifier) of our delayed-init
    // magic.
    SV* derefPObj = SvRV(thePerlObj);
    MAGIC *mg;
    if (SvTYPE(derefPObj) >= SVt_PVMG) {
      for (mg = SvMAGIC(derefPObj); mg; mg = mg->mg_moremagic) {
        if ((mg->mg_type == PERL_MAGIC_ext)) {
          if (mg->mg_virtual == &gDelayedInitMagicVTable) {
            TObject* ptr = *INT2PTR(TObject**, SvIV(derefPObj));
            sv_unmagic(derefPObj, PERL_MAGIC_ext);
            // Fetch the reference pad for this TObject and append this SV
            PtrAnnotation* refPad = gSOOTObjects->FetchOrCreate(ptr);
            ++(refPad->fNReferences);
            sv_setpviv(derefPObj, PTR2IV(ptr));
            (refPad->fPerlObjects).push_back(thePerlObj);
            refPad->fDoNotDestroy = true; // can't destroy late init objects
          }
          break;
        } // end is PERL_MAGIC_ext magic
      } // end foreach magic
    } // end if magical
  }

} // end namespace SOOT

