// inventory_circle.gdshader
shader_type canvas_item;

void fragment() {
    // Get distance from center
    vec2 uv = UV * 2.0 - 1.0;
    float distance = length(uv);
    
    // Create circle with smooth edge
    float circle = 1.0 - smoothstep(0.8, 0.85, distance);
    
    // Create border
    float border = 1.0 - smoothstep(0.8, 0.83, distance);
    border -= 1.0 - smoothstep(0.77, 0.8, distance);
    
    // Combine circle and border
    vec4 inside_color = COLOR;
    vec4 border_color = vec4(0.0, 0.0, 0.0, 1.0); // Black border
    
    // Final color
    COLOR = mix(inside_color * circle, border_color, border);
    COLOR.a *= (circle + border); // Make outside transparent
}