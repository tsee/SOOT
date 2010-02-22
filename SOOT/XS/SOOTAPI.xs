
MODULE = SOOT		PACKAGE = SOOT::API

SV
type(sv)
    SV* sv
  INIT:
    SOOT::BasicType type;
  PPCODE:
    dXSTARG;
    type = GuessType(aTHX_ sv);
    const char* type_str = SOOT::gBasicTypeStrings[type];
    XPUSHp(type_str, strlen(type_str));

SV*
cproto(sv)
    SV* sv
  INIT:
    SOOT::BasicType type;
  PPCODE:
    dXSTARG;
    type = GuessType(aTHX_ sv);
    STRLEN len;
    const char* cproto = CProtoFromType(aTHX_ sv, len, type);
    XPUSHp(cproto, len);

void
prevent_destruction(rootObject)
    SV* rootObject
  PPCODE:
    SOOT::PreventDestruction(aTHX_ rootObject);

