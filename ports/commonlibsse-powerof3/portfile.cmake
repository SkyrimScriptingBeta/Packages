vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/powerof3/CommonLibSSE.git
    REF f4478e5e9ccd7d50f770c92337d1ef44d95f500a
)

option(REX_OPTION_INI "Enables ini config support for REX." OFF)
option(REX_OPTION_JSON "Enables json config support for REX." OFF)
option(REX_OPTION_TOML "Enables toml config support for REX." OFF)
option(SKSE_SUPPORT_XBYAK "Enables trampoline support for Xbyak." OFF)
option(SKYRIM_SUPPORT_AE "Enables support for Skyrim AE" OFF)

vcpkg_check_features(OUT_FEATURE_OPTIONS)

if(rex-ini IN_LIST OUT_FEATURE_OPTIONS)
    message(STATUS "Enabling ini config support for REX.")
    set(REX_OPTION_INI on)
endif()

if(rex-json IN_LIST OUT_FEATURE_OPTIONS)
    message(STATUS "Enabling json config support for REX.")
    set(REX_OPTION_JSON on)
endif()

if(rex-toml IN_LIST OUT_FEATURE_OPTIONS)
    message(STATUS "Enabling toml config support for REX.")
    set(REX_OPTION_TOML on)
endif()

if(xbyak IN_LIST OUT_FEATURE_OPTIONS)
    message(STATUS "Enabling trampoline support for Xbyak.")
    set(SKSE_SUPPORT_XBYAK on)
endif()

if(skyrim-ae IN_LIST OUT_FEATURE_OPTIONS)
    message(STATUS "Enabling support for Skyrim AE.")
    set(SKYRIM_SUPPORT_AE on)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS -DREX_OPTION_INI=${REX_OPTION_INI} -DREX_OPTION_JSON=${REX_OPTION_JSON} -DREX_OPTION_TOML=${REX_OPTION_TOML} -DSKSE_SUPPORT_XBYAK=${SKSE_SUPPORT_XBYAK} -DSKYRIM_SUPPORT_AE=${SKYRIM_SUPPORT_AE}
)

vcpkg_install_cmake()
vcpkg_cmake_config_fixup(PACKAGE_NAME CommonLibSSE CONFIG_PATH lib/cmake)
vcpkg_copy_pdbs()

file(GLOB CMAKE_CONFIGS "${CURRENT_PACKAGES_DIR}/share/CommonLibSSE/CommonLibSSE/*.cmake")
file(INSTALL ${CMAKE_CONFIGS} DESTINATION "${CURRENT_PACKAGES_DIR}/share/CommonLibSSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
