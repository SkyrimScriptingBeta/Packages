package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/rnnoise.git")
    add_versions("2024.12.18", "1cbdbcf1283499bbb2f32b239a1249ee9c113528")

    on_install(function(package)
        -- Write a simple xmake.lua to build rnnoise
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
