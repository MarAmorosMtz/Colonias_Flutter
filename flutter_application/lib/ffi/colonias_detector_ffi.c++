#include "include/colonias_detector_ffi.h"
#include "include/colonias_detector.h"
#include <vector>
#include <cstring>

extern "C" {

DetectionResultFFI detect_colonies(const char* image_path) {
    DetectionResultFFI result_ffi = {0};
    
    try {
        DetectionResult result = ColoniesDetector::detectColonies(image_path);
        
        result_ffi.red_count = result.redCount;
        result_ffi.yellow_count = result.yellowCount;
        result_ffi.blue_count = result.blueCount;
        
        if (!result.redColonies.empty()) {
            result_ffi.image_width = result.redColonies.cols;
            result_ffi.image_height = result.redColonies.rows;
            
            std::vector<uint8_t> red_buffer(result_ffi.image_width * result_ffi.image_height * 4);
            cv::Mat red_rgba;
            cv::cvtColor(result.redColonies, red_rgba, cv::COLOR_BGR2RGBA);
            std::memcpy(red_buffer.data(), red_rgba.data, red_buffer.size());
            
            result_ffi.red_image_data = new uint8_t[red_buffer.size()];
            std::copy(red_buffer.begin(), red_buffer.end(), result_ffi.red_image_data);

        }
    } catch (const std::exception& e) {
        std::cerr << "Error en detect_colonies: " << e.what() << std::endl;
    }
    
    return result_ffi;
}

void free_detection_result(DetectionResultFFI* result) {
    if (result->red_image_data) {
        delete[] result->red_image_data;
        result->red_image_data = nullptr;
    }
    if (result->yellow_image_data) {
        delete[] result->yellow_image_data;
        result->yellow_image_data = nullptr;
    }
    if (result->blue_image_data) {
        delete[] result->blue_image_data;
        result->blue_image_data = nullptr;
    }
}

}