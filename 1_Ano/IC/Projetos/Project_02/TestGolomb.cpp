#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include "BitStream.h"
#include "Golomb.h"

void testGolomb(const std::string &inputFile, const std::string &outputFile, int m, bool interleave){
    std::vector<int> integers;
    std::ifstream input(inputFile);
    if(!input.is_open()){
        std::cerr << "Error opening input file " << inputFile << std::endl;
        return;
    }

    int value;
    while(input >> value){
        integers.push_back(value);
    }
    input.close();
    //encode
    BitStream bitStream(outputFile, true);
    Golomb golombEncoder(m, interleave);
    for(const auto &num : integers) {
        golombEncoder.encode(num, bitStream);
    }
    //calling the deconstructor (might need to solve BitStream later)
    bitStream.~BitStream();
    //decode
    BitStream bitStreamIn(outputFile, false);
    std::vector<int> decodedIntegers;
    for (size_t i = 0; i < integers.size(); i++){
        int decodedValue = golombEncoder.decode(bitStreamIn);
        decodedIntegers.push_back(decodedValue);
    }

    //check if encoding and decoding match
    bool allMatch = true;
    for(size_t i = 0; i < integers.size(); i++){
        if(integers[i] != decodedIntegers[i]) {
            std::cout << "Mismatch at index " << i << ": original = " << integers[i] << ", decoded = " << decodedIntegers[i] << std::endl;
            allMatch = false;
        }
    }

    if(allMatch){
        std::cout << "All integers matched successfully. Golomb encoder & decoder verified" << std::endl;
    } else {
        std::cout << "There were mismatches in the encoding/decoding process" << std::endl;
    }
}

int main() { 
    std::string inputFile = "integers.txt";
    std::string outputFile = "encoded.bin";
    int m = 5;
    bool interleave = true;

    testGolomb(inputFile, outputFile, m, interleave);
    return 0;
}
