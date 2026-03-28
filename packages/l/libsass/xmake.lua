package("libsass")
    set_homepage("https://github.com/mrowrpurr/libsass")
    set_description("C/C++ implementation of a Sass compiler")
    set_license("MIT")

    add_urls("https://github.com/mrowrpurr/libsass.git")
    add_versions("mrowrpurr", "mrowrpurr")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
