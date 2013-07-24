//
//  DKPopUpButtonCell.h
//  DarkKit
//
//  Created by Chad Weider on 3/20/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DarkKit/DarkKit.h>

@interface DKPopUpButtonCell : NSPopUpButtonCell {

}

- (void)drawIndicatorWithFrame:(NSRect)frame inView:(NSView *)controlView;
- (NSBezierPath *)bezierPathWithTriangleInRect:(NSRect)rect up:(bool)up;

@end
