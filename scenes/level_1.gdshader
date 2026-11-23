shader_type spatial;

uniform vec4 lit_color : source_color = vec4(0.96, 0.98, 1.0, 1.0);    // Crisp white lit side
uniform vec4 shadow_color : source_color = vec4(0.55, 0.68, 0.85, 1.0); // Crisp cel-shaded blue shadow side

void fragment() {
	ALBEDO = lit_color.rgb;
}

void light() {
	// Hard step cutoff instead of smooth gradient = true cel-shading!
	float ndotl = dot(NORMAL, LIGHT);
	float cel = smoothstep(-0.05, 0.05, ndotl) * ATTENUATION;
	DIFFUSE_LIGHT += mix(shadow_color.rgb, lit_color.rgb, cel) * LIGHT_COLOR;
}
