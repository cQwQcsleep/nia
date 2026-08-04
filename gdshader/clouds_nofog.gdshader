shader_type spatial;
render_mode cull_disabled, unshaded, blend_mix,  fog_disabled;
uniform sampler2D noise_tex : repeat_enable;
uniform float scroll_speed : hint_range(0.0, 10.0);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float alpha_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec3 cloud_color : source_color = vec3(1.0);
uniform float cloud_scale : hint_range(0.2, 10.0) = 2.0;

void fragment() {
    vec2 uv = UV * cloud_scale;
    uv.x += TIME * scroll_speed;
    uv.x = fract(uv.x);
	vec4 texColor = texture(noise_tex, uv);
	float alpha = smoothstep(alpha_threshold, 1.0, texColor.r) * alpha_strength;
	ALBEDO = cloud_color;
	ALPHA = alpha;
}
