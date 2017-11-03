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
#include "cinder/CinderMath.h"
#include "cinder/Perlin.h"
#include "cinder/Easing.h"


//Blocks
#include "MidiHeaders.h"
#include "cinder/osc/Osc.h"

//User
#include "MyNSTextView.h"
#include "FeedbackNSTextView.h"
#include "AudioDrawUtils.h"

#define __OBJC__

#define SOL_CHECK_ARGUMENTS
#include "sol.hpp"

#include "PostProcess.h"
#include "BuiltinPostProcesses.h"
#include "Drawable.hpp"
#include "mCircle.hpp"
#include "mRectangle.hpp"
#include "mImage.hpp"
#include "mLine.hpp"
#include "mRand.hpp"
#include "mCube.hpp"
#include "mSphere.hpp"

#include "LuaBindings.hpp"
#include "LuaBindings_2.h"

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
    
/// OSC //////////////////////////////////////////////////
    void openOSC();
    void stopOSC();
    std::shared_ptr<asio::io_service>		mIoService;
    std::shared_ptr<asio::io_service::work>	mWork;
    std::thread								mThread;
    std::mutex                              mNNMutex;
    Receiver                                mReceiver;
    float                                   nnData[10];
    
    
/// MIDI //////////////////////////////////////////////////
    void midiListener( midi::Message msg );
    void openMidi();
    midi::Input mInput;
    cinder::signals::Connection midiConnection;
    vector <int> notes;
    vector <int> cc;
    std::string status;
    
//// audio /////////////////////////////////////////////////
    void monoOrStereo();
    audio::InputDeviceNodeRef		mInputDeviceNode;
    audio::MonitorSpectralNodeRef	mMonitorSpectralNode,
                                    mMonitorSpectralNodeRight;
    vector<float>					mMagSpectrum,
                                    mMagSpectrumRight;
    vec4                            mBands,
                                    mBandsR;
    bool                            useStereo = false;
    
    SpectrumPlot					mSpectrumPlot;
    gl::TextureFontRef				mTextureFont;
    Font                            mFont;
    
/// graphics /////////////////////////////////////////////////
    void loadFiles();
    void createFBOs(int size);
    gl::FboRef fbos[4];
    gl::GlslProgRef fboGlsl, trialGlsl;
    std::string vertProg, fragProg, headerProg;
    bool renderGLSL = true;
    
    int pingPong = 0;
    int postPingPong = 0;
    gl::TextureRef audioMidiTex;
    Surface8u audioSurface;
    

/// editor //////////////////////////////////////////////////
    void shaderListener( std::string code);
    void luaListener( std::string code);
    NSView * theView;
    bool loadedShader = false;
    CinderViewMac *cvm;
    MyNSTextView *tv;
    FeedbackNSTextView *ftv;
    NSScrollView *sv;
    NSSplitView* spv;
    
/// lua files /////////////////////////////////////////////
    void my_print(sol::object a, sol::this_state s);
    std::string bach1, bach2;
    sol::state lua;
    vector<PostProcess *> postProcesses;
    bool renderLUA = true;
    
/// GUI //////////////////////////////////////////////////
    params::InterfaceGlRef	mParams;
    vector<string>			resolutionNames;
    int						resolutionSelection;
    vector<string>			mEnumNames;
    int						mEnumSelection;
    vector<string>          midiNames;
    int                     midiSelection;
    vector<string>          oscNames;
    int                     oscSelection;

/// time //////////////////////////////////////////////////
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
    createFBOs(1);
    
    loadFiles();
    
    audioSurface = Surface8u(1024, 1, false);
    audioMidiTex = gl::Texture::create(audioSurface);
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
    auto ctx = audio::Context::master();
    mInputDeviceNode = ctx->createInputDeviceNode();
    monoOrStereo();
    mSpectrumPlot.enableBorder(false);

    
/////////////////////////////////////////////
//  GUI INIT
/////////////////////////////////////////////
    mParams = params::InterfaceGl::create( getWindow(), "App parameters", toPixels( ivec2( 200, 400 ) ) );
    
    mParams->setPosition(ivec2(800, 10));
    mParams->addParam("Toggle GLSL", &renderGLSL);
    mParams->addParam("Toggle LUA", &renderLUA);
    mParams->addParam("Stereo In", &useStereo)
    .updateFn( [&](){ monoOrStereo(); } );
    
    mParams->addSeparator();
    resolutionSelection = 0;
    resolutionNames = { "full", "half", "quarter" };
    mParams->addParam( "Resolution", resolutionNames, &resolutionSelection )
    .updateFn( [&](){ createFBOs(resolutionSelection + 1); } );

    mParams->addSeparator();
    mEnumSelection = 0;
    mEnumNames = { "new GLSL", "new Lua", "Partita 1", "Partita 2", "Partita 3", "Partita 4", "Improvisation", "Reich", "Feldman", "Glass", "C major", "Elegy", "Mashup" };
    mParams->addParam( "Code", mEnumNames, &mEnumSelection )
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
//    mParams->addParam( "Port", &mString );
    mParams->addParam( "float1", &nnData[0] ).group( "NN Data" );
    //.label( "Item X" );
    mParams->addParam( "float2", &nnData[1] ).group( "NN Data" );
    mParams->addParam( "float3", &nnData[2] ).group( "NN Data" );
    mParams->addParam( "float4", &nnData[3] ).group( "NN Data" );
    mParams->addParam( "float5", &nnData[4] ).group( "NN Data" );
    mParams->addParam( "float6", &nnData[5] ).group( "NN Data" );
    mParams->addParam( "float7", &nnData[6] ).group( "NN Data" );
    mParams->addParam( "float8", &nnData[7] ).group( "NN Data" );
    mParams->addParam( "float9", &nnData[8] ).group( "NN Data" );
    mParams->addParam( "float10", &nnData[9] ).group( "NN Data" );//.optionsStr(mybar/Properties opened=false);
    mParams->setOptions("NN Data", "opened=false");
    
    
    mParams->addSeparator();
    mParams->addButton("Fix TextView", [&](){ [cvm addSubview:spv]; } );
    mParams->addButton("Toggle TextView", [&](){ [spv setHidden:![spv isHidden]]; } );
    //    mParams->addParam( "Toggle TextView", &mString );
    //    mParams->addParam( "Toggle FFT", &mString );
//    mParams->setOptions("TW_HELP", "visible=false" ); //inconified
    
/////////////////////////////////////////////
//  Text View INIT
/////////////////////////////////////////////
    NSUInteger index = [tl indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [obj isKindOfClass:[NSSplitView class]];
    }];

    spv = tl[index];
    sv = (NSScrollView*)[spv.subviews objectAtIndex:0];
    
    tv = (MyNSTextView*)[sv documentView];
    [tv assignCode:fragProg withLanguage:"GLSL"];
    
    //callback from webview when shader code changes
    tv.ShaderSignal->connect([this](std::string code) { shaderListener( code ); });
    tv.LuaSignal->connect([this](std::string code) { luaListener( code ); });
    
    sv = (NSScrollView*)[spv.subviews objectAtIndex:1];
    
    ftv = (FeedbackNSTextView*)[sv documentView];
    [ftv assignCode:"" withLanguage:"GLSL"];
    
    
    //attaching to cinder view, attaching to window view doesn't work
     cvm =  (__bridge CinderViewMac *)getWindow()->getNative();
    [cvm addSubview:spv];

/////////////////////////////////////////////
//  LUA
/////////////////////////////////////////////
    lua.open_libraries(sol::lib::base, sol::lib::string, sol::lib::table, sol::lib::math, sol::lib::os, sol::lib::package);
    
    lua.set_function("prnt", &CinderProjectBasicApp::my_print);
    lua.set("obj", this);
    lua["post"] = &postProcesses;
    lua["PI"] = 3.14159f;
    lua["2PI"] = 6.28318f;
    lua["PHI"] = 1.618f;
    lua["epsilon"] = 0.000043f;
    lua["width"] = getWindowBounds().getWidth();
    lua["height"] = getWindowBounds().getHeight();
    
    luaBindings LB = luaBindings();
    
    LB.bind(&lua);
//    luaBinding2(&lua);
    
    std::string s = loadString(loadAsset("startup.lua"));
    luaListener(s);
}



void CinderProjectBasicApp::update()
{
    //update OSC
    {//scoped for mutex
        if(mThread.joinable()) {//check for OSC connected
            std::lock_guard<std::mutex> lock( mNNMutex );
            lua["NN"] = &nnData;
            fboGlsl->uniform( "NN", nnData, 10);
            
//            for (int i = 0; i < 10; ++i) {
//                std::cout << nnData[i] << " ";
//            }
//            std::cout << std::endl;
        }
    }
    
    //update Spectrum data
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
    if (useStereo && mInputDeviceNode->getNumChannels() > 1)
        mMagSpectrumRight = mMonitorSpectralNodeRight->getMagSpectrum();
   
    pingPong = (pingPong+1)%2;
    
    for (int i=0; i< 1024; ++i) {
//        GLubyte m = 0;
//        if (i < 128) { //
//            m = notes[i] * 2;
//        } else if (i < 256) {
//            m = cc[i-128] * 2;
//        }
        
        float b2 = 0, b = audio::linearToDecibel( mMagSpectrum[i] );
        
        if (i < 256) mBands.x += b;
        else if (i < 512) mBands.y += b;
        else if (i < 768) mBands.z += b;
        else mBands.w += b;
        
        if (useStereo && mInputDeviceNode->getNumChannels() > 1) {
            b2 = audio::linearToDecibel( mMagSpectrumRight[i] );
            if (i < 256) mBandsR.x += b2;
            else if (i < 512) mBandsR.y += b2;
            else if (i < 768) mBandsR.z += b2;
            else mBandsR.w += b2;
        }
        
        audioSurface.setPixel(ivec2(i, 0),
                             Color8u(b * 2.55, //scale up to texture depth
                                     b2 * 2.55,
                                     0));
//        m));
    }
    
    audioMidiTex->update(audioSurface);
    
    mBands /= vec4(25600.0); //average across bands and scale down
    if (useStereo && mInputDeviceNode->getNumChannels() > 1)
        mBandsR /= vec4(25600.0);
    
    //TODO:: if lua?
    float currentTime = cinder::app::getElapsedSeconds();
    float deltaTime = currentTime - lastFrameTime;
    lastFrameTime = currentTime;
    lua["deltaTime"] = deltaTime;
    lua["time"] = currentTime;
    lua["width"] = getWindowBounds().getWidth();
    lua["height"] = getWindowBounds().getHeight();
    lua["midiNotes"] = &notes;
    lua["midiCC"] = &cc;
    lua["bands"] = &mBands;
    
    
    luaListener("update()");
    
    int numEffects = postProcesses.size();
    for (int i = 0; i < numEffects; ++i)
    {   //protects against non postprocess objects
        if(dynamic_cast<PostProcess*>(postProcesses[i]) != NULL){
            postProcesses[i]->updateUniforms();
            //send lua a message
        }
    }

}


void CinderProjectBasicApp::draw()
{
    if (renderGLSL)
    {
        ci::gl::ScopedFramebuffer   fboScp( fbos[pingPong] );
        ci::gl::ScopedViewport      viewScp( fbos[pingPong]->getSize() );
        ci::gl::ScopedGlslProg      glScp( fboGlsl );
        ci::gl::ScopedTextureBind   texScp( fbos[(pingPong+1)%2]->getColorTexture(), 0 );
        gl::ScopedTextureBind       scpAudBind(audioMidiTex, 1);
        ci::gl::ScopedMatrices      matScp;
        ci::gl::setMatricesWindow( fbos[pingPong]->getSize() );
        
        fboGlsl->uniform("backbuffer", 0);
        fboGlsl->uniform("audiobuffer", 1);
        fboGlsl->uniform("time", (float)getElapsedSeconds());
        fboGlsl->uniform("bands", mBands);
        fboGlsl->uniform("bandsR", mBandsR);
        fboGlsl->uniform("resolution",
                         vec2(fbos[pingPong]->getWidth(), fbos[pingPong]->getHeight()));
        
        fboGlsl->uniform("notes", &notes[0], 128);
        fboGlsl->uniform("cc", &cc[0], 128);
        
        //    if (mInputDeviceNode->getNumChannels() > 1)
        
        gl::drawSolidRect(Rectf(vec2(0), fbos[pingPong]->getSize()));
    }
    
    
    if (renderLUA)
    {
//        gl::enableAlphaBlending();
        CameraOrtho cam(0, 1280, 0, 720, -10, 10);
        gl::ScopedViewport scpVp( ivec2( 0 ), fbos[pingPong]->getSize() );
        
        gl::ScopedFramebuffer  scpFbo( fbos[pingPong] );
        
        gl::ScopedMatrices matScope;
        gl::setMatrices( cam );
        
        if (!renderGLSL)
            gl::clear( Color( 0, 0, 0 ) );
        
        
        luaListener("draw()");
//        gl::disableAlphaBlending();
    }
    
    
    
    gl::color(1.0, 1.0, 1.0, 1.0);
    int numEffects = postProcesses.size();
    
    if (numEffects > 0)
    {
        postPingPong = 2;
        
        for (int i = 0; i < numEffects; ++i)
        {
            if(dynamic_cast<PostProcess*>(postProcesses[i]) != NULL)
            {
                if(i == 0) {
                    auto tex0 = fbos[pingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
                    postProcesses[i]->draw(tex0, fbos[postPingPong]);
                }else {
                    auto tex0 = fbos[postPingPong]->getTexture2d( GL_COLOR_ATTACHMENT0 );
                    postProcesses[i]->draw(tex0, fbos[(postPingPong + 1) % 2 + 2]);
                    postPingPong = (postPingPong + 1) % 2 + 2;
                }
            }else {
                //send lua message
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
    auto result = lua.safe_script(code, simple_handler);
    if (!result.valid()) {
        sol::error err = result;
        [ftv assignCode:err.what() withLanguage:"LUA"];
    }else {
        NSString *s = [NSString stringWithUTF8String:code.c_str()];
        if(![s containsString:@"print()"] &&
           ![s isEqualToString:@"draw()"] &&
           ![s isEqualToString:@"update()"])
            [ftv assignCode:"" withLanguage:"LUA"];
    }
}

void CinderProjectBasicApp::shaderListener( std::string code)
{
    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( vertProg )
        .fragment( headerProg + code );

        trialGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        [ftv assignCode:exc.what() withLanguage:"GLSL"];
        [tv errorLineHighlight:exc.what()];
        return;
    }
    catch( ci::Exception &exc )
    {
        [ftv assignCode:exc.what() withLanguage:"GLSL"];
        [tv errorLineHighlight:exc.what()];
        return;
    }
    
    [ftv assignCode:"" withLanguage:"GLSL"];
    [tv errorLineHighlight:""];
    fboGlsl = trialGlsl;
}

void CinderProjectBasicApp::mouseDown( MouseEvent event )
{
    
}

void CinderProjectBasicApp::keyDown( KeyEvent event )
{

}

void CinderProjectBasicApp::createFBOs(int size)
{
    int FBO_WIDTH = getWindowBounds().getWidth()/size;
    int FBO_HEIGHT = getWindowBounds().getHeight()/size;
    auto format = gl::Fbo::Format()
    .samples( 4 ) // uncomment this to enable 4x antialiasing
    .attachment( GL_COLOR_ATTACHMENT0, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
    fbos[0] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[1] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[2] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[3] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
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
            [tv assignCode:"\n\nfunction update()\n\nend" withLanguage:"LUA"];
            break;
        
        case 2: // Partita 1
        {
            std::string s = loadString( loadAsset("Partita1.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 3: // Partita 2
        {
            std::string s = loadString( loadAsset("Partita1.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 4: // Partita 3
        {
            std::string s = loadString( loadAsset("Partita1.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 5: // Partita 4
        {
            std::string s = loadString( loadAsset("Partita1.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 6: // Improvisation
        {
            std::string s = loadString(loadAsset("Improvisation.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 7: // Reich
        {
        
        }
            break;
            
        case 8: // Feldman
        {
            
        }
            break;
            
        case 9: // Glass
        {
            
        }
            break;
            
        case 10: // C Major
        {
            
        }
            break;
            
        case 11: // Elegy for Pauline
        {
            std::string s = loadString(loadAsset("PaulineTribute.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 12: // mashup
        {
            std::string s = loadString(loadAsset("file.lua"));
            [tv assignCode:s withLanguage:"LUA"];
        }
            break;
            
        default:
            break;
    }
}

void CinderProjectBasicApp::my_print(sol::object a, sol::this_state s) {
    sol::state_view lua(s);
    if (a.is<std::string>()) {
        std::string tempString = a.as<std::string>();
        [ftv assignCode:tempString withLanguage:"LUA"];
    } else {
        [ftv assignCode:"nada" withLanguage:"LUA"];
    }
}

//some big batch loading system function here
void CinderProjectBasicApp::loadFiles()
{
    vertProg = loadString( loadAsset("render.vert"));
    fragProg = loadString( loadAsset("render.frag"));
    headerProg = loadString( loadAsset("header.frag"));
    gl::GlslProg::Format renderFormat;
    try {
        renderFormat.vertex( vertProg )
        .fragment( headerProg + fragProg );
        
        fboGlsl = gl::GlslProg::create( renderFormat );
    } 	catch( ci::gl::GlslProgCompileExc &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    catch( ci::Exception &exc )
    {
        CI_LOG_E( "Shader load error: " << exc.what() );
    }
    
    
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
//  Mono or Stereo
/////////////////////////////////////////////

void CinderProjectBasicApp::monoOrStereo()
{
    auto ctx = audio::Context::master();
   
    if (useStereo) {
        if(mInputDeviceNode->isEnabled() && ctx->isEnabled())
        {
            mInputDeviceNode->disable();
            mInputDeviceNode->disconnectAll();
            ctx->disable();
            ctx->disconnectAllNodes();
        }
        
        if (mInputDeviceNode->getNumChannels() > 1)
        { //stereo
            auto channelRouterLeft = ctx->makeNode(new audio::ChannelRouterNode(audio::Node::Format().channels(1)));
            auto channelRouterRight = ctx->makeNode(new audio::ChannelRouterNode(audio::Node::Format().channels(1)));
            auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
            mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
            mMonitorSpectralNodeRight = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
            mInputDeviceNode >> channelRouterLeft->route(0, 0) >> mMonitorSpectralNode;
            mInputDeviceNode >> channelRouterRight->route(1, 0) >> mMonitorSpectralNodeRight;
        } else {
            useStereo = false;
        }
    }
    
    if (!useStereo)
    { //mono
        if(mInputDeviceNode->isEnabled())
        {
            mInputDeviceNode->disable();
            mInputDeviceNode->disconnectAll();
        }
        
        auto monitorFormat = audio::MonitorSpectralNode::Format().fftSize( 2048 ).windowSize( 1024 );
        mMonitorSpectralNode = ctx->makeNode( new audio::MonitorSpectralNode( monitorFormat ) );
        mInputDeviceNode >> mMonitorSpectralNode;
    }
    
    mInputDeviceNode->enable();
    ctx->enable();

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
//                             NSLog(@"data");
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
        mReceiver.removeListener("liveware/nn/");
        mReceiver.close();
     }
}

void CinderProjectBasicApp::cleanup()
{
    stopOSC();
}

CINDER_APP( CinderProjectBasicApp, RendererGl )
