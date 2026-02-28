package("onnxruntime-wasm-compatible")
    set_homepage("https://www.onnxruntime.ai")
    set_description("ONNX Runtime: cross-platform, high performance ML inferencing and training accelerator (with WASM support)")
    set_license("MIT")

    -- Desktop: same prebuilt binaries as the upstream onnxruntime package
    if is_plat("windows") then
        if is_arch("x64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x64-$(version).zip")
            add_versions("1.22.0", "174c616efc0271194488642a72f1a514e01487da4dfe84c49296d66e40ebe0da")
        elseif is_arch("x86") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-x86-$(version).zip")
            add_versions("1.22.0", "466ebaf8b8db4e672dd91bdcd3d6420287e9aeb728278e419127d29a3832a8a3")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-win-arm64-$(version).zip")
            add_versions("1.22.0", "7008f7ff82f8e7de563a22f2b590e08e706a1289eba606b93de2b56edfb1e04b")
        end
    elseif is_plat("linux") then
        if is_arch("x86_64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-x64-$(version).tgz")
            add_versions("1.22.0", "8344d55f93d5bc5021ce342db50f62079daf39aaafb5d311a451846228be49b3")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-linux-aarch64-$(version).tgz")
            add_versions("1.22.0", "bb76395092d150b52c7092dc6b8f2fe4d80f0f3bf0416d2f269193e347e24702")
        end
    elseif is_plat("macosx") then
        if is_arch("x86_64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-x86_64-$(version).tgz")
            add_versions("1.22.0", "e4ec94a7696de74fb1b12846569aa94e499958af6ffa186022cfde16c9d617f0")
        elseif is_arch("arm64") then
            set_urls("https://github.com/microsoft/onnxruntime/releases/download/v$(version)/onnxruntime-osx-arm64-$(version).tgz")
            add_versions("1.22.0", "cab6dcbd77e7ec775390e7b73a8939d45fec3379b017c7cb74f5b204c1a1cc07")
        end
    elseif is_plat("wasm") then
        set_urls("https://github.com/SkyrimScriptingBeta/Packages/releases/download/onnxruntime-wasm-v$(version)/onnxruntime-wasm-static-$(version).tar.gz")
        add_versions("1.22.0", "60247cb697f97cfaa0ba5d5eb5c3befebf1b727dc46bd17b9c884c33c925e3ba")
    end

    on_load(function (package)
        if package:is_plat("wasm") then
            package:add("ldflags", "-pthread", "-msimd128", "-sALLOW_MEMORY_GROWTH=1")
        end
    end)

    on_install("windows", "linux|arm64", "linux|x86_64", "macosx", function (package)
        if package:is_plat("windows") then
            os.mv("lib/*.dll", package:installdir("bin"))
        end
        os.cp("*", package:installdir())
    end)

    on_install("wasm", function (package)
        os.cp("include/*", package:installdir("include"))
        os.cp("lib/*", package:installdir("lib"))
    end)

    on_test(function (package)
        if package:is_plat("wasm") then
            assert(package:check_cxxsnippets({test = [[
                void test() {}
            ]]}, {configs = {languages = "c++17"}, includes = "onnxruntime_cxx_api.h"}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <array>
                #include <cstdint>
                void test() {
                    std::array<float, 2> data = {0.0f, 0.0f};
                    std::array<int64_t, 1> shape{2};

                    Ort::Env env;

                    auto memory_info = Ort::MemoryInfo::CreateCpu(OrtDeviceAllocator, OrtMemTypeCPU);
                    auto tensor = Ort::Value::CreateTensor<float>(memory_info, data.data(), data.size(), shape.data(), shape.size());
                }
            ]]}, {configs = {languages = "c++17"}, includes = "onnxruntime_cxx_api.h"}))
        end
    end)
