shader_type spatial;
render_mode depth_prepass_alpha;
uniform sampler2D swash_texture : filter_linear_mipmap_anisotropic;
uniform float fade_duration = 2.0;
uniform float move_duration = 4.0;
uniform float wave_strength = 0.02;
uniform float wave_speed = 2.0;
uniform float wave_frequency = 10.0;
uniform float opacity = 1.0; // Manual control over opacity

void fragment() {
    vec2 uv = UV;

    // Total animation time
    float total_duration = fade_duration + move_duration;

    // Normalize TIME to loop over total_duration
    float t = mod(TIME, total_duration) / total_duration;

    // Fade in/out using smoothstep
    float fade_in = smoothstep(0.0, 0.3, t);
    float fade_out = 1.0 - smoothstep(0.7, 1.0, t);
    float alpha = fade_in * fade_out * opacity;

    // Vertical movement with easing
    float move_t = smoothstep(0.0, 1.0, t);
    float eased_move = sin(move_t * 3.1415); // ease in/out
    uv.y += eased_move * 0.6;

    // Wave distortion
    uv.x += sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
    uv.y += cos(uv.x * wave_frequency + TIME * wave_speed) * wave_strength;

    vec4 tex = texture(swash_texture, uv);
    ALBEDO = tex.rgb;
    ALPHA = tex.a * alpha;
}