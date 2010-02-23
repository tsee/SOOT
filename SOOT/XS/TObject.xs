
MODULE = SOOT		PACKAGE = TObject

void
DESTROY(self)
    SV* self
  PPCODE:
    SOOT::UnregisterObject(aTHX_ self);


SV*
as(self, newType)
    SV* self
    const char* newType
  CODE:
    RETVAL = SOOT::RegisterObject(aTHX_ self, newType);
  OUTPUT: RETVAL



####### FIXME The following is a super-evil workaround for the "type enum" bug, so that users can at least do GetXaxis()->as("TAxis")!

MODULE = SOOT		PACKAGE = enum

void
DESTROY(self)
    SV* self
  PPCODE:
    SOOT::UnregisterObject(aTHX_ self);


SV*
as(self, newType)
    SV* self
    const char* newType
  CODE:
    RETVAL = SOOT::RegisterObject(aTHX_ self, newType);
  OUTPUT: RETVAL



