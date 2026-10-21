#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform ubuf {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    vec3 text = texture(source, qt_TexCoord0).rgb;
    float alpha = max(text.r, max(text.g, text.b));
    fragColor = vec4(vec3(0.88, 0.94, 0.73) * alpha, alpha) * qt_Opacity;
}
