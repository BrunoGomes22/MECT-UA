# Part III readme

## How to Run: 
1. Install OpenCV:
```bash
    sudo apt-get update
    sudo apt-get install libopencv-dev
```

2. To run test_image:
```bash
    g++ test_image.cpp -o test_image `pkg-config --cflags --libs opencv4`
    ./test_image  -s <image_name> | -g <image_name> | -h <image_name> | -b <image_name> <kernel_size> | -c <image1_name> <image2_name> | -q <image_name> <levels>
```
    -s show image
    -g grayscale and RBG channels
    -h histogram of pixel intensities
    -c compare images, MSE, PSNR
    -q quantization



