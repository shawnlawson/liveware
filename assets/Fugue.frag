
void main() {
vec3 c = black;
vec3 c2 = black;

//start
//scale up space per voice
    vec3 v = voronoi(vec3(st(), time * .1 + bands.y));
    v.z = pow(sin(v.z) * 1.2, 4.5);
    c = v.z * yellow;

    vec3 v2 = voronoi(vec3(st() * 3., time * .1 + bands.x));
    v2.z = pow(sin(v2.z) * 1.2, 4.5);
    c2 = v2.z * blue;

    c = mix(c, c2, .5 );
    FragColor = vec4(c, 1.0);
}
