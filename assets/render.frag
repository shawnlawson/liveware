#version 330 core

in vec2 vTexCoord;

uniform sampler2D tex;
uniform vec2 resolution;

out vec4 color;

void main(void)
{
	color = vec4( gl_FragCoord.x/resolution.x, 0.0, 0.0, 1.0 );
}