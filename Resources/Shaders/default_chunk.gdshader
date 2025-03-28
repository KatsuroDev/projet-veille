shader_type spatial;

uniform sampler2D gradient_texture:source_color;
uniform int height_multiplier;

varying float height;

void vertex() {
	height = VERTEX.y / float(height_multiplier);
}

void fragment() {
	ALBEDO = texture(gradient_texture, vec2(height, 0.0)).rgb;
}
