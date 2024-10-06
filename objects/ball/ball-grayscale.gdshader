shader_type canvas_item;
render_mode blend_mix;

uniform float ratio : hint_range(0, 1, 0.001) = 1.0;

varying flat vec4 modulate;
void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV) * modulate;
	float grayscale_component = dot(color.rgb, vec3(0.3, 0.59, 0.11));
	COLOR = vec4(mix(color.rgb, vec3(grayscale_component), ratio), color.a);
}
