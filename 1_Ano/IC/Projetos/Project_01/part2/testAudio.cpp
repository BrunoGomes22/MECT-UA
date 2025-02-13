#include <SFML/Audio.hpp>
#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <cmath>


void displayInfo(const sf::SoundBuffer& buffer) {
    unsigned int sampleRate = buffer.getSampleRate();
    unsigned int channelCount = buffer.getChannelCount();
    sf::Time duration = buffer.getDuration();

    std::cout << "Sample Rate: " << sampleRate << " Hz" << std::endl;
    std::cout << "Channels: " << channelCount << std::endl;
    std::cout << "Duration: " << duration.asSeconds() << " seconds" << std::endl;
}

void saveSamplesToFile(const sf::SoundBuffer& buffer, const std::string& filename) {
    const sf::Int16* samples = buffer.getSamples();
    std::size_t sampleCount = buffer.getSampleCount();

    std::ofstream outFile(filename);
    for (std::size_t i = 0; i < sampleCount; ++i) {
        outFile << samples[i] << "\n";
    }
    outFile.close();
    std::cout << "Samples saved to " << filename << std::endl;
}

void saveQuantizedSamplesToFile(const std::vector<sf::Int16>& samples, const std::string& filename) {
    std::ofstream outFile(filename);
    for (const auto& sample : samples) {
        outFile << sample << "\n";
    }
    outFile.close();
    std::cout << "Quantized samples saved to " << filename << std::endl;
}

std::vector<sf::Int16> quantizeSamples(const sf::SoundBuffer& buffer, int bits) {
    const sf::Int16* samples = buffer.getSamples();
    std::size_t sampleCount = buffer.getSampleCount();
    std::vector<sf::Int16> quantizedSamples(sampleCount);

    int levels = std::pow(2, bits);
    int maxAmplitude = std::numeric_limits<sf::Int16>::max();
    int minAmplitude = std::numeric_limits<sf::Int16>::min();
    int stepSize = (maxAmplitude - minAmplitude) / (levels - 1);

    for (std::size_t i = 0; i < sampleCount; ++i) {
        int normalizedSample = samples[i] - minAmplitude;

        int quantizationLevel = std::round(static_cast<float>(normalizedSample) / stepSize);
        int quantizedValue = quantizationLevel * stepSize + minAmplitude;
        quantizedSamples[i] = static_cast<sf::Int16>(quantizedValue);
    }

    return quantizedSamples;
}

std::vector<sf::Int16> readSamplesFromFile(const std::string& filename) {
    std::vector<sf::Int16> samples;
    std::ifstream inFile(filename);
    sf::Int16 sample;
    while (inFile >> sample) {
        samples.push_back(sample);
    }
    inFile.close();
    return samples;
}

double calculateMSE(const std::vector<sf::Int16>& originalSamples, const std::vector<sf::Int16>& quantizedSamples) {
    double mse = 0.0;
    std::size_t sampleCount = originalSamples.size();
    for (std::size_t i = 0; i < sampleCount; ++i) {
        double diff = static_cast<double>(originalSamples[i]) - static_cast<double>(quantizedSamples[i]);
        mse += diff * diff;
    }
    mse /= sampleCount;
    return mse;
}


double calculateSNR(const std::vector<sf::Int16>& originalSamples, const std::vector<sf::Int16>& quantizedSamples) {
    double signalPower = 0.0;
    double noisePower = 0.0;
    std::size_t sampleCount = originalSamples.size();
    for (std::size_t i = 0; i < sampleCount; ++i) {
        double signal = static_cast<double>(originalSamples[i]);
        double noise = static_cast<double>(originalSamples[i]) - static_cast<double>(quantizedSamples[i]);
        signalPower += signal * signal;
        noisePower += noise * noise;
    }
    double snr = 10 * std::log10(signalPower / noisePower);
    return snr;
}

void plotWaveform(unsigned int sampleRate, const std::string& filename) {
    std::cout << "Running Python script to plot waveform..." << std::endl;
    std::string command = "python3 plot_waveform.py " + std::to_string(sampleRate) + " " + filename;
    int result = std::system(command.c_str());
    if (result != 0) {
        std::cerr << "Error running Python script. Exit code: " << result << std::endl;
    }
}

void plotHistogram(unsigned int sampleRate, const std::string& filename) {
    std::cout << "Running Python script to plot histogram..." << std::endl;
    std::string command = "python3 plot_histogram.py " + std::to_string(sampleRate) + " " + filename;
    int result = std::system(command.c_str());
    if (result != 0) {
        std::cerr << "Error running Python script. Exit code: " << result << std::endl;
    }
}

void plotWaveformComparison(unsigned int sampleRate, const std::string& originalFilename, const std::string& quantizedFilename) {
    std::cout << "Running Python script to plot waveform comparison..." << std::endl;
    std::string command = "python3 plot_waveform_comparison.py " + std::to_string(sampleRate) + " " + originalFilename + " " + quantizedFilename;
    int result = std::system(command.c_str());
    if (result != 0) {
        std::cerr << "Error running Python script. Exit code: " << result << std::endl;
    }
}

void quantize(unsigned int sampleRate, const std::string& filename, int bits) {
    std::cout << "Quantizing audio samples..." << std::endl;
    sf::SoundBuffer buffer;
    if (!buffer.loadFromFile("audiofiles/" + filename)) {
        std::cerr << "Error loading file: " << filename << std::endl;
        return;
    }

    std::string originalFilename = "original_" + filename + ".txt";
    saveSamplesToFile(buffer, originalFilename);

    std::vector<sf::Int16> quantizedSamples = quantizeSamples(buffer, bits);
    std::string quantizedFilename = "quantized_" + filename + ".txt";
    saveQuantizedSamplesToFile(quantizedSamples, quantizedFilename);

    std::vector<sf::Int16> originalSamples = readSamplesFromFile(originalFilename);
    double mse = calculateMSE(originalSamples, quantizedSamples);
    double snr = calculateSNR(originalSamples, quantizedSamples);
    std::cout << "MSE: " << mse << std::endl;
    std::cout << "SNR: " << snr << " dB" << std::endl;      
    
    plotWaveformComparison(sampleRate, originalFilename, quantizedFilename);
}

int main(int argc, char* argv[]) {
    if (argc < 4) {
        std::cerr << "Usage: " << argv[0] << " -f <audio_file_name1> <audio_file_name2> ... -i|-w|-h|-q <bits>" << std::endl;
        std::cerr << "  -i: Display basic info" << std::endl;
        std::cerr << "  -w: Display waveform" << std::endl;
        std::cerr << "  -h: Display histogram" << std::endl;
        std::cerr << "  -q: Quantize" << std::endl;
        return -1;
    }

    bool displayInfoFlag = false;
    bool plotWaveformFlag = false;
    bool plotHistogramFlag = false;
    bool quantizeFlag = false;
    int quantizeBits = 8; // Default quantization bits

    int i = 1;
    while (i < argc && std::string(argv[i]) != "-i" && std::string(argv[i]) != "-w" && std::string(argv[i]) != "-h" && std::string(argv[i]) != "-q") {
        ++i;
    }

    if (i == argc) {
        std::cerr << "No task specified. Use -i, -w, -h, or -q." << std::endl;
        return -1;
    }

    for (int j = i; j < argc; ++j) {
        if (std::string(argv[j]) == "-i") {
            displayInfoFlag = true;
        } else if (std::string(argv[j]) == "-w") {
            plotWaveformFlag = true;
        } else if (std::string(argv[j]) == "-h") {
            plotHistogramFlag = true;
        } else if (std::string(argv[j]) == "-q") {
            quantizeFlag = true;
            if (j + 1 < argc) {
                quantizeBits = std::stoi(argv[j + 1]);
                ++j;
            }
        }
    }

    for (int k = 2; k < i; ++k) {
        std::string filePath = argv[k];

        sf::SoundBuffer buffer;
        if (!buffer.loadFromFile("audiofiles/" + filePath)) {
            std::cerr << "Error loading file: " << filePath << std::endl;
            continue;
        }

        std::cout << "File: " << filePath << std::endl; // Print file name

        if (displayInfoFlag) {
            displayInfo(buffer);
        }
        if (plotWaveformFlag) {
            std::string samplesFile = "samples_" + filePath + ".txt";
            saveSamplesToFile(buffer, samplesFile);
            plotWaveform(buffer.getSampleRate(), samplesFile);
        }
        if (plotHistogramFlag) {
            std::string samplesFile = "samples_" + filePath + ".txt";
            saveSamplesToFile(buffer, samplesFile);
            plotHistogram(buffer.getSampleRate(), samplesFile);
        }
        if (quantizeFlag) {
            quantize(buffer.getSampleRate(), filePath, quantizeBits);
        }
    }

    return 0;
}