package("SkyrimScripting.Plugin")
    set_homepage("https://github.com/SkyrimScriptingBeta/Plugin")
    set_description("Opinionated SKSE plugin helper library")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/Plugin/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/Plugin.git")

    add_deps("skse_plugin_info")

    add_configs("commonlib", { description = "Specify package name for commonlib dependency", default = nil, type = "string" })

    on_load(function (package)
        -- Require users to specify which CommonLib package they want
        local commonlib = package:config("commonlib")
        if not commonlib then
            raise("You must specify a CommonLib version, e.g., `xmake f --commonlib=skyrim-commonlib-ae`")
        end
        
        package:add("deps", "SkyrimScripting.Entrypoint", { configs = { commonlib = commonlib }})
        package:add("deps", "SkyrimScripting.Logging", { configs = { commonlib = commonlib }})
        package:add("deps", "SkyrimScripting.SKSE_Messages", { configs = { commonlib = commonlib }})
    end)

    on_install(function (package)
        import("package.tools.xmake").install(package, {
            commonlib = package:config("commonlib"),
            build_example = false
        })
    end)
