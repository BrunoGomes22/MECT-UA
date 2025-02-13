#include <iostream> 
#include <opencv2/opencv.hpp> 
#include "BitStream.h"
#include "Golomb.h"
using namespace cv; 
using namespace std; 

vector<int> predictiveCoding(const Mat &image) {
    vector<int> predictionErrors;
    for (int i = 0; i < image.rows; ++i) {
        for (int j = 0; j < image.cols; ++j) {
            for (int c = 0; c < 3; ++c) { // process each RGB channel separately 
                int currentPixel = image.at<Vec3b>(i, j)[c];
                int predictedPixel = (j == 0) ? 0 : image.at<Vec3b>(i, j - 1)[c];
                int predictionError = currentPixel - predictedPixel;
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
                int predictedPixel = (j == 0) ? 0 : decodedImage.at<Vec3b>(i, j - 1)[c];
                int currentPixel = predictionErrors[index++] + predictedPixel;
                decodedImage.at<Vec3b>(i, j)[c] = currentPixel;
            }
        }
    }
    return decodedImage;
}

int findOptimalM(const vector<int> &predictionErrors) {
    double mean = 0.0;
    for (int error : predictionErrors) {
        mean += abs(error);
    }
    mean /= predictionErrors.size();

    int optimalM = round(mean);
    return max(1, optimalM); // Ensure m is at least 1
}

int main(int argc, char** argv) 
{   
	// read the image file
	Mat image = imread("imagefiles/airplane.ppm"); 

	// error Handling 
	if (image.empty()) { 
		cout << "Image File "
			<< "Not Found" << endl; 

		cin.get(); 
		return -1; 
	} 

	imshow("Original image", image); 

    // calculate the prediction errors (current pixel - predicted pixel)
    vector<int> predictionErrors = predictiveCoding(image);

    // find the optimal value of m
    int optimalM = findOptimalM(predictionErrors);
    cout << "Optimal m value: " << optimalM << endl;

    BitStream bitStreamEnc("encoded.bin", true);
    Golomb golombEncoder(optimalM, true);
    for (int error : predictionErrors) {
        golombEncoder.encode(error, bitStreamEnc);
    }
    bitStreamEnc.~BitStream();

    BitStream bitStreamDec("encoded.bin", false);
    Golomb golombDecoder(optimalM, true); 
    vector<int> decodedErrors;
    try{
        while (!bitStreamDec.eof()) {
            decodedErrors.push_back(golombDecoder.decode(bitStreamDec));
        }
    } catch (const std::ios_base::failure &e) {
            if (!bitStreamDec.eof()) {
                std::cerr << "Error reading encoded file: " << e.what() << std::endl;
            }
    }

    bitStreamDec.~BitStream();

    // reconstruct the image from the prediction errors
    Mat decodedImage = inversePredictiveCoding(decodedErrors, image.rows, image.cols);

    // display the decoded image
    imshow("Decoded Image", decodedImage);

    // save the decoded image
    imwrite("decoded_image.ppm", decodedImage);

    waitKey(0);

	return 0; 
}
