#ifndef COLONIAS_DETECTOR_H
#define COLONIAS_DETECTOR_H

#include <opencv2/opencv.hpp>
#include <vector>
#include <string>

struct DetectionResult {
    int redCount;
    int yellowCount;
    int blueCount;
    cv::Mat redColonies;
    cv::Mat yellowColonies;
    cv::Mat blueColonies;
};

class ColoniesDetector {
public:
    static DetectionResult detectColonies(const std::string& imagePath);
    
private:
    static cv::Mat preprocessImage(const cv::Mat& img);
    static cv::Mat createColorMask(const cv::Mat& hsv, 
                                 const cv::Scalar& lower1, 
                                 const cv::Scalar& upper1,
                                 const cv::Scalar& lower2 = cv::Scalar(), 
                                 const cv::Scalar& upper2 = cv::Scalar());
    static int processColor(const cv::Mat& img, 
                          const cv::Mat& mask, 
                          cv::Mat& outputImg, 
                          int minArea = 20);
};

#endif // COLONIAS_DETECTOR_H