shader_type spatial;
render_mode cull_front, unshaded, fog_disabled;

uniform vec4 outline_color : source_color = vec4(0.06, 0.1, 0.18, 1.0); // Deep ink navy-black
uniform float outline_thickness : hint_range(0.01, 0.25) = 0.06;

void vertex() {
	// Pushes backfaces outward along vertex normals to form a crisp outline around every block
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}