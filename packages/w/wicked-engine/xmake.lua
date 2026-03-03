package("wicked-engine")
    set_homepage("https://github.com/SkyrimScriptingBeta/WickedEngine")
    set_description("Wicked Engine - 3D rendering engine")

    add_urls("https://github.com/SkyrimScriptingBeta/WickedEngine.git")
    add_versions("mrowrpurr", "mrowrpurr")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)

    on_fetch(function(package)
        local result = {}
        result.links = {"WickedEngine", "Jolt", "LUA", "Utility"}
        result.syslinks = {"d3d12", "dxgi", "d3dcompiler", "dxguid", "comdlg32", "shell32"}
        result.linkdirs = {package:installdir("lib")}
        result.includedirs = {package:installdir("include")}
        result.defines = {
            "WIN32=1", "_HAS_EXCEPTIONS=0", "UNICODE", "_UNICODE", "NOMINMAX", "WICKED_CMAKE_BUILD",
            "_XM_SSE4_INTRINSICS_", "_XM_AVX_INTRINSICS_", "_XM_F16C_INTRINSICS_", "_XM_FMA3_INTRINSICS_",
            "JPH_DEBUG_RENDERER",
            "JPH_USE_SSE4_1", "JPH_USE_SSE4_2", "JPH_USE_AVX",
            "JPH_USE_LZCNT", "JPH_USE_TZCNT", "JPH_USE_F16C", "JPH_USE_FMADD"
        }
        return result
    end)
