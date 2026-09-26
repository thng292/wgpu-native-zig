const std = @import("std");
const wgpu = @import("wgpu");

pub fn main(init: std.process.Init) !void {
    _ = init;
    std.debug.print("Hello world!\n", .{});
}
