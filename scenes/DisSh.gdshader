shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float wave_count : hint_range(1.0, 20.0, 1.0) = 10.0;
uniform float intensity : hint_range(0.0, 0.5) = 0;
uniform float max_speed : hint_range(1.0, 50.0, 1.0) = 20.0;  // Límite máximo para speed
uniform float rainbow_effect : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 cPos = -1.0 + 2.0 * UV / (1.0 / TEXTURE_PIXEL_SIZE);

    // Calcular un offset único basado en el tiempo para las distorsiones
    float time_offset = TIME * 0.1;
    vec2 distortion_offset = vec2(cos(time_offset), sin(time_offset));

    // Calcular speed y height basado en intensidad, ajustando la función para speed
    float speed = 80.0 * intensity * intensity + 5.0 * intensity + 2.0;
    speed = min(speed, max_speed);  // Limitar speed a max_speed
	
    float height = 0.05 * intensity;
    
    // Modificar height si la intensidad es 0.5
    if (intensity == 0.5) {
        height = 0.08 * intensity;
    }

    // Utilizar una combinación de funciones para generar un patrón no circular con distorsión basada en tiempo
    float wave1 = sin((cPos.x * wave_count - TIME * speed) * 0.5 + distortion_offset.x);
    float wave2 = cos((cPos.y * wave_count - TIME * speed) * 0.5 + distortion_offset.y);
    
    // Aplicar las distorsiones a UV tanto horizontal como verticalmente
    vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy + vec2(wave1, wave2) * height;

    // Obtener el color original de la textura
    vec3 col = texture(SCREEN_TEXTURE, uv).xyz;

    // Aplicar un efecto de arcoíris si rainbow_effect es mayor que 0
    float r = 0.5 + 0.5 * cos(TIME + uv.x * 10.0);
    float g = 0.5 + 0.5 * cos(TIME + uv.y * 10.0 + 2.0);
    float b = 0.5 + 0.5 * cos(TIME + uv.x * 10.0 + 4.0);
    vec3 rainbow_color = vec3(r, g, b);

    // Mezclar el color original con el efecto de arcoíris basado en rainbow_effect
    vec3 final_color = mix(col, rainbow_color, rainbow_effect);

    // Establecer el color final del fragmento
    COLOR = vec4(final_color, 1.0);
}
