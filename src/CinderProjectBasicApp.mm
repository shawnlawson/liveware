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
#include "FeedbackNSTextView.h"
#include "AudioDrawUtils.h"

//#define __OBJC__

#include "sol.hpp"

#include "Drawable.h"
#include "mCircle.h"
#include "mRectangle.h"
#include "mImage.h"
#include "PostProcess.h"
#include "BuiltinPostProcesses.h"

using namespace ci;
using namespace ci::app;
using namespace std;

//OSC UDP
using Receiver = osc::ReceiverUdp;
using protocol = asio::ip::udp;

//class mPrinter {
//public:
//    static ci::signals::Signal<void(std::string)>      printSignal;
//    
//    void my_print(sol::this_state ts)
//    {
//        lua_State* L = ts;
//        //    sol::state_view lua(L);
//        //    lua.safe_script("print('x, y, radius')");)
//        
//        int nargs = lua_gettop(L);
//        string s = "in my_print:";
//        for (int i=1; i <= nargs; ++i) {
//            if (lua_isstring(L, i)) {
//                s += lua_tostring(L, i);
//            }
//        }
//        s += "\n";
//        
//        printSignal.emit( s );
//    }
//    
//    ci::signals::Signal<void(std::string)>* LuaSignal() {
//        return &luaSignal;
//    }
//};

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
    
    //graphics
    void renderToFBO();
    gl::FboRef fbos[4];
    gl::GlslProgRef fboGlsl, trialGlsl;
    std::string vertProg, fragProg;
    bool renderGLSL = true;
    
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
    FeedbackNSTextView *ftv;
    NSScrollView *sv;
    
    //lua files
    void drawLua();
    std::string bach1, bach2;
    sol::state lua;
    vector<Drawable *> drawables;
    vector<PostProcess *> postProcesses;
    bool renderLUA = true;
    
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
    .samples( 4 ) // uncomment this to enable 4x antialiasing
    .attachment( GL_COLOR_ATTACHMENT0, gl::Texture2d::create( FBO_WIDTH, FBO_HEIGHT ) );
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
    mParams->addParam("Stereo", &useStereo)
    .updateFn( [&](){ monoOrStereo(); } );
    
    mParams->addSeparator();
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
//        return [obj isKindOfClass:[NSScrollView class]];
        return [obj isKindOfClass:[NSSplitView class]];
    }];
//    sv = tl[index];
    NSSplitView* spv = tl[index];
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
//    [cvm addSubview:sv];
    [cvm addSubview:spv];
}



void CinderProjectBasicApp::update()
{
    //update OSC
    {//scoped for mutex
        if(mThread.joinable()) {//check for OSC connected
            std::lock_guard<std::mutex> lock( mNNMutex );
            for (int i = 0; i < 10; ++i) {
                std::cout << nnData[i] << " ";
            }
            std::cout << std::endl;
        }
    }
    
    //update Spectrum data
    mMagSpectrum = mMonitorSpectralNode->getMagSpectrum();
    if (useStereo && mInputDeviceNode->getNumChannels() > 1)
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
        
        if (useStereo && mInputDeviceNode->getNumChannels() > 1) {
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
    //TODO::OSC lua["osc"] =
    //TODO::MIDI lua["midi"] =
    
    sol::function luaUpdate = lua["update"];
    luaUpdate();
    
    int numEffects = postProcesses.size();
    for (int i = 0; i < numEffects; ++i)
    {   //protects against non postprocess objects
        if(dynamic_cast<PostProcess*>(postProcesses[i]) != NULL){
            postProcesses[i]->updateUniforms();
            //send lua a message
        }
    }

}

void CinderProjectBasicApp::renderToFBO()
{

    
    ci::gl::ScopedFramebuffer   fboScp( fbos[pingPong] );
    ci::gl::ScopedViewport      viewScp( fbos[pingPong]->getSize() );
    ci::gl::ScopedGlslProg      glScp( fboGlsl );
    ci::gl::ScopedTextureBind   texScp( fbos[(pingPong+1)%2]->getColorTexture(), 0 );
    gl::ScopedTextureBind       scpAudBind(audioMidiTex, 1);
    ci::gl::ScopedMatrices      matScp;
    ci::gl::setMatricesWindow( fbos[pingPong]->getSize() );
    
    fboGlsl->uniform("uRenderMap", 0);
    fboGlsl->uniform("uAudioMap", 1);
    fboGlsl->uniform("time", (float)getElapsedSeconds());
    fboGlsl->uniform("bands", mBands);

    //TODO::OSC glsl["osc"] =
    //TODO::MIDI glsl["midi"] =

    
    if (mInputDeviceNode->getNumChannels() > 1)
        fboGlsl->uniform("bandsR", mBandsR);
    
    gl::drawSolidRect(Rectf(vec2(0), fbos[pingPong]->getSize()));
    
}

void CinderProjectBasicApp::drawLua()
{
    
    CameraOrtho cam(0, 1280, 0, 720, -10, 10);
    gl::ScopedViewport scpVp( ivec2( 0 ), fbos[pingPong]->getSize() );

    gl::ScopedFramebuffer  scpFbo( fbos[pingPong] );

    gl::ScopedMatrices matScope;
    gl::setMatrices( cam );

    if (!renderGLSL)
        gl::clear( Color( 0, 0, 0 ) );
    
    sol::function luaDraw = lua["draw"];
    luaDraw();
}

void CinderProjectBasicApp::draw()
{
    if (renderGLSL)
         renderToFBO();
    
    if (renderLUA)
        drawLua();
    
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
        [ftv assignCode:"" withLanguage:"LUA"];
    }
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
        [ftv assignCode:exc.what() withLanguage:"GLSL"];
        [tv errorLineHighlight:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
        return;
    }
    catch( ci::Exception &exc )
    {
        [ftv assignCode:exc.what() withLanguage:"GLSL"];
        [tv errorLineHighlight:exc.what()];
//        CI_LOG_E( "Shader load error: " << exc.what() );
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
    
    lua.open_libraries(sol::lib::base, sol::lib::math, sol::lib::package);
    
//    const std::string package_path = lua["package"]["path"];
//    lua["package"]["path"] = package_path + (!package_path.empty() ? ";" : "") + test::scripts_path("proc/valid/") + "?.lua";


        lua.new_usertype<mCircle>("circle",
                                "x", &mCircle::x,
                                "y", &mCircle::y,
                                "z", &mCircle::z,
                                  "rx", &mCircle::rX,
                                  "ry", &mCircle::rY,
                                  "rz", &mCircle::rZ,
                                  "sx", &mCircle::sX,
                                  "sy", &mCircle::sY,
                                  "sz", &mCircle::sZ,
                                  "r", &mCircle::r,
                                  "g", &mCircle::g,
                                  "b", &mCircle::b,
                                  "a", &mCircle::a,
                                  "radius", &mCircle::radius,
                                  "outline", &mCircle::outline,
                                  "lineWidth", &mCircle::lineWidth,
                                "print", &mCircle::print,
                                "draw", &mCircle::draw
                                 );

    
    lua.new_usertype<mRectangle>("rect",
                              "x", &mRectangle::x,
                              "y", &mRectangle::y,
                              "z", &mRectangle::z,
                              "rx", &mRectangle::rX,
                              "ry", &mRectangle::rY,
                              "rz", &mRectangle::rZ,
                              "sx", &mRectangle::sX,
                              "sy", &mRectangle::sY,
                              "sz", &mRectangle::sZ,
                              "r", &mRectangle::r,
                              "g", &mRectangle::g,
                              "b", &mRectangle::b,
                              "a", &mRectangle::a,
                             "w", &mRectangle::w,
                             "h", &mRectangle::h,
                                 "radians", &mRectangle::radians,
                              "outline", &mRectangle::outline,
                             "lineWidth", &mRectangle::lineWidth,
                              "print", &mRectangle::print,
                              "draw", &mRectangle::draw
                              );
 
    lua.new_usertype<mImage>("image",
                                 "x", &mImage::x,
                                 "y", &mImage::y,
                                 "z", &mImage::z,
                                 "rx", &mImage::rX,
                                 "ry", &mImage::rY,
                                 "rz", &mImage::rZ,
                                 "sx", &mImage::sX,
                                 "sy", &mImage::sY,
                                 "sz", &mImage::sZ,
                                 "r", &mImage::r,
                                 "g", &mImage::g,
                                 "b", &mImage::b,
                                 "a", &mImage::a,
                                 "radians", &mImage::radians,
                             "open", &mImage::open,
                                "print", &mImage::print,
                                 "draw", &mImage::draw
                                 );
    
    lua.new_usertype<invert>("invert",
                                "listUniforms", &invert::listUniforms
                                );
    
    lua.new_usertype<greyscale>("greyscale",
                                "amount", &greyscale::amount,
                                "listUniforms", &greyscale::listUniforms
                                );
    
    lua.new_usertype<vignette>("vignette",
                                "amount", &vignette::amount,
                                "listUniforms", &vignette::listUniforms
                                );
    
    lua.new_usertype<aberration>("aberration",
                                "amount", &aberration::amount,
                                "listUniforms", &aberration::listUniforms
                                );
    
    lua.new_usertype<scanline>("scanline",
                                "amount", &scanline::amount,
                               "speed", &scanline::speed,
                                "listUniforms", &scanline::listUniforms
                                );

    lua.new_usertype<blur>("blur",
                               "width", &blur::width,
                               "height", &blur::height,
                                "updateUniforms", &blur::updateUniforms,
                               "listUniforms", &blur::listUniforms
                               );

    
//    lua["scene"] = &drawables;
    lua["post"] = &postProcesses;
    
    // call lua code directly
    std::string s = loadString(loadAsset("startup.lua"));
    auto simple_handler = [](lua_State*, sol::protected_function_result result) {
        // You can just pass it through to let the call-site handle it
        return result;
    };
    auto result = lua.safe_script(s, simple_handler);
    if (!result.valid()) {
        sol::error err = result;
        std::cout << "Error:" << err.what() << std::endl;
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
        mReceiver.removeListener("liveware/nn/");
        mReceiver.close();
     }
}

void CinderProjectBasicApp::cleanup()
{
    stopOSC();
}

CINDER_APP( CinderProjectBasicApp, RendererGl )
