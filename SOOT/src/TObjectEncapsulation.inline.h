
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


  inline bool
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


} // end namespace SOOT

