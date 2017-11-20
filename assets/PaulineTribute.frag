

void main() {
    float theta = log(length(st()));
    float phi = atan(st().x, st().y);

        float v = vrmf(vec2( .0 * theta  + phi * .0 + stN().x + time * .0141 + bands.x * .05, st().y ) , 1);
    float v2 = vrmf(vec2( .0 * -theta + phi * .0 + stN().x  - time * .141 + bandsR.x * .05, st().y), 1 );

    vec3 c = black;
    c =  v * (0. + stN().x)  * white;
    c = pow(c * 1.3, 2. * white);
    c = step(.1, c) - step(.5, c * 2.);
    c *= green * .25;

    vec3 cr = black;
    cr = v2 * (1. - stN().x) * white;
    cr = pow(cr *1.3, 2. * white);
    cr =  step(.1, cr) - step(.5, cr* 2.) ;
    cr *= blue * .5;
    c +=cr;


    vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;

    vec3 cc = mix(c * 1., bb, .0);
    
    FragColor = vec4(cc, 1.0);

}




// void main() {
//     float theta = log(length(st()));
//     float phi = atan(abs(st().x), st().y);

//     float v = vrmf(vec2( 1.5 * theta  + phi * 1.5 + stN().x + time * -.241 + bands.x * .5, st().y ) , 6);
//     float v2 = vrmf(vec2( 1.5 * -theta + phi * 1.5 + stN().x  - time * -.241 + bandsR.x * .5, st().y), 6 );

//     vec3 c = black;
//     c =  v * (.5 + stN().x)  * white;
//     c = pow(c * 1.3, 2. * white);
//     c = step(.1, c) - step(.5, c * 2.);
//     c *= green * .25;

//     vec3 cr = black;
//     cr = v2 * (1.5 - stN().x) * white;
//     cr = pow(cr *1.3, 2. * white);
//     cr =  step(.1, cr) - step(.5, cr* 2.) ;
//     cr *= blue * .5;
//     c +=cr;

//     vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;

//     vec3 cc = mix(c * 4., bb, .96);
// //     cc = cc *.7 + c * .2 + cr * .2;
//     FragColor = vec4(cc, 1.0);

// }




