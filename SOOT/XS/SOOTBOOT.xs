
BOOT:
  //cout << "BOOTING SOOT" << endl;
  static TTObjectEncapsulator e;
  gROOT->GetListOfCleanups()->Add( &e );

  SOOT::gSOOTObjects = new SOOT::PtrTable(aTHX_ (UV)1024, &SOOT::ClearAnnotation);
  SOOT::GenerateClassStubs(aTHX);
  SOOT::InitializePerlGlobals(aTHX);

