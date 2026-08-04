shader_type sky;

uniform sampler2D source_panorama : filter_linear, source_color, hint_default_black, repeat_disable;
uniform float exposure : hint_range(0, 128) = 1.0;
uniform vec2 uv_offset;
uniform float uv_scale : hint_range(0.01, 10.0) = 1.0;

// Mirror a coordinate across its integer boundary
vec2 mirror(vec2 uv) {
	//uv = abs(fract(uv) * 2.0 - 1.0);
	//uv.y = uv.y;
	uv.x = abs(fract(uv.x) * 2.0 - 1.0);
	return uv;
}

void sky() {
	vec2 centered_coords = SKY_COORDS - 0.5;
	centered_coords /= uv_scale;
	centered_coords += 0.5 + uv_offset;
	vec2 mirrored_coords = mirror(centered_coords);
	COLOR = texture(source_panorama, mirrored_coords).rgb * exposure;
}
