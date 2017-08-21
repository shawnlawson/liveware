//
//  MyLineNumberView.h
//  CinderProjectswift
//
//  Created by Shawn Lawson on 8/18/17.
//
//

#import <Cocoa/Cocoa.h>
#import <CoreText/CoreText.h>

@interface MyLineNumberView : NSRulerView {

    
}

- (id)initWithScrollView:(NSScrollView *)aScrollView
             orientation:(NSRulerOrientation)orientation;

@end
