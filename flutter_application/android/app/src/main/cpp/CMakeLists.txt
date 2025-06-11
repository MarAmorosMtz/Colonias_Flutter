cmake_minimum_required(VERSION 3.10.2)  # Versión compatible con Android

# Configura OpenCV (ajusta la ruta según tu instalación)
set(OpenCV_DIR $ENV{OPENCV_ANDROID}/sdk/native/jni)
find_package(OpenCV REQUIRED)

# Tu biblioteca nativa
add_library(
    colonias_detector
    SHARED
    colonias_detector.cpp
    colonias_detector_ffi.cpp
)

# Vincula dependencias
target_include_directories(colonias_detector PRIVATE ${OpenCV_INCLUDE_DIRS})
target_link_libraries(
    colonias_detector
    ${OpenCV_LIBS}
    log
    android
)

# Configuración específica para Android
if(ANDROID)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -frtti -fexceptions")
endif()