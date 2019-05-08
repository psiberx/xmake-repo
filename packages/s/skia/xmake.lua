package("skia")

    set_homepage("https://skia.org/")
    set_description("A complete 2D graphic library for drawing Text, Geometries, and Images.")

    set_urls("https://skia.googlesource.com/skia.git",
             "https://github.com/google/skia.git")

    add_versions("68046c", "68046cd7be837bd31bc8f0e821a2f82a02dda9cf")

    add_deps("python2", "ninja")

    on_install("macosx", "linux", "windows", function (package)
        os.vrun("git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git --depth 1")
        local pathes = os.getenv("PATH")
        pathes = pathes .. path.envsep() .. path.join(os.curdir(), "depot_tools")
        pathes = pathes .. path.envsep() .. path.join(os.curdir(), "bin")
        local args = {is_official_build = true, is_debug = package:debug()}
        local argstr = ""
        for k, v in pairs(args) do
            argstr = argstr .. ' ' .. k .. '=' .. tostring(v)
        end
        os.vrunv("python2", {"tools/git-sync-deps"}, {envs = {PATH = pathes}})
        os.vrun("bin/gn gen build --args='%s'", argstr)
        os.vrun("ninja -C build")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            SkPaint paint;
            paint.setStyle(SkPaint::kFill_Style);
        ]]}, {configs = {languages = "c++14"}, includes = "core/SkPaint.h", defines = "DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN"}))
    end)