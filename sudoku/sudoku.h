//
//  sukudo.h
//  sudoku
//
//  Created by Flueg H.G. Lau on 6/28/15.
//  Copyright (c) 2015 Flueg H.G. Lau. All rights reserved.
//

#ifndef __sudoku__sukudo__
#define __sudoku__sukudo__

#include <string>

const int BLANK = 0;
const int ONES = 0x3fe;     // Binary 0011 1111 1110, which means number 1 - 9 could be set the sudoku grid.

class CSudoku
{
private:
    const std::string inputFile;      // file contains the sudoku input
    const std::string outputFile;     // file to store the sudoku resolution.
    /*
     Use a 9-bit integer array to repersent the rows, cols and blocks in sukodu.
     e.g. row[0] - the first row of sudoku.
     */
    int row[9];
    int col[9];
    int block[9];
    
    // We have 81 (from 0 to 80) grids in a sudoku square. Let's store the row number,
    // column number and block number of all grids.
    int rowNumOfGrid[81], colNumOfGrid[81], blockNumOfGrid[81], stackLevelCount[81];
    
    // Store the sudoku input. Once initialized, do not change it outside the constructor.
    int processSequences[81];
    
    // Where we store a temple sudoku resolution.
    int sudokuSolution[81];
    
    public:
    
    int currentSequenceIndex, visitCount;

    CSudoku(std::string iFile = "sudoku.input", std::string oFile = "sudoku.output"):
    inputFile(iFile), outputFile(oFile), currentSequenceIndex(0), visitCount(0)
    {
        initSudoku();
    
        for (int i = 0; i < 9; i++)
            row[i] = col[i] = block[i] = ONES;
        
        // Assume that we will process the sudoku grids from 0 to 80
        for (int i = 0; i < 81; i++)
        {
            // Init the sudoku solution as BLANK as we have not worked it out.
            processSequences[i] = i;
            sudokuSolution[i] = BLANK;
            stackLevelCount[i] = 0;
        }

        getSudokuInput();
    };
    
    ~CSudoku()
    {
    }
    
    void setBit(int index, int val); // Set bit val to row[], col[] and block[];
    void setBit(int i, int j, int val)
    {
        setBit(9 * i + j, val);
    }
    void removeBit(int index, int val); // Unset bit val to row[], col[] and block[];
    void removeBit(int i, int j, int val)
    {
        removeBit(9 * i + j, val);
    }
    // If we want to place one number to the grid, we need to test if the number is
    // conflicted or not.
    int getPossibleSolutionBits(int index)
    {
        return row[rowNumOfGrid[index]] & col[colNumOfGrid[index]] & block[blockNumOfGrid[index]];
    }


    const std::string getSudokuInputFile() {return inputFile; }
    const std::string getSudokuOutputFile() {return outputFile; }
    
    void initSudoku();
    void setSudokuGrid(int i, int j, int val);
    // Func to load sudoku input from file.
    int getSudokuInput();
    
    // Func to dump sudoku resolution into local file.
    int saveSudokuResolotion(int solutionCount);
    
    // Func to generate sudoku resolution.
    void processSudoku(int currentIndex = 0);
    
    /* Get the next sudoku grid index to process.
     * Greedy Stategy:
     * Lets define:
     * possible solution - If we try to put a number to a blank grid, and no confict happends in correstponding
     *                     row, col and block. Let's call it a possible solution.
     * settled - We settled a possible solution to a sudoku grid.
     *
     * Every BLANK grid retains n possible solutions. We need to find out the least n (from 1 t0 9. Will not be 0).
     * Since every time a blank grid is settled, the possible solutions of rest blank girds will be reduced by 1,
     * we need to recalculte the possible solutions to get the least one. If many are found, use the first one.
     * We will calculate them every time instead of storing in memory.
     *
     * @param currentIndex: the current grid we are processing to.
     # @return index:       the next grid we should process to.
     */
    int getNextGridIndex(int currentIndex);
    
    /* if bit = 0x1010100, then this function will un set the least '1' bit to '0'. The result
       will be  0x1010000.
     */
    int unsetLowstBit(int& bit)
    {
        int lowestBit = bit & (-bit);
        bit &= ~lowestBit;
        return lowestBit;
    }
    
    void settleFixedGrid(int cIndex, int nIndex);
    void printSolution(FILE* fd);
};

#endif /* defined(__sudoku__sukudo__) */
