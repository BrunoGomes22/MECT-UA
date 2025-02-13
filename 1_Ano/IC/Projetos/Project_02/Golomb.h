#ifndef GOLOMB_H
#define GOLOMB_H

#include "BitStream.h"
#include <cmath>

class Golomb {
public:
    //constructor
    Golomb(int m, bool interleave = true);
    
    void encode(int value, BitStream &bitStream);
    int decode(BitStream &bitStream);


private:
    int m;
    bool interleave;

    int mapToPositive(int value);
    int mapFromPositive(int value);

};
#endif