shader_type canvas_item;
render_mode unshaded;

uniform sampler2D palette_swap;
uniform sampler2D greyscale_palette;

void fragment()
{
	vec4 old_color = texture(TEXTURE, UV);
	vec2 swap_coord = vec2 ( old_color.r, 0);
	vec4 new_color = texture(palette_swap, swap_coord);
	if (distance(old_color, texture(greyscale_palette, swap_coord)) < .3){
		new_color.a *= old_color.a;
		COLOR = new_color;
	} else {
		COLOR = old_color;
	}
}