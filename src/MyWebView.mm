//
//  MyWebViewController.m
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//

#import "MyWebView.h"

//these stay here to avoid duplicate symbol collisions
#include "Tokenize.h"
#include "NSStringFromBool.h"
#import "NSString+EscapeForJavaScript.h"

@implementation MyWebView

std::string startCode;

- (void) setupWithPath:(NSString *)path
{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController
     addScriptMessageHandler:self
                        name:@"myApp"];

    [self   initWithFrame:NSMakeRect(0, 0, 640, 720)
                    configuration:theConfiguration];
    
    self.autoresizingMask = NSViewHeightSizable;
    
    if( NSAppKitVersionNumber > 1500 ){ //safety check
        [self setValue:@(NO) forKey: @"drawsBackground"];
    }
    
    self.navigationDelegate = self;
    self.UIDelegate = self;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    [self loadRequest:[NSURLRequest requestWithURL:url]];

    [self.layer setContentsScale:[NSApp mainWindow].contentView.layer.contentsScale];
}

- (void) setStartCode:(std::string)code
{
    startCode = code;
}

- (void) executeScript:(NSString *) value
{
    [self evaluateJavaScript:value
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
    
    [self evaluateJavaScript:[NSString stringWithFormat:@"editor.getValue();"]
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
            
            [dict setValue:@(std::stoi(tokens[3]) -1)
                    forKey:@"row"];
            if (tokens.size() > 5) {
                [dict setValue:[NSString stringWithFormat:@"%s : %s",
                                tokens[4].c_str(), tokens[5].c_str() ]
                        forKey:@"text"];
            } else {
                [dict setValue:[NSString stringWithFormat:@"%s",
                            tokens[4].c_str() ]
                    forKey:@"text"];
            }
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
    NSString *js = [NSString stringWithFormat:@"setLineErrors(%@, 0, true);", jsonString];
    
    [self executeScript:js];
}

- (void) clearErrors {
    [self executeScript:
     [NSString stringWithFormat:@"clearErrors();"]];
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

/////////////////////////////////////////////
//  Web View messages arrive here
/////////////////////////////////////////////
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
    NSLog(@"Disaster in webpage load");
}

@end


//- (IBAction)changeItAll:(id)sender{
//    
//}
//
//- (IBAction)tryFullScreen:(id)sender{
//    //    ci::app::setFullScreen( ! ci::app::isFullScreen() );
//    
//}
//
//- (BOOL)validateUserInterfaceItem:(id <NSValidatedUserInterfaceItem>)anItem
//{
//    SEL theAction = [anItem action];
//
//    if (theAction == @selector(changeItAll:)) {
//        //        if ( /* there is a current selection and it is copyable */ )
//        //        {
//        //            return YES;
//        //        }
//        //        return NO;
//        return YES;
//    }
//    else {
//        //        if (theAction == @selector(paste:)) {
//        //            if ( /* there is a something on the pasteboard we can use and
//        //                  the user interface is in a configuration in which it makes sense to paste */ ) {
//        //                      return YES;
//        //                  }
//        //            return NO;
//        //        }
//        //        else {
//        //            /* check for other relevant actions ... */
//        //        }
//    }
//    // Subclass of NSDocument, so invoke super's implementation
//    // return [super validateUserInterfaceItem:anItem];
//    return YES;
//}
//
//- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
//    if (commandSelector == @selector(cancelOperation:)) {
//        if([self inFullScreenMode]) {
//            [self.window toggleFullScreen:nil];
//        }
//    }
//    else {
//        return NO;
//    }
//    return YES;
//}
//
//- (BOOL) inFullScreenMode {
//    NSApplicationPresentationOptions opts = [[NSApplication sharedApplication ] presentationOptions];
//    if ( opts & NSApplicationPresentationFullScreen) {
//        return YES;
//    }
//    return NO;
//}


