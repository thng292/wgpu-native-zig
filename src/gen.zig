const std = @import("std");

const logger = std.log.scoped(.main);

pub fn main(init: std.process.Init) !void {
    var args_iterator = init.minimal.args.iterate();
    _ = args_iterator.skip(); // skip args[0]
    const cwd = std.Io.Dir.cwd();
    var buffer: [512]u8 = undefined;
    const buf: []u8 = &buffer;
    const arena = init.arena.allocator();
    while (args_iterator.next()) |file| {
        defer _ = init.arena.reset(.retain_capacity);
        logger.debug("processing: {s}", .{file});

        const input_json = try cwd.openFile(init.io, file, .{ .mode = .read_only });
        errdefer input_json.close(init.io);

        var reader = input_json.reader(init.io, buf);
        const input_json_content = try reader.interface.readAlloc(arena, try input_json.length(init.io));
        input_json.close(init.io);
        defer arena.free(input_json_content);

        const parsed = try std.json.parseFromSlice(
            Yml,
            arena,
            input_json_content,
            .{
                .allocate = .alloc_if_needed,
                .ignore_unknown_fields = true,
                .duplicate_field_behavior = .@"error",
                .parse_numbers = true,
            },
        );
        errdefer parsed.deinit();
        logger.debug("{s}", .{parsed.value.copyright});
        const zig_code = try generateZigCode(parsed.value, arena);
        defer arena.free(zig_code);
        parsed.deinit();

        const outfile_name = try std.mem.concat(arena, u8, &.{ file, ".zig" });
        defer arena.free(outfile_name);
        const outfile = try cwd.createFile(init.io, outfile_name, .{});
        try outfile.writeStreamingAll(init.io, zig_code);
        outfile.close(init.io);
    }
}

fn generateZigCode(spec: Yml, allocator: std.mem.Allocator) ![]u8 {
    var results: std.Io.Writer.Allocating = .init(allocator);
    var writer = &results.writer;

    // ---------------Copyright---------------
    try writeComment(spec.copyright, .top, writer);
    try writeComment(spec.doc, .top, writer);

    // ---------------Copyright---------------
    _ = try writer.write(@embedFile("template.zig"));

    for (spec.typedefs) |typedef| {
        _ = std.ascii.upperString(typedef.name, typedef.name);
        _ = std.ascii.upperString(typedef.type, typedef.type);
        if (typedef.doc.len > 0) {
            try writeComment(typedef.doc, .doc, writer);
        }
        _ = try writer.write("pub const ");
        _ = try writer.write(typedef.name);
        _ = try writer.write(" = ");
        try renderTypeName(spec, typedef.type, writer);
        _ = try writer.write(";\n\n");
    }

    for (spec.constants) |*constant| {
        _ = std.ascii.upperString(constant.name, constant.name);
        _ = std.ascii.upperString(constant.value, constant.value);
        if (constant.doc.len > 0) {
            try writeComment(constant.doc, .doc, writer);
        }
        try writer.print("pub const {s} = {s};\n\n", .{ constant.name, constant.value });
    }

    for (spec.functions) |function| {
        try renderCFunction(spec, function, writer);
        try writer.writeByte('\n');
        try writer.writeByte('\n');
    }

    try writer.flush();
    return results.toOwnedSlice();
}

fn writeComment(comment_: []const u8, kind: enum { normal, doc, top }, writer: *std.Io.Writer) !void {
    const comment = std.mem.trim(u8, comment_, &std.ascii.whitespace);
    var line_iter = std.mem.splitAny(u8, comment, "\n");
    while (line_iter.next()) |line| {
        switch (kind) {
            .normal => try writer.print("// {s}\n", .{line}),
            .doc => try writer.print("/// {s}\n", .{line}),
            .top => try writer.print("//! {s}\n", .{line}),
        }
    }
}

fn convertSnakeToCamel(input: []const u8, writer: *std.Io.Writer) !void {
    var next_upper = false;
    for (input) |c| {
        if (c == '_') {
            next_upper = true;
            continue;
        }
        if (next_upper) {
            try writer.writeByte(std.ascii.toUpper(c));
        } else {
            try writer.writeByte(c);
        }
        next_upper = false;
    }
}

fn convertSnakeToPascal(input: []const u8, writer: *std.Io.Writer) !void {
    var next_upper = true;
    for (input) |c| {
        if (c == '_') {
            next_upper = true;
            continue;
        }
        if (next_upper) {
            try writer.writeByte(std.ascii.toUpper(c));
        } else {
            try writer.writeByte(c);
        }
        next_upper = false;
    }
}

const QueryResult = union(enum) {
    constant: Constant,
    typedef: Typedef,
    @"enum": Enum,
    bitflag: Bitflag,
    @"struct": Struct,
    callback: Callback,
    function: Function,
    object: Object,
};

fn queryRef(spec: Yml, query: []const u8) ?QueryResult {
    // Query format: stuff.inner
    var split_iter = std.mem.splitAny(u8, query, ".");
    const stuff = split_iter.next() orelse return null;
    const inner = split_iter.rest();
    const QueryResultTag = std.meta.Tag(QueryResult);
    const tag = std.meta.stringToEnum(QueryResultTag, stuff) orelse return null;
    switch (tag) {
        inline else => |field| {
            const items = @field(spec, @tagName(field) ++ "s");
            for (items) |item| {
                if (std.mem.eql(u8, item.name, inner)) {
                    return @unionInit(QueryResult, @tagName(field), item);
                }
            }
        },
    }

    return null;
}

fn renderTypeName(spec: Yml, type_name: []const u8, writer: *std.Io.Writer) !void {
    const prefined_type_map: std.StaticStringMap([]const u8) = .initComptime(.{
        .{ "bool", "Bool" },
        .{ "string_with_default_empty", "StringView" },
        .{ "out_string", "StringView" },
        .{ "nullable_string", "StringView" },
        .{ "int16", "i16" },
        .{ "uint16", "i16" },
        .{ "int32", "i32" },
        .{ "uint32", "u32" },
        .{ "int64", "i64" },
        .{ "uint64", "u64" },
        .{ "usize", "usize" },
        .{ "float32", "f32" },
        .{ "nullable_float32", "f32" },
        .{ "float64", "f64" },
        .{ "float64_supertype", "f64" },
        .{ "c_void", "void" },
        .{ "c_void_data_ptr", "void" },
        .{ "c_void_mapped_range_ptr", "void" },
        .{ "c_void_a_native_window", "void" },
        .{ "c_void_ca_metal_layer", "void" },
        .{ "c_void_h_instance", "void" },
        .{ "c_void_h_wnd", "void" },
        .{ "c_void_wl_display", "void" },
        .{ "c_void_wl_surface", "void" },
        .{ "c_void_x11_display", "void" },
        .{ "c_void_xcb_connection", "void" },
    });
    if (prefined_type_map.get(type_name)) |name| {
        _ = try writer.write(name);
        return;
    }
    if (queryRef(spec, type_name)) |query_result| {
        switch (query_result) {
            inline else => |value| {
                try convertSnakeToPascal(value.name, writer);
            },
        }
    } else {
        _ = try writer.write(type_name);
    }
}

fn renderCParam(spec: Yml, param: ParameterType, writer: *std.Io.Writer) !void {
    const array_start = "array<";
    if (std.mem.startsWith(u8, param.type, array_start)) {
        _ = try writer.write(param.name.?[0 .. param.name.?.len - 1]);
        _ = try writer.write("Count: usize,");

        _ = try writer.write(param.name.?);
        try writer.writeByte(':');
        try renderPtrAndOptional(param.optional, param.pointer, writer);
        try renderTypeName(spec, param.type[array_start.len .. param.type.len - 1], writer);
    } else {
        _ = try writer.write(param.name.?);
        try writer.writeByte(':');
        try renderPtrAndOptional(param.optional, param.pointer, writer);
        try renderTypeName(spec, param.type, writer);
    }
}

fn renderParam(spec: Yml, param: ParameterType, writer: *std.Io.Writer) !void {
    _ = try writer.write(param.name.?);
    try writer.writeByte(':');
    try renderPtrAndOptional(param.optional, param.pointer, writer);
    try renderTypeName(spec, param.type, writer);
}

fn renderCFunction(spec: Yml, function: Function, writer: *std.Io.Writer) !void {
    _ = try writer.write("extern \"C\" fn wgpu");
    try convertSnakeToPascal(function.name, writer);

    try writer.writeByte('(');
    for (function.args) |arg| {
        try renderCParam(spec, arg, writer);
        try writer.writeByte(',');
    }
    try writer.writeByte(')');

    if (function.returns) |rt| {
        try renderPtrAndOptional(rt.optional, rt.pointer, writer);
        try renderTypeName(spec, rt.type, writer);
    } else {
        _ = try writer.write("void");
    }

    try writer.writeByte(';');
}

fn renderPtrAndOptional(
    optional: bool,
    pointer: ?PointerType,
    writer: *std.Io.Writer,
) !void {
    if (optional) _ = try writer.write("?");
    if (pointer) |ptr_type| {
        _ = try writer.write("*");
        switch (ptr_type) {
            .immutable => _ = try writer.write("const "),
            .mutable => {},
        }
    }
}

pub const PointerType = enum {
    mutable,
    immutable,
};

pub const Base = struct {
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,
};

pub const Yml = struct {
    copyright: []u8,
    name: []u8,
    doc: []u8,
    enum_prefix: u16,

    constants: []Constant = &[_]Constant{},
    typedefs: []Typedef = &[_]Typedef{},
    enums: []Enum = &[_]Enum{},
    bitflags: []Bitflag = &[_]Bitflag{},
    structs: []Struct = &[_]Struct{},
    callbacks: []Callback = &[_]Callback{},
    functions: []Function = &[_]Function{},
    objects: []Object = &[_]Object{},
};

pub const Constant = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    value: []u8,
};

pub const Typedef = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    type: []u8,
};

pub const Enum = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    entries: []?EnumEntry = &[_]?EnumEntry{},
};

pub const EnumEntry = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    value: ?u16 = null,
};

pub const Bitflag = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    entries: []BitflagEntry = &[_]BitflagEntry{},
};

pub const BitflagEntry = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    value: ?[]u8 = null,
    value_combination: [][]u8 = &[_][]u8{},
};

pub const ParameterType = struct {
    name: ?[]u8 = null,
    namespace: []u8 = "",
    doc: []u8 = "",
    type: []u8,
    passed_with_ownership: ?bool = null,
    pointer: ?PointerType = null,
    optional: bool = false,
    default: ?std.json.Value = null,
};

pub const Callback = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    style: []u8,
    args: []ParameterType = &[_]ParameterType{},
};

pub const Function = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    returns: ?ParameterType = null,
    callback: ?[]u8 = null,
    args: []ParameterType = &[_]ParameterType{},
};

pub const Struct = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    type: []u8,
    free_members: bool = false,
    members: []ParameterType = &[_]ParameterType{},
    extends: [][]u8 = &[_][]u8{},
};

pub const Object = struct {
    // Base (yaml:",inline")
    name: []u8,
    namespace: []u8 = "",
    doc: []u8 = "",
    extended: bool = false,

    methods: []Function = &[_]Function{},
};
