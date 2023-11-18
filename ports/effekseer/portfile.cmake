# vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effekseer/Effekseer
    REF 170e # 92fdeb349c0c7eab9dfaf152047f22dec2fa102d
    SHA512 58e103993ec085cad1573394f4f3a1e28beda776c640a86e71caf3f7b7119889cff421e24dfbe553c38a7acd123a8d1f182196dfd7a104a88626c5d4244e84bf
    HEAD_REF master
    PATCHES
        fix-cmake.patch
        fix-sources.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  BUILD_VULKAN
        vulkan  BUILD_VULKAN_COMPILER
        tool    BUILD_VIEWER
        tool    BUILD_EDITOR
        tool    USE_LIBPNG_LOADER
        gles    USE_OPENGLES3
        gles    USE_OPENGLES2
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" USE_DYNAMIC_RUNTIME)

vcpkg_find_acquire_program(PYTHON3)
message(STATUS "Using python3: ${PYTHON3}")

vcpkg_find_acquire_program(PKGCONFIG)
message(STATUS "Using pkgconfig: ${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON3}
        -DPKG_CONFIG_EXECUTABLE:FILEPATH=${PKGCONFIG}
        -DBUILD_GL=ON
        -DUSE_OPENGL3=OFF
        -DBUILD_TEST=OFF
        -DBUILD_EXAMPLES=OFF
        -DNETWORK_ENABLED=OFF
        -DUSE_MSVC_RUNTIME_LIBRARY_DLL=${USE_DYNAMIC_RUNTIME}
        -DUSE_EXTERNAL_GLSLANG=ON
        -DGLSLANG_INCLUDE_DIR:PATH=${CURRENT_INSTALLED_DIR}/include
    MAYBE_UNUSED_VARIABLES
        USE_MSVC_RUNTIME_LIBRARY_DLL
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake" PACKAGE_NAME Effekseer)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")