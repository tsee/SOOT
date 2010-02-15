
MODULE = SOOT		PACKAGE = TObject

void
DESTROY(self)
    SV* self
  PPCODE:
    SOOT::ClearObject(aTHX_ self);


