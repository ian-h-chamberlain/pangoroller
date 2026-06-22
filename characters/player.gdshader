/// Procedural pangolin "armor" material. Generates scales based on the 
/// UV coordinates and input colors + other parameters.

shader_type spatial;

uniform vec3 base_color : source_color;
uniform vec3 inner_color : source_color;

/// How wide the gap between scales is
uniform float edge_width = 0.01;
/// How large the scales are
uniform float scale_size = 0.5;
/// How deep inward the scales should "grow from"
uniform float scale_depth = 0.1;
/// The UV rotation of the overall appearance
uniform float rotation = 0.785; // ~pi/4
/// How "pointy" the scales should appear.
uniform float sharpness_threshold = 0.25;

/// Return a blend factor that chops the uv up into a grid based on `scale_size`.
/// Returns 1.0 when directly "on" a grid line, and 0.0 when distance from grid line > sharpness_threshold.
float blend_edge(vec2 uv_coord) {
    float u_blend = 1.0 - mod(uv_coord.x, scale_size) / edge_width + sharpness_threshold;
    float v_blend = 1.0 - mod(uv_coord.y, scale_size) / edge_width + sharpness_threshold;

    return clamp(max(u_blend, v_blend), 0.0, 1.0);
}

void vertex() {
    // Rotate the original UV and use the result for shading.
    UV2 = mat2(
            vec2(cos(rotation), -sin(rotation)),
            vec2(sin(rotation), cos(rotation))
        ) * UV;

    // Use the normal to push the area between scales inward toward the center
    VERTEX -= NORMAL * scale_depth * blend_edge(UV2);
    //VERTEX -= TANGENT * scale_depth * blend_edge(UV2);
    
    // Offset toward binormal to give a layered appearance
    vec3 offset = BINORMAL * scale_depth * blend_edge(UV2);
    VERTEX += offset * 2.0;
    // Adjust the normal for the offset, for the light processor to shade it more accurately
    NORMAL = normalize(mix(NORMAL, -offset, blend_edge(UV2)));
}

void fragment() {
    // Simple lerp to get darker colors at the joints between scales
    ALBEDO = mix(base_color.rgb,inner_color.rgb, blend_edge(UV2));
    SPECULAR = mix(0.0, 0.1, blend_edge(UV2));
    ROUGHNESS = 1.0;
    METALLIC = 0.5;
}
