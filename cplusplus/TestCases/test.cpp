#include <iostream>
#include <string>

#define N4 100
/*
 * N1: (int&)a
 * N2: char[] and *char
 * N3: int *p
 * N4: const varable
 */

int main()
{
#ifdef N1
	float a = 1.0f;
	std::cout << "(int)a is:" << (int)a << std::endl;
	std::cout << "(int&)a is:" << (int&)a << std::endl;
	std::cout << "boolalpha" << ((int)a == (int&)a) << std::endl;

	float b = 0.0f;
	std::cout << "(int)b is:" << (int)b << std::endl;
	std::cout << "(int&)b is:" << (int&)b << std::endl;
	std::cout << "boolvalue " << ((int)b == (int&)b) << std::endl;
#elif N2
	char str1[] = "abc";
	const char* str2 = "abc";
	const char* str3 = str1;
	std::cout << "str1 is: " << str1 << std::endl;
	std::cout << "str2 is: " << str2 << std::endl;

	std::cout << "boolalpha" << (str1 == str2) << std::endl;

	std::cout << "*str1 is: " << *str1 << std::endl;
	std::cout << "*str2 is: " << *str2 << std::endl;
	std::cout << "boolalpha" << (*str1 == *str2) << std::endl;
	//std::cout << "&str1 is: " << &str1 << std::endl;
	//std::cout << "&str2 is: " << &str2 << std::endl;

	str1[0] = 'd';
	std::cout << "*str1 is: " << *str1 << std::endl;
	std::cout << "*str3 is: " << *str3 << std::endl;
	std::cout << "&str1 is: " << &str1 << std::endl;
	std::cout << "&str3 is: " << &str3 << std::endl;
	std::cout << "boolalpha" << (*str3 == *str3) << std::endl;

#elif N3
	int a = 20;
	int *p = &a;
	std::cout << "a is: " << a << std::endl;
	std::cout << "&a is: " << &a << std::endl;
	std::cout << "p is: " << p << std::endl;
	std::cout << "&p is: " << &p << std::endl;
	std::cout << "*p is: " << *p << std::endl;

#elif N4
	const int M = 10;
	int M1 = 10;
	int arr1[M] = {0};
	std::cout << "sizeof arr1: " << sizeof(arr1) << std::endl;

	//int arr2[M1] = {0};
	//std::cout << "sizeof arr2: " << sizeof(arr2) << std::endl;

	int arr3[N4] = {0};
	std::cout << "sizeof arr3: " << sizeof(arr3) << std::endl;

#else
	std::cout << "Testing code not defined." << std::endl;
#endif

	return 0;
}
