#version 410

in vec4 vColor;
in vec4 vPosition;
in vec3 vNormal;
in vec4 vModelPosition;
in vec3 vModelNormal;
in vec4	vShadowCoord;


uniform vec3			uLightPos;

uniform sampler2DShadow	uShadowMap;
uniform mat4			uShadowMatrix;
uniform int				uShadowTechnique;
uniform float			uDepthBias;
uniform bool			uOnlyShadowmap;

out vec4 fragColor;

float samplePCF3x3( vec4 sc )
{
	const int s = 2;
	
	float shadow = 0.0;
	shadow += textureProjOffset( uShadowMap, sc, ivec2(-s,-s) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2(-s, 0) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2(-s, s) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( 0,-s) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( 0, 0) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( 0, s) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( s,-s) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( s, 0) );
	shadow += textureProjOffset( uShadowMap, sc, ivec2( s, s) );
	return shadow/9.0;;
}

void main()
{
	// Normal in view space
	vec3	N = normalize( vNormal );
	// Light direction
	vec3	L = normalize( uLightPos - vPosition.xyz );
	// To camera vector
	vec3	C = normalize( -vPosition.xyz );
	// Surface reflection vector
	vec3	R = normalize( -reflect( L, N ) );
	
	
	vec3	indirectGlow = vec3( clamp( dot( 0.8 * normalize(vModelNormal), -normalize(vModelPosition.xyz) ), 0.0, 0.55 ), 0.0, 0.0 );
	vec3	A =  indirectGlow + vec3( 0.07, 0.05, 0.1 );
	// Diffuse factor
	float NdotL = max( dot( N, L ), 0.0 );
	vec3	D = vec3( NdotL );
	// Specular factor
	vec3	S = pow( max( dot( R, C ), 0.0 ), 50.0 ) * vec3(1.0);
		
	// Sample the shadowmap to compute the shadow value
	float shadow = 1.0f;
	vec4 sc = vShadowCoord;
	sc.z += uDepthBias;
	
	shadow = samplePCF3x3( sc );
	
	fragColor.rgb = mix( ( ( D + S ) * shadow + A ) * vColor.rgb, vec3(shadow), float(uOnlyShadowmap) );
	fragColor.a = 1.0;
}
