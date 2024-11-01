#include <pthread.h>
#include <raylib.h>
#include <raymath.h>
#include <rlgl.h>
#include <stdbool.h>
#include <stdio.h>

typedef struct {
    int x;
    int y;
} Vec2i;

static const Color BACKGROUND_COLOR = {18, 18, 18, 255};
static const int WIN_W = 3840;
static const int WIN_H = 2160;
static float ZOOM = 0.2;
static int FONT_SIZE = 12;

int main(int argc, char** argv) {
    Vector2 img_sz_f =
        (Vector2){.x = WIN_W * ZOOM * 2.0, .y = WIN_H * ZOOM * 2.0};
    Vec2i img_sz = (Vec2i){.x = (float)img_sz_f.x, .y = (float)img_sz_f.y};

    InitWindow(img_sz.x, img_sz.y, "Shader Play");

    float fovy = 45.0;
    float calc_z = (img_sz.y * 0.1 * 0.5) / tan(DEG2RAD * fovy * 0.5);
    Camera3D camera = {0};
    camera.target = (Vector3){0.0f, 0.0f, 0.0f};
    camera.up = (Vector3){0.0f, 0.0f, 1.0f};
    camera.fovy = 45.0f;
    camera.projection = CAMERA_PERSPECTIVE;
    camera.position = (Vector3){0.0f, calc_z, 0.0f};

    Image rl_img =
        GenImageChecked(img_sz.x, img_sz.y, 10, 10, BLUE, DARKPURPLE);

    Texture2D texture = LoadTextureFromImage(rl_img);

    printf("Creating mesh...\n");
    Mesh mesh = GenMeshPlane(
        (float)(texture.width) * 0.1, (float)(texture.height) * 0.1, 2, 2);
    printf("Mesh created...\n");

    Material material = LoadMaterialDefault();
    material.maps[MATERIAL_MAP_ALBEDO].texture = texture;

    RenderTexture2D target = LoadRenderTexture(img_sz.x, img_sz.y);

    bool got_first = false;
    int shader_stage = 0;

    SetTargetFPS(60);
    printf("Starting render loop\n");

    while (!WindowShouldClose()) {
        BeginTextureMode(target);
        {
            ClearBackground(RAYWHITE);
            BeginMode3D(camera);
            {
                DrawMesh(mesh, material, MatrixIdentity());
            }
            EndMode3D();
        }
        EndTextureMode();

        BeginDrawing();
        {
            ClearBackground(RAYWHITE);
            DrawTextureRec(
                target.texture,
                (Rectangle){0,
                            0,
                            (float)target.texture.width,
                            (float)target.texture.height},
                (Vector2){0, 0},
                WHITE);

            int fps = GetFPS();
            const char* fps_msg = TextFormat("FPS: %d", fps);
            int adj_font_size = FONT_SIZE;
            DrawText("Graphics: Raylib", 20, 20, adj_font_size, LIGHTGRAY);
            DrawText(fps_msg, 20, 20 + adj_font_size, adj_font_size, LIGHTGRAY);
        }
        EndDrawing();
    }
    UnloadRenderTexture(target);
    UnloadMaterial(material);
    UnloadTexture(texture);
    UnloadImage(rl_img);
    CloseWindow();
    return 0;
}
