package("caprica")
    set_homepage("https://github.com/SkyrimScriptingBeta/Caprica")
    set_description("Papyrus script compiler for Skyrim modding")
    set_license("MIT")

    add_urls("https://github.com/SkyrimScriptingBeta/Caprica.git")
    add_versions("mrowrpurr", "mrowrpurr")

    add_deps("boost", { configs = { filesystem = true, program_options = true, container = true } })
    add_deps("pugixml")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++23")

            add_requires("boost", { configs = { filesystem = true, program_options = true, container = true } })
            add_requires("pugixml")

            target("caprica")
                set_kind("static")
                add_packages("boost", "pugixml", { public = true })
                add_files("caprica/common/**.cpp")
                add_files("caprica/papyrus/**.cpp")
                add_files("caprica/pex/**.cpp")
                add_includedirs("caprica", { public = true })
                add_headerfiles("caprica/(common/**.h)")
                add_headerfiles("caprica/(papyrus/**.h)")
                add_headerfiles("caprica/(pex/**.h)")
                add_cxxflags("cl::/Zc:inline", "cl::/bigobj")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cxxincludes("common/GameID.h", {configs = {languages = "c++23"}}))
    end)
