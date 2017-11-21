
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

//Blocks
#include "MidiHeaders.h"
#include "cinder/osc/Osc.h"

//User
#include "MyNSTextView.h"
#include "FeedbackNSTextView.h"
#include "AudioDrawUtils.h"
#include "MyNSSplitView.h"
#include "LuaBindings.hpp"
#include "LuaBindings_2.hpp"

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
    void resize() override;
    
/// OSC //////////////////////////////////////////////////
    void openOSC();
    void stopOSC();
    std::shared_ptr<asio::io_service>		mIoService;
    std::shared_ptr<asio::io_service::work>	mWork;
    std::thread								mThread;
    std::mutex                              mNNMutex;
    Receiver                                mReceiver;
    vec3                                    audioNN;
    vec2                                    classNN;
    float                                   streamNN[10];
    float                                   classFNN[30];

    
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
    gl::FboRef fbos[2];
    gl::GlslProgRef fboGlsl, trialGlsl;
    std::string vertProg, fragProg, headerProg;
    bool renderGLSL = true;
    
    int pingPong = 0;
    int postPingPong = 0;
    gl::TextureRef audioMidiTex;
    Surface8u audioSurface;
    bool clearBackground = true;
    

/// editor //////////////////////////////////////////////////
    void shaderListener( std::string code);
    void luaListener( std::string code);
    NSView * theView;
    bool loadedShader = false;
    CinderViewMac *cvm;
    MyNSTextView *tv;
//    FeedbackNSTextView *ftv;
    NSScrollView *sv;
//    NSSplitView* spv;
    MyNSSplitView* spv;
    
/// lua files /////////////////////////////////////////////
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

FeedbackNSTextView *ftv;


int super_print(lua_State* L) {
    std::string output;
    int n = lua_gettop(L);  /* number of arguments */
    int i;
    lua_getglobal(L, "tostring");
    for (i=1; i<=n; i++) {
        const char *s;
        size_t l;
        lua_pushvalue(L, -1);  /* function to be called */
        lua_pushvalue(L, i);   /* value to print */
        lua_call(L, 1, 1);
        s = lua_tolstring(L, -1, &l);  /* get result */
        if (s == NULL)
            return luaL_error(L, "'tostring' must return a string to 'print'");
        if (i>1) output.append("\t");
        output.append(s);
        lua_pop(L, 1);  /* pop result */
    }
    output.append("\n");
    [ftv assignCode:output withLanguage:"LUA"];
    return 0;
}

static const struct luaL_Reg printlib [] = {
    {"print", super_print},
    {NULL, NULL} /* end of array */
};



//contructor so that we have OSC
CinderProjectBasicApp::CinderProjectBasicApp()
    : mIoService( new asio::io_service ),
    mWork( new asio::io_service::work( *mIoService ) ),
    mReceiver( 10001, protocol::v4(), *mIoService )
{}

//CinderProjectBasicApp::CinderProjectBasicApp()
//:
//mReceiver( 10001 )
//{}
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
    audioMidiTex->setMinFilter(GL_NEAREST);
    audioMidiTex->setMagFilter(GL_NEAREST);
    mFont = Font( "Fira Code", 16 );
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
    
    for( int i = 0; i < 128; i++ )
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
    mEnumNames = { "new GLSL", "new Lua", "Reich", "Intro", "Fugue", "Corrente", "Gigue", "Adagio",  "Improvisation",  "Feldman", "Glass", "Elegy", "Mashup" };
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
//    mParams->addParam( "float1", &nnData[0] ).group( "NN Data" );
//    //.label( "Item X" );
//    mParams->addParam( "float2", &nnData[1] ).group( "NN Data" );
//    mParams->addParam( "float3", &nnData[2] ).group( "NN Data" );
//    mParams->addParam( "float4", &nnData[3] ).group( "NN Data" );
//    mParams->addParam( "float5", &nnData[4] ).group( "NN Data" );
//    mParams->addParam( "float6", &nnData[5] ).group( "NN Data" );
//    mParams->addParam( "float7", &nnData[6] ).group( "NN Data" );
//    mParams->addParam( "float8", &nnData[7] ).group( "NN Data" );
//    mParams->addParam( "float9", &nnData[8] ).group( "NN Data" );
//    mParams->addParam( "float10", &nnData[9] ).group( "NN Data" );//.optionsStr(mybar/Properties opened=false);
//    mParams->setOptions("NN Data", "opened=false");
    
    
    mParams->addSeparator();
    mParams->addButton("Fix TextView", [&](){ [cvm addSubview:spv]; } );
    mParams->addButton("Toggle TextView", [&](){ [spv setHidden:![spv isHidden]]; } );
    mParams->addButton("Reload startup Lua", [&](){ std::string s = loadString(loadAsset("startup.lua"));
                                                    luaListener(s); } );
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
    
    lua_getglobal(lua, "_G");
    luaL_setfuncs(lua, printlib, 0);
    lua_pop(lua, 1);
    
    lua.set("obj", this);
    lua["post"] = &postProcesses;
    lua["PI"] = 3.14159f;
    lua["2PI"] = 6.28318f;
    lua["PHI"] = 1.618f;
    lua["epsilon"] = 0.000043f;
    lua["width"] = getWindowBounds().getWidth();
    lua["height"] = getWindowBounds().getHeight();
    lua["midiNotes"] = &notes;
    lua["midiCC"] = &cc;
    lua["bands"] = &mBands;
    lua["audioNN"] =  &audioNN;
    lua["classNN"] = &classNN;
    lua["streamNN"] = &streamNN;
    lua["clearBackground"] = true;
    
    LuaBindings LB = LuaBindings();
    
    LB.bind(&lua);
    luaBinding2(&lua);
    
    std::string s = loadString(loadAsset("startup.lua"));
    luaListener(s);
}



void CinderProjectBasicApp::update()
{
    
    //update Spectrum data
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
    if (useStereo && mInputDeviceNode->getNumChannels() > 1)
        mMagSpectrumRight = mMonitorSpectralNodeRight->getMagSpectrum();
   
    if(!clearBackground)
        pingPong = 0;
    else
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
//                                     0));
        m));
    }
    
    audioMidiTex->update(audioSurface);
    
    mBands /= vec4(25600.0); //average across bands and scale down
    if (useStereo && mInputDeviceNode->getNumChannels() > 1)
        mBandsR /= vec4(25600.0);
    
    //TODO:: if lua?
    float currentTime = cinder::app::getElapsedSeconds();
    float deltaTime = currentTime - lastFrameTime;
    lastFrameTime = currentTime;
    
    if (renderLUA)
    {
        lua["deltaTime"] = deltaTime;
        lua["time"] = currentTime;

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

    if(renderGLSL)
    {
        fboGlsl->uniform("backbuffer", 0);
        fboGlsl->uniform("audiobuffer", 1);
        fboGlsl->uniform("time", (float)getElapsedSeconds());
        fboGlsl->uniform("bands", mBands);
        fboGlsl->uniform("bandsR", mBandsR);
        fboGlsl->uniform("resolution",
                         vec2(fbos[pingPong]->getWidth(), fbos[pingPong]->getHeight()));
        
//        fboGlsl->uniform("notes", &notes[0], 128);
//        fboGlsl->uniform("cc", &cc[0], 128);
        
        {if(mThread.joinable()) {//check for OSC connected
            std::lock_guard<std::mutex> lock( mNNMutex );
            fboGlsl->uniform( "audioNN", audioNN);
            fboGlsl->uniform( "classNN", classNN);
            fboGlsl->uniform( "streamNN", &streamNN[0], 10);
        }}
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
        
        //    if (mInputDeviceNode->getNumChannels() > 1)
        
        gl::drawSolidRect(Rectf(vec2(0), fbos[pingPong]->getSize()));
    }
    
    
    if (renderLUA)
    {
//        gl::enableAlphaBlending();
//        gl::enableDepthWrite();
//        gl::enableDepthRead();
        CameraOrtho cam(0, getWindowBounds().getWidth(), 0, getWindowBounds().getHeight(), -1000, 1000);
        gl::ScopedViewport scpVp( ivec2( 0 ), fbos[pingPong]->getSize() );
        
        gl::ScopedFramebuffer  scpFbo( fbos[pingPong] );
        
        gl::ScopedMatrices matScope;
        gl::setMatrices( cam );
        
//        if (!renderGLSL)
        clearBackground = lua["clearBackground"].get_or(true);
        if(clearBackground)
            gl::clear( Color( 0, 0, 0 ) );

        {
            std::lock_guard<std::mutex> lock( mNNMutex );
            luaListener("draw()");
        }
//        gl::disableAlphaBlending();
//        gl::disableDepthWrite();
//        gl::disableDepthRead();
        
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
        if(![s containsString:@"print("] &&
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
    .samples( 4 )
    .attachment( GL_COLOR_ATTACHMENT0, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
    fbos[0] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
    fbos[1] = gl::Fbo::create( FBO_WIDTH, FBO_HEIGHT, format);
}

void CinderProjectBasicApp::resize()
{
    NSRect f = spv.frame;
    
    if(getWindowBounds().getWidth() < 1600)
        f.size.width = 800;
    else
        f.size.width = getWindowBounds().getWidth()/2;
    
    [spv setFrame:f];
    mParams->setPosition(vec2(f.size.width, 10));
    
    createFBOs(resolutionSelection + 1);
    
    lua["width"] = getWindowBounds().getWidth();
    lua["height"] = getWindowBounds().getHeight();

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
        
        case 2:
        {
            std::string s = loadString( loadAsset("Reich.lua"));
            [tv assignCode:s withLanguage:"LUA"];
        }
            break;
            
        case 3:
        {
            std::string s = loadString( loadAsset("Intro.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 4:
        {
            std::string s = loadString( loadAsset("Fugue.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 5:
        {
            std::string s = loadString( loadAsset("Corrente.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 6:
        {
            std::string s = loadString(loadAsset("Gigue.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 7:
        {
            std::string s = loadString(loadAsset("Adagio.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 8:
        {
            std::string s = loadString(loadAsset("Improvisation.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
            break;
            
        case 9:
        {
            std::string s = loadString(loadAsset("Feldman.lua"));
            [tv assignCode:s withLanguage:"LUA"];
        }
            break;
            
        case 10: // C Major
        {
            std::string s = loadString(loadAsset("Glass.lua"));
            [tv assignCode:s withLanguage:"LUA"];
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
            std::string s = loadString(loadAsset("Mashup.frag"));
            [tv assignCode:s withLanguage:"GLSL"];
        }
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
//            status = "Pitch: " + toString( msg.pitch ) + "\n" + "Velocity: " + toString( msg.velocity );
            break;
            
        case MIDI_NOTE_OFF:
            notes[msg.pitch] = 0;
            break;
            
        case MIDI_CONTROL_CHANGE:
            cc[msg.control] = msg.value;
//            status = "Control: " + toString( msg.control ) + "\n" + "Value: " + toString( msg.value );
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
    
    // looks at window of data to determine more bullshit
    mReceiver.setListener("/LiveWare/output/audio",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              // 1 int 2 float
                              audioNN.x = (float)(msg[0].int32());
                              audioNN.y = msg[1].flt();
                              audioNN.z = msg[2].flt();
//                             NSLog(@"audio");
                          });
    
    // looks at window of data to determine which piece
    mReceiver.setListener("/LiveWare/output/midi/classifier",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              //1 int, range 0-14
                              classNN.x = (float)msg[0].int32();
//                              NSLog(@"classifier");
                          });
    mReceiver.setListener("/LiveWare/output/midi/classifier/vote",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              //1 int , range 0-14 smoothed
                              classNN.y = (float)msg[0].int32();
//                              NSLog(@"classifier/vote");
                          });

    // looks at window of data to determine which bullshit
    mReceiver.setListener("/LiveWare/output/midi/stream",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              for(int i = 0; i < 5; ++i){
                                  streamNN[i] = msg[i].flt();
                              }
                              //5 float
//                              NSLog(@"stream");
                          });
    mReceiver.setListener("/LiveWare/output/midi/stream/smooth",
                          [&]( const osc::Message &msg ){
                              std::lock_guard<std::mutex> lock( mNNMutex );
                              for(int i = 0; i < 5; ++i){
                                  streamNN[i+5] = msg[i].flt();
                              }
                              //5 float //smoothed
//                              NSLog(@"stream/smooth");
                          });

    // looks at window of data determine probability of which piece as all 15
//    mReceiver.setListener("/LiveWare/output/midi/classifierfloat",
//                          [&]( const osc::Message &msg ){
////                              std::lock_guard<std::mutex> lock( mNNMutex );
//                              for(int i = 0; i < 15; ++i){
//                                  classFNN[i] = msg[i].flt();
////                                  cFNN[i] = msg[i].flt();
//                              }
//                              //15 float
////                              NSLog(@"classifierfloat");
//                          });
//    mReceiver.setListener("/LiveWare/output/midi/classifierfloat/smooth",
//                          [&]( const osc::Message &msg ){
////                              std::lock_guard<std::mutex> lock( mNNMutex );
//                              for(int i = 0; i < 15; ++i){
//                                  classFNN[i+15] = msg[i].flt();
////                                   cFNN[i+15] = msg[i].flt();
//                              }
//                              //15 float //smoothed
////                              NSLog(@"classifierfloat/smooth");
//                          });
    
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
        mReceiver.removeListener("/LiveWare/output/audio");
        mReceiver.removeListener("/LiveWare/output/midi/classifier");
        mReceiver.removeListener("/LiveWare/output/midi/classifier/vote");
        mReceiver.removeListener("/LiveWare/output/midi/stream");
        mReceiver.removeListener("/LiveWare/output/midi/stream/smooth");
        mReceiver.removeListener("/LiveWare/output/midi/classifierfloat");
        mReceiver.removeListener("/LiveWare/output/midi/classifierfloat/smooth");
        mReceiver.close();
     }
}

void CinderProjectBasicApp::cleanup()
{
    stopOSC();
}

CINDER_APP( CinderProjectBasicApp, RendererGl )
