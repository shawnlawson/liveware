#version 400

layout(location = 0) in vec4 Vertexposition;
layout (location = 2) in vec2 VertexTexCoord;

out vec4 Position;
out vec2 TexCoord;

void main()
{
	TexCoord = VertexTexCoord;
    gl_Position = Position = Vertexposition;
}