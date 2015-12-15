#include <iostream>
#include <string>
#include <vector>

using namespace std;

#define N9 100
/*
 * N1: (int&)a
 * N2: char[] and *char
 * N3: int *p
 * N4: const varable
 * N5: array, pointer comparation
 * N6: sizeof()
 * N7: Null member struct constructor.
 * N8: Vector array
 * N9: Convenience Constructor.
 */


// Though we declare str as an array here. But it still is a pointer pointing to the array passed in.
void UpperCase( char str[] ) // 将str 中的小写字母转换成大写字母  
{  
	//WARNING: sizeof on array function parameter will return size of 'char *' instead of 'char []'
     for( size_t i=0; i<sizeof(str)/sizeof(str[0]); ++i )  
     {  
         if( 'a'<=str[i] && str[i]<='z' )  
         {  
              str[i] -= ('a'-'A' );  
         }  
     }  
}  

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

    unsigned int const size1 = 2;  
    char str1[ size1 ];  
    unsigned int temp = 0;  
    cout << "please input the array size:" << endl;
    cin >> temp;  
    unsigned int const size2 = temp;  
    char str2[ size2 ];  
    return 0; 

#elif N5
	char str1[] = "abc";  
	char str2[] = "abc";  
	  
	const char str3[] = "abc";  
	const char str4[] = "abc";  
	  
	const char* str5 = "abc";  
	const char* str6 = "abc";  
	  
	string str7("abc");
	string str8("abc");

	cout << "str1: " << *str1 << endl;
	cout << "str2: " << *str2 << endl;
	//cout << "boolalpha" << ( str1==str2 ) << endl; // 输出什么？  
	//cout << "boolalpha" << ( str3==str4 ) << endl; // 输出什么？  
	cout << "str5: " << *str5 << endl;
	cout << "str6: " << *str6 << endl;
	cout << "boolalpha" << ( str5==str6 ) << endl; // 输出什么？  
	cout << "boolalpha" << ( str7==str8 ) << endl; // 输出什么？  

#elif N6
    char str[] = "aBcDe";  
  
    cout << "str字符长度为: " << sizeof(str)/sizeof(str[0]) << endl;  
  
    UpperCase(str);  
    cout << str << endl; 

#elif N7
struct Test  
{  
    Test(int ) { }  
    Test() { }  
    void fun() { }  
};  

    Test a(1);  
    a.fun();  
    //Test b();  // warning: empty parentheses interpreted as a function declaration [-Wvexing-parse]
    //We use "Test b" or "Test *b = new Test()" to call a default constructor.
    Test b;
    b.fun();  

    // error: incompatible operand types ('int' and 'const char *')
    //cout<< (true ? 1 : "0") <<endl;

#elif N8
    //vector array;  
    vector<int> array;  
  
    array.push_back( 1 );  
    array.push_back( 2 );  
    array.push_back( 3 );  
    //for( vector::size_type i=array.size()-1; i>=0; --i )    // 反向遍历array数组  
    //for( vector<int>::size_type i=array.size()-1; i >= 0; --i )    // warning: comparison of unsigned expression >= 0 is always true [-Wtautological-compare]
    for(vector<int>::iterator i = array.end() - 1; i >= array.begin(); --i)
    {  
        //cout << array[i] << endl;  
        cout << *i << endl;  
    }  
    return 0;  

#elif N9
struct CLS  
{  
    int m_i;  
    CLS(int i){
	cout << "Convenience Contructor invoked!" << endl;
	m_i = i;
    }  
    CLS(double i) {
	cout << "Let's truncate the value of double:" << i << endl;
	m_i = (int) i;
    }
    CLS()  
    {  
	cout << "Default Contructor invoked!" << endl;
        CLS(1);  // Here just declare another object, and might cause memery leak.
	// You can invoke the super class's constructor here, bug not yourselves'.
    }  
}; 

    CLS obj;  
    cout << "get the object value:" << endl;
    cout << obj.m_i << endl;  

    CLS obj1(10);
    cout << obj1.m_i << endl;  

    CLS obj2(5.10);
    cout << obj2.m_i << endl;  

#else
	std::cout << "Testing code not defined." << std::endl;
#endif

	return 0;
}
