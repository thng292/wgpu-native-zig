const std = @import("std");
// const wgpu = @import("../src/webgpu.json.zig"); // For zls
const wgpu = @import("wgpu");

const numbers = [_]u32{ 1, 2, 3, 4 };

pub fn main(init: std.process.Init) !void {
    const instance = wgpu.createInstance(null);
    defer instance.deinit();

    const adapter = wgpu.helpers.requestAdapterSync(instance, null, init.io) orelse
        return error.NoAdapter;
    defer adapter.deinit();

    const device = wgpu.helpers.requestDeviceSync(adapter, null, init.io) orelse
        return error.NoDevice;
    defer device.deinit();

    const queue = device.getQueue();
    defer queue.deinit();

    const wgsl_source = wgpu.ShaderSourceWGSL{
        .chain = .{ .next = null, .sType = .shader_source_WGSL },
        .code = .fromSlice(@embedFile("compute-shader.wgsl")),
    };
    const shader_module = device.createShaderModule(&wgpu.ShaderModuleDescriptor{
        .label = .fromSlice("compute shader"),
        .chain = &wgsl_source.chain,
    });
    defer shader_module.deinit();

    var bind_group_layout_entry = std.mem.zeroInit(wgpu.BindGroupLayoutEntry, .{
        .binding = 0,
        .visibility = .{ .compute = true },
        .buffer = .{
            .type = .storage,
            .has_dynamic_offset = wgpu.FALSE,
            .min_binding_size = 0,
        },
    });

    const bind_group_layout = device.createBindGroupLayout(
        &wgpu.BindGroupLayoutDescriptor{
            .label = .fromSlice("bind group layout"),
            .entries_count = 1,
            .entries = @ptrCast(&bind_group_layout_entry),
        },
    );
    defer bind_group_layout.deinit();

    const pipeline_layout = device.createPipelineLayout(&wgpu.PipelineLayoutDescriptor{
        .label = .fromSlice("pipeline layout"),
        .immediate_size = 0,
        .bind_group_layouts_count = 1,
        .bind_group_layouts = (&[_]*const wgpu.BindGroupLayout{bind_group_layout}).ptr,
    });
    defer pipeline_layout.deinit();

    const pipeline = device.createComputePipeline(&wgpu.ComputePipelineDescriptor{
        .label = .fromSlice("compute pipeline"),
        .layout = pipeline_layout,
        .compute = .{
            .module = shader_module,
            .entry_point = .fromSlice("main"),
            .constants_count = 0,
            .constants = (&[_]wgpu.ConstantEntry{}).ptr,
            .chain = null,
        },
    });
    defer pipeline.deinit();

    const buffer_size: u64 = @sizeOf(@TypeOf(numbers));

    const storage_buffer = device.createBuffer(&wgpu.BufferDescriptor{
        .label = .fromSlice("storage buffer"),
        .size = buffer_size,
        .usage = .{ .storage = true, .copy_src = true, .copy_dst = true },
        .mapped_at_creation = wgpu.FALSE,
    }) orelse return error.BufferCreationFailed;
    defer storage_buffer.deinit();

    queue.writeBuffer(storage_buffer, 0, @ptrCast(&numbers), @sizeOf(@TypeOf(numbers)));

    const staging_buffer = device.createBuffer(&wgpu.BufferDescriptor{
        .label = .fromSlice("staging buffer"),
        .size = buffer_size,
        .usage = .{ .copy_dst = true, .map_read = true },
        .mapped_at_creation = wgpu.FALSE,
    }) orelse return error.BufferCreationFailed;
    defer staging_buffer.deinit();

    const bind_group = device.createBindGroup(&wgpu.BindGroupDescriptor{
        .label = .fromSlice("bind group"),
        .layout = bind_group_layout,
        .entries_count = 1,
        .entries = &.{
            wgpu.BindGroupEntry{
                .binding = 0,
                .buffer = storage_buffer,
                .offset = 0,
                .size = buffer_size,
                .sampler = null,
                .texture_view = null,
            },
        },
    });
    defer bind_group.deinit();

    const encoder = device.createCommandEncoder(null);

    const compute_pass = encoder.beginComputePass(null);
    compute_pass.setPipeline(pipeline);
    compute_pass.setBindGroup(0, bind_group, &.{});
    compute_pass.dispatchWorkgroups(numbers.len, 1, 1);
    compute_pass.end();
    compute_pass.deinit();

    encoder.copyBufferToBuffer(storage_buffer, 0, staging_buffer, 0, buffer_size);

    const command_buffer = encoder.finish(null);
    const cmds = [_]*const wgpu.CommandBuffer{command_buffer};
    queue.submit(&cmds);

    const MapState = struct {
        done: bool = false,
        status: wgpu.MapAsyncStatus = .success,

        fn callback(
            status: wgpu.MapAsyncStatus,
            _: wgpu.StringView,
            user_data1: ?*void,
            _: ?*void,
        ) callconv(.c) void {
            const self: *@This() = @ptrCast(@alignCast(user_data1.?));
            self.status = status;
            self.done = true;
        }
    };
    var map_state: MapState = .{};
    _ = staging_buffer.mapAsync(.{ .read = true }, 0, buffer_size, .{
        .nextInChain = null,
        .mode = .allow_process_events,
        .callback = MapState.callback,
        .userdata1 = @ptrCast(@alignCast(&map_state)),
        .userdata2 = null,
    });
    while (!map_state.done) {
        instance.processEvents();
    }
    if (map_state.status != .success) {
        std.debug.print("Failed to map buffer: {}\n", .{map_state.status});
        return error.MapFailed;
    }

    const result_ptr: [*]const u32 = @ptrCast(@alignCast(staging_buffer.getConstMappedRange(0, buffer_size)));
    const result = result_ptr[0..numbers.len];

    std.debug.print("Input:  {any}\n", .{numbers});
    std.debug.print("Output: {any}\n", .{result.*});

    staging_buffer.unmap();
}
