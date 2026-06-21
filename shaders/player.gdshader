shader_type spatial;

uniform vec3 base_color: source_color;
uniform vec3 inner_color: source_color;
uniform float edge_width = 0.01;
uniform float scale_size = 0.5;
uniform float scale_depth = 0.1;
uniform float rotation = 0.785; // ~pi/4

float fmod(float l, float r) {
    return l - r * floor(l / r);
}

bool is_edge(float coord) {
    return fmod(coord, scale_size) < edge_width;
}

void vertex() {
    UV2 = mat2(
        vec2(cos(rotation), sin(rotation)),
        vec2(-sin(rotation), cos(rotation))
    ) * UV;

    if (is_edge(UV2.x) || is_edge(UV2.y)) {
        VERTEX -= NORMAL * scale_depth;
        VERTEX += BINORMAL * scale_depth / 2.0;
    }
}

void fragment() {
    ALBEDO = base_color.rgb;
    // TODO: a lerp or something here would help give the appearance of
    // shadows, instead of a boolean. Possibly could use `LIGHT_VERTEX` here?
    if (is_edge(UV2.x) || is_edge(UV2.y)) {
        ALBEDO = inner_color.rgb;
    }

}
