package("kuzu")
    set_homepage("https://github.com/SkyrimScriptingBeta/kuzu")
    set_description("Kuzu - embedded graph database management system")

    add_urls("https://github.com/SkyrimScriptinBeta/kuzu.git")
    add_versions("mrowrpurr", "mrowrpurr")

    if is_plat("windows") then
        add_defines("KUZU_STATIC_DEFINE")
    end

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
