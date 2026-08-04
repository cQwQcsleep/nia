shader_type spatial;

uniform sampler2D texture_a : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D texture_b : source_color, filter_linear_mipmap_anisotropic;

uniform vec2 uv_a_scale = vec2(1.0, 1.0);
uniform vec2 uv_b_scale = vec2(1.0, 1.0);

void fragment() {
    vec2 uv_a = UV * uv_a_scale;
    vec2 uv_b = UV * uv_b_scale;
    vec4 a_tex = texture(texture_a, uv_a);
    vec4 b_tex = texture(texture_b, uv_b);
    float blend_factor = clamp(COLOR.r, 0.0, 1.0);
    vec4 final_tex = mix(a_tex, b_tex, blend_factor);
    ALBEDO = final_tex.rgb;
}