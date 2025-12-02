// thank you me for writing this

shader_type canvas_item;

uniform int sizeY = 60;

uniform float SPEED_FACTOR = 0.1;
uniform float TWIST_SPEED_FACTOR = 1.0;
uniform float TWIST_FACTOR = 1.0;
uniform float TWIST_MOVE_FACTOR = 0.0;
uniform float aspectRatio = 1.777777;

uniform sampler2D noiseTex : repeat_enable;

uniform vec3 FROM_COLOR : source_color = vec3(0.20392156862745098, 0.5725490196078431, 0.4);
uniform vec3 TO_COLOR : source_color = vec3(0.247, 0.478, 0.384);

vec2 rotate(vec2 v, float th) {
    mat2 rotMat = mat2(
        vec2(cos(th), -sin(th)),
        vec2(sin(th),  cos(th))
    );
    return rotMat * v;
}

float noise(in vec2 p) {
	return sin(p.x * 0.85481 + TIME * SPEED_FACTOR * 0.91831) * sin(p.y * 0.923 - TIME * SPEED_FACTOR * 0.8727);
}

// https://iquilezles.org/articles/fbm/
const int FBM_OCTAVES = 4;
float fbm(in vec2 x, in float H) {
	float G = exp2(-H);

	float f = 1.0;
	float a = 1.0;
	float t = 0.0;
	for(int i = 0; i < FBM_OCTAVES; i++) {
		//sum += a;
		t += a * noise(f * x);
		f *= 2.0;
		a *= G;
	}

	return t * 0.5 + 0.5;
}

float pattern(in vec2 p) {
	float H = 0.5;

	vec2 q = vec2(
		fbm(p + vec2(0.0, 0.0), H),
		fbm(p + vec2(5.2, 1.3), H)
	);

	return fbm(p + 4.0 * q, 0.5);

	//vec2 q = vec2( fbm( p + vec2(0.0,0.0), H),
                   //fbm( p + vec2(5.2,1.3), H) );
//
    //vec2 r = vec2( fbm( p + 4.0*q + vec2(1.7,9.2), H),
                   //fbm( p + 4.0*q + vec2(8.3,2.8), H) );
//
    //return fbm( p + 4.0*r , H);
}

void fragment() {

	vec3 res;
	vec2 p = vec2(length(UV * 2.0 - 1.0), acos(UV.x));

	//p *=  2.0;

	res = vec3(pattern(p));

	vec2 size = vec2(float(int(float(sizeY) * aspectRatio)), float(sizeY));

	vec2 centeredUV = SCREEN_UV * 2.0 - 1.0;
	centeredUV.x *= aspectRatio;

	vec2 discreteUV = centeredUV * size;
	discreteUV.x = float(int(discreteUV.x));
	discreteUV.y = float(int(discreteUV.y));
	discreteUV /= size;


	discreteUV = rotate(discreteUV, length(centeredUV) * TWIST_FACTOR);
	discreteUV = rotate(discreteUV, TIME * 0.05 * TWIST_SPEED_FACTOR);

	vec2 normalizedCenteredUV = normalize(centeredUV);
	float angle = atan(normalizedCenteredUV.y, normalizedCenteredUV.x);
	float normalizedAngle = angle / TAU * 0.5;

	discreteUV *= 1.0; // COMMENT

	float t = pattern(discreteUV);
	t = clamp(t, 0.0, 1.0);
	res = mix(FROM_COLOR, TO_COLOR, t);

	COLOR = vec4(res, 1.0);
}

//uniform vec4 color1 : source_color = vec4(1.0);
//uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
//uniform float asp = 1.7777777;
//
//uniform float size = 10;
//
//void fragment() {
	//vec2 uv = UV;
	//uv.y += UV.x;
	//uv.x += UV.y;
	//uv.x *= asp;
	//
	//
	//
	//float t = TIME * 0.5;
	//
	//vec2 cell = floor(uv * vec2(size)+ vec2(-t, t * 0.2));
	//
	//
	//bool is_color1 = int(cell.x + cell.y) % 2 == 0;
	//COLOR = is_color1 ? color1 : color2;
//}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
