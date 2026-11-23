shader_type spatial;

uniform vec4 bottom_color : source_color = vec4(0.32, 0.55, 0.82, 1.0); // Deep sky blue base
uniform vec4 top_color : source_color = vec4(0.98, 0.99, 1.0, 1.0);     // Crisp white top
uniform float height_scale : hint_range(1.0, 40.0) = 12.0;

varying float world_y;

void vertex() {
	world_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

void fragment() {
	float t = clamp((world_y + 5.0) / height_scale, 0.0, 1.0);
	ALBEDO = mix(bottom_color.rgb, top_color.rgb, t);
	ROUGHNESS = 0.8;
}