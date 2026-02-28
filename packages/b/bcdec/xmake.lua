package("bcdec")
    set_homepage("https://github.com/mrowrpurr/bcdec")
    set_description("Single-header library for decoding BC-compressed textures (BC1-BC7)")
    set_license("MIT")

    add_urls("https://github.com/mrowrpurr/bcdec.git")
    add_versions("mrowrpurr", "mrowrpurr")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
