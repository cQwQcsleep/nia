shader_type canvas_item;
uniform bool invert = false;
void fragment(){
	if (invert) {
		vec4 color = texture(TEXTURE, UV);
		COLOR = vec4(1.0 - color.rgb, color.a);
	}

}