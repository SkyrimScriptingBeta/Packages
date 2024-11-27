package("example_header_only_library")
    set_homepage("https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary")
    set_description("Example header-only C++ library for testing Packages registry")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/ExampleHeaderOnlyLibrary.git")

    add_versions("0.0.1", "3A6291CE6AF17A75E2B19A778D12C1E6AD347BD250348DB5AEBB101E085EC58E")

    on_install(function (package)
        import("package.tools.xmake").install(package, {})
    end)
