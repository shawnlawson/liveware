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

    //NSDictionary *_autocompletes;
//    NSString *lastAutoInsert;
    NSUInteger tabWidth;
    NSFont *currentFont;
    NSTimer *shaderTimer;
    NSTimer *luaExecHighlightTimer;
    NSRange execRange;
    NSMutableDictionary *colormap;
    NSMutableDictionary *colors;
    NSMutableArray *functions;
    NSMutableArray *uniforms;
    NSMutableArray *math;
    NSMutableArray *storage;
    NSMutableArray *keyword;
    NSMutableArray *definedColors;
    NSMutableString *operators;
    NSMutableString *commentString;
    NSMutableString *whichLanguage;

    NSRange currentLine;
    NSShadow *shadow;
    BOOL changed;
    
}

- (IBAction)indent:(id)sender;
- (IBAction)dedent:(id)sender;
- (IBAction)toggleComments:(id)sender;
- (IBAction)openDocument:(id)sender;

- (void) assignCode:(std::string)code withLanguage:(std::string)lang;
- (void) errorLineHighlight:(std::string)errors;

- (ci::signals::Signal<void(std::string)>*) ShaderSignal;
- (ci::signals::Signal<void(std::string)>*) LuaSignal;

@end

static ci::signals::Signal<void(std::string)>      shaderSignal;
static ci::signals::Signal<void(std::string)>      luaSignal;
