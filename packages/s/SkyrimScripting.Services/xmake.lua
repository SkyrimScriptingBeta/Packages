package("SkyrimScripting.Services")
    set_homepage("https://github.com/SkyrimScriptingBeta/Services")
    set_description("Share Services between SKSE plugins")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/Services/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/Services.git")

    add_deps("collections")
    add_deps("unordered_dense")

    add_configs("commonlib", { description = "Specify package name for commonlib dependency", default = nil, type = "string" })

    on_load(function (package)
        -- Require users to specify which CommonLib package they want
        local commonlib = package:config("commonlib")
        if not commonlib then
            raise("You must specify a CommonLib version, e.g., `xmake f --commonlib=skyrim-commonlib-ae`")
        end
    end)

    on_install(function (package)
        import("package.tools.xmake").install(package, {
            commonlib = package:config("commonlib"),
            build_example = false,
            build_plugin = false
        })
    end)
