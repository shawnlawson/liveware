#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/Texture.h"
#include "cinder/Text.h"
#include "cinder/Utilities.h"
#include "cinder/Log.h"
#include "cinder/Timeline.h"
#include "cinder/audio/audio.h"

//Blocks
#include "cinder/osc/Osc.h"
#include "MidiHeaders.h"

//User
#import "MyWebView.h"
#include "AudioDrawUtils.h"


using namespace ci;
using namespace ci::app;
using namespace std;

//UDP only, see example if TCP required
const uint16_t localPort = 10001;

class CinderProjectBasicApp : public App {
public:
    CinderProjectBasicApp(); //OSC needs this
    void setup() override;
    void mouseDown( MouseEvent event ) override;
    void keyDown( KeyEvent event ) override;
    void update() override;
    void draw() override;
    
    //MIDI
    void midiListener( midi::Message msg );
    midi::Input mInput;
    vector <int> notes;
    vector <int> cc;
    std::string status;
    
    //OSC - can be multithreaded if needed
    ivec2	mCurrentCirclePos; //from example, could be anything
    osc::ReceiverUdp mReceiver;
    std::map<uint64_t, asio::ip::udp::endpoint> mConnections;
    
    //audio
    audio::InputDeviceNodeRef		mInputDeviceNode;
    audio::MonitorSpectralNodeRef	mMonitorSpectralNode;
    vector<float>					mMagSpectrum;
    vec4                            mBands;
    
    SpectrumPlot					mSpectrumPlot;
    gl::TextureFontRef				mTextureFont;
    Font                            mFont;
    
    //graphics
    void renderToFBO();
    gl::FboRef fbos[2];
    gl::GlslProgRef fboGlsl, trialGlsl;
    std::string vertProg, fragProg;
    
    int	FBO_WIDTH = 1280, FBO_HEIGHT = 720;
    int pingPong = 0;
    gl::TextureRef audioMidiTex;
    Surface8u audioSuface;

    //editor
    void shaderListener( std::string code);
    MyWebView *wv;
    NSView * theView;
    bool loadedShader = false;
    
    
};

void CinderProjectBasicApp::setup()
{
    /////////////////////////////////////////////
    //  App defaults
    /////////////////////////////////////////////
    gl::enableVerticalSync();
    setWindowSize(1280, 720);
    NSArray *tl;
    [[NSBundle mainBundle] loadNibNamed:@"MainMenuTest"
                                  owner:[NSApplication sharedApplication]
                        topLevelObjects:&tl];
    
    /////////////////////////////////////////////
    //  OpenGL
    /////////////////////////////////////////////
    auto format = gl::Fbo::Format()
//    .samples( 4 ) // uncomment this to enable 4x antialiasing
    .attachment( GL_COLOR_ATTACHMENT0, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
//    .attachment( GL_COLOR_ATTACHMENT1, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
    fbos[0] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[1] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    vertProg = loadString( loadAsset("render.vert"));
    fragProg = loadString( loadAsset("render.frag"));
    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( vertProg )
        .fragment( fragProg );
        
        fboGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    catch( ci::Exception &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    
    audioSuface = Surface8u(1024, 1, false);
    audioMidiTex = gl::Texture::create(audioSuface);
    audioMidiTex->setMinFilter(GL_LINEAR);
    audioMidiTex->setMagFilter(GL_LINEAR);
    mFont = Font( "Fira Code", 12 );
    mTextureFont = gl::TextureFont::create( mFont );

    
    /////////////////////////////////////////////
    //  Web View
    /////////////////////////////////////////////
    wv = [MyWebView alloc];
    [wv setupWithPath:[NSString stringWithUTF8String:
                       getAssetPath("ACE/index.html").c_str()]];
    [wv setStartCode:fragProg];
    
    //attaching to cinder view, attaching to window view doesn't work
    theView = [[NSApp mainWindow].contentView subviews][0];
    [theView addSubview:wv];
    
    //callback from webview when shader code changes
    wv.ShaderSignal->connect([this](std::string code) { shaderListener( code ); });
    
    
/////////////////MIDI
    mInput.listPorts();
    console() << "NUMBER OF PORTS: " << mInput.getNumPorts() << endl;
    
    if( mInput.getNumPorts() > 0 )
    {
        for( int i = 0; i < mInput.getNumPorts(); i++ )
            console() << mInput.getPortName(i) << endl;
        
        mInput.openPort(0);
        
        mInput.midiSignal.connect( [this](midi::Message msg){ midiListener( msg ); });
    }
    
    for( int i = 0; i < 127; i++ )
    {
        notes.push_back( 0 );
        cc.push_back( 0 );
    }
    
    
    /////////////////////////////////////////////
    //  Audio, check duplicate device
    /////////////////////////////////////////////
    auto ctx = audio::Context::master();
    mInputDeviceNode = ctx->createInputDeviceNode();
    auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
    mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
    mInputDeviceNode >> mMonitorSpectralNode;
    mInputDeviceNode->enable();
    ctx->enable();
    mSpectrumPlot.enableBorder(false);
    
    /////////////////////////////////////////////
    //  Open Sound Control
    /////////////////////////////////////////////
    mReceiver.setListener( "/mousemove/1",
                          [&]( const osc::Message &msg ){
                              mCurrentCirclePos.x = msg[0].int32();
                              mCurrentCirclePos.y = msg[1].int32();
                          });
    try {
        mReceiver.bind();
    }
    catch( const osc::Exception &ex ) {
        CI_LOG_E( "Error binding: " << ex.what() << " val: " << ex.value() );
        quit();
    }
    mReceiver.listen(
             []( asio::error_code error, asio::ip::udp::endpoint endpoint ) -> bool {
                 if( error ) {
                     CI_LOG_E( "Error Listening: " << error.message() << " val: " << error.value() << " endpoint: " << endpoint );
                     return false;
                 }
                 else
                     return true;
             });

}



void CinderProjectBasicApp::update()
{
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
    pingPong = (pingPong+1)%2;
    
    for (int i=0; i< 1024; ++i) {
        GLubyte m = 0;
        if (i < 128) { //
            m = notes[i] * 2;
        } else if (i < 256) {
            m = cc[i-128] * 2;
        }
        
        float b = audio::linearToDecibel( mMagSpectrum[i] );
        audioSuface.setPixel(ivec2(i, 0),
                             Color8u(b *2.55, //scale up to texture depth
                                     0, //unused at the moment
                                     m));
        if (i < 256) mBands.x += b;
        else if (i < 512) mBands.y += b;
        else if (i < 768) mBands.z += b;
        else mBands.w += b;
    }
    audioMidiTex->update(audioSuface);
    mBands /= vec4(25600.0); //average across bands and scale down

    renderToFBO();
}

void CinderProjectBasicApp::renderToFBO()
{
    CameraOrtho cam(0, 1280, 0, 720, -10, 10);
    gl::ScopedViewport scpVp( ivec2( 0 ), fbos[pingPong]->getSize() );
    
    gl::ScopedTextureBind scpFboBind(fbos[(pingPong+1)%2]->getColorTexture(), 0);
    gl::ScopedTextureBind scpAudBind(audioMidiTex, 1);
    
    gl::ScopedFramebuffer  scpFbo( fbos[pingPong] );
    gl::ScopedGlslProg scpShader( fboGlsl );
    
    gl::ScopedMatrices matScope;
    gl::setMatrices( cam );
    
    fboGlsl->uniform("uRenderMap", 0);
    fboGlsl->uniform("uAudioMap", 1);
    fboGlsl->uniform("time", (float)getElapsedSeconds());
    fboGlsl->uniform("bands", mBands);
    
    
    gl::drawSolidRect(Rectf(vec2(0), fbos[pingPong]->getSize()));
}

void CinderProjectBasicApp::draw()
{
    gl::clear( Color( 0, 0, 0 ) );

    auto tex0 = fbos[pingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
    gl::draw( tex0, tex0->getBounds(), Rectf(0, 0, getWindowWidth(), getWindowHeight()) );
    
    gl::draw(audioMidiTex, Rectf( 0, 0, 1024, 100 ));
    
    mSpectrumPlot.setBounds( Rectf( 60, getWindowHeight()-60, 160, getWindowHeight() - 10 ) );
    mSpectrumPlot.draw( mMagSpectrum );
    gl::color( Color::white() );
    mTextureFont->drawString( toString( floor(getAverageFps()) ), vec2( 10, getWindowHeight() - mTextureFont->getDescent()-10 ) );
//this causes things to not render correctly in the spectal fft
//        drawAudioBuffer(mMonitorSpectralNode->getBuffer(),
//                        Rectf( 110, getWindowHeight()-60, 210, getWindowHeight() - 10 ));

    
}

void CinderProjectBasicApp::shaderListener( std::string code) {

//    std::cout << code << std::endl;
//    std::cout << "returned" << std::endl;
    
    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( vertProg )
        .fragment( code );

        trialGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        [wv setErrors:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
        return;
    }
    catch( ci::Exception &exc )
    {
        [wv setErrors:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
        return;
    }
    
    [wv clearErrors];
    fboGlsl = trialGlsl;
    
}

void CinderProjectBasicApp::mouseDown( MouseEvent event )
{
    
}

void CinderProjectBasicApp::keyDown( KeyEvent event )
{
    
}

void CinderProjectBasicApp::midiListener( midi::Message msg )
{
    // This will be called on on the main thread and
    // safe to use with update and draw.
    
    switch( msg.status )
    {
        case MIDI_NOTE_ON:
            notes[msg.pitch] = msg.velocity;
            status = "Pitch: " + toString( msg.pitch ) + "\n" + "Velocity: " + toString( msg.velocity );
            break;
            
        case MIDI_NOTE_OFF:
            notes[msg.pitch] = 0;
            break;
            
        case MIDI_CONTROL_CHANGE:
            cc[msg.control] = msg.value;
            status = "Control: " + toString( msg.control ) + "\n" + "Value: " + toString( msg.value );
            break;
            
        default:
            break;
    }
    
    std::cout<< status << std::endl;
    
}

/////////////////////////////////////////////
//  OSC needs this constructor override
/////////////////////////////////////////////
CinderProjectBasicApp::CinderProjectBasicApp()
: mReceiver( localPort )
{
}
CINDER_APP( CinderProjectBasicApp, RendererGl )
