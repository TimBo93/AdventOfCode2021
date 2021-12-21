#define part2

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <chrono>

// HOST
uint8_t* lineToBuffer(const std::string& input, int& numElements);

uint8_t* compileImage(const std::vector<uint8_t*>& rows, const int& width, const int& height);
uint8_t* resizeImage(const uint8_t* data, const int& width, const int& height, int& newWidth, int& newHeight, uint8_t surrounding);

cudaError_t simulationOnCuda(uint8_t* resultImage, const uint8_t* imageBuffer, unsigned int overallWidth, unsigned int overallHeight, const uint8_t* algorithmBuffer, unsigned int algorithmLength);

// DEVICE
__device__ int getlookUpIndex(const int x, const int y, const int overallWidth) {
    return y * overallWidth + x;
}

__global__ void simulationKernel(uint8_t*result, const uint8_t *inputImage, const uint8_t *algorithm, const int overallWidth, const int overallHeight, const int threadOffset)
{
    int i = threadIdx.x + threadOffset;

    int x = i % (overallWidth - 2);
    int y = i / (overallWidth - 2);

    x = x + 1;
    y = y + 1;

    int lookUp =
        (1 << 8) * inputImage[getlookUpIndex(x - 1, y - 1, overallWidth)] + (1 << 7) * inputImage[getlookUpIndex(x, y - 1, overallWidth)] + (1 << 6) * inputImage[getlookUpIndex(x + 1, y - 1, overallWidth)] +
        (1 << 5) * inputImage[getlookUpIndex(x - 1, y    , overallWidth)] + (1 << 4) * inputImage[getlookUpIndex(x, y    , overallWidth)] + (1 << 3) * inputImage[getlookUpIndex(x + 1, y    , overallWidth)] +
        (1 << 2) * inputImage[getlookUpIndex(x - 1, y + 1, overallWidth)] + (1 << 1) * inputImage[getlookUpIndex(x, y + 1, overallWidth)] + (1 << 0) * inputImage[getlookUpIndex(x + 1, y + 1, overallWidth)]
        ;

    result[i] = algorithm[lookUp];
}

int main()
{

    std::ifstream fin;
    fin.open("input.txt");
    std::string line;
    std::getline(fin, line);

    int lenAlgorithm;
    uint8_t* algorithm = lineToBuffer(line, lenAlgorithm);
    std::getline(fin, line);

    int imageWidth;
    int imageHeight = 0;
    int numIterations = 2;
    std::vector<uint8_t*> rows;

    while (std::getline(fin, line)) {
        uint8_t* row = lineToBuffer(line, imageWidth);
        imageHeight++;
        rows.push_back(row);
    }
    
    auto start = std::chrono::high_resolution_clock::now();

    uint8_t surrounding = 0;
    uint8_t* resultBuffer = compileImage(rows, imageWidth, imageHeight);
    
    int currentWidth = imageWidth, currentHeight = imageHeight;
    int newWidth, newHeight;
    cudaError_t cudaStatus;

#ifdef part1
    for (int i = 0; i < 2; i++)
#else
    for (int i = 0; i < 50; i++)
#endif
    {
        uint8_t* inputBuffer = resizeImage(resultBuffer, currentWidth, currentHeight, newWidth, newHeight, surrounding);
        
        if (algorithm[0] == 1) {
            // enable alternating mode
            surrounding = 1 - surrounding;
        }

        free(resultBuffer);

        resultBuffer = (uint8_t*)malloc((newWidth-2) * (newHeight-2) * sizeof(uint8_t));

        // call cuda
        cudaStatus = simulationOnCuda(resultBuffer, inputBuffer, newWidth, newHeight, algorithm, lenAlgorithm);
        if (cudaStatus != cudaSuccess) {
            fprintf(stderr, "addWithCuda failed!");
            return 1;
        }

        currentWidth = newWidth - 2;
        currentHeight = newHeight - 2;

        free(inputBuffer);

        //std::cout << "===============================" << std::endl;
        /*for (int y = 0; y < currentWidth; y++) {
            for (int x = 0; x < currentHeight; x++) {
                int val = resultBuffer[y * currentWidth + x];
                switch (val) {
                case 0:
                    std::cout.put('.');
                    break;
                case 1:
                    std::cout.put('#');
                    break;
                case 255:
                    std::cout.put('~');
                    break;
                default:
                    std::cout.put('?');
                }
            }
            std::cout.put('\n');
        }*/
    }

    int sumLit = 0;
    for (int y = 0; y < currentHeight; y++) {
        for (int x = 0; x < currentWidth; x++) {
            if (resultBuffer[y * currentWidth + x] > 0) {
                sumLit++;
            }
        }
    }

    auto finish = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = finish - start;

    std::cout << "lit points " << sumLit << std::endl;
    std::cout << "needed " << elapsed.count() << "s" << std::endl;

    free(resultBuffer);

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    cudaStatus = cudaDeviceReset();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceReset failed!");
        return 1;
    }

    return 0;
}

// Invoke CUDA
cudaError_t simulationOnCuda(uint8_t* resultImage, const uint8_t* imageBuffer, unsigned int imageBufferWidth, unsigned int imageBufferHeight, const uint8_t* algorithmBuffer, unsigned int algorithmLength)
{
    const int imageBufferSize = imageBufferWidth * imageBufferHeight * sizeof(uint8_t);
    const int resultImageSize = (imageBufferWidth-2) * (imageBufferHeight-2) * sizeof(uint8_t);
    const int algorithmBufferSize = algorithmLength * sizeof(uint8_t);

    uint8_t* dev_resultImage = 0;
    uint8_t* dev_inputImage = 0;
    uint8_t* dev_algorithm = 0;

    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)
    // Allocate Result-Buffer
    cudaStatus = cudaMalloc((void**)&dev_resultImage, resultImageSize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Allocate Input-Image
    cudaStatus = cudaMalloc((void**)&dev_inputImage, imageBufferSize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Allocate Algorithm-Buffer
    cudaStatus = cudaMalloc((void**)&dev_algorithm, algorithmBufferSize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input Input-Image from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_inputImage, imageBuffer, imageBufferSize, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Copy input Algorithm-Buffer from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_algorithm, algorithmBuffer, algorithmBufferSize, cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    int numExecutions = (imageBufferWidth - 2) * (imageBufferHeight - 2);
    int size = 1024;  // If your GPU does not support as many threads, please change it here.
    int threadOffset = 0;

    // Launch a kernel on the GPU with one thread for each element.
    // because we may have more items than #size threads, we need to split them.
    while (threadOffset < numExecutions) {
        simulationKernel <<<1, size>>> (dev_resultImage, dev_inputImage, dev_algorithm, imageBufferWidth, imageBufferHeight, threadOffset);
        threadOffset += size;
    }

    // Check for any errors launching the kernel
    cudaStatus = cudaGetLastError();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "simulationKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
        goto Error;
    }
    
    // cudaDeviceSynchronize waits for the kernel to finish, and returns
    // any errors encountered during the launch.
    cudaStatus = cudaDeviceSynchronize();
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching simulationKernel!\n", cudaStatus);
        goto Error;
    }

    // Copy output vector from GPU buffer to host memory.
    cudaStatus = cudaMemcpy(resultImage, dev_resultImage, resultImageSize, cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_resultImage);
    cudaFree(dev_inputImage);
    cudaFree(dev_algorithm);
    
    return cudaStatus;
}

uint8_t* lineToBuffer(const std::string& input, int& numElements)
{
    numElements = input.length();

    uint8_t* buffer = (uint8_t*) malloc(input.length() * sizeof(uint8_t));
    for (int i = 0; i < numElements; i++) {
        buffer[i] = input.at(i) == '#' ? 1 : 0;
    }

    return buffer;
}

uint8_t* compileImage(const std::vector<uint8_t*>& rows, const int& width, const int& height)
{
    int numElements = width * height;

    uint8_t* buffer = (uint8_t*)malloc(numElements * sizeof(uint8_t));

    for (int y = 0; y < width; y++) {
        for (int x = 0; x < height; x++) {
            int target = y * width + x;
            buffer[target] = rows.at(y)[x];
        }
    }

    return buffer;
}

uint8_t* resizeImage(const uint8_t* data, const int& width, const int& height, int& newWidth, int& newHeight, uint8_t surrounding)
{
    int offset = 2;
    newWidth = width + 2 * offset;
    newHeight = height + 2 * offset;
    int numElements = newWidth * newHeight;

    uint8_t* buffer = (uint8_t*)malloc(numElements * sizeof(uint8_t));

    for (int y = 0; y < newWidth; y++) {
        for (int x = 0; x < newHeight; x++) {

            int target = y * newWidth + x;

            if (x < offset || y < offset || x + offset >= newWidth || y + offset >= newHeight) {
                buffer[target] = surrounding;
            }
            else {
                int oldPos = (y-offset) * width + (x-offset);
                buffer[target] = data[oldPos];
            }
        }
    }

    return buffer;
}