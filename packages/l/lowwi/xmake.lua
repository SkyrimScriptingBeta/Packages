package("lowwi")
    set_homepage("https://github.com/mrowrpurr/lowwi")
    set_description("Lightweight Open Wake Word Implementation for C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/mrowrpurr/lowwi.git")
    add_versions("mrowrpurr", "mrowrpurr")

    add_deps("onnxruntime")

    on_install(function(package)
        import("package.tools.xmake").install(package, {
            build_examples = false
        })
    end)
