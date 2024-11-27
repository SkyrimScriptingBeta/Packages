package("example_library")
    set_homepage("https://github.com/SkyrimScriptingBeta/ExampleLibrary")
    set_description("Example C++ library for testing Packages registry")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/ExampleLibrary/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/ExampleLibrary.git")

    add_versions("0.0.1", "1caf7c2c606c2b02e274b329e7b6c0f1f35f01e3e59c228218f67e6b1664593a")

    on_install(function (package)
        import("package.tools.xmake").install(package, {})
    end)

-- Example: https://github.com/SkyrimScriptingBeta/ExampleLibrary/archive/refs/tags/0.0.1.tar.gz