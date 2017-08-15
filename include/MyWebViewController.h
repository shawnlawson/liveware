//
//  MyWebViewController.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//


#import <WebKit/WebKit.h>

#include <string>

@interface MyWebViewController : NSObject <WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

@property(strong,nonatomic) WKWebView *webView;

- (void) setupWithPath:(NSString*)path;
- (void) setStartCode:(std::string)code;

- (void) executeScript:(NSString *)value;
- (void) setTextValue:(std::string)value;
- (NSString*) getTextValue;

- (void) setErrors:(std::string)errors;

- (void) setTextSize:(int)size;
- (void) toggleAutoCompletion:(BOOL)value;
- (void) toggleSnippets:(BOOL)value;
// - (void) setMode ??
// - (void) setTheme ??

- (NSString *) NSStringFromBool:(BOOL) value;

@end



void Tokenize(const std::string& str,
              std::vector<std::string>& tokens,
              const std::string& delimiters = " ");
