//
//  mPerlin.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 10/1/17.
//
//


#include "cinder/Perlin.h"

#ifndef mPerlin_h
#define mPerlin_h

struct mPerlin {
    ci::Perlin perlin = ci::Perlin();
    
    
    void	setSeed( int32_t aSeed ){ perlin.setSeed(aSeed); }
    
    uint8_t	getOctaves()  { return perlin.getOctaves(); }
    
    void	setOctaves( uint8_t aOctaves ) { perlin.setOctaves(aOctaves); }
    
    /// Class Perlin look: fractal Brownian motion by summing 'mOctaves' worth of noise
    float	fBm( float v ) const { return perlin.fBm(v); };
    float	fBm2( float x, float y ) const			{ return perlin.fBm( ci::vec2( x, y ) ); }
    float	fBm( const ci::vec3 &v ) const;
    float	fBm3( float x, float y, float z ) const	{ return perlin.fBm( ci::vec3( x, y, z ) ); }
    
    /// Derivative of fractal Brownian motion, corresponding with the values returned by fBm()
    //	float	dfBm( float v ) const;
//    vec2	dfBm( const vec2 &v ) const;
//    vec2	dfBm2( float x, float y ) const			{ return dfBm( vec2( x, y ) ); }
//    vec3	dfBm3( const vec3 &v ) const;
//    vec3	dfBm4( float x, float y, float z ) const { return dfBm( vec3( x, y, z ) ); }

    /// Calculates a single octave of noise
    float	noise( float x ) const { return perlin.noise( x ); }
    float	noise2( float x, float y ) const { return perlin.noise(x, y); }
    float	noise3( float x, float y, float z ) const { return perlin.noise(x, y, z); }
    
    /// Calculates the derivative of a single octave of noise
    //	float	dnoise( float x ) const;
//    vec2	dnoise( float x, float y ) const;
//    vec3	dnoise( float x, float y, float z ) const;


    void print(sol::this_state ts)
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("print('noise \t noise2 \t noise3 \t fBm \t fBm2 \t fBm3 \t setSeed(int) \t getOctaves \t setOctaves(int)')");
    }
};

#endif /* mPerlin_h */
