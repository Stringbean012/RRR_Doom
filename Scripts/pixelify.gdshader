shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 res = vec2(156, 117);
uniform sampler2D melt_texture: repeat_disable, filter_nearest;
uniform int offsets[160];
uniform bool melting = false;

void fragment() {
	vec2 pixel_pos = floor(UV * res);
	vec2 pixel_uv = pixel_pos / res;
	COLOR = texture(screen_texture, pixel_uv);
	
	int offset = max(0, offsets[int(pixel_pos.x / 2.0)]);
	if (melting && int(pixel_pos.y) > offset){
		float v = pixel_uv.y - float(offset) / res.y;
		COLOR = texture(melt_texture, vec2(pixel_uv.x, v));
	}
		
}
