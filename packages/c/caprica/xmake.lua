package("caprica")
    set_homepage("https://github.com/SkyrimScriptingBeta/Caprica")
    set_description("Papyrus script compiler for Skyrim modding")
    set_license("MIT")

    add_urls("https://github.com/SkyrimScriptingBeta/Caprica.git")
    add_versions("mrowrpurr", "mrowrpurr")

    add_deps("boost", { configs = { filesystem = true, program_options = true, container = true } })
    add_deps("pugixml")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cxxincludes("common/GameID.h", {configs = {languages = "c++23"}}))
    end)
