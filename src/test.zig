const wgpu = @import("webgpu.json.zig");
const std = @import("std");

test "Device & Adapter" {
    std.testing.log_level = .debug;
    var instance = wgpu.createInstance(null);
    defer instance.deinit();

    var adapter = wgpu.helpers.requestAdapterSync(instance, null, std.testing.io).?;
    defer adapter.deinit();

    var device = wgpu.helpers.requestDeviceSync(adapter, null, std.testing.io).?;
    defer device.deinit();
    var adapter_info = std.mem.zeroes(wgpu.AdapterInfo);
    const status = device.getAdapterInfo(&adapter_info);
    try std.testing.expect(status == .success);
    std.debug.print("{}", .{adapter_info});
}
