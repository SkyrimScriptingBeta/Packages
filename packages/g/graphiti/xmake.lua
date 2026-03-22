package("graphiti")
    set_homepage("https://github.com/SkyrimScriptingBeta/graphiti")
    set_description("Temporally-aware knowledge graph library for AI agents")
    set_license("Apache-2.0")

    add_urls("https://github.com/SkyrimScriptingBeta/graphiti.git")
    add_versions("mrowrpurr", "mrowrpurr")

    add_deps("kuzu")
    add_deps("nlohmann_json")
    add_deps("cpp-httplib")
    add_deps("openssl3")
    add_deps("yaml-cpp")
    add_deps("ixwebsocket")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
