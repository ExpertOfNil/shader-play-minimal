const std = @import("std");
//const rl = @import("raylib");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("rlgl.h");
});

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
    const img_sz_f = rl.Vector2{ .x = WIN_W * ZOOM * 2.0, .y = WIN_H * ZOOM * 2.0 };
    const img_sz = Vec2i{ .x = @intFromFloat(img_sz_f.x), .y = @intFromFloat(img_sz_f.y) };

    rl.InitWindow(img_sz.x, img_sz.y, "Shader Play : Zig");
    defer rl.CloseWindow();

    const fovy = 45.0;
    const calc_z = img_sz_f.y * 0.1 * 0.5 / @tan(DEG2RAD * fovy * 0.5);
    const camera = rl.Camera3D{
        .target = rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .up = rl.Vector3{ .x = 0.0, .y = 0.0, .z = 1.0 },
        .fovy = fovy,
        .projection = rl.CAMERA_PERSPECTIVE,
        .position = rl.Vector3{ .x = 0.0, .y = calc_z, .z = 0.0 },
    };

    const rl_img = rl.GenImageChecked(
        img_sz.x,
        img_sz.y,
        10,
        10,
        rl.BLUE,
        rl.DARKPURPLE,
    );
    defer rl.UnloadImage(rl_img);

    const texture = rl.LoadTextureFromImage(rl_img);
    defer rl.UnloadTexture(texture);

    const texture_sz_f = rl.Vector2{
        .x = @floatFromInt(texture.width),
        .y = @floatFromInt(texture.height),
    };

    print("Creating mesh...\n", .{});
    const mesh: rl.Mesh = rl.GenMeshPlane(
        texture_sz_f.x * 0.1,
        texture_sz_f.y * 0.1,
        2,
        2,
    );
    print("Mesh created...\n", .{});
    defer rl.UnloadMesh(mesh);

    const material: rl.Material = rl.LoadMaterialDefault();
    defer rl.UnloadMaterial(material);
    material.maps[rl.MATERIAL_MAP_ALBEDO].texture = texture;

    const target: rl.RenderTexture2D = rl.LoadRenderTexture(img_sz.x, img_sz.y);
    defer rl.UnloadRenderTexture(target);

    rl.SetTargetFPS(60);
    print("Starting render loop\n", .{});

    while (!rl.WindowShouldClose()) {
        rl.BeginTextureMode(target);
        {
            rl.ClearBackground(rl.RAYWHITE);
            rl.BeginMode3D(camera);
            {
                rl.DrawMesh(mesh, material, rl.MatrixIdentity());
            }
            rl.EndMode3D();
        }
        rl.EndTextureMode();

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE);
        const rect_sz = rl.Vector2{
            .x = @floatFromInt(target.texture.width),
            .y = @floatFromInt(target.texture.height),
        };
        rl.DrawTextureRec(
            target.texture,
            rl.Rectangle{ .x = 0.0, .y = 0.0, .width = rect_sz.x, .height = rect_sz.y },
            rl.Vector2{ .x = 0.0, .y = 0.0 },
            rl.WHITE,
        );

        const fps = rl.GetFPS();
        const fps_msg = rl.TextFormat("FPS: %d", fps);
        const adj_font_size = FONT_SIZE;
        rl.DrawText("Graphics: Raylib", 20, 20, adj_font_size, rl.LIGHTGRAY);
        rl.DrawText(fps_msg, 20, 20 + adj_font_size, adj_font_size, rl.LIGHTGRAY);
    }
    return;
}
