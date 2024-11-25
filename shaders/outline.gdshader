shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_front, blend_add;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void vertex() {
    // Make sure the outline appears on top
    POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
    POSITION.z -= 0.001;
}

void fragment() {
    vec4 screen_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
    
    bool is_edge = false;
    float alpha = 0.0;
    
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            if(x == 0 && y == 0) continue;
            
            vec2 offset = vec2(float(x), float(y)) * pixel_size * outline_width;
            vec4 neighbor = texture(SCREEN_TEXTURE, SCREEN_UV + offset);
            
            if(neighbor.a < screen_tex.a) {
                is_edge = true;
                alpha = max(alpha, abs(neighbor.a - screen_tex.a));
            }
        }
    }
    
    if(is_edge) {
        ALBEDO = outline_color.rgb;
        ALPHA = outline_color.a * alpha;
    } else {
        ALPHA = 0.0;
    }
}