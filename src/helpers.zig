const wgpu = @import("webgpu.json.zig");
const std = @import("std");

const logger = std.log.scoped(.wgpu);

pub fn requestAdapterSync(instance: *wgpu.Instance, options: ?*const wgpu.RequestAdapterOptions, io: std.Io) ?*wgpu.Adapter {
    const CBType = SyncCallback(*wgpu.Adapter, wgpu.RequestAdapterStatus, null);
    var cb: CBType = .{ .io = io };
    cb.init();
    _ = instance.requestAdapter(options, .{
        .nextInChain = null,
        .mode = .allow_spontaneous,
        .callback = CBType.callback,
        .userdata1 = @ptrCast(@alignCast(&cb)),
        .userdata2 = null,
    });
    return cb.await();
}

pub fn requestDeviceSync(adapter: *wgpu.Adapter, descriptor: ?*const wgpu.DeviceDescriptor, io: std.Io) ?*wgpu.Device {
    const CBType = SyncCallback(*wgpu.Device, wgpu.RequestDeviceStatus, null);
    var cb: CBType = .{ .io = io };
    cb.init();
    _ = adapter.requestDevice(descriptor, .{
        .nextInChain = null,
        .mode = .allow_spontaneous,
        .callback = CBType.callback,
        .userdata1 = @ptrCast(@alignCast(&cb)),
        .userdata2 = null,
    });
    return cb.await();
}

pub fn SyncCallback(
    comptime result_T: type,
    comptime status_T: type,
    comptime isStatusError: ?fn (status: status_T) bool,
) type {
    if (result_T == void) {
        const UserData = struct {
            status: status_T = @fromBackingInt(@intCast(1)),
            done: std.Io.Mutex = .init,
            io: std.Io,

            pub fn init(self: *@This()) void {
                std.Io.Mutex.lockUncancelable(self.done, self.io);
            }

            pub fn callback(
                status: status_T,
                message: wgpu.StringView,
                user_data1: ?*void,
                _: ?*void,
            ) callconv(.c) void {
                const self: *@This() = @ptrCast(@alignCast(user_data1.?));
                self.status = status;

                if (message.toSlice()) |msg| {
                    logger.err("{s}", .{msg});
                }
                std.Io.Mutex.unlock(&self.done, self.io.*);
            }

            pub fn await(self: @This()) ?result_T {
                std.Io.Mutex.lockUncancelable(&self.done, self.io);
                return self.result;
            }
        };
        return UserData;
    } else {
        const UserData = struct {
            result: ?result_T = null,
            status: status_T = @fromBackingInt(@intCast(1)),
            done: std.Io.Mutex = .init,
            io: std.Io,

            pub fn init(self: *@This()) void {
                std.Io.Mutex.lockUncancelable(&self.done, self.io);
            }

            pub fn callback(
                status: status_T,
                result: ?result_T,
                message: wgpu.StringView,
                user_data1: ?*void,
                _: ?*void,
            ) callconv(.c) void {
                const self: *@This() = @ptrCast(@alignCast(user_data1.?));
                self.status = status;
                self.result = result;
                if (isStatusError) |func| {
                    if (func(status)) {
                        self.result = result;
                    } else {
                        self.result = null;
                    }
                }

                if (message.toSlice()) |msg| {
                    logger.err("{s}", .{msg});
                }
                std.Io.Mutex.unlock(&self.done, self.io);
            }

            pub fn await(self: *@This()) ?result_T {
                std.Io.Mutex.lockUncancelable(&self.done, self.io);
                return self.result;
            }
        };
        return UserData;
    }
}
