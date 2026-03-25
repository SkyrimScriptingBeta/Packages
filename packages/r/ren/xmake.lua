package("ren")
    set_homepage("https://github.com/mrowrpurr/codingagents.cpp")
    set_description("The missing SDK for AI coding tools")
    set_license("0BSD")

    add_urls("https://github.com/mrowrpurr/codingagents.cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mrowrpurr/codingagents.cpp.git")

    add_deps("nlohmann_json")
    add_deps("sqlite3-fts5-vec")
    add_deps("platformfolders")
    add_deps("spdlog")
    add_deps("cpr")
    add_deps("yaml-cpp")
    add_deps("toml++")

    on_install(function(package)
        import("package.tools.xmake").install(package, {
            build_tests = false
        })
    end)
