#include <SFML/Audio.hpp>
#include <iostream>
#include <vector>
#include <cmath>
#include <numeric>
#include "BitStream.h"
#include "Golomb.h"

using namespace std;

// get m based on residuals
int calculateOptimalM(const vector<int>& residuals) {
    double mean = 0.0;
    for (int residual : residuals) {
        mean += abs(residual);
    }
    mean /= residuals.size();

    if (mean == 0) {
        return 1;
    }

    return pow(2, ceil(log2(mean + 1))); 
}

// get residuals
vector<int> calculateResiduals(const vector<sf::Int16>& audioSamples, int numChannels) {
    vector<int> residuals(audioSamples.size());
    for (int ch = 0; ch < numChannels; ++ch) {
        residuals[ch] = audioSamples[ch];
        for (size_t i = ch + numChannels; i < audioSamples.size(); i += numChannels) {
            residuals[i] = audioSamples[i] - audioSamples[i - numChannels];
        }
    }
    return residuals;
}

// quantize residuals for lossy
vector<int> quantizeResiduals(const vector<int>& residuals, int quantizationLevel) {
    vector<int> quantizedResiduals(residuals.size());
    for (size_t i = 0; i < residuals.size(); ++i) {
        quantizedResiduals[i] = round(residuals[i] / double(quantizationLevel)) * quantizationLevel;
    }
    return quantizedResiduals;
}

// get audio from residuals
vector<sf::Int16> reconstructAudioSamples(const vector<int>& residuals, int numChannels) {
    vector<sf::Int16> audioSamples(residuals.size());
    for (int ch = 0; ch < numChannels; ++ch) {
        audioSamples[ch] = residuals[ch];
        for (size_t i = ch + numChannels; i < residuals.size(); i += numChannels) {
            audioSamples[i] = residuals[i] + audioSamples[i - numChannels];
        }
    }
    return audioSamples;
}


void encodeAudio(const string& inputFile, const string& outputFile,bool lossy, int quantizationLevel) {
    sf::SoundBuffer soundBuffer;
    if (!soundBuffer.loadFromFile(inputFile)) {
        cerr << "Error loading file: " << inputFile << endl;
        return;
    }

    // get audio data
    const sf::Int16* audioData = soundBuffer.getSamples();
    size_t totalSamples = soundBuffer.getSampleCount();
    int numChannels = soundBuffer.getChannelCount();
    int sampleRate = soundBuffer.getSampleRate();
    vector<sf::Int16> audioSamples(audioData, audioData + totalSamples);

    vector<int> residuals = calculateResiduals(audioSamples, numChannels);

    if(lossy){
        residuals = quantizeResiduals(residuals, quantizationLevel);
    }
    //custom m value
    int optimalM = calculateOptimalM(residuals);

    BitStream bitStream(outputFile, true);
    Golomb golombEncoder(optimalM, true);

    bitStream.writeBits(sampleRate, 32); // 32-bit integer for sample rate
    bitStream.writeBits(numChannels, 16); // 16-bit integer for channel count
    bitStream.writeBits(optimalM, 16);    // 16-bit integer for m
    bitStream.writeBits(lossy ? 1 : 0, 8); // 8-bit integer for lossy flag
    bitStream.writeBits(quantizationLevel, 16);

    // Encode residuals
    for (int residual : residuals) {
        golombEncoder.encode(residual, bitStream);
    }

    bitStream.addPadding(8); // last byte padding
}

void decodeAudio(const string& inputFile, const string& outputFile) {
    BitStream bitStream(inputFile, false);
    // Read metadata
    int sampleRate = static_cast<int>(bitStream.readBits(32)); // 32-bit integer for sample rate
    int numChannels = static_cast<int>(bitStream.readBits(16)); // 16-bit integer for channel count
    int optimalM = static_cast<int>(bitStream.readBits(16));    // 16-bit integer for m
    bool lossy = static_cast<int>(bitStream.readBits(8));
    int quantizationLevel = static_cast<int>(bitStream.readBits(16));

    Golomb golombDecoder(optimalM, true);
    vector<int> residuals;

    // decode residuals
    try {
        while (!bitStream.eof()) {
            residuals.push_back(golombDecoder.decode(bitStream));
        }
    } catch (const ios_base::failure& e) {
        if (!bitStream.eof()) {
            cerr << "Error reading encoded file: " << e.what() << endl;
        }
    }

    if (residuals.empty()) {
        cerr << "Error: No residuals found in the file." << endl;
        return;
    }

    vector<sf::Int16> audioSamples = reconstructAudioSamples(residuals, numChannels);

    // Create and save the audio buffer
    sf::SoundBuffer soundBuffer;
    if (!soundBuffer.loadFromSamples(audioSamples.data(), audioSamples.size(), numChannels, sampleRate)) {
        cerr << "Error creating sound buffer from samples" << endl;
        return;
    }

    if (!soundBuffer.saveToFile(outputFile)) {
        cerr << "Error saving file: " << outputFile << endl;
    }
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        cerr << "Usage: " << argv[0] << " <encode/decode> <input_file> <output_file> [-lossy -q quantization_level]" << endl;
        return -1;
    }

    string mode = argv[1];
    string inputFile = argv[2];
    string outputFile = argv[3];
    bool lossy = false;
    int quantizationLevel = 16;  // !!!!

    for (int i = 4; i < argc; ++i) {
        string arg = argv[i];
        if(arg == "-lossy"){
            lossy = true;
        } else if (arg == "-q") {
            if (i + 1 < argc) {
                quantizationLevel = stoi(argv[++i]);
            }
        }
    }

    if (mode == "encode") {
        encodeAudio(inputFile, outputFile, lossy, quantizationLevel);
    } else if (mode == "decode") {
        decodeAudio(inputFile, outputFile);
    } else {
        cerr << "Invalid mode: " << mode << endl;
        return -1;
    }

    return 0;
}