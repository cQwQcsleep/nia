shader_type spatial;

render_mode diffuse_lambert_wrap;

uniform vec3 albedo_color : source_color = vec3(0.8, 0.4, 0.4);
uniform samplerCube cubemap;
uniform sampler2D albedo_texture : filter_linear_mipmap_anisotropic, source_color, hint_default_white;
uniform vec3 specular_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float metallic : hint_range(0.0, 1.0) = 1.0;
uniform float specular_strength : hint_range(0.0, 10.0) = 2.0;
uniform vec3 fake_light_dir  = vec3(0.0, 0.0, 1.0);
uniform float ambient_boost : hint_range(0.0, 4.0) = 1.1;

void fragment() {
    vec3 N = normalize(NORMAL);
    vec3 V = normalize(-VIEW);
    vec3 L = normalize(fake_light_dir);
    vec3 ambient = albedo_color * ambient_boost;
    vec3 H = normalize(L + V);
    float NdotH = max(dot(N, H), 0.0);
    float spec = pow(NdotH, 1.0 / max(roughness, 0.01)) * specular_strength;

    vec3 final = ambient * texture(albedo_texture, UV).rgb + spec * specular_color;
    ALBEDO = final;
    ROUGHNESS = roughness;
    METALLIC = metallic;
}