package("tokenizers-cpp")
    set_homepage("https://github.com/mrowrpurr/tokenizers-cpp")
    set_description("Cross-platform C++ tokenizer bindings for HuggingFace tokenizers and SentencePiece")
    set_license("Apache-2.0")

    add_urls("https://github.com/mrowrpurr/tokenizers-cpp.git")
    add_versions("mrowrpurr", "mrowrpurr")

    on_install(function(package)
        import("package.tools.xmake").install(package)
    end)
