const std = @import("std");
const wgpu = @import("../src/webgpu.json.zig"); // For zls
// const wgpu = @import("wgpu");

const ADD2VEC_SHADERCODE =
    \\@group(0) @binding(0) let<storage, read_only> a: array<u32>;
    \\@group(0) @binding(1) let<storage, read_only> b: array<u32>;
    \\@group(0) @binding(2) let<storage, write_only> c: array<u32>;
    \\
    \\@compute @workgroup_size(32)
    \\fn main(@builtin(global_invocation_id) id: vec3<u32>) {
    \\    c[id.x] = a[id.x] * b[id.x];
    \\}
;

/// A compute pipeline is similar to a compute graph in CUDA
fn createAdd2VecComputePipeline(device: *wgpu.Device, a: []const f32, b: []const f32, c: []f32) *wgpu.ComputePipeline {
    const shader_module = device.createShaderModule(
        &wgpu.ShaderModuleDescriptor{
            .label = .empty,
            .chain = &wgpu.ChainedStruct{
                .sType = .shader_source_WGSL,
                .next = &(wgpu.ShaderSourceWGSL{
                    .chain = .{
                        .next = null,
                        .sType = .shader_source_WGSL,
                    },
                    .code = .fromSlice(ADD2VEC_SHADERCODE),
                }).chain,
            },
        },
    );

    const bind_group_layout = device.createBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
        .entries = &.{
            &wgpu.BindGroupLayoutEntry{
                .binding = 0,
                .binding_array_size = a.len,
                .visibility = .{ .compute = true },
            },
            &wgpu.BindGroupLayoutEntry{
                .binding = 1,
                .binding_array_size = b.len,
                .visibility = .{ .compute = true },
            },
            &wgpu.BindGroupLayoutEntry{
                .binding = 2,
                .binding_array_size = c.len,
                .visibility = .{ .compute = true },
            },
        },
        .entries_count = 3,
    });

    const pipeline = device.createComputePipeline(&wgpu.ComputePipelineDescriptor{
        .compute = .{
            .entry_point = .fromSlice("main"),
            .constants = &.{},
            .constants_count = 0,
            .module = shader_module,
        },
        .layout = &wgpu.PipelineLayoutDescriptor{
            .bind_group_layouts = &.{bind_group_layout},
            .bind_group_layouts_count = 0,
        },
    });

    return pipeline;
}

pub fn main(init: std.process.Init) !void {
    const instance = wgpu.createInstance(null);
    const adapter = wgpu.helpers.requestAdapterSync(instance, &wgpu.RequestAdapterOptions{
        .backend_type = .undefined,
        .compatible_surface = null,
        .feature_level = .core,
        .power_preference = .high_performance,
    }, init.io) //
        orelse return error.CanNotRequestAdapter;
    defer adapter.deinit();
    const device = wgpu.helpers.requestDeviceSync(adapter, null, init.io) //?
        orelse return error.CanNotRequestDevice;
    const queue = device.getQueue();
    defer queue.deinit();

    const command_encoder = device.createCommandEncoder(null);
    defer command_encoder.deinit();

    const command_buffers: std.ArrayList(*wgpu.CommandBuffer) = .empty;
    defer {
        for (command_buffers.items) |command_buffer| {
            command_buffer.deinit();
        }
        command_buffers.deinit(init.gpa);
    }

    {
        const compute_pass_encoder = command_encoder.beginComputePass(null);
        defer compute_pass_encoder.deinit();
        compute_pass_encoder.setPipeline();

        const pipeline = createAdd2VecComputePipeline(device, &.{}, &.{}, &.{});
        compute_pass_encoder.setPipeline(pipeline);
        compute_pass_encoder.setBindGroup(0, null, &.{});
        compute_pass_encoder.dispatchWorkgroups(32, 1, 1);
        compute_pass_encoder.end();

        command_buffers.append(init.gpa, command_encoder.finish(null));
    }
    queue.submit(command_buffers.items);
}
