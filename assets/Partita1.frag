
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//scale up space per voice
    vec3 v = voronoi(vec3(st(), time * .1 + bands.y));
    v.y = pow(v.y * 1.2, 3.);
    c = v.y * yellow;

//end
    vec3 v2 = voronoi(vec3(st() * 3., time * .1 + bands.z));
    v2.y = pow(v2.y * 1.2, 3.);
    c2 = v2.y * blue;

    c2 = sin(v2.y) * blue;

    c = mix(c, c2, .5 );
    FragColor = vec4(c, 1.0);
}
