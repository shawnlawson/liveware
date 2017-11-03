
void main() {
    vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;
    vec3 l = texture(audiobuffer, gl_FragCoord.xy/resolution).rgb;
    vec3 r = texture(audiobuffer, 1. - gl_FragCoord.xy/resolution  ).rgb;

    float v = vrmf(vec2(.25, 1.) * st() + vec2(length(bands), 0), int(5. * bands.y + 1.));
    float v2 = vrmf(vec2(.25, 1.) * st() + vec2(length(bandsR), 0) + vec2(100.), int(5. * bandsR.y + 1.) );

    vec3 c = black;
    c = bands.x * red * (v+ stN().x);
    c = pow(c * 1.5, 4. * white);

    vec3 cr = black;
    cr = bandsR.x * blue * (v2 + 1. - stN().x);
    cr = pow(cr * 3., 4. * white);

    c = mix(c * 3., cr * 3., .5);

    FragColor = vec4(c, 1.0);
//     FragColor = vec4(l.r, r.g, 0.0, 1.0);
}


void main() {
    float theta = log(length(st()));
    float phi = atan(st().x, st().y);
    float v = vrmf(vec2(theta * .4 + stN().x + time * .31, st().y) , 5);
    float v2 = vrmf(vec2(theta * .4 + (1. - stN().x) + time * .31, st().y), 5 );

    vec3 c = black;
    c =  v * stN().x  * white;
    c = pow(c * 1.3, 2. * white);
    c = step(.1, c) - step(.5, c * 2.);
    c *= green * .75;
    vec3 cr = black;
    cr = v2 * (1. - stN().x * .7) * white;
    cr = pow(cr *1.3, 2. * white);
    cr =  step(.1, cr) - step(.5, cr* 2.) ;
    cr *= blue * .5;
    c +=cr;

    vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;

    vec3 cc = mix(c * 4., bb, .95);
//     cc = cc *.7 + c * .2 + cr * .2;
    FragColor = vec4(cc, 1.0);

}



void main() {
    float theta = log(length(st())) + time* 1.5;
    float phi = abs(atan(st().x, st().y)) * 2.;


    float v = vrmf(vec2(phi + theta * .4 + stN().x  - bandsR.x* .2, st().y) , 4);
    float v2 = vrmf(vec2(-phi + theta * .4 + (1. - stN().x) - bands.x* .2, st().y), 4 );

    vec3 c = black;
    c =  v * stN().x  * white;
    c = pow(c * 1.3, 2. * white);
    c = step(.1, c) - step(.5, c * 2.);
    c *= green * .5 * length(bandsR) ;

    vec3 cr = black;
    cr = v2 * (1. - stN().x * .7) * white;
    cr = pow(cr *1.3, 2. * white);
    cr =  step(.1, cr) - step(.5, cr* 2.) ;
    cr *= blue * .5* length(bands);
    c +=cr;

    vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;

    vec3 cc = black;
    cc = mix(c * 8., bb, .95);
//     cc = cc *.7 + c * .2 + cr * .2;
    FragColor = vec4(cc, 1.0);

}

