#include "classNameSpaceFunc.h"

void bar()
{
	std::string name = "normal function";
	std::cout << name << " bar is called." << std::endl;
}


void foo()
{
	std::string name = "normal function.";
	std::cout << name << "foo is called." << std::endl;
}

void CFoo::foo()
{
	std::cout << "class "<< this->name << " Member function foo is called." << std::endl;
}

void CFoo::callFunc()
{
	CFoo::foo();
	foo();
	bar();
	this->foo();
	CFoo().foo();
}

