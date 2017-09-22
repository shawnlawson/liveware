#include "cinder/app/App.h"
#include "cinder/app/cocoa/CinderViewMac.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/Texture.h"
#include "cinder/Text.h"
#include "cinder/Utilities.h"
#include "cinder/Log.h"
#include "cinder/Timeline.h"
#include "cinder/audio/audio.h"
#include "cinder/params/Params.h"

//Blocks
#include "MidiHeaders.h"
#include "cinder/osc/Osc.h"

//User
#include "MyNSTextView.h"
#include "AudioDrawUtils.h"

//#define __OBJC__

#include "sol.hpp"

#include "thing.hpp"
#include "PostProcess.h"
#include "BuiltinPostProcesses.h"

using namespace ci;
using namespace ci::app;
using namespace std;

//OSC UDP
using Receiver = osc::ReceiverUdp;
using protocol = asio::ip::udp;

class CinderProjectBasicApp : public App {
public:
    CinderProjectBasicApp(); //for OSC override
    void setup() override;
    void mouseDown( MouseEvent event ) override;
    void keyDown( KeyEvent event ) override;
    void update() override;
    void draw() override;
    void cleanup() override;
    void swapCode();
    void loadFiles();
    
    //OSC
    void openOSC();
    void stopOSC();
    std::shared_ptr<asio::io_service>		mIoService;
    std::shared_ptr<asio::io_service::work>	mWork;
    std::thread								mThread;
    std::mutex                              mNNMutex;
    Receiver                                mReceiver;
    float                                   nnData[10];
    
    
    //MIDI
    void midiListener( midi::Message msg );
    void openMidi();
    midi::Input mInput;
    cinder::signals::Connection midiConnection;
    vector <int> notes;
    vector <int> cc;
    std::string status;
    
    //audio
    audio::InputDeviceNodeRef		mInputDeviceNode;
    audio::MonitorSpectralNodeRef	mMonitorSpectralNode,
                                    mMonitorSpectralNodeRight;
    vector<float>					mMagSpectrum,
                                    mMagSpectrumRight;
    vec4                            mBands,
                                    mBandsR;
    
    SpectrumPlot					mSpectrumPlot;
    gl::TextureFontRef				mTextureFont;
    Font                            mFont;
    
    //graphics
    void renderToFBO();
    gl::FboRef fbos[4];
    gl::GlslProgRef fboGlsl, trialGlsl;
    std::string vertProg, fragProg;
    
    int	FBO_WIDTH = 1280, FBO_HEIGHT = 720;
    int pingPong = 0;
    int postPingPong = 0;
    gl::TextureRef audioMidiTex;
    Surface8u audioSuface;

    //editor
    void shaderListener( std::string code);
    void luaListener( std::string code);
    NSView * theView;
    bool loadedShader = false;
    CinderViewMac *cvm;
    MyNSTextView *tv;
    NSScrollView *sv;
    
    //lua files
    std::string bach1, bach2;
    sol::state lua;
    vector<thing> things;
    vector<PostProcess> postProcesses;
    
    //GUI
    params::InterfaceGlRef	mParams;
    vector<string>			mEnumNames;
    int						mEnumSelection;
    vector<string>          midiNames;
    int                     midiSelection;
    vector<string>          oscNames;
    int                     oscSelection;


    //time
    double lastFrameTime;
};

//contructor so that we have OSC
CinderProjectBasicApp::CinderProjectBasicApp()
    : mIoService( new asio::io_service ),
    mWork( new asio::io_service::work( *mIoService ) ),
    mReceiver( 10001, protocol::v4(), *mIoService )
{}

void CinderProjectBasicApp::setup()
{
    /////////////////////////////////////////////
    //  App defaults
    /////////////////////////////////////////////
    gl::enableVerticalSync();
    setWindowSize(1280, 720);
    NSArray *tl;
    [[NSBundle mainBundle] loadNibNamed:@"MyMainMenu"
                                  owner:[NSApplication sharedApplication]
                        topLevelObjects:&tl];
    lastFrameTime = ci::app::getElapsedSeconds();
    
    /////////////////////////////////////////////
    //  OpenGL
    /////////////////////////////////////////////
    auto format = gl::Fbo::Format()
//    .samples( 4 ) // uncomment this to enable 4x antialiasing
    .attachment( GL_COLOR_ATTACHMENT0, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
//    .attachment( GL_COLOR_ATTACHMENT1, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
    fbos[0] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[1] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[2] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[3] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    
    loadFiles();
    
    audioSuface = Surface8u(1024, 1, false);
    audioMidiTex = gl::Texture::create(audioSuface);
    audioMidiTex->setMinFilter(GL_LINEAR);
    audioMidiTex->setMagFilter(GL_LINEAR);
    mFont = Font( "Fira Code", 12 );
    mTextureFont = gl::TextureFont::create( mFont );

    /////////////////////////////////////////////
    //  MIDI INIT
    /////////////////////////////////////////////
    mInput.listPorts();

    if( mInput.getNumPorts() > 0 )
    {
        for( int i = 0; i < mInput.getNumPorts(); i++ ) {
            //push into GUI enum
            midiNames.push_back(mInput.getPortName(i));
        }
    }
    
    midiNames.push_back("none");
    
    for( int i = 0; i < 127; i++ )
    {
        notes.push_back( 0 );
        cc.push_back( 0 );
    }
    
    
    /////////////////////////////////////////////
    //  Audio, check duplicate device INIT
    /////////////////////////////////////////////
    //TODO:: force Mono at start
    auto ctx = audio::Context::master();
    mInputDeviceNode = ctx->createInputDeviceNode();
    if (mInputDeviceNode->getNumChannels() > 1)
    { //stereo
        auto channelRouterLeft = ctx->makeNode(new audio::ChannelRouterNode(audio::Node::Format().channels(1)));
        auto channelRouterRight = ctx->makeNode(new audio::ChannelRouterNode(audio::Node::Format().channels(1)));
        auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
        mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
        mMonitorSpectralNodeRight = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
        mInputDeviceNode >> channelRouterLeft->route(0, 0) >> mMonitorSpectralNode;
        mInputDeviceNode >> channelRouterRight->route(1, 0) >> mMonitorSpectralNodeRight;
    } else { //mono
        auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
        mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
        mInputDeviceNode >> mMonitorSpectralNode;
    }
    mInputDeviceNode->enable();
    ctx->enable();
    mSpectrumPlot.enableBorder(false);

    
    /////////////////////////////////////////////
    //  GUI INIT
    /////////////////////////////////////////////
    mParams = params::InterfaceGl::create( getWindow(), "App parameters", toPixels( ivec2( 200, 400 ) ) );
    mParams->setPosition(ivec2(800, 10));
    mEnumSelection = 0;
    mEnumNames = { "new GLSL", "new Lua", "Bach 1", "Bach 2", "Bach3 ", "Bach 4", "Accordion", "Mashup", "Improv" };
    mParams->addParam( "Code", mEnumNames, &mEnumSelection )
    //    .keyDecr( "[" )
    //    .keyIncr( "]" )
//    .updateFn( [this] { console() << "enum updated: " << mEnumNames[mEnumSelection] << endl; } );
    .updateFn( [&](){ swapCode(); } );
    
    mParams->addSeparator();
    midiSelection = midiNames.size() - 1;
    mParams->addParam( "MIDI In", midiNames, &midiSelection )
    .updateFn( [&](){ openMidi(); } );
    
    oscNames = {"UDP port 10001", "none"};
    oscSelection = oscNames.size() -1;
    mParams->addSeparator();
    mParams->addParam( "OSC In", oscNames, &oscSelection)
    .updateFn( [&](){ openOSC(); } );
    
    
    /////////////////////////////////////////////
    //  Text View INIT
    /////////////////////////////////////////////
    NSUInteger index = [tl indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[NSScrollView class]];
    }];
    sv = tl[index];
    tv = (MyNSTextView*)[sv documentView];
    [tv assignCode:fragProg withLanguage:"GLSL"];
    
    //callback from webview when shader code changes
    tv.ShaderSignal->connect([this](std::string code) { shaderListener( code ); });
    tv.LuaSignal->connect([this](std::string code) { luaListener( code ); });
    
    //attaching to cinder view, attaching to window view doesn't work
     cvm =  (__bridge CinderViewMac *)getWindow()->getNative();
    [cvm addSubview:sv];
}



void CinderProjectBasicApp::update()
{
    {
//        mThread.joinable()//check for OSC connected
//        std::lock_guard<std::mutex> lock( mNNMutex );
//        for (int i = 0; i < 10; ++i) {
//            std::cout << nnData[i] << " ";
//        }
//        std::cout << std::endl;
    }
    
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
    if (mInputDeviceNode->getNumChannels() > 1)
        mMagSpectrumRight = mMonitorSpectralNodeRight->getMagSpectrum();
   
    pingPong = (pingPong+1)%2;
    
    for (int i=0; i< 1024; ++i) {
        GLubyte m = 0;
        if (i < 128) { //
            m = notes[i] * 2;
        } else if (i < 256) {
            m = cc[i-128] * 2;
        }
        
        float b2 = 0, b = audio::linearToDecibel( mMagSpectrum[i] );
        
        if (i < 256) mBands.x += b;
        else if (i < 512) mBands.y += b;
        else if (i < 768) mBands.z += b;
        else mBands.w += b;
        
        if (mInputDeviceNode->getNumChannels() > 1) {
            b2 = audio::linearToDecibel( mMagSpectrumRight[i] );
            if (i < 256) mBandsR.x += b2;
            else if (i < 512) mBandsR.y += b2;
            else if (i < 768) mBandsR.z += b2;
            else mBandsR.w += b2;
        }
        
        audioSuface.setPixel(ivec2(i, 0),
                             Color8u(b * 2.55, //scale up to texture depth
                                     b2 * 2.55,
                                     m));
    }
    
    audioMidiTex->update(audioSuface);
    
    
    mBands /= vec4(25600.0); //average across bands and scale down
    if (mInputDeviceNode->getNumChannels() > 1)
        mBandsR /= vec4(25600.0);
    
    //TODO:: if lua?
    float currentTime = cinder::app::getElapsedSeconds();
    float deltaTime = currentTime - lastFrameTime;
    lastFrameTime = currentTime;
    lua["deltaTime"] = deltaTime;
    lua["currentTime"] = currentTime;
    
    sol::function luaUpdate = lua["update"];
    luaUpdate();
    
//    int numEffects = postProcesses.size();
//    for (int i = 0; i < numEffects; ++i) {
//            postProcesses[i].updateUniforms();
//    }
//    
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
    if (mInputDeviceNode->getNumChannels() > 1)
        fboGlsl->uniform("bandsR", mBandsR);
    
    int numEffects = postProcesses.size();
    for (int i = 0; i < numEffects; ++i)
    {
        postProcesses[i].updateUniforms();
    }
    
    gl::drawSolidRect(Rectf(vec2(0), fbos[pingPong]->getSize()));
}

void CinderProjectBasicApp::draw()
{
    gl::clear( Color( 0, 0, 0 ) );
    
    //TODO:: if lua?
    for (int i = 0; i < things.size(); i++){
        things[i].draw();
    }
    
    int numEffects = postProcesses.size();
    
    if (numEffects > 0)
    {
        postPingPong = 2;
        
        for (int i = 0; i < numEffects; ++i)
        {
            if(i == 0) {
                auto tex0 = fbos[pingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
                postProcesses[i].draw(tex0, fbos[postPingPong]);
            }else {
                auto tex0 = fbos[postPingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
                postProcesses[i].draw(tex0, fbos[(postPingPong + 1) % 2 + 2]);
                postPingPong = (postPingPong + 1) % 2 + 2;
            }
        }
        
        auto lastPass = fbos[postPingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
        gl::draw( lastPass, lastPass->getBounds(), Rectf(0, 0, getWindowWidth(), getWindowHeight()) );
    }
    else {
        auto tex0 = fbos[pingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
        gl::draw( tex0, tex0->getBounds(), Rectf(0, 0, getWindowWidth(), getWindowHeight()) );
    }

    
    
//   gl::draw(audioMidiTex, Rectf( 0, 0, 1024, 100 ));
    
    mSpectrumPlot.setBounds( Rectf( 110, getWindowHeight()-60, 210, getWindowHeight() - 10 ) );
    mSpectrumPlot.draw( mMagSpectrum );
    gl::color( Color::white() );
    mTextureFont->drawString( toString( floor(getAverageFps()) ), vec2( 60, getWindowHeight() - mTextureFont->getDescent()-10 ) );

    
    // Draw the interface
    mParams->draw();
}

void CinderProjectBasicApp::luaListener( std::string code)
{
    auto simple_handler = [](lua_State*, sol::protected_function_result result) {
        // You can just pass it through to let the call-site handle it
        return result;
    };
    auto result = lua.script(code, simple_handler);
    if (!result.valid()) {
        sol::error err = result;
        std::cout << "Error:" << err.what() << std::endl;
    }
    //TODO:: HANDLE THESE ERRORS!!
}

void CinderProjectBasicApp::shaderListener( std::string code)
{
    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( vertProg )
        .fragment( code );

        trialGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        [tv errorLineHighlight:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
        return;
    }
    catch( ci::Exception &exc )
    {
        [tv errorLineHighlight:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
        return;
    }
    
    [tv errorLineHighlight:""];
    fboGlsl = trialGlsl;
}

void CinderProjectBasicApp::mouseDown( MouseEvent event )
{
    
}

void CinderProjectBasicApp::keyDown( KeyEvent event )
{
    
}


/////////////////////////////////////////////
//  Code Loading
/////////////////////////////////////////////
void CinderProjectBasicApp::swapCode()
{
    switch (mEnumSelection) {
        case 0: // new GLSL
            [tv assignCode:fragProg withLanguage:"GLSL"];
            break;
        case 1: // new Lua
            [tv assignCode:"\n\n" withLanguage:"LUA"];
            break;
        
        case 2: // Bach 1
        {
            std::string s = loadString(loadAsset("file.lua"));
            auto simple_handler = [](lua_State*, sol::protected_function_result result) {
                // You can just pass it through to let the call-site handle it
                return result;
            };
            auto result = lua.script(s, simple_handler);
            if (!result.valid()) {
                sol::error err = result;
                std::cout << "Error:" << err.what() << std::endl;
            }
            [tv assignCode:s withLanguage:"LUA"];
        }
            break;
        
        case 3: // new GLSL
            break;
            
        default:
            break;
    }
}


//some big batch loading system function here
void CinderProjectBasicApp::loadFiles()
{
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
    
    lua.open_libraries(sol::lib::base);
    // you can open all libraries by passing no arguments
    //lua.open_libraries();

    lua.new_usertype<thing>("thing",
                            "x", &thing::x,
                            "y", &thing::y,
                            "z", &thing::z,
                            "kids", &thing::kids,
                            "print", &thing::print,
                            "draw", &thing::draw,
                            "update", &thing::update,
                            "it", [](thing& t) {
                                return sol::as_container(t); //act like container
                            });
    
    lua.new_usertype<Greyscale>("Greyscale",
                                "amount", &Greyscale::amount,
                                "listUniforms", &Greyscale::listUniforms
//                            "draw", &Greyscale::draw,
//                            "update", &Greyscale::update,
//                            sol::base_classes, sol::bases<PostProcess>()
                            );

    
    lua["scene"] = &things;
    lua["post"] = &postProcesses;
    
    // call lua code directly
    lua.script("print('hello world')");
    lua.safe_script("function update() end");

    
    //for post-process shaders...
    // Shortcut for shader loading and error handling
//    auto loadGlslProg = [ & ]( const gl::GlslProg::Format& format ) -> gl::GlslProgRef
//    {
//        string names = format.getVertexPath().string() + " + " +
//        format.getFragmentPath().string();
//        gl::GlslProgRef glslProg;
//        try {
//            glslProg = gl::GlslProg::create( format );
//        } catch ( const Exception& ex ) {
//            CI_LOG_EXCEPTION( names, ex );
//            quit();
//        }
//        return glslProg;
//    };
//    gl::VboMeshRef rect			= gl::VboMesh::create( geom::Rect() );
//    ci::gl::BatchRef			mBatchBloomBlurRect;
//    int32_t version					= 330;
//    DataSourceRef fragBloomBlur				= loadAsset( "bloom/blur.frag" );
//    DataSourceRef vertPassThrough			= loadAsset( "pass_through.vert" );
//    gl::GlslProgRef bloomBlur		= loadGlslProg( gl::GlslProg::Format().version( version )
//                                                   .vertex( vertPassThrough ).fragment( fragBloomBlur )
//                                                   
//    mBatchBloomBlurRect				= gl::Batch::create( rect,		bloomBlur );
    
}

/////////////////////////////////////////////
//  MIDI
/////////////////////////////////////////////

void CinderProjectBasicApp::openMidi()
{
    if (midiConnection.isConnected())
    {
        mInput.closePort();
        midiConnection.disconnect();
    }
    
    if (midiSelection < midiNames.size() -1)
    {
        mInput.openPort(midiSelection);
        midiConnection = mInput.midiSignal.connect( [this](midi::Message msg){ midiListener( msg ); });
    }
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
//  OSC
/////////////////////////////////////////////

void CinderProjectBasicApp::openOSC()
{
    stopOSC();
    
    if(oscSelection == 1) //none
        return;
    
    mReceiver.setListener("liveware/nn/",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              for (int i = 0; i < 10; ++i) {
                                  nnData[i] = msg[i].flt();
                              }
//                              NSLog(@"data");
                          });

    try {
        mReceiver.bind();
        
        mReceiver.listen([]( asio::error_code error, protocol::endpoint endpoint ) -> bool {
                             if( error ) {
                                 CI_LOG_E( "Error Listening: " << error.message() << " val: "
                                          << error.value() << " endpoint: " << endpoint );
                                 return false;
                             }
                             else
                                 return true;
                         });
        
        mThread = std::thread( std::bind([]( std::shared_ptr<asio::io_service> &service ){
                                             service->run();
                                         }, mIoService ));
    }
    catch( const osc::Exception &ex ) {
        CI_LOG_E( "Error binding: " << ex.what() << " val: " << ex.value() );
      //  quit();
    }
}

void CinderProjectBasicApp::stopOSC()
{
     if (mThread.joinable() ){
        mWork.reset();
        mIoService->stop();
        mThread.join();
        mReceiver.removeListener("/mousemove/1");
        mReceiver.close();
     }
}

void CinderProjectBasicApp::cleanup()
{
    stopOSC();
}

CINDER_APP( CinderProjectBasicApp, RendererGl )
