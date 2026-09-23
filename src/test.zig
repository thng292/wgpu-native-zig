const wgpu = @import("translated-webgpu.h.zig");
test "Compute" {
    const instance = wgpu.wgpuCreateInstance(null).?;
    _ = wgpu.wgpuInstanceRequestAdapter(instance, null, .{});
}
