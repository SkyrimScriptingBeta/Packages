-- This is an example of a package() which can be shared in any xmake package registry

package("SkyrimScripting.Logging")
    set_homepage("https://github.com/SkyrimScriptingBeta/Logging")
    set_description("My library which uses CommonLib")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/Logging/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/Logging.git")

    add_deps("_Log_")

    add_configs("commonlib", {description = "Specify package name for commonlib dependency", default = "", type = "string"})
    add_configs("require_commonlib", {description = "If true, add_requires the CommonLib package", default = true, type = "boolean"})

    add_configs("include_repo_skyrimscripting", {description = "Include SkyrimScripting repository during build", default = true, type = "boolean"})
    add_configs("include_repo_skyrimscripting_beta", {description = "Include SkyrimScripting repository during build", default = true, type = "boolean"})
    add_configs("include_repo_mrowrlib", {description = "Include MrowrLib repository during build", default = true, type = "boolean"})

    add_configs("build_example", {description = "Build example project using this library", default = false, type = "boolean"})
    add_configs("build_papyrus_scripts", {description = "Build Papyrus scripts", default = false, type = "boolean"})

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
            include_repo_skyrimscripting = package:config("include_repo_skyrimscripting"),
            include_repo_skyrimscripting_beta = package:config("include_repo_skyrimscripting_beta"),
            include_repo_mrowrlib = package:config("include_repo_mrowrlib"),
            build_example = package:config("build_example"),
            build_papyrus_scripts = package:config("build_papyrus_scripts"),
            require_commonlib = package:config("require_commonlib")
        })
    end)
