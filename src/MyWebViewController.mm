//
//  MyWebViewController.m
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//

#import "MyWebViewController.h"

//these stay here to avoid duplicate symbol collisions
#include "Tokenize.h"
#include "NSStringFromBool.h"
#import "NSString+EscapeForJavaScript.h"

@implementation MyWebViewController

@synthesize webView;

std::string startCode;

- (void) setupWithPath:(NSString *)path
{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self
                                                               name:@"myApp"];
    
    webView = [[WKWebView alloc]
                    initWithFrame:NSMakeRect(0, 0, 640, 720)
                    configuration:theConfiguration];
    webView.autoresizingMask = NSViewHeightSizable;
    
    if( NSAppKitVersionNumber > 1500 ){ //safety check
        [webView setValue:@(NO) forKey: @"drawsBackground"];
    }
    
    webView.navigationDelegate = self;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];

    [webView.layer setContentsScale:[NSApp mainWindow].contentView.layer.contentsScale];
    
}

- (void) setStartCode:(std::string)code
{
    startCode = code;
}

- (void) executeScript:(NSString *) value
{
    [webView evaluateJavaScript:value
              completionHandler:^(id result, NSError *error) {
                  if (error == nil) {
                      if (result != nil) {
                          NSString * resultString = [NSString stringWithFormat:@"%@", result];
                          //possibly take this out
                          NSLog(@"%@", resultString);
                      }
                  } else {
                      NSLog(@"evaluateJavaScript error : %@",
                            error.localizedDescription);
                  }
              }];
}

- (void) setTextValue:(std::string)value
{
    [self executeScript: [NSString
                          stringWithFormat:@"editor.setValue(\"%@\"); editor.clearSelection();",
                          [[NSString stringWithUTF8String:value.c_str()] stringByEscapingForJavaScript]]];
}

- (NSString*) getTextValue
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;
    
    [webView evaluateJavaScript:[NSString stringWithFormat:@"editor.getValue();"]
           completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];
    
    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return resultString;
}



- (void) setErrors:(std::string)errors
{
    //FRAGMENT: ERROR: 0:16: 'FragColor' : syntax error: syntax error
    NSMutableArray * annotations = [NSMutableArray array];
    std::istringstream f(errors);
    std::string line;
    
    while(std::getline(f, line))
    {
        std::vector<std::string> tokens;
        Tokenize(line, tokens, ":");
        
        if (tokens.size() > 4)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt:0], @"column",
                    [NSNumber numberWithInt:0], @"row",
                    @"error", @"type",
                    @"Some error about something", @"text",
                                         nil];
            
            [dict setValue:@(std::stoi(tokens[3]))
                    forKey:@"row"];
            [dict setValue:[NSString stringWithFormat:@"%s : %s",
                            tokens[4].c_str(), tokens[5].c_str() ]
                    forKey:@"text"];
            
            [annotations addObject:dict];
        }
    }
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:annotations
                                                       options:kNilOptions
                                                         error:&err];
    if (!jsonData) {
        NSLog(@"JSON encoding error: %@", [err localizedDescription]);
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *js = [NSString stringWithFormat:@"editor.getSession().setAnnotations(%@);", jsonString];
    
    [self executeScript:js];
}



- (void) setTextSize:(int)size
{
  [self executeScript:
   [NSString stringWithFormat:@"editor.setFontSize('%ddpx');",size]];
}

- (void) toggleAutoCompletion:(BOOL)value
{
    [self executeScript:
     [NSString stringWithFormat:@"editor.setOption('enableBasicAutocompletion', %@);", NSStringFromBool(value)]];
}

- (void) toggleSnippets:(BOOL)value
{
    [self executeScript:[NSString stringWithFormat:@"editor.setOption('enableSnippets', %@);", NSStringFromBool(value)]];
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *sentData = (NSDictionary *)message.body;
 //   NSString *messageString = sentData[@"message"];
    
    if ([[sentData objectForKey:@"what"] isEqualToString:@"code"])
    {
//        NSLog(@"%@", sentData[@"data"]);
        shaderSignal.emit( std::string([sentData[@"data"] UTF8String]) );
    }
    
//    NSLog(@"Message received: %@", sentData);
}


- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
}

/////////////////////////////////////////////
//  Cinder signal callback
/////////////////////////////////////////////

- (ci::signals::Signal<void(std::string)>*) ShaderSignal
{
    return &shaderSignal;
}


/////////////////////////////////////////////
//  WKNavigationDelegate Callbacks
/////////////////////////////////////////////

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self setTextValue:startCode];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

}

@end


