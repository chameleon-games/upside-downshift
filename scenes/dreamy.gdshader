shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.75, 0.88, 0.98, 1.0);
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float rim_power : hint_range(1.0, 6.0) = 2.5;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	ALBEDO = mix(base_color.rgb, rim_color.rgb, fresnel);
	EMISSION = rim_color.rgb * fresnel * 0.25;
}