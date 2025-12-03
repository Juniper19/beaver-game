shader_type canvas_item;

uniform vec2 scroll_speed = vec2(40.0, 40.0); // pixels/sec
uniform vec2 texture_size = vec2(256.0, 256.0); // replace with your tile size

void fragment() {
    // convert pixel movement into UV space
    vec2 uv = UV + (scroll_speed * TIME) / texture_size;

    // wrap so the tiling repeats perfectly
    uv = fract(uv);

    COLOR = texture(TEXTURE, uv);
}
