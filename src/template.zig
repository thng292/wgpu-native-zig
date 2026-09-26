// --------------------TEMPLATE_START--------------------

const std = @import("std");
pub const helpers = @import("helpers.zig");

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
