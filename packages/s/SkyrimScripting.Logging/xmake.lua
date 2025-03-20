package("SkyrimScripting.Logging")
    set_homepage("https://github.com/SkyrimScriptingBeta/Logging")
    set_description("Add logging to your SKSE plugin")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/Logging/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/Logging.git")

    add_configs("commonlib", {description = "Specify package name for commonlib dependency", default = "", type = "string"})

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
            build_example = false
        })
    end)
