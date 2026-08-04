shader_type spatial;
render_mode cull_disabled, unshaded, fog_disabled;

uniform sampler2D matcap : source_color;
uniform sampler2D tex : source_color;
uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
//uniform sampler2D env_matcap : source_color;
uniform samplerCube env_cubemap : hint_default_black;
uniform float matcap_boost = 1.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform bool flip_horizontal = false;

uniform vec3 spec_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float spec_boost : hint_range(0.0, 10.0) = 0.0;
uniform vec3 spec_direction  = vec3(0.0, 0.0, 1.0);

uniform vec2 uv_offset = vec2(0.0, 0.0);
uniform vec2 uv_scale = vec2(1.0, 1.0);


varying vec2 matcap_uv;

void vertex() {
    vec4 view_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    vec3 view_dir = normalize(-view_pos.xyz);
    vec3 view_normal = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
    
    vec3 up_vector = vec3(0.0, 1.0, 0.0);
    vec3 right_vector = vec3(1.0, 0.0, 0.0);
    
    vec3 ref_vector = (abs(view_dir.y) > 0.9) ? right_vector : up_vector;
    
    vec3 tangent = normalize(cross(ref_vector, view_dir));
    vec3 bitangent = cross(view_dir, tangent);
    
    vec2 coords = vec2(
        dot(view_normal, tangent),
        dot(view_normal, bitangent)
    );

    coords.x = flip_horizontal ? -coords.x : coords.x;
    coords.y = -coords.y; // Flip Y coordinate
    
    matcap_uv = (coords * 0.496 + 0.5) * uv_scale + uv_offset;
}

void fragment() {
    vec4 matcap_color = texture(matcap, matcap_uv);
	//vec4 env_matcap_color = texture(env_matcap, UV);
	
	//vec3 eye_vec = normalize(MODEL_MATRIX[3].xyz - VERTEX); 
	//vec3 eye_vec = normalize(VIEW_MATRIX[3].xyz - VERTEX); 
	//vec3  env_reflect = reflect(eye_vec, NORMAL) * 0.5; 
	//vec4 env_reflect_final = texture(env_matcap,  env_reflect.rg); 
	
	vec3 N = normalize(NORMAL);
    vec3 V = normalize(-VIEW);
    vec3 L = normalize(spec_direction);
    vec3 H = normalize(L + V);
    float NdotH = max(dot(N, H), 0.0);
    float spec = pow(NdotH, 1.0 / max(0.2, 0.01)) * spec_boost;
 // Apply the reflected color to the object
	// EMISSION = reflected_color.rgb; // Alternative for a glowing metallic look
   
	vec3 reflected_vector = reflect(-V, N); // V is view vector, N is normal
	vec4 reflection_color = texture(env_cubemap, reflected_vector);
	//ALBEDO = mix(reflection_color.rgb,matcap_color.rgb  * matcap_boost + spec,0.5);
	ALBEDO = (matcap_color.rgb  * matcap_boost) + reflection_color.rgb + spec;
	ALBEDO *= color.rgb;
	ALBEDO *= texture(tex,UV).rgb;
	
	
	


    // Mix with base color
   // vec3 final_color = mix(ALBEDO, reflection_color.rgb, reflection_color.a); // Adjust mix factor as needed
//	ALBEDO = final_color;
	//EMISSION = env_reflect_final.rgb * 2.0;
}