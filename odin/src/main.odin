package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:os"
import "core:strings"
import rl "vendor:raylib"

Vec2i :: struct {
    x: i32,
    y: i32,
}

BACKGROUND_COLOR: rl.Color : {18, 18, 18, 255}
WIN_W :: 3840
WIN_H :: 2160
ZOOM :: #config(ZOOM, 0.2)
FONT_SIZE: i32 : 12

main :: proc() {
    img_sz_f: rl.Vector2 = {
        WIN_W * ZOOM * 2.0,
        WIN_H * ZOOM * 2.0,
    }
    img_sz: Vec2i = {i32(img_sz_f.x), i32(img_sz_f.y)}

    rl.InitWindow(img_sz.x, img_sz.y, "Shader Play : Odin")
    defer rl.CloseWindow()

    fovy: f32 : 45.0
    calc_z: f32 = (f32(img_sz.y) * 0.1 * 0.5) / math.tan(rl.DEG2RAD * fovy * 0.5)
    camera: rl.Camera3D
    camera.target = {0.0, 0.0, 0.0}
    camera.up = {0.0, 0.0, 1.0}
    camera.fovy = 45.0
    camera.projection = rl.CameraProjection.PERSPECTIVE
    camera.position = {0.0, calc_z, 0.0}

    rl_img := rl.GenImageChecked(img_sz.x, img_sz.y, 10, 10, rl.BLUE, rl.DARKPURPLE)
    defer rl.UnloadImage(rl_img)

    texture := rl.LoadTextureFromImage(rl_img)
    defer rl.UnloadTexture(texture)

    fmt.printfln("Creating mesh...");
    mesh: rl.Mesh = rl.GenMeshPlane(f32(texture.width) * 0.1, f32(texture.height) * 0.1, 2, 2)
    fmt.printfln("Mesh created...");
    defer rl.UnloadMesh(mesh)

    material: rl.Material = rl.LoadMaterialDefault()
    defer rl.UnloadMaterial(material);
    material.maps[rl.MaterialMapIndex.ALBEDO].texture = texture

    target: rl.RenderTexture2D = rl.LoadRenderTexture(img_sz.x, img_sz.y)
    defer rl.UnloadRenderTexture(target)

    rl.SetTargetFPS(60)
    fmt.printfln("Starting render loop")

    for (!rl.WindowShouldClose()) {
        rl.BeginTextureMode(target)
        {
            rl.ClearBackground(rl.RAYWHITE)
            rl.BeginMode3D(camera)
            defer rl.EndMode3D()
            rl.DrawMesh(mesh, material, rl.Matrix(1))
        }
        rl.EndTextureMode()

        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawTextureRec(
            target.texture,
            {0, 0, f32(target.texture.width), f32(target.texture.height)},
            {0.0, 0.0},
            rl.WHITE,
        )

        fps := rl.GetFPS()
        fps_msg := rl.TextFormat("FPS: %d", fps)
        adj_font_size := FONT_SIZE
        rl.DrawText("Graphics: Raylib", 20, 20, adj_font_size, rl.LIGHTGRAY)
        rl.DrawText(fps_msg, 20, 20 + adj_font_size, adj_font_size, rl.LIGHTGRAY)
    }

    return
}
