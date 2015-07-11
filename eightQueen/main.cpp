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

//typedef struct Queen
//{
//	int number;
//	int diagonalX;
//	int disgonalY;
//} Queen;
//Queen queen[QUEEN_NUMBER + 1];

int compare(const void* i, const void* j)
{
	if (*(int*)i < *(int*)j) return -1;
	else if (*(int*)i == *(int*)j) return 0;
	else return 1;
}

// Successfully get a solution.
// Output the solution.
void succeed()
{
	std::cout << "Solution #" << totalSolution << ":" << std::endl;
	output << "Solution #" << totalSolution++ << ":" << std::endl;
	for (int i = 1; i <= QUEEN_NUMBER; i++)
	{
		std::cout << queen[i] << " ";
		output << queen[i] << " ";
	}
	std::cout << std::endl;
	output << std::endl;
}

// Test if we place Queen n in column queen[n] is approperiate.
bool sanityTest(int n)
{
	int diagonalX[n+1], diagonalY[n+1];
	for (int i = 1; i <= n; i++)
	{
		diagonalX[i] = queen[i] - i;
		diagonalY[i] = i + queen[i] - QUEEN_NUMBER;
	}

	qsort(&diagonalX[1], n, sizeof(int), &compare);
	qsort(&diagonalY[1], n, sizeof(int), &compare);

	for (int i = 1; i < n; i++)
		if (diagonalX[i] == diagonalX[i + 1] || diagonalY[i] == diagonalY[i + 1])
			return false;
	return true; 
}

/*
 * Function to recurringly pernutate queen solutions.
 */
void Permutation(int n)
{
	if (n > QUEEN_NUMBER)
	{
		succeed();
		return;
	}

	for (int i = 1; i <= QUEEN_NUMBER; i++)
	{	
		// Column i might already has a queen.
		if (isValid[i])
		{
			// Try to set Quenn n in column i.
			queen[n] = i;
			// Test if Queen n could be set in column i.
			if (sanityTest(n))
			{
				isValid[i] = false; // Since column i is used, mark it as ! invalid.
				Permutation(n + 1);
				isValid[i] = true; // Fall back
			}
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
