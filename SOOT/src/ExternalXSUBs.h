#ifndef __ExternalXSUBs_h_
#define __ExternalXSUBs_h_
extern "C" void XS_TObject_DESTROY(register PerlInterpreter* my_perl , CV* cv);
extern "C" void XS_TObject_keep(register PerlInterpreter* my_perl , CV* cv);
extern "C" void XS_TObject_as(register PerlInterpreter* my_perl , CV* cv);
extern "C" void XS_TObject_delete(register PerlInterpreter* my_perl , CV* cv);
#endif

