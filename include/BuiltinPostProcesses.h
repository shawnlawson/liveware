

#ifndef BuiltinPostProcesses_h
#define BuiltinPostProcesses_h

#include "PostProcess.h"


// === MIRROR =================================================================

class Mirror  : public PostProcess
{
public:
    static PostProcessRef create()
    {
        return std::make_shared<PostProcess>( CI_GLSL( 400,
        
            uniform sampler2D tex0;
            in vec2 TexCoord;
            out vec4 FragColor;
            
            void main()
            {
                vec2 p = TexCoord;
                FragColor = texture( tex0, vec2( 0.5 - abs( (p.x - 0.5) ), p.y ) );
            }
        
        ));
    }
};


// === INVERT =================================================================

class Invert  : public PostProcess
{
public:
    static PostProcessRef create()
    {
        return std::make_shared<PostProcess>( CI_GLSL( 400,
        
            uniform sampler2D tex0;
            in vec2 TexCoord;
            out vec4 FragColor;
            
            void main()
            {
                vec2 p = TexCoord;
                vec4 col = texture( tex0, p );
                col.xyz = vec3( 1.0 ) - col.xyz;
                FragColor = col;
            }
        
        ));
    }
};


// === GREYSCALE ==============================================================

class Greyscale  : public PostProcess
{
public:
    Greyscale( float newAmount = 1.0f )
    : PostProcess( getFragmentShader() )
    {
        mAmount = newAmount;
    }
    
    static const std::string getFragmentShader()
    {
        return  CI_GLSL( 400,
    
        uniform sampler2D tex0;
        uniform float amount;
        in vec2 TexCoord;
        out vec4 FragColor;
        
        
        void main()
        {
            vec2 p = TexCoord;
            vec4 tex = texture( tex0, p );
            vec3 col = vec3( 0.0 );
            
            float gray = dot( tex.rgb, vec3( 0.299, 0.587, 0.114 ) );

            FragColor = vec4( mix(tex.rgb, vec3(gray), amount), tex.a );
//            FragColor = vec4( gray, gray, gray, 1.);
        }
    
                        );
    }
    
    void amount( float newAmount )
    {
        mAmount = newAmount;
        mPostProcessShader->uniform( "amount", mAmount );
    }

    virtual void updateUniforms() override
    {
        mPostProcessShader->uniform( "amount", mAmount );
    }

    std::string listUniforms()
    {
        return "amount";
    }
    
    float mAmount;
};


// === BLACK LEVELS ===========================================================

class Levels : public PostProcess
{
public:

    static std::shared_ptr<Levels> create( float black = 0.0f, float white = 1.0f )
    {
        return std::make_shared<Levels>( black, white );
    }

    Levels( float black = 0.0f, float white = 1.0f )
        : PostProcess( getFragmentShader() )
    {
    }
    
    void updateUniforms() //override
    {
        mPostProcessShader->uniform( "u_black", mBlackOut );
        mPostProcessShader->uniform( "u_white", mWhiteOut );
        mPostProcessShader->uniform( "u_brightness", mBrightness );
        mPostProcessShader->uniform( "u_contrast", mContrast );
    }
    
    void setLevels( float blackOut, float whiteOut )
    {
        mBlackOut = blackOut;
        mWhiteOut = whiteOut;
    }
    
    void setBrightness( float brightness ) { mBrightness = brightness; }
    void setContrast( float contrast )     { mContrast = contrast; }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
            
            uniform sampler2D tex0;
            uniform float u_black;
            uniform float u_white;
            uniform float u_brightness;
            uniform float u_contrast;
            
            in vec2 TexCoord;
            
            out vec4 FragColor;
            
            vec3 map(vec3 value, vec3 inMin, vec3 inMax, vec3 outMin, vec3 outMax)
            {
                return outMin + (outMax - outMin) * (value - inMin) / (inMax - inMin);
            }
            
            void main()
            {
                vec4 tex = texture( tex0, TexCoord );
                
                vec3 b = vec3( u_black );
                vec3 w = vec3( u_white );
                
                // Levels
                tex.xyz = map( clamp( tex.xyz, b, w), b, w, vec3(0.0), vec3(1.0) );
                
                // Brightness Curve
                tex.xyz = vec3(1.0) - pow( vec3(1.0) - tex.xyz, vec3(u_brightness) );
                
                // Contrast Curve
                tex.xyz = mix( vec3( 0.5 ), tex.xyz, vec3(u_contrast) );
                
                FragColor = tex;
            }
            
        );
    }
    
private:

    float mBlackOut = 0.0;
    float mWhiteOut = 1.0;
    
    float mBrightness = 1.0;
    float mContrast   = 1.0;
    
};


// === VIGNETTE ==============================================================

class Vignette   : public PostProcess
{
public:

    static std::shared_ptr<Vignette> create( float black = 0.0f, float white = 1.0f )
    {
        return std::make_shared<Vignette>( black, white );
    }

    Vignette( float black = 0.0f, float white = 1.0f )
        : PostProcess( getFragmentShader() )
    {
    }
    
    void updateUniforms() 
    {

    }

    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
            
            uniform sampler2D tex0;
            
            in vec2 TexCoord;
            
            out vec4 FragColor;
            
            float lengthSquared( vec2 p )
            {
                return p.x * p.x + p.y * p.y;
            }
            
            void main()
            {
                vec4 tex = texture( tex0, TexCoord );
                
                vec2 p = (TexCoord - 0.5) * 2.0;
                
                tex.xyz -= pow( lengthSquared( p * 0.8 ) - 0.1, 1.8 ) * 0.3;
                
                FragColor = tex;
            }
            
        );
    }
    
private:

    
};

#endif /* StockShaderProcesses_h */
