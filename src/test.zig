const wgpu = @import("webgpu.json.zig");
const std = @import("std");

test "Compute" {
    const tmp: wgpu.MapMode = .{ .read = true };
    try std.testing.expect(@as(u64, @bitCast(tmp)) == 0x0000000000000001);
}
