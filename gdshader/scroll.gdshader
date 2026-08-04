shader_type spatial;
render_mode cull_disabled;
uniform sampler2D scroll_texture : filter_linear_mipmap_anisotropic;
uniform float scroll_speed : hint_range(0.0, 10.0);
uniform float scroll_speed_y : hint_range(0.0, 10.0);
uniform sampler2D emission_texture : filter_linear_mipmap_anisotropic;
uniform float emission_strength : hint_range(0.0, 5.0) = 1.0;
void fragment() {
    vec2 uv = UV;
    uv.x += TIME * scroll_speed;
	uv.y += TIME * scroll_speed_y;
    uv.x = fract(uv.x);
	uv.x = fract(uv.x);
    ALBEDO = texture(scroll_texture, uv).rgb;
	vec4 tex_color = texture(emission_texture, uv);
	EMISSION = tex_color.rgb * emission_strength;
}
