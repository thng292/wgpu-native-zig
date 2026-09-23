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

extern "C" fn wgpuCreateInstance(descriptor:?*const InstanceDescriptor,)Instance;

extern "C" fn wgpuGetInstanceFeatures(features:*SupportedInstanceFeatures,)void;

extern "C" fn wgpuGetInstanceLimits(limits:*InstanceLimits,)Status;

extern "C" fn wgpuHasInstanceFeature(feature:InstanceFeatureName,)Bool;

