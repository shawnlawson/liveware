//
//  FeedbackNSTextView.h
//  CinderProjectBasic
//
//  Created by Shawn Lawson on 9/25/17.
//
//

#import <Cocoa/Cocoa.h>

#import "MyLineNumberView.h"
#include <string>

@interface FeedbackNSTextView : NSTextView <NSTextStorageDelegate> {
    MyLineNumberView * lineNumberView;
    
        NSFont *currentFont;
}


- (void) assignCode:(std::string)code withLanguage:(std::string)lang;

@end

