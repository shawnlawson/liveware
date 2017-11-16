
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//scale up space per voice
    float v = snoise(vec3(st().xx * 4., time * 1.1 - bands.y * 1.));
    v = pow(v * 1.2, 5.);
    v = step(.5, v);
    c = v * yellow;

//end
    float v2 = snoise(vec3(st().xx * 2., time * 1.1 - bands.z * 1.));
    v2 = pow(v2 * 1.2, 5.);
    v2 = step(.5, v2);
    c2 = v2 * blue;

    c = mix(c, c2, .5 );
    FragColor = vec4(c, 1.0);
}
