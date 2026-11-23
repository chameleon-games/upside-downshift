shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform float eyestrain : hint_range(0.0, 1.0) = 0.7;
uniform float posterize_steps : hint_range(2.0, 16.0) = 4.0;
uniform float hue_shift : hint_range(0.0, 1.0) = 0.25;
uniform float slight_pixel : hint_range(1.0, 4.0) = 2.0;

vec3 hue_rotate(vec3 col, float shift) {
	const vec3 k = vec3(0.57735);
	float cosAngle = cos(shift * 6.28318);
	return vec3(col * cosAngle + cross(k, col) * sin(shift * 6.28318) + k * dot(k, col) * (1.0 - cosAngle));
}

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Slight pixel crunch
	if (slight_pixel > 1.0) {
		vec2 screen_res = 1.0 / SCREEN_PIXEL_SIZE;
		vec2 grid = screen_res / slight_pixel;
		uv = floor(uv * grid) / grid;
	}
	
	vec3 col = texture(screen_texture, uv).rgb;
	
	// Eyestrain effect (neon hue shift + solarize + posterize + max saturation)
	vec3 wild = hue_rotate(col, hue_shift);
	wild = abs(wild - vec3(0.45)) * 2.2;
	wild = floor(wild * posterize_steps) / (posterize_steps - 1.0);
	
	float luma = dot(wild, vec3(0.299, 0.587, 0.114));
	wild = mix(vec3(luma), wild, 2.2);
	
	col = mix(col, clamp(wild, 0.0, 1.0), eyestrain);
	
	COLOR = vec4(col, 1.0);
}