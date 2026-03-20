package("qlementine-icons")
    set_homepage("https://github.com/oclero/qlementine-icons")
    set_description("Modern vector icon theme for Qt applications")
    set_license("MIT")

    add_urls("https://github.com/mrowrpurr/qlementine-icons.git")
    add_versions("mrowrpurr", "mrowrpurr")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
