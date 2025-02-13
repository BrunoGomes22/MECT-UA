#include <opencv2/opencv.hpp>
#include <iostream>
#include "BitStream.h"
#include "Golomb.h"

using namespace cv;
using namespace std;

vector<int> predictiveCoding( Mat &image, int quantization_level) {
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

Mat inversePredictiveCoding(const vector<int> &predictionErrors, int rows, int cols) {
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

int findOptimalM(const vector<int> &predictionErrors){
    double mean = 0.0;
    for(int error : predictionErrors){
        mean += abs(error);
    }
    mean /= predictionErrors.size();

    int optimalM = round(mean);
    return max(1,optimalM);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        cout << "Usage: " << argv[0] << " <video_file> <quantization_level>" << endl;
        return -1;
    }

    // Open the video file
    VideoCapture cap(argv[1]);
    int quantization_level = stoi(argv[2]);
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
    cap.open(argv[1]);
    if (!cap.isOpened()) {
        cout << "Error: Could not open video file." << endl;
        return -1;
    }

    cout << "Encoding video residuals..." << endl;

    // encode the residuals of each frame
    vector<int> allPredictionErrors;
    while (true) {
        cap >> frame; // capture a new frame
        if (frame.empty()) {
            break; // exit the loop if no more frames
        }

        vector<int> predictionErrors = predictiveCoding(frame,quantization_level);
        allPredictionErrors.insert(allPredictionErrors.end(), predictionErrors.begin(), predictionErrors.end());
    }

    // find the optimal m value
    int optimalM = findOptimalM(allPredictionErrors);
    cout << "Optimal m value: " << optimalM << endl;

    // Encode the video using the optimal m value
    BitStream bitStreamEnc("encoded_video.bin", true);
    Golomb golombEncoder(optimalM, true);

    for(int error : allPredictionErrors){
        golombEncoder.encode(error, bitStreamEnc);
    }

    // Release the video capture object
    cap.release();
    bitStreamEnc.~BitStream();
    destroyAllWindows();

    VideoCapture cap2(argv[1]);
    if(!cap2.isOpened()){
        cout << "Error: Could not open video file." << endl;
        return -1;
    }

    // open the BitStream for reading encoded data
    BitStream bitStreamDec("encoded_video.bin", false);
    Golomb golombDecoder(optimalM, true); // same golomb parameters as the encoder    

    FILE* yuvFile = fopen("decoded_video.y4m", "wb");
    if (!yuvFile) {
        cout << "Error: Could not open output file." << endl;
        return -1;
    }

     // Read the header from the original file
    ifstream originalFile(argv[1], ios::binary);
    string header;
    getline(originalFile, header);
    header += "\n";
    originalFile.close();

    // Write the header to the decoded file
    fwrite(header.c_str(), 1, header.size(), yuvFile);

    cout << "Decoding video residuals..." << endl;

    vector<Mat> decodedFrames;
    while(true){
        cap2 >> frame;
        if(frame.empty()){
            break;
        }

        vector<int> decodedErrors;
        try{
            while(decodedErrors.size() < frame.rows * frame.cols *3){
                decodedErrors.push_back(golombDecoder.decode(bitStreamDec)*quantization_level); // tentar fazer multiplicacao quantization level
            }
        } catch (const std::ios_base::failure &e) {
            if (!bitStreamDec.eof()) {
                std::cerr << "Error reading encoded file: " << e.what() << std::endl;
            }
        }

        Mat decodedImage = inversePredictiveCoding(decodedErrors, frame.rows, frame.cols);
        decodedFrames.push_back(decodedImage);

        // Write frame header
        fprintf(yuvFile, "FRAME\n");

        // Write YUV data
        for (int i = 0; i < decodedImage.rows; ++i) {
            fwrite(decodedImage.ptr(i), 1, decodedImage.cols * 3, yuvFile);
        }        
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