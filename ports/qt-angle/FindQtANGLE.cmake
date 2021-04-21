# 
# References
#   - https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html#find-module
#   - https://cmake.org/cmake/help/latest/manual/cmake-qt.7.html
#   - https://wiki.qt.io/Qt_5_on_Windows_ANGLE_and_OpenGL
# 
cmake_minimum_required(VERSION 3.13)

find_package(Qt5 REQUIRED COMPONENTS OpenGL)
message(STATUS "Found Qt5::OpenGL ${Qt5_VERSION}")
