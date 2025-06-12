#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int red_count;
    int yellow_count;
    int blue_count;
    uint8_t* red_image_data;
    uint8_t* yellow_image_data;
    uint8_t* blue_image_data;
    int image_width;
    int image_height;
} DetectionResultFFI;

DetectionResultFFI detect_colonies(const char* image_path);

void free_detection_result(DetectionResultFFI* result);

#ifdef __cplusplus
}
#endif