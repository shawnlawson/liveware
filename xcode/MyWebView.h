//
//  MyWebViewController.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//


#import <WebKit/WebKit.h>
#include <string>

@interface MyWebView : WKWebView <WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

- (void) setupWithPath:(NSString*)path;
- (void) setStartCode:(std::string)code;

- (void) executeScript:(NSString *)value;
- (void) setTextValue:(std::string)value;
- (NSString*) getTextValue;

- (void) setErrors:(std::string)errors;
- (void) clearErrors;

- (void) toggleAutoCompletion:(BOOL)value;
- (void) toggleSnippets:(BOOL)value;
// - (void) setMode ??
// - (void) setTheme ??
- (IBAction)enlargeText:(id)sender;
- (IBAction)shrinkText:(id)sender;

- (ci::signals::Signal<void(std::string)>*) ShaderSignal;

@end

static ci::signals::Signal<void(std::string)>      shaderSignal;
