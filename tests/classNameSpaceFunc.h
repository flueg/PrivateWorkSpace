#include <iostream>

class CFoo
{
	std::string name;
public:
	CFoo()
	{
		// In cplusclus, a Constructor can not call another constructor. Since it mean to construct anoter class instance.
		// However in object-c2.0, constructor can call another constructor.
		//CFoo("cfoo");
		name = "cfoo";
	}
	CFoo(std::string name)
	{
		this->name = name;
		std::cout << "class " << name << " Constructor ..." << std::endl;
	}
	~CFoo()
	{
		std::cout << "class " << name << " Deconstructor ..." << std::endl;
	}
	void foo();
	void callFunc();
};
