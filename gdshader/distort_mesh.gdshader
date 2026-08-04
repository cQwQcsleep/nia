shader_type spatial;

uniform vec4 color : source_color;
uniform float distortion_amount : hint_range(0.0, 2.0) = 0.0;

float rand(vec3 co) {
    return fract(sin(dot(co ,vec3(12.9898,78.233,45.164))) * 43758.5453);
}

void vertex() {
    float amount = distortion_amount;

    // random offset per vertex
    vec3 offset;
    offset.x = rand(VERTEX + vec3(1.0)) - 0.5;
    offset.y = rand(VERTEX + vec3(2.0)) - 0.5;
    offset.z = rand(VERTEX + vec3(3.0)) - 0.5;

    VERTEX += offset * amount;
}
void fragment() {
	ALBEDO = color.rgb;
	//ALPHA = color.a;
	}