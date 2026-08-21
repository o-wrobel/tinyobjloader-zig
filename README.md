# TinyObjLoader Zig
vendored bindings for the tinyobjloader C library.

## Example usage

Add `tinyobjloader-zig` to your `build.zig.zon`:

```shell
zig fetch --save git+https://github.com/o-wrobel/tinyobjloader-zig
```

Add it to your `build.zig`:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // ...

    const tinyobj_dep = b.dependency("tinyobjloader", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const tinyobjloader = tinyobj_dep.module("tinyobjloader");

    const exe = b.addExecutable(.{
        .name = "my_program",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "tinyobjloader", .module = tinyobjloader },
            },
        }),
    });
    b.installArtifact(exe);

    // ...
}
```

Load an OBJ file:

```zig
const std = @import("std");
const tobj = @import("tinyobjloader");

pub fn main(init: std.process.Init) !void {
    const filename = "my_model.obj";
    const allocator = init.gpa;

    // Load file text
    const model_file = try std.Io.Dir.cwd().openFile(init.io, filename, .{});
    const file_len = model_file.length(init.io) catch unreachable;
    var file_reader = model_file.reader(init.io, &.{});
    const text = try file_reader.interface.allocRemaining(allocator, .limited64(file_len+1));
    defer allocator.free(text);

    const scene = try tobj.loadFromMemory(text, null);
    std.debug.print("My scene:\n{any}", .{scene});
    
    // ...
}
```
