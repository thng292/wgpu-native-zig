const wgpu = @import("webgpu.json.zig");
const std = @import("std");

const logger = std.log.scoped(.wgpu);

pub fn requestAdapterSync(instance: *wgpu.Instance, options: ?*const wgpu.RequestAdapterOptions, io: std.Io) ?*wgpu.Adapter {
    const UserData = struct {
        result: ?*wgpu.Adapter = null,
        done: std.Io.Mutex = .init,
        io: *const std.Io,

        fn callback(status: wgpu.RequestAdapterStatus, adapter: ?*wgpu.Adapter, message: wgpu.StringView, user_data1: ?*void, _: ?*void) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(user_data1.?));
            switch (status) {
                .success => self.result = adapter,
                .@"error" => self.result = null,
                .callback_cancelled => self.result = null,
                .unavailable => self.result = null,
            }
            logger.debug("Request Adapter status: {t}", .{status});
            if (message.toSlice()) |msg| {
                logger.err("{s}", .{msg});
            }
            std.Io.Mutex.unlock(&self.done, self.io.*);
        }
    };
    var user_data: UserData = .{ .io = &io };
    std.Io.Mutex.lockUncancelable(&user_data.done, io);
    _ = instance.requestAdapter(options, .{
        .nextInChain = null,
        .mode = .allow_spontaneous,
        .callback = UserData.callback,
        .userdata1 = @ptrCast(@alignCast(&user_data)),
        .userdata2 = null,
    });
    std.Io.Mutex.lockUncancelable(&user_data.done, io);
    return user_data.result;
}

pub fn requestDeviceSync(adapter: *wgpu.Adapter, descriptor: ?*const wgpu.DeviceDescriptor, io: std.Io) ?*wgpu.Device {
    const UserData = struct {
        result: ?*wgpu.Device = null,
        done: std.Io.Mutex = .init,
        io: *const std.Io,

        fn callback(
            status: wgpu.RequestDeviceStatus,
            device: ?*wgpu.Device,
            message: wgpu.StringView,
            user_data1: ?*void,
            _: ?*void,
        ) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(user_data1.?));
            switch (status) {
                .success => self.result = device,
                .@"error" => self.result = null,
                .callback_cancelled => self.result = null,
            }
            logger.debug("Request Device status: {t}", .{status});
            if (message.toSlice()) |msg| {
                logger.err("{s}", .{msg});
            }
            std.Io.Mutex.unlock(&self.done, self.io.*);
        }
    };
    var user_data: UserData = .{ .io = &io };
    std.Io.Mutex.lockUncancelable(&user_data.done, io);
    _ = adapter.requestDevice(descriptor, .{
        .nextInChain = null,
        .mode = .allow_spontaneous,
        .callback = UserData.callback,
        .userdata1 = @ptrCast(@alignCast(&user_data)),
        .userdata2 = null,
    });
    std.Io.Mutex.lockUncancelable(&user_data.done, io);
    return user_data.result;
}
