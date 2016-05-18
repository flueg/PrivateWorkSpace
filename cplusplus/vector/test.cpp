#include <iostream>
#include <vector>
#include <iterator>
#include <string>

#define MAX(x, y) ((x) > (y) ? (x) : (y))
using namespace std;

typedef std::vector<int> VInt;
typedef VInt::iterator VIterator;

typedef std::vector<string> VString;
typedef VString::iterator VSIterator;


// This method will not delete all duplicated elements in vector.
void UniqueVector(VInt &v)
{
	for (VIterator i = v.begin(); i != v.end(); ++i)
	{
		cout << "i is: " << *i << endl;
		//if (*i == *(i+1)){
		if ((*i == 2) or (*i == 3)){
			cout << "vector size is: " << v.size() << endl;
			v.erase(i);
			cout << " vector size is: " << v.size() << endl;
		}
	}
}

void vectorInt()
{
	VInt v = {1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 5, 6};
	//VInt v;
	//v.push_back(1);
	//v.push_back(2);
	//v.push_back(2);
	//v.push_back(3);

	cout << "Vector has:" << endl;
	for (VIterator i = v.begin(); i != v.end(); ++i)
	{
		cout << *i << " ";
	}
	cout <<endl;

	for (VInt::iterator itor = v.begin(); itor != v.end(); ++itor)
	{
		cout << "iterate in :" << (itor - v.begin())<< endl;
		if ((2 == *itor) or (3 == *itor))
		{
		cout << "duplicated element in :" << (itor - v.begin())<< endl;
			 v.erase(itor);
		//if (3 == *itor) v.erase(itor);
		--itor;
		}
	}

	cout << "Vector without duplicated elements:" << endl;
	for (VIterator i = v.begin(); i != v.end(); ++i)
	{
		cout << *i << " ";
	}
	cout <<endl;
}

void vectorString()
{
	VString vstr = {"21:1005964138,1005964139,1005964140", "222:1005964138"};
	for (VSIterator it = vstr.begin(); it != vstr.end(); ++it)
	{
		string ss = *it;
		size_t pos = (*it).find(":");
		int op = atoi((*it).substr(0, pos).c_str());
		string rr = (*it).substr(pos+1);
		cout << op << " " << rr << endl;
		//cout << *it << endl;
	}
}
int main()
{
	//vectorInt();
	vectorString();
	cout << MAX(2,1) << "" << MAX(3,4) << endl;
	return 0;
}
