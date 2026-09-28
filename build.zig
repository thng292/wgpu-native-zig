const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.builtin.LinkMode, "linkage", "wgpu-native link mode") orelse .static;
    const examples = b.option([]const u8, "examples", "Build examples, pass as comma separated list");
    const version = b.option([]const u8, "wgpu-version", "wgpu-version to update to, only work with update-wgpu command");

    // Root Modulue
    const mod = b.addModule("wgpu-native-zig", .{
        .root_source_file = b.path("src/webgpu.json.zig"),
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

    // Tests
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // Generation
    const gen_step = b.step("gen", "Generate binding from webgpu.json.");
    const gen_exe = b.addExecutable(.{
        .name = "translate",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/gen.zig"),
            .target = .{
                .query = .fromTarget(&builtin.target),
                .result = builtin.target,
            },
            .optimize = optimize,
        }),
    });

    const gen_run_step = b.addRunArtifact(gen_exe);
    if (b.args) |run_args| {
        gen_run_step.addArgs(run_args);
    }
    gen_step.dependOn(&gen_run_step.step);

    // Examples
    const example_step = b.step("example", "Build examples");

    var iter = std.mem.splitAny(u8, examples orelse "", ",");
    while (iter.next()) |example| {
        const example_mod = b.addModule(example, .{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path(std.mem.concat(b.allocator, u8, &.{
                "examples/",
                example,
                ".zig",
            }) catch unreachable),
        });
        example_mod.addImport("wgpu", mod);
        const example_exe = b.addExecutable(.{ .name = example, .root_module = example_mod });
        const install_step = b.addInstallArtifact(example_exe, .{});
        example_step.dependOn(&install_step.step);
    }

    const update_wgpu = b.step("update-wgpu", "Update wgpu deps from build.zig.zon");
    inline for (entries) |entry| {
        update_wgpu.dependOn(&b.addSystemCommand(&.{
            "zig",
            "fetch",
            "--save=" ++ entry.@"0",
            std.fmt.allocPrint(
                b.allocator,
                entry.@"1",
                .{version orelse DEFAULT_VERSION},
            ) catch unreachable,
        }).step);
    }
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

// Format with version, example: https://github.com/gfx-rs/wgpu-native/releases/download/v29.0.1.1/wgpu-android-aarch64-debug.zip
const DEFAULT_VERSION = "v29.0.1.1";
const entries: []const struct { []const u8, []const u8 } = &.{
    .{ "wgpu_android_aarch64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-aarch64-debug.zip" },
    .{ "wgpu_android_aarch64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-aarch64-release.zip" },
    .{ "wgpu_android_armv7_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-armv7-debug.zip" },
    .{ "wgpu_android_armv7_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-armv7-release.zip" },
    .{ "wgpu_android_i686_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-i686-debug.zip" },
    .{ "wgpu_android_i686_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-i686-release.zip" },
    .{ "wgpu_android_x86_64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-x86_64-debug.zip" },
    .{ "wgpu_android_x86_64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-android-x86_64-release.zip" },
    .{ "wgpu_ios_aarch64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-aarch64-debug.zip" },
    .{ "wgpu_ios_aarch64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-aarch64-release.zip" },
    .{ "wgpu_ios_aarch64_simulator_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-aarch64-simulator-debug.zip" },
    .{ "wgpu_ios_aarch64_simulator_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-aarch64-simulator-release.zip" },
    .{ "wgpu_ios_x86_64_simulator_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-x86_64-simulator-debug.zip" },
    .{ "wgpu_ios_x86_64_simulator_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-ios-x86_64-simulator-release.zip" },
    .{ "wgpu_linux_aarch64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-linux-aarch64-debug.zip" },
    .{ "wgpu_linux_aarch64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-linux-aarch64-release.zip" },
    .{ "wgpu_linux_x86_64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-linux-x86_64-debug.zip" },
    .{ "wgpu_linux_x86_64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-linux-x86_64-release.zip" },
    .{ "wgpu_macos_aarch64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-macos-aarch64-debug.zip" },
    .{ "wgpu_macos_aarch64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-macos-aarch64-release.zip" },
    .{ "wgpu_macos_x86_64_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-macos-x86_64-debug.zip" },
    .{ "wgpu_macos_x86_64_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-macos-x86_64-release.zip" },
    .{ "wgpu_windows_aarch64_msvc_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-aarch64-msvc-debug.zip" },
    .{ "wgpu_windows_aarch64_msvc_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-aarch64-msvc-release.zip" },
    .{ "wgpu_windows_i686_msvc_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-i686-msvc-debug.zip" },
    .{ "wgpu_windows_i686_msvc_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-i686-msvc-release.zip" },
    .{ "wgpu_windows_x86_64_msvc_debug", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-x86_64-msvc-debug.zip" },
    .{ "wgpu_windows_x86_64_msvc_release", "https://github.com/gfx-rs/wgpu-native/releases/download/{s}/wgpu-windows-x86_64-msvc-release.zip" },
};
