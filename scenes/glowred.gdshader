shader_type canvas_item;

uniform vec4 outline_color  = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 10.0) = 3.0;
uniform vec4 glow_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec2 size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel = 1.0 / size;

    // Original color of the texture
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Outline detection
    float alpha = tex_color.a;
    float max_alpha = 0.0;
    
    // Check the neighboring pixels for the outline
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel * outline_thickness;
            max_alpha = max(max_alpha, texture(TEXTURE, UV + offset).a);
        }
    }
    
    // Determine if this pixel is part of the outline
    if (max_alpha > 0.0 && alpha == 0.0) {
        COLOR = outline_color;
    } else {
        COLOR = tex_color;
    }

    // Apply glow effect
    if (alpha > 0.0) {
        vec4 glow = vec4(0.0);
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <= 1; y++) {
                vec2 offset = vec2(float(x), float(y)) * pixel;
                glow += texture(TEXTURE, UV + offset);
            }
        }
        glow /= 9.0; // Average the glow
        glow = mix(tex_color, glow_color, glow_intensity) * glow.a;
        COLOR += glow;
    }
}
