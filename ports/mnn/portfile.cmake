if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/MNN
    REF 1.1.6
    SHA512 bdeef79fd5fd044cb5400a56acd39b183d44a3a03f3e7db0e67577c85bfb803b2b840a81480867f35b61888cecf3f0e7d3c32e56b509e41235558108a1debc9b
    HEAD_REF master
    PATCHES
        fix-cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda        MNN_CUDA
    cuda        MNN_GPU_TRACE
    tensorrt    MNN_TENSORRT
    tensorrt    MNN_TRT_DYNAMIC
    tensorrt    MNN_GPU_TRACE
    vulkan      MNN_VULKAN
    vulkan      MNN_GPU_TRACE
    vulkan      MNN_USE_SYSTEM_LIB
    opencl      MNN_OPENCL
    opencl      MNN_USE_SYSTEM_LIB
    metal       MNN_METAL
    metal       MNN_GPU_TRACE
    opengl-es   MNN_OPENGL
    opengl-es   MNN_USE_SYSTEM_LIB
    opengl-es   MNN_GPU_TRACE
)

if("opengl" IN_LIST FEATURES)
    if(NOT (VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_WINDOWS))
        message(FATAL_ERROR "The feature 'opengl' requires EGL")
    endif()
endif()

if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND PLATFORM_OPTIONS -DMNN_ARM82=ON)
elseif(VCPKG_TARGET_ARCHITECTURE MATCHES "x86"
       AND NOT VCPKG_TARGET_IS_ANDROID)
    # activate SSE/AVX targets
    list(APPEND PLATFORM_OPTIONS -DMNN_USE_SSE=ON)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
        list(APPEND PLATFORM_OPTIONS -DMNN_AVX512=ON)
    endif()
else()
    list(APPEND PLATFORM_OPTIONS -DMNN_USE_SSE=OFF)
endif()

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" BUILD_SHARED)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS} -DMNN_USE_LOGCAT=${VCPKG_TARGET_IS_ANDROID} -DMNN_SUPPORT_BF16=OFF
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        # 1.1.6.0-${commit}
        -DMNN_VERSION_MAJOR=1 -DMNN_VERSION_MINOR=1 -DMNN_VERSION_PATCH=6 -DMNN_VERSION_BUILD=0 -DMNN_VERSION_SUFFIX=-3dada34
        -DMNN_OPENGL_REGEN=OFF
    OPTIONS_DEBUG
        -DMNN_TRAIN_DEBUG=ON
        -DMNN_EXPR_ENABLE_PROFILER=ON
        -DMNN_DEBUG_MEMORY=ON -DMNN_DEBUG_TENSOR_SIZE=ON
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/MNN TARGET_PATH share/${PORT})

vcpkg_download_distfile(COPYRIGHT_PATH
    URLS "https://apache.org/licenses/LICENSE-2.0.txt" 
    FILENAME 98f6b79b778f7b0a1541.txt
    SHA512 98f6b79b778f7b0a15415bd750c3a8a097d650511cb4ec8115188e115c47053fe700f578895c097051c9bc3dfb6197c2b13a15de203273e1a3218884f86e90e8
)
file(RENAME ${COPYRIGHT_PATH} ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    if("metal" IN_LIST FEATURES)
        file(RENAME ${CURRENT_PACKAGES_DIR}/bin/mnn.metallib
                    ${CURRENT_PACKAGES_DIR}/lib/mnn.metallib)
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # remove the others. ex) mnn.metallib
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
