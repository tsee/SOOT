#include "SOOTMethod.h"

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <cmath>

#include <SOOTClass.h>

using namespace std;
using namespace SOOTbootstrap;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool
SOOTMethod::cmp(const SOOTMethod& l, const SOOTMethod& r)
{
  // returns true if l is less than r, that is, return true if
  // l is preferred over r

  // Note that we're always sorting methods that are valid for a
  // given number of input parameters.

  // The method with the highest number of required parameters is
  // preferred. FIXME think about this some more
  if (l.GetNRequiredArgs() > r.GetNRequiredArgs())
    return true;

  // Then, we prefer the method that has the least no. of total
  // parameters. FIXME think about this some more
  if (l.fNArgsTotal < r.fNArgsTotal)
    return true;

  // FIXME this will probably go away again, it's a dead-end
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
static string
S_MakeArgumentNameList(vector< pair< SOOTMethodArg, string > >& args, bool withType = false)
{
  ostringstream s;
  const unsigned int n = args.size();
  for (unsigned int i = 0; i < n; ++i) {
    pair< SOOTMethodArg, string>& arg = args[i];
    if (withType)
      s << arg.first.fType.ToStringForTypemap() << " ";
    s << arg.second;
    if (i < n-1)
      s << ", ";
  }
  return s.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTMethod::GenerateUnambiguousXSUB()
  const
{
  string className = fClass->fName;
  string fullFuncName = fClass->PerlName() + "::" + fName;

  ostringstream s;
  s << "void\n" << fullFuncName << "(invocant, ...)\n";
  if (fIsStatic) {
    s << "    " << "char * CLASS;\n";
  }
  else {
    s << "    " << className << " * THIS;\n";
  }

  ostringstream preInit;
  ostringstream ppCode;

  const unsigned int nArgsFixed = GetNRequiredArgs();
  vector< pair< SOOTMethodArg, string > > argNames;
  for (unsigned int iarg = 0; iarg < fNArgsTotal; ++iarg) {
    ostringstream argNS;
    argNS << "arg" << iarg+1;
    argNames.push_back( pair<SOOTMethodArg, string>(fMethodArgs[iarg], argNS.str()) );
  }

  // generate code to check the number of parameters
  ppCode << "    ";
  if (fNArgsOpt == 0)
    ppCode << "if (items != " << fNArgsTotal << ")\n";
  else
    ppCode << "if (items < " << nArgsFixed << " || items > fNArgsTotal)\n";
  string argListWithTypes = S_MakeArgumentNameList(argNames, true);
  ppCode << "      croak(\"Usage: " << fullFuncName
         << "(" << className << "* object"
         << (argListWithTypes == "" ? string("") : string(", ")+argListWithTypes)
         << ")\");\n";

  // Generate parameter declarations
  for (unsigned int ip = 0; ip < fNArgsTotal; ++ip) {
    pair<SOOTMethodArg, string>& argN = argNames[ip];
    preInit << "    " << argN.first.fType.ToStringForTypemap() << " " << argN.second;
    if (argN.first.fDefaultValue != "")
      preInit << " = " << argN.first.fDefaultValue;
    preInit << ";\n";
  }

  // Assemble sections
  s << "  PREINIT:\n" << preInit.str();
  s << "  PPCODE:\n" << ppCode.str();

// FIXME debug output
cout <<"\n";
cout << s.str();
cout <<"\n";
  return s.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// This is the code to generate
// void
// Foo(arg1, arg2, arg2, ...)
//   Type1 arg1;
//   Type2 arg2;
//   Type3 arg3;
/*  ostringstream s;
  s << "void\n" << fClass->PerlName() << "::" << fName << "(";
  const unsigned int nArgsFixed = GetNRequiredArgs();
  vector<string> argNames;
  for (unsigned int iarg = 1; iarg <= nArgsFixed; ++iarg) {
    ostringstream argNS;
    argNS << "arg" << iarg;
    argNames.push_back(argNS.str());
    s << argNS.str();
    if (iarg < nArgsFixed)
      s << ", ";
  }
  if (fNArgsOpt != 0) {
    if (nArgsFixed != 0) s << ", ";
    s << "...";
  }
  s << ")\n";

  for (unsigned int iarg = 0; iarg < nArgsFixed; ++iarg) {
    const SOOTMethodArg& ma = fMethodArgs[iarg];
    s << "    " << ma.fType.ToStringForTypemap() << " " << argNames[iarg] << ";\n";
  }
*/
