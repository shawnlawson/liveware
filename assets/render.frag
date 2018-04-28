//fbm, vfbm, rmf, vrmf
void main() {
    vec2 stN = stN(), st = st(); vec3 c = black; 
    float theta = (atan(st.x, st.y) + PI)/ PI2; 
    float phi = log(length(st));
    float k = 3. + bands.x * 3.; 
    float a = mod(atan(st.x, st.y)/ PI2, PI2/k); 
    a = abs(a - PI2/k/2.) * 1.;

	FragColor = vec4(c, 1.);
}
