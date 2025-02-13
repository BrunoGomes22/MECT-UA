#include "Golomb.h"
#include <cmath>
#include <iostream>

using namespace std;

Golomb::Golomb(int m, bool interleave) : m(m), interleave(interleave) {}


int Golomb::mapToPositive(int value){
    if(interleave){
        return (value >= 0) ? (2 * value) : (-2 * value - 1);
    }else{
        return (value >= 0) ? (value << 1) : ((-value << 1) | 1);
    }
}


int Golomb::mapFromPositive(int value){
    if(interleave){
        return (value % 2 == 0) ? (value / 2) : -(value / 2) - 1;

    }else{
        return (value & 1) ? -(value >> 1) : (value >> 1);
    }
}



void Golomb::encode(int value, BitStream &bitStream) {
    int mappedValue = mapToPositive(value);
    int q = mappedValue / m;
    int r = mappedValue % m;

    // Unary code for quotient q
    for (int i = 0; i < q; i++) {
        bitStream.writeBit(1);
    }
    bitStream.writeBit(0); // Stop bit

    // special case: If m = 1, we don't need to encode r (it's always 0)
    if (m > 1) {
        int r_bits = std::max(1, static_cast<int>(std::ceil(std::log2(m))));
        bitStream.writeBits(r, r_bits);
    }
}


int Golomb::decode(BitStream &bitStream) {
    int q = 0;

    // read unary part (number of 1s until the stop bit)
    while (bitStream.readBit()) {
        ++q;
    }

    // special case: If m = 1, remainder is always 0
    int r = 0;
    if (m > 1) {
        int r_bits = std::max(1, static_cast<int>(std::ceil(std::log2(m))));
        r = bitStream.readBits(r_bits);
    }

    int mappedValue = q * m + r;
    return mapFromPositive(mappedValue);
}