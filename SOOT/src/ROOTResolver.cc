
#include "ROOTResolver.h"

#include "SOOTClassnames.h"
#include <string>
#include <iostream>
#include <sstream>

using namespace SOOT;
using namespace std;
using namespace ROOT::Reflex;

void
ROOTResolver::FindMethod(pTHX_ const char* className, const char* methName, AV* args)
  const
{
  Scope scope = ROOT::Reflex::Scope::ByName(className);
  if (scope.IsClass()) {
    cout << className << " is a class" << endl;
  }
  else {
    cout << className << " is not a class" << endl;
  }
  TClass *c = TClass::GetClass(className);
  if (c) {
    cout << className << " available as TClass" << endl;
    cout << "TClass has name " << c->GetName() << endl;
  }
  else {
    cout << className << " not available as TClass" << endl;
  }
}

