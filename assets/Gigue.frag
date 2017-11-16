
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//scale up space per voice
    vec2 f2 = floor(st() * 6.);
    float v = fbm(f2  + vec2(0, -time + bands.x ), int(4.));
    v = pow(v * 1.2, 3. + bands.y * 2.);
    v = step(.5, v);
    c = v * mix(orange, yellow, bands.x  * 1.5);

//end
    vec2 f = floor(st() * 8.);
    float v2 = fbm(f  + vec2(0, -time ), int(4.));
    v2 = pow(v2 * 1.2, 3. + bands.y * 2.);
//     v2 = floor(v2 * 10.);
    v2 = step(.5, v2);
    c2 = v2 * mix(blue, teal, bands.y * 1.5);

    c = mix(c, c2, .5 );
    vec3 bb = texture(backbuffer, stN()).rgb;
    c = mix(c * 2., bb, .7);
    FragColor = vec4(c, 1.0);
}
