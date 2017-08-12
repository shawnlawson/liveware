#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/Log.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/audio/audio.h"

#import "MyWebViewController.h"
#import "AudioDrawUtils.h"


using namespace ci;
using namespace ci::app;
using namespace std;



class CinderProjectBasicApp : public App {
  public:
	void setup() override;
	void mouseDown( MouseEvent event ) override;
    void keyDown( KeyEvent event ) override;
	void update() override;
	void draw() override;
    
//audio
    audio::InputDeviceNodeRef		mInputDeviceNode;
    audio::MonitorSpectralNodeRef	mMonitorSpectralNode;
    vector<float>					mMagSpectrum;
    
    SpectrumPlot					mSpectrumPlot;
    gl::TextureFontRef				mTextureFont;
//graphics
    void renderToFBO();
        
    MyWebViewController *wv;
    NSView * theView;
    
    gl::FboRef fbos[2];
    gl::GlslProgRef fboGlsl;
    
    int	FBO_WIDTH = 1280, FBO_HEIGHT = 720;
    int pingPong = 0;

};

void CinderProjectBasicApp::setup()
{
    gl::enableVerticalSync();
    setWindowSize(1280, 720);
    wv = [MyWebViewController alloc];
    [wv setupWithPath:[NSString stringWithUTF8String:
                       getAssetPath("ACE/index.html").c_str()]];
    
    [NSApp.mainWindow.contentView addSubview:wv.webView];

//    theView = [[NSApp mainWindow].contentView subviews][0];
//    [theView addSubview:wv.webView];
    
    gl::Fbo::Format format;
    fbos[0] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[1] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);

    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( loadAsset( "render.vert" ) )
                    .fragment( loadAsset( "render.frag" ) );
        
        fboGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    catch( ci::Exception &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    
    
    //setup Audio
    auto ctx = audio::Context::master();
    
    // The InputDeviceNode is platform-specific, so you create it using a special method on the Context:
    mInputDeviceNode = ctx->createInputDeviceNode();
    
    // By providing an FFT size double that of the window size, we 'zero-pad' the analysis data, which gives
    // an increase in resolution of the resulting spectrum data.
    auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
    mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
    
    mInputDeviceNode >> mMonitorSpectralNode;
    
    // InputDeviceNode (and all InputNode subclasses) need to be enabled()'s to process audio. So does the Context:
    mInputDeviceNode->enable();
    ctx->enable();

}

void CinderProjectBasicApp::mouseDown( MouseEvent event )
{
    
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [wv.webView evaluateJavaScript:@"editor.setValue('good stuff');" completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
}

void CinderProjectBasicApp::keyDown( KeyEvent event )
{

}

void CinderProjectBasicApp::update()
{
//    pingPong = (pingPong+1)%2;
    renderToFBO();
    fboGlsl->uniform("time", (float)getElapsedSeconds());
    
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
}

void CinderProjectBasicApp::renderToFBO() {
    
    gl::ScopedFramebuffer fbScp( fbos[pingPong] );
    // clear out the FBO with blue
    gl::clear( Color( 0.0f, 0.0f, 0.0f ) );
    gl::color( Color::white() );
    gl::ScopedTextureBind(fbos[(pingPong+1)%2]->getColorTexture());
    // setup the viewport to match the dimensions of the FBO
    gl::ScopedViewport scpVp( ivec2( 0 ), fbos[pingPong]->getSize() );
    
    gl::ScopedGlslProg shaderScp( fboGlsl );
    gl::drawSolidRect(Rectf(0,0,1280,720));

    
}

void CinderProjectBasicApp::draw()
{
//	gl::clear( Color( 0, 0, 0 ) );
    
    gl::color( Color::white() );
    // use the scene we rendered into the FBO as a texture
    fbos[pingPong]->bindTexture();
    gl::draw(fbos[pingPong]->getColorTexture(),
             Rectf(0, 0, getWindowWidth(), getWindowHeight()));
    
    mSpectrumPlot.setBounds( Rectf( 20, getWindowHeight(), 100, 100 ) );
    mSpectrumPlot.draw( mMagSpectrum );

}

CINDER_APP( CinderProjectBasicApp, RendererGl )
