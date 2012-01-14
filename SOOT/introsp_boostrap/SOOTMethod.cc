#include "SOOTMethod.h"

#include <cstdlib>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <cmath>

#include <SOOTClass.h>

using namespace std;
using namespace SOOTbootstrap;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTMethod::FullyQualifiedPerlName()
  const
{
  return fClass->PerlName() + "::" + fName;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTMethod::GetInputTypemapStringFor(SOOTCppType& type, const std::string& cvarname,
                                     const std::string& inputvarstr, const std::string& indent)
  const
{
  ostringstream s;

  if (type.fSOOTTypes.count(SOOT::eTOBJECT) > 0) {
    s << indent << cvarname << " = (" << type.ToStringForTypemap() << ")SOOT::LobotomizeObject(aTHX_ " << inputvarstr << ");\n";
  }
  else if (type.fSOOTTypes.count(SOOT::eSTRING) > 0) {
    s << indent << cvarname << " = (" << type.ToStringForTypemap() << ")SvPV_nolen(" << inputvarstr << ");\n";
  }
  else if (type.fSOOTTypes.count(SOOT::eINTEGER) > 0) {
    if (type.fTypeName.substr(0,1) == "U"
        || (type.fTypeName.length() >= 8 && type.fTypeName.substr(0, 8) == "unsigned")) {
      s << indent << cvarname << " = (" << type.ToStringForTypemap() << ")SvUV(" << inputvarstr << ");\n";
    }
    else {
      s << indent << cvarname << " = (" << type.ToStringForTypemap() << ")SvIV(" << inputvarstr << ");\n";
    }
  }
  else if (type.fSOOTTypes.count(SOOT::eFLOAT) > 0) {
    s << indent << cvarname << " = (" << type.ToStringForTypemap() << ")SvNV(" << inputvarstr << ");\n";
  }
  else {
    cout << "WEEEH UNHANDLED TYPE IN GetInputTypemapStringFor()!" << endl;
    s << "WEEEH UNHANDLED TYPE IN GetInputTypemapStringFor()!" << endl;
  }

  return s.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTMethod::GetInputTypemapStringFor(SOOTCppType& type, const std::string& cvarname,
                                     const unsigned int stackargno, const std::string& indent)
  const
{
  ostringstream s;
  s << "ST(" << stackargno << ")";
  return GetInputTypemapStringFor(type, cvarname, s.str(), indent);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
static string
S_MakeArgumentNameList(vector< pair< SOOTMethodArg*, string > >& args, bool withType = false)
{
  ostringstream s;
  const unsigned int n = args.size();
  for (unsigned int i = 0; i < n; ++i) {
    pair< SOOTMethodArg*, string>& arg = args[i];
    if (withType)
      s << arg.first->fType.ToStringForTypemap() << " ";
    s << arg.second;
    if (i < n-1)
      s << ", ";
  }
  return s.str();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
std::string
SOOTMethod::GenerateUnambiguousXSUB()
{
  string className = fClass->fName;
  const string fullFuncName = FullyQualifiedPerlName();

  ostringstream s;
  s << "void\n" << fullFuncName << "(arg0, ...)\n";

  ostringstream preInit;
  ostringstream ppCode;

  string indent(4, ' ');

  const unsigned int nArgsFixed = GetNRequiredArgs();
  vector< pair< SOOTMethodArg*, string > > argNames;
  for (unsigned int iarg = 0; iarg < fNArgsTotal; ++iarg) {
    ostringstream argNS;
    argNS << "arg" << iarg+1;
    argNames.push_back( pair<SOOTMethodArg*, string>(&(fMethodArgs[iarg]), argNS.str()) );
  }

  // generate code to check the number of parameters
  ppCode << indent;
  if (fNArgsOpt == 0)
    ppCode << "if (items != " << fNArgsTotal+1 << ")\n"; // +1 for invocant
  else
    ppCode << "if (items < " << nArgsFixed+1 << " || items > " << fNArgsTotal+1 << ")\n";
  string argListWithTypes = S_MakeArgumentNameList(argNames, true);
  ppCode << indent << "  croak(\"Usage: " << fullFuncName
         << "(" << className << "* object"
         << (argListWithTypes == "" ? string("") : string(", ")+argListWithTypes)
         << ")\");\n";

  // Generate parameter declarations
  // Invocant first
  if (fIsStatic)
    preInit << indent << "char * arg0;\n";
  else
    preInit << indent << className << " * arg0;\n";

  for (unsigned int ip = 0; ip < fNArgsTotal; ++ip) {
    pair<SOOTMethodArg*, string>& argN = argNames[ip];
    preInit << "    " << argN.first->fType.ToStringForTypemap() << " " << argN.second;
    if (argN.first->fDefaultValue != "")
      preInit << " = " << argN.first->fDefaultValue;
    preInit << ";\n";
  }

  // declare retval
  preInit << "    " << fReturnType << " retval;\n";

  // Generate input type mapping
  // invocant first
  indent = string(4, ' ');
  SOOTCppType classType = fClass->MakeType();
  ppCode << GetInputTypemapStringFor( classType, string("arg0"), (unsigned int)0, indent );
  // ordinary req parameters later
  for (unsigned int ip = 0; ip < nArgsFixed; ++ip) {
    pair<SOOTMethodArg*, string>& argN = argNames[ip];

    ppCode << GetInputTypemapStringFor( argN.first->fType, argN.second, ip+1, indent );
  }

  // optional params
  if (fNArgsTotal != 0) {

    if (fNArgsOpt != 0)
      ppCode << indent << "switch (items) {\n";

    string subindent = string(10, ' ');
    for (unsigned int ip = fNArgsTotal; ip > nArgsFixed; --ip) {
      pair<SOOTMethodArg*, string>& argN = argNames[ip-1];

      ppCode << indent << "case " << ip+1 << ": {\n" // +1 for the invocant
             << GetInputTypemapStringFor( argN.first->fType, argN.second, ip, subindent )
             << indent << "  }\n";
    }

    if (fNArgsOpt != 0) {
      ppCode << indent << "case " << nArgsFixed+1 << ":\n"
             << indent << "  break;\n"
             << indent << "default:\n"
             << indent << "  croak(\"This should never happen! SOOT bug!\");\n"
             << indent << "  break;\n"
             << indent << "}\n";
    }
  } // end if any parameters

  // Now, generate the actual call
  ppCode << indent << "try {\n";
  {
    string indent(8, ' ');
    // FIXME needs if()else for static/instance
    ppCode << indent << "retval = arg0->" << fName << "(" << S_MakeArgumentNameList(argNames) << ");\n";
  }

  // FIXME free memory on exception?
  ppCode << indent << "}\n"
         << indent << "catch (std::exception& e) {\n"
         << indent << "  croak(\"Caught C++ exception of type or derived from 'std::exception': %s\", e.what());\n"
         << indent << "}\n"
         << indent << "catch (...) {\n"
         << indent << "  croak(\"Caught C++ exception of unknown type\");\n"
         << indent << "}\n";

  // FIXME free memory?



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
