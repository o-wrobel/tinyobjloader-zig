const std = @import("std");

pub const c = @import("c");
pub const Shape = c.tobj_shape;
pub const Material = c.tobj_material;
pub const Index = c.tobj_index;
pub const Attributes = c.tobj_attrib;

pub const Scene = struct {
    attributes: Attributes,
    shapes: ?[]Shape,
    materials: ?[]Material
};

pub const Config = struct {
    allocator: ?std.mem.Allocator = null,
    triangulate: bool = false,
    store_vertex_colors: bool = false,
    vertex_color_fallback: bool = false,
    parse_freeform: bool = false,
    use_arena: bool = false,
    num_threads: c_int = 0,
    max_vertices: usize = 0,
    max_indices: usize = 0,
    max_faces: usize = 0,
    max_face_arity: usize = 0,
    max_materials: usize = 0,
    max_shapes: usize = 0,
    max_line_bytes: usize = 0,
    max_input_bytes: usize = 0,
    mtl_resolver: c.tobj_material_resolver = null,
    mtl_resolver_user_data: ?*anyopaque = null,

    pub fn toC(self: Config) c.tobj_load_config {
        const this_fields = @typeInfo(Config).@"struct".fields;
        const c_fields = @typeInfo(c.tobj_load_config).@"struct".fields;
        var config: c.tobj_load_config = undefined;
        inline for (0..c_fields.len) |i| {
            const tf = this_fields[i];
            const cf = c_fields[i];
            comptime if (std.mem.eql(u8, tf.name, "allocator")) continue;
            @field(config, cf.name) = @field(self, tf.name);
        }
        return .{};
    }
};

pub const Error = error{
    InvalidArg,
    Alloc,
    Overflow,
    Parse,
    Io,
    NotFound,
    LimitExceeded,
    Unsupported,
};

pub fn errorFromCode(error_code: c.tobj_result) Error {
    return switch (error_code) {
        c.TOBJ_ERR_INVALID_ARG => Error.InvalidArg,
        c.TOBJ_ERR_ALLOC => Error.Alloc,
        c.TOBJ_ERR_OVERFLOW => Error.Overflow,
        c.TOBJ_ERR_PARSE => Error.Parse,
        c.TOBJ_ERR_IO => Error.Io,
        c.TOBJ_ERR_NOT_FOUND => Error.NotFound,
        c.TOBJ_ERR_LIMIT_EXCEEDED => Error.LimitExceeded,
        c.TOBJ_ERR_UNSUPPORTED => Error.Unsupported,

        else => unreachable

    };
}

pub fn loadFromMemory(data: []const u8, config: Config) Error!Scene {
    var scene: c.tobj_scene = undefined;
    const data_c: [*c]const u8 = @ptrCast(data);
    const config_c = config.toC();
    const result = c.tobj_load_obj_from_memory_f(
        &scene, data_c, data.len,
        &config_c, null
    );
    if (result != c.TOBJ_OK) return errorFromCode(result);
    return Scene{
        .attributes = scene.attrib,
        .shapes = if (scene.shapes) |shapes| shapes[0..scene.num_shapes] else null,
        .materials = if (scene.materials) |mats| mats[0..scene.num_materials] else null
    };
}

test "declarations" { std.testing.refAllDecls(@This()); }

test loadFromMemory {
    const data = @embedFile("pyramid.obj");
    const scene = try loadFromMemory(data, .{});
    _ = scene;
}

test Config {
    const config: Config = .{};
    _ = config.toC();
}
