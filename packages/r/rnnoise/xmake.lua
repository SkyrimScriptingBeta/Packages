package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/TeaSpeak/rnnoise-cmake.git")
    add_versions("master", "master")

    on_install(function(package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("rnnoise")
                set_kind("static")
                set_languages("c11")
                add_files("src/*.c")
                add_includedirs("include", {public = true})
                add_includedirs("src")
                add_headerfiles("include/(rnnoise.h)")
                -- COMPILE_OPUS is required - it enables the opus_fft_c implementation
                add_defines("RNNOISE_BUILD", "COMPILE_OPUS")
                if is_plat("windows") then
                    add_defines("WIN32", "_CRT_SECURE_NO_WARNINGS", "_USE_MATH_DEFINES")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("rnnoise_create", {includes = "rnnoise.h"}))
    end)
