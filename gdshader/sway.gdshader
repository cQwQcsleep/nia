shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha;

// what a gentle wind
uniform float wind_strength : hint_range(0.0, 2.0) = 0.2;
uniform float wind_speed : hint_range(0.0, 10.0) = 1.0;
uniform vec3 wind_direction = vec3(1.0, 0.0, 0.0);
uniform float emissive = 0.0;
uniform sampler2D tex: filter_linear_mipmap_anisotropic;
//uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
	float sway = sin(VERTEX.x * 0.5 + TIME * wind_speed)
	           + cos(VERTEX.z * 0.5 + TIME * wind_speed * 1.3);
	sway *= 0.5;
	VERTEX += wind_direction * sway * wind_strength;
}

void fragment() {
	vec4 color = texture(tex, UV);
	ALBEDO = color.rgb * COLOR.rgb;
	EMISSION = ALBEDO * emissive;
	ALPHA = color.a;
}