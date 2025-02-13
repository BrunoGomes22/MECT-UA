#include <opencv2/opencv.hpp>
#include <iostream>
#include <vector>
#include <cmath>
#include <fstream>
#include "BitStream.h"
#include "Golomb.h"

using namespace cv;
using namespace std;

vector<int> predictiveCoding(Mat &image, int quantization_level) {
    vector<int> predictionErrors;
    for (int i = 0; i < image.rows; ++i) {
        for (int j = 0; j < image.cols; ++j) {
            for (int c = 0; c < 3; ++c) { // Process each channel separately
                int currentPixel = image.at<Vec3b>(i, j)[c];
                int predictedPixel;
                if (j == 0) {
                    predictedPixel = (i == 0) ? 0 : image.at<Vec3b>(i - 1, j)[c];
                } else {
                    predictedPixel = (i == 0) ? image.at<Vec3b>(i, j - 1)[c] : (image.at<Vec3b>(i, j - 1)[c] + image.at<Vec3b>(i - 1, j)[c]) / 2;
                }
                int predictionError = currentPixel - predictedPixel;
                predictionError = (predictionError / quantization_level);
                image.at<Vec3b>(i,j)[c] = predictedPixel + predictionError * quantization_level;
                predictionErrors.push_back(predictionError);
            }
        }
    }
    return predictionErrors;
}

Mat inversePredictiveCoding(const vector<int> &predictionErrors, int rows, int cols, int quantization_level) {
    Mat decodedImage(rows, cols, CV_8UC3);
    int index = 0;
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            for (int c = 0; c < 3; ++c) { // Process each channel separately
                int predictedPixel;
                if (j == 0) {
                    predictedPixel = (i == 0) ? 0 : decodedImage.at<Vec3b>(i - 1, j)[c];
                } else {
                    predictedPixel = (i == 0) ? decodedImage.at<Vec3b>(i, j - 1)[c] : (decodedImage.at<Vec3b>(i, j - 1)[c] + decodedImage.at<Vec3b>(i - 1, j)[c]) / 2;
                }
                int currentPixel = predictionErrors[index++] + predictedPixel;
                decodedImage.at<Vec3b>(i, j)[c] = currentPixel;
            }
        }
    }
    return decodedImage;
}

vector<int> motionEstimation(const Mat &currentFrame, const Mat &referenceFrame, int blockSize, int searchRange) {
    vector<int> motionVectors;
    for (int i = 0; i < currentFrame.rows; i += blockSize) {
        for (int j = 0; j < currentFrame.cols; j += blockSize) {
            int bestDx = 0, bestDy = 0;
            double bestError = DBL_MAX;
            for (int dx = -searchRange; dx <= searchRange; ++dx) {
                for (int dy = -searchRange; dy <= searchRange; ++dy) {
                    double error = 0.0;
                    for (int x = 0; x < blockSize; ++x) {
                        for (int y = 0; y < blockSize; ++y) {
                            int refX = i + x + dx;
                            int refY = j + y + dy;
                            if (refX >= 0 && refX < referenceFrame.rows && refY >= 0 && refY < referenceFrame.cols) {
                                Vec3b currentPixel = currentFrame.at<Vec3b>(i + x, j + y);
                                Vec3b referencePixel = referenceFrame.at<Vec3b>(refX, refY);
                                for (int c = 0; c < 3; ++c) {
                                    error += abs(currentPixel[c] - referencePixel[c]);
                                }
                            }
                        }
                    }
                    if (error < bestError) {
                        bestError = error;
                        bestDx = dx;
                        bestDy = dy;
                    }
                }
            }
            motionVectors.push_back(bestDx);
            motionVectors.push_back(bestDy);
        }
    }
    return motionVectors;
}

int findOptimalM(const vector<int> &predictionErrors) {
    double mean = 0.0;
    for (int error : predictionErrors) {
        mean += abs(error);
    }
    mean /= predictionErrors.size();

    // Estimate the optimal m value
    int optimalM = round(mean);
    return max(1, optimalM); // Ensure m is at least 1
}

int main(int argc, char** argv) {
    if (argc < 5) {
        cout << "Usage: " << argv[0] << " <video_file> <quantization_level> <iframe_interval> <block_size> <search_range>" << endl;
        return -1;
    }

    cout << "Arguments:" << endl;
    cout << "Video file: " << argv[1] << endl;
    cout << "Quantization level: " << argv[2] << endl;
    cout << "I-frame interval: " << argv[3] << endl;
    cout << "Block size: " << argv[4] << endl;
    cout << "Search range: " << argv[5] << endl;

    string videoFile = argv[1];
    int quantizationLevel = stoi(argv[2]);
    int iframeInterval = stoi(argv[3]);
    int blockSize = stoi(argv[4]);
    int searchRange = stoi(argv[5]);

    // Open the video file
    VideoCapture cap(videoFile);
    if (!cap.isOpened()) {
        cout << "Error: Could not open video file." << endl;
        return -1;
    }

    // Get the frame rate of the video
    double fps = cap.get(CAP_PROP_FPS);
    int delay = 1000 / fps;

    // Display the original video
    Mat frame;
    while (true) {
        cap >> frame; // Capture a new frame
        if (frame.empty()) {
            break; // Exit the loop if no more frames
        }

        imshow("Original Video", frame); // Display the frame

        // Wait for a key press for the duration of the frame rate
        if (waitKey(delay) >= 0) {
            break; // Exit the loop if any key is pressed
        }
    }

    destroyAllWindows();
    cap.release();

    // Reopen the video file for encoding
    cap.open(videoFile);
    if (!cap.isOpened()) {
        cout << "Error: Could not open video file." << endl;
        return -1;
    }

    // Open the BitStream for writing encoded data
    BitStream bitStreamEnc("encoded_video.bin", true);

    cout << "Encoding video residuals..." << endl;

    // Read and encode each frame
    vector<int> allPredictionErrors;
    int frameCount = 0;
    Mat referenceFrame;
    while (true) {
        cap >> frame; // Capture a new frame
        if (frame.empty()) {
            break; // Exit the loop if no more frames
        }

        if (frameCount % iframeInterval == 0) {
            // I-frame
            vector<int> predictionErrors = predictiveCoding(frame, quantizationLevel);
            allPredictionErrors.insert(allPredictionErrors.end(), predictionErrors.begin(), predictionErrors.end());

            // Find the optimal m value for the current frame
            int optimalM = findOptimalM(predictionErrors);

            // Encode the m value
            bitStreamEnc.writeBits(optimalM, 16); // Assuming m value fits in 16 bits

            // Encode the frame using the optimal m value
            Golomb golombEncoder(optimalM, true);
            for (int error : predictionErrors) {
                golombEncoder.encode(error, bitStreamEnc);
            }

            referenceFrame = frame.clone();
        } else {
            // P-frame
            vector<int> motionVectors = motionEstimation(frame, referenceFrame, blockSize, searchRange);
            for (int mv : motionVectors) {
                bitStreamEnc.writeBits(mv, 16); // Assuming motion vector fits in 16 bits
            }

            vector<int> predictionErrors = predictiveCoding(frame, quantizationLevel);
            allPredictionErrors.insert(allPredictionErrors.end(), predictionErrors.begin(), predictionErrors.end());

            // Find the optimal m value for the current frame
            int optimalM = findOptimalM(predictionErrors);

            // Encode the m value
            bitStreamEnc.writeBits(optimalM, 16); // Assuming m value fits in 16 bits

            // Encode the frame using the optimal m value
            Golomb golombEncoder(optimalM, true);
            for (int error : predictionErrors) {
                golombEncoder.encode(error, bitStreamEnc);
            }
        }

        frameCount++;
    }

    // Release the video capture object and close the BitStream
    cap.release();
    bitStreamEnc.~BitStream();

    // Decode the video
    VideoCapture cap2(videoFile);
    if (!cap2.isOpened()) {
        cout << "Error: Could not open video file." << endl;
        return -1;
    }

    // Open the BitStream for reading encoded data
    BitStream bitStreamDec("encoded_video.bin", false);

    // Open a file to write the raw YUV data
    FILE* yuvFile = fopen("decoded_video.y4m", "wb");
    if (!yuvFile) {
        cout << "Error: Could not open output file." << endl;
        return -1;
    }

    // Read the header from the original file
    ifstream originalFile(videoFile, ios::binary);
    string header;
    getline(originalFile, header);
    header += "\n";
    originalFile.close();

    // Write the header to the decoded file
    fwrite(header.c_str(), 1, header.size(), yuvFile);

    cout << "Decoding video residuals..." << endl;

    // Decode all frames and store them in a vector
    vector<Mat> decodedFrames;
    frameCount = 0;
    while (true) {
        cap2 >> frame; // Capture a new frame
        if (frame.empty()) {
            break; // Exit the loop if no more frames
        }

        if (frameCount % iframeInterval == 0) {
            // I-frame
            // Decode the m value
            int optimalM = bitStreamDec.readBits(16);

            // Decode the frame using the optimal m value
            Golomb golombDecoder(optimalM, true);
            vector<int> decodedErrors;
            try {
                while (decodedErrors.size() < frame.rows * frame.cols * 3) {
                    decodedErrors.push_back(golombDecoder.decode(bitStreamDec)*quantizationLevel);
                }
            } catch (const std::ios_base::failure &e) {
                if (!bitStreamDec.eof()) {
                    cerr << "Error reading encoded file: " << e.what() << endl;
                }
            }

            // Reconstruct the frame from the decoded prediction errors
            Mat decodedImage = inversePredictiveCoding(decodedErrors, frame.rows, frame.cols, quantizationLevel);
            decodedFrames.push_back(decodedImage);

            // Write frame header
            fprintf(yuvFile, "FRAME\n");

            // Write YUV data
            for (int i = 0; i < decodedImage.rows; ++i) {
                fwrite(decodedImage.ptr(i), 1, decodedImage.cols * 3, yuvFile);
            }

            referenceFrame = decodedImage.clone();
        } else {
            // P-frame
            vector<int> motionVectors;
            for (int i = 0; i < (frame.rows / blockSize) * (frame.cols / blockSize) * 2; ++i) {
                motionVectors.push_back(bitStreamDec.readBits(16));
            }

            // Decode the m value
            int optimalM = bitStreamDec.readBits(16);

            // Decode the frame using the optimal m value
            Golomb golombDecoder(optimalM, true);
            vector<int> decodedErrors;
            try {
                while (decodedErrors.size() < frame.rows * frame.cols * 3) {
                    decodedErrors.push_back(golombDecoder.decode(bitStreamDec)*quantizationLevel);
                }
            } catch (const std::ios_base::failure &e) {
                if (!bitStreamDec.eof()) {
                    cerr << "Error reading encoded file: " << e.what() << endl;
                }
            }

            // Reconstruct the frame from the decoded prediction errors
            Mat decodedImage = inversePredictiveCoding(decodedErrors, frame.rows, frame.cols, quantizationLevel);
            decodedFrames.push_back(decodedImage);

            // Write frame header
            fprintf(yuvFile, "FRAME\n");

            // Write YUV data
            for (int i = 0; i < decodedImage.rows; ++i) {
                fwrite(decodedImage.ptr(i), 1, decodedImage.cols * 3, yuvFile);
            }
        }

        frameCount++;
    }

    cap2.release();
    fclose(yuvFile);
    bitStreamDec.~BitStream();
    destroyAllWindows();

    cout << "Done." << endl;

    // Display the decoded frames at the correct frame rate
    for (const Mat &decodedFrame : decodedFrames) {
        imshow("Decoded Video", decodedFrame);
        if (waitKey(delay) >= 0) {
            break;
        }
    }

    return 0;
}