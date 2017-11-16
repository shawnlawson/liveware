//
//  FeedbackNSTextView.m
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/25/17.
//
//


#import <Foundation/Foundation.h>

#import "FeedbackNSTextView.h"
 
@implementation FeedbackNSTextView

//TODO:: disable clipview scrolling and text edit

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil) {
        [self performSelector:@selector(setupLineView) withObject:nil afterDelay:0];
    }
    return self;
}

- (void)setupLineView
{
    lineNumberView = [[MyLineNumberView alloc] initWithScrollView:[self enclosingScrollView]
                                                      orientation:NSVerticalRuler];
    [[self enclosingScrollView] setVerticalRulerView:lineNumberView];
    [[self enclosingScrollView] setHasHorizontalRuler:NO];
    [[self enclosingScrollView] setHasVerticalRuler:YES];
    [[self enclosingScrollView] setRulersVisible:YES];
    [[self enclosingScrollView] setVerticalRulerView:lineNumberView];
    [lineNumberView setClientView:self];
    [self setUsesFontPanel:YES];
    
    [[self textStorage] setDelegate:self];
    NSRange area = NSMakeRange(0, [[self textStorage] length]);
    [[self textStorage] removeAttribute:NSForegroundColorAttributeName range:area];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *oldFont = [NSFont fontWithName:@"fira code" size:16];
    [self setCurrentFont:[fontManager convertFont:oldFont]];
    [self setTextColor:[NSColor whiteColor]];

    
//    [self setDrawsBackground:NO];
//    [self setBackgroundColor:[NSColor clearColor] ];
//    [self.enclosingScrollView setDrawsBackground:NO];
//    [self.enclosingScrollView setBackgroundColor:[NSColor clearColor]];
    
    self.automaticQuoteSubstitutionEnabled = NO;
    //    self.enabledTextCheckingTypes = NO;
    
}

- (void)assignCode:(std::string)code withLanguage:(std::string)lang{
    
    [[self textStorage] replaceCharactersInRange:NSMakeRange(0, [[self textStorage] length])
                                      withString:[NSString stringWithUTF8String:code.c_str()]];
//    NSRange area = NSMakeRange(0, [[self textStorage] length]);
//    [[self textStorage] removeAttribute:NSForegroundColorAttributeName range:area];
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *oldFont = [NSFont fontWithName:@"fira code" size:16];
    
    [self setCurrentFont:[fontManager convertFont:oldFont]];
    [self setTextColor:[NSColor whiteColor]];
//    NSLog(@"%@", self.textStorage.string);
}

- (void) updateRuler {
    [lineNumberView setNeedsDisplay:YES];
}

- (BOOL)isOpaque{ return NO; }

- (void) textStorageDidProcessEditing:(NSNotification *)aNotification {
    //make more efficient by checking for visible range, and threaded
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
//    shadow.shadowBlurRadius = 1;
//    shadow.shadowOffset = NSMakeSize(1, -1);
//    [self.textStorage addAttribute:NSShadowAttributeName
//                             value:shadow
//                             range:NSMakeRange(0, [self.textStorage length])];
}

#pragma mark - Font Window & Manager
//////////////////////////////////
// Font functions
//////////////////////////////////

//
//#pragma mark - Font Manager
//
//- (IBAction)chooseFont:(id)sender {
//    NSFontManager *fontManager = [NSFontManager sharedFontManager];
//    [fontManager setSelectedFont:[sender ] isMultiple:NO];
//    [fontManager orderFrontFontPanel:nil];
//}
//
- (void)setCurrentFont:(NSFont *)font
{
    currentFont = [font copy];
    [self setFont:currentFont];
    
}

// called by the shared NSFontManager when user chooses a new font or size in the Font Panel
- (void)changeFont:(id)sender
{
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [self setCurrentFont:[fontManager convertFont:[fontManager selectedFont]]];
}

@end


