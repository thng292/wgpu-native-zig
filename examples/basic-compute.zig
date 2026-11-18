const std = @import("std");
// const wgpu = @import("../src/webgpu.json.zig");
const wgpu = @import("wgpu");

const NUM_ELEMENTS = 1000;
const BUFFER_SIZE = NUM_ELEMENTS * 4; // Buffer size, in bytes

// NEED TO FORMAT FOR NUM_ELEMENTS, NOT HARDCODED
const ShaderCode =
    \\ @group(0) @binding(0)
    \\ var<storage, read_write> output: array<f32>;
    \\
    \\ @compute @workgroup_size(64)
    \\ fn main(
    \\   @builtin(global_invocation_id)
    \\   global_id : vec3u,
    \\
    \\   @builtin(local_invocation_id)
    \\   local_id : vec3u,
    \\ ) {
    \\   // Avoid accessing the buffer out of bounds
    \\   if (global_id.x >= 1000) {
    \\     return;
    \\   }
    \\
    \\   output[global_id.x] = f32(global_id.x) * 1000. + f32(local_id.x);
    \\ }
;

pub fn main(init: std.process.Init) !void {
    const wgpu_instance = wgpu.createInstance(null);
    defer wgpu_instance.deinit();
    const wgpu_adapter = wgpu.helpers.requestAdapterSync(wgpu_instance, null, init.io).?;
    defer wgpu_adapter.deinit();
    const wgpu_device = wgpu.helpers.requestDeviceSync(wgpu_adapter, null, init.io).?;
    defer wgpu_device.deinit();

    const output = wgpu_device.createBuffer(&.{
        .usage = .{ .storage = true, .copy_src = true },
        .size = BUFFER_SIZE,
    }).?;
    defer output.deinit();
    const staging_buffer = wgpu_device.createBuffer(&.{
        .usage = .{ .map_read = true, .copy_dst = true },
        .size = BUFFER_SIZE,
    }).?;
    defer staging_buffer.deinit();

    const bind_group_layout_entries = [_]wgpu.BindGroupLayoutEntry{.{
        .binding = 0,
        .visibility = .{ .compute = true },
        .buffer = .{ .type = .storage },
        .binding_array_size = 0,
    }};
    const bind_group_layout = wgpu_device.createBindGroupLayout(&.{
        .entries = &bind_group_layout_entries,
        .entries_count = bind_group_layout_entries.len,
    });
    defer bind_group_layout.deinit();

    const bind_group_entries = [_]wgpu.BindGroupEntry{.{
        .binding = 0,
        .buffer = output,
        .offset = 0,
        .size = BUFFER_SIZE,
        .sampler = null,
        .texture_view = null,
    }};
    const bind_group = wgpu_device.createBindGroup(&.{
        .layout = bind_group_layout,
        .entries = &bind_group_entries,
        .entries_count = bind_group_entries.len,
    });
    defer bind_group.deinit();

    const wgsl_shader_source: wgpu.ShaderSourceWGSL = .{
        .code = .fromSlice(ShaderCode),
        .chain = .{ .next = null, .sType = .shader_source_WGSL },
    };

    const shader_module = wgpu_device.createShaderModule(&.{
        .chain = &wgsl_shader_source.chain,
    });
    defer shader_module.deinit();
    const pipeline_layout = wgpu_device.createPipelineLayout(&.{
        .bind_group_layouts_count = 1,
        .bind_group_layouts = &.{bind_group_layout},
    });
    defer pipeline_layout.deinit();
    const compute_pipeline = wgpu_device.createComputePipeline(&.{
        .compute = .{
            .constants = &.{},
            .constants_count = 0,
            .module = shader_module,
            .entry_point = .fromSlice("main"),
        },
        .layout = pipeline_layout,
    });
    defer compute_pipeline.deinit();

    const command_encoder = wgpu_device.createCommandEncoder(null);
    defer command_encoder.deinit();
    const pass_encoder = command_encoder.beginComputePass(null);
    defer pass_encoder.deinit();
    pass_encoder.setPipeline(compute_pipeline);
    pass_encoder.setBindGroup(0, bind_group, &.{});
    pass_encoder.dispatchWorkgroups(@divCeil(NUM_ELEMENTS, 64), 1, 1);
    pass_encoder.end();
    command_encoder.copyBufferToBuffer(output, 0, staging_buffer, 0, BUFFER_SIZE);

    wgpu_device.getQueue().submit(&.{command_encoder.finish(null)});

    var cb: wgpu.helpers.SyncCallback(void, wgpu.MapAsyncStatus, null) = .{ .io = init.io };
    _ = staging_buffer.mapAsync(
        .{ .read = true },
        0,
        BUFFER_SIZE,
        cb.toCallbackInfo(wgpu.BufferMapCallbackInfo),
    );
    std.log.info("Camed before await", .{});
    while (!cb.tryAwait()) {
        wgpu_instance.processEvents();
    }
    std.log.info("Camed after await", .{});

    const copy_array_buffer: [*]const f32 = @ptrCast(@alignCast(staging_buffer.getConstMappedRange(0, BUFFER_SIZE)));
    for (0..NUM_ELEMENTS) |i| {
        std.debug.print("{}, ", .{copy_array_buffer[i]});
    }
}
