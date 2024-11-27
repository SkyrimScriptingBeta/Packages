package("example_header_only_library")
    set_homepage("https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary")
    set_description("Example header-only C++ library for testing Packages registry")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary.git")

    add_versions("0.0.1", "ce9ba0eb8e00684981856b98378027b87ad137f77fc00a669cda6a8a549df2e5")

    on_install(function (package)
        import("package.tools.xmake").install(package, {})
    end)
