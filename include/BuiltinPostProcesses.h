

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
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'nada')");
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
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'nada')");
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

    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'amount = 1.0')");
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
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'amount = 0.3')");
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
      
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'amount = 0.003')");
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
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'amount = 300.0 \t speed = 10.0')");
    }
    
    float amount;
    float speed;
    
};


// === BLUR ==============================================================
//TODO:: work on this.
class edges    : public PostProcess
{
public:
    
    edges()
    : PostProcess( getFragmentShader() )
    {
    }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
                       
                       uniform sampler2D tex0;
                       
                       in vec2 TexCoord;
                       out vec4 FragColor;
                       
                       
                       float getIntensity(vec2 u){
                           vec3 a = texture(tex0,u).xyz;
                           return (a.x+a.y+a.z)/3.0;
                       }
                       
                       void main(){
                           vec2 uv = gl_FragCoord.xy;
                           vec2 p = vec2(1.0);
                           
                           float avg = 0.0;
                           avg += getIntensity(TexCoord+vec2(p.x,0.0));
                           avg += getIntensity(TexCoord+vec2(-p.x,0.0));
                           avg += getIntensity(TexCoord+vec2(0.0,p.y));
                           avg += getIntensity(TexCoord+vec2(0.0,-p.y));
                           avg += getIntensity(TexCoord+vec2(p.x,p.y));
                           avg += getIntensity(TexCoord+vec2(-p.x,-p.y));
                           avg += getIntensity(TexCoord+vec2(p.x,-p.y));
                           avg += getIntensity(TexCoord+vec2(-p.x,p.y));
                           avg /= 8.0;
                           
                           float result = (1.0-getIntensity(TexCoord)) + avg;
                           result = (1.0 - result) * 10.0;
                           
                           FragColor = vec4(vec3(result),1.0);
                       }
                       
                       
                       );
    }
    
    virtual void updateUniforms() override
    {
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'nada");
    }
    
};

// === BLUR ==============================================================
//TODO:: work on this.
class blur    : public PostProcess
{
public:
    
    blur( float mAmount = 1.0f )
    : PostProcess( getFragmentShader() )
    {
        amount = mAmount;
    }
    
    static const std::string getFragmentShader()
    {
        return CI_GLSL( 400,
                       
                       uniform sampler2D tex0;
                       uniform float amount;
                       uniform vec2 bufferResolution;
                       
                       in vec2 TexCoord;
                       out vec4 FragColor;
                       
                       
                       float normpdf(in float x, in float sigma)
                        {
                            return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
                        }
                       
                       void main()
                       {
                           vec3 c = texture(tex0, gl_FragCoord.xy/bufferResolution).rgb;
                           
                           //declare stuff
                           const int mSize = 11;
                           const int kSize = (mSize-1)/2;
                           float kernel[mSize];
                           vec3 final_colour = vec3(0.0);
                           
                           //create the 1-D kernel
                           float sigma = 7.0;
                           float Z = 0.0;
                           for (int j = 0; j <= kSize; ++j)
                           {
                               kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
                           }
                           
                           //get the normalization factor (as the gaussian has been clamped)
                           for (int j = 0; j < mSize; ++j)
                           {
                               Z += kernel[j];
                           }
                           
                           //read out the texels
                           for (int i=-kSize; i <= kSize; ++i)
                           {
                               for (int j=-kSize; j <= kSize; ++j)
                               {
                                   final_colour += kernel[kSize+j] *
                                                   kernel[kSize+i] *
                                        texture(tex0, (gl_FragCoord.xy+vec2(float(i),float(j)))/bufferResolution  * amount).rgb;
                                   
                               }
                           }
                           
                           
                           FragColor = vec4(final_colour/(Z*Z), 1.0);
                       
                       }
                       
                       );
    }
    
    virtual void updateUniforms() override
    {
        mPostProcessShader->uniform( "bufferResolution", ci::vec2(bufferWidth, bufferHeight) );
        mPostProcessShader->uniform( "amount", amount);
        
    }
    
    virtual void print(sol::this_state ts) override
    {
        lua_State* L = ts;
        sol::state_view lua(L);
        lua.safe_script("prnt(obj, 'amount = 1.0')");
    }

    float amount;
};


#endif /* StockShaderProcesses_h */
