
#include "TObjectEncapsulation.h"

#include <string>
#include <iostream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

namespace SOOT {

  // Inspired by XS::Variable::Magic
  MGVTBL gNullMagicVTable = {
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
  EncapsulateObject(pTHX_ TObject* theROOTObject, const char* className)
  {
    SV* ref = newSV(0);
    sv_setref_pv(ref, className, (void*)theROOTObject );
    return ref;
  }


  TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject, char*& className)
  {
    className = (char*)sv_reftype(SvRV(thePerlObject), TRUE);
    return INT2PTR(TObject*, SvIV((SV*)SvRV( thePerlObject )));
  }


  TObject*
  LobotomizeObject(pTHX_ SV* thePerlObject)
  {
    return INT2PTR(TObject*, SvIV((SV*)SvRV( thePerlObject )));
  }


  void
  ClearObject(pTHX_ SV* thePerlObject)
  {
    if (SvROK(thePerlObject)) {
      SV* inner = (SV*)SvRV(thePerlObject);
      if (SvIOK(inner) && !IsIndestructible(aTHX_ inner)) {
        //cout << "CLEARING " <<SvIV(inner) << endl;
        delete INT2PTR(TObject*, SvIV(inner));
        sv_setiv(inner, 0);
      }
    }
  }

  void
  PreventDestruction(pTHX_ SV* thePerlObject) {
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      sv_magicext(SvRV(thePerlObject), NULL, PERL_MAGIC_ext, &gNullMagicVTable, 0, 0 );
    }
  }

  inline bool
  IsIndestructible(pTHX_ SV* derefPObj) {
    // My hat goes off to XS::Variable::Magic.
    // Essentially, we just check whether the attached magic is *exactly* the type
    // (and value, we use gNullMagicVTable as an identifier) of our destruction-prevention
    // magic.
    MAGIC *mg;
    if (SvTYPE(derefPObj) >= SVt_PVMG) {
      for (mg = SvMAGIC(derefPObj); mg; mg = mg->mg_moremagic) {
        if (
            (mg->mg_type == PERL_MAGIC_ext)
            &&
            (mg->mg_virtual == &gNullMagicVTable)
        ) {
          return true;
        }
      }
    }

    return false;
  }

} // end namespace SOOT

