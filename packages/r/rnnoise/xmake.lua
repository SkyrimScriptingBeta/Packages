package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/TeaSpeak/rnnoise-cmake.git")
    add_versions("master", "master")

    on_install(function(package)
        -- Build with xmake directly, disabling OPUS FFT
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("rnnoise")
                set_kind("static")
                set_languages("c11")
                add_files("src/*.c")
                add_includedirs("include", {public = true})
                add_includedirs("src")
                add_headerfiles("include/(rnnoise.h)")
                -- Do NOT define COMPILE_OPUS - use kiss_fft instead
                add_defines("RNNOISE_BUILD")
                if is_plat("windows") then
                    add_defines("WIN32", "_CRT_SECURE_NO_WARNINGS", "_USE_MATH_DEFINES")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("rnnoise_create", {includes = "rnnoise.h"}))
    end)
