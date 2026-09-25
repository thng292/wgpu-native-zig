//! Copyright 2019-2023 WebGPU-Native developers
//!
//! SPDX-License-Identifier: BSD-3-Clause
//! **Important:** *This documentation is a Work In Progress.*
//!
//! This is the home of WebGPU C API specification. We define here the standard
//! `webgpu.h` header that all implementations should provide.
//!
//! For all details where behavior is not otherwise specified, `webgpu.h` has
//! the same behavior as the WebGPU specification for JavaScript on the Web.
//! The WebIDL-based Web specification is mapped into C as faithfully (and
//! bidirectionally) as practical/possible.
//! The working draft of WebGPU can be found at <https://www.w3.org/TR/webgpu/>.
//!
//! The standard include directive for this header is `#include <webgpu/webgpu.h>`
//! (if it is provided in a system-wide or toolchain-wide include directory).
// --------------------TEMPLATE_START--------------------

const std = @import("std");

test {
    const tests = @import("test.zig");
    std.testing.refAllDecls(tests);
}

// These are some hard-coded values.
const UINT32_MAX = std.math.maxInt(u32);
const UINT64_MAX = std.math.maxInt(u64);
const USIZE_MAX = std.math.maxInt(usize);
const NAN = std.math.nan(f32);

// predefined types
pub const Flags = u64;
pub const Bool = u32;

pub const TRUE: u32 = 1;
pub const FALSE: u32 = 0;

pub const StringView = extern struct {
    data: ?[*]const u8 = null,
    length: usize = 0,

    /// Helper to construct a StringView from a standard Zig slice.
    pub fn fromSlice(slice: []const u8) StringView {
        return .{
            .data = slice.ptr,
            .length = slice.len,
        };
    }

    /// Helper to convert the StringView into a Zig slice if data is not null.
    pub fn toSlice(self: StringView) ?[]const u8 {
        const ptr = self.data orelse return null;
        return ptr[0..self.length];
    }
};

pub const WGPUProc = ?*const fn () callconv(.c) void;
/// Returns the "procedure address" (function pointer) of the named function.
/// The result must be cast to the appropriate proc pointer type.
pub extern "C" fn wgpuGetProcAddress(procName: StringView) WGPUProc;

pub const ChainedStruct = extern struct {
    next: ?*ChainedStruct,
    sType: SType,
};

// --------------------TEMPLATE_END----------------------
/// Indicates no array layer count is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const ARRAY_LAYER_COUNT_UNDEFINED = UINT32_MAX;

/// Indicates no copy stride is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const COPY_STRIDE_UNDEFINED = UINT32_MAX;

/// Indicates no depth clear value is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const DEPTH_CLEAR_VALUE_UNDEFINED = NAN;

/// Indicates no depth slice is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const DEPTH_SLICE_UNDEFINED = UINT32_MAX;

/// For `uint32_t` limits, indicates no limit value is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const LIMIT_U32_UNDEFINED = UINT32_MAX;

/// For `uint64_t` limits, indicates no limit value is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const LIMIT_U64_UNDEFINED = UINT64_MAX;

/// Indicates no mip level count is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const MIP_LEVEL_COUNT_UNDEFINED = UINT32_MAX;

/// Indicates no query set index is specified. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const QUERY_SET_INDEX_UNDEFINED = UINT32_MAX;

/// Sentinel value used in @ref WGPUStringView to indicate that the pointer
/// is to a null-terminated string, rather than an explicitly-sized string.
pub const STRLEN = USIZE_MAX;

/// Indicates a size extending to the end of the buffer. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const WHOLE_MAP_SIZE = USIZE_MAX;

/// Indicates a size extending to the end of the buffer. For more info,
/// see @ref SentinelValues and the places that use this sentinel value.
pub const WHOLE_SIZE = UINT64_MAX;

/// TODO
pub const AdapterType = enum(u32) {
    /// TODO
    discrete_GPU,
    /// TODO
    integrated_GPU,
    /// TODO
    CPU,
    /// TODO
    unknown,
};

/// TODO
pub const AddressMode = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    clamp_to_edge,
    /// TODO
    repeat,
    /// TODO
    mirror_repeat,
};

/// TODO
pub const BackendType = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    null,
    /// TODO
    WebGPU,
    /// TODO
    D3D11,
    /// TODO
    D3D12,
    /// TODO
    metal,
    /// TODO
    vulkan,
    /// TODO
    openGL,
    /// TODO
    openGLES,
};

/// TODO
pub const BlendFactor = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    zero,
    /// TODO
    one,
    /// TODO
    src,
    /// TODO
    one_minus_src,
    /// TODO
    src_alpha,
    /// TODO
    one_minus_src_alpha,
    /// TODO
    dst,
    /// TODO
    one_minus_dst,
    /// TODO
    dst_alpha,
    /// TODO
    one_minus_dst_alpha,
    /// TODO
    src_alpha_saturated,
    /// TODO
    constant,
    /// TODO
    one_minus_constant,
    /// TODO
    src1,
    /// TODO
    one_minus_src1,
    /// TODO
    src1_alpha,
    /// TODO
    one_minus_src1_alpha,
};

/// TODO
pub const BlendOperation = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    add,
    /// TODO
    subtract,
    /// TODO
    reverse_subtract,
    /// TODO
    min,
    /// TODO
    max,
};

/// TODO
pub const BufferBindingType = enum(u32) {
    /// Indicates that this @ref WGPUBufferBindingLayout member of
    /// its parent @ref WGPUBindGroupLayoutEntry is not used.
    /// (See also @ref SentinelValues.)
    binding_not_used,
    /// `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    uniform,
    /// TODO
    storage,
    /// TODO
    read_only_storage,
};

/// TODO
pub const BufferMapState = enum(u32) {
    /// TODO
    unmapped,
    /// TODO
    pending,
    /// TODO
    mapped,
};

/// The callback mode controls how a callback for an asynchronous operation may be fired. See @ref Asynchronous-Operations for how these are used.
pub const CallbackMode = enum(u32) {
    /// Callbacks created with `WGPUCallbackMode_WaitAnyOnly`:
    /// - fire when the asynchronous operation's future is passed to a call to @ref wgpuInstanceWaitAny
    ///   AND the operation has already completed or it completes inside the call to @ref wgpuInstanceWaitAny.
    wait_any_only,
    /// Callbacks created with `WGPUCallbackMode_AllowProcessEvents`:
    /// - fire for the same reasons as callbacks created with `WGPUCallbackMode_WaitAnyOnly`
    /// - fire inside a call to @ref wgpuInstanceProcessEvents if the asynchronous operation is complete.
    allow_process_events,
    /// Callbacks created with `WGPUCallbackMode_AllowSpontaneous`:
    /// - fire for the same reasons as callbacks created with `WGPUCallbackMode_AllowProcessEvents`
    /// - **may** fire spontaneously on an arbitrary or application thread, when the WebGPU implementations discovers that the asynchronous operation is complete.
    ///
    ///   Implementations _should_ fire spontaneous callbacks as soon as possible.
    ///
    /// @note Because spontaneous callbacks may fire at an arbitrary time on an arbitrary thread, applications should take extra care when acquiring locks or mutating state inside the callback. It undefined behavior to re-entrantly call into the webgpu.h API if the callback fires while inside the callstack of another webgpu.h function that is not `wgpuInstanceWaitAny` or `wgpuInstanceProcessEvents`.
    allow_spontaneous,
};

/// TODO
pub const CompareFunction = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    never,
    /// TODO
    less,
    /// TODO
    equal,
    /// TODO
    less_equal,
    /// TODO
    greater,
    /// TODO
    not_equal,
    /// TODO
    greater_equal,
    /// TODO
    always,
};

/// TODO
pub const CompilationInfoRequestStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
};

/// TODO
pub const CompilationMessageType = enum(u32) {
    /// TODO
    @"error",
    /// TODO
    warning,
    /// TODO
    info,
};

/// TODO
pub const ComponentSwizzle = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// Force its value to 0.
    zero,
    /// Force its value to 1.
    one,
    /// Take its value from the red channel of the texture.
    r,
    /// Take its value from the green channel of the texture.
    g,
    /// Take its value from the blue channel of the texture.
    b,
    /// Take its value from the alpha channel of the texture.
    a,
};

/// Describes how frames are composited with other contents on the screen when @ref wgpuSurfacePresent is called.
pub const CompositeAlphaMode = enum(u32) {
    /// Lets the WebGPU implementation choose the best mode (supported, and with the best performance) between @ref WGPUCompositeAlphaMode_Opaque or @ref WGPUCompositeAlphaMode_Inherit.
    auto,
    /// The alpha component of the image is ignored and teated as if it is always 1.0.
    @"opaque",
    /// The alpha component is respected and non-alpha components are assumed to be already multiplied with the alpha component. For example, (0.5, 0, 0, 0.5) is semi-transparent bright red.
    premultiplied,
    /// The alpha component is respected and non-alpha components are assumed to NOT be already multiplied with the alpha component. For example, (1.0, 0, 0, 0.5) is semi-transparent bright red.
    unpremultiplied,
    /// The handling of the alpha component is unknown to WebGPU and should be handled by the application using system-specific APIs. This mode may be unavailable (for example on Wasm).
    inherit,
};

/// TODO
pub const CreatePipelineAsyncStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// TODO
    validation_error,
    /// TODO
    internal_error,
};

/// TODO
pub const CullMode = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    none,
    /// TODO
    front,
    /// TODO
    back,
};

/// TODO
pub const DeviceLostReason = enum(u32) {
    /// TODO
    unknown,
    /// TODO
    destroyed,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// TODO
    failed_creation,
};

/// TODO
pub const ErrorFilter = enum(u32) {
    /// TODO
    validation,
    /// TODO
    out_of_memory,
    /// TODO
    internal,
};

/// TODO
pub const ErrorType = enum(u32) {
    /// TODO
    no_error,
    /// TODO
    validation,
    /// TODO
    out_of_memory,
    /// TODO
    internal,
    /// TODO
    unknown,
};

/// See @ref WGPURequestAdapterOptions::featureLevel.
pub const FeatureLevel = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// "Compatibility" profile which can be supported on OpenGL ES 3.1 and D3D11.
    compatibility,
    /// "Core" profile which can be supported on Vulkan/Metal/D3D12 (at least).
    core,
};

/// TODO
pub const FeatureName = enum(u32) {
    /// TODO
    core_features_and_limits,
    /// TODO
    depth_clip_control,
    /// TODO
    depth32_float_stencil8,
    /// TODO
    texture_compression_BC,
    /// TODO
    texture_compression_BC_sliced_3D,
    /// TODO
    texture_compression_ETC2,
    /// TODO
    texture_compression_ASTC,
    /// TODO
    texture_compression_ASTC_sliced_3D,
    /// TODO
    timestamp_query,
    /// TODO
    indirect_first_instance,
    /// TODO
    shader_f16,
    /// TODO
    RG11B10_ufloat_renderable,
    /// TODO
    BGRA8_unorm_storage,
    /// TODO
    float32_filterable,
    /// TODO
    float32_blendable,
    /// TODO
    clip_distances,
    /// TODO
    dual_source_blending,
    /// TODO
    subgroups,
    /// TODO
    texture_formats_tier_1,
    /// TODO
    texture_formats_tier_2,
    /// TODO
    primitive_index,
    /// TODO
    texture_component_swizzle,
    /// TODO
    subgroup_size_control,
    /// TODO
    texture_compression_unaligned,
};

/// TODO
pub const FilterMode = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    nearest,
    /// TODO
    linear,
};

/// TODO
pub const FrontFace = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    CCW,
    /// TODO
    CW,
};

/// TODO
pub const IndexFormat = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    uint16,
    /// TODO
    uint32,
};

/// TODO
pub const InstanceFeatureName = enum(u32) {
    /// Enable use of ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any,
    /// Enable passing SPIR-V shaders to @ref wgpuDeviceCreateShaderModule,
    /// via @ref WGPUShaderSourceSPIRV.
    shader_source_SPIRV,
    /// Normally, a @ref WGPUAdapter can only create a single device. If this is
    /// available and enabled, then adapters won't immediately expire when they
    /// create a device, so can be reused to make multiple devices. They may
    /// still expire for other reasons.
    multiple_devices_per_adapter,
};

/// TODO
pub const LoadOp = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    load,
    /// TODO
    clear,
};

/// TODO
pub const MapAsyncStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// TODO
    @"error",
    /// TODO
    aborted,
};

/// TODO
pub const MipmapFilterMode = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    nearest,
    /// TODO
    linear,
};

/// TODO
pub const OptionalBool = enum(u32) {
    /// TODO
    false,
    /// TODO
    true,
    /// TODO
    undefined,
};

/// TODO
pub const PopErrorScopeStatus = enum(u32) {
    /// The error scope stack was successfully popped and a result was reported.
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// The error scope stack could not be popped, because it was empty.
    @"error",
};

/// TODO
pub const PowerPreference = enum(u32) {
    /// No preference. (See also @ref SentinelValues.)
    undefined,
    /// TODO
    low_power,
    /// TODO
    high_performance,
};

/// TODO
pub const PredefinedColorSpace = enum(u32) {
    /// TODO
    SRGB,
    /// TODO
    display_p3,
};

/// Describes when and in which order frames are presented on the screen when @ref wgpuSurfacePresent is called.
pub const PresentMode = enum(u32) {
    /// Present mode is not specified. Use the default.
    undefined,
    /// The presentation of the image to the user waits for the next vertical blanking period to update in a first-in, first-out manner.
    /// Tearing cannot be observed and frame-loop will be limited to the display's refresh rate.
    /// This is the only mode that's always available.
    fifo,
    /// The presentation of the image to the user tries to wait for the next vertical blanking period but may decide to not wait if a frame is presented late.
    /// Tearing can sometimes be observed but late-frame don't produce a full-frame stutter in the presentation.
    /// This is still a first-in, first-out mechanism so a frame-loop will be limited to the display's refresh rate.
    fifo_relaxed,
    /// The presentation of the image to the user is updated immediately without waiting for a vertical blank.
    /// Tearing can be observed but latency is minimized.
    immediate,
    /// The presentation of the image to the user waits for the next vertical blanking period to update to the latest provided image.
    /// Tearing cannot be observed and a frame-loop is not limited to the display's refresh rate.
    mailbox,
};

/// TODO
pub const PrimitiveTopology = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    point_list,
    /// TODO
    line_list,
    /// TODO
    line_strip,
    /// TODO
    triangle_list,
    /// TODO
    triangle_strip,
};

/// TODO
pub const QueryType = enum(u32) {
    /// TODO
    occlusion,
    /// TODO
    timestamp,
};

/// TODO
pub const QueueWorkDoneStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// There was some deterministic error. (Note this is currently never used,
    /// but it will be relevant when it's possible to create a queue object.)
    @"error",
};

/// TODO
pub const RequestAdapterStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// TODO
    unavailable,
    /// TODO
    @"error",
};

/// TODO
pub const RequestDeviceStatus = enum(u32) {
    /// TODO
    success,
    /// See @ref CallbackStatuses.
    callback_cancelled,
    /// TODO
    @"error",
};

/// TODO
pub const SType = enum(u32) {
    /// TODO
    shader_source_SPIRV,
    /// TODO
    shader_source_WGSL,
    /// TODO
    render_pass_max_draw_count,
    /// TODO
    surface_source_metal_layer,
    /// TODO
    surface_source_windows_HWND,
    /// TODO
    surface_source_xlib_window,
    /// TODO
    surface_source_wayland_surface,
    /// TODO
    surface_source_android_native_window,
    /// TODO
    surface_source_XCB_window,
    /// TODO
    surface_color_management,
    /// TODO
    request_adapter_WebXR_options,
    /// TODO
    texture_component_swizzle_descriptor,
    /// TODO
    external_texture_binding_layout,
    /// TODO
    external_texture_binding_entry,
    /// TODO
    compatibility_mode_limits,
    /// TODO
    texture_binding_view_dimension,
};

/// TODO
pub const SamplerBindingType = enum(u32) {
    /// Indicates that this @ref WGPUSamplerBindingLayout member of
    /// its parent @ref WGPUBindGroupLayoutEntry is not used.
    /// (See also @ref SentinelValues.)
    binding_not_used,
    /// `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    filtering,
    /// TODO
    non_filtering,
    /// TODO
    comparison,
};

/// Status code returned (synchronously) from many operations. Generally
/// indicates an invalid input like an unknown enum value or @ref OutStructChainError.
/// Read the function's documentation for specific error conditions.
pub const Status = enum(u32) {
    success,
    @"error",
};

/// TODO
pub const StencilOperation = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    keep,
    /// TODO
    zero,
    /// TODO
    replace,
    /// TODO
    invert,
    /// TODO
    increment_clamp,
    /// TODO
    decrement_clamp,
    /// TODO
    increment_wrap,
    /// TODO
    decrement_wrap,
};

/// TODO
pub const StorageTextureAccess = enum(u32) {
    /// Indicates that this @ref WGPUStorageTextureBindingLayout member of
    /// its parent @ref WGPUBindGroupLayoutEntry is not used.
    /// (See also @ref SentinelValues.)
    binding_not_used,
    /// `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    write_only,
    /// TODO
    read_only,
    /// TODO
    read_write,
};

/// TODO
pub const StoreOp = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    store,
    /// TODO
    discard,
};

/// The status enum for @ref wgpuSurfaceGetCurrentTexture.
pub const SurfaceGetCurrentTextureStatus = enum(u32) {
    /// Yay! Everything is good and we can render this frame.
    success_optimal,
    /// Still OK - the surface can present the frame, but in a suboptimal way. The surface may need reconfiguration.
    success_suboptimal,
    /// Some operation timed out while trying to acquire the frame.
    timeout,
    /// The surface is too different to be used, compared to when it was originally created.
    outdated,
    /// The connection to whatever owns the surface was lost, or generally needs to be fully reinitialized.
    lost,
    /// There was some deterministic error (for example, the surface is not configured, or there was an @ref OutStructChainError). Should produce @ref ImplementationDefinedLogging containing details.
    @"error",
};

/// TODO
pub const TextureAspect = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    all,
    /// TODO
    stencil_only,
    /// TODO
    depth_only,
};

/// TODO
pub const TextureDimension = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    @"1D",
    /// TODO
    @"2D",
    /// TODO
    @"3D",
};

/// TODO
pub const TextureFormat = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    R8_unorm,
    /// TODO
    R8_snorm,
    /// TODO
    R8_uint,
    /// TODO
    R8_sint,
    /// TODO
    R16_unorm,
    /// TODO
    R16_snorm,
    /// TODO
    R16_uint,
    /// TODO
    R16_sint,
    /// TODO
    R16_float,
    /// TODO
    RG8_unorm,
    /// TODO
    RG8_snorm,
    /// TODO
    RG8_uint,
    /// TODO
    RG8_sint,
    /// TODO
    R32_float,
    /// TODO
    R32_uint,
    /// TODO
    R32_sint,
    /// TODO
    RG16_unorm,
    /// TODO
    RG16_snorm,
    /// TODO
    RG16_uint,
    /// TODO
    RG16_sint,
    /// TODO
    RG16_float,
    /// TODO
    RGBA8_unorm,
    /// TODO
    RGBA8_unorm_srgb,
    /// TODO
    RGBA8_snorm,
    /// TODO
    RGBA8_uint,
    /// TODO
    RGBA8_sint,
    /// TODO
    BGRA8_unorm,
    /// TODO
    BGRA8_unorm_srgb,
    /// TODO
    RGB10_A2_uint,
    /// TODO
    RGB10_A2_unorm,
    /// TODO
    RG11_B10_ufloat,
    /// TODO
    RGB9_E5_ufloat,
    /// TODO
    RG32_float,
    /// TODO
    RG32_uint,
    /// TODO
    RG32_sint,
    /// TODO
    RGBA16_unorm,
    /// TODO
    RGBA16_snorm,
    /// TODO
    RGBA16_uint,
    /// TODO
    RGBA16_sint,
    /// TODO
    RGBA16_float,
    /// TODO
    RGBA32_float,
    /// TODO
    RGBA32_uint,
    /// TODO
    RGBA32_sint,
    /// TODO
    stencil8,
    /// TODO
    depth16_unorm,
    /// TODO
    depth24_plus,
    /// TODO
    depth24_plus_stencil8,
    /// TODO
    depth32_float,
    /// TODO
    depth32_float_stencil8,
    /// TODO
    BC1_RGBA_unorm,
    /// TODO
    BC1_RGBA_unorm_srgb,
    /// TODO
    BC2_RGBA_unorm,
    /// TODO
    BC2_RGBA_unorm_srgb,
    /// TODO
    BC3_RGBA_unorm,
    /// TODO
    BC3_RGBA_unorm_srgb,
    /// TODO
    BC4_R_unorm,
    /// TODO
    BC4_R_snorm,
    /// TODO
    BC5_RG_unorm,
    /// TODO
    BC5_RG_snorm,
    /// TODO
    BC6H_RGB_ufloat,
    /// TODO
    BC6H_RGB_float,
    /// TODO
    BC7_RGBA_unorm,
    /// TODO
    BC7_RGBA_unorm_srgb,
    /// TODO
    ETC2_RGB8_unorm,
    /// TODO
    ETC2_RGB8_unorm_srgb,
    /// TODO
    ETC2_RGB8A1_unorm,
    /// TODO
    ETC2_RGB8A1_unorm_srgb,
    /// TODO
    ETC2_RGBA8_unorm,
    /// TODO
    ETC2_RGBA8_unorm_srgb,
    /// TODO
    EAC_R11_unorm,
    /// TODO
    EAC_R11_snorm,
    /// TODO
    EAC_RG11_unorm,
    /// TODO
    EAC_RG11_snorm,
    /// TODO
    ASTC_4x4_unorm,
    /// TODO
    ASTC_4x4_unorm_srgb,
    /// TODO
    ASTC_5x4_unorm,
    /// TODO
    ASTC_5x4_unorm_srgb,
    /// TODO
    ASTC_5x5_unorm,
    /// TODO
    ASTC_5x5_unorm_srgb,
    /// TODO
    ASTC_6x5_unorm,
    /// TODO
    ASTC_6x5_unorm_srgb,
    /// TODO
    ASTC_6x6_unorm,
    /// TODO
    ASTC_6x6_unorm_srgb,
    /// TODO
    ASTC_8x5_unorm,
    /// TODO
    ASTC_8x5_unorm_srgb,
    /// TODO
    ASTC_8x6_unorm,
    /// TODO
    ASTC_8x6_unorm_srgb,
    /// TODO
    ASTC_8x8_unorm,
    /// TODO
    ASTC_8x8_unorm_srgb,
    /// TODO
    ASTC_10x5_unorm,
    /// TODO
    ASTC_10x5_unorm_srgb,
    /// TODO
    ASTC_10x6_unorm,
    /// TODO
    ASTC_10x6_unorm_srgb,
    /// TODO
    ASTC_10x8_unorm,
    /// TODO
    ASTC_10x8_unorm_srgb,
    /// TODO
    ASTC_10x10_unorm,
    /// TODO
    ASTC_10x10_unorm_srgb,
    /// TODO
    ASTC_12x10_unorm,
    /// TODO
    ASTC_12x10_unorm_srgb,
    /// TODO
    ASTC_12x12_unorm,
    /// TODO
    ASTC_12x12_unorm_srgb,
};

/// TODO
pub const TextureSampleType = enum(u32) {
    /// Indicates that this @ref WGPUTextureBindingLayout member of
    /// its parent @ref WGPUBindGroupLayoutEntry is not used.
    /// (See also @ref SentinelValues.)
    binding_not_used,
    /// `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    float,
    /// TODO
    unfilterable_float,
    /// TODO
    depth,
    /// TODO
    sint,
    /// TODO
    uint,
};

/// TODO
pub const TextureViewDimension = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    @"1D",
    /// TODO
    @"2D",
    /// TODO
    @"2D_array",
    /// TODO
    cube,
    /// TODO
    cube_array,
    /// TODO
    @"3D",
};

/// TODO
pub const ToneMappingMode = enum(u32) {
    /// TODO
    standard,
    /// TODO
    extended,
};

/// TODO
pub const VertexFormat = enum(u32) {
    /// TODO
    uint8,
    /// TODO
    uint8x2,
    /// TODO
    uint8x4,
    /// TODO
    sint8,
    /// TODO
    sint8x2,
    /// TODO
    sint8x4,
    /// TODO
    unorm8,
    /// TODO
    unorm8x2,
    /// TODO
    unorm8x4,
    /// TODO
    snorm8,
    /// TODO
    snorm8x2,
    /// TODO
    snorm8x4,
    /// TODO
    uint16,
    /// TODO
    uint16x2,
    /// TODO
    uint16x4,
    /// TODO
    sint16,
    /// TODO
    sint16x2,
    /// TODO
    sint16x4,
    /// TODO
    unorm16,
    /// TODO
    unorm16x2,
    /// TODO
    unorm16x4,
    /// TODO
    snorm16,
    /// TODO
    snorm16x2,
    /// TODO
    snorm16x4,
    /// TODO
    float16,
    /// TODO
    float16x2,
    /// TODO
    float16x4,
    /// TODO
    float32,
    /// TODO
    float32x2,
    /// TODO
    float32x3,
    /// TODO
    float32x4,
    /// TODO
    uint32,
    /// TODO
    uint32x2,
    /// TODO
    uint32x3,
    /// TODO
    uint32x4,
    /// TODO
    sint32,
    /// TODO
    sint32x2,
    /// TODO
    sint32x3,
    /// TODO
    sint32x4,
    /// TODO
    unorm10__10__10__2,
    /// TODO
    unorm8x4_B_G_R_A,
    /// TODO
    snorm10__10__10__2,
};

/// TODO
pub const VertexStepMode = enum(u32) {
    /// Indicates no value is passed for this argument. See @ref SentinelValues.
    undefined,
    /// TODO
    vertex,
    /// TODO
    instance,
};

/// Status returned from a call to ::wgpuInstanceWaitAny.
pub const WaitStatus = enum(u32) {
    /// At least one WGPUFuture completed successfully.
    success,
    /// The wait operation succeeded, but no WGPUFutures completed within the timeout.
    timed_out,
    /// The call was invalid for some reason (see @ref Wait-Any).
    /// Should produce @ref ImplementationDefinedLogging containing details.
    @"error",
};

/// TODO
pub const WGSLLanguageFeatureName = enum(u32) {
    /// TODO
    readonly_and_readwrite_storage_textures,
    /// TODO
    packed4x8_integer_dot_product,
    /// TODO
    unrestricted_pointer_parameters,
    /// TODO
    pointer_composite_access,
    /// TODO
    uniform_buffer_standard_layout,
    /// TODO
    subgroup_id,
    /// TODO
    texture_and_sampler_let,
    /// TODO
    subgroup_uniformity,
    /// TODO
    texture_formats_tier1,
    /// TODO
    linear_indexing,
    /// TODO
    immediate_address_space,
    /// TODO
    buffer_view,
    /// TODO
    swizzle_assignment,
    /// TODO
    fragment_depth,
};

pub const BufferUsage = packed struct(Flags) {
    /// The buffer can be *mapped* on the CPU side in *read* mode (using @ref WGPUMapMode_Read).
    map_read: bool,
    /// The buffer can be *mapped* on the CPU side in *write* mode (using @ref WGPUMapMode_Write).
    ///
    /// @note This usage is **not** required to set `mappedAtCreation` to `true` in @ref WGPUBufferDescriptor.
    map_write: bool,
    /// The buffer can be used as the *source* of a GPU-side copy operation.
    copy_src: bool,
    /// The buffer can be used as the *destination* of a GPU-side copy operation.
    copy_dst: bool,
    /// The buffer can be used as an Index buffer when doing indexed drawing in a render pipeline.
    index: bool,
    /// The buffer can be used as a Vertex buffer when using a render pipeline.
    vertex: bool,
    /// The buffer can be bound to a shader as a uniform buffer.
    uniform: bool,
    /// The buffer can be bound to a shader as a storage buffer.
    storage: bool,
    /// The buffer can store arguments for an indirect draw call.
    indirect: bool,
    /// The buffer can store the result of a timestamp or occlusion query.
    query_resolve: bool,
    __unused: u54,
};
pub const ColorWriteMask = packed struct(Flags) {
    /// TODO
    red: bool,
    /// TODO
    green: bool,
    /// TODO
    blue: bool,
    /// TODO
    alpha: bool,
    /// TODO
    all: bool,
    __unused: u59,
};
pub const MapMode = packed struct(Flags) {
    /// TODO
    read: bool,
    /// TODO
    write: bool,
    __unused: u62,
};
pub const ShaderStage = packed struct(Flags) {
    /// TODO
    vertex: bool,
    /// TODO
    fragment: bool,
    /// TODO
    compute: bool,
    __unused: u61,
};
pub const TextureUsage = packed struct(Flags) {
    /// TODO
    copy_src: bool,
    /// TODO
    copy_dst: bool,
    /// TODO
    texture_binding: bool,
    /// TODO
    storage_binding: bool,
    /// TODO
    render_attachment: bool,
    /// TODO
    transient_attachment: bool,
    __unused: u58,
};
/// TODO
/// status
/// TODO
/// message
/// TODO
const BufferMapCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: MapAsyncStatus,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// TODO
/// compilation_info
/// This argument contains multiple @ref ImplementationAllocatedStructChain roots.
/// Arbitrary chains must be handled gracefully by the application!
const CompilationInfoCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: CompilationInfoRequestStatus,
        compilation_info: *const CompilationInfo,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// TODO
/// pipeline
/// TODO
/// message
/// TODO
const CreateComputePipelineAsyncCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: CreatePipelineAsyncStatus,
        pipeline: ComputePipeline,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// TODO
/// pipeline
/// TODO
/// message
/// TODO
const CreateRenderPipelineAsyncCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: CreatePipelineAsyncStatus,
        pipeline: RenderPipeline,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// device
/// Pointer to the device which was lost. This is always a non-null pointer.
/// The pointed-to @ref WGPUDevice will be null if, and only if, either:
/// (1) The `reason` is @ref WGPUDeviceLostReason_FailedCreation.
/// (2) The last ref of the device has been (or is being) released: see @ref DeviceRelease.
/// reason
/// An error code explaining why the device was lost.
/// message
/// A @ref LocalizableHumanReadableMessageString describing why the device was lost.
const DeviceLostCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        device: *const Device,
        reason: DeviceLostReason,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// See @ref WGPUPopErrorScopeStatus.
/// type
/// The type of the error caught by the scope, or @ref WGPUErrorType_NoError if there was none.
/// If the `status` is not @ref WGPUPopErrorScopeStatus_Success, this is @ref WGPUErrorType_NoError.
/// message
/// If the `status` is not @ref WGPUPopErrorScopeStatus_Success **or**
/// the `type` is not @ref WGPUErrorType_NoError, this is a non-empty
/// @ref LocalizableHumanReadableMessageString;
/// otherwise, this is an empty string.
const PopErrorScopeCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: PopErrorScopeStatus,
        type: ErrorType,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// See @ref WGPUQueueWorkDoneStatus.
/// message
/// If the `status` is not @ref WGPUQueueWorkDoneStatus_Success,
/// this is a non-empty @ref LocalizableHumanReadableMessageString;
/// otherwise, this is an empty string.
const QueueWorkDoneCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: QueueWorkDoneStatus,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// TODO
/// adapter
/// TODO
/// message
/// TODO
const RequestAdapterCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: RequestAdapterStatus,
        adapter: Adapter,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// status
/// TODO
/// device
/// TODO
/// message
/// TODO
const RequestDeviceCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    mode: CallbackMode,
    callback: *fn (
        status: RequestDeviceStatus,
        device: Device,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
/// TODO
/// device
/// TODO
/// type
/// TODO
/// message
/// TODO
const UncapturedErrorCallbackInfo = extern struct {
    nextInChain: ?*ChainedStruct,
    callback: *fn (
        device: *const Device,
        type: ErrorType,
        message: StringView,
    ) void,
    userdata1: ?*void,
    userdata2: ?*void,
};
extern "C" fn wgpuCreateInstance(
    descriptor: ?*const InstanceDescriptor,
) Instance;

/// Create a WGPUInstance
/// descriptor
/// TODO
/// Return
/// TODO
const createInstance = wgpuCreateInstance;

extern "C" fn wgpuGetInstanceFeatures(
    features: *SupportedInstanceFeatures,
) void;

/// Get the list of @ref WGPUInstanceFeatureName values supported by the instance.
/// features
/// TODO
const getInstanceFeatures = wgpuGetInstanceFeatures;

extern "C" fn wgpuGetInstanceLimits(
    limits: *InstanceLimits,
) Status;

/// Get the limits supported by the instance.
/// limits
/// TODO
/// Return
/// Indicates if there was an @ref OutStructChainError.
const getInstanceLimits = wgpuGetInstanceLimits;

extern "C" fn wgpuHasInstanceFeature(
    feature: InstanceFeatureName,
) Bool;

/// Check whether a particular @ref WGPUInstanceFeatureName is supported by the instance.
/// feature
/// TODO
/// Return
/// TODO
const hasInstanceFeature = wgpuHasInstanceFeature;

pub const Adapter = opaque {
    extern "C" fn wgpuAdapterGetLimits(
        self: *Adapter,
        limits: *Limits,
    ) Status;

    /// TODO
    /// limits
    /// TODO
    /// Return
    /// Indicates if there was an @ref OutStructChainError.
    const getLimits = wgpuAdapterGetLimits;

    extern "C" fn wgpuAdapterHasFeature(
        self: *Adapter,
        feature: FeatureName,
    ) Bool;

    /// TODO
    /// feature
    /// TODO
    /// Return
    /// TODO
    const hasFeature = wgpuAdapterHasFeature;

    extern "C" fn wgpuAdapterGetFeatures(
        self: *Adapter,
        features: *SupportedFeatures,
    ) void;

    /// Get the list of @ref WGPUFeatureName values supported by the adapter.
    /// features
    /// TODO
    const getFeatures = wgpuAdapterGetFeatures;

    extern "C" fn wgpuAdapterGetInfo(
        self: *Adapter,
        info: *AdapterInfo,
    ) Status;

    /// TODO
    /// info
    /// TODO
    /// Return
    /// Indicates if there was an @ref OutStructChainError.
    const getInfo = wgpuAdapterGetInfo;

    extern "C" fn wgpuAdapterRequestDevice(
        self: *Adapter,
        descriptor: ?*const DeviceDescriptor,
        callback: RequestDeviceCallbackInfo,
    ) void;

    /// TODO
    /// descriptor
    /// TODO
    const requestDevice = wgpuAdapterRequestDevice;
};
pub const BindGroup = opaque {
    extern "C" fn wgpuBindGroupSetLabel(
        self: *BindGroup,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuBindGroupSetLabel;
};
pub const BindGroupLayout = opaque {
    extern "C" fn wgpuBindGroupLayoutSetLabel(
        self: *BindGroupLayout,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuBindGroupLayoutSetLabel;
};
pub const Buffer = opaque {
    extern "C" fn wgpuBufferMapAsync(
        self: *Buffer,
        mode: MapMode,
        offset: usize,
        size: usize,
        callback: BufferMapCallbackInfo,
    ) void;

    /// TODO
    /// mode
    /// The mapping mode (read or write).
    /// offset
    /// Byte offset relative to beginning of the buffer.
    /// size
    /// Byte size of the region to map.
    /// If this is @ref WGPU_WHOLE_MAP_SIZE, it defaults to `buffer.size - offset`.
    const mapAsync = wgpuBufferMapAsync;

    extern "C" fn wgpuBufferGetMappedRange(
        self: *Buffer,
        offset: usize,
        size: usize,
    ) *void;

    /// Returns a mutable pointer to beginning of the mapped range.
    /// See @ref MappedRangeBehavior for error conditions and guarantees.
    /// This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    ///
    /// In Wasm, if `memcpy`ing into this range, prefer using @ref wgpuBufferWriteMappedRange
    /// instead for better performance.
    /// offset
    /// Byte offset relative to the beginning of the buffer.
    /// size
    /// Byte size of the range to get.
    /// If this is @ref WGPU_WHOLE_MAP_SIZE, it defaults to `buffer.size - offset`.
    /// The returned pointer is valid for exactly this many bytes.
    const getMappedRange = wgpuBufferGetMappedRange;

    extern "C" fn wgpuBufferGetConstMappedRange(
        self: *Buffer,
        offset: usize,
        size: usize,
    ) *const void;

    /// Returns a const pointer to beginning of the mapped range.
    /// It must not be written; writing to this range causes undefined behavior.
    /// See @ref MappedRangeBehavior for error conditions and guarantees.
    /// This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    ///
    /// In Wasm, if `memcpy`ing from this range, prefer using @ref wgpuBufferReadMappedRange
    /// instead for better performance.
    /// offset
    /// Byte offset relative to the beginning of the buffer.
    /// size
    /// Byte size of the range to get.
    /// If this is @ref WGPU_WHOLE_MAP_SIZE, it defaults to `buffer.size - offset`.
    /// The returned pointer is valid for exactly this many bytes.
    const getConstMappedRange = wgpuBufferGetConstMappedRange;

    extern "C" fn wgpuBufferReadMappedRange(
        self: *Buffer,
        offset: usize,
        data: *void,
        size: usize,
    ) Status;

    /// Copies a range of data from the buffer mapping into the provided destination pointer.
    /// See @ref MappedRangeBehavior for error conditions and guarantees.
    /// This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    ///
    /// In Wasm, this is more efficient than copying from a mapped range into a `malloc`'d range.
    /// offset
    /// Byte offset relative to the beginning of the buffer.
    /// data
    /// Destination, to read buffer data into.
    /// size
    /// Number of bytes of data to read from the buffer.
    /// (Note @ref WGPU_WHOLE_MAP_SIZE is *not* accepted here.)
    /// Return
    /// @ref WGPUStatus_Error if the copy did not occur.
    const readMappedRange = wgpuBufferReadMappedRange;

    extern "C" fn wgpuBufferWriteMappedRange(
        self: *Buffer,
        offset: usize,
        data: *const void,
        size: usize,
    ) Status;

    /// Copies a range of data from the provided source pointer into the buffer mapping.
    /// See @ref MappedRangeBehavior for error conditions and guarantees.
    /// This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    ///
    /// In Wasm, this is more efficient than copying from a `malloc`'d range into a mapped range.
    /// offset
    /// Byte offset relative to the beginning of the buffer.
    /// data
    /// Source, to write buffer data from.
    /// size
    /// Number of bytes of data to write to the buffer.
    /// (Note @ref WGPU_WHOLE_MAP_SIZE is *not* accepted here.)
    /// Return
    /// @ref WGPUStatus_Error if the copy did not occur.
    const writeMappedRange = wgpuBufferWriteMappedRange;

    extern "C" fn wgpuBufferSetLabel(
        self: *Buffer,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuBufferSetLabel;

    extern "C" fn wgpuBufferGetUsage(
        self: *Buffer,
    ) BufferUsage;

    /// TODO
    /// Return
    /// TODO
    const getUsage = wgpuBufferGetUsage;

    extern "C" fn wgpuBufferGetSize(
        self: *Buffer,
    ) u64;

    /// TODO
    /// Return
    /// TODO
    const getSize = wgpuBufferGetSize;

    extern "C" fn wgpuBufferGetMapState(
        self: *Buffer,
    ) BufferMapState;

    /// TODO
    /// Return
    /// TODO
    const getMapState = wgpuBufferGetMapState;

    extern "C" fn wgpuBufferUnmap(
        self: *Buffer,
    ) void;

    /// TODO
    const unmap = wgpuBufferUnmap;

    extern "C" fn wgpuBufferDestroy(
        self: *Buffer,
    ) void;

    /// TODO
    const destroy = wgpuBufferDestroy;
};
pub const CommandBuffer = opaque {
    extern "C" fn wgpuCommandBufferSetLabel(
        self: *CommandBuffer,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuCommandBufferSetLabel;
};
pub const CommandEncoder = opaque {
    extern "C" fn wgpuCommandEncoderFinish(
        self: *CommandEncoder,
        descriptor: ?*const CommandBufferDescriptor,
    ) CommandBuffer;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const finish = wgpuCommandEncoderFinish;

    extern "C" fn wgpuCommandEncoderBeginComputePass(
        self: *CommandEncoder,
        descriptor: ?*const ComputePassDescriptor,
    ) ComputePassEncoder;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const beginComputePass = wgpuCommandEncoderBeginComputePass;

    extern "C" fn wgpuCommandEncoderBeginRenderPass(
        self: *CommandEncoder,
        descriptor: *const RenderPassDescriptor,
    ) RenderPassEncoder;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const beginRenderPass = wgpuCommandEncoderBeginRenderPass;

    extern "C" fn wgpuCommandEncoderCopyBufferToBuffer(
        self: *CommandEncoder,
        source: Buffer,
        source_offset: u64,
        destination: Buffer,
        destination_offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// source
    /// TODO
    /// source_offset
    /// TODO
    /// destination
    /// TODO
    /// destination_offset
    /// TODO
    /// size
    /// TODO
    const copyBufferToBuffer = wgpuCommandEncoderCopyBufferToBuffer;

    extern "C" fn wgpuCommandEncoderCopyBufferToTexture(
        self: *CommandEncoder,
        source: *const TexelCopyBufferInfo,
        destination: *const TexelCopyTextureInfo,
        copy_size: *const Extent3D,
    ) void;

    /// TODO
    /// source
    /// TODO
    /// destination
    /// TODO
    /// copy_size
    /// TODO
    const copyBufferToTexture = wgpuCommandEncoderCopyBufferToTexture;

    extern "C" fn wgpuCommandEncoderCopyTextureToBuffer(
        self: *CommandEncoder,
        source: *const TexelCopyTextureInfo,
        destination: *const TexelCopyBufferInfo,
        copy_size: *const Extent3D,
    ) void;

    /// TODO
    /// source
    /// TODO
    /// destination
    /// TODO
    /// copy_size
    /// TODO
    const copyTextureToBuffer = wgpuCommandEncoderCopyTextureToBuffer;

    extern "C" fn wgpuCommandEncoderCopyTextureToTexture(
        self: *CommandEncoder,
        source: *const TexelCopyTextureInfo,
        destination: *const TexelCopyTextureInfo,
        copy_size: *const Extent3D,
    ) void;

    /// TODO
    /// source
    /// TODO
    /// destination
    /// TODO
    /// copy_size
    /// TODO
    const copyTextureToTexture = wgpuCommandEncoderCopyTextureToTexture;

    extern "C" fn wgpuCommandEncoderClearBuffer(
        self: *CommandEncoder,
        buffer: Buffer,
        offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// buffer
    /// TODO
    /// offset
    /// TODO
    /// size
    /// TODO
    const clearBuffer = wgpuCommandEncoderClearBuffer;

    extern "C" fn wgpuCommandEncoderInsertDebugMarker(
        self: *CommandEncoder,
        marker_label: StringView,
    ) void;

    /// TODO
    /// marker_label
    /// TODO
    const insertDebugMarker = wgpuCommandEncoderInsertDebugMarker;

    extern "C" fn wgpuCommandEncoderPopDebugGroup(
        self: *CommandEncoder,
    ) void;

    /// TODO
    const popDebugGroup = wgpuCommandEncoderPopDebugGroup;

    extern "C" fn wgpuCommandEncoderPushDebugGroup(
        self: *CommandEncoder,
        group_label: StringView,
    ) void;

    /// TODO
    /// group_label
    /// TODO
    const pushDebugGroup = wgpuCommandEncoderPushDebugGroup;

    extern "C" fn wgpuCommandEncoderResolveQuerySet(
        self: *CommandEncoder,
        query_set: QuerySet,
        first_query: u32,
        query_count: u32,
        destination: Buffer,
        destination_offset: u64,
    ) void;

    /// TODO
    /// query_set
    /// TODO
    /// first_query
    /// TODO
    /// query_count
    /// TODO
    /// destination
    /// TODO
    /// destination_offset
    /// TODO
    const resolveQuerySet = wgpuCommandEncoderResolveQuerySet;

    extern "C" fn wgpuCommandEncoderWriteTimestamp(
        self: *CommandEncoder,
        query_set: QuerySet,
        query_index: u32,
    ) void;

    /// TODO
    /// query_set
    /// TODO
    /// query_index
    /// TODO
    const writeTimestamp = wgpuCommandEncoderWriteTimestamp;

    extern "C" fn wgpuCommandEncoderSetLabel(
        self: *CommandEncoder,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuCommandEncoderSetLabel;
};
pub const ComputePassEncoder = opaque {
    extern "C" fn wgpuComputePassEncoderInsertDebugMarker(
        self: *ComputePassEncoder,
        marker_label: StringView,
    ) void;

    /// TODO
    /// marker_label
    /// TODO
    const insertDebugMarker = wgpuComputePassEncoderInsertDebugMarker;

    extern "C" fn wgpuComputePassEncoderPopDebugGroup(
        self: *ComputePassEncoder,
    ) void;

    /// TODO
    const popDebugGroup = wgpuComputePassEncoderPopDebugGroup;

    extern "C" fn wgpuComputePassEncoderPushDebugGroup(
        self: *ComputePassEncoder,
        group_label: StringView,
    ) void;

    /// TODO
    /// group_label
    /// TODO
    const pushDebugGroup = wgpuComputePassEncoderPushDebugGroup;

    extern "C" fn wgpuComputePassEncoderSetPipeline(
        self: *ComputePassEncoder,
        pipeline: ComputePipeline,
    ) void;

    /// TODO
    /// pipeline
    /// TODO
    const setPipeline = wgpuComputePassEncoderSetPipeline;

    extern "C" fn wgpuComputePassEncoderSetBindGroup(
        self: *ComputePassEncoder,
        group_index: u32,
        group: ?BindGroup,
        dynamic_offsetsCount: usize,
        dynamic_offsets: *const u32,
    ) void;

    /// TODO
    /// group_index
    /// TODO
    /// group
    /// TODO
    /// dynamic_offsets
    /// TODO
    const setBindGroup = wgpuComputePassEncoderSetBindGroup;

    extern "C" fn wgpuComputePassEncoderSetImmediates(
        self: *ComputePassEncoder,
        offset: u32,
        data: *const void,
        size: usize,
    ) void;

    /// TODO
    /// offset
    /// TODO
    /// data
    /// TODO
    /// size
    /// TODO
    const setImmediates = wgpuComputePassEncoderSetImmediates;

    extern "C" fn wgpuComputePassEncoderDispatchWorkgroups(
        self: *ComputePassEncoder,
        workgroupCountX: u32,
        workgroupCountY: u32,
        workgroupCountZ: u32,
    ) void;

    /// TODO
    /// workgroupCountX
    /// TODO
    /// workgroupCountY
    /// TODO
    /// workgroupCountZ
    /// TODO
    const dispatchWorkgroups = wgpuComputePassEncoderDispatchWorkgroups;

    extern "C" fn wgpuComputePassEncoderDispatchWorkgroupsIndirect(
        self: *ComputePassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void;

    /// TODO
    /// indirect_buffer
    /// TODO
    /// indirect_offset
    /// TODO
    const dispatchWorkgroupsIndirect = wgpuComputePassEncoderDispatchWorkgroupsIndirect;

    extern "C" fn wgpuComputePassEncoderEnd(
        self: *ComputePassEncoder,
    ) void;

    /// TODO
    const end = wgpuComputePassEncoderEnd;

    extern "C" fn wgpuComputePassEncoderSetLabel(
        self: *ComputePassEncoder,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuComputePassEncoderSetLabel;
};
pub const ComputePipeline = opaque {
    extern "C" fn wgpuComputePipelineGetBindGroupLayout(
        self: *ComputePipeline,
        group_index: u32,
    ) BindGroupLayout;

    /// TODO
    /// group_index
    /// TODO
    /// Return
    /// TODO
    const getBindGroupLayout = wgpuComputePipelineGetBindGroupLayout;

    extern "C" fn wgpuComputePipelineSetLabel(
        self: *ComputePipeline,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuComputePipelineSetLabel;
};
pub const Device = opaque {
    extern "C" fn wgpuDeviceCreateBindGroup(
        self: *Device,
        descriptor: *const BindGroupDescriptor,
    ) BindGroup;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createBindGroup = wgpuDeviceCreateBindGroup;

    extern "C" fn wgpuDeviceCreateBindGroupLayout(
        self: *Device,
        descriptor: *const BindGroupLayoutDescriptor,
    ) BindGroupLayout;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createBindGroupLayout = wgpuDeviceCreateBindGroupLayout;

    extern "C" fn wgpuDeviceCreateBuffer(
        self: *Device,
        descriptor: *const BufferDescriptor,
    ) ?Buffer;

    /// TODO
    ///
    /// If @ref WGPUBufferDescriptor::mappedAtCreation is `true` and the mapping allocation fails,
    /// returns `NULL`.
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createBuffer = wgpuDeviceCreateBuffer;

    extern "C" fn wgpuDeviceCreateCommandEncoder(
        self: *Device,
        descriptor: ?*const CommandEncoderDescriptor,
    ) CommandEncoder;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createCommandEncoder = wgpuDeviceCreateCommandEncoder;

    extern "C" fn wgpuDeviceCreateComputePipeline(
        self: *Device,
        descriptor: *const ComputePipelineDescriptor,
    ) ComputePipeline;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createComputePipeline = wgpuDeviceCreateComputePipeline;

    extern "C" fn wgpuDeviceCreateComputePipelineAsync(
        self: *Device,
        descriptor: *const ComputePipelineDescriptor,
        callback: CreateComputePipelineAsyncCallbackInfo,
    ) void;

    /// TODO
    /// descriptor
    /// TODO
    const createComputePipelineAsync = wgpuDeviceCreateComputePipelineAsync;

    extern "C" fn wgpuDeviceCreatePipelineLayout(
        self: *Device,
        descriptor: *const PipelineLayoutDescriptor,
    ) PipelineLayout;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createPipelineLayout = wgpuDeviceCreatePipelineLayout;

    extern "C" fn wgpuDeviceCreateQuerySet(
        self: *Device,
        descriptor: *const QuerySetDescriptor,
    ) QuerySet;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createQuerySet = wgpuDeviceCreateQuerySet;

    extern "C" fn wgpuDeviceCreateRenderPipelineAsync(
        self: *Device,
        descriptor: *const RenderPipelineDescriptor,
        callback: CreateRenderPipelineAsyncCallbackInfo,
    ) void;

    /// TODO
    /// descriptor
    /// TODO
    const createRenderPipelineAsync = wgpuDeviceCreateRenderPipelineAsync;

    extern "C" fn wgpuDeviceCreateRenderBundleEncoder(
        self: *Device,
        descriptor: *const RenderBundleEncoderDescriptor,
    ) RenderBundleEncoder;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createRenderBundleEncoder = wgpuDeviceCreateRenderBundleEncoder;

    extern "C" fn wgpuDeviceCreateRenderPipeline(
        self: *Device,
        descriptor: *const RenderPipelineDescriptor,
    ) RenderPipeline;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createRenderPipeline = wgpuDeviceCreateRenderPipeline;

    extern "C" fn wgpuDeviceCreateSampler(
        self: *Device,
        descriptor: ?*const SamplerDescriptor,
    ) Sampler;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createSampler = wgpuDeviceCreateSampler;

    extern "C" fn wgpuDeviceCreateShaderModule(
        self: *Device,
        descriptor: *const ShaderModuleDescriptor,
    ) ShaderModule;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createShaderModule = wgpuDeviceCreateShaderModule;

    extern "C" fn wgpuDeviceCreateTexture(
        self: *Device,
        descriptor: *const TextureDescriptor,
    ) Texture;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createTexture = wgpuDeviceCreateTexture;

    extern "C" fn wgpuDeviceDestroy(
        self: *Device,
    ) void;

    /// TODO
    const destroy = wgpuDeviceDestroy;

    extern "C" fn wgpuDeviceGetLostFuture(
        self: *Device,
    ) Future;

    /// Return
    /// The @ref WGPUFuture for the device-lost event of the device.
    const getLostFuture = wgpuDeviceGetLostFuture;

    extern "C" fn wgpuDeviceGetLimits(
        self: *Device,
        limits: *Limits,
    ) Status;

    /// TODO
    /// limits
    /// TODO
    /// Return
    /// Indicates if there was an @ref OutStructChainError.
    const getLimits = wgpuDeviceGetLimits;

    extern "C" fn wgpuDeviceHasFeature(
        self: *Device,
        feature: FeatureName,
    ) Bool;

    /// TODO
    /// feature
    /// TODO
    /// Return
    /// TODO
    const hasFeature = wgpuDeviceHasFeature;

    extern "C" fn wgpuDeviceGetFeatures(
        self: *Device,
        features: *SupportedFeatures,
    ) void;

    /// Get the list of @ref WGPUFeatureName values supported by the device.
    /// features
    /// TODO
    const getFeatures = wgpuDeviceGetFeatures;

    extern "C" fn wgpuDeviceGetAdapterInfo(
        self: *Device,
        adapter_info: *AdapterInfo,
    ) Status;

    /// TODO
    /// adapter_info
    /// TODO
    /// Return
    /// Indicates if there was an @ref OutStructChainError.
    const getAdapterInfo = wgpuDeviceGetAdapterInfo;

    extern "C" fn wgpuDeviceGetQueue(
        self: *Device,
    ) Queue;

    /// TODO
    /// Return
    /// TODO
    const getQueue = wgpuDeviceGetQueue;

    extern "C" fn wgpuDevicePushErrorScope(
        self: *Device,
        filter: ErrorFilter,
    ) void;

    /// Pushes an error scope to the current thread's error scope stack.
    /// See @ref ErrorScopes.
    /// filter
    /// TODO
    const pushErrorScope = wgpuDevicePushErrorScope;

    extern "C" fn wgpuDevicePopErrorScope(
        self: *Device,
        callback: PopErrorScopeCallbackInfo,
    ) void;

    /// Pops an error scope to the current thread's error scope stack,
    /// asynchronously returning the result. See @ref ErrorScopes.
    const popErrorScope = wgpuDevicePopErrorScope;

    extern "C" fn wgpuDeviceSetLabel(
        self: *Device,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuDeviceSetLabel;
};
pub const ExternalTexture = opaque {
    extern "C" fn wgpuExternalTextureSetLabel(
        self: *ExternalTexture,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuExternalTextureSetLabel;
};
pub const Instance = opaque {
    extern "C" fn wgpuInstanceCreateSurface(
        self: *Instance,
        descriptor: *const SurfaceDescriptor,
    ) Surface;

    /// Creates a @ref WGPUSurface, see @ref Surface-Creation for more details.
    /// descriptor
    /// The description of the @ref WGPUSurface to create.
    /// Return
    /// A new @ref WGPUSurface for this descriptor (or an error @ref WGPUSurface).
    const createSurface = wgpuInstanceCreateSurface;

    extern "C" fn wgpuInstanceGetWGSLLanguageFeatures(
        self: *Instance,
        features: *SupportedWGSLLanguageFeatures,
    ) void;

    /// Get the list of @ref WGPUWGSLLanguageFeatureName values supported by the instance.
    /// features
    /// TODO
    const getWGSLLanguageFeatures = wgpuInstanceGetWGSLLanguageFeatures;

    extern "C" fn wgpuInstanceHasWGSLLanguageFeature(
        self: *Instance,
        feature: WGSLLanguageFeatureName,
    ) Bool;

    /// TODO
    /// feature
    /// TODO
    /// Return
    /// TODO
    const hasWGSLLanguageFeature = wgpuInstanceHasWGSLLanguageFeature;

    extern "C" fn wgpuInstanceProcessEvents(
        self: *Instance,
    ) void;

    /// Processes asynchronous events on this `WGPUInstance`, calling any callbacks for asynchronous operations created with @ref WGPUCallbackMode_AllowProcessEvents.
    ///
    /// See @ref Process-Events for more information.
    const processEvents = wgpuInstanceProcessEvents;

    extern "C" fn wgpuInstanceRequestAdapter(
        self: *Instance,
        options: ?*const RequestAdapterOptions,
        callback: RequestAdapterCallbackInfo,
    ) void;

    /// TODO
    /// options
    /// TODO
    const requestAdapter = wgpuInstanceRequestAdapter;

    extern "C" fn wgpuInstanceWaitAny(
        self: *Instance,
        future_count: usize,
        futures: ?*FutureWaitInfo,
        timeout_NS: u64,
    ) WaitStatus;

    /// Wait for at least one WGPUFuture in `futures` to complete, and call callbacks of the respective completed asynchronous operations.
    ///
    /// See @ref Wait-Any for more information.
    /// future_count
    /// TODO
    /// futures
    /// TODO
    /// timeout_NS
    /// TODO
    /// Return
    /// TODO
    const waitAny = wgpuInstanceWaitAny;
};
pub const PipelineLayout = opaque {
    extern "C" fn wgpuPipelineLayoutSetLabel(
        self: *PipelineLayout,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuPipelineLayoutSetLabel;
};
pub const QuerySet = opaque {
    extern "C" fn wgpuQuerySetSetLabel(
        self: *QuerySet,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuQuerySetSetLabel;

    extern "C" fn wgpuQuerySetGetType(
        self: *QuerySet,
    ) QueryType;

    /// TODO
    /// Return
    /// TODO
    const getType = wgpuQuerySetGetType;

    extern "C" fn wgpuQuerySetGetCount(
        self: *QuerySet,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getCount = wgpuQuerySetGetCount;

    extern "C" fn wgpuQuerySetDestroy(
        self: *QuerySet,
    ) void;

    /// TODO
    const destroy = wgpuQuerySetDestroy;
};
pub const Queue = opaque {
    extern "C" fn wgpuQueueSubmit(
        self: *Queue,
        commandsCount: usize,
        commands: *const CommandBuffer,
    ) void;

    /// TODO
    /// commands
    /// TODO
    const submit = wgpuQueueSubmit;

    extern "C" fn wgpuQueueOnSubmittedWorkDone(
        self: *Queue,
        callback: QueueWorkDoneCallbackInfo,
    ) void;

    /// TODO
    const onSubmittedWorkDone = wgpuQueueOnSubmittedWorkDone;

    extern "C" fn wgpuQueueWriteBuffer(
        self: *Queue,
        buffer: Buffer,
        buffer_offset: u64,
        data: *const void,
        size: usize,
    ) void;

    /// Produces a @ref DeviceError both content-timeline (`size` alignment) and device-timeline
    /// errors defined by the WebGPU specification.
    /// buffer
    /// TODO
    /// buffer_offset
    /// TODO
    /// data
    /// TODO
    /// size
    /// TODO
    const writeBuffer = wgpuQueueWriteBuffer;

    extern "C" fn wgpuQueueWriteTexture(
        self: *Queue,
        destination: *const TexelCopyTextureInfo,
        data: *const void,
        data_size: usize,
        data_layout: *const TexelCopyBufferLayout,
        write_size: *const Extent3D,
    ) void;

    /// TODO
    /// destination
    /// TODO
    /// data
    /// TODO
    /// data_size
    /// TODO
    /// data_layout
    /// TODO
    /// write_size
    /// TODO
    const writeTexture = wgpuQueueWriteTexture;

    extern "C" fn wgpuQueueSetLabel(
        self: *Queue,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuQueueSetLabel;
};
pub const RenderBundle = opaque {
    extern "C" fn wgpuRenderBundleSetLabel(
        self: *RenderBundle,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuRenderBundleSetLabel;
};
pub const RenderBundleEncoder = opaque {
    extern "C" fn wgpuRenderBundleEncoderSetPipeline(
        self: *RenderBundleEncoder,
        pipeline: RenderPipeline,
    ) void;

    /// TODO
    /// pipeline
    /// TODO
    const setPipeline = wgpuRenderBundleEncoderSetPipeline;

    extern "C" fn wgpuRenderBundleEncoderSetBindGroup(
        self: *RenderBundleEncoder,
        group_index: u32,
        group: ?BindGroup,
        dynamic_offsetsCount: usize,
        dynamic_offsets: *const u32,
    ) void;

    /// TODO
    /// group_index
    /// TODO
    /// group
    /// TODO
    /// dynamic_offsets
    /// TODO
    const setBindGroup = wgpuRenderBundleEncoderSetBindGroup;

    extern "C" fn wgpuRenderBundleEncoderSetImmediates(
        self: *RenderBundleEncoder,
        offset: u32,
        data: *const void,
        size: usize,
    ) void;

    /// TODO
    /// offset
    /// TODO
    /// data
    /// TODO
    /// size
    /// TODO
    const setImmediates = wgpuRenderBundleEncoderSetImmediates;

    extern "C" fn wgpuRenderBundleEncoderDraw(
        self: *RenderBundleEncoder,
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void;

    /// TODO
    /// vertex_count
    /// TODO
    /// instance_count
    /// TODO
    /// first_vertex
    /// TODO
    /// first_instance
    /// TODO
    const draw = wgpuRenderBundleEncoderDraw;

    extern "C" fn wgpuRenderBundleEncoderDrawIndexed(
        self: *RenderBundleEncoder,
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        base_vertex: i32,
        first_instance: u32,
    ) void;

    /// TODO
    /// index_count
    /// TODO
    /// instance_count
    /// TODO
    /// first_index
    /// TODO
    /// base_vertex
    /// TODO
    /// first_instance
    /// TODO
    const drawIndexed = wgpuRenderBundleEncoderDrawIndexed;

    extern "C" fn wgpuRenderBundleEncoderDrawIndirect(
        self: *RenderBundleEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void;

    /// TODO
    /// indirect_buffer
    /// TODO
    /// indirect_offset
    /// TODO
    const drawIndirect = wgpuRenderBundleEncoderDrawIndirect;

    extern "C" fn wgpuRenderBundleEncoderDrawIndexedIndirect(
        self: *RenderBundleEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void;

    /// TODO
    /// indirect_buffer
    /// TODO
    /// indirect_offset
    /// TODO
    const drawIndexedIndirect = wgpuRenderBundleEncoderDrawIndexedIndirect;

    extern "C" fn wgpuRenderBundleEncoderInsertDebugMarker(
        self: *RenderBundleEncoder,
        marker_label: StringView,
    ) void;

    /// TODO
    /// marker_label
    /// TODO
    const insertDebugMarker = wgpuRenderBundleEncoderInsertDebugMarker;

    extern "C" fn wgpuRenderBundleEncoderPopDebugGroup(
        self: *RenderBundleEncoder,
    ) void;

    /// TODO
    const popDebugGroup = wgpuRenderBundleEncoderPopDebugGroup;

    extern "C" fn wgpuRenderBundleEncoderPushDebugGroup(
        self: *RenderBundleEncoder,
        group_label: StringView,
    ) void;

    /// TODO
    /// group_label
    /// TODO
    const pushDebugGroup = wgpuRenderBundleEncoderPushDebugGroup;

    extern "C" fn wgpuRenderBundleEncoderSetVertexBuffer(
        self: *RenderBundleEncoder,
        slot: u32,
        buffer: ?Buffer,
        offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// slot
    /// TODO
    /// buffer
    /// TODO
    /// offset
    /// TODO
    /// size
    /// TODO
    const setVertexBuffer = wgpuRenderBundleEncoderSetVertexBuffer;

    extern "C" fn wgpuRenderBundleEncoderSetIndexBuffer(
        self: *RenderBundleEncoder,
        buffer: Buffer,
        format: IndexFormat,
        offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// buffer
    /// TODO
    /// format
    /// TODO
    /// offset
    /// TODO
    /// size
    /// TODO
    const setIndexBuffer = wgpuRenderBundleEncoderSetIndexBuffer;

    extern "C" fn wgpuRenderBundleEncoderFinish(
        self: *RenderBundleEncoder,
        descriptor: ?*const RenderBundleDescriptor,
    ) RenderBundle;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const finish = wgpuRenderBundleEncoderFinish;

    extern "C" fn wgpuRenderBundleEncoderSetLabel(
        self: *RenderBundleEncoder,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuRenderBundleEncoderSetLabel;
};
pub const RenderPassEncoder = opaque {
    extern "C" fn wgpuRenderPassEncoderSetPipeline(
        self: *RenderPassEncoder,
        pipeline: RenderPipeline,
    ) void;

    /// TODO
    /// pipeline
    /// TODO
    const setPipeline = wgpuRenderPassEncoderSetPipeline;

    extern "C" fn wgpuRenderPassEncoderSetBindGroup(
        self: *RenderPassEncoder,
        group_index: u32,
        group: ?BindGroup,
        dynamic_offsetsCount: usize,
        dynamic_offsets: *const u32,
    ) void;

    /// TODO
    /// group_index
    /// TODO
    /// group
    /// TODO
    /// dynamic_offsets
    /// TODO
    const setBindGroup = wgpuRenderPassEncoderSetBindGroup;

    extern "C" fn wgpuRenderPassEncoderSetImmediates(
        self: *RenderPassEncoder,
        offset: u32,
        data: *const void,
        size: usize,
    ) void;

    /// TODO
    /// offset
    /// TODO
    /// data
    /// TODO
    /// size
    /// TODO
    const setImmediates = wgpuRenderPassEncoderSetImmediates;

    extern "C" fn wgpuRenderPassEncoderDraw(
        self: *RenderPassEncoder,
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void;

    /// TODO
    /// vertex_count
    /// TODO
    /// instance_count
    /// TODO
    /// first_vertex
    /// TODO
    /// first_instance
    /// TODO
    const draw = wgpuRenderPassEncoderDraw;

    extern "C" fn wgpuRenderPassEncoderDrawIndexed(
        self: *RenderPassEncoder,
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        base_vertex: i32,
        first_instance: u32,
    ) void;

    /// TODO
    /// index_count
    /// TODO
    /// instance_count
    /// TODO
    /// first_index
    /// TODO
    /// base_vertex
    /// TODO
    /// first_instance
    /// TODO
    const drawIndexed = wgpuRenderPassEncoderDrawIndexed;

    extern "C" fn wgpuRenderPassEncoderDrawIndirect(
        self: *RenderPassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void;

    /// TODO
    /// indirect_buffer
    /// TODO
    /// indirect_offset
    /// TODO
    const drawIndirect = wgpuRenderPassEncoderDrawIndirect;

    extern "C" fn wgpuRenderPassEncoderDrawIndexedIndirect(
        self: *RenderPassEncoder,
        indirect_buffer: Buffer,
        indirect_offset: u64,
    ) void;

    /// TODO
    /// indirect_buffer
    /// TODO
    /// indirect_offset
    /// TODO
    const drawIndexedIndirect = wgpuRenderPassEncoderDrawIndexedIndirect;

    extern "C" fn wgpuRenderPassEncoderExecuteBundles(
        self: *RenderPassEncoder,
        bundlesCount: usize,
        bundles: *const RenderBundle,
    ) void;

    /// TODO
    /// bundles
    /// TODO
    const executeBundles = wgpuRenderPassEncoderExecuteBundles;

    extern "C" fn wgpuRenderPassEncoderInsertDebugMarker(
        self: *RenderPassEncoder,
        marker_label: StringView,
    ) void;

    /// TODO
    /// marker_label
    /// TODO
    const insertDebugMarker = wgpuRenderPassEncoderInsertDebugMarker;

    extern "C" fn wgpuRenderPassEncoderPopDebugGroup(
        self: *RenderPassEncoder,
    ) void;

    /// TODO
    const popDebugGroup = wgpuRenderPassEncoderPopDebugGroup;

    extern "C" fn wgpuRenderPassEncoderPushDebugGroup(
        self: *RenderPassEncoder,
        group_label: StringView,
    ) void;

    /// TODO
    /// group_label
    /// TODO
    const pushDebugGroup = wgpuRenderPassEncoderPushDebugGroup;

    extern "C" fn wgpuRenderPassEncoderSetStencilReference(
        self: *RenderPassEncoder,
        reference: u32,
    ) void;

    /// TODO
    /// reference
    /// TODO
    const setStencilReference = wgpuRenderPassEncoderSetStencilReference;

    extern "C" fn wgpuRenderPassEncoderSetBlendConstant(
        self: *RenderPassEncoder,
        color: *const Color,
    ) void;

    /// TODO
    /// color
    /// The RGBA blend constant. Represents an `f32` color using @ref DoubleAsSupertype.
    const setBlendConstant = wgpuRenderPassEncoderSetBlendConstant;

    extern "C" fn wgpuRenderPassEncoderSetViewport(
        self: *RenderPassEncoder,
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        min_depth: f32,
        max_depth: f32,
    ) void;

    /// TODO
    ///
    /// If any argument is non-finite, produces a @ref NonFiniteFloatValueError.
    /// x
    /// TODO
    /// y
    /// TODO
    /// width
    /// TODO
    /// height
    /// TODO
    /// min_depth
    /// TODO
    /// max_depth
    /// TODO
    const setViewport = wgpuRenderPassEncoderSetViewport;

    extern "C" fn wgpuRenderPassEncoderSetScissorRect(
        self: *RenderPassEncoder,
        x: u32,
        y: u32,
        width: u32,
        height: u32,
    ) void;

    /// TODO
    /// x
    /// TODO
    /// y
    /// TODO
    /// width
    /// TODO
    /// height
    /// TODO
    const setScissorRect = wgpuRenderPassEncoderSetScissorRect;

    extern "C" fn wgpuRenderPassEncoderSetVertexBuffer(
        self: *RenderPassEncoder,
        slot: u32,
        buffer: ?Buffer,
        offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// slot
    /// TODO
    /// buffer
    /// TODO
    /// offset
    /// TODO
    /// size
    /// TODO
    const setVertexBuffer = wgpuRenderPassEncoderSetVertexBuffer;

    extern "C" fn wgpuRenderPassEncoderSetIndexBuffer(
        self: *RenderPassEncoder,
        buffer: Buffer,
        format: IndexFormat,
        offset: u64,
        size: u64,
    ) void;

    /// TODO
    /// buffer
    /// TODO
    /// format
    /// TODO
    /// offset
    /// TODO
    /// size
    /// TODO
    const setIndexBuffer = wgpuRenderPassEncoderSetIndexBuffer;

    extern "C" fn wgpuRenderPassEncoderBeginOcclusionQuery(
        self: *RenderPassEncoder,
        query_index: u32,
    ) void;

    /// TODO
    /// query_index
    /// TODO
    const beginOcclusionQuery = wgpuRenderPassEncoderBeginOcclusionQuery;

    extern "C" fn wgpuRenderPassEncoderEndOcclusionQuery(
        self: *RenderPassEncoder,
    ) void;

    /// TODO
    const endOcclusionQuery = wgpuRenderPassEncoderEndOcclusionQuery;

    extern "C" fn wgpuRenderPassEncoderEnd(
        self: *RenderPassEncoder,
    ) void;

    /// TODO
    const end = wgpuRenderPassEncoderEnd;

    extern "C" fn wgpuRenderPassEncoderSetLabel(
        self: *RenderPassEncoder,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuRenderPassEncoderSetLabel;
};
pub const RenderPipeline = opaque {
    extern "C" fn wgpuRenderPipelineGetBindGroupLayout(
        self: *RenderPipeline,
        group_index: u32,
    ) BindGroupLayout;

    /// TODO
    /// group_index
    /// TODO
    /// Return
    /// TODO
    const getBindGroupLayout = wgpuRenderPipelineGetBindGroupLayout;

    extern "C" fn wgpuRenderPipelineSetLabel(
        self: *RenderPipeline,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuRenderPipelineSetLabel;
};
pub const Sampler = opaque {
    extern "C" fn wgpuSamplerSetLabel(
        self: *Sampler,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuSamplerSetLabel;
};
pub const ShaderModule = opaque {
    extern "C" fn wgpuShaderModuleGetCompilationInfo(
        self: *ShaderModule,
        callback: CompilationInfoCallbackInfo,
    ) void;

    /// TODO
    const getCompilationInfo = wgpuShaderModuleGetCompilationInfo;

    extern "C" fn wgpuShaderModuleSetLabel(
        self: *ShaderModule,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuShaderModuleSetLabel;
};
pub const Surface = opaque {
    extern "C" fn wgpuSurfaceConfigure(
        self: *Surface,
        config: *const SurfaceConfiguration,
    ) void;

    /// Configures parameters for rendering to `surface`.
    /// Produces a @ref DeviceError for all content-timeline errors defined by the WebGPU specification.
    ///
    /// See @ref Surface-Configuration for more details.
    /// config
    /// The new configuration to use.
    const configure = wgpuSurfaceConfigure;

    extern "C" fn wgpuSurfaceGetCapabilities(
        self: *Surface,
        adapter: Adapter,
        capabilities: *SurfaceCapabilities,
    ) Status;

    /// Provides information on how `adapter` is able to use `surface`.
    /// See @ref Surface-Capabilities for more details.
    /// adapter
    /// The @ref WGPUAdapter to get capabilities for presenting to this @ref WGPUSurface.
    /// capabilities
    /// The structure to fill capabilities in.
    /// It may contain memory allocations so @ref wgpuSurfaceCapabilitiesFreeMembers must be called to avoid memory leaks.
    /// Return
    /// Indicates if there was an @ref OutStructChainError.
    const getCapabilities = wgpuSurfaceGetCapabilities;

    extern "C" fn wgpuSurfaceGetCurrentTexture(
        self: *Surface,
        surface_texture: *SurfaceTexture,
    ) void;

    /// Returns the @ref WGPUTexture to render to `surface` this frame along with metadata on the frame.
    /// Returns `NULL` and @ref WGPUSurfaceGetCurrentTextureStatus_Error if the surface is not configured.
    ///
    /// See @ref Surface-Presenting for more details.
    /// surface_texture
    /// The structure to fill the @ref WGPUTexture and metadata in.
    const getCurrentTexture = wgpuSurfaceGetCurrentTexture;

    extern "C" fn wgpuSurfacePresent(
        self: *Surface,
    ) Status;

    /// Shows `surface`'s current texture to the user.
    /// See @ref Surface-Presenting for more details.
    /// Return
    /// Returns @ref WGPUStatus_Error if the surface doesn't have a current texture.
    const present = wgpuSurfacePresent;

    extern "C" fn wgpuSurfaceUnconfigure(
        self: *Surface,
    ) void;

    /// Removes the configuration for `surface`.
    /// See @ref Surface-Configuration for more details.
    const unconfigure = wgpuSurfaceUnconfigure;

    extern "C" fn wgpuSurfaceSetLabel(
        self: *Surface,
        label: StringView,
    ) void;

    /// Modifies the label used to refer to `surface`.
    /// label
    /// The new label.
    const setLabel = wgpuSurfaceSetLabel;
};
pub const Texture = opaque {
    extern "C" fn wgpuTextureCreateView(
        self: *Texture,
        descriptor: ?*const TextureViewDescriptor,
    ) TextureView;

    /// TODO
    /// descriptor
    /// TODO
    /// Return
    /// TODO
    const createView = wgpuTextureCreateView;

    extern "C" fn wgpuTextureSetLabel(
        self: *Texture,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuTextureSetLabel;

    extern "C" fn wgpuTextureGetWidth(
        self: *Texture,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getWidth = wgpuTextureGetWidth;

    extern "C" fn wgpuTextureGetHeight(
        self: *Texture,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getHeight = wgpuTextureGetHeight;

    extern "C" fn wgpuTextureGetDepthOrArrayLayers(
        self: *Texture,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getDepthOrArrayLayers = wgpuTextureGetDepthOrArrayLayers;

    extern "C" fn wgpuTextureGetMipLevelCount(
        self: *Texture,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getMipLevelCount = wgpuTextureGetMipLevelCount;

    extern "C" fn wgpuTextureGetSampleCount(
        self: *Texture,
    ) u32;

    /// TODO
    /// Return
    /// TODO
    const getSampleCount = wgpuTextureGetSampleCount;

    extern "C" fn wgpuTextureGetDimension(
        self: *Texture,
    ) TextureDimension;

    /// TODO
    /// Return
    /// TODO
    const getDimension = wgpuTextureGetDimension;

    extern "C" fn wgpuTextureGetTextureBindingViewDimension(
        self: *Texture,
    ) TextureViewDimension;

    /// TODO
    /// Return
    /// TODO
    const getTextureBindingViewDimension = wgpuTextureGetTextureBindingViewDimension;

    extern "C" fn wgpuTextureGetFormat(
        self: *Texture,
    ) TextureFormat;

    /// TODO
    /// Return
    /// TODO
    const getFormat = wgpuTextureGetFormat;

    extern "C" fn wgpuTextureGetUsage(
        self: *Texture,
    ) TextureUsage;

    /// TODO
    /// Return
    /// TODO
    const getUsage = wgpuTextureGetUsage;

    extern "C" fn wgpuTextureDestroy(
        self: *Texture,
    ) void;

    /// TODO
    const destroy = wgpuTextureDestroy;
};
pub const TextureView = opaque {
    extern "C" fn wgpuTextureViewSetLabel(
        self: *TextureView,
        label: StringView,
    ) void;

    /// TODO
    /// label
    /// TODO
    const setLabel = wgpuTextureViewSetLabel;
};
pub const AdapterInfo = extern struct {
    chain: ChainedStruct,
    /// TODO
    vendor: StringView,
    /// TODO
    architecture: StringView,
    /// TODO
    device: StringView,
    /// TODO
    description: StringView,
    /// TODO
    backend_type: BackendType,
    /// TODO
    adapter_type: AdapterType,
    /// TODO
    vendor_ID: u32,
    /// TODO
    device_ID: u32,
    /// TODO
    subgroup_min_size: u32,
    /// TODO
    subgroup_max_size: u32,
    extern "C" fn wgpuAdapterInfoFreeMembers(
        self: *AdapterInfo,
    ) void;
    const deinit = wgpuAdapterInfoFreeMembers;
};
pub const BindGroupDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    layout: BindGroupLayout,
    /// TODO
    entriesCount: usize,
    entries: *const BindGroupEntry,
};
pub const BindGroupEntry = extern struct {
    chain: ChainedStruct,
    /// Binding index in the bind group.
    binding: u32,
    /// Set this if the binding is a buffer object.
    /// Otherwise must be null.
    buffer: ?Buffer,
    /// If the binding is a buffer, this is the byte offset of the binding range.
    /// Otherwise ignored.
    offset: u64,
    /// If the binding is a buffer, this is the byte size of the binding range
    /// (@ref WGPU_WHOLE_SIZE means the binding ends at the end of the buffer).
    /// Otherwise ignored.
    size: u64,
    /// Set this if the binding is a sampler object.
    /// Otherwise must be null.
    sampler: ?Sampler,
    /// Set this if the binding is a texture view object.
    /// Otherwise must be null.
    texture_view: ?TextureView,
};
pub const BindGroupLayoutDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    entriesCount: usize,
    entries: *const BindGroupLayoutEntry,
};
pub const BindGroupLayoutEntry = extern struct {
    chain: ChainedStruct,
    /// TODO
    binding: u32,
    /// TODO
    visibility: ShaderStage,
    /// If non-zero, this entry defines a binding array with this size.
    binding_array_size: u32,
    /// TODO
    buffer: BufferBindingLayout,
    /// TODO
    sampler: SamplerBindingLayout,
    /// TODO
    texture: TextureBindingLayout,
    /// TODO
    storage_texture: StorageTextureBindingLayout,
};
pub const BlendComponent = extern struct {
    /// If set to @ref WGPUBlendOperation_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUBlendOperation_Add.
    operation: BlendOperation,
    /// If set to @ref WGPUBlendFactor_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUBlendFactor_One.
    src_factor: BlendFactor,
    /// If set to @ref WGPUBlendFactor_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUBlendFactor_Zero.
    dst_factor: BlendFactor,
};
pub const BlendState = extern struct {
    /// TODO
    color: BlendComponent,
    /// TODO
    alpha: BlendComponent,
};
pub const BufferBindingLayout = extern struct {
    chain: ChainedStruct,
    /// If set to @ref WGPUBufferBindingType_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUBufferBindingType_Uniform.
    type: BufferBindingType,
    /// TODO
    has_dynamic_offset: Bool,
    /// TODO
    min_binding_size: u64,
};
pub const BufferDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    usage: BufferUsage,
    /// TODO
    size: u64,
    /// When true, the buffer is mapped in write mode at creation. It should thus be unmapped once its initial data has been written.
    ///
    /// @note Mapping at creation does **not** require the usage @ref WGPUBufferUsage_MapWrite.
    mapped_at_creation: Bool,
};
pub const Color = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};
pub const ColorTargetState = extern struct {
    chain: ChainedStruct,
    /// The texture format of the target. If @ref WGPUTextureFormat_Undefined,
    /// indicates a "hole" in the parent @ref WGPUFragmentState `targets` array:
    /// the pipeline does not output a value at this `location`.
    format: TextureFormat,
    /// TODO
    blend: ?*const BlendState,
    /// TODO
    write_mask: ColorWriteMask,
};
pub const CommandBufferDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
};
pub const CommandEncoderDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
};
pub const CompatibilityModeLimits = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    max_storage_buffers_in_vertex_stage: u32,
    /// TODO
    max_storage_textures_in_vertex_stage: u32,
    /// TODO
    max_storage_buffers_in_fragment_stage: u32,
    /// TODO
    max_storage_textures_in_fragment_stage: u32,
};
pub const CompilationInfo = extern struct {
    chain: ChainedStruct,
    /// TODO
    messagesCount: usize,
    messages: *const CompilationMessage,
};
pub const CompilationMessage = extern struct {
    chain: ChainedStruct,
    /// A @ref LocalizableHumanReadableMessageString.
    message: StringView,
    /// Severity level of the message.
    type: CompilationMessageType,
    /// Line number where the message is attached, starting at 1.
    line_num: u64,
    /// Offset in UTF-8 code units (bytes) from the beginning of the line, starting at 1.
    line_pos: u64,
    /// Offset in UTF-8 code units (bytes) from the beginning of the shader code, starting at 0.
    offset: u64,
    /// Length in UTF-8 code units (bytes) of the span the message corresponds to.
    length: u64,
};
pub const ComputePassDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    timestamp_writes: ?*const PassTimestampWrites,
};
pub const ComputePipelineDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    layout: ?PipelineLayout,
    /// TODO
    compute: ComputeState,
};
pub const ComputeState = extern struct {
    chain: ChainedStruct,
    /// TODO
    module: ShaderModule,
    /// TODO
    entry_point: StringView,
    /// TODO
    constantsCount: usize,
    constants: *const ConstantEntry,
};
pub const ConstantEntry = extern struct {
    chain: ChainedStruct,
    /// TODO
    key: StringView,
    /// Represents a WGSL numeric or boolean value using @ref DoubleAsSupertype.
    ///
    /// If non-finite, produces a @ref NonFiniteFloatValueError.
    value: f64,
};
pub const DepthStencilState = extern struct {
    chain: ChainedStruct,
    /// TODO
    format: TextureFormat,
    /// TODO
    depth_write_enabled: OptionalBool,
    /// TODO
    depth_compare: CompareFunction,
    /// TODO
    stencil_front: StencilFaceState,
    /// TODO
    stencil_back: StencilFaceState,
    /// TODO
    stencil_read_mask: u32,
    /// TODO
    stencil_write_mask: u32,
    /// TODO
    depth_bias: i32,
    /// TODO
    ///
    /// If non-finite, produces a @ref NonFiniteFloatValueError.
    depth_bias_slope_scale: f32,
    /// TODO
    ///
    /// If non-finite, produces a @ref NonFiniteFloatValueError.
    depth_bias_clamp: f32,
};
pub const DeviceDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    required_featuresCount: usize,
    required_features: *const FeatureName,
    /// TODO
    required_limits: ?*const Limits,
    /// TODO
    default_queue: QueueDescriptor,
    /// TODO
    device_lost_callback_info: DeviceLostCallbackInfo,
    /// Called when there is an uncaptured error on this device, from any thread.
    /// See @ref ErrorScopes.
    ///
    /// **Important:** This callback does not have a configurable @ref WGPUCallbackMode; it may be called at any time (like @ref WGPUCallbackMode_AllowSpontaneous). As such, calls into the `webgpu.h` API from this callback are unsafe. See @ref CallbackReentrancy.
    uncaptured_error_callback_info: UncapturedErrorCallbackInfo,
};
pub const Extent3D = extern struct {
    /// TODO
    width: u32,
    /// TODO
    height: u32,
    /// TODO
    depth_or_array_layers: u32,
};
pub const ExternalTextureBindingEntry = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    external_texture: ExternalTexture,
};
pub const ExternalTextureBindingLayout = extern struct {
    chain: ?*ChainedStruct,
};
pub const FragmentState = extern struct {
    chain: ChainedStruct,
    /// TODO
    module: ShaderModule,
    /// TODO
    entry_point: StringView,
    /// TODO
    constantsCount: usize,
    constants: *const ConstantEntry,
    /// TODO
    targetsCount: usize,
    targets: *const ColorTargetState,
};
pub const Future = extern struct {
    /// Opaque id of the @ref WGPUFuture
    id: u64,
};
pub const FutureWaitInfo = extern struct {
    /// The future to wait on.
    future: Future,
    /// Whether or not the future completed.
    completed: Bool,
};
pub const InstanceDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    required_featuresCount: usize,
    required_features: *const InstanceFeatureName,
    /// TODO
    required_limits: ?*const InstanceLimits,
};
pub const InstanceLimits = extern struct {
    chain: ChainedStruct,
    /// The maximum number @ref WGPUFutureWaitInfo supported in a call to ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any_max_count: usize,
};
pub const Limits = extern struct {
    chain: ChainedStruct,
    /// TODO
    max_texture_dimension_1D: u32,
    /// TODO
    max_texture_dimension_2D: u32,
    /// TODO
    max_texture_dimension_3D: u32,
    /// TODO
    max_texture_array_layers: u32,
    /// TODO
    max_bind_groups: u32,
    /// TODO
    max_bind_groups_plus_vertex_buffers: u32,
    /// TODO
    max_bindings_per_bind_group: u32,
    /// TODO
    max_dynamic_uniform_buffers_per_pipeline_layout: u32,
    /// TODO
    max_dynamic_storage_buffers_per_pipeline_layout: u32,
    /// TODO
    max_sampled_textures_per_shader_stage: u32,
    /// TODO
    max_samplers_per_shader_stage: u32,
    /// TODO
    max_storage_buffers_per_shader_stage: u32,
    /// TODO
    max_storage_textures_per_shader_stage: u32,
    /// TODO
    max_uniform_buffers_per_shader_stage: u32,
    /// TODO
    max_uniform_buffer_binding_size: u64,
    /// TODO
    max_storage_buffer_binding_size: u64,
    /// TODO
    min_uniform_buffer_offset_alignment: u32,
    /// TODO
    min_storage_buffer_offset_alignment: u32,
    /// TODO
    max_vertex_buffers: u32,
    /// TODO
    max_buffer_size: u64,
    /// TODO
    max_vertex_attributes: u32,
    /// TODO
    max_vertex_buffer_array_stride: u32,
    /// TODO
    max_inter_stage_shader_variables: u32,
    /// TODO
    max_color_attachments: u32,
    /// TODO
    max_color_attachment_bytes_per_sample: u32,
    /// TODO
    max_compute_workgroup_storage_size: u32,
    /// TODO
    max_compute_invocations_per_workgroup: u32,
    /// TODO
    max_compute_workgroup_size_x: u32,
    /// TODO
    max_compute_workgroup_size_y: u32,
    /// TODO
    max_compute_workgroup_size_z: u32,
    /// TODO
    max_compute_workgroups_per_dimension: u32,
    /// TODO
    max_immediate_size: u32,
};
pub const MultisampleState = extern struct {
    chain: ChainedStruct,
    /// TODO
    count: u32,
    /// TODO
    mask: u32,
    /// TODO
    alpha_to_coverage_enabled: Bool,
};
pub const Origin3D = extern struct {
    /// TODO
    x: u32,
    /// TODO
    y: u32,
    /// TODO
    z: u32,
};
pub const PassTimestampWrites = extern struct {
    chain: ChainedStruct,
    /// Query set to write timestamps to.
    query_set: QuerySet,
    /// TODO
    beginning_of_pass_write_index: u32,
    /// TODO
    end_of_pass_write_index: u32,
};
pub const PipelineLayoutDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    bind_group_layoutsCount: usize,
    bind_group_layouts: *const BindGroupLayout,
    /// TODO
    immediate_size: u32,
};
pub const PrimitiveState = extern struct {
    chain: ChainedStruct,
    /// If set to @ref WGPUPrimitiveTopology_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUPrimitiveTopology_TriangleList.
    topology: PrimitiveTopology,
    /// TODO
    strip_index_format: IndexFormat,
    /// If set to @ref WGPUFrontFace_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUFrontFace_CCW.
    front_face: FrontFace,
    /// If set to @ref WGPUCullMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUCullMode_None.
    cull_mode: CullMode,
    /// TODO
    unclipped_depth: Bool,
};
pub const QuerySetDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    type: QueryType,
    /// TODO
    count: u32,
};
pub const QueueDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
};
pub const RenderBundleDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
};
pub const RenderBundleEncoderDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    color_formatsCount: usize,
    color_formats: *const TextureFormat,
    /// TODO
    depth_stencil_format: TextureFormat,
    /// TODO
    sample_count: u32,
    /// TODO
    depth_read_only: Bool,
    /// TODO
    stencil_read_only: Bool,
};
pub const RenderPassColorAttachment = extern struct {
    chain: ChainedStruct,
    /// If `NULL`, indicates a hole in the parent
    /// @ref WGPURenderPassDescriptor::colorAttachments array.
    view: ?TextureView,
    /// TODO
    depth_slice: u32,
    /// TODO
    resolve_target: ?TextureView,
    /// TODO
    load_op: LoadOp,
    /// TODO
    store_op: StoreOp,
    /// TODO
    clear_value: Color,
};
pub const RenderPassDepthStencilAttachment = extern struct {
    chain: ChainedStruct,
    /// TODO
    view: TextureView,
    /// TODO
    depth_load_op: LoadOp,
    /// TODO
    depth_store_op: StoreOp,
    /// This is a @ref NullableFloatingPointType.
    ///
    /// If `NaN`, indicates an `undefined` value (as defined by the JS spec).
    /// Use @ref WGPU_DEPTH_CLEAR_VALUE_UNDEFINED to indicate this semantically.
    ///
    /// If infinite, produces a @ref NonFiniteFloatValueError.
    depth_clear_value: f32,
    /// TODO
    depth_read_only: Bool,
    /// TODO
    stencil_load_op: LoadOp,
    /// TODO
    stencil_store_op: StoreOp,
    /// TODO
    stencil_clear_value: u32,
    /// TODO
    stencil_read_only: Bool,
};
pub const RenderPassDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    color_attachmentsCount: usize,
    color_attachments: *const RenderPassColorAttachment,
    /// TODO
    depth_stencil_attachment: ?*const RenderPassDepthStencilAttachment,
    /// TODO
    occlusion_query_set: ?QuerySet,
    /// TODO
    timestamp_writes: ?*const PassTimestampWrites,
};
pub const RenderPassMaxDrawCount = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    max_draw_count: u64,
};
pub const RenderPipelineDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    layout: ?PipelineLayout,
    /// TODO
    vertex: VertexState,
    /// TODO
    primitive: PrimitiveState,
    /// TODO
    depth_stencil: ?*const DepthStencilState,
    /// TODO
    multisample: MultisampleState,
    /// TODO
    fragment: ?*const FragmentState,
};
pub const RequestAdapterOptions = extern struct {
    chain: ChainedStruct,
    /// "Feature level" for the adapter request. If an adapter is returned, it must support the features and limits in the requested feature level.
    ///
    /// If set to @ref WGPUFeatureLevel_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUFeatureLevel_Core.
    /// Additionally, implementations may ignore @ref WGPUFeatureLevel_Compatibility
    /// and provide @ref WGPUFeatureLevel_Core instead.
    feature_level: FeatureLevel,
    /// TODO
    power_preference: PowerPreference,
    /// If true, requires the adapter to be a "fallback" adapter as defined by the JS spec.
    /// If this is not possible, the request returns null.
    force_fallback_adapter: Bool,
    /// If set, requires the adapter to have a particular backend type.
    /// If this is not possible, the request returns null.
    backend_type: BackendType,
    /// If set, requires the adapter to be able to output to a particular surface.
    /// If this is not possible, the request returns null.
    compatible_surface: ?Surface,
};
pub const RequestAdapterWebXROptions = extern struct {
    chain: ?*ChainedStruct,
    /// Sets the `xrCompatible` option in the JS API.
    xr_compatible: Bool,
};
pub const SamplerBindingLayout = extern struct {
    chain: ChainedStruct,
    /// If set to @ref WGPUSamplerBindingType_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUSamplerBindingType_Filtering.
    type: SamplerBindingType,
};
pub const SamplerDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// If set to @ref WGPUAddressMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_u: AddressMode,
    /// If set to @ref WGPUAddressMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_v: AddressMode,
    /// If set to @ref WGPUAddressMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_w: AddressMode,
    /// If set to @ref WGPUFilterMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUFilterMode_Nearest.
    mag_filter: FilterMode,
    /// If set to @ref WGPUFilterMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUFilterMode_Nearest.
    min_filter: FilterMode,
    /// If set to @ref WGPUFilterMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUMipmapFilterMode_Nearest.
    mipmap_filter: MipmapFilterMode,
    /// TODO
    ///
    /// If non-finite, produces a @ref NonFiniteFloatValueError.
    lod_min_clamp: f32,
    /// TODO
    ///
    /// If non-finite, produces a @ref NonFiniteFloatValueError.
    lod_max_clamp: f32,
    /// TODO
    compare: CompareFunction,
    /// TODO
    max_anisotropy: i16,
};
pub const ShaderModuleDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
};
pub const ShaderSourceSPIRV = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    code_size: u32,
    /// TODO
    code: *const u32,
};
pub const ShaderSourceWGSL = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    code: StringView,
};
pub const StencilFaceState = extern struct {
    /// If set to @ref WGPUCompareFunction_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUCompareFunction_Always.
    compare: CompareFunction,
    /// If set to @ref WGPUStencilOperation_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    fail_op: StencilOperation,
    /// If set to @ref WGPUStencilOperation_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    depth_fail_op: StencilOperation,
    /// If set to @ref WGPUStencilOperation_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    pass_op: StencilOperation,
};
pub const StorageTextureBindingLayout = extern struct {
    chain: ChainedStruct,
    /// If set to @ref WGPUStorageTextureAccess_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUStorageTextureAccess_WriteOnly.
    access: StorageTextureAccess,
    /// TODO
    format: TextureFormat,
    /// If set to @ref WGPUTextureViewDimension_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureViewDimension_2D.
    view_dimension: TextureViewDimension,
};
pub const SupportedFeatures = extern struct {
    /// TODO
    featuresCount: usize,
    features: *const FeatureName,
    extern "C" fn wgpuSupportedFeaturesFreeMembers(
        self: *SupportedFeatures,
    ) void;
    const deinit = wgpuSupportedFeaturesFreeMembers;
};
pub const SupportedInstanceFeatures = extern struct {
    /// TODO
    featuresCount: usize,
    features: *const InstanceFeatureName,
    extern "C" fn wgpuSupportedInstanceFeaturesFreeMembers(
        self: *SupportedInstanceFeatures,
    ) void;
    const deinit = wgpuSupportedInstanceFeaturesFreeMembers;
};
pub const SupportedWGSLLanguageFeatures = extern struct {
    /// TODO
    featuresCount: usize,
    features: *const WGSLLanguageFeatureName,
    extern "C" fn wgpuSupportedWGSLLanguageFeaturesFreeMembers(
        self: *SupportedWGSLLanguageFeatures,
    ) void;
    const deinit = wgpuSupportedWGSLLanguageFeaturesFreeMembers;
};
pub const SurfaceCapabilities = extern struct {
    chain: ChainedStruct,
    /// The bit set of supported @ref WGPUTextureUsage bits.
    /// Guaranteed to contain @ref WGPUTextureUsage_RenderAttachment.
    usages: TextureUsage,
    /// A list of supported @ref WGPUTextureFormat values, in order of preference.
    formatsCount: usize,
    formats: *const TextureFormat,
    /// A list of supported @ref WGPUPresentMode values.
    /// Guaranteed to contain @ref WGPUPresentMode_Fifo.
    present_modesCount: usize,
    present_modes: *const PresentMode,
    /// A list of supported @ref WGPUCompositeAlphaMode values.
    /// @ref WGPUCompositeAlphaMode_Auto will be an alias for the first element and will never be present in this array.
    alpha_modesCount: usize,
    alpha_modes: *const CompositeAlphaMode,
    extern "C" fn wgpuSurfaceCapabilitiesFreeMembers(
        self: *SurfaceCapabilities,
    ) void;
    const deinit = wgpuSurfaceCapabilitiesFreeMembers;
};
pub const SurfaceColorManagement = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    color_space: PredefinedColorSpace,
    /// TODO
    tone_mapping_mode: ToneMappingMode,
};
pub const SurfaceConfiguration = extern struct {
    chain: ChainedStruct,
    /// The @ref WGPUDevice to use to render to surface's textures.
    device: Device,
    /// The @ref WGPUTextureFormat of the surface's textures.
    format: TextureFormat,
    /// The @ref WGPUTextureUsage of the surface's textures.
    usage: TextureUsage,
    /// The width of the surface's textures.
    width: u32,
    /// The height of the surface's textures.
    height: u32,
    /// The additional @ref WGPUTextureFormat for @ref WGPUTextureView format reinterpretation of the surface's textures.
    view_formatsCount: usize,
    view_formats: *const TextureFormat,
    /// How the surface's frames will be composited on the screen.
    ///
    /// If set to @ref WGPUCompositeAlphaMode_Auto,
    /// [defaults] to @ref WGPUCompositeAlphaMode_Inherit in native (allowing the mode
    /// to be configured externally), and to @ref WGPUCompositeAlphaMode_Opaque in Wasm.
    alpha_mode: CompositeAlphaMode,
    /// When and in which order the surface's frames will be shown on the screen.
    ///
    /// If set to @ref WGPUPresentMode_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUPresentMode_Fifo.
    present_mode: PresentMode,
};
pub const SurfaceDescriptor = extern struct {
    chain: ChainedStruct,
    /// Label used to refer to the object.
    label: StringView,
};
pub const SurfaceSourceAndroidNativeWindow = extern struct {
    chain: ?*ChainedStruct,
    /// The pointer to the [`ANativeWindow`](https://developer.android.com/ndk/reference/group/a-native-window) that will be wrapped by the @ref WGPUSurface.
    window: *void,
};
pub const SurfaceSourceMetalLayer = extern struct {
    chain: ?*ChainedStruct,
    /// The pointer to the [`CAMetalLayer`](https://developer.apple.com/documentation/quartzcore/cametallayer?language=objc) that will be wrapped by the @ref WGPUSurface.
    layer: *void,
};
pub const SurfaceSourceWaylandSurface = extern struct {
    chain: ?*ChainedStruct,
    /// A [`wl_display`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_display) for this Wayland instance.
    display: *void,
    /// A [`wl_surface`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_surface) that will be wrapped by the @ref WGPUSurface
    surface: *void,
};
pub const SurfaceSourceWindowsHWND = extern struct {
    chain: ?*ChainedStruct,
    /// The [`HINSTANCE`](https://learn.microsoft.com/en-us/windows/win32/learnwin32/winmain--the-application-entry-point) for this application.
    /// Most commonly `GetModuleHandle(nullptr)`.
    hinstance: *void,
    /// The [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd) that will be wrapped by the @ref WGPUSurface.
    hwnd: *void,
};
pub const SurfaceSourceXCBWindow = extern struct {
    chain: ?*ChainedStruct,
    /// The `xcb_connection_t` for the connection to the X server.
    connection: *void,
    /// The `xcb_window_t` for the window that will be wrapped by the @ref WGPUSurface.
    window: u32,
};
pub const SurfaceSourceXlibWindow = extern struct {
    chain: ?*ChainedStruct,
    /// A pointer to the [`Display`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Opening_the_Display) connected to the X server.
    display: *void,
    /// The [`Window`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Creating_Windows) that will be wrapped by the @ref WGPUSurface.
    window: u64,
};
pub const SurfaceTexture = extern struct {
    chain: ChainedStruct,
    /// The @ref WGPUTexture representing the frame that will be shown on the surface.
    /// It is @ref ReturnedWithOwnership from @ref wgpuSurfaceGetCurrentTexture.
    texture: Texture,
    /// Whether the call to @ref wgpuSurfaceGetCurrentTexture succeeded and a hint as to why it might not have.
    status: SurfaceGetCurrentTextureStatus,
};
pub const TexelCopyBufferInfo = extern struct {
    /// TODO
    layout: TexelCopyBufferLayout,
    /// TODO
    buffer: Buffer,
};
pub const TexelCopyBufferLayout = extern struct {
    /// TODO
    offset: u64,
    /// TODO
    bytes_per_row: u32,
    /// TODO
    rows_per_image: u32,
};
pub const TexelCopyTextureInfo = extern struct {
    /// TODO
    texture: Texture,
    /// TODO
    mip_level: u32,
    /// TODO
    origin: Origin3D,
    /// If set to @ref WGPUTextureAspect_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureAspect_All.
    aspect: TextureAspect,
};
pub const TextureBindingLayout = extern struct {
    chain: ChainedStruct,
    /// If set to @ref WGPUTextureSampleType_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureSampleType_Float.
    sample_type: TextureSampleType,
    /// If set to @ref WGPUTextureViewDimension_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureViewDimension_2D.
    view_dimension: TextureViewDimension,
    /// TODO
    multisampled: Bool,
};
pub const TextureBindingViewDimension = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    texture_binding_view_dimension: TextureViewDimension,
};
pub const TextureComponentSwizzle = extern struct {
    /// The value that replaces the red channel in the shader.
    ///
    /// If set to @ref WGPUComponentSwizzle_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_R.
    r: ComponentSwizzle,
    /// The value that replaces the green channel in the shader.
    ///
    /// If set to @ref WGPUComponentSwizzle_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_G.
    g: ComponentSwizzle,
    /// The value that replaces the blue channel in the shader.
    ///
    /// If set to @ref WGPUComponentSwizzle_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_B.
    b: ComponentSwizzle,
    /// The value that replaces the alpha channel in the shader.
    ///
    /// If set to @ref WGPUComponentSwizzle_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_A.
    a: ComponentSwizzle,
};
pub const TextureComponentSwizzleDescriptor = extern struct {
    chain: ?*ChainedStruct,
    /// TODO
    swizzle: TextureComponentSwizzle,
};
pub const TextureDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    usage: TextureUsage,
    /// If set to @ref WGPUTextureDimension_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureDimension_2D.
    dimension: TextureDimension,
    /// TODO
    size: Extent3D,
    /// TODO
    format: TextureFormat,
    /// TODO
    mip_level_count: u32,
    /// TODO
    sample_count: u32,
    /// TODO
    view_formatsCount: usize,
    view_formats: *const TextureFormat,
};
pub const TextureViewDescriptor = extern struct {
    chain: ChainedStruct,
    /// TODO
    label: StringView,
    /// TODO
    format: TextureFormat,
    /// TODO
    dimension: TextureViewDimension,
    /// TODO
    base_mip_level: u32,
    /// TODO
    mip_level_count: u32,
    /// TODO
    base_array_layer: u32,
    /// TODO
    array_layer_count: u32,
    /// If set to @ref WGPUTextureAspect_Undefined,
    /// [defaults](@ref SentinelValues) to @ref WGPUTextureAspect_All.
    aspect: TextureAspect,
    /// TODO
    usage: TextureUsage,
};
pub const VertexAttribute = extern struct {
    chain: ChainedStruct,
    /// TODO
    format: VertexFormat,
    /// TODO
    offset: u64,
    /// TODO
    shader_location: u32,
};
pub const VertexBufferLayout = extern struct {
    chain: ChainedStruct,
    /// TODO
    step_mode: VertexStepMode,
    /// TODO
    array_stride: u64,
    /// TODO
    attributesCount: usize,
    attributes: *const VertexAttribute,
};
pub const VertexState = extern struct {
    chain: ChainedStruct,
    /// TODO
    module: ShaderModule,
    /// TODO
    entry_point: StringView,
    /// TODO
    constantsCount: usize,
    constants: *const ConstantEntry,
    /// TODO
    buffersCount: usize,
    buffers: *const VertexBufferLayout,
};
