shader_type spatial;
render_mode blend_add, depth_prepass_alpha, cull_back, unshaded;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

varying vec3 uv1_triplanar_pos;

uniform float uv1_blend_sharpness : hint_range(0.0, 150.0, 0.001) = 1.0;
varying vec3 uv1_power_normal;

uniform vec3 uv1_scale = vec3(1.0,1.0,1.0);
uniform vec3 uv1_offset;

uniform sampler2D caustics_bw : hint_default_white,filter_linear_mipmap, repeat_enable;
uniform float slowdown : hint_range(0.1, 10.0, 0.1) = 5.0;
uniform float time_caust : hint_range(0.01, 1.0, 0.01) = 0.13;
uniform float tile_caust = 0.2;
uniform vec4 caustics_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // RGB = tint, A = intensity
uniform float caustics_strength : hint_range(0.0, 5.0) = 1.0;

void vertex() {
	vec3 normal = MODEL_NORMAL_MATRIX * NORMAL;

	TANGENT = vec3(0.0, 0.0, -1.0) * abs(normal.x);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.y);
	TANGENT += vec3(1.0, 0.0, 0.0) * abs(normal.z);
	TANGENT = inverse(MODEL_NORMAL_MATRIX) * normalize(TANGENT);

	BINORMAL = vec3(0.0, 1.0, 0.0) * abs(normal.x);
	BINORMAL += vec3(0.0, 0.0, -1.0) * abs(normal.y);
	BINORMAL += vec3(0.0, 1.0, 0.0) * abs(normal.z);
	BINORMAL = inverse(MODEL_NORMAL_MATRIX) * normalize(BINORMAL);

	// UV1 Triplanar: Enabled (with World Triplanar)
	uv1_power_normal = pow(abs(normal), vec3(uv1_blend_sharpness));
	uv1_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz * uv1_scale + uv1_offset;
	uv1_power_normal /= dot(uv1_power_normal, vec3(1.0));
	uv1_triplanar_pos *= vec3(1.0, -1.0, 1.0);
}

vec4 triplanar_texture(sampler2D p_sampler, vec3 p_weights, vec3 p_triplanar_pos) {
	vec4 samp = vec4(0.0);
	samp += texture(p_sampler, p_triplanar_pos.xy) * p_weights.z;
	samp += texture(p_sampler, p_triplanar_pos.xz) * p_weights.y;
	samp += texture(p_sampler, p_triplanar_pos.zy * vec2(-1.0, 1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	vec2 offset1 = vec2(sin(TIME / slowdown), cos(TIME / slowdown)) * time_caust;
    vec2 offset2 = vec2(cos(TIME / slowdown), sin(TIME / slowdown)) * time_caust;

    vec3 caustics_pos1 = (uv1_triplanar_pos * tile_caust) + vec3(offset1, 0.0);
    vec3 caustics_pos2 = (uv1_triplanar_pos * tile_caust) + vec3(offset2, 0.0);

    float caustics1 = triplanar_texture(caustics_bw, uv1_power_normal, caustics_pos1).r;
    float caustics2 = triplanar_texture(caustics_bw, uv1_power_normal, caustics_pos2).r;

    float caustics_mix = caustics1 * caustics2;


	vec3 caustics_rgb = caustics_color.rgb * caustics_mix * caustics_strength;
	float caustics_alpha = caustics_mix * caustics_color.a;

	ALBEDO = caustics_rgb;
	ALPHA = caustics_alpha;
	//EMISSION = caustics_rgb * 3333.0;
   // ALBEDO = vec3(caustics_mix);
   // ALPHA = caustics_mix; // Controls transparency


	//vec4 albedo_tex = triplanar_texture(texture_albedo, uv1_power_normal, uv1_triplanar_pos);
	//vec4 albedo_tex = texture(texture_albedo, UV);

	//ALBEDO = albedo.rgb * albedo_tex.rgb * caustics_mix;
	//ALPHA = albedo.a;

}
