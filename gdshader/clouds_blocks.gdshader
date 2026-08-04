shader_type spatial;
render_mode cull_disabled, unshaded, blend_mix, fog_disabled;
uniform sampler2D noise_tex : repeat_enable, filter_nearest;
uniform float scroll_speed : hint_range(-10.0, 10.0);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float alpha_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec3 cloud_color : source_color = vec3(1.0);
uniform float cloud_scale : hint_range(0.1, 10.0) = 2.0;

uniform float fade_radius = 0.7;
uniform vec4 fade_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float fade_power = 2.0;
void fragment() {
    vec2 uv = UV * cloud_scale;
    uv.x += TIME * scroll_speed;
    uv.x = fract(uv.x);
	vec4 texColor = texture(noise_tex, uv);
	float alpha = smoothstep(alpha_threshold, 1.0, texColor.r) * alpha_strength;
	ALBEDO = cloud_color;
	ALPHA = alpha;
    vec2 center = vec2(0.5, 0.5);
    float distance_from_center = distance(UV, center);
    float fade_amount = smoothstep(fade_radius, fade_radius - (1.0 / fade_power), distance_from_center);
    ALPHA *= mix(fade_color.a, 1.0, fade_amount);
}
