shader_type canvas_item;
uniform float state: hint_range(1.0, 128.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
//global uniform sampler2D screen_texture;
void fragment() 
{
	vec2 amt = 1.0 / state / SCREEN_PIXEL_SIZE;
	vec2 uv = round(SCREEN_UV * amt) / amt;
	vec4 c = textureLod(screen_texture, uv, 0);
	//vec4 c= texture(Scrre)
	COLOR = c;
}