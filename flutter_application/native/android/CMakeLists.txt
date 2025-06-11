LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
OPENCV_INSTALL_MODULES:=on
OPENCV_CAMERA_MODULES:=off
include /path/to/OpenCV-android-sdk/sdk/native/jni/OpenCV.mk

LOCAL_MODULE    := colonias_detector
LOCAL_SRC_FILES := colonias_detector.cpp colonias_detector_ffi.cpp
LOCAL_LDLIBS    += -llog

include $(BUILD_SHARED_LIBRARY)