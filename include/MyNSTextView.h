//
//  MyNSTextView.h
//  CinderProjectswift
//
//  Created by Shawn Lawson on 8/18/17.
//
//

#import <Cocoa/Cocoa.h>

#import "MyLineNumberView.h"

#include <string>

@interface MyNSTextView : NSTextView <NSTextStorageDelegate> {
    
    MyLineNumberView * lineNumberView;
//    MySyntaxHighlighter *syntaxHighlighter;
    //NSDictionary *_autocompletes;
//    NSString *lastAutoInsert;
    NSUInteger tabWidth;
    NSFont *currentFont;
    NSTimer *shaderTimer;
    NSMutableDictionary *colormap;
    NSMutableDictionary *colors;
    NSMutableArray *functions;
    NSMutableArray *uniforms;
    NSMutableArray *math;
    NSMutableArray *storage;
    NSMutableArray *keyword;
}

- (IBAction)indent:(id)sender;
- (IBAction)dedent:(id)sender;
- (IBAction)toggleComments:(id)sender;

- (void)assignShader:(std::string)shader;
- (void) errorLineHighlight:(std::string)errors;

- (ci::signals::Signal<void(std::string)>*) ShaderSignal;

@end

static ci::signals::Signal<void(std::string)>      shaderSignal;
