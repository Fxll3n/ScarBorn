shader_type canvas_item;

uniform vec4 trans_color: source_color = vec4(0.639, 0.890, 0.984, 1.0);
uniform float tolerance: hint_range(0.0, 1.0, 0.01) = 0.1;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    float dist = distance(color.rgb, trans_color.rgb);
    
    if (dist < tolerance) {
        color.a = 0.0;
    }
    
    COLOR = color;
}