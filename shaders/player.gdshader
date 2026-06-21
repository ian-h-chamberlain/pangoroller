shader_type spatial;

uniform vec3 base_color : source_color;
uniform vec3 inner_color : source_color;
uniform float edge_width = 0.01;
uniform float scale_size = 0.5;
uniform float scale_depth = 0.1;
uniform float rotation = 0.785; // ~pi/4

/// When we get close to the
float blend_edge(vec2 uv_coord) {
    float u_blend = mod(uv_coord.x, scale_size) / edge_width - 0.25;
    float v_blend = mod(uv_coord.y, scale_size) / edge_width - 0.25;

    return clamp(min(u_blend, v_blend), 0.0, 1.0);
}

void vertex() {
    UV2 = mat2(
            vec2(cos(rotation), sin(rotation)),
            vec2(-sin(rotation), cos(rotation))
        ) * UV;


    VERTEX += NORMAL * scale_depth * blend_edge(UV2);

    // VERTEX -= BINORMAL * scale_depth * blend_edge(UV2) * 2.0;
}

void fragment() {
    ALBEDO = mix(inner_color.rgb, base_color.rgb, blend_edge(UV2));
}
