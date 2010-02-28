### NOTE: Any stuff you want to have all SOOT classes needs to be added to ClassGenerator, too

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


SV*
keep(self)
    SV* self
  CODE:
    SOOT::PreventDestruction(aTHX_ self);
    SvREFCNT_inc(self);
    RETVAL = self;
  OUTPUT: RETVAL


void
delete(self)
    SV* self
  PPCODE:
    SOOT::MarkForDestruction(aTHX_ self);
    SvREFCNT_dec(self);



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


SV*
keep(self)
    SV* self
  CODE:
    SOOT::PreventDestruction(aTHX_ self);
    SvREFCNT_inc(self);
    RETVAL = self;
  OUTPUT: RETVAL


void
delete(self)
    SV* self
  PPCODE:
    SOOT::MarkForDestruction(aTHX_ self);
    SvREFCNT_dec(self);

