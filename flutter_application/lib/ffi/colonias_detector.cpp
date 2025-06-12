#include "colonias_detector.h"
#include <iostream>

using namespace cv;
using namespace std;

DetectionResult ColoniesDetector::detectColonies(const string& imagePath) {
    DetectionResult result;
    
    // Cargar imagen
    Mat img = imread(imagePath);
    if (img.empty()) {
        cerr << "No se pudo cargar la imagen: " << imagePath << endl;
        return result;
    }
    
    // Preprocesamiento
    Mat imgEnhanced = preprocessImage(img);
    
    // Convertir a HSV
    Mat hsv;
    cvtColor(img, hsv, COLOR_BGR2HSV);
    
    // Definir rangos de color
    // Rojo
    Scalar lower_red1(0, 50, 50);
    Scalar upper_red1(10, 255, 255);
    Scalar lower_red2(160, 50, 50);
    Scalar upper_red2(180, 255, 255);
    
    // Amarillo
    Scalar lower_yellow(20, 50, 50);
    Scalar upper_yellow(30, 255, 255);
    
    // Azul
    Scalar lower_blue1(200, 30, 30);
    Scalar upper_blue1(200, 255, 255);
    Scalar lower_blue2(85, 40, 30);
    Scalar upper_blue2(115, 120, 80);
    
    // Crear máscaras
    Mat mask_red = createColorMask(hsv, lower_red1, upper_red1, lower_red2, upper_red2);
    Mat mask_yellow = createColorMask(hsv, lower_yellow, upper_yellow);
    Mat mask_blue = createColorMask(hsv, lower_blue1, upper_blue1, lower_blue2, upper_blue2);
    
    // Procesar cada color
    Mat imgR = img.clone();
    Mat imgY = img.clone();
    Mat imgB = img.clone();
    
    result.redCount = processColor(img, mask_red, imgR);
    result.yellowCount = processColor(img, mask_yellow, imgY);
    result.blueCount = processColor(img, mask_blue, imgB);
    
    result.redColonies = imgR;
    result.yellowColonies = imgY;
    result.blueColonies = imgB;
    
    return result;
}

Mat ColoniesDetector::preprocessImage(const Mat& img) {
    Mat lab, enhanced;
    vector<Mat> lab_channels;
    
    cvtColor(img, lab, COLOR_BGR2Lab);
    split(lab, lab_channels);
    
    Ptr<CLAHE> clahe = createCLAHE();
    clahe->setClipLimit(4.0);
    clahe->setTilesGridSize(Size(16, 16));
    clahe->apply(lab_channels[0], lab_channels[0]);
    
    merge(lab_channels, lab);
    cvtColor(lab, enhanced, COLOR_Lab2BGR);
    
    return enhanced;
}

Mat ColoniesDetector::createColorMask(const Mat& hsv, 
                                    const Scalar& lower1, 
                                    const Scalar& upper1,
                                    const Scalar& lower2, 
                                    const Scalar& upper2) {
    Mat mask1, mask2, mask;
    
    inRange(hsv, lower1, upper1, mask1);
    
    if (!lower2.empty() && !upper2.empty()) {
        inRange(hsv, lower2, upper2, mask2);
        bitwise_or(mask1, mask2, mask);
    } else {
        mask = mask1;
    }
    
    // Operaciones morfológicas
    Mat kernel = getStructuringElement(MORPH_RECT, Size(5, 5));
    morphologyEx(mask, mask, MORPH_OPEN, kernel, Point(-1, -1), 1);
    morphologyEx(mask, mask, MORPH_CLOSE, kernel, Point(-1, -1), 2);
    
    // Suavizado
    GaussianBlur(mask, mask, Size(5, 5), 0);
    
    return mask;
}

int ColoniesDetector::processColor(const Mat& img, 
                                 const Mat& mask, 
                                 Mat& outputImg, 
                                 int minArea) {
    vector<vector<Point>> contours;
    findContours(mask, contours, RETR_EXTERNAL, CHAIN_APPROX_SIMPLE);
    
    int count = 0;
    for (size_t i = 0; i < contours.size(); i++) {
        double area = contourArea(contours[i]);
        if (area > minArea) {
            count++;
            drawContours(outputImg, contours, i, Scalar(0, 255, 0), 4);
            
            Moments M = moments(contours[i]);
            if (M.m00 != 0) {
                int cX = int(M.m10 / M.m00);
                int cY = int(M.m01 / M.m00);
                putText(outputImg, to_string(count), Point(cX, cY),
                       FONT_HERSHEY_SIMPLEX, 2, Scalar(0, 0, 255), 4);
            }
        }
    }
    
    return count;
}