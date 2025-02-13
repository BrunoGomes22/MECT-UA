# Part I - BitStream class

## How to test:
1. Compile encoder.cpp and decoder.cpp
```bash
g++ -o encoder encoder.cpp BitStream.cpp Golomb.cpp
g++ -o decoder decoder.cpp BitStream.cpp Golomb.cpp
```

2. Encode a file input.txt with the encoder (the code is hardcoded to encode files with name "input.txt")
```bash
./encoder
```

3. Decode the encoded binary file with the decoder
```bash
./decoder
```

# Part II - Golomb Coding

## How to test:
```bash

g++ -o test_golomb TestGolomb.cpp BitStream.cpp Golomb.cpp
./test_golomb
```

# Part III - Audio Encoding with Predictive Coding

## How to test:

```bash

g++ -o audio_codec audio_codec.cpp BitStream.cpp Golomb.cpp -lsfml-audio -lsfml-system

./audio_codec encode audiofiles/sample01.wav encoded.bin -lossy -p 1024	 
./audio_codec decode encoded.bin audiofiles/output.wav 

```
# Part IV - Image and Video Coding with Predictive Coding

## How to test the lossless image codec:
1. Compile lossless_img.cpp
```bash
g++ -Wall -o lossless_img lossless_img.cpp BitStream.cpp Golomb.cpp `pkg-config --cflags --libs opencv4`
```

2. Run the codec with the following command:
```bash
./lossless_img
```
The image file is hardcoded in the program, you have to change the file path in the code to test with other images.

## How to test the intra-frame codec:
1. Compile intraframe_codec.cpp
```bash
g++ -Wall -o intra_codec intraframe_codec.cpp BitStream.cpp Golomb.cpp `pkg-config --cflags --libs opencv4`
```

2. Run the codec with the following command:
```bash 
./intra_codec <video_file> <quantization_level>
```
Using a quantization level of 1 will result in a lossless compression.

## How to test the inter-frame codec:
1. Compile interframe_codec.cpp
```bash
g++ -Wall -o inter_codec interframe_codec.cpp BitStream.cpp Golomb.cpp `pkg-config --cflags --libs opencv4`
```

2. Run the codec with the following command:
```bash
./inter_codec <video_file> <quantization_level> <iframe_interval> <block_size> <search_range>
```
(this process may take a while, depending on the video file size)
