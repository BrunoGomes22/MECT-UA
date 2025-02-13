#include <fstream>
#include <string>
#include <vector>
#include <stdexcept>
#include <bitset>
#include "BitStream.h"


    // constructor: opens the file in binary mode for read or write
    BitStream::BitStream(const std::string &filename, bool writeMode) : byteBuffer(0), bitPos(0), writeMode(writeMode) {
        if (writeMode)
            fileStream.open(filename, std::ios::binary | std::ios::out);
        else
            fileStream.open(filename, std::ios::binary | std::ios::in);

        if (!fileStream) {
            throw std::ios_base::failure("Failed to open the file.");
        }
    }

    BitStream::~BitStream() {
        if (writeMode) {
            flushBuffer();
        }
        fileStream.close();
    }

    // writes a single bit to the file
    void BitStream::writeBit(bool bit) {
        byteBuffer = (byteBuffer << 1) | (bit ? 1 : 0);
        ++bitPos;

        if (bitPos == 8) {
            flushBuffer();
        }
    }

    // reads a single bit from the file
    bool BitStream::readBit() {
        if (bitPos == 0) {
            if (!fileStream.read(reinterpret_cast<char *>(&byteBuffer), 1)) {
                throw std::ios_base::failure("End of file reached.");
            }
            bitPos = 8;
        }
        bool bit = (byteBuffer >> (bitPos - 1)) & 1;
        --bitPos;
        return bit;
    }

    // writes an integer value represented by N bits to the file
    void BitStream::writeBits(uint64_t value, int n) {
        if (n <= 0 || n > 64) {
            throw std::invalid_argument("Number of bits must be between 1 and 64.");
        }
        for (int i = n - 1; i >= 0; --i) {
            writeBit((value >> i) & 1);
        }
    }

    // reads an integer value represented by N bits from the file
    uint64_t BitStream::readBits(int n) {
        if (n <= 0 || n > 64) {
            throw std::invalid_argument("Number of bits must be between 1 and 64.");
        }
        uint64_t value = 0;
        for (int i = 0; i < n; ++i) {
            value = (value << 1) | readBit();
        }
        return value;
    }

    // writes a string of characters to the file as a series of bits
    void BitStream::writeString(const std::string &str) {
        for (char ch : str) {
            writeBits(static_cast<uint8_t>(ch), 8);
        }
    }

    // reads a string of characters from the file as a series of bits
    std::string BitStream::readString(size_t length) {
        std::string result;
        for (size_t i = 0; i < length; ++i) {
            char ch = static_cast<char>(readBits(8));
            result += ch;
        }
        return result;
    }

    // flushes the buffer to the file when a byte is complete
    void BitStream::flushBuffer() {
        if (bitPos > 0) {
            byteBuffer <<= (8 - bitPos);
            fileStream.put(static_cast<char>(byteBuffer));
            byteBuffer = 0;
            bitPos = 0;
        }
    }

    // adds padding bits to the file to align to a byte boundary
    void BitStream::addPadding(uint64_t bitCount) {
        int paddingBits = (8 - (bitCount % 8)) % 8;
        for (int i = 0; i < paddingBits; ++i) {
            writeBit(0);
        }
    }

    // checks if the end of the file has been reached
    bool BitStream::eof() const {
        return fileStream.eof();
    }

    // moves the file pointer to a specific position
    void BitStream::seek(std::streampos position) {
        fileStream.clear(); // Clear any error flags
        fileStream.seekg(position, std::ios::beg);
        fileStream.seekp(position, std::ios::beg);
        byteBuffer = 0;
        bitPos = 0;
    }

