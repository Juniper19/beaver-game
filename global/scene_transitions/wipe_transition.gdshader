shader_type canvas_item;

uniform float progress = 0.5;
uniform float asp = 1.7777777777777;
uniform int teeth = 5;


void fragment() {
	vec2 asp_UV = UV;
	asp_UV.x *= asp;
	
	float tooth_percent = fract(float(UV.y * float(teeth)));
	float teeth_wave = 1.0 - abs(2.0 * tooth_percent - 1.0);
	
	float teeth_width = 1.0 / float(teeth);
	float teeth_offset = teeth_width * teeth_wave * 0.5;

	
	if (UV.x + teeth_offset < progress) {
		discard;
	}
	
	COLOR = vec4(1.0);
}
