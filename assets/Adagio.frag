
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//scale up space per voice
//     float v = fbm(st() * 4., 2);
//     v = pow(v * 1.2, 5.);
//     v = step(.5, v);
//     c = v * yellow;

//end
    float v2 = fbm(st() * 2. + vec2(0, -time * .02), int(2. + bands.x*7.));
//     v2 = pow(v2 * 1.2, 5.);
    v2 = step(.5, v2);
    c2 = v2 * blue;

//     c = mix(c, c2, .5 );
    vec3 bb = texture(backbuffer, stN()).rgb;
    c2 = mix(c2, bb, .98);
    FragColor = vec4(c2, 1.0);
}
