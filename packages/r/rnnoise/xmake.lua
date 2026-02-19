package("rnnoise")
    set_homepage("https://github.com/xiph/rnnoise")
    set_description("Recurrent neural network for audio noise reduction")
    set_license("BSD-3-Clause")

    -- Use jmvalin's cmake branch which has pre-trained model and CMake support
    add_urls("https://github.com/GregorR/rnnoise-cmake.git")
    add_versions("cmake", "master")

    on_install(function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("rnnoise_create", {includes = "rnnoise.h"}))
    end)
