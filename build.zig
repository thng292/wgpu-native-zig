const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.builtin.LinkMode, "linkage", "wgpu-native link mode") orelse .static;

    const mod = b.addModule("wgpu-native-zig", .{
        .root_source_file = b.path("src/translated-webgpu.h.zig"),
        .target = target,
        .link_libc = true,
        .link_libcpp = true,
    });
    linkSystemLib(mod, target.result);
    const wgpu = getWGPUDeps(b, target.result, optimize);
    mod.addLibraryPath(wgpu.path("lib/"));
    mod.linkSystemLibrary("wgpu_native", .{
        .needed = true,
        .preferred_link_mode = linkage,
        .use_pkg_config = .no,
    });

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    const gen_step = b.step("gen", "Generate binding from webgpu.json.");
    const gen_exe = b.addExecutable(.{
        .name = "translate",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/gen.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const gen_run_step = b.addRunArtifact(gen_exe);
    if (b.args) |run_args| {
        gen_run_step.addArgs(run_args);
    }
    gen_step.dependOn(&gen_run_step.step);
}

fn getWGPUDeps(b: *std.Build, target: std.Target, optimze: std.builtin.OptimizeMode) *std.Build.Dependency {
    var dep_name: []const u8 = "wgpu_";

    switch (target.os.tag) {
        .linux => {
            if (target.abi.isAndroid()) {
                dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, "android_" }) catch unreachable;
            } else {
                dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, "linux_" }) catch unreachable;
            }
        },
        inline .ios, .macos, .windows => |tag| {
            dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, @tagName(tag) ++ "_" }) catch unreachable;
        },
        inline else => |tag| @panic(std.fmt.comptimePrint("wgpu-native does not support {s}", .{@tagName(tag)})),
    }
    if (target.abi == .simulator) {
        dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, "simulator_" }) catch unreachable;
    }
    switch (target.cpu.arch) {
        inline .aarch64, .x86_64 => |tag| {
            dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, @tagName(tag) ++ "_" }) catch unreachable;
        },
        inline else => |tag| @panic(std.fmt.comptimePrint("wgpu-native does not support {s}", .{@tagName(tag)})),
    }
    if (optimze == .Debug) {
        dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, "debug" }) catch unreachable;
    } else {
        dep_name = std.mem.concat(b.allocator, u8, &.{ dep_name, "release" }) catch unreachable;
    }
    // std.log.debug("dep_name: {s}", .{dep_name});
    if (b.lazyDependency(dep_name, .{})) |dep| {
        return dep;
    }
    return undefined;
}

fn linkSystemLib(compile_step: *std.Build.Module, target: std.Target) void {
    switch (target.os.tag) {
        .windows => {},
        .macos => {
            compile_step.linkSystemLibrary("objc", .{});
            compile_step.linkFramework("Metal", .{});
            compile_step.linkFramework("CoreGraphics", .{});
            compile_step.linkFramework("Foundation", .{});
            compile_step.linkFramework("IOKit", .{});
            compile_step.linkFramework("IOSurface", .{});
            compile_step.linkFramework("QuartzCore", .{});
        },
        else => {},
    }
}
