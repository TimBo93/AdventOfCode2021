// Day 25.cpp : This file contains the 'main' function. Program execution begins and ends there.

#include <iostream>
#include <fstream>
#include <string>
#include <vector>

const uint8_t TILE_EMPTY = 0;
const uint8_t MOVE_RIGHT = 1;
const uint8_t MOVE_DOWN = 2;

// row wise
int getIndex(int x, int y, int width, int height) {
    return y * width + x;
}

uint8_t* readFile(const std::string& const path, int& const width, int& const height) {
    std::vector<std::string> fileContent;
    std::ifstream file(path);

    std::string str;
    while (std::getline(file, str)) {
        fileContent.push_back(str);
    }
    file.close();

    width = str.length();
    height = fileContent.size();

    uint8_t* buffer = new uint8_t[width * height];
    for (int y = 0;y < height; y++) {
        for (int x = 0; x < width; x++) {
            uint8_t value = 0;

            switch (fileContent[y][x]) {
            case '>':
                value = MOVE_RIGHT;
                break;
            case 'v':
                value = MOVE_DOWN;
                break;
            case '.':
                value = TILE_EMPTY;
                break;
            }

            buffer[getIndex(x, y, width, height)] = value;
        }
    }
    return buffer;
}

void kernel_right(int x, int y, int width, int height, const uint8_t* const inputBuffer, uint8_t* outputBuffer) {
    const int bufferIndex = getIndex(x, y, width, height);
    const uint8_t tile = inputBuffer[bufferIndex];

    if (tile == TILE_EMPTY) {
        int lookupLeftX = x - 1;
        if (lookupLeftX < 0) {
            lookupLeftX = width - 1;
        }
        const uint8_t tile_left = inputBuffer[getIndex(lookupLeftX, y, width, height)];

        if (tile_left == MOVE_RIGHT) {
            outputBuffer[bufferIndex] = MOVE_RIGHT;
            return;
        }
        else {
            outputBuffer[bufferIndex] = TILE_EMPTY;
            return;
        }
    }

    if (tile == MOVE_RIGHT) {
        int lookupRightX = x + 1;
        if (lookupRightX >= width) {
            lookupRightX = 0;
        }
        const uint8_t tile_right = inputBuffer[getIndex(lookupRightX, y, width, height)];

        if (tile_right == TILE_EMPTY) {
            outputBuffer[bufferIndex] = TILE_EMPTY;
            return;
        }
        else {
            outputBuffer[bufferIndex] = MOVE_RIGHT;
            return;
        }
    }

    outputBuffer[bufferIndex] = tile;
}

void kernel_down(int x, int y, int width, int height, const uint8_t* const inputBuffer, uint8_t* outputBuffer) {
    const int bufferIndex = getIndex(x, y, width, height);
    const uint8_t tile = inputBuffer[bufferIndex];

    if (tile == TILE_EMPTY) {
        int lookupUpY = y - 1;
        if (lookupUpY < 0) {
            lookupUpY = height - 1;
        }
        const uint8_t tile_top = inputBuffer[getIndex(x, lookupUpY, width, height)];

        if (tile_top == MOVE_DOWN) {
            outputBuffer[bufferIndex] = MOVE_DOWN;
            return;
        }
        else {
            outputBuffer[bufferIndex] = TILE_EMPTY;
            return;
        }
    }

    if (tile == MOVE_DOWN) {
        int lookupDownY = y + 1;
        if (lookupDownY >= height) {
            lookupDownY = 0;
        }
        const uint8_t tile_down = inputBuffer[getIndex(x, lookupDownY, width, height)];

        if (tile_down == TILE_EMPTY) {
            outputBuffer[bufferIndex] = TILE_EMPTY;
            return;
        }
        else {
            outputBuffer[bufferIndex] = MOVE_DOWN;
            return;
        }
    }

    outputBuffer[bufferIndex] = tile;
}

int main()
{
    int width, height;
    std::string path = "input.txt";
    
    uint8_t* inputBuffer = readFile(path, width, height);
    uint8_t* outputBufferStep1 = new uint8_t[width * height];
    uint8_t* outputBufferStep2 = new uint8_t[width * height];

    int numSteps = 0;

    while(true)
    {

#pragma omp parallel for
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                kernel_right(x, y, width, height, inputBuffer, outputBufferStep1);
            }
        }

#pragma omp parallel for
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                kernel_down(x, y, width, height, outputBufferStep1, outputBufferStep2);
            }
        }

        const int numItems = width * height;
        volatile bool cancellationToken = false;
        bool isEqual = true;

#pragma omp parallel for shared(cancellationToken, isEqual)
        for (int i = 0; i < numItems; i++) {
               
            if (cancellationToken) break;

            if (inputBuffer[i] != outputBufferStep2[i]) {
                cancellationToken = true;
                isEqual = false;
                break;
            }
        }

        if (isEqual) {
            break;
        }

        std::swap(inputBuffer, outputBufferStep2);
        numSteps++;
    }

    std::cout << "Required Steps: " << numSteps+1 << std::endl;
}