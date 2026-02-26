package("sqlite3-fts5-vec")
    set_homepage("https://sqlite.org/")
    set_description("SQLite3 with FTS5 full-text search and sqlite-vec vector search")
    set_license("Public Domain", "MIT", "Apache-2.0")

    -- The source is sqlite3 amalgamation; sqlite-vec amalgamation is fetched as a resource
    set_urls("https://sqlite.org/$(version)", {version = function (version)
        local year = "2026"
        local ver = version:rawstr()
        -- Extract just the sqlite3 version part (before the +vec suffix)
        -- e.g. "3.51.0+200.vec0.1.6" -> we want sqlite 3.51.0+200
        local sqlite_version = ver:match("^(.+)%.vec")
        if not sqlite_version then
            sqlite_version = ver
        end
        -- Convert version to sqlite URL format: 3.51.0+200 -> 3510200
        local version_str = sqlite_version:gsub("[.+]", "")
        if #version_str < 7 then
            version_str = version_str .. "00"
        end
        return year .. "/sqlite-autoconf-" .. version_str .. ".tar.gz"
    end})

    -- Version format: <sqlite-version>.vec<sqlite-vec-version>
    add_versions("3.51.0+200.vec0.1.6", "fbd89f866b1403bb66a143065440089dd76100f2238314d92274a082d4f2b7bb")

    add_resources("3.51.0+200.vec0.1.6", "sqlite_vec",
        "https://github.com/asg017/sqlite-vec/releases/download/v0.1.6/sqlite-vec-0.1.6-amalgamation.tar.gz",
        "99b6ec36e9d259d91bd6cb2c053c3a7660f8791eaa66126c882a6a4557e57d6a")

    on_install("!bsd", function (package)
        -- Copy sqlite-vec amalgamation files into our source dir
        local vec_dir = package:resourcedir("sqlite_vec")
        os.cp(path.join(vec_dir, "*.c"), ".")
        os.cp(path.join(vec_dir, "*.h"), ".")

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_encodings("utf-8")

            target("sqlite3")
                set_kind("static")
                add_files("sqlite3.c")
                add_headerfiles("sqlite3.h", "sqlite3ext.h")
                add_defines(
                    "SQLITE_ENABLE_FTS5",
                    "SQLITE_ENABLE_MATH_FUNCTIONS",
                    "SQLITE_ENABLE_EXPLAIN_COMMENTS",
                    "SQLITE_ENABLE_DBPAGE_VTAB",
                    "SQLITE_ENABLE_STMTVTAB",
                    "SQLITE_ENABLE_DBSTAT_VTAB",
                    "SQLITE_THREADSAFE=1",
                    {public = true}
                )
                if is_plat("macosx", "linux", "bsd") then
                    add_syslinks("pthread", "dl")
                end

            target("sqlite-vec")
                set_kind("static")
                add_files("sqlite-vec.c")
                add_headerfiles("sqlite-vec.h")
                add_deps("sqlite3")
                add_defines("SQLITE_VEC_STATIC", {public = true})
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sqlite3_open_v2", {includes = "sqlite3.h"}))
        assert(package:has_cfuncs("sqlite3_vec_init", {includes = "sqlite-vec.h"}))
    end)
