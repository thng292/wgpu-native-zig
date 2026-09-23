const std = @import("std");

const logger = std.log.scoped(.main);

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
    const tmpBuf = try allocator.alloc(u8, 2048);

    // ---------------Copyright---------------
    try writeMutilineComment(spec.copyright, .top, writer);
    try writeMutilineComment(spec.doc, .top, writer);

    // ---------------Copyright---------------
    _ = try writer.write(
        \\
        \\// --------------------TEMPLATE_START--------------------
        \\
        \\const std = @import("std");
        \\
        \\// These are some hard-coded values.
        \\const UINT32_MAX = std.math.maxInt(u32);
        \\const UINT64_MAX = std.math.maxInt(u64);
        \\const USIZE_MAX = std.math.maxInt(usize);
        \\const NAN = std.math.nan(f32);
        \\
        \\const TRUE: u32 = 1;
        \\const FALSE: u32 = 0;
        \\// --------------------TEMPLATE_END----------------------
        \\
        \\
    );
    // Generate the constants first
    for (spec.constants) |*constant| {
        _ = std.ascii.upperString(constant.name, constant.name);
        _ = std.ascii.upperString(constant.value, constant.value);
        if (constant.doc.len > 0) {
            try writeMutilineComment(constant.doc, .doc, writer);
        }
        try writer.print("const {s} = {s};\n\n", .{ constant.name, constant.value });
    }

    for (spec.functions) |function| {
        const fun_name = convertSnakeToPascal(function.name, tmpBuf);
        var remaining_buf = tmpBuf[fun_name.len..];
        for (function.args) |arg| {
            const tmp = renderParam(arg, remaining_buf);
            remaining_buf[tmp.len] = ',';
            remaining_buf = remaining_buf[tmp.len + 1 ..];
        }
        const args = tmpBuf[fun_name.len .. tmpBuf.len - remaining_buf.len];
        try writer.print("extern \"C\" fn wgpu{s}({s}) {s};\n", .{ fun_name, args, "void" });
    }

    try writer.flush();
    return results.toOwnedSlice();
}

fn writeMutilineComment(comment_: []const u8, kind: enum { normal, doc, top }, writer: *std.Io.Writer) !void {
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

fn convertSnakeToCamel(input: []const u8, output: []u8) []const u8 {
    std.debug.assert(input.len <= output.len);
    var write_count: usize = 0;
    var next_upper = false;
    for (input) |c| {
        if (c == '_') {
            next_upper = true;
            continue;
        }
        if (next_upper) {
            output[write_count] = std.ascii.toUpper(c);
        } else {
            output[write_count] = c;
        }
        write_count += 1;
        next_upper = false;
    }
    return output[0..write_count];
}

fn convertSnakeToPascal(input: []const u8, output: []u8) []const u8 {
    std.debug.assert(input.len <= output.len);
    var write_count: usize = 0;
    var next_upper = true;
    for (input) |c| {
        if (c == '_') {
            next_upper = true;
            continue;
        }
        if (next_upper) {
            output[write_count] = std.ascii.toUpper(c);
        } else {
            output[write_count] = c;
        }
        write_count += 1;
        next_upper = false;
    }
    return output[0..write_count];
}

const QueryResult = union(enum) {
    constants: Constant,
    typedefs: Typedef,
    enums: Enum,
    bitflags: Bitflag,
    structs: Struct,
    callbacks: Callback,
    functions: Function,
    objects: Object,
};

fn queryRef(spec: Yml, query: []u8) ?QueryResult {
    _ = query;
    return QueryResult{ .structs = spec.structs[0] };
}

fn renderParam(param: ParameterType, output: []u8) []u8 {
    _ = param;
    const tmp = "a: c_int";
    std.mem.copyForwards(u8, output, tmp);
    return output[0..tmp.len];
}
