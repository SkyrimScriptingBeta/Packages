package("example_static_library")
    set_homepage("https://github.com/SkyrimScriptingBeta/ExampleStaticLibrary")
    set_description("Example C++ static library for testing")
    set_license("0BSD")

    add_urls("https://github.com/SkyrimScriptingBeta/ExampleStaticLibrary/archive/refs/tags/$(version).tar.gz",
            "https://github.com/SkyrimScriptingBeta/ExampleStaticLibrary.git")

    -- Allow users to specify which CommonLib package they want
    add_configs("commonlib", {description = "Specify package name for commonlib dependency", default = nil, type = "string"})

    on_load(function (package)
        local commonlib = package:config("commonlib")
        if not commonlib then
            raise("You must specify a CommonLib version, e.g., `xmake f --commonlib=skyrim-commonlib-ae`")
        end

        -- Register the user-selected package as a required dependency
        package:add("deps", commonlib)
    end)

    on_install(function (package)
        local commonlib = package:config("commonlib")

        -- Add the required includes and link directories
        package:add("includedirs", package:dep(commonlib):installdir("include"))
        package:add("linkdirs", package:dep(commonlib):installdir("lib"))
        package:add("links", package:dep(commonlib):get("links"))

        import("package.tools.xmake").install(package, {})
    end)
