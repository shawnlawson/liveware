//
//  MyWebViewController.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//


#import <WebKit/WebKit.h>


@interface MyWebViewController : NSObject <WKScriptMessageHandler, WKUIDelegate>

@property(strong,nonatomic) WKWebView *webView;

- (void) setupWithPath:(NSString*)path;

@end

