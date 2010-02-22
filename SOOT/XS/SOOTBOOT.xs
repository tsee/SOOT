
BOOT:
  //cout << "BOOTING SOOT" << endl;
  SOOT::GenerateClassStubs(aTHX);
  SOOT::InitializePerlGlobals(aTHX);
  SOOT::gSOOTObjects = new SOOT::PtrTable(aTHX_ (UV)1024, &SOOT::ClearAnnotation);

