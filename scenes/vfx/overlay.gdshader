shader_type canvas_item;

// Получаем доступ к уже отрендеренному фону (сцене без текущего объекта)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
    // Цвет объекта с учётом текстуры и modulate
    vec4 object_color = texture(TEXTURE, UV) * COLOR;
    // Цвет фона в этой точке экрана
    vec4 bg_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Формула экранного смешивания: 1 - (1 - A) * (1 - B)
    vec3 screen_rgb = 1.0 - (1.0 - object_color.rgb) * (1.0 - bg_color.rgb);
    
    // Плавный переход между фоном и экранным смешением в зависимости от альфы объекта
    // (при object_color.a == 0 виден только фон, при 1 – чистое экранное наложение)
    vec3 final_rgb = mix(bg_color.rgb, screen_rgb, object_color.a);
    
    // Выводим непрозрачный цвет – движок полностью заменит пиксель, повторного смешивания не будет
    COLOR = vec4(final_rgb, 1.0);
}