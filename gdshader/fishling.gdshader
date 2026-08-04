shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, depth_draw_always;

uniform sampler2D _tex : source_color, filter_linear_mipmap_anisotropic;

// Swimming motion
uniform float swim_speed : hint_range(0.0, 10.0) = 2.0;
uniform float swim_amplitude : hint_range(0.0, 2.0) = 0.25;
uniform float twist_amount : hint_range(0.0, 5.0) = 1.0;

// Controls how much the fish bends toward the tail
uniform float tail_influence : hint_range(0.0, 5.0) = 1.5;

// Transparency multiplier
uniform float alpha_mult : hint_range(0.0, 1.0) = 1.0;

// Avoidance
global uniform vec3 nia_pos;
uniform float avoid_radius : hint_range(0.1, 10.0) = 4.0;
uniform float avoid_strength : hint_range(0.0, 2.0) = 0.6;

void vertex() {
    float t = TIME * swim_speed;

    // --- Base swimming motion ---
    float bend = sin(VERTEX.z * tail_influence + t) * swim_amplitude;
    VERTEX.x += bend;

    float twist = sin(VERTEX.z * tail_influence + t) * twist_amount;
    float s = sin(twist);
    float c = cos(twist);

    float x = VERTEX.x;
    float y = VERTEX.y;

    VERTEX.x = x * c - y * s;
    VERTEX.y = x * s + y * c;

    // --- Avoidance steering ---
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 to_player = nia_pos - world_pos;
    float dist = length(to_player);

    if (dist < avoid_radius) {
        float factor = 1.0 - (dist / avoid_radius);

        // Direction away from player
        vec3 away = normalize(-to_player);

        // Sideways steering (more natural than fleeing straight back)
        vec3 tangent = normalize(cross(away, vec3(0.0, 1.0, 0.0)));

        // Blend direct avoidance with sideways curve
        vec3 steer = mix(away, tangent, 0.6);

        // Apply steering in local space
        VERTEX += (inverse(MODEL_MATRIX) * vec4(steer, 0.0)).xyz
                  * avoid_strength * factor;
    }
}

void fragment() {
    vec2 uv = UV;
    vec4 tex = texture(_tex, uv);

    ALBEDO = tex.rgb * COLOR.rgb;
    EMISSION = ALBEDO * 0.5;
    ALPHA = tex.a * COLOR.a * alpha_mult;
}
