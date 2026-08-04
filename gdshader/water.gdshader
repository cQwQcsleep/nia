shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled;

uniform vec3 albedo : source_color;
uniform float water_emission_strength = 0.0;
uniform sampler2D water_emission;
uniform sampler2D water_texture1 : filter_linear_mipmap_anisotropic;
uniform sampler2D water_texture2 : filter_linear_mipmap_anisotropic;
uniform sampler2D noise_texture;
uniform vec2 scroll_speed1 = vec2(0.05, 0.0);
uniform vec2 scroll_speed2 = vec2(-0.03, 0.0);
uniform float blend_factor = 0.5;
uniform float wave_strength = 1.0;
uniform float wave_scale = 0.02;
uniform sampler2D DepthTexture : hint_depth_texture;
uniform float WaterOpacity = 1.0;
uniform bool use_edge_fade = false;
uniform float edge_fade_amount = 0.01;

uniform float triplanar_scale = 1.0;
uniform float triplanar_emission_scale = 1.0;
varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
    //vec2 global_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
    //float noise_value = texture(noise_texture, global_position * wave_scale).r;
    //float wave = sin(global_position.x * 0.2 + global_position.y * 0.2 + TIME + noise_value * 10.0) * wave_strength;
    //VERTEX.y += wave;
	vec3 normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
    world_normal = abs(normal);
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    vec2 global_position = world_pos.xz;
    float noise_value = texture(noise_texture, global_position * wave_scale).r;
    float wave = sin(global_position.x * 0.2 + global_position.y * 0.2 + TIME + noise_value * 10.0) * wave_strength;
    VERTEX.y += wave;

}

vec4 triplanar_sample(sampler2D tex, vec3 pos, vec3 normal, vec2 scroll, float scale) {
    vec2 uv_x = pos.zy * scale + scroll;
    vec2 uv_y = pos.xz * scale + scroll;
    vec2 uv_z = pos.xy * scale + scroll;

    vec4 x_proj = texture(tex, uv_x);
    vec4 y_proj = texture(tex, uv_y);
    vec4 z_proj = texture(tex, uv_z);

    vec3 weights = pow(normalize(normal), vec3(2.0));
    weights /= (weights.x + weights.y + weights.z);

    return x_proj * weights.x + y_proj * weights.y + z_proj * weights.z;
}

void fragment() {
    vec2 scroll1 = scroll_speed1 * TIME;
	vec2 scroll2 = scroll_speed2 * TIME;

	vec4 water_color1 = triplanar_sample(water_texture1, world_pos, world_normal, scroll1, triplanar_scale);
	vec4 water_color2 = triplanar_sample(water_texture2, world_pos, world_normal, scroll2, triplanar_scale);
	vec4 blended_water_color = mix(water_color1, water_color2, blend_factor);


    float depthValue = texture(DepthTexture, SCREEN_UV).r;
    vec4 worldPosition = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depthValue, 1.0);
    worldPosition.xyz /= worldPosition.w;
   // float foamEffect = clamp(1.0 - smoothstep(worldPosition.z + FoamSize, worldPosition.z, VERTEX.z), 0.0, 1.0);
  //  float foamOpacity = 1.0 - foamEffect;
  //  float foamEffectRounded = round(foamOpacity);
//float edge_fade = smoothstep(0.0, edge_fade_amount, UV.x) * smoothstep(0.0, edge_fade_amount, UV.y);
//edge_fade *= smoothstep(0.0, edge_fade_amount, 1.0 - UV.x) * smoothstep(0.0, edge_fade_amount, 1.0 - UV.y);

// Combine with WaterOpacity
//float finalOpacity = WaterOpacity * edge_fade;

	//if use_edge_fade {
	//float finalOpacity = WaterOpacity * COLOR.r * edge_fade_amount;
	//}

float fadeFactor = use_edge_fade ? ((COLOR.r * edge_fade_amount)) : 1.0;
float finalOpacity = WaterOpacity * fadeFactor;

	//float finalOpacity =COLOR.r * edge_fade_amount;
	//float finalOpacity =mix(WaterOpacity,0.0, 1.0 - (COLOR.r * edge_fade_amount));

  //  float finalOpacity =  WaterOpacity;

   ALBEDO = blended_water_color.rgb * albedo;
	//ALBEDO = COLOR.rgb;
	//ALBEDO = albedo;

    ALPHA = finalOpacity;
	//ALPHA *= WaterOpacity;
  //  EMISSION = vec3(foamEffectRounded) * FoamGlowIntensity;
	//EMISSION = texture(water_emission, blended_water_color.xy).rgb * water_emission_strength;
   //EMISSION = texture(water_emission,UV * triplanar_emission_scale).rgb * water_emission_strength;

EMISSION = blended_water_color.rgb * albedo * water_emission_strength;
//EMISSION = texture(water_emission, triplanar_sample(water_emission, world_pos, world_normal, vec2(11.0,10.0), triplanar_emission_scale).xy).rgb * water_emission_strength;
 //	METALLIC = 0.0;

   // ROUGHNESS = 1.0;
}