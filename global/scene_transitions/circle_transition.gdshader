shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float progress = 0.5;
uniform float asp = 1.7777777777777;


void fragment() {
	vec2 asp_UV = UV;
	asp_UV.x *= asp;
	
	vec2 asp_center = center;
	asp_center.x *= asp;
	
	vec2 dif = asp_center - asp_UV;

	
	vec2 max_vec_normalized = max(abs(center), abs(vec2(1.0) - center));
	vec2 max_dist_vec = max_vec_normalized;
	max_dist_vec.x *= asp;
	float max_dist_sq = dot(max_dist_vec, max_dist_vec);
	
	float dist_sq = dot(dif, dif);
	float scaled_progress = progress * progress * max_dist_sq;

	if (dist_sq < scaled_progress) {
		discard;
	}
}
