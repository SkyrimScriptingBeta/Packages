package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/rnnoise.git")
    add_versions("main", "main")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("rnnoise")
                set_kind("static")
                set_languages("c11")
                add_files("src/*.c")
                add_includedirs("include", {public = true})
                add_headerfiles("include/(rnnoise.h)")
                if is_plat("windows") then
                    add_defines("WIN32", "_USE_MATH_DEFINES")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("rnnoise_create", {includes = "rnnoise.h"}))
    end)
