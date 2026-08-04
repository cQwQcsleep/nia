shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled;

uniform sampler2D texture_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D texture_mask : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float alpha = 0.7;
uniform float uv1_blend_sharpness : hint_range(-10.0, 150.0, 0.001) = 1.0;


uniform float texture_scale = 1.0;
uniform float mask_scale = 1.0;
uniform float noise_threshold : hint_range(0.0, 1.0) = 0.5;

varying vec3 uv1_triplanar_pos;
varying vec3 uv1_power_normal;

void vertex() {
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

	uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));

	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0); // Optional axis flip for consistency
}

vec4 triplanar_texture(sampler2D tex, vec3 weights, vec3 pos, float scale) {
	vec4 samp = vec4(0.0);
	samp += texture(tex, pos.xy * scale) * weights.z;
	samp += texture(tex, pos.xz * scale) * weights.y;
	samp += texture(tex, pos.zy * vec2(-1.0, 1.0) * scale) * weights.x;
	return samp;
}

void fragment() {
	vec4 albedo_color = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos, texture_scale);
	vec4 noise_mask = triplanar_texture(texture_mask, uv1_power_normal, uv1_triplanar_pos, mask_scale);

	float final_alpha = smoothstep(noise_threshold - 0.1, noise_threshold + 0.1, noise_mask.r) * alpha;
	ALBEDO = albedo_color.rgb;
	ALPHA = final_alpha;
	//ALPHA = texture(texture_albedo,UV).a;
	ALPHA *= albedo_color.a;
}