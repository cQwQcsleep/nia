shader_type spatial;
render_mode cull_disabled, unshaded;

// --- Textures ---
uniform sampler2D tex_a : hint_default_black, filter_linear_mipmap_anisotropic;
uniform sampler2D tex_b : hint_default_black, filter_linear_mipmap_anisotropic;
uniform sampler2D noise_tex : hint_default_black;

// --- Controls ---
uniform vec3 tint_a : source_color = vec3(0.95, 0.35, 0.35);
uniform vec3 tint_b : source_color = vec3(0.75, 0.20, 0.20);
uniform float overlay_strength = 0.6;
uniform float tri_scale = 2.0;
uniform float tri_sharpness = 2.0;

// --- Wavy distortion ---
uniform float wave_amp_a = 0.15;
uniform float wave_amp_b = 0.10;
uniform float wave_freq_a = 1.6;
uniform float wave_freq_b = 1.1;
uniform float wave_speed_a = 0.8;
uniform float wave_speed_b = 0.5;

// --- Vertex pulsation ---
uniform float pulse_amp = 0.02;
uniform float pulse_freq = 2.4;
uniform float pulse_speed = 1.5;

// --- Wet look ---
uniform float wet_spec = 0.9;
uniform float wet_rough = 0.15;

// Helper: triplanar weights
vec3 tri_weights(vec3 n) {
    vec3 an = abs(n);
    an = pow(an, vec3(tri_sharpness));
    return an / (an.x + an.y + an.z + 1e-5);
}

// Triplanar sample in **local space**
vec4 triplanar_sample(sampler2D tex, vec3 lp, vec3 n, float scale, vec3 wobble) {
    vec2 uv_x = (lp.zy + wobble.zy) * scale;
    vec2 uv_y = (lp.xz + wobble.xz) * scale;
    vec2 uv_z = (lp.xy + wobble.xy) * scale;

    vec3 w = tri_weights(n);

    vec4 sx = texture(tex, uv_x);
    vec4 sy = texture(tex, uv_y);
    vec4 sz = texture(tex, uv_z);

    return sx * w.x + sy * w.y + sz * w.z;
}
varying vec3 lp;
varying vec3 ln;
void vertex() {
    lp = VERTEX;   // local position
    ln = NORMAL;   // local normal

    float base_pulse = sin(length(lp) * pulse_freq + TIME * pulse_speed);
    float disp = base_pulse * pulse_amp;

    VERTEX += ln * disp;
}

void fragment() {
   // lp = VERTEX;   // local position
   // ln = NORMAL;   // local normal

    float t = TIME;

    vec3 wobble_a = vec3(
        sin(lp.x * wave_freq_a + t * wave_speed_a),
        sin(lp.y * wave_freq_a + t * wave_speed_a + 1.7),
        sin(lp.z * wave_freq_a + t * wave_speed_a + 3.1)
    ) * wave_amp_a;

    vec3 wobble_b = vec3(
        sin(lp.x * wave_freq_b + t * wave_speed_b + 0.8),
        sin(lp.y * wave_freq_b + t * wave_speed_b + 2.3),
        sin(lp.z * wave_freq_b + t * wave_speed_b + 4.0)
    ) * wave_amp_b;

    vec4 ca = triplanar_sample(tex_a, lp, ln, tri_scale, wobble_a);
    vec4 cb = triplanar_sample(tex_b, lp, ln, tri_scale, wobble_b);

    ca.rgb *= tint_a;
    cb.rgb *= tint_b;

    float a_alpha = clamp(ca.a * overlay_strength, 0.0, 1.0);
    vec3 blended = mix(cb.rgb, ca.rgb, a_alpha);

    ALBEDO = blended;
    SPECULAR = wet_spec;
    ROUGHNESS = wet_rough;
}