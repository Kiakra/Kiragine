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

const getElapsedTime = @import("kira/glfw.zig").getElapsedTime;
const glfw = @import("kira/glfw.zig");
const renderer = @import("kira/renderer.zig");
const gl = @import("kira/gl.zig");
const input = @import("kira/input.zig");
const window = @import("kira/window.zig");

usingnamespace @import("kira/log.zig");
const check = @import("kira/utils.zig").check;

usingnamespace @import("sharedtypes.zig");
usingnamespace @import("renderer.zig");

fn pcloseCallback(handle: ?*c_void) void {
    pwinrun = false;
    if (procs.close) |fun| {
        fun();
    }
}

fn presizeCallback(handle: ?*c_void, w: i32, h: i32) void {
    gl.viewport(0, 0, w, h);
    if (procs.resize) |fun| {
        fun(w, h);
    }
}

fn keyboardCallback(handle: ?*c_void, key: i32, sc: i32, ac: i32, mods: i32) void {
    pinput.handleKeyboard(key, ac) catch unreachable;
}

fn mousebuttonCallback(handle: ?*c_void, key: i32, ac: i32, mods: i32) void {
    pinput.handleMButton(key, ac) catch unreachable;
}

fn mousePosCallback(handle: ?*c_void, x: f64, y: f64) void {
    pmouseX = @floatCast(f32, x);
    pmouseY = @floatCast(f32, y);
}

pub const Callbacks = struct {
    update: ?fn (deltatime: f32) anyerror!void = null,
    fixed: ?fn (fixedtime: f32) anyerror!void = null,
    draw: ?fn () anyerror!void = null,
    resize: ?fn (w: i32, h: i32) void = null,
    close: ?fn () void = null,
};

var pwin: *Window = undefined;
var pwinrun = false;
var pframetime = window.FrameTime{};
var pfps = window.FpsDirect{};
var pinput: *Input = undefined;
var pmouseX: f32 = 0;
var pmouseY: f32 = 0;
var pengineready = false;
var ptargetfps: f64 = 0.0;

// error: inferring error set of return type valid only for function definitions
// var pupdateproc: ?fn (deltatime: f32) !void = null;
//                                       ^
var procs = Callbacks{};

var allocator: *std.mem.Allocator = undefined;

/// Initializes the engine
pub fn init(callbacks: Callbacks, width: i32, height: i32, title: []const u8, fpslimit: u32, alloc: *std.mem.Allocator) !void {
    if (pengineready) return Error.EngineIsInitialized;

    allocator = alloc;

    pwin = try allocator.create(Window);
    pinput = try allocator.create(Input);

    try glfw.init();
    glfw.resizable(false);
    glfw.initGLProfile();

    pwin.* = window.Info{};
    pwin.size.width = width;
    pwin.size.height = height;
    pwin.minsize = pwin.size;
    pwin.maxsize = pwin.size;
    pwin.title = title;
    pwin.callbacks.close = pcloseCallback;
    pwin.callbacks.resize = presizeCallback;
    pwin.callbacks.keyinp = keyboardCallback;
    pwin.callbacks.mouseinp = mousebuttonCallback;
    pwin.callbacks.mousepos = mousePosCallback;

    const sw = glfw.getScreenWidth();
    const sh = glfw.getScreenHeight();

    pwin.position.x = @divTrunc((sw - pwin.size.width), 2);
    pwin.position.y = @divTrunc((sh - pwin.size.height), 2);

    pinput.* = Input{};
    pinput.clearAllBindings();

    try pwin.create(false);
    glfw.makeContext(pwin.handle);
    gl.init();
    gl.setBlending(true);

    if (fpslimit == 0) {
        glfw.vsync(true);
    } else {
        glfw.vsync(false);
    }

    try initRenderer(allocator, pwin);

    setCallbacks(callbacks);
    if (fpslimit != 0) ptargetfps = 1.0 / @intToFloat(f32, fpslimit);
    pengineready = true;

    std.log.info("kiragine -> initialized! Size -> width:{} & height:{} ; Title:{}", .{ pwin.size.width, pwin.size.height, pwin.title });
}

/// Deinitializes the engine
pub fn deinit() Error!void {
    if (!pengineready) return Error.EngineIsNotInitialized;

    deinitRenderer();

    try pwin.destroy();
    gl.deinit();

    glfw.deinit();
    std.log.info("kiragine -> deinitialized!", .{});

    allocator.destroy(pwin);
    allocator.destroy(pinput);
}

/// Opens the window
pub fn open() Error!void {
    if (!pengineready) return Error.EngineIsNotInitialized;
    pwinrun = true;
}

/// Closes the window
pub fn close() Error!void {
    if (!pengineready) return Error.EngineIsNotInitialized;
    pwinrun = false;
}

/// Updates the engine
pub fn update() !void {
    if (!pengineready) return Error.EngineIsNotInitialized;

    // Source: https://gafferongames.com/post/fix_your_timestep/
    var last: f64 = getElapsedTime();
    var accumulator: f64 = 0;
    var dt: f64 = 0.01;

    while (pwinrun) {
        pframetime.start();
        var ftime: f64 = pframetime.current - last;
        if (ftime > 0.25) {
            ftime = 0.25;
        }
        last = pframetime.current;
        accumulator += ftime;

        if (procs.update) |fun| {
            try fun(@floatCast(f32, pframetime.delta));
        }

        if (procs.fixed) |fun| {
            while (accumulator >= dt) : (accumulator -= dt) {
                try fun(@floatCast(f32, dt));
            }
        }
        pinput.handle();

        if (procs.draw) |fun| {
            try fun();
        }

        glfw.sync(pwin.handle);
        glfw.processEvents();

        pframetime.stop();
        pframetime.sleep(ptargetfps);

        pfps = pfps.calculate(pframetime);
    }
}

/// Returns the fps
pub fn getFps() u32 {
    return pfps.fps;
}

/// Returns the window
pub fn getWindow() *Window {
    return pwin;
}

/// Returns the input
pub fn getInput() *Input {
    return pinput;
}

/// Returns the mouse pos x
pub fn getMouseX() f32 {
    return pmouseX;
}

/// Returns the mouse pos y
pub fn getMouseY() f32 {
    return pmouseY;
}

/// Sets the callbacks
pub fn setCallbacks(calls: Callbacks) void {
    procs = calls;
}
