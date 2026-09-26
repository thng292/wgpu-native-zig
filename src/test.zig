const wgpu = @import("webgpu.json.zig");
const std = @import("std");

test "Device & Adapter" {
    // std.testing.log_level = .debug;
    defer std.log.debug("IT WORKED FINE!!!", .{});
    var instance = wgpu.createInstance(null);
    defer {
        instance.deinit();
        std.log.debug("Instance deinited", .{});
    }

    var adapter = wgpu.helpers.requestAdapterSync(instance, null, std.testing.io).?;
    defer {
        adapter.deinit();
        std.log.debug("Adapter deinited", .{});
    }

    var device = wgpu.helpers.requestDeviceSync(adapter, null, std.testing.io).?;
    defer {
        device.deinit();
        std.log.debug("Device deinited", .{});
    }

    var adapter_info = std.mem.zeroes(wgpu.AdapterInfo);
    defer {
        adapter_info.deinit();
        std.log.debug("Adapter info deinited", .{});
    }
    const status = adapter.getInfo(&adapter_info);

    try std.testing.expect(status == .success);
    // std.debug.print("{}", .{adapter_info});

    var queue = device.getQueue();
    defer {
        queue.deinit();
        std.log.debug("Queue deinited", .{});
    }
}

test "YOU SHALL PASS" {}
