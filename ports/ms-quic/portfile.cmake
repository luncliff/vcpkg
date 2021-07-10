vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF v1.4.0
    SHA512 55f6f9e3e6c76071b68913874e6f8cb5a5644ac51ce7f6bb3c55ee7188b9ae477846abdc9519429b9d4f6c06b588705b6ed2782503f56b59d3b0383fc8863d53
    HEAD_REF master
    PATCHES
        fix-install.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
    REPO quictls/openssl
    REF a6e9d76db343605dae9b59d71d2811b195ae7434
    SHA512 23510a11203b96476c194a1987c7d4e758375adef0f6dfe319cd8ec4b8dd9b12ea64c4099cf3ba35722b992dad75afb1cfc5126489a5fa59f5ee4d46bdfbeaf6
    HEAD_REF OpenSSL_1_1_1k+quic
)
file(REMOVE_RECURSE ${QUIC_SOURCE_PATH}/submodules)
file(MAKE_DIRECTORY ${QUIC_SOURCE_PATH}/submodules)
file(RENAME ${OPENSSL_SOURCE_PATH} ${QUIC_SOURCE_PATH}/submodules/openssl)

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_EXE_PATH})

if(NOT VCPKG_HOST_IS_WINDOWS)
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH ${MAKE} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${MAKE_EXE_PATH})
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${NASM_EXE_PATH})
endif()

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH ${QUIC_SOURCE_PATH}
    OPTIONS
        -DQUIC_BUILD_TOOLS=OFF
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS=openssl
        -DQUIC_TLS_SECRETS_SUPPORT=ON
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_PERF=OFF
        -DQUIC_BUILD_TEST=OFF
        -DQUIC_STATIC_LINK_CRT=${STATIC_CRT}
        -DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}
)

if("quictls" IN_LIST FEATURES)
    vcpkg_cmake_build(TARGET OpenSSL_Build) # separate build log
endif()
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME msquic CONFIG_PATH lib/cmake/msquic)

file(INSTALL ${QUIC_SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright
) 
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share
                    ${CURRENT_PACKAGES_DIR}/debug/include
)
