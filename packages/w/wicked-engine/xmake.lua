package("wicked-engine")
    set_homepage("https://github.com/SkyrimScriptingBeta/WickedEngine")
    set_description("Wicked Engine - 3D rendering engine")

    add_urls("https://github.com/SkyrimScriptingBeta/WickedEngine.git")
    add_versions("mrowrpurr", "mrowrpurr")

    add_defines("WICKED_CMAKE_BUILD")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
