if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO altseed/OpenSoundMixer
    REF 7b65b2fae8c15cc1502a8e61b8a5138c862e7abc
    SHA512 9ea9e480967342492e6040372beaece065310b795d7063e141d2f37d697b1ded9f5414f6e0edf5fd1670b7978efd264e07f5f2c11fa582928ffb886de870cafa
    HEAD_REF master
    PATCHES
        fix-install.patch
)
file(REMOVE_RECURSE ${SOURCE_PATH}/thirdparty)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TEST=OFF
)
vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE 
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
