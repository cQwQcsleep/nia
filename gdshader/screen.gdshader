shader_type spatial;
uniform sampler2D _texture : filter_linear_mipmap_anisotropic;
uniform float _emission = 0.8;
uniform float _flicker_strength = 32.0;
void fragment() {
	float _flicker;
	_flicker += abs(sin(TIME * 32.0)) / _flicker_strength;
	ALBEDO = texture(_texture, UV).rgb + _flicker;
	EMISSION = ALBEDO * _emission;
}
