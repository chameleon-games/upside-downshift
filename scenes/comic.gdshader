shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

// Comic dot controls
uniform float dot_size : hint_range(2.0, 12.0) = 4.5;         // Size of the Spider-Verse comic dots
uniform float halftone_strength : hint_range(0.0, 1.0) = 0.55; // How strong the dot shading looks
uniform float color_bands : hint_range(3.0, 12.0) = 6.0;      // Posterizes gradients slightly like comic print

// Ink edge outline controls (fixes platforms fading into the fog!)
uniform float outline_strength : hint_range(0.0, 1.0) = 0.65;
uniform float edge_sensitivity : hint_range(1.0, 20.0) = 8.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 pixel_pos = uv / SCREEN_PIXEL_SIZE;
	
	vec3 col = texture(screen_texture, uv).rgb;
	
	// 1. Subtle comic book color banding
	vec3 comic_col = floor(col * color_bands + 0.5) / color_bands;
	
	// 2. Spider-Verse Ben-Day Halftone Dots in shadows/midtones
	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	// Rotate grid 45 degrees like real comic book print!
	float angle = 0.785398; // 45 degrees
	mat2 rot = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
	vec2 grid_uv = (rot * pixel_pos) / dot_size;
	
	vec2 cell = fract(grid_uv) - 0.5;
	float dist = length(cell);
	// Darker areas get larger comic dots
	float dot_radius = (1.0 - luma) * 0.65;
	float dot_mask = smoothstep(dot_radius, dot_radius - 0.12, dist);
	
	vec3 halftoned = mix(comic_col, comic_col * 0.68, dot_mask * halftone_strength);
	
	// 3. Crisp Ink Edge Detection (outlines platforms against the fog!)
	vec2 px = SCREEN_PIXEL_SIZE;
	vec3 c_up    = texture(screen_texture, uv + vec2(0.0, -px.y)).rgb;
	vec3 c_down  = texture(screen_texture, uv + vec2(0.0,  px.y)).rgb;
	vec3 c_left  = texture(screen_texture, uv + vec2(-px.x, 0.0)).rgb;
	vec3 c_right = texture(screen_texture, uv + vec2( px.x, 0.0)).rgb;
	
	float edge = length(c_up - c_down) + length(c_left - c_right);
	float ink_line = clamp(edge * edge_sensitivity, 0.0, 1.0) * outline_strength;
	
	// Dark ink outline (deep navy-charcoal so it looks cleaner than harsh pure black)
	vec3 ink_color = vec3(0.08, 0.12, 0.22);
	vec3 final_col = mix(halftoned, ink_color, ink_line);
	
	COLOR = vec4(final_col, 1.0);
}