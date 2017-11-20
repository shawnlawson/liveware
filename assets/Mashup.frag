
void main() {

float cc1 = texture(audiobuffer, vec2(128./1024.,0.)).b;
float cc2 = texture(audiobuffer, vec2(129./1024.,0.)).b;
float cc3 = texture(audiobuffer, vec2(130./1024.,0.)).b;

	vec3 c = black;
	vec3 c2 = black;

	if (cc1 < 0.25){
        vec2 st = rotate(vec2(0), st(), cc2 * PI2);
		float v2 = fbm(st * 2. + vec2(0, -time * .02), int(2. + bands.x*8.));
// 		     v2 = pow(v2 * 1.2, 5.);
		v2 = step(cc3, v2);
		c2 = v2 * blue;

		//     c = mix(c, c2, .5 );
		vec3 bb = texture(backbuffer, stN()).rgb;
		c2 = mix(c2, bb, .98);
		FragColor = vec4(c2, 1.0);
	} 
	else if (cc1 < 0.5) 
	{
		float v = snoise(vec3(st().xx * 4., time * (cc2 +.1) - bands.y * 1.));
		v = pow(v * 1.2, 5.);
		v = step(cc3, v);
		c = v * yellow;

		//end
		float v2 = snoise(vec3(st().xx * 2., time * (cc2 +.1) - bands.z * 1.));
		v2 = pow(v2 * 1.2, 5.);
		v2 = step(cc3, v2);
		c2 = v2 * blue;

		c = mix(c, c2, .5 );
		FragColor = vec4(c, 1.0);
	} 
	else if (cc1 < 0.75) 
	{
		//start
		//scale up space per voice
		vec2 f2 = floor(st() * 16. * cc2);
		float v = fbm(f2  + vec2(0, -time + bands.x ), int(4.));
		v = pow(v * 1.2, 3. + bands.y * 2.);
		v = step(cc3, v);
		c = v * mix(orange, yellow, bands.x  * 1.5);

		//end
		vec2 f = floor(st() * 18. * cc2);
		float v2 = fbm(f  + vec2(0, -time ), int(4.));
		v2 = pow(v2 * 1.2, 3. + bands.y * 2.);
		//     v2 = floor(v2 * 10.);
		v2 = step(cc3, v2);
		c2 = v2 * mix(blue, teal, bands.y * 1.5);

		c = mix(c, c2, .5 );
		vec3 bb = texture(backbuffer, stN()).rgb;
		c = mix(c * 2., bb, .7);
		FragColor = vec4(c, 1.0);
	} 
	else 
	{
		vec3 v = voronoi(vec3(st() * cc3* 3., time * .1 + bands.y));
		v.y = pow(v.y * 1.2, 3. + cc2 * 30.);
		c = v.y * yellow;

		//end
		vec3 v2 = voronoi(vec3(st() * 6. * cc3, time * .1 + bands.z));
		v2.y = pow(v2.y * 1.2, 3. + cc2 * 30.);
		c2 = v2.y * blue;

		c2 = sin(v2.y) * blue;

		c = mix(c, c2, .5 );
		FragColor = vec4(c, 1.0);
	}


}
