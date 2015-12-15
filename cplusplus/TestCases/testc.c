#include <stdio.h>

#define TEST2 100

int main()
{
#ifdef TEST1
	const int M = 10;
	int arr1[M] = {0};
	printf("sizeof arr1: %d\n", (int)sizeof(arr1));

	//int M1 = 10;
	//int arr2[M1] = {0};
	//printf("sizeof arr2 %d\n", (int)sizeof(arr2));

	int arr3[(int)TEST1] = {0};
	printf("sizeof arr3: %d\n", (int)sizeof(arr3));


#elif TEST2
	int  a[5] = {1, 2, 3, 4, 5};  
	int  *ptr = (int *)(&a+1);  
	printf("%d %d\n",*(a+1),*(ptr-1)); 

#else
	printf("Testing code not defined.\n");
#endif
	return 0;
}
