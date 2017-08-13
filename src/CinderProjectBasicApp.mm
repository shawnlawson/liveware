#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/Utilities.h"
#include "cinder/Log.h"
#include "cinder/Timeline.h"
#include "cinder/audio/audio.h"

//Blocks
#include "cinder/osc/Osc.h"
#include "MidiHeaders.h"

//User
#import "MyWebViewController.h"
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
    void midiThreadListener( midi::Message msg );
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

//OSC needs this
CinderProjectBasicApp::CinderProjectBasicApp()
: mReceiver( localPort )
{
}

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

/////////////////MIDI
    mInput.listPorts();
    console() << "NUMBER OF PORTS: " << mInput.getNumPorts() << endl;
    
    if( mInput.getNumPorts() > 0 )
    {
        for( int i = 0; i < mInput.getNumPorts(); i++ )
            console() << mInput.getPortName(i) << endl;
        
        mInput.openPort(0);
        
        // Connect midi signal to our callback function
        // This connects to our main thread
        mInput.midiSignal.connect( [this](midi::Message msg){ midiListener( msg ); });
        
        // Optionally, this connects directly to the midi thread
        mInput.midiThreadSignal.connect( [this](midi::Message msg){ midiThreadListener( msg ); });
    }
    
    for( int i = 0; i < 127; i++ )
    {
        notes.push_back( 0 );
        cc.push_back( 0 );
    }

    
/////////////////Audio
    //there's some bullshit in core audio with devices that have the same name. my m-audio device for input apparently lists twice. gotta figure out this bug
    auto ctx = audio::Context::master();
    
    // The InputDeviceNode is platform-specific, so you create it using a special method on the Context:
    mInputDeviceNode = ctx->createInputDeviceNode();
    
    auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
    mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
    
    mInputDeviceNode >> mMonitorSpectralNode;
    
    // InputDeviceNode (and all InputNode subclasses) need to be enabled()'s to process audio. So does the Context:
    mInputDeviceNode->enable();
    ctx->enable();
    
/////////////////OSC
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
    // UDP opens the socket and "listens" accepting any message from any endpoint. The listen
    // function takes an error handler for the underlying socket. Any errors that would
    // call this function are because of problems with the socket or with the remote message.
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
    
    mSpectrumPlot.setBounds( Rectf( 10, getWindowHeight()-60, 100, getWindowHeight() - 10 ) );
    mSpectrumPlot.draw( mMagSpectrum );

}

void CinderProjectBasicApp::midiThreadListener( midi::Message msg )
{
    // This will be called from a background midi thread
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

CINDER_APP( CinderProjectBasicApp, RendererGl )
