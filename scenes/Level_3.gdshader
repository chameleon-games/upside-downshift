shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;

uniform float pixel_size : hint_range(0.0, 20.0, 1.0) = 4.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 tex_size = vec2(textureSize(screen_texture, 0));
	vec2 pixel_count = tex_size / (pixel_size * 2.0);
	vec2 pixelated_uv = floor(SCREEN_UV * pixel_count) / pixel_count;
	
	vec4 color = texture(screen_texture, pixel_size > 0.0 ? pixelated_uv : SCREEN_UV);
	
	ALBEDO = color.rgb;
}