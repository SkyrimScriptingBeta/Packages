vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary_Consumer.git
    REF 50f996b0e84aba4ac5628eb48c7e3661b361b157
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
