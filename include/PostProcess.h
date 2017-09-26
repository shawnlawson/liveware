//
//  Layer.h
//  ciProjectBasic
//
//  Created by Shawn Lawson on 9/21/17.
//
//

#ifndef PostProcess_h
#define PostProcess_h

/**
 This abstract class represents a post processing stage that can happen
 on a layer
 */
class PostProcess;
typedef std::shared_ptr<PostProcess> PostProcessRef;

class PostProcess {
    
public:
    ci::gl::GlslProgRef mPostProcessShader;
    float bufferWidth, bufferHeight;
    
    PostProcess(){}
    
    PostProcess( ci::DataSourceRef fragmentShaderSource )
    {
        CI_ASSERT(fragmentShaderSource->isFilePath());
        
        ci::gl::GlslProg::Format fmt;
        fmt.vertex( getThruVertex() ).fragment( fragmentShaderSource );
        createShader( fmt );
    }
    
    PostProcess( const std::string& fragmentShaderString )
    {
        ci::gl::GlslProg::Format fmt;
        fmt.vertex( getThruVertex() ).fragment( fragmentShaderString );
        createShader( fmt );
    }

    void draw(const ci::gl::TextureRef& texture, ci::gl::FboRef& targetFbo){
        CI_ASSERT(texture != nullptr);
        CI_ASSERT(targetFbo != nullptr);
        CI_ASSERT(mPostProcessShader != nullptr);
        
        bufferWidth = targetFbo->getWidth();
        bufferHeight = targetFbo->getHeight();
        
        ci::gl::ScopedFramebuffer   fboScp( targetFbo );
        ci::gl::ScopedViewport      viewScp( targetFbo->getSize() );
        ci::gl::ScopedGlslProg      glScp( mPostProcessShader );
        ci::gl::ScopedTextureBind   texScp( texture );
        ci::gl::ScopedMatrices      matScp;
        ci::gl::setMatricesWindow( targetFbo->getSize() );
//        ci::gl::clearColor(ci::ColorA::black());

        mPostProcessShader->uniform( "tex0", 0 );

        ci::gl::drawSolidRect( ci::Rectf(0, 0, targetFbo->getWidth(), targetFbo->getHeight()) );
    }

    virtual void updateUniforms(){   }
    virtual std::string listUniforms() { return ""; }
    
private:
    
    const std::string getThruVertex()
    {
        return CI_GLSL( 150,
                       
                       uniform mat4 ciModelViewProjection;
                       
                       in vec4 ciPosition;
                       in vec2 ciTexCoord0;
                       
                       out vec2 TexCoord;
                       
                       void main()
                       {
                           TexCoord = ciTexCoord0;
                           gl_Position = ciModelViewProjection * ciPosition;
                       }
                       
                       );
    }
    
    void createShader( const ci::gl::GlslProg::Format& fmt )
    {
        try
        {
            mPostProcessShader = ci::gl::GlslProg::create( fmt );
        }
        catch( const std::exception& e )
        {
            std::cout << "PostProcess shader error: " << e.what() << std::endl;
            CI_ASSERT( false );
        }
    }


};


#endif /* PostProcess_h */
