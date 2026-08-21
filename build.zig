const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const c = b.addTranslateC(.{
        .root_source_file = b.path("lib/tiny_obj_c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const mod = b.addModule("tiny_obj", .{
        .root_source_file = b.path("root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .imports = &.{ .{.name = "c", .module = c.createModule()} }
    });
    mod.addCSourceFile(.{ .file = b.path("lib/tiny_obj_c.c") });
    mod.addCSourceFile(.{ .file = b.path("lib/tobj_tess.c") });

    const tests = b.addTest(.{
        .root_module = mod,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);
}
