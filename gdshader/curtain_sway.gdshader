shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

uniform sampler2D tex : source_color, filter_linear_mipmap_anisotropic;
uniform float alpha = 0.0;
uniform vec2 uv_scale = vec2(1.0, 1.0);

uniform float sway_strength_x = 0.05;
uniform float sway_strength_z = 0.03;
uniform float sway_speed_x = 1.5;
uniform float sway_speed_z = 1.0;

void vertex() {
    float sway_factor = VERTEX.y;

    float offset_x = sin(TIME * sway_speed_x + VERTEX.y * 2.0) * sway_strength_x * sway_factor;
    float offset_z = cos(TIME * sway_speed_z + VERTEX.x * 2.0) * sway_strength_z * sway_factor;

    VERTEX.x += offset_x;
    VERTEX.z += offset_z;
}

void fragment() {
    vec2 uv = UV * uv_scale;
    vec4 final_tex = texture(tex, uv);
    ALBEDO = final_tex.rgb;
    ALPHA = final_tex.a - alpha;
}