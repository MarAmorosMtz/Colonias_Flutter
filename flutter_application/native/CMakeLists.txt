cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_CXX_STANDARD 11)

find_package(OpenCV REQUIRED)

add_library(
    colonias_detector
    SHARED
    colonias_detector.cpp
    colonias_detector_ffi.cpp
)

target_link_libraries(
    colonias_detector
    ${OpenCV_LIBS}
    log
)