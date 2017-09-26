

#ifndef BuiltinPostProcesses_h
#define BuiltinPostProcesses_h

#include "PostProcess.h"


// === MIRROR =================================================================

class mirror  : public PostProcess
{
public:
    mirror()
    : PostProcess( getFragmentShader() ) {}
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
        
            uniform sampler2D tex0;
            in vec2 TexCoord;
            out vec4 FragColor;
            
            void main()
            {
                vec2 p = TexCoord;
                //set for both horizontal and veritcal and which direction
                FragColor = texture( tex0, vec2( 0.5 - abs( (p.x - 0.5) ), p.y ) );
            }
        
        );
    }
    
    virtual std::string listUniforms() override
    {
        return "none";
    }
};


// === INVERT =================================================================

class invert  : public PostProcess
{
public:
    invert() : PostProcess( getFragmentShader() ) {}
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
        
            uniform sampler2D tex0;
            in vec2 TexCoord;
            out vec4 FragColor;
            
            void main()
            {
                vec2 p = TexCoord;
                vec4 col = texture( tex0, p );
                col.xyz = vec3( 1.0 ) - col.xyz;
                FragColor = vec4(col.rgb, 1.0);
            }
        
        );
    }
    
    virtual std::string listUniforms() override
    {
        return "none";
    }
};


// === GREYSCALE ==============================================================

class greyscale  : public PostProcess
{
public:
    greyscale( float newAmount = 1.0f )
    : PostProcess( getFragmentShader() )
    {
        amount = newAmount;
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
                
                float gray = dot( tex.rgb, vec3( 0.299, 0.587, 0.114 ) );

                FragColor = vec4( mix(tex.rgb, vec3(gray), amount), 1.0 );
            }
        
                        );
    }

    virtual void updateUniforms() override
    {
        mPostProcessShader->uniform( "amount", amount );
    }

    virtual std::string listUniforms() override
    {
        return "float amount 1.";
    }
    
    float amount;
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

class vignette   : public PostProcess
{
public:

    vignette( float newAmount = .3f )
    : PostProcess( getFragmentShader() )
    {
        amount = newAmount;
    }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
            
            uniform sampler2D tex0;
           uniform float amount;
            in vec2 TexCoord;
            out vec4 FragColor;
            
            
            void main()
            {
                vec4 tex = texture( tex0, TexCoord );
                
                vec2 p = (TexCoord - 0.5) * 2.0;
                
                tex.xyz *= 1.0 - pow( length(p), 3.5 ) * amount;
                
                FragColor = tex;
            }
            
        );
    }
    
    virtual void updateUniforms() override
    {
        mPostProcessShader->uniform( "amount", amount );
    }
    
    virtual std::string listUniforms() override
    {
        return "float amount .3";
    }

    float amount;
};


// === ABERRATION ==============================================================

class aberration    : public PostProcess
{
public:
    
    aberration( float newAmount = 0.003f )
    : PostProcess( getFragmentShader() )
    {
        amount = newAmount;
    }
      
      static const std::string getFragmentShader()
      {
          return CI_GLSL( 400,
                         
             uniform sampler2D tex0;
             uniform float amount;
             in vec2 TexCoord;
             out vec4 FragColor;
             
             
             void main()
             {
                 vec4 color;
                 color.r = texture( tex0, vec2(TexCoord.x + amount, TexCoord.y) ).r;
                 color.g = texture( tex0, TexCoord ).g;
                 color.b = texture( tex0, vec2(TexCoord.x - amount, TexCoord.y) ).b;
                 color.a = 1.0;
                 
                 FragColor = color;
             }
             
             );
      }
      
      virtual void updateUniforms() override
      {
          mPostProcessShader->uniform( "amount", amount );
      }
      
      virtual std::string listUniforms() override
      {
          return "float amount .003";
      }
      
      float amount;

};


// === SCANLINE ==============================================================

class scanline    : public PostProcess
{
public:
    
    scanline( float newAmount = 300.0f, float newSpeed = 10.0f )
    : PostProcess( getFragmentShader() )
    {
        amount = newAmount;
        speed = newSpeed;
    }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
                       
                       uniform sampler2D tex0;
                       uniform float amount;
                       uniform float speed;
                       uniform float time;
                       in vec2 TexCoord;
                       out vec4 FragColor;
                       
                       
                       void main()
                       {
                           vec4 color = texture( tex0, TexCoord );
                           color.rgb *= 0.9 + 0.1 * sin( speed * time + TexCoord.y * amount);
                           
                           FragColor = color;
                       }
                       
                       );
    }
    
    virtual void updateUniforms() override
    {
        float time = ci::app::getElapsedSeconds();
        mPostProcessShader->uniform( "amount", amount );
        mPostProcessShader->uniform( "speed", speed );
        mPostProcessShader->uniform( "time", time);
    }
    
    virtual std::string listUniforms() override
    {
        return "float amount 300. \n float speed 10.";
    }
    
    float amount;
    float speed;
    
};


// === BLUR ==============================================================
//TODO:: work on this.
class blur    : public PostProcess
{
public:
    
    blur( float newWidth = 1.0f, float newHeight = 1.0f )
    : PostProcess( getFragmentShader() )
    {
        width = newWidth;
        height = newHeight;
    }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
                       
                       uniform sampler2D tex0;
                       uniform vec2 amount;
                       uniform vec2 bufferResolution;
                       
                       in vec2 TexCoord;
                       out vec4 FragColor;
                       
                       void main()
                       {
                           vec4 sampleM  = texture(tex0, TexCoord);
                           vec4 sampleB0 = texture(tex0, TexCoord - amount/bufferResolution);
                           vec4 sampleF0 = texture(tex0, TexCoord + amount/bufferResolution);
                           vec4 sampleB1 = texture(tex0, TexCoord - amount/bufferResolution * 2.);
                           vec4 sampleF1 = texture(tex0, TexCoord + amount/bufferResolution * 2.);
                           vec4 sampleB2 = texture(tex0, TexCoord - amount/bufferResolution * 3.);
                           vec4 sampleF2 = texture(tex0, TexCoord + amount/bufferResolution * 3.);
                           
                           vec4 color =	0.1752 * sampleM +
                                       0.1658 * (sampleB0 + sampleF0) +
                                       0.1403 * (sampleB1 + sampleF1) + 
                                       0.1063 * (sampleB2 + sampleF2);
                           
                           FragColor = vec4(color.rgb, 1.0);
                       }
                       
                       );
    }
    
    virtual void updateUniforms() override
    {
        mPostProcessShader->uniform( "bufferResolution", ci::vec2(bufferWidth, bufferHeight) );
        mPostProcessShader->uniform( "amount", ci::vec2(width, height) );
        
    }
    
    virtual std::string listUniforms() override
    {
        return "float width 1. \n float height 1.";
    }
    
    float width;
    float height;
};



#endif /* StockShaderProcesses_h */
