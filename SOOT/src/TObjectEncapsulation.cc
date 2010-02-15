
#include "TObjectEncapsulation.h"

#include <string>
#include <iostream>
#include <cstring>
#include <cstdlib>

using namespace SOOT;
using namespace std;

namespace SOOT {

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
    if (SvROK(thePerlObject) && SvIOK((SV*)SvRV(thePerlObject))) {
      SV* inner = (SV*)SvRV(thePerlObject);
      delete INT2PTR(TObject*, SvIV(inner));
      sv_setiv(inner, 0);
    }
  }

} // end namespace SOOT

