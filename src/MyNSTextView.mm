
//
//  MyNSTextView.m
//  CinderProjectswift
//
//  Created by Shawn Lawson on 8/18/17.
//
//

#import <Foundation/Foundation.h>

#import "MyNSTextView.h"

#include "Tokenize.h"

@implementation MyNSTextView

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
    lineNumberView = [[MyLineNumberView alloc] initWithScrollView:[self enclosingScrollView] orientation:NSVerticalRuler];
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
    //    [[self textStorage] setFont:];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChangeSelection:) name:NSTextViewDidChangeSelectionNotification
                                               object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChange:) name:NSTextDidChangeNotification
                                                   object:self];
    
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


- (void) textStorageDidProcessEditing:(NSNotification *)note {
    //    [self highlight];
    
    //TODO: checked for leaks but didn't find any, still suspicious.
    shaderTimer = nil;
    shaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                   target:self
                                                 selector:@selector(sendShaderCode)
                                                 userInfo:nil
                                                  repeats:NO];
}

#pragma mark - Formatting Commands
//////////////////////////////////
// Formatting functions
//////////////////////////////////
- (void)textViewDidChangeSelection:(NSNotification *)aNotification {
    [self currentLineHighlight];
}

- (void)textDidChange:(NSNotification *)notification {
    [self highlightGLSL];
}

- (void) changeTextFormatFinalize:(NSRange)r andCharLength:(int)numChars
{
    //this fixes softwrap line breaks
    NSMutableParagraphStyle *p = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [p setLineBreakMode:NSLineBreakByCharWrapping];
    [self.textStorage addAttribute:NSParagraphStyleAttributeName
                             value:p
                             range:NSMakeRange(0, [self.textStorage length])];
    
    //this finalizes the change
    [self didChangeText];
    //this corrects any selections
    if(r.length > 0 && [self selectedRange].length > 0) {
        r = [self selectionRangeForProposedRange:NSMakeRange(r.location, r.length + numChars)
                                     granularity:NSSelectByParagraph];
        [self setSelectedRange:[self selectionRangeForProposedRange:r
                                                        granularity:NSSelectByParagraph]];
    }
    
}

- (BOOL) changeTextAt:(NSRange)aRange withString:(NSString*)aString
{
    //ask to change
    if([self shouldChangeTextInRange:aRange
                   replacementString:aString])
    {
        //make change
        [self.textStorage beginEditing];
        [self.textStorage replaceCharactersInRange:aRange
                                        withString:aString];
        [self.textStorage endEditing];
        return YES;
    } else {
        return NO;
    }
}

// override to keep /t characters out
- (void)insertTab:(id)sender
{
    NSRange r = [self selectedRange];
    [self changeTextAt:r withString:@"    "];
    [self changeTextFormatFinalize:NSMakeRange(r.location,0) andCharLength:0];
}

- (void) currentLineHighlight
{
    [self.layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                               forCharacterRange:NSMakeRange(0, [self.textStorage length])];
    
    [self.layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                        value:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3]
                            forCharacterRange:[[self.textStorage string] lineRangeForRange:NSMakeRange([self selectedRange].location, 0)]];
}

- (void) errorLineHighlight:(std::string)errors
{
    [self.layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName
                               forCharacterRange:NSMakeRange(0, [self.textStorage length])];
    
    [self.layoutManager removeTemporaryAttribute:NSUnderlineColorAttributeName
                               forCharacterRange:NSMakeRange(0, [self.textStorage length])];
    
    [self.layoutManager removeTemporaryAttribute:NSToolTipAttributeName
                               forCharacterRange:NSMakeRange(0, [self.textStorage length])];
    
    std::istringstream f(errors);
    std::string line;
    int row = 0;
    NSString * annotation;
    //    std::cout << errors << std::endl;
    while(std::getline(f, line))
    {
        std::vector<std::string> tokens;
        Tokenize(line, tokens, ":");
        
        //only look if there is something
        if (tokens.size() > 3)
        {
            //first error always tells where
            if (0 == tokens[0].compare("FRAGMENT")) {
                row = std::stoi(tokens[3]) -1; //-1 is offset from header
                //if multiple then token[0] is dropped
            } else {
                row = std::stoi(tokens[2]) -1;
                
            }
            
            //convert row to a NSRange
            unsigned numberOfLines, myIndex, stringLength = [self.textStorage length];
            for (myIndex = 0, numberOfLines = 0;
                 myIndex < stringLength && numberOfLines < row;
                 numberOfLines++) {
                myIndex = NSMaxRange([[self.textStorage string] lineRangeForRange:NSMakeRange(myIndex, 0)]);
            }
            
            [self.layoutManager addTemporaryAttribute:NSUnderlineColorAttributeName
                                                value:[NSColor colorWithCalibratedRed:1 green:.3 blue:0.3 alpha:1.]
                                    forCharacterRange:[[self.textStorage string] lineRangeForRange:NSMakeRange(myIndex, 0)]];
            
            [self.layoutManager addTemporaryAttribute:NSUnderlineStyleAttributeName
                                                value:@(NSUnderlineStyleThick)
                                    forCharacterRange:[[self.textStorage string] lineRangeForRange:NSMakeRange(myIndex, 0)]];
            
            
            //account for all lengths of information
            if (tokens.size() > 5) {
                annotation = [NSString stringWithFormat:@"%s : %s",
                              tokens[4].c_str(), tokens[5].c_str() ];
                
            } else if (tokens.size() > 4) {
                annotation = [NSString stringWithFormat:@"%s",
                              tokens[4].c_str() ];
            }
            else {
                annotation = [NSString stringWithFormat:@"%s",
                              tokens[3].c_str() ];
            }
            
            [self.layoutManager addTemporaryAttribute:NSToolTipAttributeName
                                                value:annotation
                                    forCharacterRange:[[self.textStorage string] lineRangeForRange:NSMakeRange(myIndex, 0)]];
        }
    }
}

- (void) highlightGLSL
{
    NSScanner *scanner = [NSScanner scannerWithString:[self.textStorage string]];
    unsigned preScan = 0;
    scanner.charactersToBeSkipped =  [NSCharacterSet whitespaceCharacterSet];

    while (![scanner isAtEnd])
    {
        preScan = scanner.scanLocation;
       
        //pre-compiler
        if([scanner scanString:@"#" intoString:NULL])
        {
            [scanner scanUpToString:@"\n" intoString:NULL ];
            [self setTextColor:[NSColor brownColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
             continue;
        }
        //comments
        if([scanner scanString:@"//" intoString:NULL])
        {
            [scanner scanUpToString:@"\n" intoString:NULL ];
            [self setTextColor:[NSColor grayColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
            continue;
        }
        //strings
        if([scanner scanString:@"\"" intoString:NULL])
        {
            [scanner scanUpToString:@"\"" intoString:NULL ];
            [self setTextColor:[NSColor redColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
            continue;
        }
        //words & numbers, ie vec4, etc
        if([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet]
                               intoString:NULL] &&
           [scanner scanInt:NULL])
        {
            [self setTextColor:[NSColor blueColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
            continue;
        }
        scanner.scanLocation = preScan;
        //words & numbers, ie vec4, etc
        if([scanner scanCharactersFromSet:[NSCharacterSet letterCharacterSet]
                               intoString:NULL])
        {
            [self setTextColor:[NSColor blueColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
            continue;
        }
        //numbers
        if([scanner scanDouble:NULL])
        {
            [self setTextColor:[NSColor purpleColor]
                         range:NSMakeRange(preScan, scanner.scanLocation - preScan)];
            continue;
        }
        //else
        [scanner scanCharactersFromSet:[NSCharacterSet punctuationCharacterSet]
                           intoString:NULL];
        
        [scanner scanCharactersFromSet:[NSCharacterSet symbolCharacterSet]
                            intoString:NULL];
        
        [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet]
                            intoString:NULL];
//        scanner.scanLocation += 1;
        
    }
}
#pragma mark - UI Commands
//////////////////////////////////
// UI functions
//////////////////////////////////
-(IBAction)indent:(id)sender
{
    NSRange r = [self selectionRangeForProposedRange:[self selectedRange]
                                         granularity:NSSelectByParagraph];
    __block int numChars = 0;
    [self.textStorage.string enumerateSubstringsInRange: r
                                                options: NSStringEnumerationByLines
                                             usingBlock:^(NSString *substring,
                                                          NSRange substringRange,
                                                          NSRange enclosingRange,
                                                          BOOL *stop)
     {
         NSRange replaceRange = NSMakeRange(substringRange.location, 0);
         if([self changeTextAt:replaceRange withString:@"    "])
             numChars += 4;
     }
     ];
    
    [self changeTextFormatFinalize:r andCharLength:numChars];
}

-(IBAction)dedent:(id)sender
{
    NSRange r = [self selectionRangeForProposedRange:[self selectedRange]
                                         granularity:NSSelectByParagraph];
    __block int numChars = 0;
    [self.textStorage.string enumerateSubstringsInRange: r
                                                options: NSStringEnumerationByLines
                                             usingBlock:^(NSString *substring,
                                                          NSRange substringRange,
                                                          NSRange enclosingRange,
                                                          BOOL *stop)
     {
         if ([substring hasPrefix:@"    "])
         {
             NSRange replaceRange = NSMakeRange(substringRange.location, 4);
             if([self changeTextAt:replaceRange withString:@""])
                 numChars -= 4;
         } else if ([substring hasPrefix:@"   "])
         {
             NSRange replaceRange = NSMakeRange(substringRange.location, 3);
             if([self changeTextAt:replaceRange withString:@""])
                 numChars -= 3;
         } else if ([substring hasPrefix:@"  "])
         {
             NSRange replaceRange = NSMakeRange(substringRange.location, 2);
             if([self changeTextAt:replaceRange withString:@""])
                 numChars -= 2;
         } else if ([substring hasPrefix:@" "])
         {
             NSRange replaceRange = NSMakeRange(substringRange.location, 1);
             if([self changeTextAt:replaceRange withString:@""])
                 numChars -= 1;
         }
     }
     ];
    
    [self changeTextFormatFinalize:r andCharLength:numChars];
}

-(IBAction)toggleComments:(id)sender
{
    NSRange r = [self selectionRangeForProposedRange:[self selectedRange]
                                         granularity:NSSelectByParagraph];
    __block int numChars = 0;
    [self.textStorage.string enumerateSubstringsInRange: r
                                                options: NSStringEnumerationByLines
                                             usingBlock:^(NSString *substring,
                                                          NSRange substringRange,
                                                          NSRange enclosingRange,
                                                          BOOL *stop)
     {
         if ([substring hasPrefix:@"// "])
         {
             NSRange replaceRange = NSMakeRange(substringRange.location, 3);
             if([self changeTextAt:replaceRange withString:@""])
                 numChars -= 3;
         } else {
             NSRange replaceRange = NSMakeRange(substringRange.location, 0);
             if([self changeTextAt:replaceRange withString:@"// "])
                 numChars += 3;
         }
     }
     ];
    
    [self changeTextFormatFinalize:r andCharLength:numChars];
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
- (void)setCurrentFont:(NSFont *)font {
    currentFont = [font copy];
    [self setFont:currentFont];
    
}

// called by the shared NSFontManager when user chooses a new font or size in the Font Panel
- (void)changeFont:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [self setCurrentFont:[fontManager convertFont:[fontManager selectedFont]]];
}

#pragma mark - Cinder Callback
/////////////////////////////////////////////
//  Cinder signal callback
/////////////////////////////////////////////
- (ci::signals::Signal<void(std::string)>*) ShaderSignal
{
    return &shaderSignal;
}

- (void)sendShaderCode{
    shaderSignal.emit( std::string([[[self textStorage] string] UTF8String]) );
}


@end


