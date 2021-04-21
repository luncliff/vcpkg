#
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#   TRIPLET_SYSTEM_ARCH       = arm x86 x64
#   VCPKG_TARGET_IS_WINDOWS
#   VCPKG_TARGET_IS_UWP
#   VCPKG_TARGET_IS_MINGW
#
vcpkg_fail_port_install(MESSAGE "'${PORT}' currently only supports Windows and UWP platforms" ON_TARGET "Linux" "Darwin")
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(NOT DEFINED ENV{Qt5_DIR})
    message(FATAL_ERROR "'Qt5_DIR' environment variable must be defined. ex) C:\\tools\\Anaconda3\\Library\\lib\\cmake\\Qt5")
endif()
# test the script works. use https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html#find-modules
include(${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake)
find_package(QtANGLE 5.9)
if(NOT QtANGLE_FOUND)
    message(FATAL_ERROR "Failed to search QtANGLE files")
endif()

# copy scripts and usage
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/FindQtANGLE.cmake
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/usage
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

# todo: copy Qt5's license file with QtANGLE_ROOT_DIR
#       see https://cmake.org/cmake/help/latest/command/find_file.html
# file(INSTALL ... DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
