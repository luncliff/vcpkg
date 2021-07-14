
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO effekseer/Effekseer
    REF 160d
    SHA512 56da35f313b1d028928b04d260782ef9d2f8deee50097a8e385bfdf01e6b6d87a02d6631c9039f459fa9f89742ceedbd6b87b44c49bf0d43dbd053dcea784ca6
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   BUILD_VIEWER
        tools   BUILD_EDITOR
        tools   BUILD_VERSION17
        vulkan  BUILD_VULKAN
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_EXAMPLES=OFF
        -DUSE_LIBPNG_LOADER=ON
        -DBUILD_DX12=${VCPKG_TARGET_IS_WINDOWS}
        -DBUILD_METAL=${VCPKG_TARGET_IS_OSX}
        -DBUILD_WITH_EASY_PROFILER=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
