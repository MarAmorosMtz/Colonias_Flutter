cmake_minimum_required(VERSION 3.10...3.27)

project(FLUTTER_APLICATION LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# Configura OpenCV (versión mejorada)
set(OpenCV_DIR ${CMAKE_SOURCE_DIR}/../../opencv-4.11.0-android-sdk/OpenCV-android-sdk/sdk/native/jni)
find_package(OpenCV REQUIRED)
if(NOT OpenCV_FOUND)
    message(FATAL_ERROR "OpenCV no encontrado. Asegúrate de configurar OPENCV_ANDROID")
endif()

message(STATUS "OpenCV include dirs: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "OpenCV libraries: ${OpenCV_LIBS}")

# Configuración de la biblioteca nativa
add_library(
    colonias_detector
    SHARED
    colonias_detector.cpp
    colonias_detector_ffi.cpp
)

# Configuración de propiedades importantes
set_target_properties(colonias_detector PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
)

# Configuración de includes
target_include_directories(colonias_detector PRIVATE
    ${OpenCV_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}  
)

# Configuración de compilación para Android
if(ANDROID)
    target_compile_options(colonias_detector PRIVATE
        -Wall
        -Wextra
        -Werror
        -fexceptions
        -frtti
    )
    
    # Estándar C++ moderno (recomendado C++17 o superior)
    set_target_properties(colonias_detector PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
    )
endif()

# Vinculación de bibliotecas
target_link_libraries(colonias_detector
    ${OpenCV_LIBS}
    log
    android
    # Otras dependencias si las tienes
)

# Configuración específica para FFI
target_compile_definitions(colonias_detector PRIVATE
    COLONIAS_DETECTOR_EXPORT=__attribute__((visibility("default")))
)

# Instalación de la biblioteca (opcional pero recomendado)
install(TARGETS colonias_detector
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
