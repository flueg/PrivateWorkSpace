#include <stdio.h>

int ONES = 0x3fe;

int main(int argc, char* argv[])
{
	int len = sizeof(int);
	printf("lengh of int is %d \n", len);
	printf("one is %d \n", ONES);
	int bVal = ONES;
	int lbit = bVal & -bVal;
	printf("lowest bit of %d is [%d].\n", bVal, lbit);
	bVal &= ~lbit; 
	printf("unset the lowest bit result: [%d]\n", bVal);
	bVal |= lbit; 
	printf("reset the lowest bit result: [%d]\n", bVal);
	return 0;
}
