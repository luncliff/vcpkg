vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDAB/GammaRay
    REF 235acf6ad594dd8a85b81ebba2e526c2938f59c5 # 2024-07-08
    SHA512 bc95d5b97e1465399f9c01a078d99d3649379267defc05de45e8e54bb594679220897cb35056278708ee491f7af2b57edaa88f6c7dbc5a8620053142f00d19c1
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${_qarg_OPTIONS}
        -DGAMMARAY_QT6_BUILD=ON
        -DQT_VERSION_MAJOR=6
        -DQtCore_VERSION_MAJOR=6
        -DGAMMARAY_BUILD_DOCS=OFF
        -DGAMMARAY_BUILD_CLI_INJECTOR=OFF
        -DGAMMARAY_PROBE_ONLY_BUILD=OFF
        -DGAMMARAY_MULTI_BUILD=OFF
        -DGAMMARAY_INSTALL_QT_LAYOUT=OFF
        -DBUILD_TESTING=OFF
    OPTIONS_DEBUG
        -DGAMMARAY_ENFORCE_QT_ASSERTS=ON
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/GammaRay" PACKAGE_NAME "GammaRay")

# note: the tools require Qt Plugins...
vcpkg_copy_tools(TOOL_NAMES gammaray gammaray-client gammaray-launcher AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSES"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
    "${CURRENT_PACKAGES_DIR}/LICENSES"
    "${CURRENT_PACKAGES_DIR}/README.md"
    "${CURRENT_PACKAGES_DIR}/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/share/zsh"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
