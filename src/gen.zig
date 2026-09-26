const std = @import("std");

const logger = std.log.scoped(.main);
const RAW = false;

pub fn main(init: std.process.Init) !void {
    var args_iterator = init.minimal.args.iterate();
    _ = args_iterator.skip(); // skip args[0]
    const cwd = std.Io.Dir.cwd();
    const buf: []u8 = try init.gpa.alloc(u8, 512);
    defer init.gpa.free(buf);
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
        var ctx: Context = .{ .spec = parsed.value, .allocator = arena };
        const zig_code = try generateZigCode(&ctx);
        defer arena.free(zig_code);
        parsed.deinit();

        const outfile_name = try std.mem.concat(arena, u8, &.{ file, ".zig" });
        defer arena.free(outfile_name);
        const outfile = try cwd.createFile(init.io, outfile_name, .{});
        if (RAW) {
            try outfile.writeStreamingAll(init.io, zig_code);
        } else {
            var ast = try std.zig.Ast.parse(init.gpa, zig_code, .zig);
            defer ast.deinit(init.gpa);

            if (ast.errors.len > 0) {
                for (ast.errors) |err| {
                    logger.debug("kind: {t}", .{err.tag});
                }
            }
            var outfile_writer = outfile.writer(init.io, buf);
            const interface = &outfile_writer.interface;
            try ast.render(init.gpa, interface, .{ .rebase_imported_paths = null });
            try interface.flush();
        }
        outfile.close(init.io);
    }
}

fn generateZigCode(ctx: *Context) ![:0]u8 {
    var results: std.Io.Writer.Allocating = .init(ctx.allocator);
    var writer = &results.writer;
    // ---------------Copyright---------------
    try renderComment(ctx.spec.copyright, .top, writer);
    try renderComment(ctx.spec.doc, .top, writer);

    // ---------------Copyright---------------
    _ = try writer.write(@embedFile("template.zig"));

    for (ctx.spec.typedefs) |typedef| {
        logger.debug("Generating typedef: {s}", .{typedef.name});
        if (typedef.doc.len > 0) {
            try renderComment(typedef.doc, .doc, writer);
        }
        _ = try writer.write("pub const ");
        try convertSnakeToPascal(typedef.name, writer);
        _ = try writer.write(" = ");
        try renderTypeName(ctx, typedef.type, writer);
        _ = try writer.write(";\n\n");
    }

    for (ctx.spec.constants) |constant| {
        logger.debug("Generating constant: {s}", .{constant.name});
        const upper_name = try ctx.allocator.alloc(u8, constant.name.len);
        defer ctx.allocator.free(upper_name);
        _ = std.ascii.upperString(upper_name, constant.name);

        const upper_value = try ctx.allocator.alloc(u8, constant.value.len);
        defer ctx.allocator.free(upper_value);
        _ = std.ascii.upperString(upper_value, constant.value);

        if (constant.doc.len > 0) {
            try renderComment(constant.doc, .doc, writer);
        }
        try writer.print("pub const {s} = {s};\n\n", .{ upper_name, upper_value });
    }
    for (ctx.spec.enums) |enumm| {
        logger.debug(
            "Generating enum: {s}, with {} memebers",
            .{ enumm.name, enumm.entries.len },
        );
        if (enumm.doc.len > 0) {
            try renderComment(enumm.doc, .doc, writer);
        }
        _ = try writer.write("pub const ");
        try convertSnakeToPascal(enumm.name, writer);
        _ = try writer.write(" = enum(u32) {\n");
        for (enumm.entries, 0..) |entry_, i| {
            if (entry_ == null) continue;
            const entry = entry_.?;
            if (entry.doc.len > 0) {
                try renderComment(entry.doc, .doc, writer);
            }
            try writer.print("@\"{s}\" = 0x{X:0>8},\n", .{ entry.name, entry.value orelse i });
        }
        _ = try writer.write("};\n\n");
    }
    for (ctx.spec.bitflags) |bitflag| {
        logger.debug(
            "Generating bitfag: {s}, with {} options",
            .{ bitflag.name, bitflag.entries.len },
        );
        _ = try writer.write("pub const ");
        try convertSnakeToPascal(bitflag.name, writer);
        _ = try writer.write(" = packed struct(Flags) {\n");
        var left: u6 = 63;
        for (bitflag.entries, 0..) |entry, i| {
            if (i == 0 and std.mem.eql(u8, entry.name, "none")) continue;
            if (entry.doc.len > 0) {
                try renderComment(entry.doc, .doc, writer);
            }
            try writer.print("@\"{s}\": bool = false,\n", .{entry.name});
            left -= 1;
        }
        try writer.print("__unused: u{} = 0,\n", .{left + 1});
        _ = try writer.write("};\n");
    }
    for (ctx.spec.callbacks) |cb| {
        logger.debug(
            "Generating callback: {s}, has {} args, style {s}",
            .{ cb.name, cb.args.len, cb.style },
        );
        if (cb.doc.len > 0) {
            try renderComment(cb.doc, .doc, writer);
        }
        for (cb.args) |arg| {
            if (arg.doc.len > 0) {
                try renderComment(arg.name.?, .doc, writer);
                try renderComment(arg.doc, .doc, writer);
            }
        }
        _ = try writer.write("const ");
        try convertSnakeToPascal(cb.name, writer);
        _ = try writer.write(
            \\CallbackInfo = extern struct {
            \\ nextInChain: ?*ChainedStruct,
            \\
        );
        if (std.mem.eql(u8, cb.style, "callback_mode")) {
            _ = try writer.write("mode: CallbackMode,\n");
        }
        _ = try writer.write("callback: *const ");
        // Callback type w/o *
        _ = try writer.write("fn (");
        for (cb.args) |arg| {
            if (isParamObject(arg)) {
                var arg_ = arg;
                arg_.optional = true;
                try renderCParam(ctx, arg_, writer);
            } else {
                try renderCParam(ctx, arg, writer);
            }
            try writer.writeByte(',');
        }
        _ = try writer.write("user_data1: ?*void, user_data2: ?*void,");
        _ = try writer.write(") callconv(.c) void,\n");

        _ = try writer.write(
            \\userdata1: ?*void,
            \\userdata2: ?*void,
            \\};
            \\
        );
    }

    // ------------------------For C extern functions------------------------
    for (ctx.spec.functions) |function| {
        logger.debug(
            "Generating C function: {s}, has {} args, return {s}",
            .{ function.name, function.args.len, if (function.returns) |rt| rt.type else "void" },
        );
        try renderCFunction(ctx, "", function, writer);
        try writer.writeByte('\n');
        try renderZigMapper(ctx, "", function, writer);
        try writer.writeByte('\n');
    }

    var tmp_args: std.ArrayList(ParameterType) = try .initCapacity(ctx.allocator, 10);
    defer tmp_args.deinit(ctx.allocator);
    for (ctx.spec.objects) |obj| {
        logger.debug(
            "Generating object: {s}, with {} methods",
            .{ obj.name, obj.methods.len },
        );
        _ = try writer.write("pub const ");
        try convertSnakeToPascal(obj.name, writer);
        _ = try writer.write(" = opaque {\n");
        for (obj.methods) |function| {
            logger.debug(
                "Generating C function (method): {s}, has {} args, return {s}",
                .{ function.name, function.args.len, if (function.returns) |rt| rt.type else "void" },
            );
            tmp_args.clearRetainingCapacity();
            try tmp_args.append(ctx.allocator, .{
                .type = try std.fmt.allocPrint(ctx.allocator, "object.{s}", .{obj.name}),
                .name = "self",
                .pointer = .mutable,
                .passed_with_ownership = false,
            });
            try tmp_args.appendSlice(ctx.allocator, function.args);
            var tmp_fn = function;
            tmp_fn.args = tmp_args.items;
            try renderCFunction(ctx, obj.name, tmp_fn, writer);

            try writer.writeByte('\n');

            try renderZigMapper(ctx, obj.name, tmp_fn, writer);
            try writer.writeByte('\n');
        }
        // Need a release function too
        const release: Function = .{
            .name = "release",
            .returns = null,
            .args = &.{ParameterType{
                .name = "self",
                .type = try std.fmt.allocPrint(ctx.allocator, "object.{s}", .{obj.name}),
            }},
        };
        try renderCFunction(ctx, obj.name, release, writer);
        _ = try writer.write("pub const deinit = wgpu");
        try renderCFunctionName(ctx, obj.name, release, writer);
        _ = try writer.write(";\n");
        _ = try writer.write("};\n");
    }

    for (ctx.spec.structs) |structt| {
        try renderStruct(ctx, structt, writer);
    }
    // ------------------------For C extern functions------------------------
    try writer.flush();
    return results.toOwnedSliceSentinel(0);
}

fn renderComment(comment_: []const u8, kind: enum { normal, doc, top }, writer: *std.Io.Writer) !void {
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

fn queryRef(ctx: *Context, query: []const u8) ?QueryResult {
    // Query format: stuff.inner
    var split_iter = std.mem.splitAny(u8, query, ".");
    const stuff = split_iter.next() orelse return null;
    const inner = split_iter.rest();
    const QueryResultTag = std.meta.Tag(QueryResult);
    const tag = std.meta.stringToEnum(QueryResultTag, stuff) orelse return null;
    switch (tag) {
        inline else => |field| {
            const items = @field(ctx.spec, @tagName(field) ++ "s");
            for (items) |item| {
                if (std.mem.eql(u8, item.name, inner)) {
                    return @unionInit(QueryResult, @tagName(field), item);
                }
            }
        },
    }

    return null;
}

fn renderTypeName(ctx: *Context, type_name: []const u8, writer: *std.Io.Writer) !void {
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
    if (queryRef(ctx, type_name)) |query_result| {
        switch (query_result) {
            .callback => |cb| {
                try convertSnakeToPascal(cb.name, writer);
                _ = try writer.write("CallbackInfo");
            },
            inline else => |value| {
                try convertSnakeToPascal(value.name, writer);
            },
        }
    } else {
        _ = try writer.write(type_name);
    }
}

fn renderCParam(ctx: *Context, param: ParameterType, writer: *std.Io.Writer) !void {
    if (isParamArray(param)) {
        _ = try writer.write(param.name.?);
        _ = try writer.write("Count: usize,");

        _ = try writer.write(param.name.?);
        try writer.writeByte(':');
        try renderOptionalAndPtr(param.optional, param.pointer, writer);
        try renderTypeName(ctx, param.type[ARRAY_START.len .. param.type.len - 1], writer);
    } else {
        _ = try writer.write(param.name.?);
        try writer.writeByte(':');
        if (isParamObject(param)) {
            try renderOptionalAndPtr(param.optional, param.pointer orelse .mutable, writer);
        } else {
            try renderOptionalAndPtr(param.optional, param.pointer, writer);
        }
        try renderTypeName(ctx, param.type, writer);
    }
}

fn renderCFunctionName(ctx: *Context, prefix: []const u8, function: Function, writer: *std.Io.Writer) !void {
    _ = ctx;
    try convertSnakeToPascal(prefix, writer);

    try convertSnakeToPascal(function.name, writer);
}

fn renderCFunction(ctx: *Context, prefix: []const u8, function: Function, writer: *std.Io.Writer) !void {
    _ = try writer.write("extern \"C\" fn wgpu");
    try renderCFunctionName(ctx, prefix, function, writer);

    try writer.writeByte('(');
    for (function.args) |arg| {
        try renderCParam(ctx, arg, writer);
        try writer.writeByte(',');
    }
    if (function.callback) |cb| {
        try renderCParam(ctx, .{
            .name = "callback",
            .type = cb,
        }, writer);
        try writer.writeByte(',');
    }
    try writer.writeByte(')');

    if (function.returns) |rt| {
        if (isParamObject(rt)) {
            try renderOptionalAndPtr(rt.optional, rt.pointer orelse .mutable, writer);
        } else {
            try renderOptionalAndPtr(rt.optional, rt.pointer, writer);
        }
        try renderTypeName(ctx, rt.type, writer);
    } else if (function.callback) |_| {
        _ = try writer.write("Future");
    } else {
        _ = try writer.write("void");
    }

    _ = try writer.write(";\n");
}

fn renderOptionalAndPtr(
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

fn renderStruct(ctx: *Context, structt: Struct, writer: *std.Io.Writer) !void {
    _ = try writer.write("pub const ");
    try convertSnakeToPascal(structt.name, writer);
    _ = try writer.write(" = extern struct {\n");
    if (std.mem.eql(u8, structt.type, "extensible") //
    or std.mem.eql(u8, structt.type, "extensible_callback_arg")) {
        _ = try writer.write("chain: ?*ChainedStruct,\n");
    } else if (std.mem.eql(u8, structt.type, "extension")) {
        _ = try writer.write("chain: ChainedStruct,\n");
    } else if (std.mem.eql(u8, structt.type, "standalone")) {} else {
        //
    }
    for (structt.members) |member| {
        if (member.doc.len > 0) {
            try renderComment(member.doc, .doc, writer);
        }
        if (isParamArray(member)) {
            _ = try writer.write(member.name.?);
            _ = try writer.write("Count: usize,\n");

            try writer.print("@\"{s}\": ", .{member.name.?});
            try renderOptionalAndPtr(member.optional, member.pointer, writer);
            try renderTypeName(ctx, member.type[ARRAY_START.len .. member.type.len - 1], writer);
        } else {
            try writer.print("@\"{s}\": ", .{member.name.?});
            if (isParamObject(member)) {
                try renderOptionalAndPtr(member.optional, member.pointer orelse .mutable, writer);
            } else {
                try renderOptionalAndPtr(member.optional, member.pointer, writer);
            }
            try renderTypeName(ctx, member.type, writer);
        }
        _ = try writer.write(",\n");
    }
    if (structt.free_members) {
        logger.debug(
            "Generating free members function for struct: {s}",
            .{structt.name},
        );
        const args = try ctx.allocator.alloc(ParameterType, 1);
        args[0] = .{
            .name = "self",
            .type = try std.fmt.allocPrint(ctx.allocator, "struct.{s}", .{structt.name}),
            .pointer = null,
            .passed_with_ownership = true,
        };
        const function: Function = .{
            .name = "FreeMembers",
            .returns = null,
            .args = args,
        };
        try renderCFunction(ctx, structt.name, function, writer);
        _ = try writer.write("pub const deinit = wgpu");
        try renderCFunctionName(ctx, structt.name, function, writer);
        _ = try writer.write(";\n");
    }
    _ = try writer.write("};\n");
}

fn renderZigMapper(ctx: *Context, prefix: []const u8, function: Function, writer: *std.Io.Writer) !void {
    var has_array = false;
    for (function.args) |arg| {
        has_array = has_array or isParamArray(arg);
    }
    if (function.doc.len > 0) {
        try renderComment(function.doc, .doc, writer);
    }
    for (function.args) |arg| {
        if (arg.doc.len > 0) {
            try renderComment(arg.name.?, .doc, writer);
            try renderComment(arg.doc, .doc, writer);
        }
    }
    if (function.returns) |rt| {
        if (rt.doc.len > 0) {
            try renderComment("Return", .doc, writer);
            try renderComment(rt.doc, .doc, writer);
        }
    }
    if (has_array) {
        // generate mapper with slice
        _ = try writer.write("pub fn ");
        try convertSnakeToCamel(function.name, writer);

        try writer.writeByte('(');
        for (function.args) |arg| {
            if (isParamArray(arg)) {
                _ = try writer.write(arg.name.?);
                _ = try writer.write(": []");
                try renderOptionalAndPtr(arg.optional, arg.pointer, writer);
                try renderTypeName(ctx, arg.type[ARRAY_START.len .. arg.type.len - 1], writer);
            } else {
                try renderCParam(ctx, arg, writer);
            }
            try writer.writeByte(',');
        }
        if (function.callback) |cb| {
            try renderCParam(ctx, .{
                .name = "callback",
                .type = cb,
            }, writer);
            try writer.writeByte(',');
        }
        try writer.writeByte(')');

        if (function.returns) |rt| {
            if (isParamObject(rt)) {
                try renderOptionalAndPtr(rt.optional, rt.pointer orelse .mutable, writer);
            } else {
                try renderOptionalAndPtr(rt.optional, rt.pointer, writer);
            }
        } else if (function.callback) |_| {
            _ = try writer.write("Future");
        } else {
            _ = try writer.write("void");
        }

        _ = try writer.write(" {\nwgpu");
        try renderCFunctionName(ctx, prefix, function, writer);
        _ = try writer.write("(");
        // Call the C function
        for (function.args) |arg| {
            if (isParamArray(arg)) {
                try writer.print("{s}.len, {s}.ptr", .{ arg.name.?, arg.name.? });
            } else {
                _ = try writer.write(arg.name.?);
            }
            try writer.writeByte(',');
        }
        _ = try writer.write(");}\n");
    } else {
        // rename
        _ = try writer.write("pub const ");
        try convertSnakeToCamel(function.name, writer);

        _ = try writer.write("=wgpu");
        try renderCFunctionName(ctx, prefix, function, writer);
        _ = try writer.write(";\n");
    }
}

fn isParamArray(param: ParameterType) bool {
    return std.mem.startsWith(u8, param.type, ARRAY_START);
}

fn isParamObject(param: ParameterType) bool {
    return std.mem.startsWith(u8, param.type, "object.");
}

pub const Context = struct {
    spec: Yml,
    allocator: std.mem.Allocator,
};

pub const PointerType = enum {
    mutable,
    immutable,
};

pub const Base = struct {
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,
};

pub const Yml = struct {
    copyright: []const u8,
    name: []const u8,
    doc: []const u8,
    enum_prefix: u16,

    constants: []const Constant = &[_]Constant{},
    typedefs: []const Typedef = &[_]Typedef{},
    enums: []const Enum = &[_]Enum{},
    bitflags: []const Bitflag = &[_]Bitflag{},
    structs: []const Struct = &[_]Struct{},
    callbacks: []const Callback = &[_]Callback{},
    functions: []const Function = &[_]Function{},
    objects: []const Object = &[_]Object{},
};

pub const Constant = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    value: []const u8,
};

pub const Typedef = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    type: []const u8,
};

pub const Enum = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    entries: []const ?EnumEntry = &[_]?EnumEntry{},
};

pub const EnumEntry = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    value: ?u16 = null,
};

pub const Bitflag = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    entries: []const BitflagEntry = &[_]BitflagEntry{},
};

pub const BitflagEntry = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    value: ?[]const u8 = null,
    value_combination: [][]const u8 = &[_][]const u8{},
};

pub const ParameterType = struct {
    name: ?[]const u8 = null,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    type: []const u8,
    passed_with_ownership: ?bool = null,
    pointer: ?PointerType = null,
    optional: bool = false,
    default: ?std.json.Value = null,
};

pub const Callback = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    style: []const u8,
    args: []ParameterType = &[_]ParameterType{},
};

pub const Function = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    returns: ?ParameterType = null,
    callback: ?[]const u8 = null,
    args: []const ParameterType = &[_]ParameterType{},
};

pub const Struct = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    type: []const u8,
    free_members: bool = false,
    members: []const ParameterType = &[_]ParameterType{},
    extends: []const []const u8 = &[_][]const u8{},
};

pub const Object = struct {
    // Base (yaml:",inline")
    name: []const u8,
    namespace: []const u8 = "",
    doc: []const u8 = "",
    extended: bool = false,

    methods: []const Function = &[_]Function{},
};

const ARRAY_START = "array<";
