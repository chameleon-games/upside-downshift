shader_type spatial;

uniform vec4 block_color : source_color = vec4(0.95, 0.97, 1.0, 1.0); // Crisp off-white
uniform vec4 line_color : source_color = vec4(0.35, 0.48, 0.65, 1.0);  // Clean slate-blue grid lines
uniform float grid_scale : hint_range(0.2, 5.0) = 0.5;
uniform float line_thickness : hint_range(0.01, 0.15) = 0.03;

varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 coord = world_pos * grid_scale;
	vec3 grid = abs(fract(coord - 0.5) - 0.5) / fwidth(coord);
	float line = min(min(grid.x, grid.y), grid.z);
	float line_mask = 1.0 - min(line / (line_thickness * 20.0), 1.0);
	
	ALBEDO = mix(block_color.rgb, line_color.rgb, line_mask);
	ROUGHNESS = 0.85;
}