shader_type canvas_item;

// Declarar el uniform para la textura de la pantalla
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur : hint_range(0, 6) = 0;

void fragment() {
    vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV, blur);
    COLOR = screen_tex;
}
