const wgpu = @import("webgpu.json.zig");
const std = @import("std");

const logger = std.log.scoped(.wgpu);

pub fn requestAdapterSync(instance: *wgpu.Instance, options: ?*const wgpu.RequestAdapterOptions, io: std.Io) ?*wgpu.Adapter {
    const CBType = SyncCallback(*wgpu.Adapter, wgpu.RequestAdapterStatus, null);
    var cb: CBType = .{ .io = io };
    cb.init();
    _ = instance.requestAdapter(options, cb.toCallbackInfo(wgpu.RequestAdapterCallbackInfo));
    return cb.await();
}

pub fn requestDeviceSync(adapter: *wgpu.Adapter, descriptor: ?*const wgpu.DeviceDescriptor, io: std.Io) ?*wgpu.Device {
    const CBType = SyncCallback(*wgpu.Device, wgpu.RequestDeviceStatus, null);
    var cb: CBType = .{ .io = io };
    cb.init();
    _ = adapter.requestDevice(descriptor, cb.toCallbackInfo(wgpu.RequestDeviceCallbackInfo));
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
            // done: std.Io.Mutex = .init,
            done: std.Io.Mutex = .{ .state = .init(.locked_once) },
            io: std.Io,

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
                self.done.unlock(self.io);
            }

            pub fn await(self: *@This()) void {
                self.done.lockUncancelable(self.io);
            }

            pub fn tryAwait(self: *@This()) bool {
                return self.done.tryLock();
            }

            pub fn toCallbackInfo(self: *@This(), T: type) T {
                return .{
                    .mode = .allow_process_events,
                    .callback = @This().callback,
                    .userdata1 = @ptrCast(@alignCast(self)),
                };
            }
        };
        return UserData;
    } else {
        const UserData = struct {
            result: ?result_T = null,
            status: status_T = @fromBackingInt(@intCast(1)),
            done: std.Io.Mutex = .{ .state = .init(.locked_once) },
            io: std.Io,

            pub fn init(self: *@This()) void {
                _ = self;
                // self.done.lockUncancelable(self.io);
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
                self.done.unlock(self.io);
            }

            pub fn await(self: *@This()) ?result_T {
                self.done.lockUncancelable(self.io);
                return self.result;
            }

            pub fn tryAwait(self: *@This()) bool {
                return self.done.tryLock();
            }
            pub fn toCallbackInfo(self: *@This(), T: type) T {
                return .{
                    .mode = .allow_process_events,
                    .callback = @This().callback,
                    .userdata1 = @ptrCast(@alignCast(self)),
                };
            }
        };
        return UserData;
    }
}
