shader_type canvas_item;

uniform int pixel_size : hint_range(1, 64) = 2;

void fragment() {
    // Получаем размеры экрана.
    vec2 screen_size = vec2(textureSize(TEXTURE, 0));
    // Рассчитываем пиксельные координаты.
    vec2 pixel_uv = floor(UV * screen_size / float(pixel_size)) * float(pixel_size) / screen_size;
    // Берем цвет из текстуры экрана с учетом пикселизации.
    COLOR = textureLod(TEXTURE, pixel_uv, 0.0);
}