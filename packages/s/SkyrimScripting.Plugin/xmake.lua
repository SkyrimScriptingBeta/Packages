package("SkyrimScripting.Plugin")
    set_homepage("https://github.com/SkyrimScriptingBeta/Plugin")
    set_description("Listen for SKSE messages")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/Plugin/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/Plugin.git")

    add_deps("global_macro_functions")

    add_configs("commonlib", {description = "Specify package name for commonlib dependency", default = "", type = "string"})
    add_configs("require_commonlib", {description = "If true, add_requires the CommonLib package", default = true, type = "boolean"})

    add_configs("include_repo_skyrimscripting", {description = "Include SkyrimScripting repository during build", default = true, type = "boolean"})
    add_configs("include_repo_skyrimscripting_beta", {description = "Include SkyrimScripting repository during build", default = true, type = "boolean"})
    add_configs("include_repo_mrowrlib", {description = "Include MrowrLib repository during build", default = true, type = "boolean"})

    add_configs("build_example", {description = "Build example project using this library", default = false, type = "boolean"})
    add_configs("build_papyrus_scripts", {description = "Build Papyrus scripts", default = false, type = "boolean"})

    add_configs("use_log_library", {description = "If true, builds with support for the _Log_ library", default = false, type = "boolean"})
    add_configs("use_skyrimscripting_logging", {description = "If true, builds with support for the SkyrimScripting.Logging library", default = false, type = "boolean"})
    add_configs("use_skse_plugin_info_library", {description = "If true, builds with support for the SKSEPluginInfo library", default = false, type = "boolean"})

    on_load(function (package)
        -- Require users to specify which CommonLib package they want
        local commonlib = package:config("commonlib")
        if not commonlib then
            raise("You must specify a CommonLib version, e.g., `xmake f --commonlib=skyrim-commonlib-ae`")
        end

        -- [Entrypoint]
        -- Require SkyrimScripting.Entrypoint, adding to package deps,
        -- and pass along all of these config options: commonlib, include_repo_skyrimscripting, include_repo_mrowrlib, build_example
        -- package:add("deps", "SkyrimScripting.Entrypoint", { configs = {
        --     commonlib = commonlib,
        --     require_commonlib = package:config("require_commonlib"),
        --     include_repo_skyrimscripting = package:config("include_repo_skyrimscripting"),
        --     include_repo_mrowrlib = package:config("include_repo_mrowrlib"),
        --     build_example = package:config("build_example")
        -- }})

        -- [Logging]
        -- Require SkyrimScripting.Logging, adding to package deps,
        -- and pass along all of these config options: commonlib, require_commonlib, include_repo_skyrimscripting, include_repo_mrowrlib, build_example, use_log_library, use_skse_plugin_info_library
        -- package:add("deps", "SkyrimScripting.Logging", { configs = {
        --     commonlib = commonlib,
        --     require_commonlib = package:config("require_commonlib"),
        --     include_repo_skyrimscripting = package:config("include_repo_skyrimscripting"),
        --     include_repo_mrowrlib = package:config("include_repo_mrowrlib"),
        --     build_example = package:config("build_example"),
        --     use_log_library = package:config("use_log_library"),
        --     use_skse_plugin_info_library = package:config("use_skse_plugin_info_library")
        -- }})

        -- [SKSE_Messages]
        -- Require SkyrimScripting.SKSE_Messages, adding to package deps,
        -- and pass along all of these config options: commonlib, require_commonlib, include_repo_skyrimscripting, include_repo_mrowrlib, build_example, build_papyrus_scripts, use_log_library, use_skyrimscripting_logging, use_skse_plugin_info_library
        package:add("deps", "SkyrimScripting.SKSE_Messages", { configs = {
            commonlib = commonlib,
            require_commonlib = package:config("require_commonlib"),
            include_repo_skyrimscripting = package:config("include_repo_skyrimscripting"),
            include_repo_skyrimscripting_beta = package:config("include_repo_skyrimscripting_beta"),
            include_repo_mrowrlib = package:config("include_repo_mrowrlib"),
            build_example = package:config("build_example"),
            build_papyrus_scripts = package:config("build_papyrus_scripts"),
            use_log_library = package:config("use_log_library"),
            use_skyrimscripting_logging = package:config("use_skyrimscripting_logging"),
            use_skse_plugin_info_library = package:config("use_skse_plugin_info_library")
        } })
    end)

    on_install(function (package)
        import("package.tools.xmake").install(package, {
            commonlib = package:config("commonlib"),
            include_repo_skyrimscripting = package:config("include_repo_skyrimscripting"),
            include_repo_skyrimscripting_beta = package:config("include_repo_skyrimscripting_beta"),
            include_repo_mrowrlib = package:config("include_repo_mrowrlib"),
            build_example = package:config("build_example"),
            build_papyrus_scripts = package:config("build_papyrus_scripts"),
            require_commonlib = package:config("require_commonlib"),
            use_log_library = package:config("use_log_library"),
            use_skyrimscripting_logging = package:config("use_skyrimscripting_logging")
        })
    end)
