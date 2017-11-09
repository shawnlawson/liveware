//
//  MyLineNumberView.m
//  CinderProjectswift
//
//  Created by Shawn Lawson on 8/18/17.
//
//

#import <Foundation/Foundation.h>

#import "MyLineNumberView.h"


int minNumberOfDigits = 2;
CGFloat minVerticalThickness = 32.0;
CGFloat minHorizontalThickness = 32.0;
CGFloat lineNumberPadding = 4.0;



@implementation MyLineNumberView

- (id)initWithScrollView:(NSScrollView *)aScrollView
             orientation:(NSRulerOrientation)orientation
{
    if ((self = [super initWithScrollView:aScrollView
                              orientation:orientation]) != nil)
    {
        
        shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
        shadow.shadowBlurRadius = 1;
        shadow.shadowOffset = NSMakeSize(1, -1);
        
        [self setClientView:[aScrollView documentView]];
     
        [aScrollView.documentView setUsesRuler:YES];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawHashMarksAndLabelsInRect:dirtyRect];
}

- (void)drawHashMarksAndLabelsInRect:(NSRect)aRect
{
    id view = [self clientView];
    
    if ([view isKindOfClass:[NSTextView class]])
    {
        NSLayoutManager			*layoutManager;
        NSTextContainer			*container;
        NSRect					visibleRect;//, markerRect;
        NSRange					visibleGlyphRange, nullRange;
        NSString				*text;//, *labelText;
      //  NSRectArray				rects;
        CGFloat					yinset; //ypos, 
       // NSDictionary			*textAttributes, *currentTextAttributes;
       // NSSize					stringSize, markerSize;
       // NSImage					*markerImage;
       // NSMutableArray			*lines;
        
        layoutManager = [view layoutManager];
        container = [view textContainer];
        text = [view string];
        nullRange = NSMakeRange(NSNotFound, 0);
        
        yinset = [view textContainerInset].height;
        visibleRect = [[[self scrollView] contentView] bounds];
        
   //     [[NSGraphicsContext currentContext] saveGraphicsState];
//        [[NSColor redColor] setFill];
//        [NSBezierPath fillRect:aRect];
        
        //        count all lines
        //        for (myIndex = 0, numberOfLines = 0; myIndex < stringLength; numberOfLines++) {
        //            myIndex = NSMaxRange([text lineRangeForRange:NSMakeRange(index, 0)]);
        //        }
        
        //make wider based on num lines

        
        // Find the characters that are currently visible
        visibleGlyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect inTextContainer:container];
        
        //start drawing each line
        int lineNumber = 1,
        glyphIndex = visibleGlyphRange.location;
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression
                                        regularExpressionWithPattern:@"\n"
                                                             options:NSRegularExpressionCaseInsensitive
                                                               error:&error];
        lineNumber += [regex numberOfMatchesInString:text
                                             options:0
                                               range:NSMakeRange(0, visibleGlyphRange.location)];
       
        
        while (glyphIndex < NSMaxRange(visibleGlyphRange))
        {
            int charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
            NSRange lineRange = [text lineRangeForRange:NSMakeRange(charIndex, 0)];
            NSRange lineGlyphRange = [layoutManager glyphRangeForCharacterRange:lineRange
                                                           actualCharacterRange:nil];
            
            int firstGlyphOfRow = glyphIndex;
            int lineWrapCount = 0;

            //loop through soft-wrap
            while (firstGlyphOfRow < NSMaxRange(lineGlyphRange))
            {
                NSRange effectiveRange = NSMakeRange(0, 0);
                NSRect lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:firstGlyphOfRow
                                                                  effectiveRange:&effectiveRange
                                                         withoutAdditionalLayout:true];
                if (lineWrapCount == 0)
                {
                    [self drawLineNumber:lineNumber
                              atPosition:NSMinY(lineRect) - NSMinY(visibleRect)
                                withRect:aRect];
                } else {
                    //draw wrapped
                }
                
                firstGlyphOfRow = NSMaxRange(effectiveRange);
                lineWrapCount++;
            } //end of soft-wrap loop
            
            glyphIndex = NSMaxRange(lineGlyphRange);
            lineNumber++;
        } //end of all visible glyphs, looped by hardbreak line
        
//        if ([layoutManager extraLineFragmentTextContainer]) {
//            [self drawLineNumber:lineNumber
//                      atPosition:NSMinY(layoutManager.extraLineFragmentRect)
//                        withRect:aRect];
//        }
        
   //     [[NSGraphicsContext currentContext] restoreGraphicsState];
        
        NSTextView *tv = (NSTextView*)[self clientView];
        NSFont *font = tv.font;
        NSString *numText = [NSString stringWithFormat:@"%jd", (intmax_t)0];
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        [attrs setObject:font
                  forKey:NSFontAttributeName];
        [attrs setObject:[NSColor colorWithWhite:1.0 alpha:0.5]
                  forKey:NSForegroundColorAttributeName];
        NSSize numSize = [numText sizeWithAttributes:attrs];
        if( lineNumber > 99){
            minVerticalThickness = numSize.width * 2 + 10;
        } else {
            minVerticalThickness = numSize.width * 3 + 10;
        }
    }
}

- (BOOL) isOpaque{ return NO; }

- (CGFloat) requiredThickness { return minVerticalThickness; }

- (void) drawLineNumber:(int)num atPosition:(CGFloat)yPos withRect:(NSRect)aRect
{    
    NSTextView *tv = (NSTextView*)[self clientView];
    NSFont *font = tv.font;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setObject:font
              forKey:NSFontAttributeName];
    [attrs setObject:[NSColor colorWithWhite:1.0 alpha:0.5]
              forKey:NSForegroundColorAttributeName];
    
    [attrs setObject:shadow
              forKey:NSShadowAttributeName];
    
    NSRect bounds = [self bounds];
    NSString *numText = [NSString stringWithFormat:@"%jd", (intmax_t)num];
    NSSize numSize = [numText sizeWithAttributes:attrs];
    NSPoint point;
    point.x = NSWidth(bounds) - numSize.width - 5.0;
    point.y = yPos - font.xHeight/2.0;
    [numText drawAtPoint:point withAttributes:attrs];
}


- (void) viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
    self.ruleThickness = minHorizontalThickness;
}

 - (void) dealloc
{
     [NSNotificationCenter.defaultCenter removeObserver:self];
    [super dealloc];
}

@end
