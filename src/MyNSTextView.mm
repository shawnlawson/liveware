//
//  MyNSTextView.m
//  CinderProjectswift
//
//  Created by Shawn Lawson on 8/18/17.
//
//

#import <Foundation/Foundation.h>

#import "MyNSTextView.h"


@implementation MyNSTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        // what's the right way to do this?
        [self performSelector:@selector(setupLineView) withObject:nil afterDelay:0];
    }
    NSLog(@"coder");
    return self;
}

- (void)setupLineView{
    lineNumberView = [[MyLineNumberView alloc] initWithScrollView:[self enclosingScrollView] orientation:NSVerticalRuler];
    [[self enclosingScrollView] setVerticalRulerView:lineNumberView];
    [[self enclosingScrollView] setHasHorizontalRuler:NO];
    [[self enclosingScrollView] setHasVerticalRuler:YES];
    [[self enclosingScrollView] setRulersVisible:YES];

    [self setUsesFontPanel:YES];
    
    [[self textStorage] setDelegate:self];
    NSRange area = NSMakeRange(0, [[self textStorage] length]);
    [[self textStorage] removeAttribute:NSForegroundColorAttributeName range:area];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *oldFont = [NSFont fontWithName:@"fira code" size:16];
    
    [self setCurrentFont:[fontManager convertFont:oldFont]];
    [self setTextColor:[NSColor whiteColor]];
    //    [[self textStorage] setFont:];
    
        
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification object:self];
    
}

- (void)assignShader:(std::string)shader{
    [[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length])
                                      withString:[NSString stringWithUTF8String:shader.c_str()]];
    NSRange area = NSMakeRange(0, [[self textStorage] length]);
    [[self textStorage] removeAttribute:NSForegroundColorAttributeName range:area];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *oldFont = [NSFont fontWithName:@"fira code" size:16];
    
    [self setCurrentFont:[fontManager convertFont:oldFont]];
    [self setTextColor:[NSColor whiteColor]];
}

- (void) updateRuler {
    [lineNumberView setNeedsDisplay:YES];
}




#pragma mark - UI Commands
//////////////////////////////////
// UI functions
//////////////////////////////////
-(IBAction)indent:(id)sender
{
     [self _shiftRight:[NSValue valueWithRange:[self selectedRange]]];
}

- (void)_shiftRight:(NSValue*)valueRange {
    NSRange range = [valueRange rangeValue];
    NSRange newRange = [self __shiftRight:range];
    if(!NSEqualRanges(newRange, range)) {
        [[self undoManager] registerUndoWithTarget:self selector:@selector(_shiftLeft:) object:[NSValue valueWithRange:newRange]];
        [self setSelectedRange:newRange];
    }
}

- (NSRange)__shiftRight:(NSRange)range {
    NSString* string = [[self textStorage] mutableString];
    NSRange newRange = range;
    
    NSRange subRange = [string rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
    if (subRange.location == NSNotFound) {
        range.length += range.location;
        range.location = 0;
    } else {
        range.length += range.location - subRange.location - 1;
        range.location = subRange.location + 1;
    }
    newRange.location += 1;
    newRange.length -= 1;
    
    while (1) {
        [self replaceCharactersInRange:NSMakeRange(range.location, 0) withString:@"\t"];
        newRange.length += 1;
        range.length += 1;
        
        subRange = [string rangeOfString:@"\n" options:0 range:range];
        if ((subRange.location == NSNotFound) || (subRange.location + 1 == range.location + range.length)) {
            break;
        }
        range.length -= subRange.location - range.location + 1;
        range.location = subRange.location + 1;
    }
    
    [self didChangeText];
    
    return newRange;
}


-(IBAction)dedent:(id)sender
{
   [self _shiftLeft:[NSValue valueWithRange:[self selectedRange]]];
}

- (void)_shiftLeft:(NSValue*)valueRange {
    NSRange range = [valueRange rangeValue];
    NSRange newRange = [self __shiftLeft:range];
    if(!NSEqualRanges(newRange, range)) {
        [[self undoManager] registerUndoWithTarget:self selector:@selector(_shiftRight:) object:[NSValue valueWithRange:newRange]];
        [self setSelectedRange:newRange];
    }
}

- (NSRange)__shiftLeft:(NSRange)range {
    NSString* string = [[self textStorage] mutableString];
    NSRange newRange = range;
    
    if (![string length]) {
        return newRange;
    }
    
    NSRange subRange = [string rangeOfString:@"\n" options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
    if (subRange.location == NSNotFound) {
        range.length += range.location;
        range.location = 0;
    } else {
        range.length += range.location - subRange.location - 1;
        range.location = subRange.location + 1;
    }
    if ([string characterAtIndex:range.location] == '\t') {
        if (range.location < newRange.location) {
            newRange.location -= 1;
            newRange.length += 1;
        }
    } else if (range.length == 0) {
        return newRange;
    }
    
    while (1) {
        if ([string characterAtIndex:range.location] == '\t') {
            [self replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@""];
            if (newRange.length > 0) {
                newRange.length -= 1;
            }
            if (range.length > 0) {
                range.length -= 1;
            }
        }
        
        subRange = [string rangeOfString:@"\n" options:0 range:range];
        if ((subRange.location == NSNotFound) || (subRange.location + 1 == range.location + range.length)) {
            break;
        }
        range.length -= subRange.location - range.location + 1;
        range.location = subRange.location + 1;
    }
    
    [self didChangeText];
    
    return newRange;
}


-(IBAction)toggleComments:(id)sender
{
    NSRange s = [self selectedRange];
    NSTextStorage *textStorage = [self textStorage];
    NSRange r = s;
            r = [self selectionRangeForProposedRange:s
                                         granularity:NSSelectByParagraph];
    [[textStorage string] enumerateSubstringsInRange: r
                                             options: NSStringEnumerationByLines
                                          usingBlock:^(NSString *substring,
                                                       NSRange substringRange,
                                                       NSRange enclosingRange,
                                                       BOOL *stop) {
        NSMutableString *replacementString = [[NSMutableString alloc] init];
        [replacementString appendFormat:@"%@", [self commentLine: substringRange]];
        if ([self shouldChangeTextInRange:substringRange
                        replacementString:replacementString]) {
            [[textStorage mutableString] replaceCharactersInRange:substringRange withString: replacementString];
        }

    }];
    //fix range, look at indent - it's broken
    [self setSelectedRange:r];
    [self didChangeText];
    
}

- (NSMutableString *)commentLine: (NSRange)r
{
    NSString *line = [[self string] substringWithRange: r];
    if ([line hasPrefix:@"// "]) {
        return [NSMutableString stringWithFormat: @"%@", [line substringFromIndex: 3]];
    }
    return [NSMutableString stringWithFormat: @"// %@", line];
}


#pragma mark - NSTextView Overrides

//- (void)insertTab:(id)sender {
//    [self insertText:@"    "];
//}

- (void) textStorageDidProcessEditing:(NSNotification *)note {
//    [self highlight];
    
    //TODO: we might be leaking memory here
//    if(shaderTimer.isValid){
//        [shaderTimer invalidate];
        shaderTimer = nil;
//    }
    
    shaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                   target:self
                                                 selector:@selector(sendShaderCode)
                                                 userInfo:nil
                                                  repeats:NO];
    
}

- (void)sendShaderCode{
    shaderSignal.emit( std::string([[[self textStorage] string] UTF8String]) );
}

//
//#pragma mark - Font Manager
//
//- (IBAction)chooseFont:(id)sender {
//    NSFontManager *fontManager = [NSFontManager sharedFontManager];
//    [fontManager setSelectedFont:[sender ] isMultiple:NO];
//    [fontManager orderFrontFontPanel:nil];
//}
//
- (void)setCurrentFont:(NSFont *)font {
    currentFont = [font copy];
    [self setFont:currentFont];

}

// called by the shared NSFontManager when user chooses a new font or size in the Font Panel
- (void)changeFont:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [self setCurrentFont:[fontManager convertFont:[fontManager selectedFont]]];
}


/////////////////////////////////////////////
//  Cinder signal callback
/////////////////////////////////////////////
- (ci::signals::Signal<void(std::string)>*) ShaderSignal
{
    return &shaderSignal;
}
@end
