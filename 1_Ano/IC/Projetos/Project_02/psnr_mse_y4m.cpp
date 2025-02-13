#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>

using namespace std;

// Read a frame from a YUV4MPEG file (YUV 4:2:0 format)
bool readYFrame(ifstream &file, vector<uint8_t> &Y, int width, int height) {
    string frameHeader;
    if (!getline(file, frameHeader) || frameHeader != "FRAME") {
        return false; // End of file or missing frame header
    }
    file.read(reinterpret_cast<char*>(Y.data()), width * height); // Read Y plane
    file.seekg((width * height) / 2, ios::cur); // Skip U and V planes
    return !file.eof();
}

// Calculate MSE between two frames
double calculateMSE(const vector<uint8_t> &orig, const vector<uint8_t> &decoded) {
    double mse = 0.0;
    for (size_t i = 0; i < orig.size(); ++i) {
        double diff = orig[i] - decoded[i];
        mse += diff * diff;
    }
    return mse / orig.size();
}

// Calculate PSNR from MSE
double calculatePSNR(double mse, int maxPixelValue = 255) {
    return (mse == 0) ? 100.0 : 10.0 * log10((maxPixelValue * maxPixelValue) / mse);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        cerr << "Usage: " << argv[0] << " <original.y4m> <decoded.y4m>" << endl;
        return -1;
    }

    ifstream originalFile(argv[1], ios::binary);
    ifstream decodedFile(argv[2], ios::binary);
    if (!originalFile.is_open() || !decodedFile.is_open()) {
        cerr << "Error: Could not open input files!" << endl;
        return -1;
    }

    // Read YUV4MPEG headers
    string header1, header2;
    getline(originalFile, header1);
    getline(decodedFile, header2);
    if (header1 != header2) {
        cerr << "Error: Video files have different headers!" << endl;
        return -1;
    }

    // Extract video resolution
    int width = 0, height = 0;
    sscanf(header1.c_str(), "YUV4MPEG2 W%d H%d", &width, &height);
    if (width == 0 || height == 0) {
        cerr << "Error: Invalid video resolution!" << endl;
        return -1;
    }

    vector<uint8_t> Y_orig(width * height), Y_decoded(width * height);
    double totalMSE = 0.0;
    int frameCount = 0;

    while (readYFrame(originalFile, Y_orig, width, height) &&
           readYFrame(decodedFile, Y_decoded, width, height)) {
        double mse = calculateMSE(Y_orig, Y_decoded);
        totalMSE += mse;
        frameCount++;
    }

    if (frameCount == 0) {
        cerr << "Error: No frames read!" << endl;
        return -1;
    }

    double avgMSE = totalMSE / frameCount;
    double psnr = calculatePSNR(avgMSE);

    cout << "Frames Processed: " << frameCount << endl;
    cout << "Average MSE: " << avgMSE << endl;
    cout << "PSNR: " << psnr << " dB" << endl;

    return 0;
}
