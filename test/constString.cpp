#include <iostream>
#include <string>

#undef CONST_STRING
#define CONST_STRING(name, value) const std::string name(value)

#include "extConst.h"

using namespace std;

int main()
{
    cout << "Name: " << FLUEG << endl;
    //cout << "Name: " << LAU << endl;
    return 0;
}
