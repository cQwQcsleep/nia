shader_type spatial;
render_mode unshaded, cull_disabled;
//render_mode unshaded, depth_test_disabled;

uniform float freq = 5.0;
uniform float max_alpha : hint_range(0, 1) = 1.0;
uniform float min_alpha : hint_range(0.0, 1) = 0.0;

void fragment() {

    float time_based_factor = sin(freq * TIME);
    float opacity_range = (1.0 - time_based_factor) * min_alpha;
	float final_opacity = (time_based_factor * max_alpha) + opacity_range;
    ALPHA = final_opacity;
}