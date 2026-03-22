package("tokenizers-cpp")
    set_homepage("https://github.com/mrowrpurr/tokenizers-cpp")
    set_description("Cross-platform C++ tokenizer bindings for HuggingFace tokenizers and SentencePiece")
    set_license("Apache-2.0")

    add_urls("https://github.com/mrowrpurr/tokenizers-cpp.git")
    add_versions("mrowrpurr", "mrowrpurr")

    if is_plat("windows", "mingw") then
        add_syslinks("ntdll", "wsock32", "ws2_32", "bcrypt", "iphlpapi", "userenv", "psapi")
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    end

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
