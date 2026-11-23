shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled;

uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.5, 5.0) = 1.5;
uniform float depth_threshold : hint_range(0.0001, 0.05) = 0.002;

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float get_linear_depth(vec2 uv, mat4 inv_proj) {
    float depth = texture(depth_texture, uv).r;
    vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
    vec4 view = inv_proj * vec4(ndc, 1.0);
    view.xyz /= view.w;
    return -view.z;
}

void fragment() {
    vec2 texel = (1.0 / VIEWPORT_SIZE) * outline_thickness;
    
    float d_center = get_linear_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
    float d_up     = get_linear_depth(SCREEN_UV + vec2(0.0, -texel.y), INV_PROJECTION_MATRIX);
    float d_down   = get_linear_depth(SCREEN_UV + vec2(0.0,  texel.y), INV_PROJECTION_MATRIX);
    float d_left   = get_linear_depth(SCREEN_UV + vec2(-texel.x, 0.0), INV_PROJECTION_MATRIX);
    float d_right  = get_linear_depth(SCREEN_UV + vec2( texel.x, 0.0), INV_PROJECTION_MATRIX);

    float diff = abs(d_center - d_up) + abs(d_center - d_down) + abs(d_center - d_left) + abs(d_center - d_right);

    if (diff > depth_threshold * d_center) {
        ALBEDO = outline_color.rgb;
        ALPHA = outline_color.a;
    } else {
        discard;
    }
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
