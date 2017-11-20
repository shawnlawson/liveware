
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//    vec2 f = floor(st() * 6.);
    float v = voronoi(vec3(st(), time * .1 + bands.y)).y;
//    float v = snoise(vec3(st() , time * .1 - bands.y * .1));
//    float v = fbm(f  + vec2(0, -time  *.1 + bands.x * .1 ), int(4.));
    v = pow(v * 1.2, 3.);
//    v = step(.5, v);
    c = v * yellow;

//    vec3 bb = texture(backbuffer, stN()).rgb;
    c = mix(c, c2, .5 );
    FragColor = vec4(c, 1.0);
}
