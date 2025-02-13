#include <iostream>
#include <fstream>
#include "BitStream.h"

void encode(const std::string &inputTextFile, const std::string &outputBinaryFile) {
    std::ifstream inputFile(inputTextFile);
    if (!inputFile.is_open()) {
        std::cerr << "Error opening input file: " << inputTextFile << std::endl;
        return;
    }

    BitStream outputBitStream(outputBinaryFile, true); // open BitStream in write mode

    char ch;
    uint64_t bitCount = 0;

    // reserve space for the bit count header
    outputBitStream.writeBits(0, 64);

    while (inputFile.get(ch)) {
        if (ch == '0' || ch == '1') {
            outputBitStream.writeBit(ch == '1');
            bitCount++;
        }
    }

    inputFile.close();

    // add padding if necessary (this operation should be executed by the destructor)
    // do not forget to use this function after enconding the file
    outputBitStream.addPadding(bitCount);

    // write the actual bit count at the beginning of the file
    outputBitStream.seek(0);
    outputBitStream.writeBits(bitCount, 64);

    std::cout << "Encoding complete. Written bits to binary file: " << outputBinaryFile << std::endl;
    std::cout << "Total bits written: " << bitCount << std::endl;
}

int main() {
    std::string inputTextFile = "input.txt";
    std::string outputBinaryFile = "output.bin";

    encode(inputTextFile, outputBinaryFile);
    return 0;
}