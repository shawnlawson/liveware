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
out vec4 FragColor;

void main() {
    vec3 bb = texture(uRenderMap, gl_FragCoord.xy/ciWindowSize).rgb;
    vec3 aa = texture(uAudioMap, gl_FragCoord.xy).rgb;
    FragColor = vec4(aa.r, sin(time), 0.0, 1.0);
}
