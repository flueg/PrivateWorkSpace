//
//  sukudo.cpp
//  sudoku
//
//  Created by Flueg H.G. Lau on 6/28/15.
//  Copyright (c) 2015 Flueg H.G. Lau. All rights reserved.
//
#include "sudoku.h"
#include <stdio.h>
#include <fcntl.h>
#include <exception>
#include <iostream>


void CSudoku::setBit(int index, int bitVal)
{
    //assert(val <= 0);
    
    row[rowNumOfGrid[index]] |= bitVal;
    col[colNumOfGrid[index]] |= bitVal;
    block[blockNumOfGrid[index]] |= bitVal;
}

void CSudoku::removeBit(int index, int bitVal)
{
    //assert(val <= 0);
    
    row[rowNumOfGrid[index]] &= ~bitVal;
    col[colNumOfGrid[index]] &= ~bitVal;
    block[blockNumOfGrid[index]] &= ~bitVal;
}

void CSudoku::initSudoku()
{
    // We have 81 (from 0 to 80) grids in a sudoku square. Let's remembers the row number,
    // column numbers and block numbers of all grids.
    int i, j, grid;
    for (i = 0; i < 9; i++)
        for (j = 0; j < 9; j++) {
            grid = 9 * i + j;
            rowNumOfGrid[grid] = i;
            colNumOfGrid[grid] = j;
            blockNumOfGrid[grid] = (i / 3) * 3 + ( j / 3);
        }
}

void CSudoku::settleFixedGrid(int cIndex, int nIndex)
{
    int temp = processSequences[nIndex];
    processSequences[nIndex] = processSequences[cIndex];
    processSequences[cIndex] = temp;
}

void CSudoku::setSudokuGrid(int i, int j, int val)
{
    int index = 9 * i + j;
    int valBit = 1 << val;
    sudokuSolution[index] = valBit;
    //std::cout << "set val: " << valBit << std::endl;
    removeBit(index, valBit);
    int nextSequce = currentSequenceIndex;
    while (nextSequce < 81 && processSequences[nextSequce] != index)
        nextSequce++;
    this->settleFixedGrid(this->currentSequenceIndex, nextSequce);

    // Let's move teh index forward to a unsettled grid.
    this->currentSequenceIndex++;
}

/**
 * Func to load sudoku input from file.
 *
 *   @return success/failure
 */
int CSudoku::getSudokuInput()
{
    const std::string filePath = this->getSudokuInputFile();
    char fMode[3] = {'r', '+', '\0'};
    FILE* fd = fopen(filePath.c_str(), fMode);
    if (fd == NULL)
    {
        std::cout << "errno: " << errno << std::endl;
        throw std::exception();
    }
    char line[80];
    int i = 0;
    while (fgets(line, sizeof(line), fd) != NULL)
    {
        std::cout << "get line: " << line << std::endl;
        for (int j = 0; j < 10; j++)
        {
            char ch = line[j];
            if (ch >= '1' && ch <= '9')
            {
                this->setSudokuGrid(i, j, ch - '0');
            }
        }
        ++i;
        // Only load one sudoku square in this version.
        if (i > 8) break;
    }
    fclose(fd);
    const std::string oFile = this->getSudokuOutputFile();
    fprintf(stdout, "Load data from %s:\n", filePath.c_str());
    this->printSolution(stdout);

    return 1;
}

void CSudoku::printSolution(FILE* fd)
{
    int i, j, valbit, val, index;
    char ch = '\0';
    
    index = 0;
    
    for (i = 0; i < 9; i++) {
        if (i % 3 == 0) putc('\n', fd);
        for (j = 0; j < 9; j++) {
            if (j % 3 == 0) putc(' ', fd);
            valbit = sudokuSolution[index++];
            if (valbit == 0) ch = '-';
            else {
                for (val = 1; val <= 9; val++)
                    if (valbit == (1 << val)) {
                        ch = '0' + val;
                        break;
                    }
            }
            putc(ch, fd);
        }
        putc ('\n', fd);
    }
}

// Func to dump sudoku resolution into local file.
int CSudoku::saveSudokuResolotion(int solutionCount)
{
    const std::string oFile = this->getSudokuOutputFile();
    char fMode[] = {'a', '+', '\0'};
    
    FILE* fd = fopen(oFile.c_str(), fMode);
    fprintf(fd, "Solution #%d:\n", solutionCount);
    printSolution(fd);
    fclose(fd);
    return 1;
}

void CSudoku::processSudoku(int currentIndex)
{
//    if (currentIndex == 0)
//        currentIndex = currentSequenceIndex;
    ++visitCount;
    ++stackLevelCount[currentIndex];
    
    if (currentIndex >= 81)
    {
        saveSudokuResolotion(stackLevelCount[80]);
        return;
    }

    int nextSequenceIndex = getNextGridIndex(currentIndex);
    this->settleFixedGrid(currentIndex, nextSequenceIndex);
    
    int index = processSequences[currentIndex];
    
    int possibleSolutionBit = this->getPossibleSolutionBits(index);
    while (possibleSolutionBit)
    {
        int valBit = this->unsetLowstBit(possibleSolutionBit);
        this->removeBit(index, valBit);
        sudokuSolution[index] = valBit;
   
        this->processSudoku(currentIndex + 1);
        
        this->setBit(index, valBit);
        sudokuSolution[index] = BLANK;
    }
    
    this->settleFixedGrid(currentIndex, nextSequenceIndex);
}

int CSudoku::getNextGridIndex(int currentIndex)
{
    int nextIndex, possibleSolutions;
    // As we know, we can have 9 possible solutions for a blank grid.
    int MINI_SOLUTION = 100;

    // Accelerate the speech.
    //for (int i = currentSequenceIndex; i < 81; i++)
    for (int i = currentIndex; i < 81; i++)
    {
        possibleSolutions = 0;
        int possibleSolutionBit = this->getPossibleSolutionBits(processSequences[i]);
        while (possibleSolutionBit)
        {
            ++possibleSolutions;
            // We don't care what the lowest bit is.
            this->unsetLowstBit(possibleSolutionBit);
        }
        
        // Avoid dead recusion, processSequences[i] != index.
        /*if (!possibleSolutions)
            continue;
        if (sudokuSolution[processSequences[i]] > 0) ++possibleSolutions;
        */
        if (possibleSolutions < MINI_SOLUTION)
        {
            MINI_SOLUTION = possibleSolutions;
            nextIndex = i;
        }
    }
    
    return nextIndex;
}
