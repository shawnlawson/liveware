
void main() {
vec3 c = black;
vec3 c2 = black;

//start
    float theta = log(length(st()));
    float phi = abs(atan(st().x, st().y)) * 2.;

    vec2 rad = vec2(theta - time * .3, phi - sin(time * .2));    

    rad = mix(st(), rad, 1.5);

    float v = vrmf(rad * .25 + vec2(bands.y, bands.x) * .13, 3);
    c = v * purple * 2.;
    float v2 = vrmf(rad * .15 + vec2(bands.x, bands.y) * .13, 3);
    c += v2 * green * 2.;
    float v3 = vrmf(rad * .05 + vec2(bands.x, bands.y) * .13, 3);
    c += v3 * orange * 1.;

    c = pow(c, white * 1. + bands.x * 2.);

//     vec3 bb = texture(backbuffer, stN()).rgb;
//     c = mix(c * 2., bb, .7);
    FragColor = vec4(c, 1.0);
}
