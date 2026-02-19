package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    -- Use TeaSpeak's CMake fork which has pre-trained model included
    add_urls("https://github.com/TeaSpeak/rnnoise-cmake.git")
    add_versions("master", "master")

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("rnnoise_create", {includes = "rnnoise.h"}))
    end)
