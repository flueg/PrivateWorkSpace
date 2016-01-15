#include <iostream>
#include <map>

using namespace std;

int main()
{
	map<string, int> mTest;
	map<string, int>::iterator it;
	mTest["a"] = 1;
	mTest["b"] = 2;
	mTest["c"] = 3;
	mTest["d"] = 4;
	mTest["e"] = 5;

	cout << "Before erasing ..." << endl;
	for(it = mTest.begin(); it != mTest.end(); ++it)
	{
		cout << it->second << endl;
	}

	int reCnt;
	reCnt = mTest.erase("c");
	cout << reCnt << " element(s) has/have been erased." << endl;
	reCnt = mTest.erase("f");
	cout << reCnt << " element(s) has/have been erased." << endl;

	cout << "After erasing ..." << endl;
	for(it = mTest.begin(); it != mTest.end(); ++it)
	{
		cout << it->second << endl;
	}
	return 0;
}

