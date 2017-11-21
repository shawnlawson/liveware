
void main() {
    vec3 c = black;
    float r = log(length(st()));
    float p = atan(st().x, st().y);

//     r = floor(r * 20 + bands.x * 5.);
//     p = floor(p * 20 + bands.y * 5.);

       float f = vrmf(vec2(st()) + vec2(1), 2);
       float f2 = vrmf(vec2(st()) + vec2(1), 2);

//        float f = vrmf(vec2(r, p) + vec2(sin(time * 1) - bands.y * .1, 0), int(4 * bands.x + 2.));
//        float f2 = vrmf(vec2(r, p) + vec2(1, time * .1+bands.y * .1), int(4 * bands.y + 2.));

       c = f * orange;
       c += f2 * teal;

    c = pow(c * 2., 2. * white);

    vec3 bb = texture(backbuffer, stN()).rgb;

    c = mix(c , bb, .5);

    FragColor = vec4(c, 1.0);
}
