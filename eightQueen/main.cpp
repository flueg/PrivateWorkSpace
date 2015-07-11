#include <iostream>
#include <fstream>
#include <string>
#include <stdio.h>
#include <stdlib.h>

#define QUEEN_NUMBER 8
typedef int (*fun)(int i, int j);

bool isValid[QUEEN_NUMBER + 1];
int queen[QUEEN_NUMBER + 1];
int totalSolution = 1;
std::ofstream output;

int compare(const void* i, const void* j)
{
	if (*(int*)i < *(int*)j) return -1;
	else if (*(int*)i == *(int*)j) return 0;
	else return 1;
}

void succeed()
{
	std::cout << "Solution #" << totalSolution++ << ":" << std::endl;
	output << "Solution #" << totalSolution++ << ":" << std::endl;
	for (int i = 1; i <= QUEEN_NUMBER; i++)
	{
		std::cout << queen[i] << " ";
		output << queen[i] << " ";
	}
	std::cout << std::endl;
	output << std::endl;
}

bool sanityTest(int n)
{
	int diagonalX[n+1], diagonalY[n+1];
	for (int i = 1; i <= n; i++)
	{
		diagonalX[i] = queen[i] - i;
		diagonalY[i] = i + queen[i] - 8;
	}

	qsort(&diagonalX[1], n, sizeof(int), &compare);
	qsort(&diagonalY[1], n, sizeof(int), &compare);

	for (int i = 1; i < n; i++)
		if (diagonalX[i] == diagonalX[i + 1] || diagonalY[i] == diagonalY[i + 1])
			return false;

	//for (int i = 1; i <= n; i++)
	//	for (int j = 1; j < i; j++)
	//		if ((queen[i] - i) == (queen[j] - j) || (j - 8 + queen[j]) == (i - 8 + queen[i]))
	//			return false;
	return true; 
}

void Permutation(int n)
{
//for (int i = 1; i < n; i++)
//{
//	std::cout << queen[i] << " ";
//}
//std::cout << std::endl;

	if (n > QUEEN_NUMBER)
	{
		succeed();
		return;
	}

//std::cout << "n is: " << n << std::endl;
	for (int i = 1; i <= QUEEN_NUMBER; i++)
	{	
		if (isValid[i])
		{ 
			queen[n] = i;
//std::cout << "Process " << i << std::endl;
			if (sanityTest(n))
			{
				isValid[i] = false; // Since i is used, mark it as ! invalid.
				Permutation(n + 1);
				isValid[i] = true; // Fall back
			}
			//else std::cout<< " failed " << n;
		}
	}
}

int main(int argc, char* argv[])
{
	output.open("eightQueen.output", std::ofstream::out);
	// Initilization ...
	for (int i = 1; i <= QUEEN_NUMBER; i++ )
	{
		isValid[i] = true;
		queen[i] = 0;
	}

	Permutation(1);
	output.close();
	return 0;
}
