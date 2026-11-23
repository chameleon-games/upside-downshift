shader_type spatial;
render_mode fog_disabled; // Stops WorldEnvironment fog from washing out distant platforms!

uniform vec4 floor_ceiling_color : source_color = vec4(0.98, 0.99, 1.0, 1.0); // Crisp white floors/ceilings
uniform vec4 wall_color : source_color = vec4(0.32, 0.52, 0.78, 1.0);          // Deeper slate-blue walls so they pop against the pale sky!

varying vec3 world_normal;

void vertex() {
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float is_horizontal = step(0.5, abs(world_normal.y));
	ALBEDO = mix(wall_color.rgb, floor_ceiling_color.rgb, is_horizontal);
	ROUGHNESS = 0.85;
}
