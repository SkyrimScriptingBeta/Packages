file(DOWNLOAD "https://api.github.com/repos/CharmedBaryon/CommonLibSSE/tarball/main" ${DOWNLOADS}/commonlibsse-ng-latest-latest.tar.gz
    SHOW_PROGRESS
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${DOWNLOADS}/commonlibsse-ng-latest-latest.tar.gz
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
