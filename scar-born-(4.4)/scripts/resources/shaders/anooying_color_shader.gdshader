shader_type canvas_item;

uniform vec3 color_to_remove : source_color = vec3(1.0, 0.0, 1.0); // Default: magenta
uniform float tolerance : hint_range(0.0, 1.0) = 0.01;

void fragment() {
    vec4 original_color = texture(TEXTURE, UV);

    // Check if this pixel matches the color we want to remove
    float color_distance = distance(original_color.rgb, color_to_remove);

    if (color_distance <= tolerance) {
        // Make it completely transparent
        COLOR.a = 0.0;
    } else {
        // Keep the original color
        COLOR = original_color;
    }
}