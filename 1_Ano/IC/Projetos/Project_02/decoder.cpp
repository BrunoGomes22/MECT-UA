#include <iostream>
#include <fstream>
#include "BitStream.h"

void decode(const std::string &inputBinaryFile, const std::string &outputTextFile) {
    BitStream inputBitStream(inputBinaryFile, false);  // open BitStream in read mode
    std::ofstream outputFile(outputTextFile);
    if (!outputFile.is_open()) {
        std::cerr << "Error opening output file: " << outputTextFile << std::endl;
        return;
    }

    // read the bit count header
    uint64_t bitCount = inputBitStream.readBits(64);
    std::cout << "Total bits to read: " << bitCount << std::endl;
    uint64_t bitsRead = 0;

    while (bitsRead < bitCount) {
        try {
            bool bit = inputBitStream.readBit();
            outputFile.put(bit ? '1' : '0');
            bitsRead++;
        } catch (const std::ios_base::failure &e) {
            if (!inputBitStream.eof()) {
                std::cerr << "Error reading bit: " << e.what() << std::endl;
            }
            break;
        }
    }

    outputFile.close();

    std::cout << "Decoding complete. Written bits to text file: " << outputTextFile << std::endl;
}

int main() {
    std::string inputBinaryFile = "output.bin";
    std::string outputTextFile = "decoded.txt";

    decode(inputBinaryFile, outputTextFile);
    return 0;
}