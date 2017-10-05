
void main() {
    vec3 bb = texture(backbuffer, gl_FragCoord.xy/resolution).rgb;
    vec3 aa = texture(audiobuffer, gl_FragCoord.xy/resolution).rgb;
    FragColor = vec4(aa.r, aa.g, aa.b, 1.0);
}
