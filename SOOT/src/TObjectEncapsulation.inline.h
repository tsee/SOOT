
namespace SOOT {
  inline SV*
  RegisterObject(pTHX_ SV* thePerlObject, const char* className)
  {
    return RegisterObject(aTHX_ LobotomizeObject(aTHX_ thePerlObject), className);
  }


  inline TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject, char*& className)
  {
    DoDelayedInit(aTHX_ thePerlObject);
    SV* inner = (SV*)SvRV(thePerlObject);
    className = (char*)sv_reftype(inner, TRUE);
    return INT2PTR(TObject*, SvIV(inner));
  }


  inline TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject)
  {
    DoDelayedInit(aTHX_ thePerlObject);
    SV* inner = (SV*)SvRV(thePerlObject);
    return INT2PTR(TObject*, SvIV(inner));
  }



  inline void
  ClearObject(pTHX_ SV* thePerlObject)
  {
    if (SvROK(thePerlObject)) {
      SV* inner = (SV*)SvRV(thePerlObject);
      if (SvIOK(inner)) {
        TObject* obj = INT2PTR(TObject*, SvIV(inner));
        if (!IsIndestructible(aTHX_ obj)) {
          if (obj->TestBit(kCanDelete)) {
            //gDirectory->Remove(obj); // TODO investigate Remove vs. RecursiveRemove -- Investigate necessity, too.
            obj->SetBit(kMustCleanup);
            delete obj;
          }
          sv_setiv(inner, 0);
        }
      } // end if SvIOK
    } // end if RVOK
  }


  inline bool
  IsIndestructible(pTHX_ SV* thePerlObject)
  {
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      PtrAnnotation* refPad = gSOOTObjects->Fetch(LobotomizeObject(aTHX_ thePerlObject));
      if (!refPad)
        croak("SOOT::IsIndestructible: Not an encapsulated ROOT object!");
      return refPad->fFlags & SOOTf_DoNotDestroy;
    }
    else
      croak("BAD");
  }


  inline bool
  IsIndestructible(pTHX_ TObject* theROOTObject)
  {
    PtrAnnotation* refPad = gSOOTObjects->Fetch(theROOTObject);
    if (!refPad)
      croak("SOOT::IsIndestructible: Not an encapsulated ROOT object!");
    return refPad->fFlags & SOOTf_DoNotDestroy;
  }

  inline void
  _SetFlags_internal_ROOT(pTHX_ TObject* theROOTObject, U32 flags) {
    if (theROOTObject != NULL) {
      PtrAnnotation* refPad = gSOOTObjects->Fetch(theROOTObject);
      // late intialization always prevents destruction => skip
      if (refPad != NULL) // Normal encapsulated TObject
        refPad->fFlags |= flags;
    }
  }

  /// Marks the PtrAnnotation for the given Perl-side object as related to a ROOT global
  /// and thus also as non-destructible by Perl. SV version (slow)
  inline void
  SetROOTGlobal(pTHX_ SV* thePerlObject) {
    _SetFlags_internal_SV(aTHX_ thePerlObject, (SOOTf_DoNotDestroy|SOOTf_IsROOTGlobal));
  }

  /// Marks the PtrAnnotation for the given Perl-side object as related to a ROOT global
  /// and thus also as non-destructible by Perl.
  inline void
  SetROOTGlobal(pTHX_ TObject* theROOTObject) {
    _SetFlags_internal_ROOT(aTHX_ theROOTObject, (SOOTf_DoNotDestroy|SOOTf_IsROOTGlobal));
  }

  /// Prevents destruction of an object by noting the fact in the object table (SV* variant ==> slow)
  inline void
  PreventDestruction(pTHX_ SV* thePerlObject) {
    _SetFlags_internal_SV(aTHX_ thePerlObject, SOOTf_DoNotDestroy);
  }

  /// Prevents destruction of an object by noting the fact in the object table (TObject variant ==> fast)
  inline void
  PreventDestruction(pTHX_ TObject* theROOTObject) {
    _SetFlags_internal_ROOT(aTHX_ theROOTObject, SOOTf_DoNotDestroy);
  }

} // end namespace SOOT

