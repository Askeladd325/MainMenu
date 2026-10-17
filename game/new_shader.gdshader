shader_type canvas_item;

// Control the blur intensity from the inspector
uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec4 color = vec4(0.0);
    vec2 text_size = TEXTURE_PIXEL_SIZE;
    
    // Sample surrounding pixels
    color += texture(TEXTURE, UV + vec2(-text_size.x, -text_size.y) * blur_amount) * 0.0625;
    color += texture(TEXTURE, UV + vec2(0.0, -text_size.y) * blur_amount) * 0.125;
    color += texture(TEXTURE, UV + vec2(text_size.x, -text_size.y) * blur_amount) * 0.0625;
    
    color += texture(TEXTURE, UV + vec2(-text_size.x, 0.0) * blur_amount) * 0.125;
    color += texture(TEXTURE, UV) * 0.25;
    color += texture(TEXTURE, UV + vec2(text_size.x, 0.0) * blur_amount) * 0.125;
    
    color += texture(TEXTURE, UV + vec2(-text_size.x, text_size.y) * blur_amount) * 0.0625;
    color += texture(TEXTURE, UV + vec2(0.0, text_size.y) * blur_amount) * 0.125;
    color += texture(TEXTURE, UV + vec2(text_size.x, text_size.y) * blur_amount) * 0.0625;
    
    COLOR = color;
}