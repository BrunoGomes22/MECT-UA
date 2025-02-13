#include <opencv2/opencv.hpp>
#include <iostream>
#include <cmath>
#include <fstream>

double calculateMSE(const cv::Mat& image1, const cv::Mat& image2) {
    cv::Mat diff;
    cv::absdiff(image1, image2, diff);
    diff.convertTo(diff, CV_32F);
    diff = diff.mul(diff);
    cv::Scalar s = cv::sum(diff);
    double mse = (s[0] + s[1] + s[2]) / (image1.channels() * image1.total());
    return mse;
}

double calculatePSNR(double mse) {
    if (mse == 0) {
        return std::numeric_limits<double>::infinity();
    }
    double psnr = 10.0 * std::log10((255 * 255) / mse);
    return psnr;
}

cv::Mat loadAndConvertToGray(const std::string& imagePath) {
    cv::Mat image = cv::imread(imagePath, cv::IMREAD_COLOR);
    if (image.empty()) {
        std::cerr << "Error: Could not open or find the image: " << imagePath << std::endl;
        return cv::Mat();
    }

    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);
    return grayImage;
}

cv::Mat convertToGray(const cv::Mat& image) {
    cv::Mat grayImage;
    cv::cvtColor(image, grayImage, cv::COLOR_BGR2GRAY);
    return grayImage;
}

void showImageAndChannels(const cv::Mat& image) {
    std::vector<cv::Mat> channels;
    cv::split(image, channels);

    cv::imshow("Original Image", image);
    cv::imshow("Grayscale Image", convertToGray(image));
    cv::imshow("Red Channel", channels[2]);
    cv::imshow("Green Channel", channels[1]);
    cv::imshow("Blue Channel", channels[0]);

    cv::waitKey(0);
}

void saveHistogramData(const cv::Mat& grayImage, const std::string& filename) {
    int histSize = 256;
    float range[] = { 0, 256 };
    const float* histRange = { range };

    cv::Mat hist;
    cv::calcHist(&grayImage, 1, 0, cv::Mat(), hist, 1, &histSize, &histRange);

    std::ofstream outFile(filename);
    for (int i = 0; i < histSize; ++i) {
        outFile << i << "," << hist.at<float>(i) << "\n";
    }
    outFile.close();
}

void applyGaussianBlur(const cv::Mat& image, int kernelSize) {
    if (kernelSize <= 0 || kernelSize % 2 == 0) {
        std::cerr << "Error: Kernel size must be a positive odd integer." << std::endl;
        return;
    }

    cv::Mat blurredImage;
    cv::GaussianBlur(image, blurredImage, cv::Size(kernelSize, kernelSize), 0);

    cv::imshow("Original Image", image);
    cv::imshow("Blurred Image", blurredImage);
    cv::waitKey(0);
}

cv::Mat quantizeImage(const cv::Mat& grayImage, int levels) {
    cv::Mat quantizedImage = grayImage.clone();
    int step = 256 / levels;

    for (int i = 0; i < grayImage.rows; ++i) {
        for (int j = 0; j < grayImage.cols; ++j) {
            int pixelValue = grayImage.at<uchar>(i, j);
            int quantizedValue = (pixelValue / step) * step + step / 2;
            quantizedImage.at<uchar>(i, j) = quantizedValue;
        }
    }

    return quantizedImage;
}

std::string getImagePath(const std::string& imageName) {
    std::string imagePath = "images/" + imageName;
    if (imageName.find('.') == std::string::npos) {
        // Try both .png and .ppm extensions
        std::string pngPath = imagePath + ".png";
        std::string ppmPath = imagePath + ".ppm";
        if (cv::imread(pngPath).empty()) {
            imagePath = ppmPath;
        } else {
            imagePath = pngPath;
        }
    }
    return imagePath;
}

int main(int argc, char** argv) {
    if (argc < 2 || argc > 6) {
        std::cerr << "Usage: " << argv[0] << " -s <image_name> | -g <image_name> | -h <image_name> | -b <image_name> <kernel_size> | -c <image1_name> <image2_name> | -q <image_name> <levels>" << std::endl;
        return -1;
    }

    bool showImage = false;
    bool compareImages = false;
    bool convertToGrayFlag = false;
    bool histogram = false;
    bool applyBlur = false;
    bool quantize = false;
    int kernelSize = 0;
    int levels = 0;
    std::string imageName, imageName1, imageName2, imageName3, imageName4, imageNameBlur, imageNameQuantize;

    for (int i = 1; i < argc; ++i) {
        std::string option = argv[i];
        if (option == "-s" && i + 1 < argc) {
            showImage = true;
            imageName = argv[++i];
        } else if (option == "-c" && i + 2 < argc) {
            compareImages = true;
            imageName1 = argv[++i];
            imageName2 = argv[++i];
        } else if (option == "-g" && i + 1 < argc) {
            convertToGrayFlag = true;
            imageName3 = argv[++i];
        } else if (option == "-h" && i + 1 < argc) {
            histogram = true;
            imageName4 = argv[++i];
        } else if (option == "-b" && i + 2 < argc) {
            applyBlur = true;
            imageNameBlur = argv[++i];
            kernelSize = std::stoi(argv[++i]);
        } else if (option == "-q" && i + 2 < argc) {
            quantize = true;
            imageNameQuantize = argv[++i];
            levels = std::stoi(argv[++i]);
        }
    }

    // 1. Show image
    if (showImage) {
        std::string imagePath = getImagePath(imageName);
        cv::Mat image = cv::imread(imagePath, cv::IMREAD_COLOR);
        if (image.empty()) {
            std::cerr << "Error: Could not open or find the image: " << imagePath << std::endl;
            return -1;
        }

        cv::imshow("Loaded Image", image);
        cv::waitKey(0);
    }

    // 2. Grayscale and RGB
    if (convertToGrayFlag) {
        std::string imagePath = getImagePath(imageName3);
        cv::Mat image = cv::imread(imagePath, cv::IMREAD_COLOR);
        if (image.empty()) {
            std::cerr << "Error: Could not open or find the image: " << imagePath << std::endl;
            return -1;
        }

        showImageAndChannels(image);
    }

    // 3. Histogram
    if (histogram) {
        std::string imagePath = getImagePath(imageName4);
        cv::Mat grayImage = loadAndConvertToGray(imagePath);
        if (grayImage.empty()) {
            return -1;
        }

        saveHistogramData(grayImage, "histogram.csv");
        std::system("python3 plot_histogram.py histogram.csv");
    }

    // 4. Apply Gaussian Blur
    if (applyBlur) {
        std::string imagePath = getImagePath(imageNameBlur);
        cv::Mat image = cv::imread(imagePath, cv::IMREAD_COLOR);
        if (image.empty()) {
            std::cerr << "Error: Could not open or find the image: " << imagePath << std::endl;
            return -1;
        }

        applyGaussianBlur(image, kernelSize);
    }

    // 5. Compare, MSE, PSNR
    if (compareImages) {
        std::string imagePath1 = getImagePath(imageName1);
        std::string imagePath2 = getImagePath(imageName2);

        cv::Mat image1 = cv::imread(imagePath1, cv::IMREAD_COLOR);
        cv::Mat image2 = cv::imread(imagePath2, cv::IMREAD_COLOR);

        if (image1.empty() || image2.empty()) {
            std::cerr << "Error: Could not open or find one of the images." << std::endl;
            return -1;
        }

        cv::resize(image2, image2, image1.size());

        if (image1.channels() != image2.channels()) {
            if (image1.channels() == 1) {
                cv::cvtColor(image1, image1, cv::COLOR_GRAY2BGR);
            } else if (image2.channels() == 1) {
                cv::cvtColor(image2, image2, cv::COLOR_GRAY2BGR);
            }
        }

        cv::Mat diff;
        cv::absdiff(image1, image2, diff);

        double mse = calculateMSE(image1, image2);
        double psnr = calculatePSNR(mse);

        std::cout << "Mean Squared Error (MSE): " << mse << std::endl;
        std::cout << "Peak Signal-to-Noise Ratio (PSNR): " << psnr << " dB" << std::endl;

        cv::imshow("Difference Image", diff);
        cv::waitKey(0);
    }

    // 6. Quantize Image
    if (quantize) {
        std::string imagePath = getImagePath(imageNameQuantize);
        cv::Mat grayImage = loadAndConvertToGray(imagePath);
        if (grayImage.empty()) {
            return -1;
        }

        cv::Mat quantizedImage = quantizeImage(grayImage, levels);

        double mse = calculateMSE(grayImage, quantizedImage);
        double psnr = calculatePSNR(mse);

        std::cout << "Quantization Levels: " << levels << std::endl;
        std::cout << "Mean Squared Error (MSE): " << mse << std::endl;
        std::cout << "Peak Signal-to-Noise Ratio (PSNR): " << psnr << " dB" << std::endl;

        cv::imshow("Original Grayscale Image", grayImage);
        cv::imshow("Quantized Image", quantizedImage);
        cv::waitKey(0);
    }

    return 0;
}