#version 150

// in vec3 Position;
in vec4		Color;
in vec3		Normal;
in vec2		TexCoord;

uniform sampler2D uRenderMap;
uniform sampler2D uAudioMap;
uniform ivec2 ciWindowSize;

uniform float time;
uniform vec4 bands;
uniform vec4 bandsR;
out vec4 FragColor;

void main() {
    vec3 bb = texture(uRenderMap, gl_FragCoord.xy/ciWindowSize).rgb;
    vec3 aa = texture(uAudioMap, gl_FragCoord.xy/ciWindowSize).rgb;
    FragColor = vec4(aa.r, aa.g, aa.b, 1.0);
}
