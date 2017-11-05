//
//  ShadowMap.hpp
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 11/5/17.
//
//

#ifndef ShadowMap_h
#define ShadowMap_h

typedef std::shared_ptr<class ShadowMap> ShadowMapRef;

class ShadowMap {
public:
    static ShadowMapRef create( int size ) { return ShadowMapRef( new ShadowMap{ size } ); }
    ShadowMap( int size )
    {
        reset( size );
    }
    
    void reset( int size )
    {
        ci::gl::Texture2d::Format depthFormat;
        depthFormat.setInternalFormat( GL_DEPTH_COMPONENT32F );
        depthFormat.setMagFilter( GL_LINEAR );
        depthFormat.setMinFilter( GL_LINEAR );
        depthFormat.setWrap( GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE );
        depthFormat.setCompareMode( GL_COMPARE_REF_TO_TEXTURE );
        depthFormat.setCompareFunc( GL_LEQUAL );
        mTextureShadowMap = ci::gl::Texture2d::create( size, size, depthFormat );
        
        ci::gl::Fbo::Format fboFormat;
        fboFormat.attachment( GL_DEPTH_ATTACHMENT, mTextureShadowMap );
        mShadowMap = ci::gl::Fbo::create( size, size, fboFormat );
    }
    
    const ci::gl::FboRef&		getFbo() const { return mShadowMap; }
    const ci::gl::Texture2dRef&	getTexture() const { return mTextureShadowMap; }
    
    float					getAspectRatio() const { return mShadowMap->getAspectRatio(); }
    ci::ivec2					getSize() const { return mShadowMap->getSize(); }
private:
    ci::gl::FboRef				mShadowMap;
    ci::gl::Texture2dRef		mTextureShadowMap;
};

#endif /* ShadowMap_h */
