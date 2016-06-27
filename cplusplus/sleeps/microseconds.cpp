#include <iostream>
#include <unistd.h>

using namespace std;

int main()
{
	int i = 0;
	while (true)
	{
		cout << i++ << endl;
		usleep(10 * 1000);
	}
	return 0;
}
