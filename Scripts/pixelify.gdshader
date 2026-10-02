shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 res = vec2(32.0, 20.0);

void fragment() {
	vec2 pixel_uv = floor(UV * res) / res;
	COLOR = texture(screen_texture, pixel_uv);
}
