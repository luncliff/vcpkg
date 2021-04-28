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
    tensorrt    MNN_TENSORRT
    tensorrt    MNN_TRT_DYNAMIC
    vulkan      MNN_VULKAN
    opencl      MNN_OPENCL
    metal       MNN_METAL
    opengl-es   MNN_OPENGL
)

if("opengl-es" IN_LIST FEATURES)
    if(NOT (VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_WINDOWS))
        message(FATAL_ERROR "The feature 'opengl-es' requires EGL")
    endif()
endif()
if(VCPKG_TARGET_IS_ANDROID)
    if(DEFINED NDK_VULKAN_LIB_PATH)
        list(APPEND PLATFORM_OPTIONS -DVulkan_LIBRARY:FILEPATH=${NDK_VULKAN_LIB_PATH})
    endif()
endif()

# Activate SSE/AVX/ARM targets
if(VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    list(APPEND ARCH_OPTIONS -DMNN_ARM82=ON
                             -DMNN_USE_SSE=OFF
                             -DARCHS=${VCPKG_TARGET_ARCHITECTURE} # ARCHS=arm64
    )
elseif(NOT VCPKG_TARGET_IS_ANDROID AND
       VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    list(APPEND ARCH_OPTIONS -DMNN_USE_SSE=ON)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "64")
        list(APPEND ARCH_OPTIONS -DMNN_AVX512=ON)
    endif()
else()
    # no architecture specific build
    list(APPEND ARCH_OPTIONS -DMNN_ARM82=OFF
                             -DMNN_USE_SSE=OFF
    )
endif()

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" BUILD_SHARED)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS} ${ARCH_OPTIONS} ${PLATFORM_OPTIONS}
        -DPYTHON_EXECUTABLE=${PYTHON3}
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DMNN_USE_LOGCAT=${VCPKG_TARGET_IS_ANDROID}
        -DMNN_USE_SYSTEM_LIB=ON
        -DMNN_SUPPORT_BF16=OFF
        -DMNN_GPU_TRACE=ON
        -DMNN_OPENGL_REGEN=OFF
        # 1.1.6.0-${commit}
        -DMNN_VERSION_MAJOR=1
        -DMNN_VERSION_MINOR=1
        -DMNN_VERSION_PATCH=6
        -DMNN_VERSION_BUILD=0
        -DMNN_VERSION_SUFFIX=-3dada34
    OPTIONS_DEBUG
        -DMNN_DEBUG_MEMORY=ON
        -DMNN_DEBUG_TENSOR_SIZE=ON
        -DMNN_EXPR_ENABLE_PROFILER=ON
        -DMNN_TRAIN_DEBUG=ON
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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin
                        ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
