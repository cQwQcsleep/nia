shader_type sky;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black;
uniform sampler2D noise_tex : repeat_enable;

uniform float exposure : hint_range(0, 128) = 1.0;
uniform float cloud_scroll_speed : hint_range(0.0, 10.0) = 1.0;
uniform float cloud_scale : hint_range(0.2, 10.0) = 2.0;
uniform float cloud_alpha_threshold : hint_range(0.0, 1.0) = 0.3;
uniform float cloud_alpha_strength : hint_range(0.0, 1.0) = 1.0;
uniform vec3 cloud_color : source_color = vec3(1.0);
uniform float horizon_compression : hint_range(0.0, 1.0) = 0.7;

void sky() {
    // Base panorama
    vec3 base_color = texture(source_panorama, SKY_COORDS).rgb * exposure;

    // Stretch clouds near horizon
    vec2 cloud_uv = SKY_COORDS;
    float compression = mix(1.0, horizon_compression, smoothstep(0.0, 0.7, cloud_uv.y));
    cloud_uv.y *= compression;

    cloud_uv *= cloud_scale;
    cloud_uv.x += TIME * cloud_scroll_speed;

    float noise = texture(noise_tex, fract(cloud_uv)).r;
    float alpha = smoothstep(cloud_alpha_threshold, 1.0, noise) * cloud_alpha_strength;

    vec3 final_color = mix(base_color, cloud_color, alpha);
    COLOR = vec4(final_color, 1.0).rgb;
}