#include <iostream>
#include <vector>
#include <iterator>

typedef std::vector<int> VInt;
typedef VInt::iterator VIterator;

using namespace std;

// This method will not delete all duplicated elements in vector.
void UniqueVector(VInt &v)
{
	for (VIterator i = v.begin(); i != v.end() - 1; ++i)
	{
		cout << "i is: " << *i << endl;
		if (*i == *(i+1)){
			cout << "vector size is: " << v.size() << endl;
			v.erase(i);
			cout << " vector size is: " << v.size() << endl;
		}
	}
}

int main()
{
	VInt v = {1, 2, 2, 2, 3, 3, 3, 3, 3, 4, 5, 6};

	cout << "Vector has:" << endl;
	for (VIterator i = v.begin(); i != v.end(); ++i)
	{
		cout << *i << " ";
	}
	cout <<endl;

	UniqueVector(v);

	cout << "Vector without duplicated elements:" << endl;
	for (VIterator i = v.begin(); i != v.end(); ++i)
	{
		cout << *i << " ";
	}
	cout <<endl;

	return 0;
}
