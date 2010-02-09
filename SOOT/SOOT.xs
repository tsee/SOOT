
#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
#undef do_open
#undef do_close
#ifdef __cplusplus
}
#endif


#include "SOOTClassnames.h"
#include <iostream>
#include <string>

using namespace SOOT;
using namespace std;

MODULE = SOOT		PACKAGE = SOOT

INCLUDE: XS/SOOTBOOT.xs

INCLUDE_COMMAND: $^X -MExtUtils::XSpp::Cmd -e xspp -- -t typemap.xsp SOOT.xsp


