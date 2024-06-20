if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alibaba/MNN
    REF "${VERSION}"
    SHA512 4cc099f52d6880309b74418ebf30775ee5fdbc9aadb5749d7a16a6dfaed38d9d96f4237952b700ba8976238304ff498db19f472bee712183b5fb3e5db6040d14
    HEAD_REF master
    # PATCHES
    #     use-package-and-install.patch
)
# file(REMOVE_RECURSE "${SOURCE_PATH}/3rd_party")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    test        MNN_BUILD_TEST
    test        MNN_BUILD_BENCHMARK
    cuda        MNN_CUDA
    vulkan      MNN_VULKAN
    opencl      MNN_OPENCL
    openmp      MNN_OPENMP
    metal       MNN_METAL
    train       MNN_BUILD_TRAIN
    plugin      MNN_BUILD_PLUGIN
    tools       MNN_BUILD_TOOLS
    tools       MNN_BUILD_QUANTOOLS
    tools       MNN_BUILD_TRAIN
    tools       MNN_EVALUATION
    tools       MNN_BUILD_CONVERTER
    gpu         MNN_GPU_TRACE
    system      MNN_USE_SYSTEM_LIB
)

find_program(FLATC NAMES flatc PATHS "${CURRENT_HOST_INSTALLED_DIR}/tools/flatbuffers" REQUIRED NO_DEFAULT_PATH NO_CMAKE_PATH
)
message(STATUS "Using flatc: ${FLATC}")

# regenerate some code files by schemes and flatbuffers
vcpkg_execute_build_process(
    COMMAND "${FLATC}" "-c" "-b" "--gen-object-api" "--reflect-names"
        "../default/BasicOptimizer.fbs"
        "../default/CaffeOp.fbs"
        "../default/GpuLibrary.fbs"
        "../default/MNN.fbs"
        "../default/Tensor.fbs"
        "../default/TensorflowOp.fbs"
        "../default/TFQuantizeOp.fbs"
        "../default/Type.fbs"
        "../default/UserDefine.fbs"
    WORKING_DIRECTORY "${SOURCE_PATH}/schema/current/"
    LOGNAME flatc-${TARGET_TRIPLET}
  )

if(VCPKG_TARGET_IS_WINDOWS)
    string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_RUNTIME_MT)
    list(APPEND PLATFORM_OPTIONS -DMNN_WIN_RUNTIME_MT=${USE_RUNTIME_MT})
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${NINJA_OPTION}
    OPTIONS
        ${FEATURE_OPTIONS}
        ${PLATFORM_OPTIONS}
        -DMNN_BUILD_SHARED_LIBS=${BUILD_SHARED}
        -DMNN_VERSION_MAJOR=2
        -DMNN_VERSION_MINOR=8
        -DMNN_VERSION_PATCH=4
        -DMNN_VERSION_BUILD=0
        -DMNN_VERSION_SUFFIX=-vcpkg
    OPTIONS_DEBUG
        -DMNN_DEBUG_MEMORY=ON
        -DMNN_DEBUG_TENSOR_SIZE=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # remove the others. ex) mnn.metallib
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_download_distfile(COPYRIGHT_PATH
    URLS "https://apache.org/licenses/LICENSE-2.0.txt"
    FILENAME 98f6b79b778f7b0a1541.txt
    SHA512 98f6b79b778f7b0a15415bd750c3a8a097d650511cb4ec8115188e115c47053fe700f578895c097051c9bc3dfb6197c2b13a15de203273e1a3218884f86e90e8
)
vcpkg_install_copyright(FILE_LIST "${COPYRIGHT_PATH}")
