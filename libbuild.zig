// -----------------------------------------
// |           Kiragine 1.1.1              |
// -----------------------------------------
// Copyright © 2020-2020 Mehmet Kaan Uluç <kaanuluc@protonmail.com>
// This software is provided 'as-is', without any express or implied
// warranty. In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would
//    be appreciated but is not required.
//
// 2. Altered source versions must be plainly marked as such, and must not
//    be misrepresented as being the original software.
//
// 3. This notice may not be removed or altered from any source
//    distribution.

const std = @import("std");
const Builder = @import("std").build.Builder;
const Build = @import("std").build;
const Builtin = @import("std").builtin;
const Zig = @import("std").zig;

const globalflags = [_][]const u8{"-std=c99"};

pub var strip = false;

fn setup(exe: *Build.LibExeObjStep, target: Zig.CrossTarget) void {
    const target_os = target.getOsTag();
    switch (target_os) {
        .windows => {
            exe.setTarget(target);

            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("opengl32");

            exe.subsystem = Builtin.SubSystem.Console;
        },
        .linux => {
            exe.setTarget(target);
            exe.linkSystemLibrary("X11");
        },
        else => {},
    }
}

fn compileGLFWWin32(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{"-O2"} ++ globalflags;
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("opengl32");

    exe.defineCMacro("_GLFW_WIN32");

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/wgl_context.c", &flags);

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_init.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_joystick.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_monitor.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_thread.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_time.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/win32_window.c", &flags);
}

fn compileGLFWLinux(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{"-O2"} ++ globalflags;
    exe.linkSystemLibrary("X11");

    exe.defineCMacro("_GLFW_X11");

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/glx_context.c", &flags);

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/posix_thread.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/posix_time.c", &flags);

    //exe.addCSourceFile("include/glfw-3.3.2/src/wl_init.c", &flags);
    //exe.addCSourceFile("include/glfw-3.3.2/src/wl_window.c", &flags);
    //exe.addCSourceFile("include/glfw-3.3.2/src/wl_monitor.c", &flags);

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/x11_init.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/x11_window.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/x11_monitor.c", &flags);

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/xkb_unicode.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/linux_joystick.c", &flags);
}

fn compileGLFWShared(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{"-O2"} ++ globalflags;
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/init.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/context.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/input.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/monitor.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/window.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/vulkan.c", &flags);

    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/osmesa_context.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/glfw-3.3.2/src/egl_context.c", &flags);

    //exe.addCSourceFile("include/glfw-3.3.2/src/null_init.c", &flags);
    //exe.addCSourceFile("include/glfw-3.3.2/src/null_joystick.c", &flags);
    //exe.addCSourceFile("include/glfw-3.3.2/src/null_monitor.c", &flags);
    //exe.addCSourceFile("include/glfw-3.3.2/src/null_window.c", &flags);
}

fn compileFreetypeWin32(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{ "-O2", "-DFT2_BUILD_LIBRARY" } ++ globalflags;
    const p = enginepath ++ "include/freetype-2.10.2/";
    exe.addCSourceFile(p ++ "builds/windows/ftdebug.c", &flags);
    exe.addCSourceFile(p ++ "src/base/ftsystem.c", &flags);
}

fn compileFreetypePosix(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{ "-O2", "-DFT2_BUILD_LIBRARY" } ++ globalflags;
    const p = enginepath ++ "include/freetype-2.10.2/";
    //exe.addCSourceFile(p ++ "builds/unix/ftsystem.c", &flags);
    exe.addCSourceFile(p ++ "src/base/ftdebug.c", &flags);
    exe.addCSourceFile(p ++ "src/base/ftsystem.c", &flags);
}

fn compileFreetypeShared(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    const flags = [_][]const u8{ "-O2", "-DFT2_BUILD_LIBRARY" } ++ globalflags;
    const p = enginepath ++ "include/freetype-2.10.2/";
    const ftpsharedsrc = comptime [_][]const u8{
        p ++ "src/autofit/autofit.c",
        p ++ "src/base/ftbase.c",
        p ++ "src/base/ftbbox.c",
        p ++ "src/base/ftbdf.c",
        p ++ "src/base/ftbitmap.c",
        p ++ "src/base/ftcid.c",
        p ++ "src/base/ftfstype.c",
        p ++ "src/base/ftgasp.c",
        p ++ "src/base/ftglyph.c",
        p ++ "src/base/ftgxval.c",
        p ++ "src/base/ftinit.c",
        p ++ "src/base/ftmm.c",
        p ++ "src/base/ftotval.c",
        p ++ "src/base/ftpatent.c",
        p ++ "src/base/ftpfr.c",
        p ++ "src/base/ftstroke.c",
        p ++ "src/base/ftsynth.c",
        p ++ "src/base/fttype1.c",
        p ++ "src/base/ftwinfnt.c",
        p ++ "src/bdf/bdf.c",
        p ++ "src/bzip2/ftbzip2.c",
        p ++ "src/cache/ftcache.c",
        p ++ "src/cff/cff.c",
        p ++ "src/cid/type1cid.c",
        p ++ "src/gzip/ftgzip.c",
        p ++ "src/lzw/ftlzw.c",
        p ++ "src/pcf/pcf.c",
        p ++ "src/pfr/pfr.c",
        p ++ "src/psaux/psaux.c",
        p ++ "src/pshinter/pshinter.c",
        p ++ "src/psnames/psnames.c",
        p ++ "src/raster/raster.c",
        p ++ "src/sfnt/sfnt.c",
        p ++ "src/smooth/smooth.c",
        p ++ "src/truetype/truetype.c",
        p ++ "src/type1/type1.c",
        p ++ "src/type42/type42.c",
        p ++ "src/winfonts/winfnt.c",
    };

    var i: u32 = 0;
    while (i < ftpsharedsrc.len) : (i += 1) {
        exe.addCSourceFile(ftpsharedsrc[i], &flags);
    }
}

fn addSourceFiles(exe: *Build.LibExeObjStep, target: Zig.CrossTarget, comptime enginepath: []const u8) void {
    exe.linkSystemLibrary("c");

    const target_os = target.getOsTag();
    switch (target_os) {
        .windows => {
            exe.setTarget(target);

            exe.subsystem = Builtin.SubSystem.Console;

            compileGLFWWin32(exe, enginepath);
            compileFreetypeWin32(exe, enginepath);
        },
        .linux => {
            exe.setTarget(target);

            compileGLFWLinux(exe, enginepath);
            compileFreetypePosix(exe, enginepath);
        },
        else => {},
    }

    compileGLFWShared(exe, enginepath);
    compileFreetypeShared(exe, enginepath);

    const flags = [_][]const u8{"-O3"} ++ globalflags;
    exe.addCSourceFile(enginepath ++ "include/onefile/GLAD/gl.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/onefile/stb/image.c", &flags);
    exe.addCSourceFile(enginepath ++ "include/onefile/stb/truetype.c", &flags);
}

fn addIncludeDirs(exe: *Build.LibExeObjStep, comptime enginepath: []const u8) void {
    exe.addIncludeDir(enginepath ++ "include/freetype-2.10.2/include/");
    exe.addIncludeDir(enginepath ++ "include/freetype-2.10.2/include/freetype/config");

    exe.addIncludeDir(enginepath ++ "include/glfw-3.3.2/include/");
    exe.addIncludeDir(enginepath ++ "include/onefile/");
}

pub fn buildExe(b: *Builder, target: Zig.CrossTarget, mode: Builtin.Mode, path: []const u8, name: []const u8, lib: *Build.LibExeObjStep, comptime enginepath: []const u8) *Build.LibExeObjStep {
    const exe = b.addExecutable(name, path);
    exe.strip = strip;
    exe.setOutputDir("build");
    exe.linkSystemLibrary("c");

    setup(exe, target);

    addIncludeDirs(exe, enginepath);

    exe.addLibPath("build/");
    exe.linkSystemLibrary("kiragine");
    exe.addPackagePath("kiragine", enginepath ++ "src/kiragine/kiragine.zig");

    exe.setBuildMode(mode);
    exe.install();

    return exe;
}

pub fn buildExePrimitive(b: *Builder, target: Zig.CrossTarget, mode: Builtin.Mode, path: []const u8, name: []const u8, lib: *Build.LibExeObjStep, comptime enginepath: []const u8) *Build.LibExeObjStep {
    const exe = b.addExecutable(name, path);
    exe.strip = strip;
    exe.setOutputDir("build");
    exe.linkSystemLibrary("c");

    setup(exe, target);

    addIncludeDirs(exe, enginepath);

    exe.addLibPath("build/");
    exe.linkSystemLibrary("kiragine");
    exe.addPackagePath("kira", enginepath ++ "src/kiragine/kira/kira.zig");

    exe.setBuildMode(mode);
    exe.install();

    return exe;
}

pub fn buildEngineStatic(b: *Builder, target: Zig.CrossTarget, mode: Builtin.Mode, comptime enginepath: []const u8) *Build.LibExeObjStep {
    var exe: *Build.LibExeObjStep = undefined;
    exe = b.addStaticLibrary("kiragine", enginepath ++ "src/kiragine/kiragine.zig");
    exe.setOutputDir("build");

    addIncludeDirs(exe, enginepath);
    addSourceFiles(exe, target, enginepath);

    exe.setBuildMode(mode);
    exe.install();

    return exe;
}

pub fn buildEngine(b: *Builder, target: Zig.CrossTarget, mode: Builtin.Mode, comptime enginepath: []const u8) *Build.LibExeObjStep {
    var exe: *Build.LibExeObjStep = undefined;

    // WARN: Building a shared library does not work on windows
    // There is a problem while linking windows dll's with Builder.addSharedLibrary

    //const shared = comptime if (std.Target.current.os.tag == .linux) true else false;
    // Building as dll is problematic, when the windows problem solved, i'll reconsider building as dll
    return buildEngineStatic(b, target, mode, enginepath);

    //exe = b.addSharedLibrary("kiragine", enginepath ++ "src/kiragine/kiragine.zig", .{ .versioned = .{ .major = 1, .minor = 0, .patch = 0 }});
    //exe.setOutputDir("build");

    //exe.addIncludeDir(enginepath ++ "include/glfw-3.3.2/include/");
    //exe.addIncludeDir(enginepath ++ "include/onefile/");
    //addSourceFiles(exe, target, enginepath);

    //exe.setBuildMode(mode);
    //exe.install();

    //return exe;
}
