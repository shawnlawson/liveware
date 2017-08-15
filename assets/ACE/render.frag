#version 400

// in vec3 Position;
in vec4		Color;
in vec3		Normal;
in vec2		TexCoord;

uniform sampler2D RenderTex;
uniform ivec2 ciWindowSize;

uniform float time;
out vec4 FragColor;

void main() {
    FragColor = vec4(gl_FragCoord.x/ciWindowSize.x, sin(time), 0.0, 1.0);
}
