#version 400

in vec4 ciPosition;
in vec2	ciTexCoord0;
in vec3	ciNormal;
in vec3 ciColor;

uniform mat4 	ciModelView;
uniform mat4	ciModelViewProjection;
uniform mat3	ciNormalMatrix;

out highp vec2	TexCoord;
out lowp vec4	Color;
out highp vec3	Normal;


void main()
{
    gl_Position	= ciModelViewProjection * ciPosition;
	Color 		= vec4(ciColor, 1.0);
	TexCoord	= ciTexCoord0.xy;
	Normal		= ciNormalMatrix * ciNormal;
    // Position = ciModelView * ciPosition;
}
