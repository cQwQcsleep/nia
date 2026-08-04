shader_type spatial;
render_mode cull_back;
uniform sampler2D texture_a : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D texture_b : source_color, filter_linear_mipmap_anisotropic;
uniform float texture_b_scale = 0.1;
uniform float texture_b_strength = 0.0;
varying vec3 world_pos_vtx;

void vertex() {
    world_pos_vtx = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec4 triplanar_texture(sampler2D tex, vec3 world_pos, vec3 normal, float scale) {
    vec3 n = abs(normal);
    n = n / (n.x + n.y + n.z);

    vec2 uv_x = world_pos.yz * scale;
    vec2 uv_y = world_pos.xz * scale;
    vec2 uv_z = world_pos.xy * scale;

    vec4 x_tex = texture(tex, uv_x);
    vec4 y_tex = texture(tex, uv_y);
    vec4 z_tex = texture(tex, uv_z);

    return x_tex * n.x + y_tex * n.y + z_tex * n.z;
}

void fragment() {
    vec4 col_a = texture(texture_a, UV);
    vec4 col_b = triplanar_texture(texture_b, world_pos_vtx, NORMAL, texture_b_scale);
    float mask = clamp(COLOR.r, texture_b_strength, 1.0);
    ALBEDO = mix(col_b.rgb, col_a.rgb, mask);
}
