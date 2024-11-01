const std = @import("std");
const rl = @import("raylib");

const print = std.debug.print;
const expect = std.testing.expect;
const mem = std.mem;
const pi = std.math.pi;
const tan = std.math.tan;
const DEG2RAD: comptime_float = pi / 180.0;

const BACKGROUND_COLOR: rl.Color = .{ 18, 18, 18, 255 };
const WIN_W: c_int = 3840;
const WIN_H: c_int = 2160;
const ZOOM: f32 = 0.2;
const FONT_SIZE: i32 = 12;

const Vec2i = struct {
    x: i32,
    y: i32,
};

pub fn main() !void {
    const img_sz_f = rl.Vector2.init(WIN_W * ZOOM * 2.0, WIN_H * ZOOM * 2.0);
    const img_sz: Vec2i = .{ .x = @intFromFloat(img_sz_f.x), .y = @intFromFloat(img_sz_f.y) };

    rl.initWindow(img_sz.x, img_sz.y, "Shader Play : Zig");
    defer rl.closeWindow();

    const fovy = 45.0;
    const calc_z = img_sz_f.y * 0.1 * 0.5 / @tan(DEG2RAD * fovy * 0.5);
    const camera: rl.Camera3D = .{
        .target = rl.Vector3.init(0.0, 0.0, 0.0),
        .up = rl.Vector3.init(0.0, 0.0, 1.0),
        .fovy = fovy,
        .projection = rl.CameraProjection.camera_perspective,
        .position = rl.Vector3.init(0.0, calc_z, 0.0),
    };

    const rl_img = rl.genImageChecked(
        img_sz.x,
        img_sz.y,
        10,
        10,
        rl.Color.blue,
        rl.Color.dark_purple,
    );
    defer rl.unloadImage(rl_img);

    const texture = rl.loadTextureFromImage(rl_img);
    defer rl.unloadTexture(texture);

    const texture_sz_f = rl.Vector2.init(
        @floatFromInt(texture.width),
        @floatFromInt(texture.height),
    );

    print("Creating mesh...\n", .{});
    const mesh: rl.Mesh = rl.genMeshPlane(
        texture_sz_f.x * 0.1,
        texture_sz_f.y * 0.1,
        2,
        2,
    );
    print("Mesh created...\n", .{});
    defer rl.unloadMesh(mesh);

    const material: rl.Material = rl.loadMaterialDefault();
    defer rl.unloadMaterial(material);
    material.maps[@intFromEnum(rl.MaterialMapIndex.material_map_albedo)].texture = texture;

    const target: rl.RenderTexture2D = rl.loadRenderTexture(img_sz.x, img_sz.y);
    defer rl.unloadRenderTexture(target);

    rl.setTargetFPS(60);
    print("Starting render loop\n", .{});

    while (!rl.windowShouldClose()) {
        rl.beginTextureMode(target);
        {
            rl.clearBackground(rl.Color.ray_white);
            rl.beginMode3D(camera);
            {
                rl.drawMesh(mesh, material, rl.Matrix.identity());
            }
            rl.endMode3D();
        }
        rl.endTextureMode();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.ray_white);
        const rect_sz = rl.Vector2.init(
            @floatFromInt(target.texture.width),
            @floatFromInt(target.texture.height),
        );
        rl.drawTextureRec(
            target.texture,
            rl.Rectangle.init(0.0, 0.0, rect_sz.x, rect_sz.y),
            rl.Vector2.init(0.0, 0.0),
            rl.Color.white,
        );

        const fps = rl.getFPS();
        const fps_msg = rl.textFormat("FPS: %d", .{fps});
        const adj_font_size = FONT_SIZE;
        rl.drawText("Graphics: Raylib", 20, 20, adj_font_size, rl.Color.light_gray);
        rl.drawText(fps_msg, 20, 20 + adj_font_size, adj_font_size, rl.Color.light_gray);
    }
    return;
}
