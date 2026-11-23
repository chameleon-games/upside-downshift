shader_type spatial;
render_mode unshaded;

// Deep dark cyberspace fill + glowing neon grid lines
uniform vec4 base_color : source_color = vec4(0.02, 0.03, 0.08, 1.0);
uniform vec4 grid_color : source_color = vec4(0.0, 0.95, 1.0, 1.0); // Classic TRON Cyan (or change to Orange/Magenta!)
uniform float grid_scale : hint_range(0.5, 10.0) = 1.0;
uniform float line_thickness : hint_range(0.01, 0.2) = 0.04;
uniform float glow_boost : hint_range(1.0, 5.0) = 2.2;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Calculate crisp 3D world-space grid lines on X, Y, and Z axes
	vec3 coord = world_pos * grid_scale;
	vec3 grid = abs(fract(coord - 0.5) - 0.5) / fwidth(coord);
	float line = min(min(grid.x, grid.y), grid.z);
	
	// Smooth anti-aliased neon line mask
	float line_mask = 1.0 - min(line / (line_thickness * 20.0), 1.0);
	
	vec3 final_col = mix(base_color.rgb, grid_color.rgb * glow_boost, line_mask);
	ALBEDO = final_col;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
