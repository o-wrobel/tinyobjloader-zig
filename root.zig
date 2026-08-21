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

pub fn errorFromCode(error_code: c_uint) Error {
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

pub fn loadFromMemory(data: []const u8, config: ?c.tobj_load_config) Error!Scene {
    var scene: c.tobj_scene = undefined;
    const data_c: [*c]const u8 = @ptrCast(data);
    const result = c.tobj_load_obj_from_memory_f(
        &scene, data_c, data.len,
        &(config orelse c.tobj_default_config()), null
    );
    if (result != c.TOBJ_OK) return errorFromCode(result);
    return Scene{
        .attributes = scene.attrib,
        .shapes = if (scene.shapes) |shapes| shapes[0..scene.num_shapes] else null,
        .materials = if (scene.materials) |mats| mats[0..scene.num_materials] else null
    };
}

test "declarations" {
    std.testing.refAllDecls(@This());
}

test loadFromMemory {
    const data = @embedFile("pyramid.obj");
    _ = try loadFromMemory(data, null);
}
