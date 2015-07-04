#include <iostream>
#include "sudoku.h"

int main(int argc, char *argv[])
{
    CSudoku sudoku = CSudoku("sudoku.input", "sudoku.output");
    sudoku.processSudoku();
    return 0;
}
