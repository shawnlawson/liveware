#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"

#import "MyWebViewController.h"


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
    
    MyWebViewController *wv;
    NSView * theView;

};

void CinderProjectBasicApp::setup()
{
    setWindowSize(1080, 720);
    wv = [MyWebViewController alloc];
    [wv setupWithPath:[NSString stringWithUTF8String:
                       getAssetPath("EV9D9/index.html").c_str()]];
    theView = [[NSApp mainWindow].contentView subviews][0];
    [theView addSubview:wv.webView];

}

void CinderProjectBasicApp::mouseDown( MouseEvent event )
{
    
}

void CinderProjectBasicApp::keyDown( KeyEvent event )
{
    if( event.getChar() == 'f' ) {
        FullScreenOptions f;
        f.kioskMode(false);
        // Toggle full screen when the user presses the 'f' key.
        setFullScreen( ! isFullScreen(), f);

        [wv.webView setFrame:NSMakeRect(0, 0, getWindowWidth()/2, getWindowHeight()/2)];
        [theView  addSubview:wv.webView];
    }else if (event.getChar() == 'e') {
        
        [wv.webView evaluateJavaScript:@"editor.getSession().setValue('Im Text');" completionHandler:nil];
    }
}

void CinderProjectBasicApp::update()
{
  //  cout << getWindowWidth() << " " << getWindowHeight() << endl;
    
}

void CinderProjectBasicApp::draw()
{
	gl::clear( Color( 0, 0, 0 ) );
    
    gl::color( Color( 1.0f, 0.5f, 0.25f ) );
    gl::drawSolidCircle( getWindowCenter(), 50 );

}

CINDER_APP( CinderProjectBasicApp, RendererGl )
