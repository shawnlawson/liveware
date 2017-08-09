//
//  MyWebViewController.m
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 8/8/17.
//
//

#import "MyWebViewController.h"

@implementation MyWebViewController

@synthesize webView;

//- (void)viewDidLoad {
//    [super viewDidLoad];
- (void) setupWithPath:(NSString *)path
{
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    [theConfiguration.userContentController addScriptMessageHandler:self
                                                               name:@"myApp"];
    
    self.webView = [[WKWebView alloc] initWithFrame:NSMakeRect(0, 0, 500, 600)
                              configuration:theConfiguration];
    
    if( NSAppKitVersionNumber > 1500 ){
        [self.webView setValue:@(NO) forKey: @"drawsBackground"];
    }
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    [self.webView.layer setContentsScale:[NSApp mainWindow].contentView.layer.contentsScale];
    
}

- (void)userContentController:(WKUserContentController *)userContentController
    didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *sentData = (NSDictionary *)message.body;
 //   NSString *messageString = sentData[@"message"];
    NSLog(@"Message received: %@", sentData);
}

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc
{
    [super dealloc];
}


@end
