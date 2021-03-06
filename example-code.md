# Examples
More on [examples](https://github.com/Kiakra/Kiragine/tree/master/examples)

## How to compile?

Download this github repo and copy the "libbuild.zig" file to your project for zig's build system

After that all you need to do put this code in `build.zig` file:

```zig
const Builder = @import("std").build.Builder;
usingnamespace @import("libbuild.zig");

pub fn build(b: *Builder) void {
	const target = b.standardTargetOptions(.{});
	const mode = b.standardReleaseOptions();

	const lib = buildEngine(b, target, mode, enginepath); // Note: the 'enginepath' should be a relative path!
	const exe = buildExe(b, target, mode, path, exename, lib, enginepath);
}
```
`zig build` and done!

If you are getting `xx.h` file not found error while compiling on **linux** on ubuntu please install `xorg-dev` package.

## Basic engine initialization
```zig
const std = @import("std");
const engine = @import("kiragine");

const windowWidth = 1024;
const windowHeight = 768;
const targetfps = 60;

var allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
  const callbacks = engine.Callbacks{};
  try engine.init(callbacks, windowWidth, windowHeight, "title", targetfps, allocator);

  try engine.open();
  try engine.update();

  try engine.deinit();
}
```
-------------------------
## Basic engine initialization with game loops
```zig
const std = @import("std");
const engine = @import("kiragine");

const windowWidth = 1024;
const windowHeight = 768;
const targetfps = 60;

fn update(deltatime: f32) anyerror!void {
  // Game logic
}

fn fixedUpdate(fixedtime: f32) anyerror!void {
  // Game logic
}

fn draw() anyerror!void {
  engine.clearScreen(0.1, 0.1, 0.1, 1.0);
  // Draw calls 
}

var allocator = std.heap.page_allocator;

pub fn main() anyerror!void {
  const callbacks = engine.Callbacks{
    .update = update,
    .fixed = fixedUpdate,
    .draw = draw,
  };
  try engine.init(callbacks, windowWidth, windowHeight, "title", targetfps, allocator);

  try engine.open();
  try engine.update();

  try engine.deinit();
}
```
