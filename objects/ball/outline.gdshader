shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_scale : hint_range(0, 2) = 0.5;

varying flat vec4 modulate;
void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;

	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);

	vec4 color = texture(TEXTURE, UV) * modulate;
	COLOR = mix(color, line_color, outline - color.a);
	COLOR.a *= modulate.a;
}
