#ifndef BITSTREAM_H
#define BITSTREAM_H

#include <fstream>
#include <string>
#include <cstdint>

class BitStream {
public:
    // constructor
    BitStream(const std::string &filename, bool writeMode);
    
    // destructor
    ~BitStream();

    // core class methods
    void writeBit(bool bit);
    bool readBit();
    void writeBits(uint64_t value, int n);
    uint64_t readBits(int n);
    void writeString(const std::string &str);
    std::string readString(size_t length);

    // auxiliary methods
    void addPadding(uint64_t bitCount);
    bool eof() const;
    void seek(std::streampos pos);

private:
    void flushBuffer();  // Helper to flush byteBuffer if in write mode
    std::fstream fileStream; // file stream for reading/writing
    uint8_t byteBuffer = 0;  // Buffer for byte-level operations
    int bitPos = 0;          // Current position in the byte (0 to 7)
    bool writeMode;
};

#endif
