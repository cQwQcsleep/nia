shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic;
uniform float emission = 0.0;
uniform vec4 color : source_color; // tint
uniform float scroll_speed_primary = 1.5;
uniform float scroll_speed_secondary = 0.5;
uniform bool use_alpha = true;

void fragment() {
    vec2 uv1 = UV;
    vec2 uv2 = UV;

    uv1.y += TIME * scroll_speed_primary;
    uv2.y += TIME * scroll_speed_secondary;

    vec4 tex1 = texture(tex, uv1);
    vec4 tex2 = texture(tex, uv2);

    // Combine layers softly
    float combined_intensity = tex1.r + tex2.r * 0.5;
    combined_intensity = clamp(combined_intensity, 0.0, 1.0);

    vec3 tinted = combined_intensity * color.rgb;

    ALBEDO = tinted;

    ALPHA = combined_intensity * color.a * tex1.a * COLOR.r;
	EMISSION = tinted.rgb * emission;
}