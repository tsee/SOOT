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
std::string
SOOTMethod::GenerateUnambiguousXSUB()
  const
{
  ostringstream s;
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

cout <<"\n";
cout << s.str();
cout <<"\n";
  return s.str();
}

